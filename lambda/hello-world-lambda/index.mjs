import { exportJWK, jwtVerify, importJWK } from 'jose';
import crypto from 'crypto';
import { createClient } from 'redis'
// import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm'


// const ssmClient = new SSMClient({ region: process.env.REGION });
let client

export const handler = async (event, context) => {
    // const organizations = await getParameter('waiting-room'); # for some reason it didn't work
    const { authorization } = event?.headers
    const { domainName } = event?.requestContext
    const destination = process.env.DESTINATION
    const orgIds = process.env.ENABLED_FOR_ORGS.split(',')
    console.log("########### 0", JSON.stringify(event, null, 2));

    if (!orgIds || !orgIds.length) {
        return getPolicy('Allow', destination);
    }

    if (authorization) {
        const token = authorization

        let isAllowed = 'Deny';
        try {
            const publicJwk = await convertKeyStringToRsaKey(process.env.JWT_PUBLIC_KEY);
            const cryptoKey = await importJWK(publicJwk, 'RS256');

            const { payload } = await jwtVerify(token || '', cryptoKey);

            if (!orgIds.includes(payload.orgId)) {
                return getPolicy('Allow', destination);
            }

            // Check expiration
            const currentDate = new Date();
            const expiresAt = new Date(payload.exp * 1000); // Convert to milliseconds

            if (currentDate < expiresAt) {
                isAllowed = 'Allow';

                // store token in redis
                const url = process.env.REDIS_URL;
                client = createClient({
                    socket: {
                        host: url,
                        port: 6379,
                    }
                });

                client.on('error', error => console.error('Redis Client Error:', error));
                client.on('connect', () => console.log('Redis Client Connected!'));

                await client.connect();

                await storeData({ redisClient: client, value: payload.token, orgId: payload.orgId })
            }
            const policy = getPolicy(isAllowed, destination);
            console.log('##################### 7', {
                policy: JSON.stringify(policy)
            });
            return policy;
        } catch (err) {
            console.log('JWT verification failed:', err.message);
            return getPolicy('Deny', destination)
        }
    }
};

const convertKeyStringToRsaKey = async (keyString) => {
    // Ensure the key string is properly formatted
    const formattedKeyString = keyString.replace(/\\n/g, '\n');
    const cryptoPublicKey = crypto.createPublicKey(formattedKeyString);
    return await exportJWK(cryptoPublicKey); // publicJwk
};

const storeData = async (input) => {
    const { redisClient, value, orgId } = input
    try {

        const key = `${orgId}:${value}`; // Prefix the value with orgId
        // Check if the value already exists in Redis
        const existingValue = await redisClient.get(key);

        if (existingValue) {
            // Refresh the TTL if the value exists
            await redisClient.expire(key, 60);
            console.log('Value exists. TTL refreshed to 60 seconds:', key);
            return true
        } else {
            // Set the value with a TTL of 60 seconds
            await redisClient.set(key, value, {
                EX: 60 // Time to live in seconds
            });
            return true
        }
    } catch (e) {
        console.log(e);
        return false
    } finally {
        // await redisClient.disconnect();
    }
}

const getPolicy = (isAllowed, destination) => {
    return {
        policyDocument: {
            Version: "2012-10-17",
            Statement: [
                {
                    Action: "execute-api:Invoke",
                    Resource: [destination],
                    Effect: isAllowed,
                },
            ],
        },
    }
}


// const getParameter = async (name) => {
//     try {
//         const command = new GetParameterCommand({
//             Name: name,
//             // WithDecryption: true // Set to true if the parameter is encrypted
//         });

//         const response = await ssmClient.send(command);
//         return response.Parameter.Value;
//     } catch (error) {
//         console.error('Error retrieving parameter:', error);
//         throw error; // Rethrow the error for proper handling
//     }
// };
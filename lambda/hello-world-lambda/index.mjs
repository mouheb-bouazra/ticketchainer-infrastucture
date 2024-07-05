import { exportJWK, jwtVerify, importJWK } from 'jose';
import crypto from 'crypto';
import { createClient } from 'redis'


let client

export const handler = async (event, context) => {
    const { authorization } = event?.headers
    const { domainName } = event?.requestContext
    const destination = process.env.DESTINATION
    console.log({
        domainName,
        methodArn: event.methodArn,
        destination
    })
    if (authorization) {
        const token = authorization

        let isAllowed = 'Deny';
        try {
            console.log('##################### 1');
            const publicJwk = await convertKeyStringToRsaKey(process.env.JWT_PUBLIC_KEY);
            const cryptoKey = await importJWK(publicJwk, 'RS256');

            const { payload } = await jwtVerify(token || '', cryptoKey);
            console.log('##################### 2', payload);

            // Check expiration
            const currentDate = new Date();
            const expiresAt = new Date(payload.exp * 1000); // Convert to milliseconds

            console.log('##################### 3', currentDate < expiresAt);
            if (currentDate < expiresAt) {
                isAllowed = 'Allow';

                console.log('##################### 3.1', isAllowed);
                // store token in redis
                const url = process.env.REDIS_URL;
                client = createClient({
                    socket: {
                        host: url,
                        port: 6379,
                    }
                });

                console.log('##################### 4 connecting to redis');
                client.on('error', error => console.error('Redis Client Error:', error));
                client.on('connect', () => console.log('Redis Client Connected!'));

                await client.connect();
                console.log('##################### 5 connected to redis');

                await storeData({ redisClient: client, value: payload.token, orgId: payload.orgId })
                console.log('##################### 6 stored token in redis');
            }

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
            };
        } catch (err) {
            console.log('JWT verification failed:', err.message);
            return {
                policyDocument: {
                    Version: "2012-10-17",
                    Statement: [
                        {
                            Action: "execute-api:Invoke",
                            Resource: [destination],
                            Effect: 'Deny',
                        },
                    ],
                },
            };
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

const AWS = require('aws-sdk');
const https = require('https');
const http = require('http');

/**
 * AWS Lambda function that processes DynamoDB stream events
 * and sends webhook notifications to the Phoenix application
 * when records are inserted into the AuditEvents table.
 */

// Configuration - these can be set as environment variables
const WEBHOOK_URL = process.env.WEBHOOK_URL || 'http://host.docker.internal:4000/api/webhook/dynamodb-stream';
const WEBHOOK_TIMEOUT = parseInt(process.env.WEBHOOK_TIMEOUT) || 10000; // 10 seconds
const TABLE_NAME = process.env.TABLE_NAME || 'AuditEvents';

exports.handler = async (event, context) => {
    console.log('DynamoDB Stream Lambda triggered');
    console.log('Event:', JSON.stringify(event, null, 2));
    
    try {
        // Filter records for the AuditEvents table and INSERT events
        const relevantRecords = event.Records.filter(record => {
            const tableName = record.eventSourceARN.split('/')[1];
            const eventName = record.eventName;
            
            console.log(`Processing record: table=${tableName}, event=${eventName}`);
            
            // Only process INSERT events for the AuditEvents table
            return tableName === TABLE_NAME && eventName === 'INSERT';
        });
        
        if (relevantRecords.length === 0) {
            console.log('No relevant records to process');
            return {
                statusCode: 200,
                body: JSON.stringify({ message: 'No relevant records to process' })
            };
        }
        
        console.log(`Processing ${relevantRecords.length} relevant records`);
        
        // Send webhook for each relevant record
        const webhookPromises = relevantRecords.map(record => 
            sendWebhook(record)
        );
        
        const results = await Promise.allSettled(webhookPromises);
        
        // Check results
        const successful = results.filter(result => result.status === 'fulfilled').length;
        const failed = results.filter(result => result.status === 'rejected').length;
        
        console.log(`Webhook results: ${successful} successful, ${failed} failed`);
        
        // Log failures
        results.forEach((result, index) => {
            if (result.status === 'rejected') {
                console.error(`Webhook ${index + 1} failed:`, result.reason);
            }
        });
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Stream processing completed',
                processed: relevantRecords.length,
                successful: successful,
                failed: failed
            })
        };
        
    } catch (error) {
        console.error('Error processing DynamoDB stream:', error);
        
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error processing stream',
                error: error.message
            })
        };
    }
};

/**
 * Sends a webhook notification with the DynamoDB stream record
 * @param {Object} record - DynamoDB stream record
 * @returns {Promise} - Promise that resolves when webhook is sent
 */
async function sendWebhook(record) {
    return new Promise((resolve, reject) => {
        const payload = {
            Records: [record]
        };
        
        const postData = JSON.stringify(payload);
        const url = new URL(WEBHOOK_URL);
        
        // Choose the appropriate HTTP module based on protocol
        const httpModule = url.protocol === 'https:' ? https : http;
        
        const options = {
            hostname: url.hostname,
            port: url.port || (url.protocol === 'https:' ? 443 : 80),
            path: url.pathname + (url.search || ''),
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData),
                'User-Agent': 'DynamoDB-Stream-Lambda/1.0'
            },
            timeout: WEBHOOK_TIMEOUT
        };
        
        console.log(`Sending webhook to: ${WEBHOOK_URL}`);
        console.log('Payload:', JSON.stringify(payload, null, 2));
        
        const req = httpModule.request(options, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                console.log(`Webhook response status: ${res.statusCode}`);
                console.log('Webhook response:', data);
                
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve({
                        statusCode: res.statusCode,
                        body: data
                    });
                } else {
                    reject(new Error(`Webhook failed with status ${res.statusCode}: ${data}`));
                }
            });
        });
        
        req.on('error', (error) => {
            console.error('Webhook request error:', error);
            reject(error);
        });
        
        req.on('timeout', () => {
            console.error('Webhook request timeout');
            req.destroy();
            reject(new Error('Webhook request timeout'));
        });
        
        // Send the request
        req.write(postData);
        req.end();
    });
}
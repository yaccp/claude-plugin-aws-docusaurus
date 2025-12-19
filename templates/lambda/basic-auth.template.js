'use strict';

/**
 * Lambda@Edge Basic Authentication Handler
 *
 * This function runs at CloudFront edge locations on every viewer request.
 * It validates HTTP Basic Authentication credentials before allowing access.
 *
 * Usage:
 *   1. Replace ${AUTH_USERNAME} and ${AUTH_PASSWORD} with actual credentials
 *   2. Deploy to Lambda in us-east-1 region
 *   3. Publish a version (Lambda@Edge requires versioned functions)
 *   4. Associate with CloudFront distribution at viewer-request event
 *
 * Security Notes:
 *   - For production, consider using AWS Secrets Manager instead of hardcoded credentials
 *   - Credentials are checked at edge locations for low-latency authentication
 *   - Failed attempts receive 401 Unauthorized with WWW-Authenticate challenge
 */

exports.handler = (event, context, callback) => {
    // Extract the request from CloudFront event
    const request = event.Records[0].cf.request;
    const headers = request.headers;

    // Authentication credentials
    // TODO: Replace with actual values or use environment variables
    const authUser = '${AUTH_USERNAME}';
    const authPass = '${AUTH_PASSWORD}';

    // Compute expected Authorization header value
    const authString = 'Basic ' + Buffer.from(authUser + ':' + authPass).toString('base64');

    // Check if Authorization header exists and matches expected value
    if (typeof headers.authorization === 'undefined' ||
        headers.authorization[0].value !== authString) {

        // Return 401 Unauthorized with Basic Auth challenge
        const response = {
            status: '401',
            statusDescription: 'Unauthorized',
            body: 'Unauthorized - Please provide valid credentials',
            headers: {
                'www-authenticate': [{
                    key: 'WWW-Authenticate',
                    value: 'Basic realm="Secure Area"'
                }],
                'content-type': [{
                    key: 'Content-Type',
                    value: 'text/plain; charset=utf-8'
                }]
            }
        };

        callback(null, response);
        return;
    }

    // Authentication successful - allow request to proceed
    callback(null, request);
};

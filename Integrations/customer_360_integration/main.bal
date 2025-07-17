import ballerina/http;
import ballerina/io;

// HTTP service for client 360 endpoint
service / on new http:Listener(servicePort) {

    // Resource function to handle GET /clients/{clientId}/quotes/summary
    resource function get clients/[string clientId]/quotes/summary(string productName, decimal coverageAmount) returns ClientQuoteSummary|http:InternalServerError|http:NotFound {

        // Get client details from database
        ClientInfo|error clientResult = getClientDetails(clientId);
        if clientResult is error {
            io:println("Error etrieving client details: " + clientResult.message());
            if clientResult.message() == "Client not found" {
                http:NotFound notFoundResponse = {
                    body: {
                        message: string `Client with ID ${clientId} not found`
                    }
                };
                return notFoundResponse;
            }
            http:InternalServerError errorResponse = {
                body: {
                    message: "Error retrieving client details"
                }
            };
            return errorResponse;
        }

        // Get existing policies
        // Policy[]|error policiesResult = getExistingPolicies(clientId);
        // if policiesResult is error {
        //     http:InternalServerError errorResponse = {
        //         body: {
        //             message: "Error retrieving client policies"
        //         }
        //     };
        //     return errorResponse;
        // }

        // Get new quote from external service
        QuoteResponse|error quoteResult = getNewQuote(productName, clientResult.age, clientResult.state, coverageAmount);
        if quoteResult is error {
            io:println("Error retrieving quote information: " + quoteResult.message());
            http:InternalServerError errorResponse = {
                body: {
                    message: "Error retrieving quote information"
                }
            };
            return errorResponse;
        }

        ClientQuoteSummary finalQuoteSummary = transform(clientResult, quoteResult);

        return finalQuoteSummary;
    }
}

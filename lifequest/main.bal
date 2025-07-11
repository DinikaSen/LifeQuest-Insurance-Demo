import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;


// HTTP service to expose client data from database data as API
service / on new http:Listener(8080) {

    //Get client data by client ID
    isolated resource function get clients/[string clientId]() returns Client|http:NotFound|http:InternalServerError {
        //Client|error clientResult = getClientById(clientId);
        mysql:Client dbClient = getMysqlClient();

        sql:ParameterizedQuery query = `SELECT * FROM clients WHERE client_id = ${clientId}`;
    
        Client|sql:Error clientResult = dbClient->queryRow(query);

        if clientResult is error {
            if clientResult is sql:NoRowsError {
                http:NotFound notFound = {
                    body: createErrorResponse("Client not found", string `client with ID ${clientId} not found`)
                };
                return notFound;
            }
            string errorMessage = clientResult.message();
            http:InternalServerError serverError = {
                body: createErrorResponse("Failed to retrieve client", errorMessage)
            };
            return serverError;
        }
        return clientResult;
        //return createSuccessResponse(clientResult, "Client retrieved successfully");
    }
}
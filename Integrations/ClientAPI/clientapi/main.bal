import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /lifequest on httpDefaultListener {
    resource function get clients/[string clientId]() returns http:Ok|http:NotFound|http:InternalServerError {
        do {
            mysql:Client dbClient = getMysqlClient();
            sql:ParameterizedQuery query = `SELECT * FROM clients WHERE client_id = ${clientId}`;
            Client|sql:Error clientResult = dbClient->queryRow(query);

            if clientResult is error {
                if clientResult is sql:NoRowsError {
                    http:NotFound notFound = {
                        body: createErrorResponse("Client not found", string `Client with ID ${clientId} not found`)
                    };
                    return notFound;
                }
                string errorMessage = clientResult.message();
                http:InternalServerError serverError = {
                    body: createErrorResponse("Failed to retrieve client", errorMessage)
                };
                return serverError;
            }
            
            http:Ok success = {
                body: createSuccessResponse(clientResult, "Client retrieved successfully")
            };
            return success;
        } on fail error err {
            http:InternalServerError serverError = {
                body: createErrorResponse("Internal server error", err.message())
            };
            return serverError;
        }
    }

    resource function post clients(@http:Payload ClientCreateRequest clientData) returns http:Created|http:BadRequest|http:InternalServerError {
        do {
            mysql:Client dbClient = getMysqlClient();
            sql:ParameterizedQuery insertQuery = `INSERT INTO clients (client_id, first_name, last_name, date_of_birth, email, phone) 
                                                  VALUES (${clientData.client_id}, ${clientData.first_name}, ${clientData.last_name}, 
                                                         ${clientData.date_of_birth}, ${clientData.email}, ${clientData.phone})`;
            
            sql:ExecutionResult|sql:Error insertResult = dbClient->execute(insertQuery);

            if insertResult is error {
                string errorMessage = insertResult.message();
                http:InternalServerError serverError = {
                    body: createErrorResponse("Failed to create client", errorMessage)
                };
                return serverError;
            }

            // Create the client record to return
            Client createdClient = {
                client_id: clientData.client_id,
                first_name: clientData.first_name,
                last_name: clientData.last_name,
                date_of_birth: clientData.date_of_birth,
                email: clientData.email,
                phone: clientData.phone
            };

            http:Created created = {
                body: createSuccessResponse(createdClient, "Client created successfully")
            };
            return created;
        } on fail error err {
            http:InternalServerError serverError = {
                body: createErrorResponse("Internal server error", err.message())
            };
            return serverError;
        }
    }
}
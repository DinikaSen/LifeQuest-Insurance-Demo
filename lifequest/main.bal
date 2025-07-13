import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;
import ballerina/regex;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /clients on httpDefaultListener {
    resource function get [string clientId]() returns Client|error|json|http:NotFound|http:InternalServerError {
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
            return clientResult;
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

service /agents on httpDefaultListener {
    resource function get [string agentId]/eligibility(string product, string state) returns http:InternalServerError|http:NotFound|error|AgentEligibilityResponse {
        do {
            mysql:Client dbClient = getMysqlClient();

            sql:ParameterizedQuery query = `SELECT 
                    a.agent_id,
                    a.name,
                    GROUP_CONCAT(DISTINCT al.license_code ORDER BY al.license_code) AS licenses,
                    GROUP_CONCAT(DISTINCT at.training_code ORDER BY at.training_code) AS trainings
                FROM 
                    agents a
                LEFT JOIN agent_licenses al ON a.agent_id = al.agent_id
                LEFT JOIN agent_trainings at ON a.agent_id = at.agent_id
                WHERE 
                    a.agent_id = ${agentId}
                GROUP BY 
                    a.agent_id, a.name;`;

            Agent|sql:Error agentResult = dbClient->queryRow(query);

            if agentResult is error {
                if agentResult is sql:NoRowsError {
                    http:NotFound notFound = {
                        body: createErrorResponse("Agent not found", string `Agent with ID ${agentId} not found`)
                    };
                    return notFound;
                }
                string errorMessage = agentResult.message();
                http:InternalServerError serverError = {
                    body: createErrorResponse("Failed to retrieve agent", errorMessage)
                };
                return serverError;
            }
            log:printInfo("Agent data retireved from database : " + agentResult.toBalString());
            string[] agentLicensesList = regex:split(agentResult.licenses, ",");
            string[] agentTrainingsList = regex:split(agentResult.trainings, ",");
            RuleEngineRequest requestToRuleEngine = {state: state, product: product, licenses: agentLicensesList, trainings: agentTrainingsList};
            RuleEngineResponse eligibilityResult = check ruleEngine->post("", requestToRuleEngine);

            AgentEligibilityResponse response = {
                agent_id: agentId,
                product: product,
                eligible: eligibilityResult.eligible,
                reasons: eligibilityResult.reasons,
                suggestions: eligibilityResult.suggestions
            };
            return response;

        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

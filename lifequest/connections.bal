import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string dbHost = ?;
configurable int dbPort = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;

// MySQL client initialization with proper configuration
final mysql:Client mysqlClient = check new (
    host = dbHost,
    port = dbPort,
    database = dbName,
    user = dbUser,
    password = dbPassword
);

// Function to get MySQL client
public isolated function getMysqlClient() returns mysql:Client {
    return mysqlClient;
}

// Function to close database connection
public isolated function closeDatabaseConnection() returns sql:Error? {
    return mysqlClient.close();
}

final http:Client ruleEngine = check new ("https://b48cc93e-fa33-4420-a155-bc653b4d46be-dev.e1-eu-north-azure.choreoapis.dev/lbrk/ruleengine/v1.0/eligibility");

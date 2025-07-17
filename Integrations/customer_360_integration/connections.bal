import ballerinax/mysql;
import ballerina/http;
import ballerinax/mysql.driver as _;

// MySQL client initialization
mysql:Client mysqlClient = check new (
    host = dbHost,
    user = dbUser,
    password = dbPassword,
    database = dbName,
    port = dbPort
);

// HTTP client for quote service
http:Client quoteServiceClient = check new (quoteServiceUrl);
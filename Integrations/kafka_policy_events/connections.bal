import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

// MySQL client initialization with proper configuration
// MySQL client initialization with proper configuration
final mysql:Client clientDB = check new (
    host = clientDBUrl,
    port = clientDBPort,
    database = clientDBName,
    user = clientDBUser,
    password = clientDBPassword
);

final http:Client quotesEndpoint = check new (quoteApprovalEndpoint);

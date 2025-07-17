import ballerina/ftp;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

// Initialize clients at module level
final ftp:Client sftpClient = check new (getSftpConfig());
final mysql:Client dbClient = check new  (host = dbHost, user = dbUsername, password = dbPassword, database = dbName, port = dbPort, options = getMySQLConfig());
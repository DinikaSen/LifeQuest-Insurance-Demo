import ballerina/ftp;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

// Initialize clients at module level
final ftp:Client sftpClient = check new (getSftpConfig());

sql:ConnectionPool connPool = { 
    maxOpenConnections: 5,
    maxConnectionLifeTime: 1800,
    minIdleConnections: 2 
};

// MySQL client initialization with proper configuration
final mysql:Client dbClient = check new (
    host = dbHost,
    port = dbPort,
    database = dbName,
    user = dbUsername,
    password = dbPassword,
    connectionPool = connPool
);

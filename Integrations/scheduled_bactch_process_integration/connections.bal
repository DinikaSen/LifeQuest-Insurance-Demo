import ballerina/ftp;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

// SFTP client initialization
public final ftp:Client sftpClient = check new (sftpConfig);

// MySQL client initialization
public final mysql:Client mysqlClient = check new (
    host = dbHost,
    port = dbPort,
    user = dbUsername,
    password = dbPassword,
    database = dbName,
    options = mysqlOptions
);
import ballerina/ftp;
import ballerinax/mysql;

// SFTP Configuration
configurable string sftpHost = ?;
configurable int sftpPort = 22;
configurable string sftpUsername = ?;
configurable string sftpPassword = ?;

// MySQL Configuration
configurable string dbHost = ?;
configurable int dbPort = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;
configurable string dbName= ?;

// Scheduling Configuration
configurable int scheduledHour = 1;
configurable int scheduledMinute = 0;

// HTTP Service Configuration
configurable int httpPort = 8080;

// SFTP client configuration
public final ftp:ClientConfiguration sftpConfig = {
    protocol: ftp:SFTP,
    host: sftpHost,
    port: sftpPort,
    auth: {
        credentials: {
            username: sftpUsername,
            password: sftpPassword
        }
    }
};

// MySQL client configuration
public final mysql:Options mysqlOptions = {};
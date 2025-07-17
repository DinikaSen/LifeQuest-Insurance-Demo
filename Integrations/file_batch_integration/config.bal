import ballerina/ftp;
import ballerinax/mysql;

// SFTP Configuration
configurable string sftpHost = ?;
configurable int sftpPort = 22;
configurable string sftpUsername = ?;
configurable string sftpPassword = ?;

// MySQL Configuration
configurable string dbHost = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = 3306;

// File paths and patterns
configurable string sftpIncomingPath = "/lifequest/underwriting/incoming/";
configurable string sftpOutgoingPath = "/lifequest/underwriting/outgoing/";

// Scheduling Configuration - configurable to the minute
configurable int readHour = 1;      // Hour for file reading (0-23)
configurable int readMinute = 0;    // Minute for file reading (0-59)
configurable int writeHour = 5;     // Hour for file writing (0-23)
configurable int writeMinute = 0;   // Minute for file writing (0-59)
public function getSftpConfig() returns ftp:ClientConfiguration {
    return {
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
}

public function getMySQLConfig() returns mysql:Options {
    return {};
}

// Get configured read time as string for display
public function getReadTimeString() returns string {
    return string `${readHour.toString().padStart(2, "0")}:${readMinute.toString().padStart(2, "0")}`;
}

// Get configured write time as string for display
public function getWriteTimeString() returns string {
    return string `${writeHour.toString().padStart(2, "0")}:${writeMinute.toString().padStart(2, "0")}`;
}
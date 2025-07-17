import ballerina/io;
import ballerina/http;

// HTTP service to keep the application running and provide monitoring endpoints
service /api on new http:Listener(8080) {
    
    // Initialize scheduler when service starts
    function init() returns error? {
        io:println("Starting LifeQuest Underwriting Feed Processor...");
        io:println("Configurable scheduling enabled:");
        io:println("- File reading scheduled at: " + getReadTimeString());
        io:println("- File writing scheduled at: " + getWriteTimeString());
        
        // Initialize the minute-by-minute scheduler
        error? schedulerResult = initializeSchedulerIfNeeded();
        if schedulerResult is error {
            io:println("Error initializing scheduler: " + schedulerResult.message());
            return schedulerResult;
        }
        
        io:println("Scheduler initialized successfully!");
        io:println("HTTP Service running on http://localhost:8080");
        io:println("Endpoints available:");
        io:println("  - Health check: http://localhost:8080/api/health");
        io:println("  - Status: http://localhost:8080/api/status");
        io:println("  - Configuration: http://localhost:8080/api/config");
        io:println("  - Manual read trigger: POST http://localhost:8080/api/trigger/read");
        io:println("  - Manual write trigger: POST http://localhost:8080/api/trigger/write");
    }
    
    // Health check endpoint
    resource function get health() returns json {
        return {
            status: "UP",
            serviceName: "LifeQuest Underwriting Feed Processor",
            schedulerStatus: getSchedulerStatus()
        };
    }
    
    // Detailed status endpoint
    resource function get status() returns json {
        return getSchedulerStatus();
    }
    
    // Manual trigger endpoint for file reading (for testing)
    resource function post trigger/read() returns json|error {
        io:println("Manual trigger: File reading");
        error? result = executeFileReading();
        if result is error {
            return {
                status: "ERROR",
                message: result.message()
            };
        }
        return {
            status: "SUCCESS",
            message: "File reading triggered manually",
            recordsProcessed: processedRecords.length()
        };
    }

    // Manual trigger endpoint for file writing (for testing)
    resource function post trigger/write() returns json|error {
        io:println("Manual trigger: File writing");
        error? result = executeFileWriting();
        if result is error {
            return {
                status: "ERROR",
                message: result.message()
            };
        }
        return {
            status: "SUCCESS",
            message: "File writing triggered manually"
        };
    }
    
    // Configuration endpoint to view current settings
    resource function get config() returns json {
        return {
            readTime: {
                hour: readHour,
                minute: readMinute,
                formatted: getReadTimeString()
            },
            writeTime: {
                hour: writeHour,
                minute: writeMinute,
                formatted: getWriteTimeString()
            },
            sftpPaths: {
                incoming: sftpIncomingPath,
                outgoing: sftpOutgoingPath
            }
        };
    }
    
    // Root endpoint for basic service info
    resource function get .() returns json {
        return {
            serviceName: "LifeQuest Underwriting Feed Processor",
            version: "1.0.0",
            status: "Running",
            packageName: "file_batch_integration",
            endpoints: [
                "GET /api/health - Health check",
                "GET /api/status - Detailed status", 
                "GET /api/config - Configuration",
                "POST /api/trigger/read - Manual read trigger",
                "POST /api/trigger/write - Manual write trigger"
            ]
        };
    }
}

// Main function for any additional initialization if needed
public function main() returns error? {
    io:println("LifeQuest Underwriting Feed Processor initialized via service startup");
}
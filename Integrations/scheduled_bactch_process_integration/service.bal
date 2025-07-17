import ballerina/http;
import ballerina/log;
import ballerina/time;

// HTTP service for manual file processing trigger
service /underwriting on new http:Listener(httpPort) {

    // POST endpoint to manually trigger file processing
    resource function post process() returns ProcessingResponse|ErrorResponse|http:InternalServerError {
        log:printInfo("Manual file processing triggered via HTTP endpoint");

        ProcessingResponse|ErrorResponse result = executeFileProcessingJob();

        if result is ErrorResponse {
            http:InternalServerError internalError = {
                body: result
            };
            return internalError;
        }

        return result;
    }

    // GET endpoint to check service status
    resource function get status() returns json {
        time:Utc currentTime = time:utcNow();
        string timestamp = time:utcToString(currentTime);

        json statusResponse = {
            "service": "Underwriting File Processing Service",
            "status": "running",
            "scheduledTime": scheduledHour.toString() + ":" + (scheduledMinute < 10 ? "0" + scheduledMinute.toString() : scheduledMinute.toString()),
            "timestamp": timestamp
        };

        return statusResponse;
    }
}
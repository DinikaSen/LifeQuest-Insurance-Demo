import ballerina/lang.runtime;
import ballerina/log;
import ballerina/task;
import ballerina/time;

public function main() returns error? {
    log:printInfo("Starting scheduled batch process integration");

    // Schedule the job to run daily at configured time
    task:JobId jobId = check task:scheduleJobRecurByFrequency(new Job(), 24 * 3600); // 24 hours in seconds

    log:printInfo("Scheduled underwriting file processing job to run daily at " + 
                  scheduledHour.toString() + ":" + 
                  (scheduledMinute < 10 ? "0" + scheduledMinute.toString() : scheduledMinute.toString()));
    log:printInfo("Job ID: " + jobId.toString());
    log:printInfo("HTTP service started on port " + httpPort.toString());
    log:printInfo("Manual trigger endpoint: POST /underwriting/process");
    log:printInfo("Status endpoint: GET /underwriting/status");

    // Keep the program running
    runtime:sleep(60); // Sleep for 1 minute to allow initial setup
}

// Job class for scheduled execution
class Job {
    *task:Job;

    public function execute() {
        // Check if current time matches configured schedule (allowing 5-minute window)
        time:Utc currentTime = time:utcNow();
        time:Civil civilTime = time:utcToCivil(currentTime);

        if civilTime.hour == scheduledHour && civilTime.minute >= scheduledMinute && civilTime.minute < (scheduledMinute + 5) {
            ProcessingResponse|ErrorResponse result = executeFileProcessingJob();
            
            if result is ErrorResponse {
                log:printError("Scheduled job execution failed: " + result.message);
            } else {
                log:printInfo("Scheduled job execution completed successfully. Files processed: " + 
                             (result.filesProcessed ?: 0).toString());
            }
        }
    }
}
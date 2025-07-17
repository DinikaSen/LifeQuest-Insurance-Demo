import ballerina/task;
import ballerina/time;
import ballerina/io;

// Global variables to store processed records between read and write operations
EnrichedRecord[] processedRecords = [];
string currentProcessingDate = "";
boolean hasExecutedReadToday = false;
boolean hasExecutedWriteToday = false;
string lastExecutionDate = "";
boolean schedulerInitialized = false;

// Initialize scheduler if not already initialized
public function initializeSchedulerIfNeeded() returns error? {
    if !schedulerInitialized {
        check scheduleMinuteChecker();
        schedulerInitialized = true;
    }
}

// Schedule the minute-by-minute checker
public function scheduleMinuteChecker() returns error? {
    task:JobId checkJobId = check task:scheduleJobRecurByFrequency(new MinuteCheckerJob(), 60); // Check every minute
    io:println("Scheduled minute checker job with ID: " + checkJobId.toString());
    io:println("Read time configured: " + getReadTimeString());
    io:println("Write time configured: " + getWriteTimeString());
}

// Job class that runs every minute to check if it's time to read or write
class MinuteCheckerJob {
    *task:Job;
    
    public function execute() {
        error? result = checkAndExecuteTasks();
        if result is error {
            io:println("Error in minute checker job: " + result.message());
        }
    }
}

// Check current time and execute appropriate tasks
function checkAndExecuteTasks() returns error? {
    time:Utc currentTime = time:utcNow();
    time:Civil civilTime = time:utcToCivil(currentTime);
    
    string todayDate = string `${civilTime.year}${civilTime.month.toString().padStart(2, "0")}${civilTime.day.toString().padStart(2, "0")}`;
    
    // Reset daily execution flags if it's a new day
    if lastExecutionDate != todayDate {
        hasExecutedReadToday = false;
        hasExecutedWriteToday = false;
        lastExecutionDate = todayDate;
        io:println("New day detected: " + todayDate + ". Resetting execution flags.");
    }
    
    // Check if it's time to read and we haven't read today
    if isReadTime(civilTime) && !hasExecutedReadToday {
        io:println("Executing file reading at " + getReadTimeString());
        error? readResult = executeFileReading();
        if readResult is error {
            io:println("Error in file reading: " + readResult.message());
        } else {
            hasExecutedReadToday = true;
            io:println("File reading completed successfully.");
        }
    }
   
    // Check if it's time to write and we haven't written today
    if isWriteTime(civilTime) && !hasExecutedWriteToday {
        io:println("Executing file writing at " + getWriteTimeString());
        error? writeResult = executeFileWriting();
        if writeResult is error {
            io:println("Error in file writing: " + writeResult.message());
        } else {
            hasExecutedWriteToday = true;
            io:println("File writing completed successfully.");
        }
    }
}

// Check if current time matches configured read time
function isReadTime(time:Civil civilTime) returns boolean {
    return civilTime.hour == readHour && civilTime.minute == readMinute;
}

// Check if current time matches configured write time
function isWriteTime(time:Civil civilTime) returns boolean {
    return civilTime.hour == writeHour && civilTime.minute == writeMinute;
}

// Execute file reading operation
public function executeFileReading() returns error? {
    io:println("Starting scheduled file reading...");
    
    // Get current date for filename
    time:Utc currentTime = time:utcNow();
    time:Civil civilTime = time:utcToCivil(currentTime);
    string dateStr = string `${civilTime.year}${civilTime.month.toString().padStart(2, "0")}${civilTime.day.toString().padStart(2, "0")}`;
    
    currentProcessingDate = dateStr;
    
    // Generate input filename
    string inputFilename = generateFilename(dateStr);
    string inputFilePath = sftpIncomingPath + inputFilename;
    
    io:println("Reading file from SFTP: " + inputFilePath);
    
    // Step 1: Retrieve file from SFTP
    stream<byte[] & readonly, io:Error?> fileStream = check sftpClient->get(inputFilePath);

    // Convert stream to string
    byte[] fileBytes = [];
    check fileStream.forEach(function(byte[] & readonly chunk) {
        foreach byte b in chunk {
            fileBytes.push(b);
        }
    });

    string fileContent = check string:fromBytes(fileBytes);
    
    // Step 2: Parse CSV content
    string[][]|error csvData = parseCsvContent(fileContent);
    if csvData is error {
        return error("Failed to parse CSV file: " + csvData.message());
    }
    
    io:println("CSV file retrieved successfully. Processing " + csvData.length().toString() + " rows");
    
    // Determine if file has headers
    boolean hasHeaders = false;
    if csvData.length() > 0 && csvData[0].length() >= 5 {
        string firstRowFirstCol = csvData[0][0].toLowerAscii();
        if firstRowFirstCol.includes("quote") || firstRowFirstCol == "quoteid" {
            hasHeaders = true;
            io:println("CSV file contains headers - will skip first row");
        }
    }

    // Step 3: Parse and enrich records
    EnrichedRecord[] enrichedRecords = [];
    int processedCount = 0;
    int errorCount = 0;
    
    foreach int i in 0 ..< csvData.length() {
        string[] csvRow = csvData[i];
        
        // Parse the CSV row
        UnderwritingRecord|error parseResult = parseCsvRow(csvRow, hasHeaders, i);
        if parseResult is error {
            if parseResult.message().includes("Header row") {
                continue; // Skip header row
            }
            io:println("Error parsing CSV row " + i.toString() + ": " + parseResult.message());
            errorCount += 1;
            continue;
        }
        
        // Enrich with database data
        EnrichedRecord|error enrichResult = enrichRecord(parseResult);
        if enrichResult is error {
            string quoteIdValue = parseResult.quoteId;
            io:println("Error enriching record for quote " + quoteIdValue + ": " + enrichResult.message());
            errorCount += 1;
            continue;
        }
        
        enrichedRecords.push(enrichResult);
        processedCount += 1;
    }
    
    // Store processed records for later writing
    processedRecords = enrichedRecords;
    
    io:println("File reading completed. Processed: " + processedCount.toString() + ", Errors: " + errorCount.toString());
    io:println("Records stored in memory for writing. Total records: " + processedRecords.length().toString());
}

// Execute file writing operation
public function executeFileWriting() returns error? {
    if processedRecords.length() == 0 {
        io:println("No processed records available for writing. Skipping.");
        return;
    }
    
    io:println("Starting scheduled file writing...");
    
    // Generate output filename using stored processing date
    string outputFilename = generateOutputFilename(currentProcessingDate);
    string outputFilePath = sftpOutgoingPath + outputFilename;
    
    // Convert to JSON
    string jsonContent = check convertToJson(processedRecords);
    
    // Upload processed file back to SFTP outgoing folder
    io:println("Uploading processed file to SFTP: " + outputFilePath);
    
    error? uploadResult = sftpClient->put(path = outputFilePath, content = jsonContent);
    if uploadResult is error {
        return error("Failed to upload file to SFTP: " + uploadResult.message());
    }
    
    io:println("File writing completed successfully!");
    io:println("Output file: " + outputFilePath);
    io:println("Total records written: " + processedRecords.length().toString());
    
    // Clear processed records after successful write
    processedRecords = [];
    currentProcessingDate = "";
}

// Get current status for monitoring
public function getSchedulerStatus() returns json {
    time:Utc currentTime = time:utcNow();
    time:Civil civilTime = time:utcToCivil(currentTime);
    
    return {
        currentTime: string `${civilTime.hour.toString().padStart(2, "0")}:${civilTime.minute.toString().padStart(2, "0")}`,
        configuredReadTime: getReadTimeString(),
        configuredWriteTime: getWriteTimeString(),
        hasExecutedReadToday: hasExecutedReadToday,
        hasExecutedWriteToday: hasExecutedWriteToday,
        recordsInMemory: processedRecords.length(),
        currentProcessingDate: currentProcessingDate,
        lastExecutionDate: lastExecutionDate,
        schedulerInitialized: schedulerInitialized
    };
}
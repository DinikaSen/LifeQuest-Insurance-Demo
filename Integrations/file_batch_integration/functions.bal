import ballerina/lang.value;
import ballerina/sql;
import ballerina/io;

// Generate input filename based on date
public function generateFilename(string dateStr) returns string {
    return "underwriting_feed_" + dateStr + ".csv";
}

// Generate output filename based on date
public function generateOutputFilename(string dateStr) returns string {
    return "underwriting_feed_" + dateStr + ".json";
}

// Parse CSV content from file content string
public function parseCsvContent(string fileContent) returns string[][]|error {
    // Write content to a temporary file and read as CSV
    string tempFilePath = "/tmp/temp_underwriting.csv";
    check io:fileWriteString(tempFilePath, fileContent);
    
    string[][]|io:Error csvData = io:fileReadCsv(tempFilePath);
    if csvData is io:Error {
        return error("Failed to parse CSV content: " + csvData.message());
    }
    
    return csvData;
}

// Parse a single CSV row to UnderwritingRecord
public function parseCsvRow(string[] csvRow, boolean hasHeaders, int rowIndex) returns UnderwritingRecord|error {
    // Skip header row if present
    if hasHeaders && rowIndex == 0 {
        return error("Header row - skip processing");
    }
    
    if csvRow.length() < 5 {
        return error("Invalid CSV row. Expected 5 columns, got " + csvRow.length().toString());
    }
    
    string quoteId = csvRow[0].trim();
    string policyId = csvRow[1].trim();
    string statusValue = csvRow[2].trim();
    string decisionDate = csvRow[3].trim();
    string agentId = csvRow[4].trim();
    
    // Validate required fields
    if quoteId.length() == 0 || policyId.length() == 0 || statusValue.length() == 0 {
        return error("Missing required fields in CSV row");
    }
    
    // Normalize status value
    string normalizedStatus = statusValue.toUpperAscii();
    if normalizedStatus == "APPR" || normalizedStatus == "APPROVED" {
        normalizedStatus = "APPROVED";
    } else if normalizedStatus == "REJT" || normalizedStatus == "REJECTED" {
        normalizedStatus = "REJECTED";
    } else {
        return error("Invalid status value: " + statusValue);
    }
    
    return {
        quoteId: quoteId,
        policyId: policyId,
        status: normalizedStatus,
        decisionDate: decisionDate,
        agentId: agentId
    };
}

// Enrich record with database data
public function enrichRecord(UnderwritingRecord underwritingRec) returns EnrichedRecord|error {
    string quoteIdValue = underwritingRec.quoteId;
    sql:ParameterizedQuery query = `SELECT client_name, product_type, currency FROM quote_mapping WHERE quote_id = ${quoteIdValue}`;

    QuoteMappingResult|sql:Error result = dbClient->queryRow(query);
    if result is sql:Error {
        return error("Failed to fetch quote mapping for " + quoteIdValue + ": " + result.message());
    }

    string clientNameValue = result.client_name;
    string productTypeValue = result.product_type;
    string currencyValue = result.currency;

    return {
        quoteId: underwritingRec.quoteId,
        policyId: underwritingRec.policyId,
        status: underwritingRec.status,
        decisionDate: underwritingRec.decisionDate,
        agentId: underwritingRec.agentId,
        clientName: clientNameValue,
        productType: productTypeValue,
        currency: currencyValue
    };
}

// Convert enriched records to JSON string
public function convertToJson(EnrichedRecord[] records) returns string|error {
    return value:toJsonString(records);
}
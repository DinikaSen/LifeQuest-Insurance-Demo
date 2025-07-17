// Record types for CSV data
public type UnderwritingRecord record {|
    string quoteId;
    string policyId;
    string status;
    string decisionDate;
    string agentId;
|};

// Record types for database queries
public type PolicyEnrichmentData record {|
    string clientFirstName;
    string clientLastName;
    string policyTypeName;
|};

// Record type for final JSON output
public type EnrichedUnderwritingRecord record {|
    string quoteId;
    string policyId;
    string status;
    string decisionDate;
    string agentId;
    string clientName;
    string productType;
|};

// Response types for HTTP service
public type ProcessingResponse record {|
    string status;
    string message;
    int filesProcessed?;
    string[] processedFiles?;
    string timestamp;
|};

public type ErrorResponse record {|
    string status;
    string message;
    string timestamp;
|};
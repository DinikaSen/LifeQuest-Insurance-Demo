// Record types for the underwriting feed processing

public type UnderwritingRecord record {|
    string quoteId;
    string policyId;
    string status;
    string decisionDate;
    string agentId;
|};

public type EnrichedRecord record {|
    string quoteId;
    string policyId;
    string status;
    string decisionDate;
    string agentId;
    string clientName;
    string productType;
    string currency;
|};

public type QuoteMappingResult record {|
    string client_name;
    string product_type;
    string currency;
|};
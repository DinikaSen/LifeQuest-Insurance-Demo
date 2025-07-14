// API response wrapper
public type ApiResponse record {|
    boolean success;
    string message?;
    anydata data?;
|};

// Error response type
public type ErrorResponse record {|
    boolean success;
    string 'error;
    string message?;
|};

type Agent record {|
    string agent_id;
    string name;
    string licenses;
    string trainings;
|};

type RuleEngineRequest record {|
    string state;
    string product;
    string[] licenses;
    string[] trainings;
|};

type RuleEngineResponse record {|
    boolean eligible;
    string[] reasons;
    string[] suggestions;
|};

type AgentEligibilityResponse record {|
    string agent_id;
    string product;
    boolean eligible;
    string[]? reasons;
    string[]? suggestions;
|};
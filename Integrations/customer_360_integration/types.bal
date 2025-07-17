public type ClientDbRecord record {|
    string client_id;
    string first_name;
    string last_name;
    string state_code;
    string date_of_birth;
|};

public type ClientInfo record {|
    string clientId;
    string firstName;
    string lastName;
    int age;
    string state;
|};

type QuoteRequest record {|
    string productName;
    string state;
    int age;
    decimal coverageAmount;
|};

public type QuoteResponse record {|
    string id;
    string productName;
    int age;
    decimal coverageAmount;
    string state;
    decimal estimatedPremium;
    string status;
|};


// Error response record
public type ErrorResponse record {|
    string message;
|};

type Client record {|
    string clientId;
    string name;
    int age;
    string state;
|};

type NewQuote record {|
    string quoteId;
    string product;
    decimal coverage;
    decimal premium;
|};

type ClientQuoteSummary record {|
    Client 'client;
    NewQuote newQuote;
|};

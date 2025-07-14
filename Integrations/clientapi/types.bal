// API response wrapper
public type ApiResponse record {|
    string message?;
    anydata data?;
|};

// Error response type
public type ErrorResponse record {|
    string 'error;
    string message?;
|};

// Client data type
public type Client record {|
    string client_id;
    string first_name;
    string last_name;
    string date_of_birth;
    string email;
    string phone?;
    string street?;
    string city?;
    string state_code?;
    string zip?;
|};

// Client create request type
public type ClientCreateRequest record {|
    string client_id;
    string first_name;
    string last_name;
    string date_of_birth;
    string email;
    string phone;
|};
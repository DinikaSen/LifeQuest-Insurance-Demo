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

// Client data type
public type Client record {|
    string client_id;
    string first_name;
    string last_name;
    string date_of_birth;
    string email;
    string phone;
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
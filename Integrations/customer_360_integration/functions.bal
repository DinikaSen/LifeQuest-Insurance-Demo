import ballerina/sql;
import ballerina/time;

// Function to get client details from database
function getClientDetails(string clientId) returns ClientInfo|error {
    sql:ParameterizedQuery query = `SELECT client_id, first_name, last_name, date_of_birth, state_code FROM clients WHERE client_id = ${clientId}`;
    stream<ClientDbRecord, sql:Error?> resultStream = mysqlClient->query(query);
    
    ClientDbRecord[]|error clientRecords = from ClientDbRecord clientRecord in resultStream
        select clientRecord;
    
    if clientRecords is error {
        return clientRecords;
    }
    
    if clientRecords.length() == 0 {
        return error("Client not found");
    }
    
    ClientDbRecord clientRecord = clientRecords[0];
    ClientInfo clientInfo = {
        clientId: clientRecord.client_id,
        firstName: clientRecord.first_name,
        lastName: clientRecord.last_name,
        age: check calculateAge(clientRecord.date_of_birth),
        state: clientRecord.state_code
    };
    
    return clientInfo;
}

// Function to get new quote from external service
function getNewQuote(string productName, int age, string state, decimal coverageAmount) returns QuoteResponse|error {
    QuoteRequest payload = {
        productName: productName,
        age: age,
        state: state,
        coverageAmount: coverageAmount
    };
    
    map<string|string[]> headers = {};
    
    QuoteResponse|error response = quoteServiceClient->post("", payload, headers);
    
    if response is error {
        return response;
    }
    
    // QuoteResponse quote = check response.cloneWithType(QuoteResponse);
    return response;
}

// Function to calculate age from birthdate string
function calculateAge(string birthDateString) returns int|error {
    // Parse the birthdate string to Civil time
    time:Civil|time:Error birthDate = time:civilFromString(birthDateString + "T00:00:00Z");
    if birthDate is time:Error {
        return error("Invalid birthdate format");
    }
    
    // Get current date
    time:Utc currentUtc = time:utcNow();
    time:Civil currentDate = time:utcToCivil(currentUtc);
    
    // Calculate age
    int age = currentDate.year - birthDate.year;
    
    // Adjust if birthday hasn't occurred this year
    if currentDate.month < birthDate.month || 
       (currentDate.month == birthDate.month && currentDate.day < birthDate.day) {
        age = age - 1;
    }
    
    return age;
}

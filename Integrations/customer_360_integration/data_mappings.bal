function transform(ClientInfo clientInfo, QuoteResponse quoteInfo) returns ClientQuoteSummary => let var full_name = clientInfo.firstName + " " + clientInfo.lastName in {
        'client: {clientId: clientInfo.clientId, name: full_name, age: clientInfo.age, state: clientInfo.state},
        newQuote: {quoteId: quoteInfo.id, product: quoteInfo.productName, coverage: quoteInfo.coverageAmount, premium: quoteInfo.estimatedPremium}
    };
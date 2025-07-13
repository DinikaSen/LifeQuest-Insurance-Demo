import ballerina/http;

// === Request ===
type AgentRequest record {
    string state;
    string product;
    string[] licenses;
    string[] trainings;
};

type AgentEligibility record {
    boolean eligible;
    string[] reasons;
    string[] suggestions;
};

// === Response ===
type AgentResponse record {|
  *http:Ok;
  AgentEligibility body;
|};

type PolicyPerProduct record {
    string requiredLicense;
    string[] requiredTrainings;
};

// === Rules: state → product → (license + training)
map<map<PolicyPerProduct>> productRules = {
  "NY": {
    "Life Insurance": {
      "requiredLicense": "Life-NY",
      "requiredTrainings": ["Ethics101", "LifeBasics"]
    },
    "Annuities": {
      "requiredLicense": "Life-NY",
      "requiredTrainings": ["AnnuitySuit", "Ethics101", "AnnuitySalesNY"]
    },
    "Health Insurance": {
      "requiredLicense": "Health-NY",
      "requiredTrainings": ["HealthCompliance", "PrivacyTraining", "NYHealthCompliance"]
    },
    "Auto Insurance": {
      "requiredLicense": "Auto-NY",
      "requiredTrainings": ["AutoSalesBasics", "NYStateDriving"]
    }
  },
  "CA": {
    "Life Insurance": {
      "requiredLicense": "Life-CA",
      "requiredTrainings": ["LifeBasics", "Ethics101"]
    },
    "Annuities": {
      "requiredLicense": "Life-CA",
      "requiredTrainings": ["AnnuitySalesCA", "Ethics101"]
    },
    "Health Insurance": {
      "requiredLicense": "Health-CA",
      "requiredTrainings": ["CAHealthCompliance", "HIPAATraining"]
    },
    "Auto Insurance": {
      "requiredLicense": "Auto-CA",
      "requiredTrainings": ["AutoSalesBasics", "CAStateDriving"]
    }
  },
  "TX": {
    "Life Insurance": {
      "requiredLicense": "Life-TX",
      "requiredTrainings": ["Ethics101"]
    },
    "Annuities": {
      "requiredLicense": "Life-TX",
      "requiredTrainings": ["AnnuityEssentials", "Ethics101", "AnnuitySalesTX"]
    },
    "Health Insurance": {
      "requiredLicense": "Health-TX",
      "requiredTrainings": ["PrivacyTraining", "HealthCompliance", "TXHealthCompliance"]
    },
    "Auto Insurance": {
      "requiredLicense": "Auto-TX",
      "requiredTrainings": ["AutoSalesBasics", "TXStateDriving"]
    }
  }
};

// === API Service ===
service / on new http:Listener(8080) {

    resource function post eligibility(@http:Payload AgentRequest agent) returns AgentResponse {
        
        AgentEligibility eligibilityObj = {
            eligible: true,
            reasons: [],
            suggestions: []
        };

        // Check if state is supported
        var stateRules = productRules[agent.state];
        if stateRules is () {
            eligibilityObj.eligible = false;
            eligibilityObj.reasons.push("Unsupported state: " + agent.state);
            return { body: eligibilityObj };
        }

        // Check if product is supported in this state
        var rule = stateRules[agent.product];
        if rule is () {
            eligibilityObj.eligible = false;
            eligibilityObj.reasons.push("Product not available in " + agent.state);
            return { body: eligibilityObj };
        }

        // Check required license
        if (agent.licenses.indexOf(rule.requiredLicense) == ()) {
            eligibilityObj.eligible = false;
            eligibilityObj.reasons.push("Missing license: " + rule.requiredLicense);
            eligibilityObj.suggestions.push("Obtain license: " + rule.requiredLicense);
        }

        // Check required trainings
        foreach string training in rule.requiredTrainings {
            if (agent.trainings.indexOf(training) == ()) {
                eligibilityObj.eligible = false;
                eligibilityObj.reasons.push("Missing training: " + training);
                eligibilityObj.suggestions.push("Complete training: " + training);
            }
        }

        return { body: eligibilityObj };
    }
}

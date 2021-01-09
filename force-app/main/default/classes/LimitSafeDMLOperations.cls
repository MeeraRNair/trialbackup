/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13274       Sprint 11       22-June-2016    Afiq            To separate test method in a test class from LimitSafeDMLOperations main class
*/ 

public class LimitSafeDMLOperations {
    
    public static Boolean forceTest = false;
    public static Boolean forceDMLException = false;
        
    public static void databaseUpdateAccountShares(List<AccountShare> accountShareUpdateArray) {
        
        Boolean hasNonIgnoredError = false;
        
        Integer almostDMLRows = Limits.getDMLRows() + accountShareUpdateArray.size();
        
        if (Limits.getDMLStatements() == Limits.getLimitDMLStatements() || almostDMLRows >= Limits.getLimitDMLRows() || forceDMLException)
        {
            system.debug('LimitSafeDMLOperations: databaseInsertAccountShares: DML EXCEPTION: was about to occur. Processing had to stopped.');
            String errorMessage = 'LimitSafeDMLOperations: databaseInsertAccountShares: DML EXCEPTION: was about to occur. Processing had to stop.';
            throw new dellUtil.DellException(errorMessage);
        }
    
        List <CustomResult> customResults = new List<CustomResult>();
        
        Database.SaveResult[] results = Database.update(accountShareUpdateArray,false);
        // Bad Account Shares
        List<AccountShare> badAccountShares = new List<AccountShare>();
        Integer loopCounter = 0;
        
        for (Database.SaveResult result : results) {
    
            if (result.isSuccess() == false || forceTest) {
                
                system.debug('## Result.isSuccess = ' + result.isSuccess());
                
                // Cycle through errors
                Database.Error[] dataErrors = result.getErrors();
                List<String> errorMessages = new List<String>();
    
                for (Database.Error dataError : dataErrors) {
                    // Ignore the following errors:
                    // INVALID_CROSS_REFERENCE_KEY
                    // DUPLICATE_VALUE
                    // OWNER
                    system.debug('## Result.errorMessage = ' + dataError.getMessage());
                    //if (!dataError.getMessage().contains('INVALID_CROSS_REFERENCE_KEY') && !dataError.getMessage().contains('DUPLICATE_VALUE')) {
                    if (!(dataError.getStatusCode() == StatusCode.INVALID_CROSS_REFERENCE_KEY) || ! dataError.getMessage().contains('id does not exist') &&!(dataError.getStatusCode() == StatusCode.DUPLICATE_VALUE) || ! dataError.getMessage().contains('duplicate value found')){
                        errorMessages.add(dataError.getMessage());
                    }
                    
                }   // End for
    
                if (dataErrors.size() > 0 || forceTest) {
    
                    hasNonIgnoredError = true;
        
                    CustomResult customResult = new CustomResult();
                    customResult.Operation = 'Insert';
                    customResult.sfdcObject = 'AccountShare';
                    customResult.isSuccess = result.isSuccess();
                    customResult.errors = errorMessages;
                    customResults.add(customResult);
                    badAccountShares.add(accountShareUpdateArray[loopCounter]);
                }
    
            }   // End if (isSuccess() == false)
            
            loopCounter++;
        }   // End for

        system.debug('### Non Ignored Error Status = ' + hasNonIgnoredError);
        if (hasNonIgnoredError == true || forceTest) {
            system.debug('LimitSafeDMLOperations: databaseInsertAccountShares: DATA EXCEPTION: The following account shares: ' + badAccountShares + ' were not inserted due to the following errors: ' + customResults + '.  Processing of the integration payload set was not stopped.');
            throw new dellUtil.DellException('LimitSafeDMLOperations: databaseInsertAccountShares: DATA EXCEPTION: The following account shares: ' + badAccountShares + ' were not inserted due to the following errors: ' + customResults + '.  Processing of the integration payload set was not stopped.');
        }
    }
    
    public static void insertOpportunityTeamMembers (List<OpportunityTeamMember> oppTeamMemberToSave) {
        // Display the function
        system.debug('In function setOpportunityTeam now . . .');

        // Declare variables
        Integer OppTeamMemberDMLRows = 0;

        // Check limits
        OppTeamMemberDMLRows = Limits.getDMLRows() + oppTeamMemberToSave.size();

        if (Limits.getDMLStatements() >= Limits.getLimitDMLStatements() || OppTeamMemberDMLRows >= Limits.getLimitDMLRows() || forceDMLException) {

            //system.debug('#### Limits: We are exceeding the limits...');
            String errorMessage = 'LimitSafeDMLOperations: insertOpportunityTeamMembers: DML EXCEPTION: was about to occur. Processing had to stop.';
            throw new dellUtil.DellException('The DML limits are reached for opportunity team member update. The records which were being processed during this error were: ' + oppTeamMemberToSave);
        }

        // Add opportunity team members
        system.debug('#### Inserting opportunity team members: ' + oppTeamMemberToSave.size());

        // Insert the opportunity team members
        try {
            insert oppTeamMemberToSave;
        } catch (Exception e) {
            throw new dellUtil.DellException('LimitSafeDMLOperations: insertOpportunityTeamMembers: An error occurred during the update of Sales Team Members.  The Sales Team Members being processed were: ' + oppTeamMemberToSave);
        }
    }   // End function insertDefaultOpportunityTeam() 
    
    // Set the Sales Team to R/W on Opportunity Share Access
    public static void insertOpportunityShares(List<OpportunityShare> oppShares) {
    
        Integer almostDMLRows;
        
        almostDMLRows = Limits.getDMLRows() + oppShares.size();
        
        if (Limits.getDMLStatements() >= Limits.getLimitDMLStatements() || almostDMLRows >= Limits.getLimitDMLRows() || forceDMLException) {
            system.debug('##CCWS: We are exceeding the limits...');
            throw new dellUtil.DellException('LimitSafeDMLOperations: insertOpportunityShares: Please delete some Sales Team members and try the update again. The Opportunity Shares which were being processed during this error are: ' + oppShares);
        }

        // Insert all of the Opportunity Share objects
        try {
            insert oppShares;
        } catch (Exception e) {
            throw new dellUtil.DellException('LimitSafeDMLOperations: insertOpportunityShares: An error occurred during the update of Sales Team Member permissions.  The Sales Team Members being processed were: ' + oppShares);
        }

    }   // End function insertOpportunityShares()
}
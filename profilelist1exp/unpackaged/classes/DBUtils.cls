/***********************************************************
*
* ---------------------------------------------------------
* Revision  Name    Date        Description
* 1.0                           Creation
  2.0       MenMee  19.07.2011  REL12.10 CR6493 Sales Role Change (Technical Sales Manager -> Inside Product Specialist Manager)      
* 3.0       Azwanti 03.10.2011  REL12.10 CR6493-0182 Sales Role Change (Inside Product Specialist Manager -> Technical Sales Manager)
  4.0       Krishna 21.12.2011  REL13.1 CR6708 - Added method for creating a sngle exception.
  5.0       KP      10.11.2012  REL13.10 Fix:  added try-catch in flushOutTheJobsQueue method.
  6.0       Shivam  12.01.2017  Defect#2838704/S-25/DCS0103 - Commenting Lines 376 - 384 (flushOutTheJobsQueue method)
*
************************************************************/


global class DBUtils {

    public static void CheckLimits (List<sObject> InputArray, Boolean bTestException) {

        Integer iProjectedDMLRows = 0;


        // Check the limits
        iProjectedDMLRows = Limits.getDMLRows() + InputArray.size();

        system.debug('#### DML rows already processed: ' + Limits.getDMLRows());
        system.debug('#### Size of Input Array = ' + InputArray.size());
        system.debug('#### Projected number of DML Rows = ' + iProjectedDMLRows);

        if (Limits.getDMLStatements() >= Limits.getLimitDMLStatements() || iProjectedDMLRows >= Limits.getLimitDMLRows() || (bTestException)) {
            system.debug('#### Limits: We are exceeding the limits...');
            throw new dellUtil.DellException('DML limits have been reached');
        }

    }   // End function CheckLimits
    
    public static List<AccountTeamIntegrationUtils.Result> DatabaseDeleteWithResponse(List<sObject> delArray, String strObject, Boolean bIsTest) 
    {
        system.debug('#### In function DatabaseDelete() now . . . ');

        // Confirm the receipt of the deletion array and the sObject
        system.debug('#### delArray = ' + delArray);
        system.debug('#### strObject = ' + strObject);
        
        AccountTeamMember ATMDelrecord;
        
        List<AccountTeamIntegrationUtils.Result> DeleteResultList = new List<AccountTeamIntegrationUtils.Result>();
        Boolean bError = false;
        Integer iCount = 0;


        // Delete the array
        Database.DeleteResult[] delResults = Database.delete(delArray, false);
        system.debug('#### delResults =' +delResults.size());
        for (integer i = 0; i < delResults.size(); i++)
        {
            system.debug('#### Inside FOR Loop');
            ATMDelrecord = (AccountTeamMember)delArray[i];
            AccountTeamIntegrationUtils.Result DelResultItem = new AccountTeamIntegrationUtils.Result();
            DelResultItem.AccountId = ATMDelrecord.AccountId;
            DelResultItem.UserId = ATMDelrecord.UserId;
            DelResultItem.isSuccess = delResults[i].isSuccess();
            DelResultItem.Status ='I';
                        
            system.debug('#### DB result item = ' + delResults[i]);
            
            if (delResults[i].isSuccess() == false || bIsTest)
            {
                system.debug('#### Inside FOR Loop isSuccess == False');
                Database.Error[] delErrors = delResults[i].getErrors();
                
                List<String> errorCodeDelList = new List<String>();
                List<String> errorMessageDelList = new List<String>();
                
                // Cycle through the errors
                for (Database.Error delError : delErrors)
                {
                    system.debug('#### Inside FOR Loop delError');
                    errorCodeDelList.add(''+delError.getStatusCode());
                    errorMessageDelList.add(delError.getMessage());
                }
                    
                    DelResultItem.errorCodes = StringUtils.joinStrings (errorCodeDelList, ',');
                    DelResultItem.errorDetails = StringUtils.joinStrings (errorMessageDelList, ',');                
            }
            DeleteResultList.add(DelResultItem);
            
        } // End for
        system.debug('### DeleteResultList = ' + DeleteResultList);
        return DeleteResultList;//
    }   // End function DatabaseDeleteWithResponse()
        
     
    public static List<AccountTeamIntegrationUtils.Result> DatabaseInsertWithResponse(List<sObject> insArray, Boolean bIsTest) {

        system.debug('#### In function DatabaseInsert() now . . . ');
        // Confirm the receipt of the insert array, operation, and sObject
        
        system.debug('#### insArray = ' + insArray);
        

        AccountTeamMember ATMrecord;
        List<AccountTeamIntegrationUtils.Result> insertResultList = new List<AccountTeamIntegrationUtils.Result>();
        
        // Perform the insert
        Database.SaveResult[] insResults = Database.insert(insArray, false);
        
        //Cycle through errors
        
        for(integer i = 0; i< insResults.size(); i++){  
            
            //if (strObject == 'AccountTeamMember')
            
            ATMrecord = (AccountTeamMember)insArray[i];
            AccountTeamIntegrationUtils.Result ResultItem= new AccountTeamIntegrationUtils.Result();
            ResultItem.AccountId = ATMrecord.AccountId;
            ResultItem.UserId = ATMrecord.UserId;
            ResultItem.isSuccess = insResults[i].isSuccess();
            ResultItem.Status ='A';
                

            system.debug('#### DB result item = ' + insResults[i]);

            if (insResults[i].isSuccess() == false || bIsTest) {

                Database.Error[] insErrors = insResults[i].getErrors();  
                
                List<String> errorCodeList = new List<String>();
                List<String> errorMessageList = new List<String>();
                
                // Cycle through the errors
                for (Database.Error insError : insErrors) {                 
                    errorCodeList.add(''+insError.getStatusCode());
                    errorMessageList.add(insError.getMessage());                    
                }   // End for (Database.Error insError : insErrors)  
                
                ResultItem.errorCodes = StringUtils.joinStrings(errorCodeList,',');
                ResultItem.errorDetails =StringUtils.joinStrings(errorMessageList,',');                  
            }   // End if (insResults[i].isSuccess() == false)
            
            insertResultList.add(ResultItem);       
        
        }   // End for 

        
        system.debug('### insertResultList = ' + insertResultList);
        return insertResultList;//
    }   // End function DatabaseInsertWithResponse()

  
    public static List<CustomResult> DatabaseDelete(List<sObject> delArray, String strObject, Boolean bIsTest) {


        system.debug('#### In function DatabaseDelete() now . . . ');


        // Confirm the receipt of the deletion array and the sObject
        system.debug('#### delArray = ' + delArray);
        system.debug('#### strObject = ' + strObject);


        // Declare variables
        String sErrMessage1 = 'The following ' + strObject + ' records were not deleted due to an error: ';
        String sErrMessage2 = ' .  Processing of the integration payload set was not stopped.';

        List<CustomResult> crDelete = new List<CustomResult>();
        Boolean bError = false;
        Integer iCount = 0;


        // Delete the array
        Database.DeleteResult[] delResults = Database.delete(delArray, false);


        for (Database.DeleteResult delResult : delResults) {

            system.debug('#### delResult = ' + delResult);

            if (delResult.isSuccess() == false || bIsTest) {
                List<String> delResultErr = new List<String>();

                // Cycle through errors
                Database.Error[] daterr = delResult.getErrors();
                for (Database.Error daterrInd : daterr) {

                    // Put non-"INVALID_CROSS_REFERENCE_KEY" errors into a list
                    if ((daterrInd.getStatusCode() == StatusCode.INVALID_CROSS_REFERENCE_KEY) || (daterrInd.getMessage().contains('id does not exist')) ) {
                        // Ignore these errors
                        system.debug('##CS ignoring error');
                    } else {
                        delResultErr.add(daterrInd.getMessage());
                    }   // End if (!(daterrInd.getStatusCode() == StatusCode.INVALID_CROSS_REFERENCE_KEY))
                }   // End for (Database.Error daterrInd : daterr)

                // If errors exist . . .
                if (delResultErr.size() > 0 || bIsTest) {

                    bError = true;
                    // Add the errors to an array
                    CustomResult crDelResult = new CustomResult();
                    crDelResult.Operation = 'Delete';
                    crDelResult.sfdcObject = strObject;
                    crDelResult.isSuccess = delResult.isSuccess();
                    crDelResult.Id = delArray[iCount].Id;
                    crDelResult.errors = delResultErr;
                    crDelete.add(crDelResult);
                }   // End if (delResultErr.size() > 0)
            }   // End if (delResult.isSuccess() == false)
            iCount++;
        }   // End for (Database.DeleteResult delResult : delResults)

        system.debug('### Error Status = ' + bError);

        if (bError == true) {
            //dellUtil.sendSupportEmail(sErrMessage1 + crDelete + sErrMessage2 + '[ Code:  DBUtils.DatabaseDelete() ]', dellConfig.errorEmail);
        }
        // Return the result
        return crDelete;
    }   // End function DatabaseDelete

    public static List<CustomResult> DatabaseInsert(List<sObject> insArray, String strObject, Boolean bIsTest, Boolean bUnableToLockRow) {

        system.debug('#### In function DatabaseInsert() now . . . ');
        // Confirm the receipt of the insert array, operation, and sObject
        system.debug('#### insArray = ' + insArray);
        system.debug('#### strObject = ' + strObject);
        // Declare variables
        String sErrMessage1 = 'The following ' + strObject + ' records were not created due to an error: ';
        String sErrMessage2 = ' .  Processing of the integration payload set was not stopped.';
        List<CustomResult> crInsert = new List<CustomResult>();
        Boolean bErrorIns = false;
        Integer iCountIns = 0;

        // Perform the insert
        Database.SaveResult[] insResults = Database.insert(insArray, false);

        for (Database.SaveResult insResult : insResults) {

            system.debug('#### insResult = ' + insResult);

            if (insResult.isSuccess() == false || bIsTest) {
                List<String> insResultErr = new List<String>();
                // Cycle through errors
                Database.Error[] insErrors = insResult.getErrors();

                // Test the throw of the UNABLE_TO_LOCK_ROW exception
                if (bIsTest && bUnableToLockRow) {
                    throw new dellUtil.RowLockException('UNABLE_TO_LOCK_ROW');
                }

                // Cycle through the errors
                for (Database.Error insError : insErrors) {

                    // Throw any UNABLE_TO_LOCK_ROW exceptions
                    if ((insError.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW) || (insError.getMessage().contains('unable to obtain exclusive access to this record')) || (bIsTest && bUnableToLockRow)) {
                        throw new dellUtil.RowLockException('UNABLE_TO_LOCK_ROW ' + insError.getMessage());
                    } else if (
                             (insError.getStatusCode() == StatusCode.DUPLICATE_VALUE) ||
                             (insError.getStatusCode() == StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) ||
                             (insError.getMessage().contains('duplicate value found')) ||
                             (insError.getMessage().contains('insufficient access rights on cross-reference id')) ||
                             (insError.getMessage().contains('duplicate value found: duplicates value on record with id')) ||
                             (insError.getMessage().contains('duplicates value on record with id'))
                             ) {
                            //Ignore these errors
                            system.debug('##CS ignoring error');
                    } else {
                        insResultErr.add(insError.getMessage());
                    }   // End if (!(insError.getStatusCode() == StatusCode.DUPLICATE_VALUE))
                }   // End for (Database.Error insError : insErrors)

                // If non-"DUPLICATE_VALUE" errors exist . . .
                if (insResultErr.size() > 0 || bIsTest) {

                    bErrorIns = true;

                    // Add the errors to an array
                    CustomResult crInsResult = new CustomResult();

                    crInsResult.Operation = 'Insert';
                    crInsResult.sfdcObject = strObject;
                    crInsResult.isSuccess = insResult.isSuccess();

                  if ((strObject == 'AccountTeamMember') || (strObject == 'OpportunityTeamMember')) {
                      crInsResult.AccountId = (ID)insArray[iCountIns].get('AccountId');
                      crInsResult.UserId = (ID)insArray[iCountIns].get('UserId');
                  } else if ((strObject == 'AccountShare') || (strObject == 'OpportunityShare')) {
                      crInsResult.AccountId = (ID)insArray[iCountIns].get('AccountId');
                      crInsResult.UserId = (ID)insArray[iCountIns].get('UserOrGroupId');
                  }

                    crInsResult.errors = insResultErr;
                    crInsert.add(crInsResult);
                }   // End if (insResultErr.size() > 0)
            }   // End if (insResult.isSuccess() == false)
            iCountIns++;
        }   // End for (Database.SaveResult insResult : insResults)

        system.debug('### Error Status = ' + bErrorIns);

        if (bErrorIns == true) {
            //dellUtil.sendSupportEmail(sErrMessage1 + crInsert + sErrMessage2 +'[ Code:  DBUtils.DatabaseInsert() ]', dellConfig.errorEmail);
        }
        // Return the result
        return crInsert;
    }   // End function DatabaseInsert()

    public static List<CustomResult> DatabaseUpdate(List<sObject> updArray, String strObject, Boolean bIsTest) {

        // Display the function
        system.debug('In function DatabaseUpdate() now . . .');
        // Confirm the receipt of the update array and sObject
        system.debug('#### updArray = ' + updArray);
        system.debug('#### strObject = ' + strObject);

        // Declare variables
        String sErrMessage1 = 'The following ' + strObject + ' records were not updated due to an error: ';
        String sErrMessage2 = ' .  Processing of the integration payload set was not stopped.';
        List<CustomResult> crUpdate = new List<CustomResult>();
        Boolean bErrorUpd = false;
        Integer iCountUpd = 0;

        // Perform the update
        Database.SaveResult[] rsltUA = Database.update(updArray, false);

        for (Database.SaveResult rsltUAInd : rsltUA) {
            system.debug('### Result: ' + rsltUAInd);
            if (rsltUAInd.isSuccess() == false || bIsTest) {
                List<String> rsltUAIndErr = new List<String>();
                // Cycle through errors
                Database.Error[] uaerr = rsltUAInd.getErrors();
                for (Database.Error uaerrInd : uaerr) {
                    // Throw any UNABLE_TO_LOCK_ROW exceptions
                    if (
                        (uaerrInd.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW) ||
                        (uaerrInd.getMessage().contains('unable to obtain exclusive access to this record'))
                        ) {
                        throw new dellUtil.RowLockException('UNABLE_TO_LOCK_ROW ' + uaerrInd.getMessage());
                    } else if(
                                (uaerrInd.getStatusCode() == StatusCode.INACTIVE_OWNER_OR_USER) ||
                                (uaerrInd.getMessage().contains('owner is inactive, cannot reparent record'))
                              ){
                                //Ignore these errors
                                system.debug('##CS ignoring error');
                    } else {
                        rsltUAIndErr.add(uaerrInd.getMessage());
                    }
                }   // End for (Error uaerrInd : uaerr)

                // If errors exist . . .
                if (rsltUAIndErr.size() > 0 || bIsTest) {
                    bErrorUpd = true;
                    // Add the errors to an array
                    CustomResult crUA = new CustomResult();
                    crUA.Operation = 'Update';
                    crUA.sfdcObject = strObject;
                    crUA.isSuccess = rsltUAInd.isSuccess();
                    //crUA.OpportunityId = updArray[iCountUpd].Id;
                    crUA.errors = rsltUAIndErr;
                    crUpdate.add(crUA);
                }   // End if (rsltUAIndErr.size() > 0)
            }   // End if (rsltUAInd.isSuccess() == false)
            iCountUpd++;
        }   // End for (Database.SaveResult rsltUAInd : rsltUA)

        system.debug('Error Status = ' + bErrorUpd);

        if (bErrorUpd == true) {
            //dellUtil.sendSupportEmail(sErrMessage1 + crUpdate + sErrMessage2 +'[ Code:  DBUtils.DatabaseUpdate() ]', dellConfig.errorEmail);
        }
        // Return the result
        return crUpdate;
    }   // End function DatabaseUpdate()

    public static void flushOutTheJobsQueue(){
    // Rev 6.0 starts    
        /*for(CronTrigger c : [SELECT Id, State, NextFireTime FROM CronTrigger WHERE State='Deleted' AND NextFireTime=null]){
            System.debug('### Aborting finished job : '+ c);
            try{
                System.abortjob(c.id);
            }catch(Exception e){
                System.debug('### Exception occurred in aborting the job('+ c +'):'+ e.getMessage());
            }
            
        }*/
        // Rev 6.0 ends
    }
    
    //CR4117
    public static void processResult(List<sObject> updatedList, Database.SaveResult[] listOfResult,
                                    String objectType, String Operation, String JobName, Map<Id,Id> IdToWorkItemIdMap){
    
        List<Exception__c> listOfException = new List<Exception__c>();
        List<String> errorCodeDelList = new List<String>();
        List<String> errorMessageDelList = new List<String>();
        String errorOutput='';
        for(integer i = 0; i< listOfResult.size();i++){       
      
            if(listOfResult[i].isSuccess()!=true){
                Exception__c exceptionVar = new Exception__c();        
        
                exceptionVar.Object_type__c = objectType;
                exceptionVar.Object_ID__c = updatedList[i].Id;
                exceptionVar.Operation__c = operation;
                exceptionVar.Process_Name__c = jobName;
                if (IdToWorkItemIdMap != null){
                    exceptionVar.Work_Item_Lookup__c = IdToWorkItemIdMap.get(updatedList[i].Id);
                }                   
                Database.Error [] errors = listOfResult[i].getErrors();
                
                errorCodeDelList.clear();
                errorMessageDelList.clear();
                // Cycle through the errors
                for (Database.Error error :errors){
                    errorCodeDelList.add(''+error.getStatusCode());
                    errorMessageDelList.add(''+error.getMessage());
                }            
                exceptionVar.Error_Codes__c = StringUtils.joinStrings (errorCodeDelList, ',');
                exceptionVar.Error_Messages__c = StringUtils.joinStrings (errorMessageDelList, ','); 
              
                listOfException.add(exceptionVar);        
                errorOutput = '\nId:' + updatedList[i].Id + ' Codes:' + exceptionVar.Error_Codes__c + ' Details:' + exceptionVar.Error_Messages__c; 
            }
        }
        if(listOfException.size() > 0){      
            Database.insert(listOfException,false);
            errorOutput='\n#####Error records(' +listOfException.size()+')######\nObject:' + objectType +', JobName:' + JobName +'\n' + errorOutput;
            System.debug(errorOutput);
        }
        
    }
    
    public static void processResult(List<sObject> updatedList, Database.SaveResult[] listOfResult, 
    String objectType, String operation, String jobName){
    
        //CR4117 
        processResult(updatedList, listOfResult, objectType, Operation, JobName, null);
    }
    
    
    //public static void addSingleException(String processName, 
    public static String addSingleException(String processName,
                                            String objectType,
                                            String objectId,
                                            String operation,
                                            String errorCodes,
                                            String errorMessages, 
                                            String notes){
        String exceptionId = '';
        
        try {
            Exception__c exceptionVar = new Exception__c(Process_Name__c = processName, 
                                                     Object_type__c = objectType, 
                                                     Object_ID__c = objectId,
                                                     Operation__c = operation, 
                                                     Error_Codes__c = errorCodes, 
                                                     Error_Messages__c = errorMessages, 
                                                     Notes__c = notes);        
            Database.insert(exceptionVar, false);
        
            exceptionId = exceptionVar.Id;
        } 
        catch (Exception e){
            System.debug('Error occurs while inserting the Exception record:'+e.getMessage());
        }
        
        return exceptionId;
                 
    }
    
    
    
    
}   // End global class DBUtils
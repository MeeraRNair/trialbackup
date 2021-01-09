/**
* Name          : AccountTeamIntegrationUtils
* Description   : Utility module for various functions related to Account Teams.
* -------------------------------------------------------------------------------
* Revision  Name       Date         Description
* 1.0       Krishna    13-Aug-2010  Creation
* 2.0       Azwanti    10-July-2014    CR9402 Fix issue on AccountShare
* ------------------------------------------------------------------------------
**/
/**
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 3.0      13477       FY17-DCS-1002   07-Sep-2016     Fenny           Summer ’16 seasonal release that has been causing Account team owner and members to have Ready only access to their Accounts and Related objects.
 **/

global class AccountTeamIntegrationUtils {
    
    public static List<AccountTeamMember> newlyAddedAccTeamList = new List<AccountTeamMember>(); 

    global class Result {
        webService String AccountId;
        webService String UserId;
        webService String Status;
        webService Boolean isSuccess;
        webService String errorCodes;
        webService String errorDetails;
    }
    
    webService static List<Result> setAccountTeam(List<DellTeamMember> dellTeamMembers) {
        // Declare variables
        List<Result> ATMIntegrationResponse = new List<Result>();
  
        try {
            ATMIntegrationResponse = setAccountTeamSub(dellTeamMembers);
        } catch (Exception e) {
            emailUtils.sendSupportEmail('Exception :'+ e.getMessage()+'\nCode : AccountTeamIntegrationUtils.setAccountTeamSub()\nRecords in the batch: ' + dellTeamMembers);
        }        

        try {
            SalesTeamProcessing.setAccountAndSalesTeamsWrapped(dellTeamMembers);
        } catch (Exception e) {
            emailUtils.sendSupportEmail('Exception :'+ e.getMessage()+'\nCode : AccountTeamIntegrationUtils.setAccountTeamSub()\nRecords in the batch: ' + dellTeamMembers);
        }
        return ATMIntegrationResponse;
    }   // End function setAccountTeam


    public static List<Result> setAccountTeamSub(List<DellTeamMember> dellTeamMembers) {
        // Declare variables
        Set<String> DTMAcctIDs = new Set<String>();
        Set<String> DTMUserIDs = new Set<String>();
        Set<String> DTMDeleteAcctIDs = new Set<String>();
        Set<String> DTMDeleteUserIDs = new Set<String>();
        List<DellTeamMember> DTMUpdateArray = new List<DellTeamMember>();
        List<DellTeamMember> DTMDeleteArray = new List<DellTeamMember>();
        List<DellTeamMember> DTMNoStatusArray = new List<DellTeamMember>();

        List<Result> deleteAccountTeamMembersResult = new List<Result>();
        List<Result> updateAccountTeamAndShareResult = new List<Result>();
        List<Result> finalResultList = new List<Result>();
        List<Result> DTMNoStatusResultList = new List<Result>();
        
        // Parse records of DellTeamMember into update records and deletion records
        For (DellTeamMember dtm : dellTeamMembers) {
            if (dtm.Status == 'A') {
                // Build the array of account IDs of Dell team members
                DTMAcctIDs.add(dtm.AccountId);
                // Build the array of user IDs of Dell team members
                DTMUserIDs.add(dtm.UserId);
                // Build the array of DellTeamMembers to update in Account Teams and Sales Teams
                DTMUpdateArray.add(dtm);
            }   // End if (dtm.Status == 'A')
            else if (dtm.Status == 'I') {
                // Build the array of account IDs of DellTeamMembers
                DTMDeleteAcctIDs.add(dtm.AccountId);
                // Build the array of user IDs of DellTeamMembers
                DTMDeleteUserIDs.add(dtm.UserId);
                // Build the array of DellTeamMembers to delete in Account Teams and Sales Teams
                DTMDeleteArray.add(dtm);
            }   // End if dtm.Status == 'I'
            else {
                // Build the array of DellTeamMembers having no status
                DTMNoStatusArray.add(dtm);
            }   // End If (dtm.Status != 'A' / 'I')
        }   //  End For (DellTeamMember dtm : dellTeamMembers)

        // If records with no status exist, email the designated recipient
        if (DTMNoStatusArray.size() > 0) {            
            Integer DTMNoStatusSize = DTMNoStatusArray.size();                 
            for (integer i = 0; i < DTMNoStatusSize; i++){                
                Result DTMNoStatusList = new Result();
                DTMNoStatusList.AccountId = DTMNoStatusArray[i].AccountId;
                DTMNoStatusList.UserId = DTMNoStatusArray[i].UserId;
                DTMNoStatusList.Status = DTMNoStatusArray[i].Status;
                
                DTMNoStatusList.errorCodes = 'INVALID_STATUS';              
                DTMNoStatusList.errorDetails = 'Invalid [Status] value';
                DTMNoStatusList.isSuccess = false;
                //adds to list              
                DTMNoStatusResultList.add(DTMNoStatusList);
            }      
        }
            
        // If deletion records exist, perform the deletion from the
        // AccountTeamMember table and OpportunityTeamMember table
        If (DTMDeleteArray.size() > 0) {
            // Send DellTeamMember update, account ID, and user ID
            // arrays to the AccountTeamMember delete function
            try {              
                deleteAccountTeamMembersResult = deleteAccountTeamMembers(DTMDeleteArray);
            } catch (Exception e) {
                emailUtils.sendSupportEmail('Exception :'+ e.getMessage()+'.\nCode : AccountTeamIntegrationUtils.deleteAccountTeamMembers(). \nRecords in the batch: ' + DTMDeleteArray);  
            }
            // Clear the arrays
            DTMDeleteArray.clear();
            DTMDeleteAcctIDs.clear();
            DTMDeleteUserIDs.clear();
        }   // End If (DTMDeleteArray.size() > 0)
        
        // if update records exist, perform the update to the account teams and sales teams
        If (DTMUpdateArray.size() > 0) {
            // Create a map of the active users in the DellTeamMember set
            Map<String, User> mapActiveUsers = new Map<String, User>([select Id from User where Id in :DTMUserIDs and IsActive = True]);
            // Send DellTeamMember update, account ID, and user ID
            // arrays to the AccountTeamMember and AccountShare update function
            try {
                updateAccountTeamAndShareResult = updateAccountTeamAndShare(DTMUpdateArray, DTMAcctIDs, DTMUserIDs, mapActiveUsers);            
            } catch (Exception e) {
                emailUtils.sendSupportEmail('Exception :'+ e.getMessage()+'.\nCode : AccountTeamIntegrationUtils.updateAccountTeamAndShare(). \nRecords in the batch: ' + DTMUpdateArray);           
            }
            // Clear the arrays
            DTMUpdateArray.clear();
            DTMAcctIDs.clear();
            DTMUserIDs.clear();
            mapActiveUsers.clear(); 
                    
        } // End If (DTMUpdateArray.size() > 0)
        
        //Add the results together
        finalResultList.addAll(updateAccountTeamAndShareResult);        
        finalResultList.addAll(deleteAccountTeamMembersResult);        
        finalResultList.addAll(DTMNoStatusResultList);
        
        //clears the used lists
        updateAccountTeamAndShareResult.clear();
        deleteAccountTeamMembersResult.clear();
        DTMNoStatusResultList.clear();
        
        return finalResultList;  
    } // End function setAccountTeamSub
    

    
    public static List<Result> deleteATM (List<AccountTeamMember> delArray) {
        // Declare variables
        List<Result> DeleteATMResults = new List<Result>();

        // Check the limits
        DBUtils.CheckLimits(delArray, false);

        // Delete the account team members
        try {
            DeleteATMResults = DBUtils.DatabaseDeleteWithResponse(delArray, 'AccountTeamMember', false);
        } catch (Exception e) {
            throw new dellUtil.DellException('deleteATM() Exception: ' + e.getMessage() + ' The input array was ' + delArray);
        }
        return DeleteATMResults;
    }   // End function deleteATM()



    public static List<Result> assembleATMDelArray (List<DellTeamMember> ATMDelArray) {
        // Declare variables
        Integer iDelRecords = 0;
        Integer delDTMArraySize = ATMDelArray.size();
        Integer rem = math.mod(delDTMArraySize, 100);

        Integer j = 0;
        Double iLoops = (delDTMArraySize/100);
        
        List<AccountTeamMember> batchDelArray = new List<AccountTeamMember>();
        List<AccountTeamMember> remDelArray = new List<AccountTeamMember>();

        List<String>remAID = new String[100];
        List<String>remUID = new String[100];
        Integer f = 0;
       
        List<Result> DeleteATMResultbatchesOf100 = new List<Result>();
        List<Result> DeleteATMResultbatchesRem = new List<Result>();
        List<Result> DeleteATMFinalResult = new List<Result>();
        List<Result> DeleteATMCumulativeResults = new List<Result>();
        List<Result> unProcessedDELResultList = new List<Result>();
        
        Integer x = 0;
        
        String iQuery = ' ';
        if (iLoops >= 1 || Test.isRunningTest()) {
            for(Integer i=0; i<=(iLoops-1); i++) {
                for(Integer k =0;k<=99;k++) {
                    iQuery = iQuery+' (AccountId =\''+ATMDelArray[(i*100)+k].AccountId+'\' and UserId =\''+ATMDelArray[(i*100)+k].UserId+'\' and IsDeleted = False) OR';   
                }
                x++;
            }
            if(iQuery != ' ' && iQuery != null) {
                iQuery = iQuery.removeEnd('OR');
                String query = 'select Id, AccountId, UserId from AccountTeamMember where'+iQuery;
                batchDelArray = database.query(query);
                if (batchDelArray.size() > 0) {
                    try {
                        DeleteATMResultbatchesOf100 = deleteATM(batchDelArray);
                    } catch (Exception e) {
                        throw new dellUtil.DellException('deleteATM() Exception: ' + e.getMessage());
                    }
                }
                batchDelArray.clear();
            }
        }

        // Process the remaining records using integer j
        if (rem > 0) {
            // Set the values for the remaining records
            for (Integer k=0; k<rem; k++) {
                remAID.set(k, ATMDelArray[(j*100)+k].AccountId);
                remUID.set(k, ATMDelArray[(j*100)+k].UserId);
                // Increment the counter
                f++;
            }

            // Initialize the variables for account Id and user Id
            for (Integer m=f; m<100; m++) {
                remAID.set(m, null);
                remUID.set(m, null);
            }
            
        String iQuery2 = '';
        for(Integer k=0; k<rem; k++) {
            iQuery2 = iQuery2+' (AccountId =\''+remAID[k]+'\' and UserId =\''+remUID[k]+'\' and IsDeleted = False) OR';   
        }
        if(iQuery2 != null && iQuery2 != '') {
            iQuery2 = iQuery2.removeEnd('OR');
            String query2 = 'select Id, AccountId, UserId from AccountTeamMember where'+iQuery2;
            remDelArray = database.query(query2);
        }
        // Delete the account team member records
        if (remDelArray.size() > 0) {
            try {
                DeleteATMResultbatchesRem = deleteATM(remDelArray);
            } catch (Exception e) {
                throw new dellUtil.DellException('deleteATM() Exception: ' + e.getMessage());
            }
        }

        // Clear the remainder deletion array
        remDelArray.clear();


        // Clear the Id storage arrays
        remAID.clear();
        remUID.clear();


        }   // End if (rem > 0)
            DeleteATMCumulativeResults.addAll(DeleteATMResultbatchesOf100);
            DeleteATMCumulativeResults.addAll(DeleteATMResultbatchesRem);
            Integer DelATMCumulativeSize= DeleteATMCumulativeResults.size();

            if (DelATMCumulativeSize < delDTMArraySize)
            {
            
                Map<String, Result> delATMResultSuccesMAP = new Map<String, Result>();
                Map<String, DellTeamMember> delDellTeamMemberMAP = new Map<String,DellTeamMember>();

                List<String> errorCodeList = new List<String>();
                List<String> errorDetailsList = new List<String>();
                 
                 for (Result delATMCumulativeMap : DeleteATMCumulativeResults) {
                    delATMResultSuccesMAP.put(delATMCumulativeMap.AccountId + '-' + delATMCumulativeMap.UserId, delATMCumulativeMap);
                }
                 
                for (DellTeamMember delDTMMap : ATMDelArray) {
                    delDellTeamMemberMAP.put(delDTMMap.AccountId + '-' + delDTMMap.UserId, delDTMMap);
                }
            
                Set<String> delATMSuccessMapKeySet = new Set<String>();
                Set<String> delDTMMapKeySet = new Set<String>();
                
                delATMSuccessMapKeySet = delATMResultSuccesMAP.keySet();
                delDTMMapKeySet = delDellTeamMemberMAP.keySet();    
                
                for (string delDTMMapKey : delDTMMapKeySet) {
                    if (!delATMSuccessMapKeySet.contains(delDTMMapKey)) {
                        
                        DellTeamMember delATMMapValue = delDellTeamMemberMAP.get(delDTMMapKey);
                        Result ResultItem= new Result();
                        ResultItem.AccountId = delATMMapValue.AccountId;
                        ResultItem.UserId = delATMMapValue.UserId;
                        ResultItem.isSuccess = true; //updated from false as the INVALID_RECORD means record doesnt exist. This is as per mutual agreement with Integ architect
                        ResultItem.Status ='I';
                        ResultItem.errorCodes = 'INVALID_RECORD';
                        ResultItem.errorDetails = 'Invalid record or record could not be found';
                        unProcessedDELResultList.add(ResultItem);
                    }
                }
            }
            DeleteATMFinalResult.addAll(unProcessedDELResultList);
            DeleteATMFinalResult.addAll(DeleteATMCumulativeResults);
            return DeleteATMFinalResult;
    }   // End function assembleATMDelArray()


    public static List<Result> deleteAccountTeamMembers (List<DellTeamMember> DTMDelArray) {
        // Declare variables
        List<Result> assembleATMDelArrayResult = new List<Result>();
        
        // Delete the account team members
        try {
            assembleATMDelArrayResult = assembleATMDelArray(DTMDelArray);
        } catch (Exception e) {
            throw new dellUtil.DellException('assembleATMDelArray() Exception: ' + e.getMessage());
        }
        return assembleATMDelArrayResult;
    }// End function deleteAccountTeamMembers


    public static List<Result> updateAccountTeamAndShare (List<DellTeamMember> dellTeamMembers, Set<String> DTMAcctIDs, Set<String> DTMUserIDs, Map<String, User> mapActiveUsers) {
        // Declare variables
        List<AccountTeamMember> AcctTeamUpdateArray = new List<AccountTeamMember>();
        
        List<Result> updateATMResultBatch = new List<Result>();
        List<Result> cumulativeATMResult = new List<Result>();        
        List<Result> unProcessedResultList = new List<Result>();
        
        List<String> errorCodeList = new List<String>();
        List<String> errorDetailsList = new List<String>();
        List<String> errorMessageList = new List<String>(); //CR9402
        
        // Create a map of active accounts and owners
        Map<String, String> mapOwnerAndAccount = new Map<String, String>();

        // Create object of active account record IDs and owner IDs
        List<Account> accountsToUpdate = [select Id, OwnerId from Account where Id in :DTMAcctIDs];

        //CR9402 : declare variables            
        String key;
        Map<String, Result> ResultMap = new Map<String, Result>();

        // Populate the map of active accounts and owners
        For (Account acctToUpd : accountsToUpdate) {
            mapOwnerAndAccount.put(acctToUpd.Id, acctToUpd.OwnerId);
        }

        // Build the Account Team and Account Share update arrays
        For (DellTeamMember dtm : dellTeamMembers) {
            // If user is active and account is active . . .
            if (mapActiveUsers.containsKey(dtm.UserId) && mapOwnerAndAccount.containsKey(dtm.AccountId)) {

                // Add the member to the AccountTeamMember update array
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = dtm.AccountId;
                atm.UserId = dtm.UserId;
                atm.TeamMemberRole = dtm.TeamMemberRole;
                // 3.0: START
                atm.AccountAccessLevel = dtm.AccountAccessLevel;
                atm.OpportunityAccessLevel = dtm.OpportunityAccessLevel;
                atm.CaseAccessLevel = dtm.CaseAccessLevel;
                // 3.0: END
                AcctTeamUpdateArray.add(atm);
            } else{               
                errorCodeList.clear();
                errorDetailsList.clear();

                if(!mapActiveUsers.containsKey(dtm.UserId)){
                    errorCodeList.add('INVALID_USERID');
                    errorDetailsList.add('Invalid UserId or the User is Inactive');                 
                }
                if(!mapOwnerAndAccount.containsKey(dtm.AccountId)){
                    errorCodeList.add('INVALID_ACCOUNTID');
                    errorDetailsList.add('Invalid AccountId');                  
                }
                Result ResultItem= new Result();
                
                ResultItem.AccountId = dtm.AccountId;
                ResultItem.UserId = dtm.UserId;
                ResultItem.isSuccess = false;
                ResultItem.Status ='A';
                ResultItem.errorCodes = StringUtils.joinStrings(errorCodeList,',');
                ResultItem.errorDetails =StringUtils.joinStrings(errorDetailsList,',');
                
                unProcessedResultList.add(ResultItem);              
            }            
        }   // End For (DellTeamMember dtm : dellTeamMembers)
        
        // Update the account team in batches of 200
        if (AcctTeamUpdateArray.size() > 0){
             try {
               // Perform the insert
                    Database.SaveResult[] insResults = Database.insert(AcctTeamUpdateArray, false);

                    //cycle through each save result
                    for(integer i = 0; i< insResults.size(); i++){
                        AccountTeamMember ATMrecord = AcctTeamUpdateArray[i];
                        Result res = new Result();
                        
                        key = ATMrecord.AccountId + ':' + ATMrecord.UserId;                            
                        res.AccountId = ATMrecord.AccountId;
                        res.UserId = ATMrecord.UserId;
                        res.isSuccess = insResults[i].isSuccess();
                        res.Status ='A';
                        ResultMap.put(key, res);   
                        
                        //Cycle through errors
                        if (insResults[i].isSuccess() == false) {

                            Database.Error[] insErrors = insResults[i].getErrors();
                            
                            //Add the error details as well just like existing logic.
                            // Cycle through the errors
                            for (Database.Error insError : insErrors) {                 
                                errorCodeList.add(''+insError.getStatusCode());
                                errorMessageList.add(insError.getMessage());                    
                            }   // End for (Database.Error insError : insErrors)  
                            ResultMap.get(key).errorCodes =  StringUtils.joinStrings(errorCodeList,',');
                            ResultMap.get(key).errorDetails =  'AccountTeamMember insert failed. '+ StringUtils.joinStrings(errorMessageList,','); 
                                    
                            //Now, remove the entry from AccountShareMap.. bcoz ATM failed, no need of AccountShares
                            //AccountShareMap.remove(key); // 3.0: Commented
                            
                        }   // End if (insResults[i].isSuccess() == false)  
                    }   // End for
                newlyAddedAccTeamList.addAll(AcctTeamUpdateArray);
            } catch (Exception e) {
                //CR9402 : we don't throw exception from now on. Just send email notification
                emailUtils.sendSupportEmail('update AccountTeamMember Exception : ' + e.getMessage() +'[ Code:  AccountTeamUtil.updateAccountTeamAndShare() ]  Batch : '+ newlyAddedAccTeamList);
            }            
            
        }   // End if (AcctTeamUpdateArray.size() > 0)

        // Clear objects
        mapOwnerAndAccount.clear();
        accountsToUpdate.clear();
        
        //adds the unprocessed result list
        cumulativeATMResult.addAll(unProcessedResultList);
        cumulativeATMResult.addAll(ResultMap.values()); // CR9402: adding the results from ATM & AS inserts.  

        //clears the lists after processing
        newlyAddedAccTeamList.clear();
        unProcessedResultList.clear();
        
        return cumulativeATMResult;

    } // End function updateAccountTeamAndShare
     }
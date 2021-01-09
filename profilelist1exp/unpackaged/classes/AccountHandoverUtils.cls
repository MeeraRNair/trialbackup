/**
 
* Name          : AccountHandoverUtilsTest
* Description   : Test method for Account handover utility methods.
* ---------------------------------------------------------
* Revision  Name        Date            Description
* 1.0       Unknown     xxxx            Creation
* 2.0       Ravali      14 Nov 2017     CR # 15096 - Comment AccountHandoverUtils Class
*/


public class AccountHandoverUtils {
    
   //2.0 CR # 15096 - Comment AccountHandoverUtils Class
   /* 
    //method for collecting all ISR team member Account Id and UserIds
    public static void processAccountHandOversForISRs(List<AccountTeamMember> newlyAddedAccTeamList){ // takes public static variable for processing. So parameter is passed.
        
        System.debug ('## Inside processAccountHandOversForISRs');          
        
        Map<String,String> accountIdToUserIdMap = new Map<String,String>();
                
        for(AccountTeamMember tempAccTeamRec: newlyAddedAccTeamList){
            If(tempAccTeamRec.TeamMemberRole == 'Inside Sales Rep'){
                //adds the user id and Account Id into a map:  one ISR team member per one Account. More than one records will be ignored.
                if(!accountIdToUserIdMap.containsKey(tempAccTeamRec.AccountId)){   // skips the remaining team members if an ISR has already come in for an Account. 
                    accountIdToUserIdMap.put(tempAccTeamRec.AccountId,tempAccTeamRec.UserId);
                }                           
            }
        }
        
        if(accountIdToUserIdMap.size() > 0){
            //Calls the @future method          
            updateAccountHandOverRecords(accountIdToUserIdMap);
        }
        System.debug ('## Exiting from processAccountHandOversForISRs method');     
    }//end of processAccountHandOversForISRs method
    
    
    //Asynchronous method for updating the Account handover records 
    @future
    public static void updateAccountHandOverRecords(Map<String,String> accountIdToUserIdMap){ //List<String> AccountIdList,List<String> UserIdList
        System.debug ('## Inside the Future method');
        
        Id userId;
        List<Account_Handover__c> accHandoverRecordsListToUpdate = new List<Account_Handover__c>();
        
        for(Account_Handover__c accHandoverRecord : [SELECT Status__c, Outgoing_rep__c, Outgoing_Handover_Tasks_Completed__c, Incoming_rep__c, 
                                                     Incoming_Handover_Tasks_Completed__c, Date_for_Warm_Handover_Call__c, Account__c  
                                                     FROM Account_Handover__c WHERE Account__c IN :accountIdToUserIdMap.keySet()
                                                     AND Status__c = 'Pending Assignment']){                                                        
            
            userId = accountIdToUserIdMap.get(accHandoverRecord.Account__c);
            accHandoverRecord.Incoming_rep__c = userId;
            accHandoverRecord.Status__c = 'Pending Follow-up';
            
            accHandoverRecordsListToUpdate.add(accHandoverRecord);
            if (accHandoverRecordsListToUpdate.size() == 200){
                update accHandoverRecordsListToUpdate;
                accHandoverRecordsListToUpdate.clear();
            }
            
        }
        if (accHandoverRecordsListToUpdate.size() > 0 ){
            System.debug ('## Updating the last set of AHOs');
            update accHandoverRecordsListToUpdate;
        }
        System.debug ('## Existing the Future method');
    }//end of future method
    */    
    
    public static void createFollowUpTasksForAccHandovers(List<Account_Handover__c> accHandoverRecordsList){
        
        List<Task> newTaskList = new List<Task>();
        Id stdTaskRecTypeId = IdLookupUtils.getRecordTypeId('Standard Task', 'Task', true);
        
        for (Account_Handover__c accHandoverRecord: accHandoverRecordsList){ //loops over AH list
            
            
            if(accHandoverRecord.Incoming_rep__c != null){  //ensures that the Incoming_rep__c has value
                //Creates new task
                task taskItem = new task(RecordTypeId = stdTaskRecTypeId,
                                    OwnerId = accHandoverRecord.Incoming_rep__c,
                                    WhatId = accHandoverRecord.Id,
                                    Subject = 'Account Handover - Requires Follow up', 
                                    Type = 'Account Handover Follow Up',    
                                    Description = 'A new account handover task has been assigned to you. '
                                                + 'Please ensure all information is complete and a warm handover call is scheduled with the customer.',                                 
                                    ActivityDate = Date.today()+3 );// due date                             
                                
                newTaskList.add(taskItem);
            }//end of If        
                
        }// end of for loop         
        
        insert newTaskList; //inserts the tasks.
        System.debug ('## Tasks were created');     
    }
    

}
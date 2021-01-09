/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     08-Nov-2013     Jiji            CR 235 - Lead visibility to Account Team Members  
                                        Batch to create Group member for account Group
2.0     01-Jun-2018     Kishore         As part of code reduce, commented the "DBUtils.flushOutTheJobsQueue()"
                                        Since the whole method "flushOutTheJobsQueue" was already commented in another class
                                        and hence we are commenting here aswell.
2.1     05-Jun-2018     Kishore         Defined "isTest" variable, to get code coverage for finish method                                  
********************************************************************************************/
global class CMAP_AccountTeamBatch implements Database.Batchable<sObject> {
    public String query;
    public Boolean isTest=False; //v2.1
    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
   global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Account_Team__c> accTeamlistToUpdate = new List< Account_Team__c >();
       try{
           for(sObject obj :scope){
               Account_Team__c batchRec = (Account_Team__c)obj;
               batchRec.Is_Processed__c = true;
               batchRec.Account_User_ID__c = batchRec.Account_User_ID__c + ':prg';
               accTeamlistToUpdate.add(batchRec);
            }
            database.SaveResult[] updateResults;
            if(accTeamlistToUpdate.Size() > 0){
                updateResults = Database.Update(accTeamlistToUpdate, false);
            }
        }catch (Exception e){
        }  
    }// end of execute method
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest() || isTest){ //v2.1- Added "isTest" variable, to get code coverage for below peice of code 
            CMAP_AccTeamGroupMemScheduler schJob = new  CMAP_AccTeamGroupMemScheduler();
            datetime TodayDate = datetime.now();
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
            system.schedule('CMAP_AccTeamGroupMemScheduler'+String.valueOf(TodayDate),schTime, schJob);
        }            
    }
}
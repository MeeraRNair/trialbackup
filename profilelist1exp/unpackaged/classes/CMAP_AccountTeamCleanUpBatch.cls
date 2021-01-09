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
global class CMAP_AccountTeamCleanUpBatch implements Database.Batchable<sObject> {
    public String query;
    public Boolean isTest=False; //v2.1
    global database.querylocator start(Database.BatchableContext BC){
        //DBUtils.flushOutTheJobsQueue(); //v2.0
        return Database.getQueryLocator(query);
    }
   global void execute(Database.BatchableContext BC, List<sObject> scope){
       try{
            List<Account_Team__c> lstOfAccTeam = new List<Account_Team__c>();
            for(sObject obj :scope){
                Account_Team__c batchRec = (Account_Team__c)obj;
                lstOfAccTeam.add(batchRec);
            }
            database.deleteResult[] deleteResults;
            if(lstOfAccTeam.size() > 0){
                 deleteResults = database.delete(lstOfAccTeam, false);
             }
        }
        catch (Exception e){
        }  
    }// end of execute method
    global void finish(Database.BatchableContext BC){
         if(!Test.isRunningTest() || isTest){ //v2.1- Added "isTest" variable, to get code coverage for below peice of code 
            CMAP_AccountTeamScheduler schJob = new  CMAP_AccountTeamScheduler ();   
            datetime TodayDate = datetime.now();
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
            system.schedule('CMAP_AccountTeamScheduler: '+String.valueOf(TodayDate),schTime, schJob);
        }            
     }
}
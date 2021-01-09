/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     08-Nov-2013     Jiji            CR 235 - Lead visibility to Account Team Members  
2.0     05-Jun-2018     Kishore         Defined "isTest" variable, to get code coverage for CMAP_AccountTeamBatch finish method
********************************************************************************************/
global class CMAP_AccountTeamScheduler implements Schedulable{
    Public Boolean isTest; //v2.0
    global void execute(SchedulableContext sc) {
        CMAP_AccountTeamBatch accTeamBtch = new CMAP_AccountTeamBatch ();
        accTeamBtch.isTest= isTest; //v2.0
        accTeamBtch.query= 'SELECT Account__c, Account_ID__c, '+
                           ' Sales_Channel_Name__c, '+
                           ' Account_Type__c, Badge_Number__c, '+
                           ' Team_Member_Role__c, Status__c, '+
                           ' Account_User_ID__c, '+
                           ' Is_Processed__c '+
                           ' FROM Account_Team__c '+ 
                           'LIMIT 10000'; 
        system.debug('###accTeamBtch.query####' + accTeamBtch.query);
        database.executebatch(accTeamBtch,200);
        
    }  
}
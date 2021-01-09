/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     08-Nov-2013     Jiji            CR 235 - Account Team Members Clean up
2.0     05-Jun-2018     Kishore         Defined "isTest" variable, to get code coverage for CMAP_AccountTeamCleanUpBatch finish method                                         
********************************************************************************************/
global class CMAP_AccountTeamCleanUpScheduler implements Schedulable{
    Public Boolean isTest; //v2.0
    global void execute(SchedulableContext sc) {
            
        CMAP_AccountTeamCleanUpBatch accTeamBtch = new CMAP_AccountTeamCleanUpBatch ();
        accTeamBtch.isTest= isTest; //v2.0
        accTeamBtch.query= 'SELECT Account__c, Account_ID__c, '+
                           ' Sales_Channel_Name__c,Account_Type__c, '+
                           ' Badge_Number__c,Team_Member_Role__c,Status__c, '+
                           ' Account_User_ID__c,Is_Processed__c'+
                           ' FROM Account_Team__c '+ 
                           ' WHERE Is_Processed__c = TRUE'; 

        database.executebatch(accTeamBtch,200); 
    }  
}
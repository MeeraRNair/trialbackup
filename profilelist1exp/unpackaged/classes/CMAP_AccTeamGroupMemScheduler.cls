/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     08-Nov-2013     Jiji            CR 235 - Lead visibility to Account Team Members  
2.0     05-Jun-2018     Kishore         Defined "isTest" variable, to get code coverage for CMAP_AccTeamGroupMemBatch finish method                                        
********************************************************************************************/
global class CMAP_AccTeamGroupMemScheduler implements Schedulable{
    Public Boolean isTest; //v2.0
    global void execute(SchedulableContext sc) {
            
        CMAP_AccTeamGroupMemBatch atGroupMemBatch = new CMAP_AccTeamGroupMemBatch ();
        atGroupMemBatch.isTest= isTest; //v2.0
        atGroupMemBatch.query= 'SELECT Account__c, Account_ID__c, '+
                               ' Sales_Channel_Name__c, User__c, '+
                               ' Account_Type__c, Badge_Number__c, '+
                               ' Team_Member_Role__c,Status__c, '+
                               ' Account_User_ID__c, Is_Processed__c '+
                               ' FROM Account_Team__c '+ 
                               ' WHERE Is_Processed__c = TRUE'; 

        system.debug('###atGroupMemBatch.query####' + atGroupMemBatch.query);
        database.executebatch(atGroupMemBatch, 200);
        
    }  
}
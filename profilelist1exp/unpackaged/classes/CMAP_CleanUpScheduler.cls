/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     18-Jan-2013     Sandhya         CR 7832 - Lead visibility to Partner Lead Super User   
                                        Scheduler for cleaning up the CMAP ProcessQueue records
2.0     20-Nov-2013     Annie           CR 8837:R15.3
*/
global class CMAP_CleanUpScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        CMAP_CleanUpBatch batchObj = new CMAP_CleanUpBatch();
        batchObj.query = 'SELECT Id, Channel_Lead__c, Mass_Lead_Upload_Request__c, Partner_Account__c,Type__c,operation__c,Super_User_Id__c,GroupId__c,createdDate'+
                        ' FROM CMAP_ProcessQueue__c';//ver 2.0: Added a field
        system.debug('###batchObj.query####' + batchObj.query);
        database.executebatch(batchObj,1000);        
    }  
}
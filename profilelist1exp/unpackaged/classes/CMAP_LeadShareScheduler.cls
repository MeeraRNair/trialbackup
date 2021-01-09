/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     18-Jan-2013     Sandhya         CR 7832 - Lead visibility to Partner Lead Super User
                                        Scheduler for Lead share creation   
2.0     05-Nov-2013     Jiji            CR 235: R15.3
3.0     20-Nov-2013     Annie           CR 8837:R15.3
*/
global class CMAP_LeadShareScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        CMAP_LeadShareBatch batchObj = new CMAP_LeadShareBatch();
        batchObj.query = 'SELECT Id, Channel_Lead__c, Mass_Lead_Upload_Request__c,'+ //ver 3.0: Added a field
                         ' Partner_Account__c,Type__c,operation__c,Super_User_Id__c, '+
                         ' GroupId__c '+
                         ' FROM CMAP_ProcessQueue__c '+ 
                         //ver 2.0: Code start
                         'WHERE (Type__c = \'Share\' OR Type__c = \'TeamShare\' OR Type__c = \'MLUR Share\')'; //ver 3.0: Added
                         //ver 2.0: Code end                         
        system.debug('###batchObj.query####' + batchObj.query);
        database.executebatch(batchObj,200);
    }  
}
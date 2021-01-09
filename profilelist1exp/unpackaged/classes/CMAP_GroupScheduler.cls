/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     18-Jan-2013     Sandhya         CR 7832 - Lead visibility to Partner Lead Super User   
                                        Scheduler for creating Group
2.0     05-Nov-2013     Jiji            CR 235: R15.3
3.0     20-Nov-2013     Annie           CR 8837:R15.3
*/
global class CMAP_GroupScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        CMAP_GroupBatch batchObj = new CMAP_GroupBatch();
        if(!Test.isRunningTest()){
            batchObj.query = 'SELECT Id, Channel_Lead__c, Mass_Lead_Upload_Request__c, '+ //Ver 3.0: Added one field
                             ' Partner_Account__c,Type__c,operation__c,Super_User_Id__c, '+
                             ' GroupId__c'+
                             ' FROM CMAP_ProcessQueue__c '+ 
                             //Ver 2.0: Code Start
                             ' WHERE (Type__c = \'Group\' OR Type__c = \'GroupMember\' '+
                             ' OR Type__c = \'TeamGroup\')';
                             //Ver 2.0: Code End
                    system.debug('###batchObj.query1111####' +batchObj.query);             
        }
        else{
            batchObj.query = 'SELECT Id, Channel_Lead__c, Mass_Lead_Upload_Request__c, '+ //Ver 3.0: Added one field
                             ' Partner_Account__c,Type__c,operation__c,Super_User_Id__c, '+
                             ' GroupId__c'+
                             ' FROM CMAP_ProcessQueue__c '+ 
                             //Ver 2.0: Code Start
                             ' WHERE (Type__c = \'Group\' OR Type__c = \'GroupMember\' '+
                             ' OR Type__c = \'TeamGroup\') Limit 1';
                             //Ver 2.0: Code End
            system.debug('###batchObj.query2222####' +batchObj.query);                             
        }
        system.debug('###batchObj.query####' +batchObj.query);
        database.executebatch(batchObj,200);
        
    }  
}
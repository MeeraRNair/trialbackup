global class Batch_DealExpirationNotificationExecute implements Schedulable {
     
    global static void execute(SchedulableContext SC) {     
       
        Id batchinstanceid = database.executeBatch(new Batch_DealExpirationNotification());
           
        }
        
     
    
    Public static void executeBatch(Batch_DealExpirationNotification batch) {     
    
        
        System.debug('### ExecuteBatch');   
        
        Id batchinstanceid = database.executeBatch(batch);
         
         System.debug('###DEBUG### batchinstanceid ' + batchinstanceid);
        
    }
    
}
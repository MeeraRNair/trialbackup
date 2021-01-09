global class BatchConvertAccountPAtoEAExecute implements Schedulable {
     
    global static void execute(SchedulableContext SC) {     
        Id batchinstanceid;
        integer batchSize = 1;
        
        System.debug('### Execute');
        
            //Rev 1.2                  
            batchinstanceid = database.executeBatch(new BatchConvertAccountPAtoEA(), batchSize);
        }
        
     
    
    global static void executeBatch(BatchConvertAccountPAtoEA batch) {     
        Id batchinstanceid;
        integer batchSize = 1;
        
        System.debug('### ExecuteBatch');   
        
            batchinstanceid = database.executeBatch(batch, batchSize);
        
    }
    
}
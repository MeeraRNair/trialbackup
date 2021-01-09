global class SOM_BoomiLogScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        SOM_GroupBatch batchObj = new SOM_GroupBatch();
        Datetime stDayTime = System.now()-integer.ValueOf(System.Label.SOM_Boomi_Log_Batch_Criteria);
        String stDayTime_formatted = stDayTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String st = 'SELECT Id, createdDate FROM SOM_Boomi_Log__c '+ 
                         'WHERE createdDate < '+stDayTime_formatted;

        integer batchSize= integer.ValueOf(System.Label.SOM_Boomi_Log_Batch_Size);
        // Fenny added: Limit record to <= 200, because only 1 batch (size=200) can be executed in test method
        if(Test.isRunningTest()){
            batchObj.query = 'SELECT Id, createdDate FROM SOM_Boomi_Log__c '+ 
                     'WHERE createdDate <  '+ stDayTime_formatted + ' LIMIT 200';

        }else{
            batchObj.query = 'SELECT Id, createdDate FROM SOM_Boomi_Log__c '+ 
                     'WHERE createdDate <  '+ stDayTime_formatted;
        }
        database.executebatch(batchObj,batchSize);
    }  
}
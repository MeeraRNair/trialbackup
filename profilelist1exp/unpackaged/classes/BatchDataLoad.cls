global class BatchDataLoad implements Database.Batchable<sObject> {
    
    public string query;
    public string fieldToUpdate;
    public string newValue;
    public string objectName;
    public Integer batchSize;
    public boolean needHelp;
    private Batch_Load_Data_Status__c loadStatus = null;
    public  List<Batch_Load_Data_Status__c> loadStatusList;
    
    global database.querylocator start(Database.BatchableContext BC){
        system.debug('>>>>>>>>>> BatchDataLoad query - ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(scope != null && scope.size() > 0){
            Map<Id, sObject> sobjMap = null;
            DescribeSObjectResult result = null;
            
            for(sObject obj : scope){
                if(result == null) { result = obj.getSobjectType().getDescribe(); }
                if((fieldToUpdate != null && fieldToUpdate.length() > 0) && (newValue != null && newValue.length() > 0)){
                    obj.put(fieldToUpdate, newValue);
                }
                if(sobjMap == null) { sobjMap = new Map<Id, sObject>(); }
                sobjMap.put(obj.Id, obj);
            }
            
            if(sobjMap != null && sobjMap.size() > 0){
                try{
                    system.debug('>>>>>>>>>>>>>>>> BatchDataLoad updating opp RT - ' + sobjMap.size());
                    if(needHelp){
                        BatchDataLoadHelper.getHelper(result, sobjMap);
                    }
                    update sobjMap.values();
                }catch(Exception ex){
                    system.debug('>>>>>>>>>>>>>>>> BatchDataLoad throwing exception');
                    loadStatus = new Batch_Load_Data_Status__c(Name=BC.getJobId(),Object_API_Name__c=result.getName(),
                    					Message__c=String.escapeSingleQuotes(ex.getMessage()));
                    //loadStatus.Name = BC.getJobId();
                    //loadStatus.Object_API_Name__c = 'Opportunity';
                    //loadStatus.Message__c = String.escapeSingleQuotes(ex.getMessage());
                    loadStatusList.add(loadStatus);
                    system.debug('>>>>>>>>>>>>>>>> BatchDataLoad in execute() - ' + loadStatusList.size());
                }
            }
            if(loadStatusList != null && loadStatusList.size() > 0){
                system.debug('>>>>>>>>>>>>>>>> BatchDataLoad inserting Batch_Load_Data_Status__c - ' + loadStatusList);
                insert loadStatusList;
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        /*system.debug('>>>>>>>>>>>>>>>> BatchDataLoad in finish() - ' + loadStatusList.size());
        if(loadStatusList != null && loadStatusList.size() > 0){
            system.debug('>>>>>>>>>>>>>>>> BatchDataLoad inserting Batch_Load_Data_Status__c');
            insert loadStatusList;
        }*/
        
        /*BatchDataLoadScheduler dlBatchScheduler = new BatchDataLoadScheduler();
        dlBatchScheduler.query = query;
        dlBatchScheduler.fieldToUpdate = fieldToUpdate;
        dlBatchScheduler.newValue = newValue;
        dlBatchScheduler.objectName = objectName;
        dlBatchScheduler.batchSize = batchSize;
        dlBatchScheduler.needHelp = needHelp;
        datetime todayNow = system.now().addMinutes(1);
        string runtime = todayNow.second() + ' ' + todayNow.minute() + ' ' + todayNow.hour() + ' ' + todayNow.day() + ' ' + todayNow.month() + ' ? ' + todayNow.year();
        system.schedule('Loading ' + objectName + ' @ ' + runtime, runtime, dlBatchScheduler);*/
        
        /*BatchDataLoad dl = new BatchDataLoad();
        dl.query = query;
        dl.fieldToUpdate = fieldToUpdate;
        dl.newValue = newValue;
        dl.objectName = objectName;
        dl.batchSize = batchSize;
        dl.needHelp = needHelp;
        system.scheduleBatch(dl, 'Loading ' + objectName + datetime.now().addMinutes(1), 1, batchSize);*/
    }

}
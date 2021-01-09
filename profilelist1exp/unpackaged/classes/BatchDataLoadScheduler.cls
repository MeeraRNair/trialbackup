global class BatchDataLoadScheduler implements Schedulable{
 public string fieldToUpdate;
 public string newValue;
 public string query;
 public string objectName;
    public Integer batchSize;
    public boolean needHelp;
 
  
  global void execute(SchedulableContext sc){
  system.debug('in BatchDataLoadScheduler execute method');
  
                BatchDataLoad dlBatch = new BatchDataLoad();
                dlBatch.query = query;
                dlBatch.fieldToUpdate = fieldToUpdate;
                dlBatch.newValue = newValue;
                dlBatch.objectName = objectName;
                dlBatch.batchSize = batchSize;
                dlBatch.needHelp = needHelp;
                dlBatch.loadStatusList = new List<Batch_Load_Data_Status__c>();
                ID batchprocessid = Database.executeBatch(dlBatch, batchSize==null?200:batchSize); 
                
  }
  
}
/* 
Description : The batch apex schedulable for CMI Data Queue status update from Pending to In progress

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     12-Dec-2011   	Krishna     CR 6708(R13.1) Created for updating the CMI Data Queue status from Pending to In progress 
*/

global class BatchUpdateCMIdataQueue implements Database.Batchable<sObject> {
	
	public String query;
	public Boolean isTest= false;
	global database.querylocator start(Database.BatchableContext BC){
		system.debug('## Inside Start method');
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	system.debug('## Inside Execute method');   	
    	CMI_Data_Queue__c cmiDataQueueRecord;
    	List<CMI_Data_Queue__c> cmiDataQueueList = new List<CMI_Data_Queue__c>();
    	
    	for(sObject obj :scope){
	    	cmiDataQueueRecord = (CMI_Data_Queue__c)obj;
	    	cmiDataQueueRecord.Status__c = 'In Progress';
	    	cmiDataQueueList.add(cmiDataQueueRecord);	    	
	    }
    	
    	if(cmiDataQueueList.size() >0) {
    		Database.update(cmiDataQueueList, false);
    	}	
    }// end of execute method
    
    global void finish(Database.BatchableContext BC){
    	system.debug('## Inside finish method');
    	
    	//schedule CMI integration job for after 5 sec.
    	BachCMIdataIntegrationSchedule CMIdataIntegration = new BachCMIdataIntegrationSchedule();
        Integer interval = 5; //SECONDS
        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(datetime.now(), interval);
        if(!isTest){
        	system.schedule('Batch CMI Integration job ' + String.valueOf(datetime.now()), schTime, CMIdataIntegration);
        }
    	
    }	
}
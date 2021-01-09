/* 
Description : The batch apex schedulable for CMI Data Queue status update from Pending to In progress

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     12-Dec-2011   	Krishna     CR 6708(R13.1) Created for updating the CMI Data Queue status from Pending to In progress 
*/
global class BatchUpdateCMIDataQueueSchedule implements Schedulable{		

	public Boolean isTest = false;
	
	global void execute(SchedulableContext sc){
		
       DBUtils.flushOutTheJobsQueue();
       BatchUpdateCMIDataQueue updateCMIDataQueueBatch = new BatchUpdateCMIDataQueue();
		
		if(!isTest) {
	        updateCMIDataQueueBatch.query = 'SELECT Id,Status__c' 
										+ ' FROM CMI_Data_Queue__c' 
										+ ' WHERE Status__c = \'Pending\'' 								
										+ ' ORDER BY LastModifiedDate ASC' 
										+ ' LIMIT ' + StringUtils.defaultString(Label.REUD_Job_limit_for_CMI_callout_process);
		}
		else{
	        updateCMIDataQueueBatch.query =  'SELECT Id,Status__c' 
										+ ' FROM CMI_Data_Queue__c' 
										+ ' WHERE Status__c = \'Pending\' AND Account__r.Name = \'CMIDataScheduleTest12345\'' ;  //test query	        
		}									                                            
        ID batchprocessid = Database.executeBatch(updateCMIDataQueueBatch,400);       
	}
	
}
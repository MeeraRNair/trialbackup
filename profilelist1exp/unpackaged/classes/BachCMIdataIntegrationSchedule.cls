/* 
Description : The batch apex schedulable for integrating data to CMI based on CMI Data Queue records in In progress status

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     12-Dec-2011   	Krishna     CR 6708(R13.1) Created for Http callout to CMI based on CMI Data Queue records in In progress status 
*/

global class BachCMIdataIntegrationSchedule implements Schedulable{
	public Boolean isTest = false;
	
	global void execute(SchedulableContext sc){
	
		DBUtils.flushOutTheJobsQueue();
		BachCMIdataIntegration cmiDataIntegration = new BachCMIdataIntegration();
		
		if(!isTest) {
	        cmiDataIntegration.query = 'SELECT Id, Type__c, Status__c, No_of_retries__c, Account__c' 
										+ ' FROM CMI_Data_Queue__c' 
										+ ' WHERE Status__c = \'In Progress\'' 								
										+ ' ORDER BY LastModifiedDate ASC';
		}
		else{
	        cmiDataIntegration.query =  'SELECT Id, Type__c, Status__c, No_of_retries__c, Account__c' 
										+ ' FROM CMI_Data_Queue__c' 
										+ ' WHERE Status__c = \'In Progress\'' 								
										+ ' AND Account__r.Name = \'cmiDataIntegrationTest12345\'' ;  //test query		        
		}					                                            
        ID batchprocessid = Database.executeBatch(cmiDataIntegration,1); //the batch size must be always 1
                
	}
}
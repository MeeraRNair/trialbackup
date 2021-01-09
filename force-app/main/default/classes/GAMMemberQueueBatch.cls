/* 
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     08-Jul-2011     Natesh Alagiri  Created for CR6236 and CR6238
2.0     31-May-2018     Fenny           CR15896 - Remove duplicate codes found in GAMGroupMemberBatch, GAMMemberQueueBatch, and GAMSharingBatch
*/
global class GAMMemberQueueBatch implements Database.Batchable<sObject> {
	public Boolean isTest = False;
	public String query;
	global database.querylocator start(Database.BatchableContext BC){
        GAMbatchJobUtils.sendOptionalNotification('GAM : Started GM Queue clean up job' , 'Started Queue clean up job now');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	database.delete(scope, false);
    }
    
    global void finish(Database.BatchableContext BC){
        // 2.0: Previously there is block of code that query the AsyncApexJob record and print debug statement. Now they are removed. The AsyncApexJob ID is added to the end of the email being sent by below code
        
		GAMbatchJobUtils.sendOptionalNotification('GAM : Finished GM Queue clean up job' , 'Finished Queue clean up job now. [AsyncApexJob Id: ' + BC.getJobId() + ']'); // 2.0: Added AsyncApexJob Id
		
		GAMSharingSchedule schJob = new GAMSharingSchedule();   
        datetime TodayDate = datetime.now();
        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
        if(!isTest){
	        system.schedule('GAMSharingBatch' +String.valueOf(TodayDate), schTime, schJob);
		} 
    }
}
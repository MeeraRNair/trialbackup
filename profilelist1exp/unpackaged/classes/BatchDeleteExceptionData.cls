/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      25-NOV-2010   Azwanti         Created for CR4117, R12.1

*/
global class BatchDeleteExceptionData implements Database.Batchable<sObject>{
	global string queryOldException;
	//For test method
    public boolean isTest = false;
	
	global Database.Querylocator Start(Database.BatchableContext BC){
		DBUtils.flushOutTheJobsQueue();
		return Database.getQueryLocator(queryOldException);	
	}
	
	global void Execute(Database.BatchableContext BC, List<sObject> scope){
		List<Exception__c> exceptionToDeleteList = new List<Exception__c>();
		for(sObject s: scope){
			Exception__c Exceptions = (Exception__c)s;
			exceptionToDeleteList.add(Exceptions);
		}	
		
		if(exceptionToDeleteList.size() > 0){
			Database.DeleteResult[] resultList = Database.delete(exceptionToDeleteList,false);
		}
	}
	
	global void Finish(Database.BatchableContext BC){
		if(isTest != true){
	        //1. Scheduled BatchUpdAccountWorkItem after 1 hour/3600sec interval	        
	        AccountOwnerTransitionUtils.scheduleJobs('Account Work Items');
    	}	
	}
}
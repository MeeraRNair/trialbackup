global class BatchRunAllTestClasses implements Database.Batchable<sObject> {
	public boolean isTest = false;
	public List<ApexTestQueueItem> items = null;
	
	public string jobParentId;
	public string queryString;
	public final string serverUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
	public List<string> recipients = new List<string>{'SFDC-ApexDev@dell.com'};
   
	global Database.QueryLocator start(Database.BatchableContext BC){
		try{
			return Database.getQueryLocator(queryString);
		}catch(Exception ex){
        	string err = ex.getLineNumber() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString();
    		emailUtils.sendTextEmail(recipients, 'Failed to start Run-All-Test batch job at ' + serverUrl, err);
		}
		return null;
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		try{
			if ((scope != null) && (scope.size() > 0)) {
				string startDateTime = string.valueOf(DateTime.Now());
				List<ApexTestQueueItem> queueItems = new List<ApexTestQueueItem>();
				for (sObject sobj : scope) {
					ApexClass cls = (ApexClass)sobj;
					queueItems.add(new ApexTestQueueItem(ApexClassId = cls.Id));
				}
	
				if(!isTest){
					insert queueItems;
				}
	
	            // Get the job ID of the first queue item returned.
	            if(!isTest){
		            items = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id = :queueItems[0].Id LIMIT 1];
	            }
	            if((items != null) && (items.size() > 0)){
	            	ApexTestQueueItem item = items[0];
		            jobParentId = item.ParentJobId;
		            
		            string emailBody = 'Run-All-Test started at ' + serverUrl + ' at ' + startDateTime + '. The job parent Id = ' + jobParentId;
		    		emailUtils.sendTextEmail(recipients, 'Run-All-Test Job Parent Id' , emailBody);
	            }else{
		    		emailUtils.sendTextEmail(recipients, 'Failed to queue Apex Test for Run-All-Test at ' + serverUrl, 'Failed to queue Apex Test for Run-All-Test');
	            }
	        }else{
	    		emailUtils.sendTextEmail(recipients, 'Failed to queue Apex Test for Run-All-Test at ' + serverUrl, 'No test classes added to the queue');
	        }
		}catch(Exception ex){
        	string err = ex.getLineNumber() + ' | ' + ex.getMessage() + ' | ' + ex.getStackTraceString();
    		emailUtils.sendTextEmail(recipients, 'Failed to execute Run-All-Test batch job at ' + serverUrl, err);
		}
	}

	global void finish(Database.BatchableContext BC){
	}
}
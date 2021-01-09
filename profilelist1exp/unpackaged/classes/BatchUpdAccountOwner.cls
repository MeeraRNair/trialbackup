/***********************************************************
* Name          : BatchUpdAccountOwner 
* Description   : Update Account Owner 
* ---------------------------------------------------------
* Revision      Release Name    Date            Description
* 1.0           12.1    MenMee  22.12.2010      CR5716 Processing Account owner change using batch Apex
* 1.1           12.1    MenMee  04.01.2011      Schedule Time: 1) Don't execute if BatchUpdateWorkItemToComplete is still running or going to execute within 2 hours
*                                                              2) Schedule the next job 1 hour from Finish().
* 1.2           12.1    MenMee  19.01.2011      1) Add LIMIT count to end user account
*												2) Split out partner account to BatchUpdAccountForPartner class
* 1.3			12.1	MenMee	28.01.2011		Temporary get proccessed data
* 1.4			ECR		MenMee	21.03.2011		1) (CR6022) Requery owner update field to get latest value
*												2) Exception Handling and 3) Don't null owner update field
* 2.0					MenMee	25.04.2013		CR8242 Remove hardcoded email address
* 2.1			0502	Prasanthi 26.03.2019    Story # 6374762 : Performance improvement for EndUser Batch Class.
***********************************************************/
 
global class BatchUpdAccountOwner implements Database.Batchable<sObject>, Database.Stateful {
        
    public string query = '';
    global integer totalRecord = 0;
    
    //For test method
    public boolean isTest = false;
    public string testAccountId = '';   
                
    global Database.Querylocator start (Database.Batchablecontext BC) {
        
        System.debug('##### BatchUpdAccountOwner START: ' + Datetime.now());
        
        try {       
	    	Database.Querylocator recordToBeProcessed;  	    
	        	                              
	        Datetime nextTwoHour = Datetime.now().addHours(2);
	        Datetime accountWorkItemFireTime = formatDatetime(System.Label.BatchUpdateAccountWorkItem_Schedule_Time_HH_mm_ss);	      
	        String[] classesName = StringUtils.split(StringUtils.trim(System.Label.BatchUpdate_Classes_Name), ',');
	        classesName.add('BatchUpdAccountOwner');
			
			//0. Abort finished job.
			//# 6374762:Commenting below line, because this method logic was commented in DBUtils class. 
			//DBUtils.flushOutTheJobsQueue();
			
			//1. Check whether 4117 or own job finish executing or not		
	        List<AsyncApexJob> runningJobs = [SELECT Status From AsyncApexJob
	                          WHERE Id != :BC.getJobId() AND JobType = 'BatchApex' AND                    		
	                          		ApexClass.Name IN :classesName AND Status IN ('Processing', 'Queued')                           			
	                          ORDER BY Createddate Desc];
	        
	        //Rev 1.4
	        //2. Query Account List to update
	        query = 'SELECT Id, OwnerId, Owner_Update__c '+
	                'FROM Account ' +
	                'WHERE New_Owner__c = 1 AND isPartner = false ' + 
	                (isTest? 'AND Id = \'' + testAccountId +'\' ':'') +
	                //'AND Id = \'001T000000UrB3Q\' ' + //For Testing                             
	                (System.Label.BatchUpdAccountOwner_Row_Limit != '-'? 'ORDER BY LastModifiedDate LIMIT ' + System.Label.BatchUpdAccountOwner_Row_Limit : '');
	        System.debug('##### Query: '+query);
	        	        
            //System.debug('##### Check Job 1: '+ runningJobs + ' nextTwoHour: ' + nextTwoHour + ', accountWorkItemFireTime: ' + accountWorkItemFireTime);
      	            
            //3. Don't execute if 4117 still running or going to execute within 2 hours 
            if (!isTest && (runningJobs.size() > 0 || (nextTwoHour >= accountWorkItemFireTime && nextTwoHour <= accountWorkItemFireTime.addHours(2)))) {
                System.debug('##### Batch job is running or going to execute soon');
                //# 6374762
                //return Database.getQueryLocator([SELECT Id FROM Account LIMIT 0]); //Don't return any record  
                return null;              
            }
            else {
                //Rev 1.2
                recordToBeProcessed = Database.getQueryLocator(query);
                return recordToBeProcessed;
            }	      
        }
        catch (Exception e) {
        	//If exception is thrown, proceed to FINISH and reschedule next run
        	//# 6374762
        	//return Database.getQueryLocator([SELECT Id FROM Account LIMIT 0]);
        	return null;
        }        
    }
    
    global void execute (Database.Batchablecontext BC, List<sObject> scope) {
        System.debug('##### BatchUpdAccountOwner EXECUTE: ' + Datetime.now());

        List<Account> accList = new List<Account>();         
        String objectType = 'Account'; 
        String Operation='Update';
        String JobName = 'Account Owner: '+ BC.getJobId();
        
		//Rev 1.4
		List<Account> oldAccList = (List<Account>) scope;
        //# 6374762 : The below line was commented , here it is like replication of oldAccList only
		/*List<Account> newAccList = [SELECT Id, OwnerId, Owner_Update__c
								   FROM Account
								   WHERE Id in :oldAccList AND New_Owner__c = 1];*/        
        totalRecord = totalRecord + oldAccList.size();        
        System.debug('## totalRecord: ' + totalRecord);       
                               
        for (Account acc : oldAccList) {
            acc.OwnerId = acc.Owner_Update__c;
            //acc.Owner_Update__c = null;	//Rev 1.4
            accList.add(acc); 
        }
        
        if (accList.size() > 0) {   
            Database.Saveresult[] srl = Database.update(accList, false);
            DBUtils.processResult(accList, srl, objectType, Operation, JobName);    
        }
    }
    
    global void finish (Database.Batchablecontext BC) {
        System.debug('##### BatchUpdAccountOwner FINISH: ' + Datetime.now());
        
        Integer interval; 
        Datetime nextTwoHour = Datetime.now().addHours(2);        
        Datetime accountOwnerFireTime = formatDatetime(System.Label.BatchUpdAccountOwner_Schedule_Time_HH_mm_ss);
        
        //System.debug('Check Job 2: nextTwoHour: ' + nextTwoHour + ', accountOwnerFireTime: ' + accountOwnerFireTime);

		if (AccountOwnerTransitionUtils.enabledNotification) //Rev 2.0			
			getProcessedData(BC.getJobId()); //Rev 1.3
		                
        if (nextTwoHour < accountOwnerFireTime || nextTwoHour >= accountOwnerFireTime.addHours(2)) {                      
            //Rev 1.4
            try {
            	interval = Integer.valueOf(System.label.BatchUpdAccountOwner_Interval_sec);
            }
            catch (TypeException te) {
            	interval = 3600;
            }
            string nextSchTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(datetime.now(), interval);
        
            BatchUpdAccountOwnerExecute batchExec = new BatchUpdAccountOwnerExecute();
            system.debug('##### BatchUpdAccountOwnerExecute at: '+nextSchTime);
            system.schedule('BatchUpdAccountOwnerExecute at: '+nextSchTime, nextSchTime, batchExec);         
        }
        else {
            System.debug('##### BatchUpdAccountOwner FULLY STOP: ' + Datetime.now());
        }           
    }  
    
    private Datetime formatDatetime(string scheduleTime) {
    	Datetime scheduleDatetime = Datetime.now().addDays(1);
    	try {
        	scheduleDatetime = Datetime.valueOfGmt(String.valueOf(Date.Today()) + ' ' + scheduleTime);
        }
        catch (TypeException e) {
        	//If invalid Datetime, default to 1 day later and continue     	
        }
        
        return scheduleDatetime;
    } 

 	//Rev 1.3
   	global void getProcessedData(Id batchJobId) {
   		
   		try {
			AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,	TotalJobItems, CreatedDate, CompletedDate
							  FROM AsyncApexJob 
							  WHERE Id =:batchJobId];
			
			//Rev 2.0
			String subject = 'End User Account, '+a.Id + ', ' + a.Status + ', ' + System.Label.BatchUpdAccountOwner_Batch_Size + ', '+ a.TotalJobItems + ', ' + a.JobItemsProcessed + ', ' + 
							a.NumberOfErrors + ', ' + totalRecord + ', ' + a.CreatedDate + ', ' +  a.CompletedDate;
			String body = ' End User Account '+a.Id + 
							'\n Status: ' + a.Status + 
							'\n Batch Size: ' + System.Label.BatchUpdAccountOwner_Batch_Size +
							'\n TotalJobItem: ' + a.TotalJobItems + 
							'\n JobItemsProcessed:  ' + a.JobItemsProcessed +
							'\n NumberOfErrors: ' + a.NumberOfErrors + 
							'\n TotalRecord: ' + totalRecord + 
							'\n CreatedDate: ' + a.CreatedDate + 
							'\n CompletedDate:  ' +  a.CompletedDate;
			AccountOwnerTransitionUtils.sendOptionalNotification(subject, body);
			/*				
			// Send an email to the Apex job's submitter notifying of job completion.
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'men_mee_how@dell.com'};
			mail.setToAddresses(toAddresses);
			//Type of Account, Status, TotalJobItems, JobItemsProcessed, NumberOfErrors, No# of Records, CreatedDate, CompletedDate
			mail.setSubject('End User Account, '+a.Id + ', ' + a.Status + ', ' + System.Label.BatchUpdAccountOwner_Batch_Size + ', '+ a.TotalJobItems + ', ' + a.JobItemsProcessed + ', ' + 
							a.NumberOfErrors + ', ' + totalRecord + ', ' + a.CreatedDate + ', ' +  a.CompletedDate);
			mail.setPlainTextBody
			(' End User Account '+a.Id + 
			'\n Status: ' + a.Status + 
			'\n Batch Size: ' + System.Label.BatchUpdAccountOwner_Batch_Size +
			'\n TotalJobItem: ' + a.TotalJobItems + 
			'\n JobItemsProcessed:  ' + a.JobItemsProcessed +
			'\n NumberOfErrors: ' + a.NumberOfErrors + 
			'\n TotalRecord: ' + totalRecord + 
			'\n CreatedDate: ' + a.CreatedDate + 
			'\n CompletedDate:  ' +  a.CompletedDate);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			*/
			//Rev 2.0-end
   		}
   		catch (Exception e) {
   			System.debug('##### BatchUpdAccountOwner:getProcessedData '+e.getMessage());
   		}
    }    
}
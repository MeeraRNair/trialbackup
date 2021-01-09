/***********************************************************
* Name          : BatchUpdAccountOwnerForPartner
* Description   : Update Partner Account Owner 
* ---------------------------------------------------------
* Revision      Release Name    Date            Description
* 1.0           12.1    MenMee  21.01.2011      CR5716 Processing Partner Account owner change using batch Apex
* 1.1           12.1    MenMee  28.01.2011      Temporary get proccessed data
* 1.2           ECR     MenMee  21.03.2011      1) (CR6022) Requery owner update field to get latest value
*                                               2) Exception Handling and 3) Don't null owner update field
* 2.0                   MenMee  25.04.2013      CR8242 Remove hardcoded email address
* 3.0           16.03   Amanda  12.02.2015      CR10865 Affinity - SFDC Integration - Enhance Partner Account Apex Job to process based on Priority field
* 4.0                   Kshipra 18.10.2018      Story # 5718183 : Performance improvemebt for batch
***********************************************************/
 
global class BatchUpdAccountOwnerForPartner implements Database.Batchable<sObject>, Database.Stateful {
        
    public string query = '';  
    public integer totalRecord = 0;
    
    //For test method
    public boolean isTest = false;
    public string testAccountId = '';   
                
    global Database.Querylocator start (Database.Batchablecontext BC) {
        System.debug('##### BatchUpdAccountOwnerForPartner START: ' + Datetime.now());
            
        try {    
            Database.Querylocator recordToBeProcessed;
            
            DBUtils.flushOutTheJobsQueue();         
            Datetime nextTwoHour = Datetime.now().addHours(2);
            Datetime accountWorkItemFireTime = formatDatetime(System.Label.BatchUpdateAccountWorkItem_Schedule_Time_HH_mm_ss);
            String[] classesName = StringUtils.split(StringUtils.trim(System.Label.BatchUpdate_Classes_Name), ',');
            classesName.add('BatchUpdAccountOwnerForPartner');
                   
            //1. Check whether 4117 or own job finish executing or not
            List<AsyncApexJob> runningJobs = [SELECT Status From AsyncApexJob
                              WHERE Id != :BC.getJobId() AND JobType = 'BatchApex' AND                                  
                                    ApexClass.Name IN :classesName  AND Status IN ('Processing', 'Queued')
                              ORDER BY Createddate Desc];
                              
            //2. Query Account List to update
            //For Story # 5718183 , added New_Owner__c field in the query.
            query = System.Label.BatchUpdAccountOwnerForPartnerSOQL!='-'?System.Label.BatchUpdAccountOwnerForPartnerSOQL:
            /*query = */ 'SELECT Id, OwnerId, New_Owner__c, Owner_Update__c '+
                    'FROM Account ' +
                    'WHERE New_Owner__c = 1 AND isPartner = true AND Priority__c > 0 ' +
                    (isTest? 'AND Id = \'' + testAccountId +'\' ':'') +
                    //'AND Id = \'001T000000VlaEE\' ' + //For testing                
                    (System.Label.BatchUpdPartnerAccountOwner_Row_Limit != '-'? 'ORDER BY Priority__c, Ownerid, LastModifiedDate LIMIT ' + System.Label.BatchUpdPartnerAccountOwner_Row_Limit: '');
            System.debug('##### Query: '+query);
            
            //System.debug('##### Check Job 1: '+ runningJobs + ' nextTwoHour: ' + nextTwoHour + ', accountWorkItemFireTime: ' + accountWorkItemFireTime);
                    
            //3. Don't execute if 4117 still running or going to execute within 2 hours 
            if (!isTest && (runningJobs.size() > 0 || (nextTwoHour >= accountWorkItemFireTime && nextTwoHour <= accountWorkItemFireTime.addHours(2)))) {
                System.debug('##### Batch job is running or going to execute soon');
                //return Database.getQueryLocator([SELECT Id FROM Account LIMIT 0]); //Don't return any record
                return null;
                          }
            else {      
                recordToBeProcessed = Database.getQueryLocator(query);
                return recordToBeProcessed;
            } 
        } 
        catch (Exception e) {
            //If exception is thrown, proceed to FINISH and reschedule next run           
            return null;
            //return Database.getQueryLocator([SELECT Id FROM Account LIMIT 0]); 
            
        }        
    }
    
    global void execute (Database.Batchablecontext BC, List<sObject> scope) {
       TriggerExecutionController.setSkipAccountForQEProcess(true);
        System.debug('##### BatchUpdAccountOwnerForPartner EXECUTE: ' + Datetime.now());
        if (null != scope) {
        List<Account> accList = new List<Account>();         
        String objectType = 'Account'; 
        String Operation='Update';
        String JobName = 'Account Owner For Partner: '+BC.getJobId();
        
        //Rev 1.2
        List<Account> oldAccList = (List<Account>) scope;
            //For Story # 5718183 removed the query to fetch account records.
            //Added a for loop to populate newAccList
        List<Account> newAccList = new List<Account>();
            //[SELECT Id, OwnerId, Owner_Update__c    FROM Account     WHERE Id in :oldAccList AND New_Owner__c = 1];  //[SELECT Id, OwnerId, Owner_Update__c    FROM Account     WHERE Id in :oldAccList AND New_Owner__c = 1];     
       for(Account accRec : oldAccList) {
            if(accRec.New_Owner__c == 1) {
                newAccList.add(accRec);
            }
        }
        totalRecord = totalRecord + newAccList.size();        
        System.debug('## totalRecord: ' + totalRecord);  
      
        for (Account acc : newAccList) {           
            acc.OwnerId = acc.Owner_Update__c;
            //acc.Owner_Update__c = null;   //Rev 1.2
            accList.add(acc); 
        }
        
        if (accList.size() > 0) {
            GlobalVariables.BYPASS_FUTURE_CALLS = true;
            
            Database.Saveresult[] srl = Database.update(accList, false);
            DBUtils.processResult(accList, srl, objectType, Operation, JobName);    
            
            GlobalVariables.BYPASS_FUTURE_CALLS = false;
        }
        } else {
             system.debug('There are no records to process');
        }
    }
    
    global void finish (Database.Batchablecontext BC) {
        System.debug('##### BatchUpdAccountOwnerForPartner FINISH: ' + Datetime.now());
                 
        Integer interval;   
        Datetime nextTwoHour = Datetime.now().addHours(2);        
        Datetime accountOwnerFireTime = formatDatetime(System.Label.BatchUpdPartnerAccountOwner_Schedule_Time_HH_mm_ss);
        
        //System.debug('Check Job 2: nextTwoHour: ' + nextTwoHour + ', accountOwnerFireTime: ' + accountOwnerFireTime);
        
        if (AccountOwnerTransitionUtils.enabledNotification) //Rev 2.0          
            getProcessedData(BC.getJobId()); //Rev 1.1
             //Story # 5718183 , do not enter the loop when the test class is being run.     
             //Check for isTest flag         
        if ((nextTwoHour < accountOwnerFireTime || nextTwoHour >= accountOwnerFireTime.addHours(2)) && !isTest  ) {              
            //Rev 1.2
            try {
                interval = Integer.valueOf(System.label.BatchUpdPartnerAccountOwner_Interval_sec);
            }
            catch (TypeException te) {    interval = 3600;
            }
            string nextSchTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(datetime.now(), interval);
        
            BatchUpdAccountOwnerForPartnerExecute batchExec = new BatchUpdAccountOwnerForPartnerExecute();
            system.debug('##### BatchUpdAccountOwnerForPartnerExecute at: '+nextSchTime);
            system.schedule('BatchUpdAccountOwnerForPartnerExecute at: '+nextSchTime, nextSchTime, batchExec);  
           
        }
        else {
            System.debug('##### BatchUpdAccountOwnerForPartner FULLY STOP: ' + Datetime.now());
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
    
    //Rev 1.1
   global void getProcessedData(Id batchJobId) {
        //Rev 1.2
        try {
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedDate, CompletedDate
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
            //Type of Account, Status, Batch Size, TotalJobItems, JobItemsProcessed, NumberOfErrors, No# of Records, CreatedDate, CompletedDate
            mail.setSubject('Partner Account, '+a.Id + ', ' + a.Status + ', ' + System.Label.BatchUpdPartnerAccountOwner_Batch_Size + ', '+ a.TotalJobItems + ', ' + a.JobItemsProcessed + ', ' + 
                            a.NumberOfErrors + ', ' + totalRecord + ', ' + a.CreatedDate + ', ' +  a.CompletedDate);
            mail.setPlainTextBody
            (' Partner Account '+a.Id + 
            '\n Status: ' + a.Status + 
            '\n Batch Size: ' + System.Label.BatchUpdPartnerAccountOwner_Batch_Size +
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
            
            System.debug('##### [BatchUpdAccountOwnerForPartner:getProcessedData] '+e.getMessage());
        }
    }
}
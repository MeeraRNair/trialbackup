/***********************************************************
* Name          : BatchUpdAccountOwnerForPartnerEMEA
* Description   : Update Partner Account Owner 
* ---------------------------------------------------------
* Revision      Release Name    Date            Description
* 1.0           12.1    MenMee  21.01.2011      CR5716 Processing Partner Account owner change using batch Apex
* 1.1           12.1    MenMee  28.01.2011      Temporary get proccessed data
* 1.2           ECR     MenMee  21.03.2011      1) (CR6022) Requery owner update field to get latest value
*                                               2) Exception Handling and 3) Don't null owner update field
* 2.0                   MenMee  25.04.2013      CR8242 Remove hardcoded email address
* 3.0           16.03   Amanda  12.02.2015      CR10865 Affinity - SFDC Integration - Enhance Partner Account Apex Job to process based on Priority field
* 4.0                   Hitha                   Update Account Owner depending on region

***********************************************************/
 
global class BatchUpdAccountOwnerForPartnerEMEA implements Database.Batchable<sObject>, Database.Stateful {
        
   /* public string query = '';  
    public integer totalRecord = 0;
    
    //For test method
    //public boolean isTest = false;
     public boolean isTest = true;
    public string testAccountId = '0017000000Spe4qAAB';//'001A000000TcWdH';//'001A0000014JhTc'; //'0017000000T2sVK';*/   
                
    global Database.Querylocator start (Database.Batchablecontext BC) {
     /*   System.debug('##### BatchUpdAccountOwnerForPartnerEMEA START: ' + Datetime.now());
            
        try {    
            Database.Querylocator recordToBeProcessed;
            
            DBUtils.flushOutTheJobsQueue();         
            Datetime nextTwoHour = Datetime.now().addHours(2);
            Datetime accountWorkItemFireTime = formatDatetime(System.Label.BatchUpdateAccountWorkItem_Schedule_Time_HH_mm_ss);
            String[] classesName = StringUtils.split(StringUtils.trim(System.Label.BatchUpdate_Classes_Name), ',');
            classesName.add('BatchUpdAccountOwnerForPartnerEMEA');
                   
            //1. Check whether 4117 or own job finish executing or not
            List<AsyncApexJob> runningJobs = [SELECT Status From AsyncApexJob
                              WHERE Id != :BC.getJobId() AND JobType = 'BatchApex' AND                                  
                                    ApexClass.Name IN :classesName  AND Status IN ('Processing', 'Queued')
                              ORDER BY Createddate Desc];
/////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////                              
            //Rev 3.0
            //Hitha   
                  
            list<country__c> countryList = [SELECT Name from Country__c where region__c ='EMEA'];
           // list<country__c> countryList = [SELECT Name from Country__c where region__c LIKE:s];
            System.debug('@@@@CountryList'+countryList);
            String[] cList = new string[countryList.size()]; 
            for (integer i=0; i<countryList.size(); i++){
             cList[i] = countryList[i].Name;
            System.debug('@@cList'+cList);
     
            }  
            
           String newSetStr = '' ;
           for(String str : cList)
           {
                str = String.escapeSingleQuotes(str) ;      // To avoid ' in string                  
                System.debug('@@Str'+Str); 
                newSetStr += '\'' + str + '\',';
            }               
           newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;             
           System.debug('@@newSetStr'+newSetStr); 
               
                              
///////////////////////////////////////////////////////////////////////////////////
                              
            //2. Query Account List to update
            query = 'SELECT Id, OwnerId, Owner_Update__c '+
                    'FROM Account ' +
                    'WHERE New_Owner__c = 1 AND isPartner = true AND Priority__c != null AND lastmodifieddate >= LAST_N_DAYS:2  AND Account_Country__c IN' +newSetStr+
                    //(isTest? 'AND Id = \'' + testAccountId +'\' ':'') +
                    //'AND Id = \'001T000000VlaEE\' ' + //For testing                
                     //('AND Id = \'' + testAccountId +'\' ') +  
                    //(System.Label.BatchUpdPartnerAccountOwnerEMEA_Row_Limit != '-'? 'ORDER BY Priority__c, LastModifiedDate LIMIT ' + System.Label.BatchUpdPartnerAccountOwnerEMEA_Row_Limit: '');
                    (System.Label.BatchUpdPartnerAccountOwnerEMEA_Row_Limit != '-'? ' LIMIT ' + System.Label.BatchUpdPartnerAccountOwnerEMEA_Row_Limit: '');
            System.debug('##### Query: '+query);
            
            //System.debug('##### Check Job 1: '+ runningJobs + ' nextTwoHour: ' + nextTwoHour + ', accountWorkItemFireTime: ' + accountWorkItemFireTime);
                    
            //3. Don't execute if 4117 still running or going to execute within 2 hours 
            if (!isTest && (runningJobs.size() > 0 || (nextTwoHour >= accountWorkItemFireTime && nextTwoHour <= accountWorkItemFireTime.addHours(2)))) {
                System.debug('##### Batch job is running or going to execute soon');
                return Database.getQueryLocator([SELECT Id FROM Account LIMIT 0]); //Don't return any record
            }
            else {      
                recordToBeProcessed = Database.getQueryLocator(query);
                return recordToBeProcessed;
            }
        } 
        catch (Exception e) {
            //If exception is thrown, proceed to FINISH and reschedule next run          
            return Database.getQueryLocator([SELECT Id FROM Account LIMIT 0]); 
        }        */
        Date tomorrow = Date.Today().addDays(1);
        return Database.getQueryLocator([SELECT Id FROM Account WHERE CreatedDate > :tomorrow]); // Added for test coverage
    }
    
    global void execute (Database.Batchablecontext BC, List<sObject> scope) {
  /*      System.debug('##### BatchUpdAccountOwnerForPartnerEMEA EXECUTE: ' + Datetime.now());
        
        List<Account> accList = new List<Account>();         
        String objectType = 'Account'; 
        String Operation='Update';
        String JobName = 'Account Owner For Partner: '+BC.getJobId();
        
        //Rev 1.2
        List<Account> oldAccList = (List<Account>) scope;
        List<Account> newAccList = [SELECT Id, OwnerId, Owner_Update__c
                                   FROM Account
                                   WHERE Id in :oldAccList AND New_Owner__c = 1];        
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
        }*/
    }
    
    global void finish (Database.Batchablecontext BC) {
      /*  System.debug('##### BatchUpdAccountOwnerForPartnerEMEA FINISH: ' + Datetime.now());
                 
        Integer interval;   
        Datetime nextTwoHour = Datetime.now().addHours(2);        
        Datetime accountOwnerFireTime = formatDatetime(System.Label.BatchUpdPartnerAccountOwnerEMEA_Schedule_Time_HH_mm_ss);
        
        //System.debug('Check Job 2: nextTwoHour: ' + nextTwoHour + ', accountOwnerFireTime: ' + accountOwnerFireTime);
        
        if (AccountOwnerTransitionUtils.enabledNotification) //Rev 2.0          
            getProcessedData(BC.getJobId()); //Rev 1.1
                            
        if (nextTwoHour < accountOwnerFireTime || nextTwoHour >= accountOwnerFireTime.addHours(2)) {              
            //Rev 1.2
            try {
                interval = Integer.valueOf(System.label.BatchUpdPartnerAccountOwnerEMEA_Interval_sec);
            }
            catch (TypeException te) {              
                interval = 3600;
            }
            string nextSchTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(datetime.now(), interval);
        
            BatchUpdAccountOwnerForPartnerExecuteEM batchExec = new BatchUpdAccountOwnerForPartnerExecuteEM();
            system.debug('##### BatchUpdAccountOwnerForPartnerExecuteEM at: '+nextSchTime);
            system.schedule('BatchUpdAccountOwnerForPartnerExecuteEM at: '+nextSchTime, nextSchTime, batchExec);  
           
        }
        else {
            System.debug('##### BatchUpdAccountOwnerForPartnerEMEA FULLY STOP: ' + Datetime.now());
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
        
        return scheduleDatetime;*/
    } 
    
    //Rev 1.1
 /*  global void getProcessedData(Id batchJobId) {
        //Rev 1.2
        try {
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedDate, CompletedDate
                              FROM AsyncApexJob 
                              WHERE Id =:batchJobId];
            
            //Rev 2.0
            String subject = 'End User Account, '+a.Id + ', ' + a.Status + ', ' + System.Label.BatchUpdAccountOwnerEMEA_Batch_Size + ', '+ a.TotalJobItems + ', ' + a.JobItemsProcessed + ', ' + 
                            a.NumberOfErrors + ', ' + totalRecord + ', ' + a.CreatedDate + ', ' +  a.CompletedDate;
            String body = ' End User Account '+a.Id + 
                            '\n Status: ' + a.Status + 
                            '\n Batch Size: ' + System.Label.BatchUpdAccountOwnerEMEA_Batch_Size +
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
            mail.setSubject('Partner Account, '+a.Id + ', ' + a.Status + ', ' + System.Label.BatchUpdPartnerAccountOwnerEMEA_Batch_Size + ', '+ a.TotalJobItems + ', ' + a.JobItemsProcessed + ', ' + 
                            a.NumberOfErrors + ', ' + totalRecord + ', ' + a.CreatedDate + ', ' +  a.CompletedDate);
            mail.setPlainTextBody
            (' Partner Account '+a.Id + 
            '\n Status: ' + a.Status + 
            '\n Batch Size: ' + System.Label.BatchUpdPartnerAccountOwnerEMEA_Batch_Size +
            '\n TotalJobItem: ' + a.TotalJobItems + 
            '\n JobItemsProcessed:  ' + a.JobItemsProcessed +
            '\n NumberOfErrors: ' + a.NumberOfErrors + 
            '\n TotalRecord: ' + totalRecord + 
            '\n CreatedDate: ' + a.CreatedDate + 
            '\n CompletedDate:  ' +  a.CompletedDate);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            */
            //Rev 2.0-end
        /*}
        catch (Exception e) {
            
            System.debug('##### [BatchUpdAccountOwnerForPartnerEMEA:getProcessedData] '+e.getMessage());
        }
    }*/
}
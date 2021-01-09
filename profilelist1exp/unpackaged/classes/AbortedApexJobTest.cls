@isTest(seeAllData=true)
private class AbortedApexJobTest {

    static testMethod void AccessAbortedApexJobManagerTest() {
    
        Test.startTest();  
        
       // system.schedule('BachCMIdataIntegrationSchedule executing now', '0 26 23 08 03 ? 1990', new AbortedApexJobReporter());  
        
        AbortedApexJobManager abortedApexJob = new AbortedApexJobManager ();
        abortedApexJob.getSalesforceServerURL();
        abortedApexJob.getAbortedApexJobs();
        
        List<AsyncApexJob> retrievedJobs = [Select ApexClass.Name, CreatedDate, CompletedDate, ExtendedStatus, 
                    JobItemsProcessed, JobType, MethodName, NumberOfErrors, Status, TotalJobItems 
                    From AsyncApexJob
                    where CompletedDate<>null limit 1
                    ];
        AsyncApexJob job = null;
        if((retrievedJobs != null) && (retrievedJobs.size() > 0)){
            job = retrievedJobs.get(0);
        }
        
        AbortedApexJobManager.AsyncApexJobWrapper wrapper = new AbortedApexJobManager.AsyncApexJobWrapper(job);
        
        wrapper.getFormattedCompletedDate();      
        wrapper.getFormattedCreatedDate();
        
        Test.stopTest();        
    
    }
        
    static testMethod void AccessAbortedApexJobReporterTest() {
    
        Test.startTest();  
        
        //DBUtils.flushOutTheJobsQueue();
         
        String CRON_EXP = '0 0 0 * * ?';
        AbortedApexJobReporter.isTest = true; 
        String jobId = System.schedule('AbortedApexJobReporter executing now',CRON_EXP, new AbortedApexJobReporter());
        AbortedApexJobReporter.sendFailureEmail();
        AbortedApexJobReporter.isInTestingEnvironment();
        
        Test.stopTest();   
        
        
    
    }
    
}
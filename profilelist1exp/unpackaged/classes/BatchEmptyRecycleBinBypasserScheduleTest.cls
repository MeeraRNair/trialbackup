/*
History:
Version     Date            Modified By     CR          Description     
--------------------------------------------------------------------------------------
1.0         05-November-2019     TTI               Test class to empty Recycle Bin for System_Behavior_Bypasser__c
*/
@isTest(seealldata=false)
private class BatchEmptyRecycleBinBypasserScheduleTest {
    
    static testmethod void testschedulerprocess(){
        //insert records into System_Behavior_Bypasser__c
    List<System_Behavior_Bypasser__c> listbypasser = new List<System_Behavior_Bypasser__c>();
    for(Integer inti=0;inti<1;inti++){
        System_Behavior_Bypasser__c bypass = new System_Behavior_Bypasser__c();
        bypass.Bypass_Opportunity_VRs__c = true;
        listbypasser.add(bypass);
    }
    
    insert listbypasser;
    
    delete listbypasser;
    
    //schedule
    
    Test.startTest();
    String sch = '0 0 8 * * ?';
    BatchEmptyRecycleBinBypasserSchedule rlBatch = new BatchEmptyRecycleBinBypasserSchedule ();
    String jobId = system.schedule('BatchEmptyRecycleBinBypasserSchedule',sch , rlBatch);

     // Get the information from the CronTrigger API object
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime
                        FROM CronTrigger WHERE id = :jobId];
                        
    // Verify the expressions are the same
    System.assertEquals(sch,ct.CronExpression);
    
    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);
        
     Test.stopTest();          
    }
    //test batch
    static testmethod void testbatchprocess(){
        //insert records into System_Behavior_Bypasser__c
    List<System_Behavior_Bypasser__c> listbypasser = new List<System_Behavior_Bypasser__c>();
    for(Integer inti=0;inti<1;inti++){
        System_Behavior_Bypasser__c bypass = new System_Behavior_Bypasser__c();
        bypass.Bypass_Opportunity_VRs__c = true;
        listbypasser.add(bypass);
    }
    
    insert listbypasser;
    
    delete listbypasser;
    
    //schedule
    
    Test.startTest();
    string strquery;
        //1.0 - Added Column Account Owner ID
        strquery = 'select id from System_Behavior_Bypasser__c where isDeleted = true all rows';        
                 
                 
    BatchEmptyRecycleBinBypasser Batchbypasser = new BatchEmptyRecycleBinBypasser();                    
    Batchbypasser.strquery= strquery; 
    database.executebatch(Batchbypasser,200);  
        
     Test.stopTest(); 
    List<System_Behavior_Bypasser__c> newbypasslist = [select id from System_Behavior_Bypasser__c where isDeleted = true ALL ROWS];
    
    System.assertEquals(newbypasslist.size(),1);
    }
    
}
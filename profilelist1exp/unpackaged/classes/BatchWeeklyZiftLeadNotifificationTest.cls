/*
  Revision  CR Number     Release No       Date           Modified By     Description     
----------  -----------  -------------  -------------   ---------------  --------------------
1.0           16838        FY20-0202     9/1/2019
*/

@isTest(SeeAllData=false)
private class BatchWeeklyZiftLeadNotifificationTest {

     
    static testmethod void ziftLeadTest(){
    
       TriggerExecutionController.setSkipLeadTriggers(true); 
       Id leadRTId = IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
                
        /*Lead ld = new Lead(); 
        ld.Zift_Lead_Partner__c = 'Zift Leads';
        //Record_Type__c. Id = 'Channel Lead 2.0';
        ld.Lead_Type__c = 'Inbound';
        //ld.IsActive = TRUE ; 
        ld.Email = 'abc@gmail.com'; 
        ld.Location_Number__c = 3 ;  
        insert ld;*/
        
        //v2.0 - added Sales user
        UserTestData.iNumberOfUsers = 2; //v3.0
        UserTestData.createSalesUsers();
        list<User> listUsers = UserTestData.lstUsers;
        //listUsers[0].ManagerId = listUsers[1].Id;
        listUsers[1].ManagerId = listUsers[0].Id;
        listUsers[0].Email = 'abc@dell.com';
        
        update listUsers;
        
        LeadTestData.iNumberOfLeads = 5;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();       
        
        list<Lead> listLeads = LeadTestData.lstLeads; 
        listLeads[0].OwnerId = listUsers[0].Id; // v2.0
        listLeads[0].Title = 'test CR11840';
        listLeads[0].Status = 'New'; //v5.0
        listLeads[0].Zift_Lead_Partner__c = 'Zift Leads';
        listLeads[0].Lead_Type__c = 'Inbound';
        //listLeads[0].Email = 'abc@gmail.com';
        listLeads[0].Location_Number__c = 3 ; 
        listLeads[0].RecordTypeID = leadRTId; 
        listLeads[0].Country_Code__c = 'AE';
        listLeads[0].Dell_Partner_can_contact_me__c = TRUE;
        
        insert listLeads;
        
        TriggerExecutionController.setSkipLeadTriggers(false); 
                        
        Test.startTest();
        BatchWeeklyZiftLeadNotifification  batchObj = new BatchWeeklyZiftLeadNotifification();
        database.executebatch(batchObj,2);
        batchObj.processLeads(listLeads);
        //batchObj.sendMail(new Map<String, String>{listUsers[0].Id => listLeads[0].Id});
        Test.stopTest();
        EmailTemplate expectedOwnerEmailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = 'Weekly Channel Lead Notification to Zift'];
        system.assertEquals(expectedOwnerEmailTemplate, batchObj.ziftEmailTemplate);
    }
    
     static testMethod void batchWeeklyZiftLeadEmailSchedulerTest() {
            Test.startTest();
            String strcornEXP = '0 0 0 * * ?';
            BatchWeeklyZiftLeadNtfyScheduler sch = new BatchWeeklyZiftLeadNtfyScheduler();
            String strjobId = System.schedule('batchWeeklyEmail TestScheduledApex',strcornEXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :strjobId];
            //Verify the expressions are the same
            System.assertEquals(strcornEXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
        
 }
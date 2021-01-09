/*
History:
  Revision CR Number   Release No       Date            Modified By     Description     
--------------------------------------------------------------------------------------
* 1.0                                   01-SEPT-2015    Azwanti         Created test method for BatchWeeklySummaryOpenLeadEmail class
* 2.0       CR 13068    FY17-DCS-0502   19-Apr-2016     Azwanti         INC000022127998 - SAR14004: added test method 
* 2.1       CR 13068    FY17-DCS-0502   28-Apr-2016     Gan             Modify the test method after refactor the batch class 
* 3.0       CR 13068    FY17-DCS-0602   04-May-2016     Gan             Revert back previous changes v2.0 and modify to increase code coverage
* 4.0       CR 13901    FY18-DCS-0302   10-Jan-2017     Sajith          Include Marketing Qualified Lead and Contacted statuses in weekly summary emails
* 5.0       CR 15110    FY18-DCS-0203   22-NOV-2017     Azwanti         Replace Status Open, Accepted, Contacted & Marketing Qualified Lead to New & Working, and remove Accepted Date column from table

*/

@isTest(SeeAllData=false)
private class BatchWeeklySummaryOpenLeadEmailTest {
    
    static testmethod void openLeadTest(){
        //v2.0 - added Sales user
        UserTestData.iNumberOfUsers = 2; //v3.0
        UserTestData.createSalesUsers();
        list<User> listUsers = UserTestData.lstUsers;
        //listUsers[0].ManagerId = listUsers[1].Id;
        listUsers[1].ManagerId = listUsers[0].Id;
        
        update listUsers;
        
        LeadTestData.iNumberOfLeads = 5;
        LeadTestData.bCreate = false;
        LeadTestData.createDirectLead2();       
        
        list<Lead> listLeads = LeadTestData.lstLeads; 
        listLeads[0].OwnerId = listUsers[0].Id; // v2.0
        listLeads[0].Title = 'test CR11840';
        listLeads[0].Status = 'New'; //v5.0
        // v3.0 start
        listLeads[1].OwnerId = listUsers[1].Id; // v2.0
        listLeads[1].Title = 'test CR11840';
        listLeads[1].Status = 'New'; //v5.0
        // v3.0 end
        // v4.0 start
        listLeads[2].OwnerId = listUsers[1].Id; 
        listLeads[2].Title = 'test CR13901';
        listLeads[2].Status = 'Working'; //v5.0
        
        listLeads[3].OwnerId = listUsers[1].Id; 
        listLeads[3].Title = 'test CR13901';
        listLeads[3].Status = 'Working'; //v5.0
        
        listLeads[4].OwnerId = listUsers[1].Id; 
        listLeads[4].Title = 'test CR13901';
        listLeads[4].Status = 'Marketing/alSR Pre-Qualified';  //v5.0
        // v4.0 end

        insert listLeads;
        system.debug('openLeadTest lstLeads: '+listLeads);
        Test.startTest();
        BatchWeeklySummaryOpenLeadEmail batchObj = new BatchWeeklySummaryOpenLeadEmail();
        database.executebatch(batchObj,2);
        
        Test.stopTest();
        EmailTemplate expectedOwnerEmailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = 'Lead Follow Up Email for Owner'];
        system.assertEquals(expectedOwnerEmailTemplate, batchObj.ownerEmailTemplate);
    }
    
    //v2.0 created for code coverage on BatchWeeklySummaryOpenLeadEmailScheduler class
    static testMethod void BatchWeeklySummaryOpenLeadEmailSchedulerTest() {
            Test.startTest();
            String CRON_EXP = '0 0 0 * * ?';
            BatchWeeklySummaryOpenLeadEmailScheduler sch = new BatchWeeklySummaryOpenLeadEmailScheduler();
            String jobId = System.schedule('batchWeeklyEmail TestScheduledApex',CRON_EXP,sch);
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            //Verify the expressions are the same
            System.assertEquals(CRON_EXP,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            test.stopTest();
    }
    
 }
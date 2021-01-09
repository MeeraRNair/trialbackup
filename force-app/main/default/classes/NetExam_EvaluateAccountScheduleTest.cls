@istest
class NetExam_EvaluateAccountScheduleTest {
    static testmethod void test() {
        Test.startTest();
        
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';
        acc.Partner_Relationship__c='Registered';      
        insert acc;
        
        // Schedule the test job
        datetime myDate = datetime.now(); 
        myDate = myDate.addMinutes(2); // schedule class to run after few minutes, else scheduling can fail
        String sch =  '0 '  + myDate.minute() + ' ' + myDate.hour() + ' ' + myDate.day()  + ' ' + myDate.month() + ' ? ' + myDate.year();  //'0 30 8 10 2 ?';
        
        NetExam_EvaluateAccountSchedule ns = new NetExam_EvaluateAccountSchedule();
        ns.AccountId = acc.Id;
            
        String jobId = System.schedule('testBasicScheduledApex',sch,ns);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime
                            FROM CronTrigger WHERE id = :jobId];
                            
        // Verify the expressions are the same
        System.assertEquals(sch,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        //System.assertEquals('2022-09-03 00:00:00',    String.valueOf(ct.NextFireTime));
        System.assertNotEquals('NetExam_EvaluateAccountSchedule',[SELECT id, name FROM account WHERE id = :acc.id].name);
        Test.stopTest();
        //System.assertEquals('NetExam_EvaluateAccountSchedule',    [SELECT Id, Name FROM Account WHERE Id = :acc.Id].Name);
    }
}
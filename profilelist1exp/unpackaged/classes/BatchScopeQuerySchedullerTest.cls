@isTest
private class BatchScopeQuerySchedullerTest{
    /*
    This test class will cover code in following classes
    (1) BatchScopeQueryScheduller   - 100%
    (2) BatchScopeQuery             - 100%
    (3) BatchDataLoadScheduller     - 100%
    (4) BatchDataLoad               - 73%
    (5) BatchDataLoadHelper         - 75%
    (6) OpportunityDataLoadHelper   - 83%
    */
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    private static testmethod void testBatchDataLoadOpportunity(){
        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;
        
        Account acc = new Account(Name='UT Account');
        insert acc;
        
        Opportunity opp = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=acc.Id, Type='Deal/Bid Direct', CloseDate=System.Today()+10, StageName='Plan - 1%');
        insert opp;
        
        /*Batch_Scope_Query__c query1 = new Batch_Scope_Query__c(Name='Opportunity', Query__c='SELECT Id FROM Opportunity WHERE RecordTypeId=\'012300000004zf2\'', 
                                                                Field_To_Update__c='RecordTypeId', New_Value__c = '012300000004zf2', Is_Active__c = true, 
                                                                Need_Helper__c = true, Batch_Size__c = 100);*/
        Batch_Scope_Query__c query1 = new Batch_Scope_Query__c(Name='Opportunity',  Is_Active__c = true, Need_Helper__c = true, Batch_Size__c = 100, 
                                                                Query__c='SELECT Id, Scheduled_Product_Count__c, Scheduled_Service_Products__c, Unweighted_Rev_Financing_Only__c, '
                                                                            + 'SOC_Qualify__c, Unweighted_Rev_For_Sort__c, Opportunity_Plan_Roll_up_Summary__c, '
                                                                            + 'Qualified_Vendor_Count__c, Total_Product_Quantity__c, Renewal_Extension_Total_Price__c, '
                                                                            + 'SOC_Qualify_Temp__c, Scheduled_Product_Count_Temp__c, Opportunity_Plan_Roll_up_Summary_Temp__c, Scheduled_Service_Products_Temp__c, '
                                                                            + 'Unweighted_Rev_Financing_Only_Temp__c, Unweighted_Rev_For_Sort_Temp__c, '
                                                                            + 'Qualified_Vendor_Count_Temp__c, Total_Product_Quantity_Temp__c, Renewal_Extension_Total_Price_Temp__c '
                                                                            + 'FROM Opportunity');
        insert query1;
        
        Profile profile = [SELECT id from profile WHERE Id = '00e30000000nJ6K']; // Admin profile
        User admin = new User(Username=string.valueOf(datetime.now()).replace(':', '_').replace('-', '_').replace(' ', '_') +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c=string.valueOf(datetime.now()).replace(':', '').replace('-', '').replace(' ', ''));
        insert admin;
        
        system.runAs(admin){
            test.starttest();      
              
            datetime todayNow = system.now().addMinutes(1);
            string runtime = todayNow.second() + ' ' + todayNow.minute() + ' ' + todayNow.hour() + ' ' + todayNow.day() + ' ' + todayNow.month() + ' ? ' + todayNow.year();
            String jobId = System.schedule('BatchScopeQueryScheduler',runtime, new BatchScopeQueryScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(runtime, ct.CronExpression);

            Batch_Scope_Query__c q1 = [SELECT Name, Skip_Trigger__c, Query__c, Field_to_update__c, New_Value__c, Batch_Size__c, Need_Helper__c FROM Batch_Scope_Query__c WHERE Id = :query1.Id];
            BatchDataLoadScheduler dlBatchScheduler1 = new BatchDataLoadScheduler();
            dlBatchScheduler1.query = q1.Query__c;
            dlBatchScheduler1.fieldToUpdate = q1.Field_to_update__c;
            dlBatchScheduler1.newValue = q1.New_Value__c;
            dlBatchScheduler1.objectName = q1.Name;
            dlBatchScheduler1.batchSize = Integer.valueOf(q1.Batch_Size__c);
            dlBatchScheduler1.needHelp = q1.Need_Helper__c;
            datetime todayNow1 = system.now().addMinutes(1);
            string runtime1 = todayNow1.second() + ' ' + todayNow1.minute() + ' ' + todayNow1.hour() + ' ' + todayNow1.day() + ' ' + todayNow1.month() + ' ? ' + todayNow1.year();
            String jobId1 = system.schedule('Loading ' + q1.Name + ' @ ' + runtime1, runtime1, dlBatchScheduler1);
                
            CronTrigger ct1 = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId1];
            System.assertEquals(runtime1, ct1.CronExpression);

            test.stoptest();
        }
    }
    
    private static testmethod void testBatchDataLoadAccount(){
        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;
        
        Account acc = new Account(Name='UT Account');
        insert acc;
        
        Opportunity opp = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=acc.Id, Type='Deal/Bid Direct', CloseDate=System.Today()+10, StageName='Plan - 1%');
        insert opp;
        
        Batch_Scope_Query__c query2 = new Batch_Scope_Query__c(Name='Account',  Is_Active__c = true, Need_Helper__c = true, Batch_Size__c = 100, 
                                                                Query__c='SELECT Id, Count_of_Trip_Reports__c, Competitive_Information_Count__c, Account_Plan_Count__c, Count_of_Trip_Reports_Temp__c, '
                                                                            + 'Competitive_Information_Count_Temp__c, Account_Plan_Count_Temp__c FROM Account');
        insert query2;
        
        Profile profile = [SELECT id from profile WHERE Id = '00e30000000nJ6K']; // Admin profile
        User admin = new User(Username=string.valueOf(datetime.now()).replace(':', '_').replace('-', '_').replace(' ', '_') +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c=string.valueOf(datetime.now()).replace(':', '').replace('-', '').replace(' ', ''));
        insert admin;
        
        system.runAs(admin){
            test.starttest();      
              
            datetime todayNow = system.now().addMinutes(1);
            string runtime = todayNow.second() + ' ' + todayNow.minute() + ' ' + todayNow.hour() + ' ' + todayNow.day() + ' ' + todayNow.month() + ' ? ' + todayNow.year();
            String jobId = System.schedule('BatchScopeQueryScheduler',runtime, new BatchScopeQueryScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(runtime, ct.CronExpression);

            Batch_Scope_Query__c q2 = [SELECT Name, Skip_Trigger__c, Query__c, Field_to_update__c, New_Value__c, Batch_Size__c, Need_Helper__c FROM Batch_Scope_Query__c WHERE Id = :query2.Id];
            BatchDataLoadScheduler dlBatchScheduler2 = new BatchDataLoadScheduler();
            dlBatchScheduler2.query = q2.Query__c;
            dlBatchScheduler2.fieldToUpdate = q2.Field_to_update__c;
            dlBatchScheduler2.newValue = q2.New_Value__c;
            dlBatchScheduler2.objectName = q2.Name;
            dlBatchScheduler2.batchSize = Integer.valueOf(q2.Batch_Size__c);
            dlBatchScheduler2.needHelp = q2.Need_Helper__c;
            datetime todayNow2 = system.now().addMinutes(1);
            string runtime2 = todayNow2.second() + ' ' + todayNow2.minute() + ' ' + todayNow2.hour() + ' ' + todayNow2.day() + ' ' + todayNow2.month() + ' ? ' + todayNow2.year();
            String jobId2 = system.schedule('Loading ' + q2.Name + ' @ ' + runtime2, runtime2, dlBatchScheduler2);
                
            CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId2];
            System.assertEquals(runtime2, ct2.CronExpression);
                   
            test.stoptest();
        }
    }
}
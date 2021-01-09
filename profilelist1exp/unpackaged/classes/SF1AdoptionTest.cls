/*
 * Author   : Swathi
 * Purpose  : SF1 Adoption class to capture user actions(Create/Edit) when done through mobile or browser.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 *   1.0    CR12683     FY17-DCS-0401   29-Feb-2016     Swathi          Created for implementing "User action tracking" functionality
 *   2.0    CR13154     FY17-DCS-0602   24-May-2016     Emily           Removed Browser action tracking and exclude Integration/PRM profiles
 * -------- ---------   ----------      -----------     ------------    -----------------------------------------------------------------------------------
 * 
 * 
 */

@isTest
private class SF1AdoptionTest{
      public static testMethod void TesttrackSF1Usage() {
            
            test.startTest();            
            Account testAccount = new Account(Name='Test Sf1 Account',Type = 'End User');
            insert testAccount;
            
            List<sobject> Listsobectrecord = New List<sobject>();
            List<sobject> Listsobectrecord_Tripreport = New List<sobject>();
            
            String strTriggerAction = 'AfterInsert';
            
            CustomerInteraction__c ci = new CustomerInteraction__c( Account__c=testAccount.Id);
            Listsobectrecord_Tripreport.add(ci);
            insert Listsobectrecord_Tripreport;
            
            SF1_Adoption__c newAdoptionRecord= New SF1_Adoption__c();
            newAdoptionRecord.Object_Name__c = 'Trip Report';
            newAdoptionRecord.User_Edited_Date__c= system.Now();
            insert newAdoptionRecord;
            
            datetime dtCreatedDate;
            system.assertEquals(ci.CreatedDate, dtCreatedDate);
            dtCreatedDate=system.now(); 
            system.assertNotEquals(ci.CreatedDate, dtCreatedDate);
            
            sf1Adoption.trackSF1Usage(Listsobectrecord_Tripreport,strTriggerAction);
            test.stopTest();    
    }
    
    public static testMethod void TesttrackSF1Usage_Con(){            
            test.startTest();
            Account testAccount = new Account(Name='Test Sf1 Account',Type = 'End User');
            insert testAccount;
            
            List<sobject> Listsobectrecord = New List<sobject>();           
            Contact testContactrecord = new Contact(FirstName='first', LastName='last', Phone='044223667788',
                                                Email='s@s.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                                Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                                AccountId=testAccount.Id);           
            Listsobectrecord.add(testContactrecord);
            insert Listsobectrecord;
            
            SF1_Adoption__c newAdoptionRecord= New SF1_Adoption__c();
            newAdoptionRecord.Object_Name__c = 'Contact';
            newAdoptionRecord.User_Edited_Date__c= system.Now();
            insert newAdoptionRecord;            
            
            String strTriggerAction = 'AfterInsert';            
            
            sf1Adoption sf1Adotion_controller = new sf1Adoption ();
            sf1Adoption.trackSF1Usage(Listsobectrecord,strTriggerAction);
            delete Listsobectrecord;   
            test.stopTest();            
    }
   
    public static testMethod void TesttrackSF1Usage_forTP() {
            
            test.startTest();            
            Account testAccount = new Account(Name='Test Sf1 Account',Type = 'End User');
            insert testAccount;          
                       
            List<sobject> Listsobectrecord = New List<sobject>();
            List<sobject> Listsobectrecord_Tripreport = New List<sobject>();           
                      
            String strTriggerAction = 'AfterInsert';
            String strTriggerAction_update = 'AfterUpdate';
            
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today().addDays(1),StageName = 'Plan - 1%' );       
            insert testOpp;
            
            Id idEventRT = [select id from recordtype where RecordType.Name = 'Call Plan' limit 1].id;
            Event e = new Event(whatid=testOpp.id,DurationInMinutes=30, ActivityDateTime=system.today(), RecordTypeid = idEventRT );
            insert e;
            
            Deal_Summary__c DS = new Deal_Summary__c(No_Call_Plan__c = 2, Last_Activity_Date__c=system.today(),Opportunity__c=testOpp.id );
            insert DS;            
           
            Event e2 = [select id from Event where whatid=:testOpp .id and whatid != Null ];
            Deal_Summary__c DS1 =[SELECT Opportunity__c, Opportunity__r.LastActivityDate FROM Deal_Summary__c where Opportunity__c=:testOpp.id and Opportunity__c != null];
            DS1.No_Call_Plan__c =1;
            update DS1; 
            
            Event e1 = new Event(whatid=testOpp.id, DurationInMinutes=10, ActivityDateTime=system.today());
            insert e1;
                
            delete e2;           
            SF1_Adoption__c newAdoptionRecord= New SF1_Adoption__c();
            newAdoptionRecord.Object_Name__c = 'Trip Report';
            newAdoptionRecord.User_Edited_Date__c= system.Now();
            insert newAdoptionRecord;
            
            sf1Adoption.trackSF1Usage(Listsobectrecord_Tripreport,strTriggerAction_update);
            test.stopTest();            
    }
    
    public static testMethod void TesttrackSF1Usage_forTask() {
            Account testAccount = new Account(Name='Test Sf1 Account',Type = 'End User');
            insert testAccount;
            
            List<sobject> Listsobectrecord = New List<sobject>();
            String strTriggerAction_update = 'AfterUpdate';
            
            List<Task> tasks = new List<Task>();
                                tasks.add(new Task(
                                ActivityDate = Date.today().addDays(7),
                                Subject='Sample Task',
                                WhatId = testAccount.Id,
                                OwnerId = UserInfo.getUserId(),
                                Status='In Progress'));
            
            insert tasks;
            
            Datetime yesterday = Datetime.now().addDays(-1);
            Test.setCreatedDate(tasks[0].Id, yesterday);
            
            tasks[0].Subject='Sample Task update';
            update tasks;
            test.startTest(); 
             
            SF1_Adoption__c newAdoptionRecord= New SF1_Adoption__c();
            newAdoptionRecord.Object_Name__c = 'Task';
            newAdoptionRecord.User_Edited_Date__c= system.Now();
            newAdoptionRecord.User_Action__c = 'Edit';
            insert newAdoptionRecord;
            
            datetime dtCreatedDate;
            system.assertEquals(tasks[0].CreatedDate, dtCreatedDate);
            dtCreatedDate=DateTime.now().addYears(1);
            system.assertNotEquals(tasks[0].CreatedDate, dtCreatedDate);
            
            sf1Adoption.trackSF1Usage(tasks,strTriggerAction_update);
            test.stopTest();     
    }
 
}
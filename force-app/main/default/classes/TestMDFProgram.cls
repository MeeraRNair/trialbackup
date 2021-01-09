@isTest
private class TestMDFProgram {
    
    static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like 'MDF Program Owners' limit 1];
    static User usr1 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static User usr2 = new User(alias = 'newUser2', email='user2@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge2',timezonesidkey='America/Los_Angeles', username='user2@dellteam.com');
    static User usr3 = new User(alias = 'newUser3', email='user3@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge3',timezonesidkey='America/Los_Angeles', username='user3@dellteam.com');
    static RecordType eventRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Event'];
    static RecordType fieldEventRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Field Event'];
    static RecordType trainingRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Training'];
    static User usr4 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static User usr5 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static User usr6 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static User usr7 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static User usr8 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static User usr9 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static User usr10 = new User(alias = 'newUser1', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
    static RecordType printRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Print'];
    static RecordType webRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Web'];
    static RecordType emailRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Email'];
    static RecordType dellRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Dell.com'];
    static RecordType contestRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Contest'];
    static RecordType headcountRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Headcount'];
    static RecordType seedUnitRT = [Select Id,Name from RecordType where sObjectType ='MDF_Program__c'and isActive=true and Name ='Seed Units'];
    static MDF_Program__c mpEventPrint = new MDF_Program__c();
    static MDF_Program__c mpEventWeb = new MDF_Program__c();
    static MDF_Program__c mpEventEmail = new MDF_Program__c();
    static MDF_Program__c mpEventDell = new MDF_Program__c();
    static MDF_Program__c mpEventContest = new MDF_Program__c();
    static MDF_Program__c mpEventHeadcount = new MDF_Program__c();
    static MDF_Program__c mpEventSeedUnit = new MDF_Program__c();
    static MDF_Program__c mpEvent = new MDF_Program__c();
    static MDF_Program__c mpFieldEvent = new MDF_Program__c();
    static MDF_Program__c mpTraining = new MDF_Program__c();
    
    static testMethod void testBeforeInsertEventMdfProg() {
        Test.startTest();
        
        insert usr1; //program owner
        
        //Insert event mdf program
        mpEvent.recordTypeID = eventRT.Id;
        mpEvent.Name = 'TestEventMdfProgName';
        mpEvent.Program_Owner__c=usr1.Id;
        mpEvent.POP_Owner__c=usr1.Id;
        mpEvent.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpEvent;
        
        //Retrieve and assert updated pop details
        mpEvent = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpEvent.Id];
        System.assertEquals('Signed affidavit and/or event photos showing partner or partner placement.', mpEvent.POP_Details__c);
        
        Test.stopTest();
    }
    
    static testMethod void testBeforeInsertFieldEventMdfProg() {
        Test.startTest();
        
        insert usr2; //program owner
        
        //Insert event mdf program
        mpFieldEvent.recordTypeID = fieldEventRT.Id;
        mpFieldEvent.Name = 'TestFieldEventMdfProgName';
        mpFieldEvent.Program_Owner__c=usr2.Id;
        mpFieldEvent.POP_Owner__c=usr2.Id;
        mpFieldEvent.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpFieldEvent;
        
        //Retrieve and assert updated pop details
        mpFieldEvent = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpFieldEvent.Id];
        System.assertEquals('Signed affidavit and/or event photos showing partner or partner placement.', mpFieldEvent.POP_Details__c);
        
        Test.stopTest();
    }
    
    static testMethod void testBeforeInsertTrainingMdfProg() {
        Test.startTest();
        
        insert usr3; //program owner
        
        //Insert event mdf program
        mpTraining.recordTypeID = TrainingRT.Id;
        mpTraining.Name = 'TestTrainingMdfProgName';
        mpTraining.Program_Owner__c=usr3.Id;
        mpTraining.POP_Owner__c=usr3.Id;
        insert mpTraining;
        
        //Retrieve and assert updated pop details
        mpTraining = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpTraining.Id];
        System.assertEquals('Signed affidavit and/or event photos showing partner or partner placement. Web training invitations will also be provided, if applicable.', mpTraining.POP_Details__c);
        
        Test.stopTest();
    }
    //Syazwan
    Static testMethod void testBeforeInsertPrintMdfProg() {
        Test.startTest();
        
        insert usr4; //program owner
        
        //Insert event mdf program
        mpEventPrint.recordTypeID = PrintRT.Id;
        mpEventPrint.Name = 'TestEventMdfProgName';
        mpEventPrint.Program_Owner__c=usr4.Id;
        mpEventPrint.POP_Owner__c=usr4.Id;
        mpEventPrint.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpEventPrint;
        
        //Retrieve and assert updated pop details
        mpEventPrint = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpEventPrint.Id];
        System.assertEquals('Copy of marcom vehicle, including partner placement, will be provided.', mpEventPrint.POP_Details__c);
        
        Test.stopTest();
    }
        Static testMethod void testBeforeInsertWebMdfProg() {
        Test.startTest();
        
        insert usr5; //program owner
        
        //Insert event mdf program
        mpEventWeb.recordTypeID = WebRT.Id;
        mpEventWeb.Name = 'TestEventMdfProgName';
        mpEventWeb.Program_Owner__c=usr5.Id;
        mpEventWeb.POP_Owner__c=usr5.Id;
        mpEventWeb.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpEventWeb;
        
        //Retrieve and assert updated pop details
        mpEventWeb = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpEventWeb.Id];
        System.assertEquals('Copy of website, including partner placement, will be provided.', mpEventWeb.POP_Details__c);
        
        Test.stopTest();
    }
            Static testMethod void testBeforeInsertEmailMdfProg() {
        Test.startTest();
        
        insert usr6; //program owner
        
        //Insert event mdf program
        mpEventEmail.recordTypeID = EmailRT.Id;
        mpEventEmail.Name = 'TestEventMdfProgName';
        mpEventEmail.Program_Owner__c=usr6.Id;
        mpEventEmail.POP_Owner__c=usr6.Id;
        mpEventEmail.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpEventEmail;
        
        //Retrieve and assert updated pop details
        mpEventEmail = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpEventEmail.Id];
        System.assertEquals('Copy of email, including partner placement, will be provided.', mpEventEmail.POP_Details__c);
        
        Test.stopTest();
    }
            Static testMethod void testBeforeInsertDellMdfProg() {
        Test.startTest();
        
        insert usr7; //program owner
        
        //Insert event mdf program
        mpEventDell.recordTypeID = DellRT.Id;
        mpEventDell.Name = 'TestEventMdfProgName';
        mpEventDell.Program_Owner__c=usr7.Id;
        mpEventDell.POP_Owner__c=usr7.Id;
        mpEventDell.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpEventDell;
        
        //Retrieve and assert updated pop details
        mpEventDell = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpEventDell.Id];
        System.assertEquals('Copy of website, including partner placement, will be provided.', mpEventDell.POP_Details__c);
        
        Test.stopTest();
    }
            Static testMethod void testBeforeInsertContestMdfProg() {
        Test.startTest();
        
        insert usr8; //program owner
        
        //Insert event mdf program
        mpEventContest.recordTypeID = ContestRT.Id;
        mpEventContest.Name = 'TestEventMdfProgName';
        mpEventContest.Program_Owner__c=usr8.Id;
        mpEventContest.POP_Owner__c=usr8.Id;
        mpEventContest.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpEventContest;
        
        //Retrieve and assert updated pop details
        mpEventContest = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpEventContest.Id];
        System.assertEquals('Copy of detailed contest announcement (product, high level targets and reward criteria) to the sales teams. Will also include product/sku lists, reward dinner photos as applicable.', mpEventContest.POP_Details__c);
        
        Test.stopTest();
    }
                Static testMethod void testBeforeInsertHeadcountMdfProg() {
        Test.startTest();
        
        insert usr9; //program owner
        
        //Insert event mdf program
        mpEventHeadcount.recordTypeID = HeadcountRT.Id;
        mpEventHeadcount.Name = 'TestEventMdfProgName';
        mpEventHeadcount.Program_Owner__c=usr9.Id;
        mpEventHeadcount.POP_Owner__c=usr9.Id;
        mpEventHeadcount.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpEventHeadcount;
        
        //Retrieve and assert updated pop details
        mpEventHeadcount = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpEventHeadcount.Id];
        System.assertEquals('Signed affidavit will be provided.', mpEventHeadcount.POP_Details__c);
        
        Test.stopTest();
    }
                Static testMethod void testBeforeInsertSeedUnitMdfProg() {
        Test.startTest();
        
        insert usr10; //program owner
        
        //Insert event mdf program
        mpEventSeedUnit.recordTypeID = SeedUnitRT.Id;
        mpEventSeedUnit.Name = 'TestEventMdfProgName';
        mpEventSeedUnit.Program_Owner__c=usr10.Id;
        mpEventSeedUnit.POP_Owner__c=usr10.Id;
        mpEventSeedUnit.Fiscal_Quarter__c = 'FY15Q1W01';
        insert mpEventSeedUnit;
        
        //Retrieve and assert updated pop details
        mpEventSeedUnit = [SELECT Id, POP_Details__c FROM MDF_Program__c WHERE Id = :mpEventSeedUnit.Id];
        System.assertEquals('Copy of unit order(s) summary will be provided.', mpEventSeedUnit.POP_Details__c);
        
        Test.stopTest();
    }
}
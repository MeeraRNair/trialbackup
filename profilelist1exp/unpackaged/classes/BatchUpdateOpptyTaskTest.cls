/**
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      14-DEC-2010   Azwanti         Created for CR4117, R12.1
2.0      04-DEC-2019   Vikas           Implemented TDF
*/
@isTest
private class BatchUpdateOpptyTaskTest {
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static User userRecord1, userRecord2;
    static List<User> listuserRecord = new List<User>();
    static List<Contact> listtestContact = new List<Contact>();
    static Task task;
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';        
        insert oWDsetting;
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Master Account');
        insert listAccTDF;         
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Deal Registration');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listOppTDF;
    } 
    static testMethod void testbuOpptyTask() {
        TriggerExecutionController.setSkipAllTriggers(true);
        TestDataCreation();
        listAcc = [select id, name,OwnerId from Account limit 1];
        ID prevAccountOwner = listAcc[0].OwnerId;
        listAcc[0].OwnerId = userRecord2.Id;   
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        try{
            update listAcc;
        }catch (exception e){}
        //2. Simulating Acc Work Item Batch Job by manually updating Account WI: Status,New Owner & Prev Owner
        Work_Items__c wII = new Work_Items__c();
        wII.Account__c = listAcc[0].Id;
        insert wII;      //Status__c,New_Owner__c, Previous_Owner__c,
        Work_Items__c wI = [Select Id,Account__c from Work_Items__c where Account__c =: listAcc[0].Id];
        wI.Status__c = 'In Progress';
        wI.Previous_Owner__c = userRecord1.Id;
        wI.New_Owner__c = userRecord2.Id;
        update wI;
        Work_Items__c opptyWI = new Work_Items__c(Opportunity__c = listOpp[0].Id, Status__c = 'Pending', New_Owner__c = userRecord2.Id , Previous_Owner__c = userRecord1.Id, Object_Type__c = 'Opportunity');
        insert opptyWI;
        system.debug('#### opptyWI :' + opptyWI);
        task = new Task(WhatId = listOpp[0].Id, OwnerId = userRecord1.Id);
        insert task;
        
        BatchUpdateOpptyTask buOpptyTask = new BatchUpdateOpptyTask();
        buOpptyTask.isTest = true;
        buOpptyTask.queryOpptyTask = 'SELECT WhatId, AccountId, OwnerId '+
            'FROM Task WHERE WhatId in (SELECT Opportunity__c FROM Work_Items__c WHERE Id = \''+opptyWI.Id+'\' AND Status__c = \'Pending\' AND Object_Type__c = \'Opportunity\') AND '+
            'IsClosed = false';
        system.debug('## buOpptyTask.queryOpptyTask: ' + buOpptyTask.queryOpptyTask);
        
        database.executeBatch(buOpptyTask); 
        Test.stopTest();
        Task newOpptyTask = [Select Id, OwnerId from Task where Id =: task.Id];
        system.assertEquals(listAcc[0].OwnerId, newOpptyTask.OwnerId);
    }
    
    //==================================================== TestDataCreation ===============================================================
    static void testDataCreation() {
        listAcc = [select id,name from Account limit 1];
        listAcc[0].Account_Country_Code__c = 'AI';
        listAcc[0].Account_Country__c = 'ANGUILIA';
        listAcc[0].Account_ID__c = ''+System.currentTimeMillis();
        update listAcc;
        listtestContact.clear();
        for (integer inti = 0; inti < 2; inti++) {
            Contact testContact = new Contact(Status__c='Active', AccountId=listAcc[0].Id, EMEA_Decision_Making_Role__c='Influencer', 
                                              Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                              Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+inti);
            listtestContact.add(testContact);
        }                                            
        insert listtestContact;
        List<Profile> listuserProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];        
        userRecord1 = new User(
            Username='testUser1'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test1@dell.com', 
            FirstName='Tfirst A', 
            LastName='TLast',
            ProfileId = listuserProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345',
            Title = 'Test Title'
        );
        listuserRecord.add(userRecord1);
        userRecord2 = new User(
            Username='testUser2'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test2@dell.com', 
            FirstName='Tfirst B', 
            LastName='TLast',
            ProfileId = listuserProfile[1].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST56789',
            Title = 'Test Title'
        );
        listuserRecord.add(userRecord2);
        insert listuserRecord; 
        listOpp = [select id,name,AccountID,Stagename from Opportunity limit 1];
        listOpp[0].AccountId = listAcc[0].Id;
        listOpp[0].StageName = 'Discover - 10%';
        update listOpp;
    }
}
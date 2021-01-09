@istest
private class  CTI_createtasksTest{
    
    static list<Account> listAcc;
    static list<Contact> listCon;
    static list<Opportunity> listOpp;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Contact> listConTDF = TestDataFactory.createNContacts(1);
        insert listConTDF;
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1,'Standard Opportunity');
        
        insert listOppTDF;
        
    }
    static testmethod void myUnitTest() {
        /**********************************/
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        listAcc = [Select Id from Account limit 1];
        listCon = [Select Id from Contact limit 1];
        listCon[0].AccountId = listAcc[0].Id;
        update listcon;
        
        listOpp = [Select Id from Opportunity limit 1];
        listOpp[0].CloseDate = System.Today()- 3;
        update listOpp;
        system.assertNotEquals(listAcc[0].id, null);
        /*Account acc = new Account();
acc.Name = 'testAccount';
insert acc;

Contact con = new Contact();
con.AccountId = listAcc[0].Id;
con.Email = 'test@test.com';
con.LastName = 'conLastName';
insert con;*/
        
        /*Opportunity opp = new Opportunity();
opp.Name = 'testOpp';
//opp.StageName = 'Won'; // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
opp.Stagename = 'Win - 100%'; // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
opp.Competitor_Lost_To__c = 'Unknown';  // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
opp.CloseDate = System.Today()- 3;
system.debug('----ABC---'+opp.CloseDate);
insert opp;*/
        
        //   VFCntrlr_CTISearchAccOrCon.runCTITrigger = false;
        
        
        /*********************************/
        
        CTI_Call_Log__c cTIC = new CTI_Call_Log__c
            (
                Call_Type__c = 'outgoing',
                Account__c = listAcc[0].Id, 
                contact__c = listCon[0].Id,
                Opportunity__c = listOpp[0].Id,
                Comments__c = 'testcomments',
                CreatedById = UserInfo.getUserId(),                               
                
                createddate = system.today()- 2
            );
        system.debug('----ABD---'+cTIC.createddate);
        insert cTIC ;
        update cTIC ;
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}
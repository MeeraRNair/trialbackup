@IsTest
private class PartnerDealRegistrationCtrlTest {

    private static testmethod void testNormal(){
        //NOTE: this test is depenendent upon approval process records existing.  An
        //  alternative version of this test was created; however, a trigger was causing
        //  a too many rows error so this is the method which is used.
        List<ProcessInstanceStep> instances = 
            [select ActorId from ProcessInstanceStep where StepStatus = 'Started' and ActorId in (Select id from user where isActive = TRUE) limit 1];
        if(instances.size() <= 0){
            System.debug('Exiting test: no rows returned by query \'select ActorId from ProcessInstanceStep where StepStatus = \'Started\' and ActorId in (Select id from user where isActive = TRUE) limit 1\'');
            return; 
        }
        User user = [select id from user where id = :instances.get(0).ActorId];
        System.runAs(user){
            Test.startTest();
            PartnerDealRegistrationCtrl controller = new PartnerDealRegistrationCtrl();
            System.assertNotEquals(null,controller.requests);   
            System.assert(controller.requests.size()>0);    
            System.assert(controller.getCountOfRequests()>0);   
            controller.getPreferredLanguageCode();
            Test.stopTest();
        }
    }
	
    private static testmethod void testNoApprovalSteps(){
        System.runAs(createPartnerUser()){ //since we're creating the partner user, there won't be any requests for approval
            Test.startTest();
            PartnerDealRegistrationCtrl controller = new PartnerDealRegistrationCtrl();
            System.assertNotEquals(null,controller.requests);   
            System.assertEquals(0,controller.requests.size());  
            System.assert(controller.getCountOfRequests()<=0);  
            Test.stopTest();
        }
    }
    
    private static testmethod void testProtectedDeal(){
         List<Opportunity> opportunityList;
         System.runAs(createPartnerUser()){ //since we're creating the partner user, there won't be any requests for approval
            Test.startTest();
            PartnerDealRegistrationCtrl controller = new PartnerDealRegistrationCtrl();
            opportunityList=controller.getProtectedDealList();  
            Test.stopTest();
        }
    }
	


    private static User createPartnerUser(){
        final List<Profile> partnerProfiles = 
            [select id,name from Profile where UserType = 'PowerPartner' and name like '%LA PRM%' limit 1];
        System.assert(
            !(partnerProfiles == null || partnerProfiles.size() <= 0), 
            'Test cannot execute: No partner profiles exist');  
        final List<Account> accounts = new List<Account>();
        Account account = new Account(name='Test');
        insert account;
        account.IsPartner = true;
        update account;
        Contact contact = new Contact(
                    AccountId=account.id,
                    Email='test@test.com', 
                    FirstName = 'John', 
                    LastName = 'Doe'
                );
        insert contact;
        User user = new User(
                    Username='test' + System.currentTimeMillis() + '@test.com',
                    Alias = 'test1', 
                    Email='test@test.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c=null, 
                    ContactId = contact.id
                );
        insert user;
        return user;
    }
/*
    //Would rather use the below test code but the trigger trgOppFYCloseDate
    //  is preventing this from successfully running.  That trigger fires code
    //  which runs a bunch of queries and puts the below test over the 500 rows governor limit.  :-(
    
    private static testmethod void testNormal(){
        System.runAs(createPartnerUser()){
            /*
            Entry rule criteria for R9.9_PRM_English_LA_Deal_Reg_Approval
            (Opportunity: Has Line ItemequalsTrue) 
            and (Current User: LanguageequalsEnglish) 
            and (Opportunity: Submitter ProfilecontainsLA PRM) 
            and (
                (Opportunity: Opportunity Record TypeequalsDeal Registration) 
                or (Opportunity: Opportunity Record TypeequalsDeal Registration-Submitted)
            */
/*
            Opportunity opp = new Opportunity(
                Name='Test'
                ,RecordTypeId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true)
                ,StageName='Plan'
                ,CloseDate=Date.newInstance(2008,3,5)
                ,End_User_Email__c='test@test.com'
            );
            insert opp;
            OpportunityLineItem oppline = new OpportunityLineItem(
                OpportunityId=opp.id
                ,Quantity=1
                ,TotalPrice=10000
                ,PricebookEntryId = [select id from PricebookEntry where IsActive = true
                    and CurrencyIsoCode = 'USD' limit 1].id
            );
            insert oppline;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(opp.id);
            Approval.ProcessResult result = Approval.process(req1);
            
            Test.startTest();
            PartnerDealRegistrationCtrl controller = new PartnerDealRegistrationCtrl();
            System.assertNotEquals(null,controller.requests);   
            System.assert(controller.requests.size()>0);    
            Test.stopTest();
        }
    }
*/
}
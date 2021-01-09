/* 
History:
Version     Date            Modified By                     CR          Description     
--------------------------------------------------------------------------------------
1.0         22-Jul-2016     Shahiruni Wahida                13334       Story 1913809:Add a new opportunity survey button to Opportunity page
*/

@isTest
private class OpportunityAssessmentTest {

    //Added custom settings to populate StageName values.
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
                TriggerExecutionController.setSkipAllTriggers(true);
        list<user> listUsertdf=TestDataFactory.createNPortalUser(1);
        insert listUsertdf;
        
        list<account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        listOppTdf[0].Partner_Opportunity_Stage__c = 'Plan - 1%';
       // listOppTdf[0].StageName='Plan - 1%';
        insert listOppTdf;
    }

  private static testMethod void test() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOpp=[select id from Opportunity limit 1];
       /* List<Profile> userProfile= [select id,name from profile where name like '%Sales%' order by name limit 2];
        User usr = new User(Username='test_test@dell.com', Alias='test', Email='test_test@dell.com', FirstName='Tfirst', LastName='TLast', ProfileId = userProfile[0].Id, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test'+System.currentTimeMillis(), Title='Test Title', CurrencyIsoCode='USD');
        insert usr;
        
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Opportunity oppty = new Opportunity(AccountID=acc.ID, Name='Test Oppty', Type='Standard Opportunity', StageName='Plan - 1%', 
                                            Partner_Opportunity_Stage__c = 'Plan - 1%',CloseDate=System.Now().Date().addDays(180));
        insert oppty;
        */
      system.assertNotEquals(listOpp[0].id, null);
        Test.startTest();        
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(listOpp[0]);
        OpportunityAssessment oa = New OpportunityAssessment(sc);
      
        oa.redirect(); 
        Test.stopTest();
      
       
      
  }
}
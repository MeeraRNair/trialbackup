/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountUtilsTest{
    
    private static testMethod void testSendEmailToPartnerAdmin_v1(){
        String countryCode = 'FR';
        String domain = 'dell.com.fdev';
        String email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String languageCode = 'en_US';
        
        Account newAcc = CreatePartnerAccount(countryCode, true);
        Contact con = CreatePartnerContact(newAcc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + domain);
        User u1 = CreatePartnerUser(con.Id, email, languageCode, true, true, true);
        //spf__Configuration_Variable__c conVar = CreateConVar('FAP_INSTRUCTION_DOC_URL', 'http://u4vmngcppsit01.aus.amer.dell.com:90/sites/channel/en-us/documents/find_a_partner_admin_guide_020711.pdf');

        List<Id> accPartnerFinder = new List<Id>();
        accPartnerFinder.add(newAcc.Id);
        AccountUtils.SendEmailToPartnerAdmin(accPartnerFinder);
        
        List<User> admins = [SELECT email, LanguageLocaleKey FROM User WHERE Contact.AccountId IN :accPartnerFinder];
        system.AssertEquals(1, admins.size());
        system.AssertEquals(email, admins[0].Email);
        system.AssertEquals(languageCode, admins[0].LanguageLocaleKey);  
    }
 //Dipin   
    private static testMethod void testSendCompetencyEmailToPartnerAdmin_v1(){
        String countryCode = 'FR';
        String domain = 'dell.com.fdev';
        String email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String languageCode = 'en_US';
        
        Account newAcc = CreatePartnerAccount(countryCode, true);
        Contact con = CreatePartnerContact(newAcc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + domain);
        User u1 = CreatePartnerUser(con.Id, email, languageCode, true, true, true);
        //spf__Configuration_Variable__c conVar = CreateConVar('FAP_INSTRUCTION_DOC_URL', 'http://u4vmngcppsit01.aus.amer.dell.com:90/sites/channel/en-us/documents/find_a_partner_admin_guide_020711.pdf');

        List<Id> accPartnerFinder = new List<Id>();
        accPartnerFinder.add(newAcc.Id);
       // AccountUtils.SendCompetencyEmailToPartnerAdmin(accPartnerFinder);
        
        List<User> admins = [SELECT email, LanguageLocaleKey FROM User WHERE Contact.AccountId IN :accPartnerFinder];
        system.AssertEquals(1, admins.size());
        system.AssertEquals(email, admins[0].Email);
        system.AssertEquals(languageCode, admins[0].LanguageLocaleKey);  
    }
 //Dipin  
  
    private static Account CreatePartnerAccount(String countryCode, Boolean isPartner){
        Account acc = new Account(Name = 'CreatePartnerAccount', Account_Country_Code__c = countryCode);
        insert acc;
        acc.IsPartner = isPartner;
        update acc;
        return acc;
    }
    
    private static Contact CreatePartnerContact(String accountId){
        return CreatePartnerContact(accountId, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev');
    }
    
    private static Contact CreatePartnerContact(string accountId, string email){
        Contact con1 = new Contact(AccountId = accountId, Email = email, Lastname = 'UT',Primary_Contact__c=false);
        insert con1;
        return con1;
    }
    
    private static User CreatePartnerUser(String contactId, String email, String languageCode, Boolean isActive, Boolean isPartnerAdmin, Boolean isAdminForPartnerFinder){
        // Create this user with CSPLitePortal profile,
        // so that the AccountId will be populated as same as the associated Contact's AccountId
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' LIMIT 1];
        User u1 = new User(ContactId = contactId, IsActive = isActive, Email = email, LanguageLocaleKey = languageCode, Enable_Partner_Admin__c = isPartnerAdmin,
        Is_Admin_for_Partner_Finder_Profile__c = isAdminForPartnerFinder,Badge_Number__c='FAP'+String.ValueOf(Math.round(Math.random()*100000)),
            ProfileId = p.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LastName = 'UT', Alias = 'UT', EmailEncodingKey = 'ISO-8859-1', UserName = email);
        insert u1;
        return u1;
    }

    /*private static spf__Configuration_Variable__c CreateConVar(String name, String url){
        spf__Configuration_Variable__c conVar = new spf__Configuration_Variable__c(Name = name,spf__Value__c = url);
        insert conVar;
        return conVar;
    }*/

  private static testMethod void updateAccnttracTest(){
         Id directLeadRT = IdLookupUtils.getRecordTypeId('Account Suggestion Locked', 'Lead', true);
         String countryCode = 'FR';
         Account newAcc = CreatePartnerAccount(countryCode, true);
         
         Sales_Channel_Group__c SCG = new Sales_Channel_Group__c();
         SCG .Name = 'Test';
         insert SCG;
         
         Lead LD = new Lead(Company = 'Test',
                            Status = 'Open',
                            Territory_Assignment__c = SCG.id,
                            Suggestion_Reason__c = 'New Customer',
                            LastName = 'Test',
                            Email = 'test@test.com',
                            Account_Category__c = 'Partner',
                            Account__c = newAcc.id,
                            RecordTypeId = directLeadRT,                             
                            Lead_Type__c = 'Inbound',
                            TRAC_Number__c = '123',
                            Risk_Level__c = 'Level 1',
                            TRAC_Date__c = System.Today());                            
            insert LD;
         
         Set<Id> accIds = new Set<Id>();
         accIds.add(newAcc.Id);
         system.assert(accIds.size() > 0);
         Map<Id, Lead> accLeadMap = new Map<Id, Lead>();
         accLeadMap.put(LD.Account__c, LD);
         
         AccountUtils.updateAccnttrac(accIds, accLeadMap);
          
     
    }
    
    private static testMethod void processedAccountIdTestMethod(){
      
      String countryCode = 'FR';
      String domain = 'dell.com.fdev';
      String email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
      String languageCode = 'en_US';
        
      Account newAcc = CreatePartnerAccount(countryCode, true);
      Contact con = CreatePartnerContact(newAcc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + domain);
      TriggerExecutionController.setSkipUserTriggers(true);
      User u1 = CreatePartnerUser(con.Id, email, languageCode, true, true, true);
      newAcc.Primary_Contact__c = con.Id;
      newAcc.PRD_Rep_Name__c = u1.Id;
      TriggerExecutionController.setSkipAccountTriggers(true);
      update newAcc;
      TriggerExecutionController.setSkipAccountTriggers(false);
    
      TriggerExecutionController.setSkipContactTriggers(true);
      Contact con2 = CreatePartnerContact(newAcc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '2@' + domain);
      User u2 = CreatePartnerUser(con2.Id, email+'2', languageCode, true, true, true);   

      TriggerExecutionController.setSkipUserTriggers(false);
      Test.StartTest();            
      
      Set<Id> accIds = new Set<Id>();
      accIds.add(newAcc.Id);
      
      Set<Id> conIds= new Set<Id>();   

      conIds.add(con.Id);   
      Map<Id,Set<Id>> mapOfAccIdToNonPrimaryContIdSet = new Map<Id, Set<Id>>();
      Map<Id,Id> accountToPrimaryContactIdMap = new Map<Id,Id>();

      mapOfAccIdToNonPrimaryContIdSet.put(newAcc.Id,conIds);

      AccountUtils.accountUpdate(accIds, accountToPrimaryContactIdMap,mapOfAccIdToNonPrimaryContIdSet);

      
      accountToPrimaryContactIdMap.put(newAcc.Id,con.Id);

      AccountUtils.accountUpdate(accIds, accountToPrimaryContactIdMap,mapOfAccIdToNonPrimaryContIdSet);

      Map<Id, string> accntWebsiteMap = new Map<Id, string>();
      accntWebsiteMap.put(newAcc.Id,'testWebsite');
      conIds.add(con2.Id);         
      AccountUtils.updateAccntWebsite(accIds,accntWebsiteMap);

      Test.StopTest();
      TriggerExecutionController.setSkipContactTriggers(false);
      
    }
}
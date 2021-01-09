/*
* Author   : Men Mee
* Purpose  : Test class for OppTeamMemberTrigger 
* 
* Revision CR Number   Release No  Date            Modified By                  Description
* -------- ---------   ----------  -----------     ------------                 -----------
* 1.0      11716       16.06       09-Jul-2015     Men Mee                      Send notification if got opportunity team member get deleted
* 2.0      13727       0103        6th-Jan-2017    Sazleen                      Fix 0103 test class error
*                             	    13-Oct-2019     Venugopalachary k            Implement Test Data Factory                      		     
*/

@isTest
private class OppTeamMemberTriggerTest {
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    static User u;
    static OpportunityTeamMember otm;
    static OpportunityTeamMember otm1;
    
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
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
        
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccfromFactory;
        List<Opportunity> listOppFromFactory=TestDataFactory.createNOpportunities(2, 'Channel Opportunity');
        insert listOppFromFactory;
    }
    
    static void createTestData() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[select id,RecordtypeId from Account Limit 1];
        listAcc[0].recordtypeId=TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        update listAcc;
        
        Contact testContact = new Contact(FirstName='first', LastName='last', Phone='044223667788',
                                          Email='s@s.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                          Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                          AccountId=listAcc[0].Id,MobilePhone = '9030587363',Eloqua_ID__c = '1234');
        
        insert testContact;
        listOpp=[select id from Opportunity];     
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].CurrencyIsoCode = 'USD';
        listOpp[0].Type = 'Renewal';
        listOpp[0].Domain__c = 'Non Domain';
        listOpp[0].No_times_BookDate_moved__c = 0;
        listOpp[0].StageName = 'Plan - 1%'; 
        listOpp[1].Type='Deal/Bid - Direct';
        listOpp[1].Deal_Registration_Status__c= 'Approved';
        listOpp[1].Solution_Type__c='Business Processing';
        listOpp[1].Tier_1_Approved_Rejected__c = System.now().addhours(1);            
        listOpp[1].StageName='Plan - 1%';
        listOpp[1].AccountId=listAcc[0].Id;
        
        update listOpp;
        Profile profile = new profile();
        for(Profile userProfile:[Select id from Profile where name like '%System Administrator' Limit 1]){
            profile=userprofile;
        } 
        
        String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev'; 
        u = new User(Alias = 'CM101',
                     LastName = 'testCM101',
                     Email = 'x.y@ust-global.com',
                     Username = strusername,
                     CommunityNickname = 'testCM101',
                     EmailEncodingKey = 'ISO-8859-1',
                     TimeZoneSidKey = 'America/Panama',
                     LocaleSidKey = 'en_US',
                     LanguageLocaleKey = 'en_US',
                     ProfileId = profile.id,
                     Badge_number__c='CM101');
        insert u;
        TriggerExecutionController.setSkipAllTriggers(false);
        otm = new OpportunityTeamMember(UserId = u.Id, 
                                        OpportunityId = listOpp[0].Id, 
                                        TeamMemberRole = 'DM Sales Specialist');
        insert otm;
        
        otm1 = new OpportunityTeamMember(UserId = u.Id, 
                                         OpportunityId = listOpp[1].Id, 
                                         TeamMemberRole = 'DM Solutions Engineer'); 
        insert otm1;
        TriggerExecutionController.setSkipAllTriggers(true);
        OpportunityShare oppS0 = new OpportunityShare();
        oppS0.OpportunityId = listOpp[0].Id;
        oppS0.UserOrGroupId = u.Id;
        oppS0.OpportunityAccessLevel = 'Edit';
        insert oppS0;    
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void deleteOTM() {
        createTestData();
        system.assertEquals(otm1.TeamMemberRole, 'DM Solutions Engineer');
        delete otm1;
        
    }
    
    static testMethod void testpartneruseremailafterApproval(){
        TriggerExecutionController.setSkipAllTriggers(true);
        //2.0
        listAcc=[select id,recordtypeId from account];
        listAcc[0].Is_GTM_Partner__c = true;
        listAcc[0].IsPartner = true;
        listAcc[1].recordtypeId=TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc[1].Account_Country__c = 'UNITED STATES';
        listAcc[1].Tax_Registration_Number__c = '124214';
        listAcc[1].ShippingStreet = '12';
        listAcc[1].ShippingCity = 'testStreet';
        listAcc[1].ShippingState = 'testTexas';
        listAcc[1].ShippingPostalCode = '1324';
        update listAcc;
        
        Contact con = new Contact(AccountId = listAcc[0].Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',phone='2345',mobilephone='3442',Eloqua_ID__c='234');
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        string strproid = [SELECT id from profile WHERE Name LIKE '%EC-EMEA PRM%' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User usr = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'fr',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'fr', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid , UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert usr;
        
        string strcountryCode = 'US';
        string strlanguageCode = 'ja';
        
        String strs = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';
        listOpp=[select id from Opportunity limit 1];
        listOpp[0].AccountID=listAcc[1].id;
        listOpp[0].Submission_Status_2__c = strs;
        listOpp[0].Submission_Status_3__c = strs;
        listOpp[0].Engage_Channel_Opportunity__c = false;
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityTeamMember otmnew = new OpportunityTeamMember(UserId = usr.Id, 
                                                                 OpportunityId = listOpp[0].Id, 
                                                                 TeamMemberRole = 'Reseller Contact');
        insert otmnew;
        system.assertEquals(otmnew.OpportunityId, listOpp[0].Id);
    }
    
    static testMethod void testpartneruseremailafterApprovalmorocco(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[select id,recordtypeId from account];
        listAcc[0].Is_GTM_Partner__c = true;
        listAcc[0].IsPartner = true;
        listAcc[1].recordtypeId=TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc[1].Account_Country__c = 'UNITED STATES';
        listAcc[1].Tax_Registration_Number__c = '124214';
        listAcc[1].ShippingStreet = '12';
        listAcc[1].ShippingCity = 'testStreet';
        listAcc[1].ShippingState = 'testTexas';
        listAcc[1].ShippingPostalCode = '1324';
        update listAcc;
        
        Contact con = new Contact(AccountId = listAcc[0].Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',phone='2345',mobilephone='3442',Eloqua_ID__c='234');
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        string strproid = [SELECT id from profile WHERE Name LIKE '%EC-EMEA PRM%' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User usr = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'fr',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'fr', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert usr;
        
        string strcountryCode = 'US';
        string strlanguageCode = 'ja';
        String strs = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';
        listOpp=[select id from Opportunity limit 1];
        listOpp[0].AccountID=listAcc[1].id;
        listOpp[0].Submission_Status_2__c = strs;
        listOpp[0].Submission_Status_3__c = strs;
        listOpp[0].Engage_Channel_Opportunity__c = false;
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        
        update listOpp;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityTeamMember otmnew = new OpportunityTeamMember(UserId = usr.Id, 
                                                                 OpportunityId = listOpp[0].Id, 
                                                                 TeamMemberRole = 'Reseller Contact');
        insert otmnew;
        system.assertEquals(otmnew.OpportunityId, listOpp[0].Id);
    }
    
    static testMethod void testpartneruseremailafterApprovaldefault(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[select id,recordtypeId from account];
        listAcc[0].Is_GTM_Partner__c = true;
        listAcc[0].IsPartner = true;
        listAcc[1].recordtypeId=TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc[1].Account_Country__c = 'UNITED STATES';
        listAcc[1].Tax_Registration_Number__c = '124214';
        listAcc[1].ShippingStreet = '12';
        listAcc[1].ShippingCity = 'testStreet';
        listAcc[1].ShippingState = 'testTexas';
        listAcc[1].ShippingPostalCode = '1324';
        update listAcc;
        
        Contact con = new Contact(AccountId = listAcc[0].Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',phone='2345',mobilephone='3442',Eloqua_ID__c='234');
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        string strproid = [SELECT id from profile WHERE Name LIKE '%EC-EMEA PRM%' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User usr = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'vi',
                            LocaleSidKey = 'vi',LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert usr;
        
        string strcountryCode = 'US';
        string strlanguageCode = 'ja';
        String strs = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';
        listOpp=[select id from Opportunity limit 1];
        listOpp[0].AccountID=listAcc[1].id;
        
        listOpp[0].Submission_Status_2__c = strs;
        listOpp[0].Submission_Status_3__c = strs;
        listOpp[0].Engage_Channel_Opportunity__c = false;
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        
        update listOpp;      
        
        TriggerExecutionController.setSkipAllTriggers(false);
        OpportunityTeamMember otmnew = new OpportunityTeamMember(UserId = usr.Id, 
                                                                 OpportunityId = listOpp[0].Id, 
                                                                 TeamMemberRole = 'Reseller Contact');
        insert otmnew;
        system.assertEquals(otmnew.OpportunityId, listOpp[0].Id);
    }
    
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
}
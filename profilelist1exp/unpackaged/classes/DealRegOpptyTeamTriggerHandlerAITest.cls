@isTest
public class DealRegOpptyTeamTriggerHandlerAITest {
    static Account acc;
    static Account partnerAcc;
    static Opportunity opp;
    static Opportunity opp1;
    
    static User u;
    static OpportunityTeamMember otm;
    static OpportunityTeamMember otm1;
    
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
    }
    
    static void createTestData() {
         String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityTeamMember", "Class_Name__c": "DealRegOpptyTeamTriggerHandlerAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityTeamMember';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipUserTriggers(true);
        
        
        Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
               
        acc = new Account(name='TEST',recordtypeid=acRecTypeId);         
        insert acc;
        Contact testContact = new Contact(FirstName='first', LastName='last', Phone='044223667788',
                                                Email='s@s.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                                Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                                AccountId=acc.Id,MobilePhone = '9030587363');
       
                                                   
                          
            insert testContact;
         
         Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity',CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
        
        opp1 = new Opportunity(accountId=acc.id,
            name='TestOpp',
            Type='Deal/Bid - Direct',
            Deal_Registration_Status__c= 'Approved',
            Solution_Type__c='Business Processing',
            Tier_1_Approved_Rejected__c = System.now().addhours(1),            
            StageName='Plan - 1%',            
            CloseDate=System.Date.TODAY());
         insert opp1;

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
        
        otm = new OpportunityTeamMember(UserId = u.Id, 
                OpportunityId = opp.Id, 
                TeamMemberRole = 'DM Sales Specialist');
        insert otm;
        
        otm1 = new OpportunityTeamMember(UserId = u.Id, 
                OpportunityId = opp1.Id, 
                TeamMemberRole = 'DM Solutions Engineer'); 
                insert otm1;
        
        OpportunityShare oppS0 = new OpportunityShare();
            oppS0.OpportunityId = opp.Id;
            oppS0.UserOrGroupId = u.Id;
            oppS0.OpportunityAccessLevel = 'Edit';
        insert oppS0;    
                
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipUserTriggers(false);

        system.assertEquals(2, Limits.getEmailInvocations());
        
    }
    
        
    static testMethod void testpartneruseremailafterApproval(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipUserTriggers(true);
         String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityTeamMember", "Class_Name__c": "DealRegOpptyTeamTriggerHandlerAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityTeamMember';
        tec.RecursiveCount__c = 4;
        insert tec;
        
        //2.0
        //User usr = createPartnerUser(); 
        string straccountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'PARTNER ACCOUNT'][0].Id;
        partnerAcc = new Account(Name = 'Partner Account', 
                                  Is_GTM_Partner__c = true, RecordTypeId = straccountRTId);
        insert partnerAcc;
        partnerAcc.IsPartner = true;
        Update partnerAcc;
        
        //Create partner contact
        Contact con = new Contact(AccountId = partnerAcc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',phone='2345',mobilephone='3442');
        insert con;
        
        //Create partner user
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        string strproid = [SELECT id from profile WHERE Name LIKE '%EC-EMEA PRM%' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User usr = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'fr',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'fr', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert usr;
        
        
        // 2.0 end
        //Create end user accountId
        Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
               
        Account acc1 = new Account(name='TEST',recordtypeid=acRecTypeId);         
        insert acc1;
        //Create Opportunity
        Opportunity oppnew = new Opportunity(accountId=acc1.id,
            name='TestOpp',
            Type='Deal/Bid - Direct',
            Deal_Registration_Status__c= 'Approved',
            Solution_Type__c='Business Processing',
            StageName='Plan - 1%',            
            CloseDate=System.Date.TODAY());
         insert oppnew ;
        //Add this partneruser as opportunityteammember
        
        OpportunityTeamMember otmnew = new OpportunityTeamMember(UserId = usr.Id, 
                OpportunityId = oppnew.Id, 
                TeamMemberRole = 'Reseller Contact');
        insert otmnew;

        system.assertEquals(1, Limits.getEmailInvocations());
    }
    
    static testMethod void testpartneruseremailafterApprovalmorocco(){
            String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityTeamMember", "Class_Name__c": "DealRegOpptyTeamTriggerHandlerAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityTeamMember';
        tec.RecursiveCount__c = 4;
        insert tec;
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipUserTriggers(true);
        //User usr = createPartnerUser(); 
        string straccountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'PARTNER ACCOUNT'][0].Id;
        partnerAcc = new Account(Name = 'Partner Account', 
                                  Is_GTM_Partner__c = true, RecordTypeId = straccountRTId);
        insert partnerAcc;
        partnerAcc.IsPartner = true;
        Update partnerAcc;
        
        //Create partner contact
        Contact con = new Contact(AccountId = partnerAcc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',phone='2345',mobilephone='3442');
        insert con;
        
        //Create partner user
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        string strproid = [SELECT id from profile WHERE Name LIKE '%EC-EMEA PRM%' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User usr = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'fr',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'fr', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert usr;
        //Create end user accountId
        Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
               
        Account acc1 = new Account(name='TEST',recordtypeid=acRecTypeId);         
        insert acc1;
        //Create Opportunity
        Opportunity oppnew = new Opportunity(accountId=acc1.id,
            name='TestOpp',
            Type='Deal/Bid - Direct',
            Deal_Registration_Status__c= 'Approved',
            Solution_Type__c='Business Processing',
            StageName='Plan - 1%',            
            CloseDate=System.Date.TODAY());
         insert oppnew ;
        //Add this partneruser as opportunityteammember
        
        OpportunityTeamMember otmnew = new OpportunityTeamMember(UserId = usr.Id, 
                OpportunityId = oppnew.Id, 
                TeamMemberRole = 'Reseller Contact');
        insert otmnew;

        system.assertEquals(1, Limits.getEmailInvocations());
    }
    
    static testMethod void testpartneruseremailafterApprovaldefault(){
            String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityTeamMember", "Class_Name__c": "DealRegOpptyTeamTriggerHandlerAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityTeamMember';
        tec.RecursiveCount__c = 4;
        insert tec;
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipUserTriggers(true);
        //User usr = createPartnerUser(); 
        string straccountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'PARTNER ACCOUNT'][0].Id;
        partnerAcc = new Account(Name = 'Partner Account', 
                                  Is_GTM_Partner__c = true, RecordTypeId = straccountRTId);
        insert partnerAcc;
        partnerAcc.IsPartner = true;
        Update partnerAcc;
        
        //Create partner contact
        Contact con = new Contact(AccountId = partnerAcc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',phone='2345',mobilephone='3442');
        insert con;
        
        //Create partner user
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        string strproid = [SELECT id from profile WHERE Name LIKE '%EC-EMEA PRM%' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User usr = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert usr;
        //Create end user accountId
        Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
               
        Account acc1 = new Account(name='TEST',recordtypeid=acRecTypeId);         
        insert acc1;
        //Create Opportunity
        Opportunity oppnew = new Opportunity(accountId=acc1.id,
            name='TestOpp',
            Type='Deal/Bid - Direct',
            Deal_Registration_Status__c= 'Approved',
            Solution_Type__c='Business Processing',
            StageName='Plan - 1%',            
            CloseDate=System.Date.TODAY());
         insert oppnew ;
        //Add this partneruser as opportunityteammember
        
        OpportunityTeamMember otmnew = new OpportunityTeamMember(UserId = usr.Id, 
                OpportunityId = oppnew.Id, 
                TeamMemberRole = 'Reseller Contact');
        insert otmnew;

        system.assertEquals(1, Limits.getEmailInvocations());
    }
    
    private static User createPartnerUser(){
        //Create partner Account
        string straccountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'PARTNER ACCOUNT'][0].Id;
        partnerAcc = new Account(Name = 'Partner Account', 
                                  Is_GTM_Partner__c = true, RecordTypeId = straccountRTId);
        insert partnerAcc;
        partnerAcc.IsPartner = true;
        Update partnerAcc;
        
        //Create partner contact
        Contact con = new Contact(AccountId = partnerAcc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',phone='2345',mobilephone='3442');
        insert con;
        
        //Create partner user
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User usr = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'en_US',
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert usr;
        return usr;
    }
     private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
}
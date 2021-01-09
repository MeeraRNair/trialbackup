@isTest
public class OpptyTeamTriggerHandlerADTest {
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
    
    static testMethod void deleteOTM() {
        
        String strMockMetaData = '';
        
        Map<String, string> mapEvents = new Map<String, string> {
            'AfterInsert' => 'OpptyTeamTriggerHandlerAI',
            'AfterDelete' => 'OpptyTeamTriggerHandlerAD'
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityTeamMember", "Class_Name__c": "' + mapEvents.get(strEvent) + '"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityTeamMember';
        tec.RecursiveCount__c = 4;
        insert tec;
        
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
        
        List<OpportunityTeamMember> listOTM = new List<OpportunityTeamMember>();
        
        otm = new OpportunityTeamMember(UserId = u.Id, 
                                        OpportunityId = opp.Id, 
                                        TeamMemberRole = 'DM Sales Specialist');
        listOTM.add(otm);       
        otm1 = new OpportunityTeamMember(UserId = u.Id, 
                                         OpportunityId = opp1.Id, 
                                         TeamMemberRole = 'DM Solutions Engineer');         
        listOTM.add(otm1);
        insert listOTM;
     
        delete listOTM;
 
        List<OTM_History__c> listOTMHistory = [SELECT Action__c, OTM_Removed_By__c FROM OTM_History__c WHERE OTM_SFDC_ID__c IN (:otm.Id, :otm1.Id)];
        system.assertEquals(2, listOTMHistory.size());
        for(OTM_History__c otmHistory : listOTMHistory){
            system.assertEquals('Removed', otmHistory.Action__c);
            system.assertEquals(UserInfo.getName(), otmHistory.OTM_Removed_By__c);
        }
       
    }
}
/*        
* Revision Ref Number         Release No  Date            Modified By                 Description
* -------- ----------         ----------  -----------     ------------                -----------
* 1.0      N/A                N/A         N/A             N/A                         N/A 
* 2.0      STORY 5907651      FY20-0202   10-12-2018      Haribabu.A                  Removed reference for the fields lob_registration_id__c and direct_account_name__c
* 3.0      CR 16970           FY20-0202   08-01-2019      Emily                       Removed virtualization__c
*                                         26-Sep-2018     Venugopalachary k           Implement Test Data Factory                                
*/
@isTest(seealldata = false)
public class EngageChannelAutoApprovalTest {
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
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
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(3, 'Partner Account');
        insert listAccfromFactory;
        List<Opportunity> listOppFromFactory=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        insert listOppFromFactory;
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItemTdf[0].OpportunityId=listOppFromFactory[0].id;
        insert listOppLineItemTdf;
    }   
    private static testMethod void testSubmission() {
        string strcountryCode = 'US';
        string strlanguageCode = 'ja';
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        listAcc=[select id from Account];
        listAcc[2].RecordTypeID=getRecordTypeIdbyName('End-User Account','Account');
        update listAcc;
        User u = createPartnerUser(listAcc[0],'en_US' );
        listOpp=[select id from Opportunity];
        listOpp[0].AccountID=listAcc[2].Id;
        update listOpp;
        EngageChannelAutoApprovalCtrl controller = new EngageChannelAutoApprovalCtrl();
        listOpp[0].AccountId = listAcc[0].Id;
        listOpp[0].Engage_Channel_Opportunity__c=true;
        system.assertNotEquals(listOpp[0].id, null);
        TriggerExecutionController.setSkipAllTriggers(true);
        update listOpp;
        list<OpportunityLineItem> listOppLineItem=[Select id from OpportunityLineItem Limit 1];
        Test.stopTest();
        controller.setMessage('Approved Auto');
        if (listOpp[0].Engage_Channel_Opportunity__c == TRUE) {
            controller.AutoApprove(listOpp[0].id);
        }
        controller.autoApprovalProcess(controller.result); 
    } 
    private static User createPartnerUser( account acc,string struserLanguageCode) {
        Contact con = new Contact(AccountId = acc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT');
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%NA PRM Portal%'
                     LIMIT 1
                    ];
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)'
                           ORDER BY Name DESC NULLS LAST LIMIT 1
                          ][0].Id; // Ver 1.0
        User u = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = struserLanguageCode,
                          LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                          EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        TriggerExecutionController.setSkipUserTriggers(true);
        insert u;
        system.debug('**********8'+u);
        return u;
    }
    private static string getUniqueString() {
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
    private static string getFirstPicklistValue(Schema.DescribeFieldResult field) {
        string strvalue = null;
        List < Schema.Picklistentry > listpick = field.getPicklistValues();
        for (Schema.Picklistentry pickListValue: listpick) {
            strvalue = pickListValue.getValue();
            break;
        }
        return strvalue;
    }  
    public static Id getRecordTypeIdbyName(String strRecordTypeName,String strobjectName){
        return  Schema.getGlobalDescribe().get(strobjectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
}
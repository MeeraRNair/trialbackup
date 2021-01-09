/***********************************************************
* Revision       Release                   Name           Date                  Description   
* 1.0            0202                      Vikas KH       08-Dec-2019           Impelemented TDF
***************************************************************/
@IsTest
public class CampaignMemberTriggerHandlerAUTest {
    static list<Account> listAcc;
    Static list<Campaign> listCamp;
    @TestSetup
    static void dataSetup(){
        Campaign_Member_Field_Tracking__c tracking = new Campaign_Member_Field_Tracking__c();
        tracking.Name = 'CM_Status__c';
        tracking.Type__c = 'Picklist';
        insert tracking;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampTDF;
        
    }
    static testmethod void campaignMemberUpdateTest(){
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "CampaignMember", "Class_Name__c": "CampaignMemberTriggerHandlerAU"},';
            }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'CampaignMember';
        tec.RecursiveCount__c = 2;
        insert tec;
        // Account acc = new Account(Name = 'Testacc');
        // insert acc;
        listAcc = [select id from Account limit 1];             
        Contact con = new Contact();
        con.AccountId = listAcc[0].Id;
        con.Email = 'test@test.com';
        con.phone = '6739';
        con.LastName = 'conLastName';
        con.FirstName = 'conFirstName';
        con.Status__c = 'Customer';
        con.Email_Opt_In__c = 'yes';
        con.Survey__c = 'yes';
        insert con;
        /*        Id campaign2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); 
Campaign camp1 = new Campaign();
camp1.Name = 'TestCampaign';
camp1.CurrencyIsoCode = 'USD';
camp1.RecordTypeId = campaign2RTId;
camp1.IsActive = true;
insert camp1;*/
        listCamp = [select id from Campaign limit 1];
        for(Campaign camp1 : listCamp){
            camp1.Name = 'TestCampaign';
            camp1.CurrencyIsoCode = 'USD';
            camp1.IsActive = true;
            camp1.Is_this_Account_Play_Campaign__c = False;
        }
        update listCamp;
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        Lead lead = new Lead();
        lead.FirstName = 'Direct';
        lead.LastName = 'Lead_Test' ;
        lead.Email = '123456@test.com';
        lead.Phone = '123456789';
        lead.LeadSource = 'Web';
        lead.Company = 'Dell Internal';
        lead.Lead_Type__c = 'Inbound';
        lead.Country = 'India';
        lead.Country_Code__c = 'IN';
        lead.Status = 'New'; //v5.0
        lead.RecordTypeId = directLead2RTId;
        lead.Campaign__c = listCamp[0].Id;
        Insert lead;
        //Campaign c = [Select Id,Name From Campaign where Name = 'TestCampaign'];
        CampaignMember cm = new CampaignMember(
            CampaignId = listCamp[0].Id,
            Status = 'Sent',
            ContactId = con.Id,
            LeadId = lead.Id,
            CM_Status__c = 'Accepted');
        insert cm;
        CampaignMember cm1 = [Select Id,CampaignId,Status From CampaignMember Where Id = :cm.Id];
        cm1.CM_Status__c='Responded';
        update cm1;
        Campaign_Member_Field_History__c history = [SELECT Field_Name_API__c, Old_Value__c, New_Value__c FROM Campaign_Member_Field_History__c WHERE Record_Id__c = :cm.Id];
        system.assertEquals('CM_Status__c', history.Field_Name_API__c);
        system.assertEquals('Accepted', history.Old_Value__c);
        system.assertEquals('Responded', history.New_Value__c);
    }
}
/*
* Author   : Gan
* Purpose  : Test on Helper class for associating Lead2.0 to existing Opportunity
* 
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0       13282       FY17-DCS-0801   22-Jun-2016     Gan             Added methods to invoke for conversion linked with existing oppty                                           
* 1.1      13309        FY17-DCS-0801   06-Jul-2016     Gan             Test coverage for small deal + opportunity handling after created
* 1.2                   0102            04-Dec-2019     VIKAS KH        Implemented TDF
*/

@isTest
public class Lead2OpptyAssnUtilsTest {
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
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
    } 
    static testMethod void testinsertContactRolesAndSetPrimaryInfluence() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Integer inttotalCount = 0;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;         
        ContactTestData.iNumberOfContacts = 2;
        ContactTestData.createContact();
        list<Contact> listContacts = ContactTestData.lstContacts;              
        listContacts[0].Accountid = listAccTDF[0].id;
        listContacts[1].Accountid = listAccTDF[0].id;
        update listContacts;
        CampaignTestData.bCreate = true;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        LeadTestData.bCreate = true;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        List<Opportunity> listCampaignTestOppty = new List<Opportunity>();
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Small Deal Marketing');
        listOppTDF[0].Account = listAccTDF[0];
        listCampaignTestOppty.add(listOppTDF[0]);
        insert listCampaignTestOppty;
        listCampaignTestOppty = [select id,AccountID,StageName,RecordTypeId,Isclosed from Opportunity limit 1];
        Map<String, String> mapOpptyToCampaign = new Map<String, String>();
        for(Opportunity oppty : listCampaignTestOppty) {
            mapOpptyToCampaign.put(oppty.Id, listCampaigns[0].Id); 
        } 
        update listCampaignTestOppty;
        Map<Id, List<Id>> maplistOppIdToConId = new map <id, List<id>>{listCampaignTestOppty[0].id => new List<id> {listContacts[0].id}};
            Lead2OpptyAssnUtils.insertOpportunityContactRole(maplistOppIdToConId);
        Test.startTest();
        maplistOppIdToConId = new map <id, List<id>>{listCampaignTestOppty[0].id => new List<id> {listContacts[1].id}};
            Lead2OpptyAssnUtils.insertOpportunityContactRole(maplistOppIdToConId);
        Lead2OpptyAssnUtils.setPrimaryCampaignInfluence(mapOpptyToCampaign);    
        inttotalCount = [SELECT count() FROM OpportunityContactRole WHERE OpportunityId = :listCampaignTestOppty[0].id AND contactID = :listContacts[1].id];
        System.assert(inttotalCount == 1);       
        for(Opportunity oppty : [SELECT Id, CampaignId FROM Opportunity WHERE Id IN :listCampaignTestOppty]) {
            System.assert(oppty.CampaignId == listCampaigns[0].Id);        
        }
        Lead2OpptyAssnUtils.linkedOpptyWithLead(new map<string, string>{listLeads[0].id => listCampaignTestOppty[0].id});
        Lead leadToCheck = [SELECT Id, linked_opportunity__c from lead where id = :listLeads[0].id];
        System.assert(leadToCheck.linked_opportunity__c == listCampaignTestOppty[0].id);  
        String strSmbRecordType = listCampaignTestOppty[0].RecordTypeID;
        Map<string, List<Id>> mapOpptyTypeOpptyId = new map<string, List<Id> >{'SmallDeal' => new List<Id> {listCampaignTestOppty[0].id}};                    
            Lead2OpptyAssnUtils.setupOpptyAfterConversion(mapOpptyTypeOpptyId);
        Opportunity opptyToCheck = [SELECT Id, recordtypeid from opportunity where id = :listCampaignTestOppty[0].id];
        System.assert(opptyToCheck.recordtypeid == strSmbRecordType);
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}
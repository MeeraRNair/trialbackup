/*
* Revision CR Number   Release No  	Date            Modified By    		  Description
* -------- ---------   ---------- 		-----------     ------------    	  -----------
* 1.0      CR 15625    FY19-DCE-0502   19-Apr-2018     Subramani Ramamurthy  Channel Lead Status Field
* 1.1      CR 15625    FY19-DCE-0502   04-May-2018     Shue                  DEFECT 5039288: Wunderkind :SDET: For Channel Lead partner status is not sync to lead status when lead status is Closed- worked.
*/
@isTest
public class CloseChannelUpdateLeadExtension_Test {
    public static Testmethod void TestUpdate(){
        
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        
        Lead objLead = new Lead();
        objLead.FirstName = 'testMethod';
        objLead.LastName = 'Test Lead';
        objLead.Email = '123456@test.com';
        objLead.Phone = '123456789';
        objLead.Status = 'Open';
        objLead.LeadSource = 'Web';
        objLead.Company = 'Dell Internal';
        objLead.Lead_Type__c = 'Inbound';
        objLead.RecordTypeId = directLead2RTId;
        objLead.Campaign__c = lstCampaigns[0].Id;   
        objLead.Country_Code__c='MY';
        TriggerExecutionController.setSkipLeadTriggers(true);
        insert objLead;
        TriggerExecutionController.setSkipLeadTriggers(true);        
        system.currentPageReference().getParameters().put('Id', objLead.Id);
        ApexPages.StandardController Controller = new ApexPages.StandardController(objLead);
        CloseChannelUpdateLeadExtension UpdateLeadExtension=new CloseChannelUpdateLeadExtension(Controller);
        
        UpdateLeadExtension.LeadChannelUpdate();
    }
    public static Testmethod void testNegativeStatusUpdate(){
        
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        
        Lead objLead = new Lead();
        objLead.FirstName = 'testMethod';
        objLead.LastName = 'Test Lead';
        objLead.Email = '123456@test.com';
        objLead.Phone = '123456789';
        objLead.Status = 'Closed - Worked';
        objLead.Partner_Lead_Status__c = 'Closed';
        objLead.LeadSource = 'Web';
        objLead.Company = 'Dell Internal';
        objLead.Lead_Type__c = 'Inbound';
        objLead.RecordTypeId = directLead2RTId;
        objLead.Campaign__c = lstCampaigns[0].Id;   
        objLead.Country_Code__c='MY';
        Test.startTest();
        TriggerExecutionController.setSkipLeadTriggers(true);
        insert objLead;
        TriggerExecutionController.setSkipLeadTriggers(true);
        
        system.currentPageReference().getParameters().put('Id', objLead.Id);
        ApexPages.StandardController Controller = new ApexPages.StandardController(objLead);
        CloseChannelUpdateLeadExtension UpdateLeadExtension=new CloseChannelUpdateLeadExtension(Controller);
        UpdateLeadExtension.LeadChannelUpdate();
        Test.stopTest();
    }
    
}
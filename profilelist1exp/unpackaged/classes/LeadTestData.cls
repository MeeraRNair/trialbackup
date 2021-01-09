/*
 * Author   : Ragu
 * Purpose  : Utility test class for creating Lead related data. 
 *
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11555       16.07           02-Jun-2015     Ragu            Created.
 * 2.0      13640       FY17-DCS-0103   01-Nov-2016     SuiYee          Adding Department field to Lead 2.0 and mapping with contact field
 * 3.0      14454       FY18-DCS-0802   19-Jul-2017     Azwanti        added System.runAs to avoid flow error 
 * 3.1      14599       FY18-DCS-0802   19-Jul-2017     Sajith         added mandatory field 'Marketing Primary Solution Interest'
 * 4.0      14893       FY18-DCS-1101   24-Sep-2017     Sajith         added mandatory field 'Country code' to Direct lead
 * 5.0      15341       FY19-DCS-0203   22-Dec-2017     Azwanti        replace Status from 'Open' to 'New'.
 * 6.0                  FY19-DCS-0802   27-Jul-2018     Gan            Fix the picklist value that cause failure in other test 
 */
 
@isTest
public class LeadTestData {

    public static boolean bCreate = true;
    public static integer iNumberOfLeads = 5;
    public static list<Lead> lstLeads;
    
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }
    
    public static testMethod void createDirectLead2() {
        CampaignTestData.bCreate = true;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        
        populateCommonLeadFields();
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        for(Lead leadIterator : lstLeads) {
            leadIterator.Status = 'New'; //v5.0
            leadIterator.RecordTypeId = directLead2RTId;
            leadIterator.Campaign__c = lstCampaigns[0].Id;
        }
        
        //v3.0
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];        
        if(bCreate) {
            System.runAs(adminusr) { //v3.0
                insert lstLeads;
            }
        }
    }
    
    public static testMethod void createChannelLead2() {
        CampaignTestData.bCreate = true;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        
        populateCommonLeadFields();
        Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
        for(Lead leadIterator : lstLeads) {
            leadIterator.Status = 'Open - Channel Lead';
            leadIterator.RecordTypeId = channelLead2RTId;
            leadIterator.Campaign__c = lstCampaigns[0].Id;
            leadIterator.Dell_Partner_can_contact_me__c = true;
            leadIterator.Country_Code__c = ''; //to stop invoking flow make it as blank 
                      
        }
        
        //v3.0
        
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];  
        if(bCreate) {
            System.runAs(adminusr){ //v3.0
                System.debug('######## lstLeads ' +lstLeads);
                insert lstLeads;
            }
        }
        
    }
    
    private static testMethod void populateCommonLeadFields() {
        lstLeads = new list<Lead>();
        //Country__c countryObj = [Select id,code__c,Is_Active_in_Affinity__c from Country__c where Is_Active_in_Affinity__c = true];
        for(integer i=0; i<iNumberOfLeads; i++) {
            Lead leadIterator = new Lead();
            leadIterator.FirstName = 'Direct';
            leadIterator.LastName = 'Lead_' + i;
            leadIterator.Email = '123456@test.com';
            leadIterator.Phone = '123456789';
            leadIterator.LeadSource = 'Web';
            leadIterator.Company = 'Dell Internal';
            leadIterator.Lead_Type__c = 'Inbound';
            leadIterator.Country = 'India';
            leadIterator.Marketing_Primary_Solution_Interest__c='Client Solutions';//3.1//6.0
            //leadIterator.Country_Code__c=countryObj.code__c;//4.0
            leadIterator.Country_Code__c='GB';//4.0
            leadIterator.Department__c = 'DepartmentYes';
            lstLeads.add(leadIterator);
        }
    }
    
}
/*
 * Author   : Prateek
 * Purpose  : Test class for test coverage of ChildRecordsExporter class
 *
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0             		16.07       	08-Jul-2015     Prateek         Created.
 * 2.0		CR 13091    FY17-DCS-0602   18-May-2016     Gan         	Create a new passed in parameter to hold the report name 
 * 3.0      CR 13598    FY17-DCS-0103   11-Oct-2016     Sajith          Fix hyperlinks from product map export
 * 4.0      CR 13972    FY18-DCS-0302   03-Feb-2017     Sajith          Fix for Phone field export
 */
 
@isTest
public class ChildRecordsExporter_Test
{    
    public static testMethod void TestMethod_1()
    {
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
        insert objLead;
        
        Expiring_Tag__c objET = new Expiring_Tag__c();
        objET.Customer_Name__c = 'Test Customer';
        objET.DOMS_Gii_Customer_Number__c = '12345';
        objET.DOMS_Gii_Order_Number__c = '234634';
        objET.Expiration__c = Date.Today().addDays(10);
        objET.Lead__c = objLead.Id;
        objET.LOB__c = 'Software';
        objET.Product__c = 'Test Product';
        objET.Revenue__c = 1000;
        objET.Shipping_City__c = 'Cyberjaya';
        insert objET;
        
        Export_Expiring_Tags_Config__c objEETC = new Export_Expiring_Tags_Config__c();
        objEETC.Name = 'Name';
        objEETC.API_Name__c = 'Name';
        objEETC.Include_in_File__c = true;
        objEETC.Order__c = 1;
        insert objEETC;
        
        //3.0
        Export_Expiring_Tags_Config__c objEETC2 = new Export_Expiring_Tags_Config__c();
        objEETC2.Name = 'Account';
        objEETC2.API_Name__c = 'Account__c';
        objEETC2.Include_in_File__c = true;
        objEETC2.Data_Type__c = 'Lookup';//4.0
        objEETC2.Lookup_Field__c= 'Account__r.Name';
        objEETC2.Order__c = 2;
        insert objEETC2;
        
        Export_Expiring_Tags_Config__c objEETC3 = new Export_Expiring_Tags_Config__c();
        objEETC3.Name = 'Lattice Play';
        objEETC3.API_Name__c = 'Lattice_Play__c';
        objEETC3.Include_in_File__c = true;
        objEETC3.Data_Type__c = 'Lookup';//4.0
        objEETC3.Order__c = 3;
        insert objEETC3;
        //3.0
        
        Test.setCurrentPage(Page.ChildRecordsExporter);
        ApexPages.currentPage().getParameters().put('csn', 'Export_Expiring_Tags_Config__c');
        ApexPages.currentPage().getParameters().put('on', 'Expiring_Tag__c');
        ApexPages.currentPage().getParameters().put('pri', objLead.Id);
        ApexPages.currentPage().getParameters().put('prf', 'Lead__c');
        
        ChildRecordsExporter objCRE = new ChildRecordsExporter();
        
        //2.0
        Test.setCurrentPage(Page.ChildRecordsExporter);
        ApexPages.currentPage().getParameters().put('csn', 'Export_Expiring_Tags_Config__c');
        ApexPages.currentPage().getParameters().put('on', 'Expiring_Tag__c');
        ApexPages.currentPage().getParameters().put('pri', objLead.Id);
        ApexPages.currentPage().getParameters().put('prf', 'Lead__c');
        ApexPages.currentPage().getParameters().put('fn', 'NewFileName');
        ChildRecordsExporter objCRE2 = new ChildRecordsExporter();
        
    }    
}
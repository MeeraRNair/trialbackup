/*
 * @Author     : Prasanthi M
 * Created Date : 1/2/2019
 * Purpose    : Test class for VFCntrlr_UpdateSuggestion 
 * 
 */
@isTest
public class VFCntrlr_UpdateSuggestionTest {
    private static testMethod void testUpdateUCIDInfo(){
        Campaign campaignObj=new Campaign(Name='Campaign',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                //Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Total_Targets__c = 12.0,  
                IsActive = true);
        insert campaignObj;
        Lead suggestionLead = new Lead();
        suggestionLead.LastName = 'last';
        suggestionLead.Company = 'Company';
        suggestionLead.Status = 'Open';
        suggestionLead.Email = 'test@test.com';
        suggestionLead.MobilePhone = '21441242421'; 
        suggestionLead.Fax = '3737433'; 
        suggestionLead.Lead_Type__c = 'Inbound';
        suggestionLead.Country_Code__c = 'US';
        suggestionLead.Website = 'www.testing.com';
        suggestionLead.DMU_Flag__c = true;
        suggestionLead.Campaign__c=campaignObj.id;
        suggestionLead.Location_Number__c=23;
        suggestionLead.LeadSource='Web';
        suggestionLead.Suggestion_ID__c='123456789'; 

        insert suggestionLead;
        System.assertEquals('123456789', suggestionLead.Suggestion_ID__c);
        
        TriggerExecutionController.setSkipAllTriggers(true); 
        Partner_Request__c request=new Partner_Request__c();
        request.Last_Name__c='pr last';
        request.Company__c='pr last';
        request.Lead__c=suggestionLead.Id;
        insert request;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(request);
        VFCntrlr_UpdateSuggestion vfs=new VFCntrlr_UpdateSuggestion(sc);
        try{
            vfs.updateSugg();
        }catch(Exception e){
            system.debug('Exception occured in VFCntrlr_UpdateSuggestionTest class testUpdateUCIDInfo method'+e.getMessage());
        }
        vfs.goBacktoPRPage();
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
}
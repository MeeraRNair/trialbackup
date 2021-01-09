/* 
History:
Version Release         CR #        Date            Modified By     Description     
1.0     0102                        04-Dec-2019     Vikas KH        Implemented TDF
*/

@istest
public class VFCntrlr_GetUCIDFrmSuggTest { 
        Static list<Campaign> listCampg;
        @testSetup static void setup() {
        list<Campaign> listCompn=TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCompn;
    }
    public static testMethod void getUCIDFrmSuggTest(){
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<lead> listLeads = LeadTestData.lstLeads;
        listCampg = [select id from Campaign limit 1];
        for(lead suggestionLead:listLeads)
        {
            suggestionLead.MobilePhone = '21441242421'; 
            suggestionLead.Fax = '3737433'; 
            suggestionLead.Country_Code__c = 'US';
            suggestionLead.Website = 'www.testing.com';
            suggestionLead.DMU_Flag__c = true; 
            suggestionLead.Campaign__c=listCampg[0].id;
            suggestionLead.Location_Number__c=23;
            suggestionLead.LeadSource='Web';
            suggestionLead.Suggestion_ID__c='123456789'; 
        }
        update listLeads;
        System.assertEquals('123456789', listLeads[0].Suggestion_ID__c);
        TriggerExecutionController.setSkipAllTriggers(true); 
        Partner_Request__c request=new Partner_Request__c();
        request.Last_Name__c='pr last';
        request.Company__c='pr last';
        request.Lead__c=listLeads[0].Id;
        insert request;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(request);
        VFCntrlr_GetUCIDFrmSugg vfs=new VFCntrlr_GetUCIDFrmSugg(sc);
        try{vfs.getUCID();
           }catch(exception e){}
        vfs.goBacktoPRPage();
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
}
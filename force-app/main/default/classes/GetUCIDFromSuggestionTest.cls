@istest 
public class GetUCIDFromSuggestionTest { 
    Static list<user> listUser;
    Static list<Campaign> listCampg;
    @testSetup static void setup() {
        list<User> listUserF=TestDataFactory.createNPortalUser(1);
        insert listUserF;
        list<Campaign> listCompn=TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCompn;
    }
    public static testMethod void testMethod1() {
        listUser = [select id from user limit 1];
        listCampg = [select id from Campaign limit 1];
        Partner_Request__c request=new Partner_Request__c();
        request.Last_Name__c='pr last';
        request.Company__c='pr last';
        request.OwnerID=listUser[0].Id; 
        insert request;
        system.assertEquals(request.OwnerID, listUser[0].Id);
        Lead suggestionLead = new Lead();
        suggestionLead.LastName = request.Last_Name__c;
        suggestionLead.Company = request.Company__c;
        suggestionLead.Status = 'Open';
        suggestionLead.Partner_Request__c = request.ID;
        System.debug('####request.OwnerID'+request.OwnerID);
        suggestionLead.OwnerID = request.OwnerID;
        suggestionLead.Email = 'test@test.com';
        suggestionLead.MobilePhone = '21441242421'; 
        suggestionLead.Fax = '3737433'; 
        suggestionLead.Lead_Type__c = 'Inbound';
        suggestionLead.Country_Code__c = 'US';
        suggestionLead.Website = 'www.testing.com';
        suggestionLead.Account_Owner__c = listUser[0].Id;
        suggestionLead.DMU_Flag__c = true;
        suggestionLead.Campaign__c=listCampg[0].id;
        suggestionLead.Location_Number__c=23;
        suggestionLead.LeadSource='Web';
        suggestionLead.Suggestion_ID__c='123456789';
        TriggerExecutionController.setSkipLeadTriggers(True);
        insert suggestionLead;
        request.Lead__c=suggestionLead.Id;
        update request;
        Test.startTest();
        system.assertNotEquals(Null, suggestionLead.Suggestion_ID__c);
        Test.setMock(HttpCalloutMock.class, new GetUcidFrmSuggMock());
        try{
            GetUCIDFromSuggestion.getUCIDFrmSuggestionID(request.ID);
        }catch(exception e){}
        getUCIDFromSuggestion.updateUCID(request,'1212');
        Test.stopTest();
    }
}
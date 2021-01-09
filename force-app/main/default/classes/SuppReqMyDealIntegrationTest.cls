/*
* Version   Date            Author     Release     CR#          Description
* -------   ----            ------     -------     ---          -----------
* 1.0       15-Sep-2016     Jaya       1007        US#2382050   Made SOAPAction 'getGSD_Request' name retrieve from custom label.
* 2.0       05-Feb-2018     Gan        0203        15372        Fixing existing validation error when insert oppty
*/

@isTest

private class SuppReqMyDealIntegrationTest {
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTDF[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    static testMethod void integrateMyDealTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        /*  Account acc = new Account(Name='testAccount'); 
insert acc;*/
        list<Account> listAcc=[select id from Account Limit 1];
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                                  MailingCountry='test',AccountId=listAcc[0].Id,Phone='12345');
        insert con;
        
        /* Opportunity oppty = new Opportunity(AccountId = acc.Id,
Name = 'testOpportunity',
RecordTypeId = '012300000004zf2AAA', 
CurrencyIsoCode = 'USD', 
Type = 'Renewal',
CloseDate = system.Today(),
Domain__c = 'Non Domain',
Solution_Type__c = 'Cloud Integration',
Solution_Name__c = 'Boomi Solution',
StageName = 'Plan - 1%',
Quest_Software_Contact__c= con.id, 
Forecast_Category_Override__c = 'Omitted'); //2.0
insert oppty;
*/
        
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        listOpp[0].Quest_Software_Contact__c= con.id;
        update listOpp;
        Test.startTest();
        String strcssRECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);
        Support_Request__c cssSR = new Support_Request__c(RecordTypeId = strcssRECORDTYPEID, Receive_Notification__c = 'Yes', Opportunity__c = listOpp[0].Id,
                                                          Requestor_Comments__c = 'testComment', Specialist_Role__c = 'testRole',Engagement_Time_Frame__c=Date.today(),
                                                          Support_Owner__c = UserInfo.getUserId(), Solution_Architect__c = 'Yes', Customer_Contact_InformationName__c = con.Id,
                                                          Support_Owner_Team_Role__c = 'Services Intake Manager',Status__c='New',Project_Type__c='CWS',Project_Duration_months__c =1,
                                                          Suggested_Delivery_Method__c='Custom',Decision_Date__c=Date.today(),Primary_Work_Delivery_Language__c='Spanish');
        insert cssSR;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Set<Id> setsuppReqIds = new Set<Id>(); 
        setsuppReqIds.add(cssSR.id);
        system.assertNotEquals(listOpp[0].id, null);
        SuppReqMyDealIntegration.integrateMyDeal(setsuppReqIds);
        
        Test.stopTest();
    }
}
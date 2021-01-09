/* 
History:
Version Release         CR #        Date            Modified By     Description     
1.0     0102                        04-Jan-2019     Vikas KH        Implemented TDF
*/

@isTest
public class VFCntrlr_SendPRDataToEMCTest {
    static list<Account> listAcc; 
    static Country__c testCountry;
    static Partner_Request__c request;
    static User userRecord;
    static boolean bTestDataCreated=false;
    static list<lead> listlead;
    static list<Campaign> listCamp;
    @testsetup static void setup() {
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;   
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<lead> listLeads = LeadTestData.lstLeads;
    }    
    public static testMethod void testSendPRDataToEMC() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        System.debug('#MN:START of testVFCntrlr_CreateSuggestionCtrlExt_navigateToLead_existingLead()');
        if(!bTestDataCreated){
            createPartnerRequest();
        }
        Test.startTest();
        listcamp = [select id from Campaign limit 1];
        listlead = [select id,RecordTypeID from lead limit 1 ];
        for(lead suggestionLead:listlead)
        {
            suggestionLead.MobilePhone = '21441242421'; 
            suggestionLead.Fax = '3737433'; 
            suggestionLead.Country_Code__c = 'US';
            suggestionLead.Website = 'www.testing.com';
            suggestionLead.DMU_Flag__c = true;
            suggestionLead.Campaign__c=listCamp[0].id;
            suggestionLead.Location_Number__c=23;
            suggestionLead.LeadSource='Web';
            suggestionLead.Suggestion_ID__c='123456789'; 
        }
        update listlead;
        system.assertEquals('123456789', listlead[0].Suggestion_ID__c);
        request.Lead__c = listlead[0].id;
        update request;
        PageReference pageRef = Page.CreateSuggestion;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', request.id);
        ApexPages.StandardController con = new ApexPages.StandardController(request);
        VFCntrlr_SendPRDataToEMC controller = new VFCntrlr_SendPRDataToEMC(con);
        controller.sendPRDataToEMC();
        controller.goBacktoPRPage();
    }
    private static void createPartnerRequest(){
        listAcc = [select id,name,Account_Country_Code__c,Account_Country__c,Type, IsPartner from Account];
        listAcc[0].name='PartnerAccount';
        listAcc[0].Account_Country_Code__c='AI';
        listAcc[0].Account_Country__c = 'ANGUILLA';
        listAcc[0].Type = 'Partner'; 
        listAcc[0].IsPartner = true;
        update listAcc;
        testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        userRecord = new User(
            Username='testUser'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test@dell.com', 
            FirstName='Tfirst', 
            LastName='TLast',
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345'
        );
        insert userRecord;
        listcamp = [select id from Campaign limit 1];
        listlead = [select id,RecordTypeID from lead limit 1 ];
        for(lead suggestionLead:listlead)
        {
            suggestionLead.DMU_Flag__c = true;
            suggestionLead.Campaign__c=listCamp[0].id;
            suggestionLead.LeadSource='Partner';
            suggestionLead.Suggestion_ID__c='123456789'; 
        }
        update listlead;
        request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id; 
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1'; 
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3'; 
        request.Org_City__c = 'city';
        request.Org_State__c = 'state';
        request.Org_Postal_Code__c = 'postalcode';      
        request.Address_Line_1__c = 'Address 1';
        request.Address_Line_2__c = 'Address 2';
        request.Address_Line_3__c = 'Address 3';
        request.City__c = 'city';
        request.State__c = 'state';
        request.Postal_Code__c = 'postalcode';
        request.Phone__c= 'phone';
        request.Fax__c= 'fax';
        request.Org_Fax__c= 'orgfax';
        request.Last_Name__c = 'Test Last Name';
        request.Country__c = testCountry.id;
        request.OwnerId = userRecord.Id;
        request.lead__c = listlead[0].Id;
        insert request;
        listAcc[0].Partner_Registration__c=request.id;
        update listAcc[0];
        bTestDataCreated = true;
        System.debug('##MN:Account :'+listAcc[0]);
        System.debug('##MN:request :'+request);
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
}
/* 
* Revision CR Number   Release No     Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
* 1.0       CR16018    FY19-DCS-0802  12.06.2018      Jatin           Commented NET exam logic statements as part of NET003 story
* 2.0                  0102           04.12.2019      VIKAS KH        Implemented TDF   
*/
@isTest
private class VFCntrlr_CreateSuggestionCtrlExtTest {
    static list<Account> listAcc;
    static list<lead> listlead;
    static list<Campaign> listCamp;
    static Country__c testCountry;
    static Partner_Request__c request;
    static User userRecord;
    static boolean btestDataCreated=false;
    @testsetup static void setup() {
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF; 
        campaignTestData.iNumberOfCampaigns = 1;
        campaignTestData.createCampaign2();
        list<Campaign> listCampaigns = CampaignTestData.lstCampaigns;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<lead> listLeads = LeadTestData.lstLeads;
    }    
    public static testMethod void testVFCntrlrCreateSuggestionCtrlExtnavigateToLeadexistingLead() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        System.debug('#MN:START of testVFCntrlrCreateSuggestionCtrlExtnavigateToLeadexistingLead()');
        if(btestDataCreated==false){createPartnerRequest();
                                    Test.startTest();
                                    listcamp = [select id from Campaign limit 1];
                                    listlead = [select id,RecordTypeID from lead limit 1 ];
                                    for(lead suggestionLead:listlead)
                                    {
                                        suggestionLead.LastName = request.Last_Name__c;
                                        suggestionLead.Company = request.Company__c;
                                        suggestionLead.Status = 'Open';
                                        suggestionLead.Partner_Request__c = request.ID;
                                        System.debug('####request.OwnerID'+request.OwnerID);
                                        suggestionLead.OwnerID = request.OwnerID;
                                        suggestionLead.MobilePhone = '21441242421'; 
                                        suggestionLead.Fax = '3737433'; 
                                        suggestionLead.Website = 'www.testing.com'; 
                                        suggestionLead.DMU_Flag__c = true;
                                        suggestionLead.Campaign__c=listCamp[0].id;
                                        suggestionLead.Suggestion_ID__c='123456789'; 
                                        suggestionlead.Account_Owner__c = userRecord.id;
                                    }
                                    update listlead;
                                    request.Lead__c = listlead[0].id;
                                    update request;
                                    system.assertEquals('123456789', listlead[0].Suggestion_ID__c);
                                    PageReference pageRef = Page.CreateSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    ApexPages.currentPage().getParameters().put('id', request.id);
                                    ApexPages.StandardController con = new ApexPages.StandardController(request);
                                    VFCntrlr_CreateSuggestionCtrlExt controller = new VFCntrlr_CreateSuggestionCtrlExt(con);
                                    String strretURLActual = controller.navigateToLead().getURL();
                                    String strurlTobeTested = '/'+listlead[0].Id+'/e?cancelURL='+PageUtils.encodeVariable(request.Id)
                                        +'&RecordType='+PageUtils.encodeVariable(listlead[0].id)
                                        +'&retURL='+PageUtils.encodeVariable(listlead[0].Id)
                                        +'&save_new_url='+PageUtils.encodeVariable(listlead[0].Id);
                                    System.debug('###retURL: '+strretURLActual); 
                                    Test.stopTest();
                                    System.debug('#MN:END of testVFCntrlrCreateSuggestionCtrlExtnavigateToLeadexistingLead()');
                                    TriggerExecutionController.setSkipAllTriggers(false); 
                                   }
    }
    private static void createPartnerRequest(){
        listAcc =[select id,name,Account_Country_Code__c, Account_ID__c from Account limit 1 ];
        listAcc[0].Account_Country_Code__c = 'AI';
        listAcc[0].Account_Country__c = 'ANGUILIA';            
        listAcc[0].Account_ID__c = '333333';
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
        insert request;
        ApexPages.StandardController con = new ApexPages.StandardController(request);
        VFCntrlr_CreateSuggestionCtrlExt controller = new VFCntrlr_CreateSuggestionCtrlExt(con);
        try{controller.navigateToLead();}catch(exception e){system.debug('Exception');}
        listAcc[0].IsPartner = true;
        listAcc[0].Partner_Registration__c=request.id;
        update listAcc[0];
        btestDataCreated = true;
        System.debug('##MN:Account :'+listAcc[0]);
        System.debug('##MN:request :'+request);
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
}
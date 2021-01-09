@isTest
public class ResellerAccForDistiCntrlTest {
    
    static list<Account> listAcc;
     @testSetup static void setup() {
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(2, 'Master Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
        list<User> listUserTdf=TestDataFactory.createNPortalUser(1);
        listUserTdf[0].Enable_Partner_Admin__c = false;
        listUserTdf[0].isActive=true;
        insert listUserTdf;
    }
    
    public static testmethod void createSolutionProviderPRs(){
            TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id from Account];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].BillingState='IL';
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        List<User> listusr = new List<User>();
        listusr = [SELECT Name,ContactId,Email FROM User WHERE LastName LIKE 'Version%' ];
        Partner_Request__c request = new Partner_Request__c();
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER,
                                                             'Partner_Request__c', true);
        request.Account__c = listAcc[0].id;
        request.Website__c = 'www.test1.com';
        request.First_Name__c = 'John';
        request.Last_Name__c = 'Doe';
        request.Contact__c = listusr[0].ContactId;
        request.Job_Title__c = 'VP';
        request.Address_Line_1__c = '123 Main St.';
        request.City__c = 'Peoria';
        request.State__c = 'IL';
        request.Postal_Code__c = '33333';
        request.Phone__c = '3213213211';
        request.Email__c = 'testrack@got.com';
        request.Country__c = country.id;
        request.Sponsoring_Distributor_Secondary_Email__c =listusr[0].Email;
        request.Primary_Channel_Model__c = 'Solution Provider (Reseller)';
        
        insert request;
        
        test.startTest();
        PageReference pageRef = Page.ResellerAccForDisti;
        Test.setCurrentPage(pageRef);
        ResellerAccForDistiCntrl.loadPRRecords(listusr[0].Email,20,0);
        ResellerAccForDistiCntrl.loadDistiRecords(listusr[0].Email,20,0);
        ResellerAccForDistiCntrl.findByName('testin',listusr[0].Email);
        test.stopTest();
    }
    
    private static Country__c buildMockCountry(Boolean bactivePartner){
        Country__c country = new Country__c();
        country.name = 'test';
        country.Is_Active_Partner_Country__c = bactivePartner;
        country.code__c = 'XX';
        List<Profile> listprofiles = [select id,name from Profile where UserType = 'PowerPartner' limit 1];
        System.assert(listprofiles.size()>0, 'Test cannot execute: no partner profiles exist');
        country.User_Time_Zone_Sid_Key__c = 'America/Chicago';
        country.User_Profile_ID__c = listprofiles.get(0).id;
        country.User_Locale_Sid_Key__c = 'en_US';
        country.User_Language_Locale_Key__c = 'en_US';
        country.User_Email_Encoding_Key__c = 'ISO-8859-1';
        country.User_Currency_Iso_Code__c = 'USD';
        country.Inc_Vendor_Name__c = 'Partner Advantage';
        country.Inc_Vendor_End_Point__c = 'test URL';
        country.Deal_Registration_Enabled__c = 'Yes';
        country.Lead_Management_Enabled__c = 'Yes';
        country.Lead_Management_Enabled_for_OEM__c = 'Yes';
        country.Partner_Relationship__c = 'All';
        country.Partner_Relationship_for_OEM__c = 'All';
        insert country;
        return country;
    }
}
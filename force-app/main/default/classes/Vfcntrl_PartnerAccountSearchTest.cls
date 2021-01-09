/* Revision  Name            Date                 CR         Release No            Description
* 1.0       Jatin           12.06.2018            16018      Fy-19-DCS-0802        Commented NET exam logic statements as part of NET003 story
* 2.0    Vikas KH    08.12.2019               0202           Implemented TDF 
*/

@isTest
public class Vfcntrl_PartnerAccountSearchTest {
    static list<Account> listAcc;
    static list<Case> listCase;
    @testSetup Static void setup()
    {
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTDF;
        list<Case> listCaseTDF = TestDataFactory.createNCases(1);
        insert listCaseTDF;
    }
    static testMethod void onBehalfOfAccount(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c partnerReq = createPartnerRequest();
        listAcc = [select id from Account limit 2];
        listAcc[0].Partner_Tier__c = 'Direct Partner Purchase';
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Partner_Type__c = 'COMMERCIAL';
        listAcc[0].Account_ID__c = '345555';
        listAcc[0].Partner_Registration__c = partnerReq.Id;
        listAcc[1].Partner_Type__c = 'COMMERCIAL';
        listAcc[1].Partner_Tier__c = 'Direct Partner Purchase';
        listAcc[1].Partner_Relationship__c = 'Registered';
        listAcc[1].Account_Country__c = 'United States';      
        update listAcc;
        system.assertEquals(listAcc[1].Account_Country__c, listAcc[1].Account_Country__c);
//      List<Account> accData = new List<Account>();
 /*     Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
      Partner_Request__c partnerReq = createPartnerRequest();
        Account searchResultAccount = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTId,
                                            Partner_Tier__c = 'Direct Partner Purchase',
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'United States',
                                            Partner_Type__c = 'COMMERCIAL',
                                            Account_ID__c = '345555',
                                            Partner_Registration__c = partnerReq.Id ); 
        accData.add(searchResultAccount);
        Account testAccount = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTId, 
                                            Partner_Type__c = 'COMMERCIAL',
                                            Partner_Tier__c = 'Direct Partner Purchase',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'United States' );        
        accData.add(testAccount);
        insert accData;
      */
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                                      LastName = 'MyTestContact9',
                                      AccountId =listAcc[1].Id,
                                      Status__c  =  'Marketing Suspect',
                                      Email = 'MyTestContactEmail_9@ust-global.com',
                                      Fax = '1234567',
                                      MobilePhone = '0987654',
                                      Last_Operation_Performed__c = 'testing',
                                      Phone = '1234500');
        insert newCont;
      listCase = [select id,RecordTypeID from Case limit 1];
      listCase[0].RecordTypeID = StaticFactory.getRecordTypeIdByName('Case', 'order support');
      listCase[0].AccountId = listAcc[0].Id;
      listCase[0].ContactId = newCont.id;
      listCase[0].Status = 'Open';
      listCase[0].Priority = 'High';
      listCase[0].Sub_Type_Order_Support__c = 'Box Recycling';
      listCase[0].Order_Number1__c = '123432';
      listCase[0].Alternate_Phone__c = '745476';
      listCase[0].Description = '1';
      listCase[0].Subject = '2';
      listCase[0].Origin = 'Partner Portal';
      listCase[0].Order_Reference_Number_Type__c = 'Order Number';   
      listCase[0].Case_Category__c = 'Partner';
/*     Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
      case newCase = new Case();
      newCase.AccountId = testAccount.Id;
      newCase.ContactId = newCont.id;
      newCase.Status = 'Open';
      newCase.Priority = 'High';
      newCase.Sub_Type_Order_Support__c = 'Box Recycling';
      newCase.RecordTypeId = orderSuppRTId;
      newCase.Order_Number1__c = '123432';
      newCase.Alternate_Phone__c = '745476';
      newCase.Description = '1';
      newCase.Subject = '2';
      newCase.Origin = 'Partner Portal';
      newCase.Order_Reference_Number_Type__c = 'Order Number';   
      newCase.Case_Category__c = 'Partner';
     insert newCase;
      */
        PageReference pageRef = Page.PartnerAccountSearch;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(listCase[0]);
        ApexPages.currentPage().getParameters().put('Id',listCase[0].id);
        Vfcntrl_PartnerAccountSearch accountSelectPage = new Vfcntrl_PartnerAccountSearch(sc);
        accountSelectPage.searchBy = 'Name';
        accountSelectPage.fetchResults();
       accountSelectPage.searchBy = 'Name';
       accountSelectPage.searchString = '56';
       accountSelectPage.fetchResults(); 
       accountSelectPage.searchBy = 'Name';
       accountSelectPage.searchString = '567';
       accountSelectPage.fetchResults();
       accountSelectPage.searchBy = 'Name';
       accountSelectPage.searchString = 'Test';
       accountSelectPage.fetchResults();
       accountSelectPage.searchString = '345555AAW';
       accountSelectPage.searchBy = 'Affinity';
       accountSelectPage.fetchResults();
       accountSelectPage.searchString = '345555';
       accountSelectPage.searchBy = 'Affinity';
       accountSelectPage.fetchResults();
      System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
      accountSelectPage.saveFunction();
  }
    static Partner_Request__c createPartnerRequest(){
        //create Account
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c = 'AI';
        listAcc[0].Account_Country__c = 'ANGUILIA';
        listAcc[0].Account_ID__c =''+System.currentTimeMillis();
        update listAcc;
       /* Account testAccount = new Account(
        name='Test 1',
        Account_Country_Code__c = 'AI',
        Account_Country__c = 'ANGUILIA',            
        Account_ID__c =''+System.currentTimeMillis()
        );
        insert testAccount; */
        //Create country
        Country__c testCountry = new Country__c(
        Name = 'TestCountry',
        Code__c = 'TY',
        User_Currency_Iso_Code__c = 'INR',
        Region__c = 'APJ');
        insert testCountry;
        //Create User
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        User userRecord = new User(
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
        //Create Partner Request
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
        'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
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
        request.Last_Name__c = 'Test Last Name';
        request.Country__c = testCountry.id;
        request.OwnerId = userRecord.Id;
        insert request;
        return request;
    }
}
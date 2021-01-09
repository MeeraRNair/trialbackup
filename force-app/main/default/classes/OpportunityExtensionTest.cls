/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
* 
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
* 1.0  Meenu  08.01.2019 FY20-DCE-0202 16970 Field Trip clean up for Opportunity (Remove/Comment    class_logged_or_notes_entered__c,close_date_updated__c,
*                        next_steps_updated__c,update_to_justification_statement__c fields)
*/
@istest
public class OpportunityExtensionTest {
    static ApexPages.StandardController controllerObject;
    static OpportunityRenewalExtension testedObject;
    static boolean btestDataIsNotCreated = true;
    static Country__c testCountryObject;
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(3, 'Partner Account');
        for(Account acc : listAccTdf){
            acc.Account_Country__c = 'Jedi Country';
        }
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(5, 'Standard Opportunity');
        for(Opportunity op : listOppTdf){
            op.Deal_Expiration_Timeframe__c = '120';
            op.Deal_Expiration_Date__c = System.Now().Date().addDays(10);
            op.Stage_Updated__c=false;
            op.Request_Status__c = 'New';
            op.Deal_Created_Date_Time__c = System.Now();
        }
        insert listOppTdf;
    }
    static testMethod void prepareTestData() {
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        if (btestDataIsNotCreated) {
            testCountryObject = new Country__c(name = 'Jedi Country', 
                                               Dell_Online_Country_Code__c = 'US',
                                               code__c='USS', 
                                               Enabled_Auto_Renewal__c = True, 
                                               Last_Operation_Performed__c = 'Test Data');
            insert testCountryObject;
            listAcc=[SELECT ID FROM Account LIMIT 1];
            listAcc[0].Account_Country_Code__c = 'US';
            update listAcc;
            listOpp=[SELECT ID FROM Opportunity LIMIT 2];
            listOpp[0].AccountId=listAcc[0].id;
            listOpp[1].AccountId=listAcc[0].id;
            listOpp[1].Related_Parent_Opportunity__c=listOpp[0].id;
            update listOpp;
            controllerObject = new ApexPages.StandardController(listOpp[0]);
            testedObject = new OpportunityRenewalExtension(controllerObject);
            system.assertNotEquals(listOpp[0].id, null);
            btestDataIsNotCreated = false;
            Test.stopTest();
        }
    }
    static testMethod void buttonReturnToPreviousPagePreviousPageEmptyTest() {
        PrepareTestData();
        PageReference actualPageRef = testedObject.ButtonReturnToPreviousPage();
        System.assert(actualPageRef.getUrl().Contains('/006/o'));
    }
    static testMethod void buttonReturnToPreviousPageReturnToDetailPageTest() {
        PrepareTestData();
        testedObject.previousPage = 'https://Host/' + listOpp[0].Id;
        PageReference currentPage = new PageReference('apex/RenewOpportunity?Id=' + listOpp[0].Id);
        Test.setCurrentPage(currentPage);
        PageReference actualPageRef = testedObject.ButtonReturnToPreviousPage();
        System.Debug('OpportunityID' + listOpp[0].Id);
        System.Debug('URL Return' + actualPageRef.getUrl());
        System.assert(actualPageRef.getUrl().Contains('/006')); //006 for prefix for opportunity ID
    }
    static testMethod void regionCodeTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        List < Country__c > listc = new List < Country__c > ();
        listc.add(new Country__c(Region__c = 'NA', name = 'Jedi Country', Dell_Online_Country_Code__c = 'US', Code__c = 'UST', Enabled_Auto_Renewal__c = True, Last_Operation_Performed__c = 'Test Data'));
        listc.add(new Country__c(Region__c = 'LATAM', name = 'Jedi Country', Dell_Online_Country_Code__c = 'CA', Code__c = 'CAT', Enabled_Auto_Renewal__c = True, Last_Operation_Performed__c = 'Test Data'));
        listc.add(new Country__c(Region__c = 'EMEA', name = 'Jedi Country1', Dell_Online_Country_Code__c = 'ZY', Code__c = 'ZYT', Enabled_Auto_Renewal__c = False, Last_Operation_Performed__c = 'Test Data'));
        insert listc;
        listAcc=[SELECT ID FROM Account Limit 3];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[1].Account_Country_Code__c = 'CA';
        listAcc[2].Account_Country_Code__c = 'ZY';
        update listAcc;
        listOpp=[SELECT ID,Request_Status__c FROM Opportunity lIMIT 5];
        listOpp[0].AccountID=listAcc[0].ID;
        listOpp[0].CloseDate = System.Now().Date().addDays(10);
        listOpp[0].Deal_Expiration_Date__c = System.Now().Date().addDays(10);
        listOpp[1].AccountID = listAcc[1].ID;
        listOpp[1].CloseDate = System.Now().Date().addDays(10);
        listOpp[1].Deal_Expiration_Date__c = System.Now().Date().addDays(10);
        listOpp[2].Related_Parent_Opportunity__c = listOpp[0].ID;
        listOpp[2].AccountID = listAcc[1].ID;
        listOpp[2].CloseDate = System.Now().Date().addDays(180);
        listOpp[2].Deal_Expiration_Date__c = System.Now().Date().addDays(10);
        listOpp[3].Related_Parent_Opportunity__c = listOpp[0].ID;
        listOpp[3].CloseDate = System.Now().Date().addDays(180);
        listOpp[3].Deal_Expiration_Date__c = System.Now().Date().addDays(10);
        listOpp[4].Related_Parent_Opportunity__c = listOpp[0].ID;
        listOpp[4].AccountID = listAcc[2].ID;
        listOpp[4].CloseDate = System.Now().Date().addDays(+1);
        listOpp[4].Deal_Expiration_Date__c = System.Now().Date().addDays(10);
        for(Opportunity opp : listOpp){
            opp.StageName = 'Discover - 10%';
            opp.Forecast_Category_Override__c = 'Omitted';
            opp.Deal_Expiration_Timeframe__c = '120';
            opp.Domain__c = 'Deal Reg';
            opp.Stage_Updated__c = false;
            opp.End_User_Email__c = 'ariff_bahar@dell.com';
            opp.Name = 'TestOpportunity';
            opp.Request_Status__c = 'New';
            opp.Deal_Created_Date_Time__c = System.Now();
        }
        update listOpp;
        controllerObject = new ApexPages.StandardController(listOpp[1]);
        testedObject = new OpportunityRenewalExtension(controllerObject);
        testedObject.previousPage = 'https://Host/' + listOpp[1].Id;
        PageReference currentPage = new PageReference('apex/RenewOpportunity?Id=' + listOpp[1].Id);
        Test.setCurrentPage(currentPage);
        testedObject.isPartnerUser = true;
        testedObject.SetPermissionRenewOpportunityPage();
        testedObject.isPartnerUser = false;
        testedObject.SetPermissionRenewOpportunityPage();
        testedObject.isAvailableForAccess = True;
        testedObject.opportunitySubmitted = false;
        Opportunity opp123 = new opportunity(Id = listOpp[1].Id, 
                                             Is_close_date_changed__c = true, 
                                             Related_Parent_Opportunity__c = listOpp[0].ID,
                                             stage_Updated__c = true,
                                             Partner_Opportunity_Stage__c = 'Discover - 10%',
                                             Submitter_Profile__c = 'na prm');
        Database.SaveResult results = Database.update(opp123,false);
        testedObject.isPartnerUser = true;
        Test.stopTest();
        testedObject.isPartnerUser = false;
        PageReference actualPageRef = testedObject.SubmitAutoRenewal();
        listOpp[1].CloseDate = System.Now().Date().addDays(+1);
        Opportunity opp1234 =  new opportunity(Id = listOpp[1].Id, 
                                               CloseDate = System.Now().Date().addDays(+1),
                                               Request_Status__c = 'New', 
                                               Deal_Expiration_Date__c = System.Now().Date().addDays(11));
        Database.SaveResult results12 = Database.update(opp1234,false);        
        testedObject.SubmitAutoRenewal();
        ApexPages.StandardController controllerObject1 = new ApexPages.StandardController(listOpp[2]);
        OpportunityRenewalExtension testedObject1 = new OpportunityRenewalExtension(controllerObject1);
        testedObject1.previousPage = 'https://Host/' + listOpp[2].Id;
        PageReference currentPage1 = new PageReference('apex/RenewOpportunity?Id=' + listOpp[2].Id);
        Test.setCurrentPage(currentPage1);
        listOpp[2].Submitter_Profile__c = 'na prm';
        listOpp[2].Related_Parent_Opportunity__c = listOpp[0].ID;
        PageReference actualPageRef1 = testedObject1.SubmitAutoRenewal();
        update new opportunity(ID = listOpp[0].ID, Related_Parent_Opportunity__c = listOpp[2].ID);
        listOpp[2].Submitter_Profile__c = 'TESTING_Profile';
        testedObject1.SubmitAutoRenewal();
        listOpp[2].Related_Parent_Opportunity__c = NULL;
        testedObject1.SubmitAutoRenewal();
        listOpp[2].CloseDate = NULL;
        testedObject1.SubmitAutoRenewal();
        testedObject1.isAPJ_LATAM_CA_Checked = False;
        Contact con = new Contact(FirstName = 'first', Phone = '044223667788', AccountId = listAcc[1].Id, Email = 'vv_1_1@dell.com.fdev', Lastname = 'UT', Decision_Making_Role__c = 'Influencer', Job_Function__c = 'Finance',
                                  Job_Function_Role__c = 'Finance Manager', Primary_Contact__c = false, MobilePhone = '9030587363', Eloqua_ID__c = '1234',Status__c = 'Customer');
        insert con;
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User(ContactId = con.id, IsActive = true, Email = 'vv_1_1@dell.com.fdev', LanguageLocaleKey = 'en_US',
                          LastName = 'UT', Alias = 'UT', CommunityNickname = 'DELL_TEST!', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                          EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = 'DELL_TEST_1' + '@dell.com.fdev', Badge_Number__c = '1239098');
        insert u;        
        listOpp[3] = [Select id,CreatedDate,PartnerAccountID, Partner_Account_Country_Code__c, Request_Status__c from Opportunity where id =: listOpp[3].id];
        System.runas(u)
        {
            controllerObject = new ApexPages.StandardController(listOpp[3]);
            testedObject1 = new OpportunityRenewalExtension(controllerObject);
            testedObject1.previousPage = 'https://Host/' + listOpp[3].Id;
            PageReference currentPage10 = new PageReference('apex/RenewOpportunity?Id=' + listOpp[3].Id);
            Test.setCurrentPage(currentPage10);   
        }
        System.assertNotEquals(NULL, listOpp[2].Request_Status__c);
    }
}
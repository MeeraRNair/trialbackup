/*****************************************************************************************************************
* Name          : Vfcntrl_Distributor_Switch_Form_Test
* Description   : Test Class for Vfcntrl_Distributor_Switch_Form
* -----------------------------------------------------------
* Revision     Name              Date           Release No.      CR NO     Description
* 1.0         Yeswanth          15.05.2017 
* 2.0          Jatin             4-07-2018      FY-19-DCS-0802    16018    Commented NET exam logic statements as part of NET003 story
******************************************************************************************************************/
@isTest(SeeAllData=false)
public class Vfcntrl_Distributor_Switch_Form_Test {
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    static list<user> listUser;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<user> listUserTdf=TestDataFactory.createNPortalUser(1);
        listUserTdf[0].isActive=True;
        insert listUserTdf;
        List<Account> listAccTdf=TestDataFactory.createNAccount(3, 'Partner Account');
        for(Account acc : listAccTdf){
            acc.Partner_Tier__c = 'Tier 1';
            acc.Partner_Relationship__c = 'Authorized';
            acc.Status__c = 'Active';
        }
        insert listAccTdf;
        List<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
    }
    Static testmethod void testMethod1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c partnerReq = createPartnerRequest();
        listAcc=[select id from Account limit 3];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Partner_Type__c = 'GLOBAL ALLIANCE';
        listAcc[0].DMU__c = True;  
        for(Account acc : listAcc){
            acc.Partner_Registration__c = partnerReq.Id;
            acc.Account_Country__c = 'UNITED STATES';
        }
        listAcc[1].Partner_Type__c = 'Commercial Distributor';
        listAcc[1].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        listAcc[1].DMU__c = false;
        listAcc[1].Partner_Relationship__c = 'Storage,Client';
        listAcc[1].Partner_Type__c = 'Commercial Distributor';
        listAcc[2].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        listAcc[2].DMU__c = false;
        listAcc[2].Partner_Relationship__c = 'Storage,Client';
        listAcc[2].Partner_Type__c = 'Commercial Distributor';
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        listUser=[select id from user where isActive=true limit 1];
        Disti_Relationship__c distiRel = new Disti_Relationship__c(Reseller_Account__c =listAcc[0].Id, Disti_Account__c = listAcc[1].id,
                                                                   Contracted_Disti__c = true, Requested_Distributor_Status__c = 'Submitted',
                                                                   Requested_Distributor__c = listAcc[2].id);
        insert distiRel; 
        listOpp=[select id from Opportunity limit 1];
        System.runAs(listUser[0]){
            Test.startTest();  
            PageReference pageRef = Page.Distributor_Switch_Form;
            Test.setCurrentPage(pageRef);
            Vfcntrl_Distributor_Switch_Form distiSwitchPage = new Vfcntrl_Distributor_Switch_Form();
            ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
            ApexPages.currentPage().getParameters().put('selectedAccId',listAcc[1].id);
            ApexPages.currentPage().getParameters().put('type','firstdisti');
            distiSwitchPage.TnCaccept = True;
            distiSwitchPage.DistributorSetupRequestForm =true;
            distiSwitchPage.searchString = 'Test';
            distiSwitchPage.SearchBy = 'Name';
            distiSwitchPage.fetchResults();
            distiSwitchPage.searchString = '9876543210';
            distiSwitchPage.SearchBy = 'Affinity';
            distiSwitchPage.fetchResults();
            distiSwitchPage.SearchBy = 'Email';
            distiSwitchPage.fetchResults();
            distiSwitchPage.searchString = '.com';
            distiSwitchPage.SearchBy = 'Email';
            distiSwitchPage.fetchResults();
            distiSwitchPage.searchString = '';
            distiSwitchPage.SearchBy = 'Name';
            distiSwitchPage.fetchResults();
            distiSwitchPage.searchString = 'T';
            distiSwitchPage.SearchBy = 'Name';
            distiSwitchPage.fetchResults();
            distiSwitchPage.distiRelationShip.Existing_Distributor_Informed__c = 'Yes';
            distiSwitchPage.distiRelationShip.Distributor_Request_Reason__c = 'Test';
            distiSwitchPage.onnewPageLoad();
            distiSwitchPage.onPageLoad();
            distiSwitchPage.getdistiRelationShip();
            distiSwitchPage.submitFunction();
            distiSwitchPage.cancel();
            distiSwitchPage.savefirstacc();
            distiSwitchPage.changefirstdisti();
            distiSwitchPage.changeseconddisti();
            distiSwitchPage.savesecondacc();
            distiSwitchPage.enableDisableButton();
            distiSwitchPage.searchString = 'Test';
            distiSwitchPage.SearchBy = 'Name';
            distiSwitchPage.fetchResults();
            ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
            ApexPages.currentPage().getParameters().put('selectedAccId',listAcc[1].id);
            ApexPages.currentPage().getParameters().put('type','seconddisti');
            distiSwitchPage.onnewPageLoad();
            distiSwitchPage.onPageLoad();
            distiSwitchPage.submitFunction();
            distiSwitchPage.TnCaccept = False;
            distiSwitchPage.submitFunction();
            distiSwitchPage.sendnotification(distiRel);
            distiSwitchPage.distiRelationShip.id = null;
            distiSwitchPage.onPageLoad();
            distiSwitchPage.onnewPageLoad();
            distiSwitchPage.submitFunction(); 
            Test.stopTest();     
        }
    }
    Static testmethod void testMethodgc(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c partnerReq = createPartnerRequest();
        listAcc=[select id from Account Limit 3];
        for(Account acc : listAcc){
            acc.Account_Country__c = 'CHINA';
            acc.Partner_Registration__c = partnerReq.Id;
        }
        listAcc[0].Account_Country_Code__c = 'CN';
        listAcc[0].Partner_Type__c = 'GLOBAL ALLIANCE';
        listAcc[0].DMU__c = True;
        listAcc[1].Partner_Type__c = 'Commercial Distributor';
        listAcc[1].Distribution_Sell_To_Countries__c = 'CHINA';
        listAcc[1].DMU__c = false;
        listAcc[1].Partner_Relationship__c = 'Storage,Client';
        listAcc[2].Partner_Type__c = 'Commercial Distributor';
        listAcc[2].Distribution_Sell_To_Countries__c = 'CHINA';
        listAcc[2].DMU__c = false;
        listAcc[2].Partner_Relationship__c = 'Storage,Client';
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        Contact newCont = new Contact(FirstName = 'MyTestContact9', LastName = 'MyTestContact9', AccountId =listAcc[0].Id,
                                      Status__c  =  'Marketing Suspect', Email = 'MyTestContactEmail_9@ust-global.com', Fax = '1234567',
                                      MobilePhone = '0987654', Last_Operation_Performed__c = 'testing', Phone = '1234500');
        insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', 
                                    Email='MyTestUser9@dell.com', FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='zh_CN', LocaleSidKey='zh_CN', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test99826513', isActive = TRUE, ContactId = newCont.Id);
        insert partnerUser;     
        listOpp=[Select id,StageName, Forecast_Category_Override__c from Opportunity Limit 1];
        listOpp[0].Accountid=listAcc[0].id;
        listOpp[0].Amount = 1000;
        listOpp[0].CloseDate= System.Now().Date().addDays(180);
        update listOpp;
        System.runAs(partnerUser){
            PageReference pageRef1 = Page.Distributor_Switch_Form;
            Test.setCurrentPage(pageRef1);
            Vfcntrl_Distributor_Switch_Form distiSwitchPage1 = new Vfcntrl_Distributor_Switch_Form();
            ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
            ApexPages.currentPage().getParameters().put('selectedAccId',listAcc[1].id);
            distiSwitchPage1.TnCaccept = True;
            distiSwitchPage1.DistributorSetupRequestForm =true;
            distiSwitchPage1.searchString = 'Test';
            distiSwitchPage1.onnewPageLoad();
            distiSwitchPage1.submitFunction();
        }
        Disti_Relationship__c distiRel = new Disti_Relationship__c(Reseller_Account__c =listAcc[0].Id, Disti_Account__c = listAcc[1].id,
                                                                   Contracted_Disti__c = true, Requested_Distributor_Status__c = 'Submitted',
                                                                   Requested_Distributor__c = listAcc[2].id);
        insert distiRel; 
        System.runAs(partnerUser){
            Test.startTest();  
            PageReference pageRef = Page.Distributor_Switch_Form;
            Test.setCurrentPage(pageRef);
            Vfcntrl_Distributor_Switch_Form distiSwitchPage = new Vfcntrl_Distributor_Switch_Form();
            ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
            ApexPages.currentPage().getParameters().put('selectedAccId',listAcc[1].id);
            ApexPages.currentPage().getParameters().put('type','firstdisti');
            distiSwitchPage.TnCaccept = True;
            distiSwitchPage.DistributorSetupRequestForm =true;
            distiSwitchPage.searchString = 'Test';
            distiSwitchPage.SearchBy = 'Name';
            distiSwitchPage.fetchResults();
            distiSwitchPage.searchString = '9876543210';
            distiSwitchPage.SearchBy = 'Affinity';
            distiSwitchPage.fetchResults();
            distiSwitchPage.SearchBy = 'Email';
            distiSwitchPage.fetchResults();
            distiSwitchPage.searchString = '.com';
            distiSwitchPage.SearchBy = 'Email';
            distiSwitchPage.fetchResults();
            distiSwitchPage.searchString = '';
            distiSwitchPage.SearchBy = 'Name';
            distiSwitchPage.fetchResults();
            distiSwitchPage.searchString = 'T';
            distiSwitchPage.SearchBy = 'Name';
            distiSwitchPage.fetchResults();
            distiSwitchPage.distiRelationShip.Existing_Distributor_Informed__c = 'Yes';
            distiSwitchPage.distiRelationShip.Distributor_Request_Reason__c = 'Test';
            distiSwitchPage.onnewPageLoad();
            distiSwitchPage.onPageLoad();
            distiSwitchPage.getdistiRelationShip();
            distiSwitchPage.submitFunction();
            distiSwitchPage.cancel();
            distiSwitchPage.savefirstacc();
            distiSwitchPage.changefirstdisti();
            distiSwitchPage.changeseconddisti();
            distiSwitchPage.savesecondacc();
            distiSwitchPage.enableDisableButton();
            distiSwitchPage.searchString = 'Test';
            distiSwitchPage.SearchBy = 'Name';
            distiSwitchPage.fetchResults();
            ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
            ApexPages.currentPage().getParameters().put('selectedAccId',listAcc[1].id);
            ApexPages.currentPage().getParameters().put('type','seconddisti');
            distiSwitchPage.onnewPageLoad();
            distiSwitchPage.onPageLoad();
            distiSwitchPage.submitFunction();
            distiSwitchPage.onnewPageLoad();
            distiSwitchPage.submitFunction();
            distiSwitchPage.cancel();
            Test.stopTest();     
        }
    }
    static Partner_Request__c createPartnerRequest(){
        listAcc=[Select id from Account Limit 1];
        listAcc[0].Account_Country_Code__c = 'AI';
        listAcc[0].Account_Country__c = 'ANGUILIA';
        listAcc[0].Account_ID__c =''+System.currentTimeMillis();
        Country__c testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'AM',
            User_Currency_Iso_Code__c = 'USD',
            Region__c = 'EC-EMEA');
        insert testCountry;
        Country__c testCountry1 = new Country__c( Name = 'CHINA', Code__c = 'CN', User_Currency_Iso_Code__c = 'USD', Region__c = 'APJ');
        insert testCountry1;
        Country__c testCountry2 = new Country__c( Name = 'CANADA', Code__c = 'CA', User_Currency_Iso_Code__c = 'CAD', Region__c = 'NA');
        insert testCountry2;
        list<user> listUser=[select id from User where isActive=true limit 1];
        
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
        request.OwnerId = listUser[0].Id;
        insert request;
        system.runas(listUser[0]){
            Vfcntrl_Distributor_Switch_Form distiSwitchPage1 = new Vfcntrl_Distributor_Switch_Form();
            distiSwitchPage1.submitFunction();
        }
        return request;
    }  
}
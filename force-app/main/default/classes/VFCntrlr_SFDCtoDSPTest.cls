@isTest
private class VFCntrlr_SFDCtoDSPTest {
    
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdSetting;
        
        list<User> listUserTdf=TestDataFactory.createNPortalUser(1);
        insert listUserTdf;
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].Account_Country_Code__c='CL';
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        TriggerExecutioncontroller.setSkipOpportunitySplitTriggers(True);
        insert listOppTdf;
        Country__c testCountry = new Country__c(Code__c='US'); 
        Country__c testCountry2 = new Country__c(Code__c='CA'); 
        list<Country__c> listContry =new list<Country__c>{testCountry, testCountry2}; 
            insert listContry;
    }   
    static testMethod void viewAccountinDSPTest() {
        Test.startTest();
        list<Account> listAcc=[Select id,Account_ID__c from Account Limit 1];
        list<user> listUser=[Select id from user limit 1];
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        String strurl = Label.SFDCtoDSP;
        String strredirectvalue2 = 'account/details/';
        String strnewCurrentParams = '#'+strredirectvalue2+'/001K000000tt4BB/87765';
        String strreturnurl = strurl+strnewCurrentParams;
        PageReference pr = new PageReference(strreturnurl);
        system.debug('*********account******' + strreturnurl);
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('country', 'US');
        VFCntrlr_SFDCtoDSP controller = new VFCntrlr_SFDCtoDSP();
        controller.navtoDSP();
        String strnewCurrentParams2 = '#'+'quote/create&accountId='+listAcc[0].Account_ID__c+'&dealid=456';
        string strreturnurl2 = strurl+strnewCurrentParams2;
        PageReference pr2= new PageReference(strreturnurl2);
        system.debug('*********quote******' + strreturnurl2);
        Test.setCurrentPage(pr2);
        VFCntrlr_SFDCtoDSP controller2 = new VFCntrlr_SFDCtoDSP();
        controller2.navtoDSP();
        string strnewCurrentParams3 = '#'+'opportunity/details/'+listAcc[0].id+'&dealid=5678';
        string strreturnurl3 = strurl+strnewCurrentParams3;
        PageReference pr3 = new PageReference(strreturnurl3);
        Test.setCurrentPage(pr3);
        VFCntrlr_SFDCtoDSP controller3 = new VFCntrlr_SFDCtoDSP();
        controller3.navtoDSP();
        string strredirectvalue4 = 'account/';
        string strnewCurrentParams4 = '#/'+strredirectvalue4+listAcc[0].id+'&dealid=5678';
        string strreturnurl4 = strurl+strnewCurrentParams4;
        PageReference pr4 = new PageReference(strreturnurl4);
        Test.setCurrentPage(pr4);
        VFCntrlr_SFDCtoDSP controller4 = new VFCntrlr_SFDCtoDSP();
        controller4.navtoDSP();
        try{
            String strnewCurrentParams5 = Label.COM_URL+'?redirectvalue=opportunity/details/&id='+listAcc[0].id+'&country=&accountId='+listAcc[0].Account_ID__c;
            PageReference  pr5=new PageReference(strnewCurrentParams5);
            Test.setCurrentPage(pr5);
            VFCntrlr_SFDCtoDSP controller5=new VFCntrlr_SFDCtoDSP();
            controller5.navToDSP();
        }catch(Exception e){
            String strerrMsg = 'Account Country Code is empty';
            System.assert(e.getMessage().contains(strerrMsg));
        }  
        PageReference  pr6=new PageReference(Label.COM_URL+'?id=backId');
        Test.setCurrentPage(pr6);
        VFCntrlr_SFDCtoDSP controller6=new VFCntrlr_SFDCtoDSP();
        controller6.back();
        Test.stopTest();
    }
}
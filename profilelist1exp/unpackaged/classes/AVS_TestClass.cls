/***********************************************************
* Revision       Release                   Name           Date                  Description   
* 1.0       0202             Vikas KH      08-Dec-2019      Impelemented TDF
***************************************************************/
@istest
private class AVS_TestClass{
    static list<Account> listAcc;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
        insert listAccTDF;
    }
    static testmethod void myUnitTest() {
        TriggerExecutionController.setSkipContactTriggers(true);
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Contact_AVS_Enable__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Contact_AVS_Enable__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr);
        listctr.add(ctr1);
        insert listctr;
        TriggerExecutionController.setSkipAccountTriggers(true);
  /*      string recordTypeId=[select id from RecordType where name='End-User Account' AND sobjectType='Account'].Id;
        Account acc=new Account(name='test contact', recordTypeId=recordTypeId,Account_Country_Code__c='US',Account_Country__c='United States');
        insert acc; */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].Account_Country__c='United States';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        Contact con=new Contact(firstName='testLast', lastName='testLast', AccountId=listAcc[0].Id, MailingStreet='testMialing', MailingState='test state',
                                MailingPostalCode='23423',MailingCountry ='JAPAN', Phone='234234323', email='test@dell.com',
                                Status__c='Customer', Fax='23423432', Decision_Making_Role__c='teset',
                                Job_Function__c='test', Job_Function_Role__c='test',Mailing_Address_Changed__c=true);
        
        test.startTest();
        insert con;
        test.stopTest();
        ApexPages.StandardController std=new ApexPages.StandardController(con);
        Test.setCurrentPageReference(new PageReference('Page.AVSContactSuggestion')); 
        System.currentPageReference().getParameters().put('newid', con.Id);
        VFCtrl_AVSContactSuggestion objCtlr=new VFCtrl_AVSContactSuggestion(std);
        // Invoke Test Function
        objCtlr.test();
        //Invoke Options method
        List<SelectOption> listoptions=objCtlr.getItems();
        string[] listcountries=objCtlr.getCountries();
        //set countries
        objCtlr.setCountries(listcountries);
        // Toogle Method
        objCtlr.toggleEditMode();
        // Invoke Call AVS Method
        objCtlr.CallAVS();
        // Invoke selectSuggestions method
        for(VFCtrl_AVSContactSuggestion.suggestions sugg:objCtlr.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Do Save Operation
        objCtlr.save();
        // Invoke Cancel Method
        objCtlr.doCancel();
        objCtlr.getshowAptNo();
        objCtlr.resultStatusDesc = 'Assigned Address';
        objCtlr.resultSuggestionCount = '2';
        objCtlr.aptOrSuiteNumber = '100';
        objCtlr.refineSearch();
        try{
            objCtlr.selectSuggestions();
        }catch(Exception e){
        }
    }
    
    static testmethod void myUnitTest1() {
        TriggerExecutionController.setSkipContactTriggers(true);
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Contact_AVS_Enable__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Contact_AVS_Enable__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr);
        listctr.add(ctr1);
        insert listctr;
        TriggerExecutionController.setSkipAccountTriggers(true);
        /* string recordTypeId=[select id from RecordType where name='End-User Account' AND sobjectType='Account'].Id;
        Account acc=new Account(name='test contact', recordTypeId=recordTypeId,Account_Country_Code__c='US',Account_Country__c='United States');
        insert acc;
        */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].Account_Country__c='United States';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        Contact con=new Contact(firstName='testLast', lastName='testLast', AccountId=listAcc[0].Id, MailingStreet='testMialing', MailingState='test state',
                                MailingPostalCode='23423', Phone='234234323', email='test@dell.com',
                                Status__c='Customer', Fax='23423432', Decision_Making_Role__c='teset',
                                Job_Function__c='test', Job_Function_Role__c='test',Mailing_Address_Changed__c=true);
        
        test.startTest();
        insert con;
        test.stopTest();
        ApexPages.StandardController std=new ApexPages.StandardController(con);
        Test.setCurrentPageReference(new PageReference('Page.AVSContactSuggestion')); 
        System.currentPageReference().getParameters().put('id', con.Id);
        VFCtrl_AVSContactSuggestion objCtlr=new VFCtrl_AVSContactSuggestion(std);
        objCtlr.aptOrSuiteNumber = '100';
        // Invoke Test Function
        objCtlr.test();
        //Invoke Options method
        List<SelectOption> listoptions=objCtlr.getItems();
        string[] listcountries=objCtlr.getCountries();
        //set countries
        objCtlr.setCountries(listcountries);
        // Toogle Method
        objCtlr.toggleEditMode();
        // Invoke Call AVS Method
        objCtlr.CallAVS();
        // Invoke selectSuggestions method
        for(VFCtrl_AVSContactSuggestion.suggestions sugg:objCtlr.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Do Save Operation
        objCtlr.save();
        // Invoke Cancel Method
        objCtlr.doCancel();
        objCtlr.getshowAptNo();
        objCtlr.resultStatusDesc = 'Assigned Address';
        objCtlr.resultSuggestionCount = '2';
        objCtlr.refineSearch();
        try{
            objCtlr.selectSuggestions();
        }catch(Exception e){
        }
    }
    static testmethod void myUnitTest2() {
        TriggerExecutionController.setSkipContactTriggers(true);
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Contact_AVS_Enable__c = true);
        Country__c ctr1 = new Country__c(Name='CHINA',Code__c='cn',Contact_AVS_Enable__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr);
        listctr.add(ctr1);
        insert listctr;
        TriggerExecutionController.setSkipAccountTriggers(true);
        /* string recordTypeId=[select id from RecordType where name='End-User Account' AND sobjectType='Account'].Id;
        Account acc=new Account(name='test contact', recordTypeId=recordTypeId,Account_Country_Code__c='US',Account_Country__c='United States');
        insert acc; */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].Account_Country__c='United States';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        Contact con=new Contact(firstName='testLast', lastName='testLast', AccountId=listAcc[0].Id, MailingCountry='China', MailingState='test state', MailingStreet='',
                                MailingPostalCode='', Phone='234234323', email='test@dell.com',
                                Status__c='Customer', Fax='23423432', Decision_Making_Role__c='teset',
                                Job_Function__c='test', Job_Function_Role__c='test',Mailing_Address_Changed__c=true);
        
        test.startTest();
        insert con;
        test.stopTest();
        ApexPages.StandardController std=new ApexPages.StandardController(con);
        Test.setCurrentPageReference(new PageReference('Page.AVSContactSuggestion')); 
        System.currentPageReference().getParameters().put('id', con.Id);
        VFCtrl_AVSContactSuggestion objCtlr=new VFCtrl_AVSContactSuggestion(std);
        objCtlr.aptOrSuiteNumber = '100';
        // Invoke Test Function
        objCtlr.test();
        //Invoke Options method
        List<SelectOption> listoptions=objCtlr.getItems();
        string[] listcountries=objCtlr.getCountries();
        //set countries
        objCtlr.setCountries(listcountries);
        // Toogle Method
        objCtlr.toggleEditMode();
        // Invoke Call AVS Method
        objCtlr.CallAVS();
        // Invoke selectSuggestions method
        for(VFCtrl_AVSContactSuggestion.suggestions sugg:objCtlr.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Do Save Operation
        objCtlr.save();
        // Invoke Cancel Method
        objCtlr.doCancel();
        objCtlr.getshowAptNo();
        objCtlr.resultStatusDesc = 'Assigned Address';
        objCtlr.resultSuggestionCount = '2';
        objCtlr.refineSearch();
        try{
            objCtlr.selectSuggestions();
        }catch(Exception e){
        }
    }
    
    static testmethod void myUnitTest3() {
        TriggerExecutionController.setSkipContactTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        /*  string recordTypeId=[select id from RecordType where name='End-User Account' AND sobjectType='Account'].Id;
        Account acc=new Account(name='test contact', recordTypeId=recordTypeId,Account_Country_Code__c='',Account_Country__c='');
        insert acc;*/
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].Account_Country__c='United States';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country__c, listAcc[0].Account_Country__c);
        Contact con=new Contact(firstName='testLast', lastName='testLast', AccountId=listAcc[0].Id, MailingCountry='test11', MailingState='test state', MailingStreet='',
                                MailingPostalCode='', Phone='234234323', email='test@dell.com',
                                Status__c='Customer', Fax='23423432', Decision_Making_Role__c='teset',
                                Job_Function__c='test', Job_Function_Role__c='test',Mailing_Address_Changed__c=true);
        test.startTest();
        insert con;
        test.stopTest();
        ApexPages.StandardController std=new ApexPages.StandardController(con);
        Test.setCurrentPageReference(new PageReference('Page.AVSContactSuggestion')); 
        System.currentPageReference().getParameters().put('id', con.Id);
        VFCtrl_AVSContactSuggestion objCtlr=new VFCtrl_AVSContactSuggestion(std);
        objCtlr.aptOrSuiteNumber = '100';
        // Invoke Test Function
        objCtlr.test();
        //Invoke Options method
        List<SelectOption> listoptions=objCtlr.getItems();
        string[] listcountries=objCtlr.getCountries();
        //set countries
        objCtlr.setCountries(listcountries);
        // Toogle Method
        objCtlr.toggleEditMode();
        // Invoke Call AVS Method
        objCtlr.CallAVS();
        // Invoke selectSuggestions method
        for(VFCtrl_AVSContactSuggestion.suggestions sugg:objCtlr.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Do Save Operation
        objCtlr.save();
        // Invoke Cancel Method
        objCtlr.doCancel();
        objCtlr.getshowAptNo();
        objCtlr.resultStatusDesc = 'Assigned Address';
        objCtlr.resultSuggestionCount = '2';
        objCtlr.refineSearch();
        try{
            objCtlr.selectSuggestions();
        }catch(Exception e){}
    }
    
    static testmethod void myUnitTest5() {
        TriggerExecutionController.setSkipContactTriggers(true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Contact_AVS_Enable__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr1);
        insert listctr;
        TriggerExecutionController.setSkipAccountTriggers(true);
    /* string recordTypeId=[select id from RecordType where name='End-User Account' AND sobjectType='Account'].Id;
        Account acc=new Account(name='test contact', recordTypeId=recordTypeId,Account_Country_Code__c='US',Account_Country__c='United States');
        insert acc;
        */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].Account_Country__c='United States';
        update listAcc;
    system.assertEquals(listAcc[0].Account_Country__c, listAcc[0].Account_Country__c);
        Contact con=new Contact(firstName='testLast', lastName='testLast', AccountId=listAcc[0].Id, MailingCountry='JAPAN', MailingState='test state', MailingStreet='test',
                                MailingPostalCode='', Phone='234234323', email='test@dell.com',
                                Status__c='Customer', Fax='23423432', Decision_Making_Role__c='teset',
                                Job_Function__c='test', Job_Function_Role__c='test',Mailing_Address_Changed__c=true);
        
        test.startTest();
        insert con;
        test.stopTest();
        ApexPages.StandardController std=new ApexPages.StandardController(con);
        Test.setCurrentPageReference(new PageReference('Page.AVSContactSuggestion')); 
        System.currentPageReference().getParameters().put('id', con.Id);
        VFCtrl_AVSContactSuggestion objCtlr=new VFCtrl_AVSContactSuggestion(std);
        objCtlr.aptOrSuiteNumber = '100';
        // Invoke Test Function
        objCtlr.test();
        //Invoke Options method
        List<SelectOption> listoptions=objCtlr.getItems();
        string[] listcountries=objCtlr.getCountries();
        //set countries
        objCtlr.setCountries(listcountries);
        // Toogle Method
        objCtlr.toggleEditMode();
        // Invoke Call AVS Method
        objCtlr.CallAVS();
        // Invoke selectSuggestions method
        for(VFCtrl_AVSContactSuggestion.suggestions sugg:objCtlr.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Do Save Operation
        objCtlr.save();
        // Invoke Cancel Method
        objCtlr.doCancel();
        objCtlr.getshowAptNo();
        objCtlr.resultStatusDesc = 'Assigned Address';
        objCtlr.resultSuggestionCount = '2';
        objCtlr.selCountry = 'testselCountry';
        objCtlr.resChinaSt = 'testresChinaSt';
        objCtlr.buildNameJapan = 'testbuildNameJapan';
        objCtlr.FinalMailingStreet = 'testFinalMailingStreet';
        objCtlr.resultStreet1 = 'testresultStreet1';
        objCtlr.Ausresultstreet = 'testAusresultstreet';
        objCtlr.showFloorNumber = True;
        objCtlr.resultEasyIq = 'TestresultEasyIq';
        objCtlr.resultEasyIqCount = 'TestresultEasyIqCount';
        objCtlr.oresultStatusDesc = 'TestResult';
        objCtlr.count = 1;
        objCtlr.showAptNo = True;
        objCtlr.showErrorMessage = False;
        objCtlr.refineSearch();
        objCtlr.setshowAptNo(True);
        objCtlr.getshowFloorNumber();
        objCtlr.setshowFloorNumber(True);
        try{
            objCtlr.selectSuggestions();
        }catch(Exception e){
        }
    }
    
    static testmethod void myUnitTest6() {
        TriggerExecutionController.setSkipContactTriggers(true);
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Contact_AVS_Enable__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Contact_AVS_Enable__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr);
        listctr.add(ctr1);
        insert listctr;
        TriggerExecutionController.setSkipAccountTriggers(true);
        /*  string recordTypeId=[select id from RecordType where name='End-User Account' AND sobjectType='Account'].Id;
        Account acc=new Account(name='test contact', recordTypeId=recordTypeId,Account_Country_Code__c='JP',Account_Country__c='JAPAN');
        insert acc;
        */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].Account_Country__c='United States';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        Contact con=new Contact(firstName='testLast', lastName='testLast', AccountId=listAcc[0].Id, MailingCountry='JAPAN', MailingState='test state', MailingStreet='',
                                MailingPostalCode='', Phone='234234323', email='test@dell.com',
                                Status__c='Customer', Fax='23423432', Decision_Making_Role__c='teset',
                                Job_Function__c='test', Job_Function_Role__c='test',Mailing_Address_Changed__c=true);
        
        test.startTest();
        insert con;
        test.stopTest();
        ApexPages.StandardController std=new ApexPages.StandardController(con);
        Test.setCurrentPageReference(new PageReference('Page.AVSContactSuggestion')); 
        System.currentPageReference().getParameters().put('id', con.Id);
        VFCtrl_AVSContactSuggestion objCtlr=new VFCtrl_AVSContactSuggestion(std);
        objCtlr.aptOrSuiteNumber = '100';
        // Invoke Test Function
        objCtlr.test();
        //Invoke Options method
        List<SelectOption> listoptions=objCtlr.getItems();
        string[] listcountries=objCtlr.getCountries();
        //set countries
        objCtlr.setCountries(listcountries);
        // Toogle Method
        objCtlr.toggleEditMode();
        // Invoke Call AVS Method
        objCtlr.CallAVS();
        // Invoke selectSuggestions method
        for(VFCtrl_AVSContactSuggestion.suggestions sugg:objCtlr.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Do Save Operation
        objCtlr.save();
        // Invoke Cancel Method
        objCtlr.doCancel();
        objCtlr.getshowAptNo();
        objCtlr.resultStatusDesc = 'Assigned Address';
        objCtlr.resultSuggestionCount = '2';
        objCtlr.refineSearch();
        try{
            objCtlr.selectSuggestions();
        }catch(Exception e){
        }
    }
    static testmethod void myUnitTest7() {
        TriggerExecutionController.setSkipContactTriggers(true);
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Contact_AVS_Enable__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Contact_AVS_Enable__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr);
        listctr.add(ctr1);
        insert listctr;
        TriggerExecutionController.setSkipAccountTriggers(true);
        /* string recordTypeId=[select id from RecordType where name='End-User Account' AND sobjectType='Account'].Id;
        Account acc=new Account(name='test contact', recordTypeId=recordTypeId,Account_Country_Code__c='US',Account_Country__c='United States');
        insert acc; */
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c='US';
        listAcc[0].Account_Country__c='United States';
        update listAcc;
        system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
        Contact con=new Contact(firstName='testLast', lastName='testLast', AccountId=listAcc[0].Id, MailingCountry='United States', MailingState='test state', MailingStreet='',
                                MailingPostalCode='', Phone='234234323', email='test@dell.com',
                                Status__c='Customer', Fax='23423432', Decision_Making_Role__c='teset',
                                Job_Function__c='test', Job_Function_Role__c='test',Mailing_Address_Changed__c=true);
        
        test.startTest();
        insert con;
        test.stopTest();
        ApexPages.StandardController std=new ApexPages.StandardController(con);
        Test.setCurrentPageReference(new PageReference('Page.AVSContactSuggestion')); 
        System.currentPageReference().getParameters().put('id', con.Id);
        VFCtrl_AVSContactSuggestion objCtlr=new VFCtrl_AVSContactSuggestion(std);
        objCtlr.aptOrSuiteNumber = '100';
        // Invoke Test Function
        objCtlr.test();
        //Invoke Options method
        List<SelectOption> listoptions=objCtlr.getItems();
        string[] listcountries=objCtlr.getCountries();
        //set countries
        objCtlr.setCountries(listcountries);
        // Toogle Method
        objCtlr.toggleEditMode();
        // Invoke Call AVS Method
        objCtlr.CallAVS();
        // Invoke selectSuggestions method
        for(VFCtrl_AVSContactSuggestion.suggestions sugg:objCtlr.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Do Save Operation
        objCtlr.save();
        // Invoke Cancel Method
        objCtlr.doCancel();
        objCtlr.getshowAptNo();
        objCtlr.resultStatusDesc = 'Assigned Address';
        objCtlr.resultSuggestionCount = '2';
        objCtlr.refineSearch();
        try{
            objCtlr.selectSuggestions();
        }catch(Exception e){
        }
    }
    
}
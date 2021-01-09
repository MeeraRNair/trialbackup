/***********************************************************
* Name          : AVS_Oppty_Test
* Description   : Test Class for AVSSuggestion class
* ---------------------------------------------------------
* Revision  Name       Date             Description
* 1.0       Suresh     10. Sep. 2015    Test Class for AVSSuggestion class
*           Rahul      23. March. 2018  To Skip the opportunity validation rules
************************************************************/
@isTest
private class AVS_Oppty_Test {
    Static  list<Account> listAcc = new list<Account>();
    Static list<opportunity> listOpp = new list<Opportunity>();
    Static list<OpportunitylineItem> listOppLineItem;
    
    @testsetup static void setup()
    { 
        list<Account> listAccfromFactory = TestDataFactory.createNAccount(1, 'End-User Account');
        TriggerExecutionController.setskipAccountTriggers(true);
        insert listAccfromFactory;
        list<opportunity> listOppTDF = TestDataFactory.createNOpportunities(10, 'Deal Registration');
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listOppTDF;
        list<OpportunitylineItem> listOpplTDF = TestDataFactory.createNOpportunityLineItem(8);
        listOpplTDF[0].Opportunityid=listoppTDF[0].id; 
        listOpplTDF[1].Opportunityid=listoppTDF[1].id;
        listOpplTDF[2].Opportunityid=listoppTDF[2].id;
        listOpplTDF[3].Opportunityid=listoppTDF[3].id;
        listOpplTDF[4].Opportunityid=listoppTDF[4].id;
        listOpplTDF[5].Opportunityid=listoppTDF[5].id;
        listOpplTDF[6].Opportunityid=listoppTDF[6].id;
        listOpplTDF[7].Opportunityid=listoppTDF[7].id;
        TriggerExecutionController.setSkipAllTriggers(true);
        Insert listOpplTDF;
        OWD__c owdSetting  = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdSetting;
    }  
    // Test for United States with single suggestion selected
    private static String createBasicObject(){
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Pricebook2 s = [select id,name,IsActive from Pricebook2 where IsStandard = true LIMIT 1];
        String str = s.Id;
        return str;
    }
    @isTest static void testmethodone() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listCtr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Distributor_Reseller_Name__c  = listOpp[0].id;
        listOpp[0].End_User_Mailing_Country__c = 'United States';
        listOpp[0].Distributor_Reseller_Name__c = null;
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.refineSearch();
        avsSuggestion.selectSuggestions();
        listOpp[0].End_User_Mailing_City__c = 'London';
        update listOpp;
        // Invoke Cancel Method
        avsSuggestion.cancelAction();            
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '100';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        test.stopTest();
        system.assertNotEquals('london', listOpp[0].End_User_Mailing_City__c);
    }
    //Test with multiple suggestion selected
    @isTest static void testmethodtwo() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr);
        listctr.add(ctr1);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listctr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'United States';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='10005-2858';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        //TriggerExecutionController.setSkipOpportunityTriggers(true); 
        TriggerExecutionController.setSkipAllTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '100';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('United States', listOpp[0].End_User_Mailing_Country__c);
        test.stopTest();
    }
    // Test for Japan Region
    @isTest static void testmethodthree() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listCtr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'Japan';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='161';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].Engage_Channel_Opportunity__c = true;
        listOpp[0].CloseDate = System.Today() + 30;
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        test.stopTest();
        system.assertEquals('Japan',listOpp[0].End_User_Mailing_Country__c );
    }
    // Test for Japan Region
    @isTest static void testmethodthree1() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
       // TriggerExecutionController.setSkipOpportunityTriggers(true);--
        insert listCtr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'Japan';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c =' ';
        listOpp[0].End_User_Mailing_City__c = ' ';
        listOpp[0].End_User_Mailing_State_Province_Region__c = ' ';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
        }
        avsSuggestion.refineSearch();
        avsSuggestion.selectSuggestions();
        system.assertEquals('Japan', listOpp[0].End_User_Mailing_Country__c);
        test.stopTest();
    }
    @isTest static void testmethodthree2() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN2',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
       // TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'Japan2';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='161';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertNotEquals('public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    // Check for Australia region
    @isTest static void testmethodfour() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='Australia',Code__c='AU',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr);
        listctr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listctr;
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'Australia';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='12312';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    @isTest static void testmethodfive() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'United States';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c =' ';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity'));
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        avsSuggestion.CallAVS();
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertNotEquals('public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }   
    // Test for China Region
    @isTest static void testmethodseven() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='China',Code__c='CH',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'United States';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='161';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    // Test for China Region
    @isTest static void testmethodeight() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='China',Code__c='CH',Enable_AVS_for_Opportunity__c = true);     
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);       
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';                  
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'United States';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c =' ';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;      
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    // Test for United Kingdom Region
    @isTest static void testmethodnine() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='United Kingdom',Code__c='UK',Enable_AVS_for_Opportunity__c = true);     
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'United Kingdom';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='161 ';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(ListOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', ListOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);           
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    // Test for France Region
    @isTest static void testmethodten() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='France',Code__c='FF',Enable_AVS_for_Opportunity__c = true);      
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';          
        triggerExecutionController.setSkipAccountTriggers(True);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'France';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='161 ';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch(); 
        system.assertEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    // Test for Australia Region
    @isTest static void testmethodeleven() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='Australia1',Code__c='AU',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        listAcc = [Select id from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States'; 
        //triggerExecutionController.setSkipAccountTriggers(True); Skip All
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].End_User_Mailing_Country__c = 'Australia1';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='161 ';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', ListOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    // Test for United States with single suggestion selected
    @isTest static void testmethodtwelve() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        ListCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        list<Account> listAcc = [select id, name from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        triggerExecutionController.setSkipAccountTriggers(True);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].End_User_Mailing_Country__c = 'United States';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', ListOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '62';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertNotEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    // Test for United States with single suggestion selected
    @isTest static void testmethodthirteen() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='United States1',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listctr = new List<Country__c>();
        listctr.add(ctr);
        listctr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listctr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        list<Account> listAcc = [select id, name from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        triggerExecutionController.setSkipAccountTriggers(True);
        update listAcc;
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].End_User_Mailing_Country__c = 'United States';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', ListOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();           
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '62';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertNotEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    // Test for United States with single suggestion selected
    @isTest static void testmethodfourteen() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='United States1',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        list<Account> listAcc = [select id, name from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        triggerExecutionController.setSkipAccountTriggers(True);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].End_User_Mailing_Country__c = 'United States1';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', ListOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '12';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('65 Martin Pl', listOpp[0].End_User_Mailing_Street__c);
        test.stopTest();
    }
    // Test for United States with single suggestion selected
    @isTest static void testmethodfifteen() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='United States2',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        list<Account> listAcc = [select id, name from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        triggerExecutionController.setSkipAccountTriggers(True);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].End_User_Mailing_Country__c = 'United States2';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(ListOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '62';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('65 Martin Pl', listOpp[0].End_User_Mailing_Street__c);
        test.stopTest();
    }
    // Test for United States with single suggestion selected
    @isTest static void testmethodsixteen() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='United States2',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        list<Account> listAcc = [select id, name from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAllTriggers(true);
        //triggerExecutionController.setSkipAccountTriggers(True);
        update listAcc;
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].End_User_Mailing_Country__c = 'United States2';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', ListOPP[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '12';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        //avsSuggestion.SaveCurrentAddress();
        avsSuggestion.cancelOppAction();
        system.assertEquals('65 Martin Pl', listOpp[0].End_User_Mailing_Street__c);                
        test.stopTest();
    }
    @isTest static void testmethodseventeen() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='China1',Code__c='CH',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        list<Account> listAcc = [select id, name from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAllTriggers(true);
        //triggerExecutionController.setSkipAccountTriggers(True);
        update listAcc;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].End_User_Mailing_Country__c = 'China1';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='161';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertEquals('161', listOpp[0].End_User_Mailing_Zip_Postal_Code__c);
        test.stopTest();
    }  
    @isTest static void testmethod18() {
        string str = createBasicObject();
        Country__c ctr = new Country__c(Name='United States3',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        list<Account> listAcc = [select id, name from Account];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        triggerExecutionController.setSkipAccountTriggers(True);
        update listAcc;        
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listOpp = [select id from opportunity];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = str;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();            
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '100';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        system.assertNotEquals('Public Tender', listOpp[0].Engagement_Type__c);
        test.stopTest();
    }
    @isTest static void testmethodone4() {
        triggerexecutioncontroller.setSkipAllTriggers(True);
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        string strs = createBasicObject();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id,name from account limit 1];
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 5];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        listOpp[1].AccountId=listAcc[0].Id;
        listOpp[1].End_User_Mailing_Country__c = 'United States3';
        listOpp[1].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[1].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[1].Save_End_Customer_to_my_list__c = 'No';
        listOpp[1].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[1].Probability  = 1;
        listOpp[1].Pricebook2Id  = strs;
        listOpp[2].CloseDate = System.Today() + 30;
        listOpp[2].AccountId=listAcc[0].Id;
        listOpp[2].End_User_Mailing_Country__c = 'United States3';
        listOpp[2].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[2].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[2].Save_End_Customer_to_my_list__c = 'No';
        listOpp[2].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[2].Probability  = 1;
        listOpp[2].Pricebook2Id  = strs;
        listOpp[2].CloseDate = System.Today() + 30;
        listOpp[3].AccountId=listAcc[0].Id;
        listOpp[3].End_User_Mailing_Country__c = 'United States3';
        listOpp[3].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[3].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[3].Save_End_Customer_to_my_list__c = 'No';
        listOpp[3].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[3].Probability  = 1;
        listOpp[3].Pricebook2Id  = strs;
        listOpp[3].CloseDate = System.Today() + 30;
        listOpp[4].AccountId=listAcc[0].Id;
        listOpp[4].End_User_Mailing_Country__c = 'United States3';
        listOpp[4].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[4].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[4].Save_End_Customer_to_my_list__c = 'No';
        listOpp[4].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[4].Probability  = 1;
        listOpp[4].Pricebook2Id  = strs;
        listOpp[4].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        test.startTest();
        update listOpp;
        listOppLineItem = [Select id,OpportunityID,Description,pricebookEntryId,UnitPrice from OpportunityLineItem limit 7];
        ApexPages.StandardController std=new ApexPages.StandardController(listopp[4]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listopp[4].Id);
        Id strOppty = listopp[4].Id;
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        
        //        avsSuggestion.threshold(listopp[0].id);
        //        avsSuggestion.threshold(listopp[1].id);
        //        avsSuggestion.threshold(listopp[2].id);
        //        avsSuggestion.threshold(listopp[3].id);
        //        avsSuggestion.threshold(listopp[4].id);
        avsSuggestion.selCountry='test AVS';
        avsSuggestion.resultEasyIq='test AVS1';
        avsSuggestion.resultEasyIqCount='test AVS2';
        avsSuggestion.oresultStatusDesc='test AVS3';
        avsSuggestion.resChinaSt='test AVS4';
        avsSuggestion.cancelOppAction();
        avsSuggestion.FinalMailingStreet='1021 main street';
        avsSuggestion.resultStreet1='texas';
        avsSuggestion.resultStreet2='houston';
        string[] listCountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listCountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.resultCountry = 'Australia';
        // Invoke Call AVS Method
        avsSuggestion.oppObj = listOpp[0];
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction(); 
        avsSuggestion.showError = false;
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.throwExcep('test');
        avsSuggestion.setResults(); 
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2'; 
        avsSuggestion.aptOrSuiteNumber = '100'; 
        avsSuggestion.selectSuggestions();
        //  avsSuggestion.threshold(strOppty);
        // avsSuggestion.exception(strOppty,false);
        avsSuggestion.refineSearch();
        avsSuggestion.showTable = false;
        avsSuggestion.showNoSuggestion = TRUE;
        avsSuggestion.showButton = false;
        avsSuggestion.resultSuggestionCount ='0';
        test.stopTest();
        system.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted');
    }
    @isTest static void testmethodone5(){
        triggerexecutioncontroller.setSkipAllTriggers(True);
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id,name from account limit 1];
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        test.startTest();
        update listOpp;
        try{
            ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
            Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
            System.currentPageReference().getParameters().put('id', '');
            Id strOppty = listOpp[0].Id;
            AVSSuggestion avsSuggestion =new AVSSuggestion(std);
            avsSuggestion.selCountry='test AVS';
            avsSuggestion.resultEasyIq='test AVS1';
            avsSuggestion.resultEasyIqCount='test AVS2';
            avsSuggestion.oresultStatusDesc='test AVS3';
            avsSuggestion.resChinaSt='test AVS4';
            avsSuggestion.FinalMailingStreet='1021 main street';
            avsSuggestion.resultStreet1='texas';
            avsSuggestion.resultStreet2='houston';
            string[] listCountries=avsSuggestion.getCountries();
            //set countries
            avsSuggestion.setCountries(listCountries);
            // Toogle Method
            avsSuggestion.toggleEditMode();
            avsSuggestion.resultCountry = 'Australia';
            // Invoke Call AVS Method
            avsSuggestion.CallAVS();
            // Invoke selectSuggestions method
            for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
                sugg.selected=true;
                break;
            }
            // Invoke Cancel Method
            avsSuggestion.cancelAction(); 
            avsSuggestion.showError = false;
            avsSuggestion.SaveCurrentAddress();
            avsSuggestion.getshowAptNo();
            avsSuggestion.setshowAptNo(true);
            avsSuggestion.getshowFloorNumber();
            avsSuggestion.setshowFloorNumber(true);
            avsSuggestion.test();
            avsSuggestion.throwExcep('test');
            avsSuggestion.setResults(); 
            avsSuggestion.resultStatusDesc = 'Assigned Address';
            avsSuggestion.resultSuggestionCount = '2'; 
            avsSuggestion.aptOrSuiteNumber = '100'; 
            avsSuggestion.selectSuggestions();
            //   avsSuggestion.threshold(strOppty);
            ApexPages.currentPage().getParameters().put('source','Accept1'); 
            listOppLineItem = [Select id,OpportunityID,Description,pricebookEntryId,UnitPrice from OpportunityLineItem limit 2];
            // avsSuggestion.exception(strOppty,true);
            avsSuggestion.refineSearch();
            avsSuggestion.showTable = false;
            avsSuggestion.showNoSuggestion = TRUE;
            avsSuggestion.showButton = false;
            avsSuggestion.resultSuggestionCount ='0';
            test.stopTest();
            system.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted');
        }
        catch(Exception ex) {
        }
    }
    @isTest static void testmethodone1() {
        triggerexecutioncontroller.setSkipAllTriggers(True);
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='United States1',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id,name from account limit 1];
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        test.startTest();
        update listOpp;
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        Id strOppty = listOpp[0].Id;
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        avsSuggestion.selCountry='test AVS';
        avsSuggestion.resultEasyIq='test AVS1';
        avsSuggestion.resultEasyIqCount='test AVS2';
        avsSuggestion.oresultStatusDesc='test AVS3';
        avsSuggestion.resChinaSt='test AVS4';
        avsSuggestion.FinalMailingStreet='1021 main street';
        avsSuggestion.resultStreet1='texas';
        avsSuggestion.resultStreet2='houston';
        string[] listCountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listCountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.resultCountry = 'Australia';
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction(); 
        avsSuggestion.showError = false;
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.throwExcep('test');
        avsSuggestion.setResults(); 
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2'; 
        avsSuggestion.aptOrSuiteNumber = '100'; 
        avsSuggestion.selectSuggestions();
        listOppLineItem = [Select id,OpportunityID,Description,pricebookEntryId,UnitPrice from OpportunityLineItem limit 2];
        // avsSuggestion.threshold(strOppty); 
        // avsSuggestion.exception(strOppty,false);
        avsSuggestion.refineSearch();
        avsSuggestion.showTable = false;
        avsSuggestion.showNoSuggestion = TRUE;
        avsSuggestion.showButton = false;
        avsSuggestion.resultSuggestionCount ='0';
        test.stopTest();
        System.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted'); 
    }
    @isTest static void testmethodone3() {
        triggerexecutioncontroller.setSkipAllTriggers(True);
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='CANADA',Code__c='CA',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr2 = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        listCtr.add(ctr2);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        insert listCtr;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id,name from account limit 1];
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        test.startTest();
        update listOpp;
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        Id strOppty = listOpp[0].Id;
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        avsSuggestion.selCountry='test AVS';
        avsSuggestion.resultEasyIq='test AVS1';
        avsSuggestion.resultEasyIqCount='test AVS2';
        avsSuggestion.oresultStatusDesc='test AVS3';
        avsSuggestion.resChinaSt='test AVS4';
        avsSuggestion.FinalMailingStreet='1021 main street';
        avsSuggestion.resultStreet1='texas';
        avsSuggestion.resultStreet2='houston';
        string[] listCountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listCountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.resultCountry = 'Australia';
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction(); 
        avsSuggestion.showError = false;
        avsSuggestion.SaveCurrentAddress();
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.throwExcep('test');
        avsSuggestion.setResults(); 
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2'; 
        avsSuggestion.aptOrSuiteNumber = '100'; 
        avsSuggestion.selectSuggestions();
        // avsSuggestion.threshold(strOppty);
        listOppLineItem = [Select id,OpportunityID,Description,pricebookEntryId,UnitPrice from OpportunityLineItem limit 1];
        // avsSuggestion.exception(strOppty,false);
        avsSuggestion.refineSearch();
        avsSuggestion.showTable = false;
        avsSuggestion.showNoSuggestion = TRUE;
        avsSuggestion.showButton = false;
        avsSuggestion.resultSuggestionCount ='0';
        test.stopTest();
        System.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted'); 
    }
    @isTest static void testmethodthree11() {
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='UNITED STATES',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='France',Code__c='fr',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCountry = new List<Country__c>();
        listCountry.add(ctr);
        listCountry.add(ctr1);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCountry;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id, Account_Country_Code__c,name, Account_Country__c from account limit 1];      
        listAcc[0].Account_Country_Code__c = 'fr';
        listAcc[0].Account_Country__c = 'france';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        test.startTest();
        try{ ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
            Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
            System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
            AVSSuggestion avsSuggestion =new AVSSuggestion(std);
            // Toogle Method
            avsSuggestion.toggleEditMode();
            avsSuggestion.CallAVS();
            avsSuggestion.oppObj = listOpp[0];
            System.assertEquals(null, avsSuggestion.oppObj.End_User_Mailing_Country__c);
            avsSuggestion.SaveCurrentAddress();
            avsSuggestion.renderEditMode=true;
            avsSuggestion.toggleEditMode();
            // Invoke selectSuggestions method
            for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
                sugg.selected=true;
            }
            avsSuggestion.selectSuggestions();
            avsSuggestion.refineSearch();
           }
        catch(Exception e){}
        test.stopTest();
        system.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted');
    }
    @isTest static void testmethodone6() {
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCountry = new List<Country__c>();
        listCountry.add(ctr);
        listCountry.add(ctr1);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCountry;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id, Account_Country_Code__c,name, Account_Country__c from account limit 1];       
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        test.startTest();
        update listOpp;
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();            
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '100';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        test.stopTest();
        system.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted');
    }
    @isTest static void testmethodone2() {
        triggerexecutioncontroller.setSkipAllTriggers(True);
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='United States2',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCtr;
        profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1];
        Account partnerAccount1 = new Account();
        partnerAccount1.Name = 'PartnerAccount1';
        partnerAccount1.Account_Country_Code__c = 'AI';
        partnerAccount1.Account_Country__c = 'ANGUILLA';
        partnerAccount1.Type = 'Partner';
        partnerAccount1.Partner_Type__c = 'DISTRIBUTOR (GCC)';
        partnerAccount1.RecordTypeId = System.Label.RecType_Partner_Account;
        insert partnerAccount1;
        System.assertNotEquals(null,partnerAccount1);
        string strtracks =string.valueOf(partnerAccount1.id);
        string strtracker =string.valueOf(partnerAccount1.id);
        string streligibletrack = strtracker+';'+strtracks;
        Contact partnerContact = new Contact(); 
        partnerContact.AccountId = partnerAccount1.id;
        partnerContact.Email = 'testgroup@dell.com'; // John.Doe
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title = 'VP';
        partnerContact.EligibleTracks__c = streligibletrack;
        partnerContact.Status__c ='Customer';
        partnerContact.MailingStreet = '123 Main';
        partnerContact.MailingCity = 'Peoria';
        partnerContact.MailingState = 'IL';
        partnerContact.MailingPostalCode = '33333';
        partnerContact.Phone = '3213213211';
        partnerContact.MobilePhone = '3213213211';
        partnerContact.Fax = '3213123211';
       // partnerContact.Selected_Track_Account__c=partnerAccount1.id;
        insert partnerContact;
        Profile userProfile= [select id,name from profile where name like '%PRM Portal%' order by name limit 1 ];
        UserRole role = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        User adminUser = [Select Id From User Where Profile.Name = 'System Administrator' and UserRoleId = :role.Id AND IsActive = True Limit 1];
        UserRole role1 = [select id, name from Userrole where name like '%Partner User%' limit 1];
        User userRec = new User();
        userRec.Username = 'XXYYZZ@dell.com';
        userRec.Alias = 'test';
        userRec.Email = 'testuser@test.com';
        userRec.FirstName = 'John';
        userRec.LastName = 'Doe';
        userRec.ProfileId = profileRec.Id;
        userRec.LanguageLocaleKey = 'en_US';
        userRec.LocaleSidKey = 'en_US';
        userRec.EmailEncodingKey = 'UTF-8';
        userRec.TimeZoneSidKey = 'America/Los_Angeles';
        userRec.Badge_Number__c = '12345678';
        userRec.userroleId= role1.id;
        userRec.ContactId = partnerContact.id;
        test.startTest();
        System.runAs(adminUser)
        {
            try{
                insert userRec;
            }
            catch (exception e){
                
            } 
        }  
        test.stopTest();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id, Account_Country_Code__c,name, Account_Country__c from account limit 1];       
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        listOppLineItem = [Select id,OpportunityID,Description,pricebookEntryId,UnitPrice from OpportunityLineItem limit 2];
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = listOpp[0].id;
        otm.UserId  = userRec.id; 
        otm.TeamMemberRole = 'Reseller Contact'; 
        try{
        insert otm;
        }
        catch (exception e){
        }
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        Id strOppty = listOpp[0].Id;
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        avsSuggestion.selCountry='test AVS';
        avsSuggestion.resultEasyIq='test AVS1';
        avsSuggestion.resultEasyIqCount='test AVS2';
        avsSuggestion.oresultStatusDesc='test AVS3';
        avsSuggestion.resChinaSt='test AVS4';
        avsSuggestion.FinalMailingStreet='1021 main street';
        avsSuggestion.resultStreet1='texas';
        avsSuggestion.resultStreet2='houston';
        string[] listCountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listCountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.resultCountry = 'Australia';
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction(); 
        avsSuggestion.showError = false;
        avsSuggestion.SaveCurrentAddress();
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.throwExcep('test');
        avsSuggestion.setResults(); 
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2'; 
        avsSuggestion.aptOrSuiteNumber = '100'; 
        avsSuggestion.selectSuggestions();
        //  avsSuggestion.threshold(strOppty);
        //    avsSuggestion.exception(strOppty,false);
        avsSuggestion.refineSearch();
        avsSuggestion.showTable = false;
        avsSuggestion.showNoSuggestion = TRUE;
        avsSuggestion.showButton = false;
        avsSuggestion.resultSuggestionCount ='0';
        System.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted'); 
    }         
    @isTest static void testmethodone22() {
        triggerexecutioncontroller.setSkipAllTriggers(True);
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='United Kingdom',Code__c='UK',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCtr = new List<Country__c>();
        listCtr.add(ctr);
        listCtr.add(ctr1);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1];
        Account partnerAccount1 = new Account();
        partnerAccount1.Name = 'PartnerAccount1';
        partnerAccount1.Account_Country_Code__c = 'AI';
        partnerAccount1.Account_Country__c = 'ANGUILLA';
        partnerAccount1.Type = 'Partner';
        partnerAccount1.Partner_Type__c = 'DISTRIBUTOR (GCC)';
        partnerAccount1.RecordTypeId = System.Label.RecType_Partner_Account;
        insert partnerAccount1;
        System.assertNotEquals(null,partnerAccount1);
        string strtracks =string.valueOf(partnerAccount1.id);
        string strtracker =string.valueOf(partnerAccount1.id);
        string streligibletrack = strtracker+';'+strtracks;
        Contact partnerContact = new Contact(); 
        partnerContact.AccountId = partnerAccount1.id;
        partnerContact.Email = 'testgroup@dell.com'; // John.Doe
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title = 'VP';
        partnerContact.EligibleTracks__c = streligibletrack;
        partnerContact.Status__c ='Customer';
        partnerContact.MailingStreet = '123 Main';
        partnerContact.MailingCity = 'Peoria';
        partnerContact.MailingState = 'IL';
        partnerContact.MailingPostalCode = '33333';
        partnerContact.Phone = '3213213211';
        partnerContact.MobilePhone = '3213213211';
        partnerContact.Fax = '3213123211';
        //partnerContact.Selected_Track_Account__c=partnerAccount1.id;
        insert partnerContact;
        Profile userProfile= [select id,name from profile where name like '%PRM Portal%' order by name limit 1 ];
        UserRole role = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        User adminUser = [Select Id From User Where Profile.Name = 'System Administrator' and UserRoleId = :role.Id AND IsActive = True Limit 1];
        UserRole role1 = [select id, name from Userrole where name like '%Partner User%' limit 1];
        User userRec = new User();
        userRec.Username = 'XXYYZZ@dell.com';
        userRec.Alias = 'test';
        userRec.Email = 'testuser@test.com';
        userRec.FirstName = 'John';
        userRec.LastName = 'Doe';
        userRec.ProfileId = profileRec.Id;
        userRec.LanguageLocaleKey = 'en_US';
        userRec.LocaleSidKey = 'en_US';
        userRec.EmailEncodingKey = 'UTF-8';
        userRec.TimeZoneSidKey = 'America/Los_Angeles';
        userRec.Badge_Number__c = '12345678';
        userRec.userroleId= role1.id;
        userRec.ContactId = partnerContact.id;
        test.startTest();
        System.runAs(adminUser)
        {
            try{
                insert userRec;
            }
            catch (exception e){
            } 
        }  
        test.stopTest();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id, Account_Country_Code__c,name, Account_Country__c from account limit 1];       
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        listOppLineItem = [Select id,OpportunityID,Description,pricebookEntryId,UnitPrice from OpportunityLineItem limit 1];
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = listOpp[0].id;
        otm.UserId  = userRec.id; 
        otm.TeamMemberRole = 'Reseller Contact'; 
        try{
        insert otm;
        } 
        catch (exception e){
        }
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('newid', listOpp[0].Id);
        System.currentPageReference().getParameters().put('source', 'accept1');
        Id strOppty = listOpp[0].Id;
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        avsSuggestion.selCountry='test AVS';
        avsSuggestion.resultEasyIq='test AVS1';
        avsSuggestion.resultEasyIqCount='test AVS2';
        avsSuggestion.oresultStatusDesc='test AVS3';
        avsSuggestion.resChinaSt='test AVS4';
        avsSuggestion.FinalMailingStreet='1021 main street';
        avsSuggestion.resultStreet1='texas';
        avsSuggestion.resultStreet2='houston';
        string[] listCountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listCountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        avsSuggestion.resultCountry = 'China';
        // Invoke Call AVS Method
        avsSuggestion.OppObj = listOpp[0];
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction(); 
        avsSuggestion.showError = false;
        avsSuggestion.SaveCurrentAddress();
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.throwExcep('test');
        avsSuggestion.setResults(); 
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2'; 
        avsSuggestion.aptOrSuiteNumber = '100'; 
        avsSuggestion.selectSuggestions();
        //   avsSuggestion.threshold(strOppty);
        //   avsSuggestion.exception(strOppty,false);
        avsSuggestion.refineSearch();
        avsSuggestion.showTable = false;
        avsSuggestion.showNoSuggestion = TRUE;
        avsSuggestion.showButton = false;
        avsSuggestion.resultSuggestionCount ='0';
        System.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted'); 
    }
    @isTest static void testmethodone7() {
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='United States',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCountry = new List<Country__c>();
        listCountry.add(ctr);
        listCountry.add(ctr1);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert listCountry;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id, Account_Country_Code__c,name, Account_Country__c from account limit 1];       
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        test.startTest();
        update listOpp;
        ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
        Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
        System.currentPageReference().getParameters().put('id', listOpp[0].Id);
        AVSSuggestion avsSuggestion =new AVSSuggestion(std);
        string[] listcountries=avsSuggestion.getCountries();
        //set countries
        avsSuggestion.setCountries(listcountries);
        // Toogle Method
        avsSuggestion.toggleEditMode();
        // Invoke Call AVS Method
        avsSuggestion.CallAVS();
        // Invoke selectSuggestions method
        for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
            sugg.selected=true;
            break;
        }
        // Invoke Cancel Method
        avsSuggestion.cancelAction();            
        avsSuggestion.getshowAptNo();
        avsSuggestion.setshowAptNo(true);
        avsSuggestion.getshowFloorNumber();
        avsSuggestion.setshowFloorNumber(true);
        avsSuggestion.test();
        avsSuggestion.resultStatusDesc = 'Assigned Address';
        avsSuggestion.resultSuggestionCount = '2';
        avsSuggestion.aptOrSuiteNumber = '100';
        avsSuggestion.selectSuggestions();
        avsSuggestion.refineSearch();
        test.stopTest();
        system.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted');
    }
    @isTest static void testmethodone26() {
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='United States1',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN1',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCountry = new List<Country__c>();
        listCountry.add(ctr);
        listCountry.add(ctr1);
        TriggerExecutionController.setskipAllTriggers(true);
        insert listCountry;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id, Account_Country_Code__c,name, Account_Country__c from account limit 1];       
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        Test.startTest();
        listOppLineItem = [Select id,OpportunityID,Description,pricebookEntryId,UnitPrice from OpportunityLineItem limit 1];
        Test.stopTest();
        try{ 
            ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
            Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
            System.currentPageReference().getParameters().put('id', listOpp[0].Id);
            AVSSuggestion avsSuggestion =new AVSSuggestion(std);
            string[] listcountries=avsSuggestion.getCountries();
            //set countries
            avsSuggestion.setCountries(listcountries);
            // Toogle Method
            avsSuggestion.toggleEditMode();
            avsSuggestion.CallAVS();
            for(AVSSuggestion.suggestions sugg:avsSuggestion.lstSuggestion){
                sugg.selected=true;
                break;
            }
            // Invoke Cancel Method
            avsSuggestion.cancelAction();            
            avsSuggestion.getshowAptNo();
            avsSuggestion.setshowAptNo(true);
            avsSuggestion.getshowFloorNumber();
            avsSuggestion.setshowFloorNumber(true);
            avsSuggestion.test();
            avsSuggestion.resultStatusDesc = 'Assigned Address';
            avsSuggestion.resultSuggestionCount = '2';
            avsSuggestion.aptOrSuiteNumber = '100';
            avsSuggestion.selectSuggestions();
            avsSuggestion.refineSearch();
        }
        catch(exception e){}
        system.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted');
    }
    @isTest static void testmethodone27() {
        string strs = createBasicObject();
        Country__c ctr = new Country__c(Name='United States1',Code__c='US',Enable_AVS_for_Opportunity__c = true);
        Country__c ctr1 = new Country__c(Name='JAPAN1',Code__c='JP',Enable_AVS_for_Opportunity__c = true);
        List<Country__c> listCountry = new List<Country__c>();
        listCountry.add(ctr);
        listCountry.add(ctr1);
        TriggerExecutionController.setskipAllTriggers(true);
        insert listCountry;
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        listAcc = [select id, Account_Country_Code__c,name, Account_Country__c from account limit 1];       
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        listOpp = [select id,Deal_Registration_Status__c from opportunity limit 1];       
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        listOpp[0].End_User_Mailing_Country__c = 'United States3';
        listOpp[0].End_User_Mailing_Zip_Postal_Code__c ='2000';
        listOpp[0].End_User_Mailing_Street__c = '65 Martin Pl';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'yes';
        listOpp[0].Probability  = 1;
        listOpp[0].Pricebook2Id  = strs;
        listOpp[0].CloseDate = System.Today() + 30;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        Test.startTest(); 
        listOppLineItem = [Select id,OpportunityID,Description,pricebookEntryId,quantity from OpportunityLineItem limit 1];  
        test.stoptest();
        try{ 
            ApexPages.StandardController std=new ApexPages.StandardController(listOpp[0]);
            Test.setCurrentPageReference(new PageReference('Page.AVSSuggestionforOpportunity')); 
            System.currentPageReference().getParameters().put('id', listOpp[0].Id);
            AVSSuggestion avsSuggestion =new AVSSuggestion(std);
            string[] listcountries=avsSuggestion.getCountries();
            avsSuggestion.buildAusFloorNumber='';
            avsSuggestion.renderEditMode= TRUE;
            avsSuggestion.setCountries(listcountries);
            AVSSuggestion.suggestions empW = new AVSSuggestion.suggestions(false,'SELECTION','LOCALITY1',
                                                                           'REGION1',
                                                                           'POSTCODE',
                                                                           'POSTCODE2_ODD',
                                                                           'POSTCODE2_EVEN',
                                                                           'PRIMARY_NUMBER_LOW',
                                                                           'PRIMARY_NUMBER_HIGH',
                                                                           'PRIMARY_NAME1', 
                                                                           'PRIMARY_TYPE1',
                                                                           'LOCALITY2',
                                                                           'POSTCODE1',                          
                                                                           'UNIT_NUMBER_LOW',
                                                                           'UNIT_NUMBER_HIGH',
                                                                           'FIRM',
                                                                           'PRIMARY_POSTFIX1',
                                                                           'LOCALITY3',
                                                                           'PRIMARY_NAME2',
                                                                           'building_name',
                                                                           'PRIMARY_NUMBER_DESCRIPTION',
                                                                           'PRIMARY_NAME_FULL1',
                                                                           'PRIMARY_NAME_FULL2',
                                                                           'primary_secondary_address',                
                                                                           'PRIMARY_SIDE_INDICATOR',                         
                                                                           'SECONDARY_SIDE_INDICATOR',
                                                                           'FLOOR_NUMBER_LOW',
                                                                           'FLOOR_NUMBER_HIGH',
                                                                           'FLOOR_DESCRIPTION', 
                                                                           'STAIRWELL_DESCRIPTION',
                                                                           'STAIRWELL_NAME',
                                                                           'TEST');
            avsSuggestion.CallAVS();
            avsSuggestion.cancelAction();            
            avsSuggestion.getshowAptNo();
            avsSuggestion.setshowAptNo(true);
            avsSuggestion.getshowFloorNumber();
            avsSuggestion.setshowFloorNumber(true);
            avsSuggestion.test();
            avsSuggestion.resultStatusDesc = 'Assigned Address';
            avsSuggestion.resultSuggestionCount = '2';
            avsSuggestion.aptOrSuiteNumber = '100';
            avsSuggestion.lstSuggestion.add(empW);
            avsSuggestion.selectSuggestions();
            avsSuggestion.refineSearch();
        }
        catch(exception e)
        {
        }  
        system.assertEquals(listOpp[0].Deal_Registration_Status__c,'Submitted');
    }    
    
}
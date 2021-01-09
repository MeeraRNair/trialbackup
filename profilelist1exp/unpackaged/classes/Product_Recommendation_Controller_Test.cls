@isTest 
global class Product_Recommendation_Controller_Test{

    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert oWDsetting;
    }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
    
    //Fetching custom settings for OWD
    static OWD__c owd = OWD__c.getOrgDefaults();

    static testMethod void testPageFunctionality(){
        TriggerExecutionController.setSkipAccountTriggers(true); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);        
        Account testAccount = new Account(Name='Test SAVO Account');        
        insert testAccount;     
        
        //Create Opportunity
        Opportunity testOpp = new Opportunity(Name='Test SAVO Opportunity', AccountId=testAccount.Id,RecordTypeId =     GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp;

        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newProd = new Product2(Name = 'Test Product1',ProductCode = 'TP1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE, Product_ID__c= '12345');                      
        insert newProd;
        
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newProd.id,Pricebook2ID=pbk1,isActive=true,useStandardPrice=false,UnitPrice = 50);                                      
        insert pBE1;
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOpp.Id,pricebookEntryId=pBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1'); 
        insert testLineItem;
        
        Octane_Config_Settings__c objCustomProduction = new Octane_Config_Settings__c(Name='Production',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME');
        insert objCustomProduction;
        Octane_Config_Settings__c objCustomSandbox = new Octane_Config_Settings__c(Name='Sandbox',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME');
        insert objCustomSandbox;
       
        PageReference pageRef = Page.Product_Recommendation;
        Test.setCurrentPage(pageRef);
        System.assertEquals('/apex/product_recommendation',pageRef.getURL());
        Apexpages.currentpage().getparameters().put('id',testLineItem.Id);
		Product_Recommendation_Controller.recommendationWrapper rw = new Product_Recommendation_Controller.recommendationWrapper('Test');
		rw.bIsChecked = true;
        Product_Recommendation_Controller objCon = new Product_Recommendation_Controller();
		objCon.lstData.add(rw);
        objCon.init();
		objCon.createOli();
		rw.bIsChecked = false;
		objCon.createOli();
		rw.dcUnitPrice = 10;
		rw.dcQuantity = 20;
		rw.oli = new OpportunityLineItem();
		rw.oli.Service_Support_US__c = 'ProSupport';
		objCon.createOli();
		System.assert(objCon.listOfOli.size() == 0);
        
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false); 
    }
	
	static testMethod void testPageFunctionality1(){
        TriggerExecutionController.setSkipAccountTriggers(true); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);        
        Account testAccount = new Account(Name='Test SAVO Account');        
        insert testAccount;     
        
        //Create Opportunity
        Opportunity testOpp = new Opportunity(Name='Test SAVO Opportunity', AccountId=testAccount.Id,RecordTypeId =     GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
        insert testOpp;

        Id pbk1 = Test.getStandardPricebookId();
    
        Product2 newProd = new Product2(Name = 'Test Product1',ProductCode = 'TP1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE, Product_ID__c= '12345');                      
        insert newProd;
        
        PricebookEntry pBE1= new PricebookEntry (Product2ID=newProd.id,Pricebook2ID=pbk1,isActive=true,useStandardPrice=false,UnitPrice = 50);                                      
        insert pBE1;
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOpp.Id,pricebookEntryId=pBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1'); 
        insert testLineItem;
        
        Octane_Config_Settings__c objCustomProduction = new Octane_Config_Settings__c(Name='Production',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME');
        insert objCustomProduction;
        Octane_Config_Settings__c objCustomSandbox = new Octane_Config_Settings__c(Name='Sandbox',Enable_Disable_Group_Access__c=true,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME');
        insert objCustomSandbox;
       
        PageReference pageRef = Page.Product_Recommendation;
        Test.setCurrentPage(pageRef);
        System.assertEquals('/apex/product_recommendation',pageRef.getURL());
        Apexpages.currentpage().getparameters().put('id',testLineItem.Id);
		Product_Recommendation_Controller.recommendationWrapper rw = new Product_Recommendation_Controller.recommendationWrapper('Test');
		rw.bIsChecked = true;
		rw.dcUnitPrice = 10;
		rw.dcQuantity = 20;
		rw.oli = new OpportunityLineItem();
		rw.oli.Service_Support_US__c = 'ProSupport';
        Product_Recommendation_Controller objCon = new Product_Recommendation_Controller();
		objCon.lstData.add(rw);
        objCon.init();
		objCon.createOli();
		System.assert(objCon.listOfOli.size() > 0);
        
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false); 
    }
	
    static testMethod void testPageFunctionalityNonAccess(){
        TriggerExecutionController.setSkipAccountTriggers(true); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'eapuser', Email='eapuser@dell.com',EmailEncodingKey='UTF-8', LastName='eapuser', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='eapuser@dell.com',Badge_Number__c='10321');
        System.runAs(u){
            Account testAccount = new Account(Name='Test SAVO Account');        
            insert testAccount;     
            
            //Create Opportunity
            Opportunity testOpp = new Opportunity(Name='Test SAVO Opportunity', AccountId=testAccount.Id,RecordTypeId =     GlobalVariables.STANDARD_OPP_RECTYPE,StageName=owd.Oppty_Stage10__c,CloseDate = System.Today() + 30 );                                      
            insert testOpp;

            Id pbk1 = Test.getStandardPricebookId();
        
            Product2 newProd = new Product2(Name = 'Test Product1',ProductCode = 'TP1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE, Product_ID__c= '12345');                      
            insert newProd;
            
            PricebookEntry pBE1= new PricebookEntry (Product2ID=newProd.id,Pricebook2ID=pbk1,isActive=true,useStandardPrice=false,UnitPrice = 50);                                      
            insert pBE1;
            
            OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOpp.Id,pricebookEntryId=pBE1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100,Quantity =2,Description = 'Line Description1'); 
            insert testLineItem;
            
            Octane_Config_Settings__c objCustomProduction = new Octane_Config_Settings__c(Name='Production',Enable_Disable_Group_Access__c=false,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME');
            insert objCustomProduction;
            Octane_Config_Settings__c objCustomSandbox = new Octane_Config_Settings__c(Name='Sandbox',Enable_Disable_Group_Access__c=false,Endpoint__c='http://testendpoint.com',Password__c='abcd1234',User_Name__c='testUserNAME');
            insert objCustomSandbox;
           
            PageReference pageRef = Page.Product_Recommendation;
            Test.setCurrentPage(pageRef);
            System.assertEquals('/apex/product_recommendation',pageRef.getURL());
            Apexpages.currentpage().getparameters().put('id',testLineItem.Id);
            Product_Recommendation_Controller objConOne = new Product_Recommendation_Controller();
            objConOne.init();
        }
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
    }
	
	public static void testLookUpUserAccess()
	{
		Product_Recommendation_Controller prc = new Product_Recommendation_Controller();
		prc.lookUpUserAccess(UserInfo.getUserId());
	}
}
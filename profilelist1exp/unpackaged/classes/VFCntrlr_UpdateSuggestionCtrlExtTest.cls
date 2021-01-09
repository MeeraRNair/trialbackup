@isTest
private class VFCntrlr_UpdateSuggestionCtrlExtTest {

    //Define class variables
    static Account testAccount;
    static Country__c testCountry; 
    static boolean btestDataCreated=false;
    static Id rectype = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead',true);

    //Test Method 1: 
    public static testMethod void testVFCntrlrUpdateSuggestionCtrlExtnavigateToLeadnewLead() {
        //Test method for the Conitinue without entering data
        System.debug('#KP:START of testVFCntrlrUpdateSuggestionCtrlExtnavigateToLeadnewLead()');
        
        //Create Test Data 
        if(!btestDataCreated){
        
        createTestData();       
        
        PageReference pageRef = Page.UpdateAccountSuggestion;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testAccount.id);
        
        Test.startTest();
        //Instantiate a new controller with all parameters in the page
        ApexPages.StandardController con = new ApexPages.StandardController(testAccount);
        VFCntrlr_UpdateSuggestionCtrlExt controller = new VFCntrlr_UpdateSuggestionCtrlExt(con);
        String strretURLActual = controller.navigateToLead().getURL();
        Test.stopTest();
        
        Lead suggestionLead =  [SELECT id,Account__c, Status 
                                FROM Lead
                                WHERE Account__c=:testAccount.Id AND OwnerId=:Userinfo.getUserId() AND RecordTypeId=:rectype
                                AND Status='Open' LIMIT 1];
        
        
        
        String strurlTobeTested = '/'+suggestionLead.id+'/e?cancelURL='+testAccount.Id
                    +'&retURL='+suggestionLead.id
                    +'&save_new_url='+suggestionLead.id; 
                    
        System.debug('###retURL: '+strretURLActual);
        //Asserts the value of returnURL
        System.assertEquals(strretURLActual, strurlTobeTested);  
        System.debug('#KP:END of testVFCntrlr_UpdateSuggestionCtrlExt_navigateToLead_newLead()');
        }
    }
    
    //Test Method 2:
    public static testMethod void testVFCntrlrUpdateSuggestionCtrlExtnavigateToLeadexistingLead() {
        //Test method for the Conitinue without entering data
        System.debug('#KP:START of testVFCntrlrUpdateSuggestionCtrlExtnavigateToLeadexistingLead()');
        if(!btestDataCreated){
        createTestData();
        
        
        //Create Test Data 
        Lead suggestionLead=new Lead();
        suggestionLead.LastName = Userinfo.getLastname(); 
        suggestionLead.Company = 'Test Company';
        suggestionLead.Status = 'Draft';
        suggestionLead.Account__c = testAccount.id;
        suggestionLead.RecordTypeId =  IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead',true);      
        insert suggestionLead;

        PageReference pageRef = Page.UpdateAccountSuggestion;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testAccount.id);
        Test.startTest();
        
        //Instantiate a new controller with all parameters in the page
        ApexPages.StandardController con = new ApexPages.StandardController(testAccount);
        VFCntrlr_UpdateSuggestionCtrlExt controller = new VFCntrlr_UpdateSuggestionCtrlExt(con);
        String strretURLActual = controller.navigateToLead().getURL();
        Test.stopTest();
        
        
        String strurlTobeTested = '/'+suggestionLead.id+'/e?cancelURL='+testAccount.Id
                    +'&retURL='+suggestionLead.id
                    +'&save_new_url='+suggestionLead.id; 
                    
                    
        System.debug('###retURL: '+strretURLActual);
        //Asserts the value of returnURL
        System.assertEquals(strretURLActual, strurlTobeTested);
        System.debug('#KP:END of testVFCntrlr_UpdateSuggestionCtrlExt_navigateToLead_existingLead()');
    }
}
    //Create required Test Data   
    private static void createTestData(){
        testAccount = new Account(
                name='Test 1',
                Account_Country_Code__c = 'AI',
                Account_Country__c = 'ANGUILIA',  
                States_Provinces_doing_business__c = 'Test',
                BillingStreet = 'Line1\nLine2\nLine3',
                Software_Revenue_Percent__c = '11-20%',
                Service_Revenue_Percent__c = '11-20%',
                Product_Focus__c = 'Test focus',
                ShippingCountry = 'TY',
                Primary_Channel_Model__c = 'Reseller',
                Premier_Page_s_ID__c = 'Test page',         
                Percent_Technical_Professionals__c = '11-20%',
                Percent_Sales_Force__c = '11-20%',
                Partner_Type__c = 'Test type',
                Partner_Tier__c = 'Test tier',
                Partner_Relationship__c = 'Test Relatonship',
                Preferred_Dell_Distribution_Partner__c = 'Test prefer',
                Partner_Primary_Customer__c = 'Consumer',
                Partner_Description__c = 'Test desc',
                Last_4_Closed_Qtr_Rev_Workstations__c = .50,
                Last_4_Closed_Qtr_Rev_Servers__c = .50,
                Last_4_Closed_Qtr_Rev_Notebooks__c = .50,
                Last_4_Closed_Qtr_Rev_Imaging__c = .50,
                Last_4_Closed_Qtr_Rev_Desktops__c = .50,
                Hardware_Revenue_Percent__c = '11-20%',
                Form_of_Organization__c = 'Corporation',
                Dell_Revenue_Percent__c = '11-20%',
                Fiscal_Year_End__c = Date.today(),
                Account_ID__c = '333333'+System.currentTimeMillis());        
        insert testAccount;

        testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        
        btestDataCreated = true;
        System.debug('##KP:Account :'+testAccount);
       
    }
}
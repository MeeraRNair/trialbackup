/***********************************************************
* Name          : VFCntrlr_SFDCtoCOM 
* Description   : To redirect to COM
* ---------------------------------------------------------
* Revision      CR#                             Release      Name                             Date              Description
* 1.0           8553, 8570, 8671, 8572          14.10        Che Saidi, Shahiruni Wahida      04 Sept 2013      Creation
*
*
************************************************************/

@isTest
private class VFCntrlr_SFDCtoCOMTest {
    static List<Country__c> countryList=new List<Country__c>();
    static User testUser;
    static Profile profile;
    static Account testLatamAcc;
    static Country__c testCountry;
    static Country__c testCountry2;
    static VFCntrlr_SFDCtoCOM controller;
    static Map<String,String> paramMap = null;
    static String newCurrentParams;
    static User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    
    static testMethod void viewHistorytest(){
        Test.startTest();
        createTestData();
        
        newCurrentParams = Label.COM_URL+'?id=12345&action=viewhistory&country='+testCountry.Code__c+'&accountId='+testLatamAcc.Account_ID__c+'&dealId=deal123';
        PageReference  pr=new PageReference(newCurrentParams);
        Test.setCurrentPage(pr);
        
        controller=new VFCntrlr_SFDCtoCOM();
        controller.navToCOM();
        
        Test.stopTest();
    }
    
    
    static testMethod void missingRegionTest(){
        createTestData();
        try{
            Test.Starttest();
            
            newCurrentParams = Label.COM_URL+'?id=12345&action=viewhistory&country=CL&accountId='+testLatamAcc.Account_ID__c+'&dealId=deal123';
            PageReference  pr=new PageReference(newCurrentParams);
            Test.setCurrentPage(pr);
            
            controller=new VFCntrlr_SFDCtoCOM();
            controller.navToCOM();
            
            Test.Stoptest();
        }catch(Exception e){
          String errMsg = 'Country/Region not set up correctly';
          System.assert(e.getMessage().contains(errMsg));
        }  
    }
    
    
    static testMethod void missingCountryTest(){
        createTestData();
        try{
            Test.Starttest();
           
            newCurrentParams = Label.COM_URL+'?id=12345&action=viewhistory&country='+testCountry2.Code__c+'&accountId='+testLatamAcc.Account_ID__c+'&dealId=deal123';
            PageReference  pr=new PageReference(newCurrentParams);
            Test.setCurrentPage(pr);
            
            controller=new VFCntrlr_SFDCtoCOM();
            controller.navToCOM();
            
            Test.Stoptest();
        }catch(Exception e){
          String errMsg = 'Region not set up correctly';
          System.assert(e.getMessage().contains(errMsg));
        }  
    }
    
    static testMethod void missingCountryRegionTest(){
        createTestData();
        try{
            Test.Starttest();
           
            newCurrentParams = Label.COM_URL+'?id=12345&action=viewhistory&country=&accountId='+testLatamAcc.Account_ID__c+'&dealId=deal123';
            PageReference  pr=new PageReference(newCurrentParams);
            Test.setCurrentPage(pr);
            
            controller=new VFCntrlr_SFDCtoCOM();
            controller.navToCOM();
            
            Test.Stoptest();
        }catch(Exception e){
          String errMsg = 'Account Country Code is empty';
          System.assert(e.getMessage().contains(errMsg));
        }  
    }
    
    static testMethod void backActionTest() {
        Test.startTest();
        PageReference  pr=new PageReference(Label.COM_URL+'?id=backId');
        Test.setCurrentPage(pr);
        
        controller=new VFCntrlr_SFDCtoCOM();
        
        controller.back();
        Test.stopTest();
    }
    
    
    static void createTestData(){
    system.runas(thisUser){
        profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;
        
        testLatamAcc = new Account(Name='Test COM Account', Account_ID__c='77777', Account_Country_Code__c='CL');
        insert testLatamAcc;
            
        testCountry = new Country__c(Code__c='CL', Region__c='latam'); 
        testCountry2 = new Country__c(Code__c='MY', Region__c=''); 
        insert new list<Country__c>{testCountry, testCountry2};
        }
    }
}
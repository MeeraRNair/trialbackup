public with sharing class SalesMotionTriggerTest {
    
    static User userRecord1;
    
    static Sales_Motion__c testSM;

    static testMethod void Test_SalesMotionTrigger() {
        
    TestDataCreation(); 
    
    }
    
     static void TestDataCreation(){
          //Create a user with Standard User profile        
          Profile profile = [select id from profile where Name = 'System Administrator' limit 1];
        
          userRecord1 = new User(Username='testvaliduser2' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test212'+'@dell.com',            
                                    LastName='Test22',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Country='US',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert userRecord1;
        
        //Create Account using the user profile
        System.runAs(userRecord1){
            testSM = new Sales_Motion__c(Domain__c='TEST SM',Solution_Name__c='TEST SM',Solution_Type__c='TEST SM',SalesEdge_Category__c='AD-Assets');
            insert testSM;
        }
        
     }
    
    
    
}
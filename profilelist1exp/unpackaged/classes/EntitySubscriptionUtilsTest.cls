/*
History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
2.0    14-01-2015        Men Mee        CR12402 To improve code coverage
*/

@isTest
private class EntitySubscriptionUtilsTest {
    
    static testMethod void userSubscriptionTest() {
    
    Profile profile = [SELECT id from profile WHERE Name = 'Chatter Only Profile' LIMIT 1];

    collaborationgroup c = new collaborationgroup(name ='#SFDC ? Frequently Asked Questions (FAQ)',CollaborationType='Public');
    insert c;
    
    User testMD = new User(Username='testMD' +'@dell.com',
                        Alias = 'TestMD', 
                        Email='michael_dell@dell.com.sit2',            
                        LastName='TestMD',
                        Title='CEO', 
                        ProfileId = profile.Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US',  
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='Test23'+System.currentTimeMillis());
    TriggerExecutionController.setSkipUserTriggers(true);
    insert testMD;
    TriggerExecutionController.setSkipUserTriggers(false);                    
                         
    User testUser = new User(Username='testvuser01' +'@dell.com',
                        Alias = 'Test23', 
                        Email='Test23'+'@dell.com',            
                        LastName='Test23',
                        Title='GCC Program Manager', 
                        ProfileId = profile.Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US',  
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='Test23'+System.currentTimeMillis());
      
      Test.startTest();                  
      GlobalVariables.TEST_USER_SUBSCRIPTION = true;
      insert testUser;
      GlobalVariables.TEST_USER_SUBSCRIPTION = false;
      Test.stopTest();
    }
}
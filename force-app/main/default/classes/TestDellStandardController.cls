@IsTest
private class TestDellStandardController {
	
	private class ConcreteDellStandardController extends DellStandardController{}
	
    private static testmethod void testOption1HttpParameter(){
        System.runAs(createSysAdminUser('en_US')){
        	DellStandardController controller = new ConcreteDellStandardController();
            System.assertNotEquals('es', controller.getPreferredLanguageCode());  
            ApexPages.currentPage().getParameters().put('l','XXXXXXXX');
            System.assertNotEquals('es', controller.getPreferredLanguageCode());  
            ApexPages.currentPage().getParameters().put('l','es');
            System.assertEquals('es', controller.getPreferredLanguageCode()); 
            controller.getSupportedLanguageCodes();
        }
    }
    
    private static testmethod void testOption2BrowserSettings(){
        System.runAs(createSysAdminUser('en_US')){
        	DellStandardController controller = new ConcreteDellStandardController();
            System.assertNotEquals('es', controller.getPreferredLanguageCode());  
            ApexPages.currentPage().getHeaders().put('Accept-Language','XXXXXXXX');
            System.assertNotEquals('es', controller.getPreferredLanguageCode());  
            ApexPages.currentPage().getHeaders().put('Accept-Language','es');
            System.assertEquals('es', controller.getPreferredLanguageCode());
            ApexPages.currentPage().getHeaders().put('Accept-Language','es-mx');
            System.assertEquals('es', controller.getPreferredLanguageCode());
            ApexPages.currentPage().getHeaders().put('Accept-Language','en-us,zh-cn;q=0.5');
            System.assertEquals('en-us', controller.getPreferredLanguageCode());
            ApexPages.currentPage().getHeaders().put('Accept-Language','xxxxx,zh-cn;q=0.5');
            System.assertEquals('zh-cn', controller.getPreferredLanguageCode());
        }
    }
    
    private static User createSysAdminUser(String languageCode){
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        final Integer userNumber = 1;
        User user = new User(
            Username=''+userNumber+'@dell.com',
            Alias = 'test'+userNumber, 
            Email=''+userNumber+'@dell.com', 
            FirstName='John', 
            LastName='Doe'+userNumber, 
            ProfileId = profile.Id, 
            LanguageLocaleKey=languageCode, 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c=''+9005000+userNumber 
        );
        insert user;
        return user;
    }
}
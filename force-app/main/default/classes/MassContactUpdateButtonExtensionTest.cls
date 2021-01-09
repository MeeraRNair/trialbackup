@isTest
private class MassContactUpdateButtonExtensionTest {
   
    @testSetup static void createTestData() {
        
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Type = 'Partner'; 
        acc.Account_Country_Code__c='US';              
        insert acc;
        
        TriggerExecutionController.setSkipContactTriggers(true);
        
        Contact c = new Contact(AccountId=acc.Id, LastName='TestLastName', Email='testmc+1221@dell.com');
        insert c;
        
        TriggerExecutionController.setSkipContactTriggers(false);         
        
            
    }
    
        
    private static ApexPages.StandardSetController init(){
        
        String query= 'SELECT id,LastName,Account.Name FROM Contact Where Email = \'testmc+1221@dell.com\'';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(query));
        
        return setCtrl;
    }
    
    static testMethod void MassContactUpdateButtonExtensionCancel(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        MassContactUpdateButtonExtension stdController = new MassContactUpdateButtonExtension(controller);
        stdController.cancel();
        test.stopTest();
    }
    
    static testMethod void MassContactUpdateButtonExtensionRedirect(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        MassContactUpdateButtonExtension stdController = new MassContactUpdateButtonExtension(controller);
        stdController.redirectToMassUpdatePage();
        test.stopTest();
    }

    static testMethod void MassContactUpdateButtonExtensionRedirect02(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        MassContactUpdateButtonExtension stdController = new MassContactUpdateButtonExtension(controller);
        stdController.redirectToMassUpdatePage();
      
        test.stopTest();
    }
}
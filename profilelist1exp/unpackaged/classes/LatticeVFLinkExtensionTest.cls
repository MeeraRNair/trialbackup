@isTest
private class LatticeVFLinkExtensionTest {

    static testMethod void getMethodsTest() {
            
            //Create Test Data
            PageReference pageRef = Page.LatticeVFLink;
            Test.setCurrentPage(pageRef);
            Account testAccount_No1=new Account(name='testAccount_No1',Account_ID__c='323954',POET_Leads__c=4.0,POET_Open_Leads__c=4.0);
            Account testAccount_No2=new Account(name='testAccount_No2',Account_ID__c='999545',POET_Leads__c=4.0,POET_Open_Leads__c=4.0,Account_country_code__c='US');
            Account testAccount_No3=new Account(name='testAccount_No3',Account_ID__c='888545',POET_Leads__c=4.0,POET_Open_Leads__c=4.0,Account_country_code__c='UY');
            List<Account> accountList = new List<Account>();
            accountList.add(testAccount_No1);
            accountList.add(testAccount_No2);
            accountList.add(testAccount_No3);
            insert accountList;

            // Instantiate a new controller with all parameters in the page
            Test.startTest();
            ApexPages.StandardController con = new ApexPages.StandardController(testAccount_No1);
            LatticeVFLinkExtension controller = new LatticeVFLinkExtension(con);
            system.assertEquals(con.getRecord().getsObjectType(),Account.sObjectType);
           
            Test.stopTest();
            //Assert the values returned for get methods
            
            System.assertEquals(controller.getLinkToPrism(),'/apex/latticenoregionerror?errorStr=Please+ensure+account+country+is+set.&retURL=%2F'+testAccount_No1.id);
            
           // System.assertEquals(controller.getLinkToPrism(),'/apex/LatticeVFTab?prismAccountId=323954&sfdc.tabName=01rT00000004dOs');
            System.assertEquals(controller.getIsPrismAccount(), true);
            System.assertEquals(controller.getSummary(), '4/4');           
            
            ApexPages.StandardController con2 = new ApexPages.StandardController(testAccount_No2);
            LatticeVFLinkExtension controller2 = new LatticeVFLinkExtension(con2);          
           
           //Required to update tab id for each environment
            system.assertEquals(controller2.isForbiddenRegionFlag, false);
            System.assertEquals(controller2.paramURL,'/apex/LatticeVFTab?sfdc.tabName=01rA0000000LHG2&prismAccountId=999545');
            
            ApexPages.StandardController con3 = new ApexPages.StandardController(testAccount_No3);
            LatticeVFLinkExtension controller3 = new LatticeVFLinkExtension(con3); 
             system.assertEquals(controller3.isForbiddenRegionFlag, true);    
    }
}
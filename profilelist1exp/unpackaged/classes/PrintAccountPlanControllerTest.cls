/**************************************************************
* Name          : PrintAccountPlanControllerTest
* Description   : Test class for PrintAccountPlanController
*
* Version       Date        Author      Remark
* -------------------------------------------------------------
* 1.0           30-01-2012  Raymond     Created for CR6535
* 2.0           05-03-2015  Syazwan     Fix test class to call latest method routeToBOBJ
***************************************************************/
@isTest
private class PrintAccountPlanControllerTest {

    static testMethod void PrintAccountPlanControllerTestWithId() {
        
        Account testAccount = new Account(Name='Test Account PrintAccountPlanControllerTest');
        
        
        insert testAccount;

        
        SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Plan PrintAccountPlanControllerTest', 
                                                                Account__c = testAccount.Id,
                                                                Sales_manager__c = UserInfo.getUserId() );  
       

        insert testAccntPlan;

        
        
        PrintAccountPlanController controller = new PrintAccountPlanController(new ApexPages.StandardController(testAccntPlan));
    
        System.assertEquals(controller.getHasMessage(),false);
    
       //2.0 controller.generateMSTRPDF();
       //2.0 controller.generateMSTREXCEL();
       controller.routeToBOBJ();
        
        List< MSTR_Security__c> testMSTRResult = [ SELECT Id, MicroStrategy_Account_Plan_Id__c 
                                                    FROM MSTR_Security__c 
                                                    WHERE MicroStrategy_Account_Plan_Id__c = :testAccntPlan.Id];
       

        System.assert(testMSTRResult.size() > 0);
    
    }
    
    static testMethod void PrintAccountPlanControllerTestWithoutId() {
        
        Account testAccount = new Account(Name='Test Account PrintAccountPlanControllerTest');
        
        insert testAccount;
        
        SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Plan PrintAccountPlanControllerTest', 
                                                                Account__c = testAccount.Id,
                                                                Sales_manager__c = UserInfo.getUserId() );         
                                                                
        PrintAccountPlanController controller = new PrintAccountPlanController(new ApexPages.StandardController(testAccntPlan));
    
        System.assertEquals(controller.getHasMessage(),true);
    
     //2.0   controller.generateMSTRPDF();
     //2.0   controller.generateMSTREXCEL();
     
        controller.routeToBOBJ();
        
        List< MSTR_Security__c> testMSTRResult = [ SELECT Id, MicroStrategy_Account_Plan_Id__c 
                                                    FROM MSTR_Security__c 
                                                    WHERE MicroStrategy_Account_Plan_Id__c = :testAccntPlan.Id];
        

        System.assert(testMSTRResult.size() > 0);
    
    }
    
    static testMethod void PrintAccountPlanControllerTestExceptions() {
        
        Account testAccount = new Account(Name='Test Account PrintAccountPlanControllerTest');
        
        insert testAccount;
        
        SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Plan PrintAccountPlanControllerTest', 
                                                                Sales_manager__c = UserInfo.getUserId() );          
        
        PrintAccountPlanController controller = new PrintAccountPlanController(new ApexPages.StandardController(testAccntPlan));
        controller.isTest = true;
        
        System.assertEquals(controller.getHasMessage(),true);
    
        controller.routeToBOBJ();
        
      //2.0  controller.generateMSTRPDF();
     //2.0   controller.generateMSTREXCEL();
        

    
    }
}
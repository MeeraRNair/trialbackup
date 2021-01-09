@isTest
public class Vfnctrl_RouteToMarketReAccountPageTest {
    static list<Account> listAcc;  
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        listAccTdf[0].name = 'test acc12334';
        listAccTdf[0].Status__c = 'Active';
        listAccTdf[0].type = 'Partner';
        insert listAccTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    private static testmethod void testMethod3(){
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Account');       
        listAcc=[SELECT ID,CSG__c,Storage__c,Server__c,Networking__c,LOBi_Preferred_Partner_of_Record__c,LOBi_Preferred_Partner_of_Record_Storage__c,LOBi_Preferred_Partner_of_Record_Server__c,CSG_Direct_Preference__c,Origination_Program_Storage__c,Origination_Program_Server__c,Origination_Program_Client__c,Origination_Program_Networking__c FROM Account LIMIT 2];
        listAcc[1].LOBi_Preferred_Partner_of_Record_Network__c=listAcc[0].id;
        listAcc[1].LOBi_Preferred_Partner_of_Record_Server__c = listAcc[0].id;
        listAcc[1].Origination_Program_Client__c = 'Other';
        listAcc[1].Origination_Program_Storage__c = 'Other';
        listAcc[1].CSG__c = true;
        listAcc[1].CSG_Direct_Preference__c = false;
        listAcc[1].Storage__c =true; 
        listAcc[1].Server__c = true;
        listAcc[1].Networking__c=true;
        Test.startTest();
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        update listAcc[1];
        PageReference pageRef = Page.RouteToMarketReAccountPage;
        Test.setCurrentPage(pageRef);      
        pageRef.getParameters().put('Id', String.valueOf(listAcc[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(listAcc[1]);
        vfnctrl_RouteToMarketReAccountPage testAccPlan = new vfnctrl_RouteToMarketReAccountPage(sc);
        testAccPlan.strclientPORMSg = 'Error: You must enter a value in the Partner of Record field';
        testAccPlan.beditSection = true;
        testAccPlan.bdetailSection = false;
        testAccPlan.bisEditButtonVisible = true;
        Test.stopTest();
        testAccPlan.editAction();
        testAccPlan.saveAction();
        testAccPlan.cancelAction();
        testAccPlan.click();      
        system.assertEquals('Error: You must enter a value in the Partner of Record field',testAccPlan.strclientPORMSg);
    }    
    private static testmethod void testMethod4(){
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Account');       
        listAcc=[SELECT ID,CSG__c,Storage__c,Server__c,Networking__c,LOBi_Preferred_Partner_of_Record__c,LOBi_Preferred_Partner_of_Record_Storage__c,LOBi_Preferred_Partner_of_Record_Server__c,CSG_Direct_Preference__c,Origination_Program_Storage__c,Origination_Program_Server__c,Origination_Program_Client__c,Origination_Program_Networking__c FROM Account LIMIT 2];
        listAcc[1].Networking__c=true;
        listAcc[1].LOBi_Preferred_Partner_of_Record_Network__c = null;
        listAcc[1].LOBi_Preferred_Partner_of_Record_Server__c = null;
        listAcc[1].Origination_Program_Client__c = 'Other';
        listAcc[1].Origination_Program_Server__c = 'Other';
        listAcc[1].Origination_Program_Storage__c = 'Other';
        listAcc[1].Origination_Program_Networking__c = 'Other';
        listAcc[1].CSG__c = true;
        listAcc[1].CSG_Direct_Preference__c = false;
        listAcc[1].Networking__c=true;
        listAcc[1].Server__c=true;
        Test.startTest();
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        update listAcc[1];
        PageReference pageRef = Page.RouteToMarketReAccountPage;
        Test.setCurrentPage(pageRef);      
        pageRef.getParameters().put('Id', String.valueOf(listAcc[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(listAcc[1]);
        vfnctrl_RouteToMarketReAccountPage testAccPlan = new vfnctrl_RouteToMarketReAccountPage(sc);
        testAccPlan.strclientPORMSg = 'Error: You must enter a value in the Partner of Record field';
        testAccPlan.strstoragePORMSg = 'Error: You must enter a value in the Partner of Record field';
        testAccPlan.beditSection = true;
        testAccPlan.bdetailSection = false;
        testAccPlan.bisEditButtonVisible = true;
        Test.stopTest();
        testAccPlan.editAction();
        testAccPlan.saveAction();
        testAccPlan.cancelAction();
        testAccPlan.click();   
        system.assertEquals('Error: You must enter a value in the Partner of Record field',testAccPlan.strclientPORMSg);      
    }
    private static testmethod void testMethod5(){
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Account');       
        listAcc=[SELECT ID,CSG__c,Storage__c,Server__c,Networking__c,LOBi_Preferred_Partner_of_Record__c,LOBi_Preferred_Partner_of_Record_Storage__c,LOBi_Preferred_Partner_of_Record_Server__c,CSG_Direct_Preference__c,Origination_Program_Storage__c,Origination_Program_Server__c,Origination_Program_Client__c,Origination_Program_Networking__c FROM Account LIMIT 2];
        listAcc[1].Networking__c=true;
        listAcc[1].LOBi_Preferred_Partner_of_Record_Network__c = null;
        listAcc[1].LOBi_Preferred_Partner_of_Record__c = listAcc[0].Id;
        listAcc[1].Origination_Program_Client__c = null;
        listAcc[1].Origination_Program_Storage__c=null;
        listAcc[1].LOBi_Preferred_Partner_of_Record_Server__c = null;
        listAcc[1].LOBi_Preferred_Partner_of_Record_Storage__c=listAcc[0].id;
        listAcc[1].Origination_Program_Client__c = null;
        listAcc[1].Origination_Program_Server__c = 'Other';
        listAcc[1].Origination_Program_Networking__c = 'Other';
        listAcc[1].CSG__c = true;
        listAcc[1].CSG_Direct_Preference__c = false;
        Test.startTest();
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        update listAcc[1];
        PageReference pageRef = Page.RouteToMarketReAccountPage;
        Test.setCurrentPage(pageRef);       
        pageRef.getParameters().put('Id', String.valueOf(listAcc[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(listAcc[1]);
        vfnctrl_RouteToMarketReAccountPage testAccPlan = new Vfnctrl_RouteToMarketReAccountPage(sc);
        testAccPlan.strnetworkPORMSg= 'Error: You must enter a value in the Partner of Record field';
        testAccPlan.beditSection = true;
        testAccPlan.bdetailSection = false;
        testAccPlan.bisEditButtonVisible = true;
        Test.stopTest();
        testAccPlan.editAction();
        testAccPlan.saveAction();
        testAccPlan.cancelAction();
        testAccPlan.click();   
        system.assertEquals('Error: You must enter a value in the Partner of Record field',testAccPlan.strnetworkPORMSg);      
    }
}
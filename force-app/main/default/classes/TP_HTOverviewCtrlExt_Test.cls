/*
* Author   : Kenny
* Purpose  : Test class creation - controller extension class to save input of Observations & Actions field for Historical Territory Overview page
*        
* Version  	Date            Modified By         CR#                 Description     
* --------------------------------------------------------------------------------------
* 1.0      	14-Sep-2017     Kenny               14845               Create test class for controller extension class to save input of Observations & Actions field for Historical Territory Overview page             
* 1.1		02-Oct-2017		Harsha				CR14984				Modified test class to support display charts in VF page
*/

@isTest
private class TP_HTOverviewCtrlExt_Test {
    
    public static testMethod void testCase(){    
        TriggerExecutionController.setSkipAllTriggers(true);  
        user u = Drawloop_TerritoryPlanningTest.createTestData();
        Test.startTest(); 
        system.runas(u){
            PageReference pageRef = Page.TP_HTOverview;
            Test.setCurrentPage(pageRef); 
            
            //Create test data
            Territory_Plan__c tplan =new Territory_Plan__c(HTO_Observations_Actions__c='test');

            TP_HTOverviewCtrlExt controller = new TP_HTOverviewCtrlExt(new ApexPages.StandardController(tplan));
            
            Test.stopTest();    
        }
    }   
}
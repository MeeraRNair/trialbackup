/*
 * Author  : Josie
 * Purpose : To display TP Channel Strategy Information.
 * 
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR#14937    CSM0102     22-Sep-2017     Josie           Test Class to display TP Channel Strategy Information.
 * 1.1		CR14984		FY18-0102	02-Oct-2017		Harsha			Modified test class to support display charts in VF page
 */


@isTest
public class TP_ChnlStrategyCtrlExt_Test {

    public static testMethod void testCase(){    
        TriggerExecutionController.setSkipAllTriggers(true);  
        user u = Drawloop_TerritoryPlanningTest.createTestData();
        Test.startTest(); 
        system.runas(u){
            PageReference pageRef = Page.TP_ChnlStrategy;
            Test.setCurrentPage(pageRef); 
            
            //Create test data
            Territory_Plan__c tplan =new Territory_Plan__c(HTO_DP_Observations_Actions__c='test');

            TP_ChnlStrategyCtrlExt controller = new TP_ChnlStrategyCtrlExt(new ApexPages.StandardController(tplan));

            TP_ChnlStrategyCtrlExt.Top10Accounts tpacc = new TP_ChnlStrategyCtrlExt.Top10Accounts('testd', 434.43,3);
            TP_ChnlStrategyCtrlExt.Top10Accounts tpacc2 = new TP_ChnlStrategyCtrlExt.Top10Accounts('testd', 434.43,5);
            TP_ChnlStrategyCtrlExt.Top10Accounts tpacc3 = new TP_ChnlStrategyCtrlExt.Top10Accounts('testd', 434.43,8);
            
            Test.stopTest();    
        }
    }   
}
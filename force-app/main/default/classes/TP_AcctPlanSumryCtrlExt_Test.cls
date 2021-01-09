@isTest
public class TP_AcctPlanSumryCtrlExt_Test {
    
    public static testMethod void testCase(){
        
        TriggerExecutionController.setSkipAllTriggers(true);  
        user u = Drawloop_TerritoryPlanningTest.createTestData();    
        
        Test.startTest(); 
        system.runas(u){
            PageReference pageRef = Page.TP_LOBRT_ObsActions;
            Test.setCurrentPage(pageRef); 
            
            //Create test data
            Territory_Plan__c tplan =new Territory_Plan__c(APS_Next_Steps__c='test');
            
            TP_AcctPlanSumryCtrlExt controller = new TP_AcctPlanSumryCtrlExt(new ApexPages.StandardController(tplan));

            // pagenation methods
            controller.first();
            controller.next();
            controller.previous();
            controller.last();
            controller.getDisableNext();
            controller.getDisablePrevious();
            
            Test.stopTest(); 
        }
    }   
    
    public static testmethod void testcase2(){
        Territory_Plan__c tp_Obj = new Territory_Plan__c(
            name = 'test 101011 planning2');
        TP_AcctPlanSumryCtrlExt accplan = new TP_AcctPlanSumryCtrlExt(new ApexPages.StandardController(tp_Obj));
        
        integer limitsize= 2;
        integer totalsize =10;
        integer page=1;
        integer totalpages=5;
        list<TP_AcctPlanSumryCtrlExt.TP_AccPlanSumWrapper> tmplst = new list<TP_AcctPlanSumryCtrlExt.TP_AccPlanSumWrapper>(); 
        for(integer i=0; i<10; i++){
            TP_AcctPlanSumryCtrlExt.TP_AccPlanSumWrapper tpacc = new TP_AcctPlanSumryCtrlExt.TP_AccPlanSumWrapper();
            tpacc.accountName = 'Test acc'+i;
            tpacc.accPlanName = 'test acc plan'+i;
            tpacc.status = 'Pending';
            tpacc.noOfStrategies = '3';
            
            tmplst.add(tpacc);
        }
        
        accplan.first();
        accplan.next();
        // arTrends.previous();
        //arTrends.last();
     }
}
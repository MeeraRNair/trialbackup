/*
 * Author   : Kenny
 * Purpose  : Test class creation - controller extension class to save input of Observations & Actions field for for LOB Revenue Trends page
 *        
 * Version  Date            Modified By         CR#                Description     
 * --------------------------------------------------------------------------------------
 * 1.0      19-Sep-2017     Kenny               14891              Create test class for controller extension class to save input of Observations & Actions field for for LOB Revenue Trends page            
 */

@isTest
public class TP_LOBRT_ObsActionsCtrlExt_Test {

public static testMethod void testCase(){

	TriggerExecutionController.setSkipAllTriggers(true);  
    user u = Drawloop_TerritoryPlanningTest.createTestData();    
 
     Test.startTest(); 
     system.runas(u){
     PageReference pageRef = Page.TP_LOBRT_ObsActions;
     Test.setCurrentPage(pageRef); 
     
     //Create test data
     Territory_Plan__c tplan =new Territory_Plan__c(LOB_RT_Observations_Actions__c='test');
     TP_LOBRT_ObsActionsCtrlExt controller = new TP_LOBRT_ObsActionsCtrlExt(new ApexPages.StandardController(tplan));

     /*
	 TP_LOBRT_ObsActionsCtrlExt.TP_LOBRT_List tpacc = new TP_LOBRT_ObsActionsCtrlExt.TP_LOBRT_List();
	 tpacc.accountName = 'Test acc';
	 tpacc.desktop = '99869';
	 tpacc.des_qq = '90';
	 tpacc.des_yy = '2218';
	 tpacc.notebook ='500';
	 tpacc.nb_qq = '100';
	 tpacc.nb_yy = '17';
	 tpacc.server = '22537';
	 tpacc.ser_qq = '100';
	 tpacc.ser_yy ='47';
	 tpacc.storage = '19534';
	 tpacc.stg_qq = '100';
	 tpacc.stg_yy = '502';
	 tpacc.netWorking = '35269';
	 tpacc.nw_qq = '100';
	 tpacc.nw_yy = '724';
*/
     // pagenation methos
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
        TP_LOBRT_ObsActionsCtrlExt tpLob = new TP_LOBRT_ObsActionsCtrlExt(new ApexPages.StandardController(tp_Obj));
        
        integer limitsize= 2;
        integer totalsize =10;
        integer page=1;
        integer totalpages=5;
        list<TP_LOBRT_ObsActionsCtrlExt.TP_LOBRT_List> tmplst = new list<TP_LOBRT_ObsActionsCtrlExt.TP_LOBRT_List>(); 
        for(integer i=0; i<10; i++){
            TP_LOBRT_ObsActionsCtrlExt.TP_LOBRT_List tpacc = new TP_LOBRT_ObsActionsCtrlExt.TP_LOBRT_List();
            tpacc.accountName = 'Test acc'+i;
            tpacc.desktop = '99869';
            tpacc.des_qq = '90';
            tpacc.des_yy = '2218';
            tpacc.notebook ='500';
            tpacc.nb_qq = '100';
            tpacc.nb_yy = '17';
            tpacc.server = '22537';
            tpacc.ser_qq = '100';
            tpacc.ser_yy ='47';
            tpacc.storage = '19534';
            tpacc.stg_qq = '100';
            tpacc.stg_yy = '502';
            tpacc.netWorking = '35269';
            tpacc.nw_qq = '100';
            tpacc.nw_yy = '724';
            tmplst.add(tpacc);
        }
        
        tpLob.first();
        tpLob.next();
        // arTrends.previous();
        //arTrends.last();
     }
}
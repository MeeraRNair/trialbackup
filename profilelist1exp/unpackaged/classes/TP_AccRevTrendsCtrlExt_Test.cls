/*
* Author  : Nagaraju Yelluri
* Purpose : To display Account Revenue Trends Information.
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR14927      10.01      15-Sep-2017     Nagaraju        This class gives the test coverage for TP_AccRevTrendsCtrlExt class.
*/
@isTest
public class TP_AccRevTrendsCtrlExt_Test {
    public static testmethod void testcase1() {
        TriggerExecutionController.setSkipAllTriggers(true);  
        user u = Drawloop_TerritoryPlanningTest.createTestData(); 
        
        Test.startTest();
        Territory_Plan__c tp_Obj = new Territory_Plan__c(
            name = 'test 101011 planning');
        // insert tp_Obj;
        system.runAs(u) {
            PageReference pageRef = Page.TP_AccRevTrends;
            Test.setCurrentPage(pageRef);
            TP_AccRevTrendsCtrlExt arTrends = new TP_AccRevTrendsCtrlExt(new ApexPages.StandardController(tp_Obj));
            
            //test data creation.
            TP_AccRevTrendsCtrlExt.TP_AccRevTrendsWrapper tpacc = new TP_AccRevTrendsCtrlExt.TP_AccRevTrendsWrapper();
            tpacc.accountName = 'Test acc';
            tpacc.fy1 = '99869';
            tpacc.fy2 = '90';
            tpacc.fy_YTD = '2218';
            tpacc.fy_Q1 ='500';
            tpacc.fy_Q2 = '100';
            tpacc.fy_Q3 = '17';
            tpacc.fy_Q4 = '22537';
            tpacc.qq_Growth = '100';
            tpacc.yy_Growth ='47';
            
            arTrends.first();
            arTrends.next();
            arTrends.previous();
            arTrends.last();
            arTrends.getDisableNext();
            arTrends.getDisablePrevious();
        }
        Test.stopTest();
    }
    
    public static testmethod void testcase2(){
        Territory_Plan__c tp_Obj = new Territory_Plan__c(
            name = 'test 101011 planning2');
        TP_AccRevTrendsCtrlExt arTrends = new TP_AccRevTrendsCtrlExt(new ApexPages.StandardController(tp_Obj));
        
        integer limitsize= 2;
        integer totalsize =10;
        integer page=1;
        integer totalpages=5;
        list<TP_AccRevTrendsCtrlExt.TP_AccRevTrendsWrapper>tmplst = new list<TP_AccRevTrendsCtrlExt.TP_AccRevTrendsWrapper>(); 
        for(integer i=0; i<10; i++){
            TP_AccRevTrendsCtrlExt.TP_AccRevTrendsWrapper tpacc = new TP_AccRevTrendsCtrlExt.TP_AccRevTrendsWrapper();
            tpacc.accountName = 'Test acc'+i;
            tpacc.fy1 = '99869';
            tpacc.fy2 = '90';
            tpacc.fy_YTD = '2218';
            tpacc.fy_Q1 ='500';
            tpacc.fy_Q2 = '100';
            tpacc.fy_Q3 = '17';
            tpacc.fy_Q4 = '22537';
            tpacc.qq_Growth = '100';
            tpacc.yy_Growth ='47';
            tmplst.add(tpacc);
        }
        
        arTrends.first();
        arTrends.next();
        // arTrends.previous();
        arTrends.last();
        
    } 
}
/**************************************************************
* Name          : AccntPlanMultipleCustTechInitCtrlTest
* Description   : Test class for  AccntPlanMultipleCustTechInitCtrl
*
* Version        Date        Author           Remark
* -------------------------------------------------------------
* 1.0           5/22/2014   P Praveen Babu    CR 9551
***************************************************************/


@isTest
private class AccntPlanMultipleCustTechInitCtrlTest{
static testMethod void test1()
{
 
 //string samQuery= 'SELECT Account__c,Obsolete_Record_Type__c,TSP__c FROM SFDC_Acct_Plan__c Where Id='';
 AccntPlanMultipleCustTechInitCtrl accPlanMctic = new  AccntPlanMultipleCustTechInitCtrl();
 accPlanMctic.getCanProceed();
 accPlanMctic.getnoOfFilledFields();
 
 accPlanMctic.add();
 accPlanMctic.remove();
 
 accPlanMctic.save();
 
 accPlanMctic.cancel(); 

 
 
}
}
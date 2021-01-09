/*
 * Author   : Sazleen
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to SFDC_Acct_Plan__c object. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      US# 7067965  1101       30-Sept-2019     Sazleen| Naga   Update all related Account Plan record when Focus Account on Account object updated to AGL or NON AGL
 * 
 *
 */
public class AccountPlanAccountTriggerHandlerAU implements AfterUpdate{
     
     public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){         
        
        AccountPlanUtilities.updateNonAGLtoAGLAccountPlan(listNew, (map<Id,Account>) mapOld);
   }
}
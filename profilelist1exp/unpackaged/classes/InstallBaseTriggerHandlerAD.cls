/*
 * Author   : Fenny
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Install_Base__c.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      13796       FY17-DCS-0103   09-Dec-2016     Fenny           Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      17931       FY20-1002       14-Aug-2019     Fenny           Refactoring trigger framework. Following method calls copied from InstallBaseTriggerHandler
*/
public class InstallBaseTriggerHandlerAD implements AfterDelete{
     
    public void handleAfterDelete(List<sObject> listOld){
        InstallBaseUtilities.updateRollUpSummaryInAccount(Trigger.oldMap, Trigger.newMap);
    }
}
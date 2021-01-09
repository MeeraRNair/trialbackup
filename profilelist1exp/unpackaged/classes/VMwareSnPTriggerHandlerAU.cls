/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0       6637336      FY20-1002    26-Aug-2019        Anusha       new framework. Below method calls copied from 
**/

public class VMwareSnPTriggerHandlerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
      
         VmwareSNPVendorDatatoOLI.afterUpdate(listNew,(map<Id, S_P_Vendors__c>)mapOld,null,false);
    }
}
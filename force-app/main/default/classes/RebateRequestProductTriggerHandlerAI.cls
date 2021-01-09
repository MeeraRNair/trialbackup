/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      
 * 2.0      17934       FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Below methods calls copied from RebateRequestProductTriggerHandler
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class RebateRequestProductTriggerHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){

        RebaterequestproducttriggerCls.insertPopualateTotalIntelDiscountRequested (listNew);
    }
}
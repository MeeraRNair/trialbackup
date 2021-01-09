/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0       6637336      FY20-1002    26-Aug-2019        Anusha       new framework. Below method calls copied from 
**/
public class VMWareOLITriggerHandlerBI implements BeforeInsert{
    
    public void handleBeforeInsert(List<sObject> listNew){
      
         //S&P Deal Reg Link in Product info(Autopopulating S&PVendor Field Values into Opportunity Line Item)
          VmwareSNPVendorDatatoOLI.afterUpdate(null,null,listNew,true);
    }
}
/*
 * Author   : Kokila
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Product2.
 * 
 * Revision  CR Number  Release No      Date           Modified By     Description
 * --------  ---------  ----------      -----------    ------------    -----------
 * 1.0       CR11414    16.06           30-Apr-2015    Kokila          Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0       CR11506    16.07(MAJ-S-03) 27-May-2015    Krishnamoorthi  Updated to call send email functionality if Name or Product code changed  
 * 3.0       CR13980    FY18-DCS-0302   09-Feb-2017    Harsha Ch       Commentted updateAppassureOppAndOLI method calling, as we dont need this functionality after DSG decomission.
 * 4.0       CR14938    FY18-DCS-1101   21-Sep-2017    Ananth          Commented  sendEmailToSalesEdge method calling, as we are not going to use SAVO functionality.
 */
public class Product2TriggerHandler extends TriggerHandler {

    public override void getRecordSelector() {
        
    }

    //
    //public override void onAfterUpdate() {
        //v2.0
        /*v4.0 start 
        Product2Utilities.sendEmailToSalesEdge((Map<Id, Product2>) Trigger.newMap, (Map<Id, Product2>) Trigger.oldMap);
        v4.0 end */
      /*v3.0 start  
        Product2Utilities.updateAppassureOppAndOLI((Map<Id, Product2>) Trigger.newMap, (Map<Id, Product2>) Trigger.oldMap);
      v3.0 end */
  //  }
    
}
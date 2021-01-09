/*
 * Author   : Ismail
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Opportunity.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      13902     FY17-DCS-0202   18-Jan-2017      Ismail          Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      14618     FY18-DCS-0802   07-Jul-2017      Jessie          Update Lead_on_Services__c of Opp Product with value of Dell_Leading_Professional_Services__c of S&P Vendor
 * 3.0      14789     FY18-DCS-1001   23-Aug-2017      Jessie          Story 3686076:VMware API – Registration Extensions (button logic)
 * 4.0		17878       FY20-1002		06-Aug-2019		Fenny			Trigger refactoring - new framework. Moved the method calls to new classes: SnPVendorsTriggerHandlerXX
 * 5.0		18309		FY20-0102		25-Nov-2019			Fenny			Accessible SnPVendorsRecordSelector
**/

public class SnPVendorsTriggerHandler extends TriggerHandler {
    // 5.0
    public static SnPVendorsRecordSelector snpRecordSelector;
    public override void getRecordSelector() {
        snpRecordSelector = new SnPVendorsRecordSelector(Trigger.new, Trigger.oldMap, this);
    }

    /*
    public override void onAfterDelete(){
        // 1.0
        SnPVendorsUtilities.updateRollUpSummaryInOpportunity(Trigger.oldMap, Trigger.newMap);
    }
    // 1.0
    
    // consolidted triggers logic start  
    public override void onBeforeInsert(){
    SnPVendorsUtilities.updateSendNotification(Trigger.old, Trigger.new);
    SnPVendorsUtilities.beforeInsertUpdate(Trigger.new);
    
        
    }
    // END
    
    //v3.0 - start
    public override void onBeforeUpdate(){
        SnPVendorsUtilities.resetExtendRegistrationFlag(Trigger.new);
        // consolidted triggers logic start  
        SnPVendorsUtilities.updateSendNotification(Trigger.old, Trigger.new);
        SnPVendorsUtilities.checkValidation(Trigger.new);
        SnPVendorsUtilities.beforeInsertUpdate(Trigger.new);

    }
    //END
    //v3.0 - end 
    
    public override void onAfterUpdate(){
        //v2.0 - start
        SnPVendorsUtilities.updateLeadOnServicesOfOppProduct (Trigger.new);
         // consolidted triggers logic start  
        SnPVendorsUtilities.validationCheck(Trigger.new);
        // END
        //v2.0 - end
    }
    */
}
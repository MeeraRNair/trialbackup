/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on OpportunityLineItem.
 *          Calls business logics by passing trigger context variables or corresponding results from OpportunityLineItemRecordSelector class.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR10496     15.10           05-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR10826     16.03           23-Dec-2014     Meghana         Comment method OpportunityLineItemUtilities.backupOpportunityLineItem
 * 3.0      CR10616     16.03           23-Dec-2014     Micky           Created method OpportunityLineItemUtilities.populateOpportunityLineItemSchedule
 * 4.0      CRQ 1166    16.03           17-Mar-2015     Meghana         Uncomment changes done in version 2.0
 * 5.0      CR11464     16.07           15-May-2015     Krishna         Logic show the Export complaince message in Opportunity Page.
 * 6.0      CR11414     16.07(MAJ-S-01) 30-Apr-2015     Krishnamoorthi  Called OpportunityLineItemUtilities method to populate SAVO Opportunity fields Product_Group_Hidden and Product_Brand_Hidden 
 * 7.0      TFS184551    16.07          28-Jul-2015     Krishnakumar    Created new method and moved the logic from workflow  Update Supportability Last Updated. 
 * 8.0      CR11932     16.10           10-Sep-2015     Krishnamoorthi  Changed the order of calling the method updateFieldsForSAVO() inorder to avoid updating the Opportunity with old values due to multiple updates  
 * 9.0      CR12306     16.12           09-Nov-2015     Jiji            Restrict Partners from adding new Channel LOBs to existing approved deals
 * 9.1      CR12348     16.12           16-Nov-2015     Dipin Raju      Validate Customer Requested Date based on Book Date
 * 9.2      TFS217277   16.12           05-Jan-2015     Ananth          To populate SAVO Opportunity field Product_Brand_Hidden whenever Opportunity Product is updated.
 * 9.3      CR13055     Sprint 6        20-Apr-2016     Afiq            To populate EMC Product Flag in Oppty based on added/removed Opportunity Product with certain criterias
 * 9.4      CRXXXXX     Sprint 7        03-May-2016     Afiq            To check Opportunity Line Items Sales Motion for EMC
 * 10.0     CR13134     Sprint 9        26-May-2016     Kenny           Update Product_Fld_EMC_CRUD_Behavior_Read_Only__c in opporunity to 'Read Only' when one of the line items whereby EMC_CRUD_Behavior__c is 'Read Only'. 
 * 11.0     CR13201     Sprint 9        02-June-2016    Kenny           Create entry in Oppty_Product_Deleted__c object for each deleted EMC Product.
 * 12.0     CR13224     Sprint 10       09-June-2016    Syidah          Update “EMC Sales Motion”  based on 'EMC Sales motion flag' on Opportunity line item value. 
 * 13.0                 Sprint 11       21-June-2016    Afiq            Added logic to disable/enable codes using Custom Settings
 * 14.0     13668       FY17-DCS-0103   02-Nov-2016     Fenny           Update roll up summary in Opportunity when deleting OpportunityLineItem
 * 15.0     CR13732     Sprint22        24-Nov-2016     Afiq            Comment previous codes and created new codes to populate Sales Motion in Opportunity based on Opportunity Line Item Business Family
 * 16.0     CR13980     FY18-DCS-0302   13-Feb-2017     Sri Harsha Ch   Comment recalculateDSGCBOProductFlagAfterDelete,recalculateDSGCBOProductFlagAfterInsert method calls, as they are related to DSG.
 * 16.1     13902       FY18-DCS-0202   14-Feb-2017     Fenny           CR1390 CRQ1203
 * 17.0     CR14160     FY18-DCS-0502   11-Apr-2017     Sriram          Comment previous code and logic implemented in PB and Flow
 * 18.0     CR14122&CR14285 FY18-DCS-0602 28-Apr-2017   Kenny           Update Opportunity Owner Email when Oppotunity Type is 'Deal/Bid - Direct' and Supportability Status is either Risk or Not Supportable/Update Account Owner Email when Oppotunity Type is 'Deal/Bid - Indirect' and Supportability Status is either Risk or Not Supportable   
 * 19.0     Defect 3361955 FY18-DCS-0602 15-May-2017   Pawan Vasigala   Added Custom setting update lines to toggle the visibility of Opportunity Product Incumbency Popop
 * 20.0     CR14654     FY18-DCS-1001   02-08-2017     Jessie Tan      Story 3382308:VMware Next Gen CR-00140306: Product Additions
 * 21.0    US#3691934   FY19-DCS-0202   17-oct-2017     Yeswanth        Manage Deals: Enable Partners/Sales users to Add Products on approved deal reg Channel Opportunities
 * 22.0     CR15166     FY18-0203   26-Nov-2017        Krishnakumar     Display Forecasted Units and Quote Numbers in myDeal
 * 23.0     CR17550     FY20-0702       24-May-2019     Fenny           OpportunityLineItemTriggerHandler obsolete
 * 24.0		CR18307		FY20-0102		25-Nov-2019		Fenny			Accessible OpportunityLineItem RecordSelector
*/    
 
public class OpportunityLineItemTriggerHandler extends TriggerHandler {

//13.0 Start
//String EMCCodes ='EMC Codes';


    public static OpportunityLineItemRecordSelector oliRecordSelector;
    public static OpportunityLineItemTriggerHandler handler;
    public override void getRecordSelector() {
        handler = this;
        oliRecordSelector = new OpportunityLineItemRecordSelector(Trigger.new, Trigger.oldMap, this);
    }
    /*
    public override void onBeforeInsert() {
         // Auto populate fields based on the Trigger event
        OpportunityLineItemUtilities.populateFields(this.trigEvent, Trigger.new, null);
                
        // Identify eligible Opportunity Products for SnP and call SnPUtils.calculateQualifiedSnPDRProg() for processing
        SnPUtils.initiateSnPCalculations(SnPUtils.TriggerType.ISINSERT, Trigger.new, null);
        
        //Update LOT indicator on Opportunity Product
        //OpportunityLineItemUtilities.updateLOTIndicator(this.trigEvent, Trigger.new, null); 
        
        //Update Supportability Last Update field
        OpportunityLineItemUtilities.updateSupportability_Last_Updated(this.trigEvent, Trigger.new, null);    
     
        
        
        //Ver 9.0: CR 12306: Restrict Partners from adding new Channel LOBs to existing approved deals:Start
       // Ver 21.0: Commented out and added in after insert as part of US#3691934: Start
           OpportunityLineItemUtilities.RestrictNewlineItemsforApproveddeals(this.trigEvent, Trigger.new, null); 
       // Ver 21.0: Commented out and added in after insert as part of US#3691934: End
       //Ver 9.0: CR 12306: Restrict Partners from adding new Channel LOBs to existing approved deals:Start
        
        //validate EMC Product
        //13.0 Start
        
        
        //Enable_Codes_Settings__c EMCSet = Enable_Codes_Settings__c.getInstance(EMCCodes);
        //if(EMCSet.Enable__c == true){
            //system.debug(EMCSet.Enable__c);
            //OpportunityLineItemUtilities.validateEMCProducts(Trigger.new);
        //}
        
        //12.0
        //OpportunityLineItemUtilities.updateEMCSalesMotion(oliRecordSelector.setOpportunityIds);
        
        //Ver 18.0: CR 14122: Update Opportunity Owner Email to Opportunity Owner's Email field when the value is different from Opportunity Owner Email
        OpportunityLineItemUtilities.UpdateOpportunityOwnerEmail(this.trigEvent, Trigger.new, null);
        
        //v20.0 - start
        OpportunityLineItemUtilities.populateNewProductFlagForVMware (Trigger.new, oliRecordSelector);
        //v20.0 - end
        
    }
    
    public override void onBeforeUpdate() {     
        // Auto populate fields based on the Trigger event
        OpportunityLineItemUtilities.populateFields(this.trigEvent, Trigger.new, Trigger.oldMap);       
        
        // Identify eligible Opportunity Products for SnP and call SnPUtils.calculateQualifiedSnPDRProg() for processing
        SnPUtils.initiateSnPCalculations(SnPUtils.TriggerType.ISUPDATE, Trigger.new, (map<Id, OpportunityLineItem>)Trigger.oldMap);
        
        //Update the discount for DSA opportunity product
        DSAUtils.applyDiscountForDSAOpportunities(Trigger.new);
        
        //Update the discount  to 0 for DSA opportunity product in case of disconnect
        DSAUtils.resetDiscountForDSAOpportunities(Trigger.new,(map<Id, OpportunityLineItem>)Trigger.oldMap);   
        
        //Update LOT indicator on Opportunity Product
        //OpportunityLineItemUtilities.updateLOTIndicator(this.trigEvent, Trigger.newMap, Trigger.oldMap);
        
        //Update Supportability Last Update field
        OpportunityLineItemUtilities.updateSupportability_Last_Updated(this.trigEvent, Trigger.new, (map<Id, OpportunityLineItem>)Trigger.oldMap);
        
        //validate Quote # if updates come from Boomi
        OpportunityLineItemUtilities.validateQuoteFromBoomi(Trigger.new, (map<Id, OpportunityLineItem>)Trigger.oldMap);
 
        //v9.1: Validate Customer Requested Date based on Book Date
        OpportunityLineItemUtilities.validateCustReqDate(this.trigEvent, Trigger.new, null);
        
        // 10.0 Update Product_Fld_EMC_CRUD_Behavior_Read_Only__c in opporunity to 'Read Only' when one of the line items whereby EMC_CRUD_Behavior__c is 'Read Only'. 
        //OpportunityLineItemUtilities.ValidateOpportunityFieldUpdate(Trigger.new);
        
        //Ver 18.0: CR 14122: Update Opportunity Owner Email to Opportunity Owner's Email field when the value is different from Opportunity Owner Email
        OpportunityLineItemUtilities.UpdateOpportunityOwnerEmail(this.trigEvent, Trigger.new, (map<Id, OpportunityLineItem>)Trigger.oldMap);
    }
    
    public override void onBeforeDelete() {
        // Validate deletion of the Opportuntiy Products
        OpportunityLineItemUtilities.validateDeletion(Trigger.old, oliRecordSelector.mapRelatedRecords);
        
        // Identify eligible Opportunity Products for SnP and call SnPUtils.calculateQualifiedSnPDRProg() for processing
        SnPUtils.initiateSnPCalculations(SnPUtils.TriggerType.ISDELETE, Trigger.old, (map<Id, OpportunityLineItem>)Trigger.oldMap);
    }
    
    public override void onAfterInsert() {
        //v8.0 - Changed the order of calling the method updateFieldsForSAVO() inorder to avoid updating the Opportunity with old values due to multiple updates
        //v6.0 - To populate SAVO Opportunity fields Product_Group_Hidden and Product_Brand_Hidden whenever Opportunity Product is inserted
        //Do not change this order of calling and do not place your method call before updateFieldsForSAVO() to avoid updating the Opportunity with old values****
        OpportunityLineItemUtilities.updateFieldsForSAVO(this);
        
        if(!GlobalVariables.BYPASS_LOT_OCEAN_CALCULATION) {
            // Recalculate Product Quantity in S_P_Vendors__c whenever Opportunity Product is inserted / updated
            SnPDealRegistrationMainClass.computeSnPProdQuantity(oliRecordSelector.mapAllRelatedOLIs.values(), oliRecordSelector.mapAllRelatedSnPVendors.values());
            
            // Reevaluate all DGR related details whenever Opportunity Product is inserted / updated
            OpportunityLineItemUtilities.initiateDGRCalculations(Trigger.new, this);

            //Inserting OpportunityLineItemSchedule details when a new OpportunityLineItem is created
            OpportunityLineItemRevenueSchedule.populateOpportunityLineItemSchedule((map<Id, OpportunityLineItem>)Trigger.newMap);
        }

        // Update DSG_CBO_Product_Flag__c field in related parent Opportunity based on the DSG_CBO_Opportunity_Product__c field in Opportunity Product
        //v16.0 start
        //OpportunityLineItemUtilities.recalculateDSGCBOProductFlagAfterInsert(Trigger.new, oliRecordSelector.mapRelatedRecords);
        //v16.0 end
        
        // Update AppAssure_Product_Flag__c field in Opportunity based DSG_CBO_Opportunity_Product__c field in Opportunity Product
        OpportunityLineItemUtilities.updateAppAssureProductFlag(oliRecordSelector.setOpportunityIds, null);

        //Logic show the Export complaince message in Opportunity Page.    
        OpportunityLineItemUtilities.checkEI_Products(oliRecordSelector.setOpportunityIds,Trigger.new,oliRecordSelector.mapRelatedOpportunities,oliRecordSelector.mapAllRelatedOLIs.values());
        
        //Update LOT indicator on Opportunity Product
        //OpportunityLineItemUtilities.updateLOTIndicator(this.trigEvent, Trigger.new, null);
        
        //Update Supportability Indicator on Opportunity
        OpportunityLineItemUtilities.updateSupportabilityIndicator(this.trigEvent, Trigger.new, null);
        
        // To do realtime update on OSC when opportunitylineitem is created
        System.debug('***************** Product Line Item AFTER INSERT');
        OpportunityLineItemUtilities.RealTimeProductUpdate(Trigger.new);
        
        //13.0 Start
        
        //15.0 Start
        
        //Enable_Codes_Settings__c EMCSet = Enable_Codes_Settings__c.getInstance(EMCCodes);
        //if(EMCSet.Enable__c == true){
            // CR13055 update EMC_Product_Flag field in Opportunity based EMC_Sales_Motion & EMC_CRUD_Behavior field in Opportunity Product
        //    OpportunityLineItemUtilities.updateEMCProductFlag(oliRecordSelector.setOpportunityIds, null); 
        //}
        //15.0 End
        
        //15.0 Start
        //CR14160 - Start
        //OpportunityLineItemUtilities.updateEMCProductFlag(oliRecordSelector.setOpportunityIds);   
        //CR14160 - End  
        //15.0 End
        
        // Defect 3361955 added custom setting update lines to accomodate Opportunity Incumbency Popup disable/enable
        OpportunityLineItemUtilities.checkForPopupForIncumbentProducts(Trigger.newMap,oliRecordSelector.mapAllRelatedOLIs,oliRecordSelector.mapRelatedOpportunities);
        
        //v20.0 - start
        OpportunityLineItemUtilities.updateOppVmwareFlag (Trigger.new, oliRecordSelector);
        //v20.0 - end 
        
        // Added By Rajashekar kura to Update Specialty Queue flag Check on Opportunity    
        OpportunityLineItemUtilities.OpportunitySpecialtyQueueFlagUpdate(Trigger.new);
        
          // Ver 21.0: Manage Deals: Enable Partners/Sales users to Add Products on approved deal reg Channel Opportunities: Start
          //*************************** Please dont add any validations below this method ******************************************
           //OpportunityLineItemUtilities.RestrictNewlineItemsforApproveddeals(this.trigEvent, (map<Id, OpportunityLineItem>)Trigger.newMap); 
           //*************************** Please dont add any validations below this method ******************************************
       // Ver 21.0: Manage Deals: Enable Partners/Sales users to Add Products on approved deal reg Channel Opportunities: End

    }
    
    public override void onAfterUpdate() {
        if(!GlobalVariables.BYPASS_LOT_OCEAN_CALCULATION) {
            // Recalculate Product Quantity in S_P_Vendors__c whenever Opportunity Product is inserted / updated
            SnPDealRegistrationMainClass.computeSnPProdQuantity(oliRecordSelector.mapAllRelatedOLIs.values(), oliRecordSelector.mapAllRelatedSnPVendors.values());
            
            // Reevaluate all DGR related details whenever Opportunity Product is inserted / updated
            OpportunityLineItemUtilities.initiateDGRCalculations(Trigger.new, this);
            
            //Logic show the Export complaince message in Opportunity Page.
            //OpportunityLineItemUtilities.checkEI_Products(oliRecordSelector.setOpportunityIds,Trigger.new,oliRecordSelector.mapRelatedOpportunities);

            //Inserting OpportunityLineItemSchedule details when a new OpportunityLineItem is updated
             OpportunityLineItemRevenueSchedule.updateOpportunityLineItemSchedule((map<Id, OpportunityLineItem>)Trigger.newMap,(map<Id, OpportunityLineItem>)Trigger.oldMap);
            
            //v9.2 - To populate SAVO Opportunity field Product_Brand_Hidden whenever Opportunity Product is updated 
             OpportunityLineItemUtilities.updateFieldsForSAVO(this);
        }
        
        //Update LOT indicator on Opportunity Product
        //OpportunityLineItemUtilities.updateLOTIndicator(this.trigEvent, Trigger.new, null);
        
        
        //Update Supportability Indicator on Opportunity
        OpportunityLineItemUtilities.updateSupportabilityIndicator(this.trigEvent, Trigger.new, Trigger.oldMap);
         
        //CR11598: Create Supportability Field History to track history/changes on selected OpportunityLineItem fields
        //CustomFieldHistoryTracker.trackFieldHistory('OpportunityLineItem', 'Supportability_Field_History__c', 'Supportability_Field_Tracking__c', 'OpportunityId', 'Opportunity__c', trigger.oldMap, oliRecordSelector.mapAllRelatedOLIs);
        system.debug('in onAfterUpdate OpportunityLineItemTriggerHandler');
        OpportunityLineItemUtilities.generateSupportabilityFieldHistory(Trigger.newMap);
        
        //v20.0 - start
        OpportunityLineItemUtilities.updateOppVmwareFlag (Trigger.new, oliRecordSelector);
        //v20.0 - end       
    }
    
    public override void onAfterDelete() {
        //v8.0 - Changed the order of calling the method updateFieldsForSAVO() inorder to avoid updating the Opportunity with old values due to multiple updates
        //v6.0 - To populate SAVO Opportunity fields Product_Group_Hidden and Product_Brand_Hidden whenever Opportunity Product is deleted
        //***Do not change this order of calling and do not place your method call before updateFieldsForSAVO() to avoid updating the Opportunity with old values****
        OpportunityLineItemUtilities.updateFieldsForSAVO(this);
        
        // Recalculate Product Quantity in S_P_Vendors__c whenever Opportunity Product is deleted / undeleted
        SnPDealRegistrationMainClass.computeSnPProdQuantity(oliRecordSelector.mapAllRelatedOLIs.values(), oliRecordSelector.mapAllRelatedSnPVendors.values());
        
        // Reevaluate all DGR related details whenever Opportunity Product is deleted / undeleted
        OpportunityLineItemUtilities.initiateDGRCalculations(Trigger.old, this);
        
        // Update DSG_CBO_Product_Flag__c field in related parent Opportunity based on the DSG_CBO_Opportunity_Product__c field in Opportunity Product
        //v16.0 start 
        //OpportunityLineItemUtilities.recalculateDSGCBOProductFlagAfterDelete(oliRecordSelector.setOpportunityIds);
        //v16.0 end 
        
        // Update AppAssure_Product_Flag__c field in Opportunity based DSG_CBO_Opportunity_Product__c field in Opportunity Product
        OpportunityLineItemUtilities.updateAppAssureProductFlag(oliRecordSelector.setOpportunityIds, oliRecordSelector.setDeletedOLIsOppIds);
        
        //v2.0-Start - Comment method to backup SonicWall oppty line deletion
        //v4.0 - uncomment 2.0 changes
        // Create entry in Oppty_Product_Deleted__c object for each deleted SonicWall Opportunity Products
        // OpportunityLineItemUtilities.backupOpportunityLineItem(Trigger.old); 
        //v2.0-end
        
        // To do realtime update on OSC when opportunitylineitem is deleted
        System.debug('***************** Product Line Item AFTER DELETE');
        OpportunityLineItemUtilities.RealTimeProductUpdate(Trigger.old);
        
        //13.0 Start     
        //15.0 Start
        
        //Enable_Codes_Settings__c EMCSet = Enable_Codes_Settings__c.getInstance(EMCCodes);
        //if(EMCSet.Enable__c == true){
            // CR13055 Update EMC_Product_Flag field in Opportunity based EMC_Sales_Motion & EMC_CRUD_Behavior field in Opportunity Product
        //    OpportunityLineItemUtilities.updateEMCProductFlag(oliRecordSelector.setOpportunityIds, oliRecordSelector.setDeletedOLIsOppIds);
        //}
      //CR14160 - Start
        //OpportunityLineItemUtilities.updateEMCProductFlag(oliRecordSelector.setOpportunityIds);  
       //CR14160 - End 
        //13.0 Start
        //if(EMCSet.Enable__c == true){
         //11.0 Create entry in Oppty_Product_Deleted__c object for each deleted EMC Product.
         OpportunityLineItemUtilities.backupEMCOpportunityLineItem(Trigger.old); 
        //}
        //15.0 End

        // 14.0 & 16.1 &20 &22.0
        OpportunityLineItemDeleteUtilities.updateRollUpSummaryInOpportunity(Trigger.oldMap, Trigger.newMap);
        
        
        //Added by Rajashekar Kura to update Speciality flag in Opportunity
        OpportunityLineItemUtilities.OpportunitySpecialtyQueueFlagUncheck(trigger.old);
 
  }
    
    public override void onAfterUndelete() {
        // Recalculate Product Quantity in S_P_Vendors__c whenever Opportunity Product is deleted / undeleted
        SnPDealRegistrationMainClass.computeSnPProdQuantity(oliRecordSelector.mapAllRelatedOLIs.values(), oliRecordSelector.mapAllRelatedSnPVendors.values());
        
        // Reevaluate all DGR related details whenever Opportunity Product is deleted / undeleted
        OpportunityLineItemUtilities.initiateDGRCalculations(Trigger.new, this);
    }*/
 }
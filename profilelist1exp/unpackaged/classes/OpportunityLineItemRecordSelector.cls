/*
 * Author   : Ragu
 * Purpose  : Centralize the record selection process for OpportunityLineItem.
 *          Defines the methods which iterate and segregate the OpportunityLineItem records for further use.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR10496     15.10           05-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR11414     16.07(MAJ-S-01) 05-May-2015     Krishnamoorthi  Added the SAVO Opportunity fields Product_Group_Hidden__c and Product_Brand_Hidden__c in the mapRelatedOpportunities query
 * 3.0      D3398057    SP08-May08      22-MAY-2017     Pawan V         Added Account Incumbency checkbox fields in Opportunity Related Records query.
 * 4.0      CR14654     DCS-FY18-1001   09-Aug-2017     Jessie Tan      Story 3382308:VMware Next Gen CR-00140306: Product Additions
 * 5.0      CR14931     DCS-FY18-1101   20-Sep-2017     Naga            Code cleanup for savo functionality, removed all refferences of Product_Group_Hidden__c and Product_Brand_Hidden__c fields from code.
 * 6.0		CR17974     FY20-DCE-1002	04-Aug-2019		Shubham B	added fields(type,Source_System__c) in opportunity query in getRelatedRecords   
 */

public class OpportunityLineItemRecordSelector extends RecordSelector {
    
    private OpportunityLineItemTriggerHandler oliTriggerHandler;
    public set<Id> setOpportunityIds = new set<Id>();
    public map<Id, OpportunityLineItem> mapRelatedRecords = new map<Id, OpportunityLineItem>();
    public map<Id, OpportunityLineItem> mapAllRelatedOLIs = new map<Id, OpportunityLineItem>();
    public map<Id, Opportunity> mapRelatedOpportunities = new map<Id, Opportunity>();
    public map<Id, S_P_Vendors__c> mapAllRelatedSnPVendors = new map<Id, S_P_Vendors__c>();
    
    // Used in OpportunityLineItemUtilities.updateAppAssureProductFlag()
    public set<Id> setDeletedOLIsOppIds = new set<Id>();
    
    // Used in OpportunityLineItemUtilities.initiateDGRCalculations()
    public set<Id> setExcludedOppIdsForLO = new set<Id>();
    
    //v4.0 - start
    public Map<Id, S_P_Vendors__c> mapOppIdSPVendorOfVMware = new Map<Id, S_P_Vendors__c>();
    //v4.0 - end 
    
    public OpportunityLineItemRecordSelector(list<sObject> lstLineItems, map<Id, sObject> mapOldLineItems, OpportunityLineItemTriggerHandler oliTriggerHandler) {
        this.oliTriggerHandler = oliTriggerHandler;
        
        this.getRecords(lstLineItems, mapOldLineItems);
        
        if(lstLineItems != null) {
            this.getRelatedRecords(lstLineItems);
        }
        else if(mapOldLineItems != null) {
            this.getRelatedRecords(mapOldLineItems.values());
        }
        
        removeNulls();
    }
/* Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 2.0      CR11580     15.07       15-Jun-2015     Krishna Manohar Added Account fields and opportunity fields in mapRelatedOpportunities
 * 3.0      CR13980    FY18DCS-0302 14-Feb-2017     Harsha          Removed fields DSG_CBO_Product_Flag__c, DSG_CBO_Opportunity_Product__c from queries.
 * 4.0      CR17974  FY20-DCE-1002	04-Aug-2019		Shubham B	added fields(type,Source_System__c) in opportunity query in getRelatedRecords getRelatedRecords 
 */ 
    protected override void getRelatedRecords(list<sObject> lstLineItems) {
        if(Utility.isIdAvailable(lstLineItems)) {
        /* v3.0 start    
            mapRelatedRecords = new map<Id, OpportunityLineItem>([select Id, Name, OpportunityId, Opportunity.CreatedById, Opportunity.CreatedBy.Profile.Name, 
                                                                    Opportunity.Related_Parent_Opportunity__c, Opportunity.Related_Parent_Opportunity__r.DSG_CBO_Product_Flag__c
                                                                  from OpportunityLineItem where Id in :Utility.getIds(lstLineItems)]); v3.0 end*/
            mapRelatedRecords = new map<Id, OpportunityLineItem>([select Id, Name, OpportunityId, Opportunity.CreatedById, Opportunity.CreatedBy.Profile.Name, 
                                                                    Opportunity.Related_Parent_Opportunity__c
                                                                  from OpportunityLineItem where Id in :Utility.getIds(lstLineItems)]);
        }
        
        if(oliTriggerHandler != null) {
            if(oliTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                mapRelatedOpportunities = new map<Id, Opportunity>([select Id, RecordTypeId,Solution_Name__c, 
                                                                    Name,Recalculate_LOT_OCEAN__C, Products_Brand_Desc_Hidden__c, 
                                                                    Dell_Defined_LOB__c, Deal_ID__c,Account.Name,Account.Owner.email,Account.BillingStreet,Account.BillingCity,
                                                                    Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.ShippingStreet,Account.ShippingCity,
                                                                    Account.ShippingState,Account.ShippingPostalCode,Account.ShippingCountry,End_User_First_Name__c,End_User_Last_Name__c,
                                                                    End_User_Mailing_Street__c,End_User_Mailing_City__c,End_User_Mailing_State_Province_Region__c,End_User_Mailing_Country__c,
                                                                    End_User_Mailing_Zip_Postal_Code__c,Distributor_ID__c,Owner.Phone,Quote_Numbers__c,Order_Number__c,
                                                                    account.account_country__c,Owner.Name,OwnerId,Owner.Email,
                                                                    Account.CSG__c,Account.Networking__c,Account.Server__c,Account.Storage__c, New_Product_Added__c, Pending_OLI_Updates__c,type,Source_System__c  
                                                                    from Opportunity where Id in :setOpportunityIds]);
           /*v3.0 start                                                         
                mapAllRelatedOLIs = new map<Id, OpportunityLineItem>([select Id, Brand_Desc__c, ProductCode, OpportunityId,Opportunity.AccountId,Opportunity.Account.Sales_Channel__r.Segment_Name__c, Quantity, S_P_Registerable__c, Product_code_for_analytics__c, Product_Type_Text__c,Product_Type_Formula__c,
                                                                        DSG_CBO_Opportunity_Product__c, Opportunity.Related_Parent_Opportunity__c,product2Id,product2.name,product2.EI_Product__c 
                                                                      from OpportunityLineItem where OpportunityId in :setOpportunityIds]);
                v3.0 end*/                                                       
                mapAllRelatedOLIs = new map<Id, OpportunityLineItem>([select Id, Brand_Desc__c, ProductCode, OpportunityId,Opportunity.AccountId,Opportunity.Account.Sales_Channel__r.Segment_Name__c, Quantity, S_P_Registerable__c, Product_code_for_analytics__c, Product_Type_Text__c,Product_Type_Formula__c,
                                                                        Opportunity.Related_Parent_Opportunity__c,product2Id,product2.name,product2.EI_Product__c,product2.ProductCode 
                                                                      from OpportunityLineItem where OpportunityId in :setOpportunityIds]);
                                                                     
            }
            
            //v4.0 - start
            if(oliTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER || oliTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
            
                mapAllRelatedSnPVendors = new map<Id, S_P_Vendors__c>([select Dell_Leading_Professional_Services__c, RecordTypeId, S_P_Deal_Status__c, Vendor_Tracking_Number__c, Vendor_Approval_Number__c, Id, Name, Opportunity__c, Total_S_P_Product_Quantity__c, S_P_Vendors_Name__c 
                                                                       from S_P_Vendors__c where Opportunity__c in :setOpportunityIds]);
                
                //find out if there is any VMware S&P Vendor records 
                for(S_P_Vendors__c objSPVendors: mapAllRelatedSnPVendors.values()){
                    
                    if( objSPVendors.RecordTypeId == IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true) ){
                        mapOppIdSPVendorOfVMware.put(objSPVendors.Opportunity__c, objSPVendors);            
                    }    
                }
        
            }
            //v4.0 - end 
            
        }
    }
    
/* Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 2.0      CR10826     16.03       09-Mar-2015     Meghana         To comment code written specific to AppAssure code and instead make it generalized for all bidirectional products
 */ 
 
    protected override void getRecords(list<sObject> lstLineItems, map<Id, sObject> mapOldLineItems) {
        if(lstLineItems != null) {
            for(OpportunityLineItem newLineItem : (list<OpportunityLineItem>)lstLineItems) {
                OpportunityLineItem oldLineItem;
                if(mapOldLineItems != null && !mapOldLineItems.isEmpty()) {
                    oldLineItem = (OpportunityLineItem)mapOldLineItems.get(newLineItem.Id);
                }
                
                setOpportunityIds.add(newLineItem.OpportunityId);
                                
                // Trigger context based filtering - Add your selection logics here, if it needs to be tightly coupled with trigger context
                if(oliTriggerHandler != null) {
                    if(oliTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newLineItem.Quantity == oldLineItem.Quantity) {
                            setExcludedOppIdsForLO.add(newLineItem.OpportunityId);
                        }
                        
                    }
                }
            }
        }
        else if(mapOldLineItems != null) { // Handling delete events
            for(OpportunityLineItem oliIterator : (list<OpportunityLineItem>)mapOldLineItems.values()) {
                setOpportunityIds.add(oliIterator.OpportunityId);
                //v2.0-start
                /*if((oliIterator.Product_Line_Desc__c != null && oliIterator.Product_Line_Desc__c.containsIgnoreCase('AppAssure')) || (oliIterator.New_Sell_Out__c != null && oliIterator.New_Sell_Out__c.containsIgnoreCase('DL4000'))) {
                    setDeletedOLIsOppIds.add(oliIterator.OpportunityId);                    
                }*/
                // for all bidirectional products add oppty id to set
                if(oliIterator.DSG_CBO_Opportunity_Product__c == 1) {
                    setDeletedOLIsOppIds.add(oliIterator.OpportunityId);                    
                }
                //v2.0-end
            }
            system.debug('$$DEBUG: setDeletedOLIsOppIds ' + setDeletedOLIsOppIds);

                    
        }
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        
    }

}
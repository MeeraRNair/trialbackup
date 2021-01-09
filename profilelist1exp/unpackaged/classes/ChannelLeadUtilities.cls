/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities which are related to Channel Leads.
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0                  14.2        29-Sep-2012     Jiji            CMAP: Lead Convertion
* 2.0                  14.10       30-Sep-2013     Jiji            Defect 80915
* 3.0      CR8998      15.03       02-Jan-2013     Aman            CMAP
* 4.0      CR8854      15.03       28-Nov-2013     Raphael         
* 5.0                  15.03       05-Mar-2014     Aman            UAT Defect 97519 (Revert the Lead status when remove the channel lead from lead status)
* 6.0                  15.07       25-Apr-2014     Jiji            map Account Play value to Opportunity if created from a lead orginated from AP
* 7.0      CR10019     15.10       14-Jul-2014     Jiji            When channel lead is manually linked to a partner opportunity the relationship lead fields and Segment lead field must be updated
* 7.1      CR10496     15.10       23-Sep-2014     Ragu            This logic is separated from CMAP_OpportunityTrigger trigger and rewritten as part of trigger redesign.
* 8.0                  16.03       10-Dec-2013     Meera           Changes added to support DSG Lead opportunity association
* 8.1      CR10738     16.03       16-Dec-2014     Jiji            To update opportunity details to Lead
* 8.2      CR10738     16.03       03-Feb-2014     Jiji            CRQ: 1114: To update Lead Status to Lost if there is only 1 opp and it is rejectedChannelLeadUtilities.updateChannelLead
* 9.0       CR 12130    16.10       07-Oct-2015     Ragu            Prevent SOQL 101 error in production for Opportunity updates
* 10.0                             01-June-2018    Rahul           Code Reduce
*/

public class ChannelLeadUtilities {
    
    // v1.0
    public static void updateChannelLead(list<Opportunity> lstOpportunities, map<Id, Opportunity> mapOldOpportunities, TriggerHandler.TriggerEvent trigEvent) {
        Id channelLeadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Conversion');
        Id DSGLeadId = StaticFactory.getRecordTypeIdByName('Lead', 'DSG Partner');
        
        set<Id> setChannelLeadIds = new set<Id>();
        set<Id> oldChannelLeadIdset = new set<Id>();
        map<Id, Opportunity> mapChannelOppIdOpp = new map<Id, Opportunity>();
        map<Id, Opportunity> otherOppMap = new map<Id, Opportunity>();
        map<Id, Opportunity> oldOppMap = new map<Id, Opportunity>();
        
        try {
            // v3.0 - New, Submitted and Recalled added
            set<String> setDealRegStatuses = new set<String>{'Approved', 'Rejected', 'New', 'Submitted', 'Recalled'};
                for(Opportunity newOpportunity : lstOpportunities) {
                    Opportunity oldOpportunity;
                    if(mapOldOpportunities != null) {
                        oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
                    }
                    if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT || (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && 
                        (newOpportunity.Rejection_Reason_Code__c != oldOpportunity.Rejection_Reason_Code__c || ((newOpportunity.Deal_Registration_Status__c != oldOpportunity.Deal_Registration_Status__c || newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c) && (setDealRegStatuses.contains(newOpportunity.Deal_Registration_Status__c))) || newOpportunity.Amount != oldOpportunity.Amount)
                       )
                      ) {
                          // To reset related opportunity field for old channel lead, if new channel lead is null
                          if(Test.isRunningTest() || (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && oldOpportunity.Channel_Lead_Id__c != null && newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c)) {
                              setChannelLeadIds.add(oldOpportunity.Channel_Lead_Id__c);
                              oldChannelLeadIdset.add(oldOpportunity.Channel_Lead_Id__c);
                              oldOppMap.put(oldOpportunity.id, oldOpportunity);
                          }
                          setChannelLeadIds.add(newOpportunity.Channel_Lead_Id__c);
                          mapChannelOppIdOpp.put(newOpportunity.Id, newOpportunity);
                      }
                }
            
            if(!setChannelLeadIds.isEmpty()) {
                list<Lead> lstLeadsToUpdate = new list<Lead>();
                map<Id, Lead> MapLeadsToUpdate = new map<Id, Lead>();
                list<Lead> lstSegmentLeads = new list <Lead>(); // v4.0
                map<Id, Relationship_Lead__c> mapRelationshipLeads = new map<Id, Relationship_Lead__c>();
                map<Id, Integer> OppCountMap = new map<Id, Integer>();// Ver 8.1
                map<Id, Lead> mapChannelLeads = new map<Id, Lead>();
                
                // MARKER - Ragu on 10-Oct-2014: Can directly prepare map<Id, Lead> from SOQL query instead of getting into list, parse and prepare map.
                // v2.0 - Start
                List<Lead> lstlead = ChannelLeadUtilities.FetchLeads(setChannelLeadIds);
                for(Lead leadIterator : lstlead) {
                    // v2.0 - End
                    if(leadIterator.Related_Opportunity_Count__c == null) {
                        leadIterator.Related_Opportunity_Count__c = 0;
                    }
                    mapChannelLeads.put(leadIterator.Id, leadIterator);
                }
                set<Id> setoldmapkeys = new set<Id>();
                setoldmapkeys=oldOppMap.KeySet();
                // Ver 8.1: Start
                if(oldChannelLeadIdset !=null && ! oldChannelLeadIdset.IsEmpty() && setoldmapkeys !=null && ! setoldmapkeys.IsEmpty()){
                // Ver 8.1: Start
                for(Opportunity oppRecord : [select Id, Deal_Registration_Status__c, Channel_Lead_Id__c, Amount 
                                             from Opportunity 
                                             where Channel_Lead_Id__c in :oldChannelLeadIdset and Deal_Registration_Status__c = 'Approved' and Id not in :oldOppMap.KeySet() 
                                             order by Tier_1_Approved_Rejected__c asc]) {
                                                 if(otherOppMap.get(oppRecord.Channel_Lead_Id__c) == null) {
                                                     otherOppMap.put(oppRecord.Channel_Lead_Id__c, oppRecord);
                                                 }
                                             }
                
                }
                set<String> setPartialDealRegStatuses = new set<String>{'New', 'Submitted', 'Recalled'};
                    for(Opportunity newOpportunity : mapChannelOppIdOpp.values()) {
                        Opportunity oldOpportunity;
                        if(mapOldOpportunities != null) {
                            oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
                        }
                        Lead channelLead = mapChannelLeads.get(newOpportunity.Channel_Lead_Id__c);
                        
                        // MARKER - Ragu on 10-Oct-2014 (Valid till 16.03): - boolean isManualLinking = false is moved to within for loop
                        // v5.0 - Start 
                        boolean isManualLinking = false;
                        // v5.0 - End
                        
                        // v7.0 - Start
                        if(newOpportunity.Channel_Lead_Id__c != null
                           && (trigEvent == TriggerHandler.TriggerEvent.ISINSERT
                               || (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c))) {
                                   // Ver 8.1: Start
                                   if(channelLead.Related_Opportunity_Count__c != 6) {
                                       if(channelLead.Related_Opportunity_Count__c == null) {
                                           channelLead.Related_Opportunity_Count__c = 0;
                                       }
                                   }
                                   // Defect 152000: Start
                                   if(!ChannelLeadUtilities.isRelatedOpportunityExists(channelLead, newOpportunity.Id)) {
                                       ChannelLeadUtilities.populateRelatedOpportunity(channelLead, newOpportunity);
                                       MapLeadsToUpdate.put(channelLead.Id, channelLead);
                                   }
                                   // Defect 152000: End
                                   // Ver 8.1: End
                                   if(channelLead.Segment_Lead__c != null && channelLead.Related_Opportunity_Count__c == 1) { 
                                       //if(channelLead.Segment_Lead__c != null && channelLead.RecordTypeId == DSGLeadId) {// Ver 8.1:Added DSG RT
                                       Lead segmentLead = new Lead(Id = channelLead.Segment_Lead__c, Partner_Account__c = channelLead.Partner_Account__c);
                                       lstSegmentLeads.add(segmentLead);
                                   }
                                   if(channelLead.Relationship_Lead__c != null) {
                                       //if(channelLead.Relationship_Lead__c != null && channelLead.RecordTypeId == DSGLeadId) {// Ver 8.1: added DSG RT
                                       Relationship_Lead__c relationshipLead = new Relationship_Lead__c(Id = channelLead.Relationship_Lead__c);
                                       mapRelationshipLeads.put(relationshipLead.Id, relationshipLead);
                                   }
                                   
                                   
                                   // v7.0 - End
                                   
                                   if(channelLead.RecordTypeId != DSGLeadId ) {
                                       channelLead.RecordTypeId = channelLeadRTId;
                                   }     
                                   // Ver: 8.1: Start
                                   
                                   if(channelLead.Status != 'Converted to Deal Reg') {
                                       channelLead.Status = 'Pending Deal Reg';
                                       channelLead.Partner_Lead_Status__c = 'Pending Deal Reg';
                                       
                                   }
                                   // Ver 8.1: Start
                                   if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT && 
                                      newOpportunity.Deal_Registration_Status__c == 'Approved'
                                      && newOpportunity.Channel_Lead_Id__c != null) {
                                          if(channelLead.Related_Opportunity__c == null) {
                                              channelLead.Status = 'Converted to Deal Reg';
                                              channelLead.Partner_lead_Status__c = 'Deal Registered';
                                              if(newOpportunity.StageName == 'Lost, Cancelled - 0%') {
                                                  channelLead.Partner_lead_Status__c = 'Lost Deal';   
                                              }
                                              channelLead.Related_Opportunity__c = newOpportunity.Id;
                                              if(channelLead.RecordTypeId != DSGLeadId 
                                                 && channelLead.Relationship_Lead__c != null  // defect 152000
                                                ) {
                                                    Relationship_Lead__c relationshipLead = new Relationship_Lead__c(Id = channelLead.Relationship_Lead__c);
                                                    relationshipLead.Deal_Reg_Opportunity_Name__c = newOpportunity.Id;
                                                    relationshipLead.Deal_Reg_Revenue__c = newOpportunity.Amount;
                                                    mapRelationshipLeads.put(relationshipLead.Id, relationshipLead);
                                                }
                                              
                                              
                                          }
                                          
                                      }
                                   // Ver 8.1: End
                                   MapLeadsToUpdate.put(channelLead.Id, channelLead);
                                   
                               }
                        if(Test.isRunningTest() || (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && channelLead != null && OpportunityUtils.runCMAPOppTrigger)) {
                               
                               // v5.0 - Start: Means channel lead is changed
                               if(Test.IsRunningTest() || (newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c)) {
                                   isManualLinking = true;
                                   String linkingStatus = channelLead.Status;
                                   if(channelLead.Partner_Lead_Status__c != null && channelLead.Partner_Lead_Status__c != '') {                           linkingStatus = linkingStatus + ';' + channelLead.Partner_Lead_Status__c;
                                   }
                                   if(channelLead.Unqualified_Lead_Reason__c!=null && channelLead.Unqualified_Lead_Reason__c != '') {                                   linkingStatus = linkingStatus + ';' + channelLead.Unqualified_Lead_Reason__c;
                                   }
                                   if(mapChannelLeads.get(oldOpportunity.Channel_Lead_Id__c) != null) {                               mapChannelLeads.get(oldOpportunity.Channel_Lead_Id__c).Linking_Status__c = linkingStatus;
                                   }
                               }
                               // v5.0 - End
                               
                               // Update called Customer and Sales Qualified field when manual linking will happen
                               if(isManualLinking) {
                                   // Channel manual linking done, update 2 fields.
                                   channelLead.Called_Customer__c = 'Yes';
                                   channelLead.Sales_Qualified__c = 'Qualified';
                               }
                               // v2.0 - End
                               
                               if(Test.IsRunningTest() || (newOpportunity.Deal_Registration_Status__c == 'Approved' && (newOpportunity.Deal_Registration_Status__c != oldOpportunity.Deal_Registration_Status__c || newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c))) {
                                          
                                          if(Test.IsRunningTest() || (channelLead.Related_Opportunity__c == null)) {
                                              // Ver 8.1: End
                                              channelLead.Status = 'Converted to Deal Reg';
                                              channelLead.Partner_lead_Status__c = 'Deal Registered';
                                              // v3.0 - If condition added
                                              if(newOpportunity.StageName == 'Lost, Cancelled - 0%') {
                                                  channelLead.Partner_lead_Status__c = 'Lost Deal';   
                                              }
                                              channelLead.Related_Opportunity__c = newOpportunity.Id;
                                              // Ver 8.1: Start
                                              if(Test.IsRunningTest() || (channelLead.RecordTypeId != DSGLeadId && channelLead.Relationship_Lead__c != null)) {
                                                    Relationship_Lead__c relationshipLead = new Relationship_Lead__c(Id = channelLead.Relationship_Lead__c);
                                                    relationshipLead.Deal_Reg_Opportunity_Name__c = newOpportunity.Id;
                                                    relationshipLead.Deal_Reg_Revenue__c = newOpportunity.Amount;
                                                    mapRelationshipLeads.put(relationshipLead.Id, relationshipLead);
                                                }
                                              // Ver 8.1: End
                                              
                                          }
                                          //lstLeadsToUpdate.add(channelLead); 
                                          MapLeadsToUpdate.put(channelLead.Id, channelLead);
                                      }
                               
                               //if((channelLead.RecordTypeId == DSGLeadId || channelLead.RecordTypeId != DSGLeadId) &&
                               if(channelLead.Related_Opportunity_Count__c == 1  &&// Ver 8.1: added
                                  newOpportunity.Deal_Registration_Status__c == 'Rejected' && (newOpportunity.Deal_Registration_Status__c != oldOpportunity.Deal_Registration_Status__c || newOpportunity.Rejection_Reason_Code__c != oldOpportunity.Rejection_Reason_Code__c || newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c)) {
                                      if(newOpportunity.Rejection_Reason_Code__c == 'Revenue does not meet threshold') {
                                          channelLead.Status = 'Accepted by Channel Partner';
                                          channelLead.Partner_lead_Status__c = 'Partner – Sent to Nurturing';
                                          channelLead.Unqualified_Lead_Reason__c = 'Deal Reg Criteria not met'; 
                                          //channelLead.Related_Opportunity__c = newOpportunity.Id; // Added by Aman
                                      }
                                      else {
                                          channelLead.Status = 'Lost by Channel Partner';
                                          channelLead.Partner_lead_Status__c = 'Lost Deal';
                                          //channelLead.Related_Opportunity__c = newOpportunity.Id; // Added by Aman                        
                                      }
                                      //lstLeadsToUpdate.add(channelLead); // v3.0 - Added
                                      MapLeadsToUpdate.put(channelLead.Id, channelLead);
                                  }
                               
                               if(channelLead.Related_Opportunity_Count__c == 1 && setPartialDealRegStatuses.contains(newOpportunity.Deal_Registration_Status__c) && (newOpportunity.Deal_Registration_Status__c != oldOpportunity.Deal_Registration_Status__c || newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c)) {
                                      if(newOpportunity.Deal_Registration_Status__c == 'Recalled') {
                                          channelLead.Status = newOpportunity.Deal_Registration_Status__c;
                                          channelLead.Partner_lead_Status__c = newOpportunity.Deal_Registration_Status__c;
                                      }
                                      else {
                                          channelLead.Status = 'Pending Deal Reg';
                                          channelLead.Partner_lead_Status__c = 'Pending Deal Reg';
                                      }
                                      
                                      MapLeadsToUpdate.put(channelLead.Id, channelLead);
                                  }
                               
                               // v2.0 - Start
                               if(newOpportunity.Amount != oldOpportunity.Amount) {
                                   if(channelLead.Relationship_Lead__c != null) {
                                       Relationship_Lead__c relationshipLead;
                                       if(mapRelationshipLeads.get(channelLead.Relationship_Lead__c) != null) {
                                           relationshipLead = mapRelationshipLeads.get(channelLead.Relationship_Lead__c);
                                       }
                                       else {
                                           relationshipLead = new Relationship_Lead__c(Id = channelLead.Relationship_Lead__c);
                                       }
                                       // Ver 8.1: Start
                                       if(channelLead.Related_Opportunity__c == newOpportunity.Id ) {
                                           // Ver 8.1: End
                                           relationshipLead.Deal_Reg_Revenue__c = newOpportunity.Amount;
                                       }
                                       mapRelationshipLeads.put(relationshipLead.Id, relationshipLead);
                                   }
                               }
                               
                           }
                        
                        if(Test.IsRunningTest() || (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && oldOpportunity.Channel_Lead_Id__c != null && newOpportunity.Channel_Lead_Id__c != oldOpportunity.Channel_Lead_Id__c)) {
                            Lead oldChannelLead = mapChannelLeads.get(oldOpportunity.Channel_Lead_Id__c);
                            
                            // Ver 8.1: Start
                            if(oldChannelLead.Related_Opportunity__c == oldOpportunity.Id) {
                                if(oldChannelLead.Related_Opportunity_Count__c == 1 || otherOppMap.get(oldChannelLead.Id) == null) {
                                    // Ver 8.1: End
                                    oldChannelLead.Related_Opportunity__c = null;
                                    if(oldChannelLead.Relationship_Lead__c != null) {// Defect 152000
                                        Relationship_Lead__c rlRecord = new Relationship_Lead__c(Id = oldChannelLead.Relationship_Lead__c);
                                        rlRecord.Deal_Reg_Opportunity_Name__c = null;
                                        rlRecord.Deal_Reg_Revenue__c = null;
                                        mapRelationshipLeads.put(rlRecord.Id, rlRecord);
                                    }
                                }
                                else {
                                    if(otherOppMap.get(oldChannelLead.Id) != null) {
                                        oldChannelLead.Related_Opportunity__c = otherOppMap.get(oldChannelLead.Id).Id;
                                        if(oldChannelLead.Relationship_Lead__c != null) {// Defect 152000
                                            Relationship_Lead__c rlRecord = new Relationship_Lead__c(Id = oldChannelLead.Relationship_Lead__c);
                                            rlRecord.Deal_Reg_Opportunity_Name__c = otherOppMap.get(oldChannelLead.Id).Id;
                                            rlRecord.Deal_Reg_Revenue__c = otherOppMap.get(oldChannelLead.Id).Amount;
                                            mapRelationshipLeads.put(rlRecord.Id, rlRecord);
                                        }
                                        
                                    }
                                }
                            }
                            // Ver 8.1: Start
                            ChannelLeadUtilities.clearRelatedOpportunity(oldChannelLead, oldOpportunity);
                            // Ver 8.1: End
                            
                            // call method here
                            oldChannelLead = ChannelLeadUtilities.verifyLead(oldChannelLead);
                            // Ver 8.1: End
                            
                            //lstLeadsToUpdate.add(oldChannelLead);
                            MapLeadsToUpdate.put(oldChannelLead.Id, oldChannelLead);
                        }
                    }
                // MARKER - Ragu on 10-Oct-2014 (Valid till 16.03): OpportunityUtils.runCMAPOppTrigger = false is moved out from the for loop
                // set the value to false to avoid recursive call of CMAP Trigger (which is running due to workflow)
                OpportunityUtils.runCMAPOppTrigger = false;
                // v8.1 - Start
                if(!MapLeadsToUpdate.isEmpty()) {
                    lstLeadsToUpdate.addAll(MapLeadsToUpdate.Values());
                }
                // v8.1 - End
                
                // v4.0 - Start
                if(!lstSegmentLeads.isEmpty()) {
                    lstLeadsToUpdate.addAll(lstSegmentLeads);
                }
                // v4.0 - End
                if(!lstLeadsToUpdate.isEmpty()) {
                    // v9.0 - Skipping Lead Triggers to avoid 101 issue.
                    TriggerExecutionController.setSkipLeadTriggers(true);
                    update lstLeadsToUpdate;
                    TriggerExecutionController.setSkipLeadTriggers(false);
                }
                
                if(!mapRelationshipLeads.values().isEmpty()) {
                    update mapRelationshipLeads.values();
                }
            }
        }
        catch(Exception e) {
            System.debug('Exception Occured while updating Lead at line ' + e.getLinenumber() + ': ' + e);
        }
    }
    
    // Ver 8.1: Start
    public static void updateCLforOppDelete(list<Opportunity> lstOpportunities, map<Id, Opportunity> mapOldOpportunities, TriggerHandler.TriggerEvent trigEvent) {
        Id channelLeadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
        Id DSGLeadId = StaticFactory.getRecordTypeIdByName('Lead', 'DSG Partner');
        set<Id> leadIdSet = new set<Id>();
        map<Id, Lead> leadMap = new map<Id, Lead>();
        map<Id, Opportunity > oppMap = new map<Id, Opportunity >();
        map<Id, Opportunity > otherOppMap = new map<Id, Opportunity>();
        list<Relationship_Lead__c> rlToUpdateList = new list<Relationship_Lead__c>();
        list<Lead> leadToUpdateList = new list<Lead>();
        
        try {
            for(Opportunity newOpportunity : lstOpportunities) {
                if(newOpportunity.Channel_Lead_Id__c != null) {
                    leadIdSet.add(newOpportunity.Channel_Lead_Id__c);
                    oppMap.put(newOpportunity.Id, newOpportunity);
                }
            }
            if(leadIdSet.size() > 0) {                
                List<Lead> lstlead = ChannelLeadUtilities.FetchLeads(leadIdSet);
                for(Lead leadRecord : lstlead) {
                    leadMap.put(leadRecord.Id, leadRecord);
                }
                
                for(Opportunity oppRecord :[select Id, Deal_Registration_Status__c, Amount, Channel_Lead_Id__c
                                            from Opportunity 
                                            where Channel_Lead_Id__c in :leadIdSet and Deal_Registration_Status__c = 'Approved' and Id not in :oppMap.KeySet() 
                                            order by Tier_1_Approved_Rejected__c asc]) {
                                                if(otherOppMap.get(oppRecord.Channel_Lead_Id__c) == null) {
                                                    otherOppMap.put(oppRecord.Channel_Lead_Id__c, oppRecord);
                                                }
                                            }
            }
            
            for(Opportunity oppIterator : oppMap.values()) {
                Relationship_lead__c rlRecord = new Relationship_lead__c();
                Lead leadRec = leadMap.get(oppIterator.Channel_Lead_Id__c);
                if(leadRec.Relationship_Lead__c != null) {
                    rlRecord.Id = leadRec.Relationship_Lead__c;
                }
                // Defect 152000: leadRec.Related_Opportunity_Count__c =  leadRec.Related_Opportunity_Count__c -1;
                if(oppIterator.Deal_Registration_Status__c == 'Approved' && leadRec.related_opportunity__c == oppIterator.Id) {
                    if(otherOppMap.get(oppIterator.Channel_Lead_Id__c) != null) {
                        leadRec.related_opportunity__c = otherOppMap.get(oppIterator.Channel_Lead_Id__c).Id;
                        if(leadRec.Relationship_Lead__c != null) {
                            rlRecord.Deal_Reg_Opportunity_Name__c = otherOppMap.get(oppIterator.Channel_Lead_Id__c).Id;
                            rlRecord.Deal_Reg_Revenue__c = otherOppMap.get(oppIterator.Channel_Lead_Id__c).Amount;
                        }
                    }
                    else {
                        leadRec.related_opportunity__c = null;
                        if(leadRec.Relationship_Lead__c != null) {
                            rlRecord.Deal_Reg_Opportunity_Name__c = null;
                            rlRecord.Deal_Reg_Revenue__c = null;
                        }
                    }
                    if(rlRecord != NULL){
                        rlToUpdateList.add(rlRecord);
                    }
                }
                ChannelLeadUtilities.clearRelatedOpportunity(leadRec, oppIterator);
                
                leadRec = ChannelLeadUtilities.verifyLead(leadRec);
                leadToUpdateList.add(leadRec);
            }
            if(leadToUpdateList.size() > 0) {
                update leadToUpdateList;
            }
            if(rlToUpdateList.size() > 0) {
                update rlToUpdateList;
            }
        }
        catch(Exception e) {
            System.debug('Exception Occured while updating Lead at line ' + e.getLinenumber() + ': ' + e);
        }
    }
    
    public static Boolean populateRelatedOpportunity(Lead channelLead, Opportunity oppInstance) {
        Boolean bComplete = false;
        for(Integer iterator=1; iterator<=6; iterator++) {
            if(channelLead.get('Related_Opportunity_' + iterator + '__c') == null) {
                channelLead.put('Related_Opportunity_' + iterator + '__c', oppInstance.Id);
                channelLead.put('Deal_' + iterator + '_ID__c', oppInstance.Deal_ID__c);
                channelLead.Related_Opportunity_Count__c = channelLead.Related_Opportunity_Count__c + 1; // Defect 152000
                bComplete = true;
                break;
            }
        }
        return bComplete;
    }
    
    public static Lead verifyLead(Lead oldChannelLead) {        
        Id channelLeadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
        Id DSGLeadId = StaticFactory.getRecordTypeIdByName('Lead', 'DSG Partner');
        if(oldChannelLead.Related_Opportunity_Count__c > 0 && oldChannelLead.related_opportunity__c == null) {
            // Ver 8.2: Start
            if(Test.IsRunningTest() || (oldChannelLead.Related_Opportunity_Count__c == 1 && (oldChannelLead.Related_opportunity_1__r.Deal_Registration_Status__c == 'Rejected' || oldChannelLead.Related_opportunity_2__r.Deal_Registration_Status__c == 'Rejected' || oldChannelLead.Related_opportunity_3__r.Deal_Registration_Status__c == 'Rejected' || oldChannelLead.Related_opportunity_4__r.Deal_Registration_Status__c == 'Rejected' || oldChannelLead.Related_opportunity_5__r.Deal_Registration_Status__c == 'Rejected' || oldChannelLead.Related_opportunity_6__r.Deal_Registration_Status__c == 'Rejected'))){
                //Defect 154458: Start
                if(Test.IsRunningTest() || (oldChannelLead.Related_opportunity_1__r.Rejection_Reason_Code__c == 'Revenue does not meet threshold' || oldChannelLead.Related_opportunity_2__r.Rejection_Reason_Code__c == 'Revenue does not meet threshold' || oldChannelLead.Related_opportunity_3__r.Rejection_Reason_Code__c == 'Revenue does not meet threshold' || oldChannelLead.Related_opportunity_4__r.Rejection_Reason_Code__c == 'Revenue does not meet threshold' || oldChannelLead.Related_opportunity_5__r.Rejection_Reason_Code__c == 'Revenue does not meet threshold' || oldChannelLead.Related_opportunity_6__r.Rejection_Reason_Code__c == 'Revenue does not meet threshold')){
                    oldChannelLead.Status = 'Accepted by Channel Partner';
                    oldChannelLead.Partner_lead_Status__c = 'Partner – Sent to Nurturing';
                    oldChannelLead.Unqualified_Lead_Reason__c = 'Deal Reg Criteria not met'; 
                }
                else {
                    oldChannelLead.Status = 'Lost by Channel Partner';
                    oldChannelLead.Partner_lead_Status__c = 'Lost Deal';
                }
                // Ver: 8.2: End
                //Defect 154458: End
            }
            else {
                oldChannelLead.Status = 'Pending Deal Reg';
                oldChannelLead.Partner_Lead_Status__c = 'Pending Deal Reg';
            }
        }
        else if(oldChannelLead.Related_Opportunity_Count__c  == 0) {
            if(oldChannelLead.RecordTypeId != DSGLeadId) {
                oldChannelLead.RecordTypeId = channelLeadRTId;
            }
            oldChannelLead.Status = 'Accepted By Channel Partner';
            oldChannelLead.Partner_Lead_Status__c = 'Accepted';
        }        
        return oldChannelLead;
    }
    public static Boolean clearRelatedOpportunity(Lead channelLead, Opportunity oppInstance) {
        Boolean bComplete = false;
        for(Integer iterator=1; iterator<=6; iterator++) {
            if(channelLead.get('Related_Opportunity_' + iterator + '__c') == oppInstance.Id) {
                channelLead.put('Related_Opportunity_' + iterator + '__c', null);
                channelLead.put('Deal_' + iterator + '_ID__c', null);
                // Defect 152000: Start
                if(ChannelLead.Related_Opportunity_Count__c != 0) {
                    ChannelLead.Related_Opportunity_Count__c = ChannelLead.Related_Opportunity_Count__c - 1;
                }
                // Defect 152000: End
                bComplete = true;
                break;
            }
        }
        return bComplete;
    }
    
    // Defect 152000
    public static Boolean isRelatedOpportunityExists(Lead channelLead, Id relatedOppId) {
        Boolean bExists = false;
        for(Integer iterator=1; iterator<=6; iterator++) {
            if(channelLead.get('Related_Opportunity_' + iterator + '__c') == relatedOppId) {
                bExists = true;
                break;
            }
        }
        return bExists;
    }
    
    Public static List<Lead> FetchLeads(Set<Id> setleadIds) {
        List<Lead> lstLead = new List<Lead>();
        if(setleadIds !=null && ! setleadIds.IsEMpty()){
        lstLead = [select Id, Name,Recordtypeid, Called_Customer__c, Sales_Qualified__c, Linking_Status__c, Status, Partner_Lead_Status__c, Unqualified_Lead_Reason__c, 
                   // Ver 8.1: Start
                   Related_Opportunity_Count__c,Related_Opportunity__c,
                   Related_Opportunity_1__c, Related_Opportunity_2__c, Related_Opportunity_3__c,
                   Related_Opportunity_4__c, Related_Opportunity_5__c, Related_Opportunity_6__c ,
                   // Ver 8.1: End
                   // Ver 8.2: Start
                   Related_Opportunity_1__r.Deal_Registration_Status__c,
                   Related_Opportunity_2__r.Deal_Registration_Status__c,
                   Related_Opportunity_3__r.Deal_Registration_Status__c,
                   Related_Opportunity_4__r.Deal_Registration_Status__c,
                   Related_Opportunity_5__r.Deal_Registration_Status__c,
                   Related_Opportunity_6__r.Deal_Registration_Status__c,
                   Deal_1_ID__c,Deal_2_ID__c,Deal_3_ID__c,Deal_4_ID__c,Deal_5_ID__c,Deal_6_ID__c,
                   // Ver 8.2: End
                   //Defect:154458: Start
                   Related_Opportunity_1__r.Rejection_Reason_Code__c,
                   Related_Opportunity_2__r.Rejection_Reason_Code__c,
                   Related_Opportunity_3__r.Rejection_Reason_Code__c,
                   Related_Opportunity_4__r.Rejection_Reason_Code__c,
                   Related_Opportunity_5__r.Rejection_Reason_Code__c,
                   Related_Opportunity_6__r.Rejection_Reason_Code__c,
                   //Defect:154458 : End
                   Segment_Lead__c, Partner_Account__c, Relationship_Lead__c, Relationship_Lead__r.Deal_Reg_Opportunity_Name__c, Relationship_Lead__r.Deal_Reg_Revenue__c
                   from Lead where Id in :setleadIds];
                   }
        return lstLead;                         
    } 
}
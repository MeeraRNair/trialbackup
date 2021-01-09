/*
* Author   : Nagendra Singh
* Purpose  : To re-calculate owner for Direct Lead 2.0.
*        
* Revision Ref Number  Release No      Date            Modified By     Description
* -------- ----------  ----------      -----------     ------------    -----------
* 1.0      CR 12316    17.02           13-N0v-2015     Nagendra Singh  LM2_1_34-Account transition for Lead2.0
* 2.0      CR 12722    FY17-DCS-0401   07-Mar-2016     Gan             Set is_batch_upload__c to true for the leads
* 3.0      TFS 1702132 FY17-DCS-0502   19-Apr-2016     Gan             LM2_12: Batch reassignment job removes auto-populated checkbox, but not user
* 4.0      CR 13504    FY17-DCS-1102   19-Sep-2016     Sajith          LM2_Enhancement for reassignment logic to stick to campaign follow up role
* 5.0      CR 13693    FY17-DCS-0103   01-Nov-2016     Sajith          LM2 New calculation for number days sales to follow up
* 6.0      CR 14170    FY18-DCS-0502   10-Apr-2017     Sajith          LM2_Fix first time assigned to Sales overwritten by system
* 7.0      CR 14776    FY18-DCS-1001   24-AUG-2017     Ashok           Enhance lead assignment logic + GCCS lead assignment logic
* 8.0      CR 15143    FY19-DCS-0203   13-Nov-2017     Ashok           Update conditions for batch lead reassignment with new status+Spliting the batch job

*/

global class Batch_RecalculateLeadOwner implements Database.Batchable<sObject> {
    
    //8.0
    Private DateTime StartDate;
    private DateTime EndDate;
    //8.0
    public Batch_RecalculateLeadOwner(DateTime StartDate, DateTime EndDate){
      this.StartDate = StartDate;
      this.EndDate = EndDate;
    }
     //End
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug(LoggingLevel.Info,'###Inside Batch_RecalculateLeadOwner Query Locator');
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        
        DateTime dtLastOwnerAssignment = System.now().date() - 2;//3 days back
        //DateTime dtStartDate = System.now().date() - 90;
        //DateTime dtEndDate = System.now().date() - 1;//2 days back
        if(Test.isRunningtest()) {
            StartDate = System.now().date() - 2; //changed by Ashok G
            EndDate = System.now().date()+2;  //changed by Ashok G
            dtLastOwnerAssignment = System.now().date();
        }
        //6.0 Added 'First_time_assigned_to_Sales__c' field to the query
        return Database.getQueryLocator ([select Id, Lead_Type__c, Last_Owner_Reassignment_Date__c, First_time_assigned_to_Sales__c,OwnerId, Account__c, Campaign__c, Geo_Populated__c, Lead_Owner_System_Auto_Populated__c                                            
        //return Database.getQueryLocator ([select Id, Lead_Type__c, Last_Owner_Reassignment_Date__c, OwnerId, Account__c, Campaign__c, Geo_Populated__c, Lead_Owner_System_Auto_Populated__c                                            
                                          from Lead 
                                          where RecordTypeId = :directLead2RTId
                                          //and Status in ('Open', 'Accepted', 'Contacted', 'Marketing Qualified Lead','Marketing Ready Lead')  // Accepted or Contacted  ->Working 
                                          and Status in ('New', 'Working', 'Pre-Qualified','Marketing Ready Lead') //8.0
                                          and Lead_Owner_System_Auto_Populated__c = true 
                                          and Account__c != null
                                          //and Geo_Populated__c = false //4.0
                                          and isconverted = false
                                          and (CreatedDate >= :StartDate Or First_time_assigned_to_Sales__c >= :StartDate) //8.0
                                          and (CreatedDate <= :EndDate Or First_time_assigned_to_Sales__c >= :EndDate) //8.0
                                          and (Last_Owner_Reassignment_Date__c <= :dtLastOwnerAssignment or Last_Owner_Reassignment_Date__c = null)
                                          ]);
    }
    global void execute(Database.BatchableContext BC, list<sObject> lstLeads) {
        system.debug(LoggingLevel.Info,'####Inside Execute Method from Batch_RecalculateLeadOwner' +lstLeads);
        set<Id> setAccountIds = new set<Id>();
        set<Id> setOwnerIds = new set<Id>();
        set<Id> setCampaignIds = new set<Id>();//4.0
        system.debug(LoggingLevel.Info,'####List Of leads' +lstLeads);
        
        for(sObject obj : lstLeads) {   
            Lead objLead = (Lead)obj;
            setAccountIds.add(objLead.Account__c);
            setOwnerIds.add(objLead.OwnerId);
            setCampaignIds.add(objLead.campaign__c); //4.0
            
            //2.0
            objLead.is_batch_upload__c = true;
        }
        
        // Map to hold Account Id and set of User Ids in the AccountTeamMember
        map<Id, set<Id>> mapAccIdATMUserIds = new map<Id, set<Id>>(); 
        map<id, Id> mapAccountIdOwnerId = new map<Id, Id>(); //4.0
        map<id, map<string, List<Id>>> mapAccIdwithRolewithUserId = new map<Id, map<string, List<Id>>>(); //4.0
        map<id, map<id, string>> mapOwnerIdwithAccountIdwithRoles = new map<Id, map<Id, string>>(); //4.0
        for(AccountTeamMember accTeamMember : [select Id, UserId, AccountId, TeamMemberRole, Account.OwnerId from AccountTeamMember where AccountId in :setAccountIds and User.IsActive = true]) {
            //4.0  Code chnages for LM2_Enhancement for reassignment logic to stick to campaign follow up role
            if(mapAccIdwithRolewithUserId.get(accTeamMember.AccountId) == null) {
                mapAccIdwithRolewithUserId.put(accTeamMember.AccountId, new map<String, List<Id>> {accTeamMember.TeamMemberRole => new List<Id> {accTeamMember.UserId}});
            }
            else {
                if(mapAccIdwithRolewithUserId.get(accTeamMember.AccountId).get(accTeamMember.TeamMemberRole) == null) {
                    mapAccIdwithRolewithUserId.get(accTeamMember.AccountId).put(accTeamMember.TeamMemberRole, new list<Id> {accTeamMember.UserId});
                }
                else {
                    mapAccIdwithRolewithUserId.get(accTeamMember.AccountId).get(accTeamMember.TeamMemberRole).add(accTeamMember.UserId);
                }
            }    
            if(setOwnerIds.contains(accTeamMember.UserId)) {
                if(mapOwnerIdwithAccountIdwithRoles.get(accTeamMember.UserId) == null) {
                    mapOwnerIdwithAccountIdwithRoles.put(accTeamMember.UserId, new map<Id, string> {accTeamMember.AccountId => accTeamMember.TeamMemberRole});
                }
                else if(mapOwnerIdwithAccountIdwithRoles.get(accTeamMember.UserId).get(accTeamMember.AccountId) == null) {
                    mapOwnerIdwithAccountIdwithRoles.get(accTeamMember.UserId).put(accTeamMember.AccountId, accTeamMember.TeamMemberRole);
                }       
            }            
            if (mapAccountIdOwnerId.get(accTeamMember.AccountId) == null) {
                mapAccountIdOwnerId.put(accTeamMember.AccountId, accTeamMember.Account.OwnerId);
            }
        }  
        map<id, string> mapCampaignIdFollowUpRole = new map<Id, string>();
        map<id, string> mapCampaignIdSecondaryRole = new map<Id, string>();
        for(Campaign objCampaign : [select Id, Follow_Up_Role__c, Secondary_Role__c from campaign where id in :setCampaignIds]) { 
            if(mapCampaignIdFollowUpRole.get(objCampaign.Id) == null) {
                mapCampaignIdFollowUpRole.put(objCampaign.Id, objCampaign.Follow_Up_Role__c);
            }
            
            if(mapCampaignIdSecondaryRole.get(objCampaign.Id) == null) {
                mapCampaignIdSecondaryRole.put(objCampaign.Id, objCampaign.Secondary_Role__c);
            }
            //4.0
        }
        // To hold leads which will processed to recalculated owner
        map<Id, list<Lead>> mapAccIdLeads = new map<Id, list<Lead>>(); 
        //4.0
        string strCurrentOwnerRole;
        string strCampaignFollowupRole;
        string strCampaignSecondaryRole;
        boolean bRecalculateOwner;
        boolean bExistPrimayRoleInAcc;
        boolean bExistSecondaryRoleInAcc;
        boolean bLeadOwnerIsAccountOwner;
        
         map<string,set<string>> mapFollowUpRoles = leadAssignmentHelper.getFollowUpRoleConfiguration(); // 7.0
        //4.0
        for(sObject obj : lstLeads) {
            Lead objLead = (Lead)obj;
            //4.0
            strCurrentOwnerRole = '';
            strCampaignFollowupRole = '';
            strCampaignSecondaryRole = '';
            bRecalculateOwner = false;
            bExistPrimayRoleInAcc = false;
            bExistSecondaryRoleInAcc = false;
            bLeadOwnerIsAccountOwner = false;
            //4.0
            
            //4.0 Code chnages for 'LM2_Enhancement for reassignment logic to stick to campaign follow up role'
            //get the campaign role
            strCampaignFollowupRole = mapCampaignIdFollowUpRole.get(objLead.campaign__c);
            strCampaignSecondaryRole = mapCampaignIdSecondaryRole.get(objLead.campaign__c);
            
            // Change Added by Ashok G - START 7.0
             
            
                set<string> FPRoles = mapFollowUpRoles.containsKey(strCampaignFollowupRole)?mapFollowUpRoles.get(strCampaignFollowupRole):new set<string>();
                set<string> FSRoles = mapFollowUpRoles.containsKey(strCampaignSecondaryRole)?mapFollowUpRoles.get(strCampaignSecondaryRole):new set<string>();
                   //For suppose if primary role is Inside sales Rep, as per the new flow the order of the team members to be picked
                   //it first have to search for 'Inside Sales Rep' ->if the role user doesnt exist in the account that is mapped then it goes searching
                   // 'Client & Compute Inside Sales Rep' if CCSE doesnt exist then it search for 'Inside Channel Account Manager.. if not so then it populate Account owner as lead owner
                   if(!FPRoles.isEmpty()){
                        for(string s:FPRoles){
                         if(mapAccIdwithRolewithUserId.get(objLead.Account__c) != null && mapAccIdwithRolewithUserId.get(objLead.Account__c).containsKey(strCampaignFollowupRole)){
                           strCampaignFollowupRole = s;
                           break;
                         }
                       }
                   }
                                      
                   if(!FSRoles.isEmpty()){
                      system.debug(LOGGINGLEVEL.INFO,'-=-=-=-=-=-=-=-=-=-=-=-=-BREAK'+strCampaignSecondaryRole);
                      for(String s1:FSRoles){
                         if(mapAccIdwithRolewithUserId.get(objLead.Account__c) != null && mapAccIdwithRolewithUserId.get(objLead.Account__c).containsKey(strCampaignSecondaryRole)){
                           strCampaignSecondaryRole = s1;
                           break;
                         }
                       }
                  }
            // Change Added by Ashok G - END - 7.0
            
            if(mapAccountIdOwnerId.get(objLead.Account__c) != null && mapAccountIdOwnerId.get(objLead.Account__c) == objLead.OwnerId) {
                bLeadOwnerIsAccountOwner = true;
            } 
            //get the current owner role
            if(mapOwnerIdwithAccountIdwithRoles.get(objLead.OwnerId) != null && mapOwnerIdwithAccountIdwithRoles.get(objLead.OwnerId).get(objLead.Account__c) != null) {    
                strCurrentOwnerRole = mapOwnerIdwithAccountIdwithRoles.get(objLead.OwnerId).get(objLead.Account__c);   
                
                if(mapAccIdwithRolewithUserId.get(objLead.Account__c) != null && mapAccIdwithRolewithUserId.get(objLead.Account__c).get(strCampaignFollowupRole) != null) {
                    bExistPrimayRoleInAcc = true;
                }
                
                if(mapAccIdwithRolewithUserId.get(objLead.Account__c) != null && mapAccIdwithRolewithUserId.get(objLead.Account__c).get(strCampaignSecondaryRole) != null) {
                    bExistSecondaryRoleInAcc = true;
                }
                bRecalculateOwner = IsToRecalOwnerWithOwnerInATM(strCurrentOwnerRole, strCampaignFollowupRole, strCampaignSecondaryRole, bExistPrimayRoleInAcc, bExistSecondaryRoleInAcc, bLeadOwnerIsAccountOwner);   
            }
            else {
                bRecalculateOwner = true;      
            }
            //process each lead 
            if (bRecalculateOwner) {
                if(mapAccIdLeads.get(objLead.Account__c) == null) {
                    mapAccIdLeads.put(objLead.Account__c, new list<Lead> {objLead});
                }
                else {
                    mapAccIdLeads.get(objLead.Account__c).add(objLead);
                }  
            }  
            //4.0
        }
        if(mapAccIdLeads.size() > 0) {
            list<Lead> lstLeadsToPopulateOwner = new list<Lead>();            
            for(Id accountId : mapAccIdLeads.keyset()) {               
                if(mapAccIdLeads.get(accountId) != null) {
                    lstLeadsToPopulateOwner.addAll(mapAccIdLeads.get(accountId));
                }
            }
            
            // To hold old lead records before processing owner calculation
            list<Lead> lstOldLeads = lstLeadsToPopulateOwner.deepclone(true, true, false); 
            
            //3.0
            LeadAssignment.setForcePopulateFields(true);
            LeadAssignment.assignDirectLeads2(lstLeadsToPopulateOwner);
            LeadFieldPopulator.populateLeadOwnerDetails(lstLeadsToPopulateOwner, new map<Id, Lead>(lstOldLeads));
            LeadFieldPopulator.populateSalesAssignedDate(lstLeadsToPopulateOwner, new map<Id, Lead>(lstOldLeads)); //5.0
            LeadFieldPopulator.populateLastOwnerReassignmentDate(lstLeadsToPopulateOwner, new map<Id, Lead>(lstOldLeads));
            
            TriggerExecutionController.setSkipAllTriggers(true);
            Database.update(lstLeadsToPopulateOwner, false);
            TriggerExecutionController.setSkipAllTriggers(false);
        }   
    }
    //4.0 Code chnages for 'LM2_Enhancement for reassignment logic to stick to campaign follow up role'
    // logic to return if we should recalculate the owner
    private boolean IsToRecalOwnerWithOwnerInATM(string strCurOwnerRole, string strCampFollowupRole, string strCampSecondaryRole, boolean bHasPrimayRoleInAcc, boolean bHasSecondaryRoleInAcc, boolean bLeadOwnerIsAccOwner) {
        // if lead owner not with follow up role and there are primary role member in Account team
        if(bHasPrimayRoleInAcc && strCurOwnerRole != strCampFollowupRole) {
            return true;
        }
        // if lead owner not with follow up role and not with secondary role and there are secondary role in account
        if(bHasSecondaryRoleInAcc && strCurOwnerRole != strCampFollowupRole && strCurOwnerRole != strCampSecondaryRole) {
            return true;
        }
        // if lead owner is not account owner and primary role is Account Owner
        if (!bLeadOwnerIsAccOwner && strCampFollowupRole == 'Account Owner') {
            return true;
        }
        // if lead owner is not account owner and secondary owenr is account owner and lead owner is not with primary role
        if (!bLeadOwnerIsAccOwner && strCampSecondaryRole == 'Account Owner' && strCurOwnerRole != strCampFollowupRole) {
            return true;
        }  
        return false;    
    }
    //4.0
    
    global void finish(Database.BatchableContext BC){      
    }  
}
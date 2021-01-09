/*
 * Author   : 
 * Purpose  : To handle all Route to Segment controller logics.
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0                  15.07       10-Mar-2014     Annie           R2S
 * 2.0                  15.07       19-Jun-2014     Jiji            R2S for Assigned Leads
 * 3.0      9846        16.03       30-Dec-2014     Jiji            R2S for Channel Leads created from Account Play
 * 4.0      12064       16.10       12-Oct-2015     Ragu            Code formatting and optimization - General.
 * 
 */

public without sharing class CMAP_RouteToSegmentController {
    
    public Boolean showFirstBlock {get; set;}
    public Boolean showSecondBlock {get; set;}
    public Boolean showThirdBlock {get; set;}
    public Boolean isError {get; set;}
    public Lead channelLead {get; set;}
    public Relationship_Lead__c relationshipLead {get; set;}
    public Lead channelRecord;
    
    public String chId;
    public String newId;
    String retURL;
    String action;
    String recid;
    Id currentUserId;
    
    list<GroupMember> grpMemList = new list<GroupMember>();

    public CMAP_RouteToSegmentController(ApexPages.StandardController controller) {
        try {
            chId = ApexPages.currentPage().getParameters().get('chId');
            newId = ApexPages.currentPage().getParameters().get('newId');
            retURL = ApexPages.currentPage().getParameters().get('retURL');
            action = ApexPages.currentPage().getParameters().get('action');
            recid = ApexPages.currentPage().getParameters().get('recid');
            currentUserId = UserInfo.getUserId();
            
            if(chId != NULL) {
                // v2.0: Added Allocation_Queue_GUID__c in the below SOQL query
                // v3.0: Added AP_Segment_Lead__c in the below SOQL query
                // v4.0: Removed AP_Segment_Lead__c in the below SOQL query for story #5936181
                channelRecord = [select Id, Name, FirstName, LastName, Title, Phone, MobilePhone, email, Company, Purchase_timeframe__c, Decision_Making_Role__c, AnnualRevenue, Employees__c,
                                    Questions_Comments__c, Sales_Comments__c, Marketing_Comments__c, Allocation_Queue_GUID__c, Salutation, User_Access_OLD__c, City, State, PostalCode, 
                                    Country, Segment_Lead__c, Relationship_Lead__c, Status, Owner.Name, OwnerId, CreatedById, Channel_to_Segment_Criteria__c, Account_Play__c, Campaign__r.Region__c, 
                                    Relationship_Lead__r.Account_Name__c, Relationship_Lead__r.Purchase_Timeframe__c, Relationship_Lead__r.Decision_Making_Role__c, Relationship_Lead__r.Employee__c
                                 from Lead where Id = :chId];
                
                // v3.0: Start
                if(channelRecord.Account_Play__c != null) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Routing Channel Lead back to Segment...'));
                }
                // v3.0: End
                
                // For finding the group members for error display
                String strOwner = channelRecord.OwnerId;
                
                if(strOwner.startsWith('00G') && (channelRecord.Owner.Name == null ? false :channelRecord.Owner.Name.Contains('Allocation') || (channelRecord.Owner.Name == null ? false :channelRecord.Owner.Name.Contains('Nurturing') && channelRecord.Campaign__r.Region__c == 'NA'))) {
                    
                    grpMemList = [select UserOrGroupId From GroupMember where GroupId = :channelRecord.OwnerId and UserOrGroupId = :currentUserId];
                }
                else {
                    // v2.0: Start
                    if(channelRecord.Status == 'Assigned to Channel Partner') {
                        grpMemList = [select UserOrGroupId From GroupMember where GroupId = :channelRecord.Allocation_Queue_GUID__c and UserOrGroupId = :currentUserId];
                    }
                    // v2.0: End
                }
                
                
            }

            if(newId != NULL) {
                if(newId.startsWith('00Q')) {
                    showSecondBlock = true;
                    channelLead = [select Id, Channel_lead__c, Channel_Lead__r.Relationship_Lead__c, Channel_lead__r.Segment_lead__c, Questions_Comments__c, Channel_lead__r.OwnerID,
                                        Channel_lead__r.Owner.Name, Channel_lead__r.Campaign__r.Region__c, Channel_lead__r.User_Access_OLD__c, Sales_Comments__c, Marketing_Comments__c
                                   from Lead where Id = :newId];
                } 
                else {
                    showThirdBlock = true;
                    relationshipLead = [select Id, Questions_Comments__c, Channel_lead__r.User_Access_OLD__c, Channel_lead__c, Account_Name__c, Sales_Comments__c, Marketing_Comments__c
                                        from Relationship_Lead__c where Id = :newId];
                }
            }
        }
        catch(Exception e) {
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.CMAP_Default_Error_Message));
            isError = true;
        }
    }
    
    public PageReference redirect() {
        try {
            // Check for cancel operation
            if(action != null) {
                // Get Channel lead details
                Lead channelLead = [select Id, Name, FirstName, LastName, Title, Account__c, Phone, MobilePhone, email, Company, Purchase_timeframe__c, Decision_Making_Role__c,
                                        AnnualRevenue, Employees__c, Questions_Comments__c, Sales_Comments__c, Marketing_Comments__c, Salutation, User_Access_OLD__c, City, State, PostalCode, Country, 
                                        Segment_Lead__c, Relationship_Lead__c, Status, Owner.Name, OwnerId, CreatedById, Channel_to_Segment_Criteria__c, Account_Play__c, Campaign__r.Region__c, 
                                        Relationship_Lead__r.Account_Name__c, Relationship_Lead__r.Purchase_Timeframe__c, Relationship_Lead__r.Decision_Making_Role__c, Relationship_Lead__r.Employee__c
                                    from Lead where Id = :recid];
                
                if(action == 'segLeadCancel') {
                    // Remove segment Lead share
                    if(channelLead.User_Access_OLD__c == 'No Access' || channelLead.User_Access_OLD__c == 'Read') {
                        list<Leadshare> lstLeadShares = [select Id, UserOrGroupId, LeadAccessLevel, LeadId from LeadShare where LeadId = :channelLead.Segment_Lead__c and UserOrGroupId = :currentUserId];
                        if(channelLead.User_Access_OLD__c == 'No Access') {
                            delete lstLeadShares;
                        }
                        else {
                            if(channelLead.User_Access_OLD__c == 'Read') {
                                lstLeadShares[0].LeadAccessLevel = 'Read';
                                update lstLeadShares;
                            }
                        }
                    }
                }
                else if(action == 'relLeadCancel') {
                    // Remove rel lead share
                    if(channelLead.User_Access_OLD__c == 'No Access' || channelLead.User_Access_OLD__c == 'Read') {
                        list<Accountshare> lstAccountShares = [select Id, UserOrGroupId, RowCause, OpportunityAccessLevel, ContactAccessLevel, AccountId, AccountAccessLevel
                                                               from AccountShare where AccountId = :channelLead.Account__c and UserOrGroupId = :currentUserId];
                        
                        if(channelLead.User_Access_OLD__c == 'No Access') {
                            delete lstAccountShares;
                        } 
                        else if(channelLead.User_Access_OLD__c == 'Read') {
                            lstAccountShares[0].AccountAccessLevel = 'Read';
                            update lstAccountShares;
                        }
                    }
                }
                channelLead.User_Access_OLD__c = null;
                update channelLead;
                
                return new PageReference('/' + recid);
            }
            
            if(chId != NULL &&
                //Ver 2.0: Start
                ((String.valueOf(channelRecord.OwnerId).startsWith('00G') && (channelRecord.Owner.Name == null ? false :channelRecord.Owner.Name.Contains('Allocation') || (channelRecord.Owner.Name == null ? false : channelRecord.Owner.Name.Contains('Nurturing') && channelRecord.Campaign__r.Region__c == 'NA'))) || channelRecord.Status == 'Assigned to Channel Partner')
                //Ver 2.0: End
            ) {
                if(grpMemList.size() == 0) {
                    PageUtils.AddError('This button is intended for Regional Allocation Queue Members. Please contact your Channel Marketing manager for assistance. Thank you');
                    showFirstBlock = true;
                    showSecondBlock = false;
                    isError = true;
                }
                else {
                    showFirstBlock = false;
                    if(channelRecord.Account_Play__c == NULL) {
                        showSecondBlock = true;
                    }

                    String Status = pageUtils.encodeVariable('Open');
                    if(chId != NULL) {
                        if(channelRecord.Segment_Lead__c != null) {
                            list<LeadShare> leadsharetoUpdateList = new list<LeadShare>();
                            list<Leadshare> ldShareList = [select Id, UserOrGroupId, RowCause, LeadId, LeadAccessLevel from LeadShare where LeadId = :channelRecord.Segment_Lead__c and UserOrGroupId = :currentUserId];
                            if(ldShareList.Size() == 0) {
                                LeadShare segLeadShareRec = new LeadShare(LeadId = channelRecord.Segment_Lead__c, UserOrGroupId = currentUserId, LeadAccessLevel = 'Edit');
                                channelRecord.User_Access_OLD__c = 'No Access';
                                leadsharetoUpdateList.add(segLeadShareRec);
                            } 
                            else {
                                for(leadShare ldShare: ldShareList) {
                                    if(ldShare.LeadAccessLevel == 'Read') {
                                        channelRecord.User_Access_OLD__c = 'Read';
                                        LeadShare segLeadShareRec = new Leadshare(Id = ldShare.Id, LeadAccessLevel = 'Edit');
                                        leadsharetoUpdateList.add(segLeadShareRec);
                                    } 
                                    else {
                                        if(ldShare.LeadAccessLevel == 'Edit') {
                                            channelRecord.User_Access_OLD__c = 'Edit';
                                        }
                                    }
                                }
                            }
                            try {
                                if(leadsharetoUpdateList.Size() > 0) {
                                    upsert leadsharetoUpdateList;
                                    update channelRecord;
                                }
                            }
                            catch(Exception ex) {
                                ApexPages.addmessages(ex);
                                isError = true;
                            }
                            
                            String saveURLString = '/apex/CMAP_RouteToSegment?retURL=' + channelRecord.Id;
                            String cancelURLString = pageUtils.encodeVariable('/apex/CMAP_RouteToSegment?action=segLeadCancel&recid=' + channelRecord.Id);
                            String URL = '/' + channelRecord.Segment_Lead__c + '/e?lea13=' + Status + '&retURL=' + channelRecord.Id + '&saveURL=' + saveURLString + '&cancelURL=' + cancelURLString 
                                        + '&CF00NJ00000010XKc_lkid=' + channelRecord.Id + '&CF00NJ00000010XKc=' + channelRecord.Name
                                        + (channelRecord.FirstName != NULL ? '&name_firstlea2=' + pageUtils.encodeVariable(channelRecord.FirstName) : '') 
                                        + (channelRecord.LastName != NULL ? '&name_lastlea2=' + pageUtils.encodeVariable(channelRecord.LastName) : '') 
                                        + (channelRecord.Title != NULL ? '&lea4=' + pageUtils.encodeVariable(channelRecord.Title) : '') 
                                        + (channelRecord.Email != NULL ? '&lea11=' + pageUtils.encodeVariable(channelRecord.Email) : '') 
                                        + (channelRecord.Phone != NULL ? '&lea8=' + pageUtils.encodeVariable(channelRecord.Phone) : '') 
                                        + (channelRecord.Purchase_Timeframe__c != NULL ? '&00N70000002MSnl=' + pageUtils.encodeVariable(channelRecord.Purchase_Timeframe__c) : '') 
                                        + (channelRecord.Decision_Making_Role__c != NULL ? '&00N70000002MSo0=' + pageUtils.encodeVariable(channelRecord.Decision_Making_Role__c) : '') 
                                        + (channelRecord.AnnualRevenue != NULL ? '&lea7=' + channelRecord.AnnualRevenue : '')
                                        + (channelRecord.Employees__c != NULL ? '&00N70000002MSoA=' + pageUtils.encodeVariable(channelRecord.Employees__c) : '') 
                                        + (channelRecord.Salutation != NULL ? '&name_salutationlea2=' + pageUtils.encodeVariable(channelRecord.Salutation) : '') 
                                        + (channelRecord.MobilePhone != NULL ? '&lea9=' + pageUtils.encodeVariable(channelRecord.MobilePhone) : '') 
                                        + (channelRecord.Company != NULL ? '&lea3=' + pageUtils.encodeVariable(channelRecord.Company) : '') 
                                        + (channelRecord.PostalCode != NULL ? '&lea16zip=' + pageUtils.encodeVariable(channelRecord.PostalCode) : '') 
                                        + (channelRecord.City != NULL ? '&lea16city=' + pageUtils.encodeVariable(channelRecord.City) : '') 
                                        + (channelRecord.State != NULL ? '&lea16state=' + pageUtils.encodeVariable(channelRecord.State) : '') 
                                        + (channelRecord.Country != NULL ? '&lea16country=' + pageUtils.encodeVariable(channelRecord.Country) : '');
                            PageUtils.addError('New Id: ' + newId);
                            PageReference page = new PageReference(URL);
                            page.setRedirect(true);
                            return page;
                        } 
                        else if(channelRecord.Relationship_Lead__c != NULL) {
                            // Get the user's access on Account
                            list<AccountShare> lstAccountShares = [select Id, UserOrGroupId, RowCause, OpportunityAccessLevel, ContactAccessLevel, AccountId, AccountAccessLevel
                                                                   from AccountShare where AccountId = : channelRecord.Relationship_Lead__r.Account_Name__c AND UserOrGroupId = : currentUserId];
                            
                            AccountShare newAccShare;
                            // If no access create new share
                            if(lstAccountShares.size() == 0) {
                                channelRecord.User_Access_OLD__c = 'No Access';
                                newAccShare = new AccountShare(AccountId = channelRecord.Relationship_Lead__r.Account_Name__c, UserOrGroupId = currentUserId, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read');
                            }
                            // If read access update it as edit
                            else if(lstAccountShares.size() == 1 && lstAccountShares[0].AccountAccessLevel == 'Read') {
                                newAccShare = new AccountShare(Id = lstAccountShares[0].Id, AccountAccessLevel = 'Edit');
                                channelRecord.User_Access_OLD__c = 'Read';
                            } 
                            else if(lstAccountShares.size() == 1 && lstAccountShares[0].AccountAccessLevel == 'Edit') {
                                channelRecord.User_Access_OLD__c = 'Edit';
                            }

                            if(newAccShare != null) {
                                upsert newAccShare;
                                update channelRecord;
                            }

                            Status = pageUtils.encodeVariable('Requires Follow-Up');
                            String saveURLString = '/apex/CMAP_RouteToSegment?retURL=' + channelRecord.Id;
                            String cancelURLString = pageUtils.encodeVariable('/apex/CMAP_RouteToSegment?action=relLeadCancel&recid=' + channelRecord.Id);
                            String URL = '/' + channelRecord.Relationship_Lead__c + '/e?nooverride=1&00NA0000000b8af=' + Status + '&retURL=' + channelRecord.Id + '&saveURL=' + saveURLString + '&cancelURL=' + cancelURLString 
                                        + (channelRecord.Purchase_Timeframe__c != NULL ? '&00NA0000000b8aX=' + pageUtils.encodeVariable(channelRecord.Purchase_Timeframe__c) : '') 
                                        + (channelRecord.Decision_Making_Role__c != NULL ? '&00NA0000000b8aE=' + pageUtils.encodeVariable(channelRecord.Decision_Making_Role__c) : '')
                                        + (channelRecord.Employees__c != NULL ? '&00NA0000000b8aI=' + pageUtils.encodeVariable(channelRecord.Employees__c) : '');
                            PageReference page = new PageReference(URL);
                            page.setRedirect(true);
                            return page;
                        }
                        // v3.0: Start
                        /* Commented for story 5936181
                        else if(channelRecord.Account_Play__c != NULL) {
                            if(channelRecord.AP_Segment_Lead__c == NULL) {
                                // Get custom setting and retrieve fields to be mapped
                                Lead segLead = new Lead();
                                list<CMAP_AP_R2S_Fieldmapping__c> apfieldList = CMAP_AP_R2S_Fieldmapping__c.getall().values();
                                // Retrieve values from channel Lead based up on customsetting
                                String soql = 'select ';
                                for(CMAP_AP_R2S_Fieldmapping__c fieldmap: apfieldList) {
                                    soql += fieldmap.name + ',';
                                }
                                if(soql.endsWith(',')) {
                                    soql = soql.subString(0, soql.lastIndexOf(','));
                                }
                                String ldid = channelRecord.Id;
                                System.debug('ldid:' + ldid);
                                soql += ' FROM Lead WHERE Id=\'' + channelRecord.Id + '\'';

                                System.debug('SOQL :' + soql);
                                Lead chanelLead = (Lead) Database.query(soql);

                                // Assign channel Lead values to Segment Lead
                                for(CMAP_AP_R2S_Fieldmapping__c fieldmap: apfieldList) {
                                    segLead.put(fieldmap.name, chanelLead.get(fieldmap.name));
                                }
                                System.debug('SegmentLead:' + segLead);
                                String campid = System.Label.CMAP_AP_R2S_CampaignId;
                                // Query and retrieve Campaign
                                list<Campaign> camList = [select Id from Campaign WHERE Id = :campid];
                                if(camList.size()> 0) {
                                    segLead.Campaign__c = camList[0].Id;
                                } 
                                else if(UserInfo.getOrganizationId() != '00D300000006urqEAA') {
                                    camList = [select Id from Campaign WHERE RecordTypeid = '0127000000055pe' AND isActive = true AND Is_this_Account_Play_Campaign__c = false limit 1];
                                    segLead.Campaign__c = camList[0].Id;
                                }

                                segLead.recordtypeid = '012A0000000Vhxi';
                                segLead.Status = 'Open';
                                // select a campaign and assign its Id
                                //segLead.Campaign__c = camList[0].Id;
                                segLead.ownerid = '00GA0000001IWEI';
                                segLead.Channel_to_Segment_Criteria__c = null;
                                segLead.Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)';
                                segLead.Consent_to_engage_Dell_Channel_Partner__c = false;
                                // Add the related contact mapping here for defect 141262 
                                segLead.contact__c = chanelLead.Related_contact__c;
                                segLead.Related_contact__c = null;
                                System.debug('SegmentLead1:' + segLead);
                                Database.SaveResult srList = Database.insert(segLead, false);
                                
                                //PageUtils.addInfo('The Channel Lead originated from Account Play has completed the Route to Segment process.');
                                if(srList.isSuccess()) {
                                    String msg = 'The Channel Lead originated from Account Play has completed the Route to Segment process.';
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, msg));
                                } 
                                else {
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.CMAP_Default_Error_Message));
                                }

                                // Update channel Lead
                                channelRecord.Status = 'Routed to Segment';
                                channelRecord.AP_Segment_Lead__c = segLead.Id;
                                update channelRecord;
                                
                                // Update Account Play
                                Account_Play__c ap = new Account_Play__c(Id = channelRecord.Account_Play__c);
                                ap.Accept_Reject_Status__c = 'Routed to Segment';
                                ap.Status__c = 'Routed to Segment';
                                ap.Account_Play_Close_Date__c = System.now();
                                update ap;
                                
                                showFirstBlock = true;
                                showSecondBlock = false;
                                showThirdBlock = false;
                                return null;
                            }
                            else {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Lead is already routed to segment'));
                            }
                        }*/
                        // v3.0: End
                    }
                }
            }
        }
        catch(Exception ex) {
            system.debug('------ex---------'+ex);
            system.debug('------ex---------'+ex.getLineNumber());
            isError = true;
            ApexPages.addMessages(ex);
        }
        return null;
    }

    // Method to add permissionset
    public PageReference addPermissionset() {
        list<PermissionSet> permSet = [select Id from PermissionSet where Name = 'Channel_R2S_Access'];
        if((permSet != null) && (permSet.size()> 0)) {
            Id permSetId = permSet[0].Id;
            list<PermissionSetAssignment> assignments = [select Id, AssigneeId from PermissionSetAssignment where PermissionSetId = :permSetId and AssigneeId = :currentUserId];
            if(assignments.size() == 0) {
                assignments = new list<PermissionSetAssignment>();
                PermissionSetAssignment assi = new PermissionSetAssignment(AssigneeId = currentUserId, PermissionSetId = permSetId);
                assignments.add(assi);
                insert assignments;
            }
        }
        return null;
    }
    
    // Method to remove permissionset - not used since added batch for removal
    /*
    public PageReference removePermissionset(){
        list<PermissionSet> permSet = [select Id FROM PermissionSet WHERE Name = 'Channel_R2S_Access'];
        if((permSet != null) && (permSet.size()> 0)){              
            Id permSetId = permSet[0].Id;                   
            list<PermissionSetAssignment> assignments = [select Id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permSetId AND AssigneeId=:userid];
            if(assignments.size()>0){
                delete assignments;
            }
        }
        String URL= '/'+newId;        
        PageReference page = new PageReference(URL);
        page.setRedirect(true);
        return page;
    }
    */

    public PageReference okButton() {
        return (PageUtils.redirect('/' + chId));
    }
    
    public PageReference saveButton() {
        try {
            if(channelLead != null) {
                update channelLead;
                if(channelLead.Channel_lead__r.User_Access_OLD__c == 'No Access' || channelLead.Channel_lead__r.User_Access_OLD__c == 'Read') {
                    list<Leadshare> lstLeadShares = [select Id, UserOrGroupId, LeadAccessLevel, LeadId from LeadShare where LeadId = :channelLead.Id and UserOrGroupId = :currentUserId];
                    if(channelLead.Channel_lead__r.User_Access_OLD__c == 'No Access') {
                        delete lstLeadShares;
                    } 
                    else {
                        if(channelLead.Channel_lead__r.User_Access_OLD__c == 'Read') {
                            lstLeadShares[0].LeadAccessLevel = 'Read';
                            update lstLeadShares;
                        }
                    }
                }
                channelRecord = new Lead(Id = channelLead.Channel_lead__c);
            } 
            else if(relationshipLead != NULL) {
                update relationshipLead;
                if(relationshipLead.Channel_lead__r.User_Access_OLD__c == 'No Access' || relationshipLead.Channel_lead__r.User_Access_OLD__c == 'Read') {
                    list<AccountShare> lstAccountShares = [select Id, UserOrGroupId, RowCause, OpportunityAccessLevel, ContactAccessLevel, AccountId, AccountAccessLevel
                                                           from AccountShare where AccountId = :relationshipLead.Account_Name__c and UserOrGroupId = :currentUserId];
                    if(relationshipLead.Channel_lead__r.User_Access_OLD__c == 'No Access') {
                        delete lstAccountShares;
                    } 
                    else if(relationshipLead.Channel_lead__r.User_Access_OLD__c == 'Read') {
                        lstAccountShares[0].AccountAccessLevel = 'Read';
                        update lstAccountShares;
                    }
                }
                channelRecord = new Lead(Id = relationshipLead.Channel_lead__c);
            }

            // Remove old value from channel lead - common for segment lead and RL
            if(channelRecord.User_Access_OLD__c != null) {
                channelRecord.User_Access_OLD__c = null;
                update channelRecord;
            }

            String URL = '/' + channelRecord.Id;
            PageReference page = new PageReference(URL);
            page.setRedirect(true);
            return page;
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.CMAP_Default_Error_Message));
            isError = true;
            return null;
        }
    }
}
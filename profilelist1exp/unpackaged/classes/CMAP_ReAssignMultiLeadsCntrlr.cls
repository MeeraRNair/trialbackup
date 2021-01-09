/* 
REVISION HISTORY
================
 * Author   : Anwar
 * Purpose  : Mass lead reassign feature for all web pages of leads in Partner Direct.
 *        
 * Revision CR Number   Release No  Date            Created By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 12110    16.12       02-Dec-2015     Anwar           Mass lead reassign feature for all web pages of leads in Partner Direct.                                                                 Note:we are cloning the code from CMAP_ManualAssignmentCntrlr(Apex class) for Massupdate
 * 2.0                              18-June-2018    Rahul           Code Reduce
 * 3.0      CR 17117    FY20-0402   28-Mar-2019     Shue            Story 6098726: Channel: [PAM-Technical] Reassign Lead
*/
public class CMAP_ReAssignMultiLeadsCntrlr{
     public List<Lead> leadObj{get;set;}
     public List<Lead> listleadrec{get;set;}
     public Integer totalPages{get;set;}
     List<UserWrapper> partnerUserToRole {get;set;}
     Public Boolean isPartner{get;set;}
     Integer pageSize = 10;
     public Lead leadObjForUser{get;set;}
     public Boolean partnerAccountExist{get;set;}
     Map<Id,User>userMap = new Map<Id,User>();
     public String action ='';
     public String userStr;
     public String selUserId;
     public boolean valCheck {get; set;}
     public String partnerUsr;  
     String strOwner;
     List<GroupMember> grpMemList = new List<GroupMember>();
     List<GroupMember> grpMemEClerxList = new List<GroupMember>();
     List<GroupMember> grpMemReassignList = new List<GroupMember>();
     public boolean showPage {get;set;}
     public boolean showOkPage {get;set;}
     public String profileName;
     //StandardSetController from query locator 
    public ApexPages.StandardSetController con {
                   
        get {
                  
            if(con == null) {
                try{
                
                                   
                if(leadObj[0].Partner_Account__c != NULL ){
                    
                    Account rec = new Account();
                    rec=[select id,name,Partner_Track__c,Master_Group_Id__c from account where id=:leadObj[0].Partner_Account__c];
                    
                    //3.0 Start
                    list<ID> listSMAUserIds=new list<ID>();
                    listSMAUserIds= PamCMAPutilityClass.getUserssUnderSalesMotion(rec);
                    
                    con = new ApexPages.StandardSetController(Database.getQueryLocator([select Name,Id,AccountId,Enable_Partner_Admin__c,Enable_As_Partner_Lead_Super_User__c,LanguageLocaleKey
                                         from User 
                                         where isactive = true and //AccountId=:leadObj[0].Partner_Account__c 
                                         id in : listSMAUserIds 
                                         and Id !=: leadObj[0].OwnerId
                                         and Enable_Partner_Lead_Management__c = true
                                         Order by Name
                                         LIMIT 500]));
                    //3.0 End
                    
                    /* Commented for 3.0
                    con = new ApexPages.StandardSetController(Database.getQueryLocator([select Name,Id,AccountId,Enable_Partner_Admin__c,Enable_As_Partner_Lead_Super_User__c,LanguageLocaleKey
                                         from User 
                                         where isactive = true and AccountId=:leadObj[0].Partner_Account__c and Id !=: leadObj[0].OwnerId
                                         and Enable_Partner_Lead_Management__c = true
                                         Order by Name
                                         LIMIT 500]));
                    */
                }
                // sets the number of records in each page set
                con.setPageSize(pageSize);
                }
                Catch(Exception e){
                    if(isPartner){// This message visible to Partner
                        PageUtils.AddError(System.Label.CMAP_Default_Error_Message);
                    }
                }
            }
            return con;
        }
        set;
     }
     public CMAP_ReAssignMultiLeadsCntrlr(ApexPages.StandardController controller){
         isPartner = false;
         partnerAccountExist = true;
         valCheck = false;
         try{
            // list<Lead> leadObj = new list<Lead>(); 
            list<string> leadId = new list<string>(); 
            String LeadRecords = ApexPages.currentPage().getParameters().get('leadRecorIds');
            String[] idArray = LeadRecords.split(',');
            for(String leadId1:idArray)
            {
                    leadId.add(leadId1);
            }   
             
             leadObj = [Select Id, name,Partner_Account__c,Partner_Account__r.OwnerId,Partner_Account__r.Name,Owner_Language_Code__c,
                     Partner_User__c,Partner_Admin__c,Partner_Account_Owner_ApiOnly__c, Accept_Reject_Reassign_Status__c,
                     Partner_Lead_Status__c, Allocation_Queue_GUID__c, Account_Play__c,  
                     Owner.Name, OwnerId,Owner.Type,Status  
                     from Lead where Id IN :leadId];
             User usr = [Select Id,Name,LanguageLocaleKey, ContactId,AccountId,IsPortalEnabled from User where id =: UserInfo.getUserId()];
             leadObjForUser = new Lead();
             
             for(Lead leadObj1 : leadObj){
             action = ApexPages.currentPage().getParameters().get('action');
             if(action == null || action != 'AssignLead'){
                 action = 'Reassign';
             }
             
             if(action == 'AssignLead' && leadObj1.Owner.Type == 'Queue'){
               leadObj1.Allocation_Queue_GUID__c = leadObj1.OwnerId;
             }
             if(usr.IsPortalEnabled == true){
                 isPartner = true;
             }
             if(leadObj1.Partner_Account__c == null){
                 partnerAccountExist = False;
                 PageUtils.AddError('Please assign a Partner Account for the Lead');
             }
             if(leadObj1.Partner_Account__c != null && leadObj1.Partner_User__c != null){
              valCheck = true;
              partnerUsr = leadObj1.Partner_User__c;
             } 
             }
            }Catch(Exception e){
             if(isPartner){ // This message visible to Partner
                 PageUtils.AddError(System.Label.CMAP_Default_Error_Message);
             }
             else{
                 PageUtils.AddError('Lead ID is incorrect');
             }
         }
     }
     
     public pagereference redirect(){
        try{
            action = ApexPages.currentPage().getParameters().get('action');
            if(action == null || action != 'AssignLead'){
                 action = 'Reassign';
            }
          
            list<string> leadId = new list<string>(); 
            String LeadRecords = ApexPages.currentPage().getParameters().get('leadRecorIds');
            String[] idArray = LeadRecords.split(',');
            for(String leadId1:idArray)
            {
                    leadId.add(leadId1);
            }   
           
             listleadrec = [Select Name, Account_Play__c
                            , Partner_Account__c,Allocation_Queue_GUID__c,Segment_Lead__c,
                            Relationship_Lead__c, Owner.Name,Owner.Type,ownerId,CreatedById 
                            from Lead where Id =:leadId];
                            
           User usr = [Select Id,Name,Profile_Name__c, LanguageLocaleKey, ContactId,AccountId,IsPortalEnabled,Enable_As_Partner_Lead_Super_User__c from User where id =: UserInfo.getUserId()];
           Set<Id> groupIdSet = new Set<Id>();
            Map<Id, GroupMember> GroupToGroupMemberMap = new MAp<Id, GroupMember> ();
            
            if(groupIdSet.Size() > 0){
                    for(GroupMember gpMem :[Select GroupId, UserOrGroupId From GroupMember where GroupId =:groupIdSet and UserOrGroupId =:usr.Id]){
                        GroupToGroupMemberMap.put(gpMem.GroupId, gpMem);
                    }
                }
           for(Lead leadrec : listleadrec){                
                strOwner = leadrec.ownerId;
                
              
                profileName = usr.Profile_name__c;
                CMAP_Queue_Settings__c eClerxQueueId = CMAP_Queue_Settings__c.getValues('Channel_eClerx');
                            
                
                
                if(strOwner.startsWith('00G')){
                    groupIdSet.add(leadrec.OwnerId);
                }
                if(leadrec.Relationship_lead__c == NULL && leadrec.Segment_Lead__c == NULL
                    && leadrec.Account_Play__c == null 
                ){
                    groupIdSet.add(eClerxQueueId.Queue_Id__c);
                }
                if(leadrec.Allocation_Queue_GUID__c!=null){
                    groupIdSet.add(leadrec.Allocation_Queue_GUID__c);
                }
           
           if((action == 'AssignLead' && usr.IsPortalEnabled == false &&
                    ((strOwner.startsWith('00G') && GroupToGroupMemberMap.get(leadrec.OwnerId) != NULL) ||
                     profileName.contains('Channel Marketing') ||
                     profileName.contains('Marketing Operations Admin') ||
                    (leadrec.Segment_Lead__c == null && leadrec.Relationship_Lead__c == null  
                     && leadrec.Account_Play__c == null 
                     && GroupToGroupMemberMap.get(eClerxQueueId.Queue_Id__c) != NULL)
                   ))|| 
                   (action == 'Reassign' &&
                   (usr.IsPortalEnabled == true || usr.Enable_As_Partner_Lead_Super_User__c == true
                   || profileName.contains('Channel Marketing')
                   || profileName.contains('Marketing Operations Admin')
                   ||
                   ( leadrec.Allocation_Queue_GUID__c !=null && GroupToGroupMemberMap.get(leadrec.Allocation_Queue_GUID__c) != NULL)
                   ||
                   (leadrec.Segment_Lead__c == null && leadrec.Relationship_Lead__c == null 
                   && leadrec.Account_Play__c == null 
                   && GroupToGroupMemberMap.get(eClerxQueueId.Queue_Id__c) != NULL)
                   )
                   
                   )){   
                    showPage = true;
                    showOkPage = false;
                }
           
                            
                else{
                 PageUtils.AddError(System.Label.CMAP_Error_for_AssignLead);
                 showPage = false;
                 showOkPage = true;
             }
            }
        }
        catch(Exception ex){
            ApexPages.addmessages(ex);
        }
        return NULL;
    }
    
    // returns list of wrapper 
    public List<UserWrapper> getpartnerUserToRole() {
        partnerUserToRole = new List<UserWrapper>();
        List<UserWrapper> partnerUserToRole1 = new List<UserWrapper>();
        UserWrapper userToRoleObj ;
       
        try{
          if(con.getPageNumber() == 1 && partnerUsr != null){
            User u = [Select Id,Name, Enable_Partner_Admin__c, LanguageLocaleKey,
                      Enable_As_Partner_Lead_Super_User__c  from User where id =: partnerUsr 
                      and Enable_Partner_Lead_Management__c = true limit 1];
            UserWrapper uw = new UserWrapper();
            uw.Id = partnerUsr;
            uw.userName = u.Name;
            if(u.Enable_Partner_Admin__c == true && u.Enable_As_Partner_Lead_Super_User__c == true){
                  uw.Role = System.Label.CMAP_Admin_Lead_Super_User;
              }
              else if(u.Enable_Partner_Admin__c == true){
                  uw.Role = System.Label.CMAP_Admin;
              }
              else if(u.Enable_As_Partner_Lead_Super_User__c == true){
                  uw.Role = System.Label.CMAP_Lead_Super_User;
              }
              else{
                  uw.Role = System.Label.CMAP_User;
              }
            if(valCheck && (uw.Id == partnerUsr)){
              uw.isChecked = true;
            }
            partnerUserToRole.add(uw);
            userMap.put(u.id,u);
          }
        }Catch(Exception e){
          PageUtils.AddError('Exception:' + e);
        }
       
        for (User u: (List<User>)con.getRecords()){
            userMap.put(u.Id,u);
            if(u.Id != partnerUsr){
              userToRoleObj = new UserWrapper();
              userToRoleObj.userName = u.Name;
              userToRoleObj.Id = u.Id;
              if(u.Enable_Partner_Admin__c == true && u.Enable_As_Partner_Lead_Super_User__c == true){
                  userToRoleObj.Role = System.Label.CMAP_Admin_Lead_Super_User;
              }
              else if(u.Enable_Partner_Admin__c == true){
                  userToRoleObj.Role = System.Label.CMAP_Admin;
              }
              else if(u.Enable_As_Partner_Lead_Super_User__c == true){
                  userToRoleObj.Role = System.Label.CMAP_Lead_Super_User;
              }
              else{
                  userToRoleObj.Role = System.Label.CMAP_User;
              }
              partnerUserToRole.add(userToRoleObj);
            }
        }
        if(math.mod(con.getResultSize(), pageSize) > 0) {
            totalPages  =(con.getResultSize()/pageSize) + 1;
        }else{
            totalPages  = (con.getResultSize()/pageSize);
        }
        if(totalPages ==0){
            totalPages =1;
        }
        return partnerUserToRole;
    }

    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
 
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
 
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
 
    // returns the next page of records
    public void next() {
        con.next();
    }
 
    // returns the PageReference of the original page, if known, or the home page.
    public Pagereference cancel() {
        return(PageUtils.redirect('/00Q'));
    }
    
    //Wrapper
    public class UserWrapper {
        public String userName{get;set;}
            public String Role{get;set;}
            public String Id{get;set;}
         
         public boolean isChecked{get; set;}
       
     
        public UserWrapper(){
            this.userName ='';
            this.Role = '';
            this.Id ='';
          isChecked = false;
         
        }
     }
     //Update Lead record
    public PageReference selectedUser(){
        String newOwnerLangStr = 'en_US';
         try{
            selUserId = ApexPages.currentPage().getParameters().get('radioName');
            Boolean partnerUserFlag = false;
            if(selUserId != null){
               
                if(selUserId == 'other'){// Any other User option which is visible only to internal users
                    if(leadObjForUser.OwnerId == null ){//If radiobutton checked and dint select a user in lookup
                        PageUtils.AddError('Please select a Partner User or Queue');
                        return null;
                    }
                    else{
                        userStr = leadObjForUser.OwnerId;
                        if (userStr.startsWith('005') == true){//Checking whether the selected owner is a user or queue
                            User u = [Select id, Name,UserType,AccountId,LanguageLocaleKey,Enable_Partner_Lead_Management__c from User where id =: leadObjForUser.OwnerId];//ss
                            if(u.UserType == 'PowerPartner'){//If a Partner, then proceed with existing functionality
                               selUserId =  leadObjForUser.OwnerId;
                               newOwnerLangStr = u.LanguageLocaleKey;
                               for(Lead l12:leadObj){
                               l12.Partner_Account__c = u.AccountId;
                               }
                               partnerUserFlag = true;
                              
                              
                            }
                            else{
                                PageUtils.AddError('Assigned user should be a Partner User or Queue.');
                                return null;
                            }
                           
                            if(u.Enable_Partner_Lead_Management__c != true){
                              PageUtils.AddError('This Partner user does not have Lead Management access. To proceed, please choose a partner user who is enabled for lead management access.');
                                return null;
                            }
                          
                        }
                    }                 
                }
                if(selUserId != 'other' && userMap.containsKey(selUserId)){
                    newOwnerLangStr = userMap.get(selUserId).LanguageLocaleKey;
                    partnerUserFlag = true;
                }   
                
                
                for(Lead L1:leadObj){
                    if(partnerUserFlag == true){  //If a partner proceed with existing functionality
                            L1.OwnerId = selUserId ;
                            L1.Partner_User__c = selUserId;
                            L1.Owner_Language_Code__c = newOwnerLangStr;
                            L1.Status='Assigned to Channel Partner';
                            L1.RecordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);                
                            if(action == 'Reassign'|| 
                               (L1.Accept_Reject_Reassign_Status__c == 'Rejected by Channel' &&
                                L1.Partner_Lead_Status__c  == 'Rejected'
                               )){
            
                                L1.Accept_Reject_Reassign_Status__c='Reassigned by Channel';
                                L1.Partner_Lead_Status__c  = 'Reassigned';
                            }
                           
                            if(L1.Accept_Reject_Reassign_Status__c != 'Reassigned by Channel' && 
                               L1.Accept_Reject_Reassign_Status__c != 'Rejected by Channel'){
                                L1.Partner_Lead_Status__c  = 'New';
                            }
                            
                        
                    }
                    else{//If new owner is queue and status is not Assigned to Channel Partner, just change the owner only.No other fields need to be updated.
                        
                        if(L1.Status != 'Assigned to Channel Partner' && L1.Status != 'Accepted by Channel Partner'){
                            L1.OwnerId = leadObjForUser.OwnerId;
                           
                        }
                        else{
                            
                            PageUtils.addError('Lead is assigned to a Partner.Cannot be reassigned to queue');
                            return null;
                        }
                    }
                
                }
            
                update leadObj;
               
            }
            else{
                if(isPartner){
                    PageUtils.AddError(System.Label.CMAP_select_a_Partner_User);
                }
                else{
                    PageUtils.AddError('Please select a Partner User or Queue');
                }
                return null;
            }
            
            return (PageUtils.Redirect('/00Q/o'));
        }Catch(Exception e){
            if(isPartner){ // This message visible to Partner
                PageUtils.AddError(System.label.CMAP_Default_Error_Message);
            }
            else{
                PageUtils.AddError('Lead Id is incorrect.');
            }
        }
        return null;
     }
 }
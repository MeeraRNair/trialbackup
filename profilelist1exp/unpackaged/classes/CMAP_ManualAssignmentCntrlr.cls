/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#            Description
-------     ------      ----            --------    ---            -----------
1.0         Sandhya     12-Nov-2012     14.2        --             Controller for Manual assignment of Lead.
2.0         Sandhya     16-Aug-2013     14.10       8593
3.0         Jiji        20-Aug-2013     14.10       8456           Enable lead share for all the queue member
4.0         Manju       19-Nov-2013     15.3        8842           Auto-check Partner user if Partner_User__c is populated
5.0         Manju       06-Mar-2014     15.3        CRQ:0925       To show only Partner Users with Lead Management access in the Manual Assignment VF page
6.0         Manju       14-Mar-2014     15.3        CRQ:0930       To update lead assignment page to consider record permission
7.0         Jiji        19-Mar-2014     15.3        Defect:97978   To grand Assign/Reassign permission to Users
8.0         Jiji        01-Apr-2014     15.7        --             eClerx team should not access leads R2C from AP
9.0         Naga        27-Sep-2016     1101        CRQ:13550      A partner user will be able to see more than 500 users to reassign leads
10.0        Shue        02-May-2018     FY19-0602   15686          Story 4144896: Channel: Remove BANT Qualified leads process (Code)
11.0        Rahul       11-May-2018     FY19-0703                  Code Reduce
12.0        Naresh      3-Feb-2019      FY20-0402    17117         Lead Reassign code changes. 
*/
public without sharing class CMAP_ManualAssignmentCntrlr{
     public Lead leadObj{get;set;}
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
     //Ver 4.0 - Start
     public boolean valCheck {get; set;}
     public String partnerUsr;  
     //Ver 4.0 - End  
     //Ver 6.0 - Start   
     String strOwner;
     List<GroupMember> grpMemList = new List<GroupMember>();
     List<GroupMember> grpMemEClerxList = new List<GroupMember>();
     List<GroupMember> grpMemReassignList = new List<GroupMember>();
     public boolean showPage {get;set;}
     public boolean showOkPage {get;set;}
     public String profileName;
     //Ver 6.0 - End 
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                try{
                if(leadObj.Partner_Account__c != NULL ){
                //V 12.0 start
                account rec=new account();
                rec=[select id,name,Partner_Track__c,Master_Group_Id__c from account where id=:leadObj.Partner_Account__c];                
                list<ID> listSMAUserIds=new list<ID>();                               
               System.debug('@@@@@@@@@@@@ rec'+rec);
                listSMAUserIds= PamCMAPutilityClass.getUserssUnderSalesMotion(rec);
                 System.debug('@@@@@@@@@@@@ listSMAUserIds'+listSMAUserIds);
                 System.debug('@@@@@@@@@@@@ listSMAUserIds Size'+listSMAUserIds.size());
                    con = new ApexPages.StandardSetController(Database.getQueryLocator([select Name,Id,AccountId,Enable_Partner_Admin__c,Enable_As_Partner_Lead_Super_User__c,LanguageLocaleKey
                                         from User
                                         //below line updated to fetch user records with same partner track . 
                                         where isactive = true and id in : listSMAUserIds and Id !=: leadObj.OwnerId
                                         //Ver 5.0 - Start 
                                         and Enable_Partner_Lead_Management__c = true
                                         //Ver 5.0 - End 
                                         Order by Name
                                         LIMIT 10000]));
                                         
                }
                system.debug('@@@@@@@@@@ con '+con );
               
                //V 12.0 End
                // sets the number of records in each page set
                con.setPageSize(pageSize);
                }
                Catch(Exception e){
                system.debug('@@@@@@@@ isPartner'+isPartner);
                    if(isPartner){// This message visible to Partner
                        PageUtils.AddError(System.Label.CMAP_Default_Error_Message);
                    }
                }
            }
            return con;
        }
        set;
     }
     public CMAP_ManualAssignmentCntrlr(ApexPages.StandardController controller){
         isPartner = false;
         partnerAccountExist = true;
         //Ver 4.0 - Start
         valCheck = false;
         //Ver 4.0 - End
         try{
             String leadId = ApexPages.currentPage().getParameters().get('Id');
             leadObj = [Select Id, name,Partner_Account__c,Partner_Account__r.OwnerId,Partner_Account__r.Name,Owner_Language_Code__c,
                     Partner_User__c,Partner_Admin__c,Partner_Account_Owner_ApiOnly__c, Accept_Reject_Reassign_Status__c,
                     Partner_Lead_Status__c, Allocation_Queue_GUID__c, Account_Play__c,  
                     Owner.Name, OwnerId,Owner.Type,Status  
                     from Lead where Id =:leadId];
             User usr = [Select Id,Name,LanguageLocaleKey, ContactId,AccountId,IsPortalEnabled from User where id =: UserInfo.getUserId()];
             leadObjForUser = new Lead();
             action = ApexPages.currentPage().getParameters().get('action');
             if(action == null || action != 'AssignLead'){
                 action = 'Reassign';
             }

             if(action == 'AssignLead' && leadObj.Owner.Type == 'Queue'){
             //Ver 7.0: Code End: To Store the GUID of Queue doing assign Lead action
                 leadObj.Allocation_Queue_GUID__c = leadObj.OwnerId;
             }
             
             //ver 3.0: Code End: Save the queue details as back up for creating Lead Share
             if(usr.IsPortalEnabled == true){
                 isPartner = true;
             }
             if(leadObj.Partner_Account__c == null){
                 partnerAccountExist = False;
                 PageUtils.AddError('Please assign a Partner Account for the Lead');
             }
             //Ver 4.0 - Start
             if(leadObj.Partner_Account__c != null && leadObj.Partner_User__c != null){
              valCheck = true;
              partnerUsr = leadObj.Partner_User__c;
             } 
             //Ver 4.0 - End
         }Catch(Exception e){
             if(isPartner){ // This message visible to Partner
                 PageUtils.AddError(System.Label.CMAP_Default_Error_Message);
             }
             else{
                 PageUtils.AddError('Lead ID is incorrect');
             }
         }
     }
     
     //Ver 6.0 - Start
     public pagereference redirect(){
        try{
            action = ApexPages.currentPage().getParameters().get('action');
            if(action == null || action != 'AssignLead'){
                 action = 'Reassign';
            }
            String leadId = ApexPages.currentPage().getParameters().get('Id');
            Lead leadrec = [Select Name, Account_Play__c
                            , Partner_Account__c,Allocation_Queue_GUID__c,Segment_Lead__c,
                            Relationship_Lead__c, Owner.Name,Owner.Type,ownerId,CreatedById 
                            from Lead where Id =:leadId];
            strOwner = leadrec.ownerId;
            User usr = [Select Id,Name,Profile_Name__c, LanguageLocaleKey, ContactId,AccountId,IsPortalEnabled,Enable_As_Partner_Lead_Super_User__c from User where id =: UserInfo.getUserId()];
            //Ver 7.0: Code Start: To Grand access to Channel Marketing profile users
            profileName = usr.Profile_name__c;
            CMAP_Queue_Settings__c eClerxQueueId = CMAP_Queue_Settings__c.getValues('Channel_eClerx');
                        
            Set<Id> groupIdSet = new Set<Id>();
            Map<Id, GroupMember> GroupToGroupMemberMap = new MAp<Id, GroupMember> ();
            if(strOwner.startsWith('00G')){
                groupIdSet.add(leadrec.OwnerId);
            }
            if(leadrec.Relationship_lead__c == NULL && leadrec.Segment_Lead__c == NULL
                && leadrec.Account_Play__c == null //ver 8.0: R2C from AP
            ){
                groupIdSet.add(eClerxQueueId.Queue_Id__c);
            }
            if(leadrec.Allocation_Queue_GUID__c!=null){
                groupIdSet.add(leadrec.Allocation_Queue_GUID__c);
            }
            
            if(groupIdSet.Size() > 0){
                for(GroupMember gpMem :[Select GroupId, UserOrGroupId From GroupMember where GroupId =:groupIdSet and UserOrGroupId =:usr.Id]){
                    GroupToGroupMemberMap.put(gpMem.GroupId, gpMem);
                }
            }
            if((action == 'AssignLead' && usr.IsPortalEnabled == false &&
                ((strOwner.startsWith('00G') && GroupToGroupMemberMap.get(leadrec.OwnerId) != NULL) ||
                 profileName.contains('Channel Marketing') ||// Ver 7.0
                 profileName.contains('Marketing Operations Admin') ||// Ver 7.0
                (leadrec.Segment_Lead__c == null && leadrec.Relationship_Lead__c == null  
                 && leadrec.Account_Play__c == null //ver 8.0: R2C from AP
                 && GroupToGroupMemberMap.get(eClerxQueueId.Queue_Id__c) != NULL)
               ))|| 
               (action == 'Reassign' &&
               (usr.IsPortalEnabled == true || usr.Enable_As_Partner_Lead_Super_User__c == true
               || profileName.contains('Channel Marketing')//Ver 7.0:as per defect 97978, marketing user needs reassign access
               || profileName.contains('Marketing Operations Admin')//Ver 7.0:as per defect 196280, marketing super user needs reassign access
               ||
               ( leadrec.Allocation_Queue_GUID__c !=null && GroupToGroupMemberMap.get(leadrec.Allocation_Queue_GUID__c) != NULL)
               ||
               (leadrec.Segment_Lead__c == null && leadrec.Relationship_Lead__c == null 
               && leadrec.Account_Play__c == null //ver 8.0: R2C from AP
               && GroupToGroupMemberMap.get(eClerxQueueId.Queue_Id__c) != NULL)
               )
               
               )){   
                showPage = true;
                showOkPage = false;
            }else{
                 PageUtils.AddError(System.Label.CMAP_Error_for_AssignLead);
                 showPage = false;
                 showOkPage = true;
            }
        }
        catch(Exception ex){
            ApexPages.addmessages(ex);
        }
        return NULL;
    }
    //Ver 6.0 - End
    
    // returns list of wrapper 
    public List<UserWrapper> getpartnerUserToRole() {
        partnerUserToRole = new List<UserWrapper>();
        List<UserWrapper> partnerUserToRole1 = new List<UserWrapper>();
        UserWrapper userToRoleObj ;
        //Ver 4.0 - Start
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
          PageUtils.AddError('Exception occurred:' + e);
        }
        //Ver 4.0 - End
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
        return(PageUtils.redirect('/'+leadObj.Id));
    }
    
    //Wrapper
    public class UserWrapper {
        public String userName{get;set;}
            public String Role{get;set;}
            public String Id{get;set;}
            //Ver 4.0 - Start
         public boolean isChecked{get; set;}
         //Ver 4.0 - End
     
        public UserWrapper(){
            this.userName ='';
            this.Role = '';
            this.Id ='';
            //Ver 4.0 - Start
           isChecked = false;
        }
     }
     //Update Lead record
    public PageReference selectedUser(){
        String newOwnerLangStr = 'en_US';
         try{
            selUserId = ApexPages.currentPage().getParameters().get('radioName');
            Boolean partnerUserFlag = false;//Ver 2.0
            if(selUserId != null){
                /* Ver 2.0 Start */
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
                               //leadObj.Partner_Account__c = u.AccountId;
                               partnerUserFlag = true;
                              
                            }
                            else{
                                PageUtils.AddError('Assigned user should be a Partner User or Queue.');
                                return null;
                            }
                            //Ver 5.0 - Start
                            if(u.Enable_Partner_Lead_Management__c != true){
                              PageUtils.AddError('This Partner user does not have Lead Management access. To proceed, please choose a partner user who is enabled for lead management access.');
                                return null;
                            }
                            //Ver 5.0 - End
                        }
                    }                 
                }
                if(selUserId != 'other' && userMap.containsKey(selUserId)){
                    newOwnerLangStr = userMap.get(selUserId).LanguageLocaleKey;
                    partnerUserFlag = true;
                }   
                if(partnerUserFlag == true){  //If a partner proceed with existing functionality
                    leadObj.OwnerId = selUserId ;
                    leadObj.Partner_User__c = selUserId;
                    leadObj.Owner_Language_Code__c = newOwnerLangStr;
                    
                    leadObj.RecordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);                
                    if(action == 'Reassign'|| 
                       (leadObj.Accept_Reject_Reassign_Status__c == 'Rejected by Channel' &&
                        leadObj.Partner_Lead_Status__c  == 'Rejected'
                       )){
                        if(leadObj.Status =='Accepted by Channel Partner' && leadObj.Partner_Lead_Status__c  == 'Accepted') {
                        leadObj.Partner_Lead_Status__c  = 'Accepted';
                        leadObj.Status='Accepted by Channel Partner';
                        }
                        //10.0 Remove BANT Qualified
                        else{
                        leadObj.Partner_Lead_Status__c  = 'Reassigned';
                        leadObj.Status='Assigned to Channel Partner';
                        }
                        leadObj.Accept_Reject_Reassign_Status__c='Reassigned by Channel';
                        
                    }
                   
                    if(leadObj.Accept_Reject_Reassign_Status__c != 'Reassigned by Channel' && 
                       leadObj.Accept_Reject_Reassign_Status__c != 'Rejected by Channel'){
                        leadObj.Partner_Lead_Status__c  = 'New';
                        leadObj.Status='Assigned to Channel Partner';
                    }
                }
                else{//If new owner is queue and status is not Assigned to Channel Partner, just change the owner only.No other fields need to be updated.
                    
                    if(leadObj.Status != 'Assigned to Channel Partner' && leadObj.Status != 'Accepted by Channel Partner'){
                        leadObj.OwnerId = leadObjForUser.OwnerId;
                    }
                    else{
                        
                        PageUtils.addError('Lead is assigned to a Partner.Cannot be reassigned to queue');
                        return null;
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
            }/*Ver 2.0 - End */
            
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
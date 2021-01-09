/*
 * Author   : Men Mee
 * Purpose  : Centralize the record selection process for User.
 *          Defines the methods which iterate and segregate the User records for further use.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR12402     17.02       30-11-2015      Men Mee            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 
 * 
 */

public class UserRecordSelector extends RecordSelector {

    private TriggerHandler usrTriggerHandler;
    public Set<Id> contactIdSet = new Set<Id>();
    public Map<Id, Contact> contactMap = new Map<Id, Contact>();
    public Set<id> LMchangedids = new Set<id>();
    public Set<String> leadmgmntenabledIds = new Set<String>();
    public Set<String> leadmgmntdisabledIds = new Set<String>();
    public List<string> chatterUserIDList = new List<string>();
    public Map<Id, User> userMap = new Map<Id, User>();
    public Map<String, Id> gpMap = new Map<String, Id>();
       
    public UserRecordSelector(list<sObject> lstUsers, map<Id, sObject> mapOldUsers, TriggerHandler usrTriggerHandler) {
        this.usrTriggerHandler= usrTriggerHandler;
        
        this.getRecords(lstUsers, mapOldUsers);
        
        if(lstUsers!= null) {
            this.getRelatedRecords(lstUsers);
        }
        else if(mapOldUsers!= null) {
            this.getRelatedRecords(mapOldUsers.values());
        }
        
        removeNulls();
    }
    
    protected override void getRecords(list<sObject> lstUsers, map<Id, sObject> mapOldUsers) {
        string profileName;
        string userEmail;
        String GroupName;
        boolean isDellContractor = false;
        
        if(lstUsers != null) { 
        /* Map<id,id> mapusercontactMap=new Map<id,id>();
        list<id> listconidList=new list<id>();
        map<id,list<id>> mapconeligiblesmap=  new map<id, list<id>>();
         
       
 for(User usr:(list<User>)lstUsers){
    mapusercontactMap.put(usr.contactid,usr.id);
 }
 
        map<id,contact> mapcontactsmap =new map<id,contact>([select id,EligibleTracks__c from contact where id IN :mapusercontactMap.keyset()]);
        
           for(contact con :mapcontactsmap .values()){
           list<id> listelgids= new list<id>();
              list<string> listelg ;
               if(con.eligibletracks__c !=null){
               listelg = con.EligibleTracks__c.split(';');
              }
              if(listelg.size()>0){
           for(string strs:listelg){
             id id1=id.valueOf(strs);
              listelgids.add(id1);
                 }
                 }
                mapconeligiblesmap.put(con.id,listelgids);
                 
        }   */       
            for(User newUser : (list<User>)lstUsers) {
                
                User oldUser;
                if(mapOldUsers!= null && !mapOldUsers.isEmpty()) {
                    oldUser= (User) mapOldUsers.get(newUser.Id);
                }

                profileName = newUser.Profile_Name__c ;
                if (mapOldUsers == null) {                  
                    userEmail = newUser.Email.toUpperCase() ;

                    isDellContractor = userEmail.contains('DELLTEAM') ? true : false ;

                    system.debug('###### is contractor '+ isDellContractor);
                    system.debug('###### user email is '+ userEmail);

                    if(!profileName.contains('PRM Portal User') && !isDellContractor && newUser.IsActive == true && newUser.UserType == 'Standard' )
                    {
                        chatterUserIDList.add(newUser.Id);
                    }
                }
                
                contactIdSet.add(newUser.ContactId);

                //CMAP: Lead Management Enabled - Validation
                if (newUser.contactId != null && newUser.Enable_Partner_Lead_Management__c ) {
                    if (mapOldUsers == null || newUser.Enable_Partner_Lead_Management__c != oldUser.Enable_Partner_Lead_Management__c) {
                        LMchangedids.add(newUser.Id);
                    }
                }               

                //CMAP: Lead Management Enabled - Grant Tab/Object access
                if (profileName.contains('PRM Portal') && newUser.Enable_Partner_Lead_Management__c && newUser.isActive) {
                    if (mapOldUsers == null || newUser.Enable_Partner_Lead_Management__c != oldUser.Enable_Partner_Lead_Management__c)  {
                        leadmgmntenabledIds.add(newUser.id);
                    }
                }
                
                //CMAP: Lead Management Enabled - Remove Tab/Object access
                if (mapOldUsers != null && 
                    ((oldUser.Enable_Partner_Lead_Management__c && !newUser.Enable_Partner_Lead_Management__c && profileName.contains('PRM Portal') && newUser.isActive) ||
                     (oldUser.isActive && !newUser.isActive && newUser.Enable_Partner_Lead_Management__c && profileName.contains('PRM Portal')) ||
                     (oldUser.Profile_Name__c.contains('PRM Portal') && !profileName.contains('PRM Portal') && newUser.Enable_Partner_Lead_Management__c && newUser.isActive))) {
                    leadmgmntdisabledIds.add(newUser.id);
                }
                
             // List<id> listaccountids=mapconeligiblesmap.get(newUser.contactid);
                if(newUser.IsActive == TRUE && ((mapOldUsers == null && newUser.Enable_As_Partner_Lead_Super_User__c == TRUE) || (mapOldUsers != null && newUser.Enable_As_Partner_Lead_Super_User__c != oldUser.Enable_As_Partner_Lead_Super_User__c))){
                    GroupName = 'CMAP:'+newUser.AccountId;
                    userMap.Put(newUser.Id, newUser);
                    //gpMap.Put(GroupName, newUser.Id);
                    system.debug('----000000-------'+userMap);
                }               
            }
        }
        else if(mapOldUsers != null) { // Handling delete events
            
        }
    }
    
    protected override void getRelatedRecords(list<sObject> lstUsers) {
        if (!contactIdSet.isEmpty()) {
            contactMap = new Map<Id, Contact>([SELECT AccountId, Account.IsPartner,Vendor_Update_Datetime__c  FROM Contact WHERE Id IN :contactIdSet]);
        }    
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        
    }

}
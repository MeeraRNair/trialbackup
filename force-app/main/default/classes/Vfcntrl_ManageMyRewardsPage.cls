/*
REVISION HISTORY
================
Version        Author                Date          Release#         CR#                         Description
-------    ----------------       -----------     ------------     --------                    --------------       
1.0         Yeswanth Ravilla       01-Nov-2018     FY-19 0102       16746            Story 5704709: VTX: Modify Partner Manage MyRewards Status Page - Make it Lightning compatible
*/

public without sharing class Vfcntrl_ManageMyRewardsPage {
        
    public boolean bisPartnerAdmin { get; set; }
    public boolean isPermittedUser { get; set; }
    public string givenAccountId  { get; set; }
    public string str_PartnerTrackId  { get; set; }
    public string str_LoggedinContact  { get; set; }
    public string str_Selectedtrack  { get; set; }
  
    public Vfcntrl_ManageMyRewardsPage(){
        try{
            bisPartnerAdmin = false;
            isPermittedUser = false;          
            User loggedInUser = [SELECT Enable_Partner_Admin__c, UserType , Contact.AccountId, Contact.Account.Id, Contact.Title, Contact.Selected_Track__c FROM User WHERE Id = :UserInfo.getUserId()];
         // User loggedInUser = [SELECT Enable_Partner_Admin__c, UserType , Contact.AccountId, Contact.Account.Id, Contact.Title, Contact.Selected_Track__c FROM User WHERE Id = '0055C0000017BGuQAM'];  
            
            system.debug('givenAccountId-----------------------'+loggedInUser.Contact.Account.Id);
            if((loggedInUser.Contact != null) && (loggedInUser.Contact.Account != null)) { 
                givenAccountId = loggedInUser.Contact.AccountId;
                bisPartnerAdmin = loggedInUser.Enable_Partner_Admin__c;
               // str_LoggedinContact = loggedInUser.contactid;
               str_Selectedtrack = loggedInUser.contact.Selected_Track__c;
                 system.debug('str_LoggedinContact-----------------------'+loggedInUser.contact.Selected_Track__c);
            }
            if(givenAccountId == null || givenAccountId.length() == 0){
                givenAccountId = PageUtils.get('accountId'); 
                system.debug('>>>givenAccountId '+givenAccountId );
                str_PartnerTrackId  = PageUtils.get('partnerTrackId');
                system.debug('>>>str_PartnerTrackId  '+str_PartnerTrackId );
                 if(givenAccountId == null || givenAccountId.length() == 0){ 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid account Id.'));
                    return;
                 }
                 Set<Id> permittedProfileIds = new Set<Id>();
                    permittedProfileIds.add('00e30000000nJ6K'); // System Administrator
                    permittedProfileIds.add('00e70000000wzqq'); // GBL PRM Operations
                    permittedProfileIds.add('00e70000000x0Xj'); // GBL PRM Operations - non SSO
                    permittedProfileIds.add('00eA0000000hOpn'); // GBL PRM Certification Admin
                    permittedProfileIds.add('00eA0000000hOps'); // GBL PRM Certification Admin - Non SSO
                    permittedProfileIds.add('00eA0000000hORl'); // GBL PRM Operations Admin
                    permittedProfileIds.add('00eA0000000hORq'); // GBL PRM Operations Admin - Non SSO
                              
                    isPermittedUser = permittedProfileIds.contains(UserInfo.getProfileId());
              }      
           
                if(!isPermittedUser && !bisPartnerAdmin ){            
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.access_denied ));
                }          
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: PartnerSelfServiceIncBulkNominateCtrlExt]');
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Your request could not be handled at this time. Please try again later or contact your administrator for assistance.'));
        }
    }
  
   @TestVisible
  public class ResponseWrapper{
        @AuraEnabled public Map < String,String > cmpyStatusValues;
        @AuraEnabled public List<Contact> contactList;
        @AuraEnabled public string rewardsCmpyStatus;
        @AuraEnabled public string baseURL;
        @AuraEnabled public Map < String,String > rewardsRoles;
        @AuraEnabled public boolean hasChanges;
        
     }
  
 @AuraEnabled
  public static ResponseWrapper onLoadMethodCtrl(String accId,String partnertrackid){  
      System.debug('accId'+accId);
      System.debug('partnertrackid'+partnertrackid);
      
       User loggedInUser = [SELECT Enable_Partner_Admin__c, UserType , Contact.AccountId, Contact.Account.Id,Contact.selected_track__c,Contact.Title FROM User WHERE Id = :UserInfo.getUserId()];
      System.debug('loggedInUser>>'+loggedInUser.contact); 
      String str_Selectedtrack = loggedInUser.Contact.selected_track__c;
      
      System.debug('str_Selectedtrack>>'+str_Selectedtrack);
      
       ResponseWrapper res = new ResponseWrapper();    
       list<contact> conList = new list<contact>();
        list<Partner_track__c> partnertrackList = new list<Partner_track__c>();

      
      res.rewardsRoles = fetchPicklistValues('Assign_MyRewards_Role__c');
      System.debug('res.rewardsRoles'+res.rewardsRoles);
    res.cmpyStatusValues = fetchPicklistValues('MyRewards_Company_Status__c');
      conList = fetchContacts(accId,null,null,null,null,null,null);
      System.debug('res.rewardsRoles'+res.rewardsRoles);
      if(String.isNotBlank(partnertrackid)){
         
        partnertrackList = [select id,MyRewards_Company_Status__c from Partner_track__c where id=:partnertrackid];
        res.rewardsCmpyStatus = partnertrackList[0].MyRewards_Company_Status__c; 
          system.debug('>>>>> res.rewardsCmpyStatus'+ res.rewardsCmpyStatus);
         }
      else{//res.cmpyStatusValues = fetchPicklistValues('MyRewards_Enabled__c');
          
          partnertrackList = [select id,MyRewards_Company_Status__c from Partner_track__c where id=:str_Selectedtrack];
          res.rewardsCmpyStatus = partnertrackList[0].MyRewards_Company_Status__c; 
         

           }
      
      res.contactList = conList;
      if(conList.size() > 0){
     // res.rewardsCmpyStatus = conList[0].Account.MyRewards_Enabled__c;
      }
      res.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
      
      return res;
  }  
    
  @AuraEnabled  
      public static boolean updateCompanyStatusCtrl(ID accID,String rewardsValue){
        boolean retVal = false;
          Account accOld = [select id,MyRewards_Enabled__c from Account where Id=:accID];
          if(accOld.MyRewards_Enabled__c !=rewardsValue){
              retVal = true;
          }else{
              retVal = false;
          }
        Account acc = new Account(Id=accID, MyRewards_Enabled__c=rewardsValue);
      try{
        update acc;
      }catch(DmlException e) {
            //get DML exception message
            throw new AuraHandledException(e.getMessage());
        }
          
          return retVal;
    }
    
    @AuraEnabled  
      public static boolean updateCompanyStatusCtrlPT(string partnertrackid,String rewardsValue){
         System.debug(' res.accountPartnerTrackId'+ partnertrackid);
          string trackId;
          
          boolean retVal = false;
          Partner_track__c PTOld = [select id,MyRewards_Company_Status__c from Partner_track__c where Id=:partnertrackid];
          if(PTOld.MyRewards_Company_Status__c !=rewardsValue){
              retVal = true;
          }else{
              retVal = false;
          }
        Partner_track__c PTT = new Partner_track__c(Id=partnertrackid,MyRewards_Company_Status__c=rewardsValue);
      try{
        update PTT;
      }catch(DmlException e) {
            //get DML exception message
            throw new AuraHandledException(e.getMessage());
        }
          
          return retVal;
    }
    
    public static Map < String,String > fetchPicklistValues(string fldName){
     Map < String,String > allOpts = new Map < String,String > ();
     Schema.sObjectType objType;
        
       // Get the object type of the SObject.
        if(fldName == 'MyRewards_Enabled__c'){
          objType = Account.getSObjectType();
        } else if(fldName == 'Assign_MyRewards_Role__c'){
           objType = Contact.getSObjectType();        
        }else if(fldName=='MyRewards_Company_Status__c'){
            objType = Partner_Track__c.getSObjectType(); 
        }
    
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
     
      // Get a map of fields for the SObject
      map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
    
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a: fieldMap.get(fldName).getDescribe().getPickListValues()) {
       //allOpts.put('','');
       allOpts.put(a.getValue(),a.getLabel());
      }
       return allOpts;
    }     
  
 @AuraEnabled
    public static ResponseWrapper saveContacts(List<Contact> lstContact) { 
        ResponseWrapper res = new ResponseWrapper();    
        contact blankCon = new contact();
        Map<id,Contact> orgContactMap = new Map<id,Contact>();
        list<contact> conListToUpdate = new list<contact>();
        List<Contact> lstOrgContact = new List<Contact>();
        lstOrgContact = fetchContacts(lstContact[0].AccountId,null,null,null,null,null,null);
        
        for(contact temp :lstOrgContact ){
            orgContactMap.put(temp.id,temp);
        }

        for(contact temp: lstContact){
               contact con = new contact();
            if(orgContactMap.get(temp.id).Enable_User_for_MyRewards__c != temp.Enable_User_for_MyRewards__c ) {
                con.id = temp.id;
                con.Enable_User_for_MyRewards__c = temp.Enable_User_for_MyRewards__c;               
            }
             if(orgContactMap.get(temp.id).Is_Enabled_for_Incentives__c != temp.Is_Enabled_for_Incentives__c ) {
                con.id = temp.id;
                con.Is_Enabled_for_Incentives__c = temp.Is_Enabled_for_Incentives__c;                  
            }
             if(orgContactMap.get(temp.id).Assign_MyRewards_Role__c != temp.Assign_MyRewards_Role__c ) {
     
                 
                 con.id = temp.id;
                con.Assign_MyRewards_Role__c = temp.Assign_MyRewards_Role__c;                   
            }
            
            if(con != blankCon){
                   conListToUpdate.add(con);
                }
        }
        system.debug('****' +conListToUpdate);
        res.contactList = lstContact;
        try{
            if(conListToUpdate.size() > 0){
                update conListToUpdate;
            }else{
             res.hasChanges = false;
            }
        }catch(DmlException e) {
            //get DML exception message
            throw new AuraHandledException(e.getMessage());
        }
        return res;
    }
    
  @AuraEnabled
    public static List < Contact > fetchContacts(String givenAccountId,string searchFirstNameVal,string searchLastNameVal,string searchJobTitleVal,string includesearchAssignRewardsVal,
                                                 string searchStatusVal,string searchUserRewardsVal) {
                                                 system.debug('includesearchAssignRewardsVal :'+includesearchAssignRewardsVal);
        list<contact> conList = new list<contact>();
          string newFilterString = '';
        try{
            newFilterString += (searchFirstNameVal != null && searchFirstNameVal.length() > 0) ? ' AND FirstName LIKE \'%' + searchFirstNameVal + '%\'' : '';
            newFilterString += (searchLastNameVal != null && searchLastNameVal.length() > 0) ? ' AND LastName LIKE \'%' + searchLastNameVal + '%\'' : '';    
            newFilterString += (searchJobTitleVal != null && searchJobTitleVal.length() > 0) ? ' AND Contact.Title LIKE \'%' + searchJobTitleVal + '%\'' : '';
            if('--None--' != IncludesearchAssignRewardsVal ) {
                newFilterString += (null != IncludesearchAssignRewardsVal && IncludesearchAssignRewardsVal != '' && IncludesearchAssignRewardsVal .length() > 0) ? ' AND Contact.Assign_MyRewards_Role__c = :IncludesearchAssignRewardsVal ':'';
             }else{
             newFilterString += ('--None--' == IncludesearchAssignRewardsVal ) ? ' AND Contact.Assign_MyRewards_Role__c = null':'';
             }
            system.debug('****' +newFilterString);
            if(searchStatusVal != null && searchStatusVal.length() > 0){
                if(searchStatusVal.equals(Label.yes)){
                    newFilterString += ' AND Contact.Is_Enabled_for_Incentives__c = TRUE'; 
                }else if(searchStatusVal.equals(Label.no)){
                    newFilterString += ' AND Contact.Is_Enabled_for_Incentives__c = FALSE';
                }
            }    
            if(searchUserRewardsVal != null && searchUserRewardsVal.length() > 0){
                if(searchUserRewardsVal.equals(Label.yes)){
                    newFilterString += ' AND Contact.Enable_User_for_MyRewards__c = TRUE'; 
                }else if(searchUserRewardsVal.equals(Label.no)){
                    newFilterString += ' AND Contact.Enable_User_for_MyRewards__c = FALSE';
                }
            }
        
        string defaultFilterCriteria;
            
        if(!test.isRunningTest()){
         defaultFilterCriteria    = ' WHERE AccountId = \'' + givenAccountId + '\' AND Partner_user__r.IsActive = TRUE';
        }else{
          defaultFilterCriteria = ' WHERE AccountId = \'' + givenAccountId.trim() +  '\'' ;      
          }
          system.debug('givenAccountId '+givenAccountId);
        string filterCriteria;
          if(newFilterString.length() > 0){
                filterCriteria = defaultFilterCriteria + newFilterString;
            }else{
                filterCriteria = defaultFilterCriteria;
            }
        
         string queryString = 'select Account.MyRewards_Enabled__c,Enable_User_for_MyRewards__c,Assign_MyRewards_Role__c,Is_Enabled_for_Incentives__c,Partner_user__r.Name,Title,' 
                             + 'Partner_user__r.Enable_Partner_Admin__c,Partner_user__r.IsActive from contact ' + filterCriteria +' ORDER BY FirstName LIMIT 10000';  
        
           system.debug('Query : '+queryString );
            conList = database.query(queryString); 
            system.debug('*****' +conList);
         
           }catch(Exception e) {
            //get DML exception message
            throw new AuraHandledException(e.getMessage());
        }
         return conList;
    }
    
}
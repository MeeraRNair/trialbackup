/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#              Description
-------     ------      ----            --------    ---             -----------
1.0         
2.0         Annie        13-Oct-2014     15.10      10483 FR 9.4.1    
3.0         Annie        12-Nov-2014     15.10      10623  
4.0         Annie        14-Nov-2014     15.10      10623            Added SFDC Profiles are add 
                                                                     to OSC_Profile_Settings__c custom setting  
5.0         Samridh      30-Dec-2014     16.03      10752            user now able to search through Deal Id search box
6.0         Jaya         23-Jun-2016     MIM        CRQ000000462832  Fix solution records select query, replace with aggregation count() query.   
7.0         Venkat       10-Oct-2018     FY19-0102  16670            Show only Approved deals whose expiration date is greater or equal to today and also empty.
8.0         Emily        08-Jan-2019     FY20-0202  16970            Remove primary_owner__c
9.0         Mahesh       31-Jan-2019     FY20-0402                   Updated code to sync with PAM Changes  
*/

public without sharing class ExistingDealRegistrationCls
{
    public String oppid{get; set;}
    Public List<Opportunity> lstOpp;
    public String oscid;
    public string DealId{get;set;}
    public boolean showHideErr{get;set;}
    public boolean erroroverride ;
    public user usr;
    public user usr1;
    public user usr2;
    public user usr3;
    public string err{get;set;}
    public string confmsg{get;set;}
    private integer counter=0;  //keeps track of the offset
    private integer list_size=25; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    //R14.5 - Add search/filter
    public String searchOppName { get; set; }
    public String searchPrimaryOwner { get; set; }
    public String searchEndUserAccName { get; set; }
    //public Date searchCloseDate { get; set; } //use searchOpp.Decision_Date__c instead to get date input control from inputField
    public Opportunity searchOpp { get; set; }
    public String searchOppIds{ get; set; }    
    public String searchStage { get; set; }
    public String searchDealRegStatus { get; set; }
    public String searchTagged { get; set; }
    
    public boolean isTagged {get;set;}
    public String strsalesMotionAccId { get; set; }
    public list<Account> listSalesMotionAcc;
    public string strpartnerTrackID;
        
    public class AdminController{
    public User usr {get;set;}
        
        

   // creating dummy method
   public String getUser() {
        return null;
    }

     public AdminController(){
       usr= new User();
    }
}
 
    String[] s = new String[]{'New','Submitted','Approved'};
    //ver 2.0 Code Start
    public boolean IsProfile {get;set;} 
    public boolean ishasList {get;set;} 
    Id userId; // = userinfo.getUserId();
    List<User> usrLst = new List<User>();    
    //Ver 4.0:CR 10623: Code Change: SFDC Profiles are checked in OSC_Profile_Settings__c custom setting :Start
    //List<OSC_Profile_Settings__c> profileList = OSC_Profile_Settings__c.getall().values();
    String profileNameWithoutVersion ;//= profileName.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}',''); 
    OSC_Profile_Settings__c profileList; // = OSC_Profile_Settings__c.getValues(profileNameWithoutVersion); 
    //Ver 4.0:CR 10623: Code Change :SFDC Profiles are checked in OSC_Profile_Settings__c custom setting: End
    
    //ver 2.0 Code End*/
    public String OSCActionIdentifier = 'Association';
    public Id loggedInUserIdVar {get; set;}
    
    public ExistingDealRegistrationCls(){
        try{
             strsalesMotionAccId = ApexPages.currentPage().getParameters().get('SalesmotionId');
             strpartnerTrackID = ApexPages.currentPage().getParameters().get('PartnerTrackID');
            
            userId = userinfo.getUserId();
            usrLst = [Select id, UserType, IsPortalEnabled From User Where Id =: UserId];           
            //R14.5
            ishasList = false;
            IsProfile = false;
            erroroverride = false;
            searchOpp = new Opportunity();
            searchOpp.Decision_Date__c = null;
            list<Account> listSalesMotionAcc = new list<Account>();
            //8.0 searchOpp.Primary_Owner__c = null;
            isTagged = true;
            loggedInUserIdVar = userInfo.getUserId();
            oscid = Apexpages.currentpage().getParameters().get('oscid');
            //ver 2.0 Code Start               
            //Ver 4.0:CR 10623: Code Change :SFDC Profiles are checked in OSC_Profile_Settings__c custom setting: Start
            //for(OSC_Profile_Settings__c oscProf : profileList){         
            //if(profileName.contains(oscProf.Name)){
            //Ver 4.0:CR 10623: Code Commented }           
            //ver 2.0 Code End
            if(usrLst[0].UserType == 'PowerPartner' && usrLst[0].IsPortalEnabled == TRUE){
              IsProfile = true;    //ver 2.0 Code Change      
          }    
  }
       Catch(Exception e){
         system.Debug('----exception occured----'+e);
      }
      
    }
    
   public void SearchAction(){
   erroroverride = false;
   ishasList = false;
   showHideErr = false;
   counter = 0;
   getLstOpp();
   getDisablePrevious();
   getDisableNext();
   getTotal_size();
   getPageNumber();
   getTotalPages();
   } 
   
   public void ResetAction(){
   erroroverride = true;
   IsProfile = true;
   ishasList = false;
   showHideErr = false;
   DealId = '';
   searchOppName = '';   
   searchEndUserAccName = '';
   searchOpp.Decision_Date__c = null;
   //8.0 searchOpp.Primary_Owner__c = null;
   searchStage = 'All';   
   searchTagged = 'All'; 
   isTagged = true;
   counter = 0;
   getLstOpp();
   getDisablePrevious();
   getDisableNext();
   getTotal_size();
   getPageNumber();
   getTotalPages();
     
   } 
      
    public List<Opportunity> getLstOpp(){   
      
    List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
    String oppTeamQuery = 'Select userid, OpportunityId FROM OpportunityTeamMember where userid = ' + '\'' + userInfo.getUserId() + '\'' ;  
    oppTeamList = Database.query(oppTeamQuery);   
    Set<Id> oppIds = new Set<Id>();
    
    for( OpportunityTeamMember oppTeam: oppTeamList ){
        oppIds.add(oppTeam.OpportunityId);
    }  
    /*8.0
    If(searchOpp.Primary_Owner__c != null ){
    loggedInUserIdVar = searchOpp.Primary_Owner__c;
     usr3 =[select accountid from user where id = :searchOpp.Primary_Owner__c] ;
     List<OpportunityTeamMember> oppTeamtaggedList = new List<OpportunityTeamMember>();
    String oppTeamQuery1 = 'Select userid, OpportunityId FROM OpportunityTeamMember where userid = ' + '\'' + searchOpp.Primary_Owner__c + '\'' ;
    oppTeamtaggedList = Database.query(oppTeamQuery1);
    Set<Id> opptagIds = new Set<Id>();
    
    for( OpportunityTeamMember opptaggedTeam: oppTeamtaggedList ){
        opptagIds.add(opptaggedTeam.OpportunityId);
    }
    List<Opportunity> opt3 = new List<Opportunity>();
      try{        
        opt3=[select name,Account.Name,End_User_Account_Name__c,PartnerAccountId,CloseDate,StageName,Deal_Registration_Status__c,OwnerId,Deal_Expiration_Date__c from Opportunity where (Deal_Registration_Status__c = 'Approved') AND (OwnerId =: usr3.id OR Id IN: opptagIds) AND (Deal_Expiration_Date__c >= TODAY OR Deal_Expiration_Date__c = null) AND (StageName NOT IN ('Win - 100%','Lost, Cancelled - 0%'))];
        system.debug('deal status'+opt3);
        if(opt3.size()>0){
        if (usr3.id == searchOpp.Primary_Owner__c){
        total_size = 1;
        return opt3;
        }
        else{
        showHideErr = True;
        err = 'No matching records found';
        counter = -25;
        total_size = 0;
        return null;
            }
        } 
         } 
         catch(Exception e){
       system.debug('pinku: 101 ' );
    showHideErr = true;
    err='error';
    return null;
 }
    }else{
        loggedInUserIdVar = userInfo.getUserId();
    }
    */
    
    loggedInUserIdVar = userInfo.getUserId();
    
    If(searchTagged != null && searchTagged == 'Owned' ){
      usr1 =[select accountid from user where id = :userinfo.getuserid()] ;
    List<Opportunity> opt1 = new List<Opportunity>();
      try{
          system.debug('******strsalesMotionAccId' +strsalesMotionAccId);
       if(strsalesMotionAccId != null){
            opt1=[select name,Account.Name,End_User_Account_Name__c,PartnerAccountId,CloseDate,StageName,Deal_Registration_Status__c,OwnerId,Deal_Expiration_Date__c from Opportunity where OwnerId =: usr1.id AND Deal_Registration_Status__c='Approved' AND (Deal_Expiration_Date__c >= TODAY OR Deal_Expiration_Date__c = null) AND (StageName NOT IN ('Win - 100%','Lost, Cancelled - 0%')) AND PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c = :strpartnerTrackID AND PartnerAccount.Account_ID__c = : strsalesMotionAccId];
        }else{
           opt1=[select name,Account.Name,End_User_Account_Name__c,PartnerAccountId,CloseDate,StageName,Deal_Registration_Status__c,OwnerId,Deal_Expiration_Date__c from Opportunity where OwnerId =: usr1.id AND Deal_Registration_Status__c='Approved' AND (Deal_Expiration_Date__c >= TODAY OR Deal_Expiration_Date__c = null) AND (StageName NOT IN ('Win - 100%','Lost, Cancelled - 0%')) AND PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c = :strpartnerTrackID];
        }
       
       if(opt1.size()>0){
        if (usr1.id == userinfo.getuserid()){
        total_size = 1;
        return opt1;
        }
        else {
        system.debug('pinku 6');
        showHideErr = True;
        err = 'No matching records found';
        counter = -25;
        total_size = 0;
        return null;
            }
        } 
         } 
         catch(Exception e){
       system.debug('pinku: 101 ' );
    showHideErr = true;
    err='error';
    return null;
 }
    }
    
    If(searchTagged != null && searchTagged == 'Tagged' ){
    usr2 =[select accountid from user where id = :userinfo.getuserid()] ;
    List<Opportunity> opt2 = new List<Opportunity>();
      try{
        opt2=[select name,Account.Name,End_User_Account_Name__c,PartnerAccountId,CloseDate,StageName,Deal_Registration_Status__c,OwnerId,Deal_Expiration_Date__c from Opportunity where Id IN: oppIds AND Deal_Registration_Status__c='Approved' AND (Deal_Expiration_Date__c >= TODAY OR Deal_Expiration_Date__c = null) AND (StageName NOT IN ('Win - 100%','Lost, Cancelled - 0%')) ];
        if(opt2.size()>0){
        system.debug('####Opportunities size' + opt2);
        if (usr2.id == userinfo.getuserid()){
        total_size = 1;
        return opt2;
        }
        }
        else {
        showHideErr = True;
        err = 'No matching records found';
        counter = -25;
        total_size = 0;
        return null;
            }
        }        
         catch(Exception e){
       system.debug('pinku: 101 ' );
    showHideErr = true;
    err='error';
    return null;
 }
    }  
            
   If(DealId != null && String.isNotBlank(DealId)){
      usr =[select accountid from user where id = :userinfo.getuserid()] ;
      string dealtrim = DealId.trim();
      List<Opportunity> opt = new List<Opportunity>();
      try{
           list<OpportunityTeamMember> listOTM=[SELECT Name,OpportunityId  FROM OpportunityTeamMember WHERE Opportunity.Deal_ID__c = :dealtrim AND UserId = :userinfo.getuserid() limit 1];
           if(listOTM.size() > 0 ){
           opt=[select name,Account.Name,End_User_Account_Name__c,PartnerAccountId,CloseDate,StageName,Deal_Registration_Status__c,OwnerId,Deal_Expiration_Date__c from Opportunity where Deal_ID__c = :dealtrim AND Deal_Registration_Status__c='Approved' AND (Deal_Expiration_Date__c >= TODAY OR Deal_Expiration_Date__c = null) AND (StageName NOT IN ('Win - 100%','Lost, Cancelled - 0%'))]; 
           }else{
           opt=[select name,Account.Name,End_User_Account_Name__c,PartnerAccountId,CloseDate,StageName,Deal_Registration_Status__c,OwnerId,Deal_Expiration_Date__c from Opportunity where Deal_ID__c = :dealtrim AND Deal_Registration_Status__c='Approved' AND (Deal_Expiration_Date__c >= TODAY OR Deal_Expiration_Date__c = null) AND (StageName NOT IN ('Win - 100%','Lost, Cancelled - 0%')) AND PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c = :strpartnerTrackID AND OwnerId =:userinfo.getuserid()];  
           }
           if(opt.size()>0){
        if( ( usr.accountid != null && opt[0].PartnerAccountId != null) || oppIds.contains(opt[0].Id) ){ //usr.accountid == opt[0].PartnerAccountId &&
        system.debug('pinku 5');
        total_size = 1;
        return opt;
          }
        else{
         showHideErr = True;
        err = 'No matching records found. Please ensure that the Deal ID is valid.';
        counter = -25;
        total_size = 0;
        return null;
            }    
        }
      
     else{
     system.debug('Pinku list is empty: ');  
  /*   if(dealtrim.length() != 7)
     {
         system.debug('pinku 7');
      showHideErr = True;
       err = 'The format entered is incorrect. Please search using a valid Deal ID.';
       counter = -25;
       total_size = 0;
     } 
     else{ */
     system.debug('pinku 8');
      showHideErr = True;
      system.debug('jjjjjj'+showHideErr);
      err = 'No matching records found. Please ensure that the Deal ID is valid.';
      counter = -25;
      total_size = 0;
    //}
      return null;
     } 
    }
    catch(Exception e){
       system.debug('pinku: 101 ' );
    showHideErr = true;
    err='error';
    return null;
 }  
 }
 String soqlSelect;
        String soqlSearch = '';
        String soqlOrder;
        String soqlLimitOffset;
        String SoqlSelectcount;
        String lmcount;
        String OptTeamMember;
  if(usrLst[0].UserType == 'PowerPartner' && usrLst[0].IsPortalEnabled == TRUE){
         system.debug('pinku 9');           
            soqlSelect = 'SELECT Name, End_User_Account_Name__c,Account.Name, CloseDate, StageName, Deal_Registration_Status__c, OwnerId,Deal_Expiration_Date__c FROM Opportunity ' +
                                'WHERE PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c = :strpartnerTrackID AND Deal_Registration_Status__c IN (\'Approved\')  ' + 'AND StageName NOT IN (\'Win - 100%\',\'Lost, Cancelled - 0%\')' + 'AND (Deal_Expiration_Date__c >=TODAY OR Deal_Expiration_Date__c=null)'
                                + 'AND ( OwnerId = \'' + userInfo.getUserId() + '\' '  + ' OR ID IN: oppIds )'; //Venkat - modified condition as part of OSC changes
                      
            SoqlSelectcount =  'SELECT Count() FROM Opportunity ' +
                                'WHERE PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c = :strpartnerTrackID AND Deal_Registration_Status__c IN (\'Approved\')  ' + 'AND StageName NOT IN (\'Win - 100%\',\'Lost, Cancelled - 0%\')' + 'AND (Deal_Expiration_Date__c >=TODAY OR Deal_Expiration_Date__c=null)'
                                + 'AND ( OwnerId = \'' + userInfo.getUserId() + '\' '  + ' OR ID IN: oppIds )'; //Venkat - modified condition as part of OSC changes
             lmcount = +'LIMIT 2000';                  
            soqlLimitOffset = 'LIMIT ' + String.valueOf(list_size) + ' OFFSET ' + String.valueOf(counter);
            if(String.isNotBlank(searchOppName)) {
                soqlSearch += 'AND Name LIKE \'%' + String.escapeSingleQuotes(searchOppName) + '%\' ';
            }
            if(String.isNotBlank(searchEndUserAccName)) {
                soqlSearch += 'AND End_User_Account_Name__c LIKE \'%' + String.escapeSingleQuotes(searchEndUserAccName) + '%\' ';
            }
            if(searchOpp.Decision_Date__c!=null) {
                soqlSearch += 'AND CloseDate = ' +
                               String.valueOf(searchOpp.Decision_Date__c.year()) + '-' +
                               (Integer.valueOf(searchOpp.Decision_Date__c.month()) >= 10 ? '' + searchOpp.Decision_Date__c.month() : '0' + searchOpp.Decision_Date__c.month()) + '-' +
                               (Integer.valueOf(searchOpp.Decision_Date__c.day()) >= 10 ? '' + searchOpp.Decision_Date__c.day() : '0' + searchOpp.Decision_Date__c.day()) + ' ';
            }
            if(searchStage!=null && searchStage!='All') {
                soqlSearch += 'AND StageName = \'' + searchStage + '\' ';
            }
            if(String.isNotBlank(searchOppName)) {
                soqlSearch += 'AND Name LIKE \'%' + String.escapeSingleQuotes(searchOppName) + '%\' ';
            }
            /*8.0
            if(searchOpp.Primary_Owner__c!=null) {
                soqlSearch += 'AND Primary_Owner__c = \'' + searchOpp.Primary_Owner__c+ '\' ';
            }
            */     
                            
            system.debug('@@soqlSelect: '+soqlSelect);
            system.debug('@@soqlSelect2: '+soqlSearch);
            system.debug('@@soqlSelect3: '+soqlLimitOffset);
            system.debug('@@Total_Size: '+ total_size);
            total_size = Database.countQuery( SoqlSelectcount + soqlSearch + lmcount); 
            if(total_size > 0){
            return Database.query(soqlSelect + soqlSearch + soqlLimitOffset); 
            }
            else{
            total_size = 0;
            counter = -25;
            If(erroroverride == false){
            showHideErr = true;
            err='No matching records found.';
            }
            return null ; 
            }    
        } 
       
        return NULL;        
    }
    
    //R14.5 - for search filter
  public List<selectOption> getStages() {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('All', 'All - Open'));
        Schema.sObjectType sobject_type = searchOpp.getSObjectType();       
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();       
        List<Schema.PicklistEntry> pick_list_values = field_map.get('StageName').getDescribe().getPickListValues();       
        for (Schema.PicklistEntry a : pick_list_values) { 
           if(a.getValue()!= 'Win - 100%' && a.getValue()!= 'Lost, Cancelled - 0%'){            
            options.add(new selectOption(a.getValue(), a.getValue()));
           } //Pallavi - added picklist value filter as part of OSC changes           
        }
        return options;
    }
    
    //R14.5 - for search filter
    
   public List<selectOption> getDealRegStatuses() {
        List<selectOption> options = new List<selectOption>();         
        options.add(new selectOption('Approved', 'Approved'));
        return options;
    }
   
    public List<selectOption> getTagged() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('', ''));
        options.add(new selectOption('Tagged', 'Tagged'));
        options.add(new selectOption('Owned', 'Owned'));
        return options;
    }
    
     public List<selectOption> getSalesMotion() {
        listSalesMotionAcc = [select id,Account_id__c,name from account where account_id__c = :ApexPages.currentPage().getParameters().get('SalesmotionId')];
        List<selectOption> listoptions = new List<selectOption>();
         if(listSalesMotionAcc.size() > 0){
             listoptions.add(new selectOption(listSalesMotionAcc[0].Account_id__c, listSalesMotionAcc[0].name));
         }
            listoptions.add(new selectOption('', ''));
        return listoptions;
    }
    
    public without sharing class UserController {
    public List<User> UserTemp = new List<User>();
    public UserController()
    {
    
    }
}
                
    public PageReference Beginning() { //user clicked beginning
      counter = 0;      
      return null;
   }

   public PageReference Previous() { //user clicked previous button
      counter -= list_size;   
      return null;
   }

   public PageReference Next() { //user clicked next button
      counter += list_size;
      return null;
   }

   public PageReference End() { //user clicked end
   if (math.mod(total_size, list_size) > 0) {
      counter = total_size - math.mod(total_size, list_size);   
      } else {
         counter = total_size - math.mod(total_size, list_size)-25;
      }      
      return null;
   }

   public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }

   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + list_size < total_size) return false; else return true;
   }

   public Integer getTotal_size() {
      return total_size;
   }

   public Integer getPageNumber() {
      return counter/list_size + 1;
   }

   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
    
    public PageReference associate(){
     ishasList = false;
     showHideErr = false;
        if(oscid!='' && oscid!=null)
        {
            if(oscid.contains('%3A')){
                oscid = oscid.replace('%3A',':');   
           }
            // Ver 6.0 code Start
            integer totalSolutionRecordExist = database.countQuery('select count() from Solution__c where OSC_Regional_ID__c=:oscid');
            // verifying if the solution id has already been existed in the database, totalSolutionRecordExist must be more than 0.
            if(totalSolutionRecordExist>0){
                showHideErr = True;
                err = system.Label.SolutionID_Error_Message;
                return null;
            }
            // Ver 6.0 code end         
            // create new solution record  and associating to the deal 
            Solution__c solObj = new Solution__c();
            solObj.Opportunity__c = oppid;
            solObj.OSC_Regional_ID__c = oscid;
            try
            {                             
             // create maps to send the opportunity details to osc web service callout class  - samridh
                Map<id,Opportunity> oppMp = new  Map<id,Opportunity>();
                Map<Id,List<String>> sendsolMap = new Map<Id,List<String>>();
                Map<Id,List<Opportunitylineitem>> opptylineitem = new Map<ID,List<Opportunitylineitem>>();
                list<opportunitylineitem> opptylineitemlist = new list<opportunitylineitem>();
                    if(usrLst[0].UserType == 'PowerPartner' && usrLst[0].IsPortalEnabled == TRUE){
                      Opportunity o = [select id,ownerid,name,end_user_account_name__c,account.name, deal_id__c,deal_type__c,Deal_Registration_Status__c,StageName,Deal_Expiration_Date__c,Opportunity_Customer_Number__r.Name,Affinity_ID__c,Unassigned_End_User__c,Unweighted_Rev_USD__c,partnerAccount.Account_id__c,PartnerAccount.name,PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c,PartnerAccount.Partner_Track__r.name from opportunity where id=:oppid];      //Anamika - pass Opportunity_Customer_Number & End User Affinity ID info to OSC       
                      opptylineitemlist = [select PricebookEntry.product2.name, PricebookEntry.productcode, product_type__c from opportunitylineitem where opportunity.id =: o.id];
                        if(o!=null){
                            oppMp.put(o.id,o);
                            sendsolMap.put(o.id,new List<String>{oscid});
                            if(opptylineitemlist.size() > 0){
                                opptylineitem.put(o.id,opptylineitemlist);
                            }
                            Boolean bolTagFlag=false;
                            if(userinfo.getuserid() != o.ownerid){
                                bolTagFlag=true;
                            }
                            OSCWebServiceCallout.processRequest(oppMp,sendsolMap,OSCActionIdentifier,opptylineitem,bolTagFlag); 
                        }
                    }
                insert solObj;
            }
            catch(DMLException e)
            {
            // displaying error message if the solution id has already been existed in the database.
                if(e.getMessage().contains('duplicate value found: OSC_Regional_ID__c')){
                showHideErr = True;
                err = system.label.SolutionID_Error_Message;
               }
                return null;
            }
            catch(Exception exc)
            {
                System.debug(exc);
            }
        }
        
        // Confirmation message when user is not the owner of the record     
         if(usrLst[0].UserType == 'PowerPartner' && usrLst[0].IsPortalEnabled == TRUE){
                       
              UserRecordAccess oppaccess = [SELECT HasReadAccess,RecordId FROM UserRecordAccess Where UserId=:userInfo.getUserId() and RecordId = :oppid];
              if( oppaccess.HasReadAccess == false){
                 ishasList = true;
                 confmsg = 'Your solution has been associated to the deal. In order to view deal details, you need to be the owner of the deal.';
                 return null;
                  }
              }
        return new Pagereference('/'+oppid);
    }
}
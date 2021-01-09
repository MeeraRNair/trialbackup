/*
REVISION HISTORY
================
Version     Author      Date            Release#       CR#     Description
-------     ------      ----            --------       ----    ------------
1.0         Fenny       19-Nov-2012     14.2           7863    Bulk Incentive Nomination UI for partner admin, as well as channel operation team
2.0         Michael     11-June-2018    FY19-DCS-0802  16007   Removed Contact.Provisioned_in_Netexam_on__c, from the query in line number 200 as part of Decommisioning Provisioned_in_Netexam_on__c for Story# 4988554
2.1         Jatin Puri  11-June-2018    FY19-DCS-0802  16018   Decommisioned netexam and Feature_Request_Training__c as part of story# 4988542
3.0         Yeswanth    14-Sep-2018     FY19-DCE-1101  16486   STORY 5447994:-VTX: Modify Invite new Partner Contacts Page - User Section
3.1         Pavan       18-Sep-2018     FY19-DCE-1101  16488   Story 5461301: Modify Invite new Partner Contacts Page - Search Section
3.2         Suresh      18-Sep-2018     FY19-DCE-1101  16489   Story 5461301: Modify Invite new Partner Contacts Page - SAVE confirmation message
*/
public class PartnerSelfServiceIncBulkNominateCtrlExt extends DellStandardController {
    private User loggedInUser;
    private string givenAccountId;
    Public Id AccountId;
    private string defaultFilterCriteria;
    private string filterCriteria;  
    public string searchStatusVal { get; set; }
    public String searchUserRewardsVal {get;set;}
    public String searchAssignRewardsVal {get;set;}
    public String IncludesearchAssignRewardsVal {get;set;}
    public string searchLastNameVal { get; set; }
    public string searchJobTitleVal { get; set; }
    public string searchFirstNameVal { get; set; }
    public Integer pageSize { get; set; }
    public Integer totalPageNumber { get; set; }  
    public boolean isPartnerAdmin { get; private set; }
    public boolean isPermittedUser { get; private set; }
    public boolean hasError { get{ return (PageUtils.getErrorMessagesOnly().size() > 0); } }
    public List<contactWrapper> users { get; private set; }
    Public boolean temp{get;set;}   
    public final Integer DEFAULT_PAGE_SIZE = 20;
    public final string prChangeDescription = 'Bulk Nomination Changes: Incentives Portal = ';
    public string myRewardsValue {get;set;}
    public string rewardsRole {get;set;}
    
    
    public PartnerSelfServiceIncBulkNominateCtrlExt(){
        try{
        IncludesearchAssignRewardsVal ='';
            isPartnerAdmin = false;
            isPermittedUser = false;
            searchStatusVal = Label.Bulk_Nomination_All;
            pageSize = DEFAULT_PAGE_SIZE;
            
            loggedInUser = [SELECT Enable_Partner_Admin__c, UserType , Contact.AccountId, Contact.Account.Id, Contact.Title FROM User WHERE Id = :UserInfo.getUserId()];
            system.debug('user type-----------------------'+loggedInUser.Usertype);
            if((loggedInUser.Contact != null) && (loggedInUser.Contact.Account != null)) { 
                givenAccountId = loggedInUser.Contact.AccountId;
            }
            if(givenAccountId == null || givenAccountId.length() == 0){
                givenAccountId = PageUtils.get('accountId'); // 001Z000000FgTv5
            }
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: PartnerSelfServiceIncBulkNominateCtrlExt]');
            PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
        }
    }
    
    public PageReference doPageLoad(){
        try{
            if(givenAccountId == null || givenAccountId.length() == 0){ 
                PageUtils.addError('Invalid account Id.'); 
            }else{ 
                myRewardsValue = [Select Id, MyRewards_Enabled__c from Account Where Id =: givenAccountId].MyRewards_Enabled__c;
                
                if((loggedInUser.Contact != null) && (loggedInUser.Contact.Account != null)){
                    isPartnerAdmin = loggedInUser.Enable_Partner_Admin__c;
                }else{
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
                  system.debug('permitted user and partneradmin-----------------------------'+isPermittedUser  + isPartnerAdmin);
                if(!isPermittedUser && !isPartnerAdmin){                
                    PageUtils.addError(Label.access_denied); 
                }else{
                    defaultFilterCriteria = 'WHERE Contact.AccountId = \'' + givenAccountId + '\' AND IsActive = TRUE';
                    filterCriteria = defaultFilterCriteria;
                    
                    populateContactWrapper((List<User>)getUserStdSetController.getRecords());
                }
            } 
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: doPageLoad]');
            PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
        }
        return null;
    }
    
    public PageReference doSearch(){
        try{
            string newFilterString = '';
            newFilterString += (searchFirstNameVal != null && searchFirstNameVal.length() > 0) ? ' AND FirstName LIKE \'%' + searchFirstNameVal + '%\'' : '';
            newFilterString += (searchLastNameVal != null && searchLastNameVal.length() > 0) ? ' AND LastName LIKE \'%' + searchLastNameVal + '%\'' : '';    
            newFilterString += (searchJobTitleVal != null && searchJobTitleVal.length() > 0) ? ' AND Contact.Title LIKE \'%' + searchJobTitleVal + '%\'' : '';
            newFilterString += (null != IncludesearchAssignRewardsVal && IncludesearchAssignRewardsVal != '' && IncludesearchAssignRewardsVal .length() > 0) ? ' AND Contact.Assign_MyRewards_Role__c = :IncludesearchAssignRewardsVal ':'';
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

            if(newFilterString.length() > 0){
                filterCriteria = defaultFilterCriteria + newFilterString;
            }else{
                filterCriteria = defaultFilterCriteria;
            }
            getUserStdSetController = null;
            populateContactWrapper((List<User>)getUserStdSetController.getRecords());
            getUserStdSetController.setPageNumber(1);
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: doSearch]');
            PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
        }
        return null;
    }
        
    public PageReference goSelfServiceProfilePage(){
        Map<String,String> params = new Map<String,String>();
        params.put('retURL',Page.PartnerSelfServiceIncentiveBulkNominate.getUrl());
        params.put('cancelURL',Page.PartnerSelfServiceIncentiveBulkNominate.getUrl());
        params.put('userId',PageUtils.get('userId'));
        return standardRedirect(Page.PartnerSelfServiceMyProfile,params);
    }
    
    public PageReference goUserDetailsPage(){
        PageReference pf = new PageReference('/' + PageUtils.get('userId') + '?noredirect=1');
        return pf;
    }
    
    public List<SelectOption> getSearchIsEnabledOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        //options.add(new SelectOption(Label.Bulk_Nomination_All, Label.Bulk_Nomination_All)); 
        options.add(new SelectOption(Label.yes, Label.yes)); 
        options.add(new SelectOption(Label.no, Label.no)); 
        return options; 
    }
    public PageReference reset(){
       searchUserRewardsVal = null;
       searchAssignRewardsVal = null;
       searchLastNameVal = null;
       searchJobTitleVal = null;
       searchFirstNameVal =null;
       searchStatusVal = null;
       PageReference pg;
       AccountId = PageUtils.get('accountId');
       String url = URL.getSalesforceBaseUrl().toExternalForm();
       if(AccountId != null){
           pg = new Pagereference(url+'/apex/PartnerSelfServiceIncentiveBulkNominate?accountid='+AccountId);
       }else{
          pg = new Pagereference(url+'/apex/PartnerSelfServiceIncentiveBulkNominate');
       }
       return pg;
   }
   public List<SelectOption> getSearchIsEnabled() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(Label.yes, Label.yes)); 
        options.add(new SelectOption(Label.no, Label.no)); 
        return options; 
    }

    private ApexPages.StandardSetController getUserStdSetController {
        get{
            try{
                if(getUserStdSetController == null){    
                    string queryString = 'SELECT Enable_Partner_Admin__c, Enable_As_Partner_Lead_Super_User__c, Contact.Email_Opt_In__c, Contact.Title, ' + 
                                            'Name, Contact.Email, Contact.MobilePhone, Contact.Fax, Contact.Phone, Contact.MailingCountry, ' +
                                            'Contact.MailingPostalCode, Contact.MailingState, Contact.MailingCity, Contact.MailingStreet, ' +
                                            'Contact.Salutation, Contact.FirstName, Contact.LastName, ContactId, Contact.AccountId, Contact.Account.id, ' +
                                            'Contact.Account.name, Contact.Account.account_country_code__c, userrole.name, ' +
                                            'Contact.Account.ShippingStreet,Contact.Account.ShippingCity,Enable_Partner_Deal_Registration__c, Enable_Partner_Lead_Management__c,' +
                                            'Contact.Account.ShippingState,Contact.Account.ShippingPostalCode,FirstName,LastName, Contact.Is_Enabled_for_Incentives__c, ' +
                                            'Contact.Account.Phone,Contact.Account.Fax,Contact.Account.Is_Rebate_Partner__c, Contact.Is_Rebate_User__c,Contact.Assign_MyRewards_Role__c,Contact.Enable_User_for_MyRewards__c ' +
                                            'FROM User ' + filterCriteria + ' ORDER BY Name LIMIT 10000';
                                            system.debug('############### fenny | filterCriteria = ' + filterCriteria);
                                            
                    getUserStdSetController = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    getUserStdSetController.setPageSize(DEFAULT_PAGE_SIZE);
                    totalPageNumber = Integer.valueOf(Math.ceil((Double)getUserStdSetController.getResultSize()/pageSize));
                }
            }catch(Exception ex){
                throw ex;
            }
            return getUserStdSetController;
        }set;
    }
    
    private void populateContactWrapper(List<User> uList){
        try{
            if(users == null){
                users = new List<contactWrapper>();
            }else{
                users.clear();
            }
            
            for(User u : uList){ 
                users.add(new contactWrapper(u)); 
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    
    private Id getRecordTypeId(String recordTypeName){
        Id recordTypeId = IdLookupUtils.getRecordTypeId(recordTypeName, 'Partner_Request__c', true);
        System.assert(recordTypeId != null,'Record type \'' + recordTypeName + '\' not found.');
        return recordTypeId;
    }
        
    public void next() {
        try{
            getUserStdSetController.next();
            populateContactWrapper((List<User>)getUserStdSetController.getRecords());
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: next]');
            PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
        }
    }
     
    public void previous() {
        try{
            getUserStdSetController.previous();
            populateContactWrapper((List<User>)getUserStdSetController.getRecords());
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: previous]');
            PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
        }
    }
      
     public void first() {
        try{
            getUserStdSetController.first();
            populateContactWrapper((List<User>)getUserStdSetController.getRecords());
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: first]');
            PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
        }
    }
 
    public void last() {
        try{
            getUserStdSetController.last();
            populateContactWrapper((List<User>)getUserStdSetController.getRecords());
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: last]');
            PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
        }
    }
    
    public Boolean hasNext {
        get {
            try{
                hasNext =  getUserStdSetController.getHasNext();
            }catch(Exception ex){
                system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: hasNext]');
                PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
            }
            return hasNext;
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            try{
                hasPrevious = getUserStdSetController.getHasPrevious();
            }catch(Exception ex){
                system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: hasPrevious]');
                PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
            }
            return hasPrevious;
        }
        set;
    }
 
    public Integer pageNumber {
        get {
            try{
                pageNumber = getUserStdSetController.getPageNumber();
            }catch(Exception ex){
                system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: pageNumber]');
                PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
            }
            return pageNumber;
        }
        set;
    }
    
    public pagereference backreference(){
        AccountId = PageUtils.get('accountId');
        Pagereference pageref = new pagereference('/' +AccountId);
        return pageref;
        
    }
    
    public class contactWrapper{
        public Id userId { get; set; }
        public Id contactId { get; set; }
        public string Name { get; set; }
        public string Title { get; set; }
        public string isAdmin { get; set; }
        public boolean enabledIncentive { get; set; }
        public boolean enabledIncentiveInput { get; set; }
        public User portalUser { get; set; }
        public string rewardsRole { get;set; }
        public string rewardsRoleInput { get;set; }
        public boolean enableUserForMyRewards{ get;set; }
        public boolean enableUserForMyRewardsInput{ get;set; }

        public contactWrapper(User u){
            this.userId = u.Id;
            this.contactId = u.Contact.Id;
            this.Name = u.Name;
            this.Title = u.Contact.Title;
            this.isAdmin = u.Enable_Partner_Admin__c ? Label.yes : Label.no;
            this.enabledIncentive = u.Contact.Is_Enabled_for_Incentives__c;
            this.enabledIncentiveInput = u.Contact.Is_Enabled_for_Incentives__c;
            this.enableUserForMyRewards = u.Contact.Enable_User_for_MyRewards__c;
            this.enableUserForMyRewardsInput = u.Contact.Enable_User_for_MyRewards__c;
            this.rewardsRole = u.Contact.Assign_MyRewards_Role__c;
            this.rewardsRoleInput = u.Contact.Assign_MyRewards_Role__c;
            this.portalUser = u;
        }
    }
    
    public void updateMyRewardsCompanyStatus(){
        Account acc = new Account(Id=givenAccountId, MyRewards_Enabled__c=myRewardsValue);
        update acc;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Message.'));
    }
    
    public List<SelectOption> getMyRewardsOptions()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = Account.MyRewards_Enabled__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
       }       
       return options;
    }
           
   public List<SelectOption> getRewardRoles()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = contact.Assign_MyRewards_Role__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
    
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
       }       
       return options;
    }
    public List<SelectOption> getIncludeRewardRoles()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = contact.Assign_MyRewards_Role__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('', '')); 
    
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
       }       
       return options;
    }
   
    public void saveAction(){
        try{
            contact blankCon = new contact();
            list<contact> conToUpdate = new list<contact>();
            for(contactWrapper w : users){
                contact con = new contact();
                if(w.rewardsRoleInput != w.rewardsRole){
                    con.id = w.contactId;
                    con.Assign_MyRewards_Role__c = w.rewardsRoleInput;  
                /*    if(w.rewardsRoleInput == 'Unassigned'){
                        con.Enable_User_for_MyRewards__c = false;
                    }else{
                       con.Enable_User_for_MyRewards__c = true;
                    }
                     if( w.enableUserForMyRewardsInput == true){
                        con.Enable_User_for_MyRewards__c = w.enableUserForMyRewardsInput;

                     }*/
                }  
                if(w.enableUserForMyRewardsInput != w.enableUserForMyRewards){
                    con.id = w.contactId;
                    con.Enable_User_for_MyRewards__c = w.enableUserForMyRewardsInput;
                }  
                
               if(w.enabledIncentive != w.enabledIncentiveInput){
                    con.id = w.contactId;
                    con.Is_Enabled_for_Incentives__c = w.enabledIncentiveInput;
                }
                if(con != blankCon){
                    conToUpdate.add(con);
                }
            }          
            system.Debug('*****conToUpdate' +conToUpdate);
            update conToUpdate;
            integer currentPageNumber = pageNumber;
            getUserStdSetController = null;
            getUserStdSetController.setPageNumber(currentPageNumber);
            populateContactWrapper((List<User>)getUserStdSetController.getRecords()); 
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSelfServiceIncBulkNominateCtrlExt | Method: saveAction]');
            PageUtils.addError('Your request could not be handled at this time. Please try again later or contact your administrator for assistance. [PartnerSelfServiceIncBulkNominateCtrlExt (' + ex.getLineNumber() + '): ' + ex.getMessage() + ']');
        }
        
    }

}
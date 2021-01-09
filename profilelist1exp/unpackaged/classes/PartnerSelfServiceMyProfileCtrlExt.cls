/**
 * Controller logic for Self Service of Partner Users.  Handles both new and
 * edit requests from either a Partner Admin or a regular Partner User.
 *
 * There are three main use cases:
 * (1) Partner Admin is creating another user for the admin's Partner Account.
 * (2) Partner Admin is editing another user for the admin's Partner Account.
 * (3) Partner User is editing own profile.
 *
 * A Partner Admin is defined as a User having the Enable_Partner_Admin__c flag equal
 * to true on their User record.
 *
 * The end result of this screen is a Partner_Request__c record will be created with
 * a record type of either "New User" or "Update User".  The changes will not be applied
 * immediately.
 *
 * @author Richard Vanhook
 * @date 2/19/09
 * Revision Date            Modified By     Release No      CR Number - Description 
 *  1.0     18-Sep-2009     Raymond                         CR1790 - Added option to enable Rebate feature when requesting New User
 *  1.1     28-Sep-2009     Raymond                         CR1773 - Default PR's Enable Rebate flag base on Contact's Rebate Flag during Edit. Populate PR's Description if value of the flag is changed
 *  1.2     27-Oct-2009     Raymond                         Defect #52760 - Hide Enable Rebate flag from Admin when they are editing their own profile
 *  2.0     20-Feb-2010     Raymond                         CR2421 - Automate Update User operation by Partner Admin from Partner Portal
 *  2.1     05-Mar-2010     Raymond                         Updated logi to handle email change scenarios - CR2093
 *  2.2     14-Apr-2010     Raymond                         CR2571 - Update of Email will required user confirmation/acknowledgement
 *  3.0     21-Jun-2010     MenMee                          CR2087 - Automate Self Service New User Partner Request
 *  3.1     29-Jun-2010     MenMee                          CR2750 - Skip messaging for Update User from Self service portal
 *  4.0     23-Nov-2012     Sandhya                         CR 7824- Add Enable as Lead Super User
 *  4.1     24-Nov-2012     Ariff                           R14.2- Add Enable for Incentives
 *  4.2     15-Dec-2012     Sandhya                         CR 7823 - Rename field labels
 *  4.3     15-Jan-2013     Ariff                           R14.2 - Remove Account.IS country enabled for incentives reference and change it to Contact.Vendor Name
 *  4.4     10-Jan-2013     Fenny                           CR7944 - Permission set 'Partner_Opportunity_Access' assignment
 *  5.0     22-Apr-2013     Sandhya                         Defect #65618 fix
 *  6.0     24-Oct-2013     Meera                           15.3 CMAP Chnages
 *  7.0     12-May-2014     Devika                          15.07 Maintainance - CR 9365 - Make email field read only for edit mode.
 *  8.0     23-Dec-2014     Ragu                            16.03: CR10733 - Lead Management partner users should automatically be enabled for Training
 *  8.1     02-Jan-2015     Anamika                         16.03: CR 10742 - Allow the partner admin or partner company to indicate who receives the notices for “Leads are ready” and who doesn't.
 *  8.2     09-Dec-2015     Kishore                         16.10: CR 12430 - Added option to enable for bid builder, when requesting new users or existing users
 *  8.3     03-Jan-2018     Sneha                           CR 4477630 - Update the Link for changing the Email Address.
 *  9.1     07-June-2018    Michael         FY19-DCS-0802   CR 16007 Decommisioned netexam and Provisioned_in_Netexam_on__c as Part of Story# 4988554  
 *  9.2 -   07-june-2018   JatinPuri1       FY19-DCS-0802   CR16018  Decommisioned netexam and Feature_Request_Training__c as part of story# 4988542   
 *  10.0 -  06-Nov-2018    Yeswanth         FY19-DCS-0102   CR16759 Story 5768288: VTX: Display Access status to Partner user 
 */
 
public without sharing class PartnerSelfServiceMyProfileCtrlExt extends DellStandardController {

    //=============================================================
    //PAGE INPUT PARAMETERS
    //=============================================================
    public static final String HTTP_PARAMETER_RETURL    = 'retURL';
    public static final String HTTP_PARAMETER_CANCELURL = 'cancelURL';
    public static final String HTTP_PARAMETER_USERID    = 'userId';
    public static final String HTTP_PARAMETER_NEWFLAG   = 'newFlag';

    //=============================================================
    //ERROR CODES
    //=============================================================
    public String ACCESS_DENIED_STANDARD_LICENSE_USER   {get{return 'ACCESS_DENIED_STANDARD_LICENSE_USER';}}
    public String ACCESS_DENIED_PARTNER_USER_NOT_ADMIN  {get{return 'ACCESS_DENIED_PARTNER_USER_NOT_ADMIN';}}
    public String CRUD_ERROR                            {get{return 'CRUD_ERROR';}}
    public String errorCode                             {get;set;}

    private Partner_Request__c request;
    private User userToModify;
    private ApexPages.StandardController controller;
    public Country__c country {get;set;}
    public Boolean isSaved{get;set;}
    public Boolean isNewUser{get;set;}
    public Boolean editMode{get;set;}
    public Boolean isCurrentUserPartnerAdmin{get;set;}
    public Boolean isCurrentUserGroupAdmin{get;set;}
    public Boolean isCurrentUserTrackAdmin{get;set;}
    public Boolean isalowedLeadMAnagement{get;set;}
    Public Static Boolean StopAutomaticPrimaryContact = false;
    Public Boolean isbidbuilderpart {get; set;}
    //Added Bahar, Ariff 24th Nov 2012 14.2 SSO
    public Boolean visible_Incentive{get;set;}
    
    //20090918 Raymond: Added for CR1790. Flag to indicate if Rebate is enabled for Account
    public Boolean isAccountRebateEnabled{get;set;}

    public List<User> partnerAdminsForAccount{get;set;}

    //public String getPreferredLanguageCode(){ return PartnerUtils.getPreferredLanguageCode(); }
    public String retURL {get;set;}
    public String cancelURL {get;set;}
    public String strLabel {get;set;}
    public String preferredLanguageCode{ get{return PartnerUtils.getPreferredLanguageCode();}}
    public Boolean optInROE{get;set;}
    public Boolean optInApj{get;set;}

    //Added for defect #52760
    public Boolean isHiddenFromAdminSelf{get;set;}
    
    //Raymond 20100223 - added for CR2421
    private Contact contactToModify;
    public boolean isTest = false;
    public boolean isEmailChanged{get;set;}

    //Raymond 14-Apr-2010 - CR2571
    public boolean isConfirmEmailChange {get;set;}
    //private string emailChangedMessage = 'Changes in Email Address should be done in MyAccount. Check \"Confirm Email Change\" to confirm change (existing user will be deactivated). ';
    private string emailChangedMessage = System.Label.Email_Change_Should_be_done_in_MyAccount;

    private string emailInvalidChangedMessage = System.Label.invalid_email_address;

    public Country__c countryObj; // CR 9365
    public String contactEmail {get;set;}// CR 9365
    User userLoggedIn; //CR 9365
    public Boolean bTrainingAutoUpdateEnabled {get; set;} // CR 10733
    
    public boolean enableUserForMyRewards {get;set;}
    public string assignMyRewardsRole {get;set;}

    public PartnerSelfServiceMyProfileCtrlExt(ApexPages.StandardController controller) {
        //parter admin should be able to:
        //  create new users
        //  request changes to existing user in account
        //partner user should be able to:
        //  request changes to own user
        //super();
        
        //get http input param values
        final String userIdParam = PageUtils.param(HTTP_PARAMETER_USERID);
        final Boolean newFlagParam ='true'.equalsIgnoreCase(PageUtils.param(HTTP_PARAMETER_NEWFLAG));
        this.retURL = PageUtils.param(HTTP_PARAMETER_RETURL);
        this.cancelURL = PageUtils.param(HTTP_PARAMETER_CANCELURL);

        //initialize vars
        this.controller = controller;
        this.request = (Partner_Request__c) controller.getRecord();
        this.editMode = true;
        this.isSaved = false;
        this.isConfirmEmailChange = false;
        this.contactEmail = null; // CR 9365
  
        //get current user and check if not partner user
        userLoggedIn =  getUser(UserInfo.getUserId()); //getUser('00530000000mMJ9AAM');//
        isCurrentUserPartnerAdmin = userLoggedIn.Enable_Partner_Admin__c;
        //isCurrentUserGroupAdmin = userLoggedIn.Contact.Enable_as_Partner_Group_Administrator__c;   
        //Add by Bahar, Ariff (20121218) 14.2 SSO Project

        PartnerCountry pc = new PartnerCountry();
        Map<string, Country__c> countryMap = pc.returnCountryCodeMap();
        
        //Country__c countryObj; CR 9365
        
        if (StringUtils.isNotBlank(userLoggedIn.Contact.Account.Account_Country_Code__c)){
            countryObj= countryMap.get(StringUtils.uppercase((userLoggedIn.Contact.Account.Account_Country_Code__c).trim()));
        }


        if (countryObj!=null){
            //if (userLoggedIn.Contact.Account.Is_Enabled_for_Incentives__c && userLoggedIn.Contact.Account.Is_Country_Enabled__c){
            String  vendorName = countryObj.Inc_Vendor_Name__c;
            System.debug('Vendor Name:' + countryObj.Inc_Vendor_Name__c);
            if ((vendorName == 'Partner Direct Rewards Center') || (vendorName == 'Partner Advantage') ||  (vendorName == 'Dell Achievers')){
                if (userLoggedIn.Contact.Account.Is_Enabled_for_Incentives__c && (userLoggedIn.Contact.Account.Vendor_Update_Datetime__c != NULL)&&
                    (userLoggedIn.Contact.Account.Is_Incentive_Updated__c == false)){
                    visible_Incentive = true;
                }
                else{
                    visible_Incentive =false;
                }
            }
            else{
                visible_Incentive =false;
            }
        }
        else{
            visible_Incentive =false;
        }

        //20090918 Raymond: Added for CR1790. Flag to indicate if Rebate is enabled for Account
        isAccountRebateEnabled = userLoggedIn.Contact.Account.Is_Rebate_Partner__c;
        
        enableUserForMyRewards = userLoggedIn.Contact.Enable_User_for_MyRewards__c;       
        assignMyRewardsRole = userLoggedIn.Contact.Assign_MyRewards_Role__c;

        //added for defect #52760
        isHiddenFromAdminSelf = false;
        isEmailChanged = false;
        System.debug('userLoggedIn.userrole.name'+userLoggedIn.userrole.name);
        if(userLoggedIn.userrole == null || StringUtils.isBlank(userLoggedIn.userrole.name)
            || userLoggedIn.contact == null || userLoggedIn.contact.id == null) {
            // Basically this is a standard user license user
            errorCode = ACCESS_DENIED_STANDARD_LICENSE_USER;
            return;
        }
        request.Account__c = userLoggedIn.Contact.AccountId;

        if(StringUtils.isNotBlank(userLoggedIn.Contact.Account.Account_Country_Code__c)){
            try{
                //20090918 Raymond: CR1790 - Modified query to retrieve Rebate_Enabled__c
                //Meera:15.3 CMAP modification- Adding lead management related fields
                this.country =
                    [select id, Partner_Support_Queue_ID__c,Code__c,Bid_Builder_Enabled__c,Bid_Builder_Partner_Relationship__c,
                        Training_Enabled__c, Partner_Finder_Enabled__c, Deal_Registration_Enabled__c,
                        Rebate_Enabled__c,Lead_Management_Enabled__c,Lead_Management_Enabled_for_OEM__c,Partner_Relationship__c,
                        Partner_Relationship_for_OEM__c
                    from Country__c
                    where Code__c = :userLoggedIn.Contact.Account.Account_Country_Code__c
                    limit 1];
                request.Country__c = this.country.id;
                request.OwnerId = this.country.Partner_Support_Queue_ID__c;
            }
            catch(QueryException e){}
        }
        System.debug('userIdParam'+userIdParam);
        System.debug('newFlagParam'+newFlagParam);
        if(StringUtils.isBlank(userIdParam)){
            if(newFlagParam){
                //=====================================
                //ADMIN CREATING USER
                //=====================================
                //this is a net new record, only partner admins should be able to do this
                //set record type for request
                //make sure the user is a partner admin
                if(!isCurrentUserPartnerAdmin){
                    setErrorNotEnabledAsPartnerAdmin(request.Account__c);
                    return;
                }
                isNewUser = true;
                
                // v8.1
                this.request.Enable_notifications_about_Channel_Leads__c = true;
                /*this.request.Primary_Contact_Aligned__c = 'No'; //v9
                this.request.Create_Primary_Contact__c ='No';//v9
                System.debug('================= REQUEST =========: '+this.request);*/
                populateRequestFromAccount(request,userLoggedIn.Contact.Account);
            } 
            else {
                //=====================================
                //ADMIN OR NON-ADMIN EDITING SELF
                //=====================================
                //current user is modifying own profile (i.e. My Profile tab)
                isCurrentUserPartnerAdmin = false;
                isNewUser = false;
                editMode = false;
                updateContact();// CR 9365
                populateRequestFromUser(request,userLoggedIn);
                userToModify = userLoggedIn;
            }
        } 
        else {
            //=====================================
            //ADMIN EDITING ANOTHER USER
            //=====================================
            //existing record, only admins should be able to modify other users
            isNewUser = false;
            updateContact();//CR 9365
            try{
                userToModify = getUser(userIdParam);
            }
            catch(QueryException e){
                PageUtils.addError('User not found: ' + e.getMessage());
            }
            System.debug('userToModify == null: ' + (userToModify == null));
            if(userToModify == null){
                //something would really have to go wrong for this error to occurr
                PageUtils.addError('Record not found.');
                return;
            }

            //if current user is attempting to modify own user account, this is ok
            //if current user is attempting to modify another parnter user account, verify is admin and user to modify belongs
            //  to same account
            if(userToModify.id != userLoggedIn.id){
                if(!isCurrentUserPartnerAdmin){
                    setErrorNotEnabledAsPartnerAdmin(request.Account__c);
                    userToModify = null;
                    return;
                }

                //verify that current user isn't attempting to modify user outside of Partner account
                if(userToModify.contact.account.id != userLoggedIn.contact.account.id){
                    PageUtils.addError('Access Denied.');
                    userToModify = null;
                    return;
                }
            }

            //added for defect #52760
            if(isCurrentUserPartnerAdmin && userToModify.id == userLoggedIn.id) {
                isHiddenFromAdminSelf = true;
            }
             
             populateRequestFromUser(request,userToModify);

        }

        if(userToModify != null && userToModify.contactId != null)
        {
            contactToModify = getContact(userToModify.contactId);
        }

        isalowedLeadMAnagement = false;
         //Meera:15.3 CMAP Addition- Check whether this user can be permitted for lead management
            //for OEM Accounts
                
            if(userLoggedIn.Contact.Account.Sales_Channel__r != null && (userLoggedIn.Contact.Account.Sales_Channel__r.Name).contains('OEM') && this.country.Lead_Management_Enabled_for_OEM__c == 'Yes' && 
                    userLoggedIn.Contact.Account.Partner_Relationship__c != null &&(this.country.Partner_Relationship_for_OEM__c.contains(userLoggedIn.Contact.Account.Partner_Relationship__c) || this.country.Partner_Relationship_for_OEM__c.contains('All'))){
                        isalowedLeadMAnagement = true;
                }
            
            //for other Accounts
            
                else if(this.country.Lead_Management_Enabled__c == 'Yes' && userLoggedIn.Contact.Account.Partner_Relationship__c != null &&
                    (this.country.Partner_Relationship__c.contains(userLoggedIn.Contact.Account.Partner_Relationship__c) || this.country.Partner_Relationship__c.contains('All'))){
                        isalowedLeadMAnagement = true;
                }
            //}  
            
        System.debug('##isalowedLeadMAnagement:'+isalowedLeadMAnagement);
        
        //kishore
        isbidbuilderpart = false;
        if(this.country.Bid_Builder_Enabled__c != null && this.country.Bid_Builder_Enabled__c == 'Yes' && userLoggedIn.Contact.Account.Partner_Relationship__c != null &&
                (this.country.Bid_Builder_Partner_Relationship__c.contains(userLoggedIn.Contact.Account.Partner_Relationship__c))){
                    isbidbuilderpart = true;
        }
        // v8.0 - Start
        if(isCurrentUserPartnerAdmin && this.country != null && country.Training_Enabled__c == 'Yes') {
            bTrainingAutoUpdateEnabled = true;
        }
        else {
            bTrainingAutoUpdateEnabled = false;
        }
        // v8.0 - End
    }
    
    //Meera:15.3 Addition
    public pagereference showorHideLeadDetails(){
        System.debug('Enable_Partner_Deal_Registration__c:'+request.Feature_Request_Deal_Registration__c);
        System.debug('Enable_Partner_Lead_Management__c:'+request.Feature_Request_Lead_Management__c);
        System.debug('##isalowedLeadMAnagement:'+isalowedLeadMAnagement);
        if(request.Feature_Request_Deal_Registration__c == false){
            request.Feature_Request_Lead_Management__c = false;
        }
        if(request.Feature_Request_Lead_Management__c == false){
            request.Enable_as_Lead_Super_User__c = false;
        }
        return null;
    }

    public void setErrorNotEnabledAsPartnerAdmin(String accountId){
        errorCode = ACCESS_DENIED_PARTNER_USER_NOT_ADMIN;
        partnerAdminsForAccount = [
            select Contact.Title, Contact.Email, Contact.FirstName, Contact.LastName, ContactId,Contact.Enable_for_Bid_Builder__c
            from User where contact.accountid = :accountId and 
            (Enable_Partner_Admin__c = true 
            // OR Contact.Enable_as_Partner_Group_Administrator__c = true  
             )
          ];
    }

    private Id getRecordTypeId(String recordTypeName){
        Id recordTypeId = IdLookupUtils.getRecordTypeId(recordTypeName, 'Partner_Request__c', true);
        System.assert(recordTypeId != null,'Record type \'' + recordTypeName + '\' not found.');
        return recordTypeId;
    }

    private void populateRequestFromAccount(Partner_Request__c request, Account account){        
        request.RecordTypeId = getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER);
        String[] addressTokens = StringUtils.split(account.ShippingStreet,'\n');
        if(addressTokens == null){ addressTokens = new String[]{}; }

        request.Account__c          = account.id;
        request.Address_Line_1__c   = addressTokens.size() > 0 ? StringUtils.trim(addressTokens[0]) : '';
        request.Address_Line_2__c   = addressTokens.size() > 1 ? StringUtils.trim(addressTokens[1]) : '';
        request.Address_Line_3__c   = addressTokens.size() > 2 ? StringUtils.trim(addressTokens[2]) : '';
        request.City__c             = account.ShippingCity;
        request.State__c            = account.ShippingState;
        request.Postal_Code__c      = account.ShippingPostalCode;
        request.Phone__c            = account.Phone;
        request.Fax__c              = account.Fax;
    }

    private void populateRequestFromUser(Partner_Request__c request, User user){
        optInROE = false;
        optInApj = false;
        strLabel = null;
        request.RecordTypeId = getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER);
        String[] addressTokens = StringUtils.split(user.Contact.MailingStreet,'\n');
        if(addressTokens == null){ addressTokens = new String[]{}; }//x

        request.Salutation__c               = user.Contact.Salutation;
        request.First_Name__c               = user.Contact.FirstName;
        request.Last_Name__c                = user.Contact.LastName;
        request.Job_Title__c                = user.Contact.Title;
        request.Address_Line_1__c           = addressTokens.size() > 0 ? StringUtils.trim(addressTokens[0]) : ''; //x
        request.Address_Line_2__c           = addressTokens.size() > 1 ? StringUtils.trim(addressTokens[1]) : '';
        request.Address_Line_3__c           = addressTokens.size() > 2 ? StringUtils.trim(addressTokens[2]) : '';
        request.City__c                     = user.Contact.MailingCity;
        request.State__c                    = user.Contact.MailingState;
        request.Postal_Code__c              = user.Contact.MailingPostalCode;
        request.Phone__c                    = user.Contact.Phone;
        request.Mobile__c                   = user.Contact.MobilePhone;
        request.Fax__c                      = user.Contact.Fax;
        request.Email__c                    = user.Contact.Email;
        //request.Newsletter_Opt_In__c        = 'yes'.equalsIgnoreCase(user.Contact.Email_Opt_In__c);
        if(countryObj != null){
            if(countryObj.Code__c == 'ca') {                        
                 strLabel = Label.Newsletter_Confirmation; 
            }
            else if(countryObj.Code__c == 'de' || countryObj.Code__c == 'at' || countryObj.Code__c == 'ch'){
                strLabel = Label.Partner_Registration_01.replace('{!Country}',countryObj.Code__c).replace('{!lang}',preferredLanguageCode);
            }
            else if(countryObj.Region__c == 'Apj' || countryObj.Region__c == 'Latam'){
                strLabel = Label.Partner_Registration_APJ_02.replace('{!Country}',countryObj.Code__c).replace('{!lang}',preferredLanguageCode);
                optInApj = true;
            }
            else if(countryObj.Code__c == 'us') {                        
                strLabel = Label.Partner_Registration_US; 
            }
            else {                    
                strLabel = Label.receive_newsletter_02.replace('{!Country}',countryObj.Code__c).replace('{!lang}',preferredLanguageCode);
                optInROE = true;
            }                  
                  
            if(user.Contact.Email_Opt_In__c == 'yes'){            
                if(countryObj.Code__c == 'de' || countryObj.Code__c == 'at' || countryObj.Code__c == 'ch'){
                    request.Newsletter_Opt_In__c = true;
                }
                else{
                    request.Newsletter_Opt_In__c = false;
                }
            }
            else if(user.Contact.Email_Opt_In__c == 'No'){
                if(countryObj.Code__c == 'de' || countryObj.Code__c == 'at' || countryObj.Code__c == 'ch'){
                    request.Newsletter_Opt_In__c = false;
                }
                else{
                    request.Newsletter_Opt_In__c = true;
                }
            }
            else{
                request.Newsletter_Opt_In__c = false;
            }
        }
        request.Enable_As_Partner_Admin__c  = user.Enable_Partner_Admin__c;
        request.Enable_as_Lead_Super_User__c = user.Enable_As_Partner_Lead_Super_User__c; //CR 7824- Add Enable as Lead Super User

        //20090928 Raymond: CR1773, Added to default request.Feature_Request_Rebates__c flag
        request.Feature_Request_Rebates__c = user.Contact.Is_Rebate_User__c;

        //Raymond 20100223 - a bug where training and deal reg field changes is not tracked. Fixed in CR2421
        request.Feature_Request_Deal_Registration__c = user.Enable_Partner_Deal_Registration__c;

        //Bahar, Ariff (20121212)R14.2 - SSO Project
        request.Is_Enabled_for_Incentives__c = user.Contact.Is_Enabled_for_Incentives__c;
        
        //Meera:15.3 CMAP project
        request.Feature_Request_Lead_Management__c = user.Enable_Partner_Lead_Management__c;
        
        //v8.1
        request.Enable_notifications_about_Channel_Leads__c = user.Enable_notifications_about_Channel_Leads__c;
        //v8.2 CR 12430
        request.Enable_for_Bid_Builder__c = user.contact.Enable_for_Bid_Builder__c;
    }
   //20090918 Raymond: Modified query to retrieve Is_Rebate_Partner__c from Account and Is_Rebate_User__c from Contact
   //20131024 Meera: Modified query to include lead management flag
    private User getUser(String userId)
    {
        return
            [select id, Enable_Partner_Admin__c, Enable_As_Partner_Lead_Super_User__c, Contact.Email_Opt_In__c, Contact.Title, Contact.Email, Contact.MobilePhone, Contact.Fax, Contact.Phone,
                Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, Contact.MailingCity, Contact.MailingStreet,
                Contact.Salutation, Contact.FirstName, Contact.LastName,Contact.Enable_for_Bid_Builder__c,ContactId, Contact.AccountId, Contact.Account.id, Contact.Account.name,
                Contact.Account.account_country_code__c, userrole.name,
                Contact.Account.ShippingStreet,Contact.Account.ShippingCity,Enable_Partner_Deal_Registration__c,
                Contact.Account.ShippingState,Contact.Account.ShippingPostalCode,FirstName,LastName,
                Contact.Account.Phone,Contact.Account.Fax,Contact.Account.Is_Rebate_Partner__c, Contact.Is_Rebate_User__c, Contact.Is_Enabled_for_Incentives__c,
                Contact.Account.Is_Enabled_for_Incentives__c,Contact.Account.Vendor_Update_Datetime__c,Contact.Account.Is_Incentive_Updated__c, Contact.Primary_Contact__c,
                //Contact.Enable_as_Partner_Group_Administrator__c,
                Contact.Enable_User_for_MyRewards__c,toLabel(Contact.Assign_MyRewards_Role__c),
                Enable_Partner_Lead_Management__c,contact.Account.Partner_Relationship__c,contact.Account.Sales_Channel__r.name,
                Enable_notifications_about_Channel_Leads__c
            from user where id = :userId]; 
            // Defect# 65618 fix
            // CR 7824 Add Enable as Lead Super User -Added Enable_As_Partner_Lead_Super_User__c field to query
            // R14.2 - Add contact.Enable for Incentives, Account.Is Enabled for Incentives and Account. Is Country Enabled at query
            // v8.1 - Added Enable_notifications_about_Channel_Leads__c field to the above query
    }

    public PageReference doCancelNewUser(){
        System.debug('doCancelNewUser URL >> ' + Page.PartnerSelfServiceMyCompany.getUrl());
        return cancelUrlOr(Page.PartnerSelfServiceMyCompany.getUrl());
    }

    public PageReference doCancel(){
        return cancelUrlOr(Page.PartnerSelfServiceMyProfile.getUrl());
    }
    /*
    private boolean checkMissingFields() {
        if(StringUtils.isBlank(request.First_Name__c))      { request.First_Name__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Last_Name__c))       { request.Last_Name__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Job_Title__c))       { request.Job_Title__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Address_Line_1__c))  { request.Address_Line_1__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.City__c))            { request.City__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.State__c))           { request.State__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Postal_Code__c))     { request.Postal_Code__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Phone__c))           { request.Phone__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Email__c))           { request.Email__c.addError('You must enter a value'); }

        final String[] REQUIRED_FIELDS = new String[]{'First_Name__c','Last_Name__c','Job_Title__c',
                'Address_Line_1__c','City__c','State__c','Postal_Code__c','Phone__c','Email__c'};

        if(SObjectUtils.isAnyFieldBlank(request,REQUIRED_FIELDS)){
            return true;
        }

        return false;
    }
    */
    

  
    
    public PageReference doSave()
    {
        System.debug('Inside dosave');
        System.debug('SU:'+request.Enable_as_Lead_Super_User__c);
        System.debug('LM:'+request.Feature_Request_Lead_Management__c);
        /*
        if(StringUtils.isBlank(request.First_Name__c))      { request.First_Name__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Last_Name__c))       { request.Last_Name__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Job_Title__c))       { request.Job_Title__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Address_Line_1__c))  { request.Address_Line_1__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.City__c))            { request.City__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.State__c))           { request.State__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Postal_Code__c))     { request.Postal_Code__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Phone__c))           { request.Phone__c.addError('You must enter a value'); }
        if(StringUtils.isBlank(request.Email__c))           { request.Email__c.addError('You must enter a value'); }

        final String[] REQUIRED_FIELDS = new String[]{'First_Name__c','Last_Name__c','Job_Title__c',
                'Address_Line_1__c','City__c','State__c','Postal_Code__c','Phone__c','Email__c'};
        if(SObjectUtils.isAnyFieldBlank(request,REQUIRED_FIELDS)){
            return null;
        }
        */
        
        // v8.0 - Start
        /*if(!validateTrainingEnabled()) {
            return null;
        }*/
        // v8.0 - End

        //CR2087 - handle at VF page
        //if(checkMissingFields()) {return null;}

        populateChangeFlags();

        // CR 8196  : Validate the email is in the required Dell Format
        if(isConfirmEmailChange) {
            string newEmail = request.email__c;

            Pattern p = Pattern.compile('^([a-zA-Z0-9_\\-\\.\\\']+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,6}|[0-9]{1,3})(\\]?)');
            Matcher pm = p.matcher( newEmail );

            if(!pm.matches()){
                request.email__c.addError(emailInvalidChangedMessage);
                return null;
            }
        }

        //Raymond CR2571 - If email is changed and not acknowledge, prompt message
        if(isEmailChanged && !isConfirmEmailChange) {
            request.email__c.addError(emailChangedMessage);
            return null;
        }

        Savepoint sp = null;
        try
        {
            sp = Database.setSavepoint();
            request.Status__c = PartnerConstants.REG_STATUS_DRAFT;
            insert request;
        }catch(Exception e) { //x

            Database.rollback(sp); //x
            ApexPages.addMessages(e); //x
            return null; //x
        }

        //CR2087
        if (request.id !=null && isNewUser)
        {
            //StopAutomaticPrimaryContact = true;
            PageReference pageRef = new PageReference('/apex/PartnerRegistrationProvisionUser?id='+request.id); 
            return PageUtils.redirect(pageRef.getUrl());
        }
        //CRR2087-end

        //Ray 20101114 - Fix for NetExam sync to CMI issue
        List<Partner_Request__c> IncompletePRList = new List<Partner_Request__c>();
        system.debug('-----is New User-------------'+isNewUser);
        //raymond CR2421 - new user request will not be automated
        if(request.id != null && !isNewUser)
        {
            try
            {
                executeUserUpdate();
                if(!isTest && !isEmailChanged) {
                //Remove parameter toEnableTraining in below Method
                    synchronizeToCMIandNetExam(contactToModify.Id, request.Id);
                }
                else {
                    setIncompletForRequestWithReason(request,'User has updated the email address on Contact. Please reprovision the user and refer to Partner Request to set the appropriate application access.');

                    //Ray 20101114 - Fix for NetExam sync to CMI issue
                    IncompletePRList.add(request);
                }
            }
            catch (Exception e)
            {
                ApexPages.addMessages(e);
                setIncompletForRequestWithReason(request,'Error: Trying to call synchronizeToCMIandNetExam: ' + e.getMessage());
                //request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
                //request.Description__c += + ' \nError: ' + e.getMessage();

                //Ray 20101114 - Fix for NetExam sync to CMI issue
                IncompletePRList.add(request);
            }
        }


        //Raymond 20100223 - added for CR2421
        try
        {
            //Ray 20101114 - Fix for NetExam sync to CMI issue
            if(IncompletePRList.size() > 0) {
                update IncompletePRList;
            }
        }
        catch(Exception e)
        {

            ApexPages.addMessages(e);
            return null;
        }

        //isSaved = true;
        return null;

    }

    // Fenny [10 Jan 2013]: CR7944
    public PageReference doPermissionSetAssignment(){
        // v8.0 - Start
        // v8.0 - End
        
        try{
            List<PermissionSet> permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Partner_Opportunity_Access'];
            if((permSet != null) && (permSet.size() > 0)){
                if(userToModify.Enable_Partner_Deal_Registration__c){
                    List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userToModify.Id and PermissionSetId = :permSet[0].Id];
                    if((assignments == null) || (assignments.size() == 0)){
                        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId = userToModify.Id, PermissionSetId = permSet[0].Id);
                        insert assignment;
                    }
                }else{
                    List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userToModify.Id and PermissionSetId = :permSet[0].Id];
                    delete assignments;
                }
            }else{
                string err = 'A problem has occured: Permission set \'Partner_Opportunity_Access\' not found. User ID = ' + userToModify.Id;
                List<string> recipients = new List<string>{'SFDC-ApexDev@dell.com'};
                emailUtils.sendTextEmail(recipients, 'Permission set \'Partner_Opportunity_Access\' not found', err);
            }
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }

        return null;
    }

    private void populateChangeFlags(){
        system.debug('----------'+request+'-----------'+userToModify+'----------'+editMode);
        if(request == null || userToModify == null || editMode == false){
            return;
        }
        //15.03 CMAP Addition
        if(request.Feature_Request_Deal_Registration__c == false){
            request.Feature_Request_Lead_Management__c = false;
            request.Enable_as_Lead_Super_User__c = false;
        }
        if(request.Feature_Request_Lead_Management__c == false){
            request.Enable_as_Lead_Super_User__c = false;
        }
        //Raymond - reset to false for every check
        isEmailChanged = false;

        request.Contact__c = userToModify.ContactId;
        Map<String,String> changes = new Map<String,String>();
        if(userToModify.Contact.Salutation != request.Salutation__c){ changes.put('Salutation', request.Salutation__c); request.Salutation_CF__c = true;}
        if(userToModify.Contact.FirstName != request.First_Name__c){ changes.put('First Name', request.First_Name__c); request.First_Name_CF__c = true;}
        if(userToModify.Contact.LastName != request.Last_Name__c){ changes.put('Last Name', request.Last_Name__c); request.Last_Name_CF__c = true;}
        if(userToModify.Contact.Title != request.Job_Title__c){ changes.put('Job Title', request.Job_Title__c); request.Job_Title_CF__c = true;}
        String[] addressTokens = StringUtils.split(userToModify.Contact.MailingStreet,'\n');
        if(addressTokens == null){ addressTokens = new String[]{}; } //x
        System.debug('(addressTokens.size() <= 0 ? \'\' : addressTokens[0]) = [' + (addressTokens.size() <= 0 ? '' : addressTokens[0]) + ']');
        System.debug('request.Address_Line_1__c = [' + request.Address_Line_1__c + ']');
        if((addressTokens.size() <= 0 ? '' : StringUtils.trim(addressTokens[0])) != request.Address_Line_1__c){ changes.put('Address Line 1', request.Address_Line_1__c); request.Address_Line_1_CF__c = true;}
        if((addressTokens.size() <= 1 ? '' : StringUtils.trim(addressTokens[1])) != request.Address_Line_2__c){ changes.put('Address Line 2', request.Address_Line_2__c); request.Address_Line_2_CF__c = true;} //x
        if((addressTokens.size() <= 2 ? '' : StringUtils.trim(addressTokens[2])) != request.Address_Line_3__c){ changes.put('Address Line 3', request.Address_Line_3__c); request.Address_Line_3_CF__c = true;} //x
        if(userToModify.Contact.MailingCity != request.City__c){ changes.put('City', request.City__c); request.City_CF__c = true;}
        if(userToModify.Contact.MailingState != request.State__c){ changes.put('State', request.State__c); request.State_CF__c = true;}
        if(userToModify.Contact.MailingPostalCode != request.Postal_Code__c){ changes.put('Postal Code', request.Postal_Code__c); request.Postal_Code_CF__c = true;}
        if(userToModify.Contact.Phone != request.Phone__c){ changes.put('Phone', request.Phone__c); request.Phone_CF__c = true;}
        if(userToModify.Contact.MobilePhone != request.Mobile__c){ changes.put('Mobile', request.Mobile__c); request.Mobile_CF__c = true;}
        if(userToModify.Contact.Fax != request.Fax__c){ changes.put('Fax', request.Fax__c); request.Fax_CF__c = true;}
        if(userToModify.Contact.Email != request.Email__c){
            changes.put('Email', request.Email__c);
            request.Email_CF__c = true;
            if(!isNewUser) {
                isEmailChanged = true;
            }
        }
        if('yes'.equalsIgnoreCase(userToModify.Contact.Email_Opt_In__c) != request.Newsletter_Opt_In__c){ changes.put('Newsletter Opt-In', (request.Newsletter_Opt_In__c ? 'Checked' : 'Unchecked')); request.Newsletter_Opt_In_CF__c = true;} //x
        if(userToModify.Enable_Partner_Admin__c != request.Enable_As_Partner_Admin__c){ changes.put('Enable As Partner Admin', (request.Enable_As_Partner_Admin__c ? 'Checked' : 'Unchecked')); request.Enable_As_Partner_Admin_CF__c = true;} //x
        //CR 7824 - Add Enable Lead Super User
        if(userToModify.Enable_As_Partner_Lead_Super_User__c != request.Enable_as_Lead_Super_User__c){ changes.put('Enable As Lead Super User', (request.Enable_as_Lead_Super_User__c? 'Checked' : 'Unchecked')); }

        // ***change flag is not there in request**
        //CR 7823 - Rename field labels
        //Meera - 15.3 CMAP changeback label
        if(userToModify.Enable_Partner_Deal_Registration__c != request.Feature_Request_Deal_Registration__c){ changes.put('Enable Deal Registration', (request.Feature_Request_Deal_Registration__c ? 'Checked' : 'Unchecked')); /*request.Feature_Request_Deal_Registration__c__c = true;*/} //x
        if(userToModify.Enable_Partner_Lead_Management__c != request.Feature_Request_Lead_Management__c){ changes.put('Enable Lead Management', (request.Feature_Request_Lead_Management__c ? 'Checked' : 'Unchecked')); /*request.Feature_Request_Deal_Registration__c__c = true;*/} //x
 
        
        //v8.2 CR 12430
        if(userToModify.Contact.Enable_for_Bid_Builder__c != request.Enable_for_Bid_Builder__c) { changes.put('Enable Bid Builder', (request.Enable_for_Bid_Builder__c ? 'Checked' : 'Unchecked'));
            //request.Enable_for_Bid_Builder_CF__c = true;
        }
        
        //20090928 Raymond: CR1773, Added to add changes of Rebate flag to description
        if(userToModify.Contact.Is_Rebate_User__c != request.Feature_Request_Rebates__c) { changes.put('Enable Rebates',(request.Feature_Request_Rebates__c ? 'Checked' : 'Unchecked'));request.Feature_Request_Rebates_CF__c  = true;}

        //Added by Bahar, Ariff R14.2 SSO Project
        if(userToModify.Contact.Is_Enabled_for_Incentives__c!= request.Is_Enabled_for_Incentives__c){ changes.put('Enable For Incentives', (request.Is_Enabled_for_Incentives__c? 'Checked' : 'Unchecked')); request.Is_Enabled_for_Incentives_CF__c  = true; }
        
        // v8.1
        if(userToModify.Enable_notifications_about_Channel_Leads__c != request.Enable_notifications_about_Channel_Leads__c) { 
            changes.put('Enable notifications about Channel Leads', (request.Enable_notifications_about_Channel_Leads__c ? 'Checked' : 'Unchecked'));
            request.Enable_notifications_about_Chnl_Leads_CF__c = true;
        }

        if(!changes.isEmpty()){
            request.Description__c = 'Changes:  ';
            Boolean isFirst = true;
            for(String key : changes.keySet()){
                if(isFirst){
                    isFirst = false;
                } else {
                    request.Description__c += '; ';
                }
                request.Description__c += key + ' = \'' + changes.get(key) + '\'\n';
            }
        }
    }

    public PageReference doOK(){
      

        return returnUrlOr(Page.PartnerSelfServiceMyProfile.getUrl());
    }

    public PageReference doEdit(){
        editMode = true;        
        updateContact();// CR 9365
        return null;
    }
    
    /************ CR 9365 ************************/
    public void updateContact(){
     contactEmail = '';
     system.debug('*****'+contactEmail);
     if(countryObj != null && userLoggedIn.Contact.Email != null){
          contactEmail = System.Label.CaseManagementPortalLink;
          /* Commenting the Code based on CR 4477630
          if(countryObj.Code__c == 'US' || countryObj.Code__c == 'CA'){
            contactEmail = 'us_partnerdirect@dell.com';
          }else{
            contactEmail =  countryObj.Partner_Support_Email__c; 
          } 
          if(contactEmail == null){        
            if (countryObj.Region__c !=  null){
              if(countryObj.Region__c == 'APJ'){
                Map<String,RegionDefaultEmailIds__c> apjEmailMap = new Map<String,RegionDefaultEmailIds__c>();
                for(RegionDefaultEmailIds__c regionEmails :[Select Name,EmailId__c from RegionDefaultEmailIds__c where Name LIKE
                                                                   'APJ%']){
                  apjEmailMap.put(regionEmails.Name,regionEmails);
                }
                system.debug('***'+apjEmailMap );
                for(String APJ :apjEmailMap.keySet()){
                  if(APJ.contains(countryObj.Code__c.toUpperCase())){
                    contactEmail = apjEmailMap.get(APJ).EmailId__c;                
                  }
                }
                if(contactEmail == null){
                  contactEmail = apjEmailMap.get('APJ-Others').EmailId__c;                                
                }                                                   
              }else{
                Map<String,RegionDefaultEmailIds__c> defaultEmailMap = RegionDefaultEmailIds__c.getAll();
                if(defaultEmailMap.containsKey(countryObj.Region__c)){
                  contactEmail = defaultEmailMap.get(countryObj.Region__c).EmailId__c;
                }else{
                  contactEmail = 'us_partnerdirect@dell.com';               
                }
              } 
            }else{
              contactEmail = 'us_partnerdirect@dell.com';            
            }              
          }*/                          
        }
      }  
              
    /*************CR 9365 Ends **************/
     
    /*private static Id getPartnerSupportQueue(String countryCode){
        if(StringUtils.isBlank(countryCode)){
            return null;
        }
        List<Country__c> countryList = [
            select Partner_Support_Queue_ID__c
            from Country__c
            where Code__c = :countryCode];
        if(countryList.isEmpty()){
            return null;
        }
        return countryList.get(0).Partner_Support_Queue_ID__c;
    }*/

    /*public PageReference returnUrl(){
        return redirect(null,retURL);
    }*/

    public PageReference returnUrlOr(String secondaryURL){
        return redirect(retURL, secondaryURL);
    }

    /*public PageReference cancelUrl(){
        return redirect(null,cancelURL);
    }*/

    public PageReference cancelUrlOr(String secondaryURL){
        return redirect(cancelURL, secondaryURL);
    }

    private static PageReference redirect(String primary, String backup){
        PageReference pageRef = null;
        if(primary != null && primary.length()!=0){
            pageRef = new PageReference(primary); //x
        }
        if(pageRef == null && backup != null && backup.length()!=0){
            pageRef = new PageReference(backup);
        }
        return PageUtils.redirect(pageRef.getUrl());
        //return standardRedirect(pageRef);
    }


    //raymond CR2421
    private void executeUserUpdate(){
        if(request == null || userToModify == null || editMode == false){
            return;
        }

        //Raymond 20100305 - This has to come first before other changes check so that the isEmailChanged flag
        //                   can be set before hand. CR2093 will reset MyAccountGUID to blank if email is changed, which
        //                   will cause the integration to CMI to fail (no account guid). This flag will prevent the
        //                   integration from happening
        if(contactToModify.Email != request.Email__c){
            contactToModify.Email = request.Email__c;
            //isEmailChanged = true;
        }

        if(contactToModify.Salutation != request.Salutation__c){
            contactToModify.Salutation = request.Salutation__c;
        }

        if(contactToModify.FirstName != request.First_Name__c){
            contactToModify.FirstName = request.First_Name__c;
        }

        if(contactToModify.LastName != request.Last_Name__c){
            contactToModify.LastName = request.Last_Name__c;
        }

        if(contactToModify.Title != request.Job_Title__c){
            contactToModify.Title = request.Job_Title__c;
        }

        String newAddress = request.Address_Line_1__c + '\n' + request.Address_Line_2__c + '\n' + request.Address_Line_3__c;
        if(contactToModify.MailingStreet != newAddress){
            contactToModify.MailingStreet = newAddress;
        }

        if(contactToModify.MailingCity != request.City__c){
            contactToModify.MailingCity = request.City__c;
        }

        if(contactToModify.MailingState != request.State__c){
            contactToModify.MailingState = request.State__c;
        }

        if(contactToModify.MailingPostalCode != request.Postal_Code__c){
            contactToModify.MailingPostalCode = request.Postal_Code__c;
        }

        if(contactToModify.Phone != request.Phone__c){
            contactToModify.Phone = request.Phone__c;
        }

        if(contactToModify.MobilePhone != request.Mobile__c){
            contactToModify.MobilePhone = request.Mobile__c;
        }

        if(contactToModify.Fax != request.Fax__c)
        {
            contactToModify.Fax = request.Fax__c;
        }

        if('yes'.equalsIgnoreCase(contactToModify.Email_Opt_In__c) != request.Newsletter_Opt_In__c || 'yes'.equalsIgnoreCase(contactToModify.Email_Opt_In__c) == request.Newsletter_Opt_In__c)
        {
            if(countryObj.Code__c == 'de' || countryObj.Code__c == 'at' || countryObj.Code__c == 'ch'){
                if(request.Newsletter_Opt_In__c) {
                    contactToModify.Email_Opt_In__c = 'Yes';
                }
                else {
                    contactToModify.Email_Opt_In__c = 'No';
                }
            }
            else{
                if(request.Newsletter_Opt_In__c) {
                    contactToModify.Email_Opt_In__c = 'No';
                }
                else {
                    contactToModify.Email_Opt_In__c = 'Yes';
                }
            }
        }

        //[Krishna 19-Mar-2010]Added the names update on the user. Fix for defect #52584
        if(userToModify.FirstName != contactToModify.FirstName)
        {
            userToModify.FirstName = contactToModify.FirstName;
        }

        if(userToModify.LastName != contactToModify.LastName)
        {
            userToModify.LastName = contactToModify.LastName;
        }

        //Raymond 20100503 - prevent update if email is changed
        if(!isEmailChanged && userToModify.Enable_Partner_Admin__c != request.Enable_As_Partner_Admin__c){
            userToModify.Enable_Partner_Admin__c = request.Enable_As_Partner_Admin__c;
        }

        //Raymond 20100223 - a bug where training and deal reg field changes is not tracked. Fixed in CR2421
        //Raymond 20100503 - prevent update if email is changed
        if(!isEmailChanged && userToModify.Enable_Partner_Deal_Registration__c != request.Feature_Request_Deal_Registration__c){
            userToModify.Enable_Partner_Deal_Registration__c = request.Feature_Request_Deal_Registration__c;
        }
        //Meera: 15.3 CMAP Addition
        if(!isEmailChanged && userToModify.Enable_Partner_Lead_Management__c != request.Feature_Request_Lead_Management__c){
            userToModify.Enable_Partner_Lead_Management__c = request.Feature_Request_Lead_Management__c;
        }
        //CR 7824 - Add Enable as Lead Super User
        if(userToModify.Enable_As_Partner_Lead_Super_User__c!= request.Enable_as_Lead_Super_User__c){
            userToModify.Enable_As_Partner_Lead_Super_User__c = request.Enable_as_Lead_Super_User__c;
        }

        //Bahar,Ariff (20121212 )R14.2 - SSO Project
        if(contactToModify.Is_Enabled_for_Incentives__c != request.Is_Enabled_for_Incentives__c ){
            contactToModify.Is_Enabled_for_Incentives__c = request.Is_Enabled_for_Incentives__c;
        }
        
        //v8.2 CR 12430
        if(contactToModify.Enable_for_Bid_Builder__c != request.Enable_for_Bid_Builder__c ){
            contactToModify.Enable_for_Bid_Builder__c = request.Enable_for_Bid_Builder__c;
        }
        
        //20090928 Raymond: CR1773, Added to add changes of Rebate flag to description
        //Raymond 20100503 - prevent update if email is changed
        if(!isEmailChanged && contactToModify.Is_Rebate_User__c != request.Feature_Request_Rebates__c) {
            contactToModify.Is_Rebate_User__c = request.Feature_Request_Rebates__c;
        }

        //Raymond 20100223 - a bug where training and deal reg field changes is not tracked. Fixed in CR2421
        //Raymond 20100503 - prevent update if email is changed. When training is disabled, the Provisioned_in_netexam_on
        //                   field will still be updated to null.
        
        // v8.1
        if(userToModify.Enable_notifications_about_Channel_Leads__c != request.Enable_notifications_about_Channel_Leads__c) {
            userToModify.Enable_notifications_about_Channel_Leads__c = request.Enable_notifications_about_Channel_Leads__c;
        }

        //Raymond 20100225: Temporary disable CMI integration, CR2421
        GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = true;

        update userToModify;

        update contactToModify;

        GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = false;
    }

    //raymond CR2421
    //Added by Bahar, Ariff (20121212) Is_Enabled_for_Incentives__c as part of the query.
    //Meera: 15.3 CMAP Changes :added lead management related fields in query
    private Contact getContact(String contactId){
        return
            [select id, Email_Opt_In__c, Title, Email, MobilePhone, Fax, Phone,
                MailingCountry, MailingPostalCode, MailingState, MailingCity, MailingStreet,
                Salutation, FirstName, LastName,Enable_for_Bid_Builder__c, AccountId, Account.id, Account.name,
                Account.account_country_code__c,
                Account.ShippingStreet,Account.ShippingCity,
                Account.ShippingState,Account.ShippingPostalCode,
                Account.Phone,Account.Fax,Account.Is_Rebate_Partner__c, Is_Rebate_User__c, Is_Enabled_for_Incentives__c,
                Account.Partner_Relationship__c,Account.Sales_Channel__r.name
            from Contact where id = :contactId];
    }

    public String getRequestId() {
        return request.id;
    }

    public static void setIncompletForRequestWithReason(Partner_Request__c request, String Reason){
        request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
        if(request.Description__c == null) {
            request.Description__c += Reason;
        }
        else {
            request.Description__c += ' \n\n' + Reason;
        }

    }

    //raymond 2421
    @future (callout=true)
    //Remove boolean enableTraining Method in the below Method
    public static void synchronizeToCMIandNetExam(String contactId, String requestId) {
        Partner_Request__c request;
        //Contact targetContact;

        //Boolean isNetExamSuccess = false;
        Boolean isCMISuccess = false;

        try {
            /*
            request = [SELECT Id, Status__c,Enable_for_Bid_Builder__c,Description__c FROM Partner_Request__c WHERE Id = :requestId];

            //initialize the status to 'Complete'
            request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;

            //start pushing to net exam
            if(enableTraining) {
                targetContact = [SELECT Id, Partner_My_Account_GUID__c,Enable_for_Bid_Builder__c
                                            FROM Contact WHERE Id=:contactId];

                //first pushing  the netexam, so that the PP integration contains the training data as well.


                try{

                    List<String> messages = NetExamConnector.sendContactWithAccount(
                                            targetContact.id,
                                            targetContact.Partner_My_Account_GUID__c + '@partner.dell.com');



                    //List<String> messages = null;
                    System.debug('#### NetExam Response : '+ messages);
                    if(messages == null || messages.size()==0){ //if success
                        isNetExamSuccess = true;

                        try {

                                //Else Calling @future inside @future. Needs to impliment in Contact Trigger.
                                GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = true;
                                update targetContact;
                                GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = false;

                        }
                        catch(Exception e) {
                            setIncompletForRequestWithReason(request,'Failed to update \'Provisioned in NextExam on\' field.' + e.getMessage());

                        }

                    } else { //if failed
                        setIncompletForRequestWithReason(request,'Integration with NetExam failed. Please contact your System Administrator. ' + messages);
                    }
                }catch(Exception e) {
                    setIncompletForRequestWithReason(request,'Integration with NetExam failed.' + e.getMessage());
                    System.debug('#### Integration with NetExam failed: ' + e.getMessage());
                }
            }
            //end pushing to net exam
           */

            try{

                request = [SELECT Id, Status__c,Enable_for_Bid_Builder__c,Description__c FROM Partner_Request__c WHERE Id = :requestId];
                Contact contactObj = [Select Is_Incentives_Updated__c,Enable_for_Bid_Builder__c from contact where id =:contactId ];

                system.debug('Request Status (1): ' + request.Status__c);
                system.debug('Request Status ID: ' + requestId);
                system.debug('Contact ID: ' + contactId  );
                system.debug('Is Incentives Updated: '  +contactObj.Is_Incentives_Updated__c );

                //ray - 20101114 fix NetExam update to CMI issue. If status is incomplete, do not update to complete
                //Ariff - 20130122 add extra condition for udpate. If incentive is update is equal to true, do not update PR status
                if( request.Status__c != PartnerConstants.REG_STATUS_INCOMPLETE && !(contactObj.Is_Incentives_Updated__c)) {
                //initialize the status to 'Complete'
                    request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;
                }
                system.debug('Request Status (2): ' + request.Status__c);

                //sends the Contact data to Partner profile
                String response = PartnerProfileIntegration.integratePartnerDataWithResponse(contactId);

                if(response != null && !response.contains(GlobalVariables.CMI_RESPONSE_SUCCESSFUL)) { //if Failed.
                    setIncompletForRequestWithReason(request,'Integration with CMI failed. Please contact your System Administrator.');
                }
            }
            catch(Exception e) {
                setIncompletForRequestWithReason(request,'Integration with CMI failed. ' + e.getMessage());
                System.debug('#### Integration with CMI failed : ' + e.getMessage());
            }

            //updating the request.
            update request;

        }
        catch(Exception e) {
            system.debug('## Caught APEX exception: while updating Partner Request ' + e.getMessage());
            //emailUtils.sendSupportEmail('PartnerSelfServiceAutoUpdateUserError: while updating Partner Request ' + request.Id + ': ' + e.getMessage(), dellConfig.errorEmail);
        }
    }

    
    public void synchronizeToCMIandNetExamForTest() {
        synchronizeToCMIandNetExam(contactToModify.Id, request.Id);
    }
}
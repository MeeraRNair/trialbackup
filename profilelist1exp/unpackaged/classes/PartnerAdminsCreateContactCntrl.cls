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
* The end intresult of this screen is a Partner_Request__c record will be created with
* a record type of either "New User" or "Update User".  The mapchanges will not be applied
* immediately.
*
* 
*/

public without sharing class PartnerAdminsCreateContactCntrl extends DellStandardController {
    
    //=============================================================
    //PAGE INPUT PARAMETERS
    //=============================================================
    public static final String HTTP_PARAMETER_RETURL    = 'retURL';
    public static final String HTTP_PARAMETER_CANCELURL = 'strcancelURL';
    public static final String HTTP_PARAMETER_USERID    = 'userId';
    public static final String HTTP_PARAMETER_NEWFLAG   = 'newFlag';
    
    //=============================================================
    //ERROR CODES
    //=============================================================
    public String straccessdeniedstandardlicenseuser   {get{return 'ACCESS_DENIED_STANDARD_LICENSE_USER';}}
    public String straccessdeniedpartnerusernotadmin  {get{return 'ACCESS_DENIED_PARTNER_USER_NOT_ADMIN';}}
    public String strcruderror                            {get{return 'CRUD_ERROR';}}
    public String strerrorCode                             {get;set;}
    
    public Partner_Request__c request{get;set;}
    private User userToModify;
    private ApexPages.StandardController controller;
    public Country__c country {get;set;}
    public Boolean bisSaved{get;set;}
    public Boolean bisNewUser{get;set;}
    public Boolean beditMode{get;set;}
    public Boolean botherCategory{get;set;}
    //public Boolean bisCurrentUserTrackAdmin{get;set;}
    public Boolean bisCurrentUserGroupAdmin{get;set;}
    public Boolean bisCurrentUserTrackAdmin{get;set;}
    public Boolean bisalowedLeadMAnagement{get;set;}
    public Boolean bisalowedleadSuperUserValue{get;set;}
    Public Static Boolean bstopAutomaticPrimaryContact = false;
    Public List<User> listpartnerAdminsForAccount{get;set;}
    
    //public String getPreferredLanguageCode(){ return PartnerUtils.getPreferredLanguageCode(); }
    public String strretURL {get;set;}
    public String strcancelURL {get;set;}
    public String strLabel {get;set;}
    public String strpreferredLanguageCode{ get{return PartnerUtils.getPreferredLanguageCode();}}
    public Boolean boptInROE{get;set;}
    public Boolean boptInApj{get;set;}
    
    //Added for defect #52760
    public Boolean bisHiddenFromAdminSelf{get;set;}
    
    //Raymond 20100223 - added for CR2421
    private Contact contactToModify;
    public boolean bisTest = false;
    public boolean bisEmailChanged{get;set;}
    
    //Raymond 14-Apr-2010 - CR2571
    public boolean bisConfirmEmailChange {get;set;}
    //private string stremailChangedMessage = 'mapchanges in Email Address should be done in MyAccount. Check \"Confirm Email Change\" to confirm change (existing user will be deactivated). ';
    private string stremailChangedMessage = System.Label.Email_Change_Should_be_done_in_MyAccount;
    
    private string stremailInvalidChangedMessage = System.Label.invalid_email_address;
    
    public Country__c countryObj; // CR 9365
    public String strcontactEmail {get;set;}// CR 9365
    User userLoggedIn; //CR 9365
    //public List<String> lst_EligibleTracks {get; set;}
    
    // Multi Select picklist Display
    Public List<string> listleftselected{get;set;}
    Public List<string> listrightselected{get;set;}
    Set<string> setleftvalues = new Set<string>();
    Set<string> setrightvalues = new Set<string>();
    Set<string> setsetleftValuesBackup = new Set<string>();
    
    //For Email Validation
    public String strenteredEmail{get;set;}
    
    Public String strlocationOfUser{get;set;}
    
    Public string strcountryName {get;set;}
    
    //For EditMyProfile check(5868178)
    public boolean bpartnerUserEditingOwnProfile{get;set;}
    
    // For disabling Multiselect Picklist
    public boolean bdisablePickListForGroupAdmin{get;set;}    
    
    // To display other job category field on vf page
    public String strjobCategory {get;set;}
    
    public string strJobCatValue{get;set;}
    // To capture case record Id
    public String strCaseRecordTypeId{get;set;}
    
    
    public PartnerAdminsCreateContactCntrl(ApexPages.StandardController controller) {
        
        system.debug('======== controller=='+controller);
        strlocationOfUser = '';
        strcountryName ='';
        botherCategory=false;
        //get http input param values
        final String userIdParam = PageUtils.param(HTTP_PARAMETER_USERID);
        final Boolean newFlagParam ='true'.equalsIgnoreCase(PageUtils.param(HTTP_PARAMETER_NEWFLAG));
        this.strretURL = PageUtils.param(HTTP_PARAMETER_RETURL);
        this.strcancelURL = PageUtils.param(HTTP_PARAMETER_CANCELURL);
        
        //initialize vars
        this.controller = controller;
        this.request = (Partner_Request__c) controller.getRecord();
        this.beditMode = true;
        this.bisSaved = false;
        this.bpartnerUserEditingOwnProfile = false;
        this.bisConfirmEmailChange = false;
        this.strcontactEmail = null; // CR 9365
        listleftselected = new List<String>();
        listrightselected = new List<String>();
        //get current user and check if not partner user
        userLoggedIn =  getUser(UserInfo.getUserId());
        bisCurrentUserTrackAdmin = userLoggedIn.Enable_Partner_Admin__c;
        bisCurrentUserGroupAdmin = userLoggedIn.Enable_as_Partner_Group_Administrator__c; 
        strCaseRecordTypeId = String.valueOf(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.OnBoarding).getRecordTypeId());
        System.debug('strCaseRecordTypeId'+strCaseRecordTypeId);
        System.debug('userLoggedIn.userrole.name'+userLoggedIn.userrole.name);
        if(userLoggedIn.userrole == null || StringUtils.isBlank(userLoggedIn.userrole.name)
           || userLoggedIn.contact == null || userLoggedIn.contact.id == null) {
               
               strerrorCode= straccessdeniedstandardlicenseuser   ; //ACCESS_DENIED_STANDARD_LICENSE_USER;
               return;
           }
        request.Account__c = userLoggedIn.Contact.AccountId;
        request.Website__c = userLoggedIn.Contact.Account.Website;
        System.debug('request.Website__c'+request.Website__c);
        bisHiddenFromAdminSelf = false;
        bisEmailChanged = false;
        
        System.debug('userIdParam'+userIdParam);
        System.debug('newFlagParam'+newFlagParam);
        System.debug('bisCurrentUserTrackAdmin'+bisCurrentUserTrackAdmin);
        System.debug('bisCurrentUserGroupAdmin'+bisCurrentUserGroupAdmin);
        System.debug('beditMode'+beditMode);
        
        //Meera:15.3 CMAP Addition- Check whether this user can be permitted for lead management
        //for OEM Accounts
        if(StringUtils.isNotBlank(userLoggedIn.Contact.Selected_Track__r.Country_Code__c)){
            try{
                this.country =
                    [select id,Name,Partner_Support_Queue_ID__c,Code__c,Bid_Builder_Enabled__c,Bid_Builder_Partner_Relationship__c,
                     Training_Enabled__c, Partner_Finder_Enabled__c, Deal_Registration_Enabled__c,Region__c,
                     Rebate_Enabled__c,Lead_Management_Enabled__c,Lead_Management_Enabled_for_OEM__c,Partner_Relationship__c,
                     Partner_Relationship_for_OEM__c
                     from Country__c
                     where Code__c = :userLoggedIn.Contact.Selected_Track__r.Country_Code__c
                     limit 1];
                request.Country__c = this.country.id;
                request.OwnerId = this.country.Partner_Support_Queue_ID__c;
                countryObj = this.country;
            }
            catch(QueryException e){}
        }
        
        if(StringUtils.isBlank(userIdParam)){
            if(newFlagParam){
                //=====================================
                //ADMIN CREATING USER
                //=====================================
                //this is a net new record, only partner admins should be able to do this
                //set record type for request
                //make sure the user is a partner track admin or group admin
                if(!bisCurrentUserTrackAdmin && !bisCurrentUserGroupAdmin){
                    setErrorNotEnabledAsPartnerAdmin(request.Account__c);
                    return;
                }
                bisNewUser = true;
                populateRequestFromAccount(request,userLoggedIn.Contact.Account);
                request.OSC_Create_Quote__c = true;
                request.OSC_Create_Order__c = true;
                request.OSC_Specialty_Product_Create_Quote__c= true;
                request.OSC_Specialty_Product_Create_Order__c= true;
            } 
            else {
                //=====================================
                //ADMIN OR NON-ADMIN EDITING SELF
                //=====================================
                //current user is modifying own profile (i.e. My Profile tab)
                //bisCurrentUserTrackAdmin = false;
                //bisCurrentUserGroupAdmin = false;
                bisNewUser = false;
                beditMode = false;
                updateContact();// CR 9365
                populateRequestFromUser(request,userLoggedIn);
                if(request.Job_Category__c == 'Other'){
                    botherCategory=true; 
                }
                userToModify = userLoggedIn;
                if(bisCurrentUserTrackAdmin || bisCurrentUserGroupAdmin){
                    bpartnerUserEditingOwnProfile = false; //5868178
                }
                else{
                     bpartnerUserEditingOwnProfile = true; //5868178
                }
               
                
            }
            System.debug('**editingOwnProfile'+ bpartnerUserEditingOwnProfile);
        } 
        else {
            //=====================================
            //ADMIN EDITING ANOTHER USER
            //=====================================
            //existing record, only admins should be able to modify other users
            bisNewUser = false;
            bpartnerUserEditingOwnProfile=false; //5868178
            updateContact();//CR 9365
            try{
                userToModify = getUser(userIdParam);
                bdisablePickListForGroupAdmin = userToModify.Enable_as_Partner_Group_Administrator__c;
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
            System.debug('****editingOwnProfile'+ bpartnerUserEditingOwnProfile);
            //if current user is attempting to modify own user account, this is ok
            //if current user is attempting to modify another parnter user account, verify is admin and user to modify belongs
            //  to same account
            if(userToModify.id != userLoggedIn.id){
                System.debug('beditMode'+'Entered'+(!bisCurrentUserTrackAdmin || !bisCurrentUserGroupAdmin));
                if(!bisCurrentUserTrackAdmin && !bisCurrentUserGroupAdmin){
                    System.debug('Entered'+ (!bisCurrentUserTrackAdmin || !bisCurrentUserGroupAdmin));
                    setErrorNotEnabledAsPartnerAdmin(request.Account__c);
                    userToModify = null;
                    beditMode=false;
                    bpartnerUserEditingOwnProfile=false;
                    return;
                }
                
                //verify that current user isn't attempting to modify user outside of Partner account
                if(userToModify.contact.account.id != userLoggedIn.contact.account.id){
                    
                    PageUtils.addError('Access Denied.');
                    userToModify = null;
                    beditMode=false;
                    return;
                }
            }
            
            if((bisCurrentUserTrackAdmin || bisCurrentUserGroupAdmin) && userToModify.id == userLoggedIn.id) {
                bisHiddenFromAdminSelf = true;
                bpartnerUserEditingOwnProfile = true; //pallavi
            }
            else if(userToModify.id == userLoggedIn.id){
                bpartnerUserEditingOwnProfile = true;
            }
            
            System.debug('***CheckeditingOwnProfile'+ bpartnerUserEditingOwnProfile);
            populateRequestFromUser(request,userToModify);
            
            
        }
        if(userToModify != null && userToModify.contactId != null){
            contactToModify = getContact(userToModify.contactId);
        }
        
        system.debug('***delreg' +request.Feature_Request_Deal_Registration__c);
        system.debug('***delreg' +request.Feature_Request_Deal_Registration__c);
        /*    if(request.Feature_Request_Deal_Registration__c == true){
system.debug('***Line273' +request.Feature_Request_Deal_Registration__c);
bisalowedLeadMAnagement = false;
}
else{
system.debug('***Line277' +request.Feature_Request_Deal_Registration__c);
bisalowedLeadMAnagement = true;
}
if(request.Feature_Request_Lead_Management__c == true){
system.debug('***Line279' +request.Feature_Request_Lead_Management__c );
bisalowedleadSuperUserValue = false;
}
else{
system.debug('***Line283' +request.Feature_Request_Lead_Management__c );
bisalowedleadSuperUserValue = true;
} */
        //bisalowedLeadMAnagement = true;
        system.debug('***finalLead' +bisalowedLeadMAnagement);
        system.debug('***super finalLead' +bisalowedleadSuperUserValue);
        //5868178 check
        System.debug('***userToModify ID'+userToModify);
        System.debug('***userLoggedIn ID'+userLoggedIn);
        System.debug('editingOwnProfile'+ bpartnerUserEditingOwnProfile);
        
        /*

if(userLoggedIn.Contact.Account.Sales_Channel__r != null && (userLoggedIn.Contact.Account.Sales_Channel__r.Name).contains('OEM') && this.country.Lead_Management_Enabled_for_OEM__c == 'Yes' && 
userLoggedIn.Contact.Account.Partner_Relationship__c != null &&(this.country.Partner_Relationship_for_OEM__c.contains(userLoggedIn.Contact.Account.Partner_Relationship__c) || this.country.Partner_Relationship_for_OEM__c.contains('All'))){
bisalowedLeadMAnagement = true;
}
//for other Accounts
else if(this.country.Lead_Management_Enabled__c == 'Yes' && userLoggedIn.Contact.Account.Partner_Relationship__c != null &&
(this.country.Partner_Relationship__c.contains(userLoggedIn.Contact.Account.Partner_Relationship__c) || this.country.Partner_Relationship__c.contains('All'))){
bisalowedLeadMAnagement = true;
}
*/
        System.debug('##bisalowedLeadMAnagement:'+bisalowedLeadMAnagement);
        if(String.isNotBlank(userLoggedIn.Contact.EligibleTracks__c)){
            if(userLoggedIn.Contact.EligibleTracks__c.contains(';')){
                setleftvalues.addAll(userLoggedIn.Contact.EligibleTracks__c.trim().split(';'));
                setsetleftValuesBackup.addAll(setleftvalues);
            }
            else{
                setleftvalues.add(userLoggedIn.Contact.EligibleTracks__c.trim());
                setsetleftValuesBackup.addAll(setleftvalues);
            }
            //setleftvalues.addAll(userLoggedIn.Contact.EligibleTracks__c.trim().split(';'));  
        }
        if(userToModify != null && String.isnotBlank(userToModify.Contact.EligibleTracks__c) ){
            if(userToModify.Contact.EligibleTracks__c.contains(';')){
                setrightvalues.addAll(userToModify.Contact.EligibleTracks__c.trim().split(';'));
                validateCSPTrack();
            }
            else{
                setrightvalues.add(userToModify.Contact.EligibleTracks__c.trim());
                validateCSPTrack();
            }
            
            
        }
        
        System.debug('from Constructor:: setleftvalues'+setleftvalues+'setrightvalues::'+setrightvalues);
        
    }
    
    
    public PageReference refreshPicklistNew() {
        system.debug('>>>>>>>>> '+Apexpages.currentpage().getParameters().get('valueIs'));
        strJobCatValue = Apexpages.currentpage().getParameters().get('valueIs');
        if(strJobCatValue=='Other'){
            botherCategory=true; 
        }
        else{
            botherCategory=false; 
        }
        //  system.debug('====request =='+request.Job_Category__c);
        //  request.Job_Title__c = null;
        return null; 
    }
    
    public PageReference refreshPicklist() {
        system.debug('====request =='+request.Job_Category__c);
        if(request.Job_Category__c == 'Other'){
            botherCategory=true; 
        }
        else if(request.Job_Category__c!= 'Other' && String.isNotBlank(request.Other_Job_Category__c )){
            request.Other_Job_Category__c ='';
        }
        
        
        request.Job_Title__c = null;
        return null; 
    } 
    public void jobTitleChange(){
        system.debug('Pick value'+Partner_Request__c.Job_Title__c);
        /*  if(Partner_Request__c.Job_Title__c=='Others' && Partner_Request__c.Job_Category__c=='Other'){
botherCategory=true;
}*/
    }
    // Populate the Address on selection of Track
    public void updateAddress(){
        System.debug('strlocationOfUser'+strlocationOfUser+'updateAddress()');
        System.debug('request.Location_Of_User__c'+request.Location_Of_User__c);
        System.debug('this.country.Code__c::'+this.country.Code__c);
        if(strlocationOfUser != System.Label.NoneForPicklist && String.isNotBlank(strlocationOfUser) ){
            Partner_Track__c ptRecord = new Partner_Track__c();
            ptRecord = [SELECT Id,Primary_Sales_Motion_Affinity_ID__c FROM Partner_Track__c WHERE Id =:strlocationOfUser];
            System.debug('ptRecord'+ptRecord);
            if(String.IsNotBlank(ptRecord.Primary_Sales_Motion_Affinity_ID__c)){
                Account acc = new Account();
                acc = [SELECT Id,BillingStreet,Account_Country_Code__c,BillingCity,BillingState,BillingPostalCode,BillingCountry FROM Account WHERE Account_ID__c =: ptRecord.Primary_Sales_Motion_Affinity_ID__c];
                
                String[] listaddressTokens = StringUtils.split(acc.BillingStreet,'\n');
                if(listaddressTokens == null){ 
                    listaddressTokens = new String[]{}; 
                        }
                if(String.isNotBlank(acc.Account_Country_Code__c)){
                    
                    
                    this.country = [SELECT id,Name,Partner_Support_Queue_ID__c,Code__c,Region__c
                                    FROM Country__c
                                    WHERE Code__c = :acc.Account_Country_Code__c
                                    LIMIT 1];
                    System.debug('this.country.Code__c::'+this.country.Code__c);
                    request.Country__c = this.country.id;
                    request.OwnerId = this.country.Partner_Support_Queue_ID__c;
                    //countryObj = this.country;
                    // Defect #6298036
                    System.debug('::Editing own Profile::');
                    /*if(bisNewUser){
                        System.debug('Validate Email when an change!');
                        validateEmail();  
                    }*/
                }
                request.Address_Line_1__c   = listaddressTokens.size() > 0 ? StringUtils.trim(listaddressTokens[0]) : '';
                request.Address_Line_2__c   = listaddressTokens.size() > 1 ? StringUtils.trim(listaddressTokens[1]) : '';
                request.Address_Line_3__c   = listaddressTokens.size() > 2 ? StringUtils.trim(listaddressTokens[2]) : '';
                request.Location_Of_User__c = strlocationOfUser;
                request.City__c             = acc.BillingCity;
                request.State__c            = acc.BillingState;
                request.Postal_Code__c      = acc.BillingPostalCode;
                strcountryName              = this.country.Name; //acc.BillingCountry;
                
            }
            else{
                request.Location_Of_User__c = strlocationOfUser;
                request.Address_Line_1__c   = '';
                request.Address_Line_2__c   = '';
                request.Address_Line_3__c   = '';
                request.City__c             = '';
                request.State__c            = '';
                request.Postal_Code__c      = '';
                strcountryName                 = '';
                request.Country__c          = null;
            }
            
            system.debug('request >>>> '+request);
        }
        else{
           
            request.Address_Line_1__c   = '';
            request.Address_Line_2__c   = '';
            request.Address_Line_3__c   = '';
            request.City__c             = '';
            request.State__c            = '';
            request.Postal_Code__c      = '';
            request.country__c          = null;
            strcountryName              = '';
            strlocationOfUser           = '';
            request.Location_Of_User__c = '';
            system.debug('===== request obj=='+request);
        }
        
    }
    
    // build a pick list for Location of User
    public List<selectOption> getLocationOfTracksAvailable(){
        System.debug('getLocationOfTracksAvailable Entered');
        Set<String> setlstTracks = new Set<String>();
        List<selectOption> listoptions = new List<selectOption>(); //new list for holding all of the picklist listoptions
        if(String.isNotBlank(userLoggedIn.Contact.EligibleTracks__c)){
            System.debug('userLoggedIn.Contact.EligibleTracks__c::'+userLoggedIn.Contact.EligibleTracks__c);
            setlstTracks = getTrackIds(userLoggedIn.Contact.EligibleTracks__c);
            
        }
        
        if(setlstTracks.size() > 0){
            for (Partner_Track__c addtrack : [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN: setlstTracks]) {
                if(String.isNotBlank(addtrack.Track_Name__c)){
                    listoptions.add(new selectOption(addtrack.Id, addtrack.Track_Name__c)); //for all records found - add them to the picklist listoptions
                }
                
            }
        }
        
        return listoptions;
        
    }
    //builds a picklist of Eligilble tracks 
    public List<selectOption> getEligibleTracks() {
        Set<String> setlstTracks = new Set<String>();
        List<selectOption> listoptions = new List<selectOption>(); //new list for holding all of the picklist listoptions
        List<string> listtempList = new List<String>();
        if(userToModify!=null){
            if(setleftvalues.size() > 0){
                listtempList.addAll(setleftvalues);
                // Added on 3rd Jan
                System.debug('listtempList'+listtempList);
                System.debug('setrightvalues'+setrightvalues);
                if(setrightvalues.size() > 0){
                    List<String> listlisttempListRight = new List<String>();
                    listlisttempListRight.addAll(setrightvalues);
                    System.debug('listlisttempListRight::'+listlisttempListRight);
                    for(String strs: setleftvalues){
                        if(listlisttempListRight.contains(strs)){
                            Integer intresult = listtempList.indexOf(strs);//listlisttempListRight.indexOf(strs);
                            System.debug('intresult'+intresult);
                            if(intresult != -1){
                                listtempList.remove(intresult);
                            }
                            else{
                                System.debug('List doesnt contain the value');
                            }
                            
                        }
                        
                    }
                    System.debug('On Load during Edit::'+listtempList);
                }
                listtempList.sort();
                if(listtempList.size()>0){
                    setlstTracks.addAll(listtempList);
                }
            }
            else if(setleftvalues.size() == 0){
                setlstTracks.clear(); 
            }
            else if(String.isNotBlank(userLoggedIn.Contact.EligibleTracks__c)){
                System.debug('userLoggedIn.Contact.EligibleTracks__c::'+userLoggedIn.Contact.EligibleTracks__c);
                setlstTracks = getTrackIds(userLoggedIn.Contact.EligibleTracks__c);
            }
        }
        else if(setleftvalues.size() > 0){
            listtempList.addAll(setleftvalues);
            listtempList.sort();
            if(listtempList.size()>0){
                setlstTracks.addAll(listtempList);
            }
        }
        else if(setleftvalues.size() == 0){
            setlstTracks.clear();
        }
        else if(String.isNotBlank(userLoggedIn.Contact.EligibleTracks__c)){
            System.debug('userLoggedIn.Contact.EligibleTracks__c::'+userLoggedIn.Contact.EligibleTracks__c);
            setlstTracks = getTrackIds(userLoggedIn.Contact.EligibleTracks__c);
        }
        
        if(setlstTracks.size() > 0){
            for (Partner_Track__c addtrack : [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN: setlstTracks]) {
                if(String.isNotBlank(addtrack.Track_Name__c)){
                    listoptions.add(new selectOption(addtrack.Id, addtrack.Track_Name__c));
                }
            }   
        }
        return listoptions; //return the picklist listoptions
    }
    
    // build a picklist of Selected Tracks
    public List<SelectOption> getEligibleTracksSelected(){
        Set<String> setlstTracks = new Set<String>();
        List<SelectOption> listoptions1 = new List<SelectOption>();
        List<string> listtempList = new List<String>();
        if(userToModify!=null && String.isNotBlank(userToModify.Contact.EligibleTracks__c)){
            if(setrightvalues.size() > 0){
                listtempList.addAll(setrightvalues);
                // 21st Jan
                System.debug('setleftvalues'+setleftvalues);
                System.debug('setrightvalues'+listtempList);
                List<String> listtempListLeft = new List<String>();
                if(setleftvalues.size() > 0){
                    listtempListLeft.addAll(setleftvalues);
                }
                if(userLoggedIn.Contact.EligibleTracks__c.contains(';')){
                    listtempListLeft.addAll(userLoggedIn.Contact.EligibleTracks__c.trim().split(';'));
                }
                else{
                    listtempListLeft.add(userLoggedIn.Contact.EligibleTracks__c.trim());
                }
                if(listleftselected.size() > 0){
                    listtempListLeft.addAll(listleftselected);  
                }
                System.debug('listtempListLeft::'+listtempListLeft);
                for(String strs: setrightvalues){
                    System.debug('right value in 508'+strs);
                    if(!listtempListLeft.contains(strs)){
                        Integer intresult = listtempList.indexOf(strs);//listlisttempListRight.indexOf(strs);
                        System.debug('intresult'+intresult);
                        if(intresult != -1){
                            listtempList.remove(intresult);
                        }
                        else{
                            System.debug('List doesnt contain the value');
                        }
                        
                    }
                    
                }
                System.debug('On Load during Edit::'+listtempList);
                
                
                if(listtempList.size() > 0){
                    listtempList.sort();
                    setlstTracks.addAll(listtempList);
                }
            }
            else if(setrightvalues.size() == 0){
                setlstTracks.clear();
            }
            else if(String.isNotBlank(userToModify.Contact.EligibleTracks__c)){
                System.debug('userToModify.Contact.EligibleTracks__c'+userToModify.Contact.EligibleTracks__c);
                setlstTracks = getTrackIds(userToModify.Contact.EligibleTracks__c);
            }
        }
        
        else if(setrightvalues.size() > 0){
            listtempList.addAll(setrightvalues);
            listtempList.sort();
            if(listtempList.size() > 0){
                setlstTracks.addAll(listtempList);
            }
        }
        else if(setrightvalues.size() == 0){
            setlstTracks.clear();
            PageUtils.addError('Atleast one track should be selected');
            return listoptions1;
        }
        
        if(setlstTracks.size() > 0){
            for (Partner_Track__c addtrack : [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN: setlstTracks]) {
                if(String.isNotBlank(addtrack.Track_Name__c)){
                    listoptions1.add(new selectOption(addtrack.Id, addtrack.Track_Name__c)); //for all records found - add them to the picklist listoptions 
                }
                
            }
        }
        
        System.debug('listoptions1'+listoptions1);
        return listoptions1;
    }
    
    public Set<String> getTrackIds(String strtrackIds){
        Set<String> setTracks = new Set<String>();
        List<String> setsttrackIds = new List<String>();
        System.debug('Entered getTrackIds');
        if(String.isNotBlank(strtrackIds)){
            System.debug('strtrackIds::'+strtrackIds);
            if(String.ValueOf(strtrackIds).contains(';')){
                setsttrackIds =strtrackIds.split(';');
                setTracks.addAll(setsttrackIds);
            }
            else{
                setTracks.add(strtrackIds);
            }
        }
        return setTracks;
        
    }
    
    //Select a track
    public PageReference selectTrack(){
        
        System.debug('selectTrack::'+listleftselected.size()+listleftselected);
        //listrightselected.clear();
        if(listleftselected.size() > 0){
            for(String strs: listleftselected){
                System.debug('S'+strs);
                setleftvalues.remove(strs);
                setrightvalues.add(strs);
                
            }
             // As per Story 7767854
        validateCSPTrack();
            //  listleftselected.clear();
        }
        else{
            PageUtils.addError('Select atleast One track'); 
            return null;
        }
      
            
        System.debug(setrightvalues+'::listrightselected after adding'+listrightselected);
        System.debug(setleftvalues+'::listleftselected after removing'+listleftselected);
        return null;
    }
    // Deselect a track
    public PageReference unselectclick(){    
        System.debug('unselectclick::'+'listrightselected::'+listrightselected+'Before Clearing::listleftselected after adding'+listleftselected);
        System.debug('setrightvalues before removing:'+setrightvalues+'setleftvalues before adding:'+setleftvalues);
        Set<String> setlstTracks = new Set<String>();
        listleftselected.clear();
        for(String strs: listrightselected){
            setrightvalues.remove(strs);
            setleftvalues.add(strs);
        }
        listrightselected.clear();
        System.debug('setrightvalues after removing'+setrightvalues+'setleftvalues after adding'+setleftvalues);
        return null;
    }
    
    public PageReference validateCSPTrack(){
        System.debug('validateCSPTrack::');
        System.debug('setrightvalues::'+setrightvalues);
        if(setrightvalues.size() > 0){
             // As per Story 7767854
            List<Partner_Track__c> listPT = [SELECT Id,Speciality_Product_Purchase_Path__c,Purchase_Path__c,
                                             Partner_Type__c
                                             FROM Partner_Track__c 
                                             WHERE Id IN: setrightvalues
                                             AND Partner_Type__c =: System.Label.Cloud_Service_Provider
                                             AND (Speciality_Product_Purchase_Path__c =: System.Label.Indirect_Purchase_Path OR 
                                                  Purchase_Path__c  =: System.Label.Indirect_Purchase_Path)];
            
            if(listPT.size() > 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Cloud_Service_Provider_Warning_Msg));
                return null;
            }
        }
        return null;
    }
    
    //====== Vasu (For Group Admin)=======================
    // When Group Admin is checked, all available tracks are assigned to Choosen tracks
    public PageReference assignAllTracksToSeleted(){  
        string strisGroupAdmin = (String) Apexpages.currentPage().getParameters().get('gAdmin');
        //setsetleftValuesBackup.addAll(setleftvalues);
        System.debug('Group Admin Value: ' ); 
        if(strisGroupAdmin.toLowerCase().trim() == 'true' ){            
            setrightvalues.addAll(setleftvalues);
            setleftvalues.clear();
            bdisablePickListForGroupAdmin = true;
            //bisCurrentUserGroupAdmin = true;
            
        } else if(strisGroupAdmin.toLowerCase().trim() == 'false' ){
            setleftvalues.addAll(setrightvalues);
            setrightvalues.removeAll(setsetleftValuesBackup);
            //setrightvalues.clear();
            bdisablePickListForGroupAdmin = false;
            //bisCurrentUserGroupAdmin = false;
        }
        
        return null;
    }
    /*public PageReference validateEmail(){
        System.debug('Just entered validateEmail'+strenteredEmail);
        System.debug('this.country.Code__c::'+this.country.Code__c);
        System.debug('errorCode::'+strerrorCode);
        String strexcludeFor;
        String strnewEmail;
        //Check if the email format is valid
        if(String.isNotBlank(request.email__c)){strnewEmail = request.email__c;}
        else if(String.isNotBlank(strenteredEmail)){strnewEmail = strenteredEmail;}
        if(String.isNotBlank(strnewEmail)){
            Pattern p = Pattern.compile('^([a-zA-Z0-9_\\-\\.\\\']+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,6}|[0-9]{1,3})(\\]?)');
            Matcher pm = p.matcher(strnewEmail);
            if(!pm.matches()){
                system.debug('in page ');
                request.email__c.addError(stremailInvalidChangedMessage);
                strerrorCode= stremailInvalidChangedMessage;
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,stremailInvalidChangedMessage));
                return null;
            }
            // get the country Code
            system.debug('Country Code===>>'+Label.GCCountryCodes.split(';').contains(this.country.Code__c));
            if(Label.GCCountryCodes.split(';').contains(this.country.Code__c)){
                strexcludeFor='GC countries';
            }
            else{
                strexcludeFor='Non GC countries';
            }
            System.debug('strexcludeFor'+strexcludeFor);
            System.debug('email duplication check'+PartnerAdminsCreateContactCntrl.emailDuplicationCheck(strnewEmail));
            List<string> listdomain = strnewEmail.split('@');
            // Check the Website
            System.debug('website::'+userLoggedIn.Contact.Account.Website);
            System.debug('listdomain ::'+listdomain );
            List<String> listwebsiteDomain = userLoggedIn.Contact.Account.Website.split('\\.');
            System.debug('listwebsiteDomain'+listwebsiteDomain);
            List<String> listemailDomain = listdomain[1].split('\\.');
            System.debug('listemailDomain'+listemailDomain);
            if(String.isNotBlank(strerrorCode) && (strerrorCode!= straccessdeniedstandardlicenseuser   || strerrorCode!= straccessdeniedpartnerusernotadmin  )){
                strerrorCode= '';
            }
            if(strexcludeFor == 'Non GC countries'){
                System.debug('::Non GC Countries::');
                // Check if the Email Already exists in the system
                if(bisNewUser){
                    System.debug('New User');
                    if(!PartnerAdminsCreateContactCntrl.emailDuplicationCheck(strnewEmail)){
                        // Check the domain against Company Website
                        Boolean bvalidEmailAddress = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(listdomain[1]);
                        System.debug('bvalidEmailAddress::'+bvalidEmailAddress);
                        if (bvalidEmailAddress){
                            strerrorCode= System.Label.Domain_Validation_NonGC;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,System.Label.Domain_Validation));
                            return null;
                        } 
                        if(listwebsiteDomain.size() > 0 && listemailDomain.size() > 0 && !listwebsiteDomain[1].equalsIgnoreCase(listemailDomain[0])){
                            System.debug('domain validation block');
                            //strerrorCode= System.Label.Domain_Validation;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.WARNING,System.Label.Domain_Validation));
                            return null;
                        }
                        
                        
                    }
                    else{
                        strerrorCode=System.Label.Duplicate_Email_Validation;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,System.Label.Duplicate_Email_Validation));
                        return null; 
                    }
                }
                else{
                    System.debug('Existing User');
                    // Check the domain against Company Website
                    Boolean bvalidEmailAddress = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(listdomain[1]);
                    System.debug('bvalidEmailAddress::'+bvalidEmailAddress);
                    if (bvalidEmailAddress){
                        strerrorCode= System.Label.Domain_Validation_NonGC;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,System.Label.Domain_Validation));
                        return null;
                    } 
                    if(listwebsiteDomain.size() > 0 && listemailDomain.size() > 0 && !listwebsiteDomain[1].equalsIgnoreCase(listemailDomain[0])){
                        System.debug('domain validation block');
                        //strerrorCode= System.Label.Domain_Validation;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.WARNING,System.Label.Domain_Validation));
                        return null;
                    }
                }
                
            }
            if(strexcludeFor == 'GC countries'){
                System.debug('::GC Countries::');
                Boolean bvalidEmailAddress = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(listdomain[1]); 
                System.debug('bvalidEmailAddress::'+bvalidEmailAddress);
                if(!bvalidEmailAddress){
                    // Check the domain against Company Website
                    if(listwebsiteDomain.size() > 0 && listemailDomain.size() > 0 && !listwebsiteDomain[1].equalsIgnoreCase(listemailDomain[0])){
                        System.debug('domain validation block');
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Warning,System.Label.Domain_Validation));
                        //return null;
                    }
                    //Duplicate Check
                    if(bisNewUser){
                        if(PartnerAdminsCreateContactCntrl.emailDuplicationCheck(strnewEmail)){
                            strerrorCode= System.Label.Duplicate_Email_Validation;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,System.Label.Duplicate_Email_Validation));
                            return null;
                            
                        }
                    }
                }
                
                
            }
            System.debug('errorCode'+strerrorCode);
        }
        return null;
    }*/
    public static Boolean emailDuplicationCheck(String stremailAddress){
        Boolean bemailExists;
        List<Contact> listcon = new List<Contact>();
        listcon = [SELECT Id,Email
                   FROM CONTACT
                   WHERE Email =: stremailAddress 
                   AND Partner_User_Active__c= true];
        System.debug('listcon'+listcon);
        if(listcon.size() == 0){
            bemailExists = false;
        }
        else{
            bemailExists = true;
        }
        return bemailExists;
        
    }   
    public void setErrorNotEnabledAsPartnerAdmin(String straccountId){
        strerrorCode= straccessdeniedpartnerusernotadmin ; //ACCESS_DENIED_PARTNER_USER_NOT_ADMIN;
        listpartnerAdminsForAccount = [
            select Contact.Title, Contact.Email, Contact.FirstName, Contact.LastName, ContactId,Contact.Enable_for_Bid_Builder__c
            from User where contact.accountid = :straccountId and 
            (Enable_Partner_Admin__c = true OR 
             Contact.Enable_as_Partner_Group_Administrator__c = true
            )
        ];
    }
    private Id getRecordTypeId(String strrecordTypeName){
        Id recordTypeId = IdLookupUtils.getRecordTypeId(strrecordTypeName, 'Partner_Request__c', true);
        System.assert(recordTypeId != null,'Record type \'' + strrecordTypeName + '\' not found.');
        return recordTypeId;
    }
    
    private void populateRequestFromAccount(Partner_Request__c request, Account account){        
        request.RecordTypeId = getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER);
    }
    
    private void populateRequestFromUser(Partner_Request__c request, User user){
        system.debug('====== request =='+request);
        system.debug('======user =='+user);
        boptInROE = false;
        boptInApj = false;
        strLabel = null;
        request.RecordTypeId = getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER);
        String[] listaddressTokens = StringUtils.split(user.Contact.MailingStreet,'\n');
        if(listaddressTokens == null){ listaddressTokens = new String[]{}; }//x
        
        request.Salutation__c               = user.Contact.Salutation;
        request.First_Name__c               = user.Contact.FirstName;
        request.Last_Name__c                = user.Contact.LastName;
        //request.Job_Title__c                = user.Contact.Title;
        request.Address_Line_1__c           = listaddressTokens.size() > 0 ? StringUtils.trim(listaddressTokens[0]) : ''; //x
        request.Address_Line_2__c           = listaddressTokens.size() > 1 ? StringUtils.trim(listaddressTokens[1]) : '';
        request.Address_Line_3__c           = listaddressTokens.size() > 2 ? StringUtils.trim(listaddressTokens[2]) : '';
        request.City__c                     = user.Contact.MailingCity;
        request.State__c                    = user.Contact.MailingState;
        request.Postal_Code__c              = user.Contact.MailingPostalCode;
        System.debug('user.Contact.MailingCountry'+user.Contact.MailingCountry);
        strcountryName            = user.Contact.MailingCountry;
        if(country!=null){request.Country__c= country.Id;}
        request.Phone__c                    = user.Contact.Phone;
        request.Mobile__c                   = user.Contact.MobilePhone;
        request.Fax__c                      = user.Contact.Fax;
        //request.Eligible_Partner_Tracks__c  = user.Contact.EligibleTracks__c;
        request.Job_Category__c             = user.Contact.Job_Function__c;
        request.Job_Title__c                = user.Contact.Job_Function_Role__c;
        if( request.Job_Category__c  == 'Other'){
            strJobCatValue = 'Other'; //request.Job_Category__c;
            botherCategory=true;
            System.debug('strJobCatValue'+strJobCatValue);
            request.Other_Job_Category__c       = user.Contact.Other_Job_Function_Category__c;
            System.debug('Other_Job_Function_Category__c'+request.Other_Job_Category__c);
        }
        request.Email__c                    = user.Contact.Email;
        request.Location_Of_User__c         = user.Contact.Location_Of_User__c;
        strlocationOfUser = request.Location_Of_User__c;
        System.debug('strlocationOfUser'+strlocationOfUser);
        System.debug('Address_Line_1__c::'+request.Address_Line_1__c);
        //request.Newsletter_Opt_In__c        = 'yes'.equalsIgnoreCase(user.Contact.Email_Opt_In__c);
        System.debug('countryObj::'+countryObj);
        if(countryObj != null){
            if(countryObj.Code__c == 'ca') {                        
                strLabel = Label.Newsletter_Confirmation; 
            }
            else if(countryObj.Code__c == 'de' || countryObj.Code__c == 'at' || countryObj.Code__c == 'ch'){
                strLabel = Label.Partner_Registration_01.replace('{!Country}',countryObj.Code__c).replace('{!lang}',strpreferredLanguageCode);
            }
            else if(countryObj.Region__c == 'Apj' || countryObj.Region__c == 'Latam'){
                strLabel = Label.Partner_Registration_APJ_02.replace('{!Country}',countryObj.Code__c).replace('{!lang}',strpreferredLanguageCode);
                boptInApj = true;
            }
            else if(countryObj.Code__c == 'us') {                        
                strLabel = Label.Partner_Registration_US; 
            }
            else {                    
                strLabel = Label.receive_newsletter_02.replace('{!Country}',countryObj.Code__c).replace('{!lang}',strpreferredLanguageCode);
                boptInROE = true;
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
        system.debug('***delreg874' +request.Feature_Request_Deal_Registration__c);
        request.Enable_As_Partner_Admin__c  = user.Enable_Partner_Admin__c;
        request.Enable_as_Lead_Super_User__c = user.Enable_As_Partner_Lead_Super_User__c;
        request.Feature_Request_Lead_Management__c = user.Enable_Partner_Lead_Management__c;
        request.Feature_Request_Deal_Registration__c = user.Enable_Partner_Deal_Registration__c;
        request.Enable_Partner_Group_Admin__c = user.Enable_as_Partner_Group_Administrator__c;
        request.Partner_Central__c = user.contact.Allow_Partner_Central_User__c;
        request.Program_Tracker__c = user.contact.Allow_Program_Tracker__c;
        request.RFP_Proposal_Express_Tool__c = user.contact.Allow_RFP_and_Proposal_Express_Tool__c;
        request.Enable_Premier_Pages_access_Flag__c = user.contact.Premier_Partner__c;
        request.Feature_Request_MDF__c = user.Contact.Is_MDF_User__c;
        request.Feature_Request_Rebates__c = user.contact.Is_Rebate_User__c ;
        request.Facebook__c = user.contact.Facebook__c;
        request.Instagram__c = user.contact.Instagram__c;
        request.Corporate_Twitter__c = user.contact.Corporate_Twitter__c;
        request.Personal_Twitter__c = user.contact.Twitter__c;
        request.LinkedInProfile__c = user.contact.LinkedInProfile__c;
     //[ShyamB]
        request.OSC_Create_Order__c = user.OSC_Create_Order__c;
        request.OSC_Create_Quote__c = user.OSC_Create_Quote__c;
        request.OSC_Specialty_Product_Create_Order__c = user.OSC_Specialty_Product_Create_Order__c;
        request.OSC_Specialty_Product_Create_Quote__c = user.OSC_Specialty_Product_Create_Quote__c;
        System.debug('user.contact.EMEA_Preferred_Contact_Language__c'+user.contact.EMEA_Preferred_Contact_Language__c);
        // request.Preferred_Language__c = user.contact.EMEA_Preferred_Contact_Language__c;
        
    }
    
    private User getUser(String struserId){
        return
            [SELECT id, Enable_Partner_Admin__c, Enable_As_Partner_Lead_Super_User__c, Contact.Email_Opt_In__c, Contact.Title, Contact.Email, Contact.MobilePhone, Contact.Fax, Contact.Phone,
             Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, Contact.MailingCity, Contact.MailingStreet,
             Contact.Salutation, Contact.FirstName, Contact.LastName,Contact.Enable_for_Bid_Builder__c,ContactId, Contact.AccountId, Contact.Account.id, Contact.Account.name,
             Contact.Account.account_country_code__c, userrole.name,Enable_as_Partner_Group_Administrator__c,
             Contact.Account.ShippingStreet,Contact.Account.ShippingCity,Enable_Partner_Deal_Registration__c,contact.Corporate_Twitter__c,
             Contact.Account.ShippingState,Contact.Account.ShippingPostalCode,FirstName,LastName,contact.Twitter__c,contact.LinkedInProfile__c,
             Contact.Account.Phone,Contact.Account.Fax,Contact.Account.Is_Rebate_Partner__c, Contact.Is_Rebate_User__c, Contact.Is_Enabled_for_Incentives__c,
             Contact.Account.Is_Enabled_for_Incentives__c,Contact.Account.Vendor_Update_Datetime__c,Contact.Account.Is_Incentive_Updated__c, Contact.Primary_Contact__c,
             Contact.Enable_as_Partner_Group_Administrator__c,Contact.Location_Of_User__c,contact.Facebook__c,contact.Instagram__c,
             Enable_Partner_Lead_Management__c,contact.Account.Partner_Relationship__c,contact.Account.Sales_Channel__r.name,contact.Job_Function__c,contact.Job_Function_Role__c,
             Enable_notifications_about_Channel_Leads__c,contact.EligibleTracks__c,contact.Allow_Partner_Central_User__c,Contact.EMEA_Preferred_Contact_Language__c,Contact.Account.Website,
             contact.Allow_Program_Tracker__c,contact.Allow_RFP_and_Proposal_Express_Tool__c,contact.Premier_Partner__c,contact.Selected_Track__c,contact.Selected_Track__r.Country_Code__c,
             contact.Preferred_Track__c,Contact.Is_MDF_User__c,Contact.Other_Job_Function_Category__c,OSC_Create_Order__c,OSC_Create_Quote__c,OSC_Specialty_Product_Create_Order__c,OSC_Specialty_Product_Create_Quote__c
             FROM user WHERE id = :struserId]; 
        
    }
    
    public PageReference doCancelNewUser(){
        System.debug('doCancelNewUser URL >> ' + Page.ManageUsers.getUrl());
        //return strcancelURLOr(Page.ManageUsers.getUrl());
        PageReference pg = new pageReference('/apex/ManageUsers');
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference doCancel(){
        System.debug('doCancel::bpartnerUserEditingOwnProfile::'+bpartnerUserEditingOwnProfile);
        if(bpartnerUserEditingOwnProfile ){
            PageReference pg = new pageReference('/apex/PartnerAdminsCreateContact');
            pg.setRedirect(true);
            return pg;
        }
        else{
            PageReference pg = new pageReference('/apex/ManageUsers');
            pg.setRedirect(true);
            return pg;
        }
        
    }
    public PageReference doSave(){
        System.debug('Inside dosave ::'+ request);
        populateChangeFlags();
        System.debug('bisEmailChanged::'+bisEmailChanged+'----- bisConfirmEmailChange::'+bisConfirmEmailChange+'bisNewUser'+bisNewUser+'beditMode::'+beditMode);
        /*if(bisNewUser){
            System.debug('Call Validate Email Method:');
            validateEmail();
            System.debug('error occured. STOP!'+strerrorCode);
            if(String.isNotBlank(strerrorCode)){
                if(strerrorCode!= System.Label.Domain_Validation){
                    System.debug('error occured. STOP!'+strerrorCode);
                    return null; 
                }
            }
            else{
                System.debug('no error occured');
            }
        }*/
        
        System.debug('strlocationOfUser'+strlocationOfUser);
        System.debug('bpartnerUserEditingOwnProfile'+bpartnerUserEditingOwnProfile);
        if(bpartnerUserEditingOwnProfile && strlocationOfUser == System.Label.NoneForPicklist && String.isNotBlank(strlocationOfUser)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Mandate_Location_of_User));
            return null;
        }
        if(strlocationOfUser == System.Label.NoneForPicklist && String.isNotBlank(strlocationOfUser) ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Mandate_Location_of_User));
            return null;
        }
        // Add all the tracks if its a Group and track Admin
        System.debug('bisCurrentUserGroupAdmin::'+bisCurrentUserGroupAdmin+'setleftvalues'+setleftvalues+'Right Values'+setrightvalues);
        System.debug('request.Enable_Partner_Group_Admin__c ==>'+request.Enable_Partner_Group_Admin__c + '==>setrightvalues.size(): ' + setrightvalues.size());
        if(request.Enable_Partner_Group_Admin__c == true){
            request.Enable_as_Partner_Admin__c = true;
            Set<String> setsttrackIds = new Set<String>();
            if(setleftvalues.size() > 0){
                setsttrackIds.addAll(setleftvalues);
            } 
            if(setrightvalues.size() > 0){
                setsttrackIds.addAll(setrightvalues);
                
            }
            System.debug('setsttrackIds::'+setsttrackIds);
            if(setsttrackIds.size()>0){
                for(String strtrackId : setsttrackIds){
                    if(String.isNotBlank(request.Eligible_Partner_Tracks__c) && !request.Eligible_Partner_Tracks__c.contains(strtrackId) ){
                        request.Eligible_Partner_Tracks__c = request.Eligible_Partner_Tracks__c+';'+ strtrackId ;
                    }
                    else{
                        request.Eligible_Partner_Tracks__c =strtrackId ; 
                    }
                    
                    
                }
            }
            
        }
        else if(setrightvalues.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Mandate_Partner_Track));
            return null;
        }
        else{
            for(String strtrackId : setrightvalues){
                System.debug('request.Eligible_Partner_Tracks__c'+request.Eligible_Partner_Tracks__c);
                if(String.isNotBlank(request.Eligible_Partner_Tracks__c)){
                    if(!request.Eligible_Partner_Tracks__c.contains(strtrackId ) && !request.Eligible_Partner_Tracks__c.contains(strtrackId) ){
                        request.Eligible_Partner_Tracks__c = request.Eligible_Partner_Tracks__c+';'+ strtrackId ; 
                    }
                    
                }
                else{
                    request.Eligible_Partner_Tracks__c =strtrackId ;
                }
                
                
            }
            
        }
        System.debug('request.Eligible_Partner_Tracks__c::'+request.Eligible_Partner_Tracks__c);
        
        Savepoint sp = null;
        try{
            sp = Database.setSavepoint();
            request.Status__c = PartnerConstants.REG_STATUS_DRAFT;
            system.debug('@#@#'+request);
            insert request;
            System.debug('request inserted'+request);
        }
        catch(Exception e) { //x
            System.debug('Exception'+e.getMessage());
            Database.rollback(sp); //x
            ApexPages.addMessages(e); //x
            return null; //x
        }
        if (request.id !=null && bisNewUser){
            PageReference pageRef = new PageReference('/apex/PartnerRegistrationProvisionUser?id='+request.id); 
            return PageUtils.redirect(pageRef.getUrl());
        }
        
        List<Partner_Request__c> listincompletePRList = new List<Partner_Request__c>();
        System.debug('--is New User--'+bisNewUser+'--bpartnerUserEditingOwnProfile--'+bpartnerUserEditingOwnProfile);
        //raymond CR2421 - new user request will not be automated
        if(request.id != null && !bisNewUser)
        {
            try{
                executeUserUpdate();
                System.debug('bisEmailChanged'+bisEmailChanged);
                if(!bisTest && !bisEmailChanged){
                    synchronizeToCMIandNetExam(contactToModify.Id, request.Id);
                }
                if(bpartnerUserEditingOwnProfile){
                    PageReference page = new pageReference('/apex/PartnerAdminsCreateContact');
                    page.setRedirect(true);
                    return page;
                }
                else{
                    PageReference pg = new pageReference('/apex/ManageUsers');
                    pg.setRedirect(true);
                    return pg;
                }
                
                
                // Will never be called as there is no email change from our pages
                /*   else {
System.debug('setIncompletForRequestWithReason!!');
setIncompletForRequestWithReason(request,'User has updated the email address on Contact. Please reprovision the user and refer to Partner Request to set the appropriate application access.');
listincompletePRList.add(request);
}
System.debug('listincompletePRList'+listincompletePRList);
*/
            }
            catch (Exception e){
                System.debug('Exception::'+e);
                ApexPages.addMessages(e);
                setIncompletForRequestWithReason(request,'Error: Trying to call synchronizeToCMIandNetExam: ' + e.getMessage());
                request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
                request.Description__c += + ' \nError: ' + e.getMessage();
                listincompletePRList.add(request);
            }
        }
        try
        {
            System.debug('737::');
            if(listincompletePRList.size() > 0) {
                update listincompletePRList;
            }
        }
        catch(Exception e){
            System.debug('745'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            //ApexPages.addMessages(e);
            return null;
        }
        return null;
        
    }
    public void doPermissionSetAssignment(){
        try{
            List<PermissionSet> listpermSet = [SELECT Id FROM PermissionSet WHERE Name = 'Partner_Opportunity_Access'];
            if((listpermSet != null) && (listpermSet.size() > 0)){
                if(userToModify.Enable_Partner_Deal_Registration__c){
                    List<PermissionSetAssignment> listassignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userToModify.Id and PermissionSetId = :listpermSet[0].Id];
                    if((listassignments == null) || (listassignments.size() == 0)){
                        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId = userToModify.Id, PermissionSetId = listpermSet[0].Id);
                        insert assignment;
                    }
                }else{
                    List<PermissionSetAssignment> listassignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userToModify.Id and PermissionSetId = :listpermSet[0].Id];
                    delete listassignments;
                }
                
            }else{
                string strerr = 'A problem has occured: Permission set \'Partner_Opportunity_Access\' not found. User ID = ' + userToModify.Id;
                List<string> listrecipients = new List<string>{'SFDC-ApexDev@dell.com'};
                    emailUtils.sendTextEmail(listrecipients, 'Permission set \'Partner_Opportunity_Access\' not found', strerr);
                
            }
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
        
        //return null;
    }
    private void populateChangeFlags(){
        System.debug('>>>>groupadmin'+request.Enable_Partner_Group_Admin__c);
        System.debug('>>>>trackadmin'+request.Enable_as_Partner_Admin__c);
        system.debug('----------'+request+'-----------'+userToModify+'----------'+beditMode);
        
        if(request == null || userToModify == null || beditMode == false){return;}
        if(request.Feature_Request_Deal_Registration__c == false){
            request.Feature_Request_Lead_Management__c = false;
            request.Enable_as_Lead_Super_User__c = false;
        }
        if(request.Feature_Request_Lead_Management__c == false){
            request.Enable_as_Lead_Super_User__c = false;
        }
        system.debug('request.Enable_Partner_Group_Admin__c'+request.Enable_Partner_Group_Admin__c);
        if(request.Enable_Partner_Group_Admin__c== true){
            request.Enable_as_Partner_Admin__c= true;
        }
        if(request.OSC_Create_Quote__c == false){
            request.OSC_Create_Order__c = false;
        }
        if(request.OSC_Specialty_Product_Create_Quote__c == false){
            request.OSC_Specialty_Product_Create_Order__c = false;
        }
        if(request.OSC_Create_Order__c == true){
            request.OSC_Create_Quote__c = true;
        }
        if(request.OSC_Specialty_Product_Create_Order__c  == true){
            request.OSC_Specialty_Product_Create_Quote__c= true;
        }
        bisEmailChanged = false;
        request.Contact__c = userToModify.ContactId;
        Map<String,String> mapchanges = new Map<String,String>();
        if(userToModify.Contact.Salutation != request.Salutation__c){ 
            mapchanges.put('Salutation', request.Salutation__c);request.Salutation_CF__c = true;
        }
        if(userToModify.Contact.FirstName != request.First_Name__c){ 
            mapchanges.put('First Name', request.First_Name__c);request.First_Name_CF__c = true;
        }
        if(userToModify.Contact.LastName != request.Last_Name__c){ mapchanges.put('Last Name', request.Last_Name__c); request.Last_Name_CF__c = true;}
        if(userToModify.Contact.Title != request.Job_Title__c){ mapchanges.put('Title', request.Job_Title__c); request.Job_Title_CF__c = true;}
        if(userToModify.Contact.Job_Function_Role__c != request.Job_Title__c){ mapchanges.put('Job Title', request.Job_Title__c); request.Job_Title_CF__c = true;}
        if(userToModify.Contact.Job_Function__c != request.Job_Category__c){ mapchanges.put('Job Category', request.Job_Category__c);}
        if(userToModify.Contact.Other_Job_Function_Category__c != request.Other_Job_Category__c){mapchanges.put('Other Job Category', request.Other_Job_Category__c);}
        if(userToModify.Contact.EMEA_Preferred_Contact_Language__c != request.Preferred_Language__c){ mapchanges.put('Preferred Language', request.Preferred_Language__c);}
        String[] listaddressTokens = StringUtils.split(userToModify.Contact.MailingStreet,'\n');
        if(listaddressTokens == null){ listaddressTokens = new String[]{}; } 
        System.debug('(listaddressTokens.size() <= 0 ? \'\' : listaddressTokens[0]) = [' + (listaddressTokens.size() <= 0 ? '' : listaddressTokens[0]) + ']');
        System.debug('request.Address_Line_1__c = [' + request.Address_Line_1__c + ']');
        if((listaddressTokens.size() <= 0 ? '' : StringUtils.trim(listaddressTokens[0])) != request.Address_Line_1__c){ mapchanges.put('Address Line 1', request.Address_Line_1__c); request.Address_Line_1_CF__c = true;}
        if((listaddressTokens.size() <= 1 ? '' : StringUtils.trim(listaddressTokens[1])) != request.Address_Line_2__c){ mapchanges.put('Address Line 2', request.Address_Line_2__c); request.Address_Line_2_CF__c = true;} //x
        if((listaddressTokens.size() <= 2 ? '' : StringUtils.trim(listaddressTokens[2])) != request.Address_Line_3__c){ mapchanges.put('Address Line 3', request.Address_Line_3__c); request.Address_Line_3_CF__c = true;} //x
        if(userToModify.Contact.MailingCity != request.City__c){ mapchanges.put('City', request.City__c); request.City_CF__c = true;}
        if(userToModify.Contact.MailingState != request.State__c){ mapchanges.put('State', request.State__c); request.State_CF__c = true;}
        if(userToModify.Contact.MailingPostalCode != request.Postal_Code__c){ mapchanges.put('Postal Code', request.Postal_Code__c); request.Postal_Code_CF__c = true;}
        if(userToModify.Contact.MailingCountry != request.Country__r.Name){ mapchanges.put('Country', request.Country__r.Name); }
        if(userToModify.Contact.Phone != request.Phone__c){ mapchanges.put('Phone', request.Phone__c); request.Phone_CF__c = true;}
        if(userToModify.Contact.MobilePhone != request.Mobile__c){ mapchanges.put('Mobile', request.Mobile__c); request.Mobile_CF__c = true;}
        
        // Other tool Access on Contact
        // Sales Tools
        if(userToModify.Enable_Partner_Deal_Registration__c != request.Feature_Request_Deal_Registration__c){ mapchanges.put('Enable Deal Registration', (request.Feature_Request_Deal_Registration__c ? 'Checked' : 'Unchecked'));} 
        if(userToModify.Contact.Premier_Partner__c != request.Enable_Premier_Pages_access_Flag__c){mapchanges.put('Premier Pages', (request.Enable_Premier_Pages_access_Flag__c ? 'Checked' : 'Unchecked'));}
        
        if(userToModify.Contact.Allow_RFP_and_Proposal_Express_Tool__c != request.RFP_Proposal_Express_Tool__c){mapchanges.put('RFP Proposal Express', (request.RFP_Proposal_Express_Tool__c ? 'Checked' : 'Unchecked'));}
        if(userToModify.OSC_Create_Order__c != request.OSC_Create_Order__c){ mapchanges.put('OSC Create Order', (request.OSC_Create_Order__c ? 'Checked' : 'Unchecked'));} 
        if(userToModify.OSC_Create_Quote__c != request.OSC_Create_Quote__c){ mapchanges.put('OSC Create Quote', (request.OSC_Create_Quote__c ? 'Checked' : 'Unchecked'));} 
        if(userToModify.OSC_Specialty_Product_Create_Order__c != request.OSC_Specialty_Product_Create_Order__c){ mapchanges.put('OSC Specialty Product Create Order', (request.OSC_Specialty_Product_Create_Order__c ? 'Checked' : 'Unchecked'));} 
        if(userToModify.OSC_Specialty_Product_Create_Quote__c != request.OSC_Specialty_Product_Create_Quote__c){ mapchanges.put('OSC Specialty Product Create Quote', (request.OSC_Specialty_Product_Create_Quote__c ? 'Checked' : 'Unchecked'));} 
        
        // Marketing Tools
        if(userToModify.Enable_Partner_Lead_Management__c != request.Feature_Request_Lead_Management__c){ mapchanges.put('Enable Lead Management', (request.Feature_Request_Lead_Management__c ? 'Checked' : 'Unchecked'));}
        
        if(userToModify.Enable_As_Partner_Lead_Super_User__c != request.Enable_as_Lead_Super_User__c){mapchanges.put('Enable As Lead Super User', (request.Enable_as_Lead_Super_User__c? 'Checked' : 'Unchecked'));}
        if(userToModify.Contact.Is_MDF_User__c != request.Feature_Request_MDF__c){mapchanges.put('Enable MDF', (request.Feature_Request_MDF__c ? 'Checked' : 'Unchecked'));}
        //Partner Program Tools
        if(userToModify.Contact.Allow_Partner_Central_User__c != request.Partner_Central__c){mapchanges.put('Partner Central', (request.Partner_Central__c? 'Checked' : 'Unchecked'));}
        if(userToModify.Contact.Allow_Program_Tracker__c != request.Program_Tracker__c){mapchanges.put('Partner Tracker', (request.Program_Tracker__c ? 'Checked' : 'Unchecked'));}
        if(userToModify.Contact.Is_Rebate_User__c != request.Feature_Request_Rebates__c){mapchanges.put('Enable Rebate', (request.Feature_Request_Rebates__c ? 'Checked' : 'Unchecked'));}
        
        //Partner Tracks
        if(userToModify.Enable_as_Partner_Group_Administrator__c != request.Enable_Partner_Group_Admin__c){mapchanges.put('Enable As Partner Group Admin', (request.Enable_Partner_Group_Admin__c? 'Checked' : 'Unchecked'));}
        if(userToModify.Enable_Partner_Admin__c != request.Enable_As_Partner_Admin__c){mapchanges.put('Enable As Partner Admin', (request.Enable_As_Partner_Admin__c ? 'Checked' : 'Unchecked')); request.Enable_As_Partner_Admin_CF__c = true;} 
        
        if(userToModify.Contact.EligibleTracks__c != request.Eligible_Partner_Tracks__c){mapchanges.put('Eligible Tracks', request.Eligible_Partner_Tracks__c);}
        //Social Networking
        if(userToModify.Contact.Facebook__c != request.Facebook__c){mapchanges.put('Facebook', request.Facebook__c);}
        if(userToModify.Contact.Instagram__c != request.Instagram__c){mapchanges.put('Instagram', request.Instagram__c);}
        if(userToModify.Contact.LinkedInProfile__c != request.LinkedInProfile__c){mapchanges.put('LinkedIn Profile', request.LinkedInProfile__c);}
        if(userToModify.Contact.Twitter__c != request.Personal_Twitter__c){mapchanges.put('Personal Twitter', request.Personal_Twitter__c);}
        if(userToModify.Contact.Corporate_Twitter__c != request.Corporate_Twitter__c){mapchanges.put('Corporate Twitter', request.Corporate_Twitter__c);}
        
        if('yes'.equalsIgnoreCase(userToModify.Contact.Email_Opt_In__c) != request.Newsletter_Opt_In__c){ mapchanges.put('Newsletter Opt-In', (request.Newsletter_Opt_In__c ? 'Checked' : 'Unchecked')); request.Newsletter_Opt_In_CF__c = true;} //x
        // Different Tool Access
        
        if(!mapchanges.isEmpty()){
            request.Description__c = 'mapchanges:  ';
            Boolean bisFirst = true;
            for(String strkey : mapchanges.keySet()){
                if(bisFirst){
                    bisFirst = false;
                } else {
                    request.Description__c += '; ';
                }
                request.Description__c += strkey + ' = \'' + mapchanges.get(strkey ) + '\'\n';
            }
        }
    }
    /*
public PageReference doOK(){
return returnUrlOr(Page.PartnerAdminsCreateContact.getUrl());
}
public PageReference returnUrlOr(String secondaryURL){
return redirect(strretURL , secondaryURL);
}
public PageReference strcancelURLOr(String secondaryURL){
return redirect(strcancelURL, secondaryURL);
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
public void synchronizeToCMIandNetExamForTest() {
synchronizeToCMIandNetExam(contactToModify.Id, request.Id);
}

*/
    public PageReference doEdit(){
        beditMode = true;        
        updateContact();
        return null;
    }
    public void updateContact(){
        strcontactEmail = '';
        system.debug('*****'+strcontactEmail);
        if(countryObj != null && userLoggedIn.Contact.Email != null){
            strcontactEmail = System.Label.CaseManagementPortalLink;
        }
    }  
    @TestVisible 
    private void executeUserUpdate(){
        if(request == null || userToModify == null || beditMode == false){
            return;
        }
        if(contactToModify.Email != request.Email__c){
            contactToModify.Email = request.Email__c;
            //bisEmailChanged = true;
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
        if(contactToModify.Job_Function__c != request.Job_Category__c){
            contactToModify.Job_Function__c = request.Job_Category__c;
        }
        if(contactToModify.Job_Function_Role__c != request.Job_Title__c){
            contactToModify.Job_Function_Role__c = request.Job_Title__c;
        }
        if(contactToModify.Other_Job_Function_Category__c != request.Other_Job_Category__c){
            contactToModify.Other_Job_Function_Category__c = request.Other_Job_Category__c;
        }
        String strnewAddress = request.Address_Line_1__c + '\n' + request.Address_Line_2__c + '\n' + request.Address_Line_3__c;
        if(contactToModify.MailingStreet != strnewAddress){
            contactToModify.MailingStreet = strnewAddress;
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
        if(request.Country__c!=null){        
            System.debug('request.Country__c::'+request.Country__c);
            if(contactToModify.MailingCountry != country.Name){
                contactToModify.MailingCountry = country.Name;
                strcountryName  = country.Name;
                
            }
        }
        if(contactToModify.Phone != request.Phone__c){
            contactToModify.Phone = request.Phone__c;
        }
        
        if(contactToModify.MobilePhone != request.Mobile__c){
            contactToModify.MobilePhone = request.Mobile__c;
        }
        
        if(contactToModify.Allow_Partner_Central_User__c != request.Partner_Central__c){
            contactToModify.Allow_Partner_Central_User__c = request.Partner_Central__c;
        }
        if(contactToModify.Allow_Program_Tracker__c != request.Program_Tracker__c){
            contactToModify.Allow_Program_Tracker__c = request.Program_Tracker__c;
        }
        if(contactToModify.Is_MDF_User__c != request.Feature_Request_MDF__c){
            contactToModify.Is_MDF_User__c = request.Feature_Request_MDF__c;
        }
        if(contactToModify.Is_Rebate_User__c != request.Feature_Request_Rebates__c){
            contactToModify.Is_Rebate_User__c = request.Feature_Request_Rebates__c;
        }
        
        if(contactToModify.Premier_Partner__c != request.Enable_Premier_Pages_access_Flag__c){
            contactToModify.Premier_Partner__c = request.Enable_Premier_Pages_access_Flag__c;
        }
        if(contactToModify.Allow_RFP_and_Proposal_Express_Tool__c != request.RFP_Proposal_Express_Tool__c){
            contactToModify.Allow_RFP_and_Proposal_Express_Tool__c = request.RFP_Proposal_Express_Tool__c;
        }
        
        if(contactToModify.Fax != request.Fax__c){
            contactToModify.Fax = request.Fax__c;
        }
        if(contactToModify.Location_Of_User__c != request.Location_Of_User__c){
            contactToModify.Location_Of_User__c = request.Location_Of_User__c;
        }
        if(contactToModify.EligibleTracks__c != request.Eligible_Partner_Tracks__c){
            contactToModify.EligibleTracks__c = request.Eligible_Partner_Tracks__c;
            System.debug('contactToModify.Preferred_Track__c::'+contactToModify.Preferred_Track__c);
            System.debug('contactToModify.Selected_Track__c::'+contactToModify.Selected_Track__c);
            if(contactToModify.EligibleTracks__c.contains(';')){
                if(!(String.valueOf(contactToModify.Preferred_Track__c).contains(String.valueOf(contactToModify.EligibleTracks__c).trim()))){
                    contactToModify.Preferred_Track__c = Id.valueof(String.valueOf(contactToModify.EligibleTracks__c).split(';')[0]);                
                }
                if(!(String.valueOf(contactToModify.Selected_Track__c).contains(String.valueOf(contactToModify.EligibleTracks__c).trim()))){
                    contactToModify.Selected_Track__c = Id.valueof(String.valueOf(contactToModify.EligibleTracks__c).split(';')[0]);                
                }
            }
            else{
                if(!(String.valueOf(contactToModify.Preferred_Track__c).contains(String.valueOf(contactToModify.EligibleTracks__c).trim()))){
                    contactToModify.Preferred_Track__c = Id.valueOf(String.valueOf(contactToModify.EligibleTracks__c).trim());  
                }
                if(!(String.valueOf(contactToModify.Selected_Track__c).contains(String.valueOf(contactToModify.EligibleTracks__c).trim()))){
                    contactToModify.Selected_Track__c = Id.valueOf(String.valueOf(contactToModify.EligibleTracks__c).trim());  
                }
            }
            System.debug('updated contactToModify.EligibleTracks__c::'+contactToModify.EligibleTracks__c);
            System.debug('updated contactToModify.Preferred_Track__c::'+contactToModify.Preferred_Track__c);
            System.debug('updated contactToModify.Selected_Track__c::'+contactToModify.Selected_Track__c);
        }
        //Social Networking
        if(contactToModify.Facebook__c != request.Facebook__c){contactToModify.Facebook__c = request.Facebook__c;}
        if(contactToModify.Instagram__c != request.Instagram__c){contactToModify.Instagram__c = request.Instagram__c;}
        if(contactToModify.LinkedInProfile__c != request.LinkedInProfile__c){contactToModify.LinkedInProfile__c = request.LinkedInProfile__c;}
        if(contactToModify.Twitter__c != request.Personal_Twitter__c){contactToModify.Twitter__c = request.Personal_Twitter__c;}
        if(contactToModify.Corporate_Twitter__c != request.Corporate_Twitter__c){contactToModify.Corporate_Twitter__c = request.Corporate_Twitter__c;}
        if('yes'.equalsIgnoreCase(contactToModify.Email_Opt_In__c) != request.Newsletter_Opt_In__c || 'yes'.equalsIgnoreCase(contactToModify.Email_Opt_In__c) == request.Newsletter_Opt_In__c)
        {  
            if(countryObj!=null){
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
        System.debug('bisEmailChanged in executeUserUpdate::'+bisEmailChanged);
        if(userToModify.Enable_Partner_Admin__c != request.Enable_As_Partner_Admin__c){
            userToModify.Enable_Partner_Admin__c = request.Enable_As_Partner_Admin__c;
        }
        system.debug('***delreg1372' +request.Feature_Request_Deal_Registration__c);
        if(userToModify.Enable_Partner_Deal_Registration__c != request.Feature_Request_Deal_Registration__c){
            userToModify.Enable_Partner_Deal_Registration__c = request.Feature_Request_Deal_Registration__c;
        }
        if(userToModify.OSC_Create_Order__c != request.OSC_Create_Order__c){
            userToModify.OSC_Create_Order__c = request.OSC_Create_Order__c;
        }
        if(userToModify.OSC_Create_Quote__c != request.OSC_Create_Quote__c){
            userToModify.OSC_Create_Quote__c = request.OSC_Create_Quote__c;
        }
        if(userToModify.OSC_Specialty_Product_Create_Order__c != request.OSC_Specialty_Product_Create_Order__c){
            userToModify.OSC_Specialty_Product_Create_Order__c = request.OSC_Specialty_Product_Create_Order__c;
        }
        if(userToModify.OSC_Specialty_Product_Create_Quote__c != request.OSC_Specialty_Product_Create_Quote__c){
            userToModify.OSC_Specialty_Product_Create_Quote__c = request.OSC_Specialty_Product_Create_Quote__c;
        }                        
        if(userToModify.Enable_Partner_Lead_Management__c != request.Feature_Request_Lead_Management__c){
            userToModify.Enable_Partner_Lead_Management__c = request.Feature_Request_Lead_Management__c;
        }
        //CR 7824 - Add Enable as Lead Super User
        if(userToModify.Enable_As_Partner_Lead_Super_User__c!= request.Enable_as_Lead_Super_User__c){
            userToModify.Enable_As_Partner_Lead_Super_User__c = request.Enable_as_Lead_Super_User__c;
        }
        //Add Enable as Group admin User
        if(userToModify.Enable_as_Partner_Group_Administrator__c!= request.Enable_Partner_Group_Admin__c){
            userToModify.Enable_as_Partner_Group_Administrator__c = request.Enable_Partner_Group_Admin__c;
        }
        //Raymond 20100225: Temporary disable CMI integration, CR2421
        GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = true;
        
        update userToModify;
        
        update contactToModify;
        
        GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = false;
    }
    
    private Contact getContact(String strcontactId){
        return
            [select id, Email_Opt_In__c, Title, Email, MobilePhone, Fax, Phone,
             MailingCountry, MailingPostalCode, MailingState, MailingCity, MailingStreet,
             Salutation, FirstName, LastName,Enable_for_Bid_Builder__c, AccountId, Account.id, Account.name,
             Account.account_country_code__c,Location_Of_User__c,Job_Function__c,Job_Function_Role__c,
             Account.ShippingStreet,Account.ShippingCity,EligibleTracks__c,Account.Website,Is_MDF_User__c,Other_Job_Function_Category__c,
             Account.ShippingState,Account.ShippingPostalCode,Allow_Program_Tracker__c,EMEA_Preferred_Contact_Language__c,
             Account.Phone,Account.Fax,Account.Is_Rebate_Partner__c, Allow_RFP_and_Proposal_Express_Tool__c,Selected_Track__c,Preferred_Track__c,
             Is_Rebate_User__c, Is_Enabled_for_Incentives__c,Allow_Partner_Central_User__c,Premier_Partner__c,Selected_Track__r.Country_Code__c,
             Account.Partner_Relationship__c,Account.Sales_Channel__r.name,Instagram__c,Facebook__c,Twitter__c,LinkedInProfile__c,Corporate_Twitter__c
             from Contact where id = :strcontactId];
    }
    public static void setIncompletForRequestWithReason(Partner_Request__c request, String strreason){
        request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
        if(request.Description__c == null) {
            request.Description__c += strreason;
        }
        else {
            request.Description__c += ' \n\n' + strreason;
        }
        
    }
    
    //raymond 2421
    @future (callout=true)
    
    public static void synchronizeToCMIandNetExam(String strcontactId, String strrequestId) {
        Partner_Request__c request;
        Boolean bisCMISuccess = false;
        try {
            try{
                request = [SELECT Id, Status__c,Enable_for_Bid_Builder__c,Description__c FROM Partner_Request__c WHERE Id = :strrequestId];
                Contact contactObj = [Select Is_Incentives_Updated__c,Enable_for_Bid_Builder__c from contact where id =:strcontactId];
                
                system.debug('Request Status (1): ' + request.Status__c);
                system.debug('Request Status ID: ' + strrequestId);
                system.debug('Contact ID: ' + strcontactId);
                system.debug('Is Incentives Updated: '  +contactObj.Is_Incentives_Updated__c );
                
                //ray - 20101114 fix NetExam update to CMI issue. If status is incomplete, do not update to complete
                //Ariff - 20130122 add extra condition for udpate. If incentive is update is equal to true, do not update PR status
                if( request.Status__c != PartnerConstants.REG_STATUS_INCOMPLETE && !(contactObj.Is_Incentives_Updated__c)) {
                    //initialize the status to 'Complete'
                    request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;
                }
                system.debug('Request Status (2): ' + request.Status__c);
                
                //sends the Contact data to Partner profile
                String strresponse = PartnerProfileIntegration.integratePartnerDataWithResponse(strcontactId);
                System.debug('response::'+strresponse );
                if(strresponse != null && !strresponse.contains(GlobalVariables.CMI_RESPONSE_SUCCESSFUL)) { //if Failed.
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
        }
    }
    
    Public pagereference rewardaccess(){
        PageReference pageRef = new PageReference('/apex/PartnerSelfServiceIncentiveBulkNominate');
        pageRef.setRedirect(true);
        return pageRef ;
        
    }
    /* 
public PageReference doSaveForEOP(){
System.debug('doSave::bpartnerUserEditingOwnProfile::'+bpartnerUserEditingOwnProfile);
updateContact();
PageReference pg = new PageReference('/apex/PartnerAdminsCreateContact');
pg.setRedirect(true);
return pg;
}
*/
}
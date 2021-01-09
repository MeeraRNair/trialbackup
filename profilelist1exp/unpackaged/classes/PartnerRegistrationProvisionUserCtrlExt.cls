/* 
* Controller logic for provisioning partner portal users. 
*
* This page is accessed from either a Contact or Partner_Request__c
* record.  Correspondingly, this controller first looks for an ID
* param and checks to make sure the ID is a valid Contact or
* Partner_Request__c ID.
*
* Steps:
* Get GUID from My Account
* If Partner Request Passed
*   If Contact record exists (where account = x and email = y)
*     Show Merge
*   Else
*     Create Contact
* Create User
* Create NetExam User
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
*          CR1466                     22-Jul-2009:     Raymond         Copy values from PartnerRequest to Account.This is done in the onLoad method.
*          CR1790                     18-Sept-2009     Raymond         Enable Channel Ops to provision Rebate feature to users
*          CR2087                     21-Jun-2010      MenMee          Automate Self Service New User Partner Request
*                                     01-Sep-2010      MenMee          Fix:MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): Partner_Request__c, original object: User: []
*          CR3387                     03-Sept-2010     Carmen          Add Campaign Builder, Premier, Transactional Store, Warranty Parts Info
*          CR2764                     22-Oct-2010      Carmen          Enable NetExam from Portal
*          CR5821                     21-Feb-2011      Carmen          Populate user.CompanyName field in doReuseOrCreateContact.
*          CR6637                     06-Oct-2011      Carmen          Set Emerging_Markets_Partner__c to true if account region is EC-EMEA
*          CR6728                     23-May-2012      Amir            PRM - LATAM Deal Reg Routing Issue Fix
* 13.7     CR6765                     01-Jun-2012      Krishnamoorthi  PRM - Code fix to ensure effective user provisioning for NetExam
*          CR7824                     23-Nov-2012      Sandhya         Add Enable Lead Super user
* 14.2                                24-Nov-2012      Meera           SSO - enable contact record as ready for BOOMI during user provisioning
* 14.2                                25-Nov-2012      Meera           SSO - Add new Access Enabled for Incentives
* 14.2                                14-Jan-2013      Bikram          SSO - Removed field Is Country Enabled for Incentives  
*          CR7944                     10-Jan-2013      Fenny           Permission Set 'Partner_Opportunity_Access' assignment
*                                     07-June-2013     Aman            New fields added in Partner Request and Account query from Join_Dell_PartnerDirect_Program__c TO Size_of_Customer_Base__c in copyPRFieldsToAccount function
* 14.10    CR8433                     14-Aug-2013      Vikas Gandhi    Primary Contact needs to be tagged as Checked in SFDC when in Online Registration Form User has selected Primary Contact Aligned as YES in Contact tab
* 15.07    CR8510                     26-May-2014      Devika          Added Email functionality after user is succesfully provisioned.
* 15.10    CR9838                     22-Aug-2014      Rakesh Muppiri  To address the new records, modify the provisioning code to populate the User GUID into the newly created “Partner User” field
* 16.0     CR15997   FY19-DCS-0802    05-June-2018     Pallavi         Commented NET Exam logic statements as part of NET001 story
* 16.1   CR15997,16007 FY19-DCS-0802  07-July-2018     Pallavi,Michael Removed commented NET exam logic statements as part of NET001 story
* 16.2   CR16018      FY19-DCS-0802   07-July-2018     Jatin           Commented NET exam logic statements as part of NET003 story
* 17                  FY19-0402       26-Nov-18        Michael         Net New Partner Onboarding Story 5748109
* 17.1                FY19-0402       05-Feb-2019      Varsha          Updating contact with eligibletracks 
* 17.2                FY19-0402       20-Feb-2019      Sneha           My Account Country Code changes for PAM 
* 17.3                                                                 Defect #
* 18.0        FY19-0102      5-Nov-2019     Sneha    Mail To Sponsoring Disti
*/
public class PartnerRegistrationProvisionUserCtrlExt {
    //=============================================================
    //PAGE LOAD ERROR CODES
    //=============================================================
    //public static String strMISSINGPARAM    {get{return 'MISSING_PARAM';}}      //HTTP 'id' parameter is blank
    public static String MISSING_PARAM      {get{return 'MISSING_PARAM';}}      //HTTP 'id' parameter is blank
    public static String RECORD_NOT_FOUND   {get{return 'RECORD_NOT_FOUND';}}   //no contact or partner request record with id can be found
    //public static String strRECORD_NOT_FOUND   {get{return 'RECORD_NOT_FOUND';}} 
    public static String INVALID_REC_TYPE   {get{return 'INVALID_REC_TYPE';}}   //record is partner request and not of New Partner or New User record type
    public static String COUNTRY_NOT_FOUND  {get{return 'COUNTRY_NOT_FOUND';}}  //record not associated with a country
    public static String COUNTRY_NOT_ENABLED{get{return 'COUNTRY_NOT_ENABLED';}}//record associate with a country which is not partner country
    public static String ACCT_NOT_LINKED    {get{return 'ACCT_NOT_LINKED';}}    //record is not linked to an account
    public static String ACCT_NOT_PARTNER   {get{return 'ACCT_NOT_PARTNER';}}   //record is linked to a non-partner account
    public static String CONTACT_NO_EMAIL   {get{return 'CONTACT_NO_EMAIL';}}   //contact does not have an email address
    
    //22-Jul-2009 Raymond - Added for CR1466
    public static String ACCOUNT_NOT_UPDATED{get{return 'ACCOUNT_NOT_UPDATED';}}//account not copied
    
    //public String ssoLinkMyAcctUrl {get{return constants.SSO_LINK_MY_ACCT_URL;}}
    //private C_Partner constants;
    //23-Feb-2019 Sneha
    public static String strNotValidMasterGroup{get{return 'Master Group Not Valid';}}//account not copied
    
    public static String strRelationshipNotExist {get{return 'Relationship yet to be build';}}
     public static String strEligibleTracks {get{return 'Add Eligible Tracks';}}
    
    
    
    
    public String ssoLinkMyAcctUrl {get{return PartnerConstants.SSO_LINK_MY_ACCT_URL;}}
    //public String ssoLinkMyAcctUrl {get{return null;}}
    
    public List<Partner_Track__c> listMgPartnerTrack; //#5748109: Added by Varsha
    
    //=============================================================
    //PAGE STATE VARIABLES
    //=============================================================
    public UserDataVO userData {get;set;}
    public Boolean isPartnerRequest {get;set;}
    public String errorCode {get;set;}
    public Boolean getErrorOccurred(){ return StringUtils.isNotBlank(errorCode); }
    public String ajaxError {get;set;}
    public Boolean IsPortalEnabled {get; set;}
    private String setPRError; //MenMee: Fix:MIXED_DML_OPERATION    
    private String recordId;
    public ProvisionState state {get;set;}
    // To hold the Master Group Id
    public String strMasterGroupId;
    //To hold the list of Contact Status 
    public List<String> listACS;// = new List<String>{'Customer','Active','Prospect','Marketing Suspect','INTERNAL - Crisis Mgmt'};
    //public String getPrimaryContacValue = ApexPages.currentPage().getParameters().get('isPrimaryContact');
    
    //14.2 SSO Addition
    PartnerCountry pc = new PartnerCountry();
    Map<string, Country__c> countryMap = pc.returnCountryCodeMap();
    String vendorName;
    
    // Public boolean showDealregAccess {get;set;}
    
    public class ProvisionState{
        public String guid {get;set;}
        public String enablePartnerAdmin {get;set;}
        /*Added By Michael as per Story 5748109*/
        public String enableAsPartnerGroupAdmin {get;set;}
        public Boolean AllowPartnerCentralUser {get;set;}
        public Boolean enableMDFUser {get;set;}
        public Boolean AllowProgramTracker {get;set;}
        //public Boolean EnableUserForMyRewards {get;set;}
        public Boolean EnableSPLViewWithDistipricing {get;set;}
        public Boolean SPLViewWithPartnerRecmndPrcng {get;set;}
        public Boolean EnableSPLViewWithAllCntryPrice {get;set;}
        public Boolean AllowRFPandProposalExpressTool {get;set;}
        /*Above added by Michael*/
        public String enableLeadSuperUser {get;set;} // CR 7824 - Add Enable Lead Super user
        public String enablePartnerDealRegistration {get;set;}
        public String strEnableCreateOSCQuote {get;set;}
        public String strEnableCreateOSCOrder {get;set;}
        public String strEnableCreateOSCSpQuote {get;set;}
        public String strEnableCreateOSCSpOrder {get;set;}
        public Boolean contactIsCampaignBuilder {get;set;}
        public Boolean contactIsPremier {get;set;}
        public Boolean contactIsTransactionalStore {get;set;}
        public Boolean contactIsWarrantyPartsInfo {get;set;}
        public Boolean contactIsEnabledForIncentives {get;set;}     
        public Boolean accountIsEnabledForIncentives{get;set;}
        public Boolean countryIsEnabledForIncentives{get;set;}
        public Boolean isSpecialJobRole{get;set;}
        //15.3 CMAP
        public String enablePartnerLeadManagement{get;set;}
        //public Boolean isalowedLeadMAnagement{get;set;}
        
        public Contact contact {get;set;}
        public User user {get;set;}
        public Partner_Request__c request {get;set;}
        
        //Raymond 20090918: Added for CR1790
        public boolean enableModelNRebates {get;set;}       //Rebate flag for user
        public boolean accountIsRebatePartner{get; set;}    //is Rebate enabled for Partner Accou
        
        
        
    }
    
    
    /**
* Sole constructor
*/
    public PartnerRegistrationProvisionUserCtrlExt(){
        
        // showDealregAccess  = true;
        //this.constants = C_Partner.getInstance();
        this.recordId = PageUtils.param('id');
        //Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        this.state = new ProvisionState();
        
        listACS = System.Label.Active_Contact_Status.split(';');
        System.debug('listACS'+listACS);
        
    }
    
    /**
* Executes one time when the screen loads.  Differs from the constructor
* in this method returns a PageReference.
*/
    public PageReference doOnLoad(){
        
        isPortalEnabled = false;    //CR2087
        
        if(StringUtils.isBlank(recordId)){
            return error(MISSING_PARAM);
        }
        
                    this.state.AllowProgramTracker = false;
                    this.state.AllowRFPandProposalExpressTool = false;
                    this.state.contactIsPremier = false;
                    this.state.EnableSPLViewWithAllCntryPrice = false;
                    this.state.SPLViewWithPartnerRecmndPrcng = false;
                    this.state.EnableSPLViewWithDistipricing = false;
                    //this.state.EnableUserForMyRewards = false;
                    this.state.AllowPartnerCentralUser = false;
                    this.state.enableMDFUser = false;
                    this.state.enableModelNRebates = false;
                    this.state.strEnableCreateOSCQuote  = 'true';
                    this.state.strEnableCreateOSCOrder = 'true';
                    this.state.strEnableCreateOSCSpQuote = 'true';
                    this.state.strEnableCreateOSCSpOrder = 'true';
                
        //get the first three characters of the ID passed to this controller
        final String recordIdPrefix = StringUtils.defaultString(StringUtils.substring(recordId, 0, 3));
        
        // showDealregAccess   = findDealRegAccess(recordIdPrefix,recordId);
        System.debug('recordIdPrefix.....'+recordIdPrefix);
        
        try{
            //determine if this "user provisioning" originated from a Contact or a Partner Request record
            this.state.countryIsEnabledForIncentives = false;
            if(recordIdPrefix.equals(Partner_Request__c.sObjectType.getDescribe().getKeyPrefix())){
                //===============
                // Partner Request
                //===============
                isPartnerRequest = true;
                
                //CR2087
                List<User> userList = [SELECT IsPortalEnabled FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true AND contactId != null];
                if (userList.size() > 0) isPortalEnabled = userList[0].IsPortalEnabled;
                System.debug('Portal: '+UserInfo.getName() + '-'+isPortalEnabled);
                //CR2087-end
                
                //CR1466 Raymond 20090716 -
                copyPRFieldsToAccount(recordId);                
                
                userData = new UserDataVOPartnerRequest(this);
                System.debug('doOnLoad 1.....');
                userData.load(recordId);
                this.state.request = (Partner_Request__c)userData.record();
                this.state.enablePartnerAdmin = 'true';
                this.state.enableAsPartnerGroupAdmin = 'true';
                this.state.enableLeadSuperUser = ''+this.state.request.Enable_as_Lead_Super_User__c;//CR 7824 - Add Enable Lead Super user
                this.state.enablePartnerDealRegistration = ''+this.state.request.Feature_Request_Deal_Registration__c;
                this.state.strEnableCreateOSCQuote= ''+this.state.request.OSC_Create_Quote__c;
                this.state.strEnableCreateOSCSpQuote= ''+this.state.request.OSC_Specialty_Product_Create_Quote__c;
                this.state.strEnableCreateOSCOrder= ''+this.state.request.OSC_Create_Order__c;
                this.state.strEnableCreateOSCSpOrder= ''+this.state.request.OSC_Specialty_Product_Create_Order__c;
                //Meera-Added as part of 15.3 CMAP
                this.state.enablePartnerLeadManagement = ''+this.state.request.Feature_Request_Lead_Management__c;
                this.state.contactIsCampaignBuilder = false;//this.state.request.Contact__r.Campaign_Builder__c;
                /*Below fields Added by Michael as per Story 5748109*/
                system.debug('email='+this.state.request.email__c);
                system.debug('request'+this.state.request);
                //system.debug('email='+this.state.request.email__c);
                List<Contact> conlist = [select id, name, email,Status__c, Allow_Program_Tracker__c, Allow_RFP_and_Proposal_Express_Tool__c,Premier_Partner__c,AccountId,EligibleTracks__c,
                                         Enable_SPL_View_with_All_country_Price__c, SPL_view_with_partner_recommeded_pricing__c,Is_MDF_User__c,Is_Rebate_User__c,
                                         Enable_SPL_view_with_Disti_pricing__c, Allow_Partner_Central_User__c,Partner_User_Partner_Admin__c,Partner_User_Lead_Management__c,
                                         Enable_as_Partner_Group_Administrator__c,Partner_User_Lead_Super_User__c,Partner_User_Deal_Registration__c,Transactional_Store__c,
                                         Warranty_Parts_Info__c,Campaign_Builder__c,
                                         OSC_Create_Order__c,OSC_Create_Quote__c,OSC_Specialty_Product_Create_Order__c,OSC_Specialty_Product_Create_Quote__c
                                         from contact where
                                         email =: this.state.request.email__c 
                                         AND Status__c IN: listACS 
                                         limit 1];//Enable_User_for_MyRewards__c, removed from the query
                
                
                
                if(this.state.request.account__r.Master_Group_Id__c != null && this.state.request.account__r.RecordType.Name == System.Label.Partner_Account){
                        strMasterGroupId         = this.state.request.account__r.Master_Group_Id__c;
                 }
                else if(this.state.request.account__c != null && this.state.request.account__r.RecordType.Name == System.Label.Master_Account_Record_Type_Name ){
                        strMasterGroupId           = this.state.request.account__c;
                }
                else{
                     return error(strRelationshipNotExist);
                }
                
                System.debug('strMasterGroupId'+strMasterGroupId);
                if(conlist.size() > 0 && String.isNotBlank(strMasterGroupId) && conlist[0].AccountId != strMasterGroupId){
                        return error(strNotValidMasterGroup);
                } 
                
                else if(conlist.size() > 0 && String.isNotBlank(strMasterGroupId) && conlist[0].AccountId == strMasterGroupId){
                        system.debug('Contact-->'+conlist[0]);
                        this.state.AllowProgramTracker = conlist[0].Allow_Program_Tracker__c;
                        this.state.contactIsPremier = conlist[0].Premier_Partner__c;
                        this.state.AllowRFPandProposalExpressTool = conlist[0].Allow_RFP_and_Proposal_Express_Tool__c;
                        this.state.EnableSPLViewWithAllCntryPrice = conlist[0].Enable_SPL_View_with_All_country_Price__c;
                        this.state.SPLViewWithPartnerRecmndPrcng = conlist[0].SPL_view_with_partner_recommeded_pricing__c;
                        this.state.EnableSPLViewWithDistipricing = conlist[0].Enable_SPL_view_with_Disti_pricing__c;
                        //this.state.EnableUserForMyRewards = conlist[0].Enable_User_for_MyRewards__c;
                        this.state.AllowPartnerCentralUser = conlist[0].Allow_Partner_Central_User__c; 
                        this.state.enableMDFUser = conlist[0].Is_MDF_User__c;
                        this.state.enableModelNRebates = conlist[0].Is_Rebate_User__c;
                        system.debug('Inside doload->if');
                        this.state.enablePartnerAdmin = String.valueof(conlist[0].Partner_User_Partner_Admin__c);
                        this.state.enablePartnerLeadManagement =  String.valueof(conlist[0].Partner_User_Lead_Management__c);
                        this.state.enableAsPartnerGroupAdmin =  String.valueof(conlist[0].Enable_as_Partner_Group_Administrator__c);
                        this.state.enableLeadSuperUser =  String.valueof(conlist[0].Partner_User_Lead_Super_User__c);
                        this.state.enablePartnerDealRegistration = String.valueof(conlist[0].Partner_User_Deal_Registration__c);
                     //   this.state.strEnableCreateOSCQuote = String.valueof(conlist[0].OSC_Create_Quote__c);
                      //  this.state.strEnableCreateOSCSpQuote = String.valueof(conlist[0].OSC_Specialty_Product_Create_Quote__c);
                      //  this.state.strEnableCreateOSCOrder = String.valueof(conlist[0].OSC_Create_Order__c);
                       // this.state.strEnableCreateOSCSpOrder = String.valueof(conlist[0].OSC_Specialty_Product_Create_Order__c);
                        this.state.contactIsTransactionalStore = conlist[0].Transactional_Store__c;
                        this.state.contactIsWarrantyPartsInfo = conlist[0].Warranty_Parts_Info__c;
                        this.state.contactIsCampaignBuilder =  conlist[0].Campaign_Builder__c;
                    }
                else if(this.state.request.Eligible_Partner_Tracks__c!= null){
                    System.debug('this.state.request::'+this.state.request);
                    this.state.AllowProgramTracker = this.state.request.Program_Tracker__c;
                    this.state.AllowRFPandProposalExpressTool = this.state.request.RFP_Proposal_Express_Tool__c;
                    this.state.AllowPartnerCentralUser = this.state.request.Partner_Central__c;
                    this.state.contactIsPremier  = this.state.request.Enable_Premier_Pages_access_Flag__c;
                    this.state.enablePartnerAdmin = String.valueOf(this.state.request.Enable_as_Partner_Admin__c);
                    this.state.enableAsPartnerGroupAdmin = String.valueOf(this.state.request.Enable_Partner_Group_Admin__c);
                    this.state.enablePartnerDealRegistration = String.valueOf(this.state.request.Feature_Request_Deal_Registration__c);
                    this.state.strEnableCreateOSCQuote = String.valueOf(this.state.request.OSC_Create_Quote__c);
                    this.state.strEnableCreateOSCSpQuote = String.valueOf(this.state.request.OSC_Specialty_Product_Create_Quote__c);
                    this.state.strEnableCreateOSCOrder = String.valueOf(this.state.request.OSC_Create_Order__c);
                    this.state.strEnableCreateOSCSpOrder = String.valueOf(this.state.request.OSC_Specialty_Product_Create_Order__c);                    
                    this.state.enablePartnerLeadManagement = String.valueOf(this.state.request.Feature_Request_Lead_Management__c);
                    this.state.enableLeadSuperUser = String.valueOf(this.state.request.Enable_as_Lead_Super_User__c);
                    System.debug('this.state.enablePartnerAdmin::'+this.state.request.Enable_as_Partner_Admin__c);
                    System.debug('this.state.enablePartnerAdmin::'+this.state.enablePartnerAdmin);
                    this.state.enableMDFUser = this.state.request.Feature_Request_MDF__c;
                    this.state.enableModelNRebates = this.state.request.Feature_Request_Rebates__c;
                }
                //this.state.contactIsTransactionalStore = this.state.request.Contact__r.Transactional_Store__c;
               // this.state.contactIsWarrantyPartsInfo = this.state.request.Contact__r.Warranty_Parts_Info__c;
                //14.2 SSO additions
                this.state.contactIsEnabledForIncentives = this.state.request.Is_Enabled_for_Incentives__c;             
                this.state.accountIsEnabledForIncentives = this.state.request.account__r.Is_Enabled_for_Incentives__c;
                System.debug('Request Account Country Code::'+state.request.account__r.Account_Country_Code__c);
                if(String.isNotBlank(this.state.request.account__r.Account_Country_Code__c)){
                    Country__c country = countryMap.get(StringUtils.uppercase((this.state.request.account__r.Account_Country_Code__c).trim()));
                    if(country != null){
                        vendorName = country.Inc_Vendor_Name__c;
                        if ((vendorName == 'Partner Direct Rewards Center') || (vendorName == 'Partner Advantage') ||  (vendorName == 'Dell Achievers')){                       
                            this.state.countryIsEnabledForIncentives = true;
                        }else{
                            this.state.countryIsEnabledForIncentives = false;
                        }                 
                    } 
                }
                else{
                    return error(COUNTRY_NOT_FOUND);
                }
                //Meera:15.3 CMAP Addition- Check whether this user can be permitted for lead management
                //for OEM Accounts
                //Commented By : Sneha
                // Lead Management doesn't require above checks as per PAM
               /* if(this.state.request.account__r.Sales_Channel__r != null &&
                   (this.state.request.account__r.Sales_Channel__r.Name).contains('OEM') && userData.getCountry().Lead_Management_Enabled_for_OEM__c == 'Yes' && 
                   this.state.request.account__r.Partner_Relationship__c != null && (userData.getCountry().Partner_Relationship_for_OEM__c.contains(this.state.request.account__r.Partner_Relationship__c) || userData.getCountry().Partner_Relationship_for_OEM__c.contains( 'All'))){
                       this.state.isalowedLeadMAnagement = true;
                   }
                
                //for other Accounts                    
                else if(userData.getCountry().Lead_Management_Enabled__c == 'Yes' &&this.state.request.account__r.Partner_Relationship__c != null && 
                        (userData.getCountry().Partner_Relationship__c.contains(this.state.request.account__r.Partner_Relationship__c) || userData.getCountry().Partner_Relationship__c.contains('All'))){
                            this.state.isalowedLeadMAnagement = true;
                            System.debug('Inside non OEM');
                        }
                  */
                //this.state.isalowedLeadMAnagement = true;
                system.debug('***delreg' +state.request.Feature_Request_Deal_Registration__c);
                //System.debug('lead Management:'+this.state.isalowedLeadMAnagement);
                System.debug('lead Management:'+this.state.enableLeadSuperUser);
                        
                //}
                /*System.debug(userData.getCountry().Lead_Management_Enabled__c == 'Yes');
System.debug(this.state.contact);
System.debug(this.state.request.Contact__c);
System.debug(this.state.contact.account);
System.debug(this.state.contact.account.Partner_Relationship__c);
System.debug(this.state.contact.account.Partner_Relationship__c != null);
System.debug(userData.getCountry());
System.debug(userData.getCountry().Partner_Relationship__c.contains('All'));
System.debug('country:'+userData.getCountry());
System.debug(userData.getCountry().Partner_Relationship__c);
System.debug(this.state.isalowedLeadMAnagement);*/
                System.debug('country:'+userData.getCountry());
                this.state.isSpecialJobRole = checkSpecialJobTitle(this.state.request.Job_Title__c);
                //if the job title is of secial job title enable him as partner admin
                if(this.state.isSpecialJobRole){
                    this.state.enablePartnerAdmin = ''+this.state.isSpecialJobRole;
                }
                
                //Raymond 20090918: Added for CR1790
                //this.state.enableModelNRebates = this.state.request.Feature_Request_Rebates__c;
                //Commented by Varsha
                //this.state.accountIsRebatePartner = this.state.request.Account__r.Is_Rebate_Partner__c ;
                
            } 
            else if(recordIdPrefix.equals(Contact.sObjectType.getDescribe().getKeyPrefix())){
                //===============
                // Contact
                //===============
                isPartnerRequest = false;
                userData = new UserDataVOContact(this);
                userData.load(recordId);
                this.state.contact = (Contact)userData.record();
                this.state.contactIsCampaignBuilder = this.state.contact.Campaign_Builder__c;
                this.state.contactIsPremier = this.state.contact.Premier_Partner__c;
                this.state.contactIsTransactionalStore = this.state.contact.Transactional_Store__c;
                this.state.contactIsWarrantyPartsInfo = this.state.contact.Warranty_Parts_Info__c;
                //14.2 SSO Additions
                this.state.contactIsEnabledForIncentives = this.state.contact.Is_Enabled_for_Incentives__c;             
                this.state.accountIsEnabledForIncentives = this.state.contact.account.Is_Enabled_for_Incentives__c;
                if(String.isNotBlank(this.state.contact.account.Account_Country_Code__c)){
                    Country__c country = countryMap.get(StringUtils.uppercase((this.state.contact.account.Account_Country_Code__c).trim()));
                    if(country != null){
                        vendorName = country.Inc_Vendor_Name__c;
                        if ((vendorName == 'Partner Direct Rewards Center') || (vendorName == 'Partner Advantage') ||  (vendorName == 'Dell Achievers')){                       
                            this.state.countryIsEnabledForIncentives = true;
                        }else{
                            this.state.countryIsEnabledForIncentives = false;
                        }
                    } 
                }
                else{
                    return error(COUNTRY_NOT_FOUND);
                }
                //Meera:15.3 CMAP Addition- Check whether this user can be permitted for lead management
                //for OEM Accounts
                System.debug(this.state.contact.account.Partner_Relationship__c);
                System.debug('value:'+userData.getCountry().Partner_Relationship_for_OEM__c);
                //System.debug(userData.getCountry().Partner_Relationship_for_OEM__c.contains(this.state.contact.account.Partner_Relationship__c));
                //System.debug(userData.getCountry().Partner_Relationship_for_OEM__c.contains('All'));

                /*if(this.state.contact.account.Sales_Channel__r != null && (this.state.contact.account.Sales_Channel__r.Name).contains('OEM') && userData.getCountry().Lead_Management_Enabled_for_OEM__c == 'Yes' && 
                   this.state.contact.account.Partner_Relationship__c != null && (userData.getCountry().Partner_Relationship_for_OEM__c.contains(this.state.contact.account.Partner_Relationship__c) || userData.getCountry().Partner_Relationship_for_OEM__c.contains('All'))){
                       this.state.isalowedLeadMAnagement = true;
                       System.debug('Inside');
                   }
                
                //for other Accounts
                
                else if(userData.getCountry().Lead_Management_Enabled__c == 'Yes' && this.state.contact.account.Partner_Relationship__c != null &&
                        (userData.getCountry().Partner_Relationship__c.contains(this.state.contact.account.Partner_Relationship__c) || userData.getCountry().Partner_Relationship__c.contains('All'))){
                            this.state.isalowedLeadMAnagement = true;
                            System.debug('Inside1');
                        }
                */
                //}
                            
                this.state.isSpecialJobRole = checkSpecialJobTitle(this.state.contact.Title);
                //if the job title is of secial job title enable him as partner admin
                if(this.state.isSpecialJobRole){
                    this.state.enablePartnerAdmin = ''+this.state.isSpecialJobRole;
                }
                System.debug('doOnLoad 2.....');
            } 
            else {
                //===============
                // Neither
                //===============
                return error(RECORD_NOT_FOUND);
            }
        } catch (NotLinkedToAccountException e){  return error(ACCT_NOT_LINKED);
                                               } catch (CountryNotFoundException e){  return error(COUNTRY_NOT_FOUND);
                                                                                   } catch (CountryNotEnabledException e){  return error(COUNTRY_NOT_ENABLED);
                                                                                                                         } catch (ContactNoEmailException e){ return error(CONTACT_NO_EMAIL);
                                                                                                                                                            } catch (QueryException e){ return error(RECORD_NOT_FOUND);
                                                                                                                                                                                      }
        //22-Jul-2009 Raymond - Added for CR1466
        catch (FailedToCopyPRFieldsToAccntException e) {  return error(ACCOUNT_NOT_UPDATED);
                                                       }
        
        return userData.validate();
    }
    
    public PageReference doUpdateContactProvisionedFlags(){
        final Contact contactRecord = state.contact;
        if(contactRecord == null){
            return ajaxError('Invalid State');
        }
        if(contactRecord.Provisioned_in_Salesforce_on__c == null){
            contactRecord.Provisioned_in_Salesforce_on__c = Datetime.now();
        }
        contactRecord.Partner_My_Account_GUID__c = state.guid;
        contactRecord.Campaign_Builder__c = state.contactIsCampaignBuilder;
        contactRecord.Premier_Partner__c = state.contactIsPremier;
        /*Below fields Added by Michael as per Story 5748109*/
        contactRecord.Allow_Partner_Central_User__c = state.AllowPartnerCentralUser;
        contactRecord.Allow_Program_Tracker__c = state.AllowProgramTracker;
        contactRecord.Is_MDF_User__c = state.enableMDFUser;
        //Added by Varsha
        contactRecord.Is_Rebate_User__c = state.enableModelNRebates;
        system.debug('AllowProgramTracker '+this.state.AllowProgramTracker);
        contactRecord.Allow_RFP_and_Proposal_Express_Tool__c = state.AllowRFPandProposalExpressTool;
        contactRecord.Enable_SPL_View_with_All_country_Price__c = state.EnableSPLViewWithAllCntryPrice;
        contactRecord.SPL_view_with_partner_recommeded_pricing__c = state.SPLViewWithPartnerRecmndPrcng;
        contactRecord.Enable_SPL_view_with_Disti_pricing__c = state.EnableSPLViewWithDistipricing;
        //contactRecord.Enable_User_for_MyRewards__c = state.EnableUserForMyRewards;
        //Above fields added by Michael
        contactRecord.Transactional_Store__c = state.contactIsTransactionalStore;
        contactRecord.Warranty_Parts_Info__c = state.contactIsWarrantyPartsInfo;
        //14.2 SSO Modifications
        System.debug('state.contactIsEnabledForIncentives:'+state.contactIsEnabledForIncentives);
        contactRecord.Is_Enabled_for_Incentives__c = state.contactIsEnabledForIncentives;
         //#5748109: Added by Varsha
        system.debug('groupadmin:'+this.state.enableAsPartnerGroupAdmin );
        if(this.state.enableAsPartnerGroupAdmin  == 'true'){
            String strEligibleTracks = '';
            listMgPartnerTrack = [SELECT id, Master_Group_Id__c FROM Partner_Track__c WHERE Master_Group_Id__c =: state.contact.AccountId];
            if(listMgPartnerTrack.size()>0){
                for(partner_track__c pt: listMgPartnerTrack) {
                    if(String.isNotBlank(strEligibleTracks)){
                        strEligibleTracks +=';'+pt.id; 
                    }
                    else{
                        strEligibleTracks += pt.id;  
                    }
                }
                contactRecord.EligibleTracks__c = strEligibleTracks;
                contactRecord.Preferred_Track__c = listMgPartnerTrack[0].id;
                contactRecord.Selected_Track__c = contactRecord.Preferred_Track__c;
            }
        }//Varsha's Code End
        
        try{
            update contactRecord;
        }catch(Exception e){ return ajaxError(e.getMessage());
                           }
        //------Added code as per CR#1389, R10.5 ------
        String recordIdPrefixvalue = StringUtils.defaultString(StringUtils.substring(recordId, 0, 3));
        if(recordIdPrefixvalue.equals(Contact.sObjectType.getDescribe().getKeyPrefix()) || Test.isRunningTest()){
            try{
                List<String> stringList=new List<String>{contactRecord.id};
                    //future-method call for Partner profile integartion
                    PartnerProfileIntegration.integratePartnerData(stringList);
                
                //method to Hit New SQl DB 2016 End point
                //CR 13831
                PartnerProfileIntegration.sendDatatoDpApiFromFuture(stringList);                
                //end of  CR 13831 changes
                
            }catch(Exception e){  return ajaxError('Failed to send data to Partner Profile. ['+ e.getMessage()+ ']');
                               }
        }
        //-----------------------------------------------
        return ajaxSuccess();
    }
    
    /**
* Creates a contact if one doesn't exist
* -or-
* Update contact if does exist
*/
    public PageReference doReuseOrCreateContact(){
        final Partner_Request__c request = state.request;
        String companyName;
        Contact contact = state.contact; 
        try{
            if( !isPartnerRequest || request == null || request.account__c == null || StringUtils.isBlank(request.Email__c) || contact != null){
                
                return ajaxError('Invalid State');
                
            }
        }catch(Exception ex){}
        try{
             
            contact = [SELECT
                id, Title, Status__c, Salutation, RecordTypeId, Phone, MobilePhone, Job_Function__c,Job_Function_Role__c, MailingStreet,AccountId,
                MailingState, MailingPostalCode, MailingCountry, MailingCity, LastName, account.Forgot_Password_Request_Id__c,account.Name,
                HomePhone, FirstName, Fax, Email_Opt_In__c, Email, Provisioned_in_Salesforce_on__c,Location_Of_User__c,
                Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_Parts_Info__c,Is_Rebate_User__c,
                Is_Enabled_for_Incentives__c, account.Partner_Registration__r.Org_Country__r.User_Language_Locale_Key__c,
                Allow_Partner_Central_User__c, Allow_Program_Tracker__c, Allow_RFP_and_Proposal_Express_Tool__c, Enable_SPL_View_with_All_country_Price__c, Is_MDF_User__c, 
                SPL_view_with_partner_recommeded_pricing__c, Enable_SPL_view_with_Disti_pricing__c, 
                account.Partner_Registration__r.Org_Country__r.Dell_Online_Country_Code__c,account.Partner_Registration__r.Country__r.Dell_Online_Country_Code__c,account.Partner_Registration__r.Country__r.User_Language_Locale_Key__c,
                Enable_as_Partner_Group_Administrator__c,Other_Job_Function_Category__c,EligibleTracks__c,Preferred_Track__c,Selected_Track__c,Primary_Contact__c
                FROM Contact WHERE email =: request.email__c AND Status__c IN: listACS AND AccountId =: strMasterGroupId Limit 1];//Removed  "accountid = :request.account__c"  Enable_User_for_MyRewards__c,
        }catch(Exception e){
            contact = new Contact();
        }
        if(contact.Provisioned_in_Salesforce_on__c == null){
            contact.Provisioned_in_Salesforce_on__c = Datetime.now();
        }
        if(contact.id == null){
            contact.Salutation          = request.Salutation__c;
            contact.FirstName           = request.First_Name__c;
            contact.LastName            = request.Last_Name__c;
            contact.Email               = request.Email__c;
            contact.Title               = request.Job_Title__c;
            contact.Phone               = request.Phone__c;
            contact.MobilePhone         = request.Mobile__c;
            contact.Fax                 = request.Fax__c;
            contact.MailingStreet       = request.Address_Line_1__c +
                (StringUtils.isBlank(request.Address_Line_2__c) ? '' : '\n' + request.Address_Line_2__c ) +
                (StringUtils.isBlank(request.Address_Line_3__c) ? '' : '\n' + request.Address_Line_3__c );
            contact.MailingCity         = request.City__c;
            contact.MailingState        = request.State__c;
            contact.MailingPostalCode   = request.Postal_Code__c;
            contact.MailingCountry      = request.Country__r.Name;
            contact.Email_Opt_In__c     = (request.Newsletter_Opt_In__c ? 'Yes' : 'No');
            //contact.EMEA_Preferred_Contact_Language__c = request.Preferred_Language__c;
            contact.Job_Function__c     = request.Job_Category__c;
            contact.Job_Function_Role__c = request.Job_Title__c;   
            contact.Other_Job_Function_Category__c= request.Other_Job_Category__c;
            contact.Facebook__c = request.Facebook__c;
            contact.Instagram__c = request.Instagram__c;
            contact.Corporate_Twitter__c = request.Corporate_Twitter__c;
            contact.LinkedInProfile__c = request.LinkedInProfile__c;
            contact.Twitter__c = request.Personal_Twitter__c;
            contact.Location_Of_User__c = request.Location_Of_User__c;
            //contact.AccountId           = request.account__c; //Replaced by below line as part of Story 5748109
            // Replaced as part of story create/edit contact
            if(request.account__r.Master_Group_Id__c != null && request.account__r.RecordType.Name == System.Label.Partner_Account){
               contact.AccountId           = request.account__r.Master_Group_Id__c;
               if(String.isNotBlank(request.account__r.Master_Group_Id__r.Name)){
                  companyName        = request.account__r.Master_Group_Id__r.Name; 
               }
               
            }
            else if(request.account__c != null && request.account__r.RecordType.Name == System.Label.Master_Account_Record_Type_Name ){
              contact.AccountId           = request.account__c;
              if(String.isNotBlank(request.account__r.Name)){
                  companyName        = request.account__r.name; 
              }
             
            }
            else{
                return ajaxError('Relationship is yet to be build.');
            }
            //contact.AccountId           = request.account__r.Master_Group_Id__c;
            contact.Partner_My_Account_GUID__c = state.guid;
            if (contact.MailingCountry == null) {
                if (request.Account__c != null) {   contact.MailingCountry = request.Account__r.Account_Country__c;
                                                } else {
                                                    contact.MailingCountry = request.Country__r.Name;
                                                }
            }
        }
        
        contact.Campaign_Builder__c = state.contactIsCampaignBuilder;
        contact.Premier_Partner__c = state.contactIsPremier;
        /*Added By Michael as per Story 5748109*/
        System.debug('state attributes:'+state.AllowPartnerCentralUser+state.AllowProgramTracker+state.AllowRFPandProposalExpressTool);
        contact.Allow_Partner_Central_User__c = state.AllowPartnerCentralUser;
        contact.Allow_Program_Tracker__c = state.AllowProgramTracker;
        contact.Is_MDF_User__c = state.enableMDFUser;
        system.debug('inside doReuseOrCreateContact, AllowProgramTracker '+this.state.AllowProgramTracker);
        contact.Allow_RFP_and_Proposal_Express_Tool__c = state.AllowRFPandProposalExpressTool; 
        contact.Enable_SPL_View_with_All_country_Price__c = state.EnableSPLViewWithAllCntryPrice; 
        contact.SPL_view_with_partner_recommeded_pricing__c = state.SPLViewWithPartnerRecmndPrcng; 
        contact.Enable_SPL_view_with_Disti_pricing__c = state.EnableSPLViewWithDistipricing; 
        //contact.Enable_User_for_MyRewards__c = state.EnableUserForMyRewards; 
        //Added By Michael
        contact.Transactional_Store__c = state.contactIsTransactionalStore;
        contact.Warranty_Parts_Info__c = state.contactIsWarrantyPartsInfo;
        
        //Raymond 20090918: Added for CR1790
        contact.Is_Rebate_User__c = state.enableModelNRebates;
        // Added as part of PAM Changes
        //contact.EligibleTracks__c = request.Eligible_Partner_Tracks__c;  //Replaced by below line as part of Story 5748109
        System.debug('request.Eligible_Partner_Tracks__c::'+request.Eligible_Partner_Tracks__c);
        System.debug('request.account__r.Partner_Track__c::'+request.account__r.Partner_Track__c);
        System.debug('contact.EligibleTracks__c::'+contact.EligibleTracks__c);
        if(request.Eligible_Partner_Tracks__c !=NULL && String.isNotBlank(request.Eligible_Partner_Tracks__c)){
            if(String.isNotBlank(contact.EligibleTracks__c) && request.Eligible_Partner_Tracks__c.contains(';')){
                System.debug('540');
                for(String newPT : (request.Eligible_Partner_Tracks__c.trim().split(';'))){
                    System.debug('newPT::'+newPT);
                    if(!(contact.EligibleTracks__c).contains(newPT)){
                        contact.EligibleTracks__c = contact.EligibleTracks__c+';'+newPT;
                    }
                    if(contact.Preferred_Track__c!= null && !newPT.containsOnly(String.valueOf(contact.Preferred_Track__c))){
                        contact.Preferred_Track__c = Id.valueof(String.valueOf(request.Eligible_Partner_Tracks__c).split(';')[0]);                
                    }
                    else{
                        contact.Preferred_Track__c = Id.valueOf(String.valueOf(request.Eligible_Partner_Tracks__c).split(';')[0]);
                    }
                }
            }
            else{
                contact.EligibleTracks__c = String.valueOf(request.Eligible_Partner_Tracks__c);
                if(String.valueOf(request.Eligible_Partner_Tracks__c).contains(';')){
                    contact.Preferred_Track__c = Id.valueOf(String.valueOf(request.Eligible_Partner_Tracks__c).trim().split(';')[0]);
                }
                else{
                    contact.Preferred_Track__c = Id.valueOf(String.valueOf(request.Eligible_Partner_Tracks__c)); 
                }
                
            }
            
        }
         //#5748109: Added by Varsha
        else if(this.state.enableAsPartnerGroupAdmin  == 'true' && request.account__r.Partner_Track__c!= null){
            System.debug('Group Admin');
            String strEligibleTracks = '';
            listMgPartnerTrack = [SELECT id, Master_Group_Id__c FROM Partner_Track__c WHERE Master_Group_Id__c =: contact.AccountId];
            if(listMgPartnerTrack.size()>0){
                for(partner_track__c pt: listMgPartnerTrack) {
                    if(String.isNotBlank(strEligibleTracks)){
                        strEligibleTracks +=';'+pt.id; 
                    }
                    else{
                        strEligibleTracks += pt.id;  
                    }
                }
                contact.EligibleTracks__c = strEligibleTracks;
                contact.Preferred_Track__c = listMgPartnerTrack[0].id;
            }
        }//Varsha's Code End
        else if(String.isNotBlank(contact.EligibleTracks__c) && this.state.enableAsPartnerGroupAdmin  == 'false' && request.account__r.Partner_Track__c!= null){
            System.debug('Not a group Admin');
            if(!contact.EligibleTracks__c.contains(String.valueOf(request.account__r.Partner_Track__c))){
                contact.EligibleTracks__c = contact.EligibleTracks__c+';'+String.valueOf(request.account__r.Partner_Track__c);//apend
            }
            
        }
        else if(request.account__r.Partner_Track__c!= null && request.account__r.RecordType.Name == System.Label.Partner_Account){
            contact.EligibleTracks__c = String.valueOf(request.account__r.Partner_Track__c);
            contact.Preferred_Track__c = request.account__r.Partner_Track__c;
        }
        else{
                return ajaxError('Relationship is yet to be build.');
            }
        System.debug('request.Eligible_Partner_Tracks__c'+request.Eligible_Partner_Tracks__c);
        /*
if(String.isNotBlank(request.Eligible_Partner_Tracks__c)){
if(String.valueOf(request.Eligible_Partner_Tracks__c).contains(';')){
contact.Preferred_Track__c = Id.valueof(String.valueOf(request.Eligible_Partner_Tracks__c).split(';')[0]);                
}
else{
contact.Preferred_Track__c = Id.valueOf(String.valueOf(request.Eligible_Partner_Tracks__c));
}
}
*/
        if(contact.Selected_Track__c==NULL){
        contact.Selected_Track__c = contact.Preferred_Track__c;//Added by Michael Story 5748109
        }
        
        //14.2 SSO Modificatin
        contact.Is_Enabled_for_Incentives__c = state.contactIsEnabledForIncentives;
        // CR6728 [BEGIN]: Populate Contact MailingCountry field with Account country OR Partner Request country 
        
        // CR6728 [END]
        // START R14.10 CR8433 Added by Vikas: Primary Contact needs to be tagged as Checked in SFDC when in Online Registration Form User has selected Primary Contact Aligned as YES in Contact tab
        //  if(!PartnerSelfServiceMyProfileCtrlExt.StopAutomaticPrimaryContact){
        /*if(getPrimaryContacValue == 'FALSE' || getPrimaryContacValue == NULL ){
request.Primary_Contact_Aligned__c = 'No';
contact.Primary_Contact__c = false;
}else if(request.Primary_Contact_Aligned__c == 'Yes')
contact.Primary_Contact__c = true; */
        // END R14.10 CR8433 Added by Vikas
        // }
        /*(  if(request.Primary_Contact_Aligned__c == 'No'|| request.Primary_Contact_Aligned__c == null){
contact.Primary_Contact__c = false;
System.debug('----------------->>>>>>>>>>>> contact.Primary_Contact__c 4022 : '+ contact.Primary_Contact__c );
}*/
        if(request.Primary_Contact_Aligned__c == 'Yes'){
            contact.Primary_Contact__c = true;
        }

        
        try{
            system.debug('contact.AccountId = ' + contact.AccountId);
            if(contact.id == null){  insert contact;
                                  } else {
                                      update contact;
                                  }
            System.debug('----------------->>>>>>>>>>>> Contact 428 : '+ contact);
            if(contact.Primary_Contact__c){
                //Added by Vikas on 16 Sep 2013: Defect 80358
                Account acc = new Account(id = request.account__c); 
                acc.Primary_Contact__c = contact.id;
                update acc;
                System.debug('_______Account: '+acc);
                //Ended by Vikas on 16 Sep 2013: Defect 80358
            }
            System.debug('----------Contact.id:'+contact);
        }catch(Exception e){
            //CR2087
            if (!isPortalEnabled) {
                return ajaxError(e.getMessage());
            }
            else {
                //MenMee: Fix:MIXED_DML_OPERATION               
                //setIncompleteForRequestWithReason(request.Id, e.getMessage());
                setPRError = e.getMessage(); 
                return ajaxError(System.label.New_User_Error_message);
            }           
        }
        //CR5821: Populate user.CompanyName field
        if (request.account__c != null){
            System.debug('request.account__c');
            if(String.isNotBlank(contact.accountId)) {
                //CR 6765: Passing Account Id 
                //Account account = new Account();
                Account account = new Account(id = request.account__c);
                if(String.isNotBlank(companyName)){
                    account.Name = companyName;
                    contact.account = account;
                }else{
                    account.Name = request.account__r.name;
                    contact.account = account;
                }
                
            }
            else {
                System.debug('companyName'+companyName);
                if(String.isNotBlank(companyName)){
                    contact.account.Name = companyName;
                }else{
                    contact.account.Name = request.account__r.name;
                }
                
            }
            
        }
        
        state.contact = contact;
        
        /*String emailBody = getForgotPWEmailTemplate(state.contact);
//EmailTemplate et=[Select id from EmailTemplate where name='ForgotPassword Email Template'];
List<OrgWideEmailAddress> orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox'];
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setTargetObjectId(state.contact.Id);
List<String> sendTo = new List<String>();
sendTo.add(request.Email__c);
mail.setToAddresses(sendTo);
List<String> ccTo = new List<String>();
ccTo.add('Channel_STG@dell.com');
mail.setCcAddresses(ccTo);
mail.setSubject('Reset your Password');
mail.setHtmlBody(emailBody);
// mail.setTemplateId(et.id);
// mail.setWhatId(state.contact.Id);
if(!orgWideAddress.isEmpty()){
mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);
}
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
        
        return ajaxSuccess();
    }
    /**
*    Check if a PR's or Contact's Job title is part of special job title
*14.2 SSO Addition
*
*
**/
    
    public Boolean checkSpecialJobTitle(String title){
        List<SpecialJobTitle__c> specialJobTitle = new List<SpecialJobTitle__c>();
        specialJobTitle = [SELECT id FROM SpecialJobTitle__c where Job_Title__c = :title]; 
        if(specialJobTitle.size()==0){
            return false;
        }
        else{
            return true;
        }
        
    }
    /**
* Creates a user if one doesn't exist
* -or-
* Update user if does exist
*
* Will return an error if any of the following conditions occur:
* <ul>
*  <li></li>
*  <li></li>
*  <li></li>
*  <li></li>
* </ul>
*/
    public PageReference doReuseOrCreateUser(){
        system.debug('---11111---');
        final String guid = state.guid;
        final Contact contactRecord = state.contact;
        final Partner_Request__c request = state.request; //CR6728 Amir: May 23, 2012
        User user = null;
        System.debug('***GUID: '+ guid);
        if(StringUtils.isBlank(guid) || contactRecord == null){
            return ajaxError('Invalid State');
        }
        final String username = guid + '@partner.dell.com';
        try{
            user = [
                select
                username,alias,email,firstname,lastname,profileid,languagelocalekey,DefaultCurrencyIsoCode,
                localesidkey,emailencodingkey,timezonesidkey,badge_number__c,contactid,
                title,enable_partner_admin__c,Enable_Partner_Deal_Registration__c,Enable_As_Partner_Lead_Super_User__c,
                Enable_Partner_Lead_Management__c,
                OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Order__c,OSC_Specialty_Product_Create_Quote__c
                from User //CR 7824 - Add Enable Lead Super user
                where contactid = :contactRecord.id limit 1];
        }catch(Exception e){
            user = new User();
            user.alias = StringUtils.substring(guid, 0, 8);
            user.contactid = contactRecord.id;
        }
        /*
Not applicable with CR 2332
if(user.contactid != contactRecord.id){
//user already exists but is tied to another contact record
return ajaxError('User already exists but is associated to Contact ' + user.contactid);
}
*/
        
        
        user.Enable_as_Partner_Group_Administrator__c        = 'true'.equalsIgnoreCase(state.enableAsPartnerGroupAdmin);//Added by Michael as per Story 5748109
        user.Enable_Partner_Admin__c                         = (user.Enable_as_Partner_Group_Administrator__c  == true) ? true : 'true'.equalsIgnoreCase(state.enablePartnerAdmin);
        system.debug('---0000----'+state.enablePartnerAdmin);
        user.Enable_Partner_Deal_Registration__c = 'true'.equalsIgnoreCase(state.enablePartnerDealRegistration);
        user.OSC_Create_Quote__c = 'true'.equalsIgnoreCase(state.strEnableCreateOSCQuote);
        user.OSC_Specialty_Product_Create_Quote__c = 'true'.equalsIgnoreCase(state.strEnableCreateOSCSpQuote);
        user.OSC_Create_Order__c = 'true'.equalsIgnoreCase(state.strEnableCreateOSCOrder);
        user.OSC_Specialty_Product_Create_Order__c = 'true'.equalsIgnoreCase(state.strEnableCreateOSCSpOrder);
        //Meera 15.3 CMAP Addition
        user.Enable_Partner_Lead_Management__c   = 'true'.equalsIgnoreCase(state.enablePartnerLeadManagement);
       
        system.debug('---22222 Lead M----'+state.enablePartnerLeadManagement);
        //CR 7824 - Add Enable Lead Super user
        system.debug('---22222----'+state.enableLeadSuperUser);
        user.Enable_As_Partner_Lead_Super_User__c = 'true'.equalsIgnoreCase(state.enableLeadSuperUser);
        
        system.debug('---33333----'+user.Enable_As_Partner_Lead_Super_User__c);
        System.debug('### userData: ' + userData); 
        System.debug('### userData.getCountry(): ' + userData.getCountry());
        // Added By : Sneha
        // Added on :22 feb 2019
        // Added for: Defect # 6245535
        // Update country details for new user
        if(user.id == null){
        try{ 
            user.username                       = username;
            user.Email                          = contactRecord.email;
            user.FirstName                      = contactRecord.FirstName;
            user.LastName                       = contactRecord.LastName;
            user.Title                          = contactRecord.title;
            System.debug('contactRecord.Account.Name::'+contactRecord.Account.Name);
            user.CompanyName                    = contactRecord.Account.Name;//Manju Feb 8,2011
            user.ProfileId                      = userData.getCountry().User_Profile_ID__c;
            user.LanguageLocaleKey              = userData.getCountry().User_Language_Locale_Key__c;
            user.LocaleSidKey                   = userData.getCountry().User_Locale_Sid_Key__c;
            user.EmailEncodingKey               = userData.getCountry().User_Email_Encoding_Key__c;
            user.TimeZoneSidKey                 = userData.getCountry().User_Time_Zone_Sid_Key__c;
            user.DefaultCurrencyIsoCode         = userData.getCountry().User_Currency_Iso_Code__c;
            user.Badge_Number__c                = null;
             //CR6637
            user.Emerging_Markets_Partner__c         = (userData.getRegion()=='EC-EMEA')? true : false;
            if(request != null){
           /* if(request.Account__c != null) {  user.Country = request.Account__r.Account_Country__c;
                                           } else {*/
                //For new Partner Requests, fetching country from Account as country name might be long for few countries
                if(request.account__r.RecordType.Name == System.Label.Partner_Account){
                    user.Country = request.Account__r.Account_Country__c;
                }
                else{
                if(request.Country__c!= null){
                    if(request.Country__r.code__c == 'MK'){
                        user.Country = 'MACEDONIA';
                    }
                    else{                        
                        user.Country = request.Country__r.Name;
                    }
                    
                }
                }
                
           //}  // CR6728-end     
          }
          else{
                System.debug('state.contact '+state.contact);
                //New else logic
               /* if(null!=state.contact.account.Partner_Registration__c){
                    user.Country=    state.contact.account.Partner_Registration__r.Country__r.Name; 
                }else{*/
              if(String.isNotBlank(state.contact.account.Account_Country__c)){
                  if(state.contact.account.Account_Country__c.contains('MACEDONIA')){
                      user.Country = 'MACEDONIA';  
                  }
                  else{
                    user.Country = state.contact.account.Account_Country__c;                      
                  }
              }
                    
                //}
            
        }
           
        }catch(Exception ex){}
        }

        
        
        try{
            system.debug('---4444----'+user);
            if(user.id == null){
                system.debug('inserting user');
                insert user;
                system.debug('after inserting user');
            } else {
                update user;
            }
        }catch(DmlException e){
            system.debug('dml exception on fields: ' + ArrayUtils.toString(e.getDmlFieldNames(0)));
            //CR2087
            if(Test.isRunningTest()){isPortalEnabled = true;}
            if (!isPortalEnabled) 
                return ajaxError(e.getMessage());
            else {
                //MenMee: Fix:MIXED_DML_OPERATION
                //setIncompleteForRequestWithReason(recordId, e.getMessage());  
                if(user != null) state.user = user;                     
                setPRError = e.getMessage();
                return ajaxError(System.label.New_User_Error_message);
            }
            
        }catch(Exception e){
            //CR2087
            if (!isPortalEnabled) {  return ajaxError(e.getMessage());
                                  }
            else {
                //MenMee: Fix:MIXED_DML_OPERATION
                //setIncompleteForRequestWithReason(recordId, e.getMessage());  
                if(user != null) state.user = user;                     
                setPRError = e.getMessage();                
                return ajaxError(System.label.New_User_Error_message);
            }           
        }
        state.user = user;
        
        //------Added code as per CR#1389, R10.5 ------
        String recordIdPrefixvalue = StringUtils.defaultString(StringUtils.substring(recordId, 0, 3));
        
        if(recordIdPrefixvalue.equals(Partner_Request__c.sObjectType.getDescribe().getKeyPrefix())){
            try{
                List<String> stringList=new List<String>{state.request.Account__c,state.contact.id};
                    
                    //calls future method to integrate to the Partner profile system               
                    if (!isPortalEnabled) {
                        PartnerProfileIntegration.integratePartnerData(stringList);
                        
                        //method to Hit New SQl DB 2016 End point
                        //CR 13831
                        PartnerProfileIntegration.sendDatatoDpApiFromFuture(stringList);
                        //end of CR 13831
                        
                    }
                else {   
                    state.request.Provisioned_User__c = user.Id;
                    state.request.Provision_First_User_Is_Complete_Flag__c = true;
                    update state.request;               
                    synchronizeToCMI(state.contact.id, recordId, state.user.Id,this.state.contactIsEnabledForIncentives);//CR15997-Removed 'boolean.valueOf(this.state.provisionNetExam)' from the parameter as part of NET001 story
                    
                    //method to Hit New SQl DB 2016 End point
                    //CR 13831
                    PartnerProfileIntegration.sendDatatoDpApiFromFuture(String.valueof(state.contact.id));
                    //end of CR 13831
                    if(!Test.isRunningtest()){
                        PMCIntegration.pmcPostCallout(String.valueof(state.contact.id));
                    }                     
                }               
                
            }catch(Exception e){                
                return ajaxError('Failed to send data to Partner Profile. ['+ e.getMessage()+ ']');             
            }
        }
        //-----------------------------------------------
        return ajaxSuccess();
    }
    
    // Fenny [10 Jan 2013]: CR7944
    public PageReference doPermissionSetAssignment(){
        List<PermissionSet> permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Partner_Opportunity_Access'];
        if((permSet != null) && (permSet.size() > 0)){
            if(state.user.Enable_Partner_Deal_Registration__c){
                List<PermissionSetAssignment> listassignments = new List<PermissionSetAssignment>();
                listassignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :state.user.Id and PermissionSetId = :permSet[0].Id];
                if(listassignments.size() == 1){
                    System.debug('Permission set already exists::');
                }
                else{
                    PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId = state.user.Id, PermissionSetId = permSet[0].Id);
                    insert assignment; 
                }
               
            }else{
                //if(state.user !=null){
                System.debug('state.user.Id    '+state.user);
                List<PermissionSetAssignment> listDelassignments = new List<PermissionSetAssignment>();
                listDelassignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :state.user.Id and PermissionSetId = :permSet[0].Id];
                if(listDelassignments.size() > 0){
                    delete listDelassignments;
                }
                    
                //}
            }
        }else{
            string err = 'A problem has occured: Permission set \'Partner_Opportunity_Access\' not found. User ID = ' + state.user.Id;
            List<string> recipients = new List<string>{'SFDC-ApexDev@dell.com'};
                emailUtils.sendTextEmail(recipients, 'Permission set \'Partner_Opportunity_Access\' not found', err);
        }
        
        return ajaxSuccess();
    }
    
    //14.2 SSO Addition
    //Method added to make Contact record ready for BOOMI operation if it is enebled for incentives
    public PageReference checkforVendorUpdate(){
        final Contact contactRecord = state.contact;
        try{
            if(contactRecord.Is_Enabled_for_Incentives__c == true ){
                contactRecord.Is_Vendor_Update_Required__c = true;
                contactRecord.Is_Vendor_Updated__c = false;
                contactRecord.Last_Operation_Performed__c = 'SFDC Updated';
                System.debug('isPortalEnabled:'+isPortalEnabled);
                if(contactRecord.Vendor_Update_Datetime__c != null){//to handle disabling of a user where new User will be created when we are provisioning again.
                    contactRecord.Operation_for_Boomi__c = 'UPDATE_USER';
                }
                
                else if(!isPortalEnabled){//First user provisioning, pass Account info also
                    System.debug('Inside NEW_USER_WITH_ACCOUNT');
                    contactRecord.Operation_for_Boomi__c = 'NEW_USER_WITH_ACCOUNT';
                }
                else{
                    contactRecord.Operation_for_Boomi__c = 'NEW_USER';
                }
                contactRecord.Is_Incentives_Updated__c = true;
                
            }
            else{
                contactRecord.Is_Vendor_Update_Required__c = false;
                contactRecord.Operation_for_Boomi__c = null;
            }
            System.debug('##contactRecord.Is_Vendor_Update_Required__c:'+contactRecord.Is_Vendor_Update_Required__c);
            
            //Added by Bahar, Ariff 19th Feb 2013.  
            /*User userObj = [Select LanguageLocaleKey From User where ContactID =:contactRecord.ID Limit 1];

If (userObj !=null){
if (StringUtils.IsBlank(contactRecord.Language__c) || contactRecord.Language__c <> userObj.LanguageLocaleKey){
if (StringUtils.isNotBlank(userObj.LanguageLocaleKey)){
contactRecord.Language__c = userObj.LanguageLocaleKey;
}
}
}*/
            contactRecord.Language__c = state.user.LanguageLocaleKey;
            //End Added by Bahar, Ariff 19th Feb 2013. 
            if(state.user != null){
                System.debug('***Inside Contact Test: '+ state.user);
                contactRecord.partner_user__c = state.user.id;//Added by Rakesh - CMAP 15.10 CR 9838 - FR9.3
            } 
            
            update contactRecord;
        }catch(Exception e){
            System.debug('error occured'+e.getMessage());                
            return ajaxError('Failed to make the record ready for BOOMI operation to send incentive info to vendor. ['+ e.getMessage()+ ']');             
        }
        return ajaxSuccess();
        
    }
    public PageReference doUpdateRequest(){
        final Partner_Request__c request = state.request;
        final User user = state.user;
        if(!isPartnerRequest || request == null || user == null){
            return ajaxError('Invalid State');
        }
        
        request.Provisioned_User__c = user.id;
        request.Provision_First_User_Is_Complete_Flag__c = true;
        request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;
        
        try{
            update request;
        } catch(Exception e){
            return ajaxError(e.getMessage());
        }
        return ajaxSuccess();
    }
    //MenMee: Fix:MIXED_DML_OPERATION
    public void setIncompleteForRequestWithReasonJS() {
        System.debug('setIncompleteForRequestWithReasonJS');
        final User user = state.user;
        List<Partner_Request__c> requestList = [SELECT Id, Status__c, Description__c,Enable_as_Partner_Admin__c,Enable_Partner_Group_Admin__c,Enable_as_Lead_Super_User__c,Feature_Request_Deal_Registration__c,Feature_Request_Lead_Management__c,
                                                                OSC_Create_Quote__c, OSC_Create_Order__c, OSC_Specialty_Product_Create_Order__c, OSC_Specialty_Product_Create_Quote__c FROM Partner_Request__c WHERE Id = :recordId LIMIT 1];
        
        if (requestList != null) {       
            Partner_Request__c request = requestList[0];
            request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
            
            if (user != null) {             
                request.Provisioned_User__c = user.id;
                request.Provision_First_User_Is_Complete_Flag__c = true;
            }   
            
            if(request.Description__c == null) {
                request.Description__c = setPRError;   
            }
            else {
                request.Description__c += ' \n\n' + setPRError;
            }       
            
            update request;
        }
        //return null;
    }
    
    public PageReference doBackToRegistrationButton(){
        /*** CR 8510 Starts ***/
        system.debug('******'+ajaxError );
        if(ajaxError == null || ajaxError == System.label.New_User_Error_message){
            
            /* Http http = new Http();
HttpRequest requestToDais = new HttpRequest();
requestToDais.setEndpoint(system.Label.DAIS_Endpoint_ForgotPassword);
requestToDais.setMethod('POST');
requestToDais.setHeader('Content-Type', 'application/json;charset=UTF-8');
requestToDais.setHeader('x-dell-identity-key', system.Label.DAIS_Identity_Key);
requestToDais.setHeader('x-dell-identity-restriction-api-key', system.Label.DAIS_Restriction_API_Key);
requestToDais.setHeader('Cache-Control','no-cache');

String connectionId;
If(DealRegUtils.isGCCountry() == true){
connectionId = system.Label.DAIS_ConnectionId_GC;
}else{
connectionId = system.Label.DAIS_ConnectionId_NonGC;
}

// Set the body as a JSON object
requestToDais.setBody('{"FirstName":"'+state.contact.FirstName+'","LastName":"'+state.contact.LastName+'","Email":"'+state.contact.Email+'","Country":"'+state.contact.account.Account_Country_Code__c+'","Language":"'+state.contact.account.Partner_Registration__r.Org_Country__r.User_Language_Locale_Key__c+'","ConnectionId":"'+connectionId+'"}');
requestToDais.setTimeout(integer.valueOf(System.Label.DAIS_Timeout_Variable)); // 100000 
system.debug('++++++getBody'+requestToDais.getBody());
if(!Test.isRunningTest()){
HttpResponse response = http.send(requestToDais);
// Parse the JSON response
if (response.getStatusCode() != 201) {
System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
System.debug(response.getBody());
} else {
System.debug(response.getBody());
} 
state.guid = response.getBody().substringBetween('"ProfileId":"','"');
system.debug('profileid'  +response.getBody().substringBetween('"ProfileId":"','"'));
system.debug('Forgotpassword'  +response.getBody().substringBetween('"ForgotPasswordRequestId":"','"'));
//string res = response.getBody();
if (response.getStatusCode() == 200) {
Contact cont = [select Id, Name from Contact where id = :state.contact.id limit 1];
cont.Forgot_Password_Request_Id__c = response.getBody().substringBetween('"ForgotPasswordRequestId":"','"');
update cont; 
}
}*/
            if(state.contact!= null){
                
            
            User user = [
                select
                username,alias,email,firstname,lastname,profileid,languagelocalekey,DefaultCurrencyIsoCode,
                localesidkey,emailencodingkey,timezonesidkey,badge_number__c,contactid,
                title,enable_partner_admin__c,Enable_Partner_Deal_Registration__c,Enable_As_Partner_Lead_Super_User__c,
                Enable_Partner_Lead_Management__c,
                OSC_Create_Quote__c, OSC_Create_Order__c, OSC_Specialty_Product_Create_Order__c, OSC_Specialty_Product_Create_Quote__c
                from User 
                where contactid = :state.contact.id limit 1];
            
            EmailTemplate et;
            if(user != null){
                System.debug('***User Language: '+ user.languagelocalekey);
            if( user.languagelocalekey == 'ko'){ 
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Korean'];
            }else if( user.languagelocalekey == 'ar' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Arabic'];
            }else if( user.languagelocalekey == 'zh_CN' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email chineses'];
            }else if( user.languagelocalekey == 'zh_TW' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email ChineseT'];
            }else if( user.languagelocalekey == 'cs' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Czech'];
            }else if( user.languagelocalekey == 'da' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Danish'];
            }else if( user.languagelocalekey == 'nl_NL' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Dutch'];
            }else if( user.languagelocalekey == 'fr' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email French'];
            }else if( user.languagelocalekey == 'de' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email German'];
            }else if( user.languagelocalekey == 'el' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Greece'];
            }else if( user.languagelocalekey == 'hu' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Hungari'];
            }else if( user.languagelocalekey == 'it' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Italian'];
            }else if( user.languagelocalekey == 'no' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Norvegian'];
            }else if( user.languagelocalekey == 'pl' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Polish'];
            }else if( user.languagelocalekey == 'pt_BR' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Portuguese'];
            }else if( user.languagelocalekey == 'ro' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Romanian'];
            }else if( user.languagelocalekey == 'ru' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Russian'];
            }else if( user.languagelocalekey == 'sk' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Slov'];
            }else if( user.languagelocalekey == 'es' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Spanish'];
            }else if( user.languagelocalekey == 'sv' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Swedish'];
            }else if( user.languagelocalekey == 'tr' ){
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email Turkish'];
            }else{
                et=[Select id from EmailTemplate where name=:'Company User Provisioning Email'];
            }
            //emailToSponsoringDistibutor();
            //EmailTemplate et=[Select id from EmailTemplate where name=:'Company User Provisioning Email'];
            List<OrgWideEmailAddress> orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox'];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(state.contact.Id);
            List<String> ccTo = new List<String>();
            ccTo.add('Channel_STG@dell.com');
            mail.setCcAddresses(ccTo);
            mail.setWhatId(state.contact.Id);
            mail.SaveAsActivity= false;
            mail.setTemplateId(et.id);
            if(!orgWideAddress.isEmpty()){
                mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           
            }
  
           if(state.request.Primary_Channel_Model__c == 'Solution Provider (Reseller)'){
                emailToSponsoringDistibutor();
             }
        }
        }
        /*** CR 8510 Ends ***/
        
        
        //CR2087
        if (!isPortalEnabled) {
            return PageUtils.redirect('/' + recordId);
        }
        else {
            //return PageUtils.redirect('/apex/PartnerSelfServiceMyCompany');
            //return PageUtils.redirect('/apex/ViewMyCompanyDetails');
            //As per defect #6260774
            return PageUtils.redirect('/apex/ManageUsers');
        }
        
    }
    
    public void emailToSponsoringDistibutor(){
         System.debug('emailToSponsoringDistibutor');
        if(String.isNotBlank(state.request.Sponsoring_Distributor_Primary_Email__c) || String.isNotBlank(state.request.Sponsoring_Distributor_Secondary_Email__c)){
          EmailTemplate et=[Select Id 
                              from EmailTemplate 
                              where DeveloperName =:'Sponsoring_distributor_notification_mail'];
            List<OrgWideEmailAddress> listOrgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox'];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(state.contact.Id);
            List<String> listToAddress = new List<String>();
            if(String.isNotBlank(state.request.Sponsoring_Distributor_Primary_Email__c)){
                listToAddress.add(state.request.Sponsoring_Distributor_Primary_Email__c) ;
            }
            if(String.isNotBlank(state.request.Sponsoring_Distributor_Secondary_Email__c)){
                listToAddress.add(state.request.Sponsoring_Distributor_Secondary_Email__c);
            }
            List<String> listccTo = new List<String>();
            listccTo.add('Channel_STG@dell.com');
            mail.setCcAddresses(listccTo);
            if(!listToAddress.isEmpty()){
                System.debug('listToAddress::'+listToAddress);
                mail.setToAddresses(listToAddress);
            }
          mail.setWhatId(state.request.Id);
            mail.SaveAsActivity= false;
            mail.setTemplateId(et.id);
            mail.setTreatTargetObjectAsRecipient(false);
          if(!listOrgWideAddress.isEmpty()){
                mail.setOrgWideEmailAddressId(listOrgWideAddress[0].Id);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
    
    //CR2087
    @future (callout=true)
    //CR15997-removed 'boolean isTrainingEnabled' parameter from the synchronizeToCMI method as part of NET001 story
    public static void synchronizeToCMI(String contactId, String requestId, String userId, boolean isIncentiveUpdated) {     
        List<Partner_Request__c> requestList;
        String reason = null;
        
        try{
            //sends the Contact data to Partner profile
            String response = PartnerProfileIntegration.integratePartnerDataWithResponse(contactId);                
            
            if (response != null && !response.contains(GlobalVariables.CMI_RESPONSE_SUCCESSFUL)) {
                reason = 'Integration with CMI failed. Please contact your System Administrator.';  
            }   
            /*MenMee: Fix:MIXED_DML_OPERATION
if (isTrainingEnabled) {
if (reason == null)
reason = 'NetExam access is requested. Manual provisioning is required to enable Partner in NetExam';
else
reason = reason + ' \n\n NetExam access is requested. Manual provisioning is required to enable Partner in NetExam';
}
*/
            requestList = [SELECT Id, Status__c, Description__c,Enable_as_Partner_Admin__c,Enable_Partner_Group_Admin__c,Enable_as_Lead_Super_User__c,Feature_Request_Deal_Registration__c,Feature_Request_Lead_Management__c,
                                 OSC_Create_Quote__c, OSC_Create_Order__c, OSC_Specialty_Product_Create_Order__c, OSC_Specialty_Product_Create_Quote__c FROM Partner_Request__c WHERE Id = :requestId LIMIT 1];
            
            if (requestList != null) {     
                Partner_Request__c request = requestList[0];        
                System.debug('1:'+request);
                if (reason != null) { 
                    //Fix for:MIXED_DML_OPERATION
                    //setIncompleteForRequestWithReason(request, reason);
                    request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
                    if(request.Description__c == null) { request.Description__c = Reason;   
                                                       }
                    else {
                        request.Description__c += ' \n\n' + Reason;
                    }               
                }
                else  {                         
                    if(request.Status__c ==  PartnerConstants.REG_STATUS_DRAFT && request.Description__c == null && !isIncentiveUpdated) 
                        request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;                  
                }
                System.debug('1:'+request);     
                update request;
            }          
        }
        catch(Exception e) {
            //setIncompleteForRequestWithReason(request, e.getMessage());                     
            System.debug('#### synchronizeToCMIandNetExam : ' + e.getMessage());
        }       
    }
    //CR2087-end
    
    private PageReference error(String code){
        this.errorCode = code;
        return null;
    }
    
    public interface UserDataVO{
        ID getRecordId();
        String getEmail();
        String getFirstName();
        String getLastName();
        String getCountryCode();
        String getCountryName();
        Country__c getCountry();
        String getLanguage();
        String getRegion();
        String getNewsletterOptIn();
        PageReference validate();
        void load(String recordId);
        SObject record();
    }
    
    public abstract class UserDataVOConcrete implements UserDataVO{
        private PartnerRegistrationProvisionUserCtrlExt controller;
        private Country__c country;
        public UserDataVOConcrete(PartnerRegistrationProvisionUserCtrlExt controller){
            this.controller = controller;
        }
        public void setCountry(String countryCode){
            if(StringUtils.isBlank(countryCode)){
                throw new CountryNotFoundException();
            }
            try{
                //Raymond 20090918: CR1790 - Modified query to retrieve Rebate_Enabled__c
                //Meera22102013: Modified to add lead management related fields
                this.country = [select name,Region__c,Code__c,Dell_Online_Country_Code__c,Is_Active_Partner_Country__c,User_Language_Locale_Key__c,
                                User_Currency_Iso_Code__c,User_Locale_Sid_Key__c,User_Email_Encoding_Key__c,User_Time_Zone_Sid_Key__c,User_Profile_ID__c,
                                Deal_Registration_Enabled__c,Rebate_Enabled__c,Lead_Management_Enabled__c,Lead_Management_Enabled_for_OEM__c,Partner_Relationship__c,Partner_Relationship_for_OEM__c
                                from Country__c
                                where code__c = :countryCode 
                                and code__c != null];//CR15997- Removed 'Training_Enabled__c' field from the query as part of NET001 story
            }catch(QueryException e){ throw new CountryNotFoundException();
                                    }
            if(this.country.Is_Active_Partner_Country__c == false){
                throw new CountryNotEnabledException();
            }
        }
        public PageReference error(String code){
            return this.controller.error(code);
        }
        public String getCountryCode(){ return this.country==null ? null : this.country.Dell_Online_Country_Code__c; }
        public String getLanguage(){ return StringUtils.lowerCase(StringUtils.substring(this.country==null ? null : this.country.User_Language_Locale_Key__c,0,2)); }
        public String getRegion(){ return this.country==null ? null : this.country.Region__c; }
        public String getCountryName(){ return this.country==null ? null : this.country.name; }
        public Country__c getCountry(){ return this.country; }
    }
    
    public class UserDataVOContact extends UserDataVOConcrete{
        public Contact contact{get;set;}
        public UserDataVOContact(PartnerRegistrationProvisionUserCtrlExt controller){
            super(controller);
        }
        public void load(String contactId){
            //Meera:15.3 CMAP, Added lead management related fields
            //Varsha #5748109: Added EligibleTracks__c and Enable_as_Partner_Group_Administrator__c
            this.contact = [
                select
                id,accountid,account.Account_Country_Code__c,account.IsPartner,account.id,account.name,
                lastname,firstname,Email_Opt_In__c,Email,title,Partner_My_Account_GUID__c,
                Provisioned_in_Salesforce_on__c, Campaign_Builder__c, Premier_Partner__c, account.Forgot_Password_Request_Id__c,
                Transactional_Store__c, Warranty_Parts_Info__c,Is_Enabled_for_Incentives__c,account.Is_Enabled_for_Incentives__c,
                account.Sales_Channel__r.name,account.Partner_Relationship__c, account.Partner_Registration__r.Org_Country__r.User_Language_Locale_Key__c,
                account.Partner_Registration__r.Org_Country__r.Dell_Online_Country_Code__c,account.Partner_Registration__r.Country__r.User_Language_Locale_Key__c,
                account.Partner_Registration__r.Country__r.Dell_Online_Country_Code__c,account.Partner_Registration__r.Country__r.Name,account.Account_Country__c,
                Allow_Partner_Central_User__c, Allow_Program_Tracker__c, Allow_RFP_and_Proposal_Express_Tool__c, Enable_SPL_View_with_All_country_Price__c, Is_MDF_User__c, 
                SPL_view_with_partner_recommeded_pricing__c, Enable_SPL_view_with_Disti_pricing__c,Job_Function__c,Job_Function_Role__c, EligibleTracks__c, 
                Enable_as_Partner_Group_Administrator__c,Preferred_Track__c,Selected_Track__c,Other_Job_Function_Category__c 
                from Contact
                where id = :contactId
            ];//, Enable_User_for_MyRewards__c removed
            if(this.contact.accountid == null){
                throw new NotLinkedToAccountException();
            }
            if(StringUtils.isBlank(this.contact.Email)){
                throw new ContactNoEmailException();
            }
            
            setCountry(this.contact.account.account_country_code__c);  
            
            
        }
        public ID getRecordId(){ return this.contact.id; }
        public String getFirstName(){ return this.contact.firstname; }
        public String getLastName(){ return this.contact.lastname; }
        public String getEmail(){ return this.contact.email; }
        public String getNewsletterOptIn(){ return 'yes'.equalsIgnoreCase(this.contact.Email_Opt_In__c) ? '1' : '0';}
        public PageReference validate(){
            if( this.contact.account.IsPartner == false ){  return error(ACCT_NOT_PARTNER);}
            return null;
        }
        public SObject record(){
            return this.contact;
        }
    }
    
    public class UserDataVOPartnerRequest extends UserDataVOConcrete{
        public Partner_Request__c request{get;set;}
        public UserDataVOPartnerRequest(PartnerRegistrationProvisionUserCtrlExt controller){
            super(controller);
        }
        
        //Raymond 20090918: Cr1790 - Modified query to retrieve Feature_Request_Rebates__c
        //                  and Account__r.Is_Rebate_Partner__c
        //Amir May 23, 2012: CR6728 - Modified query to retrieve Account__r.Account_Country__c
        //                  and Country__r.Name
        //CR 7824 - Add Enable Lead Super user- Modified query to query Enable_as_Lead_Super_User__c
        //Meera - Added Feature_Request_Lead_Management__c,account__r.Partner_Relationship__c, for 15.3 CMAP requirement
        
        public void load(String reqId){
            this.request = [SELECT salutation__c,first_name__c,last_name__c,email__c,account__c, Job_Title__c,Other_Job_Category__c,Phone__c,Job_Category_Non_GC__c,RFP_Proposal_Express_Tool__c,
                            Mobile__c,Fax__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Preferred_Language__c,Eligible_Partner_Tracks__c,
                            City__c,State__c,Postal_Code__c,Newsletter_Opt_In__c,id,recordtype.name,Facebook__c,Instagram__c,LinkedInProfile__c,Personal_Twitter__c,Corporate_Twitter__c,
                            Is_Enabled_for_Incentives__c,account__r.Is_Enabled_for_Incentives__c,account__r.Account_Country_Code__c,account__r.Partner_Relationship__c,
                            account__r.IsPartner, account__r.id, account__r.name, account__r.account_country__c, account__r.Sales_Channel__r.Name,account__r.Master_Group_Id__c,account__r.Partner_Track__c,
                            Feature_Request_Deal_Registration__c,Feature_Request_Lead_Management__c,Enable_as_Partner_Admin__c,Enable_Partner_Group_Admin__c,Enable_as_Lead_Super_User__c, country__r.name,
                            Feature_Request_Rebates__c, Program_Tracker__c,Partner_Central__c,Enable_Premier_Pages_access_Flag__c,Account__r.Is_Rebate_Partner__c, 
                            Contact__r.Campaign_Builder__c, Contact__r.Allow_Program_Tracker__c, Contact__r.Is_MDF_User__c,
                            Contact__r.Enable_SPL_View_with_All_country_Price__c, Contact__r.SPL_view_with_partner_recommeded_pricing__c, Contact__r.Enable_SPL_view_with_Disti_pricing__c,
                            Contact__r.Allow_Partner_Central_User__c,Location_of_User__c,Job_Category__c,Feature_Request_MDF__c,
                            Contact__r.Premier_Partner__c, Contact__r.Transactional_Store__c, Contact__r.Warranty_Parts_Info__c,Primary_Contact_Aligned__c, Org_Country__r.User_Language_Locale_Key__c,Org_Country__r.Dell_Online_Country_Code__c,
                            Country__r.User_Language_Locale_Key__c,Country__r.Dell_Online_Country_Code__c,country__r.Code__c,account__r.RecordType.Name,account__r.Master_Group_Id__r.Name,
                            OSC_Create_Quote__c, OSC_Create_Order__c, OSC_Specialty_Product_Create_Order__c, OSC_Specialty_Product_Create_Quote__c,Primary_Channel_Model__c,Sponsoring_Distributor_Primary_Email__c,Sponsoring_Distributor_Secondary_Email__c
                            FROM Partner_Request__c
                            WHERE id = :reqId 
                            ];//Removed Contact__r.Enable_User_for_MyRewards__c,
            if(this.request.account__c == null){
                throw new NotLinkedToAccountException();
            }
            if(StringUtils.isBlank(this.request.email__c)){
                throw new ContactNoEmailException();
            }
            //setCountry(this.request.account__r.account_country_code__c);
            System.debug('this.request.Country__r.Code__c'+this.request.Country__r.Code__c);
            setCountry(this.request.Country__r.Code__c);
        }
        public ID getRecordId(){ return this.request.id; }
        public String getFirstName(){ return this.request.first_name__c; }
        public String getLastName(){ return this.request.last_name__c; }
        public String getEmail(){ return this.request.email__c; }
        public String getNewsletterOptIn(){ return (this.request.Newsletter_Opt_In__c ? '1' : '0'); }
        public PageReference validate(){
            if( !(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER.equalsIgnoreCase(this.request.recordtype.name)
                  || PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER.equalsIgnoreCase(this.request.recordtype.name)
                  || PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER_ADMIN.equalsIgnoreCase(this.request.recordtype.name) // Fenny: R12.10 - CR6245
                  || PartnerConstants.REQUEST_RECORD_TYPE_EXIST_PARTNER.equalsIgnoreCase(this.request.recordtype.name)) ){
                      return error(INVALID_REC_TYPE);
                  }
            if( this.request.account__r.IsPartner == false ){   return error(ACCT_NOT_PARTNER);}
            return null;
        }
        public SObject record(){
            return this.request;
        }
    }
    
    public class NotLinkedToAccountException extends Exception{}
    public class CountryNotFoundException extends Exception{}
    public class CountryNotEnabledException extends Exception{}
    public class ContactNoEmailException extends Exception{}
    
    //22-Jul-2009 Raymond - Added for CR1466
    public class FailedToCopyPRFieldsToAccntException extends Exception{}
    
    /**
* Helper method for returning back JSON responses to the Javascript contained in the VF page.
*/
    private PageReference ajaxSuccess(){
        return ajaxError(null);
    }
    
    /**
* Helper method for returning back JSON responses to the Javascript contained in the VF page.
* Format of the JSON response will be:
*   {"success": true|false, "errorDescription": null|"the error"}
* @error the error occurred if any; if no error occurred then pass null
*/
    private PageReference ajaxError(String error){
        this.ajaxError = error;
        return null;
    }
    
    public String ajaxResponse{
        set{}
        get{
            return '{"success":' + (ajaxError==null ? 'true' : 'false') + ',"errorDescription":' + (ajaxError==null ? 'null' : toJSONString(ajaxError)) + '}';
        }
    }
    
    
    /**
* Helper method for properly encoding JSON strings
* @aString the string to encode
*/
    @Testvisible
    private String toJSONString(String aString){
        return (aString == null) ? 'null' : '"' +
            StringUtils.replaceEach(aString,new String[]{
                '"'
                    ,'\\'
                    ,'\n'
                    ,'\t'
                    ,'\f'
                    ,'\r'
                    ,'/'
                    },new String[]{
                        '\\"'
                            ,'\\\\'
                            ,'\\n'
                            ,'\\t'
                            ,'\\f'
                            ,'\\r'
                            ,'\\/'
                            })
            + '"';
    }
    
    //22-Jul-2009 Raymond - Added for CR1466. Copied from
    //                      PartnerRegistrationLinkToAcctCtrlrExt
    // New fields added in Partner Request and Account query from Join_Dell_PartnerDirect_Program__c TO Size_of_Customer_Base__c
    public void copyPRFieldsToAccount(String requestId) {
        try {
            Partner_Request__c req =
                [SELECT
                 id,
                 Currently_Selling_Dell__c,
                 Dell_Revenue_Percent__c,
                 Hardware_Revenue_Percent__c,
                 Other_Customers__c,
                 Percent_Sales_Force__c,
                 Percent_Technical_Professionals__c,
                 Preferred_Dell_Distribution_Partner__c,
                 Primary_Channel_Model__c,
                 Primary_Routes_to_Market__c,
                 Primary_Customer__c,
                 Product_Focus__c,
                 Reseller_Tax_ID__c,
                 Service_Revenue_Percent__c,
                 Software_Revenue_Percent__c,
                 States_Provinces_doing_business__c,
                 Account__c,
                 RecordType.Name,
                 Join_Dell_PartnerDirect_Program__c, Primary_Contact_Aligned__c,Number_of_Branches_Subsidiaries__c,
                 Principle_Name__c,Principle_Title__c,Primary_Vertical_Market_Segment__c,Secondary_Vertical_Market_Segment__c,Secondary_Customer__c,
                 Top_3_Vendors__c,Organization_Industry_Certificate__c,Managed_Service_Provider__c,Hardware_Reseller__c,
                 Solution_Oriented_Reseller__c,Large_Enterprise__c,Traditional_Reseller__c,Value_Added_Reseller__c,
                 Software_Reseller__c, Referral_Partner__c, Distributor__c, Technology_Partner__c, Org_Country__r.User_Language_Locale_Key__c,Country__r.User_Language_Locale_Key__c,Country__r.Dell_Online_Country_Code__c,
                 Retailer__c,Telco__c,eTailer__c,Other__c,ISV__c,System_Integrator__c,OEM__c,Boutique_Firm__c,Size_of_Customer_Base__c,Service_Type__c,
                 Service_Capability__c,Mode_Of_Service__c,Hardware_warranty_Break_fix_support__c,Software_Technical_Support__c,Installation_Deployment_Services__c,
                 Installation_Deployment_Services_Market__c,Custom_Configuration_Imaging__c,Data_Migration__c,Asset_recovery_resale_recycling__c,
                 Consulting__c,Consulting_Market__c,Education_Training__c,Managed_Deployment__c,Custom_enterprise_data_center_services__c,Dell_Service_Tools_Used__c,
                 agreed_on__c,account__r.RecordType.Name,account__r.Name,account__r.Master_Group_Id__r.Name,Does_Business_As__c 
                 FROM Partner_Request__c WHERE  Id = :requestId LIMIT 1];
            
            Account acc =
                [SELECT
                 Id,
                 Partner_Registration__c,
                 IsPartner,
                 Currently_Selling_Dell__c,
                 Dell_Revenue_Percent__c,
                 Hardware_Revenue_Percent__c,
                 Other_Customers__c,
                 Percent_Sales_Force__c,
                 Percent_Technical_Professionals__c,
                 Preferred_Dell_Distribution_Partner__c,
                 Primary_Channel_Model__c,
                 Primary_Routes_to_Market__c,
                 Partner_Primary_Customer__c,
                 Product_Focus__c,
                 Reseller_Tax_ID__c,
                 Service_Revenue_Percent__c,
                 Software_Revenue_Percent__c,
                 States_Provinces_doing_business__c,
                 Join_Dell_PartnerDirect_Program__c,Primary_Contact_Aligned__c,Number_of_Branches_Subsidiaries__c,
                 Principle_Name1__c,Principle_Title1__c,Primary_Vertical_Market_Segment__c,Secondary_Vertical_Market_Segment__c,Secondary_Customer_Segment__c,
                 Top_3_Vendors__c,Organization_Industry_Certificate__c,Managed_Service_Provider__c,Hardware_Reseller__c,
                 Solution_Oriented_Reseller__c,Large_Enterprise__c,Traditional_Reseller__c,Value_Added_Reseller__c,
                 Software_Reseller__c, Referral_Partner__c, Distributor__c, Technology_Partner__c, 
                 Retailer__c ,Telco__c,eTailer__c,Other__c,ISV__c,System_Integrator__c,OEM__c,Boutique_Firm__c,Size_of_Customer_Base__c,Service_Type__c,
                 Service_Capability__c,Mode_Of_Service__c,Hardware_warranty_Break_fix_support__c,Software_Technical_Support__c,Installation_Deployment_Services__c,
                 Installation_Deployment_Services_Market__c,Custom_Configuration_Imaging__c,Data_Migration__c,Asset_recovery_resale_recycling__c,
                 Consulting__c,Consulting_Market__c,Education_Training__c,Managed_Deployment__c,Partner_Level__c,Custom_enterprise_data_center_services__c,Dell_Service_Tools_Used__c,
                 Partner_Origin__c,Does_Business_As__c FROM Account WHERE Id=:req.Account__c LIMIT 1];
            
            if(req.RecordType.Name == 'New Partner' && acc.Partner_Registration__c == null) {
                acc.Partner_Registration__c = req.id;
                if(req.agreed_on__c !=null && system.label.Do_autoPopulate == 'True'){
                    acc.New_Partner_Programme_T_C_s_agreed_on__c = req.agreed_on__c;
                    acc.New_Partner_Programme_T_C_s__c = True;
                }
                acc.IsPartner = true;
                acc.Currently_Selling_Dell__c = req.Currently_Selling_Dell__c;
                acc.Dell_Revenue_Percent__c = req.Dell_Revenue_Percent__c;
                acc.Hardware_Revenue_Percent__c = req.Hardware_Revenue_Percent__c;
                acc.Other_Customers__c = req.Other_Customers__c;
                acc.Percent_Sales_Force__c = req.Percent_Sales_Force__c;
                acc.Percent_Technical_Professionals__c = req.Percent_Technical_Professionals__c;
                acc.Preferred_Dell_Distribution_Partner__c = req.Preferred_Dell_Distribution_Partner__c;
                acc.Primary_Channel_Model__c = req.Primary_Channel_Model__c;
                acc.Primary_Routes_to_Market__c = req.Primary_Routes_to_Market__c;
                acc.Partner_Primary_Customer__c = req.Primary_Customer__c;
                acc.Product_Focus__c = req.Product_Focus__c;
                acc.Reseller_Tax_ID__c = req.Reseller_Tax_ID__c;
                acc.Service_Revenue_Percent__c = req.Service_Revenue_Percent__c;
                acc.Software_Revenue_Percent__c = req.Software_Revenue_Percent__c;
                acc.States_Provinces_doing_business__c = req.States_Provinces_doing_business__c;
                //New Field added in R14.5
                acc.Join_Dell_PartnerDirect_Program__c=req.Join_Dell_PartnerDirect_Program__c;
                acc.Primary_Contact_Aligned__c=req.Primary_Contact_Aligned__c;
                acc.Number_of_Branches_Subsidiaries__c=req.Number_of_Branches_Subsidiaries__c;
                acc.Principle_Name1__c=req.Principle_Name__c;
                acc.Principle_Title1__c=req.Principle_Title__c;
                acc.Primary_Vertical_Market_Segment__c=req.Primary_Vertical_Market_Segment__c;
                acc.Secondary_Vertical_Market_Segment__c=req.Secondary_Vertical_Market_Segment__c;
                acc.Top_3_Vendors__c=req.Top_3_Vendors__c;
                acc.Organization_Industry_Certificate__c=req.Organization_Industry_Certificate__c;
                acc.Secondary_Customer_Segment__c=req.Secondary_Customer__c;
                acc.Managed_Service_Provider__c=req.Managed_Service_Provider__c;
                acc.Hardware_Reseller__c=req.Hardware_Reseller__c;
                acc.Solution_Oriented_Reseller__c=req.Solution_Oriented_Reseller__c;
                acc.Large_Enterprise__c=req.Large_Enterprise__c;
                acc.Traditional_Reseller__c=req.Traditional_Reseller__c;
                acc.Value_Added_Reseller__c=req.Value_Added_Reseller__c;
                acc.Retailer__c=req.Retailer__c;
                acc.Telco__c=req.Telco__c;
                acc.eTailer__c=req.eTailer__c;
                acc.Other__c=req.Other__c;
                acc.ISV__c=req.ISV__c;
                acc.System_Integrator__c=req.System_Integrator__c;
                acc.OEM__c=req.OEM__c;
                acc.Boutique_Firm__c=req.Boutique_Firm__c;
                acc.Software_Reseller__c = req.Software_Reseller__c;
                acc.Referral_Partner__c = req.Referral_Partner__c;
                acc.Distributor__c = req.Distributor__c;
                acc.Technology_Partner__c = req.Technology_Partner__c;
                acc.Size_of_Customer_Base__c=req.Size_of_Customer_Base__c;
                /*R16.03 PP II Starts */
                acc.Service_Type__c=req.Service_Type__c;
                acc.Service_Capability__c=req.Service_Capability__c;
                acc.Mode_Of_Service__c=req.Mode_Of_Service__c;
                acc.Hardware_warranty_Break_fix_support__c=req.Hardware_warranty_Break_fix_support__c;
                acc.Software_Technical_Support__c=req.Software_Technical_Support__c;
                acc.Installation_Deployment_Services__c=req.Installation_Deployment_Services__c;
                acc.Installation_Deployment_Services_Market__c=req.Installation_Deployment_Services_Market__c;
                acc.Custom_Configuration_Imaging__c=req.Custom_Configuration_Imaging__c;
                acc.Data_Migration__c=req.Data_Migration__c;
                acc.Asset_recovery_resale_recycling__c=req.Asset_recovery_resale_recycling__c;
                acc.Consulting__c=req.Consulting__c;
                acc.Consulting_Market__c=req.Consulting_Market__c;
                acc.Education_Training__c=req.Education_Training__c;
                acc.Managed_Deployment__c=req.Managed_Deployment__c;
                acc.Custom_enterprise_data_center_services__c=req.Custom_enterprise_data_center_services__c;
                acc.Dell_Service_Tools_Used__c=req.Dell_Service_Tools_Used__c;
                acc.Partner_Origin__c='Self-Nominated';
                acc.Partner_Level__c = 'Level 5';
                acc.Does_Business_As__c = req.Does_Business_As__c; 
                /*R16.03 PP II Ends */
                    update acc;
            }
        }
        catch (QueryException e) {  throw e;
                                 }
        catch (Exception e) {  throw new FailedToCopyPRFieldsToAccntException();
                            }
    }
    /* 
public static boolean findDealRegAccess(String recordIdPrefix,String RecordId){
try{
boolean returnValue = true; 

if(recordIdPrefix.equals(Partner_Request__c.sObjectType.getDescribe().getKeyPrefix())){

try{
Account Acc = [select id,Partner_Relationship__c, Partner_Tier__c from Account where Partner_Registration__c=:RecordId];

returnValue  = CheckForCondition(Acc.Partner_Relationship__c,Acc.Partner_Tier__c );
}catch(Exception ex){
Partner_Request__c pr = [select id,Account__r.Partner_Relationship__c, Account__r.Partner_Tier__c from Partner_Request__c where id=:RecordId];

returnValue  = CheckForCondition(PR.Account__r.Partner_Relationship__c,PR.Account__r.Partner_Tier__c );


}

}else if(recordIdPrefix.equals(Contact.sObjectType.getDescribe().getKeyPrefix())){


Contact con = [select id,Account.Partner_Relationship__c,Account.Partner_Tier__c  from Contact where id=:RecordId];

returnValue  = CheckForCondition(con.Account.Partner_Relationship__c,con.Account.Partner_Tier__c );
}
return returnValue ;
}catch(Exception ex){
return null;
}
}

public static boolean CheckForCondition(String PartnerRelation,String PartnerTier){

if(!System.Label.Exclude_PartnerRelation.contains(PartnerRelation) && ( PartnerTier== System.Label.Exclude_PartnerTier))
{
return false;
}else{
return true;
}
}*/
    
    //dais update
    public PageReference doDiasWebServiceCall(){
        final Partner_Request__c request = state.request;
        final contact existingContact = state.contact;
        
        string firstname;
        string lastname;
        string email;
        string country;
        string language;
        id accid;
        
        if(existingContact == null)
        {
            FirstName = request.First_Name__c;
            LastName =  request.Last_Name__c;
            Email=      request.Email__c;
            Country=    request.Country__r.Dell_Online_Country_Code__c ;
            Language=   request.Country__r.User_Language_Locale_Key__c ;
            //accid= request.Account__c;
            //accid= request.Account__c;
            //Added by Sneha - As part of PAM
            if(request.account__r.Master_Group_Id__c != null && request.account__r.RecordType.Name == System.Label.Partner_Account){
                        accid         = request.account__r.Master_Group_Id__c;
            }
            else if(request.account__c != null && request.account__r.RecordType.Name == System.Label.Master_Account_Record_Type_Name ){
                        accid           = request.account__c;
            }
        }
        else{
            FirstName = state.contact.FirstName ;
            LastName =  state.contact.LastName;
            Email=      state.contact.Email;
            //Commented By: Sneha
            //Country=    state.contact.account.Partner_Registration__r.Country__r.Dell_Online_Country_Code__c;
            //Language=   state.contact.account.Partner_Registration__r.Country__r.User_Language_Locale_Key__c ; 
            //Added as part of PAM Changes
            if(state.request.Country__c != null){
                Country =  state.request.Country__r.Dell_Online_Country_Code__c; 
                Language = state.request.Country__r.User_Language_Locale_Key__c;
            }
            else{
                System.debug('state.contact.account.Account_Country_Code__c::'+state.contact.account.Account_Country_Code__c);
                Country__c countryObject = new Country__c();
                countryObject = [SELECT Id,Dell_Online_Country_Code__c,User_Language_Locale_Key__c
                                             FROM Country__c 
                                             WHERE CODE__C =:state.contact.account.Account_Country_Code__c];
                String strDellCountryCode = countryObject.Dell_Online_Country_Code__c;
                String strDellLanguage = countryObject.User_Language_Locale_Key__c;
                System.debug('strDellCountryCode::'+strDellCountryCode);
                System.debug('strDellLanguage::'+strDellLanguage);
                Country = strDellCountryCode; //state.contact.account.Account_Country_Code__c; 
                Language = strDellLanguage ;
            }
            accid = state.contact.AccountId;
        }  
        if(null != Language)
            Language = Language.substring(0,2);
        Http http = new Http();
        HttpRequest requestToDais = new HttpRequest();
        requestToDais.setEndpoint(system.Label.DAIS_Endpoint_ForgotPassword);
        requestToDais.setMethod('POST');
        requestToDais.setHeader('Content-Type', 'application/json;charset=UTF-8');
        requestToDais.setHeader('x-dell-identity-key', system.Label.DAIS_Identity_Key);
        requestToDais.setHeader('x-dell-identity-restriction-api-key', system.Label.DAIS_Restriction_API_Key);
        requestToDais.setHeader('Cache-Control','no-cache');
        
        String connectionId;
        If(DealRegUtils.isGCCountry() == true){
            connectionId = system.Label.DAIS_ConnectionId_GC;
        }else{
            connectionId = system.Label.DAIS_ConnectionId_NonGC;
        }
        
        // Set the body as a JSON object
        requestToDais.setBody('{"FirstName":"'+FirstName+'","LastName":"'+LastName+'","Email":"'+Email+'","Country":"'+Country+'","Language":"'+Language+'","ConnectionId":"'+connectionId+'"}');
        requestToDais.setTimeout(integer.valueOf(System.Label.DAIS_Timeout_Variable)); // 100000 
        system.debug('++++++getBody'+requestToDais.getBody());
        if(!Test.isRunningTest()){
            HttpResponse response = http.send(requestToDais);
            // Parse the JSON response
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug(response.getBody());
            } else {
                System.debug(response.getBody());
            } 
            state.guid = response.getBody().substringBetween('"ProfileId":"','"');
            //state.guid = 'saadsfdffgfhgghg';
            system.debug('profileid'  +response.getBody().substringBetween('"ProfileId":"','"'));
            system.debug('Forgotpassword'  +response.getBody().substringBetween('"ForgotPasswordRequestId":"','"'));
            //string res = response.getBody();
            if (response.getStatusCode() == 200) {
                Account acc = [select Id, Name from Account where id = :accid limit 1];
                acc.Forgot_Password_Request_Id__c = response.getBody().substringBetween('"ForgotPasswordRequestId":"','"');
                update acc; 
            }
        }
        return ajaxSuccess();
    }
}
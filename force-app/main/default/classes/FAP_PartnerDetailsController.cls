/* 
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0    FY20-0102       FAP Migration   Migrated from FAP managed package 
2.0    10-OCT-2019     Sakshi Shetty   Service Offerings under Summary tab to be displayed country wise for CSP tracks
3.0    24-OCT-2019     Niveda          
4.0    5-NOV-2019      Akshita         FAP - Competency Icons update   
5.0    20-NOV-2019     Akshita         FAP - FED - Summary page - data display
*/

global class FAP_PartnerDetailsController extends FAP_PartnerFinderBaseController implements FAP_SObjectPaginatorListener {
    //==================================================
    // PROPERTIES
    //==================================================
    private static final Integer DEFAULT_PAGE_SIZE = 5;
    
    // EMAIL FIELDS
    public String senderEmailFullName {
        get;
        set;
    }
    public String senderEmailAddress {
        get;
        set;
    }
    public String senderEmailSubject {
        get;
        set;
    }
    public String senderEmailBody {
        get;
        set;
    }
    //CR 12405
    public String senderEmailFirstName {
        get;
        set;
    }
    public String senderEmailLastName {
        get;
        set;
    }
    public String senderEmailPhone {
        get;
        set;
    }
    public String senderEmailCompany {
        get;
        set;
    }
    public String senderEmailBusinessNeed {
        get;
        set;
    }
    public boolean fieldError;
    public String emailValidation {
        get;
        set;
    }
    public String reqErrField {
        get;
        set;
    }
    //CR 12405

    // PAGE LOAD ERROR CODES
    public String eMPTYIDPARAM {
        get {
            return 'EMPTY_ID_PARAM';
        }
    }
    public String rECORDNOTFOUND {
        get {
            return 'RECORD_NOT_FOUND';
        }
    }
    public String aCCESSDENIED {
        get {
            return 'ACCESS_DENIED';
        }
    }
    public String dELETEFAILED {
        get {
            return 'DELETE_FAILED';
        }
    }
    public String tERMSREQUIRED {
        get {
            return 'TERMS_REQUIRED';
        }
    }
    public String lOCATIONREQUIRED {
        get {
            return 'LOCATION_REQUIRED';
        }
    }
    public String eRRORNOMAPAPIKEY {
        get {
            return 'ERROR_NO_MAP_API_KEY';
        }
    }
    public String eRRORNOACCOUNTID {
        get {
            return 'ERROR_NO_ACCOUNT_ID';
        }
    }
    public string eMPTYFIELD {
        get {
            return 'EMPTY_FIELD';
        }
    }

    public Boolean isIE {
        get {
            return FAP_PageUtils.isIE();
        }
    }
    public Boolean isChrome {
        get {
            return FAP_PageUtils.isChrome();
        }
    } // Ver 1.0
    public Boolean isFirefox {
        get {
            return FAP_PageUtils.isFirefox();
        }
    } // Ver 1.0
    public String errorCode {
        get;
        private set;
    }
    public Boolean errorOccurred {
        get {
            return FAP_StringUtils.isNotEmpty(this.errorCode);
        }
    }
    public Boolean isCurrentUserAdmin {
        get;
        set;
    }
    public String googleMapsApiKey {
        get;
        set;
    }
    public String googleMapsApiURL {
        get {
            return FAP_Configuration.getInstance().googleMapsApiURL;
        }
    }
    //5.0 GAN POC
    public String strBaiduMapsApiUrl {
        get {
            return FAP_Configuration.getInstance().baiduMapsApiUrl;
        }
    }
    public String recordId {
        get;
        set;
    }
    public FAP_Partner partnerRecord {
        get;
        set;
    }
    public List < FAP_Location > locations {
        get;
        set;
    }
    public String locationsInJson {
        get;
        set;
    }
    public FAP_SObjectPaginator locationPaginator {
        get;
        set;
    }
    public String selectedLocation {
        get;
        set;
    }
    public List < FAP_FormField > partnerDetailFieldsBasic {
        get;
        set;
    }
    public List < FAP_FormField > partnerDetailFieldsOverview {
        get;
        set;
    }   
    public Boolean checkAgreement {
        get;
        set;
    }
    public String deleteLocationId {
        get;
        set;
    }
     
    public String deleteShowcaseId {
        get;
        set;
    }
    public Account accountForID {
        get;
        set;
    }
    public Account accountToView {
        get;
        set;
    }
    
    public List<Partner_Location__c> partnerTrackLocation {
        get;
        set;
    }
     /*public Account acctcompanydes {
        get;
        set;
    }*/

    public Service_Information__c serviceInfo {
        get;
        set;
    }
    
    // Service Offering Data - PAM Changes
    public List < Service_Offering__c > serviceOfferingFields {
        get;
        set;
    }
	
	//Version 1.0 start
	public map<String,String> mapServiceTechToCountries {
		get;
		set;
	}
	
	public map<String, Service_Offering__c> mapServiceTechToServiceOffering{
		get;
		set;
	}
	//Version 1.0 end
    
    public String activeTab {
        get;
        set;
    }

    //v2.1 Start
    public List < FAP_FormField > smFieldsOverview {
        get;
        set;
    }
    public Social_Media__c socialMediaFields = null;
    private List < FAP_FormField > smEditFields = null;
    //v2.1 End
    public List < FAP_FormField > cmpDesc {
        get;
        set;
    }
    public SObject companydes = null;
    private List < FAP_FormField > cmpDescEditField = null;
    public List < FAP_FormField > partnerLvlFields {
        get;
        set;
    }
    public String accPatnrRelationship {
        get;
        set;
    }
    public String accPatnrType {
        get;
        set;
    }
    public String partnerLvl = null;
    public String partnerLvlDistri = null;
    public String accDistributor = null;
    private FAP_Configuration config;
    Public Boolean afterDelLoc {
        get;
        set;
    }
    //v2.2 Start
    public Boolean showcaseTab {
        get;
        set;
    }
    public String returnPage {
        get;
        set;
    }
    //v2.2 End
    public Boolean servicesTab {
        get;
        set;
    }
    public Social_Media__c services {
        get;
        private set;
    }
    public List < Social_Media__c > servicesDetails {
        get;
        set;
    }
    public Account acct {
        get;
        private set;
    }
    public string oKey{
        get;
        set;
    }
    //v3.0
    public boolean boolIsFed{
        get;
        set;
    }

    private User currentUser = null;

    private static Set < String > accFieldsOverview;
    private static Set < String > accFieldsBasic;
    private static Set < String > locationFields;
    private static ID selectedLocationId;
    private static Map < String, Set < String >> fieldMapLocationStatic = new Map < String, Set < String >> ();
    private static Map < String, Set < String >> fieldMapBasic = new Map < String, Set < String >> ();
    private static Map < String, Set < String >> fieldMapOverview = new Map < String, Set < String >> ();
    private static Map < String, Schema.SObjectField > detailFields = null;
    private String recordIdType;
    private String keyObject;
    private SObject recordToEdit;
    private Map < String, Set < String >> fieldMapLocation = new Map < String, Set < String >> ();
    private List < FAP_FormField > editFields = null;
    private List < String > additionalMessages;
    private Partner_Location__c partnerContactLocation = null;
    //PAM changes
    
    public String partnerDetailsURL {
        get;
        set;
    }

    //Start v2.0
    public FAP_SearchForm form {
        get;
        private set;
    }
    public String paramString {
        get;
        set;
    }
    public String countryCode {
        get;
        set;
    }
    public String urlCountryCode {
        get;
        set;
    }
    public String languageCode {
        get;
        set;
    }
    public String languageCodeOmniture {
        get;
        set;
    } // Added By Sree For Omniture Track
    public List < FAP_FormField > showcaseFieldsOverview {
        get;
        set;
    }
    public String urlAccId {
        get;
        set;
   }
    private Partner_Showcase__c showcaseCustView = null;
    public List < Partner_Showcase__c > showCaseDetails {
        get;
        set;
    }
    public String activeShowcaseTab {
        get;
        set;
    }
    public List < FAP_ShowcaseClass > showCaseFields {
        get;
        set;
    }
    public String showCasesInJson {
        get;
        set;
    }

    //Start v2.4
    public boolean server {
        get;
        set;
    }
    public boolean storage {
        get;
        set;
    }
    public boolean networking {
        get;
        set;
    }
    public boolean dataProtection {
        get;
        set;
    }
    public boolean coreClient {
        get;
        set;
    }
    public boolean clientDataSecurity {
        get;
        set;
    }
    public boolean workstation {
        get;
        set;
    }
    public boolean desktopVirtul {
        get;
        set;
    }
    public boolean digitalTransformation {
        get;
        set;
    }
    public boolean iTTransformation {
        get;
        set;
    }
    public boolean storageservices {
        get;
        set;
    }
    public boolean networkingservices {
        get;
        set;
    }
    public boolean clientservices {
        get;
        set;
    }
    public boolean serverservices {
        get;
        set;
    }
    public boolean hybridCloudPlatformservices {
        get;
        set;
    }
    public boolean dataProtectionservices {
        get;
        set;
    }

    //7.0 start
    public boolean hyperConvergeInfa {
        get;
        set;
    } //Converged/Hyper-Converged Infrastructure
    public boolean hybridCloud {
        get;
        set;
    } //Hybrid Cloud
    public boolean softwDefinedInfa {
        get;
        set;
    } //Software Defined Infrastructure
    public boolean connectedWforce {
        get;
        set;
    } //Connected Workforce
    public boolean hyperConvergeInfaServ {
        get;
        set;
    } //Converged/Hyper-Converged Infrastructure services
    //7.0 End   
    
    //Nath and Vismy created for added new competencies
    public boolean dataAnalytics{
        get;
        set;        
    }  
    public boolean businessApplications{
        get;
        set;        
    }  
	//4.0 start
	public boolean bDellTechnologiesCloud{
        get;
        set;        
    }  
	public boolean bFapOEM{
        get;
        set;        
    }  
	public boolean bInternetOfThings{
        get;
        set;        
    }
	public boolean bUnifiedWorkspace{
        get;
        set;        
    } 
	public boolean bWyseForVDI{
        get;
        set;        
    } 	
	//4.0 end
    public boolean highPerformanceCompute{
        get;
        set;        
    }  
    public boolean ioT{
        get;
        set;        
    }    
    public boolean security{
        get;
        set;        
    } 
    //Ended new competencies changes Nath and Vismy
    
    private Map < String, String > mapServiceCompetency;
    private String strServCompetency;

    //0602 start
    public boolean isDeploymentType {
        get;
        set;
    }
    public boolean isSupportType {
        get;
        set;
    }
    public boolean isConsultingType {
        get;
        set;
    }

    public List < String > listDeploymentType {
        get;
        set;
    }
    public List < String > listSupportType {
        get;
        set;
    }
    public List < String > listConsultingType {
        get;
        set;
    }

    //0602 end

    public integer delCompCount {
        get;
        set;
    }
    public List < string > dellCompetencies {
        get;
        set;
    }
    public string dellCompetenciesStr {
        get;
        set;
    }
    public List < string > dellServicesCompetencies {
        get;
        set;
    }
    public string strDellServicesCompetencies {
        get;
        set;
    }
    public Account accEditID {
        get;
        set;
    }
    private SObject accRecordToEdit;
    private List < FAP_FormField > editAccFields = null;
    public string termsConditionVal {
        get;
        set;
    } //2.6
    public string regionValue {
        get;
        set;
    }
    public integer columnCount {
        get;
        set;
    }
    public string ownerId {
        get;
        set;
    }
    public String accPrimaryCustrVal {
        get;
        set;
    }
    public String accGeograPhy {
        get;
        set;
    }
    public Boolean sandBox {
        get;
        set;
    }
    public String domainUrl {
        get;
        set;
    }
    //v3.0
    public string countrySelected {
        get;
        set;
    }
    public String timeframeSelected {
        get;
        set;
    }
    public String empSelected {
        get;
        set;
    }
    public String errorMessage {
        get;
        set;
    }
    String accFieldNL = 'Partner_Type__c';
    public String nameLoc {
        get;
        set;
    }  
  /* public Partner_Track__c partnerRecordsList{
        get;
        set;
    } */
    public Partner_Location__c partnerLocationObj{
        get;
        set;
    }      
    public Partner_Track__c partnerRecordUpdate
    {
        get;
        set;
    }   
              
    public List < FAP_Country__mdt > countryList;
    public List < String > strTimeframes;
    public List < String > strEmployee;
    //End v3.0
              
   /* New Changes for Detail Page declarations starts here*/           
              
   
   
    public string keyValueWithoutDot= FAP_Configuration.keyValue == 'Account__r.'? FAP_Configuration.keyValue.removeEnd('.').replace('__r',' '):FAP_Configuration.keyValue.removeEnd('.').replace('__r','__c');

   //public string keyValueWithoutDot=FAP_Configuration.keyValue.removeEnd('.').replace('__r','__c');
   

   /* public Partner_Track__c partnerTrackRecordObj {
            get;
            set;
    }*/
              
    String partnerTrackID = null; 
    
    public SObject currentKeyRecordToView;
   
    SObject adminKeyRecordForCurrentUser; 
              
  /*  public List <Partner_Location__c> partnerProgramTier {
        get;
        set;
    }*/
              
   /* New Changes for Detail Page declarations ends here*/             

    //==================================================
    // CONSTRUCTOR 
    //==================================================
    public FAP_PartnerDetailsController() {
        system.debug('**DetailpageCtrl');
        // Ver 1.1:
        oKey= FAP_Configuration.keyValue ;
        isCurrentUserAdmin = false;
        checkAgreement = false;
        this.recordId = FAP_PageUtils.param('id');
        this.keyObject = FAP_Configuration.getInstance().termsAndConditionsUrl;
        //v2.2 -Start - To Hide showcase tab in customer view if no showcase records are present for that account & To make active tab as current working tab on returning from any Edit page
        showcaseTab = false;
        returnPage = null; //test
        returnPage = ApexPages.currentPage().getParameters().get('returnTab');
        //v2.2 - End
        servicesTab = false;
        //v3.0
        reqErrField = null;
        emailValidation = '';
        this.afterDelLoc = false;
        partnerDetailsURL = '/apex/FAP_PartnerDetails?returnTab=' + returnPage;

        //Start v1.3
        this.paramString = FAP_StringUtils.substringAfter(ApexPages.currentPage().getUrl(), '?');
        system.debug('###################### URL would be   ' + ApexPages.currentPage().getUrl());
        this.countryCode = (FAP_PageUtils.param('c') != null ? FAP_PageUtils.param('c').toUpperCase() : '');
        this.urlCountryCode = (FAP_PageUtils.param('urlc') != null ? FAP_PageUtils.param('urlc').toUpperCase() : ''); // Ver 2.10 
        this.languageCode = (FAP_PageUtils.param('l') != null ? FAP_PageUtils.param('l').toUpperCase() : '');
        this.urlAccId = (FAP_PageUtils.param('id') != null ? FAP_PageUtils.param('id').toUpperCase() : ''); //Ver 2.0      
        this.strServCompetency = (FAP_PageUtils.param('servcomp') != null ? FAP_PageUtils.param('servcomp') : null); //Ver 2.0      

        if ((urlCountryCode == null) || (urlCountryCode.trim().length() == 0)) {
            this.urlCountryCode = this.countryCode;
        }
        //Start - Added For Omniture Tool Report Purpose By Sree On 07-Jan-16
        if (this.languagecode.length() > 4) {
            this.languageCodeOmniture = this.languagecode.substring(0, 2);
        } else {
            this.languageCodeOmniture = this.languagecode;
        }
        //End By Sree

        // End

        server = false;
        storage = false;
        networking = false;
        dataProtection = false;
        //ConvergedInfrastructure=false;
        coreClient = false;
        clientDataSecurity = false;
        workstation = false;
        desktopVirtul = false;
        digitalTransformation = false;
        iTTransformation = false;
        storageservices = false;
        networkingservices = false;
        clientservices = false;
        serverservices = false;
        //ConvergedInfrastructureservices=false;
        hybridCloudPlatformservices = false;
        dataProtectionservices = false;
        //Krishna - Start
        hyperConvergeInfa = false;
        hybridCloud = false;
        softwDefinedInfa = false;
        connectedWforce = false;
        hyperConvergeInfaServ = false;
        // End

        isDeploymentType = false;
        isSupportType = false;
        isConsultingType = false;

        dataAnalytics = false;
        businessApplications = false;
		//4.0 start
		bDellTechnologiesCloud = false;
		bFapOEM = false;
		bInternetOfThings = false;
		bUnifiedWorkspace = false;
		bWyseForVDI = false;
		//4.0 end
        highPerformanceCompute = false;
        ioT = false;
        security = false;
        
        ownerId = userinfo.getUserId();
        string sqlConQuery = 'SELECT id, Partner_User__c, AccountID FROM Contact WHERE Partner_User__c=: ownerId limit 1';
        List < Contact > lstPrimaryCon = (List < Contact > ) Database.query(sqlConQuery);

        string accId;
        if (lstPrimaryCon.size() > 0 && lstPrimaryCon != null) {
            accId = lstPrimaryCon[0].AccountID;
        }
        if (accId != null) {
            //Dynamic SOQL Query for getting the client accounts to be merged
            string sqlAccQuery = 'SELECT id, name, Account_Country__c FROM Account WHERE Id =: accId limit 1';
            List < Account > lstPrimaryAccount = (List < Account > ) Database.query(sqlAccQuery);
            for (Account acc: lstPrimaryAccount) {
                accEditID = acc;
            }
        }
        
        populateServCompt();
        getEditAccFields();
        Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType accSchema = schemaMap.get('Account');
        Map < String, Schema.SObjectField > fieldMap = accSchema.getDescribe().fields.getMap();
        String strAcctLocalName = (FAP_Configuration.keyValue == 'Account__r.'? 'NameLocal':'Partner_Track_Account_Local_Name__c');
        for (String fieldName: fieldMap.keySet()) {
            if (fieldName == strAcctLocalName ) {
                accFieldNL = strAcctLocalName;
            }
        }  
    }

    public String country {
        get;
        set;
    }

    public void getipaddress() {
        string returnValue = '';
        returnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        if (returnValue == '' || returnValue == null) {
            returnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }
        if (returnValue == '' || returnValue == null) {
            returnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }
        System.Debug('ReturnValue##' + returnValue);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://ipinfo.io/' + returnValue + '/json?token=dell_internal';
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        HttpResponse res;
        try {
            res = h.send(req);
            Map < string, object > m = (Map < string, object > ) JSON.deserializeUntyped(res.getbody());
            country = (String) m.get('country');
        } catch (Exception e) {}
    }

    public void populateServCompt() {
        mapServiceCompetency = new Map < String, String > ();
        for (FAP_Competency__mdt subComp: [select id, services_Comptency__c, Account_Competency__c from FAP_Competency__mdt where User_type__c = 'Authenticated']) {
            for (String strAccCompt: subComp.Account_Competency__c.split(',')) {
                mapServiceCompetency.put(strAccCompt, subComp.services_Comptency__c);
            }

        }
    }

    // Below code is to fetch from Competency Tracker Object, it is not required for PAM
    
   /* public List < String > fetchCompetencyTracker(String accountId) {
        List < String > listCompletedComp = new List < String > ();
        String strRecName = (FAP_Configuration.keyValue == 'Account__r.'? 'Account__c':'Partner_Track__c');
        FAP_FieldCondition cond = new FAP_FieldCondition(strRecName).equals(accountId);
        final String soql =
            new FAP_SoqlBuilder()
            .selectx(FAP_Configuration.strServicesCompetencies)
            .fromx('Certification_Tracker__c')
            .wherex(cond)
            .toSoql(null);
        List < SObject > objTracker = Database.query(soql);
        for (sObject obj: objTracker) {
            listCompletedComp.add((String) obj.get(FAP_Configuration.strServicesCompetencies));
        }
        return listCompletedComp;
    }*/
     

    //==================================================
    // ACTIONS
    //==================================================
    public PageReference doOnLoad() {
        system.debug('##### doOnload ->');
        try {
            getipaddress();
            //domainUrl = System.URL.getSalesforceBaseURL().getHost();
            Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];

            if (org.IsSandbox) {
                sandBox = true;
            } else {
                sandBox = false;
            }

            this.currentUser = [
                select Contact.AccountId,Contact.Selected_Track__c, Enable_Partner_Admin__c, country
                from User where id =: Userinfo.getUserId()
            ];
             system.debug('currentuser'+  this.currentUser);
            this.form = FAP_SearchForm.deSerialize(this.paramString);
        } catch (QueryException e) {}
        
        if (FAP_StringUtils.isEmpty(this.recordId)) {
            //this.recordId = this.currentUser.Contact.AccountId; 
            this.recordId = (FAP_Configuration.keyValue == 'Account__r.'? this.currentUser.Contact.AccountId:this.currentUser.Contact.Selected_Track__c);
               system.debug('6666666666666666  '+ this.recordId);
        }
        system.debug('############### do OnLoad is called    ');
        this.additionalMessages = new List < String > ();
        String accountId = null;
        initialize();
        //DETERMINE ENTRY POINT
        final String idPrefix = FAP_StringUtils.defaultString(FAP_StringUtils.substring(this.recordId, 0, 3));
         system.debug('Account id............... '+idPrefix);
        if (idPrefix.equals(Account.sObjectType.getDescribe().getKeyPrefix())) {            
            accountId = this.recordId; //Account ID from URL   
            system.debug('Account id '+accountId ); 
        } else if (idPrefix.equals(Partner_Location__c.sObjectType.getDescribe().getKeyPrefix())) {           
            selectedLocationId = this.recordId; //Location ID from URL
            PartnerLocationObj = getPartnerLocationFromLocationID(this.recordId);
             system.debug('11111111111111111'+selectedLocationId );
            accountId = PartnerLocationObj.account__c;
            partnerTrackId = PartnerLocationObj.Partner_Track__c;
            
              system.debug('partnerTrackId--PAM-------'+partnerTrackId);
        } else if (idPrefix.equals(Partner_Track__c.sObjectType.getDescribe().getKeyPrefix())) {            
            partnerTrackId = this.recordId; 
            system.debug('partnerTrackId--PAM-------id'+partnerTrackId);        
        } 
        
        /*if(FAP_Configuration.keyValue == 'Account__r.'){ // FAP
           this.currentKeyRecordToView =loadAccount(accountId);
           this.AdminKeyRecordForCurrentUser = loadAccount(FAP_UserUtils.getCurrentUserPortalAccountID());
           accountToView =(Account)currentKeyRecordToView;
           this.partnerDetailFieldsBasic = FAP_FormField.populateFields(
           FAP_FormField.build(FAP_Configuration.getInstance().detailScreenCompanyBasicFields), accountToView);
           this.partnerDetailFieldsOverview = FAP_FormField.populateFields(
           FAP_FormField.build(FAP_Configuration.getInstance().detailScreenCompanyExtendedFields), accountToView);                         
           
        }
        
        else*/
         if(FAP_Configuration.keyValue == 'Partner_Track__r.'){ // PAM
           System.debug('Line number 838'+FAP_Configuration.keyValue );         
           //accountToView = loadAccount(accountId);
           if(PartnerLocationObj != null){
            this.currentKeyRecordToView = (sObject)PartnerLocationObj.Partner_Track__r;
            
            Partner_Track__c partnerToView = loadPartnertrack(this.currentKeyRecordToView.id);
            partnerTrackLocation = partnerToView.Partner_Locations_1__r;
             if(partnerToView.Partner_Type__c.contains('Federal')){
              boolIsFed= true;
            }
                  
           }
           else
           {
          // to change this.currentKeyRecordToView = loadPartnertrack(partnerTrackId);
          // to change this.AdminKeyRecordForCurrentUser = getPartnerTrackFromPartnertrackID(this.currentUser.Contact.Selected_Track__c);
           this.currentKeyRecordToView = loadPartnertrack(partnerTrackId);
           system.debug('33333333333'+partnerTrackId);
           system.debug('......................'+this.currentKeyRecordToView);
            Partner_Track__c partnerToView = loadPartnertrack(this.currentKeyRecordToView.id);
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+partnerToView );
            partnerTrackLocation = partnerToView.Partner_Locations_1__r;
            system.debug('XXXXXXXXXXXXXXXXXXX'+partnerTrackLocation);
             if(partnerToView.Partner_Type__c.contains('Federal')){
              boolIsFed= true;
           }
               
           } 
          //this.AdminKeyRecordForCurrentUser = getPartnerTrackFromPartnertrackID(this.currentUser.Contact.Selected_Track__c);        
          this.AdminKeyRecordForCurrentUser = loadPartnertrack(this.currentUser.Contact.Selected_Track__c);
           
           this.partnerDetailFieldsBasic = FAP_FormField.populateFields(
           FAP_FormField.build(FAP_Configuration.getInstance().detailScreenPartnerTrackBasicFields), currentKeyRecordToView);
           this.partnerDetailFieldsOverview = FAP_FormField.populateFields(
           FAP_FormField.build(FAP_Configuration.getInstance().detailScreenPartnerTrackExtendedFields), currentKeyRecordToView);
        }

        if (this.currentKeyRecordToView == null) {
            if (this.AdminKeyRecordForCurrentUser == null) {
                return error(eMPTYIDPARAM);
            }           
            currentKeyRecordToView = AdminKeyRecordForCurrentUser;
        } else {          
            currentKeyRecordToView = this.currentKeyRecordToView;
        }
        
      
        this.isCurrentUserAdmin = currentUser == null ? false : 
           // (currentUser.Contact.AccountID == accountToView.id && currentUser.Enable_Partner_Admin__c);
           ((FAP_Configuration.keyValue == 'Account__r.'? this.currentUser.Contact.AccountId:this.currentUser.Contact.Selected_Track__c) == (FAP_Configuration.keyValue == 'Account__r.'? accountToView.id :currentKeyRecordToView.id)&& currentUser.Enable_Partner_Admin__c); 
        
       /* if(FAP_Configuration.keyValue == 'Account__r.'){
             if (FAP_StringUtils.isNotEmpty(FAP_Configuration.getInstance().termsAndConditionsUrl) &&
            FAP_StringUtils.isEmpty(String.valueof(this.currentKeyRecordToView.get('Partner_User_Agreed_to_PF_Terms_Cond__c')))) {
            system.debug('this.currentKeyRecordToView'+this.currentKeyRecordToView.get('Partner_User_Agreed_to_PF_Terms_Cond__c'));
            if (this.isCurrentUserAdmin) {
                return error(tERMSREQUIRED);
            } else {
                return error(aCCESSDENIED);
           }
        }
        }
        else */
        if (FAP_Configuration.keyValue == 'Partner_Track__r.'){
            if (FAP_StringUtils.isNotEmpty(FAP_Configuration.getInstance().termsAndConditionsUrl) &&
            FAP_StringUtils.isEmpty(String.valueof(this.currentKeyRecordToView.get('User_Agreed_to_PF_Terms_Cond__c')))) {
            system.debug('this.currentKeyRecordToView'+this.currentKeyRecordToView.get('User_Agreed_to_PF_Terms_Cond__c'));
            if (this.isCurrentUserAdmin) {
                return error(tERMSREQUIRED);
            } else {
                return error(aCCESSDENIED);
           }
        }
        }
                
        if(this.currentKeyRecordToView != null){
            system.debug('this.currentKeyRecordToView in build--------------------------'+this.currentKeyRecordToView);
        this.partnerRecord = FAP_Partner.build(this.currentKeyRecordToView, FAP_Configuration.getInstance());
        system.debug('Akshita________' + FAP_Configuration.getInstance());
        }
      
         if (partnerDetailFieldsBasic != null && partnerDetailFieldsBasic.size() > 0) 
        {
            dellCompetenciesStr = '';
            strDellServicesCompetencies = '';
            
           /* If(FAP_Configuration.keyValue == 'Account__r.')//pull Competencies from 'Competency Tracker' Object only for FAP
            {
                for (FAP_FormField fmObj: partnerDetailFieldsBasic) 
                {
                   
                    if ((fmObj.label).contains(Label.Dell_Competencies) || (fmObj.label).contains(Label.Dell_Certification_Areas) || fmObj.fieldName.contains('Dell_Certification_Areas__c') || fmObj.name.contains('Dell_Certification_Areas__c') || fmObj.fieldName.contains('Certification_Completed__c')) 
                    {
                        dellCompetenciesStr = dellCompetenciesStr + ';' + string.valueOf(fmObj.typedValueLabel);
                        system.debug('dellCompetenciesStr-----in if--------'+dellCompetenciesStr);
                    }
                }
                
               // List < String > listCertiTracker = fetchCompetencyTracker(accountId);
              //  dellCompetenciesStr += (listCertiTracker.isEmpty()) ? ';' : ';' + String.join(listCertiTracker, ';');
                strDellServicesCompetencies = dellCompetenciesStr;
                
            }else
            {*/
                for (FAP_FormField fmObj: partnerDetailFieldsBasic) 
                {
                   
                    if (fmObj.name.contains('Dell_Certification_Areas__c') || fmObj.fieldName.contains('Certification_Completed__c')) 
                    {
                        dellCompetenciesStr = dellCompetenciesStr + ';' + string.valueOf(fmObj.typedValueLabel);
                        system.debug('dellCompetenciesStr-----else Dell_Certification_Areas__c--------'+dellCompetenciesStr);
                    }
                    
                    if (fmObj.name.contains('Services_Competencies__c'))
                    {
                            strDellServicesCompetencies = strDellServicesCompetencies + ';' + string.valueOf(fmObj.typedValueLabel);
                            system.debug('strDellServicesCompetencies-----if--------'+dellCompetenciesStr);
                    }
                }
            //}             
             
            dellCompetenciesStr         = dellCompetenciesStr.trim();
            strDellServicesCompetencies = strDellServicesCompetencies.trim();
            
            dellCompetenciesStr         = dellCompetenciesStr.substring(1,dellCompetenciesStr.length());
            strDellServicesCompetencies = strDellServicesCompetencies.substring(1,strDellServicesCompetencies.length());
            
            System.debug('$$$Dell Competencies:  '     + dellCompetenciesStr);
            System.debug('$$$Services Competencies:  ' + strDellServicesCompetencies);
            
        }
            
        delCompCount = 0;
        
        if (dellCompetenciesStr != null && dellCompetenciesStr != '' && dellCompetenciesStr.length() > 0) 
        {
            
            dellCompetenciesStr = dellCompetenciesStr.replaceAll('; ', ';');
            dellCompetencies = dellCompetenciesStr.split(';');
            
            System.debug('@@@Dell Competencies:  ' + dellCompetencies);
            
            for (string strObj: dellCompetencies) 
            {
            
                if (strObj == Label.IT_Transformtion) {
                    ITTransformation = true;
                }
                if (strObj == Label.Digital_Transformtion) {
                    DigitalTransformation = true;
                }
                if (strObj == Label.Converged_Hyper_Converged_Infrastructure || strObj == Label.Converged_Infrastruct) {
                    HyperConvergeInfa = true;
                }
                if (strObj == Label.Data_Protect) {
                    dataProtection = true;
                }
                if (strObj == Label.Storage_Com) {
                    storage = true;
                }
                if (strObj == Label.Server_Com) {
                    server = true;
                }
                if (strObj == Label.Networking_Com) {
                                                            system.debug('networking ----------line no 1013--------'+strObj);
                                                            system.debug('networking ----------line no 1014--------'+networking );
                    networking = true;
                }
                if (strObj == Label.Core_Clint) {
                    coreClient = true;
                }
                if (strObj == Label.Client_Data_Secur) {
                    clientDataSecurity = true;
                }
                if (strObj == Label.Workstation_Com) {
                    workstation = true;
                }
                if (strObj == Label.Desktop_Virtualization_Sol) {
                    desktopVirtul = true;
                }
                if (strObj == Label.Software_Defined_Infrastructure) {
                    SoftwDefinedInfa = true;
                }
                if (strObj == Label.Hybrid_Cloud) {
                    HybridCloud = true;
                }
                if (strObj == Label.Connected_Workforce) {
                    ConnectedWforce = true;
                }
				//4.0 start
                if (strObj == Label.Data_Analytc) {
                    dataAnalytics = true;
                }
                if (strObj == Label.Business_Applicatns) {
                    businessApplications = true;
                }    
                if (strObj == Label.Dell_Tech_Cld) {
                    bDellTechnologiesCloud = true;
                }  
				if (strObj == Label.FP_OM) {
                    bFapOEM = true;
                }  
				if (strObj == Label.Internet_of_Thng_IoT) {
                    bInternetOfThings = true;
                }
				if (strObj == Label.Unified_Wrkspc) {
                    bUnifiedWorkspace = true;
                }
				if (strObj == Label.WyseVDI) {
                    bWyseForVDI= true;
                }
                if (strObj == Label.High_Perform_Compute) {
                    highPerformanceCompute = true;
                }     
				//4.0 end               
                if (strObj == Label.IoT) {
                    IoT = true;
                }  
                if (strObj == Label.Security) {
                    security = true;
                }
                
                //FAP Competency Meta
                
                if (mapServiceCompetency.containsKey(strObj)) 
                {
                    String strCompe = mapServiceCompetency.get(strObj);
                    if (strCompe == Label.Converged_Hyper_Converged_Infrastructure_services || strCompe == Label.Converged_Infrastructure_Servics) {
                        HyperConvergeInfaServ = true;
                    }
                    if (strCompe == Label.Hybrid_Cloud_Platform_Servics) {
                        HybridCloudPlatformservices = true;
                    }
                    if (strCompe  == Label.Data_Protection_Servics) {
                        DataProtectionservices = true;
                    }
                    if (strCompe == Label.Server_Servics) {
                        Serverservices = true;
                    }
                    if (strCompe == Label.Client_services_Deployment) {
                        Clientservices = true;
                    }
                    if (strCompe == Label.Storage_Servics) {
                        Storageservices = true;
                    }
                    if (strCompe == Label.Networking_Servics) {
                        system.debug('Label ------------------'+strCompe);
                        system.debug('Networkingservices ------------------'+Networkingservices);
                        Networkingservices = true;
                    }
                }
            }
        } 
                                   
        //services related Competency separated.
                    
        if (strDellServicesCompetencies != null && strDellServicesCompetencies != '' && strDellServicesCompetencies.length() > 0) 
        {
            Set < String > setDeploymentType = new Set < String > ();
            Set < String > setSupportType = new Set < String > ();
            Set < String > setConsultingType = new Set < String > ();
            
            strDellServicesCompetencies = strDellServicesCompetencies.replaceAll('; ', ';');
            dellServicesCompetencies  = strDellServicesCompetencies.split(';');
            
            System.debug('@@@Services Competencies:  ' + dellServicesCompetencies);
            
            for (string strObj: dellServicesCompetencies) 
            {
                if (mapServiceCompetency.containsKey(strObj)) 
                {
                    servicesTab = true; // 0602 services Tab visibility...
                    
                    if (strObj.contains('Deployment') || Label.Deployment_Competencies_xtra.contains(strObj)) {
                        isDeploymentType = true;
                        setDeploymentType.add(strObj);
                    }
                    if (strObj.contains('Support')) {
                        isSupportType = true;
                        setSupportType.add(strObj);
                    }
                    if (strObj.contains('Consultancy')) {
                        isConsultingType = true;
                        setConsultingType.add(strObj);
                    }
                }
            }
            listDeploymentType = new List < String > (setDeploymentType);
            listSupportType = new List < String > (setSupportType);
            listConsultingType = new List < String > (setConsultingType);
            listDeploymentType.sort();
            listSupportType.sort();
            listConsultingType.sort();
        }

        PrimaryCstr();
        //v2.1 Start - Social Media Edit
        this.SocialMediaFields = getSocialMediaFields();
        this.smEditFields = FAP_FormField.build(FAP_Configuration.getInstance().detailScreenSMExtendedFields);
        this.smFieldsOverview = FAP_FormField.populateFields(this.smEditFields, this.SocialMediaFields);
        this.Companydes = getCompanydes();
        this.cmpDescEditField = FAP_FormField.build(FAP_Configuration.getInstance().detailScreenEditCompDesc);
        this.cmpDesc = FAP_FormField.populateFields(this.cmpDescEditField, this.companydes);
        //v3.0 - show Lead TimeFrame and Employee picklist          
        countryList = [Select FAP_Country_Value__c From FAP_Country__mdt Where FAP_Country_Value__c != null and Region__c != null ORDER BY FAP_Country_Value__c ASC];
        if (getPicklistValues('Lead', 'Purchase_Timeframe__c') != null) {
            strTimeframes = getPicklistValues('Lead', 'Purchase_Timeframe__c');
        }
        if (getPicklistValues('Lead', 'Employees__c') != null) {
            strEmployee = getPicklistValues('Lead', 'Employees__c');
        }
        //v3.0 - end
        this.fieldMapLocation = fieldMapLocationStatic;
        this.partnerContactLocation = getPartnerContactLocation();
       this.acct = this.accountToView;
        
        this.services = getservices();
        this.servicesDetails = getservicesDetails();
        partnerLvl = getPatnerLvl();
        if (this.servicesDetails != null && this.servicesDetails.size() > 0) {
            for (Social_Media__c scObj: servicesDetails) {
                if (scObj.services__c != null) {
                    servicesTab = true;
                }
            }
        }     
        If(FAP_Configuration.keyValue != 'Account__r.'){
            this.serviceInfo = getServiceInfo(PartnerTrackID);
        }
        
        
        //Service offering fields - PAM Changes
        this.serviceOfferingFields = getServiceOfferingData();
        system.debug('@@this.serviceOfferingFields' +this.serviceOfferingFields);
        
        this.showCaseDetails = getShowCaseDetails();
        If(this.showCaseDetails != null && this.showCaseDetails.size() > 0) {
            showcaseTab = true;
        }
        this.locationPaginator = new FAP_SObjectPaginator(DEFAULT_PAGE_SIZE, this);
        //this.locationPaginator.setRecords(accountToView.Partner_Locations__r);
        this.locationPaginator.setRecords(FAP_Configuration.keyValue == 'Account__r.'? accountToView.Partner_Locations__r : partnerTrackLocation); 
        return null;
    }
    
    public List < SelectOption > getsenderEmailCountry() {
        List < SelectOption > countryOptions = new List < SelectOption > ();
         system.debug('CountryList----------------'+CountryList);
        countryOptions.add(new SelectOption('', '--'));
        for (FAP_Country__mdt option: CountryList) {
            countryOptions.add(new SelectOption(option.FAP_Country_Value__c, option.FAP_Country_Value__c));
        }
        system.debug('countryOptions----------------'+countryOptions);
        return countryOptions;
    }

    public List < SelectOption > getTimeframeOptions() {
        List < SelectOption > timeframeOptions = new List < SelectOption > ();
        timeframeOptions.add(new SelectOption('', '--'));
        for (String option: strTimeframes) {
            system.debug('timeframe option: ' + option);
            if (option.contains(Label.timeframe_1_6_months) || option.contains('1-6 months')) {
                timeframeOptions.add(new SelectOption(Label.timeframe_1_6_months, Label.timeframe_1_6_months));
            } else if (option.contains(Label.timeframe_3_months) || option.contains('3 months')) {
                timeframeOptions.add(new SelectOption(Label.timeframe_3_months, Label.timeframe_3_months));
            } else if (option.contains(Label.timeframe_6_months) || option.contains('6 months')) {
                timeframeOptions.add(new SelectOption(Label.timeframe_6_months, Label.timeframe_6_months));
            } else if (option.contains(Label.timeframe_7_12_months) || option.contains('7-12 months')) {
                timeframeOptions.add(new SelectOption(Label.timeframe_7_12_months, Label.timeframe_7_12_months));
            } else if (option.contains(Label.timeframe_9_months) || option.contains('9+ months')) {
                timeframeOptions.add(new SelectOption(Label.timeframe_9_months, Label.timeframe_9_months));
            } else if (option.contains(Label.timeframe_Immediately) || option.contains('Immediately')) {
                timeframeOptions.add(new SelectOption(Label.timeframe_Immediately, Label.timeframe_Immediately));
            } else if (option.contains(Label.timeframe_Undecided) || option.contains('Undecided')) {
                timeframeOptions.add(new SelectOption(Label.timeframe_Undecided, Label.timeframe_Undecided));
            } else if (option.contains(Label.timeframe_13_24_months) || option.contains('13-24+ months')) {
                timeframeOptions.add(new SelectOption(Label.timeframe_13_24_months, Label.timeframe_13_24_months));
            }     
        }
        return timeframeOptions;
    }

    public List < SelectOption > getempOptions() {
        List < SelectOption > empOptions = new List < SelectOption > ();
        empOptions.add(new SelectOption('', '--'));
        System.Debug('Entered empOptions');
        for (String option: strEmployee) {
            empOptions.add(new SelectOption(option, option));
        }
        return empOptions;
    }
    
    public List < FAP_FormField > getEditAccFields() {
        if (editAccFields == null) {
            this.editAccFields = FAP_FormField.build(FAP_Configuration.getInstance().detailScreenEditFields);
            this.setAccEditDetailRecord();
            this.editAccFields = FAP_FormField.populateFields(this.editAccFields, accRecordToEdit);
        }
        return editAccFields;
    }
    
    private void setAccEditDetailRecord() {
        this.accRecordToEdit = null;
        try {
            this.accRecordToEdit = Database.query(
                new FAP_SoqlBuilder()
                .selectx(getAccountFields())
                .fromx('Account')
                .wherex(new FAP_FieldCondition('id', this.accEditID.id))
                .toSoql());
        }catch (Exception exp) {
        }
    }

    public PageReference clickTab() {
        this.activeTab = FAP_PageUtils.param('tab');
        return null;
    }

    public PageReference clickDetailsTab() {
        this.activeTab = 'Details';
        return null;
    }

    public PageReference clickShowcaseTab() {
        this.activeShowcaseTab = 'Showcase';
        return null;
    }

    public PageReference cancelDetail() {
        if (this.activeTab == 'Services') {
            PageReference pg = new PageReference('/apex/FAP_PartnerDetails?returnTab=services');
            pg.setRedirect(true);
            return pg;
        } else {
            PageReference pg = new PageReference('/apex/FAP_PartnerDetails?returnTab=Details');
            pg.setRedirect(true);
            return pg;
        }
        //return backToPartnerDetails();       
    }

    private PageReference error(String errorCode) {
        this.errorCode = errorCode;
        return null;
    }

    public PageReference backToPartnerDetails() {
        system.debug('********************************************');
        PageReference pageRef = page.FAP_PartnerDetails;
        pageRef.setRedirect(false);
        pageRef.getParameters().put('id', this.recordId);
        pageRef.getParameters().put('l', this.languageCode);
        return pageRef;
    }

    public PageReference saveDetail() {
        if (additionalMessages != null) {
            additionalMessages.clear();
        }
        if (recordToEdit != null) {
            FAP_FormField.populateSObject(recordToEdit, this.editFields);

            if (this.editFields != null && this.editFields.size() > 0) {
                for (FAP_FormField fmObj: this.editFields) {
                    if (((fmObj.name == 'Partner_Self_Description_Short__c') || (fmObj.fieldName == 'Partner_Self_Description_Short__c')) && (FAP_StringUtils.isEmpty((fmObj.value).trim()))) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Company_Overview_You_must_enter_a_value));
                        return null;
                    }
                    if (((fmObj.name == 'Website') || (fmObj.fieldName == 'Website') ||(fmObj.name == 'Website__c')|| (fmObj.fieldName == 'Website__c')) && (FAP_StringUtils.isEmpty((fmObj.value).trim()))) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.You_must_enter_a_value));
                        return null;
                    }
                    if (((fmObj.name == 'Partner_Self_Description_Short__c') || (fmObj.fieldName == 'Partner_Self_Description_Short__c')) && ((fmObj.value).trim().length() > 255)) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Company_Overview_Error_Message));
                        return null;
                    }
                    if (((fmObj.name == 'Website') || (fmObj.fieldName == 'Website') ||(fmObj.name == 'Website__c')|| (fmObj.fieldName == 'Website__c')) && ((fmObj.value).trim().length() > 255)) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Website_Error_Message));
                        return null;
                    }

                }
            }
            Database.Saveresult result = null;

            try {

                result = Database.update(recordToEdit);
            } catch (Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.msgdetailrecordnotedited));

                //return null;
            }
            if (result != null && result.isSuccess()) {
                this.additionalMessages.add(Label.msgdetailrecordedited);

            } else {
                this.additionalMessages.add(Label.msgdetailrecordnotedited);
            }
        } else {
            this.additionalMessages.add(Label.internal_error_record_not_found);
        }
        if (companydes != null) {
            for (FAP_FormField fmObj: this.cmpDesc) {
                if (((fmObj.name == 'Partner_Self_Description_Long__c') || (fmObj.fieldName == 'Partner_Self_Description_Long__c')) && ((fmObj.value).trim().length() > 5000)) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Company_Description_Error_Message));
                    return null;
                }
                if (((fmObj.name == 'Partner_Self_Description_Long__c') || (fmObj.fieldName == 'Partner_Self_Description_Long__c')) && ((fmObj.value).trim().length() != null)) {
                    if ((fmObj.value).contains('<img')) {
                        apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, Label.Company_Desc_Image_Error));
                        return null;
                    }
                }
            }

            FAP_FormField.populateSObject(companydes, this.cmpDescEditField);
            //companydes.Account = null;
            Database.upsertresult compDescResult = null;
            try {
                compDescResult = Database.upsert(companydes);
            } catch (Exception e) {
                return null;
            }

        }
        if ((services.services__c).contains('<img')) {
            apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR, Label.services_Image_Error));
            return null;
        }
        
        if ((services.services__c).trim().length() > 5000) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.services_Description_Error_Msg));
            return null;
        }
        
             ID partnerAccountId;
                /*if(FAP_Configuration.keyValue == 'Account__r.')
                {
                    partnerAccountId = this.currentKeyRecordToView.id; 
                }
                else
                {*/
                     Partner_Track__c partnerTrackAccount = (Partner_Track__c ) this.currentKeyRecordToView;
                     // partnerAccountId = partnerTrackAccount.Primary_SMAffinity_Account__c;
                    partnerAccountId = partnerTrackAccount.id;
               // }
       
               
        if (SocialMediaFields != null) {
            FAP_FormField.populateSObject(SocialMediaFields, this.smEditFields);
            Database.upsertresult smResult = null;
            try {
                SocialMediaFields.services__c = services.services__c;
                smResult = Database.upsert(SocialMediaFields);
                //4.0:added below codition to update date of profile field when any changes happens on edit summary
                if (accountForID != null) {
                    FAP_PageUtils.dateOfProfileUpdate(partnerAccountId);
                }
            } catch (Exception e) {
                return null;
            }
        } 

        if (this.activeTab == 'services') {
            if (services.services__c != null && services.services__c != '') {
                PageReference pg = new PageReference('/apex/FAP_PartnerDetails?returnTab=Services');
                pg.setRedirect(true);
                return pg;
            } else {
                PageReference pg = new PageReference('/apex/FAP_PartnerDetails?returnTab=Details');
                pg.setRedirect(true);
                return pg;
            }
        } else {
            PageReference pg = new PageReference('/apex/FAP_PartnerDetails?returnTab=Details');
            pg.setRedirect(true);
            return pg;
        }

    }
    
    public PageReference cancelContactEmail() {
        return backToPartnerDetails();
    }
 
    public PageReference updateTermsAndContitionsStatus() {
        
         Database.Saveresult result;
               /* if(FAP_Configuration.keyValue == 'Account__r.'){
                    this.accountForID.Partner_User_Agreed_to_PF_Terms_Cond__c = Userinfo.getUserId();
                    this.accountForID.Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now();
                       result = Database.update(this.accountToView);
                } else */
                if(FAP_Configuration.keyValue == 'Partner_Track__r.'){
                    this.PartnerRecordUpdate =(Partner_Track__c)currentKeyRecordToView;
                    this.PartnerRecordUpdate.User_Agreed_to_PF_Terms_Cond__c = Userinfo.getUserId();
                    this.PartnerRecordUpdate.Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now();
                    result = Database.update(this.PartnerRecordUpdate);
                }
        
         if (result.isSuccess()) {
            PageReference pageRef = Page.FAP_PartnerDetails;
            pageRef.setRedirect(false);
            return pageRef;
        }
        return null;
    }

    public PageReference updatePublishStatus() {
        String accField = FAP_Configuration.keyValue+'Id';
        system.debug('**UP accField'+accField);
        if (additionalMessages != null) {
            additionalMessages.clear();
        }
        try {
            String param = FAP_PageUtils.param('publish');
            if ('Yes'.equalsIgnoreCase(param) || 'No'.equalsIgnoreCase(param)) {
                if ('Yes'.equalsIgnoreCase(param)) {
                    //validate at least one location has been added
                    try {
                        //String sQuery= 'select count() from Partner_Location__c where ' + accField  +' = \''+this.currentKeyRecordToView.id+  '\'';
                        String sQuery= 'select id from Partner_Location__c where ' + accField  +' = \''+this.currentKeyRecordToView.id+  '\'';
                        system.debug('**UP sQuery'+sQuery);
                        List<Partner_Location__c> locationCount = Database.query(sQuery);
                        system.debug('**UP sQuery'+locationCount);                   
                        if (locationCount.size() < 1) {
                            this.additionalMessages.add(Label.your_profile_cannot_be_published_in_ord); //Syazwan 15.06.2015 9.48am
                            return null;
                        }
                    } catch (QueryException e) {
                        FAP_PageUtils.addFatal('{Label.publish_unpublish_error}' + e.getMessage());
                    }
                }
            }
            this.partnerRecord = FAP_Partner.build(this.currentKeyRecordToView, FAP_Configuration.getInstance());
            Database.Saveresult result;
                /*if(FAP_Configuration.keyValue == 'Account__r.'){
                    this.accountToView.Profile_Published_to_Partner_Finder__c = param;
                    this.accountToView.Date_of_Profile_Update__c = datetime.now();
                       result = Database.update(this.accountToView);
                } else if(FAP_Configuration.keyValue == 'Partner_Track__r.'){*/
                    this.PartnerRecordUpdate =(Partner_Track__c)currentKeyRecordToView;
                    this.PartnerRecordUpdate.Profile_Published_to_Partner_Finder__c = param;
                    this.PartnerRecordUpdate.Date_of_Profile_Update__c = datetime.now();
                    result = Database.update(this.PartnerRecordUpdate);
               // }
            
                if (result.isSuccess()) {
                    if ('Yes'.equalsIgnoreCase(param)) {
                        FAP_PageUtils.addInfo(Label.msgpartnerpublished);
                    } else {
                        FAP_PageUtils.addInfo(Label.msgpartnerunpublished);
                    }
                } else {
                    if ('Yes'.equalsIgnoreCase(param)) {
                        FAP_PageUtils.addInfo(Label.msgpartnernotpublished);
                    } else {
                        FAP_PageUtils.addInfo(Label.msgpartnernotunpublished);
                    }
                }
        } catch (Exception exp) {
            FAP_PageUtils.addFatal('{!$Label.publish_unpublish_error}' + exp.getMessage());
        }
        return null;
    }

    public PageReference sendContactEmail() {
        //v3.0
        try {
            Lead channelLead = new Lead();
            System.Debug('checkContactUsFormField()' + checkContactUsFormField());
            if (!checkContactUsFormField()) {
                emailValidation = '';
                System.Debug('Enter If');
                Map < String, Schema.SObjectType > mapSObjectNameToSObjects = Schema.getGlobalDescribe();
                
                // Custom Setting
                Schema.SObjectType customSettingObjType = mapSObjectNameToSObjects.get('LeadCustomField__mdt'); //'LeadCustomField__mdt'
                System.Debug('customSettingObjType'+ customSettingObjType);              
              Set < String > cs = new Set < String > ();
                
                for (LeadCustomField__mdt obj: [SELECT Id,MasterLabel,DeveloperName,TextArea__c,Type_c__c FROM LeadCustomField__mdt]) {
                    cs.add(obj.MasterLabel.toLowerCase());
                }
                System.Debug('ccs'+ cs); 
                // Source Object
                Schema.SObjectType sourceObjType = mapSObjectNameToSObjects.get('Lead'); //'Lead'
                Schema.DescribeSObjectResult sourceDescribeResult = sourceObjType.getDescribe();
                Map < String, Schema.SObjectField > mapSourceFieldNameToFields = sourceDescribeResult.fields.getMap();

                //Target Object
                Schema.SObjectType targetObjType = mapSObjectNameToSObjects.get('Lead'); //'Lead'
                String partnerAccountId;
                /*if(FAP_Configuration.keyValue == 'Account__r.')
                { 
                    system.Debug('**this.currentKeyRecordToView.id'+ this.currentKeyRecordToView.id); 
                    system.Debug('**currentKeyRecordToView.id'+ currentKeyRecordToView.id); 
                    partnerAccountId = this.currentKeyRecordToView.id; 
                    system.Debug('**this.partnerAccountId '+ partnerAccountId); 
                }
                else
                {*/
                    system.Debug('**this.currentKeyRecordToView.id'+ this.currentKeyRecordToView.id); 
                    system.Debug('**currentKeyRecordToView.id'+ currentKeyRecordToView.id); 
                    Partner_Track__c partnerTrackAccount = (Partner_Track__c ) this.currentKeyRecordToView;
                    partnerAccountId = partnerTrackAccount.Primary_SMAffinity_Account__c;
                    system.Debug('**partnerTrackAccount'+ partnerTrackAccount);
                    system.Debug('**partnerAccountId'+ partnerAccountId);
                //}
               
                      
                Map < String, String > fieldAPIToInputTextMap = new Map < String, String > {
                    'firstname' => this.senderEmailFirstName,
                    'lastname' => this.senderEmailLastName,
                    'email' => this.senderEmailAddress,
                    'phone' => this.senderEmailPhone,
                    'company' => this.senderEmailCompany,
                    'country' => this.countrySelected,
                    'status' => 'Assigned to Channel partner',
                    'leadsource' => 'Web',
                    'questions_comments__c' => this.senderEmailBusinessNeed,
                    'purchase_timeframe__c' => this.timeframeSelected != null ? this.timeframeSelected : 'Immediately',
                    'employees__c' => this.empSelected != null ? this.empSelected : '1000+',
                   // 'partner_account__c' => this.currentKeyRecordToView.id,
                     'partner_account__c' => partnerAccountId,
                      'fap_originated_lead__c'=>'Yes',
                    'fap_point_of_contact_email__c' => this.partnerContactLocation.Point_of_Contact_Email__c != null ? this.partnerContactLocation.Point_of_Contact_Email__c : 'test_partner@email.com',
                    'partner_lead_status__c' => 'New'
                };
                
                system.debug('fieldAPIToInputTextMap--'+ fieldAPIToInputTextMap);
                system.debug('mapSourceFieldNameToFields--'+ mapSourceFieldNameToFields);
                
                sObject sTargetObj = targetObjType.newSObject();
                
                for (String obj: mapSourceFieldNameToFields.keyset()) {
                    if (cs.contains(obj)) {
                        sTargetObj.put(obj, fieldAPIToInputTextMap.get(obj));
                    }
                }
                system.debug('sTargetObj--'+ sTargetObj);
        
                database.saveResult rsl = database.insert(sTargetObj);
                if (rsl.isSuccess()) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fapContactUs_Confirmation));
                }
            } else {
                //throw error
                reqErrField = Label.fapContactUs_Error + ' : ' + Label.fapContactUs_errRequiredField;

                return null;
            }
            system.debug('reqErrField---error-----'+reqErrField);
        } catch (DmlException e) {
            system.debug('DMLException: ' + e.getMessage());
            if (e.getMessage().contains('invalid email')) {
                emailValidation = 'Invalid email address: ' + this.senderEmailAddress;
            }
            return null;
        } catch (Exception e) {
            system.debug('sendContactEmail issue: ' + e.getMessage());
        }
        return backToPartnerDetails();
    }

    public boolean checkContactUsFormField() {
        fieldError = false;
        system.debug('this.senderEmailFirstName: ' + FAP_StringUtils.isEmpty(this.senderEmailFirstName));
        //FirstName required field checking
        if ((this.senderEmailFirstName == null || FAP_StringUtils.isEmpty(this.senderEmailFirstName)) ||
            (this.senderEmailLastName == null || FAP_StringUtils.isEmpty(this.senderEmailLastName)) ||
            (this.senderEmailAddress == null || FAP_StringUtils.isEmpty(this.senderEmailAddress)) ||
            (this.senderEmailCompany == null || FAP_StringUtils.isEmpty(this.senderEmailCompany)) ||
            (this.countrySelected == null || FAP_StringUtils.isEmpty(this.countrySelected)) ||
            (this.senderEmailBusinessNeed == null || FAP_StringUtils.isEmpty(this.senderEmailBusinessNeed))) {

            fieldError = true;
            system.debug('fieldError: ' + fieldError);
        }
        return fieldError;
    }

    public PageReference deleteLocation() {
        String accField=FAP_Configuration.keyValue+'Id';
        if (additionalMessages != null) {
            additionalMessages.clear();
        }
        if (!FAP_StringUtils.isEmpty(deleteLocationId)) {
            Database.Deleteresult deleteResult = Database.delete(deleteLocationId);
            if (deleteResult.isSuccess()) {
                  String sQuery= 'select id from Partner_Location__c where ' + accField  +' = \''+this.currentKeyRecordToView.id+  '\'';
                  List<Partner_Location__c> locationCount = Database.query(sQuery);                   
                  if (locationCount.size() < 1) {
                    //updatePublishStatus();
                    this.afterDelLoc = true;
                    //this.partnerRecord = FAP_Partner.build(this.accountToView, FAP_Configuration.getInstance());
                    this.partnerRecord = FAP_Partner.build(this.currentKeyRecordToView, FAP_Configuration.getInstance());
                    /*if(FAP_Configuration.keyValue == 'Account__r.')
                    {
                    this.accountToView.Profile_Published_to_Partner_Finder__c = 'No';
                    this.accountToView.Date_of_Profile_Update__c = datetime.now();                   
                    Database.Saveresult result = Database.update(this.accountToView);
                    }
                    else
                    {*/
                      this.PartnerRecordUpdate =(Partner_Track__c)currentKeyRecordToView;
                      this.PartnerRecordUpdate.Profile_Published_to_Partner_Finder__c = 'No';
                      this.PartnerRecordUpdate.Date_of_Profile_Update__c = datetime.now();                   
                    Database.Saveresult result = Database.update(this.PartnerRecordUpdate);
                    //}                    
                    
                }
                //4.0:added below codition to update date of profile field when any showcase record deleted
                Id partnerAccountId;
                if(FAP_Configuration.keyValue == 'Account__r.')
                {
                    partnerAccountId = this.currentKeyRecordToView.id; 
                }
                else
                {
                     Partner_Track__c partnerTrackAccount = (Partner_Track__c ) this.currentKeyRecordToView;
                    partnerAccountId = partnerTrackAccount.id;
                }
              
       
                if (currentKeyRecordToView  != null) {
                    
                    FAP_PageUtils.dateOfProfileUpdate(partnerAccountId);
                }
                List < SObject > records = this.locationPaginator.all;
                system.debug('records--------------'+records);
                for (Integer i = 0; i < records.size(); i++) {
                    if (deleteLocationId.equalsIgnoreCase(records.get(i).Id)) {
                    system.debug('deleted----------');
                        FAP_PageUtils.addInfo('{!$Label.location_deleted}');
                        records.remove(i);
                        break;
                    }
                }
                this.locationPaginator.setRecords(records);
                system.debug('this.locationPaginator----------'+this.locationPaginator);
            } else {
                FAP_PageUtils.addInfo(Label.deletion_failed);
            }
        }
        return null;
    }

    public pagereference deleteShowcase() {
        if (additionalMessages != null) {
            additionalMessages.clear();
        }
               Id partnerAccountId;
                /*if(FAP_Configuration.keyValue == 'Account__r.')
                {
                    partnerAccountId = this.currentKeyRecordToView.id; 
                }
                else
                {*/
                     Partner_Track__c partnerTrackAccount = (Partner_Track__c ) this.currentKeyRecordToView;
                   // partnerAccountId = partnerTrackAccount.Primary_SMAffinity_Account__c;
                   partnerAccountId = partnerTrackAccount.id;
                //}
         
        if (!FAP_StringUtils.isEmpty(deleteShowcaseId)) {
            Database.Deleteresult deleteResult = Database.delete(deleteShowcaseId);
            if (deleteResult.isSuccess()) {
                //4.0:added below codition to update date of profile field when any showcase record deleted
                if (currentKeyRecordToView  != null){
                    system.debug('partnerAccountId-------------in delete'+partnerAccountId);
                    FAP_PageUtils.dateOfProfileUpdate(partnerAccountId);
                }
            }
            getShowCaseDetails();
        } else {
            FAP_PageUtils.addInfo(Label.deletion_failed);
        }
        return null;
    }

    public PageReference skipToLocation() {
        String pageNumberParam = FAP_PageUtils.param('pageNumber');
        if (FAP_StringUtils.isNumeric(pageNumberParam)) {
            this.locationPaginator.skipToPage(Integer.valueOf(pageNumberParam));
        }
        return null;
    }

    public PageReference toggleEmail() {
        showEmail = !showEmail;
        if (showEmail) {
            //reset form
            senderEmailFirstName = null;
            senderEmailLastName = null;
            senderEmailAddress = null;
            senderEmailPhone = null;
            senderEmailCompany = null;
            countrySelected = null;
            senderEmailBusinessNeed = null;
            timeframeSelected = null;
            empSelected = null;
            fieldError = false;
            reqErrField = null;

        }
        return Page.FAP_Email_Partner;
    }

    public PageReference toggleEditDetail() {
        return Page.FAP_PartnerDetailsEdit;
    }

    // Add Showcase Link
    public PageReference addNewShowcase() {
        return Page.FAP_EditShowcase;
    }

    //==================================================
    // DERIVED PROPERTIES
    //==================================================
    public List < String > getMessages() {
        List < String > msgList = new List < String > ();
        if (this.additionalMessages != null && !this.additionalMessages.isEmpty()) {
            for (String msg: this.additionalMessages) {
                if (msg.startsWith('Page:')) {
                    msg = msg.substringAfter(': ');
                }
                msgList.add(msg);
            }
        }
        return msgList;
    }

    public String getSearchStateParams() {
        List < String > params = new List < String > ();
        system.debug('URL $$$$$$'+ApexPages.currentPage().getUrl());
        system.debug('URL Params $$$$$$$'+FAP_StringUtils.substringAfter(ApexPages.currentPage().getUrl(), '?'));
        params.add(FAP_StringUtils.substringAfter(ApexPages.currentPage().getUrl(), '?'));
        system.debug('Joined URL Params $$$$$$$'+FAP_StringUtils.joinArray(params, '&'));
        return FAP_StringUtils.joinArray(params, '&');
    }

    public void setEditFields(List < FAP_FormField > fields) {
        editFields = fields;
    }

    public List < FAP_FormField > getEditFields() {
        if (editFields == null) {
            //this.editFields = FAP_FormField.build(FAP_Configuration.getInstance().detailScreenEditFields);
            this.editFields = FAP_FormField.build(FAP_Configuration.getInstance().detailPartnerTrackScreenEditFields); //Website Edit Detail Fix
            this.setEditDetailRecord();
            this.editFields = FAP_FormField.populateFields(this.editFields, recordToEdit);
        }
        return editFields;
    }

    public String getTermsAndConditionsURL() {
        return FAP_Configuration.getInstance().termsAndConditionsUrl;
    }

    private void setEditDetailRecord() {
        this.recordToEdit = null;
        String objectName;
        
        Set < Object > detailFields = new Set < Object >();
        final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration > ();      
        
        /*if(FAP_Configuration.keyValue =='Account__r.'){ 
           
            combined.addAll(FAP_Configuration.getInstance().detailScreenCompanyBasicFields);
            combined.addAll(FAP_Configuration.getInstance().detailScreenCompanyExtendedFields);
            combined.addAll(FAP_Configuration.getInstance().detailScreenEditFields);    
            combined.addAll(FAP_Configuration.getInstance().detailAccountFields); 
            system.debug('combined----------------'+combined);
            if (combined != null && combined.size() > 0) {
                for (FAP_FieldConfiguration field: combined) {
                    detailFields.add(field.fieldName);
                    system.debug('DetailFields--------inside if--------'+detailFields);
                }
            } 
            system.debug('DetailFields----------------'+detailFields);
        } 
        else if(FAP_Configuration.keyValue =='Partner_Track__r.'){*/
            combined.addAll(FAP_Configuration.getInstance().detailScreenPartnerTrackBasicFields);
            combined.addAll(FAP_Configuration.getInstance().detailScreenPartnerTrackExtendedFields);
            combined.addAll(FAP_Configuration.getInstance().detailPartnerTrackScreenEditFields);
            combined.addAll(FAP_Configuration.getInstance().detailPartnerTrackFieldsload);  
            combined.addAll(FAP_Configuration.getInstance().listDetailPartnerTrackFederalFields); //5.0
                if (combined != null && combined.size() > 0) {
                for (FAP_FieldConfiguration field: combined) {
                    detailFields.add(field.fieldName);
                }
            }            
        //}
        try {
            system.debug('##### currentKeyRecordToView.id -->'+this.currentKeyRecordToView.id);
            this.recordToEdit = Database.query(
                new FAP_SoqlBuilder()
                .selectx(detailFields) 
                .fromx(keyValueWithoutDot)
                .wherex(new FAP_FieldCondition('id', this.currentKeyRecordToView.id))
                .toSoql());
        }
         catch (Exception exp) {
            FAP_PageUtils.addError(Label.failed_to_load_record + exp.getMessage());
        }
    }

    public void primaryCstr() {
        try {
            string imaryCustVal;
            string geoGraphyVal;  
            if (partnerDetailFieldsOverview != null && partnerDetailFieldsOverview.size() > 0) {
                for (FAP_FormField ptObj: partnerDetailFieldsOverview) {
                    if (ptObj.fieldName == 'Partner_Primary_Customer__c') {
                        imaryCustVal = string.valueOf(ptObj.typedValueLabel);
                    }
                    if (ptObj.label == 'Geographic Coverage' || ptObj.fieldName == 'Capability__c') {
                        geoGraphyVal = string.valueOf(ptObj.typedValueLabel);
                    }
                }
            }

            /**added below conditions to display primary customer, geography with translations, in customer facing view hard code value checking will help to diplay the translated value.
                In profile form custom label will help to display the translated values, reason for this is, profile form labels and field values are coming with translations
            */
            if (imaryCustVal != null) {
                if (imaryCustVal.contains(Label.Primary_Customer_Consumer) || imaryCustVal.contains('Consumer (home)')) {
                    accPrimaryCustrVal = Label.Primary_Customer_Consumer;
                } else if (imaryCustVal.contains(Label.Primary_Customer_Corporate) || imaryCustVal.contains('Corporate (+500 employees)')) {
                    accPrimaryCustrVal = Label.Primary_Customer_Corporate;
                } else if (imaryCustVal.contains(Label.Primary_Customer_Education) || imaryCustVal.contains('Education')) {
                    accPrimaryCustrVal = Label.Primary_Customer_Education;
                } else if (imaryCustVal.contains(Label.Primary_Customer_Federal_Government) || imaryCustVal.contains('Federal Government')) {
                    accPrimaryCustrVal = Label.Primary_Customer_Federal_Government;
                } else if (imaryCustVal.contains(Label.Primary_Customer_Midsize) || imaryCustVal.contains('Midsize Companies (100-499)')) {
                    accPrimaryCustrVal = Label.Primary_Customer_Midsize;
                } else if (imaryCustVal.contains(Label.Primary_Customer_Small_Govt_Ent) || imaryCustVal.contains('Small Government Entities')) {
                    accPrimaryCustrVal = Label.Primary_Customer_Small_Govt_Ent;
                } else if (imaryCustVal.contains(Label.Primary_Customer_SMB) || imaryCustVal.contains('Small Medium Business (1-99 employees)')) {
                    accPrimaryCustrVal = Label.Primary_Customer_SMB;
                } else if (imaryCustVal.contains(Label.Primary_Customer_State_Government) || imaryCustVal.contains('State Government')) {
                    accPrimaryCustrVal = Label.Primary_Customer_State_Government;
                }
            }
            if (geoGraphyVal != null) {
                if (geoGraphyVal.contains(Label.Geographic_Coverage_Global) || geoGraphyVal.contains('Global')) {
                    accGeograPhy = Label.Geographic_Coverage_Global;
                } else if (geoGraphyVal.contains(Label.Geographic_Coverage_Local) || geoGraphyVal.contains('Local')) {
                    accGeograPhy = Label.Geographic_Coverage_Local;
                } else if (geoGraphyVal.contains(Label.Geographic_Coverage_National) || geoGraphyVal.contains('National')) {
                    accGeograPhy = Label.Geographic_Coverage_National;
                } else if (geoGraphyVal.contains(Label.Geographic_Coverage_Regional) || geoGraphyVal.contains('Regional')) {
                    accGeograPhy = Label.Geographic_Coverage_Regional;
                }
            }

        } catch (QueryException e) {
            system.debug('Primary Customer' + e);
        }
    }
    public String getPatnerLvl() {

        config = FAP_Configuration.getInstance();
        accDistributor = config.distributorPartnerType;
        List < String > distributorList = accDistributor.split('\\|');
        try {

            if (partnerDetailFieldsBasic != null && partnerDetailFieldsBasic.size() > 0) {
                for (FAP_FormField ptLvl: partnerDetailFieldsBasic) {
                    if (ptLvl.fieldName == (FAP_Configuration.keyValue == 'Account__r.'? 'Partner_Relationship__c':'Partner_Program_Tier__c') ) {
                        accPatnrRelationship = string.valueOf(ptLvl.typedValueLabel);
                    }
                    if (ptLvl.fieldName == 'Partner_Type__c') {
                        accPatnrType = string.valueOf(ptLvl.typedValueLabel);
                    }
                }
            }
            if (distributorList.size() > 0) {
                for (String dist: distributorList) {
                    if (accPatnrType == dist) {
                        partnerLvlDistri = Label.Authorized_Distributor_Partner_Level;
                    }
                }
            }

            if (accPatnrRelationship == 'Premier') {
                partnerLvl = Label.Premier_Partner_Level;
            } else if (accPatnrRelationship == 'Preferred') {
                partnerLvl = Label.Preferred_Partner_Level;
            } else if (accPatnrRelationship == 'Registered') {
                partnerLvl = Label.Registered_Partner_Level;
            }            
            if (partnerLvlDistri != null) {
                partnerLvl = partnerLvlDistri;
            }

        } catch (QueryException e) {
            system.debug('Partner lvl excep' + e);
        }
        return partnerLvl;
    }

    //v2.1 Start
    public Social_Media__c getSocialMediaFields() {
        final Set < Object > socialMediaFields = new Set < Object >();
        final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration > ();
        combined.addAll(FAP_Configuration.getInstance().detailScreenSMExtendedFields);
         System.debug('combined-----');
        if (combined != null && combined.size() > 0) {
            for (FAP_FieldConfiguration field: combined) {
                socialMediaFields.add(field.fieldName);
            }
        }                   
        try {                     
            this.SocialMediaFields = Database.query(
                new FAP_SoqlBuilder()
                .selectx(socialMediaFields)
                .fromx('Social_Media__c')
                .wherex(new FAP_FieldCondition(FAP_Configuration.keyValue+'Id', this.currentKeyRecordToView.id))
                .limitx(1)
                .toSoql()
            );
       } catch (QueryException e) {
            if (e.getMessage() == 'List has no rows for assignment to SObject') {
                this.SocialMediaFields = new Social_Media__c();
                //this.SocialMediaFields.Account__c = this.currentKeyRecordToView.id;
                this.SocialMediaFields.Partner_Track__c = this.currentKeyRecordToView.id;
             
            } else {
                FAP_PageUtils.addError(Label.failed_to_load_record + e.getMessage());
            }
        }

        return this.SocialMediaFields;
    }

    public Social_Media__c getservices() {
        try {
            this.services = Database.query(
                new FAP_SoqlBuilder()
                .selectx(new Set < Object > {
                    'Id',
                    'services__c',
                    'Account__c'
                })
                .fromx('Social_Media__c')
                .wherex(new FAP_ORCondition().add(new FAP_FieldCondition(FAP_Configuration.keyValue+'Id', this.currentKeyRecordToView.id))
                .add(new FAP_FieldCondition('id', socialMediaFields.id)))
                .limitx(1)
                .toSoql()
            );
        } catch (QueryException e) {
            if (e.getMessage() == 'List has no rows for assignment to SObject') {
                this.services = new Social_Media__c();
                //this.services.Account__c = this.currentKeyRecordToView.id;
                this.services.Partner_Track__c = this.currentKeyRecordToView.id;
                
            } else {
                FAP_PageUtils.addError(Label.failed_to_load_record + e.getMessage());
            }
        }

        return this.services;
    }

    public List < Social_Media__c > getservicesDetails() {
        String accField= FAP_Configuration.keyValue +'id';
        String sQuery = 'select Id, name, Account__c, services__c from Social_Media__c where ' + accField +' = \''+this.currentKeyRecordToView.id+  '\'';
          sQuery = sQuery +' ORDER By Name desc'; 
        this.servicesDetails  = Database.query(sQuery);
        
        return this.servicesDetails;
    }

    public List < Partner_Showcase__c > getShowCaseDetails() {
        String accField= FAP_Configuration.keyValue +'id';
        String sQuery = 'select Id, Name, Account__c, Short_Description__c, Long_Description__c, ShowCase_Title__c, ShowCase_Title_Url__c from Partner_Showcase__c where ' + accField +' = \''+this.currentKeyRecordToView.id+  '\'';
        sQuery = sQuery +' ORDER By Name desc'; 
        system.debug('******* sQuery *****'+ sQuery );
        this.showCaseDetails  = Database.query(sQuery);        

        return this.showCaseDetails;
    }
    //End v2.0
  
    public Partner_Location__c getPartnerContactLocation() {
        final Set < Object > fieldsLocation = new Set < Object >();           
        final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration > ();
        combined.addAll(FAP_Configuration.getInstance().searchMinFieldsforPartnerLoc);
        if (combined != null && combined.size() > 0) {
            for (FAP_FieldConfiguration field: combined) {
                fieldsLocation.add(field.fieldName);
            }
        }     
        if (this.partnerContactLocation == null) {
            try {
                this.partnerContactLocation = Database.query(
                    new FAP_SoqlBuilder()
                    .selectx(fieldsLocation)
                    .fromx('Partner_Location__c')
                    .wherex(new FAP_FieldCondition(selectedLocationId == this.recordId ? 'Id' : FAP_Configuration.keyValue+'Id').equals(this.recordId))          
                    .orderByx(new FAP_OrderBy('Is_Primary__c').descending())
                    .orderByx(new FAP_OrderBy('LastModifiedDate').descending()) //added by ashish for userstory 192360         
                    .limitx(1)
                    .toSoql()
                );

            } catch (QueryException e) {}
        }
        return this.partnerContactLocation;
    }

    //==================================================
    // HELPER METHODS
    //==================================================
    private void initialize() {
        this.partnerRecord = null;
        this.locations = new List < FAP_Location > ();
        this.accountForID = null;
        this.showEmail = false;
        this.showEditDetail = false;
        this.partnerRecordupdate=null;
        if (this.activeTab == 'Details') {
            this.activeTab = 'Details';
            returnPage = null;
        }
        //To Hide showcase tab in customer view if no showcase records are present for that account & To make active tab as current working tab on returning from any Edit page
        else if (returnPage == 'Services') {
            this.activeTab = 'Services';
        } else if (returnPage == 'Showcase') {
            this.activeTab = 'Showcase';
        } else if (returnPage == 'Locations') { // To handle return tab for Locations
            this.activeTab = 'Locations';
        } 
        else {
            this.activeTab = 'Details';
        }

        this.isCurrentUserAdmin = false;
        this.errorCode = '';
        this.showCaseFields = new List < FAP_ShowcaseClass > ();
        this.googleMapsApiKey = FAP_StringUtils.isEmpty(Site.getName()) ? FAP_Configuration.getInstance().googleMapsApiKey : FAP_Configuration.getInstance().googleMapsApiKeyForSites;

    }

    private Boolean sendEmail(String toEmail, String fromEmail,
        String senderDisplayName, String subject,
        String content) {
        // Create a new single email message object that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {
            toEmail
        };
        String[] ccAddresses = new String[] {};
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);

        // Specify the address used when the recipients reply to the email.
        mail.setReplyTo(toEmail);

        // Specify the name used as the display name.
        mail.setSenderDisplayName(senderDisplayName);

        // Specify the subject line for your email address.
        mail.setSubject(subject);

        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);

        // Specify the text content of the email.
        mail.setPlainTextBody(content);

        //mail.setHtmlBody('Your case:<b> ' + case.Id +' </b>has been created<p>'+
        //    ' View case <a href=https://na1.salesforce.com/'+case.Id+'>click here</a>');

        // Send the email you have created.
        List < Messaging.Sendemailresult > emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
        if (emailResults.size() > 0) {
            Messaging.Sendemailresult emailResult = emailResults[0];
            if (emailResult.isSuccess()) {
                this.additionalMessages.add('Your message sent successfully!');
                return true;
            }
        }
        return false;
    }
    
    private List < FAP_FormField > getCustomLocationFields(List < FAP_FormField > initialFieldList) {
        List < FAP_FormField > filteredFieldList = new List < FAP_FormField > ();
        for (FAP_FormField locDetail: initialFieldList) {
            if (!locDetail.name.equalsIgnoreCase('Id') &&
                !locDetail.name.equalsIgnoreCase('Name') &&
                !locDetail.name.equalsIgnoreCase('Latitude__c') &&
                !locDetail.name.equalsIgnoreCase('Longitude__c') &&
                !locDetail.name.equalsIgnoreCase('Street__c') &&
                !locDetail.name.equalsIgnoreCase('City__c') &&
                !locDetail.name.equalsIgnoreCase('State_Province__c') &&
                !locDetail.name.equalsIgnoreCase('Postal_Code__c') &&
                !locDetail.name.equalsIgnoreCase('Country__c')
            ) {
                filteredFieldList.add(locDetail);
            }
        }
        return filteredFieldList;
    }

    global void handlePageChange(List < SObject > newPage) {
        this.locations.clear();
        this.locationsInJson = null;
        system.debug('newPage--------------------'+newPage);
        if (this.locationPaginator == null || newPage == null) {
            return;
        }
        List < String > locationsInJsonList = new List < String > ();
        FAP_Location aLocation = null;
        for (Integer i = 0; i < newPage.size(); i++) {
            aLocation = FAP_Location.build((Partner_Location__c) newPage.get(i));
            aLocation.detailFields = this.getCustomLocationFields(FAP_FormField.populateFields(FAP_FormField.build(FAP_Configuration.getInstance().detailScreenLocationFields), newPage.get(i)));
            aLocation.serialNumber = i + this.locationPaginator.pageStartPositionDisplayFriendly;
            locationsInJsonList.add(aLocation.toJSON());
            this.locations.add(aLocation);

        }
        system.debug('locationsInJsonList--------------------'+locationsInJsonList);
        this.locationsInJson = '{ "locations" : [' + FAP_StringUtils.joinArray(locationsInJsonList, ',') + ']}';
    }

    private List < FAP_FormField > getShowcaseFields(List < FAP_FormField > initialFieldList) {
        List < FAP_FormField > filteredFieldList1 = new List < FAP_FormField > ();
        for (FAP_FormField showCaseDetail: initialFieldList) {
            if (!showCaseDetail.name.equalsIgnoreCase('Id') &&
                !showCaseDetail.name.equalsIgnoreCase('Name') &&
                !showCaseDetail.name.equalsIgnoreCase('CaseStudy_Image_Url__c') &&
                !showCaseDetail.name.equalsIgnoreCase('Video_Url__c') &&
                !showCaseDetail.name.equalsIgnoreCase('ShowCase_Title__c') &&
                !showCaseDetail.name.equalsIgnoreCase('ShowCase_Title_Url__c') &&
                !showCaseDetail.name.equalsIgnoreCase('ShowCase_Type__c') &&
                !showCaseDetail.name.equalsIgnoreCase('Short_Description__c') &&
                !showCaseDetail.name.equalsIgnoreCase('Long_Description__c')
            ) {
                filteredFieldList1.add(showCaseDetail);
            }
        }
        return filteredFieldList1;
    }
    
    global void handlePageChangeForShowCase(List < SObject > newPage) {
        this.showCaseFields.clear();
        this.ShowcasesInJson = null;
        if (this.locationPaginator == null || newPage == null) {
            return;
        }
        List < String > showcasesInJsonList = new List < String > ();
        FAP_ShowcaseClass aShowcase = null;
        for (Integer i = 0; i < newPage.size(); i++) {
            aShowcase = FAP_ShowcaseClass.build((Partner_Showcase__c) newPage.get(i));
            aShowcase.detailFields = this.getShowcaseFields(FAP_FormField.populateFields(FAP_FormField.build(FAP_Configuration.getInstance().detailScreenShowcaseFields), newPage.get(i)));
            showcasesInJsonList.add(aShowcase.toJSON());
            this.showCaseFields.add(aShowcase);

        }
        this.ShowcasesInJson = '{ "showCaseFields" : [' + FAP_StringUtils.joinArray(showcasesInJsonList, ',') + ']}';
    }

    private String getAccountQuery(String accountId) {
        
        final Set < Object > fieldsLocation = new Set < Object >();
        final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration > ();
        combined.addAll(FAP_Configuration.getInstance().searchMinFieldsforPartnerLoc);
        if (combined != null && combined.size() > 0) {
            for (FAP_FieldConfiguration field: combined) {
                fieldsLocation.add(field.fieldName);
            }
        }            
                       
        if (FAP_Configuration.getInstance().detailScreenLocationFields != null && FAP_Configuration.getInstance().detailScreenLocationFields.size() > 0) {
            for (FAP_FieldConfiguration field: FAP_Configuration.getInstance().detailScreenLocationFields) {
                fieldsLocation.add(field.fieldName);
            }
        }

        List < FAP_OrderBy > orderListLocations = new List < FAP_OrderBy > {
            new FAP_OrderBy('Is_Primary__c').descending(),
            new FAP_OrderBy('Country__c').ascending(),
            new FAP_OrderBy('City__c').ascending()
        };
        return new FAP_SoqlBuilder()
            .selectx(getAccountFields())
            .selectx(
                new FAP_SoqlBuilder()
                .selectx(fieldsLocation)
                .selectx(getPartnerTrackFields())
                .fromx('Partner_Locations__r')
                .orderByx(orderListLocations)
            )
            .selectx(
                new FAP_SoqlBuilder()
                .selectx(getPartnerTrackRecords())
                .fromx('Partner_Track__r')
            )
            .fromx('Account')
            .wherex(new FAP_FieldCondition('id', accountId))
            .toSoql();
    }

    private Set < Object > getAccountFields() {

        final Set < Object > returnValue = new Set < Object >();
        final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration > ();
        combined.addAll(FAP_Configuration.getInstance().detailScreenCompanyBasicFields);
        combined.addAll(FAP_Configuration.getInstance().detailScreenCompanyExtendedFields);
        combined.addAll(FAP_Configuration.getInstance().detailScreenEditFields);
    
        combined.addAll(FAP_Configuration.getInstance().detailAccountFields);
        if (combined != null && combined.size() > 0) {
            for (FAP_FieldConfiguration field: combined) {
                returnValue.add(field.fieldName);
            }
        }
        return returnValue;
     }
   
    
    private Account loadAccount(String accountId) {
        if (accountId == null) {
            return null;
        }
        String accountQuery = getAccountQuery(accountId);
        List < Account > accounts = Database.query(accountQuery);
        if (accounts != null || accounts.size() > 0) {
            return accounts.get(0);
        }
        return null;
    }

    public Boolean showEmail {
        get {
            if (showEmail == null) {
                showEmail = true;
            }
            return showEmail;
        }
        set;
    }


    public Boolean showEditDetail {
        get {
            if (showEditDetail == null){
                showEditDetail = false;
            }
            return showEditDetail;
        }
        set;
    }

    // dynamic method to get picklist values
    
    public static List < String > getPicklistValues(String objectApiname, String field_name) {
        List < String > lstPickvals = new List < String > ();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiname); //From the Object Api name retrieving the sobject
        Sobject objectname = targetType.newSObject();
        Schema.sObjectType sobjecttype = objectname.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobjectdescribe = sobjecttype.getDescribe(); //describe the sobject
        Map < String, Schema.SObjectField > fieldmap = sobjectdescribe.fields.getMap(); //get a map of fields for the passed sobject

        if (fieldmap.get(field_name) != null) {
            List < Schema.PicklistEntry > picklistvalues = fieldmap.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a: picklistvalues) { //for all values in the picklist list
                lstPickvals.add(a.getValue()); //add the value  to our final list
            }
        }       
        return lstPickvals;
    }


    private Set < Object > getPartnerTrackFields() {
      final Set < Object > returnValue = new Set < Object >();
      final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration> ();               
     
      for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().detailPartnerTrackFields){ 
        if(fieldConfiguration != null){
                 returnValue.add(('Partner_Track__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? 'Partner_Track__r.' : '') 
                                        + fieldConfiguration.fieldName);
            }
        }               
       //5.0        
      for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().listDetailPartnerTrackFederalFields){ 
        if(fieldConfiguration != null){
                 returnValue.add(('Partner_Track__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? 'Partner_Track__r.' : '') 
                                        + fieldConfiguration.fieldName);
            }
        }
      return returnValue;
      }
         
    
    private static Partner_Track__c getPartnerTrackFromAccountID(String accountId) {        
        Partner_Track__c pTrackObj = new Partner_Track__c();
        try{
          
            if(accountId != null){
                 pTrackObj = [Select id from Partner_Track__c where Primary_SMAffinity_Account__c =: accountId  Limit 1];              
            }

        } catch(Exception e) {}    
      return pTrackObj;    
    }

 
    
    private Set < Object > getPartnerTrackRecords() {
        final Set < Object > returnValue = new Set < Object >();
        final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration> ();               
        for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().detailPartnerTrackFields){ 
            if(fieldConfiguration != null){
                returnValue.add(('Partner_Track__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? '' : '') 
                                        + fieldConfiguration.fieldName);
            }
        }      
        //5.0
        for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().listDetailPartnerTrackFederalFields){ 
            if(fieldConfiguration != null){
                returnValue.add(('Partner_Track__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? '' : '') 
                                        + fieldConfiguration.fieldName);
            }
        } 
        return returnValue;
    }   
                    
 
    
    public Service_Information__c getServiceInfo(String partnerTrackId) {
        try {
            this.serviceInfo = Database.query(
                new FAP_SoqlBuilder()
                .selectx(new Set < Object > {
                        'id',
                        'Advanced_Performing_Deploy__c',
                        'Advanced_Performing_Support__c'
                        })
                .fromx('Service_Information__c')
                .wherex(new FAP_FieldCondition('Partner_Track__c',partnerTrackId))
                .toSoql()
            );
            
        } catch (QueryException e) {}
        return this.serviceInfo;
    } 
    
    //Service Offering Data - PAM Changes
    public List<Service_Offering__c> getServiceOfferingData() {
        try {
            this.serviceOfferingFields = Database.query(
                new FAP_SoqlBuilder()
                .selectx(new Set < Object > {
                        'id',
                        'Service_Offering__c',
                        'CSP_Product__c',
                        'CSP_Country__c'
                        })
                .fromx('Service_Offering__c')
                .wherex(new FAP_FieldCondition(FAP_Configuration.keyValue+'Id', this.currentKeyRecordToView.id))
                .orderByx(new FAP_OrderBy('CSP_Country__c').ascending())
                .toSoql()
            );
			
			//Version 1.0 start
			
			mapServiceTechToCountries = new  map<String,String>();
			mapServiceTechToServiceOffering = new map<String, Service_Offering__c>();
            
			for(Service_Offering__c objServiceOffering : this.serviceOfferingFields){
			    
			    if(objServiceOffering.Service_Offering__c != null || objServiceOffering.CSP_Product__c != null){
                
                    String strComb = objServiceOffering.Service_Offering__c+';'+objServiceOffering.CSP_Product__c;
                    
    				if(mapServiceTechToCountries.containsKey(strComb)){
    					
                        String strCountry = mapServiceTechToCountries.get(strComb) == 'none'? '':mapServiceTechToCountries.get(strComb);
                        if(objServiceOffering.CSP_Country__c != null && !strCountry.containsIgnoreCase(objServiceOffering.CSP_Country__c)){
    						strCountry = (strCountry == '')? objServiceOffering.CSP_Country__c : (strCountry+',  '+objServiceOffering.CSP_Country__c);
                            mapServiceTechToCountries.put(strComb, strCountry);
    					}
    				}
    				else{
    					
                        if(objServiceOffering.CSP_Country__c != null){
                        	mapServiceTechToCountries.put(strComb, objServiceOffering.CSP_Country__c);
                        }
                        else{
                            mapServiceTechToCountries.put(strComb, 'none');
                        }
                        
    					mapServiceTechToServiceOffering.put(strComb, objServiceOffering);
    				}
			    }
			}
			//Version 1.0 end
            
        } catch (QueryException e) {}
        
        return this.serviceOfferingFields;
        
    }
    
    
    private Partner_Location__c getPartnerLocationFromLocationID(String LocationID) {
    Partner_Location__c pObj = new Partner_Location__c();
        if (LocationID == null) {
            return null;
        }
        set <Object> partnerTrackFields = new Set <Object> ();
        set <Object> accFields = new Set <Object> ();
        List<Partner_Location__c> locationList = new List<Partner_Location__c> ();
        for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().detailPartnerTrackFields){  
            if(fieldConfiguration != null){
                partnerTrackFields.add(('Partner_Track__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? 'Partner_Track__r.' : 'Partner_Track__r.') 
                            + fieldConfiguration.fieldName);
            }
        }
        //5.0 start
        for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().listDetailPartnerTrackFederalFields){  
            if(fieldConfiguration != null){
                partnerTrackFields.add(('Partner_Track__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? 'Partner_Track__r.' : 'Partner_Track__r.') 
                            + fieldConfiguration.fieldName);
            }
        }//5.0 end
        for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().detailAccountFields){  
            if(fieldConfiguration != null){
                accFields.add(('Partner_Location__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? 'Account__r.' : 'Account__r.') 
                            + fieldConfiguration.fieldName);
            }
        }           
                                                            
        final String soql = 
            new FAP_SoqlBuilder()
                .selectx(accFields)
                .selectx(partnerTrackFields)
                .fromx('Partner_Location__c')
                .wherex(new FAP_FieldCondition('id',LocationID))
                .toSoql();
        System.debug('##### soql ' + soql);   
        locationList =  Database.query(soql); 
        pObj =  locationList [0]; 
        return pObj;
    }
    private Partner_Track__c loadPartnerTrack(String partnerTrackId) {
        if (partnerTrackId == null) {
            return null;
        }
        String partnerTrackQuery = getPartnerTrackQuery(partnerTrackId);
        List < Partner_Track__c > partnerTracks = Database.query(partnerTrackQuery);
        if (partnerTracks != null || partnerTracks.size() > 0) {
            return partnerTracks.get(0);
        }
        return null;
    }
        
    private String getPartnerTrackQuery(String partnerTrackId) {
        
        final Set < Object > fieldsLocation = new Set < Object >();
        final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration > ();
        combined.addAll(FAP_Configuration.getInstance().searchMinFieldsforPartnerLoc);
        if (combined != null && combined.size() > 0) {
            for (FAP_FieldConfiguration field: combined) {
                fieldsLocation.add(field.fieldName);
            }
        }            
                       
        if (FAP_Configuration.getInstance().detailScreenLocationFields != null && FAP_Configuration.getInstance().detailScreenLocationFields.size() > 0) {
            for (FAP_FieldConfiguration field: FAP_Configuration.getInstance().detailScreenLocationFields) {
                fieldsLocation.add(field.fieldName);
            }
        }

        List < FAP_OrderBy > orderListLocations = new List < FAP_OrderBy > {
            new FAP_OrderBy('Is_Primary__c').descending(),
            new FAP_OrderBy('Country__c').ascending(),
            new FAP_OrderBy('City__c').ascending()
        };
        return new FAP_SoqlBuilder()
            .selectx(getloadPartnerTrackFields())
            .selectx(
                new FAP_SoqlBuilder()
                .selectx(fieldsLocation)
                .fromx('Partner_Locations_1__r')
                .orderByx(orderListLocations)
            )
            .fromx('Partner_Track__c')
            .wherex(new FAP_FieldCondition('id', partnerTrackId))
            .toSoql();
    }
    
     private Set < Object > getloadPartnerTrackFields() {
      final Set < Object > returnValue = new Set < Object >();
      final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration> ();               
        for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().detailPartnerTrackFields){ 
            if(fieldConfiguration != null){
                returnValue.add(('Partner_Track__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? '' : '') 
                                        + fieldConfiguration.fieldName);
            }
        }  
        //5.0
        for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().listDetailPartnerTrackFederalFields){ 
            if(fieldConfiguration != null){
                returnValue.add(('Partner_Track__c'.equalsIgnoreCase(fieldConfiguration.objectName) ? '' : '') 
                                        + fieldConfiguration.fieldName);
            }
        }  
       return returnValue;
    }
        
    public sObject getCompanydes(){
        try{
            this.Companydes = Database.query(
                new FAP_SoqlBuilder()
                .selectx(new Set<Object>{
                    'id','Partner_Self_Description_Long__c'})
                .fromx(keyValueWithoutDot)                       
                .wherex(new FAP_FieldCondition('id',this.currentKeyRecordToView.id))                              
                .limitx(1)
                .toSoql()
            );                    
            
        }catch(QueryException e){}
        
        return this.Companydes;
        
    }  
    
              
}
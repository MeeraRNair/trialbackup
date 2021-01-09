global class FAP_Configuration {

    //==================================================
    // CONSTANTS
    //==================================================
    global static final String KEY_SEARCH_SCREEN_BASIC_SEARCH_FIELDS       = 'FIELDS_BASIC_SEARCH';
    global static final String KEY_SEARCH_SCREEN_ADVANCED_SEARCH_FIELDS    = 'FIELDS_ADVANCED_SEARCH';
    global static final String KEY_SEARCH_SCREEN_FIELDS_IN_RESULT_LIST     = 'FIELDS_IN_RESULTS_LIST';
    global static final String KEY_SEARCH_SCREEN_SORTABLE_FIELDS           = 'FIELDS_SORTING';
    global static final String KEY_DETAIL_SCREEN_COMPANY_BASIC_FIELDS      = 'FIELDS_DETAIL_BASIC';
    global static final String KEY_DETAIL_SCREEN_COMPANY_BASIC_FIELDS_PT      = 'FIELDS_DETAIL_BASIC_PARTNER';
    global static final String KEY_DETAIL_SCREEN_COMPANY_EXTENDED_FIELDS   = 'FIELDS_DETAIL_OVERVIEW';
    global static final String KEY_DETAIL_SCREEN_COMPANY_EXTENDED_FIELDS_PT   = 'FIELDS_DETAIL_OVERVIEW_PARTNER';
    //test start
    global static final String KEY_DETAIL_SCREEN_SM_EXTENDED_FIELDS        = 'FIELDS_SOCIALMEDIA_EDIT'; //v3.1 Added
    global static final String KEY_DETAIL_SCREEN_SERVICES_EDIT_FIELD           = 'FIELD_SERVICES_EDIT'; // Naga added for user story - 197189 (16.12)
    global static final String KEY_DETAIL_SCREEN_SHOWCASE_EDIT_FIELDS           = 'FIELDS_SHOWCASE_EDIT';
    global Static final String KEY_DETAILS_WEBSITE_EDIT_FIELD              = 'FIELD_WEBSITE_EDIT';
    global Static final String KEY_DETAILS_COMP_DESC_EDIT_FIELD            = 'FIELD_COMP_DESC_EDIT';
    //test end
    global static final String KEY_DETAIL_SCREEN_LOCATION_FIELDS           = 'FIELDS_DETAIL_LOCATION';
    global static final String KEY_DETAIL_SCREEN_EDIT_FIELDS               = 'FIELDS_DETAIL_EDIT';
    global static final String KEY_DETAIL_SCREEN_EDIT_FIELDS_PT            = 'FIELDS_DETAIL_EDIT_PARTNER_TRACK'; //JJ
    //v2.0
    //global static final String KEY_DETAIL_SCREEN_EDIT_FIELDS_FED            = 'FIELDS_DETAIL_EDIT_PARTNER_TRACK_FED'; //JJ

    global static final String KEY_DETAIL_SCREEN_TC                       = 'FIELDS_DETAIL_EDIT_T&C';
    global static final String KEY_DETAIL_SCREEN_EDIT_CON_FIELDS           = 'FIELDS_DETAIL_EDIT_CONTACT';
    global static final String KEY_GOOGLE_MAPS_API_KEY                     = 'GOOGLE_MAPS_API_KEY';
    global static final String KEY_GOOGLE_MAPS_API_KEY_SITES               = 'GOOGLE_MAPS_API_KEY_SITES';
    global static final String KEY_GOOGLE_MAPS_API_URL                     = 'GOOGLE_MAPS_API_URL';
    global static final String KEY_TERMS_AND_CONDITIONS_URL                = 'TERMS_AND_CONDITIONS_URL';
    global static final String KEY_IMAGE_URL_RECOMMENDED_PARTNER           = 'IMAGE_URL_RECOMMENDED_PARTNER';
    global static final String KEY_SEARCH_HELP_URL                         = 'SEARCH_HELP_URL';
    global static final String KEY_SEARCH_DISTANCE_DEFAULT                 = 'SEARCH_DISTANCE_DEFAULT';
    global static final String KEY_SEARCH_DISTANCE_OPTIONS                 = 'SEARCH_DISTANCE_OPTIONS';
    global static final String KEY_SEARCH_MAX_RESULTS                      = 'SEARCH_MAX_RESULTS';
    global static final String KEY_AUTO_COMPLETION_ENABLED                 = 'AUTO_COMPLETION_ENABLED';
    global static final String KEY_KEYWORD_AUTO_COMPLETION_ENABLED         = 'KEYWORD_AUTO_COMPLETION_ENABLED';
    global static final String KEY_LOCATION_AUTO_COMPLETION_ENABLED        = 'LOCATION_AUTO_COMPLETION_ENABLED';
    global static final String KEY_PRIORITIZED_COUNTRY_LIST                = 'PRIORITIZED_COUNTRY_LIST';
    // Ver 1.0: Added KEY_PARTNERDIRECT_LOGO_URLS
    global static final String KEY_PARTNERDIRECT_LOGO_URLS                 = 'PARTNERDIRECT_LOGO_URLS'; 
    // Ver 2.1: Default Region
    global static final String KEY_DEFAULT_REGION                          = 'DEFAULT_REGION'; 
    global static final String KEY_DEFAULT_LANGUAGE                        = 'DEFAULT_LANGUAGE'; 
    global static final String KEY_DISTRIBUTOR_PARTNER_TYPE                = 'DISTRIBUTOR_PARTNER_TYPE';
    global static final String KEY_SCRIPT_STATEMENT_LIMIT                  = 'SCRIPT_STATEMENT_LIMIT'; // Ver 2.3: added
    //Start v2.4
    global static final String KEY_DETAIL_SCREEN_SHOWCASE_BASIC_FIELDS       = 'FIELDS_SHOWCASE_OVERVIEW';
    //End
    
    //v4.0 - start
    global static final String KEY_FIELDS_CONTACT_US = 'FIELDS_CONTACT_US';
    //v4.0 - end
    
    //5.0 GAN POC
    global static final String KEY_BAIDU_MAPS_API_URL                     = 'BAIDU_MAPS_API_URL';
    
    //6.o - start
    global static final String KEY_CSP_7_SEARCH_FIELDS = 'CSP_7_SEARCH_FIELDS';
    //6.0 - end

    // Added by Vismy
    global static final String KEY_OBJECT = 'KEY_OBJECT';
    global static final String KEY_FIELDS_PARTNER_TRACK_RESULT = 'FIELDS_PARTNER_TRACK_RESULT';
    global static final String KEY_FIELDS_MASTER_GROUP_RESULT = 'FIELDS_MASTER_GROUP_RESULT';
    global static final String KEY_ACCOUNT_DETAIL_FIELDS ='ACCOUNT_DETAIL_FIELDS';
    global static final String KEY_PARTNER_TRACK_DETAIL_FIELDS='A_PARTNER_TRACK_DETAIL_FIELDS';
    
    global static final String STR_KEY_FIELDS_FEDERAL_DETAIL_VIEW='FIELDS_FEDERAL_DETAIL_VIEW'; //Added by Akshita
    
    global static final String KEY_DETAIL_SCREEN_PARTNER_TRACK_FIELDS_EDIT      = 'FIELDS_DETAIL_BASIC_EDIT';
    
    
    //Added by Neeti & Shravan on 26-12-2018 Start
    
    global static final string KEY_FIELD_MIN_PARTNERLOCATION = 'FIELD_MIN_PARTNERLOCATION';
    global static final string KEY_FIELD_MIN_ACCOUNT = 'FIELD_MIN_ACCOUNT';

    global static final string KEY_VIEW_DETAIL_FIELDS = 'VIEW_DETAIL_FIELDS';
    
        
    //End Neeti & Shravan end
    
    
    private static final String[] ALL_CONFIG_KEY = new String[]{
         KEY_GOOGLE_MAPS_API_KEY
        ,KEY_GOOGLE_MAPS_API_KEY_SITES
        ,KEY_GOOGLE_MAPS_API_URL
        ,KEY_SEARCH_SCREEN_ADVANCED_SEARCH_FIELDS
        ,KEY_SEARCH_SCREEN_BASIC_SEARCH_FIELDS
        ,KEY_SEARCH_SCREEN_FIELDS_IN_RESULT_LIST
        ,KEY_DETAIL_SCREEN_COMPANY_BASIC_FIELDS
        ,KEY_DETAIL_SCREEN_COMPANY_BASIC_FIELDS_PT
        ,KEY_DETAIL_SCREEN_COMPANY_EXTENDED_FIELDS
        ,KEY_DETAIL_SCREEN_COMPANY_EXTENDED_FIELDS_PT
        //test start
        ,KEY_DETAIL_SCREEN_SM_EXTENDED_FIELDS //v3.1 Added
        ,KEY_DETAIL_SCREEN_SERVICES_EDIT_FIELD // Naga added for user story- 197189
        ,KEY_DETAIL_SCREEN_SHOWCASE_EDIT_FIELDS
        ,KEY_DETAILS_WEBSITE_EDIT_FIELD
        ,KEY_DETAILS_COMP_DESC_EDIT_FIELD
        //test end
        ,KEY_DETAIL_SCREEN_LOCATION_FIELDS
        ,KEY_DETAIL_SCREEN_EDIT_FIELDS
        ,KEY_DETAIL_SCREEN_EDIT_FIELDS_PT
        //,KEY_DETAIL_SCREEN_EDIT_FIELDS_FED//v2.0
        ,KEY_DETAIL_SCREEN_TC
        ,KEY_DETAIL_SCREEN_EDIT_CON_FIELDS
        ,KEY_SEARCH_SCREEN_SORTABLE_FIELDS
        ,KEY_TERMS_AND_CONDITIONS_URL
        ,KEY_IMAGE_URL_RECOMMENDED_PARTNER
        ,KEY_SEARCH_HELP_URL
        ,KEY_SEARCH_DISTANCE_DEFAULT
        ,KEY_SEARCH_DISTANCE_OPTIONS
        ,KEY_SEARCH_MAX_RESULTS
        ,KEY_AUTO_COMPLETION_ENABLED
        ,KEY_KEYWORD_AUTO_COMPLETION_ENABLED
        ,KEY_LOCATION_AUTO_COMPLETION_ENABLED
        ,KEY_PRIORITIZED_COUNTRY_LIST
        // Ver 1.0: To query the list of PD logo url
        ,KEY_PARTNERDIRECT_LOGO_URLS
        // Ver 2.1: Default Region
        ,KEY_DEFAULT_REGION
        ,KEY_DEFAULT_LANGUAGE
        ,KEY_DISTRIBUTOR_PARTNER_TYPE
        ,KEY_SCRIPT_STATEMENT_LIMIT // Ver 2.3: added 
        ,KEY_DETAIL_SCREEN_SHOWCASE_BASIC_FIELDS //v2.4
        ,KEY_FIELDS_CONTACT_US //v4.0  
        ,KEY_BAIDU_MAPS_API_URL //5.0 GAN POC
        ,KEY_CSP_7_SEARCH_FIELDS //6.0
        ,KEY_OBJECT
        ,KEY_FIELD_MIN_PARTNERLOCATION
        ,KEY_FIELD_MIN_ACCOUNT
        ,KEY_FIELDS_PARTNER_TRACK_RESULT
        ,STR_KEY_FIELDS_FEDERAL_DETAIL_VIEW //Added by Akshita
        ,KEY_FIELDS_MASTER_GROUP_RESULT
        ,KEY_ACCOUNT_DETAIL_FIELDS
        ,KEY_PARTNER_TRACK_DETAIL_FIELDS
        ,KEY_DETAIL_SCREEN_PARTNER_TRACK_FIELDS_EDIT
        ,KEY_VIEW_DETAIL_FIELDS
    };
//Added By Susmitha to identify Account/Partner Track
    global static string keyValue= string.valueof(FAP_Configuration.getInstance().KeyObject);
    global static string keyValueWithoutDot=keyValue.removeEnd('.');

    global static string  strObjectName =  keyValue == 'Account__r.'?'Account':'Partner_Track__c';
    global static string  strObjectAPIName =  keyValue == 'Account__r.'?'Account__c':'Partner_Track__c';
    
    global static String strIsPartner= keyValue == 'Account__r.'? 'Account__r.IsPartner':'Partner_Track__r.Partner_Account__c';
    global static String strApprovedforPartnerFinder= keyValue == 'Account__r.'? 'Account__r.Approved_for_Partner_Finder__c':'Partner_Track__r.Approved_for_Partner_Finder__c';
    global static String strProfilePublishedtoPartnerFinder= keyValue == 'Account__r.'? 'Account__r.Profile_Published_to_Partner_Finder__c':'Partner_Track__r.Profile_Published_to_Partner_Finder__c';
    global static String strUserAgreedtoPFTermsCond= keyValue == 'Account__r.'? 'Account__r.Partner_User_Agreed_to_PF_Terms_Cond__c':'Partner_Track__r.User_Agreed_to_PF_Terms_Cond__c';
    global static String strDateAgreedtoPFTermsCond= keyValue == 'Account__r.'? 'Account__r.Partner_Date_Agreed_to_PF_Terms_Cond__c':'Partner_Track__r.Partner_Date_Agreed_to_PF_Terms_Cond__c';
    
    global static String strRecLegalName = (keyValue == 'Account__r.'? 'Name':'Primary_Sales_Motion_Account_Legal_Name__c');
    global static String strAcctLocalName = (keyValue == 'Account__r.'? 'NameLocal':'Partner_Track_Account_Local_Name__c');

    global static String strFieldPartnerType = keyValue == 'Account__r.'?'Account.Partner_Type__c':'Partner_Track__c.Partner_Type__c';
    global static String strPartnerUsrAgreed = keyValue == 'Account__r.'? 'Partner_User_Agreed_to_PF_Terms_Cond__c':'User_Agreed_to_PF_Terms_Cond__c';

    //End By Susmitha
    // Start: Fields for Certification_Tracker__c added by Shravan
    
    global static string strServicesCompetencies = keyValue == 'Account__r.'?'Deployment_Certifications_Completed__c':'Services_Competencies__c';
    
    global static string strCompObjectAPIName = 'Account_Name__c';
    global static String strCompIsPartner= 'Account_Name__r.IsPartner';
    global static String strCompApprovedforPartnerFinder= 'Account_Name__r.Approved_for_Partner_Finder__c';
    global static String strCompProfilePublishedtoPartnerFinder= 'Account_Name__r.Profile_Published_to_Partner_Finder__c';
    global static String strCompUserAgreedtoPFTermsCond= 'Account_Name__r.Partner_User_Agreed_to_PF_Terms_Cond__c';
    global static String strCompDateAgreedtoPFTermsCond= 'Account_Name__r.Partner_Date_Agreed_to_PF_Terms_Cond__c';
    
    //End: Fields for Certification_Tracker__c added by Shravan
    
    //==================================================
    // PROPERTIES
    //==================================================
    private Map<String,String> rawConfig = null;

    global Integer searchDistanceDefault        {get;set;}
    global Integer searchMaxResults             {get;set;}
    global Integer scriptStatementLimit         {get;set;} // Ver 2.3: added
    global List<Integer> searchDistanceOptions  {get;set;}
    global String regionDefault                 {get;set;}
    global String langaugeDefault               {get;set;}
    global String distributorPartnerType        {get;set;}
    global String keyObject                     {get;set;}  

    //==================================================
    // DERIVED PROPERTIES
    //==================================================
        
    global List<FAP_FieldConfiguration> searchScreenBasicSearchFields {get{
        if(searchScreenBasicSearchFields == null){
            searchScreenBasicSearchFields = load(KEY_SEARCH_SCREEN_BASIC_SEARCH_FIELDS);
            
        }
        return searchScreenBasicSearchFields;
    }private set;}
    
    global List<FAP_FieldConfiguration> searchScreenAdvancedSearchFields {get{
        if(searchScreenAdvancedSearchFields == null){
            searchScreenAdvancedSearchFields = load(KEY_SEARCH_SCREEN_ADVANCED_SEARCH_FIELDS);
        }
        return searchScreenAdvancedSearchFields;
    }private set;}

    global List<FAP_FieldConfiguration> searchScreenFieldsInResultList {get{
        if(searchScreenFieldsInResultList == null){
            searchScreenFieldsInResultList = load(KEY_SEARCH_SCREEN_FIELDS_IN_RESULT_LIST); 
        }
        system.debug('##### - searchScreenFieldsInResultList ' + searchScreenFieldsInResultList);
        return searchScreenFieldsInResultList;
    }private set;}
    
    //Added by Neeti & Shravan on 26-12-2018 Start
    
    global List<FAP_FieldConfiguration> searchMinFieldsforPartnerLoc {get{
        if(searchMinFieldsforPartnerLoc == null){
            searchMinFieldsforPartnerLoc = filterByObjectName(load(KEY_FIELD_MIN_PARTNERLOCATION),'Partner_Location__c');
           }
            system.debug('@@@@searchMinFieldsforPartnerLoc @@@@ ' + searchMinFieldsforPartnerLoc);
            return searchMinFieldsforPartnerLoc ;
        }private set;}
        
    global List<FAP_FieldConfiguration> searchMinFieldsforAccount {get{
        if(searchMinFieldsforAccount == null){
           searchMinFieldsforAccount = load(KEY_FIELD_MIN_ACCOUNT);
           }
            system.debug('@@@@searchMinFieldsforAccount@@@@ ' + searchMinFieldsforAccount);
            return searchMinFieldsforAccount;
        }private set;}
        
   global List<FAP_FieldConfiguration> detailPartnerTrackFields {get{
        if(detailPartnerTrackFields == null){
            detailPartnerTrackFields = load(KEY_FIELDS_PARTNER_TRACK_RESULT);
        } 
        system.debug('@@@@detailPartnerTrackFields @@@@ ' + detailPartnerTrackFields);
        return detailPartnerTrackFields;
    }private set;} 
    
   global List<FAP_FieldConfiguration> listDetailPartnerTrackFederalFields {get{
        if(listDetailPartnerTrackFederalFields == null){
            listDetailPartnerTrackFederalFields = load(STR_KEY_FIELDS_FEDERAL_DETAIL_VIEW);
        } 
        system.debug('@@@@detailPartnerTrackFederalFields @@@@ ' + listDetailPartnerTrackFederalFields);
        return listDetailPartnerTrackFederalFields;
    }private set;}    
    global List<FAP_FieldConfiguration> detailMasterGroupFields {get{
        if(detailMasterGroupFields== null){
            detailMasterGroupFields = load(KEY_FIELDS_MASTER_GROUP_RESULT);
        } 
        system.debug('@@@@detailMasterGroupFields@@@@ ' + detailMasterGroupFields);
        return detailMasterGroupFields;
    }private set;}  
        
     //Added by Neeti & Shravan on 26-12-2018 End
        
    global List<FAP_FieldConfiguration> searchScreenSortableFields {get{
        if(searchScreenSortableFields == null){
           searchScreenSortableFields = load(KEY_SEARCH_SCREEN_SORTABLE_FIELDS);
        } 
        return searchScreenSortableFields;
    }private set;}

    global List<FAP_FieldConfiguration> detailScreenCompanyBasicFields {get{
        if(detailScreenCompanyBasicFields == null){
           detailScreenCompanyBasicFields = filterByObjectName(load(KEY_DETAIL_SCREEN_COMPANY_BASIC_FIELDS),'Account');
        } 
        system.debug('@@@@detailScreenCompanyBasicFields@@@@ ' + detailScreenCompanyBasicFields );
        return detailScreenCompanyBasicFields;
    }private set;}
    
    global List<FAP_FieldConfiguration> detailScreenPartnerTrackBasicFields {get{
        if(detailScreenPartnerTrackBasicFields == null){
           detailScreenPartnerTrackBasicFields = filterByObjectName(load(KEY_DETAIL_SCREEN_COMPANY_BASIC_FIELDS_PT),'Partner_Track__c');
        } 
        system.debug('@@@@detailScreenPartnerTrackBasicFields@@@@ ' + detailScreenPartnerTrackBasicFields);
        return detailScreenPartnerTrackBasicFields ;
    }private set;}
    
    global List<FAP_FieldConfiguration> detailScreenPartnerTrackExtendedFields {get{
        if(detailScreenPartnerTrackExtendedFields == null){
            detailScreenPartnerTrackExtendedFields = filterByObjectName(load(KEY_DETAIL_SCREEN_COMPANY_EXTENDED_FIELDS_PT),'Partner_Track__c');
        } 
        return detailScreenPartnerTrackExtendedFields ;
    }private set;}
    
    global List<FAP_FieldConfiguration> detailScreenCompanyExtendedFields {get{
        if(detailScreenCompanyExtendedFields == null){
            detailScreenCompanyExtendedFields = filterByObjectName(load(KEY_DETAIL_SCREEN_COMPANY_EXTENDED_FIELDS),'Account');
        } 
        return detailScreenCompanyExtendedFields;
    }private set;}
    
    //v4.0 - start
    global List<FAP_FieldConfiguration> detailContactUsFields {get{
        if(detailContactUsFields == null){
           detailContactUsFields = filterByObjectName(load(KEY_FIELDS_CONTACT_US),'Lead');
        } 
        return detailContactUsFields;
    }private set;}
    //v4.0 - end

    //Start v2.4
    global List<FAP_FieldConfiguration> detailScreenShowcaseFields {get{
        if(detailScreenShowcaseFields == null){
            detailScreenShowcaseFields = filterByObjectName(load(KEY_DETAIL_SCREEN_SHOWCASE_BASIC_FIELDS),'Partner_Showcase__c');
        } 
        return detailScreenShowcaseFields;
    }private set;}
    //End v2.4
    
   //v3.1 Start 
   global List<FAP_FieldConfiguration> detailScreenSMExtendedFields {get{
        if(detailScreenSMExtendedFields == null){
            detailScreenSMExtendedFields = load(KEY_DETAIL_SCREEN_SM_EXTENDED_FIELDS);
        } 
        return detailScreenSMExtendedFields;
    }private set;}
   //v3.1 End
    //Start - Naga added user story - 197189 (16.12)
    global List<FAP_FieldConfiguration> detailScreenServicesEditField{get{
        if(detailScreenServicesEditField == null){
            detailScreenServicesEditField = load(KEY_DETAIL_SCREEN_SERVICES_EDIT_FIELD);
        } 
        return detailScreenServicesEditField;
    }private set;}
    
    //End
        //SHOWCASE
    global List<FAP_FieldConfiguration> detailScreenShowcaseEditFields{get{
        if(detailScreenShowcaseEditFields == null){
            detailScreenShowcaseEditFields = load(KEY_DETAIL_SCREEN_SHOWCASE_EDIT_FIELDS);
        } 
        return detailScreenShowcaseEditFields;
    }private set;}

    //test end

    global List<FAP_FieldConfiguration> detailScreenLocationFields {get{
        if(detailScreenLocationFields == null){
            detailScreenLocationFields = load(KEY_DETAIL_SCREEN_LOCATION_FIELDS);
        } 
        return detailScreenLocationFields;
    }private set;}

    global List<FAP_FieldConfiguration> detailScreenEditFields {get{
        if(detailScreenEditFields == null){
           
                detailScreenEditFields = load(KEY_DETAIL_SCREEN_EDIT_FIELDS);
         
        } 
        return detailScreenEditFields;
    }private set;}
    
    global List<FAP_FieldConfiguration> detailPartnerTrackScreenEditFields {get{
        if(detailPartnerTrackScreenEditFields == null){
           
              detailPartnerTrackScreenEditFields = load(KEY_DETAIL_SCREEN_EDIT_FIELDS_PT);    
           
        } 
        return detailPartnerTrackScreenEditFields;
    }private set;}
    
    //v2.0
     /* global List<FAP_FieldConfiguration> detailPartnerTrackScreenEditFieldsFed {get{
        if(detailPartnerTrackScreenEditFieldsFed == null){           
              detailPartnerTrackScreenEditFieldsFed = load(KEY_DETAIL_SCREEN_EDIT_FIELDS_FED);    
           
        } 
        return detailPartnerTrackScreenEditFieldsFed;
    }private set;} */ 
    
    
    global List<FAP_FieldConfiguration> detailScreenEditTCFields {get{
        if(detailScreenEditFields == null){
            detailScreenEditFields = load(KEY_DETAIL_SCREEN_TC);
        } 
        return detailScreenEditFields;
    }private set;}
    
    global List<FAP_FieldConfiguration> detailScreenEditWebsite {get{
        if(detailScreenEditWebsite == null){
            detailScreenEditWebsite = load(KEY_DETAILS_WEBSITE_EDIT_FIELD);
        } 
        return detailScreenEditWebsite;
    }private set;}   
       
    global List<FAP_FieldConfiguration> detailScreenEditCompDesc {get{
        if(detailScreenEditCompDesc == null){
            detailScreenEditCompDesc = load(KEY_DETAILS_COMP_DESC_EDIT_FIELD);
        } 
        return detailScreenEditCompDesc;
    }private set;}
    
    global List<String> prioritizedCountries{
        
        get{ return (FAP_StringUtils.isEmpty(get(KEY_PRIORITIZED_COUNTRY_LIST))?new List<String>():FAP_StringUtils.split(get(KEY_PRIORITIZED_COUNTRY_LIST),'|'));}
        private set;
    }
    
    //6.0 - Start
    global List<FAP_FieldConfiguration> searchCSPFields {get{
        if(searchCSPFields == null){
            searchCSPFields = load(KEY_CSP_7_SEARCH_FIELDS);
            
        }
        system.debug('###searchCSPFields-'+searchCSPFields);
        return searchCSPFields;
    }private set;}
      
        
    global String googleMapsApiKey              {get{return get(KEY_GOOGLE_MAPS_API_KEY          );}}
    global String googleMapsApiKeyForSites      {get{return get(KEY_GOOGLE_MAPS_API_KEY_SITES    );}}
    //2.0 Change google maps api url from v2 to v3
    global String googleMapsApiUrl              {get{
                                                     String url = get(KEY_GOOGLE_MAPS_API_URL);
                                                     return (FAP_StringUtils.isEmpty(url)?'http://maps.google.com/maps?file=api&v=2&sensor=false&key=':url);
                                                     //return ('https://maps.googleapis.com/maps/api/js?key=AIzaSyAhnhBsjW_gI9WUz__VAiRSplanYjaPLkM&sensor=false&v=3.7&client=gme-dellusalp');
                                                     
                                                }}
                                 
    
    //5.0 GAN POC
    global String baiduMapsApiUrl              {get{
                                                     String url = get(KEY_BAIDU_MAPS_API_URL);
                                                     return (FAP_StringUtils.isEmpty(url)?'https://api.map.baidu.com/api?v=2.0&ak=IS3a8mjty9TaTB29INDlToT7WHUxeDi0&s=1&&callback=initialize':url);
                                                }}
    
    global String imageUrlRecommendedPartner    {get{return get(KEY_IMAGE_URL_RECOMMENDED_PARTNER);}}
    global String searchHelpUrl                 {get{return get(KEY_SEARCH_HELP_URL              );}}
    global String termsAndConditionsUrl         {get{return get(KEY_TERMS_AND_CONDITIONS_URL     );}}

    global Boolean isAutoCompletionEnabled      {get{ String configVal = get(KEY_AUTO_COMPLETION_ENABLED);
                                                          return FAP_StringUtils.isEmpty(configVal)? true : 
                                                                                            (configVal.equalsIgnoreCase('false')||configVal.equalsIgnoreCase('0'))?false:true ;}}
    global Boolean isKeywordAutoCompletionEnabled       {get{ String configVal = get(KEY_KEYWORD_AUTO_COMPLETION_ENABLED);
                                                          return FAP_StringUtils.isEmpty(configVal)? true : 
                                                                                            (configVal.equalsIgnoreCase('false')||configVal.equalsIgnoreCase('0'))?false:true ;}}
    global Boolean isLocationAutoCompletionEnabled      {get{ String configVal = get(KEY_LOCATION_AUTO_COMPLETION_ENABLED);
                                                          return FAP_StringUtils.isEmpty(configVal)? true : 
                                                                                            (configVal.equalsIgnoreCase('false')||configVal.equalsIgnoreCase('0'))?false:true ;}}
    global Boolean isTermsConditionsFeatureEnabled{
        get{return FAP_StringUtils.isNotEmpty(termsAndConditionsUrl);}
    }
           
    // Ver 1.0: Return a map that contains PartnerDirect logos, the partner relationship as the key, and PartnerDirect logo relative url as value
    global Map<string, string> partnerDirectLogos{
        get{
            if(partnerDirectLogos == null) {partnerDirectLogos = new Map<string, string>(); }
            if(partnerDirectLogos.size() == 0) {
                List<string> elements = FAP_StringUtils.split(get(KEY_PARTNERDIRECT_LOGO_URLS), '|');
                if((elements != null) && (elements.size() > 0)){
                    for(string element : elements){
                        List<string> keyValuePair = FAP_StringUtils.split(element, '@');
                        partnerDirectLogos.put(FAP_StringUtils.upperCase(keyValuePair[0]), keyValuePair[1]);
                    }
                }
            }
            return partnerDirectLogos;
        }
        private set;
    }


    //==================================================
    // CONSTRUCTOR
    //==================================================
    private FAP_Configuration(){
        this.rawConfig = new Map<String,String>();
        //Modified with Configuration Variable metadata
        /*final List<FAP_Configuration_Variable__c> vars = 
            [select Value__c, Name, Id 
            from FAP_Configuration_Variable__c 
            where name in :ALL_CONFIG_KEY];
        if(vars != null && vars.size() > 0){
            for(FAP_Configuration_Variable__c var : vars){
                this.rawConfig.put(FAP_StringUtils.trim(var.name),var.value__c);
            }
        }*/
                system.debug('ALL_CONFIG_KEY $$$'+ALL_CONFIG_KEY);

        final List<Configuration_Variable__mdt> vars = 
            [select Value__c, DeveloperName, Id 
            from Configuration_Variable__mdt 
            where DeveloperName in :ALL_CONFIG_KEY];
            system.debug('@@@@@vars@@@@' + vars );
        if(vars != null && vars.size() > 0){
            for(Configuration_Variable__mdt var : vars){
                this.rawConfig.put(FAP_StringUtils.trim(var.DeveloperName),var.value__c);
            }
        }
         system.debug('@@@@@rawConfig@@@@' +  this.rawConfig);
        //Modified with Configuration Variable metadata
        
        this.searchDistanceDefault = parseInteger(get(KEY_SEARCH_DISTANCE_DEFAULT));
        this.searchMaxResults = parseInteger(get(KEY_SEARCH_MAX_RESULTS));
        this.searchDistanceOptions = parseIntegerList(get(KEY_SEARCH_DISTANCE_OPTIONS));
        this.regionDefault = get(KEY_DEFAULT_REGION);
        this.langaugeDefault = get(KEY_DEFAULT_LANGUAGE);
        this.distributorPartnerType = get(KEY_DISTRIBUTOR_PARTNER_TYPE);
        // Ver 2.3: added
        string scriptLimit = get(KEY_SCRIPT_STATEMENT_LIMIT);
        this.scriptStatementLimit = (scriptLimit == null) || (scriptLimit.trim().length() == 0) ? Limits.getLimitScriptStatements()  : Integer.valueOf(scriptLimit.trim()); 
        
        if(this.searchMaxResults == null || this.searchMaxResults <= 0 || this.searchMaxResults > 10000){
            this.searchMaxResults = 500;
        }
        this.keyObject =get(KEY_OBJECT);
    }
    
    //==================================================
    // HELPER METHODS
    //==================================================
    global static FAP_Configuration instance;
    
    global static FAP_Configuration getInstance(){
        if(instance == null){
            instance = new FAP_Configuration();
        }
        return instance;
    }
    
    private List<FAP_FieldConfiguration> loadIfNull( List<FAP_FieldConfiguration> fieldConfigList, final String key){
        if(fieldConfigList == null){
            fieldConfigList = load(key);
        }
        return fieldConfigList;
    }


    private List<FAP_FieldConfiguration> load( final String key){
        //List<FAP_FieldConfiguration> returnValue = filterInvalidFields(FAP_FieldConfiguration.parse(get(key))); // Ver 2.2: To fix 'Too many script statements'
        //return returnValue;  // Ver 2.2: To fix 'Too many script statements'
        system.debug('##### key -->'+Key);
        return filterInvalidFields(FAP_FieldConfiguration.parse(get(key)));
    }

    private List<FAP_FieldConfiguration> filterByObjectName(  final List<FAP_FieldConfiguration> fieldConfigurations,
                                                           final String objectName)
    {
        final List<FAP_FieldConfiguration> filtered = new List<FAP_FieldConfiguration>();
        if(fieldConfigurations != null && fieldConfigurations.size() > 0){
            for(FAP_FieldConfiguration fieldConfiguration : fieldConfigurations){
                if(FAP_StringUtils.equalsIgnoreCase(objectName,fieldConfiguration.objectName)){
                    filtered.add(fieldConfiguration);
                }
            }
        }
        return filtered;
    }
    private String get(String key){
        String returnValue = null;
        if((key != null) && (key.trim().length() != 0) && this.rawConfig.containsKey(key)){
            returnValue = this.rawConfig.get(key);
        }
        return returnValue;
    }
    
    private List<FAP_FieldConfiguration> filterInvalidFields(  final List<FAP_FieldConfiguration> fieldConfigurations){
                system.debug('##### fieldConfigurations -->'+fieldConfigurations);

        final FAP_FieldIndex fieldIndex = new FAP_FieldIndex().indexType(
            new List<Schema.DescribeSObjectResult>{
                Schema.sObjectType.Account,
                Schema.sObjectType.Partner_Location__c,
                Schema.sObjectType.Social_Media__c,
                Schema.sObjectType.Partner_Showcase__c,
                Schema.sObjectType.Partner_Track__c
            }
        );
        
        system.debug('##### fieldIndex -->'+fieldIndex);
       
        final List<FAP_FieldConfiguration> validFields = new List<FAP_FieldConfiguration>();
        if(fieldIndex != null && fieldConfigurations != null && fieldConfigurations.size() > 0){
            for(FAP_FieldConfiguration fieldConfiguration : fieldConfigurations){
                        system.debug('##### fieldConfiguration - 513 -->'+fieldConfiguration);
                if(fieldIndex.isValidField(fieldConfiguration.objectName, fieldConfiguration.fieldName)){
                    fieldConfiguration.populateFieldsFromDescribe(
                       fieldIndex.getDescribeForField(
                           fieldConfiguration.objectName, 
                           fieldConfiguration.fieldName
                       )
                    );
                    
                    validFields.add(fieldConfiguration);
                }
            }
        }
        system.debug('****validFields***'+validFields);
        return validFields;
    }

    public static Integer parseInteger(String value){
        Integer returnValue = null;
        if(FAP_StringUtils.isNotBlank(value)){
            try{
                returnValue = Integer.valueOf(value);
            }catch(System.TypeException e){}
        }
        return returnValue;
    }

    public static List<Integer> parseIntegerList(String value){
        List<Integer> returnValue = new List<Integer>();
        List<String> split = FAP_StringUtils.split(value,'|');
        if(split != null && !split.isEmpty()){
            Integer parsed = null;
            for(String toParse : split){
                parsed = parseInteger(toParse);
                if(parsed != null){
                    returnValue.add(parsed);
                }
            }
        }
        return returnValue;
    } 

    global List<FAP_FieldConfiguration> detailAccountFields{get{
        if(detailAccountFields == null){
            detailAccountFields = load(KEY_ACCOUNT_DETAIL_FIELDS);
        } 
        return detailAccountFields;
    }private set;}  
    global List<FAP_FieldConfiguration> detailPartnerTrackFieldsload{get{
        if(detailPartnerTrackFields == null){
            detailPartnerTrackFields = load(KEY_PARTNER_TRACK_DETAIL_FIELDS);
        } 
        return detailPartnerTrackFields;
    }private set;} 
    global List<FAP_FieldConfiguration> detailScreenPartnerTrackFieldsEdit {get{
        if(detailScreenPartnerTrackFieldsEdit == null){
           detailScreenPartnerTrackFieldsEdit = load(KEY_DETAIL_SCREEN_PARTNER_TRACK_FIELDS_EDIT );
        } 
        return detailScreenPartnerTrackFieldsEdit;
    }private set;}    
    global List<FAP_FieldConfiguration> viewDetailFields{get{
        if(viewDetailFields == null){
            viewDetailFields = load(KEY_VIEW_DETAIL_FIELDS);
        } 
        return viewDetailFields;
    }private set;}     
}
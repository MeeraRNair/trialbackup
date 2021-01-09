public class FAP_PartnerSearchConstants {
    public static final String CONFIG_KEY_GOOGLE_MAPS_API_KEY           = 'GOOGLE_MAPS_API_KEY';
    public static final String CONFIG_KEY_GOOGLE_MAPS_API_KEY_SITES     = 'GOOGLE_MAPS_API_KEY_SITES';
    public static final String CONFIG_KEY_FIELDS_SEARCHABLE_ADVANCED    = 'FIELDS_ADVANCED_SEARCH';
    public static final String CONFIG_KEY_FIELDS_SEARCHABLE_BASIC       = 'FIELDS_BASIC_SEARCH';
    public static final String CONFIG_KEY_FIELDS_IN_RESULT_LIST         = 'FIELDS_IN_RESULTS_LIST';
    public static final String CONFIG_KEY_FIELDS_DETAIL_BASIC           = 'FIELDS_DETAIL_BASIC';
    public static final String CONFIG_KEY_FIELDS_DETAIL_OVERVIEW        = 'FIELDS_DETAIL_OVERVIEW';
    public static final String CONFIG_KEY_FIELDS_SOCIALMEDIA_EDIT       = 'FIELDS_SOCIALMEDIA_EDIT';
    public static final String CONFIG_KEY_FIELDS_SHOWCASE_EDIT          = 'FIELDS_SHOWCASE_EDIT';
    public static final String CONFIG_KEY_FIELDS_DETAIL_LOCATION        = 'FIELDS_DETAIL_LOCATION';
    public static final String CONFIG_KEY_FIELDS_DETAIL_EDIT            = 'FIELDS_DETAIL_EDIT';
    public static final String CONFIG_KEY_FIELDS_SORTING                = 'FIELDS_SORTING';
    public static final String CONFIG_KEY_TERMS_AND_CONDITIONS_URL      = 'TERMS_AND_CONDITIONS_URL';
    public static final String CONFIG_KEY_IMAGE_URL_RECOMMENDED_PARTNER = 'IMAGE_URL_RECOMMENDED_PARTNER';
    public static final String CONFIG_KEY_SEARCH_HELP_URL               = 'SEARCH_HELP_URL';
    public static final String CONFIG_KEY_OBJECT                        = 'KEY_OBJECT';
    
    private static final String[] ALL_CONFIG_KEY = new String[]{
         CONFIG_KEY_GOOGLE_MAPS_API_KEY
        ,CONFIG_KEY_GOOGLE_MAPS_API_KEY_SITES
        ,CONFIG_KEY_FIELDS_SEARCHABLE_ADVANCED
        ,CONFIG_KEY_FIELDS_SEARCHABLE_BASIC
        ,CONFIG_KEY_FIELDS_IN_RESULT_LIST
        ,CONFIG_KEY_FIELDS_DETAIL_BASIC
        ,CONFIG_KEY_FIELDS_DETAIL_OVERVIEW
        ,CONFIG_KEY_FIELDS_SOCIALMEDIA_EDIT
        ,CONFIG_KEY_FIELDS_SHOWCASE_EDIT  
        ,CONFIG_KEY_FIELDS_DETAIL_LOCATION
        ,CONFIG_KEY_FIELDS_DETAIL_EDIT
        ,CONFIG_KEY_FIELDS_SORTING
        ,CONFIG_KEY_TERMS_AND_CONDITIONS_URL
        ,CONFIG_KEY_IMAGE_URL_RECOMMENDED_PARTNER
        ,CONFIG_KEY_SEARCH_HELP_URL
        ,CONFIG_KEY_OBJECT
    };

    public String googleMapsApiKey              {get;private set;}
    public String googleMapsApiKeySites         {get;private set;}
    public String fieldsSearchableAdvanced      {get;private set;}
    public String fieldsSearchableBasic         {get;private set;}
    public String fieldsInResultList            {get;private set;}
    public String fieldsDetailBasic             {get;private set;}
    public String fieldsDetailOverview          {get;private set;}
    public String fieldsSocialmediaEdit         {get;private set;}
    public String fieldsShowcaseEdit            {get;private set;}
    public String fieldsDetailLocation          {get;private set;}
    public String fieldsDetailEdit              {get;private set;}
    public String fieldsSorting                 {get;private set;}
    public String termsAndConditionsUrl         {get;private set;}
    public String imageUrlRecommendedPartner    {get;private set;}
    public String searchHelpUrl                 {get;private set;}
    public String keyObject                     {get;private set;}

    public static FAP_PartnerSearchConstants getInstance(){
        Map<String,String> nameToValue = new Map<String,String>();
        List<Configuration_Variable__mdt> vars = [select Value__c, DeveloperName, Id from Configuration_Variable__mdt 
            where DeveloperName in :ALL_CONFIG_KEY];
        if(vars != null && vars.size() > 0){
            for(Configuration_Variable__mdt var : vars){
                nameToValue.put(var.DeveloperName,var.value__c);
            }
        }
        final FAP_PartnerSearchConstants constants  = new FAP_PartnerSearchConstants();
        constants.googleMapsApiKey                  = nameToValue.get(CONFIG_KEY_GOOGLE_MAPS_API_KEY );
        constants.googleMapsApiKeySites             = nameToValue.get(CONFIG_KEY_GOOGLE_MAPS_API_KEY_SITES );
        constants.fieldsSearchableAdvanced          = nameToValue.get(CONFIG_KEY_FIELDS_SEARCHABLE_ADVANCED );
        constants.fieldsSearchableBasic             = nameToValue.get(CONFIG_KEY_FIELDS_SEARCHABLE_BASIC );
        constants.fieldsInResultList                = nameToValue.get(CONFIG_KEY_FIELDS_IN_RESULT_LIST);
        constants.fieldsDetailBasic                 = nameToValue.get(CONFIG_KEY_FIELDS_DETAIL_BASIC);
        constants.fieldsDetailOverview              = nameToValue.get(CONFIG_KEY_FIELDS_DETAIL_OVERVIEW);
        constants.fieldsSocialmediaEdit             = nameToValue.get(CONFIG_KEY_FIELDS_SOCIALMEDIA_EDIT);
        constants.fieldsShowcaseEdit                = nameToValue.get(CONFIG_KEY_FIELDS_SHOWCASE_EDIT);
        constants.fieldsDetailLocation              = nameToValue.get(CONFIG_KEY_FIELDS_DETAIL_LOCATION);
        constants.fieldsDetailEdit                  = nameToValue.get(CONFIG_KEY_FIELDS_DETAIL_EDIT);
        constants.fieldsSorting                     = nameToValue.get(CONFIG_KEY_FIELDS_SORTING );
        constants.termsAndConditionsUrl             = nameToValue.get(CONFIG_KEY_TERMS_AND_CONDITIONS_URL);
        constants.imageUrlRecommendedPartner        = nameToValue.get(CONFIG_KEY_IMAGE_URL_RECOMMENDED_PARTNER);
        constants.searchHelpUrl                     = nameToValue.get(CONFIG_KEY_SEARCH_HELP_URL);
        constants.keyObject                         = nameToValue.get(CONFIG_KEY_OBJECT);
        
        system.debug('##### CONFIG_KEY_FIELDS_DETAIL_EDIT -->'+CONFIG_KEY_FIELDS_DETAIL_EDIT);
        system.debug('##### nameToValue.get(CONFIG_KEY_FIELDS_DETAIL_EDIT) -->'+nameToValue.get(CONFIG_KEY_FIELDS_DETAIL_EDIT));
        system.debug('##### constants.fieldsDetailEdit -->'+constants.fieldsDetailEdit);

        return constants;
    } 
}
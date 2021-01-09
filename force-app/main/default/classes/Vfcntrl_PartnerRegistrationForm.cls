/* Revision  Name            Date                 CR       Release No            Description
* 1.0       Jatin        12.06.2018            16018       Fy-19-DCS-0802       Commented NET exam logic statements as part of NET003 story
*/

public without sharing class Vfcntrl_PartnerRegistrationForm {

    
 // Variables declaration
    public static string country; 
    public static string language; 
    public static Country__c selectedCountryRecord; 
    public static map<string,string> partnerTypeOption;
    public static string selectedPartnerType;
    public static List<PartnerRegistrationFormTabHelper> tabs;
    public static Map<String, String> fieldConfigToFieldNameMap;
    public static Map<String, Partner_Type_Field_Configuration__c> fieldConfigMap;
    public static final Integer MAX_ATTACHMENTS = 5;  
    
    public static string getLanguage(){
        system.debug('$$$$$' +language);
        return language;       
    }
          
    @TestVisible private static List<Country__c> countryList{
        get{
            if(countryList == null){
                countryList = [SELECT name, code__c,Region__c,User_Language_Locale_Key__c FROM Country__c WHERE Is_Active_Partner_Country__c = true ORDER BY name];
            }
            return countryList;
        }
        set;
    }
    
     @TestVisible private static Map<String,String> countryMap {
        get{
             if(countryMap == null || test.isRunningTest() ){
                    countryMap = new Map<String,String>();
                    for(Country__c country : countryList){
                        countryMap.put(country.name, StringUtils.lowerCase(country.code__c));
                    }
             }
             return countryMap;
        }
        set;
    }
    
   @TestVisible  private static Map<String,String> countryCodeMap {
        get{
             if(countryCodeMap == null || test.isRunningTest()){
                    countryCodeMap = new Map<String,String>();
                    for(Country__c country : countryList){
                        countryCodeMap.put(StringUtils.lowerCase(country.code__c),country.name);
                    }
             }
             return countryCodeMap;
        }
        set;
    }
    
      public static String UserRegion{
        get{
                map<string,string> regionOptions = new map<string,string>();
                for(Country__c country : regionList){
                    If( country.Region__C != null ){
                        regionOptions.put(country.name,country.Region__C);
                    }
                  }
                    UserRegion = regionOptions.get(country);
                    system.debug('****' +UserRegion);   
            return UserRegion;
        }
        set;
    }
    
    @TestVisible private static List<Country__c> regionList{
        get{
            if(regionList== null){
                regionList= [ SELECT name, code__c,Region__c FROM Country__c WHERE Is_Active_Partner_Country__c = true ORDER BY name];
            }
            return regionList;
        }
        set;
    }
    
       @TestVisible   private static boolean isvalidLanguage(String languageCode){                    
              boolean isvalid;
              map<string,string> countryLanguageMap = new Map<String,String>();
                    for(Country__c country : countryList){

                     if(country.Code__c == 'NL'){
                            countryLanguageMap.put('nl__c',country.name);
                        }else{
                        countryLanguageMap.put(StringUtils.lowerCase(country.User_Language_Locale_Key__c)+'__c',country.name);}
                    }
           if(countryLanguageMap.get(StringUtils.lowerCase(languageCode)) == null){
               isvalid = false;
           }else{
              isvalid = true;
           }
            return isvalid;
     }
    
    
    
   @TestVisible   private static map<String,string> getPartnerTypeOptions(String Country,boolean isInviteLink){

         string translate='';
         map<String,string> partnerTypeOptions = new map<String,string>();
       
          system.debug('isInviteLink>>>'+isInviteLink);
       List<Partner_Type__c> partnerTypes ;
       
       if(isInviteLink)
       {
           partnerTypes = [SELECT name, Translated_Partner_Type_Name__c
                        FROM Partner_Type__c
                        WHERE Is_Active__c = true AND Country__r.name = :Country                          
                        ORDER BY Sort_Order__c ];
       }else
       { 
          partnerTypes = [SELECT name, Translated_Partner_Type_Name__c
                        FROM Partner_Type__c
                        WHERE Is_Active__c = true AND Country__r.name = :Country AND Is_Visible__C =:true                        
                        ORDER BY Sort_Order__c];
       
       }
         for(Partner_Type__c partnerType : partnerTypes){
            translate = partnerType.Translated_Partner_Type_Name__c != null? partnerType.Translated_Partner_Type_Name__c: partnerType.name;
            partnerTypeOptions.put(partnerType.name,translate);
         }
            return partnerTypeOptions;
     }
    
      public static map<String,string> getPreferredDellDistributorOptions(string country){
         string translate='';
         map<string,string> PreferredDellDistributorOptions = new map<string,string>();
         List<Select_your_preferredDell_Distributor__c> PreferredDellDistributors = [SELECT name, Translated_preferred_Dell_Distributor__c
                        FROM Select_your_preferredDell_Distributor__c
                        WHERE Contry__r.name = :country];

         for(Select_your_preferredDell_Distributor__c PreferredDellDistributor : PreferredDellDistributors){
            translate = PreferredDellDistributor.Translated_preferred_Dell_Distributor__c != null? PreferredDellDistributor.Translated_preferred_Dell_Distributor__c: PreferredDellDistributor.name;
            PreferredDellDistributorOptions.put(PreferredDellDistributor.name,translate);
         }
         return PreferredDellDistributorOptions;
    }
    
    public static map<String,string> getSponsoringDistributorOptions(string country){
         string translate='';
         map<String,string> SponsoringDistributorOptions = new map<String,string>();
          List<Sponsoring_Distributor__c> SponsorDellDistributors = [SELECT name, Translated_Sponsoring_Distributor__c
                        FROM Sponsoring_Distributor__c
                        WHERE Country__r.name = :country];
        
         for(Sponsoring_Distributor__c SponsordDellDistributor : SponsorDellDistributors ){
            translate = SponsordDellDistributor.Translated_Sponsoring_Distributor__c!= null? SponsordDellDistributor.Translated_Sponsoring_Distributor__c: SponsordDellDistributor.name;
            SponsoringDistributorOptions.put(SponsordDellDistributor.name,translate);
         }
         return SponsoringDistributorOptions;
    }
    
/* Commented Transalations Custom Metadata and created new Onboarding_Translations__c object
    @AuraEnabled
    public static list < Translations__mdt > getLabels() {
        return [select developerName, MasterLabel, cs__c,da__c,de__c,el__c,en_us__c,es__c,es_mx__c,fi__c,hu__c,fr__c,it__c,iw__c,ja__c,ko__c,nl__c,no__c,pl__c,pt_br__c,ro__c,ru__c,sk__c,sv__c,th__c,tr__c,zh_cn__c,zh_tw__c
                from Translations__mdt];
    }*/
    
	@AuraEnabled
    public static list < Onboarding_Translations__c > getLabels() {
        return [select Name,Label__c, cs__c,da__c,de__c,el__c,en_us__c,es__c,es_mx__c,fi__c,hu__c,fr__c,it__c,iw__c,ja__c,ko__c,nl__c,no__c,pl__c,pt_br__c,ro__c,ru__c,sk__c,sv__c,th__c,tr__c,zh_cn__c,zh_tw__c
                from Onboarding_Translations__c];
    }
    
 public class exstngPRDetailsWrapper{
   @AuraEnabled
   public List<PartnerRegistrationFormTabHelper> tabs;
    @AuraEnabled
   public partner_request__c PR;
    @AuraEnabled
   public string country;
    @AuraEnabled
   public string selectedPartnerType;
   @AuraEnabled
   public boolean accessDenied;
    @AuraEnabled
   public list <Onboarding_Translations__c> translations;
   @AuraEnabled
   public string language;
}
    
 @AuraEnabled
 public static exstngPRDetailsWrapper fetchExstngPRDetails(string id,string token,string langFromCmp) {
     
       exstngPRDetailsWrapper wrapper = new exstngPRDetailsWrapper();
       list<partner_request__c> pr = new  list<partner_request__c>();
     
         pr = [select Preferred_language_code__c from partner_request__c where id = :id];
         if(pr.size() > 0){                  
           if(pr[0].Preferred_language_code__c != '' &&  pr[0].Preferred_language_code__c != 'All' &&  pr[0].Preferred_language_code__c != null){
                language = StringUtils.lowerCase(pr[0].Preferred_language_code__c+'__c');
             }else{
                 language = 'en_us__c';
             }
         
            system.debug('**language***' +language);
         }      
           
       tabs = new List<PartnerRegistrationFormTabHelper>();
        PartnerSelectionTab partnerSelectionTab = new PartnerSelectionTab(Label.smart_entry_tab, 'smartEntryTab'); 
        ContactTab contactTab = new ContactTab(Label.contact_tab, 'contactTab');       
        CompanyTab CompanyTab = new CompanyTab (Label.Company_Tab, 'CompanyTab');
        FocusTab focusTab = new FocusTab(Label.focus_tab, 'focusTab'); 
        SegmentTab segmentTab = new SegmentTab(Label.segment_tab, 'segmentTab');  
        ServiceTab serviceTab = new ServiceTab(Label.Service_Tab, 'Cloud Service Provider');
        tabs.add(partnerSelectionTab);
        tabs.add(contactTab); 
        tabs.add(CompanyTab);
        tabs.add(focusTab); 
        tabs.add(segmentTab); 
        tabs.add(serviceTab);
     
        partner_request__c request = new partner_request__c();
        request = loadRequest(id);

        system.debug('****exstngPR*****'+request);        
      
     if(token == request.Incomplete_Registration_Security_Token__c && request.Status__c == 'Incomplete'){
        doUpdateFieldConfig();
        wrapper.PR = request;
        wrapper.tabs = tabs;
        wrapper.country = country;
        wrapper.accessDenied = false;
        wrapper.language = language;
        wrapper.translations = getLabels();
        wrapper.selectedPartnerType = selectedPartnerType;
     }else{
        wrapper.accessDenied = true;
     }
        return wrapper;
 }
    
 public static Partner_Request__c loadRequest(String id){
      partner_request__c pr = new partner_request__c();
     
        Set<String> fieldToSelect = new Set<String>();
        fieldToSelect.add('id');
        fieldToSelect.add('Status__c');
        fieldToSelect.add('Country__c');
        fieldToSelect.add('Region__c');
        fieldToSelect.add('Incomplete_Registration_Security_Token__c');
        fieldToSelect.add('Primary_Channel_Model__c');
        fieldToSelect.add('Job_Title__c');
        fieldToSelect.add('Job_Title_Non_GC__c');
        fieldtoSelect.add('Other_Job_Category__c');
        fieldtoSelect.add('Country__r.Region__c');
        fieldtoSelect.add('Select_your_preferred_Dell_Distributor__c');
        fieldtoSelect.add('Sponsoring_Distributor__c');
        fieldtoSelect.add('select_your_secondary_business_type__c');
        fieldtoSelect.add('Preferred_language_code__c');
        
      for(PartnerRegistrationFormTabHelper aTab : tabs){
                 for(PartnerRegistrationFormFieldHelper field : aTab.fields){
                      fieldToSelect.add(field.fieldName);                    
                 }
             }
        String query = 'select '
            + StringUtils.joinSet(fieldToSelect, ',')
            + ' from Partner_Request__c where id = \'' + String.escapeSingleQuotes(id) + '\' limit 1';
        
        pr = Database.query(query);
     
      selectedPartnerType = pr.Primary_Channel_Model__c;
      country = [select name from country__C where id = :pr.Country__c].name;    
        return pr;
    }
    
       
   @AuraEnabled
    public Static tabLabelsAndCountryListWrapper TabLabelsandCountryListMethod(){
                 
        list<string> tabLabelsfromCustomLabel = new list<string>();
        list<country__c> activeCountryList = new list<country__c>();
        Map<string,id> activeCountryNames = new  Map<string,id>();
        
        tabLabelsfromCustomLabel.add(Label.smart_entry_tab);
        tabLabelsfromCustomLabel.add(Label.contact_tab);
        tabLabelsfromCustomLabel.add(Label.company_tab);
        tabLabelsfromCustomLabel.add(Label.focus_tab);
        tabLabelsfromCustomLabel.add(Label.segment_tab);
        tabLabelsfromCustomLabel.add(Label.Service_Tab);
        tabLabelsfromCustomLabel.add(Label.complete_tab);
        
        activeCountryList = [SELECT id,name, code__c,Region__c  FROM Country__c WHERE Is_Active_Partner_Country__c = true ORDER BY name];
         
        for(country__c temp :activeCountryList){
            activeCountryNames.put(temp.name,temp.id);
        }
       
        tabLabelsAndCountryListWrapper newtabLabelsAndCountryListWrapper = new tabLabelsAndCountryListWrapper(tabLabelsfromCustomLabel,activeCountryNames,countryCodeMap);  
        return newtabLabelsAndCountryListWrapper;
    }
    //Secondary Dependent PickList Changes Start
    public class partnerTypeChangeWrapper{
        List<PartnerRegistrationFormTabHelper> listTabs;
        map<string,string> mapSecondaryTypes;
        public partnerTypeChangeWrapper(){
            listTabs=new List<PartnerRegistrationFormTabHelper>();
            mapSecondaryTypes =new map<string,string>();
        }
    }
    public static map<String,string> getSecondaryPartnerTypeOptions(String strCountry,String strPartnerType){
        string strTranslate='';
        map<String,string> mapSecondaryPartnerTypeOptions = new map<String,string>();
        try{
            
                for(Partner_Program_Track__c secondaryPartnerType : [SELECT Name, Translated_Partner_Type__c FROM Partner_Program_Track__c
                                         WHERE Is_Active__c = true AND Country__r.name = :strCountry AND Partner_Type__c =:strPartnerType                        
                                         ORDER BY Name]){
                    strTranslate = secondaryPartnerType.Translated_Partner_Type__c != null? secondaryPartnerType.Translated_Partner_Type__c: secondaryPartnerType.Name;
                    mapSecondaryPartnerTypeOptions.put(secondaryPartnerType.Name,strTranslate);
                }
         
        }catch(exception e){
            system.debug('Exception : '+e.getMessage());
        }
        return mapSecondaryPartnerTypeOptions;
    }
    //Secondary Dependent PickList Changes End
    @AuraEnabled
    public Static String handlePartnerTypeChangeMethod(string strselectedPartnerFromCmp,string strselectedCountryFromCmp,string strlangFromCmp){
      selectedPartnerType = strselectedPartnerFromCmp;
      country = strselectedCountryFromCmp;
        if(isvalidLanguage(strlangFromCmp) == true){
             language = StringUtils.lowerCase(strlangFromCmp);
        }else{
            language = 'en_us__c';
        }

       tabs = new List<PartnerRegistrationFormTabHelper>();
        PartnerSelectionTab partnerSelectionTab = new PartnerSelectionTab(Label.smart_entry_tab, 'smartEntryTab'); 
        ContactTab contactTab = new ContactTab(Label.contact_tab, 'contactTab');       
        CompanyTab CompanyTab = new CompanyTab (Label.Company_Tab, 'CompanyTab');
        FocusTab focusTab = new FocusTab(Label.focus_tab, 'focusTab'); 
        SegmentTab segmentTab = new SegmentTab(Label.segment_tab, 'segmentTab');  
        ServiceTab serviceTab = new ServiceTab(Label.Service_Tab, 'Cloud Service Provider');
        tabs.add(partnerSelectionTab);
        tabs.add(contactTab); 
        tabs.add(CompanyTab);
        tabs.add(focusTab); 
        tabs.add(segmentTab); 
        tabs.add(serviceTab);
        
        doUpdateFieldConfig();
        partnerTypeChangeWrapper returnWrap=new partnerTypeChangeWrapper();
        returnWrap.listTabs.addAll(tabs);
        returnWrap.mapSecondaryTypes.putAll(getSecondaryPartnerTypeOptions(strselectedCountryFromCmp,strselectedPartnerFromCmp));
        return JSON.serialize(returnWrap);  
    } 
    
    
   @TestVisible private static void doUpdateFieldConfig(){
      
        // Partner Selection tab
            fieldConfigToFieldNameMap = new Map<String,String>();
            fieldConfigToFieldNameMap.put('join dell partnerdirect program','Join_Dell_PartnerDirect_Program__c');
            fieldConfigToFieldNameMap.put('select your preferred dell distributor','Select_your_preferred_Dell_Distributor__c');
            fieldConfigToFieldNameMap.put('sponsoring distributor','Sponsoring_Distributor__c');
            fieldConfigToFieldNameMap.put('select your secondary business type','select_your_secondary_business_type__c');
        //Contact Tab
            fieldConfigToFieldNameMap.put('salutation','Salutation__c');
            fieldConfigToFieldNameMap.put('first name','First_Name__c');
            fieldConfigToFieldNameMap.put('last name','Last_Name__c');
            fieldConfigToFieldNameMap.put('job category','Job_Category__c');
            fieldConfigToFieldNameMap.put('job category non gc','Job_Category_Non_GC__c');
            fieldConfigToFieldNameMap.put('address 1','Address_Line_1__c');
            fieldConfigToFieldNameMap.put('address 2','Address_Line_2__c');
            fieldConfigToFieldNameMap.put('address 3','Address_Line_3__c');
            fieldConfigToFieldNameMap.put('city','City__c');
            fieldConfigToFieldNameMap.put('state / province','State__c');
            fieldConfigToFieldNameMap.put('postal code','Postal_Code__c');
            fieldConfigToFieldNameMap.put('phone number','Phone__c'); 
            fieldConfigToFieldNameMap.put('mobile phone','Mobile__c');
            fieldConfigToFieldNameMap.put('fax number','Fax__c');   
            fieldConfigToFieldNameMap.put('email','Email__c');
            fieldConfigToFieldNameMap.put('would you like to receive our newsletter?','Newsletter_Opt_In__c');          
            fieldConfigToFieldNameMap.put('primary contact aligned','Primary_Contact_Aligned__c');
            fieldConfigToFieldNameMap.put('primary contact first name','Primary_Contact_First_Name__c');
            fieldConfigToFieldNameMap.put('financing options','Financing_Options__c');
            fieldConfigToFieldNameMap.put('financing options non gc','Financing_Options_Non_GC__c');
            fieldConfigToFieldNameMap.put('primary contact last name','Primary_Contact_Last_Name__c');
            fieldConfigToFieldNameMap.put('primary contact job category','Primary_Contact_Job_Category__c');
            fieldConfigToFieldNameMap.put('primary contact phone number','Primary_Contact_Phone_Number__c');
            fieldConfigToFieldNameMap.put('primary contact mobile number','Primary_Contact_Mobile_Number__c');
            fieldConfigToFieldNameMap.put('primary contact email','Primary_Contact_Email__c');
            fieldConfigToFieldNameMap.put('primary contact address 1','Primary_Contact_Address_1__c');
            fieldConfigToFieldNameMap.put('primary contact address 2','Primary_Contact_Address_2__c');
            fieldConfigToFieldNameMap.put('primary contact address 3','Primary_Contact_Address_3__c');
            fieldConfigToFieldNameMap.put('primary contact city','Primary_Contact_City__c');
            fieldConfigToFieldNameMap.put('primary contact state province','Primary_Contact_State_Province__c');
            fieldConfigToFieldNameMap.put('primary contact postal code','Primary_Contact_Postal_Code__c');
        
        
         //Company Tab
            fieldConfigToFieldNameMap.put('Full Legal Name of Your Organization','Company__c');
            fieldConfigToFieldNameMap.put('company legal english name','Company_HK__c');
            fieldConfigToFieldNameMap.put('doing business as / alternative company name','Does_Business_As__c');
            fieldConfigToFieldNameMap.put('company local name/alternative co. name','Does_Business_As_HK__c');
            fieldConfigToFieldNameMap.put('number of branches subsidiaries','Number_of_Branches_Subsidiaries__c');
            fieldConfigToFieldNameMap.put('principal name','Principle_Name__c');
            fieldConfigToFieldNameMap.put('principal title','Principle_Title__c');
            fieldConfigToFieldNameMap.put('organization address 1','Org_Address_1__c');
            fieldConfigToFieldNameMap.put('organization address 2','Org_Address_2__c');
            fieldConfigToFieldNameMap.put('organization address 3','Org_Address_3__c');
            fieldConfigToFieldNameMap.put('organization city','Org_City__c');
            fieldConfigToFieldNameMap.put('organization state / province','Org_State__c');
            fieldConfigToFieldNameMap.put('organization postal code','Org_Postal_Code__c');
            fieldConfigToFieldNameMap.put('organization country','Org_Country__c');
            fieldConfigToFieldNameMap.put('dun and bradstreet duns number','Dun_and_Bradstreet_DUNS_Number__c');
            fieldConfigToFieldNameMap.put('organization phone number','Org_Phone__c');
            fieldConfigToFieldNameMap.put('organization fax','Org_Fax__c');
            fieldConfigToFieldNameMap.put('company website / url','Website__c');
            fieldConfigToFieldNameMap.put('legal representative/proxy holder name','Legal_representative_Proxy_Holder_Name__c');
            fieldConfigToFieldNameMap.put('legal representative/proxy holder email','Legal_representative_Proxy_Holder_Email__c');
            fieldConfigToFieldNameMap.put('form of organization','Form_of_Organization__c');
            fieldConfigToFieldNameMap.put('number of years in business?','Number_of_years_in_business__c');
        // Diverse Questions Sarveswar 
           fieldConfigToFieldNameMap.put('are you considered a diverse owned business?','considered_a_diverse_owned_business__c');
       	   fieldConfigToFieldNameMap.put('diversity certification','Diversity_Certification__c');
           fieldConfigToFieldNameMap.put('national minority development council (nmsdc)','National_Minority_Development_Council__c');    
           fieldConfigToFieldNameMap.put('women\'s business enterprise national council (wbenc)','Women_s_Business_Eprise_National_Council__c');
           fieldConfigToFieldNameMap.put('national lgbt chamber of commerce (nglcc)','National_LGBT_Chamber_of_Commerce__c');
           fieldConfigToFieldNameMap.put('national veteran business development council (nvbdc)','National_Veteran_Business_Devel_Council__c');
           fieldConfigToFieldNameMap.put('small business','Small_Business__c');
       // added by harsha
      		fieldConfigToFieldNameMap.put('Company_Diversity_Certification','Diversity_Certification__c');
           fieldConfigToFieldNameMap.put('other_certifications','Other_Certifications__c'); 
           fieldConfigToFieldNameMap.put('reseller tax id','Reseller_Tax_ID__c');
           
        //Focus Tab
            //fieldConfigToFieldNameMap.put('reseller tax id','Reseller_Tax_ID__c');
            fieldConfigToFieldNameMap.put('states provinces doing bus','States_Provinces_doing_business__c');
            fieldConfigToFieldNameMap.put('total employees','Total_Employees__c');
            fieldConfigToFieldNameMap.put('percent technical prof','Percent_Technical_Professionals__c');
            fieldConfigToFieldNameMap.put('percent sales force','Percent_Sales_Force__c');
            fieldConfigToFieldNameMap.put('annual revenue','Org_Annual_Revenue__c');
            fieldConfigToFieldNameMap.put('hardware revenue percent','Hardware_Revenue_Percent__c');
            fieldConfigToFieldNameMap.put('software revenue percent','Software_Revenue_Percent__c');
            fieldConfigToFieldNameMap.put('service revenue percent','Service_Revenue_Percent__c');
            fieldConfigToFieldNameMap.put('product revenue','Product_Revenue__c');
            fieldConfigToFieldNameMap.put('total marketing professionals','Total_marketing_professionals__c');
            fieldConfigToFieldNameMap.put('currently selling dell','Currently_Selling_Dell__c');
            fieldConfigToFieldNameMap.put('dell revenue percent','Dell_Revenue_Percent__c'); //dependency on Currently_Selling_Dell__c field
            fieldConfigToFieldNameMap.put('primary routes to market','Primary_Routes_to_Market__c');
            fieldConfigToFieldNameMap.put('percentage marketing professional employees','Percentage_Marketing_Professional_Employ__c');
            fieldConfigToFieldNameMap.put('hardware laptop desktop tablet revenue','Hardware_Laptop_Desktop_Tablet_Revenue__c');
            fieldConfigToFieldNameMap.put('hardware server storage networking revenue','Hardware_Server_Storage_Networking_Reven__c');
            fieldConfigToFieldNameMap.put('cloud services revenue','Cloud_Services_Revenue__c');
            fieldConfigToFieldNameMap.put('sell vce products & services','Sell_VCE_Products_Services__c');

        // Segment Tab
            fieldConfigToFieldNameMap.put('size of customer base', 'Size_of_Customer_Base__c');
            fieldConfigToFieldNameMap.put('area of interest','Area_of_Interest__c');
            fieldConfigToFieldNameMap.put('area of interest non gc','Area_of_Interest_Non_GC__c');
            fieldConfigToFieldNameMap.put('product focus','Product_Focus__c');
            fieldConfigToFieldNameMap.put('product focus non gc','Product_Focus_Non_GC__c');
            fieldConfigToFieldNameMap.put('primary customer','Primary_Customer__c');
            fieldConfigToFieldNameMap.put('primary customer non gc','Primary_Customer_Non_GC__c');
            fieldConfigToFieldNameMap.put('secondary customer segment','Secondary_Customer__c');
            fieldConfigToFieldNameMap.put('secondary customer segment non gc','Secondary_Customer_Segment_Non_GC__c');
            fieldConfigToFieldNameMap.put('tertiary customer','tertiary_customer_segment__c');
            fieldConfigToFieldNameMap.put('tertiary customer segment non gc','tertiary_customer_segment_Non_GC__c');
            fieldConfigToFieldNameMap.put('tertiary practice area','Tertiary_Practice_Area__c');
            fieldConfigToFieldNameMap.put('tertiary practice area non gc','Tertiary_Practice_Area_Non_GC__c');
            fieldConfigToFieldNameMap.put('other customers','Other_Customers__c');
            fieldConfigToFieldNameMap.put('other customers non gc','Other_Customers_Non_GC__c');
            fieldConfigToFieldNameMap.put('have read partner program guide','Have_read_the_Partner_Program_Guide__c');
            fieldConfigToFieldNameMap.put('preferred dell distr partner','Preferred_Dell_Distribution_Partner__c');
            fieldConfigToFieldNameMap.put('resale revenue','Resale_Revenue__c');
            fieldConfigToFieldNameMap.put('active buying relationship agreement','Active_Buying_Relationship_Agreement__c');
            fieldConfigToFieldNameMap.put('export compliance agreed','Export_Compliance_Agreed__c');
            fieldConfigToFieldNameMap.put('requesting to support letters in latam','Requesting_To_Support_Letters_in_LATAM__c');             
            fieldConfigToFieldNameMap.put('deal registration & lead management enabled','Feature_Request_Deal_Registration__c');//CR 7823
            fieldConfigToFieldNameMap.put('partner finder enabled','Feature_Request_Partner_Finder__c');
            fieldConfigToFieldNameMap.put('agree dell reseller','Agree_Dell_Reseller__c');
            fieldConfigToFieldNameMap.put('agree technology partner program','Agree_Dell_ISV_Program__c');
            fieldConfigToFieldNameMap.put('agree to dell mft partner program','AGREE_to_Dell_MFT_Partner_Program__c');
            fieldConfigToFieldNameMap.put('agree oem terms and conditions','Agree_OEM_Terms_and_Conditions__c');
            fieldConfigToFieldNameMap.put('agree dell partner dist pro','Agree_Dell_Partner_Dist_Pro__c');
            fieldConfigToFieldNameMap.put('agree dell partner dist sup','Agree_Dell_Partner_Dist_Sup__c');
            fieldConfigToFieldNameMap.put('primary vertical market segment','Primary_Vertical_Market_Segment__c');
            fieldConfigToFieldNameMap.put('primary vertical market segment non gc','Primary_Vertical_Market_Segment_Non_GC__c');
            fieldConfigToFieldNameMap.put('secondary vertical market segment','Secondary_Vertical_Market_Segment__c');
            fieldConfigToFieldNameMap.put('secondary vertical market segment non gc','Secondary_Vertical_Market_Segment_Non_GC__c');
            fieldConfigToFieldNameMap.put('top 3 vendors','Top_3_Vendors__c');
            fieldConfigToFieldNameMap.put('top 3 vendors non gc','Top_3_Vendors_Non_GC__c');
            fieldConfigToFieldNameMap.put('application environments','Application_Environments__c');
            fieldConfigToFieldNameMap.put('organization industry certificate','Organization_Industry_Certificate__c');
            fieldConfigToFieldNameMap.put('organization industry certificate non gc','Organization_Industry_Certificate_Non_GC__c');
            fieldConfigToFieldNameMap.put('currently under investigation?','Ability_to_do_business_with_Federal__c');
            fieldConfigToFieldNameMap.put('individual principals','Individual_Principals__c');
            fieldConfigToFieldNameMap.put('position of influence or power?','Serving_as_high_ranking_officials__c');
            fieldConfigToFieldNameMap.put('comments','Comments__c'); 
            fieldConfigToFieldNameMap.put('source of information','Source_of_Information__c');
       

        //Service tab
            fieldConfigToFieldNameMap.put('service type','Service_Type__c');
            fieldConfigToFieldNameMap.put('service coverage','Service_Capability__c');
            fieldConfigToFieldNameMap.put('mode of service','Mode_Of_Service__c');
            fieldConfigToFieldNameMap.put('hardware warranty(break/fix support)','Hardware_warranty_Break_fix_support__c');
            fieldConfigToFieldNameMap.put('software technical support','Software_Technical_Support__c');
            fieldConfigToFieldNameMap.put('installation/deployment services','Installation_Deployment_Services__c');
            fieldConfigToFieldNameMap.put('installation/deployment services market','Installation_Deployment_Services_Market__c');
            fieldConfigToFieldNameMap.put('custom configuration/imaging','Custom_Configuration_Imaging__c');
            fieldConfigToFieldNameMap.put('data migration','Data_Migration__c');
            fieldConfigToFieldNameMap.put('asset recovery/resale/recycling','Asset_recovery_resale_recycling__c');
            fieldConfigToFieldNameMap.put('consulting','Consulting__c');
            fieldConfigToFieldNameMap.put('consulting market','Consulting_Market__c');
            fieldConfigToFieldNameMap.put('education/training','Education_Training__c');
            fieldConfigToFieldNameMap.put('managed deployment','Managed_Deployment__c');
            fieldConfigToFieldNameMap.put('custom enterprise/data center services','Custom_enterprise_data_center_services__c');
            fieldConfigToFieldNameMap.put('deliver to your customer','Deliver_to_your_C__c');
            fieldConfigToFieldNameMap.put('resell to your customer','Resell_to_your_Customer__c');
            fieldConfigToFieldNameMap.put('dell service tools used','Dell_Service_Tools_Used__c');            
            fieldConfigToFieldNameMap.put('sales sponser name','Sales_Sponser_Name__c');
            fieldConfigToFieldNameMap.put('sales sponsor email','Sales_Sponsor_Email__c');
            fieldConfigToFieldNameMap.put('sales sponsor telephone','Sales_Sponsor_Telephone__c');                
            fieldConfigToFieldNameMap.put('marketing contact name','Marketing_Contact_Name__c');
            fieldConfigToFieldNameMap.put('marketing contact telephone','Marketing_Contact_Telephone__c');
            fieldConfigToFieldNameMap.put('marketing contact title','Marketing_Contact_Title__c');
            fieldConfigToFieldNameMap.put('marketing contact email','Marketing_Contact_Email__c');                
            fieldConfigToFieldNameMap.put('sale report provider contact name','Sale_Report_Provider_Contact_Name__c');
            fieldConfigToFieldNameMap.put('sale report provider contact telephone','Sale_Report_Provider_Contact_Telephone__c');
            fieldConfigToFieldNameMap.put('sale report provider contact title','Sale_Report_Provider_Contact_Title__c');
            fieldConfigToFieldNameMap.put('sale report provider contact email','Sale_Report_Provider_Contact_Email__c');                
            fieldConfigToFieldNameMap.put('service offering contact name','Service_Offering_Contact_Name__c');
            fieldConfigToFieldNameMap.put('service offering contact telephone','Service_Offering_Contact_Telephone__c');
            fieldConfigToFieldNameMap.put('service offering contact title','Service_Offering_Contact_Title__c');
            fieldConfigToFieldNameMap.put('service offering contact email','Service_Offering_Contact_Email__c');                
            fieldConfigToFieldNameMap.put('existing contractual relationship','existing_contractual_relationship__c');
            fieldConfigToFieldNameMap.put('csp/msp organization require emc storage','CSP_MSP_Organization_require_EMC_Storage__c');
            fieldConfigToFieldNameMap.put('dell services portfolio','Dell_Services_Portfolio__c');
            fieldConfigToFieldNameMap.put('intrested in learning dell services?','Intrested_in_learning_Dell_Services__c');
            fieldConfigToFieldNameMap.put('services lead first name','Services_Lead_First_Name__c');
            fieldConfigToFieldNameMap.put('services lead last name','Services_Lead_Last_Name__c');
            fieldConfigToFieldNameMap.put('services lead job title','Service_Lead_Job_Title__c');
            fieldConfigToFieldNameMap.put('services lead phone number','Services_Lead_Phone_Number__c');
            fieldConfigToFieldNameMap.put('services lead email','Services_Lead_Email__c');
              
         List<Partner_Type_Field_Configuration__c> fieldConfigList = new List<Partner_Type_Field_Configuration__c>();
         fieldConfigList =[SELECT Field_Name__c, Tab_Name__c, Is_Required__c, Is_Enabled__c FROM Partner_Type_Field_Configuration__c
                                WHERE Partner_Type__r.Country__r.name = :country AND Partner_Type__r.Name = :selectedPartnerType];
                system.debug('****fieldconfigList****' +fieldConfigList);
        
           fieldConfigMap = new Map<String, Partner_Type_Field_Configuration__c>();
            for (Partner_Type_Field_Configuration__c fieldConfig : fieldConfigList)
            {
             if (fieldConfigToFieldNameMap.containsKey(StringUtils.lowerCase(fieldConfig.Field_Name__c))) {
                    fieldConfigMap.put(fieldConfigToFieldNameMap.get(StringUtils.lowerCase(fieldConfig.Field_Name__c)), fieldConfig);
                }
            }

        
          //Update special fields
             if (getEnabled('Job_Category__c')){
                updateFieldConfigMap('Contact', 'Job_Title__c', true, getRequired('Job_Category__c'));
            }
            updateFieldConfigMap('Contact', 'Other_Job_Category__c', true, false);
            
            if (getEnabled('Job_Category_Non_GC__c')){
                updateFieldConfigMap('Contact', 'Job_Title_Non_GC__c', true, getRequired('Job_Category_Non_GC__c'));
            }
            updateFieldConfigMap('Contact', 'Other_Job_Category__c', true, false);

           if (getEnabled('Primary_Contact_Job_Category__c')){
                updateFieldConfigMap('Contact', 'Primary_Contact_Job_Title__c', true, getRequired('Primary_Contact_Job_Category__c'));
            }
            updateFieldConfigMap('Contact', 'Primary_Contact_Other_Job_Category__c',true , false);

        
           if (getEnabled('Currently_Selling_Dell__c')){
                updateFieldConfigMap('Segment', 'Dell_Revenue_Percent__c', true,true);
            }
            //Required fields to create lead record            
            updateFieldConfigMap('Contact', 'Last_Name__c', true, true);
            updateFieldConfigMap('Contact', 'Email__c', true, true);       
            updateFieldConfigMap('Contact', 'Company__c', true, true);  
        
          country__c countryList = [select Code__c, Region__c from country__c where code__c = :countryMap.get(country)];
        
            for(PartnerRegistrationFormTabHelper aTab : tabs){
                 for(PartnerRegistrationFormFieldHelper field : aTab.fields){
                     
                   if (field.fieldName == 'Newsletter_Opt_In__c') {
                            field.countryCode = countryMap.get(country); 
                            field.optInApjLatam = countryList.Region__c; 
                            System.debug('newsletter field2 '+field.countryCode);
                            
                            if(countryMap.get(country) == 'ca') {                              
                                field.labelValue = getTranslatedLabel('Newsletter_Confirmation') == null ? Label.Newsletter_Confirmation:getTranslatedLabel('Newsletter_Confirmation');
                                //field.labelValue = Label.Newsletter_Confirmation; 
                            }
                            else if(countryMap.get(country) == 'de' || countryMap.get(country) == 'at' || countryMap.get(country) == 'ch'){
                                field.labelValue = getTranslatedLabel('Partner_Registration_01') == null ?  Label.Partner_Registration_01:getTranslatedLabel('Partner_Registration_01');                               
                                string strLabel = field.labelValue.replace('{!Country}',countryMap.get(country)).replace('{!lang}',language.split('__c')[0]);
                                field.labelValue = strLabel;
                            }
                            else if(field.optInApjLatam == 'Apj' || field.optInApjLatam == 'Latam'){
                                String lvalue;
                                lvalue = getTranslatedLabel('Partner_Registration_APJ_02') == null ?  Label.Partner_Registration_APJ_02:getTranslatedLabel('Partner_Registration_APJ_02');                               
                             //   lvalue=Label.Partner_Registration_APJ_02;
                                field.labelValue =lvalue;
                                string strLabel = field.labelValue.replace('{!Country}',countryMap.get(country)).replace('{!lang}',language.split('__c')[0]);
                                field.labelValue = strLabel;
                            }
                            else if(countryMap.get(country) == 'us') {  
                              field.labelValue = getTranslatedLabel('Partner_Registration_US') == null ? Label.Partner_Registration_US:getTranslatedLabel('Partner_Registration_US');
                             // field.labelValue = Label.Partner_Registration_US;                                
                            }
                            else {
                                field.labelValue = getTranslatedLabel('receive_newsletter_02') == null ? Label.receive_newsletter_02:getTranslatedLabel('receive_newsletter_02');
                                //field.labelValue = Label.receive_newsletter_02;
                                string strLabel = field.labelValue.replace('{!Country}',countryMap.get(country)).replace('{!lang}',language.split('__c')[0]);
                                system.debug('URL>>>>'+strLabel);
                                field.labelValue = strLabel;   
                                field.optInRestOfEMEA = countryList.Region__c;  
                            }                      
                        }
                           
                  field.updateConfig(getEnabled(field.fieldName), getRequired(field.fieldName));                     
                 }
            }
    }
    
public static string getTranslatedLabel(string strMasterLabelName){
        string translatedLabel;
        list<Onboarding_Translations__c> listTranslatedValue = new list<Onboarding_Translations__c>();
        try{
            String query = 'select '
                + language
                + ' from Onboarding_Translations__c where Name = \'' + strMasterLabelName + '\' limit 1';
            
            listTranslatedValue = Database.query(query);
            system.debug('Translated Value****' +listTranslatedValue[0].get(language));
            
            if(listTranslatedValue[0].get(language) != ''){
                return string.valueof(listTranslatedValue[0].get(language));
            }else{
                return null;
            }
        }catch(exception ex){
            system.debug('exception occured in getTranslatedLabel method' +ex.getMessage());
            return null;
        }
    }
   

@AuraEnabled
  public static termsAndConditionsWrapper doUpdateCountryDependentFields(string countryFromCmpnt){    
        Set<String> fieldsOnCountryToSelect = new Set<String>();
       
        fieldsOnCountryToSelect.add('DELL_ONLINE_TERMS_CONDITIONS_URL__C');      
        fieldsOnCountryToSelect.add('Dell_ISV_Terms_Conditions_URL__c'); 
        fieldsOnCountryToSelect.add('Dell_OEM_Technology_Partner_T_C_URL__c'); 
        fieldsOnCountryToSelect.add('Dell_MFT_Partner_URL__c'); 
        fieldsOnCountryToSelect.add('Distributor_Partner_Program_TC_URL__c');
        
        String query = 'select '
            + StringUtils.joinSet(fieldsOnCountryToSelect, ',')
            + ' from Country__c where name = \'' + countryFromCmpnt + '\' limit 1';
      
        selectedCountryRecord = Database.query(query);
      
        system.debug('selected Country ='+selectedCountryRecord);
        system.debug('country ='+countryFromCmpnt);
      
        string distributorppTCUL = selectedCountryRecord == null ? '' :selectedCountryRecord.Distributor_Partner_Program_TC_URL__c;
        string termConditionURL = selectedCountryRecord == null ? '' :selectedCountryRecord.DELL_ONLINE_TERMS_CONDITIONS_URL__C;
        string ISVTermsAndConditionsURL = selectedCountryRecord== null ? '' :selectedCountryRecord.Dell_ISV_Terms_Conditions_URL__c; 
        string MFTTermsAndConditionsURL = selectedCountryRecord== null ? '' :selectedCountryRecord.Dell_MFT_Partner_URL__c;
        string OEMTermsAndConditionsURL = selectedCountryRecord == null ? '' :selectedCountryRecord.Dell_OEM_Technology_Partner_T_C_URL__c;
      
        System.debug('distributorppTCUL >>'+distributorppTCUL);
        System.debug('termConditionURL >>'+termConditionURL);
        System.debug('ISVTermsAndConditionsURL >>'+ISVTermsAndConditionsURL);
        System.debug('MFTTermsAndConditionsURL >>'+MFTTermsAndConditionsURL);
        System.debug('OEMTermsAndConditionsURL>>'+OEMTermsAndConditionsURL);
        
        termsAndConditionsWrapper wrapper = new termsAndConditionsWrapper();
        wrapper.distributorppTCUL  = distributorppTCUL;
        wrapper.termConditionURL = termConditionURL;
        wrapper.ISVTermsAndConditionsURL = ISVTermsAndConditionsURL;
        wrapper.MFTTermsAndConditionsURL = MFTTermsAndConditionsURL;
        wrapper.OEMTermsAndConditionsURL = OEMTermsAndConditionsURL;
        
        return wrapper;
  
    }
    
    
  public class termsAndConditionsWrapper{
   @AuraEnabled
   public string distributorppTCUL;
    @AuraEnabled
   public string termConditionURL;
    @AuraEnabled
   public string ISVTermsAndConditionsURL;
    @AuraEnabled
   public string MFTTermsAndConditionsURL;
   @AuraEnabled
   public string OEMTermsAndConditionsURL;
}
 
  public static void updateFieldConfigMap(String tabName, String fieldName, Boolean isRequired){
        Partner_Type_Field_Configuration__c fieldConfig = new Partner_Type_Field_Configuration__c();
        fieldConfig.Tab_Name__c = tabName;
        fieldConfig.Field_Name__c = fieldName;

        if (fieldConfigMap.containsKey(fieldName)){
            fieldConfig = fieldConfigMap.get(fieldName);
        }
        fieldConfig.Is_Required__c = isRequired;

        fieldConfigMap.put(fieldName,fieldConfig);
    }

    public static void updateFieldConfigMap(String tabName, String fieldName, Boolean isEnabled, Boolean isRequired){
        Partner_Type_Field_Configuration__c fieldConfig = new Partner_Type_Field_Configuration__c();
        fieldConfig.Tab_Name__c = tabName;
        fieldConfig.Field_Name__c = fieldName;

        if (fieldConfigMap.containsKey(fieldName)){
            fieldConfig = fieldConfigMap.get(fieldName);
        }
        fieldConfig.Is_Enabled__c = isEnabled;
        fieldConfig.Is_Required__c = isRequired;

        fieldConfigMap.put(fieldName,fieldConfig);
    }
    
    
     public static Boolean getEnabled(string field){
        if (fieldConfigMap != null && fieldConfigMap.containsKey(field)){
            return fieldConfigMap.get(field).Is_Enabled__c;
        }
        return false;
    }

    public static Boolean getRequired(string field){
        if (fieldConfigMap != null && fieldConfigMap.containsKey(field)){
            return fieldConfigMap.get(field).Is_Required__c;
        }
        return false;
    }
    
    @AuraEnabled
    public static string fetchRegion(String selectedCountry){
         country = selectedCountry;
         return UserRegion;
    }
    
      @AuraEnabled
    public static map<string,string> fetchPartnertypes(String selectedCountry,boolean isInviteLink){
         partnerTypeOption = getPartnerTypeOptions(selectedCountry,isInviteLink);
         return partnerTypeOption;  
    }
    
    
     public class tabLabelsAndCountryListWrapper extends PRformtabLabelsAndCountryList{
        public tabLabelsAndCountryListWrapper(List<String> tabLabels,Map<string,id> countryList, Map<string,string> countryNameToCodemap){
            super(tabLabels,countryList,countryNameToCodemap);
          }
     } 
   
     public class PartnerSelectionTab extends PartnerRegistrationFormTabHelper{
        public PartnerSelectionTab(String tabLabel, String name){
            super(tabLabel,name);
          }
         public override void decorate(List<PartnerRegistrationFormFieldHelper> fields){        
             fields.add(new JoinDellPartnerDirectProgramInputField());
             fields.add(new SelectyourpreferredDellDistributorInputField());
             fields.add(new SponsorDistrubutorInputField()); 
             fields.add(new SelectYourSecondaryBusiness()); 
        }
       }
    
    
    
     public class JoinDellPartnerDirectProgramInputField extends PartnerRegistrationFormFieldHelper{
        public JoinDellPartnerDirectProgramInputField(){
            super(Label.Join_Dell_PartnerDirect_Program, 'MULTIPICKLIST', 'Join_Dell_PartnerDirect_Program__c',Partner_Request__c.Join_Dell_PartnerDirect_Program__c.getDescribe());
            }
    }
    
     public class SelectyourpreferredDellDistributorInputField extends PartnerRegistrationFormFieldHelper{
        public SelectyourpreferredDellDistributorInputField(){
            super(Label.Select_your_preferred_Dell_Distributor, 'PICKLIST', 'Select_your_preferred_Dell_Distributor__c',Vfcntrl_PartnerRegistrationForm.getPreferredDellDistributorOptions(country));
            }
    }
     public class SponsorDistrubutorInputField extends PartnerRegistrationFormFieldHelper{
        public SponsorDistrubutorInputField(){
            super(Label.Sponsoring_Distributor, 'PICKLIST', 'Sponsoring_Distributor__c',Vfcntrl_PartnerRegistrationForm.getSponsoringDistributorOptions(country));
            }
    }
     public class SelectYourSecondaryBusiness extends PartnerRegistrationFormFieldHelper{
        public SelectYourSecondaryBusiness(){
            super(Label.select_your_secondary_business_type, 'PICKLIST', 'select_your_secondary_business_type__c',Partner_Request__c.select_your_secondary_business_type__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
    }
     public class ContactTab extends PartnerRegistrationFormTabHelper{
        public ContactTab(String tabLabel, String name){
            super(tabLabel,name);
       }
        public override void decorate(List<PartnerRegistrationFormFieldHelper> fields){   
            fields.add(new SalutationInputField());
            fields.add(new FirstNameInputField());
            fields.add(new LastNameInputField());
            fields.add(new JobCategoryInputField());
            fields.add(new JobCategoryNonGCInputField());
            fields.add(new JobTitleInputField());
            fields.add(new JobTitleNonGCInputField());
            fields.add(new OtherJobCategoryInputField());
            fields.add(new AddressLine1InputField());
            fields.add(new AddressLine2InputField());
            fields.add(new AddressLine3InputField());
            fields.add(new CityInputField());
            fields.add(new StateProvinceInputField());
            fields.add(new PostalCodeInputField());
            fields.add(new PhoneInputField());           
            fields.add(new MobileInputField());
            fields.add(new FaxInputField());
            fields.add(new EmailInputField());
            fields.add(new NewsletterOptinInputField());
            fields.add(new FinancingOptionsInputfield());
            fields.add(new FinancingOptionsNonGCInputfield());
            fields.add(new PrimaryContactAlignedInputField());
            fields.add(new PrimaryContactFirstNameInputField());
            fields.add(new PrimaryContactLastNameInputField());
            fields.add(new PrimaryContactJobCategoryInputField());
            fields.add(new PrimaryContactJobTitleInputField());
            fields.add(new PrimaryContactOtherJobCategoryInputField());
            fields.add(new PrimaryContactPhoneInputField());
            fields.add(new PrimaryContactMobileInputField());
            fields.add(new PrimaryContactEmailInputField());
            fields.add(new PrimaryContactAddress1InputField());
            fields.add(new PrimaryContactAddress2InputField());
            fields.add(new PrimaryContactAddress3InputField());
            fields.add(new PrimaryContactCityInputField());
            fields.add(new PrimaryContactStateProvinceInputField());
            fields.add(new PrimaryContactPostalCodeInputField());
        }
    }
    
    public class SalutationInputField extends PartnerRegistrationFormFieldHelper{
        public SalutationInputField(){
            super(Label.salutation, 'PICKLIST', 'Salutation__c',Partner_Request__c.Salutation__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
       
    }

    public class FirstNameInputField extends PartnerRegistrationFormFieldHelper{
        public FirstNameInputField(){ 
            super(Label.first_name, 'STRING', 'First_Name__c'); 
        }
    }

    public class LastNameInputField extends PartnerRegistrationFormFieldHelper{
        public LastNameInputField(){ 
            super(Label.last_name, 'STRING', 'Last_Name__c'); 
        }
    }

    public class JobCategoryInputField extends PartnerRegistrationFormFieldHelper{
        public JobCategoryInputField(){
            super(Label.job_category, 'PICKLIST', 'Job_Category__c',Partner_Request__c.Job_Category__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }       
    }
    
    public class FinancingOptionsNonGCInputfield extends PartnerRegistrationFormFieldHelper{
        public FinancingOptionsNonGCInputfield(){
            super(Label.Financing_Options, 'PICKLIST', 'Financing_Options_Non_GC__c',Partner_Request__c.Financing_Options_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
    }
    
   public class PrimaryContactJobCategoryInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactJobCategoryInputField(){
            super(Label.Primary_Contact_Job_Category, 'PICKLIST', 'Primary_Contact_Job_Category__c',Partner_Request__c.Primary_Contact_Job_Category__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
    }
   
    public class JobTitleInputField extends PartnerRegistrationFormFieldHelper{
        public JobTitleInputField(){
            super(Label.job_title, 'PICKLIST', 'Job_Title__c',Partner_Request__c.Job_Title__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
    }
    
    public class PrimaryContactJobTitleInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactJobTitleInputField(){
            super(Label.Primary_Contact_Job_Title, 'PICKLIST', 'Primary_Contact_Job_Title__c',Partner_Request__c.Primary_Contact_Job_Title__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
    } 
    
    public class JobCategoryNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public JobCategoryNonGCInputField(){
            super(Label.job_category, 'PICKLIST', 'Job_Category_Non_GC__c',Partner_Request__c.Job_Category_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
    }
    
    public class JobTitleNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public JobTitleNonGCInputField(){
            super(Label.job_title, 'PICKLIST', 'Job_Title_Non_GC__c',Partner_Request__c.Job_Title_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
    }

    public class PrimaryContactOtherJobCategoryInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactOtherJobCategoryInputField(){ 
            super(Label.Primary_Contact_Other_Job_Category, 'STRING', 'Primary_Contact_Other_Job_Category__c');
        }
    }   
    
    public class PhoneInputField extends PartnerRegistrationFormFieldHelper{
        public PhoneInputField(){ 
            super(Label.Phone_Number_Non_china, 'STRING', 'Phone__c');
        }    
    }
     public class MobileInputField extends PartnerRegistrationFormFieldHelper{
        public MobileInputField(){
            super(Label.mobile_phone, 'STRING', 'Mobile__c'); 
        }
    }
    
    public class EmailInputField extends PartnerRegistrationFormFieldHelper{
        public EmailInputField(){ 
            super(Label.email, 'STRING', 'Email__c'); 
        }
    }
    
    public class OtherJobCategoryInputField extends PartnerRegistrationFormFieldHelper{
        public OtherJobCategoryInputField(){ 
            super(Label.other_job_category, 'STRING', 'Other_Job_Category__c'); 
        }
    }

    public class NewsletterOptinInputField extends PartnerRegistrationFormFieldHelper{
        public NewsletterOptinInputField(){ 
            super(Label.receive_newsletter, 'BOOLEAN', 'Newsletter_Opt_In__c');
        }
    }
   

    public class AddressLine1InputField extends PartnerRegistrationFormFieldHelper{
        public AddressLine1InputField(){ 
            super(Label.address_1, 'STRING', 'Address_Line_1__c'); 
        }
    }

    public class AddressLine2InputField extends PartnerRegistrationFormFieldHelper{
        public AddressLine2InputField(){ 
            super(Label.address_2, 'STRING', 'Address_Line_2__c');
        }
    }

    public class AddressLine3InputField extends PartnerRegistrationFormFieldHelper{
        public AddressLine3InputField(){ 
            super(Label.address_3, 'STRING', 'Address_Line_3__c'); 
        }
    }

    public class CityInputField extends PartnerRegistrationFormFieldHelper{
        public CityInputField(){ 
            super(Label.city, 'STRING', 'City__c'); 
        }
    }

    public class StateProvinceInputField extends PartnerRegistrationFormFieldHelper{
        public StateProvinceInputField(){
            super(Label.state_province, 'STRING', 'State__c');
        }
    }

    public class PostalCodeInputField extends PartnerRegistrationFormFieldHelper{
        public PostalCodeInputField(){ 
            super(Label.postal_code, 'STRING', 'Postal_Code__c');
        }
    }

      public class PrimaryContactAlignedInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactAlignedInputField(){
            super(Label.Primary_Contact_Aligned, 'PICKLIST', 'Primary_Contact_Aligned__c',Partner_Request__c.Primary_Contact_Aligned__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
   
    public class PrimaryContactFirstNameInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactFirstNameInputField(){ 
            super(Label.Primary_Contact_First_Name, 'STRING', 'Primary_Contact_First_Name__c');
        }
    }

    public class PrimaryContactLastNameInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactLastNameInputField(){ 
            super(Label.Primary_Contact_Last_Name, 'STRING', 'Primary_Contact_Last_Name__c');
        }
    }

   public class PrimaryContactPhoneInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactPhoneInputField(){
            super(Label.Primary_Contact_Phone_Number, 'STRING', 'Primary_Contact_Phone_Number__c'); 
        }
    }

    public class PrimaryContactMobileInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactMobileInputField(){ 
            super(Label.Primary_Contact_Mobile_Phone, 'STRING', 'Primary_Contact_Mobile_Number__c'); 
        }
    }

    public class PrimaryContactEmailInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactEmailInputField(){ 
            super(Label.Primary_Contact_Email, 'STRING', 'Primary_Contact_Email__c');
        }
    }
   
      public class PrimaryContactAddress1InputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactAddress1InputField(){
            super(Label.Primary_Contact_Address_1, 'STRING', 'Primary_Contact_Address_1__c'); 
        }
    }

    public class PrimaryContactAddress2InputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactAddress2InputField(){ 
            super(Label.Primary_Contact_Address_2, 'STRING', 'Primary_Contact_Address_2__c');
        }
    }

    public class PrimaryContactAddress3InputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactAddress3InputField(){
            super(Label.Primary_Contact_Address_3, 'STRING', 'Primary_Contact_Address_3__c'); 
        }
    }

    public class PrimaryContactCityInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactCityInputField(){ 
            super(Label.Primary_Contact_City, 'STRING', 'Primary_Contact_City__c'); 
        }
    }

    public class PrimaryContactStateProvinceInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactStateProvinceInputField(){
            super(Label.Primary_Contact_State_Province, 'STRING', 'Primary_Contact_State_Province__c'); 
        }
    }

    public class PrimaryContactPostalCodeInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryContactPostalCodeInputField(){ 
            super(Label.Primary_Contact_Postal_Code, 'STRING', 'Primary_Contact_Postal_Code__c'); 
        }
    }   

    public class FinancingOptionsInputfield extends PartnerRegistrationFormFieldHelper{
        public FinancingOptionsInputfield(){
            super(Label.Financing_Options, 'PICKLIST', 'Financing_Options__c',Partner_Request__c.Financing_Options__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }       
    }
     public class FaxInputField extends PartnerRegistrationFormFieldHelper{
        public FaxInputField(){ 
            super(Label.fax_number, 'STRING', 'Fax__c'); 
        }
    }
    
   /*   @AuraEnabled
      public static List<String> getDependentOptionsImpl(String objName, String contrfieldName, 
                                                                       String depfieldName, String jobcategory){
        
        String objectName = objName.toLowerCase();
        String controllingField = contrfieldName.toLowerCase();
        String dependentField = depfieldName.toLowerCase();        
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
        }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            //return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            //return objResults;     
        }
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
               Schema.PicklistEntry depentry = depEntries[dependentIndex];
               objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        objEntries = null;
        objJsonEntries = null;
         List<String> jobTtlList = objResults.get(jobcategory);
        return jobTtlList;
    }*/
    
       //Added by Mounika starts here
        @AuraEnabled
        public static list<picklistData> getDependentOptionsImpl(String objName, String contrfieldName, 
                                                                       String depfieldName, String jobcategory){
          String LanguageIs = Vfcntrl_PartnerRegistrationForm.getLanguage();
          list<Picklist_Translations__mdt> PicklistValues = [select id,developerName,MasterLabel, cs__c,da__c,de__c,el__c,
                                                           en_us__c,es__c,es_mx__c,fi__c,hu__c,fr__c,it__c,iw__c,ja__c,ko__c,nl__c,no__c,pl__c,pt_br__c,
                                                            ro__c,ru__c,sk__c,sv__c,th__c,tr__c,zh_cn__c,zh_tw__c from Picklist_Translations__mdt where PicklistName__c='Jobtitle__c'];
       map<String,String> values = new map<String,String>(); 
        for(Picklist_Translations__mdt each:PicklistValues){
            if(null!=each.get(LanguageIs) && '' !=each.get(LanguageIs)){
            values.put(each.MasterLabel,''+each.get(LanguageIs));
            }else{
                 values.put(each.MasterLabel,each.MasterLabel);
            }
            
        }
        String objectName = objName.toLowerCase();
        String controllingField = contrfieldName.toLowerCase();
        String dependentField = depfieldName.toLowerCase();        
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
        }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            //return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            //return objResults;     
        }
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getValue();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
               Schema.PicklistEntry depentry = depEntries[dependentIndex];
               objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getValue();
                objResults.get(contrLabel).add(objJson.value);
            }
        }
        objEntries = null;
        objJsonEntries = null;
         List<String> jobTtlList = objResults.get(jobcategory);
        list<picklistData> FinalList = new list<picklistData>();
            for(String eachCat:jobTtlList){
                System.debug('>>>>>>>>>>>>>>>> eachCat '+eachCat);
                System.debug('>>>>>>> '+values + ' >>>>>>>>>>>>> '+eachCat.replace(' ','_'));
                if(null !=values.get(eachCat)){
                                   FinalList.add(new picklistData(eachCat,values.get(eachCat))); 
                }else{
                     FinalList.add(new picklistData(eachCat,eachCat));
                }
                                                 
               }                                                           
        return FinalList;
    }
    class picklistData{
        @AuraEnabled
        public String KeyIs{get;set;}
        @AuraEnabled
         public String ValueIs{get;set;}
        public picklistData(String KeyIs,String ValueIs){
            this.KeyIs = KeyIs;
            this.ValueIs = ValueIs;
            
        }
    }
    
  public class BitSet{
    public Map<String,Integer> alphaNumCharCodes {get;set;}
    public Map<String, Integer> base64CharCodes {get;set;}
    
    public BitSet(){
        LoadCharCodes();
    }
    
    //Method loads the character codes for all letters
    @TestVisible private void LoadCharCodes(){
        alphaNumCharCodes = new Map<String,Integer>{
            'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
            'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
            'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90    
        };
        base64CharCodes = new Map<String, Integer>();
        //all lower cases
        Set<String> pUpperCase = alphaNumCharCodes.keySet();
        for(String pKey : pUpperCase){
            //the difference between upper case and lower case is 32
            alphaNumCharCodes.put(pKey.toLowerCase(),alphaNumCharCodes.get(pKey)+32);
            //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
            base64CharCodes.put(pKey,alphaNumCharCodes.get(pKey) - 65);
            base64CharCodes.put(pKey.toLowerCase(),alphaNumCharCodes.get(pKey) - (65) + 26);
        }
        //numerics
        for (Integer i=0; i<=9; i++){
            alphaNumCharCodes.put(string.valueOf(i),i+48);
            //base 64 numeric starts from 52
            base64CharCodes.put(string.valueOf(i), i + 52);
        }
    }
        
      public List<Integer> testBits(String pValidFor,List<Integer> nList){
            List<Integer> results = new List<Integer>();
            List<Integer> pBytes = new List<Integer>();
            Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
            Integer pFullValue = 0;
            if (bytesBeingUsed <= 1)
                return results;
            for(Integer i=0;i<pValidFor.length();i++){
                pBytes.Add((base64CharCodes.get((pValidFor.Substring(i, i+1)))));
            }   
            for (Integer i = 0; i < pBytes.size(); i++)
            {
                Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value
                pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
            }
            
            Integer bit;
            Integer targetOctet;
            Integer shiftBits;
            Integer tBitVal;
            Integer n;
            Integer nListSize = nList.size();
            for(Integer i=0; i<nListSize; i++){
                n = nList[i];
                bit = 7 - (Math.mod(n,8)); 
                targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed); 
                shiftBits = (targetOctet * 8) + bit;
                tBitVal = ((Integer)(2 << (shiftBits-1)) & pFullValue) >> shiftBits;
                if (tBitVal==1)
                    results.add(n);
            }
            return results;
        }    
    }
    
    public class PicklistEntryWrapper{
    
    public PicklistEntryWrapper(){            
    }
    public String active {get;set;}
    public String defaultValue {get;set;}
    public String label {get;set;}
    public String value {get;set;}
    public String validFor {get;set;}
}
    
      public class validateEmailDomainWrapper{
          @AuraEnabled
          public string result;
          @AuraEnabled
          public string matchingAccName;
           @AuraEnabled
          public string matchingAccId;
           @AuraEnabled
          public string recordTypeID;
           @AuraEnabled
          public string matchAccId;
           @AuraEnabled
          public string userDomain;
          @AuraEnabled              
          public boolean Exclude;
          @AuraEnabled              
          public boolean restrictUser;
          
      }
    
    
    @AuraEnabled
    public static validateEmailDomainWrapper ValidateEmailDomain(String email, String selPartnerType, String selCountry, String secondaryPartnerTypes){
     list<user> partnerAdminList = new list<user>();
        System.debug('s****  '+secondaryPartnerTypes);
        String ExcludeFor;
         validateEmailDomainWrapper validateDomainWrapper = new validateEmailDomainWrapper();
         String selectedCountryCode ;
       for(Country__c selCountryCode : [SELECT name, code__c,Region__c FROM Country__c WHERE Name =: selCountry ] )
        {
            selectedCountryCode = selCountryCode.code__c;
               System.debug('selectedCountryCode****  '+selectedCountryCode);
            
        }
        system.debug('===>>'+Label.GCCountryCodes.split(';').contains(selectedCountryCode));
        if(Label.GCCountryCodes.split(';').contains(selectedCountryCode) && ( (selectedCountryCode!= 'SG' || selectedCountryCode!= 'MY') && secondaryPartnerTypes != 'Consumer Partner')){
            ExcludeFor='GC countries';
        }else if( (selectedCountryCode == 'SG' || selectedCountryCode == 'MY') && secondaryPartnerTypes == 'Consumer Partner'){
            ExcludeFor='GC countries'; 
        }else{
            ExcludeFor='Non GC countries';
        }
       list<string> domain = email.split('@');
         validateDomainWrapper.Exclude = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(domain[1]);
          if (validateDomainWrapper.Exclude && ExcludeFor=='Non GC countries'){
              validateDomainWrapper.restrictUser  = True;
          }else{
             if (validateDomainWrapper.Exclude){
                   validateDomainWrapper.result  = 'move_next';
             }else{
                   Account matchingAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(selectedCountryCode, domain[1],selPartnerType,secondaryPartnerTypes);
                   System.debug('matchingAccount****'+ matchingAccount);
       
                  if (matchingAccount == null || matchingAccount.Partner_Primary_Customer__c == 'Federal Government'){
                        validateDomainWrapper.result  = 'move_next';
                    }
                 else{
                        partnerAdminList = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(matchingAccount.Master_Group_Id__c, domain[1]);
                            System.debug('partnerAdminList!!!'+partnerAdminList);
                        if(partnerAdminList != null && partnerAdminList.size()>0) {
                          validateDomainWrapper.result   = 'move_to_finaltab';
                          validateDomainWrapper.matchAccId = matchingAccount.Master_Group_Id__c;
                          validateDomainWrapper.userDomain = domain[1]; 
                           system.debug('***matchAccId : ' + validateDomainWrapper.matchAccId);
                           system.debug('***userDomain : ' + validateDomainWrapper.userDomain);
                       }
                        else{
                            validateDomainWrapper.matchingAccName = matchingAccount.Name + '-' + matchingAccount.Id;
                            validateDomainWrapper.matchingAccId = matchingAccount.Id;
                            validateDomainWrapper.recordTypeID = IdLookupUtils.getRecordTypeId('New Partner Admin', 'Partner_Request__c', true);
                            validateDomainWrapper.result = 'move_next';
                   }        
               }
            }
          }
         return validateDomainWrapper;
    }   
   // Added by wassim START
     public class SegmentTab extends PartnerRegistrationFormTabHelper{
        public SegmentTab(String tabLabel, String name){
            super(tabLabel,name);
        }
        public override void decorate(List<PartnerRegistrationFormFieldHelper> fields){
            fields.add(new CountriesDoingBusinessInInputField());
            fields.add(new TotalEmployeesInputField());
            fields.add(new PercentTechnicalInputField());
            fields.add(new AnnualRevenueInputField());
            fields.add(new SellVCEProductsServicesInputField());
            fields.add(new CurrentlySellingInputField());
            fields.add(new DellRevenuePercentInputField());
            fields.add(new PrimaryRoutesToMarketInputField());
            fields.add(new AreaOfInterestInputField());
            fields.add(new AreaOfInterestNonGCInputField());
            fields.add(new ProductFocusInputField());
            fields.add(new ProductFocusNonGCInputField());
            fields.add(new SizeofCustomerBaseInputField());
            fields.add(new PrimaryCustomerInputField());
            fields.add(new PrimaryCustomerNonGCInputField());
            fields.add(new SecondaryCustomerInputField());
            fields.add(new SecondaryCustomerSegmentNonGCInputField());
            fields.add(new PrimaryVerticalMarketSegmentInputField());
            fields.add(new PrimaryVerticalMarketSegmentNonGCInputField());
            fields.add(new SecondaryVerticalMarketSegmentInputField());
            fields.add(new SecondaryVerticalMarketSegmentNonGCInputField());
            fields.add(new TertiaryCustomerSegmentInputField());
            fields.add(new TertiaryCustomerSegmentNonGCInputField());
            fields.add(new TertiaryPracticeAreaInputField());
            fields.add(new TertiaryPracticeAreaNonGCInputField());
            fields.add(new OtherCustomersInputField());
            fields.add(new OtherCustomersNonGCInputField());
            fields.add(new HaveReadPartnerProgramGuideInputField());            
            fields.add(new PreferredDistributionPartnerInputField());
            fields.add(new ResaleRevenueInputField());
            fields.add(new Top3VendorsInputField());
            fields.add(new Top3VendorsNonGCInputField());
            fields.add(new ApplicationEnvironmentsInputField());
            fields.add(new OrganizationIndustryCertificateInputField());
            fields.add(new OrganizationIndustryCertificateNonGCInputField());
            fields.add(new AgreeToExportComplianceInputField());
            fields.add(new RequestingToSupportLettersinLATAMInputField());    
            fields.add(new EnableDealRegistrationInputField());
            fields.add(new EnablePartnerFinderInputField());
            fields.add(new AgreeOEMTermsandConditionsInputField());
            fields.add(new ISVTermsAndConditionsInputField());
            fields.add(new MFTTermsAndConditionsInputField());
            fields.add(new ResellerTermsAndConditionsInputField());            
            fields.add(new BothISVResellerTermsAndConditionsInputField());
            fields.add(new DistProgramTermsAndConditionsInputField());           
            fields.add(new DistSupplierTermsAndConditionsInputField());
            fields.add(new ActiveBuyingRelationshipAgreement());
            fields.add(new AbilitytodoBusinesswithFederalInputField());
            fields.add(new IndividualPrincipalsInputField());
            fields.add(new ServingashighrankingofficialsInputField());
            fields.add(new CommentsInputField()); 
            fields.add(new SourceOfInfoInputField()); 
            
        }
    }
    // End's here
    // Added by Bharadwaj START
     public class FocusTab extends PartnerRegistrationFormTabHelper{
        public FocusTab(String tabLabel, String name){
            super(tabLabel,name);
          }
         public override void decorate(List<PartnerRegistrationFormFieldHelper> fields){   
           
            fields.add(new PercentSalesforceInputField());
            //START R14.2
            fields.add(new PercentMarketingProfessionalInputField());
            //END R14.2
            
            //START R14.2
            //fields.add(new HardwareRevenuePercentInputField());
            //END R14.2
            fields.add(new SoftwareRevenuePercentInputField());
            fields.add(new ServicesRevenuePercentInputField());
            //START R14.2
            fields.add(new HardwareLaptopDesktopTabletRevenueInputField());
            fields.add(new HardwareServerStorageNetworkingRevenueInputField());
            fields.add(new CloudServicesRevenueInputField());
           //Ujwala CR13803 adding New Field for EMC change
           // fields.add(new SellVCEProductsServicesInputField());
            //end of EMC change 
            ///fields.add(new ProductRevenueInputField());
            ///fields.add(new TotalNumberOfMarketingProfessionalInputField());
            ///END R14.2
           // DellRevenuePercentInputField dellRev = new DellRevenuePercentInputField();
            //fields.add(new CurrentlySellingInputField(dellRev));
            //fields.add(dellRev); 
            //
           /* fields.add(new CurrentlySellingInputField());
            fields.add(new DellRevenuePercentInputField());
            fields.add(new PrimaryRoutesToMarketInputField()); */
            //START R14.5 VIKAS: CR8152: Reseller Tax ID field location needs to be changed to at the bottom on Focus tab
            //fields.add(new ResellerTaxIDInputField()); 
            //END R14.5 
        }
       } 
      
     public class CountriesDoingBusinessInInputField extends PartnerRegistrationFormFieldHelper{
        public CountriesDoingBusinessInInputField(){
            super(Label.states_provinces_doing_business_in_prompt, 'MULTIPICKLIST', 'States_Provinces_doing_business__c',null,null,Partner_Request__c.States_Provinces_doing_business__c.getDescribe());
            }
    }
    
    /*
    public class ResellerTaxIDInputField extends PartnerRegistrationFormFieldHelper{
        public ResellerTaxIDInputField(){
            super(Label.reseller_tax_id,'STRING','Reseller_Tax_ID__c');
        }
    }
*/

    public class TotalEmployeesInputField extends PartnerRegistrationFormFieldHelper{
        public TotalEmployeesInputField(){
            super(Label.total_employees_prompt, 'PICKLIST', 'Total_Employees__c',Partner_Request__c.Total_Employees__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
    
      
    public class SourceOfInfoInputField extends PartnerRegistrationFormFieldHelper{
        public SourceOfInfoInputField(){
            super(Label.Source_of_Information, 'PICKLIST', 'Source_of_Information__c',Partner_Request__c.Source_of_Information__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }

    public class PercentTechnicalInputField extends PartnerRegistrationFormFieldHelper{
        public PercentTechnicalInputField(){
            super(Label.percent_technical_prof_prompt, 'PICKLIST','Percent_Technical_Professionals__c',Partner_Request__c.Percent_Technical_Professionals__c.getDescribe());
        }       
    }

    public class PercentSalesforceInputField extends PartnerRegistrationFormFieldHelper{
        public PercentSalesforceInputField(){
            super(Label.percent_sales_force_prompt, 'PICKLIST','Percent_Sales_Force__c',Partner_Request__c.Percent_Sales_Force__c.getDescribe());
        }
        
    }

    public class AnnualRevenueInputField extends PartnerRegistrationFormFieldHelper{
        public AnnualRevenueInputField(){
            super(Label.org_annual_revenue_prompt, 'PICKLIST', 'Org_Annual_Revenue__c',Partner_Request__c.Org_Annual_Revenue__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }

    public class HardwareRevenuePercentInputField extends PartnerRegistrationFormFieldHelper{
        public HardwareRevenuePercentInputField(){
            super(Label.hardware_revenue_percent_prompt, 'PICKLIST', 'Hardware_Revenue_Percent__c',Partner_Request__c.Hardware_Revenue_Percent__c.getDescribe());
        }
      
    }

    public class SoftwareRevenuePercentInputField extends PartnerRegistrationFormFieldHelper{
        public SoftwareRevenuePercentInputField(){
            super(Label.software_revenue_percent_prompt, 'PICKLIST', 'Software_Revenue_Percent__c',Partner_Request__c.Software_Revenue_Percent__c.getDescribe());
        }
        
    }

    public class ServicesRevenuePercentInputField extends PartnerRegistrationFormFieldHelper{
        public ServicesRevenuePercentInputField(){
            super(Label.service_revenue_percent_prompt, 'PICKLIST', 'Service_Revenue_Percent__c',Partner_Request__c.Service_Revenue_Percent__c.getDescribe());
        }
       
    }
    
    public class PercentMarketingProfessionalInputField extends PartnerRegistrationFormFieldHelper{
        public PercentMarketingProfessionalInputField(){
            super(Label.Percentage_Marketing_Professional_Employees, 'PICKLIST', 'Percentage_Marketing_Professional_Employ__c',Partner_Request__c.Percentage_Marketing_Professional_Employ__c.getDescribe());
        }
        
    }
    
    public class HardwareLaptopDesktopTabletRevenueInputField extends PartnerRegistrationFormFieldHelper{
        public HardwareLaptopDesktopTabletRevenueInputField(){
            super(Label.Hardware_Laptop_Desktop_Tablet_Revenue, 'PICKLIST', 'Hardware_Laptop_Desktop_Tablet_Revenue__c',Partner_Request__c.Hardware_Laptop_Desktop_Tablet_Revenue__c.getDescribe());
        }
        
    }

     public class HardwareServerStorageNetworkingRevenueInputField extends PartnerRegistrationFormFieldHelper{
        public HardwareServerStorageNetworkingRevenueInputField(){
            super(Label.Hardware_Server_Storage_Networking_Revenue, 'PICKLIST', 'Hardware_Server_Storage_Networking_Reven__c',Partner_Request__c.Hardware_Server_Storage_Networking_Reven__c.getDescribe());
        }
       
    }

     public class CloudServicesRevenueInputField extends PartnerRegistrationFormFieldHelper{
        public CloudServicesRevenueInputField(){
            super(Label.Cloud_Services_Revenue, 'PICKLIST', 'Cloud_Services_Revenue__c',Partner_Request__c.Cloud_Services_Revenue__c.getDescribe());
        }
        
    }
    public class SellVCEProductsServicesInputField extends PartnerRegistrationFormFieldHelper{
        public SellVCEProductsServicesInputField(){
            super(Label.Sell_VCE_Products_Services, 'PICKLIST', 'Sell_VCE_Products_Services__c',Partner_Request__c.Sell_VCE_Products_Services__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
       
    }  
 
    /*
    public class CurrentlySellingInputField extends PartnerRegistrationFormFieldHelper{
        private DellRevenuePercentInputField revPercent;
         
        public override void handleFieldChange(){
        //Adding EMC change
             try{
        System.debug('>>>>>> request.Country__c '+request.Country__c);
        if(countryMap.get(request.Country__c).equals('hk')){
          question ='All';//'HK';
         }
     else{ 
         question = 'All';   
         }  
        }catch(Exception ex){} //End of EMC change
            if('true'.equalsIgnoreCase(this.value)){
                revPercent.visible = true;
                revPercent.required = true;
            } else {
                revPercent.visible = false;
                revPercent.required = false; 
            }
        }

        public CurrentlySellingInputField(DellRevenuePercentInputField revPercent){
            super(Label.currently_selling_dell_prompt, TYPE_BOOLEAN, 'Currently_Selling_Dell__c',Partner_Request__c.Currently_Selling_Dell__c.getDescribe());
            this.revPercent = revPercent;
            this.handleFieldChange();
        }
        
    }
    */

    public class CurrentlySellingInputField extends PartnerRegistrationFormFieldHelper{
        public CurrentlySellingInputField(){
            super(Label.currently_selling_dell_prompt, 'BOOLEAN', 'Currently_Selling_Dell__c',Partner_Request__c.Currently_Selling_Dell__c.getDescribe());
         
        }   
      }

    public class DellRevenuePercentInputField extends PartnerRegistrationFormFieldHelper{
         
        public DellRevenuePercentInputField(){           
            super(Label.dell_revenue_percent_prompt, 'PICKLIST', 'Dell_Revenue_Percent__c',Partner_Request__c.Dell_Revenue_Percent__c.getDescribe());
         system.debug('In apex DellRevenuePercentInputField method'+Partner_Request__c.Dell_Revenue_Percent__c.getDescribe());
        }        
    }


    public class PrimaryRoutesToMarketInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryRoutesToMarketInputField(){
            super(Label.primary_route_to_market,  'PICKLIST', 'Primary_Routes_to_Market__c',Partner_Request__c.Primary_Routes_To_Market__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }        
    }
      
    
    //Added by Uday
    public static String RegionOfCountryis {get;set;}
    
    public static String question {get;set;}
    
    
    
    
    // Added by Bharadwaj END
    
    
    
    
    
       // Added by srikanth For Company Tab
        public class CompanyTab extends PartnerRegistrationFormTabHelper{
        public CompanyTab(String tabLabel, String name){
            super(tabLabel,name);
          }
         public override void decorate(List<PartnerRegistrationFormFieldHelper> fields)
        {
            //fields.add(new LatinCharactersInputField());
            fields.add(new CompanyNameInputField());
            fields.add(new CompanyNameHKInputField());
            fields.add(new DoesBusinessAsInputField());
            fields.add(new DoesBusinessAsHKInputField());
             //START R14.2
            fields.add(new NumberofBranchesSubsidiariesInputField());
            fields.add(new PrincipalNameInputField());
            fields.add(new PrincipalTitleInputField());
            //END R14.2
            fields.add(new OrganizationAddressLine1InputField());
            fields.add(new OrganizationAddressLine2InputField());
            fields.add(new OrganizationAddressLine3InputField());
            fields.add(new OrganizationCityInputField());
            fields.add(new OrganizationStateProvinceInputField());
            fields.add(new OrganizationPostalCodeInputField());
            fields.add(new OrganizataionCountryInputField());
            fields.add(new DunAndBradstreetDUNSNumberInputField());
            fields.add(new OrganizationPhoneInputField());
            fields.add(new OrganizationFaxInputField());
            fields.add(new WebsiteInputField());
            //Ujwala CR13828 Adding New fields for EMC changes
            fields.add(new LegalrepresentativeInputField());
            fields.add(new ProxyHolderEmailInputField());
            //end of EMC change
            fields.add(new FormOfOrganizationInputField());
            fields.add(new NumberOfYearsInBusinessInputField());
            // Diverse Questions Sarveswar
            fields.add(new AreyouconsideredadiverseownedbusinessCheckBox()); 
            // added by harsha
            fields.add(new DervisityCertificationmultipicklist());
            fields.add(new NationalMinorityDevelopmentCouncilCheckBox());
            fields.add(new WomensBusinessEnterpriseNationalCouncilCheckBox());
            fields.add(new NationalLGBTChamberofCommerceCheckBox());
            fields.add(new NationalVeteranBusinessDeveleopmentCouncilCheckBox());
            fields.add(new SmallBusinessCheckBox());
            fields.add(new OtherCertificationsTextkBox());
            fields.add(new ResellerTaxIDInputField()); 
           
        }
       }
       
       
      // Added for hong kong by Prathyusha
       public class CompanyNameHKInputField extends PartnerRegistrationFormFieldHelper{
                public CompanyNameHKInputField(){
                    super(Label.Company_HK,'STRING','Company_HK__c');
                }
            } 
            
            
       public class DoesBusinessAsHKInputField extends PartnerRegistrationFormFieldHelper{
                public DoesBusinessAsHKInputField(){
                    super(Label.Does_Business_As_HK,'STRING','Does_Business_As_HK__c');
                }
            } 
      // Diverse Questions Sarveswar
      
        public class AreyouconsideredadiverseownedbusinessCheckBox extends PartnerRegistrationFormFieldHelper{
                public AreyouconsideredadiverseownedbusinessCheckBox(){
                    super(Label.Are_you_considered_a_diverse_owned_business,'BOOLEAN','considered_a_diverse_owned_business__c');
                }
            } 
        // added by harsha
        public class DervisityCertificationmultipicklist extends PartnerRegistrationFormFieldHelper{
          public DervisityCertificationmultipicklist(){
                super(Label.Company_Diversity_Certification, 'MULTIPICKLIST', 'Diversity_Certification__c',null,null,Partner_Request__c.Diversity_Certification__c.getDescribe());
          }
    }
        public class NationalLGBTChamberofCommerceCheckBox extends PartnerRegistrationFormFieldHelper{
                public NationalLGBTChamberofCommerceCheckBox(){
                    super(Label.National_LGBT_Chamber_of_Commerce,'BOOLEAN','National_LGBT_Chamber_of_Commerce__c');
                }
            } 
        
        public class NationalMinorityDevelopmentCouncilCheckBox extends PartnerRegistrationFormFieldHelper{
                public NationalMinorityDevelopmentCouncilCheckBox(){
                    super(Label.National_Minority_Development_Council,'BOOLEAN','National_Minority_Development_Council__c');
                }
            } 
        
        public class NationalVeteranBusinessDeveleopmentCouncilCheckBox extends PartnerRegistrationFormFieldHelper{
                public NationalVeteranBusinessDeveleopmentCouncilCheckBox(){
                    super(Label.National_Veteran_Business_Develeopment_Council,'BOOLEAN','National_Veteran_Business_Devel_Council__c');
                }
            } 
        
        public class OtherCertificationsTextkBox extends PartnerRegistrationFormFieldHelper{
                public OtherCertificationsTextkBox(){
                    super(Label.Other,'STRING','Other_Certifications__c');
                }
            } 
        
        public class SmallBusinessCheckBox extends PartnerRegistrationFormFieldHelper{
                public SmallBusinessCheckBox(){
                    super(Label.Small_Business,'BOOLEAN','Small_Business__c');
                }
            } 
        
        public class WomensBusinessEnterpriseNationalCouncilCheckBox extends PartnerRegistrationFormFieldHelper{
                public WomensBusinessEnterpriseNationalCouncilCheckBox(){
                    super(Label.Women_s_Business_Enterprise_National_Council,'BOOLEAN','Women_s_Business_Eprise_National_Council__c');
                }
            }  
        public class CompanyNameInputField extends PartnerRegistrationFormFieldHelper{
        //public CompanyNameInputField(){ super(Label.Company, TYPE_STRING, 'Company__c'); }
         public CompanyNameInputField(){
         super(Label.Company, 'STRING', 'Company__c');
         }
    }
    
    public class ResellerTaxIDInputField extends PartnerRegistrationFormFieldHelper{
        public ResellerTaxIDInputField(){
            super(Label.reseller_tax_id,'STRING','Reseller_Tax_ID__c');
        }
    }
    
     public class DoesBusinessAsInputField extends PartnerRegistrationFormFieldHelper{
        public DoesBusinessAsInputField(){ super(Label.doing_business_as, 'STRING', 'Does_Business_As__c'); }
    }
    
     public class NumberofBranchesSubsidiariesInputField extends PartnerRegistrationFormFieldHelper{
        public NumberofBranchesSubsidiariesInputField(){ super(Label.Number_of_Branches_Subsidiaries, 'STRING', 'Number_of_Branches_Subsidiaries__c'); }
    }
    
    public class PrincipalNameInputField extends PartnerRegistrationFormFieldHelper{
        public PrincipalNameInputField(){ super(Label.Principle_Name, 'STRING', 'Principle_Name__c'); }
    }

     public class PrincipalTitleInputField extends PartnerRegistrationFormFieldHelper{
        public PrincipalTitleInputField(){
            super(Label.Principle_Title, 'PICKLIST', 'Principle_Title__c',Partner_Request__c.Principle_Title__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
    
    public class OrganizationAddressLine1InputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationAddressLine1InputField(){ super(Label.organization_address_1, 'STRING', 'Org_Address_1__c'); }
    }

    public class OrganizationAddressLine2InputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationAddressLine2InputField(){ super(Label.organization_address_2, 'STRING', 'Org_Address_2__c'); }
    }

    public class OrganizationAddressLine3InputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationAddressLine3InputField(){ super(Label.organization_address_3, 'STRING', 'Org_Address_3__c'); }
    }

    public class OrganizationCityInputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationCityInputField(){ super(Label.organization_city, 'STRING', 'Org_City__c'); }
    }

    public class OrganizationStateProvinceInputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationStateProvinceInputField(){ super(Label.organization_state_province, 'STRING', 'Org_State__c'); }
    }

    public class OrganizationPostalCodeInputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationPostalCodeInputField(){ super(Label.organization_postal_code, 'STRING', 'Org_Postal_Code__c'); }
    }

    public class OrganizataionCountryInputField extends PartnerRegistrationFormFieldHelper{
        List<SelectOption> countries;
        public OrganizataionCountryInputField(){
            super(Label.organization_country, 'PICKLIST', 'Org_Country__c');
        }
        
    }

     public class DunAndBradstreetDUNSNumberInputField extends PartnerRegistrationFormFieldHelper{
        public DunAndBradstreetDUNSNumberInputField(){ super(Label.Dun_and_Bradstreet_DUNS_Number, 'STRING', 'Dun_and_Bradstreet_DUNS_Number__c'); }
    }
    
  /*   public class OrganizataionCountryInputField extends PartnerRegistrationFormFieldHelper{
        List<SelectOption> countries;
        public OrganizataionCountryInputField(){
            super(Label.organization_country, TYPE_PICKLIST, 'Org_Country__c');
        }
        public override List<SelectOption> retrievePicklistValues(){
                return PartnerRegistrationFormCtrlExt.countryOptions;
        }
    }

    public class OrganizationPhoneInputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationPhoneInputField(){ super(Label.organization_phone_number, TYPE_STRING, 'Org_Phone__c'); }
    }
    */
     public class OrganizationPhoneInputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationPhoneInputField(){ super(Label.Phone_Number_Non_china, 'STRING', 'Org_Phone__c');}    
    }

    public class OrganizationFaxInputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationFaxInputField(){ super(Label.organization_fax, 'STRING', 'Org_Fax__c'); }
    }

    public class WebsiteInputField extends PartnerRegistrationFormFieldHelper{
        public WebsiteInputField(){ super(Label.company_website_url, 'URL', 'Website__c'); }
    }
    //Ujwala CR13828 Adding New fields for EMC changes
        public class LegalrepresentativeInputField extends PartnerRegistrationFormFieldHelper{
        public LegalrepresentativeInputField(){ super(Label.Legal_representative_Proxy_Holder_Name, 'STRING', 'Legal_representative_Proxy_Holder_Name__c'); }
    }
    
    public class ProxyHolderEmailInputField extends PartnerRegistrationFormFieldHelper{
        public ProxyHolderEmailInputField(){ super(Label.Legal_representative_Proxy_Holder_Email, 'STRING', 'Legal_representative_Proxy_Holder_Email__c'); }
    }
    //End of EMC change
    public class FormOfOrganizationInputField extends PartnerRegistrationFormFieldHelper{
        public FormOfOrganizationInputField(){super(Label.form_of_organization, 'PICKLIST', 'Form_of_Organization__c',Partner_Request__c.Form_of_Organization__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());}
        
    }

    public class NumberOfYearsInBusinessInputField extends PartnerRegistrationFormFieldHelper{
        public NumberOfYearsInBusinessInputField(){super(Label.number_of_years_in_business, 'PICKLIST', 'Number_of_years_in_business__c',Partner_Request__c.Number_of_years_in_business__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());}
        
    }
    
   @AuraEnabled
    public static ResponseWrapper getDnBSupportedCountry(ID orgCountry){
        list<Country__c> countryList = new list<country__c>(); 
        ResponseWrapper res = new ResponseWrapper();
        countryList =  [Select Name,DnB_Supported_Country__c from Country__c where ID =:orgCountry];
        if(countryList[0].DnB_Supported_Country__c == false){
            res.isDnBSupported = false;
            res.localLangInd = false;            
        }else{
        res.isDnBSupported = true;
        Map<string,Dnb_Local_language_supported_countries__c> countryMap = Dnb_Local_language_supported_countries__c.getAll();
        Set<String> KeySet = new Set<String>();
        for(String s: countryMap.keySet()){
            KeySet.add(s.toUpperCase());
        }
        if (KeySet.contains(countryList[0].Name.touppercase())){
             res.localLangInd = true;            
        }else{
             res.localLangInd = false;            
        }
      }
       return res;
    }

    
    @AuraEnabled
    public static ResponseWrapper prepareComResponseWrapper(String CountryName,String PartnerTypeName){
        
        ResponseWrapper res = new ResponseWrapper();
       // res.BusinessList  = getBusiness();
       // res.OrganizationList = getOrganization();
       // res.PrincipalTitleList = getPrincipalTitle();
       res.Countrylist = getCountry();
       
        res.companyList = getCompany(CountryName, PartnerTypeName);
        return res;
    }
    
     public class ResponseWrapper{
        @AuraEnabled public List<String> salutationList;
        @AuraEnabled public List<Partner_Type_Field_Configuration__c> contactList;
        @AuraEnabled public List<String> primaryContactAlignedList;
        @AuraEnabled public List<String> FinancingOptionsNonGCList;
       // @AuraEnabled public  List<String> NewsletterOptInList;
       
       @AuraEnabled public List<String> BusinessList;
        @AuraEnabled public List<Partner_Type_Field_Configuration__c> companyList;
        @AuraEnabled public List<String> OrganizationList;
        @AuraEnabled public List<Country__c> Countrylist;
        
        @AuraEnabled public  List<String> PrincipalTitleList;
        @AuraEnabled public  boolean isDnBSupported;
        @AuraEnabled public  boolean localLangInd;
     }
    
      @TestVisible private static List<Country__c> getcountryList(){
        List<Country__c> Con= new List<Country__c>();
        con = [select name from Country__c];
        return con;
    }
    
    public static List<Country__c> getCountry(){
            return [SELECT name, code__c,Region__c FROM Country__c WHERE Is_Active_Partner_Country__c = true ORDER BY name];
    }
    
     // Added by Srikanth for attachments
   
  @AuraEnabled
    public static String saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, Partner_request__C partnerRequest, String currentStep, String selectedCountry,String languageFrmCmpt) {
   /*    string testCountry = selectedCountry;
       system.debug('***Ganji contentType: '+ contentType);
        system.debug('***Ganji fileId: '+ fileId);*/
        system.debug('***Ganji partreq: '+ partnerRequest);
        system.debug('***Ganji currentStep: '+ currentStep);
        system.debug('***Ganji selcountry: '+ selectedCountry );
        language = languageFrmCmpt;
        String returnMsg;
         string dummyCstep = 'company';
        if (fileId == '') {
            system.debug('>>>fileId'+fileId);
            returnMsg = saveTheFile(parentId, fileName, base64Data, contentType, partnerRequest,  currentStep, selectedCountry ); //selectedCountry
            
        } else {
           returnMsg = appendToFile(fileId, base64Data,fileName,partnerRequest);
            
        }
 
        return returnMsg;
    }
 
    public static String saveTheFile(Id parentId, String fileName, String base64Data, String contentType, Partner_request__C partnerRequest, String currentStep, String selectedCountry ) {  //, string selectedCountry
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        String msg;
        string dummyCstep = 'company';
        system.debug('>>>base64Data '+base64Data );
        if(base64Data != null){
            system.debug('>>>partnerRequest'+partnerRequest.id);
            savePartReq1(partnerRequest,currentStep,selectedCountry ); //selectedCountry
        }
 
          Integer attachmentCount = [SELECT count() FROM Attachment WHERE ParentId = :partnerRequest.id];
          system.debug('>>Attachcount'+attachmentCount);
         if(attachmentCount >= MAX_ATTACHMENTS){
            msg = 'No more files can be uploaded.  Only ' + MAX_ATTACHMENTS + ' attachments are allowed per request.';
        } 

         else{ 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;

        system.debug('PR name'+partnerRequest.Name);
        system.debug('PR name'+partnerRequest.id);
        string partnername;
       partnername = [select Name from Partner_Request__c where id=:partnerRequest.id limit 1].Name;
        system.debug('partnername '+partnername ); 
            if(partnername == null || partnername =='')
                partnername=partnerRequest.Name;
             
        if(oAttachment!=null){
            attachmentCount++;
                msg= oAttachment.Id+ ':' + getTranslatedLabel('File') +' \''+ fileName + '\' '
                    + getTranslatedLabel('Was_Uploaded_Successfully_to_Registratio')  + '   '+ partnername + '.  '
                    + getTranslatedLabel('You_may_upload_no_more_than') + '  ' + '('+  (MAX_ATTACHMENTS-attachmentCount)+')'+ '  ' + getTranslatedLabel('more_file_s') + '. ' ;
        }
          //getTranslatedLabel('receive_newsletter_02') 
         }
          
        return msg;
    }
 
  /*  private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        String msg;
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
       
            update a;
        
        
        
    }*/
    
   @TestVisible private static String appendToFile(Id fileId, String base64Data,String fileName,Partner_request__C partnerRequest) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        String msg;
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
 Integer attachmentCount = [SELECT count() FROM Attachment WHERE ParentId = :partnerRequest.id];
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Name = fileName;
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        try{
            update a;
            string partnername;
             partnername = [select Name from Partner_Request__c where id=:partnerRequest.id limit 1].Name;
            system.debug('partnername '+partnername ); 
            if(partnername == null || partnername =='')
                partnername=partnerRequest.Name;
           // msg = 'Updated Successfully';
            msg= a.Id+':'+ getTranslatedLabel('File')  +' \''+fileName+'\' '
                    + getTranslatedLabel('Was_Uploaded_Successfully_to_Registratio')  + '   '+ partnername+ '.  '
                    + getTranslatedLabel('You_may_upload_no_more_than') + '  '+'('+ (MAX_ATTACHMENTS-attachmentCount) +')' + '  '+ getTranslatedLabel('more_file_s')+'. ' ;
       
        }
        catch(Exception e){
            System.debug('Exception'+e.getMessage());
            msg = e.getMessage();
        }
        return msg;
        
        
    }
    
    @AuraEnabled
    public static Partner_Request__c savePartReq(Partner_Request__c partreq, string selectedCountry, string currentStep){
       // Partner_Request__c p = new Partner_Request__c ( );
           system.debug('>>> Save PR record');
           system.debug('***Ganji partreq: '+ partreq);
            //p.Company__c=comp;
            //p.Dun_and_Bradstreet_DUNS_Number__c= duns;
               partreq.Status__c='Aborted By Partner';
              partreq.RecordTypeId=Label.Aborted_by_Partner_record_type_Id;
              system.debug(Label.Aborted_by_Partner_record_type_Id);
              partreq.Org_Phone__c=partreq.phone__c;
              partreq.Org_Address_1__c=partreq.Address_Line_1__c;
              partreq.Org_Address_2__c=partreq.Address_Line_2__c;
              if(partreq.Application_Environments__c== '--None--' || partreq.Application_Environments__c=='None'){
              partreq.Application_Environments__c=null;
              }
              if(partreq.Area_of_Interest_Non_GC__c=='--None--' || partreq.Area_of_Interest_Non_GC__c=='None'){
              partreq.Area_of_Interest_Non_GC__c=null;}
              if(partreq.Job_Category_Non_GC__c=='--None--' || partreq.Job_Category_Non_GC__c=='None'){
              partreq.Job_Category_Non_GC__c=null;}
              if(partreq.Job_Title_Non_GC__c=='--None--' || partreq.Job_Title_Non_GC__c=='None'){
              partreq.Job_Title_Non_GC__c=null;}
              if(partreq.Primary_Customer_Non_GC__c=='--None--' || partreq.Primary_Customer_Non_GC__c=='None'){
              partreq.Primary_Customer_Non_GC__c=null;}
              if(partreq.Primary_Vertical_Market_Segment_Non_GC__c=='--None--' || partreq.Primary_Vertical_Market_Segment_Non_GC__c=='None'){
              partreq.Primary_Vertical_Market_Segment_Non_GC__c=null;}
              if(partreq.Secondary_Customer_Segment_Non_GC__c=='--None--' || partreq.Secondary_Customer_Segment_Non_GC__c=='None'){
              partreq.Secondary_Customer_Segment_Non_GC__c=null;}
              if(partreq.Individual_Principals__c=='--None--' || partreq.Individual_Principals__c=='None'){
              partreq.Individual_Principals__c=null;}
        
        
        
            insert partreq ;
             System.debug('>>>>>PRID'+partreq.Id);
             partreq = [Select Id,Name,RecordTypeId from Partner_Request__c
                        WHERE Id =: partreq.Id];
           system.debug(partreq);
             return partreq;
             
           // System.debug('>>>>>PR ID'+partreq.Id);
    }
    
     @AuraEnabled
    public static List<Partner_Type_Field_Configuration__c> getCompany(String CountryName, String PartnerTypeName) {
       
        return [SELECT Field_Name__c, Tab_Name__c, Partner_Type__r.name,Partner_Type__r.country__c,
                Is_Required__c, Is_Enabled__c FROM Partner_Type_Field_Configuration__c 
                where Tab_name__c = 'Company' AND Is_Enabled__c = true AND Partner_Type__r.country__r.Name = :CountryName AND Partner_type__r.name=:PartnerTypeName ];
      
    }
    // End Here for Company Tab
    
        
    public class ServiceTab extends PartnerRegistrationFormTabHelper{
        public ServiceTab(String tabLabel, String name){
            super(tabLabel,name);
          }
         public override void decorate(List<PartnerRegistrationFormFieldHelper> fields){        
             fields.add(new ServiceTypeInputField());             
             fields.add(new ServiceCapabilityInputField());
             fields.add(new ModeOfServiceInputField());
             fields.add(new HardwareWarrantyInputField());
             fields.add(new SoftwareTechnicalSupportInputField());
             fields.add(new InstallationDeploymentInputField());
             fields.add(new InstallationDeploymentMarketInputField());
             fields.add(new CustomConfigInputField());
             fields.add(new DataMigrationInputField());
             fields.add(new AssetRecoveryInputField());
             fields.add(new ConsultingInputField());
             fields.add(new ConsultingMarketInputField());
             fields.add(new EducationTrainingInputField());
             fields.add(new ManagedDeploymentInputField());
             fields.add(new CustomEnterpriseInputField());
             fields.add(new HowdeliverInputField());
             fields.add(new HowresellInputField());
             fields.add(new DellServicesToolsInputField());
             fields.add(new SalesSponserNameInputField());
             fields.add(new SalesSponserTelephoneInputField());
             fields.add(new SalessponserEmailInputField());
             fields.add(new MarketingContactNameInputField());
             fields.add(new MarketingContactTitleInputField());
             fields.add(new MarketingContactTelephoneInputField());
             fields.add(new MarketingContactEmailInputField());
             fields.add(new ReportContactNameInputField());            
             fields.add(new ReportContactTitleInputField());
             fields.add(new ReportContactTelephoneInputField());
             fields.add(new ReportContactEmailInputField());
             fields.add(new ServiceContactNameInputField());
             fields.add(new ServiceContactTitleInputField());
             fields.add(new ServiceContactTelephoneInputField());
             fields.add(new ServiceContactEmailInputField());            
             fields.add(new existingContractualRelationshipInputField());
             fields.add(new CSPMSPOrganizationInputField());
             fields.add(new DellServicesPortfolioInputField());
             fields.add(new InterestedAbtDellServicesInputField());
             fields.add(new ServicesFirstNameInputField()); 
             fields.add(new ServicesLastNameInputField());
             fields.add(new ServicesJobTitleInputField());
             fields.add(new ServicesPhoneNumberInputField());
             fields.add(new ServicesLeadEmailInputField());
        }
       }
    
    public class ServiceTypeInputField extends PartnerRegistrationFormFieldHelper{
        public ServiceTypeInputField(){
            super(Label.Do_you, 'MULTIPICKLIST', 'Service_Type__c',Partner_Request__c.Service_Type__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
    }
    
    public class ServiceCapabilityInputField extends PartnerRegistrationFormFieldHelper{
         public ServiceCapabilityInputField(){
                super(Label.Service_Capability, 'MULTIPICKLIST', 'Service_Capability__c',Partner_Request__c.Service_Capability__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
     }
    public class ModeOfServiceInputField extends PartnerRegistrationFormFieldHelper{
          public ModeOfServiceInputField(){
                super(Label.Mode_of_Service, 'MULTIPICKLIST', 'Mode_Of_Service__c',Partner_Request__c.Mode_Of_Service__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
          }
    }
    public class HardwareWarrantyInputField extends PartnerRegistrationFormFieldHelper{
            public HardwareWarrantyInputField(){
                super(Label.Hardware_warranty_Break_fix_support, 'MULTIPICKLIST', 'Hardware_warranty_Break_fix_support__c',Partner_Request__c.Hardware_warranty_Break_fix_support__c.getDescribe());
            }
        }
    public class SoftwareTechnicalSupportInputField extends PartnerRegistrationFormFieldHelper{
            public SoftwareTechnicalSupportInputField(){
                super(Label.Software_Technical_Support, 'MULTIPICKLIST', 'Software_Technical_Support__c',Partner_Request__c.Software_Technical_Support__c.getDescribe());
            }
        }
    public class InstallationDeploymentInputField extends PartnerRegistrationFormFieldHelper{
            public InstallationDeploymentInputField(){                
                super(Label.Installation_Deployment_Services, 'MULTIPICKLIST', 'Installation_Deployment_Services__c',Partner_Request__c.Installation_Deployment_Services__c.getDescribe());
            }
        }
    public class InstallationDeploymentMarketInputField extends PartnerRegistrationFormFieldHelper{
            public InstallationDeploymentMarketInputField(){
                super(Label.Installation_Deployment_Services_Market, 'MULTIPICKLIST', 'Installation_Deployment_Services_Market__c',Partner_Request__c.Installation_Deployment_Services_Market__c.getDescribe());
            }
        }
    public class CustomConfigInputField extends PartnerRegistrationFormFieldHelper{
            public CustomConfigInputField(){                
                super(Label.Custom_Configuration_Imaging, 'MULTIPICKLIST', 'Custom_Configuration_Imaging__c',Partner_Request__c.Custom_Configuration_Imaging__c.getDescribe());
            }
        }
    public class DataMigrationInputField extends PartnerRegistrationFormFieldHelper{
            public DataMigrationInputField(){
                super(Label.Data_Migration, 'MULTIPICKLIST', 'Data_Migration__c',Partner_Request__c.Data_Migration__c.getDescribe());
            }
        }
    public class AssetRecoveryInputField extends PartnerRegistrationFormFieldHelper{
            public AssetRecoveryInputField(){
                super(Label.Asset_recovery_resale_recycling, 'MULTIPICKLIST', 'Asset_recovery_resale_recycling__c',Partner_Request__c.Asset_recovery_resale_recycling__c.getDescribe());
            }
        }
    public class ConsultingInputField extends PartnerRegistrationFormFieldHelper{
            public ConsultingInputField(){
                super(Label.Consulting, 'MULTIPICKLIST', 'Consulting__c',Partner_Request__c.Consulting__c.getDescribe());
            }
        }
    public class ConsultingMarketInputField extends PartnerRegistrationFormFieldHelper{
            public ConsultingMarketInputField(){
                super(Label.Consulting_Market, 'MULTIPICKLIST', 'Consulting_Market__c',Partner_Request__c.Consulting_Market__c.getDescribe());
            }
        }
    public class EducationTrainingInputField extends PartnerRegistrationFormFieldHelper{
            public EducationTrainingInputField(){
                super(Label.Education_Training, 'MULTIPICKLIST', 'Education_Training__c',Partner_Request__c.Education_Training__c.getDescribe());
            }
        }
    public class ManagedDeploymentInputField extends PartnerRegistrationFormFieldHelper{
            public ManagedDeploymentInputField(){
                super(Label.Managed_Deployment, 'MULTIPICKLIST', 'Managed_Deployment__c',Partner_Request__c.Managed_Deployment__c.getDescribe());
            }
        }
    public class CustomEnterpriseInputField extends PartnerRegistrationFormFieldHelper{
            public CustomEnterpriseInputField(){
                super(Label.Custom_enterprise_data_center_services, 'MULTIPICKLIST', 'Custom_enterprise_data_center_services__c',Partner_Request__c.Custom_enterprise_data_center_services__c.getDescribe());
            }
        }
         public class HowdeliverInputField extends PartnerRegistrationFormFieldHelper{
            public HowdeliverInputField(){
                super(Label.How_you_deliver_the_services, 'MULTIPICKLIST', 'Deliver_to_your_C__c',Partner_Request__c.Deliver_to_your_C__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
        }
         public class HowresellInputField extends PartnerRegistrationFormFieldHelper{
            public HowresellInputField(){
                super(Label.How_you_resell_the_services, 'MULTIPICKLIST', 'Resell_to_your_Customer__c',Partner_Request__c.Resell_to_your_Customer__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
        }
    public class DellServicesToolsInputField extends PartnerRegistrationFormFieldHelper{
            public DellServicesToolsInputField(){
                super(Label.Dell_Service_Tools_Used, 'MULTIPICKLIST', 'Dell_Service_Tools_Used__c',Partner_Request__c.Dell_Service_Tools_Used__c.getDescribe());
            }
        }

        public class DellServicesPortfolioInputField extends PartnerRegistrationFormFieldHelper{
            public DellServicesPortfolioInputField(){
                super(Label.Dell_Services_Portfolio, 'PICKLIST', 'Dell_Services_Portfolio__c',Partner_Request__c.Dell_Services_Portfolio__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
        }
    public class ServicesJobTitleInputField extends PartnerRegistrationFormFieldHelper{
            public ServicesJobTitleInputField(){
                super(Label.Services_Lead_Job_Title, 'PICKLIST', 'Service_Lead_Job_Title__c',Partner_Request__c.Service_Lead_Job_Title__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
        }
    
     public class ServicesFirstNameInputField extends PartnerRegistrationFormFieldHelper{
            public ServicesFirstNameInputField(){
                super(Label.Services_Lead_First_Name, 'STRING', 'Services_Lead_First_Name__c',Partner_Request__c.Services_Lead_First_Name__c.getDescribe());
            }
        }
    
    public class ServicesLastNameInputField extends PartnerRegistrationFormFieldHelper{
            public ServicesLastNameInputField(){
                super(Label.Services_Lead_Last_Name, 'STRING', 'Services_Lead_Last_Name__c',Partner_Request__c.Services_Lead_Last_Name__c.getDescribe());
            }
        }
     public class ServicesPhoneNumberInputField extends PartnerRegistrationFormFieldHelper{
            public ServicesPhoneNumberInputField(){ 
                super(Label.Services_Lead_Phone_Number, 'STRING', 'Services_Lead_Phone_Number__c',Partner_Request__c.Services_Lead_Phone_Number__c.getDescribe()); 
            }
        }
    public class ServicesLeadEmailInputField extends PartnerRegistrationFormFieldHelper{
            public ServicesLeadEmailInputField(){
                super(Label.Services_Lead_Email, 'STRING', 'Services_Lead_Email__c',Partner_Request__c.Services_Lead_Email__c.getDescribe());
            }
        }
     public class InterestedAbtDellServicesInputField extends PartnerRegistrationFormFieldHelper{
        public InterestedAbtDellServicesInputField(){
                super(Label.Intrested_in_learning_Dell_Services, 'BOOLEAN', 'Intrested_in_learning_Dell_Services__c',Partner_Request__c.Intrested_in_learning_Dell_Services__c.getDescribe());
        }
    }
    public class SalesSponserNameInputField extends PartnerRegistrationFormFieldHelper{
        public SalesSponserNameInputField(){ 
                super(Label.sales_sponser_name, 'STRING', 'Sales_Sponser_Name__c',Partner_Request__c.Sales_Sponser_Name__c.getDescribe());
            }
    }
    public class SalesSponserTelephoneInputField extends PartnerRegistrationFormFieldHelper{
        public SalesSponserTelephoneInputField(){ 
                super(Label.sales_sponser_telephone, 'STRING', 'Sales_Sponsor_Telephone__c',Partner_Request__c.Sales_Sponsor_Telephone__c.getDescribe());
        }
    }
    public class SalessponserEmailInputField extends PartnerRegistrationFormFieldHelper{
        public SalessponserEmailInputField(){  
                super(Label.sales_sponser_email, 'STRING', 'Sales_Sponsor_Email__c',Partner_Request__c.Sales_Sponsor_Email__c.getDescribe());
        }
    }    
    public class MarketingContactNameInputField extends PartnerRegistrationFormFieldHelper{
        public MarketingContactNameInputField(){ 
                super(Label.marketing_contact_name, 'STRING', 'Marketing_Contact_Name__c',Partner_Request__c.Marketing_Contact_Name__c.getDescribe());
        }
    }
    public class  MarketingContactTitleInputField extends PartnerRegistrationFormFieldHelper{
        public MarketingContactTitleInputField(){  
                super(Label.marketing_contact_title, 'STRING', 'Marketing_Contact_Title__c',Partner_Request__c.Marketing_Contact_Title__c.getDescribe());
        }
    }
    public class MarketingContactTelephoneInputField extends PartnerRegistrationFormFieldHelper{
        public MarketingContactTelephoneInputField(){  
                super(Label.marketing_contact_telephone, 'STRING', 'Marketing_Contact_Telephone__c',Partner_Request__c.Marketing_Contact_Telephone__c.getDescribe());
        }
    }
    public class MarketingContactEmailInputField extends PartnerRegistrationFormFieldHelper{
        public MarketingContactEmailInputField(){  
                super(Label.marketing_contact_email, 'STRING', 'Marketing_Contact_Email__c',Partner_Request__c.Marketing_Contact_Email__c.getDescribe());
        }
    }
        
    public class ReportContactNameInputField extends PartnerRegistrationFormFieldHelper{
        public ReportContactNameInputField(){ 
                super(Label.sales_contact_name, 'STRING', 'Sale_Report_Provider_Contact_Name__c',Partner_Request__c.Sale_Report_Provider_Contact_Name__c.getDescribe()); 
        }
    }
    public class ReportContactEmailInputField extends PartnerRegistrationFormFieldHelper{
        public ReportContactEmailInputField(){ 
                super(Label.sales_provider_email, 'STRING', 'Sale_Report_Provider_Contact_Email__c',Partner_Request__c.Sale_Report_Provider_Contact_Email__c.getDescribe());
        }
     }
    public class ReportContactTitleInputField extends PartnerRegistrationFormFieldHelper{
        public ReportContactTitleInputField(){  
                super(Label.sales_contact_title, 'STRING', 'Sale_Report_Provider_Contact_Title__c',Partner_Request__c.Sale_Report_Provider_Contact_Title__c.getDescribe());
        }
    }
    public class ReportContactTelephoneInputField extends PartnerRegistrationFormFieldHelper{
        public ReportContactTelephoneInputField(){  
                super(Label.sales_contact_telephone, 'STRING', 'Sale_Report_Provider_Contact_Telephone__c',Partner_Request__c.Sale_Report_Provider_Contact_Telephone__c.getDescribe());
        }
    }
    public class ServiceContactNameInputField extends PartnerRegistrationFormFieldHelper{
        public ServiceContactNameInputField(){ 
                super(Label.service_contact_name, 'STRING', 'Service_Offering_Contact_Name__c',Partner_Request__c.Service_Offering_Contact_Name__c.getDescribe());
        }
    }
    public class ServiceContactEmailInputField extends PartnerRegistrationFormFieldHelper{
        public ServiceContactEmailInputField(){ 
                super(Label.service_contact_email, 'STRING', 'Service_Offering_Contact_Email__c',Partner_Request__c.Service_Offering_Contact_Email__c.getDescribe());
        }
    }
    public class ServiceContactTelephoneInputField extends PartnerRegistrationFormFieldHelper{
        public ServiceContactTelephoneInputField(){
                super(Label.service_contact_telephone, 'STRING', 'Service_Offering_Contact_Telephone__c',Partner_Request__c.Service_Offering_Contact_Telephone__c.getDescribe());
        }
    }
    public class ServiceContactTitleInputField extends PartnerRegistrationFormFieldHelper{
        public ServiceContactTitleInputField(){ 
                super(Label.service_contact_title, 'STRING', 'Service_Offering_Contact_Title__c',Partner_Request__c.Service_Offering_Contact_Title__c.getDescribe());
        }
    }
    public class existingContractualRelationshipInputField extends PartnerRegistrationFormFieldHelper{
        public existingContractualRelationshipInputField(){ 
                super(Label.existing_contractual_relation, 'STRING', 'existing_contractual_relationship__c',Partner_Request__c.existing_contractual_relationship__c.getDescribe());
        }
    }
    public class CSPMSPOrganizationInputField extends PartnerRegistrationFormFieldHelper{
            public CSPMSPOrganizationInputField(){
                super(Label.ord_require_emc_products, 'PICKLIST', 'CSP_MSP_Organization_require_EMC_Storage__c',Partner_Request__c.CSP_MSP_Organization_require_EMC_Storage__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
        }
//Segment Method
public class AreaOfInterestInputField extends PartnerRegistrationFormFieldHelper{
        public AreaOfInterestInputField(){ super(Label.area_of_interest, 'PICKLIST', 'Area_of_Interest__c',Partner_Request__c.Area_of_Interest__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
        
    } 
    public class PrimaryVerticalMarketSegmentNonGCInputField extends PartnerRegistrationFormFieldHelper {
  public PrimaryVerticalMarketSegmentNonGCInputField() {
   super(Label.Primary_Vertical_Market_Segment, 'PICKLIST', 'Primary_Vertical_Market_Segment_Non_GC__c', Partner_Request__c.Primary_Vertical_Market_Segment_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
  }

 }
    public class SizeofCustomerBaseInputField extends PartnerRegistrationFormFieldHelper{
        public SizeofCustomerBaseInputField(){ super(Label.Size_of_Customer_Base, 'PICKLIST', 'Size_of_Customer_Base__c',Partner_Request__c.Size_of_Customer_Base__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
        
    }  
    public class AreaOfInterestNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public AreaOfInterestNonGCInputField(){ super(Label.area_of_interest, 'PICKLIST', 'Area_of_Interest_Non_GC__c',Partner_Request__c.Area_of_Interest_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
        
    }

     public class ProductFocusInputField extends PartnerRegistrationFormFieldHelper{
        public ProductFocusInputField(){
            super(Label.Product_Focus_Prompt_HK, 'MULTIPICKLIST', 'Product_Focus__c',Partner_Request__c.Product_Focus__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
    public class ProductFocusNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public ProductFocusNonGCInputField(){
            super(Label.product_focus_prompt, 'MULTIPICKLIST', 'Product_Focus_Non_GC__c',Partner_Request__c.Product_Focus_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
    public class PrimaryCustomerInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryCustomerInputField(){
            super(Label.primary_customer_prompt, 'PICKLIST', 'Primary_Customer__c',Partner_Request__c.Primary_Customer__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
      public class PrimaryCustomerNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryCustomerNonGCInputField(){
            super(Label.primary_customer_prompt, 'PICKLIST', 'Primary_Customer_Non_GC__c',Partner_Request__c.Primary_Customer_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
    
    public class SecondaryCustomerInputField extends PartnerRegistrationFormFieldHelper{
        public SecondaryCustomerInputField(){ super(Label.Secondary_Customer, 'PICKLIST', 'Secondary_Customer__c',Partner_Request__c.Secondary_Customer__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
     }
    public class SecondaryCustomerSegmentNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public SecondaryCustomerSegmentNonGCInputField(){ super(Label.Secondary_Customer, 'PICKLIST', 'Secondary_Customer_Segment_Non_GC__c',Partner_Request__c.Secondary_Customer_Segment_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
        
    }
   
    
     public class TertiaryCustomerSegmentNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public TertiaryCustomerSegmentNonGCInputField(){ super(Label.TertiaryCustomerSegment, 'PICKLIST', 'tertiary_customer_segment_Non_GC__c',Partner_Request__c.tertiary_customer_segment_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
    }
    
   public class SecondaryVerticalMarketSegmentNonGCInputField extends PartnerRegistrationFormFieldHelper{
      public SecondaryVerticalMarketSegmentNonGCInputField(){ super(Label.Secondary_Vertical_Market_Segment, 'PICKLIST', 'Secondary_Vertical_Market_Segment_Non_GC__c',Partner_Request__c.Secondary_Vertical_Market_Segment_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
       
    }
    
     public class TertiaryPracticeAreaInputField extends PartnerRegistrationFormFieldHelper{
        public TertiaryPracticeAreaInputField(){ super(Label.TertiaryPracticeArea, 'PICKLIST', 'Tertiary_Practice_Area__c',Partner_Request__c.Tertiary_Practice_Area__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
        
    }
    public class TertiaryPracticeAreaNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public TertiaryPracticeAreaNonGCInputField(){ super(Label.TertiaryPracticeArea, 'PICKLIST', 'Tertiary_Practice_Area_Non_GC__c',Partner_Request__c.Tertiary_Practice_Area_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
        
    }
      public class OtherCustomersInputField extends PartnerRegistrationFormFieldHelper{
        public OtherCustomersInputField(){
            super(Label.other_customers_prompt, 'MULTIPICKLIST', 'Other_Customers__c',Partner_Request__c.Other_Customers__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
       
    }
     public class OtherCustomersNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public OtherCustomersNonGCInputField(){
            super(Label.other_customers_prompt, 'MULTIPICKLIST', 'Other_Customers_Non_GC__c',Partner_Request__c.Other_Customers_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
    public class HaveReadPartnerProgramGuideInputField extends PartnerRegistrationFormFieldHelper{
        public HaveReadPartnerProgramGuideInputField(){
            super(Label.i_have_read_the_partner_program_guide, 'BOOLEAN', 'Have_read_the_Partner_Program_Guide__c');
        }
    }

    public class ActiveBuyingRelationshipAgreement extends PartnerRegistrationFormFieldHelper{
        public ActiveBuyingRelationshipAgreement(){
            super(Label.Active_Buying_Relationship_Agreement, 'BOOLEAN', 'Active_Buying_Relationship_Agreement__c');
        }
    }
    
    public class AgreeOEMTermsandConditionsInputField extends PartnerRegistrationFormFieldHelper{
           public AgreeOEMTermsandConditionsInputField(){
                super(Label.OEM_tc_APJ, 'BOOLEAN', 'Agree_OEM_Terms_and_Conditions__c'); 
           }
        }
    
      public class ISVTermsAndConditionsInputField extends PartnerRegistrationFormFieldHelper{
            public ISVTermsAndConditionsInputField(){
            super(Label.Agree_Dell_ISV_Program,'BOOLEAN', 'Agree_Dell_ISV_Program__c');
        }
      }
       public class MFTTermsAndConditionsInputField extends PartnerRegistrationFormFieldHelper{
            public MFTTermsAndConditionsInputField(){            
            super(Label.Agree_MFT_Partner_Program, 'BOOLEAN', 'AGREE_to_Dell_MFT_Partner_Program__c');
            }
        }
    
     public class AgreeToExportComplianceInputField extends PartnerRegistrationFormFieldHelper{
        public AgreeToExportComplianceInputField(){
            super(Label.agree_to_export_compliance, 'BOOLEAN', 'Export_Compliance_Agreed__c');
        }
    }
     public class RequestingToSupportLettersinLATAMInputField extends PartnerRegistrationFormFieldHelper{
        public RequestingToSupportLettersinLATAMInputField(){
            super(Label.Will_you_be_requesting_Support_Letters, 'BOOLEAN', 'Requesting_To_Support_Letters_in_LATAM__c');
        }
    }
     public class PreferredDistributionPartnerInputField extends PartnerRegistrationFormFieldHelper{
        public PreferredDistributionPartnerInputField(){
            super(Label.preferred_dell_distr_partner_prompt, 'STRING',
                'Preferred_Dell_Distribution_Partner__c');
        }
        
    }
    public class ResaleRevenueInputField extends PartnerRegistrationFormFieldHelper{
        public ResaleRevenueInputField(){ super(Label.ResaleRevenue, 'PICKLIST', 'Resale_Revenue__c',Partner_Request__c.Resale_Revenue__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage()); }
    }
   
   
    public class EnableDealRegistrationInputField extends PartnerRegistrationFormFieldHelper{
        public EnableDealRegistrationInputField(){
            super(Label.I_want_to_submit_Sales_Deals_Leads, 'BOOLEAN', 'Feature_Request_Deal_Registration__c');//CR 7823
        }
    }
    
    public class EnablePartnerFinderInputField extends PartnerRegistrationFormFieldHelper{
        public EnablePartnerFinderInputField(){
            super(Label.i_want_to_be_published_to_the_dell_part, 'BOOLEAN', 'Feature_Request_Partner_Finder__c');
        }
    }
    public class ResellerTermsAndConditionsInputField extends PartnerRegistrationFormFieldHelper{
        public ResellerTermsAndConditionsInputField(){
            super(Label.Agree_Dell_Reseller_PartnerDirect, 'BOOLEAN', 'Agree_Dell_Reseller__c');
        }
    }
      public class BothISVResellerTermsAndConditionsInputField extends PartnerRegistrationFormFieldHelper{
        public BothISVResellerTermsAndConditionsInputField(){
            super(Label.Agree_Both_Dell_Reseller_And_ISV, 'BOOLEAN', 'Agree_Both_Dell_ResellerISV__c');
        }
      }
   
    public class DistProgramTermsAndConditionsInputField extends PartnerRegistrationFormFieldHelper{
        public DistProgramTermsAndConditionsInputField(){
            super(Label.Agree_Dell_PartnerDirect_Distributor_Program, 'BOOLEAN', 'Agree_Dell_Partner_Dist_Pro__c');
        }
    }
        public class DistSupplierTermsAndConditionsInputField extends PartnerRegistrationFormFieldHelper{
        public DistSupplierTermsAndConditionsInputField(){
            super(Label.Agree_Dell_PartnerDirect_Distributor_Supplier, 'BOOLEAN', 'Agree_Dell_Partner_Dist_Sup__c');
        }
    }
       
    public class PrimaryVerticalMarketSegmentInputField extends PartnerRegistrationFormFieldHelper{
        public PrimaryVerticalMarketSegmentInputField(){
            super(Label.Primary_Vertical_Market_Segment, 'PICKLIST', 'Primary_Vertical_Market_Segment__c',Partner_Request__c.Primary_Vertical_Market_Segment__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
    
    public class SecondaryVerticalMarketSegmentInputField extends PartnerRegistrationFormFieldHelper{
        public SecondaryVerticalMarketSegmentInputField(){
            super(Label.Secondary_Vertical_Market_Segment, 'PICKLIST', 'Secondary_Vertical_Market_Segment__c',Partner_Request__c.Secondary_Vertical_Market_Segment__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }

  public class TertiaryCustomerSegmentInputField extends PartnerRegistrationFormFieldHelper{
          public TertiaryCustomerSegmentInputField(){
            super(Label.TertiaryCustomerSegment, 'PICKLIST', 'tertiary_customer_segment__c',Partner_Request__c.tertiary_customer_segment__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        } 
    }
    public class Top3VendorsInputField extends PartnerRegistrationFormFieldHelper{
        public Top3VendorsInputField(){
            super(Label.Top_3_Vendors, 'MULTIPICKLIST', 'Top_3_Vendors__c',Partner_Request__c.Top_3_Vendors__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
     public class Top3VendorsNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public Top3VendorsNonGCInputField(){
            super(Label.Top_3_Vendors, 'MULTIPICKLIST', 'Top_3_Vendors_Non_GC__c',Partner_Request__c.Top_3_Vendors__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }  
     public class ApplicationEnvironmentsInputField extends PartnerRegistrationFormFieldHelper{
        public ApplicationEnvironmentsInputField(){
            super(Label.Application_Environments, 'PICKLIST', 'Application_Environments__c',Partner_Request__c.Application_Environments__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
        
    }
    public class OrganizationIndustryCertificateInputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationIndustryCertificateInputField(){
            super(Label.Organization_Industry_Certificate, 'MULTIPICKLIST', 'Organization_Industry_Certificate__c',Partner_Request__c.Organization_Industry_Certificate__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    }
     public class OrganizationIndustryCertificateNonGCInputField extends PartnerRegistrationFormFieldHelper{
        public OrganizationIndustryCertificateNonGCInputField(){
            super(Label.Organization_Industry_Certificate, 'MULTIPICKLIST', 'Organization_Industry_Certificate_Non_GC__c',Partner_Request__c.Organization_Industry_Certificate_Non_GC__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
        }
        
    } 
    
      public class AbilitytodoBusinesswithFederalInputField extends PartnerRegistrationFormFieldHelper{
            public AbilitytodoBusinesswithFederalInputField(){
                super(Label.Ability_to_do_business_with_Federal, 'PICKLIST', 'Ability_to_do_business_with_Federal__c',Partner_Request__c.Ability_to_do_business_with_Federal__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
           
        }
    public class IndividualPrincipalsInputField extends PartnerRegistrationFormFieldHelper{
        public IndividualPrincipalsInputField(){
            super(Label.Individual_Principals, 'PICKLIST', 'Individual_Principals__c',Partner_Request__c.Individual_Principals__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
        
    } 
     public class ServingashighrankingofficialsInputField extends PartnerRegistrationFormFieldHelper{
            public ServingashighrankingofficialsInputField(){
                super(Label.Serving_as_high_ranking_officials, 'PICKLIST', 'Serving_as_high_ranking_officials__c',Partner_Request__c.Serving_as_high_ranking_officials__c.getDescribe(),Vfcntrl_PartnerRegistrationForm.getLanguage());
            }
            
        }
    public class CommentsInputField extends PartnerRegistrationFormFieldHelper{
        public CommentsInputField(){ super(Label.Enter_Additional_Information_Or_Comments, 'STRING', 'Comments__c'); }
    }
    
   

     public class returnResultWrapper{
        @AuraEnabled public Partner_Request__c partreqObj;
        @AuraEnabled public string prNumber;
        @AuraEnabled public string countryEmail; 
        @AuraEnabled public string errorMsg;         
    
     }
    
 @AuraEnabled
 public static  returnResultWrapper savePartReq1 (Partner_Request__c partreqList, string currentStep, string selectedCountry) { //, string selectedCountry
  returnResultWrapper returnResult = new returnResultWrapper();
  try{   
  Lead lead = null;
  Id regId;
 
  country__c selcountObj = [select id, User_Language_Locale_Key__c,Partner_Support_Email__c,Partner_Support_Queue_ID__c from country__c where name =: selectedCountry  limit 1]; 
  string countryEmail = selcountObj.Partner_Support_Email__c;
  system.debug('***tab?:' + currentStep);
  system.debug('***SelCounlang?:' + selcountObj.User_Language_Locale_Key__c);
     system.debug('>>>>>partreqList_recordtpeID'+partreqList.RecordTypeId);      

 if (selcountObj.User_Language_Locale_Key__c != null) 
    partreqList.Preferred_language_code__c = selcountObj.User_Language_Locale_Key__c;
   else
    partreqList.Preferred_language_code__c = 'All';
  if (partreqList.id == null) {
      
   if (partreqList.Feature_Request_Deal_Registration__c == true) {
    partreqList.Feature_Request_Lead_Management__c = true;
   }

   if (currentStep.equals('Cloud Service Provider') || (currentStep.equals('segment') && partreqList.Primary_Channel_Model__c != 'CSP (Cloud Service Provider)')) {
    partreqList.Status__c = 'NEW';
    partreqList.OwnerId = selcountObj.Partner_Support_Queue_ID__c;
    partreqList.RecordTypeId = IdLookupUtils.getRecordTypeId('New Partner', 'Partner_Request__c', true);
    partreqList.agreed_on__c = System.now();
   } 
   else {
    partreqList.Status__c = 'Aborted By Partner';    
    partreqList.RecordTypeId = IdLookupUtils.getRecordTypeId('Aborted Partner', 'Partner_Request__c', true);
   }
  
   insert partreqList;
   regId = partreqList.Id;
   system.debug('***PR Created:' + partreqList.id);

   if (currentStep.equals('Cloud Service Provider') || (currentStep.equals('segment') && partreqList.Primary_Channel_Model__c != 'CSP (Cloud Service Provider)')) {
    lead = populateLead(null, partreqList);
    insert lead;
   }
  }else if(currentStep.equals('Cloud Service Provider') || (currentStep.equals('segment') && partreqList.Primary_Channel_Model__c != 'CSP (Cloud Service Provider)') &&
           (partreqList.RecordTypeId == IdLookupUtils.getRecordTypeId('Aborted Partner', 'Partner_Request__c', true) ||partreqList.RecordTypeId == IdLookupUtils.getRecordTypeId('New Partner Admin', 'Partner_Request__c', true) )){
                    partreqList.Status__c = 'New';
                    partreqList.OwnerId = selcountObj.Partner_Support_Queue_ID__c;
                    partreqList.RecordTypeId = IdLookupUtils.getRecordTypeId('New Partner', 'Partner_Request__c', true);
                    update partreqList;
                    lead = populateLead(null,partreqList);
                    insert lead;
                                
  }else if(partreqList.Status__c == 'Incomplete' && (currentStep.equals('Cloud Service Provider') || (currentStep.equals('segment') && partreqList.Primary_Channel_Model__c != 'CSP (Cloud Service Provider)'))){
                    partreqList.Status__c = 'Re-submitted';
                    partreqList.OwnerId = selcountObj.Partner_Support_Queue_ID__c;
                    partreqList.RecordTypeId = IdLookupUtils.getRecordTypeId('New Partner', 'Partner_Request__c', true);
                    update partreqList;
                    lead = populateLead(getLead(partreqList.id),partreqList);
                    update lead;
                }
      
   if (lead != null && lead.id != null) {
    partreqList.Lead__c = lead.id;
    update partreqList;
   }
   Partner_Request__c regNumberRequest = [SELECT name, Primary_Channel_Model__c FROM Partner_Request__c where id = :partreqList.id];
    string registrationNumber = regNumberRequest.name;
     returnResult.partreqObj = partreqList;
     returnResult.countryEmail = countryEmail;
     returnResult.prNumber = registrationNumber;
      system.debug('***Pr Nub' +registrationNumber);
     }catch(Exception e){
       system.debug('****Excep: '+ e);
       returnResult.errorMsg =  e.getLineNumber() +''+ ':-' + e.getMessage();
     }
    return returnResult;
 }

    
 @TestVisible private static Lead getLead(ID regId) {
  Lead returnValue = null;
  List < Partner_Request__c > regList = [SELECT lead__c FROM Partner_Request__c WHERE id = : regId];
  if (!regList.isEmpty()) {
   ID leadId = regList.get(0).lead__c;
   List < Lead > leadList = [SELECT LastName, Company, Status, Partner_Request__c FROM Lead WHERE id = : leadId ];
   if (!leadList.isEmpty()) {
    returnValue = leadList.get(0);
   }
  }
  return returnValue;
 }

 @TestVisible private static Lead populateLead(Lead lead, Partner_Request__c partreqList) {
  Id IdLeadRT = StaticFactory.getRecordTypeIdByName('Lead', 'Lead Qualification');
  if (lead == null) {
   lead = new Lead();
  }
  lead.LastName = partreqList.Last_Name__c;
  lead.Company = partreqList.Company__c;
  lead.Status = 'Open';
  lead.Partner_Request__c = partreqList.ID;
  lead.OwnerID = partreqList.OwnerID;
  lead.RecordTypeId = IdLeadRT;
  lead.email = partreqList.email__c;
  lead.phone = partreqList.phone__c;
  lead.MobilePhone = partreqList.Mobile__c;

  return lead;
 }
    //Dependent Picklist
   /* @AuraEnabled
    public static Map < String, List < String >> getDependentMap(sObject objDetail, string contrfieldApiName, string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map < String, List < String >> objResults = new Map < String, List < String >> ();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType == null) {
            return objResults;
        }
        
        Map < String, Schema.SObjectField > objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
            return objResults;
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List < Schema.PicklistEntry > contrEntries = ctrlField.getDescribe().getPicklistValues();
        List < PicklistEntryWrapper > depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List < String > controllingValues = new List < String > ();
        
        for (Schema.PicklistEntry ple: contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List < String > ());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew: depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
     public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE64CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String BASE64CHARS = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List < PicklistEntryWrapper > wrapPicklistEntries(List < Schema.PicklistEntry > ples) {
        return (List < PicklistEntryWrapper > )
            JSON.deserialize(JSON.serialize(ples), List < PicklistEntryWrapper > .class);
    } */
    //Dependent End
 @AuraEnabled 
 public static void  doSendEmail(Partner_Request__c partreqObj, string selectedCountry, string matchAccId,string userDomain, string comments ){

list<user> partnerAdminList = new list<user>();
      system.debug('***account' +matchAccId+'***'+userDomain);
     partnerAdminList = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(matchAccId, userDomain);
     system.debug('***comments' +comments);
     
    country__c selcountObj = [select id,Name, User_Language_Locale_Key__c,Partner_Support_Email__c,Partner_Support_Queue_ID__c,code__c from country__c where name =: selectedCountry  limit 1]; 
    
    Account trackName = [Select Id,Partner_Track__r.Track_Name__c from Account where Id =:matchAccId Limit 1];
        
     system.debug('selcountObj'+selcountObj);
     String countryCode = countryMap.get(partreqObj.Country__r.code__c);
        list<string> domain = partreqObj.Email__c.split('@');
        PartnerRegistrationDomainDuplicateCheck.PartnerInfo info = new PartnerRegistrationDomainDuplicateCheck.PartnerInfo();
        info.Firstname = partreqObj.First_Name__c;
        info.Lastname = partreqObj.Last_Name__c;
        info.PhoneNumber = partreqObj.Phone__c;
        info.MobilePhone = partreqObj.Mobile__c;
        info.Email = partreqObj.Email__c;
        info.RegisteringCountry = selcountObj.Name;
        info.Comment = Comments;
        info.partnerTrack = selcountObj.code__c+'-'+partreqObj.select_your_secondary_business_type__c;
        PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, partnerAdminList);
     system.debug('***partnerAdminList' +partnerAdminList);
     system.debug('***1partreqObj' +partreqObj);
    }   
    
}
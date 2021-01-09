/* 
    REVISION HISTORY
    ================
    Version     Author      Date            Release#        CR#     Description
    -------     ------      ----            --------        ---     -----------
    1.0         Fenny       28-Mar-2012     13.4            7052    To fix an issue, to enable search partner by country
    1.1         Murphy      03-Apr-2012     13.4            7056    Hide or display Google Map based on search result
    2.0         Murphy      03-May-2012     13.7            7111    Migrate Google Maps API v2 to v3
    2.1         Fenny       04-May-2012     13.7            7112    Enable sort for Search Result
    2.2         Sandhya     18-May-2012     13.7            7105    Commented line 66 :assign the selected country to the SearchForm instance for query
    2.3         Fenny       02-Jun-2012     13.7            7108    Dell.com Look & Feel
    2.4         Sandhya     26-Jun-2012     13.7            7105    Defect fix 37047
    2.5         Fenny       04-Jul-2012     13.7                    Defect#: 36898, 37042, 37241: Too many script statements: 200001
    2.6         Fenny       09-Jul-2012     13.7            7112    CRQ 0397
    2.7         Fenny       13-Jul-2012     13.7                    Initialize boolean properties to prevent NullPointerException
    2.8         Sheeba      12-Jul-2012     13.7                    Defect#: 37825
    2.9         Fenny       15-Jul-2012     13.7                    Defect #37825
    2.10        Fenny       10-Aug-2012     13.7                    Defect #:41184
    3.0         Gan         18-Nov-2016     FY17-DCS-0103   13725   Baidu Map Implementation
    3.1         Sakshi      09-OCT-2019     FY20-0102               FAP - Separate Reset button for each partner type search page
    */
    global class FAP_PartnerSearchController extends FAP_PartnerFinderBaseController implements FAP_ObjectPaginatorListener{

        //==================================================
        // PROPERTIES
        //==================================================
        public Boolean isIE{get{return FAP_PageUtils.isIE();}}  // Ver 2.3
        public Boolean isChrome{get {return FAP_PageUtils.isChrome();}} // Ver 2.3
        public Boolean isFirefox{get {return FAP_PageUtils.isFirefox();}} // Ver 2.3
        public FAP_Configuration            config                      {get; private set;} 
        public FAP_SearchForm               form                        {get; private set;}
        public List<FAP_SearchHitWrapper>   hits                        {get; private set;} 
        public FAP_ObjectPaginator          paginator                   {get; set;} 
        public Boolean                      displayAdvancedSearchFlag   {get; set;}
        public Boolean                      displaySearchResultsFlag    {get; set;}
        public Boolean                      displaySearchResultsFlagMap {get; set;}
        public String                       sortColumn                  {get; set;}
        public String                       searchSerialized            {get; set;}
        public String                       strResetValue               {get; set;}
        public String                       paramString                 {get; set;}
        public String                       countryCode                 {get; set;}
        public String                       urlCountryCode              {get; set;} // Ver 2.10
        public String                       languageCode                {get; set;}
        public String                       languageCodeOmniture        {get; set;}// Added By Sree For Omniture Track
        public String                       urllanguagecode             {get; set;}
        public String                       urlpartnertype              {get; set;}  //FAP Link-Partner Type
        public String                       nullValue                   {get; set;}
        public String                       regionValue                 {get; set;}
        public String                       language                    {get; set;}
        Public Integer                      val  = 0;
        public string                       viewDetails                 {get;set;}       
        public string                       view                 {get;set;}       
        public string                       viewDe                 {get;set;}       

        private transient Map<String,String> mapServiceCompetency = new Map<String,String>();
        public List<FAP_Customization__c> partnerTypeList = null;
      
        //==================================================
        // CONSTRUCTOR  
        //==================================================
        public Boolean sandBox {get;set;}
        public String domainUrl {get;set;}
        public String country {get;set;}

        public void getipaddress(){
          string returnValue = '';  
          returnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
          if (returnValue == '' || returnValue == null) {
           returnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
          } 
          if (returnValue == '' || returnValue == null) {
           returnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
          }
          System.Debug('returnValue ipaddress##'+returnValue);
          try{
              Http h = new Http();
              HttpRequest req = new HttpRequest();
              //String endpoint = 'http://freegeoip.net/json/'+returnValue;
              String endpoint = 'https://ipinfo.io/'+returnValue+'/json?token=dell_internal';
              //String endpoint = 'http://ipinfo.io/'+returnValue+'/json';
              //String endpoint = 'http://www.geoplugin.net/json.gp?ip='+returnValue;
              //String endpoint = 'https://ipinfo.io/country?token=dell_internal';          
              req.setEndpoint(endpoint);
              req.setMethod('GET');
              HttpResponse res;
              res = h.send(req);
              //country = res.getBody().remove('\n');
              System.Debug('m##'+res.getBody());
              System.Debug('country##'+country);
              JSONParser parser = JSON.createParser(res.getBody());
              while (parser.nextToken() != null) {
                  if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'country')) {
                    {
                        parser.nextToken();
                        country = parser.getText();
                  }
               }
               System.Debug('country##'+country);
            
              }
          
        }catch(Exception e){
            System.Debug('Exception Occured'+e.getMessage());
          }
      }

        public FAP_PartnerSearchController(){
           
            // Ver 2.7
            displayAdvancedSearchFlag = false;
            displaySearchResultsFlag = false;
            displaySearchResultsFlagMap = false;            
            
            this.paramString = FAP_StringUtils.substringAfter(ApexPages.currentPage().getUrl(),'?');
            system.debug('###################### paramString  ' + this.paramString);
            system.debug('###################### URL would be   ' + ApexPages.currentPage().getUrl());
            this.countryCode =(FAP_PageUtils.param('c')!=null?FAP_PageUtils.param('c').toUpperCase():'');
            system.debug('-------------countryCode 1---'+countryCode );
            this.urlCountryCode = (FAP_PageUtils.param('urlc')!=null?FAP_PageUtils.param('urlc').toUpperCase():''); // Ver 2.10  
            system.debug('-------------urlCountryCode 1----'+urlCountryCode );
            this.languageCode = (FAP_PageUtils.param('l')!=null?FAP_PageUtils.param('l').toUpperCase():''); 
            system.debug('-------------languageCode ----'+languageCode );
            this.urllanguagecode = (FAP_PageUtils.param('urll')!=null?FAP_PageUtils.param('urll').toLowerCase():'');  
            system.debug('-------------urllanguagecode 1----'+urllanguagecode );   
            if(countryCode != null || countryCode != ''){
                system.debug('-------------countryCode in region call----'+countryCode );   
                setUpRegion(countryCode);
            }       
            
            if(countryCode==null || countryCode==''){
                this.setUserCountry();
            }
            if((urlCountryCode == null) || (urlCountryCode.trim().length() == 0)){
                this.urlCountryCode = this.countryCode;
            }
            if((urllanguagecode == null) || (urllanguagecode.trim().length() == 0)){
                system.debug('-------------urllanguagecode 2---'+this.languagecode );  
                this.urllanguagecode = this.languagecode;
             }
            //Start - Added For Omniture Tool Report Purpose By Sree On 07-Jan-16
            if(this.languagecode.length()>4){           
            this.languageCodeOmniture = this.languagecode.substring(0,2);
            }
            else{
            this.languageCodeOmniture = this.languagecode;
            }
            //End By Sree
            
            this.urlpartnertype  = (FAP_PageUtils.param('pt')!=null?FAP_PageUtils.param('pt').toLowerCase():'');
                       
            search();
            viewDetails=Label.btnViewDetails;
            System.debug('@*@*@*@*@*@* CountryCode :: '+ countryCode);        
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');// For Partner boxes show out of place in FAP page in IE -- Added By Sree
            //ApexPages.currentPage().getParameters().put('X-Content-Type-Options', 'nosniff');// For Logo display in IE issue test purpose -- Added By Sree        
        }      
        
        //==================================================
        // ACTIONS
        //==================================================
        public pageReference doOnLoad(){    
            
            try{
                //GAN POC
                //this.country = 'CN';
                try{
                getipaddress();
                }
                catch(Exception ex){
                  System.Debug('Exception Occured doOnLoad'+ex.getMessage());
                }
                
                this.config = FAP_Configuration.getInstance();
                system.debug('======config====='+config.googleMapsApiURL);
                this.hits = new List<FAP_SearchHitWrapper>();
                this.paginator = new FAP_ObjectPaginator(this);
                system.debug('====paginator ======='+paginator );
                this.form = FAP_SearchForm.deSerialize(this.paramString);
                system.debug('this.paramString)>>>>>>>>>>' + this.paramString);
                //domainUrl = System.URL.getSalesforceBaseURL().getHost();
                Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
            
                if(org.IsSandbox){
                    sandBox = true;
                }else{
                    sandBox = false;
                }
                
                if(FAP_StringUtils.isEmpty(form.countryCode) && !FAP_StringUtils.isEmpty(this.countryCode)){ form.countryCode = this.countryCode; }
                    if(FAP_StringUtils.isEmpty(form.urlCountryCode) && !FAP_StringUtils.isEmpty(this.urlCountryCode)){ form.urlCountryCode = this.urlCountryCode; } // Ver 2.10
                        if(!form.isBlank){
                            System.debug('~~~~~~~~~~~form '+form);
                            return search(); 
                        } 
                this.displayAdvancedSearchFlag = !form.advancedFieldsAreBlank;
            
            }
            catch(Exception ex){
                system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: FAP_PartnerSearchController | Method: doOnLoad]');          
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                    'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                    '[FAP_PartnerSearchController Line ' + ex.getLineNumber() + 
                    ': [' + ex.getTypeName() + ']' +
                    ': ' + ex.getMessage() + ']'));
            }
            
            return null; 
        }
         
        public PageReference searchClicked(){ 
            // Ver 2.1: If 'Sort by' is Distance, location is required
            //return search();  
            return sortByRefresh(); 
        } 
        
        public PageReference refresh(){ 
            return null;
        }
        
        //Ver 2.4 Defect fix 37047
        public PageReference resetPage(){ 
           String redirectStr = ApexPages.currentPage().getURL();            
           return(FAP_PageUtils.redirect(redirectStr));
           
         }     

            
        // Ver 2.1: This action method is being invoked first to validate the location before do search
        public PageReference sortByRefresh(){
            // Ver 2.5: To fix 'Too many script statements: 200001'
            //if(StringUtils.equalsIgnoreCase(form.sortOption, Label.PartnerSearchDistance) && StringUtils.isEmpty(form.address)){
           
            try{

                if((((form.sortOption != null) && (Label.FAP_Distance!= null) && form.sortOption.equalsIgnoreCase(string.valueOf(3)))) &&      ((form.address == null) || (form.address.length() == 0))){
                    System.Debug('Entered If');
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.FAP_Alert_Distance_Required));
                }else{
                    System.Debug('Entered Else');
                    return search();
                }
            }catch(FAP_FAPLimitException ex){
                system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerSearchController | Method: sortByRefresh]');          
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.FAP_Alert_Search));
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                    'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                    '[PartnerSearchController Line ' + ex.getLineNumber() + 
                    ': [' + ex.getTypeName() + ']' +
                    ': ' + ex.getMessage() + ']'));
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                    'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                    '[PartnerSearchController Line ' + ex.getLineNumber() + 
                    ': [' + ex.getTypeName() + ']' +
                    ': ' + ex.getMessage() + ']'));
            }
          
            return null;     
        }
        
        public PageReference search(){
            System.debug('In search *************** ');              
            ApexPages.getMessages().clear(); 
                  
            if(form != null){
                // Ver 1.0: Assign the selected country to the SearchForm instance for query
                 this.paginator.setRecords(
                    wrap(
                        new FAP_Search(
                            form.getAttributeSearchCriteria()
                            ,form.getGeoSearchCriteria()
                            ,form.getOrderBy() // Ver 2.1; Get the sorting option from UI
                            
                        )
                        .addFields(buildFieldsInResultListForQueryAsSet(this.config))
                        .execute()
                    )
                );               
                
                system.debug('form.pageNumber: ' + form.pageNumber);
                /* <START> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
                    if(Integer.valueOf(form.pageNumber) > 0) {
                    if(Integer.valueOf(this.form.pageNumber) >= paginator.pageCount) {
                    this.form.pageNumber = String.valueOf(this.paginator.pageNumber);
                    }else
                    {
                    this.paginator.skipToPage(Integer.valueOf(form.pageNumber));
                    }
                }
                /* <END> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
                
                this.displaySearchResultsFlag = true;
                this.searchSerialized = this.form.serialize();
                //version 3.1 START
                this.strResetValue = this.searchSerialized;
                this.strResetValue = this.strResetValue.substringAfter('&partner_track__c.partner_type__c=');
                this.strResetValue = this.strResetValue.substringBefore('&');
                //version 3.1 END
                //1.1 Display Google Map if result >= to 1
                if(hits.isempty()){      
                    this.displaySearchResultsFlagMap = false;
                }
                else{
                    this.displaySearchResultsFlagMap = true;
                }
            }
            
            System.debug('@*@*@*@*@*@* CountryCode :: '+ CountryCode); 
            return null; 
        } 
        
        public PageReference skipToLocation(){ 
            try{     

                this.paginator.skipToPage((Integer.valueOf(this.paginator.pageNumberDisplayFriendly) - 1 ));
                        
            }catch(FAP_FAPLimitException ex){
                system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: FAP_PartnerSearchController | Method: skipToLocation]');          
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                    'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                    '[PartnerSearchController Line ' + ex.getLineNumber() + 
                    ': [' + ex.getTypeName() + ']' +
                    ': ' + ex.getMessage() + ']'));
            }
            return null; 
        } 
        
        public PageReference toggleFilter(){
            this.displayAdvancedSearchFlag = !this.displayAdvancedSearchFlag;
            return null; 
        } 
        public PageReference sortData(){     
        
            return null;          
        } 

        //==================================================
        // DERIVED PROPERTIES
        //==================================================
      
        //2.0 Remove Google Maps API v2 Key
        public String googleMapsApiURL   { get{return config == null ? null : config.googleMapsApiUrl; }}
       
        //3.0 GAN POC
        public String strBaiduMapsApiUrl   { get{return config == null ? null : config.baiduMapsApiUrl; }}
        public String locationsJSON      { get{return FAP_SearchHitWrapper.toJSON(hits);} set;}        
        
        public Boolean hitMaxSearchResults{ get{return paginator != null && paginator.all != null && paginator.all.size() >= FAP_Configuration.getInstance().searchMaxResults;}}
       
        
        // Ver 2.1: Get a list of sort optons
        public List<SelectOption> sortOptions{
            get{
                sortOptions = sortOptions == null ? new List<SelectOption>() : sortOptions;
                if(sortOptions.size() == 0){
                    sortOptions.add(new SelectOption(string.valueOf(0), Label.FAP_Sort_By));
                    sortOptions.add(new SelectOption(string.valueOf(1), Label.FAP_Company_Name));
                    //sortOptions.add(new SelectOption(string.valueOf(2), Label.FAP_Partner_Status));
                    sortOptions.add(new SelectOption(string.valueOf(3), Label.FAP_Distance)); 
            }
                return sortOptions;
            }
            private set;
        }
        
       
        
        //==================================================
        // HELPER METHODS
        //==================================================
        global void handlePageChange(List<Object> records){
            try{
                this.hits.clear();
                if(records != null && records.size() > 0){
                    for(Object record : records){
                       /* if(Limits.getScriptStatements() >= config.scriptStatementLimit) { 
                        throw new FAPLimitException(); 
                        } // Ver 2.9
                        */
                        this.hits.add((FAP_SearchHitWrapper)record);
                    }
                }
                
            }
            
            catch(FAP_FAPLimitException ex){
                system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: FAP_PartnerSearchController | Method: skipToLocation]');          
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                    'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                    '[PartnerSearchController Line ' + ex.getLineNumber() + 
                    ': [' + ex.getTypeName() + ']' +
                    ': ' + ex.getMessage() + ']'));
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                    'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                    '[PartnerSearchController Line ' + ex.getLineNumber() + 
                    ': [' + ex.getTypeName() + ']' +
                    ': ' + ex.getMessage() + ']'));
            }
            /* <START> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
            if(this.paginator.pageNumber > 0) {
                this.form.pageNumber = String.valueOf(this.paginator.pageNumber);
                this.searchSerialized = this.form.serialize();
            }
            /* <END> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
        }

        public List<SelectOption> getSortColumnList() {
            final List<SelectOption> returnValue = new List<SelectOption>();
            if( config != null 
                && config.searchScreenSortableFields != null 
                && config.searchScreenSortableFields.size() > 0){
                for(FAP_FieldConfiguration field : config.searchScreenSortableFields){
                    if(field != null){
                        returnValue.add(new SelectOption(field.name,field.label));
                    }
                }
            }
            System.debug('@*@*@*@*@*@* CountryCode :: '+countryCode); 
            return returnValue;
        }

        public List<String> getMessages(){
            List<String> msgList= new List<String>();
            for(ApexPages.Message msg:ApexPages.getMessages()){
                msgList.add(msg.getSummary());
            }
            return msgList;
        }
        
        private List<FAP_SearchHitWrapper> wrap(List<FAP_SearchHit> hits){
            system.debug('^^^^^ hits - ' + hits);
            final List<FAP_SearchHitWrapper> wrappedHits = new List<FAP_SearchHitWrapper>();
            if(hits != null && hits.size() > 0){
                final FAP_FieldIndex fieldIndex = new FAP_FieldIndex().indexType(
                    new List<Schema.DescribeSObjectResult>{
                        Schema.sObjectType.Account,
                        Schema.sObjectType.Partner_Location__c
                    }
                );
                for(FAP_SearchHit hit : hits){
                  // Ver 2.9
                    wrappedHits.add(new FAP_SearchHitWrapper(hit,this.config)); 
                }
            }
            System.debug('@*@*@*@*@*@* CountryCode :: '+countryCode); 
            System.debug('@*@*@*@*@*@* logorecId :: '+wrappedHits);  
            
            return wrappedHits;
        }
        
        private void setUserCountry(){
            system.debug('used id------------------'+UserInfo.getUserId());
            User usr = [Select u.Contact.MailingCountry, u.ContactId From User u Where Id = :UserInfo.getUserId()];
            if(usr.ContactId!=null && usr.Contact.MailingCountry!=null){
                Schema.DescribeFieldResult f = Partner_Location__c.Country__c.getDescribe();
                List<Schema.PicklistEntry> entries = f.getPicklistValues();
                for(Schema.PicklistEntry entry: entries){
                    if(entry.getLabel().contains(usr.Contact.MailingCountry) || 
                       entry.getValue().contains(usr.Contact.MailingCountry)){
                        Integer index1 = entry.getValue().lastIndexOf('(');
                        Integer index2 = entry.getValue().lastIndexOf(')');
                        
                        system.debug('Mailing Country in contact ' + usr.Contact.MailingCountry + ' Country in PickList   ' + entry.getValue().subString(index1+1, index2));
                        
                        if(index1>=0 && index2>index1){
                            this.countryCode = entry.getValue().subString(index1+1, index2);
                        }
                    }
                }   
            }
            System.debug('@*@*@*@*@*@* CountryCode :: '+countryCode); 
        }

        private static Set<Object> buildFieldsInResultListForQueryAsSet(FAP_Configuration config){
            final Set<Object> fields = new Set<Object>();
            // Ver 2.5: To fix 'Too many script statements'
            if(config != null){
                List<FAP_FieldConfiguration> fieldConfigs = config.searchScreenFieldsInResultList;
                system.debug('##### - fieldConfigs ' + fieldConfigs);
                if(fieldConfigs != null && fieldConfigs.size() > 0){
                    for(FAP_FieldConfiguration fieldConfiguration : fieldConfigs){
                        if(fieldConfiguration != null){
                            fields.add((FAP_Configuration.strObjectName.equalsIgnoreCase(fieldConfiguration.objectName) ? FAP_Configuration.keyValue  : '') 
                                        + fieldConfiguration.fieldName);
                        }
                    }
                }
            }
            system.debug('^^^^^ return fields to search() - ' + fields);
            return fields;
        }

      /*  private static String fieldConfigurationToFieldName(FAP_FieldConfiguration fieldConfiguration){
            String returnValue = null;
            if(fieldConfiguration != null){
                returnValue = (FAP_Configuration.strObjectName.equalsIgnoreCase(fieldConfiguration.objectName) ? FAP_Configuration.keyValue  : '') 
                    + fieldConfiguration.fieldName;
            }
            return returnValue;
        }
        */
        public void setUpRegion(string cCode){  
            Map<string, string> countryCodeCountryMap = new Map<string, string> ();
            Schema.DescribeFieldResult f = Partner_Location__c.Country__c.getDescribe();
            List<Schema.PicklistEntry> entries = f.getPicklistValues();
            for(Schema.PicklistEntry entry : entries){
              Integer index1 = entry.getValue().lastIndexOf('(');
              Integer index2 = entry.getValue().lastIndexOf(')');
              countryCodeCountryMap.put(entry.getValue().subString(index1+1, index2), entry.getLabel());
            }
            string userCountry = countryCodeCountryMap.get(cCode);    
            FAP_Country__mdt uCountry = [SELECT FAP_Country_Value__c,Region__c,User_Language_Locale_Key__c FROM FAP_Country__mdt where FAP_Country_Value__c =: userCountry LIMIT 1 ]; 
            if (uCountry != null){
                this.regionValue = uCountry.Region__c;
                this.language = uCountry.User_Language_Locale_Key__c;
            } 
        }
    }
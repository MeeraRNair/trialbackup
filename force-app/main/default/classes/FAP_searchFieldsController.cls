/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Sakshi     31-Oct-2019      FY20-0102   18271   FAP - Availability of Country and State search for CSP separately - FAP Part

*/
public class FAP_searchFieldsController{

    public String thisRegion { get; set; }
    public FAP_SearchForm formFields;
    public FAP_Configuration configFields;
    public FAP_SearchUtils searchUtilsVal;
    //public FAP_Customization__c fapCustObj{get;set;}
    public List<FAP_SetOfThreeSearchFields> basicFields {get;set;}
    public List<SelectOption> countryList { get; private set; }    
    public List<FAP_SetOfThreeSearchFields>fapAdvancedFields;
    public Boolean isIE{get{return FAP_PageUtils.isIE();}}  // Ver 1.1
    public Boolean isChrome{get {return FAP_PageUtils.isChrome();}} // Ver 1.1
    public Boolean isFirefox{get {return FAP_PageUtils.isFirefox();}} // Ver 1.1
    Map<String,String>indexMap = new Map<String,String>(); // Ver 1.3    
    public String country {get;set;}
    //public String address {get;set;}
    //public String strSelected  {get;set;}  //mychanges
    //public string selectCountries{get;set;} //mychanges
    public Boolean bCSPPT; //CSP change
    public string strPT; //CSP change
   // public string selectedPartner { get; set; }

    transient private Map<String,List<SelectOption>> mapCompCategory {get;set;}
    //public String strsubComp{get;set;}
    //public String strCompCateg{get;set;}
    public Boolean bDisplayCategory {get;set;}
    
    //1.0 start
    public String strCountrySelected        { get; set;}
    public List<SelectOption> listStatesDisplay   {get; set;}
    
    //1.0 end
         
         
    public FAP_searchFieldsController(){
        system.debug('##### inside constructor');
        basicFields =  new List<FAP_SetOfThreeSearchFields>();
        countryList = new List<SelectOption>();
        country = FAP_SearchUtils.ipCountry;
        system.debug('##### country -->'+country);
        bDisplayCategory = true;

        // Ver 1.3 Tranlsation for Region and country drop down
        // Populate a map with field name and field API name
        Map<String, Schema.SObjectField> objectFieldMap = Schema.SObjectType.FAP_Translation__c.fields.getMap();//Schema.getGlobalDescribe().get('FAP Translation').getDescribe().Fields.getMap();
        system.debug('##### ObjectFieldMap - Translation -->'+objectFieldMap);
        if (objectFieldMap != null){
            for (Schema.SObjectField ft : objectFieldMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                indexMap.put(fd.getLabel(),fd.getName());
                system.debug('##### indexMap -->'+indexMap);
            }
        }
        
        //1.0 start
        listStatesDisplay = new List<SelectOption>();

        if(String.isBlank(strCountrySelected)){
            
            strCountrySelected = system.CurrentPageReference().getParameters().get('service_offering__c.data_center_country__c');
            if(!String.isBlank(strCountrySelected)){
                showStates();
            }
        }
        //1.0 end
    }
    
    public PageReference refreshRegion(){
        system.debug('?????????????????? Calling this');
        return null;
    }
    
    public PageReference doFilter(){
    
        system.debug('############### AJAX refresh   ');
        return null;
    }
    
    //Emd Test Method
    
    /* Method to refresh the countrylist when a region is selected*/
    public PageReference refreshCountry(){
        countryList = new List<SelectOption>();
        
        if(formFields.region == Null){
            
            countryList = getAllCountries();
            system.debug('##### countryList -->'+countryList);
        }
        else{
            try{
                //Ver 1.2 To fix 'Too many script statements'
                countryList.add(new SelectOption('',Label.None));
                List<string>countryTemList = new List<String>();
                String regionTemp = (formFields.region!= null?String.escapeSingleQuotes((formFields.region).trim()):'') ;
                system.debug('##### regionTemp -->'+regionTemp);
                for(sObject sObj1 : Database.query( // Ver 1.5
                               'select FAP_Region__c,Region__c,FAP_Country_Value__c,Enable_for_FAP__c from FAP_Country__mdt' 
                               + ' where FAP_Region__c = \'' + regionTemp+ '\' and Enable_for_FAP__c = True order by FAP_Country_Value__c')){   //Changed from Country__c to metadata FAP_Country__mdt            
                    //Ver 1.3 Translation of Region and Country drop down
                    system.debug('##### sObj1 -->'+sObj1);
                    countryTemList.add((String)sObj1.get('FAP_Country_Value__c'));
                    system.debug('##### countryTemList -->'+countryTemList);
               }  
               //Ver 1.3 Translation of Region and Country drop down 
               Map<String,String>translatedMap = new Map<String,String>();
               translatedMap = translateStringList(countryTemList);
               system.debug('##### translatedMap -->'+translatedMap);
               for(String str : countryTemList){
                    String value = extractCountryCode(str);
                    system.debug('##### value -->'+value);
                    if(value != null && value != '' && translatedMap.get(str) != null){
                        countryList.add(new SelectOption(value , translatedMap.get(str)));
                    } 
                    system.debug('##### countryList -->'+countryList);
               }
            }catch(Exception e){}
        }
          
        return null;
    }
    public PageReference dCountry(){
        string cName = '';
        cName = (FAP_CountryUtils.PartnerCountryMap.get(formFields.countryCode) != null?String.escapeSingleQuotes(FAP_CountryUtils.PartnerCountryMap.get(formFields.countryCode).trim()):'') ;
        system.debug('##### cName -->'+cName);
        for(FAP_Country__mdt obj :[SELECT Id,DeveloperName,FAP_Country_Value__c,Units__c FROM FAP_Country__mdt WHERE FAP_Country_Value__c =: cName]){
            system.debug('##### obj -->'+obj);          
            formFields.unit = obj.Units__c;   
            system.debug('##### formFields.unit -->'+formFields.unit);      
        }
        system.debug('test naga@@:'+ formFields.unit);
        return null;
    }
        
    public FAP_SearchForm getformFields(){
        system.debug('##### formFields@:'+formFields);//to test
        system.debug('##### formFields.basicSearchFieldSet@:'+formFields.basicSearchFieldSet);//to test
        return formFields;
    }
    public void setformFields(FAP_SearchForm  formFields){
        system.debug('##### formFields -->'+formFields); 
        this.formFields = formFields;
    }
       
    public FAP_Configuration getconfigFields(){
        system.debug('##### configFields -->'+configFields); 
        return configFields;
    }
    public void setconfigFields(FAP_Configuration  configFields){
        system.debug('##### configFields -->'+configFields); 
        this.configFields = configFields;        
    }
     public List<FAP_SetOfThreeSearchFields> getfapbasicfields(){
         //system.debug('##### formFields.basicSearchFieldSet -->'+formFields.basicSearchFieldSet); 
         return formFields.basicSearchFieldSet;
    }
    
    public void setfapbasicfields(List<FAP_SetOfThreeSearchFields> fapbasicfields){
    }
    
     public List<FAP_SetOfThreeSearchFields> getfapAdvancedFields(){
        return formFields.advancedFieldsSet;
    }
    
    public void setfapAdvancedFields(List<FAP_SetOfThreeSearchFields> fapAdvancedFields){
        this.fapAdvancedFields =  fapAdvancedFields;
    }
       
    private Map<String,String> getCountryMap(List<Schema.PicklistEntry> entries){
        Map<String,String> countryCodeLabelMap = new Map<String,String>();
        system.debug('##### entries -->'+entries); 
         
        for(Schema.PicklistEntry entry : entries){
            String value = extractCountryCode(entry.getValue());
            countryCodeLabelMap.put(value, entry.getLabel());
            system.debug('##### value -->'+value); 
            system.debug('##### countryCodeLabelMap -->'+countryCodeLabelMap); 
        }
        return countryCodeLabelMap;
    } 
    
    private String extractCountryCode(String value){
        system.debug('##### value -->'+value);
        if(value.contains('(') && value.contains(')')){
            Integer index1 = value.lastIndexOf('('); //StringUtils.indexOf(value, '(');
            Integer index2 = value.lastIndexOf(')');
            system.debug('##### index1 -->'+index1);
            system.debug('##### index2 -->'+index2);
            system.debug('##### value -->'+value.subString(index1+1, index2));
            return value.subString(index1+1, index2);
        }
        else{
            return value;
        }
    }
    
    /* Method to display the region dropdown */
    public List<SelectOption> getRegions(){
        List<SelectOption> options = new List<SelectOption>();
        try{
            //Ver 1.2 To fix 'Too many script statements'
            options.add(new SelectOption('',Label.None));
            Set<String>regionSet = new Set<String>();
            for(sObject sObj : Database.query(
                               'select FAP_Region__c,Region__c,FAP_Country_Value__c,Enable_for_FAP__c from FAP_country__mdt' 
                               + ' where Enable_for_FAP__c = True and FAP_Region__c!='+'null'+' Order By FAP_Region__c')){
                system.debug('##### sobj -->'+sobj);
                if((sObj.get('FAP_Region__c') != null)&&
                   ((String)sObj.get('FAP_Region__c') != '')){
                    regionSet.add((String)sObj.get('FAP_Region__c'));  
                } 
                system.debug('##### regionSet -->'+regionSet);
            }
            List<String> regionList = new List<String>();
            regionList.addAll(regionSet);
            system.debug('##### regionList -->'+regionList);
            regionList.sort();
            //Ver 1.3 Translation of Region and Country drop down 
            Map<String,String>translatedMap = new Map<String,String>();
            translatedMap = translateStringList(regionList);
            for(String str: regionList){
                if(str != null && str != '' && translatedMap.get(str) != null && translatedMap.get(str) != '')
                options.add(new SelectOption(Str , translatedMap.get(Str)));
            }
            system.debug('##### options -->'+options);
        }catch(Exception e){
            System.debug('Exception Occurred');
        }
        return options;
    }
    
    /* Method to display country dropdown*/
    public List<SelectOption> getCountries(){
        List<SelectOption> options = new List<SelectOption>();
        if(formFields.region == Null){ // When region is null, display all countries
           options = getAllCountries(); //Ver 1.2 To fix 'Too many script statements'
           system.debug('##### options -->'+options);
        }
        else{
            try{
                //Ver 1.2 To fix 'Too many script statements'
                //RP US: Remove Labels from picklsit and use the first value as label
                //options.add(new SelectOption('',Label.None));
             //   options.add(new SelectOption('','Country')); Commented By FAP Team to fix view state error
                List<string>countryTemList = new List<String>();
                // Ver 1.5
                String regionTemp = (formFields.region!= null?String.escapeSingleQuotes((formFields.region).trim()):'') ; 
                system.debug('##### regionTemp -->'+regionTemp);
                for(sObject sObj1 : Database.query( 
                               'select FAP_Region__c,Region__c,FAP_Country_Value__c,Enable_for_FAP__c from FAP_Country__mdt' 
                               + ' where FAP_Region__c = \'' + regionTemp + '\' and Enable_for_FAP__c = True and FAP_Country_Value__c!='+
                               'null'+' order by FAP_Country_Value__c')){ 
                    system.debug('##### sObj1 -->'+sObj1);
                    if(sObj1!=null){
                        //Ver 13. Translation for region and country drop down
                        countryTemList.add((String)sObj1.get('FAP_Country_Value__c'));
                    } 
                    system.debug('##### countryTemList -->'+countryTemList);
                }
                //Ver 1.3 Translation of Region and Country drop down 
                Map<String,String>translatedMap = new Map<String,String>();
                translatedMap = translateStringList(countryTemList);
                system.debug('##### translatedMap -->'+translatedMap);
                for(String tempStr : countryTemList){
                    String value = extractCountryCode(tempStr);
                    system.debug('##### value -->'+value);

                    if(value != null && value != '' && translatedMap.get(tempStr) != null)
                    {
                    options.add(new SelectOption(value, translatedMap.get(tempStr)));
                    }
                    
                    system.debug('##### options -->'+options);
                }
                translatedMap = null;
            }catch(Exception e){}
        }  
                
        return options;
    }
    
    /* Method to display all countries */
    public List<SelectOption> getAllCountries(){
        List<SelectOption> options = new List<SelectOption>();
        FAP_Configuration config = FAP_Configuration.getInstance();
        Schema.DescribeFieldResult f = Partner_Location__c.Country__c.getDescribe();
        
        system.debug('##### config -->'+config);
        system.debug('##### F -->'+F);
        system.debug('##### options -->'+options);
        
        List<Schema.PicklistEntry> entries = F.getPicklistValues();
        system.debug('##### entries -->'+entries);
        //RP US: Remove Labels from picklsit and use the first value as label
        //options.add(new SelectOption('','Country'));Commented By FAP Team to fix view state error
        Set<String> prioritizedCountrySet = new Set<String>();
        
        for(String cCode: config.prioritizedCountries){
            system.debug('##### config.prioritizedCountries -->'+config.prioritizedCountries);
            prioritizedCountrySet.add(cCode);
            system.debug('##### prioritizedCountrySet -->'+prioritizedCountrySet);
        }
        
        //Ver 1.3 Translation for Region and Country drop down
        //Ver 1.2 To fix 'Too many script statements'
        transient List<String> countryStrList = new List<String>();
               
        /* 
        * Commented by Susmitha and Shravan on Dec 13
        *  for(sObject sObj : Database.query(
        'select FAP_Region__c,Region__c,FAP_Country_Value__c,Enable_for_FAP__c from FAP_Country__mdt' 
        + ' where Enable_for_FAP__c = True and FAP_Country_Value__c!='+'null'+' order by FAP_Country_Value__c')){
        countryStrList.add((String)sObj.get('FAP_Country_Value__c'));  
        }
        //End of comments
        */
        //New code added by Susmitha and Shravan  on dec 13
        list<FAP_Country__mdt> countryList=[select FAP_Region__c,Region__c,FAP_Country_Value__c,Enable_for_FAP__c from FAP_Country__mdt where Enable_for_FAP__c = True and FAP_Country_Value__c!=null order by FAP_Country_Value__c ];
        system.debug('##### countryList -->'+ countryList);
        for(FAP_Country__mdt mdt : countryList){
            countryStrList.add(String.valueof(mdt.FAP_Country_Value__c));
        }
        system.debug('##### countryStrList -->'+ countryStrList);
        //End new code
        List<String> countryFullList = new List<String>();
        countryFullList.addAll(countryStrList);
        countryFullList.addAll(config.prioritizedCountries);
        //Ver 1.3 Translation of Region and Country drop down 
        Map<String,String>translatedMap = new Map<String,String>();
        translatedMap = translateStringList(countryFullList);
        
        system.debug('##### countryFullList -->'+ countryFullList);
        system.debug('##### translatedMap -->'+ translatedMap);
        
        Map<String,String> countryMap = getCountryMap(entries);
        system.debug('##### countryMap -->'+ countryMap);
        system.debug('##### config.prioritizedCountries -->'+ config.prioritizedCountries);

        for(String cCode: config.prioritizedCountries){
            if(cCode!=null && countryMap.containsKey(cCode) && translatedMap.get(countryMap.get(cCode)) != null){
                options.add(new SelectOption(cCode, translatedMap.get(countryMap.get(cCode))));
            }   
        }
        system.debug('##### options -->'+ options);

        //add a disabled item as a separator
        if(config.prioritizedCountries.size()>0){
            SelectOption option = new SelectOption('SEPARATOR','----');
            option.setDisabled(true);
            options.add(option);
        }
        system.debug('##### options -->'+ options);
              
        for(String entry : countryStrList){
            if(!prioritizedCountrySet.contains(entry)) {
                String value = extractCountryCode(entry);
                if(translatedMap.get(entry) != null && translatedMap.get(entry) != null)
                {
                options.add(new SelectOption(value,translatedMap.get(entry)));
                }
            }
        }
        system.debug('##### options -->'+ options);
        translatedMap = null;
        return options;
    }
    
    //Ver 1.3 Translation for Region and country drop down
    public Map<String,String> translateStringList(List<String> toTranslateStrList){
        Map<String,String>translateTempMap = new Map<String,String>();
        String translatedStr  = '';
        String lang = indexMap.get(formFields.usrLanguage);
        if(lang == null || lang.length()==0){   
            lang = 'English__c'; // If there is no match, set default as English
        }
        transient Map<String,FAP_Translation__c>existingTranslatedMap = new Map<String,FAP_Translation__c>();
        try{
           List<sObject>sObjectTransList = Database.query('select Value__c,Brazilian_Portuguese__c,Chinese_Simplified__c,'+
                                             'Chinese_Traditional__c,Czech__c,Danish__c,Dutch__c,'+
                                             'English__c,Finnish__c,French__c,German__c,Hungarian__c,'+
                                             'Italian__c,Japanese__c,Korean__c,Polish__c,Russian__c,'+
                                             'Spanish__c,Swedish__c,Thai__c,Turkish__c from FAP_Translation__c '+
                                             'where Value__c IN : toTranslateStrList');
            if(sObjectTransList.size()>0){
                for(sObject trans : sObjectTransList){
                    existingTranslatedMap.put((String)trans.get('Value__c'),(FAP_Translation__c)trans);
                } 
            }
            sObjectTransList = null;
        }catch(Exception e){
            system.debug('Exception Occurred');
        }
        for(String tempStr : toTranslateStrList){
            if(existingTranslatedMap.containsKey(tempStr)){
                FAP_Translation__c fapTrans = existingTranslatedMap.get(tempStr);
                translatedStr = '';
                translatedStr = (String)fapTrans.get(lang);
                 if(translatedStr == null || translatedStr.equalsIgnoreCase('NULL')||
                   translatedStr == '' ){
                   translatedStr = (String)fapTrans.get('English__c');
                    if((translatedStr == null) || (translatedStr  == '') ||
                        translatedStr.equalsIgnoreCase('NULL')){
                        translatedStr = tempStr;
                    }
                }
            }
            else{
                translatedStr = tempStr;
            }
            translateTempMap.put(tempStr,translatedStr);
        }
        existingTranslatedMap = null;
        return translateTempMap;
    }

    public PageReference getSubComptencyDetails(){
        String strUsrType = formFields.userType;   
        String strsubComp = formFields.strSubCompetency;        
        mapCompCategory = new Map<String,List<SelectOption>>();
        for(FAP_Competency__mdt subComp: [select id,Services_Comptency__c,Account_Competency__c,User_type__c from FAP_Competency__mdt where User_type__c=:strUsrType and Services_Comptency__c != 'null' ]){
            system.debug('##### subComp -->'+ subComp); 
            formFields.mapSubCompSearch.put(subComp.Services_Comptency__c,subComp.Account_Competency__c);
            if(!mapCompCategory.containsKey(subComp.Services_Comptency__c)){
                mapCompCategory.put(subComp.Services_Comptency__c,new List<SelectOption>());
            }           
            
            if(subComp.Account_Competency__c.containsIgnoreCase('Deployment') && subComp.Account_Competency__c.containsIgnoreCase('Support')){
                mapCompCategory.get(subComp.Services_Comptency__c).add(new SelectOption('Deployment',Label.Deployment));  //Use Custom lable here
                mapCompCategory.get(subComp.Services_Comptency__c).add(new SelectOption('Support',Label.Support));  //Use Custom lable here                    
            }

            mapCompCategory.put('All',new List<SelectOption>());
            mapCompCategory.get('All').add(new SelectOption('Deployment',Label.Deployment));
            mapCompCategory.get('All').add(new SelectOption('Support',Label.Support));
            mapCompCategory.get('All').add(new SelectOption('Consultancy',Label.Consultancy));

        }
        return null;
    }    

    public List<SelectOption> getSubComptencyList(){ 
        getSubComptencyDetails();
        List<SelectOption> listOptions = new List<SelectOption>();
        String strsubComp = this.formFields.strSubCompetency;
        String strTransLabel = '';
        try{            
            for(String subComp: formFields.mapSubCompSearch.KeySet()){ 
                if(subComp==Label.Converged_Hyper_Converged_Infrastructure_Services){
                    listOptions.add(new SelectOption(subComp,Label.Converged_Hyper_Converged_Infra_Services));
                }else if(subComp==Label.Hybrid_Cloud_Platform_Servics){
                    listOptions.add(new SelectOption(subComp,Label.Hybrid_Cloud_Platform_Services));
                }else if(subComp==Label.Data_Protection_Servics){
                    listOptions.add(new SelectOption(subComp,Label.Data_Protection_Services));
                }else if(subComp==Label.Server_Servics){
                    listOptions.add(new SelectOption(subComp,Label.Server_Services));
                }else if(subComp==Label.Client_Services_Deployment){
                    listOptions.add(new SelectOption(subComp,Label.Client_Services));
                }else if(subComp==Label.Storage_Servics){
                    listOptions.add(new SelectOption(subComp,Label.Storage_Services));
                }else if(subComp==Label.Networking_Servics){
                    listOptions.add(new SelectOption(subComp,Label.Networking_Services));
                }
            }
            system.debug('##### listOptions -->'+ listOptions); 
            if(String.isBlank(strsubComp)){
                bDisplayCategory = true;                
            }
            getCompCategory();
           
            }catch(Exception ex){
                system.debug('----Exception Occurred---'+ex.getStackTraceString());
                system.debug('----Exception Occurred---'+ex.getMessage());
            }
           
         return listOptions;   
    }

    public PageReference getCompCategory(){
       
        String strsubComp = formFields.strSubCompetency; 
        System.debug(strsubComp+'##### Selected Competency--'+bDisplayCategory);
        if(String.isBlank(strsubComp) || (mapCompCategory.containskey(strsubComp) && mapCompCategory.get(strsubComp).size() >= 2)){            
                bDisplayCategory = true;
            }else{
                bDisplayCategory = false;
                formFields.strCompCategory=null;
            }
        System.debug('bDisplayCategory--'+bDisplayCategory);
        return null;
    }

    public List<SelectOption> getCompCategoryList(){ 
        if(mapCompCategory == null){
            getSubComptencyDetails();
        }
        List<SelectOption> listOptions = new List<SelectOption>();
        System.debug('##### Sub Competency--'+formFields.strSubCompetency);
        System.debug('##### mapCompCategory--'+mapCompCategory);
        if(formFields.strSubCompetency != null && mapCompCategory.containskey(formFields.strSubCompetency)){
            listOptions.addAll(mapCompCategory.get(formFields.strSubCompetency));
        }else{
            listOptions.addAll(mapCompCategory.get('All'));
        }
        return listOptions;
    }

    
    public PageReference handlePartnerTypeChange(){
    
        String sel = Apexpages.currentPage().getParameters().get('selectedPartner');
       System.debug('##### TestCSP--'+sel);
        
        
        if(!String.isEmpty(sel) && (sel.contains('MSP') || (sel=='Cloud Service Provider'))){
            
            System.debug('###### TestCSP11--'+sel);
            this.formFields.setFieldConfig(formFields.searchCSPString,formFields.cspFieldsMap);   
            this.setfapbasicfields(this.formFields.basicSearchFieldSet);   
        }else if(!String.isEmpty(sel)){
                      
            System.debug('TestCSP22--'+sel);
            this.formFields.setFieldConfig(formFields.searchBasicFAPString,formFields.basicFieldsMap);
            this.setfapbasicfields(this.formFields.basicSearchFieldSet); 
        }
          
        return null;
    }

    public PageReference dummyFunction(){
        return null;
    }
    
    //1.0 start
    public PageReference showStates(){
        
        listStatesDisplay = new List<SelectOption>();
        for(FAP_Country__mdt objState: [select id,MasterLabel,States__c from FAP_Country__mdt where MasterLabel =: strCountrySelected]){             
            if(objState.States__c != null){
                for(String strState:objState.States__c.split(',')){
                    listStatesDisplay.add(new SelectOption(strState,strState));
                } 
            }
        } 
        return null; 
    }
    //1.0 end
}
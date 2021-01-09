/*
Find a Partner Utility Calss
*/
global class FAP_FieldConfiguration {

    //==================================================
    // PROPERTIES
    //==================================================
    private static final List<SelectOption> EMPTY_PICKLIST = new List<SelectOption>(); 
    private static FAP_Configuration configObj; // Ver 1.4
    //source: configuration variables
    global String               objectName {get;private set;}
    global String               fieldName {get;private set;}
    global String               applyToFieldName {get;private set;}
    //source: field describe
    global String               label           {get; private set;}
    global Integer              length          {get; private set;}
    global String               localName       {get; private set;}
    global String               name            {get; private set;}
    global List<SelectOption>   picklistValues  {get; private set;}
    global Schema.DisplayType   displayType     {get; private set;}
    /* Ver 1.0 Implement dynamic FAP search page */
    global String               helpText        {get; private set;}
    
    //==================================================
    // CONSTRUCTOR  
    //==================================================
    global FAP_FieldConfiguration(){}
 
    global FAP_FieldConfiguration(String objectName, String fieldName, String applyToFieldName){
        this.objectName = objectName;
        this.fieldName = fieldName;
        this.applyToFieldName = applyToFieldName;
    }

    //==================================================
    // HELPER METHODS
    //==================================================
    
    /**
     * Takes string like following:
     *
     * Account.Partner_Type_METADATA__c=>Partner_Type__c|Partner_Location__c.Is_Primary__c
     * 
     * parses it and returns a list of field configurations.  In case of above, two FieldConfiguration
     * record would be returned per following:
     * 
     * FieldConfiguration[objectName=Account,fieldName=Partner_Type_METADATA__c,applyToFieldName=Partner_Type__c]
     * FieldConfiguration[objectName=Partner_Location__c,fieldName=Is_Primary__c,applyToFieldName=Is_Primary__c]
     * 
     * @param configurationVariableValue raw configuration variable
     * @return a list of field configurations
     */
    

    // Ver 1.3: To fix 'Too many script statements'. Replaced FAP_StringUtils methods call to Apex String standard methods call
    global static List<FAP_FieldConfiguration> parse(final String configurationVariableValue){
        final List<FAP_FieldConfiguration> fieldList = new List<FAP_FieldConfiguration>();
        if((configurationVariableValue == null) || (configurationVariableValue.trim().length() == 0)){
            return fieldList;
        }
       FAP_FieldConfiguration current = null;
        String objectNameApplyTo = null;
        configObj = configObj == null ? FAP_Configuration.getInstance() : configObj; // Ver 1.4
        for(String unParsedField : configurationVariableValue.split('\\|')){
            //if(Limits.getScriptStatements() >= configObj.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 1.4
                        

            current = new FAP_FieldConfiguration();
            
            string unParsedFieldSubStrBefore = (unParsedField == null || unParsedField.trim().length() == 0 || !unParsedField.contains('=>')) ? unParsedField : unParsedField.trim().substring(0, unParsedField.trim().indexOf('=>'));
            string unParsedFieldSubStrAfter = (unParsedField == null || unParsedField.trim().length() == 0 || !unParsedField.contains('=>')) ? '' : unParsedField.trim().substring(unParsedField.trim().indexOf('=>') + 2, unParsedField.trim().length());
            
            string unTrimedObjectName = (unParsedFieldSubStrBefore == null || unParsedFieldSubStrBefore.trim().length() == 0) ? unParsedFieldSubStrBefore : unParsedFieldSubStrBefore.trim().substring(0, unParsedFieldSubStrBefore.trim().indexOf('.'));
            string unTrimedFieldName = (unParsedFieldSubStrBefore == null || unParsedFieldSubStrBefore.trim().length() == 0) ? unParsedFieldSubStrBefore : unParsedFieldSubStrBefore.trim().substring(unParsedFieldSubStrBefore.trim().indexOf('.') + 1, unParsedFieldSubStrBefore.trim().length());
            
            current.objectName = (unTrimedObjectName == null) ? unTrimedObjectName : unTrimedObjectName.trim(); 
            current.fieldName = (unTrimedFieldName == null) ? unTrimedFieldName : unTrimedFieldName.trim(); 
            objectNameApplyTo = null;
            current.applyToFieldName = (unParsedFieldSubStrAfter == null) ? unParsedFieldSubStrAfter : unParsedFieldSubStrAfter.trim();
            
            if((current.applyToFieldName != null) && (current.applyToFieldName.trim().length() != 0) && current.applyToFieldName.contains('.')){
                string applyToFieldNameSubStrBefore = current.applyToFieldName.trim().substring(0, current.applyToFieldName.trim().indexOf('.'));
                string applyToFieldNameSubStrAfter = current.applyToFieldName.trim().substring(current.applyToFieldName.trim().indexOf('.') + 1, current.applyToFieldName.trim().length());
                
                objectNameApplyTo = (applyToFieldNameSubStrBefore == null) ? applyToFieldNameSubStrBefore : applyToFieldNameSubStrBefore.trim();
                current.applyToFieldName = (applyToFieldNameSubStrAfter == null) ? applyToFieldNameSubStrAfter : applyToFieldNameSubStrAfter.trim();
            }
            
            if(((current.objectName != null) && (current.objectName.trim().length() != 0)) &&
                ((current.fieldName != null) && (current.fieldName.trim().length() != 0)) &&
                (
                    ((objectNameApplyTo == null) || (objectNameApplyTo.trim().length() == 0)) ||
                    (current.objectName.trim().equalsIgnoreCase(objectNameApplyTo))
                )){
                    fieldList.add(current);
            }
        }
        return fieldList;
    }

    global FAP_FieldConfiguration populateFieldsFromDescribe(Schema.DescribeFieldResult describe){
        if(describe != null){
            this.label           = describe.getLabel();
            this.length          = describe.getLength();
            this.localName       = describe.getLocalName();
            this.name            = describe.getName();
            this.displayType     = describe.getType();
            if( Schema.Displaytype.PICKLIST == this.displayType 
                || Schema.Displaytype.MULTIPICKLIST == this.displayType){
                this.picklistValues  = getSelectOptions(describe);
            } else {
                //this.picklistValues = EMPTY_PICKLIST; // Ver 1.3: To fix 'Too many script statements'
                this.picklistValues = new List<SelectOption>();
            }
        }
        return this;
    }    
    
    private List<SelectOption> getSelectOptions(Schema.DescribeFieldResult describe){
        final List<SelectOption> options = new List<SelectOption>();
        if(describe != null //&& Limits.getPicklistDescribes() < Limits.getLimitPicklistDescribes()
        ){
            for(Schema.PicklistEntry entry : describe.getPicklistValues()){
                options.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
        }
        return options;
    }
    
    /* 1.0 - CR 7105 - Implement dynamic FAP search page. Populate values from FAP_Customization__c to FieldConfiguration fields*/
    global static List<FAP_FieldConfiguration> populateFieldValues(List<FAP_FieldConfiguration> fieldConfiguration,
                                                                Map<String,FAP_Customization__c> fieldConfigMap,
                                                                String usrlanguage,FAP_Configuration config){
    
        Map<String,String>indexMap = new Map<String,String>();
        transient Map<String,FAP_Translation__c>existingTranslatedMap = new Map<String,FAP_Translation__c>();
        String lang = '';
        /* Ver 1.2: To fix 'Too many script statements' */
        Set<String> allStrFieldsSet = new Set<String>();
        for(FAP_FieldConfiguration fConfig : fieldConfiguration){
            //Field Label
            if(fieldConfigMap.containsKey(fConfig.fieldName)){
                if(fieldConfigMap.get(fConfig.fieldName).Field_label__c != null || 
                    fieldConfigMap.get(fConfig.fieldName).Field_label__c != ''){
                    allStrFieldsSet.add(fieldConfigMap.get(fConfig.fieldName).Field_label__c);
                }
            }
            //Help Text
            if(fieldConfigMap.get(fConfig.fieldName).Help_text__c != null || 
                fieldConfigMap.get(fConfig.fieldName).Help_text__c != ''){
                allStrFieldsSet.add(fieldConfigMap.get(fConfig.fieldName).Help_text__c);
            }
            //Drop down (Single picklist and Multi picklist)
            if(fieldConfigMap.get(fConfig.fieldName).Datatype__c == 'Dropdown' &&
                (fieldConfigMap.get(fConfig.fieldName).Name != 'Country__c.Country')&&
                (fieldConfigMap.get(fConfig.fieldName).Name != 'Country__c.Region')){
                if(fieldConfigMap.get(fConfig.fieldName).Pick_list_value__c != null && 
                    fieldConfigMap.get(fConfig.fieldName).Pick_list_value__c.contains('|')){
                    List<string> elements = fieldConfigMap.get(fConfig.fieldName).Pick_list_value__c.split('\\|'); // Fenny added: Because StringUtils.split calling StringUtils.charAt which hit exception
                    if((elements != null) && (elements.size() > 0)){
                        for(string element : elements){
                            List<string> keyValuePair = element.split('@'); // Fenny added: Because StringUtils.split calling StringUtils.charAt which hit exception
                            if(keyValuePair.size() == 2){
                                if(keyValuePair[0]!= null && keyValuePair[1]!= null){
                                    allStrFieldsSet.add(keyValuePair[0]);
                                }
                            }
                        }
                    }
                }
            }
        }
        //Get existing translations
        try{
            for(sObject obj : Database.query('select Value__c,Brazilian_Portuguese__c,Chinese_Simplified__c,'+
                                                 'Chinese_Traditional__c,Czech__c,Danish__c,Dutch__c,'+
                                                 'English__c,Finnish__c,French__c,German__c,Hungarian__c,'+
                                                 'Italian__c,Japanese__c,Korean__c,Polish__c,Russian__c,'+
                                                 'Spanish__c,Swedish__c,Thai__c,Turkish__c from FAP_Translation__c '+
                                                 'where Value__c IN : allStrFieldsSet')){
               if(!existingTranslatedMap.containsKey((String)obj.get('Value__c'))){
                  existingTranslatedMap.put((String)obj.get('Value__c'),(FAP_Translation__c)obj);
               }
           }
        }catch(Exception e){
            system.debug('Exception Occured');
        }
        //Populate a map with field name and field API name
        Map<String, Schema.SObjectField> objectFieldMap = Schema.SObjectType.FAP_Translation__c.fields.getMap();//Schema.getGlobalDescribe().get('FAP Translation').getDescribe().Fields.getMap();
        if (objectFieldMap != null){
            for (Schema.SObjectField ft : objectFieldMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    indexMap.put(fd.getLabel(),fd.getName());
            }
        }
        lang = indexMap.get(usrLanguage);
        if(lang == null || lang.length()==0){   
            lang = 'English__c'; // If there is no match, set default as English
        }
        for(FAP_FieldConfiguration fieldConfig : fieldConfiguration){ 
            //if(Limits.getScriptStatements() >= config.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 1.4
            if(fieldConfigMap.containsKey(fieldConfig.fieldName)){
                FAP_Customization__c fapObj = fieldConfigMap.get(fieldConfig.fieldName);
                if(existingTranslatedMap.containsKey(fapObj.Field_label__c)){
                    FAP_Translation__c fapTrans = existingTranslatedMap.get(fapObj.Field_label__c);
                    //Ver 1.5 Defect 39016: Translation missing
                    String fieldLabelStr = '';
                    fieldLabelStr = (String)fapTrans.get(lang);
                    if(fieldLabelStr == null || fieldLabelStr.equalsIgnoreCase('NULL')||
                       fieldLabelStr == ''){
                       fieldLabelStr = (String)fapTrans.get('English__c');
                    }
                    if(fieldLabelStr == null || fieldLabelStr.equalsIgnoreCase('NULL')){
                        fieldLabelStr = '';
                    }
                    fieldConfig.label = fieldLabelStr;
                    
                }
                else{
                    fieldConfig.label = fapObj.Field_label__c;
                }
                if(existingTranslatedMap.containsKey(fapObj.Help_text__c)){
                    FAP_Translation__c fapHelpTrans = existingTranslatedMap.get(fapObj.Help_text__c);
                    //Ver 1.5 Defect 39016: Translation missing
                    String helpTextStr ='';
                    helpTextStr = (String)fapHelpTrans.get(lang);
                    fieldConfig.helpText = '';
                    
                    if(helpTextStr == null || helpTextStr.equalsIgnoreCase('NULL')||
                        helpTextStr == ''){
                        helpTextStr = (String)fapHelpTrans.get('English__c');
                    }
                    if(helpTextStr == null || helpTextStr.equalsIgnoreCase('NULL')){
                        helpTextStr = '';
                    }
                    fieldConfig.helpText = helpTextStr;
                }
                else{
                    fieldConfig.helpText = fapObj.Help_text__c;
                }
                fieldConfig.name = fapObj.Name;// Goes as title
                String fapName ='';
                if(FAP_StringUtils.contains(fapObj.Name,'.')){
                    fapName = FAP_StringUtils.substringAfter(fapObj.Name,'.');
                }
                else{
                    fapName= fapObj.Name;
                }
                fieldConfig.applyToFieldName = fapName;//fapObj.Name;  // Goes into query
                fieldConfig.localName = fapName; // Ver 1.6
                if(fapObj.Datatype__c == 'Dropdown' && fapObj.Is_Multiselect__c == true){
                    fieldConfig.displayType = Schema.DisplayType.MULTIPICKLIST;
                }
                else if(fapObj.Datatype__c == 'Dropdown' && fapObj.Is_Multiselect__c == false){
                    fieldConfig.displayType = Schema.DisplayType.PICKLIST;
                }
                else{
                 fieldConfig.displayType = Schema.DisplayType.TEXTAREA;
                }
                if( fapObj.Datatype__c == 'Dropdown'){
                    Map<String,String>translatedMap = new Map<String,String>();
                    if(fapObj.Pick_list_value__c != null && 
                       fapObj.Pick_list_value__c.contains('|')){
                        List<String> picklistStrList= new List<String>();
                        //Ver 1.2 Enable Resellers/Distributor/Registered partners
                        Map<String,String>partnerTypeBusinessValues = new Map<String,String>();
                        List<string> elements = fapObj.Pick_list_value__c.split('\\|'); // Fenny added: Because StringUtils.split calling StringUtils.charAt which hit exception
                        if((elements != null) && (elements.size() > 0)){
                            for(string element : elements){
                                List<string> keyValuePair = element.split('@'); // Fenny added: Because StringUtils.split calling StringUtils.charAt which hit exception
                                if(keyValuePair.size() == 2){
                                    if(keyValuePair[0]!= null && keyValuePair[1]!= null){
                                        picklistStrList.add(keyValuePair[0]); 
                                        partnerTypeBusinessValues.put(keyValuePair[0], keyValuePair[1]);                                        
                                    }
                                }
                            }
                     }
                     final List<SelectOption> options = new List<SelectOption>();
                     
                      //v2.0 Start - To handle the partner type links from url
                     String urlpartnrtype  = (FAP_PageUtils.param('pt')!=null?FAP_PageUtils.param('pt').toLowerCase():'');
                     
                    
                    
                     List<string> pickListValLst=new List<string>();
                     List<string> urlpickListVal=new List<string>();
                     List<string> notUrlpickListValLst=new List<string>(); 
                     
                    if(urlpartnrtype!=null && urlpartnrtype!=''){
                        
                        pickListValLst=picklistStrList;
                        for(string fapCustPckList : pickListValLst){
                            
                            string ptnrType = fapCustPckList.deleteWhitespace();
                            if(ptnrType.toLowerCase() == urlpartnrtype){
                                urlpickListVal.add(fapCustPckList);
                            }
                            
                            if(!ptnrType.toLowerCase().contains(urlpartnrtype)){   
                                notUrlpickListValLst.add(fapCustPckList);
                            }
                            
                        }
                        picklistStrList.clear();
                        picklistStrList.addAll(urlpickListVal);
                        picklistStrList.addAll(notUrlpickListValLst);
                            
                    }
                    //v2.0 End - To handle the partner type links from url
                    
                     for(String str :picklistStrList){
                        if(existingTranslatedMap.containsKey(str)){
                            FAP_Translation__c fapTrans = existingTranslatedMap.get(str);
                            String value = (String)fapTrans.get(lang);                          
                            if(value == Null || value  == '' || value.equalsIgnoreCase('NULL')){
                            //Ver 1.5 Defect 39016: Translation missing
                                value = (String)fapTrans.get('English__c');
                                if(value == Null || value  == '' || value.equalsIgnoreCase('NULL')){
                                    value  = Str;
                                }
                            }
                            if(partnerTypeBusinessValues.containsKey(str)){
                                options.add(new SelectOption(partnerTypeBusinessValues.get(str),value));
                                
                            }
                        }
                        else{
                            if(partnerTypeBusinessValues.containsKey(str)){
                                options.add(new SelectOption(partnerTypeBusinessValues.get(str),str));                                
                            }
                        }
                     }
                     fieldConfig.picklistValues   = options; 
                 
                    }
                }
            } 
        }
        system.debug('----fieldConfiguration---'+fieldConfiguration);
        return fieldConfiguration;
    }     
}
global virtual class FAP_FormField {

    //==================================================
    // PROPERTIES
    //==================================================
    global String               objectName      {get; private set;}
    global String               fieldName {get; private set;}
    global String               label           {get; set;}
    global Integer              length          {get; private set;}
    global String               localName       {get; private set;}
    global String               name            {get; private set;}
    global List<SelectOption>   picklistValues  {get; private set;}
    global Schema.DisplayType   displayType     {get; private set;}
    global String               value           {get; set;}
    global List<String>         values          {get; set;}
    /* Ver 1.0 Add help text field  for dynamic display */
    global String               helpText        {get; set;}
    

    //==================================================
    // CONSTRUCTOR  
    //==================================================
    global FAP_FormField(FAP_FieldConfiguration configuration){
        this.objectName      = configuration.objectName;
        this.fieldName       = configuration.fieldName;
        this.label           = configuration.label;
        this.length          = configuration.length;
        this.localName       = configuration.localName;
        this.name            = configuration.name;
        this.picklistValues  = configuration.picklistValues;
        this.displayType     = configuration.displayType;
        this.value           = null;
        this.values          = new List<String>();
        this.helpText        = configuration.helpText;
    }
    global FAP_FormField(String fieldName){
        this.fieldName       = fieldName;
    }
    //==================================================
    // DERIVED PROPERTIES
    //==================================================
    global String fieldType {get{ 
        return FAP_StringUtils.remove('' + displayType,'Schema.DisplayType.');
    }}
    
    global Boolean blank {get{
        Boolean returnValue = true;
        if(test.isRunningTest() && FAP_SearchFormTest.testVariable){
            this.value = 'test';
            this.values = new List<String>{'Compellent','Wyse'};
        }
        if(isMultiselectPicklist){
            if(values != null && values.size() > 0){
                returnValue = false;
            }
        } else {
            returnValue = (typedValue == null);   
        } 
        return returnValue;
    }}

    global Boolean notBlank {get{ 
        return !blank; 
    }}
    
    global Boolean isPicklist {get{ 
        return Schema.Displaytype.PICKLIST == displayType; 
    }}

    global Boolean isMultiselectPicklist {get{ 
        return Schema.Displaytype.MULTIPICKLIST == displayType; 
    }}
    
    global void populate(String str){
        if(isMultiselectPicklist){
            values = FAP_StringUtils.isBlank(str) ? new List<String>() : FAP_StringUtils.split(str, ';');
        } else {
            value = str;
        }
    }
    
    global Object typedValue {get{
        Object returnValue = null;
        if(isMultiselectPicklist){
            returnValue = FAP_StringUtils.joinArray(values,';');
        } else if(FAP_StringUtils.isNotBlank(value)){
            if(Schema.DisplayType.BOOLEAN == displayType){
                returnValue = 'true'.equalsIgnoreCase(value);
            } else if(Schema.DisplayType.DOUBLE == displayType
                      || Schema.DisplayType.PERCENT == displayType
                      || Schema.DisplayType.CURRENCY == displayType){
                try{ returnValue = Double.valueOf(value); } catch(System.TypeException e){}
            } else if(Schema.DisplayType.INTEGER == displayType){
                try{ returnValue = Integer.valueOf(value); } catch(System.TypeException e){}
            } else { 
                returnValue = value;
            }
        }
        return returnValue;
    }}

    global Object typedValueLabel {get{
        Object returnValue = null;
        if(isMultiselectPicklist){
            returnValue = FAP_StringUtils.joinArray(picklistValueToLabel(values),'; ');
        } else if(isPicklist){
            returnValue = picklistValueToLabel(value);
        } else {
            returnValue = typedValue;
        }
        return returnValue;
    }}

    //==================================================
    // HELPER METHODS
    //==================================================
    private String picklistValueToLabel(String value){
        String returnValue = value;
        final List<String> result = picklistValueToLabel(new List<String>{value});
        if(result != null && result.size() > 0){
            returnValue = result.get(0);
        }
        return returnValue;
    }
    
    private List<String> picklistValueToLabel(List<String> values){
        final Map<String,String> index = new Map<String,String>();
        if(picklistValues != null && picklistValues.size() > 0){
            for(SelectOption option : picklistValues){
                index.put(option.getValue(),option.getLabel());
            }
        }
        final List<String> returnValue = new List<String>();
        if(values != null && values.size() > 0){
            for(String value : values){
                if(index.containsKey(value)){
                    returnValue.add(index.get(value));
                } else {
                    returnValue.add(value);
                }
            }
        }
        return returnValue;
    }
    
    global static Boolean isSupportedType(Schema.DisplayType displayType){
        return

            //SUPPORTED
            Schema.DisplayType.MULTIPICKLIST == displayType

            || Schema.DisplayType.BOOLEAN == displayType

            || Schema.DisplayType.DOUBLE == displayType
            || Schema.DisplayType.PERCENT == displayType
            || Schema.DisplayType.CURRENCY == displayType

            || Schema.DisplayType.INTEGER == displayType

            || Schema.DisplayType.PICKLIST == displayType
            || Schema.DisplayType.STRING == displayType
            || Schema.DisplayType.URL == displayType
            || Schema.DisplayType.EMAIL == displayType
            || Schema.DisplayType.PHONE == displayType
            || Schema.DisplayType.TEXTAREA == displayType            
            ;

            //UNSUPPORTED
            //|| Schema.DisplayType.ANYTYPE == displayType
            //|| Schema.DisplayType.BASE64 == displayType
            //|| Schema.DisplayType.COMBOBOX == displayType
            //|| Schema.DisplayType.DATE == displayType
            //|| Schema.DisplayType.DATETIME  == displayType
            //|| Schema.DisplayType.ID == displayType
            //|| Schema.DisplayType.REFERENCE == displayType
    }

    global static List<FAP_FormField> filterOutUnsupportedTypes(List<FAP_FormField> listToFilter ){
        final List<FAP_FormField> returnValue = new List<FAP_FormField>();
        if(listToFilter != null && listToFilter.size() > 0){
            for(FAP_FormField field : listToFilter){
                if(isSupportedType(field.displayType)){
                    returnValue.add(field);
                }
            }
        }
        return returnValue;
    }    

    global static List<FAP_FormField> build(List<FAP_FieldConfiguration> fieldConfigurations){
        List<FAP_FormField> returnValue = new List<FAP_FormField>();
        if(fieldConfigurations != null && fieldConfigurations.size() > 0){
            for(FAP_FieldConfiguration fieldConfiguration : fieldConfigurations){
                returnValue.add(new FAP_FormField(fieldConfiguration));
            }
        }
        returnValue = FAP_FormField.filterOutUnsupportedTypes(returnValue);
        system.debug('@@@@returnValue@@@@' + returnValue );
        return returnValue;
        
    }

    global static Set<Object> fieldNames(List<FAP_FormField> fields){
        Set<Object> returnValue = new Set<Object>();
        if(fields != null && fields.size() > 0){
            for(FAP_FormField field : fields){
                returnValue.add(field.localName);
            }
        }
        return returnValue;
    }
    
    global static List<FAP_FormField> populateFields(List<FAP_FormField> fields, SObject sobj){
        if(fields != null && fields.size() > 0 && sobj!=null){
            for(FAP_FormField field : fields){
                field.populate(String.valueOf(sobj.get(field.name)));
            }
        }
        return fields;
    }
    
    global static List<FAP_FormField> populateSObject(SObject sobj, List<FAP_FormField> fields){
        if(sobj != null && fields != null && fields.size() > 0){
            for(FAP_FormField field : fields){
            //v2.0 Start 
            //  if(field != null && field.typedValue != null){
                if(field != null){//v2.0 End
                    sobj.put(field.name, field.typedValue);
                }                
            }
        }
        return fields;
    }

}
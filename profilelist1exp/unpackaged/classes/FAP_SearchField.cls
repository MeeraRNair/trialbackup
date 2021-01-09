global class FAP_SearchField extends FAP_FormField {

    global String applyTo {get; private set;}
    
    global FAP_SearchField(FAP_FieldConfiguration configuration){
        super(configuration);
        this.applyTo = configuration.applyToFieldName;
        if(FAP_StringUtils.isBlank(this.applyTo)){
            this.applyTo = this.localName;
        }
    }

    global static List<FAP_SearchField> filterOutUnsupportedTypes(List<FAP_SearchField> listToFilter ){
        final List<FAP_FormField> formFields = FAP_FormField.filterOutUnsupportedTypes(listToFilter);
        final List<FAP_SearchField> returnValue = new List<FAP_SearchField>();
        if(formFields != null && formFields.size() > 0){
            for(FAP_FormField formField : formFields){
                returnValue.add((FAP_SearchField)formField);
            }
        }
        return returnValue;
    }

    global static List<FAP_SearchField> build(List<FAP_FieldConfiguration> fieldConfigurations){
        final List<FAP_SearchField> returnValue = new List<FAP_SearchField>();
        if(fieldConfigurations != null && fieldConfigurations.size() > 0){
            for(FAP_FieldConfiguration fieldConfiguration : fieldConfigurations){
            system.debug('searchfield ReturnValue:'+returnValue);
                returnValue.add(new FAP_SearchField(fieldConfiguration));
            }
        }
        return FAP_SearchField.filterOutUnsupportedTypes(returnValue);
    }
}
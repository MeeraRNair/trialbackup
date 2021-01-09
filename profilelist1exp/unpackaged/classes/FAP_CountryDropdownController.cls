public without sharing class FAP_CountryDropdownController {
    
    public List<SelectOption> getCountries(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        Schema.DescribeFieldResult f = Partner_Location__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> entries = f.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        Set<String> prioritizedCountrySet = new Set<String>();
        for(String cCode: config.prioritizedCountries){
            prioritizedCountrySet.add(cCode);
        }
        System.debug('prioritizedCountrySet : '  + prioritizedCountrySet);
        Map<String,String> countryMap = getCountryMap(entries);
        System.debug('countryMap : ' + countryMap);
        
        for(String cCode: config.prioritizedCountries){
            System.debug('cCode : ' + cCode + '  Country : ' + countryMap.get(cCode));
            if(cCode!=null && countryMap.containsKey(cCode)){
                options.add(new SelectOption(cCode, countryMap.get(cCode)));
            }   
        }
        
        //add a disabled item as a separator
        if(config.prioritizedCountries.size()>0){
            SelectOption option = new SelectOption('SEPARATOR','----');
            option.setDisabled(true);
            options.add(option);
        }
        for(Schema.PicklistEntry entry : entries){
            String value = extractCountryCode(entry.getValue());
            if(!prioritizedCountrySet.contains(value)) {
                options.add(new SelectOption(value,entry.getLabel()));
            }
        }
        return options;
    }
    
    private Map<String,String> getCountryMap(List<Schema.PicklistEntry> entries){
        Map<String,String> countryCodeLabelMap = new Map<String,String>();
        for(Schema.PicklistEntry entry : entries){
            String value = extractCountryCode(entry.getValue());
            countryCodeLabelMap.put(value, entry.getLabel());
        }
        return countryCodeLabelMap;
    } 
    
    private String extractCountryCode(String value){
        Integer index1 = value.lastIndexOf('('); //StringUtils.indexOf(value, '(');
        Integer index2 = value.lastIndexOf(')');
        return value.subString(index1+1, index2);
    }
    

}
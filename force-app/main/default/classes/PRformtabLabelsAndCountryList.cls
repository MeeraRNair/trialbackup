public virtual class PRformtabLabelsAndCountryList {
        @AuraEnabled
         public List<String> tabLabels;
        @AuraEnabled
         public Map<string,id> countryList;
        @AuraEnabled
         public Map<string,string> countryNameToCodemap;
    
    public PRformtabLabelsAndCountryList(List<String> tabLabels,Map<string,id> countryList,Map<string,string> countryNameToCodemap){
        this.tabLabels = tabLabels;
        this.countryList = countryList;
        this.countryNameToCodemap = countryNameToCodemap;
    }
}
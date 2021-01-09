global class FAP_PartnerSearchResult{
    
    public ID id{get;set;}
    public ID companyId{get;set;}
    public ID locationId{get;set;}
    public ID logoId{get; set;}
    public ID logoRecordId{get; set;}
    public Integer recordNumber{get; set;}
    public String companyName{get;set;}
    public String locationName{get;set;}
    public String street{get;set;}
    public String city{get;set;}
    public String state{get;set;}
    public String postalCode{get;set;}
    public String country{get;set;}
    public Double latitude{get;set;}  
    public Double longitude{get;set;}  
    public Double distance{get;set;}
    public String website{get; set;}
    public String phone{get; set;}
    public String pointOfContactName{get;set;}
    public Boolean isRecommended{get;set;}
    public Integer locationCount{get; set;}
    public Double getDistanceRounded(){ return Decimal.valueOf(distance).setScale(2); }
    public List<FAP_RenderField> customFields{get;set;}
    
    
    public FAP_PartnerSearchResult(Partner_Location__c location){
       
        this.id = location.id;
        this.companyName =  FAP_Configuration.keyValueWithoutDot == 'Account__r' ? string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Name')):string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Primary_Sales_Motion_Account_Legal_Name__c'));
        this.companyId = FAP_Configuration.keyValueWithoutDot == 'Account__r' ? location.account__r.id : location.Partner_Track__r.id;
        this.logoRecordId = FAP_Configuration.keyValueWithoutDot == 'Account__r'?((string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('logo__c'))==null)?null:string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('logo__c'))):(string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('logo__c'))!=null?string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('logo__c')):string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Master_Logo_ID__c')));
        this.locationName = location.name;
        this.locationId = location.id;
        this.street = FAP_Configuration.keyValueWithoutDot == 'Account__r'?location.Street__c:String.ValueOf(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Legal_Address_Street__c'));
        this.city = FAP_Configuration.keyValueWithoutDot == 'Account__r'?location.City__c:string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Legal_Address_City__c'));
        this.state = FAP_Configuration.keyValueWithoutDot == 'Account__r'?location.State_Province__c:string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Legal_Address_State_Province__c'));
        this.postalCode = FAP_Configuration.keyValueWithoutDot == 'Account__r'?location.Postal_Code__c:string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Legal_Address_Postal_Code__c'));
        this.country = FAP_Configuration.keyValueWithoutDot == 'Account__r'?location.Country__c:string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Legal_Address_Country__c'));
        this.latitude = location.Latitude__c;
        this.longitude = location.Longitude__c;
        this.website= FAP_UrlUtils.ensureUrlBeginsWithHttp(location.Website__c);
        this.pointOfContactName=location.Point_of_Contact_Name__c;
        this.phone=location.Point_of_Contact_Phone__c;
        this.locationCount=1;
        this.distance = 0;
        this.isRecommended = location.account__r.Partner_Finder_Recommended_Flag__c; 
        this.customFields=new List<FAP_RenderField>();
        
    }
    
    
    
}
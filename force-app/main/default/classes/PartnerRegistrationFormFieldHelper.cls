public abstract class PartnerRegistrationFormFieldHelper {
   @AuraEnabled
    public String labelValue;
   @AuraEnabled
    public String fieldType;
   @AuraEnabled
    public String fieldName;
   @AuraEnabled
    public Boolean isVisible;
   @AuraEnabled
    public Boolean isRequired;
   @AuraEnabled
   // public List<String> pickListValues;
   public Map<String, String> pickListValues;
     @AuraEnabled
    public List<String> PickListValue; 
   @AuraEnabled
    public String fieldValue;
   @AuraEnabled
    public String countryCode;
    @AuraEnabled
    public String optInApjLatam;
    @AuraEnabled
    public String optInRestOfEMEA;
     @AuraEnabled
    public String language;
    
  public PartnerRegistrationFormFieldHelper(String labelValue,String fieldType,String fieldName,Boolean visible, 
                                            Boolean required,Schema.DescribeFieldResult field){ 
    this.labelValue = labelValue;
    this.fieldType = fieldType;
    this.fieldName = fieldName;
    this.isVisible = visible;
    this.isRequired = required;
    this.PickListValue = getPickListOptions(field);
      
  } 
    
    public PartnerRegistrationFormFieldHelper(String labelValue,String fieldType,String fieldName,map<String,string> fieldValue){ 
    this.labelValue = labelValue;
    this.fieldType = fieldType;
    this.fieldName = fieldName;
    this.pickListValues = fieldValue;
      
  }
 
  public PartnerRegistrationFormFieldHelper(String labelValue,String fieldType,String fieldName,Boolean visible, 
                                            Boolean required,String fieldValue){ 
    this.labelValue = labelValue;
    this.fieldType = fieldType;
    this.fieldName = fieldName;
    this.isVisible = visible;
    this.isRequired = required;
    this.fieldValue = fieldValue;
      
  }
            
  public PartnerRegistrationFormFieldHelper(String labelValue,String fieldType,String fieldName){ 
    this.labelValue = labelValue;
    this.fieldType = fieldType;
    this.fieldName = fieldName;      
  }
    
   public PartnerRegistrationFormFieldHelper(String labelValue,String fieldType,String fieldName,Schema.DescribeFieldResult field){ 
    this.labelValue = labelValue;
    this.fieldType = fieldType;
    this.fieldName = fieldName;
   this.pickListValues = getSelectOptions(field,fieldName,'en_us__c');
    //this.pickListValues = pickListValues;     
  } 
  
  public PartnerRegistrationFormFieldHelper(String labelValue,
                                            String fieldType,
                                            String fieldName,
                                            Schema.DescribeFieldResult field,
                                            String language1){ 
                                              //  system.debug('*****' +language1);
    this.labelValue = labelValue;
    this.fieldType = fieldType;
    this.fieldName = fieldName;
    this.language= language1;
    this.pickListValues = getSelectOptions(field,fieldName,language);
      
  }    
    
     public map<string,string> getSelectOptions(Schema.DescribeFieldResult field, String fieldName,String language){
     // system.debug('Inside getSelectOptions');
     // system.debug('language@@@@'+language);
          list<Picklist_Translations__mdt> PicklistValues = [select id,developerName,MasterLabel, cs__c,da__c,de__c,el__c,ar__c,
                                                             en_us__c,es__c,es_mx__c,fi__c,hu__c,fr__c,it__c,iw__c,ja__c,ko__c,nl__c,no__c,pl__c,pt_br__c,
                                                             ro__c,ru__c,sk__c,sv__c,th__c,tr__c,zh_cn__c,zh_tw__c,order__C from Picklist_Translations__mdt where PicklistName__c=:fieldName ORDER BY order__C,MasterLabel ASC];
      
       map<String,String> values = new map<String,String>(); 
        for(Picklist_Translations__mdt each:PicklistValues){
        System.debug('language '+language);
        if(language == null ){
		system.debug('<<<Language>>>');            
            language = 'en_us__c'; 
        }
        String fieldIs = language;//+'__c'; //'cs__c';
            if(String.valueOf(each.get(fieldIs))!=null){
             values.put(each.MasterLabel,String.valueOf(each.get(fieldIs)));
            }else{
             values.put(each.MasterLabel,each.MasterLabel);
            }
           // System.debug('values!!!!'+values +fieldName);
        }
       /* final List<string> options = new List<string>();
        if(field != null){
            for(Schema.PicklistEntry entry : field.getPicklistValues()){
            String valueIs = values.get(entry.getValue());
            if(valueIs==null){
                valueIs  =entry.getValue();
            }
                options.add(valueIs);       
            }
        } */
        return values;
    } 
    // ends here
    
   public List<string> getPickListOptions(Schema.DescribeFieldResult field){
     system.debug('Inside getSelectOptions');
        final List<string> options = new List<string>();
        if(field != null){
            for(Schema.PicklistEntry entry : field.getPicklistValues()){
                options.add(entry.getValue());       
            }
        }
        return options;
    }
    
    public void updateConfig (boolean isVisible, boolean isRequired) {
      this.isVisible = isVisible;
      this.isRequired = isRequired;
    }
}
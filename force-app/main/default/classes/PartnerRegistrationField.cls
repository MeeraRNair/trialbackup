public abstract class PartnerRegistrationField{
    
    //SUPPORTED FIELD TYPES
    public static String TYPE_STRING                            {get{return 'STRING';}}
    /*
                public static String TYPE_INTEGER               {get{return 'INTEGER';}}
                public static String TYPE_LONG                  {get{return 'LONG';}}
                public static String TYPE_DOUBLE                {get{return 'DOUBLE';}}
    */
    public static String TYPE_URL                               {get{return 'URL';}}
    public static String TYPE_PICKLIST                          {get{return 'PICKLIST';}}
    public static String TYPE_PICKLIST_WITH_OTHER               {get{return 'PICKLIST_WITH_OTHER';}}
    public static String TYPE_MULTIPICKLIST                     {get{return 'MULTIPICKLIST';}}//START R14.2
    //END R14.2
   
    public static String TYPE_BOOLEAN                           {get{return 'BOOLEAN';}}
    public static String TYPE_BOOLEAN_MULTIAGREEE_CHKBOX        {get{return 'BOOLEAN_MULTIAGREEE_CHKBOX';}}
    public static String TYPE_BUTTON        {get{return 'BUTTON';}}
    
    // AMAN START R14.5 CR 8160    Constructor and variables used for RADIO BUTTON AND MULTIPICKLIST FIELD
    public static String TYPE_MULTIPICKLIST_WITH_OTHER          {get{return 'MULTIPICKLIST_WITH_OTHER';}}    // CR 8159
    public static String TYPE_RADIO         {get{return 'RADIO';}}
    public List<SelectOption> radioOptions{get;set;}
    public map<string, boolean> radioOptionVisible{get;set;}
    
    // END R14.5
        
    //VARIABLES FOR COUNTRY & LANGUAGE
    public String      paramCountry {get;set;}
    private String       paramLanguage {get;set;}
    public  static String    usrCountry ='';
    public  static String   usrLanguage ='';
    public String       STR_COUNTRY ='COUNTRY';
    public String       STR_LANGUAGE ='LANGUAGE'; 
    public String strLabel{get;private set;}
    private static List<SelectOption> EMPTY_OPTIONS = new List<SelectOption>();

    public Partner_Request__c request
    {   
        get; set;}
    public String labelValue {get;set;}
    public String fieldType {get;private set;}   
    public Boolean isVisible{get;set;}
    public Boolean isRequired{get;set;}//START R14.2
    public String defaultValue{get;set;}//END R14.2
    public Boolean showOther {get{ if(this.showOther == null){ this.showOther = false;} return this.showOther;}set;}//START R14.2
    private Boolean otherValueAdded = false;//END R14.2
    public String helpText{get;set;}
    
    public String value {
        get{
            if(request != null){
                Object val;
                if(this.fieldName!=null && this.fieldName!='' && fieldType!=TYPE_RADIO)
                 val= request.get(this.fieldName);
                 // to set Radio Button value (API name in Radio Options List on VF Page
                if(fieldType==TYPE_RADIO)
                {
                    return this.value;
                }
                if(val != null){
                    if(fieldType == TYPE_BOOLEAN || fieldType == TYPE_BOOLEAN_MULTIAGREEE_CHKBOX){
                        return ((Boolean) val) ? 'true' : 'false';
                    } 
                    else {           
                        return (String) val;
                    }
                }
                
            }
      system.debug('value = '+this.value);
      system.debug('fieldName = '+this.fieldName);
      if(request != null && !isFieldNeedSelection(this.fieldName)){
        System.debug('came in to null');
        return null;
      }else{
        System.debug('came in to value');
        
        return value;
      }
            
        }
        set{            
            System.debug('set invoked for ' + fieldName); 
            if(request != null){            
            if(fieldType == TYPE_BOOLEAN || fieldType == TYPE_BOOLEAN_MULTIAGREEE_CHKBOX)
            {
                request.put(this.fieldName,'true'.equalsIgnoreCase(value));
                System.debug('Show in TYPE_BOOLEAN..');
            } else if(fieldType == TYPE_PICKLIST_WITH_OTHER && showOther && StringUtils.isNotEmpty(value)
                 && !StringUtils.startsWith(value, 'Other: ')){
                request.put(this.fieldName,'Other: ' + value);
                
            }
            // AMAN START R14.5    CR8160    Set Radio Button selected Value
            else if(fieldType==TYPE_RADIO)    
            {
                system.debug('--in radio setting-----'+value);
                for(SelectOption opT:this.radioOptions)
                {
                    system.debug('-----in for loop value-----'+opT.getValue());
                    if(opT.getValue()==value)
                        request.put(opT.getValue(),true);
                    else
                        request.put(opT.getValue(),false);
                }
            }
            // END R14.5
            
            else {
                    request.put(this.fieldName,value); 
            }
        }
        this.value = value;
        }
    }
    
    public String otherValue{get;
        set{
            this.otherValue = value;
            // AMAN START R14.5 CR 8159   // Set top3 vendor picklist value 
            if(fieldType==TYPE_MULTIPICKLIST_WITH_OTHER && !showOther)
            {
                 request.put(this.fieldName,this.otherValue);
            }
            // END R14.5
            }
    }

    public String[] valueMultiPicklist {
        get{
            if(request != null){
                String val = value;
                List<String> selectListValues = new List<String>();
                if(StringUtils.isNotBlank(val)){
                    for(String singleValue : StringUtils.split(val,';')){
                        selectListValues.add(singleValue);
                    }
                }
                return selectListValues;
            }
            return null;
        }
        set{
            this.value = StringUtils.joinStrings(value,';');
        }
    }

    public String fieldName {get;set;}
    public String visibleFieldName {get;set;}
    public String requireFieldName {get;set;}
    public Boolean visible {get; set;}
    public Boolean required {get; set;}
    public Boolean visibleControlledByCountry {get{return StringUtils.isNotBlank(visibleFieldName);}}
    public Boolean requiredControlledByCountry {get{return StringUtils.isNotBlank(requireFieldName);}}
    
    public Boolean isFieldNeedSelection(String fieldName){
      Boolean isFlag = false;
      if(StringUtils.equalsIgnoreCase(fieldName, 'Country__c'))isFlag=true;
      if(StringUtils.equalsIgnoreCase(fieldName, 'Preferred_Language__c'))isFlag=true;
      return isFlag;
    }
    
    public PartnerRegistrationField(String labelValue, String fieldType, String fieldName){ 
      
        this.labelValue = labelValue;
        
        this.fieldType = fieldType;
        
        this.fieldName = fieldName; 
        
    }
    public PartnerRegistrationField(String fieldType, String fieldName){ 
      
        
        
        this.fieldType = fieldType;
        
        this.fieldName = fieldName; 
        
    }
    
    public PartnerRegistrationField(String labelValue, String fieldType, String fieldName,
        Boolean visible, Boolean required){
        this.labelValue = labelValue;
        this.fieldType = fieldType;
        this.fieldName = fieldName;
        this.visible = visible;
        this.required = required;
    }
    
    public PartnerRegistrationField(list<selectoption> opt,  String fieldType, String fieldName)
    {
        radioOptionVisible=new map<string,boolean>();
        this.fieldType=fieldType;
        this.radioOptions=opt;
        this.fieldName=fieldName;
    }
    
    
  //added to allow option to be selected
  public PartnerRegistrationField(String labelValue, String fieldType, String fieldName,
    Boolean visible, Boolean required, String optionValueSelection,String optionField){
    
    paramCountry = PageUtils.param('c');
    paramLanguage = PageUtils.param('l');   
     //===================================================================
    //Initialized User language and country  
    //===================================================================
      initUsrCountryLang(optionField);
    
      System.debug('paramCountry='+paramCountry);
      System.debug('paramLanguage='+paramLanguage);
      
      System.debug('usrCountry='+usrCountry);
      System.debug('usrLanguage='+usrLanguage);
    this.labelValue = labelValue;
    this.fieldType = fieldType;
    this.fieldName = fieldName;
    this.visible = visible;
    this.required = required;
    this.value = doParseParam(fieldName);
    
    system.debug('optionValueSelection>>' + optionValueSelection);
    system.debug('value of doParseParam>>' + value);
  }
  
  public String doParseParam(String fieldName){
    String tempParam = '';
    if(StringUtils.isNotBlank(fieldName)){
      if(StringUtils.equalsIgnoreCase(fieldName, 'country__c'))tempParam=usrCountry;    
      if(StringUtils.equalsIgnoreCase(fieldName, 'Preferred_Language__c'))tempParam=usrLanguage;
    }
    return tempParam;
  }
  
    public PageReference doShowOther(){
    //Ujwala CR13828,CR13803 for EMC change
   // System.debug('>>>>> '+countryMap);
   System.debug('Other class >>>> '+apexpages.currentpage().getparameters().get('ContCode'));
try{
   PartnerRegistrationFormCtrlExt.RegionOfCountryis  =  apexpages.currentpage().getparameters().get('Region');
   }catch(Exception ex){}
   if(apexpages.currentpage().getparameters().get('ContCode')!='hk')
     PartnerRegistrationFormCtrlExt.question='All';
     else 
     PartnerRegistrationFormCtrlExt.question='HK';
     //End of EMC change
        showOther = true;
        this.value = null;
        return null;    
    }
    
    public PageReference doShowPicklist(){
    
    try{
   PartnerRegistrationFormCtrlExt.RegionOfCountryis  =  apexpages.currentpage().getparameters().get('Region');
   }catch(Exception ex){}
        //Ujwala CR13828,CR13803 for EMC change
        if(apexpages.currentpage().getparameters().get('ContCode')!='hk')
             PartnerRegistrationFormCtrlExt.question='All';
         else 
             PartnerRegistrationFormCtrlExt.question='HK';
        //End of EMC change     
        showOther = false;
        this.value = null;
        return null;     
    }
    
    public virtual void handleChkBoxControllerClick(){}
    public PageReference handleCheckboxChange(){        
        handleChkBoxControllerClick();      
        return null;
    }
    
    public virtual void handleFieldChange(){}
    public PageReference handleSelectionChange(){
    
    try{
   PartnerRegistrationFormCtrlExt.RegionOfCountryis  =  apexpages.currentpage().getparameters().get('Region');
   }catch(Exception ex){}
        handleFieldChange();
        return null;
    }
    
    //Author : Alvin , CR 1842, Desc : Set country and preference language based on param 'c' & param'l'
  public void initUsrCountryLang(String optionField){
    
    if(StringUtils.isNotBlank(optionField) && StringUtils.equalsIgnoreCase(optionField,STR_COUNTRY)){
      PartnerCountryLangInt pc =  new PartnerCountry();
      usrCountry = pc.returnMatchValue(paramCountry);
    }else 
    if(StringUtils.isNotBlank(optionField) && StringUtils.equalsIgnoreCase(optionField,STR_LANGUAGE)){      
      PartnerCountryLangInt pl =   new PartnerLanguage();       
      usrLanguage = pl.returnMatchValue(paramLanguage);  
    }          
  }

    public Boolean isEmpty{
        get{
            if(fieldType == TYPE_MULTIPICKLIST){
                String[] vals = valueMultiPicklist;
                return vals == null || vals.size() <= 0;
            }
            if(fieldType == TYPE_BOOLEAN){
                return !'true'.equalsIgnoreCase(this.value);
            }
            return StringUtils.isBlank(this.value);
        }
    }
  
    public List<SelectOption> picklistValues{ 
        get{
            if(picklistValues == null){ picklistValues = retrievePicklistValues(); }
            return picklistValues;
        }
        set{}
    }
    
    public virtual List<SelectOption> retrievePicklistValues(){return EMPTY_OPTIONS;}
    
    public void setCountry(Country__c country){
        if(visibleControlledByCountry && country != null){
            this.visible = this.visibleFieldName == null ? false : 'Yes'.equalsIgnoreCase((String)country.get(this.visibleFieldName));
        }
        if(requiredControlledByCountry && country != null){
            this.required = this.requireFieldName == null ? false : 'Yes'.equalsIgnoreCase((String)country.get(this.requireFieldName));
        }
    }

    public List<SelectOption> getSelectOptions(Schema.DescribeFieldResult field){
        final List<SelectOption> options = new List<SelectOption>();
        if(field != null){
            for(Schema.PicklistEntry entry : field.getPicklistValues()){
                options.add(new SelectOption(entry.getValue(), entry.getValue()));                 
            }
        }
        return options;
    }
    
    public void updateConfig (boolean isVisible, boolean isRequired) {
      this.visible = isVisible;
      this.required = isRequired;
      System.debug('**is required**' + isRequired);
    }
    
    /*
    public String toStr(){
        return 
            '<#PartnerRegistrationField('
            + 'labelValue=' + labelValue
            + ',fieldType=' + fieldType
            + ',value=' + value
            + ',fieldName=' + fieldName
            + ',visibleFieldName=' + visibleFieldName
            + ',requireFieldName=' + requireFieldName
            + ',visible=' + visible
            + ',required=' + required
            + ',visibleControlledByCountry=' + visibleControlledByCountry
            + ',requiredControlledByCountry=' + requiredControlledByCountry
            + ')';
    }
    */
      
}
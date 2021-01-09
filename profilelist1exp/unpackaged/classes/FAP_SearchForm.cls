/*
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Fenny       28-Mar-2012     13.4        7052    To fix an issue, to enable search partner by country
2.0         Sandhya     03-May-2012     13.7        7105    Implement dynamic FAP search page
2.1         Fenny       14-May-2012     13.7        7112    Enable sort for Search results
2.2         Sandhya     22-May-2012     13.7        7100    Search by region
2.3         Sandhya     27-May-2012     13.7        7102    Add partner status in regular search
2.4         Sandhya     30-May-2012     13.7        7104    Enable Resellers/Distributor/Registered partners
2.5         Fenny       04-Jul-2012     13.7                Defect#: 36898, 37042, 37241: Too many script statements: 200001
2.6         Fenny       15-Jul-2012     13.7                Defect #37825
2.7         Sandhya     27-Jul-2012     13.7                Defect #:39742
2.8         Fenny       10-Aug-2012     13.7                Defect #:41184
2.9         Sandhya     17-Aug-2012     13.7                Defect #:41665
3.0         Sandhya     01-Oct-2012     13.7                Defect #:Issue with translations
3.1         Mohammad    25-Feb-2015     MInSprint16.03- 1   show Distributor(Partner Type) to Un-autheticated users
4.0         Kokila      10-Dec-2015     16.2        12330   Story 161281:Create new FAP Links: Partner Type
4.1         Ashish      15-Dec-2015     16.2                Story 208946:Prioritize in FAP: Sort Order  
5.0         Krishna     12-Apr-2018     05.02       15652   Enhance Services search with Competencies and category   
5.1         Kokila      06-Jun-2018     FY19.07.03  15924   Extend the PartnerSearch Competencies to Competency Tracker Object  
6.0         Niveda      16-Oct-2019     FY20-DCS-0102       FAP: Federal Search
7.0         Akshita     31-Oct-2019     FY20-DCS-0102       FAP: CSP Partner Name search
8.0         Sakshi      31-Oct-2019     FY20-DCS-0102       FAP - Availability of Country and State search for CSP separately - FAP Part
9.0         Sakshi      19-Nov-2019     FY20-DCS-0102       FAP - FED - Search options for Federal partners - Diversity Certification and Search for Enabled Contracts
*/
public class FAP_SearchForm {

    // Ver 1.0: Variable that hold selected country in the search field
    public String               countryCode         {get; set;}
    public String               urlCountryCode      {get; set;} // Ver 2.8
    public String               urllanguagecode     {get; set;}
    public String               languagecode        {get; set;}
    public String               keyword             {get; set;}
    public String               address             {get; set;}
    public String               unit                {get; set;}
    public Integer              distance            {get; set;}
    public Double               latitude            {get; set;}
    public Double               longitude           {get; set;}
    public List<SelectOption>   distanceOptions     {get; private set;}
    public List<FAP_SearchField>    basicFields         {get; private set;}
    public List<FAP_SearchField>    advancedFields      {get; private set;}
    private List<FAP_SearchField>   allFields           {get; private set;}
    private boolean   isDistributorSeearch = false;
    public List<FAP_SetOfThreeSearchFields> advancedFieldsSet{get; private set;}
    public String               urlpartnertype      {get; set;}//v4.0 - Added
    public Map<String,String> checking = new Map<String,String>();   
    public String value {get; set;}
    public static String accField {get;set;}
    
  
    
    // Ver 2.1: Added sortOption page no
    public String sortOption { get; set; }
    /* <START> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
    public String pageNumber { 
        get {
            if(pageNumber == null) {
                pageNumber = '0';
            }
            return pageNumber;
        }
        set; 
    }    
    /* <START> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
    public String               region         {get; set;}
    public String               partnerType    {get; set;}
    /* 2.0 - CR 7105 - Implement dynamic FAP search page. */
    public List<FAP_SearchField>    customBasicFAPSearchFields      {get; private set;}
    public List<FAP_SetOfThreeSearchFields> basicSearchFieldSet{get; private set;}
    public String searchBasicFAPString='';
    public String searchCSPString='';
    public String searchAdvancedFAPString='';
    public String usrlanguage='';
    public String userType =''; 
    public String regionDefault='';
    public String langaugeDefault='';
    public String ditributorListToCheck='';//Ver 2.4 Do not show Distributor to Un-autheticated users
    public Map<String,FAP_Customization__c> basicFieldsMap;
    public Map<String,FAP_Customization__c> advancedFieldsMap;
    public Map<String,FAP_Customization__c> cspFieldsMap;
    private FAP_Configuration config; // Ver 2.6: added

    public String  strCompetency    {get; set;}
    public String  strSubCompetency    {get; set;}
    public String  strCompCategory    {get; set;}
    public Map<String,String> mapSubCompSearch = new Map<String,String>(); 
    
    //CSP Change
    public String  strCSPPartnerType   {get; set;}
     @TestVisible
    private FAP_SearchForm(){
        // Ver 2.6
        config = FAP_Configuration.getInstance();
        distance = config.searchDistanceDefault;
        regionDefault = config.regionDefault;
        langaugeDefault = config.langaugeDefault;
        ditributorListToCheck = config.distributorPartnerType; //Ver 2.4 Do not show Distributor to Un-autheticated users
        if(distanceOptions == null || distanceOptions.isEmpty()){
            distanceOptions = new List<SelectOption>();
            // RP: use the distance map to display values
             Map<Integer,String> distanceMap = new Map<Integer,String>();
             distanceMap.put(Integer.valueOf('5'),'5 miles/8 kilometres');
             distanceMap.put(Integer.valueOf('10'),'10 miles/16 kilometres');
             distanceMap.put(Integer.valueOf('25'),'25 miles/40 kilometres');
             distanceMap.put(Integer.valueOf('50'),'50 miles/80 kilometres');
             distanceMap.put(Integer.valueOf('75'),'75 miles/120 kilometres');
             distanceMap.put(Integer.valueOf('100'),'100 miles/160 kilometres');
             distanceMap.put(Integer.valueOf('200'),'200 miles/320 kilometres');             
             
            for(String aDistance : new List<String>{'5','10','25','50','75','100','200'})            
            {
                distanceOptions.add(new SelectOption(aDistance,aDistance));
            }            
        }
        /* 2.0 - CR 7105 - Implement dynamic FAP search page. */
        String sel = Apexpages.currentPage().getParameters().get('partner_track__c.partner_type__c');
        String sel1 = system.CurrentPageReference().getParameters().get('partner_track__c.partner_type__c');
        System.debug('CSP in FAP_SearchForm--'+sel+'---'+sel1);
        
        getFAPCustomization();
        system.debug('*****CSP getFAPCustomization() Loaded'); 
        System.debug('--strPartnerType--'+this.partnerType);
        //setFieldConfig(searchBasicFAPString,basicFieldsMap);
        
         if(!String.isEmpty(sel) && (sel.contains('MSP')||sel=='Cloud Service Provider' )){
            setFieldConfig(searchCSPString,cspFieldsMap); //bckcommentd
        }else{
            setFieldConfig(searchBasicFAPString,basicFieldsMap);
        }

                         
    }
    

    public void setFieldConfig(String searchString,Map<String,FAP_Customization__c> fieldMap){
        List<FAP_FieldConfiguration> fieldConfigBasic = FAP_FieldConfiguration.populateFieldValues(
                                            FAP_FieldConfiguration.parse(searchString), fieldMap,
                                            usrlanguage,config);
        basicFields = FAP_SearchField.build(fieldConfigBasic);
        basicSearchFieldSet = FAP_SetOfThreeSearchFields.createFromList(basicFields);
        system.debug('**************************basicFields---'+basicFields);
        system.debug('**************************fieldMap---'+fieldMap);
                 
        List<FAP_FieldConfiguration> fieldConfigAdvanced = FAP_FieldConfiguration.populateFieldValues(
                                            FAP_FieldConfiguration.parse(searchAdvancedFAPString), advancedFieldsMap,
                                            usrlanguage,config);
        advancedFields = FAP_SearchField.build(fieldConfigAdvanced);
        advancedFieldsSet = FAP_SetOfThreeSearchFields.createFromList(advancedFields);
        this.allFields = new List<FAP_SearchField>();
        this.allFields.addAll(basicFields);
        this.allFields.addAll(advancedFields);   
                     
    }

    public Boolean isBlank{get{return keywordBlank && geoBlank && basicFieldsAreBlank && advancedFieldsAreBlank;}}
    public Boolean keywordBlank{get{return FAP_StringUtils.isBlank(keyword);}}
    public Boolean geoBlank{get{return FAP_StringUtils.isBlank(address);}}
    public Boolean basicFieldsAreBlank{get{return areBlank(this.basicFields);}}
    public Boolean advancedFieldsAreBlank{get{return areBlank(this.advancedFields);}}
    
    @TestVisible
    private static Boolean areBlank(List<FAP_SearchField> fields){
        Boolean returnValue = true;
        if(fields != null && fields.size() > 0){
            for(FAP_SearchField field : fields){
                if(field.notBlank){
                    returnValue = false;
                    break;
                }
            }
        }
        return returnValue;
    }
    
    public String toStr{get{return toStr();}}

    public String toStr(){
        return '<#FAP_SearchForm[' 
            + 'keyword=' 
            + this.keyword
            + ',address=' 
            + this.address
             + ',region='  //Ver 2.2: Search by region
            + this.region
            + ',unit=' 
            + this.unit
            + ',partnerType=' 
            + this.partnerType
            + ',distance=' 
            + this.distance
            + ',distanceOptions=' 
            + this.distanceOptions
            + ',basicFields=' 
            + this.basicFields
            + ',advancedFields=' 
            + this.advancedFields
            + ']>';
    }

    public FAP_Condition getAttributeSearchCriteria(){        
        // Ver 2.5: To fix 'Too many script statements'    
        accField = FAP_Configuration.keyValue +'Partner_Type__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType accSchema = schemaMap.get(FAP_Configuration.strObjectName);
        Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
        
            for (String fieldName: fieldMap.keySet()) {
                if(fieldName == FAP_Configuration.strAcctLocalName){
                    accField = FAP_Configuration.keyValue+FAP_Configuration.strAcctLocalName;
                    system.debug('##accField '+accField);
                }
            }
            
        
        FAP_AndCondition returnValue = new FAP_AndCondition();
        Boolean partnerTypeFlag = false; //Ver 2.4 Do not show Distributor to Un-autheticated users
        Boolean countryFieldFlag = false;
        
        Boolean bHasCloudServiceProvider = false; //7.0
        
        // Ver 2.5: To fix 'Too many script statements'
        if((countryCode == null) || (countryCode.trim().length() == 0)){            
            if((region != null) && (region.trim().length() != 0)){                                 
                List<String> countryList = new List<String>();// Ver 2.9
                for(sObject obj : Database.query('select FAP_Region__c,Region__c,FAP_Country_Value__c,Enable_for_FAP__c from Country__c where FAP_Region__c= \'' + String.escapeSingleQuotes(region.trim())+ '\'')){
                    if(Limits.getScriptStatements() >= config.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 2.6
                    countryList.add((String)obj.get('FAP_Country_Value__c'));
                }
                if(countryList.size()>0){
                    returnValue.add(new FAP_SetCondition('Country__c', FAP_Operator.INX, countryList));
                }
            }
        }
        if(this.allFields != null && this.allFields.size() > 0){   
            system.debug('TestCSP this.allFields' +this.allFields);          
            String qualifiedName = '';
            Boolean bHasFederalType = false; //9.0 added
            
            for(FAP_SearchField field : this.allFields){
                if(Limits.getScriptStatements() >= config.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 2.6
                if(field.name == 'Country__c.Country'){
                    countryFieldFlag = true; // If country is not included as search field, then dont include country in query
                }
                qualifiedName = (FAP_Configuration.strObjectName.equalsIgnoreCase(field.objectName) ? FAP_Configuration.keyValue : '') + field.applyTo;  
                system.debug('TestCSP qualifiedName ' +qualifiedName );               
                if(field.notBlank){
                    //Ver 2.3  Add partner status in regular search
                    //Ver 2.4    Enable Resellers/Distributor/Registered partners
                    /* Using INX operator since some fields are of type Text in Object.
                    But requirement is to be able to select multiple values.
                    So error occurs if handled as a normal multipicklist.Need to use INX operator
                    for Text fields in Object and INCLUDES for Multipicklist fields*/
                    
                    system.debug('TestCSP field' +field);
                    system.debug('TestCSP field.isMultiselectPicklist1' +field.isMultiselectPicklist);
                    if(field.isMultiselectPicklist){      
                        system.debug('TestCSP field.isMultiselectPicklist2' +field.isMultiselectPicklist);                  
                        List<String>valueList = new List<String>();
                        if(field.name == FAP_Configuration.strFieldPartnerType && field.values.size()>0){
                            partnerTypeFlag = true; //Ver 2.4 Do not show Distributor to Un-autheticated users
                        }
                        
                        
                        //Ver 2.7 - Use INCLUDES for multipicklists in Account/Partner_Location__c
                        List<String>strList  = new List<String>();
                        Boolean multipicklistFlag = false;
                        system.debug('TestCSP field.Name1' +field.Name);
                        
                        if(field.Name.contains('.')){
                            strList = field.Name.split('\\.');
                            system.debug('TestCSP strList 1' +strList);
                            if((FAP_Configuration.strObjectName.equalsIgnoreCase(field.objectName) && strList[1]!= null && strList[1] != '')&&
                                FAP_Configuration.strObjectName == 'Account'?(Schema.sObjectType.Account.fields.getMap().get(strList[1]).getDescribe().getType().Name() == 'MULTIPICKLIST'):
                                (Schema.sObjectType.Partner_Track__c.fields.getMap().get(strList[1]).getDescribe().getType().Name() == 'MULTIPICKLIST')||
                                ('Partner_Location__c'.equalsIgnoreCase(field.objectName) && strList[1]!= null && strList[1] != '')&&
                                (Schema.sObjectType.Partner_Location__c.fields.getMap().get(strList[1]).getDescribe().getType().Name() == 'MULTIPICKLIST')){
                                system.debug('TestCSP field.Values1' +field.Values);
                                system.debug('TestCSP qualifiedName1' +qualifiedName);
                                if(field.Values != null && field.Values.size()>0 && field.Values[0]!=''){
                                returnValue.add(new FAP_SetCondition(qualifiedName).INCLUDES(field.Values)); 
                                    multipicklistFlag = true;
                                }
                                system.debug('TestCSP returnValue1' +returnValue);
                            }
                        }
                        if(multipicklistFlag == false){
                            system.debug('TestCSP multipicklistFlag ' +multipicklistFlag );
                            for(String str : field.values){
                                if(Limits.getScriptStatements() >= config.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 2.6
                                
                                if((str != null) && (str.trim().length() != 0)){
                                    if(str.contains(',')){ // Checking whether the picklist values have multiple SFDC values
                                        valueList.addAll(str.split(',')); // Ver 2.5: To fix 'Too many script statements'
                                    }
                                    else{
                                        valueList.add(str); 
                                    }
                                }
                            }
                            if(valueList.size() > 0){                                
                                 if(String.valueOf(valueList).indexOf('Distributor') > 0 && String.valueOf(valueList).indexOf('Federal') == 0){
                                 isDistributorSeearch = true;
                                 }
                                 else{
                                 isDistributorSeearch = false;                                 
                                 }
                                 
                                returnValue.add(new FAP_SetCondition(qualifiedName).inx(valueList));  
                                
                            }
                            system.debug('TestCSP returnValue2' +returnValue);
                        } 
                     }else if(field.isPicklist && qualifiedName != 'Country__c'){                        
                        List<String>valueList = new List<String>();
                        String picklistValue = (String)field.typedValue;
                        
                        if(field.name == FAP_Configuration.strFieldPartnerType && 
                          (picklistValue!=null && picklistValue.trim().length() != 0)){
                            
                            partnerTypeFlag = true; //Ver 2.4 Do not show Distributor to Un-autheticated users
                        }
                        
                        
                        
                        if((picklistValue != null)&& (picklistValue.trim().length() != 0)){
                            if(picklistValue.contains(',')){ // Checking whether the picklsit values have multiple SFDC values
                                valueList.addAll(picklistValue.split(',')); // Ver 2.5: To fix 'Too many script statements'
                            }
                            else{
                                valueList.add(picklistValue); 
                            }
                            
                            if(qualifiedName == FAP_Configuration.keyValue+'Partner_Type__c'){                                
                               if(String.valueOf(valueList).indexOf('Federal') == 0){
                                   returnValue.add(new FAP_FieldCondition('Partner_Track__r.Active_Sales_Channel__c',FAP_Operator.EQUALS,True)); 
                               }
                               //9.0 starts
                               if(!valueList.isEmpty() && valueList[0] == 'Federal Solution Provider'){
                                   bHasFederalType = true;
                               }
                               //9.0 ends
                               //7.0 start
                               if(!valueList.isEmpty() && valueList[0] == 'Cloud Service Provider'){
                                   bHasCloudServiceProvider = true;
                                   system.debug('bHasCloudServiceProvider' +bHasCloudServiceProvider);
                               }
                               //7.0 end
                            }
                            
                            system.debug('TestCSP valueList22' +valueList);
                            //9.0 starts
                            if(bHasFederalType){ 

                                if(qualifiedName == 'Partner_Track__r.Diversity_Certification__c'){
                                    
                                    String strDC = valueList[0];
                                    system.debug('=====strDC' +strDC);
                                    if(strDC != 'Other'){
                                        returnValue.add(new FAP_SetCondition(qualifiedName).includes(valueList));
                                    }
                                    else{
                                        returnValue.add(new FAP_FieldCondition('Partner_Track__r.Diversity_Certification_Other__c',FAP_Operator.NOT_EQUALS,null));
                                    }
                                }
                                
                                if(qualifiedName == 'Partner_Track__r.Contracts_Enabled__c'){
                                    
                                    String strDC = valueList[0];
                                    system.debug('=====strDC' +strDC);
                                    if(strDC != 'Other'){
                                        returnValue.add(new FAP_SetCondition(qualifiedName).includes(valueList));
                                    }
                                    else{
                                        returnValue.add(new FAP_FieldCondition('Partner_Track__r.Additional_Contracts_Enabled__c',FAP_Operator.NOT_EQUALS,null));
                                    }
                                }
                            }
                            //9.0 ends
                            //CSP Change - Start
                           if(FAP_Configuration.keyValue == 'Account__r.' && qualifiedName == FAP_Configuration.keyvalue+'CSP_Industry__c')
                            {
                               returnValue.add(new FAP_SetCondition(qualifiedName).includes(valueList));
                            } 
                            
                            if(FAP_Configuration.keyValue != 'Account__r.' && qualifiedName == FAP_Configuration.keyvalue+'Industries__c')
                            {
                               returnValue.add(new FAP_SetCondition(qualifiedName).inx(valueList));
                            }        
                            
                            system.debug('TestCSP returnValueCSP_Industry__c ' +returnValue);
                            
                            // 8.0 version - added Data_Center_Country__c and Data_Center_State__c
                            if(qualifiedName == 'CSP_Country__c' ||
                               qualifiedName == 'Service_Offering__c' ||
                               qualifiedName == 'CSP_Product__c' ||
                               qualifiedName == 'Data_Center_Country__c' ||   
                               qualifiedName == 'Data_Center_State__c' ||
                               qualifiedName == 'Cloud_Model__c' ||
                               qualifiedName == 'Contract_Type__c'
                               ){
                                List<String> lstCSPSOAccountId = getCSPServiceOfferingAccs(qualifiedName,valueList); //Get Service Offering Account Ids
                                
                                system.debug('**TestCSP qualifiedName  ' +qualifiedName );  
                                system.debug('**TestCSP valueList' +valueList); 
                                system.debug('**TestCSP lstCSPSOAccountId ' +lstCSPSOAccountId );
                                  
                                if(!lstCSPSOAccountId.isEmpty()){   
                                    returnValue.add(new FAP_ORCondition()
                                       .add(new FAP_SetCondition(FAP_Configuration.keyvalue+'id',FAP_Operator.INX,lstCSPSOAccountId )) 
                                                                     );
                                }else{
                                    returnValue.add(new FAP_SetCondition(FAP_Configuration.keyValue == 'Account__r.'? FAP_Configuration.keyvalue+'CSP_Industry__c':FAP_Configuration.keyvalue+'Industries__c', FAP_Operator.INX, valueList));
                                          
                                }
                            }         
                            system.debug('TestCSP returnValueCSP_Country__c ' +returnValue);
                            
                            //CSP Change - End
                            
                           //RP Add the like operator for Dell Cert Areas
                           String strCertification = FAP_Configuration.keyValue + 'Dell_Certification_Areas__c' ;
                           
                              if(qualifiedName == strCertification )
                              {
                               system.debug('Entry Qualified Name $$$$');
                                if(!isDistributorSeearch)
                                {
                                   system.debug('Entry Qualified Name1 $$$$');

                                    //5.0 Start - 0502
                                    // Need to add..,if value = ' Services'

                                    if(valueList[0].equalsIgnoreCase('Services') && !mapSubCompSearch.isempty())
                                    {
                                        if(strSubCompetency == null && strCompCategory == null){
                                                                           system.debug('Entry Qualified Name2 $$$$');

                                            for(String accCompt:mapSubCompSearch.keySet()){
                                                valueList.addAll((mapSubCompSearch.get(accCompt)).split(','));    
                                            }                                            
                                        }else if(strSubCompetency == null && strCompCategory != null){
                                                                           system.debug('Entry Qualified Name3 $$$$');

                                            for(String accCompt:mapSubCompSearch.values()){
                                                for(String strCert:accCompt.split(',')){
                                                    if(strCert.contains(strCompCategory) || (strCompCategory == 'Deployment' && Label.Deployment_Competencies_xtra.contains(strCert))){
                                                     valueList.add(strCert);
                                                    }
                                                }   
                                            } 
                                        }else{
                                            String strAccCertification = mapSubCompSearch.get(strSubCompetency);
                                                                               system.debug('Entry Qualified Name strAccCertification $$$$'+strAccCertification);

                                            if(strCompCategory == null){
                                                valueList.addAll(strAccCertification.split(','));
                                            }else{                                                
                                                for(String strCert:strAccCertification.split(',')){
                                                    if(strCert.contains(strCompCategory) || (strCompCategory == 'Deployment' && Label.Deployment_Competencies_xtra.contains(strCert))){
                                                        valueList.add(strCert);                                                        
                                                    }

                                                }
                                            }
                                        }
                                    }
                                    
                                  system.debug('TestCSP 5.1 valueList' +valueList);            
                                  //v5.1 - Start - To extend Partner Search logic to pull Competencies from 'Competency Tracker' Object
                                  List<String> listAccountId = new List<String>(); 
                                  
                                  If(FAP_Configuration.keyValue == 'Partner_Track__r.')//pull Competencies from Service competency field from partner track object only for PAM
                                    {
                                     
                                        List<String>valueList1 = new List<String>();
                                        valueList1.add(valueList[0]);
                                        
                                        returnValue.add(new FAP_ORCondition()
                                        .add(new FAP_SetCondition(qualifiedName).includes(valueList1))
                                        .add(new FAP_SetCondition('Partner_Track__r.Services_Competencies__c').includes(valueList))
                                        );
                                    }
                                                //5.0 End
                                    system.debug('TestCSP 5.1 returnValue' +returnValue);
                            }
                                
                      }
                                
                            if(qualifiedName == (FAP_Configuration.keyValue =='Account__r.'? 'Account__r.Partner_Relationship__c':'Partner_Track__r.Partner_Program_Tier__c')){
                                
                                if(!isDistributorSeearch){
                                 if(String.valueOf(valueList).indexOf('Distributor') > 0 && String.valueOf(valueList).indexOf('Federal') == 0){
                                 isDistributorSeearch = true;
                                 }
                                 else{
                                 isDistributorSeearch = false;
                                 }
                                returnValue.add(new FAP_SetCondition(qualifiedName).inx(valueList));
                                }else{
                                 if(String.valueOf(valueList).indexOf('Distributor') > 0 && String.valueOf(valueList).indexOf('Federal') == 0){
                                 isDistributorSeearch = true;
                                 }
                                 else{
                                 isDistributorSeearch = false;
                                 }
                                 }
                            }
                              
                            if(qualifiedName == FAP_Configuration.keyValue+'Partner_Type__c'){   
                                system.debug('****Partner Type value--'+valueList);                             
                                 if(String.valueOf(valueList).indexOf('Distributor') > 0 && String.valueOf(valueList).indexOf('Federal') == 0){
                                    isDistributorSeearch = true;
                                 }else{
                                    isDistributorSeearch = false;
                                 }
                                 //5.0 Start
                                 /*if(String.valueOf(valueList).indexOf('OEM') > 0){
                                    List<String> valueRel = new List<String>{'Titanium','Gold','Platinum'};
                                     if(FAP_Configuration.keyValue !='Account__r.')
                                    {
                                        valueRel.add('Titanium Black');
                                    }
                                    returnValue.add(new FAP_SetCondition(FAP_Configuration.keyValue =='Account__r.'? 'Account__r.Partner_Relationship__c':'Partner_Track__r.Partner_Program_Tier__c').inx(valueRel));                                
                                 }*/
                              

                                if(valueList == null || valueList.isempty()){                                   
                                    valueList = new List<String>{'Commercial General','Commercial SMB Partner','Commercial LE Partner','Commercial Public Partner','Solution Provider'};
                                    returnValue.add(new FAP_SetCondition(qualifiedName).inx(valueList));                                
                                }
                                if(valueList != null || !valueList.isempty()){
                                    returnValue.add(new FAP_SetCondition(qualifiedName).inx(valueList));
                                }  
                                system.debug('TestCSP 5.1 returnValue Account Partner_Type__c' +returnValue);                                 
                            }                      
                        } 
                     }
                     else {
                        Object value = field.typedValue;
                        system.debug('TestCSP else typedValue' +value );
                        returnValue.add(new FAP_FieldCondition(qualifiedName,FAP_Operator.LIKEX,value));                        
                        if(field.name == FAP_Configuration.keyValue+'Partner_Type__c' && 
                          (value!=null && string.valueOf(value).trim().length() != 0)){                            
                            partnerTypeFlag = true; //Ver 2.4 Do not show Distributor to Un-autheticated users
                        }    
                        system.debug('TestCSP else returnValue' +returnValue);
                    }
                }
            }
        }
     
        // Ver 2.5: To fix 'Too many script statements'
        if((countryCode != null) && (countryCode.trim().length() != 0) && countryFieldFlag == true){
            returnValue.add(new FAP_FieldCondition('Country__c', FAP_Operator.EQUALS, FAP_CountryUtils.PartnerCountryMap.get(countryCode)));
            FAP_SearchUtils.countrycode   =   countryCode;  //added by Ashish for User Story 204503:ABU Find a Reseller
        }
        //7.0 start
        
        if((keyword != null) && (keyword.trim().length() != 0)){
            if(bHasCloudServiceProvider){
            returnValue.add(new FAP_ORCondition()
                    .add(new FAP_FieldCondition(accField).likex(keyword))
                 );
            }else{
                returnValue.add(new FAP_ORCondition()
                        .add(new FAP_FieldCondition(FAP_Configuration.keyValue+FAP_Configuration.strRecLegalName).likex(keyword))
                        .add(new FAP_FieldCondition(accField).likex(keyword))
                        .add(new FAP_FieldCondition('name').likex(keyword))
                     );
            }
        }
        
        //7.0 end
        return returnValue;
    }
 
    //CSP - Start
  
    public List<String> getCSPServiceOfferingAccs(string strqualifiedName, List<string> getValueList){

        Set<String> cspAccountId = new Set<String>();
        
        final FAP_NestableCondition condition = null;
        
		// 8.0 version - added Data_Center_Country__c and Data_Center_State__c
		
        if(strqualifiedName != null && ((strqualifiedName == 'CSP_Product__c') || (strqualifiedName == 'Contract_Type__c') || (strqualifiedName == 'Data_Center_Country__c') || (strqualifiedName == 'Data_Center_State__c') || (strqualifiedName == 'Cloud_Model__c'))){
            condition = new FAP_AndCondition() 
            .add(new FAP_SetCondition(strqualifiedName).INCLUDES(getValueList));
            
            system.debug('**TestCSP MultistrqualifiedName : '+strqualifiedName);   
            system.debug('**TestCSP MultigetValueList : '+getValueList);   
        }else if(strqualifiedName != null && ((strqualifiedName == 'CSP_Country__c') || (strqualifiedName == 'Service_Offering__c'))){
            system.debug('**TestCSP else strqualifiedName : '+strqualifiedName);   
            system.debug('**TestCSP else getValueList : '+getValueList); 
            condition = new FAP_AndCondition() 
            .add(new FAP_SetCondition(strqualifiedName,FAP_Operator.INX, getValueList));
        }
        
        //condition = new FAP_AndCondition()  
                  condition
                    .add(new FAP_FieldCondition(FAP_Configuration.strIsPartner,true)) 
                    .add(new FAP_FieldCondition(FAP_Configuration.strApprovedforPartnerFinder,true)) 
                    .add(new FAP_FieldCondition(FAP_Configuration.strProfilePublishedtoPartnerFinder,'Yes'));
                    
        system.debug('**CSPSOcondition : '+condition );             
        if(FAP_Configuration.getInstance().isTermsConditionsFeatureEnabled){
                    condition
                    .add(new FAP_FieldCondition(FAP_Configuration.strUserAgreedtoPFTermsCond,FAP_Operator.NOT_EQUALS,'')) 
                    .add(new FAP_FieldCondition(FAP_Configuration.strDateAgreedtoPFTermsCond,FAP_Operator.NOT_EQUALS,null)); 
                }
 
        String soqlCSPSO = new FAP_SoqlBuilder()
                                            .selectx(FAP_Configuration.strObjectAPIName)
                                            .fromx('Service_Offering__c')
                                            .wherex(condition)
                                            .toSoql(null); 
                                            
        system.debug('**soqlCSPSO : '+soqlCSPSO );
        for(SObject sObj:Database.query(soqlCSPSO)){
           cspAccountId.add((String) sObj.get(FAP_Configuration.strObjectAPIName));        
        }
        system.debug('**cspAccountId : '+cspAccountId);
        return new List<String>(cspAccountId);
    }   
    //CSP - End
    
    // Ver 2.5: To fix 'Too many script statements'
    public FAP_GeoSearchCriteria getGeoSearchCriteria(){
        if((address != null) && (address.trim().length() != 0) && (latitude != null) && (longitude != null)){
            try{
                return new fap_GeoSearchCriteria(
                    new fap_GeoPoint(latitude,longitude)
                    ,Double.valueOf(''+this.distance)
                    ,((this.unit != null) && (this.unit.trim().length() != 0) && this.unit.trim().equalsIgnoreCase('miles')) ? FAP_UnitOfLength.MILES : FAP_UnitOfLength.KILOMETERS);
            }catch(FAP_IllegalArgumentException e){}
        }
        return null;
    }
    
    public static FAP_SearchForm blank(){
        return new FAP_SearchForm();
    }
    
    public String serialize(){        
        final Map<String,String> values = new Map<String,String>();
        
        if((this.keyword != null) && (this.keyword.length() != 0)){
           values.put('keyword', this.keyword);
           checking.put('accName', this.keyword);
          }  
       
        //Ver 2.2 Search by region
        if((this.region != null) && (this.region.length() != 0)){
            values.put('region',  this.region);            
        }
        
        // Ver 2.8

        if((this.countryCode != null) && (this.countryCode.trim().length() > 0)){
            string countryValue = (FAP_CountryUtils.PartnerCountryMap.get(this.countryCode) != null?String.escapeSingleQuotes(FAP_CountryUtils.PartnerCountryMap.get(this.countryCode).trim()):'') ;
            values.put('c',  this.countryCode);
            checking.put('country', countryValue);
        }
        if((this.urlCountryCode != null) && (this.urlCountryCode.trim().length() > 0)){
            values.put('urlc',  this.urlCountryCode);            
        }

        if((this.urlpartnertype!= null) && (this.urlpartnertype.trim().length() > 0)){
            values.put('pt',  this.urlpartnertype);
            checking.put('pt',  this.urlpartnertype);            
        }
        /* <START> User story 188311 - Reset Functionality(Sort By and Pagination) by Kokila 01-Aug-2015 */
        if((this.sortOption != null) && (this.sortOption.trim().length() > 0)){
            values.put('sort',  this.sortOption);
            System.debug('this.sortOption - Serialize>>>>>>>>>> '+this.sortOption);
        }
        /* <END> User story 188311 - Reset Functionality(Sort By and Pagination) by Kokila 01-Aug-2015 */

        /* <START> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
        if((this.pageNumber!= null) && (this.pageNumber.trim().length() > 0)){           
            values.put('pgnum', this.pageNumber);
        }
        /* <START> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
        
        // Ver 2.5: To fix 'Too many script statements'
        if((this.address != null) && (this.address.length() != 0)){
            checking.putAll(new Map<String, String>{
                                            'address'=>this.address,
                                            'distance'=>(this.distance == null ? '' : string.valueOf(this.distance)),                                            
                                            'unit'=>(this.unit == null ? '' : this.unit)});
            values.putAll(new Map<String, String>{
                                            'address'=>this.address,
                                            'unit'=>(this.unit == null ? '' : this.unit),
                                            'distance'=>(this.distance == null ? '' : string.valueOf(this.distance)),
                                            'latitude'=>(this.latitude == null ? '' : string.valueOf(this.latitude)),
                                            'longitude'=>(this.longitude == null ? '' : string.valueOf(this.longitude))});
                                           
        }

        if(this.allFields != null && this.allFields.size() > 0){
            for(FAP_SearchField field : this.allFields){
                if(Limits.getScriptStatements() >= config.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 2.6
                if(field.notBlank){
                       
                    values.put(
                        
                        ((field.objectName == null) || (field.objectName.trim().length() == 0) ? '' : field.objectName.trim().toLowerCase()) + '.' 
                            + ((field.localName == null) || (field.localName.trim().length() == 0) ? '' : field.localName.trim().toLowerCase()),
                        field.isMultiselectPicklist ? serializeList(field.values) : field.value
                    );
                    checking.put(
                        ((field.objectName == null) || (field.objectName.trim().length() == 0) ? '' : field.objectName.trim().toLowerCase()) + '.' 
                            + ((field.localName == null) || (field.localName.trim().length() == 0) ? '' : field.localName.trim().toLowerCase()),
                        field.isMultiselectPicklist ? serializeList(field.values) : field.value
                    );              
                }
            }
        }
        Integer i = 1;    
        
        for(String key : values.keySet()){
            values.put(key,EncodingUtil.urlEncode(values.get(key),'UTF-8')); 
            system.debug('$$$$$Values :'+ values);            
        }
        List<String> str = new List<String>();
        for(String key : checking.keySet()){ 
             checking.put(key, checking.get(key));
             str.add(checking.get(key));
             this.value = FAP_StringUtils.joinArray(str, '|');                    
             system.debug('$$$$$this.value :'+ this.value);           
        }                
        return FAP_MapUtils.joinMap(values,'=','&');  
        
    }
        
    public static FAP_SearchForm deSerialize(String serialized){
        final FAP_SearchForm form = FAP_SearchForm.blank(); 
        final List<String> params = FAP_StringUtils.split(serialized, '&');
        if(params != null && params.size() > 0){
            final Map<String,String> values = new Map<String,String>();
            for(String param : params){
            System.debug('param before>>>>>>>>>>>>>>>>>>> '+FAP_StringUtils.trim(FAP_StringUtils.substringAfter(param,'=')));           
                values.put(
                    FAP_StringUtils.lowerCase(FAP_StringUtils.trim(FAP_StringUtils.substringBefore(param,'=')))
                    ,EncodingUtil.urlDecode(FAP_StringUtils.trim(FAP_StringUtils.substringAfter(param,'=')),'UTF-8'));
                    System.debug('param after>>>>>>>>>>>>>>>>>>> '+EncodingUtil.urlDecode(FAP_StringUtils.trim(FAP_StringUtils.substringAfter(param,'=')),'UTF-8'));
            }
            System.debug('values>>>>>>>>>>>>>>>>>>> '+values);
            final Map<String,FAP_SearchField> nameToFieldIndex = new Map<String,FAP_SearchField>();
            if(form.allFields != null && form.allFields.size() > 0){
                for(FAP_SearchField field : form.allFields){
                    nameToFieldIndex.put(FAP_StringUtils.lowerCase(field.objectName) + '.' + FAP_StringUtils.lowerCase(field.localName),field);
                }
            }
            string cName = '';
            cName = (FAP_CountryUtils.PartnerCountryMap.get(form.countryCode) != null?String.escapeSingleQuotes(FAP_CountryUtils.PartnerCountryMap.get(form.countryCode).trim()):'') ;
            for(FAP_Country__mdt obj :[SELECT Id,DeveloperName,FAP_Country_Value__c,Units__c FROM FAP_Country__mdt WHERE FAP_Country_Value__c =: cName]){
                    form.unit = obj.Units__c;   
                   
            }
            // Ver 1.0: Assign country code from querystring to variable, so that if the request URL contains keyword, the search will filter by country
            form.countryCode = FAP_StringUtils.upperCase(values.get('c'));
            form.urlpartnertype = values.get('pt');
            /* <START> User story 188311 - Reset Functionality(Sort By and Pagination) by Kokila 01-Aug-2015 */
            form.sortOption = values.get('sort');
            System.debug('form.sortOption - DeSerialize>>>>>>>>>> '+form.sortOption);
            /* <END> User story 188311 - Reset Functionality(Sort By and Pagination) by Kokila 01-Aug-2015 */
            /* <START> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
            form.pageNumber = values.get('pgnum');
            /* <END> User story 194596 - To Remain in the same Page Number after Back Button is selected from detail page by Kokila 03-Aug-2015 */
            form.keyword     = values.get('keyword');
            
            form.address = values.get('address'); 
            system.debug('Naga###address:'+form.address);           
            
            try{ form.distance = Integer.valueOf(values.get('distance')); } catch(System.TypeException e){} catch(NullPointerException e){}
            try{ form.latitude = Double.valueOf(values.get('latitude')); } catch(System.TypeException e){} catch(NullPointerException e){}
            try{ form.longitude = Double.valueOf(values.get('longitude')); } catch(System.TypeException e){} catch(NullPointerException e){}

            form.strSubCompetency = values.get('servcomp');
            form.strCompCategory = values.get('cpmcategory');
            
            FAP_SearchField field = null;
            for(String fieldName : values.keySet()){
                field = nameToFieldIndex.get(fieldName);
                if(field != null){
                    if(field.isMultiselectPicklist){
                        field.values = deSerializeList(values.get(fieldName));
                    } else {
                        String value = values.get(fieldName);
                        
                        field.value = value;
                        System.debug('field.value>>>>>>>>>>>>>>>>>>> '+field.value);
                    }
                }
            }
        }
        return form;
    }
    @TestVisible
    private static String serializeList(List<String> aList){
        List<String> encoded = new List<String>();
        if(aList != null && aList.size() > 0){
            for(String value : aList){
                encoded.add(EncodingUtil.urlEncode(value,'UTF-8'));
            }
        }
        return FAP_StringUtils.joinArray(encoded,',');
    }
    
    public static List<String> deSerializeList(String serializedList){
        final List<String> decoded = new List<String>();
        final List<String> split = FAP_StringUtils.split(serializedList,',');
        if(split != null && split.size() > 0){
            for(String value : split){
                decoded.add(EncodingUtil.urlDecode(value,'UTF-8'));
                System.debug('decoded>>>>>>>>>>>>>>>>>>> '+decoded);
            }
        }
        return decoded;
    }
    
    public static List<SelectOption> toSelectOption(List<Integer> integers){
        Map<Integer,String> distanceMap = new Map<Integer,String>();
             distanceMap.put(Integer.valueOf('5'),'5 miles/8 kilometres');
             distanceMap.put(Integer.valueOf('10'),'10 miles/16 kilometres');
             distanceMap.put(Integer.valueOf('25'),'25 miles/40 kilometres');
             distanceMap.put(Integer.valueOf('50'),'50 miles/80 kilometres');
             distanceMap.put(Integer.valueOf('75'),'75 miles/120 kilometres');
             distanceMap.put(Integer.valueOf('100'),'100 miles/160 kilometres');
             distanceMap.put(Integer.valueOf('200'),'200 miles/320 kilometres');
             
        List<SelectOption> returnValue = new List<SelectOption>();
        if(integers != null && !integers.isEmpty()){
            for(Integer anInteger : integers){
                returnValue.add(new SelectOption(''+anInteger,distanceMap.get(anInteger)));
            }
        }
        return returnValue;
    }
    /* 2.0 - CR 7105 - Implement dynamic FAP search page. Fetch the search fields from FAP_Customization__c*/
    public void getFAPCustomization(){
        String regionStr= '';
        String paramString = FAP_StringUtils.substringAfter(ApexPages.currentPage().getUrl(),'?');
        countryCode = (FAP_PageUtils.param('c')!=null?FAP_PageUtils.param('c').toUpperCase():'');
        urlCountryCode = (FAP_PageUtils.param('urlc')!=null?FAP_PageUtils.param('urlc').toUpperCase():''); // Ver 2.8
        languagecode = (FAP_PageUtils.param('l')!=null?FAP_PageUtils.param('l').toLowerCase():'');
        urllanguagecode = (FAP_PageUtils.param('urll')!=null?FAP_PageUtils.param('urll').toLowerCase():'');
        urlpartnertype  = (FAP_PageUtils.param('pt')!=null?FAP_PageUtils.param('pt').toLowerCase():'');  //v4.0 - Added
        
        if(countryCode==null || countryCode==''){
            this.setUserCountry();
            
        }
        // Ver 2.8
        if((urlCountryCode == null) || (urlCountryCode.trim().length() == 0)){
            this.urlCountryCode = this.countryCode;
        }
               
        if((urllanguagecode == null) || (urllanguagecode.trim().length() == 0)){
            if(this.languagecode == 'nl'){ this.languagecode = 'nl_nl';}
            if(this.languagecode == 'zh'){
            this.languagecode = 'zh_'+this.urlCountryCode;
            }
            if(this.languagecode == 'en'){ this.languagecode = 'en_us';}            
            this.urllanguagecode = this.languagecode;
        }
        //Ver 2.9
        String countryName ='';
        // Ver 3.0
        countryName = (FAP_CountryUtils.PartnerCountryMap.get(urlCountryCode) != null?String.escapeSingleQuotes(FAP_CountryUtils.PartnerCountryMap.get(urlCountryCode).trim()):'') ; // Ver 2.8
        List<sObject> sObjList = Database.query(
                               'select FAP_Region__c,Region__c,FAP_Country_Value__c,Enable_for_FAP__c,User_Language_Locale_Key__c from Country__c' 
                               + ' where FAP_Country_Value__c = \'' +countryName+ '\' and Enable_for_FAP__c = True LIMIT 1');
        if(sObjList.size() >0){
            regionStr = (String)sObjList[0].get('Region__c');
        }
        if(regionStr == null || regionStr == ''){
            regionStr = regionDefault;
        }       
               
        if(regionStr != null){
            FAP_PartnerCountryLangInt pl =   new FAP_PartnerLanguage(true);
            User usr1 = [Select ContactId, Profile.Name from user where Id=: UserInfo.getUserId()]; 
            if(usr1.ContactId !=null){
                userType = 'Authenticated';
                //Get the language of autheticated user  
                usrLanguage = pl.returnMatchValue(UserInfo.getLanguage());
            }
            else{
                userType = 'Un-authenticated';
               
                usrLanguage = pl.returnMatchValue(urllanguagecode);
            }
            if(usrLanguage == Null || usrLanguage ==''){
                usrLanguage = langaugeDefault;           
            }
            system.debug('--userType--'+userType);
            system.debug('--regionStr--'+regionStr);
            system.debug('--usrLanguage--'+usrLanguage);
            
            try{
                 final FAP_NestableCondition condition = new FAP_AndCondition()
                                                    .add(new FAP_FieldCondition('Region__c' ).equals   (regionStr)) 
                                                    .add(new FAP_FieldCondition('User_type__c').equals  (userType))
                                                    .add(new FAP_FieldCondition('Is_Active__c').equals  (True));
                                                    
                List<FAP_OrderBy> orderList =  new List<FAP_OrderBy>{
                    
                    new FAP_OrderBy('Field_Order__c').ascending()
                };
                system.debug('TestCSP condition ' +condition);
                system.debug('TestCSP orderList ' +orderList);
                 List<FAP_Customization__c> queryFAPCustomization = Database.query(
                                                                    new FAP_SoqlBuilder()
                                                                        .selectx(new Set<Object>{
                                                                            'Datatype__c',
                                                                            'Name',
                                                                            'Field_label__c',
                                                                            'Help_text__c',
                                                                            'Is_Multiselect__c',
                                                                            'Location__c',
                                                                            'Pick_list_value__c',
                                                                            'Region__c',
                                                                            'Field_Order__c',
                                                                            'User_type__c',
                                                                            'Is_Active__c'}) 
                                                                        .fromx('FAP_Customization__c')
                                                                        .wherex(condition)
                                                                        .OrderByx(orderList)
                                                                        .toSoql()
                                                                );
                basicFieldsMap = new Map <String,FAP_Customization__c>();
                advancedFieldsMap = new Map <String,FAP_Customization__c>();
                cspFieldsMap  = new Map <String,FAP_Customization__c>();
                
                List<FAP_Customization__c>fapRegularList = new List<FAP_Customization__c>();
                List<FAP_Customization__c>fapAdvancedList = new List<FAP_Customization__c>();
                List<FAP_Customization__c>fapCSPList = new List<FAP_Customization__c>();
                
                for(FAP_Customization__c fap : queryFAPCustomization){
                    //CSP Change - Start
                    if(fap.Location__c == 'Regular' && fap.Name != FAP_Configuration.strObjectName+'.Partner_Track_Account_Local_Name__c'){//  7.0 version - added Partner_Track_Account_Local_Name__c
                        fapRegularList.add(fap);
                    }//
                    if(fap.Name == FAP_Configuration.strObjectName+'.Partner_Track_Account_Local_Name__c' || fap.Name == FAP_Configuration.strObjectName+'.Partner_Type__c' || fap.Name == (FAP_Configuration.keyValue == 'Account__r.'? FAP_Configuration.strObjectName+'.CSP_Industry__c':FAP_Configuration.strObjectName+'.Industries__c') ||fap.Name.contains('Service_Offering__c')){ //kokila & 7.0 version- Partner_Track_Account_Local_Name__c
                        fapCSPList.add(fap);
                    }
                    
                    //CSP Change - End
                    if(fap.Location__c == 'Advanced'){
                        fapAdvancedList.add(fap);
                    }
                }
                system.debug('*************TestCSP fapRegularList1' +fapRegularList);
                system.debug('*************TestCSP fapCSPList2' +fapCSPList);
                 
                 for(FAP_Customization__c fap : fapRegularList){    
                     if(FAP_StringUtils.isNotBlank(fap.Name)){
                        String fapTempName ='';
                        if(FAP_StringUtils.contains(fap.Name, '.')){
                            fapTempName = FAP_StringUtils.substringAfter(fap.Name,'.');
                        }
                        else{
                            fapTempName = fap.Name;
                        }
                            
                        if(!basicFieldsMap.containsKey(fapTempName)){
                            basicFieldsMap.put(fapTempName,fap);
                            searchBasicFAPString += fap.Name+'|';                                           
                        }
                    }
                }
                for(FAP_Customization__c fap : fapAdvancedList){    
                     if(FAP_StringUtils.isNotBlank(fap.Name)){
                        String fapTempName ='';
                        if(FAP_StringUtils.contains(fap.Name, '.')){
                            fapTempName = FAP_StringUtils.substringAfter(fap.Name,'.');
                        }
                        else{
                            fapTempName = fap.Name;
                        }
                        if(!advancedFieldsMap.containsKey(fapTempName)){
                            advancedFieldsMap.put(fapTempName,fap);
                            searchAdvancedFAPString += fap.Name+'|';
                        }
                    }
                }
                for(FAP_Customization__c fap : fapCSPList){
                    if(FAP_StringUtils.isNotBlank(fap.Name)){
                        String fapTempName ='';
                        if(FAP_StringUtils.contains(fap.Name, '.')){
                            fapTempName = FAP_StringUtils.substringAfter(fap.Name,'.');
                        }
                        else{
                            fapTempName = fap.Name;
                        }
                            
                        if(!cspFieldsMap.containsKey(fapTempName)){
                            cspFieldsMap.put(fapTempName,fap);
                            searchCSPString += fap.Name+'|';                                           
                        }
                    }
                }
                system.debug('***************************************');
                system.debug('************CSP String******************'+searchCSPString+'***'+cspFieldsMap);
                system.debug('***************************************');

            }catch(Exception exp){
                FAP_PageUtils.addError(Label.failed_to_load_record + exp.getMessage());
            }
        }
    }

    // Ver 2.5: To fix 'Too many script statements'
    // Ver 2.1: Get list of FAP_OrderBy based on the selected sortOption  
    
    public List<FAP_OrderBy> getOrderby(){
        List<FAP_OrderBy> fapOrderByList = new List<FAP_OrderBy>();
        
                    
        try{
            system.debug('###################  sortOption   ' + sortOption);
            if ((Label.FAP_Company_Name != null) && (sortOption != null) && sortOption.trim().equalsIgnoreCase(string.valueOf(1))){
                fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyValue == 'Account__r.'? FAP_Configuration.keyvalue+'name':FAP_Configuration.keyvalue+'Primary_Sales_Motion_Account_Legal_Name__c')); 
            }else if ((Label.FAP_Partner_Status != null) && (sortOption != null) && sortOption.trim().equalsIgnoreCase(string.valueOf(2))){
               fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyvalue+'FAP_Sort_Order__c'));
            }

       
           else if ((Label.FAP_Distance != null) && (sortOption != null) && sortOption.trim().equalsIgnoreCase(string.valueOf(3))){
                fapOrderByList.add(new FAP_OrderBy('City__c'));
            }
           
           else { if(((sortOption == null) || sortOption.trim().equalsIgnoreCase(string.valueOf(0)))) {
               
               if(((this.address == null) || (this.address.trim().length() == 0)) && !isDistributorSeearch){
                    fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyvalue+'FAP_Sort_Order__c'));
                    fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyvalue+'Prioritize_in_FAP__c').descending()); //added by ashish for UserStory 208946:Prioritize in FAP: Sort Order
                    fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyValue == 'Account__r.'? FAP_Configuration.keyvalue+'name':FAP_Configuration.keyvalue+'Primary_Sales_Motion_Account_Legal_Name__c'));
               } else if(isDistributorSeearch && (!((this.address != null) && (this.address.trim().length() != 0)))){
                   fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyvalue+'FAP_Sort_Order__c')); 
                   fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyvalue+'Prioritize_in_FAP__c').descending()); //added by ashish for UserStory 208946:Prioritize in FAP: Sort Order                  
                   fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyValue == 'Account__r.'? FAP_Configuration.keyvalue+'name':FAP_Configuration.keyvalue+'Primary_Sales_Motion_Account_Legal_Name__c'));
               }
                  
                    
            } else {
                if(isDistributorSeearch && (!((this.address != null) && (this.address.trim().length() != 0)))){
                    fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyvalue+'Prioritize_in_FAP__c').descending()); //added by ashish for UserStory 208946:Prioritize in FAP: Sort Order
                    fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyValue == 'Account__r.'? FAP_Configuration.keyvalue+'name':FAP_Configuration.keyvalue+'Primary_Sales_Motion_Account_Legal_Name__c'));
                }
            } 
            

            if (((this.address != null) && (this.address.trim().length() != 0))){
                if(!isDistributorSeearch){
                  fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyvalue+'FAP_Sort_Order__c')); 
                  fapOrderByList.add(new FAP_OrderBy(FAP_Configuration.keyvalue+'Prioritize_in_FAP__c').descending()); //added by ashish for UserStory 208946:Prioritize in FAP: Sort Order              
                  fapOrderByList.add(new FAP_OrderBy('City__c'));
                }
              
            }
            }

            system.debug('###################  fapOrderByList   ' + fapOrderByList);
            
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: FAP.FAP_SearchForm | Method: getOrderby]');
            FAP_PageUtils.addError(Label.failed_to_load_record + e.getMessage());
        }
        return fapOrderByList;
    }
     @TestVisible
     private void setUserCountry(){
        User usr = [Select u.Contact.MailingCountry, u.ContactId From User u Where Id = :UserInfo.getUserId()];
        if(usr.ContactId!=null && usr.Contact.MailingCountry!=null){
            string mailingCountry = usr.Contact.MailingCountry.toUpperCase();
            Schema.DescribeFieldResult f = Partner_Location__c.Country__c.getDescribe();
            List<Schema.PicklistEntry> entries = f.getPicklistValues();
            for(Schema.PicklistEntry entry: entries){
                if(entry.getLabel().contains(mailingCountry) || 
                   entry.getValue().contains(mailingCountry)){
                    Integer index1 = entry.getValue().lastIndexOf('(');
                    Integer index2 = entry.getValue().lastIndexOf(')');
                    if(index1>=0 && index2>index1){
                        this.countryCode = entry.getValue().subString(index1+1, index2);
                    }
                    
                }
                
            }   
        }
    }

}
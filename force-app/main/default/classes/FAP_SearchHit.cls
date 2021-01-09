/** 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.1         Niveda    24-May-2019        FY20-07-02  17541   Tile to display address from Partner location
1.2         Vismy     13-Sep-2019        FY20-11-01  18088   FAP - Tile records on searching willdisplay the account name information only once
**/
global class FAP_SearchHit implements Comparable {
    private Partner_Location__c location;
    public static string minLocFields;
    
    
    public static Set<Object> minimumFields()
    {
        final Set < Object > returnValue = new Set < Object > ();
        final List < FAP_FieldConfiguration > combined = new List < FAP_FieldConfiguration > ();
        
        combined.addAll(FAP_Configuration.getInstance().searchMinFieldsforPartnerLoc);
        
        if (combined != null && combined.size() > 0) 
        {
            for (FAP_FieldConfiguration field: combined) 
            {
                returnValue.add(field.fieldName);
            }
        }
        system.debug('$$$$$Minimum Fields of Partner Location: ' +returnValue);
        
        for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().searchMinFieldsforAccount ){
            if(fieldConfiguration != null){
                returnValue.add((FAP_Configuration.StrObjectName.equalsIgnoreCase(fieldConfiguration.objectName) ? FAP_Configuration.keyValue : '') 
                            + fieldConfiguration.fieldName);
            }
        }
          
        system.debug('$$$$$Minimum Fields: ' +returnValue);
        return returnValue;
     }
    
    //Local Name code is added by Shravan
    
    global String partnerNameLocal {get{
    
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType accSchema = FAP_Configuration.keyValueWithoutDot == 'Account__r'? schemaMap.get('Account'):schemaMap.get('Partner_Track__c');
    Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
        
    sObject sb = location.getSobject(FAP_Configuration.keyValueWithoutDot);
    // 1.2 Added by Vismy start - FAP - Tile records on searching willdisplay the account name information only once
   // string pNameLoc = (FAP_Configuration.keyValueWithoutDot == 'Account__r'? String.valueOf(sb.get('NameLocal')) : String.valueOf(sb.get('Partner_Track_Account_Local_Name__c')));
    
   // if(pNameLoc==null && FAP_Configuration.keyValueWithoutDot != 'Account__r')
   // {
    //    pNameLoc = String.valueOf(sb.get('Master_Local_Name__c'));
    //}
    
    string strpNameLoc;
    if(String.valueOf(sb.get('Partner_Track_Account_Local_Name__c')) != null){
        strpNameLoc = String.valueOf(sb.get('Partner_Track_Account_Local_Name__c'));  
    } 
    else if(String.valueOf(sb.get('Primary_Sales_Motion_Account_Local_Name__c')) != null){
          strpNameLoc = String.valueOf(sb.get('Primary_Sales_Motion_Account_Local_Name__c')); 

    }
    else {
        strpNameLoc = String.valueOf(sb.get('partner_track_account_name__c'));    
       
    }
    
    return strpNameLoc;}}
    //End 1.2
    
    global string searchSerialize{get;set;}
    global Integer resultSequenceNumber {get;set;}
    global String locationName {get{ return location.name;}}
    global ID locationId {get{ return location.id;}}
    
    // Code for Legal Name by Shravan & Neeti
    
    global String partnerName {get{ 
    
    String pName = FAP_Configuration.keyValueWithoutDot == 'Account__r' ? string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Name')):string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Primary_Sales_Motion_Account_Legal_Name__c'));
    
    if(pName == null  && FAP_Configuration.keyValueWithoutDot != 'Account__r')
    {
         pName = string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Master_Legal_Name__c'));
    }
    
    if(pName!= null  && pName.length() > 36){
        pName = pName.substring(0, 35); 
        pName = pName.substringBeforeLast(' ');     
    }
    return pName;}}
    
    //Added FAP Category for summary box. By Sree 
    
    global String fapCategory{get{
    string fCategory = string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('FAP_Category__c'));
    if(fCategory!=null && fCategory!='' && fCategory.length()>31){
    fCategory = fCategory.substring(0,30);  
    }
    return fCategory;}}
    
    global ID partnerAccountId {get{ return string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('id'));}}
    global String website {get{ return FAP_UrlUtils.ensureUrlBeginsWithHttp(location.Website__c);}}
    global Boolean isPrimary {get{ return location.Is_Primary__c;}}
    global Boolean isMainContact {get{ return location.isMainContact__c;}}
    global String pointOfContactPhone {get{ return location.Point_of_Contact_Phone__c;}}
    global String pointOfContactName {get{ return location.Point_of_Contact_Name__c;}}
    global String pointOfContactEmail {get{ return location.Point_of_Contact_Email__c;}}
    global String description {get{ return location.Description__c;}}
    
    global String street {get{ 
            string streetStr;
            streetStr = location.Street__c ;                     
            if(streetStr != null && streetStr.length() > 0)
            {
                if(streetStr.length() > 45)
                {
                    streetStr = streetStr.substring(0,44);
                    streetStr = streetStr.substringBeforeLast(' ');
                    streetStr = streetStr.substringBeforeLast(',');                        
                }                  
            }
        
    return streetStr;}}
    
    global string city {get{return location.City__c;}}
    
    global Map<String,String> mapServiceCompetency = new Map<String,String>();
    global Map<Id,String> mapPL = new Map<Id,String>();//3.0
     //Ver 1.1
    global String stateProvince {get{return location.State_Province__c; }}     
    global String postalCode {get{ return location.Postal_Code__c;}}
    global String country {get{ return location.Country__c ;}}
    global Double longitude {get{ return location.Longitude__c;}}
    global Double latitude {get{ return location.Latitude__c;}}
    global FAP_GeoPoint point {get;private set;}
    global Boolean containsDistance {get{return distanceInKilometers != null;}}
    global Double distanceInKilometers {get;private set;}
    global Double distanceInMiles {get{ return FAP_ConversionUtils.convert(distanceInKilometers,FAP_UnitOfLength.KILOMETERS,FAP_UnitOfLength.MILES);}}
    global string keyConfigValue {get{return string.valueof(FAP_Configuration.getInstance().KeyObject);}}
    
    global Boolean isRecommended {get{return Boolean.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Partner_Finder_Recommended_Flag__c'));}}
    global String logoId {get;set;}
    
    
    global String logoRecordId {get {return  FAP_Configuration.keyValueWithoutDot == 'Account__r' ? ( (string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('logo__c')) == null) ? null : string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('logo__c')) ) : ( string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('logo__c')) != null ? string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('logo__c')) : (String.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Master_Logo_ID__c'))== null?null:String.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Master_Logo_ID__c'))));}}
   
    global Map<String,Object> userRequestedFieldValues {get;set;}
    
    // Ver 1.0: Added partnerRelationship and partnerType
    global String partnerRelationship {get{return  FAP_Configuration.keyValueWithoutDot == 'Account__r' ? ( location.getSobject(FAP_Configuration.keyValueWithoutDot) == null ? null : string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Partner_Relationship__c')) ) : string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Partner_Program_Tier__c'));}} 
    
    global String partnerType {get{return location.getSobject(FAP_Configuration.keyValueWithoutDot) == null ? null : string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Partner_Type__c'));}}
    
    //global String certiCompleted {get{return location.getSobject(FAP_Configuration.keyValueWithoutDot) == null ? null :string.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Certification_Completed__c'));}}
 
    global FAP_SearchHit(Partner_Location__c location){
        if(location == null){
            throw new FAP_IllegalArgumentException('Invalid argument: location is null');
        }
        this.location = location;
        this.point = new FAP_GeoPoint(latitude, longitude);
    }
    
    global boolean dellTechPartner {get{return FAP_Configuration.keyValueWithoutDot == 'Partner_Track__r'? Boolean.valueof(Location.getSobject(FAP_Configuration.keyValueWithoutDot).get('Dell_Technologies_Partner__c')): false;}} 
    
    global void setDistanceToPoint(FAP_GeoPoint point){
        distanceInKilometers = FAP_GeoMath.distanceInKilometers(this.point,point);
    }

    global static List<FAP_SearchHit> sortByDistance(List<FAP_SearchHit> hits){
        return (List<FAP_SearchHit>) FAP_ArrayUtils.qsort(hits,new SearchHitSortByDistComparator());        
    }
    
    // Ver 2.0: Implement the compareTo() method derived from Comparable interface
    global Integer compareTo(Object compareTo) {
        FAP_SearchHit compareToHit = (FAP_SearchHit)compareTo;
        if (distanceInKilometers == compareToHit.distanceInKilometers) {
            return 0;
        }
        if (distanceInKilometers > compareToHit.distanceInKilometers){ 
            return 1;
        }
        return -1;        
    }

    global class SearchHitSortByDistComparator implements FAP_ObjectComparator{

        global Integer compare(Object object1, Object object2){
            final Double r1 = ((FAP_SearchHit)object1).distanceInKilometers;
            final Double r2 = ((FAP_SearchHit)object2).distanceInKilometers;
            return (r1 == r2 || (r1 == null && r2 == null)) ? 0 : ((r1 < r2) ? -1 : 1);
        }
    }
}
// This class manipulate partner country
global class FAP_CountryUtils {
  
  // Ver 1.0: This method returns a map collection of country which the country code as value while label as label
  global static Map<string, string> partnerCountryMap{
      //
    get{
      if(partnerCountryMap == null || partnerCountryMap.size() == 0){
        partnerCountryMap = partnerCountryMap == null ? new Map<string, string>() : partnerCountryMap;
        Schema.DescribeFieldResult describeFR = Partner_Location__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> entries = describeFR.getPicklistValues();
        for(Schema.PicklistEntry entry : entries){
          Integer index1 = entry.getValue().lastIndexOf('(');
          Integer index2 = entry.getValue().lastIndexOf(')');
          partnerCountryMap.put(entry.getValue().subString(index1+1, index2), entry.getLabel());
        }
      }
    return partnerCountryMap;
    }
    private set;
  }
  
  // Ver 2.0: This method returns a map collection of country which the country name as value while label as label
  global static Map<string, string> partnerShippingCountryMap{
    get{
      if(partnerShippingCountryMap == null || partnerShippingCountryMap.size() == 0){
        partnerShippingCountryMap = partnerShippingCountryMap == null ? new Map<string, string>() : partnerShippingCountryMap;
        Schema.DescribeFieldResult describeFR = Partner_Location__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> entries = describeFR.getPicklistValues();
        for(Schema.PicklistEntry entry : entries){
          Integer index = entry.getValue().lastIndexOf('(');
          partnerShippingCountryMap.put(entry.getValue().subString(0, index-1), entry.getLabel());
        }
      }
    return partnerShippingCountryMap;
    }
    private set;
  }
  
  // Ver 2.0: This method returns a map collection of country which the label as both the value and label
  global static Map<string, string> partnerLocationCountryMap{
    get{
      if(partnerLocationCountryMap == null || partnerLocationCountryMap.size() == 0){
        partnerLocationCountryMap = partnerLocationCountryMap == null ? new Map<string, string>() : partnerLocationCountryMap;
        Schema.DescribeFieldResult describeFR = Partner_Location__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> entries = describeFR.getPicklistValues();
        for(Schema.PicklistEntry entry : entries){
          partnerLocationCountryMap.put(entry.getLabel(), entry.getLabel());
        }
      }
    return partnerLocationCountryMap;
    }
    private set;
  }
}
/****************************************************************


v2.0 Devika  CR 9365  Added "Partner_Support_Email__c" to the SOQL
                      query.
*****************************************************************/

public virtual class PartnerCountry Implements PartnerCountryLangInt{
            
            private String defaultCountryKey = ''; 
            private Map<String, String> usrCountryMap = new Map<String, String>();
            private Map<string, Country__c> countryCodeMap = null;  // Fenny added on 7 Dec 2012 for 14.2 SSO project               
        
            public PartnerCountry(){
                initCountryMap();
            }
        
            public void initCountryMap(){               
                List<Country__c> countries = [
                select name, code__c 
                from Country__c 
                where Is_Active_Partner_Country__c = true
                order by name];
                
                for(Country__c country : countries){
                    //this.usrCountryMap.put(StringUtils.uppercase(country.Code__c), country.id);
                    this.usrCountryMap.put(country.Code__c == null ? null : country.Code__c.toUpperCase(), country.id);
                    //System.debug('Code__c = '+ country.Code__c + ', id= '+country.name);
                }
            }           
            
            public virtual String returnDefaultKey(){
                return defaultCountryKey;
            }   
            
            //method to get value by passing keyValue like en-us        
            public virtual String returnMatchValue(String tempKey){ 
                System.debug('tempKey in returnCountryValue>>>>' + tempKey);                        
                if(checkingExistence(tempKey)){             
                    System.debug('found it.....');  
                    return usrCountryMap.get(StringUtils.UpperCase(tempKey));                   
                }else{
                    System.debug('not found it, calling default.....');
                    return usrCountryMap.get(StringUtils.UpperCase(returnDefaultKey()));    
                }                                           
            } 
            
            
            public virtual Boolean checkingExistence(String tempKey){
                Boolean isExist = false;
                if(StringUtils.isNotBlank(tempKey)&& usrCountryMap.containsKey(StringUtils.UpperCase(tempKey))) isExist=true;
                return isExist;
            }
            
            public Map<string,string> returnUsrMap(){
                return usrCountryMap;
            }
            
            // Fenny added on 7 Dec 2012 for 14.2 SSO project
            public Map<string, Country__c> returnCountryCodeMap(){
                if(countryCodeMap == null) { countryCodeMap = new Map<string, Country__c>(); }
                
                if(countryCodeMap.size() == 0){
                        for(Country__c country : [select name, code__c, Inc_Vendor_Name__c, Dell_Online_Country_Code__c, User_Profile_ID__c,
                                                      Region__c, Is_Active_Partner_Country__c, User_Language_Locale_Key__c,
                                                      User_Locale_Sid_Key__c, User_Email_Encoding_Key__c, User_Time_Zone_Sid_Key__c, User_Currency_Iso_Code__c,
                                                      Lead_Management_Enabled__c,Lead_Management_Enabled_for_OEM__c,Partner_Relationship__c,
                                                      Partner_Relationship_for_OEM__c
                                                      /* CR 9365 ***/,Partner_Support_Email__c
                                                      from Country__c]){
                        //this.countryCodeMap.put(StringUtils.uppercase(country.Code__c), country);
                        this.countryCodeMap.put(country.Code__c == null ? null : country.Code__c.toUpperCase(), country);  
                    }
                }
                return countryCodeMap;
            }

            /*
                //Search by keyValue and return default language if not specific else specific value 
            public Boolean searchCountry(String tempKey){
                Boolean isSearchable = false;
                if(checkingExistence(tempKey))isSearchable = true;              
                return isSearchable;
            }
            
            public Map<String,String> returnUsrMap(){
                return usrCountryMap;
            }
            */

}
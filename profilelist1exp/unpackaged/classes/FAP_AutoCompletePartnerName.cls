/**
REVISION HISTORY
================
Version     Author      Date            Release#       CR#     Description
-------     ------      ----            --------       ---     -----------
1.0         Sandhya     24-Jul-2012     13.7           CR7530  Defect#: 38172
1.1         Fenny       27-Jul-2012     13.7           CR7530  Defect#: 38172
1.2         Niveda      16-Oct-2019     FY20-DCS-0102          FAP: Federal Search

**/
global class FAP_AutoCompletePartnerName extends FAP_AutoCompleteSearch{
    
 
    global FAP_AutoCompletePartnerName(String searchString){
        super(searchString);
    }

     // Ver 1.0
     public override List<String> internalExecute(){         
        String accField = FAP_Configuration.keyValue+'Partner_Type__c';
        String accFieldNL = 'Partner_Type__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType accSchema = FAP_Configuration.keyValue == 'Account__r.'? schemaMap.get('Account'): schemaMap.get('Partner_Track__c');
        Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
            
            for (String fieldName: fieldMap.keySet()) {
                if(fieldName == 'NameLocal' && FAP_Configuration.keyValue == 'Account__r.'){
                    accField = 'Account__r.NameLocal';
                    accFieldNL = 'NameLocal';
                    system.debug('##accField '+accField);
                }
                if(fieldName == 'Partner_Track_Account_Local_Name__c' && FAP_Configuration.keyValue == 'Partner_Track__r.'){
                    accField = 'Partner_Track__r.Partner_Track_Account_Local_Name__c';
                    accFieldNL = 'Partner_Track_Account_Local_Name__c';
                    system.debug('##accField '+accField);
                }
            } 
                            
        final List<String> distinct = new List<String>(); 
        final Map<String,String> caseInsensitiveMapTemp = new Map<String,String>(); // Ver 1.1
        final Map<String,String> caseInsensitiveMap = new Map<String,String>(); // Ver 1.1
        final String searchStrWildcarded = FAP_StringUtils.ensureStringStartsEndsWithChar(this.searchString,'%');
        final Integer searchLimit = 5; 
        //Ver 1.0 Starts with String search     
        String strQuery1;
        
        if (FAP_Configuration.keyValue == 'Account__r.')
        {
            strQuery1= 'SELECT Account__r.name,'+accField+' FROM Partner_Location__c ' +
                        'WHERE Account__r.Approved_for_Partner_Finder__c = true ' +
                        'AND Account__r.Profile_Published_to_Partner_Finder__c = \'Yes\' ' +
                        'AND Account__r.IsPartner = true and Is_Primary__c = true ' +
                        'AND (Account__r.name like \'' + this.searchString + 
                        '%\' OR '+accField+' like \'' + this.searchString + 
                        '%\') ORDER BY account__r.Partner_Finder_Recommended_Flag__c DESC, '+
                        'Account__r.name ASC LIMIT 1000';
        }else
        {
            strQuery1= 'SELECT Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c,'+accField+' FROM Partner_Location__c ' +
                        'WHERE Partner_Track__r.Approved_for_Partner_Finder__c = true ' +
                        'AND Partner_Track__r.Profile_Published_to_Partner_Finder__c = \'Yes\' ' +
                        'AND Partner_Track__r.Partner_Account__c = true and Is_Primary__c = true ' +
                        'AND (Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c like \'' + this.searchString + 
                        '%\' OR '+accField+' like \'' + this.searchString + 
                        '%\') ORDER BY Partner_Track__r.Partner_Finder_Recommended_Flag__c DESC, '+
                        'Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c ASC LIMIT 1000';
        }
         system.debug('strQuery1strQuery1 !!!'+strQuery1);
        
        for(Partner_Location__c location : Database.query(strQuery1)){
            //Ver1.1
           sObject sb = location.getSobject(FAP_Configuration.keyValueWithoutDot);
           string str = String.valueOf(sb.get(accFieldNL));
           string keystr = 'location.'+accField;
           if (FAP_Configuration.keyValue == 'Account__r.')
            {
               if((location.Account__r.name != null) && (location.Account__r.name.toLowerCase().contains(this.searchString.toLowerCase())) && (!caseInsensitiveMapTemp.containsKey(location.Account__r.name.toLowerCase())))
                {   
                    caseInsensitiveMap.put(location.Account__r.name.toLowerCase(), location.Account__r.name);
                    caseInsensitiveMapTemp.put(location.Account__r.name.toLowerCase(), location.Account__r.name);                
                }
                
            }else
            {
                if((location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c != null) && (location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c.toLowerCase().contains(this.searchString.toLowerCase())) && (!caseInsensitiveMapTemp.containsKey(location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c.toLowerCase())))
                {
                    caseInsensitiveMap.put(location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c.toLowerCase(), location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c);
                    caseInsensitiveMapTemp.put(location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c.toLowerCase(), location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c);                
                }
            }
            if(str != null && str.toLowerCase().contains(this.searchString.toLowerCase())){
                caseInsensitiveMap.put(keystr.toLowerCase(), str);
                caseInsensitiveMapTemp.put(keystr.toLowerCase(), str);
            }
            //Ver 1.1
            if(caseInsensitiveMapTemp.size() == 5){ break; }
            system.debug('value:'+caseInsensitiveMap.values());
        }
        List<String> distinctStartsWithList = new List<String>();
        distinctStartsWithList.addAll(caseInsensitiveMapTemp.keySet()); // Ver 1.1
        caseInsensitiveMapTemp.clear(); // Ver 1.1
        
        // Ver 1.0 Wildcard company name search
        String strQuery2;
        if(distinctStartsWithList.size() < searchLimit){
            if (FAP_Configuration.keyValue == 'Account__r.')
            {
                strQuery2= 'SELECT Account__r.name,'+accField+' FROM Partner_Location__c ' +
                            'WHERE Account__r.Approved_for_Partner_Finder__c = true ' +
                            'AND Account__r.Profile_Published_to_Partner_Finder__c = \'Yes\' ' +
                            'AND Account__r.IsPartner = true and Is_Primary__c = true ' +
                            'AND (NOT (Account__r.name like \'' + this.searchString + '%\' OR '+accField+' like \'' + this.searchString + '%\'))' + 
                            'AND (Account__r.name like \'' + searchStrWildcarded + '\' OR '+accField+' like \'' + searchStrWildcarded + '%\')' +
                            'ORDER BY account__r.Partner_Finder_Recommended_Flag__c DESC, '+
                            'Account__r.name ASC LIMIT 1000';
            }else
            {
                strQuery2= 'SELECT Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c,'+accField+' FROM Partner_Location__c ' +
                            'WHERE Partner_Track__r.Approved_for_Partner_Finder__c = true ' +
                            'AND Partner_Track__r.Profile_Published_to_Partner_Finder__c = \'Yes\' ' +
                            'AND Partner_Track__r.Partner_Account__c = true and Is_Primary__c = true ' +
                            'AND (NOT (Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c like \'' + this.searchString + '%\' OR '+accField+' like \'' + this.searchString + '%\'))' + 
                            'AND (Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c like \'' + searchStrWildcarded + '\' OR '+accField+' like \'' + searchStrWildcarded + '%\')' +
                            'ORDER BY Partner_Track__r.Partner_Finder_Recommended_Flag__c DESC, '+
                            'Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c ASC LIMIT 1000';
            }
            system.debug('strQuery2 !!!1 '+strQuery2);
            for(Partner_Location__c location : Database.query(strQuery2)){
                // Ver 1.1
                sObject sb = location.getSobject(FAP_Configuration.keyValueWithoutDot);
                string str = String.valueOf(sb.get(accFieldNL));
                string keystr = 'location.'+accField;
                if (FAP_Configuration.keyValue == 'Account__r.')
                {
                   if((location.Account__r.name != null) && (location.Account__r.Name.toLowerCase().contains(searchStrWildcarded.toLowerCase())) && (!caseInsensitiveMapTemp.containsKey(location.Account__r.name.toLowerCase())))
                    {
                        caseInsensitiveMap.put(location.Account__r.name.toLowerCase(), location.Account__r.name);
                        caseInsensitiveMapTemp.put(location.Account__r.name.toLowerCase(), location.Account__r.name);                    
                    }
                    
                }else
                {
                    if((location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c != null) && (location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c.toLowerCase().contains(searchStrWildcarded.toLowerCase())) && (!caseInsensitiveMapTemp.containsKey(location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c.toLowerCase())))
                    {
                        caseInsensitiveMap.put(location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c.toLowerCase(), location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c);
                        caseInsensitiveMapTemp.put(location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c.toLowerCase(), location.Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c);                
                    }
                }
                /*if((location.Account__r.name != null) && (location.Account__r.Name.toLowerCase().contains(searchStrWildcarded.toLowerCase())) && (!caseInsensitiveMapTemp.containsKey(location.Account__r.name.toLowerCase()))){
                    caseInsensitiveMap.put(location.Account__r.name.toLowerCase(), location.Account__r.name);
                    caseInsensitiveMapTemp.put(location.Account__r.name.toLowerCase(), location.Account__r.name);                    
                }*/
                if(str != null && str.toLowerCase().contains(searchStrWildcarded.toLowerCase())){
                caseInsensitiveMap.put(keystr.toLowerCase(), str);
                caseInsensitiveMapTemp.put(keystr.toLowerCase(), str);
            }
                //Ver 1.1
                if(caseInsensitiveMapTemp.size()+distinctStartsWithList.size() == searchLimit){ break; }
            }
        }
        //Ver 1.2
        List<String> distinctWildCardList = new List<String>();
        distinctWildCardList.addAll(caseInsensitiveMapTemp.keySet());
        distinctWildCardList.sort();
        distinctStartsWithList.sort();
        for(string key : distinctStartsWithList){ distinct.add(caseInsensitiveMap.get(key)); }
        for(string key : distinctWildCardList){ distinct.add(caseInsensitiveMap.get(key)); }
        return distinct;
    }
}
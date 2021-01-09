/**
REVISION HISTORY
================
Version     Author      Date            Release#    CR#       Description
-------     ------      ----            --------    ---       -----------
1.0         Sandhya     18-May-2012     13.7        7110      Contexual search on Location
1.1         Fenny       19-Jul-2012     13.7        7110      CRQ 0417
1.2         Sandhya     24-Jul-2012     13.7                  Defect#: 38172 
1.3         TK Chin     07-Dec-2012     14.2        7675      Contextual Search on Location by country  
1.4         Niveda      25-May-2019     FY20-0702   17541     FAP: Auto complete City. Search by City, postal code and distance
**/
global class FAP_AutoCompleteLocation extends FAP_AutoCompleteSearch{
    

    global FAP_AutoCompleteLocation(String searchString){
        super(searchString);
    }

    public override List<String> internalExecute(){ // Ver 1.1
        final List<String> distinct = new List<String>(); // Ver 1.1
        final Map<String,String> caseInsensitiveMapTemp = new Map<String,String>(); // Ver 1.1
        final Map<String,String> caseInsensitiveMap = new Map<String,String>(); // Ver 1.1
        final String searchStrWildcarded = FAP_StringUtils.ensureStringStartsEndsWithChar(this.searchString,'%');
        final Integer searchLimit = 5;
        
        // Ver 1.3 - R14.2 - CR7675 - Add country to the queries
        Map<String,String> params = FAP_PageUtils.getParameters('countryCode');
        String strCountryCode = '';
        if(params != null && params.size() > 0){
          system.debug('######## countryCode = ' + params.values().get(0));
          //strCountryCode = 'AND Country__c like \'%\( ' + params.values().get(0)+ '/)%\' ';
          //Ver 1.4
          strCountryCode = 'AND Country__c like \'%(' + params.values().get(0) +')%\'';
        }
        
        String strQuery1;
        
        strQuery1= 'SELECT City__c FROM Partner_Location__c ' +
                        'WHERE Partner_Track__r.Approved_for_Partner_Finder__c = true ' +
                        'AND Partner_Track__r.Profile_Published_to_Partner_Finder__c = \'Yes\' ' +
                        'AND Partner_Track__r.Partner_Account__c = true ' + strCountryCode +
                        'AND City__c like \'' + this.searchString + '%\' ORDER BY City__c LIMIT 1000';
        
        system.debug('******strQuery1******'+ strQuery1);
        // Ver 1.1
        for(Partner_Location__c location : Database.query(strQuery1)){
            if((location.City__c != null) && (!caseInsensitiveMapTemp.containsKey(location.City__c.toLowerCase()))){
                caseInsensitiveMap.put(location.City__c.toLowerCase(), location.City__c);
                caseInsensitiveMapTemp.put(location.City__c.toLowerCase(), location.City__c);
            }
            //Ver 1.1
            if(caseInsensitiveMapTemp.size() == 5){ break; }
        }
        List<String> distinctStartsWithList = new List<String>();
        distinctStartsWithList.addAll(caseInsensitiveMapTemp.keySet()); // Ver 1.1
        caseInsensitiveMapTemp.clear(); // Ver 1.1
        
        // Ver 1.2 Wildcard City search
        if(distinctStartsWithList.size() < searchLimit){
            String strQuery2;
            strQuery2= 'SELECT City__c FROM Partner_Location__c ' +
                            'WHERE Partner_Track__r.Approved_for_Partner_Finder__c = true ' +
                            'AND Partner_Track__r.Profile_Published_to_Partner_Finder__c = \'Yes\' ' +
                            'AND Partner_Track__r.Partner_Account__c = true ' + strCountryCode +
                            'AND (NOT City__c like \'' + this.searchString + '%\')' + 
                            'AND City__c like \'' + searchStrWildcarded + '\' ' +
                            'ORDER BY City__c LIMIT 1000';
            
            system.debug('******strQuery2******'+ strQuery2);
            for(Partner_Location__c location : Database.query(strQuery2)){
                if((location.City__c != null) && (!caseInsensitiveMapTemp.containsKey(location.City__c.toLowerCase()))){
                    caseInsensitiveMap.put(location.City__c.toLowerCase(), location.City__c);
                    caseInsensitiveMapTemp.put(location.City__c.toLowerCase(), location.City__c);
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
        system.debug('******distinct*****'+distinct);
        return distinct;
    }
   
}
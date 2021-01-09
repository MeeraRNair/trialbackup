/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Fenny       04-May-2012     13.7        7112    Enable sort for Search results
1.1         Fenny       05-Jul-2012     13.7                Defect#: 36898, 37042, 37241: Too many script statements: 200001
1.2         Fenny       15-Jul-2012     13.7                Defect #37825
2.0         Kokila      06-Jul-2018     FY19-0703   15924   STORY 5119435 Competency Grouping extended to Competency Tracker Object
*/
global class FAP_Search {
    
    private static final Integer   DEFAULT_MAX_RECURSION    = 10;

    private Set<Object>             fields                  {get;set;}
    // Ver 1.0: Added orderByList
    private List<FAP_OrderBy> orderByList;
    private FAP_Configuration config; // Ver 1.2
    private static FAP_Configuration staticConfig; // Ver 1.2

    global FAP_Condition                attributeSearchCriteria {get;set;}
    global FAP_GeoSearchCriteria        geoSearchCriteria       {get;set;}
    public Integer                  maxRecursion            {get;set;}
    public Integer                  queryRowLimit           {get;set;}
    public Boolean accField = false;

           

    global FAP_Search(){
        this(null,null);
    }
    
    global FAP_Search(  FAP_Condition attributeSearchCriteria){
        this(attributeSearchCriteria,null);
    }

    global FAP_Search(  FAP_GeoSearchCriteria geoSearchCriteria){
        this(null,geoSearchCriteria);
    }    
    
    // Ver 1.0: Pass NULL to orderByList if no List<OrderByList> parameter passed in
    global FAP_Search(FAP_Condition attributeSearchCriteria, FAP_GeoSearchCriteria geoSearchCriteria){
        this(attributeSearchCriteria, geoSearchCriteria, null);
    }

    // Ver 1.0: Added orderByList parameter
    global FAP_Search(  FAP_Condition attributeSearchCriteria, 
                    FAP_GeoSearchCriteria geoSearchCriteria,
                    List<FAP_OrderBy> orderByList){
        this.fields = new Set<Object>();
        this.attributeSearchCriteria = attributeSearchCriteria;        
        this.geoSearchCriteria = geoSearchCriteria;
        this.maxRecursion = DEFAULT_MAX_RECURSION;
        this.queryRowLimit = FAP_Configuration.getInstance().searchMaxResults;
        // Ver 1.0: Assign the passed in orderByList to this class' orderByList variable
        this.orderByList = orderByList;
       // system.debug('########### attributeSearchCriteria  ' + attributeSearchCriteria);        
    }             
                
    global FAP_Search addFields(Set<Object> fields){
        if(fields != null && fields.size() > 0){
            this.fields.addAll(fields);
        }
        return this;
    }
       global List<FAP_SearchHit> execute(){
        return addLogoIDs(doSearch(
           null,
           attributeSearchCriteria,
           geoSearchCriteria,
           geoSearchCriteria,
           1,
           maxRecursion,
           queryRowLimit,
           fields,
           // Ver 1.0: 
           orderByList));
    }
    
    private static List<FAP_SearchHit> doSearch(    List<FAP_SearchHit> previous,
                                                FAP_Condition attributeCriteria,
                                                FAP_GeoSearchCriteria originalGeoCriteria,
                                                FAP_GeoSearchCriteria currentGeoCriteria,
                                                Integer recursionDepth,
                                                final Integer maxRecursion,
                                                final Integer queryRowLimit,
                                                Set<Object> userRequestedFields,
                                                // Ver 1.0:
                                                List<FAP_OrderBy> orderByList){
        if(recursionDepth >= maxRecursion){
            return previous;
        }

       // system.debug('##### userRequestedFields - ' + userRequestedFields);
        staticConfig = staticConfig == null ? FAP_Configuration.getInstance() : staticConfig; // Ver 1.2
        
        //======================================================
        //EXECUTE QUERY
        //======================================================
        final Set<Object> allFields = new Set<Object>();
        allFields.addAll(FAP_SearchHit.minimumFields());
        allFields.addAll(userRequestedFields);           
      //  system.debug('^^^^^ userRequestedFields in doSearch() - ' + userRequestedFields);
       // system.debug('^^^^^ allFields in doSearch() - ' + allFields);
        
        //JJ
        for(Object obj :allFields){
           //  system.debug('##### obj ->'+obj);                                       
        }
                                                    
        system.debug('===111===allFields ========='+allFields );   
       // system.debug('======currentGeoCriteria ========='+currentGeoCriteria );
       // system.debug('======attributeCriteria ========='+attributeCriteria );
       // system.debug('======currentGeoCriteria ========='+currentGeoCriteria );     
        final List<Partner_Location__c> results = FAP_SearchUtils.doQuery(  
            allFields, //fields
            currentGeoCriteria == null ? null : currentGeoCriteria.bounds, //bounds            
            attributeCriteria, //extraCriteria
            currentGeoCriteria == null, //primaryOnly
            
            orderByList,//orderBy
            queryRowLimit);
         system.debug('======results ========='+results );       
        //======================================================
        //PROCESS RESULTS
        //======================================================
        List<FAP_SearchHit> current = new List<FAP_SearchHit>();
        if(results != null && results.size() > 0 ){
            FAP_SearchHit hit = null;
            System.debug('~~~~~~~~~~results~~~~~~~~~~ '+results[0]);
            map<Id,String> mapPL = new map<Id, String>();
                
            //Start 2.0 - To get the list of AccountIds from results
            for(Partner_Location__c pl : results){
              
              if(FAP_Configuration.keyValue=='Account__r.'){//For FAP 
              mapPL.put(pl.Account__c, null);
              }
              else{//For PAM
              mapPl.put(pl.Partner_Track__c,null);
              }
            } //2.0 End

            Map<String,String> mapServiceCompetency = populateServCompt();
            
            for(Partner_Location__c result : results){
                
                if(Limits.getScriptStatements() >= staticConfig.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 1.2
                hit = new FAP_SearchHit(result);
                hit.mapPL = mapPL; //2.0 - Send the Competency Tracker Competecies to form the Grouping 
                hit.mapServiceCompetency = mapServiceCompetency;
                if(currentGeoCriteria != null){
                    hit.setDistanceToPoint(currentGeoCriteria.point);
                }
                if(userRequestedFields != null && userRequestedFields.size() > 0){
                    hit.userRequestedFieldValues = new Map<String,Object>();
                    String fieldName = null;
                    for(Object userRequestedField : userRequestedFields){
                        if(Limits.getScriptStatements() >= staticConfig.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 1.2
                        if(userRequestedField instanceof String){
                            fieldName = (userRequestedField == null) ? '' : string.valueOf(userRequestedField).trim();
                            if((fieldName != null) && (fieldName.length() != 0) && fieldName.contains('.')){
                                hit.userRequestedFieldValues.put(
                                    fieldName,
                                    result.getSObject(fieldName.substring(0, fieldName.indexOf('.')))
                                    .get(fieldName.substring(fieldName.indexOf('.') + 1, fieldName.length()))
                                );     
                                
                            } else {
                                hit.userRequestedFieldValues.put(fieldName,result.get(fieldName));
                            }
                        }
                    }
                }
                current.add(hit);
                //system.debug('**Test last hit: '+current);
            }
        }
        // Ver 1.0: Sort the result by distance for different condition
        boolean isDefaultSorting = false;
        boolean sortByDistance = false;
        List<FAP_SearchHit> sortedHits = new List<FAP_SearchHit>();
        if((current != null) && (current.size() > 0)){
            if(orderByList != null){
                for(FAP_OrderBy ob : orderByList){
                    
                    if((ob.field != null) && ob.field.trim().equalsIgnoreCase(FAP_Configuration.keyValue + 'FAP_Sort_Order__c')){
                        isDefaultSorting = true;
                        //sortByDistance = true;
                    }else if((ob.field != null) && ob.field.trim().equalsIgnoreCase('City__c')){
                        sortByDistance = true;
                    }
                }
            }
            // Ver 1.0: Sort the group of partners with same relationship by distance
            if(isDefaultSorting && sortByDistance && (currentGeoCriteria != null)){
                boolean statusFirstHit = true;
                String previousStatus = null;
                List<FAP_SearchHit> hits = new List<FAP_SearchHit>();
                if(current.size() == 1){
                    sortedHits.addAll(FAP_SearchUtils.filterResultsOutsideDistance(current,currentGeoCriteria.distanceInKilometers));
                }else{
                    integer i = 1;
                    for(FAP_SearchHit hit : current){
                        if(Limits.getScriptStatements() >= staticConfig.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 1.2
                        if(!((previousStatus != null) && previousStatus.trim().equalsIgnoreCase(hit.partnerRelationship)) && !statusFirstHit){
                            // Ver 1.1: To fix 'Too many script statements'
                            hits.sort();
                            sortedHits.addAll(FAP_SearchUtils.filterResultsOutsideDistance(hits,currentGeoCriteria.distanceInKilometers));
                            hits.clear();
                        }
                        hits.add(hit);
                        previousStatus = hit.partnerRelationship;
                        if(statusFirstHit) { statusFirstHit = false; }
                    }
                    // Ver 1.1: To fix 'Too many script statements'
                    hits.sort();
                    sortedHits.addAll(FAP_SearchUtils.filterResultsOutsideDistance(hits,currentGeoCriteria.distanceInKilometers));
                }
            // Ver 1.0: Sort the partners by distance only
            }else if(sortByDistance && (currentGeoCriteria != null)){
                // Ver 1.1: To fix 'Too many script statements'
                current.sort();
                sortedHits = FAP_SearchUtils.filterResultsOutsideDistance(current,currentGeoCriteria.distanceInKilometers);
            // Ver 1.0: Do not need to sort partners by distance
            }else{
                sortedHits = current;
            }
        }

        //======================================================
        //DETERMINE IF RECURSIVE CALL SHOULD BE EXECUTED
        //  A recursive call needs to be executed if the current query is a geographic
        //  based query and returned max results.  This is due to limitations with
        //  SOQL result set size and inability of SOQL to perform SOQL side functions.  In
        //  this case, a function is needed in SOQL to determine distance from point so
        //  that results can be sorted on distance.  As a workaround, a max of 5 recursive
        //  calls will be made which vary the search distance.
        //======================================================
            recursionDepth = maxRecursion;
        for(Integer i = 0; i < (sortedHits == null ? 0 : sortedHits.size()); i++){
            if(Limits.getScriptStatements() >= staticConfig.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 1.2
            sortedHits.get(i).resultSequenceNumber = i+1; 
        }

        return doSearch(
            // current, // Ver 1.0
            sortedHits,
            attributeCriteria,
            originalGeoCriteria,
            currentGeoCriteria,
            recursionDepth,
            maxRecursion,
            queryRowLimit,
            userRequestedFields,
            // Ver 1.0:
            orderByList
        );
    }
    @TestVisible
    private List<FAP_SearchHit> addLogoIDs(final List<FAP_SearchHit> hits){
        
       
       try{ config = config == null ? FAP_Configuration.getInstance() : config; // Ver 1.2
        if(hits != null && hits.size() > 0){
            Set<String> distinctLogoRecordIds = new Set<String>(); 
            Map<String,List<FAP_SearchHit>> logoRecordId2Hits = new Map<String,List<FAP_SearchHit>>();
            system.debug('========logoRecordId2Hits==='+logoRecordId2Hits);
            
            for(FAP_SearchHit hit : hits){
                if(Limits.getScriptStatements() >= config.scriptStatementLimit) { 
                    
                    throw new FAP_FAPLimitException(); } // Ver 1.2
                system.debug('hit.logoRecordId $$$$'+hit.logoRecordId);
                                system.debug('hit.logoRecordId2Hits$$$$'+logoRecordId2Hits);

                if(hit.logoRecordID != null){
                       if(!logoRecordId2Hits.containsKey(hit.logoRecordID)){
                        logoRecordId2Hits.put(hit.logoRecordID, new List<FAP_SearchHit>());
                        
                    }
                    logoRecordId2Hits.get(hit.logoRecordID).add(hit);
                    distinctLogoRecordIds.add(hit.logoRecordId);
                                        system.debug('$$$$$ logoRecordId2Hits'+logoRecordId2Hits);
                                        system.debug('$$$$$ logoRecordId2Hits map'+logoRecordId2Hits.get(hit.logoRecordId));


                }
            }
            List<FAP_SearchHit> resultsForOneLogo = null;
            string logoParentId='';
                system.debug('distinctLogoRecordIds $$$'+distinctLogoRecordIds);
                            List<Attachment> logos =new List<Attachment>();

                if(distinctLogoRecordIds!=null){
             logos = [select id,parentid from Attachment where parentid in :distinctLogoRecordIds]; 
            }
           
           system.debug('logos $$$$'+logos[0].id);
            if(logos != null && logos.size() > 0){
                for(Attachment logo : logos){
                    if(Limits.getScriptStatements() >= config.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 1.2
                  system.debug('logo.parentid $$$$'+logo.parentid);
                  //Added By Susmitha for displaying LOGO
                   logoParentId=logo.parentId;

                  if(logoParentId.length()==18 && FAP_Configuration.keyValue!='Account__r'){
                  }
                  else{
                        logoParentId=logo.parentId;
                    }
                    //End Added by susmitha for displaying Logo
                   system.debug('logoRecordId2Hits.get(logo.parentid) $$$$'+logoRecordId2Hits.get(logo.parentid));

                    resultsForOneLogo = logoRecordId2Hits.get(logoParentId);
                    if(resultsForOneLogo != null && resultsForOneLogo.size() > 0){
                        for(FAP_SearchHit aResult : resultsForOneLogo){
                           system.debug('entry $$$$');
                            aResult.logoId = logo.id;
                        }
                    }
            }
            }
        }
        
       }
       catch(Exception e){
       system.debug('Exception is :- '+e);
       }
        return hits;
    } 
          
       @TestVisible
        private static Map<String,String> populateServCompt(){
            Map<String,String> mapServiceCompetency = new Map<String,String>();
            for(FAP_Competency__mdt subComp: [select id,Services_Comptency__c,Account_Competency__c from FAP_Competency__mdt where User_type__c='Authenticated']){             
                for(String strAccCompt:subComp.Account_Competency__c.split(',')){
                    mapServiceCompetency.put(strAccCompt,subComp.Services_Comptency__c);
                }                
            }    
            return mapServiceCompetency;   
        }          
   
}
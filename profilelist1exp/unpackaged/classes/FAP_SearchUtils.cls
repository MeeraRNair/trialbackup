public class FAP_SearchUtils {
                
        public static String countrycode {get; set;} 
        public static String ipCountry {get; set;}
        public static String address {get;set;}
        public FAP_searchForm form {get;set;}
        public static String accField {get;set;}
        public static String accFieldVal {get;set;}
        

        public static set <Object> partnerTrackFields = new Set <Object> ();
        public static set <Object> masterGroupAccFields = new Set <Object> ();
        
        
        public static List<Partner_Location__c> doQuery(    Set<Object> fields, 
                                                            FAP_GeoBounds bounds,
                                                            final FAP_Condition extraCondition,
                                                            Boolean primaryOnly,
                                                            final List<FAP_OrderBy> orderBy,
                                                            Integer queryRowLimit){            
            System.Debug('##fields'+fields);
            System.Debug('##bounds'+bounds);
            System.Debug('##extraCondition'+extraCondition);
            System.Debug('##orderBy'+orderBy);
            System.Debug('##queryRowLimit'+queryRowLimit);
            System.Debug('##ipCountry'+ipCountry);
            System.Debug('##address'+address);
          
             for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().detailPartnerTrackFields){  
                if(fieldConfiguration != null){
                    partnerTrackFields .add((FAP_Configuration.StrObjectName.equalsIgnoreCase(fieldConfiguration.objectName) ? 'Partner_Track__r.' : 'Partner_Track__r.') 
                                + fieldConfiguration.fieldName);
                }
            }
             system.debug('=====PartnerTrackFields =in if loop=='+partnerTrackFields ); 
             
             for(FAP_FieldConfiguration fieldConfiguration : FAP_Configuration.getInstance().detailMasterGroupFields)
             {  
                if(fieldConfiguration != null)
                {
                    masterGroupAccFields.add((FAP_Configuration.StrObjectName.equalsIgnoreCase(fieldConfiguration.objectName) ? FAP_Configuration.keyvalue :'') 
                                + fieldConfiguration.fieldName);
                }
             }
             
           system.debug('=====masterGroupAccFields=in if loop=='+masterGroupAccFields);
            
            accField = FAP_Configuration.KeyValue+'Profile_Published_to_Partner_Finder__c';
            accFieldVal = 'Yes';
            bounds = (bounds == null ? FAP_GeoBounds.MAX : bounds);
            primaryOnly = (primaryOnly == null ? false : primaryOnly);
            queryRowLimit = (queryRowLimit == null ? FAP_Configuration.getInstance().searchMaxResults : queryRowLimit); 
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType accSchema = schemaMap.get(FAP_Configuration.StrObjectName);
            Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
            
            System.Debug('##### accSchema'+accSchema);
            System.Debug('##### fieldMap'+fieldMap);
            
            // Added by Neeti as we do not need this for PAM
            if(FAP_Configuration.KeyValue == 'Account__r.')
                {
                for (String fieldName: fieldMap.keySet()) {                
                    if(fieldName == 'Account_Type_Integration__c'){
                        accField = FAP_Configuration.KeyValue+'Account_Type_Integration__c';
                        accFieldVal = 'Account';
                       // system.debug('##accField '+accField);
                    }
                }
            }
            
            final FAP_NestableCondition condition = null;
           
                    condition = new FAP_AndCondition()
                
                    //LATITUDE & LONGITUDE
                    .add(new FAP_FieldCondition('Latitude__c' ).lessThanOrEqualTo   (bounds.northeast.latitude)) 
                    .add(new FAP_FieldCondition('Longitude__c').lessThanOrEqualTo   (bounds.northeast.longitude)) 
                    .add(new FAP_FieldCondition('Latitude__c' ).greaterThanOrEqualTo(bounds.southwest.latitude)) 
                    .add(new FAP_FieldCondition('Longitude__c').greaterThanOrEqualTo(bounds.southwest.longitude)) 

                    //ACCOUNT STATE FLAGS
                    .add(new FAP_FieldCondition(accField).equals (accFieldVal))
                    .add(new FAP_FieldCondition(FAP_Configuration.strIsPartner,true)) 
                    .add(new FAP_FieldCondition(FAP_Configuration.strApprovedforPartnerFinder,true)) 
                    .add(new FAP_FieldCondition(FAP_Configuration.strProfilePublishedtoPartnerFinder,'Yes'));
                  
            if(primaryOnly){
                condition
                .add(new FAP_FieldCondition('Is_Primary__c',true));
            }
            if(FAP_Configuration.getInstance().isTermsConditionsFeatureEnabled){
                condition
                .add(new FAP_FieldCondition(FAP_Configuration.strUserAgreedtoPFTermsCond,FAP_Operator.NOT_EQUALS,'')) 
                .add(new FAP_FieldCondition(FAP_Configuration.strDateAgreedtoPFTermsCond,FAP_Operator.NOT_EQUALS,null)); 
            }
            if(extraCondition != null){
                condition
                .add(extraCondition);
            }        
            system.debug('##### fields          ->' +fields);
            system.debug('##### accField        ->' +accField);                                                    
            system.debug('##### condition       ->' +condition);
            system.debug('##### orderBy         ->' +orderBy);
            system.debug('##### queryRowLimit   ->' +queryRowLimit);
                                                                
            final String soql = 
                new FAP_SoqlBuilder()
                    .selectx(fields)
                    .selectx(accField)
                    .selectx(partnerTrackFields)
                    .selectx(masterGroupAccFields)
                    .fromx('Partner_Location__c')
                    .wherex(condition)
                    .orderByx(orderBy)
                    .limitx(queryRowLimit)
                    .toSoql(new FAP_SoqlOptions().wildcardStringsInLikeOperators());
            System.debug('##### soql ' + soql);         
            return Database.query(soql);
        }
        
        /**
         * Removes search hits which exceed certain distance.  Background:  queries 
         * against latitude and longitude essentially query a box instead of a circle.
         * This means its likely some geo search results will contain results which
         * fit inside the box but are outside the circle.  For example, let's say
         * you have following:
         * Search point:  lat = 0, lng = 0
         * Location:      lat = 1, lng = 1
         * The two points are 157km apart.  But if you execute a search for all locations
         * which are 120km apart, the soql query will contain following lat/lng bounds:
         * lat > 1.08 and lat < 1.08 and lng > 1.08 and lng < 1.08
         * That will of course, pick up the location which is 157km away.  The purpose of
         * this method is to remove such cases.
         * @param hits                          the list of hits with distance populate
         * @param limitDistanceInKilometers     the distance to not be exceeeded
         */
        public static List<FAP_SearchHit> filterResultsOutsideDistance( List<FAP_SearchHit> hits, 
                                                                    Double limitDistanceInKilometers){
            if(hits != null && hits.size() > 0){
                List<Integer> indicesToRemove = new List<Integer>();
                for(Integer i = 0; i < hits.size(); i++){
                    if(hits.get(i).distanceInKilometers > limitDistanceInKilometers){
                        indicesToRemove.add(i);
                    }
                }
                for(Integer i = 0; i < indicesToRemove.size(); i++){
                    hits.remove(indicesToRemove.get(i)-i);
                }
            }
            return hits;
        }

        /**
         * This method is used to determine distance change for recursive geo search.
         * <pre>
         * distanceChange(100,1) = 100 
         * distanceChange(100,2) = 50
         * distanceChange(100,3) = 25
         * distanceChange(100,4) = 12.5
         * </pre>
         * @param d                 original distance
         * @param recursionDepth    
         */
        public static Double distanceChange(Double d, Integer recursionDepth){
            return d * 1 / Math.pow(2,(recursionDepth-1));
           
        }
    }
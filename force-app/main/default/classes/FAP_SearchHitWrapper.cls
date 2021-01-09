/* FAP Controller*/

global class FAP_SearchHitWrapper {

    global FAP_SearchHit wrapped {get;private set;}
    
    global Integer resultSequenceNumber {get{return wrapped.resultSequenceNumber;}}
    global String locationName {get{return wrapped.locationName;}}
    global ID locationId {get{return wrapped.locationId;}}
    global String partnerName {get{return wrapped.partnerName;}}
    global String partnerNameLocal {get{return wrapped.partnerNameLocal;}}
    global String fapCategory {get{return wrapped.fapCategory;}}//Added By Sree
    global ID partnerAccountId {get{return wrapped.partnerAccountId;}}
    global String website {get{return wrapped.website;}}
    global Boolean isPrimary {get{return wrapped.isPrimary;}}
    global Boolean isMainContact {get{return wrapped.isMainContact;}}
    global String pointOfContactPhone {get{return wrapped.pointOfContactPhone;}}
    global String pointOfContactName {get{return wrapped.pointOfContactName;}}
    global String pointOfContactEmail {get{return wrapped.pointOfContactEmail;}}
    global String description {get{return wrapped.description;}}
    global String street {get{return wrapped.street;}}
    global String city {get{return wrapped.city;}}
    global String stateProvince {get{return wrapped.stateProvince;}}
    global String postalCode {get{return wrapped.postalCode;}}
    global String country {get{return wrapped.country;}}
    global Double longitude {get{return wrapped.longitude;}}
    global Double latitude {get{return wrapped.latitude;}}
    global FAP_GeoPoint point {get{return wrapped.point;}}
    global Boolean containsDistance {get{return wrapped.containsDistance;}}
    global Double distanceInKilometers {get{return wrapped.distanceInKilometers;}}
    global Double distanceInMiles {get{return wrapped.distanceInMiles;}}
    global Boolean isRecommended {get{return wrapped.isRecommended;}}
    
    global string keyConfigValue  {get{return wrapped.keyConfigValue;}} // Added by Neeti to be used on Partner serach change to check for PAM Changes
    global String logoId {get{return wrapped.logoId;}}
    global String dellComp {get; set;}
    global Integer dellCompLength {get; set;}
    global String dellPartnerLvl {get; set;}
    global Integer dellPartnerLvlLength {get; set;}
    // Ver 2.0: Added partnerType variable to return partner type that will be displayed at search result
    global String partnerType {get{return wrapped.partnerType;}}
    global String logoRecordId {get{return wrapped.logoRecordId;}}
    public boolean storage{get;set;}
    public boolean server{get;set;}    
    public boolean networking{get;set;}
    public boolean dataProtection{get;set;}
    //public boolean ConvergedInfrastructure{get;set;}
    public boolean coreClient{get;set;}
    public boolean clientDataSecurity{get;set;}
    public boolean workstation{get;set;}
    public boolean desktopVirtul{get;set;}
    public boolean digitalTransformation{get;set;}
    public boolean itTransformation{get;set;}
    public boolean storageServices{get;set;}
    public boolean networkingServices{get;set;}
    public boolean clientServices{get;set;}
    public boolean serverServices{get;set;}
    //public boolean ConvergedInfrastructureServices{get;set;}
    public boolean hybridCloudPlatformServices{get;set;}
    public boolean dataProtectionServices{get;set;}
    //Start - Added by Akshita
    
    public boolean boolDellTechnologiesCloud{get;set;}
    public boolean boolFapOEM{get;set;}
    public boolean boolInternetOfThings{get;set;}
    public boolean boolUnifiedWorkspace{get;set;}
    public boolean boolWyseForVDI{get;set;}
    public boolean boolDataAnalytics{get;set;}
    public boolean boolBusinessApplications{get;set;}
    public boolean boolHighPerformanceCompute{get;set;}
    //End
    //4.0 start
    public boolean hyperConvergeInfa{get;set;}  //Converged/Hyper-Converged Infrastructure
    public boolean hybridCloud{get;set;}    //Hybrid Cloud
    public boolean softwDefinedInfa{get;set;}   //Software Defined Infrastructure
    public boolean connectedWforce{get;set;} //Connected Workforce
    public boolean hyperConvergeInfaServ{get;set;} //Converged/Hyper-Converged Infrastructure Services
    
    


    public String delCompCount{get;set;}
    public List<string> dellCompetencies{get;set;}
    
    global string searchSerialize {get;set;}
    
    global List<FAP_FormField> customFields{get;set;}
    
    
    private Map<string, string> partnerDirectLogos = FAP_Configuration.getInstance().partnerDirectLogos;
     

    global FAP_SearchHitWrapper(FAP_SearchHit wrapped, FAP_Configuration configuration){
        //system.debug('=====partnerType========'+partnerType);
      server=false;
      storage=false;  
        if(wrapped == null){
            throw new FAP_IllegalArgumentException('Invalid argument: wrapped is null');
        }
        if(configuration == null){
            throw new FAP_IllegalArgumentException('Invalid argument: configuration is null');
        }
        this.wrapped = wrapped;
        // Ver 1.0: Get the map of partner direct logos from config object, because it's not static in config class
        this.customFields = new List<FAP_FormField>();
        final Map<String,FAP_FormField> fieldLookup = buildFieldsInResultListForQuery(configuration);
        //system.debug('^^^^^ fieldLookup - ' + fieldLookup);
       
        // Ver 2.2: To fix 'Too many script statements'
        
        //dellcomp = '';
        
        if(fieldLookup != null && fieldLookup.size() > 0){
            FAP_FormField formField = null;
            for(String field : fieldLookup.keySet()){
                if(Limits.getScriptStatements() >= configuration.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 2.3
                   system.debug('^^^^^ wrapped.userRequestedFieldValues ******' + wrapped.userRequestedFieldValues);                              
                  // system.debug('^^^^^ wrapped.userRequestedFieldValues.get(field)  ******' + wrapped.userRequestedFieldValues.get(field) );                              
                  // system.debug('^^^^^ wrapped.userRequestedFieldValues.get(field) instanceof String  ******' + wrapped.userRequestedFieldValues.get(field) );                              
                   system.debug('^^^^^ field  ******' + field);
                if(wrapped != null && wrapped.userRequestedFieldValues != null && wrapped.userRequestedFieldValues.get(field) != null 
                  && wrapped.userRequestedFieldValues.get(field) instanceof String){
                    fieldLookup.get(field).populate((String) wrapped.userRequestedFieldValues.get(field));
                    dellcomp = dellcomp+';'+(String) wrapped.userRequestedFieldValues.get(field);     
                  //  system.debug('^^^^^ dellPartnerLvl- ' + dellPartnerLvl);                              
                    dellPartnerLvl = (String) wrapped.partnerRelationship;
                    //keyValueWithoutDot //keyConfigValue
                    // if(!'Account__r.Certification_Completed__c'.equalsIgnoreCase(field)) //5.0
                    string str = keyConfigValue+'Certification_Completed__c';
                    //system.debug('====22======'+str);
                      if(!str.equalsIgnoreCase(field)){ //5.0
                      this.customFields.add(fieldLookup.get(field));}
                }
            }

        }
      //  System.debug('---n customFields---'+customFields);
       // System.debug('---n dellPartnerLvl---'+dellPartnerLvl);
      //  System.debug('---n dellPartnerLvl---'+dellPartnerLvl.length());

        if(dellPartnerLvl != null && dellPartnerLvl.length() > 0){
       // system.debug('^^^^^ dellPartnerLvl enter if ');
            dellPartnerLvlLength = dellPartnerLvl.length();        
        }
        system.debug('^^^^^ dellPartnerLvl- ' + dellPartnerLvl);
        system.debug('^^^^^ fieldLookup - ' + fieldLookup);  
        system.debug('partnerAccountId--*-'+wrapped.mapPL);
        system.debug('mapPl-11-*-'+wrapped.partnerAccountId);
        
        
        //v5.1 - Regroup all competencies under single classification along with Competencies from Competency Tracker 
        if(wrapped.mapPL.containskey(partnerAccountId)){
            dellcomp = dellcomp + ';' + wrapped.mapPL.get(partnerAccountId);
        }//End - v5.1
        
        system.debug('mapPl--*-'+wrapped.mapPL);
        system.debug('dellcomp--*-'+dellcomp);
        
        delCompCount='';        
       
        if((dellcomp != null && dellcomp != '')){

            Map<String,String> mapServiceCompetency = wrapped.mapServiceCompetency;
               
                dellCompetencies =  dellcomp.split(';');

                for(string strObj:dellCompetencies){                  
                    
                    strObj = strObj.trim();
                    
                    //Start v5.1 - To display Competency Grouping if Account's Competency is null and Competency Tracker has values
                    if(this.customFields.isempty() && (strObj!='null')){
                        this.customFields.add(new FAP_FormField(FAP_Configuration.strServicesCompetencies));
                    }//End - v5.1
                    System.debug('---customFields---'+customFields);
                    System.debug('---strObj---'+strObj);
                    if(strObj==Label.Storage_Com){
                        storage=true;
                    }
                    
                    if(strObj==Label.Server_Com){
                        server=true;
                    }
                    
                    if(strObj==Label.Networking_Com){
                        networking=true;
                    }           
                    
                    if(strObj==Label.Data_Protect){
                        dataProtection=true;
                    } 
                    
                   
                    
                    if(strObj==Label.Core_Clint){
                        coreClient=true;                    
                    }
                    
                    if(strObj==Label.Client_Data_Secur){
                        clientDataSecurity=true;
                    }
                    
                    if(strObj==Label.Workstation_Com){
                        workstation=true;
                    }
                    
                    if(strObj==Label.Desktop_Virtualization_Sol){
                        desktopVirtul=true;
                    }
                    
                    if(strObj==Label.Digital_Transformtion){
                        digitalTransformation=true;
                    }
                    
                    if(strObj==Label.IT_Transformtion){
                        itTransformation=true;
                    }                  
                    //Start - Added by Akshita
                    if(strObj==Label.Dell_Technologies_Cloud){
                        boolDellTechnologiesCloud=true;
                    } 
                    if(strObj==Label.FAP_OEM){
                        boolFapOEM=true;
                    } 
                    if(strObj==Label.Internet_of_Things_IoT){
                        boolInternetOfThings=true;
                    } 
                    if(strObj==Label.Unified_Workspace){
                        boolUnifiedWorkspace=true;
                    } 
                    if(strObj==Label.Wyse_for_VDI){
                        boolWyseForVDI=true;
                    } 
                    if(strObj==Label.Data_Analytics){
                        boolDataAnalytics=true;
                    } 
                    if(strObj==Label.Business_Applications){
                        boolBusinessApplications=true;
                    } 
                    if(strObj==Label.High_Performance_Compute){
                        boolHighPerformanceCompute=true;
                    } 
                    //End
                    
                    if(strObj==Label.Converged_Hyper_Converged_Infrastructure || strObj==Label.Converged_Infrastruct){
                        hyperConvergeInfa=true;
                    } 
                    
                    if(strObj==Label.Hybrid_Cloud){
                        hybridCloud=true;
                    } 
                    if(strObj==Label.Software_Defined_Infra){
                        softwDefinedInfa=true;
                    } 
                    if(strObj==Label.Connected_Workforce){
                        connectedWforce=true;
                    }                  

                    //5.0 Start
                    //Services related Competency separated.
                    if(mapServiceCompetency.containsKey(strObj)){
                        String strCompe = mapServiceCompetency.get(strObj);
                        //system.debug('strCompe----'+strCompe);
                        if(strCompe==Label.Converged_Hyper_Converged_Infrastructure_Services || strCompe==Label.Converged_Infrastructure_Servics){
                            hyperConvergeInfaServ=true;
                        }   
                        if(strCompe==Label.Hybrid_Cloud_Platform_Servics){
                            hybridCloudPlatformServices=true;
                        }
                        if(strCompe==Label.Data_Protection_Servics){
                            dataProtectionServices=true;
                        } 
                        if(strCompe==Label.Server_Servics){
                            serverServices=true;
                        }     
                        if(strCompe==Label.Client_Services_Deployment){
                            clientServices=true;
                        }
                        if(strCompe==Label.Storage_Servics){
                            storageServices=true;
                        }
                        if(strCompe==Label.Networking_Servics){
                            networkingServices=true;
                        }                       
                    }
                   
                }
            }
            if(storage==true)
            {
                delCompCount += Label.storage + ';';
            }
            if(server==true)
            {
                delCompCount += Label.Server_Com + ';';
            }
            if(networking==true)
            {
                delCompCount += Label.networking + ';';
            }
            if(dataProtection==true)
            {
                delCompCount += Label.data_protection + ';';
            }
            if(desktopVirtul==true)
            {
                delCompCount += Label.Desktop_Virtualization + ';';
            }
            if(workstation==true)
            {
                delCompCount += Label.Workstation + ';';
            }
           
            if(coreClient==true)
            {
                delCompCount += Label.core_client + ';';
            }
            if(clientDataSecurity==true)
            {
                delCompCount += Label.client_data_security + ';';
            }
            if(digitalTransformation==true)
            {
                delCompCount += Label.digital_transformation + ';';   
            }
            if(itTransformation==true)
            {
                delCompCount += Label.it_transformation + ';';
            }
            if(storageServices==true)
            {
                delCompCount += Label.storage_services + ';';     
            }
            if(networkingServices==true)
            {
                delCompCount += Label.networking_services + ';';
            }
            if(clientServices==true)
            {
                delCompCount += Label.client_services + ';';
            }
            if(serverServices==true)
            {
                delCompCount += Label.server_services + ';';
            }
            if(hybridCloudPlatformServices==true)
            {
                delCompCount += Label.hybrid_cloud_platform_services + ';';
            }
            if(dataProtectionServices==true)
            {
                delCompCount += Label.data_protection_services + ';';  
            }
            if(hyperConvergeInfa==true)
            {
                delCompCount += Label.Converged_Hyper_Converged_Infra + ';';  
            }
            if(hybridCloud==true)
            {
                delCompCount += Label.Hybrid_Cld + ';';  
            }
            if(softwDefinedInfa==true)
            {
                delCompCount += Label.Software_Defined_Infra + ';';  
            }
            if(connectedWforce==true)
            {
                delCompCount += Label.Connected_Wrkforce + ';'; 
            }
            if(hyperConvergeInfaServ==true)
            {
                delCompCount += Label.Converged_Hyper_Converged_Infrastructure + ';';  
            }
            //Start - Added by Akshita
            if(boolDellTechnologiesCloud==true)
            {
                delCompCount += Label.Dell_Technologies_Cloud + ';';  
            }
            if(boolFapOEM==true)
            {
                delCompCount += Label.FAP_OEM + ';';  
            }
            if(boolInternetOfThings==true)
            {
                delCompCount += Label.Internet_of_Things_IoT + ';';  
            }
            if(boolUnifiedWorkspace==true)
            {
                delCompCount += Label.Unified_Workspace + ';';  
            }
            if(boolWyseForVDI==true)
            {
                delCompCount += Label.Wyse_for_VDI + ';';  
            }
            if(boolDataAnalytics==true)
            {
                delCompCount += Label.Data_Analytics + ';';  
            }
            if(boolBusinessApplications==true)
            {
                delCompCount += Label.Business_Applications + ';';  
            }
            if(boolHighPerformanceCompute==true)
            {
                delCompCount += Label.High_Performance_Compute + ';';  
            }
            //End
            dellCompLength = 0;    
            if(delCompCount!= null && delCompCount.length() > 0){
            delCompCount = delCompCount.replaceAll(';', '; ');
            dellCompLength = delCompCount.length() ;
            if(delCompCount.length() > 125){
                delCompCount= delCompCount.substring(0, 125);
                delCompCount= delCompCount.substringBeforeLast(';');
            }            
        } 
                 
        
       
    }


    
    
    // Ver 1.0: Get the partner direct logo relative url based on the partner relationship/type
    global string partnerDirectLogoURL{
        get{
           
            // Ver 2.2: To fix 'Too many script statements'
            if(partnerDirectLogos != null){
                // Ver 1.0: If the partner is a distributor, get the distributor PD logo regardless the partner relationship
                if((wrapped.partnerType != null) && wrapped.partnerType.trim().equalsIgnoreCase('Distributor')){
                    partnerDirectLogoURL = partnerDirectLogos.get('DISTRIBUTOR');
                // Ver 1.0: If the partner relationship as the key exists in the logos map, get the relative url to the logo image
                }else{
                    partnerDirectLogoURL = partnerDirectLogos.get((wrapped.partnerRelationship == null) ? '' : wrapped.partnerRelationship.trim().toUpperCase());
                }
                // Ver 1.0: If the partner relationship/type as the key does not exists in the logos map, get the relative url to the PD standard logo image
                if((partnerDirectLogoURL == null) || (partnerDirectLogoURL.trim().length() == 0)){
                    partnerDirectLogoURL = partnerDirectLogos.get('STANDARD');
                }
            }
            return partnerDirectLogoURL;
        }
        private set;
    }
    
    //V2.4 - Start: Modified below code to accomodate the new map functionality
    global static String toJson(List<FAP_SearchHitWrapper> hits){
        String json = '';
        final List<String> locationsJSONEncoded = new List<String>();
        if(hits != null && hits.size() > 0){
            for(FAP_SearchHitWrapper hit : hits){
            
                locationsJSONEncoded.add(
                    '{' 
                    + FAP_MapUtils.joinMap(
                        new Map<String,String>{
                            
                            '"recordNumber"'=>FAP_SearchHitWrapper.toJSONString(String.valueOf(hit.resultSequenceNumber)),
                            '"id"'=>FAP_SearchHitWrapper.toJSONString(hit.locationId),
                            '"name"'=>FAP_SearchHitWrapper.toJSONString(hit.locationName),
                            '"latitude"'=>''+hit.latitude,
                            '"longitude"'=>''+hit.longitude,
                            '"street"'=>FAP_SearchHitWrapper.toJSONString(hit.street),
                            '"city"'=>FAP_SearchHitWrapper.toJSONString(hit.city),
                            '"state"'=>FAP_SearchHitWrapper.toJSONString(hit.stateProvince),
                            '"postalCode"'=>FAP_SearchHitWrapper.toJSONString(hit.postalCode),
                            '"country"'=>FAP_SearchHitWrapper.toJSONString(hit.country),
                            '"partnerName"'=>FAP_SearchHitWrapper.toJSONString(hit.partnerName)
                        }
                       ,':'
                       ,','
                    )
                    + '}'
                );
            }
        }
        json = '{ "locations" : [' + FAP_StringUtils.joinArray(locationsJSONEncoded,',') + ']}';
        return json;
    }
    //V2.4 - End
    
    private static String toJSONString(String aString){
        if(aString != null){
           
            // Ver 2.2: To fix 'Too many script statements'
            aString = aString.replace('"', '\\"').replace('\\', '\\\\').replace('\n', '\\n').replace('\t', '\\t').replace('\f', '\\f').replace('\r', '\\r').replace('/', '\\/');
        }
        return (aString == null) ? 'null' : '"' + aString + '"';
       
    }
    
    private static Map<String,FAP_FormField> buildFieldsInResultListForQuery(FAP_Configuration configuration){
        final Map<String,FAP_FormField> fields = new Map<String,FAP_FormField>();
       
        //Ver 2.2: To fix 'Too many script statements'
        if(configuration != null){
            List<FAP_FieldConfiguration> searchScreenFieldsInResultList = configuration.searchScreenFieldsInResultList;
            if((searchScreenFieldsInResultList != null) && (searchScreenFieldsInResultList.size() > 0)){
                for(FAP_FieldConfiguration fieldConfiguration : searchScreenFieldsInResultList){
                    if(Limits.getScriptStatements() >= configuration.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 2.3
                    if(fieldConfiguration != null){
                        //system.debug('*************11111'+FAP_Configuration.strObjectName.equalsIgnoreCase(fieldConfiguration.objectName));
                       // system.debug('******fieldConfiguration.objectName*******11111'+fieldConfiguration.objectName);
                        fields.put(
                             (FAP_Configuration.strObjectName.equalsIgnoreCase(fieldConfiguration.objectName) ? FAP_Configuration.keyValue : '') + fieldConfiguration.fieldName
                            ,new FAP_FormField(fieldConfiguration)
                        );
                    }
                   // system.debug('**fieldConfiguration.fieldName11'+fieldConfiguration.fieldName);
                  //  system.debug('**searchScreenFieldsInResultList '+searchScreenFieldsInResultList );
                  //  system.debug('**fieldConfiguration'+fieldConfiguration);
                 //   system.debug('**fields'+fields);
                 //   system.debug('**strObjectName11'+FAP_Configuration.strObjectName);
                }
            }
        }
         system.debug('**fields111'+fields);
        return fields;
    }/*
    
    private static List<String> buildFieldsInResultListForQueryAsList(FAP_Configuration configuration){
        final List<String> fields = new List<String>();
       
        
        //Ver 2.2: To fix 'Too many script statements'
        if(configuration != null){
            List<FAP_FieldConfiguration> searchScreenFieldsInResultList = configuration.searchScreenFieldsInResultList;
            if((searchScreenFieldsInResultList != null) && (searchScreenFieldsInResultList.size() > 0)){
                for(FAP_FieldConfiguration fieldConfiguration : searchScreenFieldsInResultList){
                    if(Limits.getScriptStatements() >= configuration.scriptStatementLimit) { throw new FAP_FAPLimitException(); } // Ver 2.3
                    if(fieldConfiguration != null){
                        fields.add((FAP_Configuration.strObjectName.equalsIgnoreCase(fieldConfiguration.objectName) ? FAP_Configuration.keyValue : '') + fieldConfiguration.fieldName);
                    }
                }
            }
            system.debug('**strObjectName22'+FAP_Configuration.strObjectName);
        }
        return fields;
    }

    private static String fieldConfigurationToFieldName(FAP_FieldConfiguration fieldConfiguration){
        String returnValue = null;
        if(fieldConfiguration != null){
            returnValue = (FAP_Configuration.strObjectName.equalsIgnoreCase(fieldConfiguration.objectName) ? FAP_Configuration.keyValue : '') 
                + fieldConfiguration.fieldName;
        }
        return returnValue;
    }
    */
}
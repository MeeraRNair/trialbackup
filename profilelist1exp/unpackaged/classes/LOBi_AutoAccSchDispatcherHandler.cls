/*
 * Revision CR Number   Release No  Date            Created/Modified By         Description
 * -------- ---------   ----------  -----------     -------------------         -----------
 * 1.0      CR#14155    FY18-0602   19-Apr-2017     Venkateswarlu Chirala       LOBi_AutoAccSchDispatcherHandler class calls the LOBi_AutoIdentifyAccountBatch class
 *                                                                            ** Test Class for this class is: LOBi_SchDispatcher_Batch_RulesTest
 *   
 */
 
    public class LOBi_AutoAccSchDispatcherHandler implements LOBi_AutoAccSchDispatcher.IScheduleDispatched {
    
        /** 
         * @author Venkateswarlu Chirala
         * @date  19-Apr-2017
         * @description execute method to instantiate the class to schedule
         *     1) Prepare the dynamic SOQL query to send to LOBi_AutoIdentifyAccountBatch class as parameterized constructor. 
         *     2) Elgible Accounts: End user RecordType; Rating filed not equal to NULL
         *     3) Exclude: Account Country has GC countries , Account country code has GC country codes & Partner_Type__c = 'US Federal'
         *
         *@param SchedulableContext Interface a class that implements the Schedulable interface and contains the scheduled job ID.
         */
        public void execute(SchedulableContext sc) {
            
            List<String> RTtypes        =     new List<String>{'GBL_Standard_RT'}; // defined End user Record type. 
            Set<String> ratingSet       =     new Set<String>(); //  {'T1a High Sp R&D','T1b Med Sp R&D','T1c','T2a High BP ACQ','T2b Med BP ACQ','T3 MM','T4 CFL','T5 Greenfield'};           
            List<String> gcCountries    =     new List<String>(); //{'China','Hong Kong','Macau','Taiwan'};
            List<String> gcCountryCodes =     new List<String>(); // {'CN','HK','TW','MO'};
            List<String> USFedCountries =     new List<String>(); // SalesChannelUS FED countries
            List<String> segmentName     =     new List<String>();// Exlude AMER US FED Channels Accounts
             
          // Get the Rating picklsit values from Custom meta data types to add in Dynamic SOQL
            for (List<LOBi_Business_Rules__mdt> lobiList: [SELECT ID,DeveloperName,Eligible_Rating_picklist_values__c FROM LOBi_Business_Rules__mdt WHERE Eligible_Rating_picklist_values__c != NULL  LIMIT 10]) {
                    if (lobiList.size() > 0){
                        for (LOBi_Business_Rules__mdt lobi: lobiList){
                            for(String rating: lobi.Eligible_Rating_picklist_values__c.normalizeSpace().split(';'))
                                  if(String.isNotBlank(rating.trim())) ratingSet.add(rating.trim());              
                     }                  
                }
            }
          
        //Get GC countries from custom labels to add in Dynamic SOQL
         if(System.Label.GCCountries.normalizeSpace() != 'NULL')
           for(String gc:System.Label.GCCountries.normalizeSpace().split(';'))
                 if(String.isNotBlank(gc.trim())) gcCountries.add(gc.trim());
                 
        //Get GC countries codes from custom labels to add in Dynamic SOQL                    
         if(System.Label.GCCountryCodes.normalizeSpace() != 'NULL')
           for(String gcCodes:System.Label.GCCountryCodes.normalizeSpace().split(';'))
                if(String.isNotBlank(gcCodes.trim())) gcCountryCodes.add(gcCodes.trim());
                
        //Get US federal from custom labels to add in Dynamic SOQL  
         if(System.Label.Sales_Channel_US_Countries.normalizeSpace() != 'NULL')
            for(String fed:System.Label.Sales_Channel_US_Countries.normalizeSpace().split(';'))
                if(String.isNotBlank(fed.trim())) USFedCountries.add(fed.trim());
        
        //Get US federal from custom labels to add in Dynamic SOQL  
         if(System.Label.Sales_Channel_Segment_Name.normalizeSpace() != 'NULL')
            for(String segName:System.Label.Sales_Channel_Segment_Name.normalizeSpace().split(';'))
                 if(String.isNotBlank(segName.trim())) segmentName.add(segName.trim());
             
          // Construct the dynamic SOQL query
            String soql = 'SELECT ID,Account_Country__c ,Account_Country_Code__c ,Rating,CSG__c,Networking__c,Server__c,Storage__c,CSG_Timestamp__c,Networking_Timestamp__c,Server_Timestamp__c,Storage_Timestamp__c FROM Account '; // Base query
                   soql = soql + ' WHERE Account_Country__c != NULL AND Account_Country_Code__c != NULL AND Rating != NULL AND RecordTypeID != NULL '; // NOT NULL checks
                   soql = soql + ' AND ( (CSG__c= FALSE AND CSG_Timestamp__c = NULL) OR ( Networking__c = FALSE AND Networking_Timestamp__c = NULL) OR ( Server__c= FALSE AND Server_Timestamp__c= NULL) OR (Storage__c= FALSE AND Storage_Timestamp__c= NULL) ) '; // Eligibility of Incumbency flags
                   soql = soql + ' AND RecordType.DeveloperName IN:RTtypes AND Rating IN:ratingSet '; //  inlcude End user RT & Rating
           
           if(!gcCountries.isEmpty()) soql = soql + ' AND Account_Country__c NOT IN: gcCountries '; // Exclude the GC countries names if contains
           if(!gcCountryCodes.isEmpty()) soql = soql + ' AND Account_Country_Code__c NOT IN: gcCountryCodes ';  // Exclude the GC countries code coutnires if contains
           if(!USFedCountries.isEmpty()) soql = soql + ' AND ( Country_Name_lookup__c NOT IN: USFedCountries '; // Exclude the SalesChannel US Fed countries //( NOT Sales_Channel__r.Name LIKE \'%'+salesChannelUSFed +'%\' ) '; // Exclude the US federa if contains
           if(!segmentName.isEmpty()) soql= soql + ' OR Segment_Name_lookup__c NOT IN: segmentName ) '; // Exlude the if SalesChannel Segmentname IN "FED"
    
          System.debug('-------------->> Dynamic SOQL '+soql);
            
         // invoke Batch class with parameterized constructor and Execute the batch class with batch size from custom label.
           LOBi_AutoIdentifyAccountBatch lobiBatch= new LOBi_AutoIdentifyAccountBatch(soql, RTtypes, gcCountries, gcCountryCodes, segmentName, ratingSet,USFedCountries ); 
           Database.executeBatch(lobiBatch, Integer.valueOf(System.Label.LOBi_BatchSize.trim()));
        }
    }
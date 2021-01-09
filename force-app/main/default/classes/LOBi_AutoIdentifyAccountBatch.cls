/*
 * Revision CR Number   Release No  Date            Created/Modified By         Description
 * -------- ---------   ----------  -----------     ------------                -----------
 * 1.0      CR#14155    FY18-0602   19-Apr-2017     Venkateswarlu Chirala         Automatically identify eligible commerical End user accounts based on Business rules
 *                                                                             ** Test Class for this class is: LOBi_SchDispatcher_Batch_RulesTest                                                                              
 *    
 */
 
global class LOBi_AutoIdentifyAccountBatch implements Database.Batchable<sObject> {
        
    public String query;                                   // Query to to set the Database.getQueryLocator method of start()
    List<String> RTtypes        =   new List<String>();    // To holds the Record Types names
    List<String> gcCountries    =   new List<String>();    // To holds the GC names
    List<String> segmentName    =   new List<String>();    // To holds the SegmentName like"FED"
    Set<String> ratingSet       =   new Set<String>();     // To holds the Rating field picklist values
    List<String> gcCountryCodes =   new List<String>();    // To holds the GC codes
    List<String> USFedCountries =   new List<String>();    // SalesChanel US Countries list
        
     /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description LOBi_AutoIdentifyAccountBatch called from LOBi_AutoAccSchDispatcherHandler class
     *     
     *@param To prepare the SOQL query & required binding variables for start method to Query data
     */
    public LOBi_AutoIdentifyAccountBatch(String soql, List<String> RTtypes,List<String> gcCountries,
                                         List<String> gcCountryCodes, List<String> segmentName, Set<String> ratingSet, List<String> USFedCountries ){
        query=soql;
        this.RTtypes.addAll(RTtypes);
        this.gcCountries.addAll(gcCountries);
        this.gcCountryCodes.addAll(gcCountryCodes);
        this.segmentName.addAll(segmentName);
        this.ratingSet.addAll(ratingSet);
        this.USFedCountries.addAll(USFedCountries);
        
        System.debug('------------->>query '+query);   
    }
    
    /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description  Collect the Account object records to pass to the interface method execute for execute of business rules
     *     
     *@param Represents the parameter type of a batch job method and contains the batch job ID. 
     *       This interface is implemented internally by Apex.
     */
     
    global database.queryLocator start(Database.BatchableContext BC) {
      System.debug('------------->>query Start Method'+query);
        return Database.getQueryLocator(query);
    }

    /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description  method is called for each batch of records that you pass to it to execute Business rules 
     *  1) Prepare the Eligible Account by checking all conditions i.e. Account Country NOT NULL, Account  Count code NOT NULL, validated in Country object, etc...
     *  2) Prepare the required dataset to execute business rules: Fetch Last 8 Quarters, Fetch Last 4 Quartes ,
            Fetch last Quarter Start Date & End Date from custom setting
     *  3) Get the business rules configuration setting data from Custom Metadata Types
     *  4) Process business rules: 
     *          Rule 1: Check the Enduser Account Revenue criteria meets. for ISG < $10K last 8 quarter and CSG < $10K in last 4 quarters
     *          Rule 2: Check on End User Account Partner opportunity criteria meets, won in last quarter & Medaled partner
     *          Rule 3: Check the Opporutntiy products prize criteria meets  the min (50/20k) rev requirement based of Tiering
     *          Rule 4: If account reach LOB incumbency on at least one ISG LoB (Server or Networking or Storage),
     *                   we need to check if the overall ISG Revenue is <10k and then the account will earn complete ISG incumbency
     *  5) Exception Handeling: To store the failed record into Exception__c object for monitoring/reporting purpose only(no functionality associated with LOBi)
     *@param Reference to the Database.BatchableContext object and list of Account to process
     *       
     */
    global void execute(Database.BatchableContext BC, list<Account> accList) {
    
    if(accList.size() > 0){  
        
     // Declartion all the variables needed to execute method
        Map<ID, Account> accMap                             =   new Map<ID, Account>(accList);
        Map<ID, Set<String>> autoEligAccIncumMap            =   new Map<ID, Set<String>>();
        Map<String,LOBi_Business_Rules__mdt> lobiCustMeta   =   new Map<String,LOBi_Business_Rules__mdt>();
        Set<String> last8QuartersSet                        =   new Set<String>();
        Set<String> last4QuartsSet                          =   new Set<String>();
        Map<String, Set<String>> countryName_Codes          =   new Map<String, Set<String>>();
        Date lastQuarterStDate,lastQuarterEndDate;   
        Set<String> Tiers_1a_5                              =   new Set<String>(); //{'T1a High Sp R&D','T1b Med Sp R&D','T1c','T2a High BP ACQ','T2b Med BP ACQ','T3 MM','T4 CFL','T5 Greenfield'};
        Set<string> Tiers_2a_2b_5                           =   new Set<String>(); //{'T2a High BP ACQ','T2b Med BP ACQ','T3 MM','T4 CFL','T5 Greenfield'};
        Set<String> ISG_1a_2a                               =   new Set<String>(); //{'T1a High Sp R&D','T2a High BP ACQ'};
        Set<string> ISG_1b_2b_3_5                           =   new Set<String>(); //{'T1b Med Sp R&D', 'T2b Med BP ACQ','T1c','T3 MM','T4 CFL','T5 Greenfield'};
        Set<String> CSG_2a                                  =   new Set<String>(); //{'T2a High BP ACQ'};
        Set<String> CSG_2b_3_5                              =   new Set<String>(); //{'T2b Med BP ACQ','T3 MM','T4 CFL','T5 Greenfield'};
        Set<String> partnerRelSet                           =   new Set<string>(); //{'Gold', 'Platinum', 'Titanium', 'Titanium Black' };

     
       // Get the "Country" object data and assign to Map for validate the Account country names & country codes 
         for(Country__c c:[SELECT ID,Name,Dell_Online_Country_Code__c , Code__c FROM Country__c 
                                  WHERE Name!= NULL AND (Dell_Online_Country_Code__c != NULL OR Code__c!= NULL) LIMIT 1000]){
             if(String.isNotBlank(c.Name) && (String.isNotBlank(c.Dell_Online_Country_Code__c) || String.isNotBlank(c.Code__c))) {
                 Set<String> codes=new Set<string>();
                 if(String.isNotBlank(c.Dell_Online_Country_Code__c)) codes.add(c.Dell_Online_Country_Code__c.toUpperCase());
                 if(String.isNotBlank(c.Code__c))  codes.add(c.Code__c.toUpperCase());
                 countryName_Codes.put(c.Name.toUpperCase(), codes);
             }
         }
     
        // Get the Rating picklsit values from Custom meta data types        
           for (List<LOBi_Business_Rules__mdt> lobiList: [SELECT ID, MasterLabel,DeveloperName,Eligible_Rating_picklist_values__c, Eligible_Product_codes__c FROM LOBi_Business_Rules__mdt LIMIT 10]) {
                if (lobiList.size() > 0)
                    for (LOBi_Business_Rules__mdt lobi: lobiList){
                        lobiCustMeta.put(lobi.DeveloperName, lobi);
                        
                          if (lobi.DeveloperName == 'Storage_Incum' || lobi.DeveloperName == 'Networking_Incum' ||lobi.DeveloperName == 'Server_Incum'){
                              for(String rating: lobi.Eligible_Rating_picklist_values__c.normalizeSpace().split(';'))
                                 if(String.isNotBlank(rating.trim())) Tiers_1a_5.add(rating.toUpperCase().trim());
                           }
                          if(lobi.DeveloperName == 'Client_Incum'){
                            for(String rating: lobi.Eligible_Rating_picklist_values__c.normalizeSpace().split(';'))
                               if(String.isNotBlank(rating.trim())) Tiers_2a_2b_5.add(rating.toUpperCase().trim());
                        }
                    }
                } // End of of getting rating picklsit values from Custom meta data types   
          
            // Get the Tiering sets from custom labels
            if(System.Label.ISG_1a_2a.normalizeSpace() != 'NULL')
                 for(String isg1a:System.Label.ISG_1a_2a.normalizeSpace().split(';'))
                    if(String.isNotBlank(isg1a.trim())) ISG_1a_2a.add(isg1a.toUpperCase().trim());
                    
            if(System.Label.ISG_1b_2b_3_5.normalizeSpace() != 'NULL')
                 for(String isg1b_2b:System.Label.ISG_1b_2b_3_5.normalizeSpace().split(';'))
                    if(String.isNotBlank(isg1b_2b.trim())) ISG_1b_2b_3_5.add(isg1b_2b.toUpperCase().trim());
                    
            if(System.Label.CSG_2a.normalizeSpace() != 'NULL')
                 for(String csg2a:System.Label.CSG_2a.normalizeSpace().split(';'))
                    if(String.isNotBlank(csg2a.trim())) CSG_2a.add(csg2a.toUpperCase().trim());
                    
            if(System.Label.CSG_2b_3_5.normalizeSpace() != 'NULL')
                 for(String csg2b:System.Label.CSG_2b_3_5.normalizeSpace().split(';'))
                    if(String.isNotBlank(csg2b.trim())) CSG_2b_3_5.add(csg2b.toUpperCase().trim());
                    
            if(System.Label.partnerRelationTypes.normalizeSpace() != 'NULL')
                 for(String pr:System.Label.partnerRelationTypes.normalizeSpace().split(';'))
                    if(String.isNotBlank(pr.trim())) partnerRelSet.add(pr.trim());
           // End of getting Tiering sets from custom labels  
               
                
        // Validate the Account country names & country codes by comparing in "Country" object data & eligbile Account Incumbency flags
        for (Account acc: accList) {
            if(countryName_Codes.containsKey(acc.Account_Country__c.toUpperCase())&& 
                countryName_Codes.get(acc.Account_Country__c.toUpperCase()).contains(acc.Account_Country_Code__c.toUpperCase()) && String.isNotBlank(acc.Rating)){
            Set <String> elgFlags = new Set <String> ();
            Boolean clntFlag  = (!acc.CSG__c && String.isBlank(String.valueOf(acc.CSG_Timestamp__c)) && (Tiers_2a_2b_5.contains((accMap.get(acc.ID).Rating).toUpperCase().trim()))) ? elgFlags.add('Client') : FALSE;
            Boolean nwFlag    = (!acc.Networking__c && String.isBlank(String.valueOf(acc.Networking_Timestamp__c))&& (Tiers_1a_5.contains((accMap.get(acc.ID).Rating).toUpperCase().trim()))) ? elgFlags.add('Networking') : FALSE;
            Boolean srFlag    = (!acc.Server__c && String.isBlank(String.valueOf(acc.Server_Timestamp__c)) && (Tiers_1a_5.contains((accMap.get(acc.ID).Rating).toUpperCase().trim()))) ? elgFlags.add('Server') : FALSE;
            Boolean strFlag   = (!acc.Storage__c && String.isBlank(String.valueOf(acc.Storage_Timestamp__c)) && (Tiers_1a_5.contains((accMap.get(acc.ID).Rating).toUpperCase().trim()))) ? elgFlags.add('Storage') : FALSE;
            if (!elgFlags.isEmpty()) autoEligAccIncumMap.put(acc.ID, elgFlags);
          }
        }
        System.debug('--------->> accMap------------>> '+accMap);
        System.debug('--------->> autoEligAccIncumMap -->' + autoEligAccIncumMap);
        
        // Fetch Last 8 Quarters, Fetch Last 4 Quartes and last Quarter Start Date & End Date from custom setting
        if (!autoEligAccIncumMap.isEmpty()) {
            Date today = System.today();
            Date startDate = Date.newInstance(today.year(), today.month() - 24, today.day());
            Integer i = 1;
            while (startDate < today) {
                for (Fiscal_Years__c fy: (Fiscal_Years__c.getAll()).values()) {
                    if (startDate >= fy.Start_Date__c && startDate <= fy.End_Date__c) {
                        last8QuartersSet.add('FY20' + fy.Name.subString(2, 4) + 'Q0' + fy.Name.right(1));
                        if (i > 4) last4QuartsSet.add('FY20' + fy.Name.subString(2, 4) + 'Q0' + fy.Name.right(1));
                        if (i == 8) {
                            lastQuarterStDate = fy.Start_Date__c;
                            lastQuarterEndDate = fy.End_Date__c;
                        }
                    }
                }
                startDate = startDate.addMonths(3);
                i = i + 1;
            }
            System.debug('=====>last8QuartersSet' + last8QuartersSet);
            System.debug('=====>last4QuartsSet' + last4QuartsSet);
            System.debug('=====>lastQuarterStartDate' + lastQuarterEndDate + '=====>' + lastQuarterStDate);               
       // End of setup the data for business rules
        
        
           // ---- Rule 1 ---: Check the Enduser Account Revenue criteria meets. for ISG < $10K last 8 quarter and CSG < $10K in last 4 quarters
            Map<ID, Set<String>> revSucMapAccID_IncmFlags   = new Map<ID, Set<String>>();
            Map<ID, Set<String>> revFailMapAccID_IncmFlags  = new Map<ID, Set<String>>();
            Map<ID, Double> totalISGRevenue                 = new Map<ID, Double>();
        
            Map<String, Object> returnDataSet = LOBi_AutoIdentifyAccBusinessRules.endUserAccRevenueRuleCheck(autoEligAccIncumMap, last8QuartersSet, last4QuartsSet,
                                                                                                                  accMap, Tiers_1a_5, Tiers_2a_2b_5);
            revSucMapAccID_IncmFlags    = (Map<ID, Set<String>>) returnDataSet.get('RevSucess');
            revFailMapAccID_IncmFlags   = (Map<ID, Set<String>>) returnDataSet.get('RevFailed');
            totalISGRevenue             = (Map<ID, Double>) returnDataSet.get('ISGTotalRev');
        
            // ---- Rule 2 ----: Check on End User Account Partner opportunity criteria meets, won in last quarter & Medaled partner
            if (!revSucMapAccID_IncmFlags.isEmpty()) {                               
                Map<ID, Set<ID>> oppSucMapAccID_OppSet = new Map<ID, Set<ID>>();
                oppSucMapAccID_OppSet = LOBi_AutoIdentifyAccBusinessRules.endUserAccPartOppRuleCheck(revSucMapAccID_IncmFlags, partnerRelSet, lastQuarterStDate, lastQuarterEndDate);
               
              // ----Rule 3 ----: Check the Opporutntiy products prize criteria meets  the min (50/20k) rev requirement based of Tiering
                if (!oppSucMapAccID_OppSet.isEmpty()) { 
                    Map<ID, Set<String>> succMap_OppProdRev = new Map<ID, Set<String>>();                   
        
                    Map<String, Object> returnDataSetOppPr = LOBi_AutoIdentifyAccBusinessRules.partOppProductsRevRuleCheck(oppSucMapAccID_OppSet, accMap, ISG_1a_2a, ISG_1b_2b_3_5,
                                                                                                                             CSG_2a, CSG_2b_3_5, revSucMapAccID_IncmFlags, lobiCustMeta);
                    succMap_OppProdRev = (Map<ID, Set<String>>) returnDataSetOppPr.get('succOppProdRev');
        
                // ---- Rule 4 ----: account reach LOB incumbency on at least one ISG LoB (Server or Networking or Storage), if the overall ISG Revenue is <10k and then the account will earn complete ISG incumbency
                    if (!succMap_OppProdRev.isEmpty()) {
                        List <Account> accUpdateList = new List<Account>();
                        accUpdateList = LOBi_AutoIdentifyAccBusinessRules.finalNewLogoRuleCheck(autoEligAccIncumMap, totalISGRevenue, succMap_OppProdRev);
        
                       if(accUpdateList.size() > 0){
                          TriggerExecutionController.setSkipAllTriggers(True); // setSkipAllTriggers as "TRUE"
                          List<Database.SaveResult> updateResults = Database.update(accUpdateList, false); // DML Operation get saveResult[]
                          
                          //---- Exception handeling ---- storing into Exception object with error message & object ID
                          List<Exception__c> exceList=new List<Exception__c>();                       
                           for(Integer inte=0;inte<updateResults.size();inte++){
                                if (!updateResults.get(inte).isSuccess())
                                    exceList.add(new Exception__c(Process_Name__c='LOBi_AutoIdentifyAccountBatch',Object_type__c='Account',Object_ID__c=accUpdateList.get(inte).ID,
                                                                  Error_Messages__c=updateResults.get(inte).getErrors().get(0).getMessage()));
                            }
                            if(!exceList.isEmpty()) // Insert Exception object if size > 0
                              insert exceList; 
                      } // End of accUpdateList final update
                    } // End of succMap_OppProdRev 
                } // End of oppSucMapAccID_OppSet
            } // End of revSucMapAccID_IncmFlags       
          } // End of autoEligAccIncumMap
        } // End of if(accList)     
      } // End of Execute method()
        
    /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description  Logic for next schdule 3 months
     *     
     *@param Represents the parameter type of a batch job method and contains the batch job ID. 
     *       This interface is implemented internally by Apex.
     */
        global void finish(Database.BatchableContext BC) {
        // Logic to schdule for next 3 months
        // System.Schedule('LOBi_AutoAccSchdDispatcher '+(DateTime.Now().format())+'MilliSec '+ DateTime.now().millisecond(), Datetime.now().addMonths(3).format('s m H d M ? yyyy'),new  LOBi_AutoAccSchDispatcher()); 
       }
    }
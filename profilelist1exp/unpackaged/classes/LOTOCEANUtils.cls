/*
Author: Raymond Yip

History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      20-Apr-2010    Raymond         Created for CR2559, 2560, R11.5
2.0      12-May-2010    Raymond         Updated for code to reset all Line Item when Oppty doesnt mee requirement
2.1      24-May-2010    Raymond         Added Adjustment_weeks__c calculation to Ocean
2.2      31-May-2010    Raymond         Added Volume_to_Dollar_Ratio__c to ship rate calculation
2.3      22-Jun-2010    Carmen          CR2804: Added Pallet_Rate__c and Pallet_Quantity__c in Ocean calculation
2.4      22-Jun-2010    Carmen          CR2808: Set Do_you_want_to_pursue_Ocean__c to No if Must_Arrive_By_Date__c is checked
2.5      07-Jul-2010    Raymond         Added code to retrieve only countries needed from LOT Region
2.6      08-Jul-2010    Carmen          Added Ocean Type in Opportunity and Opportunity Product
2.7      09-Jul-2010    Raymond         Added static variable and static method to retrieve country region
2.8      15-Jul-2010    Carmen          Fixed setupCountryToRegionMap
2.9      22-Jul-2010    Raymond         Added countryToStgRegionMap, for Country to Region mapping
2.10     22-Jul-2010    Carmen          CR2804: Fixed Potential_Cost_Savings_if_Ocean__c to calculate by ttlQty
2.11     29-Jul-2010    Raymond         Modified to fix defect 61175.
2.12     30-Jul-2010    Carmen          Fixed TD61196: Modified processOCEANQualifiedOppty to fix Do_you_want_to_pursue_Ocean__c
2.13     02-Aug-2010    Carmen          CR2804: Remove logic to nullify Ocean Type if not Ocean Eligible
2.14     03-Aug-2010    Nooryati        Modified to fix too many SOQL queries, related with CR2805
2.15     08-Sep-2010    Raymond         CR4192 - To Fix error where LOT is removed when it is not supposed to. This happens when
                                        the user a product that threshold is not maintained in the product details.
3.1      17-Sep-2010    Raymond         CR4381 - Handle threshold less or equals to zero (treat it as null, skip LOT)
3.2      20-Sep-2010    Raymond         CR3481 - Replace Lead time in weeks with new formula:
                                            {On the Sea and Land from ODM to Customer} = ({Standard OE to SC} + {On the sea by ODM} + {Days in country Delivery}) / 7
3.3      25-Nov-2010    Raymond         CR5603 - Fix of defect where Ocean Data not correctly selected base on country
4.0      14-Dec-2010    Raymond         CR5529 - Modifiers
4.1      17-Dec-2010    Nooryati        CR5531: Splitting the APJ LOT Threshold
5.0      28-Mar-2012    Krishnamoorthi  CR6923: For R13.4 Maintenance Project - The system shall be able to mark the AMER FED Opportunities as LOT Opportunities
6.0      21-May-2012    Patrick         CR7118: Added a Map for Integration Profiles to be excluded
7.0     24-Apr-2013     Impana          CR8188 - Fix NULL Pointer Exception
8.0      7-June-2013    Ajay Singh      CR8347 - Maint: LOT - Fix the LOT functionality for "Korea, Repulic of"
9.0     25-Nov-2013     Vikas Gandhi    CR 8827 - LOT functionality should be excluded when opportunity having software enabled line items
9.1      29-Jan-2014    Sree Prakash    CR8979 - LOT - Code modified for the introduction of Override Probability field.
10.0    23-May-2014     Devika          CR 9337 - Exclude LOT functionality for Channel recordtypes.
11.0    27-08-2014      Mohammad        CR 9701  - Include Channel Commercial Email Fields in Lot Ocean Emial Object t osend lot Notifiaction when Segment Business Unit name is Channel Commercial
12.0    30-11-2015      Afiq            CR 12402 - Comment few method to reduce SQL queries as well edition existing queries to be more robust
13.0    13-06-2017      Akshita         CR 14471 - Replaced the Hard-coded stage names to the names given in OWD__c custom settings and added the value for 'Order-Submitted - 99%' stage
14.0    05-Mar-2018     Emily           CR 15486 - Field Trip clean up for Opportunity
*/
public class LOTOCEANUtils {

    //adding constructor to assist in getting code coverage
    public LOTOCEANUtils(){
    }    
        final Map<String, String> segmentEmailByCountryMap = new Map<String, String>{
                                                        'LARGE ENTERPRISE' => 'Country_LE__c',
                                                        'PUBLIC' => 'Country_PUB__c',
                                                        'SMALL MEDIUM BUSINESS' => 'Country_SMB__c',
                                                        'CONSUMER' => 'Country_Consumer_Retail__c',
                                                        'NA COMMERCIAL' => 'Country_NA_Commercial__c',
                                                        'LA COMMERCIAL ' => 'Country_LA_Commercial__c',
                                                        'APJ COMMERCIAL ' => 'Country_APJ_Commercial__c',
                                                        'EMEA COMMERCIAL' => 'Country_EMEA_Commercial__c',
                                                        'GLOBAL COMMERCIAL' => 'Country_Global_Commercial__c',
                                                        'CHANNEL COMMERCIAL' => 'Country_Channel_Commercial__c'
};

    final Map<String, String> segmentEmailByRegionMap = new Map<String, String>{
                                                    'LARGE ENTERPRISE' => 'Region_LE__c',
                                                    'PUBLIC' => 'Region_PUB__c',
                                                    'SMALL MEDIUM BUSINESS' => 'Region_SMB__c',
                                                    'CONSUMER' => 'Region_Consumer_Retail__c',
                                                    'NA COMMERCIAL' => 'Region_NA_Commercial__c',
                                                    'LA COMMERCIAL' => 'Region_LA_Commercial__c',
                                                    'APJ COMMERCIAL' => 'Region_APJ_Commercial__c',
                                                    'EMEA COMMERCIAL' => 'Region_EMEA_Commercial__c',
                                                    'GLOBAL COMMERCIAL' => 'Region_Global_Commercial__c',
                                                    'CHANNEL COMMERCIAL' => 'Region_Channel_Commercial__c'
};


    final Map<String, String> thresholdByRegionMap = new Map<String, String> {
                                                    'AMER' => 'AMER__c',
                                                    'APJ ASIA' => 'APJ_ASIA__c',
                                                    'APJ CHINA' => 'APJ_China__c',
                                                    'APJ INDIA' => 'APJ_ICC__c',
                                                    'APJ HONG KONG, JAPAN & KOREA' => 'APJ_HK_JPN_KOR__c',
                                                    'BRAZIL' => 'Brazil__c',
                                                    'EMEA' => 'EMEA__c',
                                                    'FED' => 'FED__c',
                                                    'LATAM' => 'LATAM__c'};

     //for getting picklist values from custom setting
    
    public OWD__c obj = OWD__c.getOrgDefaults();
    
    public String win = obj.Oppty_Stage100__c;    
    public String qualify = obj.Oppty_Stage30__c;    
    public String propose = obj.Oppty_Stage60__c;    
    public String comit = obj.Oppty_Stage90__c;    
    public String order_submitted = obj.Oppty_Stage99__c;

    Map<String, Ocean_Data__c> oceanDataMap;
    Map<String, LOT_OCEAN_EMAIL__c> emailsByCountryMap;
    Map<String, LOT_OCEAN_EMAIL__c> emailsByRegionMap;

    public static Map<string,string> RMCountryMappingMap = new Map<string,string>();

    public static void setRMCountryMappingMap(){

     List<LOT_Region__c> regionList = [Select l.Threshold_Region__c, l.Region__c, l.Name, l.Id , l.RM_Country__c From LOT_Region__c l WHERE l.RM_Country__c != null ];

     if(regionList != null)
     {
        for(LOT_Region__c rm : regionList){

            RMCountryMappingMap.put(rm.RM_Country__c,rm.Name.toUpperCase());


        }
     }
     
        
    }

    // 2.14: CR 2805 - Exclude 'Services Profiles'
    public static Map<Id,Profile> profileIdToSkipLOTOcean = null;

    static {
        profileIdToSkipLOTOcean = new Map<Id, Profile>([SELECT Id, Name from Profile where Name LIKE '%service%']);
    }

    public static Map <Id, Profile> getprofileIdToSkipLOTOcean(){
        return profileIdToSkipLOTOcean;
    }

    //7.0: CR7118 - Exclude 'Integration Profiles'
    //START 7.0
    public static Map<Id, Profile> integrationProfiles = null;

    static {
        integrationProfiles = new Map<Id, Profile>([SELECT Id, Name FROM Profile
                                WHERE Name LIKE '%Integration%']);
    }

    public static Map<Id, Profile> getIntegrationProfiles(){
        return integrationProfiles;
    }
    //END 7.0

    public static Map<String, String> countryToRegionMap;
    public static Map<String, String> countryToStdRegionMap;

    Map<Id, Opportunity> opptyMap;
    Map<Id, Opportunity> newOpptyMap;

    List<AggregateResult> quantityByOpptyProd;

    Map<Id, Product2> productMap;

    List<OpportunityLineItem> opptyLineItemList;
    Map<Id,List<OpportunityLineItem>> mapOLIRecords;

    public static Set<String> countrySet; //2.5

    //For new Opportunity
    public LOTOCEANUtils(Map<Id, Opportunity> newOpportunityMap) {

        newOpptyMap = newOpportunityMap;

        Set<String> opptyIdSet = new Set<String>();

        for(Opportunity oppty : newOpportunityMap.values()) {
            opptyIdSet.add(oppty.Id);
        }
        setupEmailMaps();
        setupOceanDataMap();
        setupCountryToRegionMap();
        opptyMap = getOpptyMap(opptyIdSet);
        quantityByOpptyProd = getAggregatedResult(opptyIdSet);
        opptyLineItemList = getOpptyLineItemList(opptyIdSet);
        productMap = getProductMap(quantityByOpptyProd);
        mapOLIRecords = queryLineItems(opptyIdSet);

    }

    private void setupOceanDataMap() {
        oceanDataMap = new Map<String, Ocean_Data__c>();

        //3.2: Removed "Lead_Time_in_Weeks__c", added "Days_in_country_Delivery__c" and "On_the_sea_by_ODM__c"
        List<Ocean_Data__c> odList = [SELECT Source__c, Ship_Rate__c, Pallet_Rate__c, Region__c, Exception_Country__c,
                                        CFS_Delivery_Time_in_Weeks__c, CFI_Delivery_Time_in_Weeks__c, MSP_Incremental_in_Weeks__c,
                                        Days_in_country_Delivery__c,On_the_sea_by_ODM__c,Pallet_Multiplier_Factor__c,Container_Multiplier_Factor__c
                                        FROM Ocean_Data__c];

        for(Ocean_Data__c od : odList) {
            //3.3
            if(od.Exception_Country__c != null) {
                oceanDataMap.put((od.Source__c.toUpperCase() + '-' + od.Exception_Country__c.toUpperCase()), od);
            } else {
                oceanDataMap.put((od.Source__c.toUpperCase() + '-' + od.region__c.toUpperCase()), od);
            }
        }
    }

    private Map<Id, Product2> getProductMap(List<AggregateResult> result) {

        Set<String> prodIdSet = new Set<String>();

        for(AggregateResult r : result) {
            prodIdSet.add((String)r.get('ProductId'));
        }

        //3.2: Added Standard_OE_to_SC__c
        Map<Id, Product2> tempMap = new Map<Id, Product2>([SELECT Id, Name,Standard_OE_to_SC__c,
                                                                APJ_ASIA__c,APJ_China__c,APJ_ICC__c,APJ_HK_JPN_KOR__c,
                                                                LATAM__c,Brazil__c,FED__c,
                                                                AMER__c,EMEA__c, Source__c,
                                                                Container_Volume__c, Pallet_Quantity__c, Volume_to_Dollar_Ratio__c
                                                            FROM Product2
                                                            WHERE Id IN :prodIdSet]);
        return tempMap;
    }

    private List<AggregateResult> getAggregatedResult(Set<String> idSet) {
        List<AggregateResult> tempResult = [ SELECT
                                            OpportunityId,
                                            PriceBookEntry.Product2Id ProductId,
                                            SUM(Quantity)totalQty
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId IN :idSet // CR 8827 Start
                                        AND DSG_CBO_Opportunity_Product__c != 1 AND DSG_CBO_Opportunity_Product__c != 2 // CR 8827 End
                                        GROUP BY OpportunityId, PriceBookEntry.Product2Id];

        return tempResult;
    }

    private Map<Id, Opportunity> getOpptyMap(Set<String> opptyIdSet) {
        Map<Id, Opportunity> tempMap = new Map<Id, Opportunity>( [
                                        SELECT Id, Name, Adjustment_weeks__c, Adjustment_Potential_Cost_Saving__c, StageName, Override_Probability__c,
                                                Probability, Primary_Product_Delivery_Address_Country__c,
                                                Primary_Product_Delivery_Address_Region__c,
                                                Account.Sales_Channel__r.Region_Name__c,
                                                Account.Sales_Channel__r.Segment_Business_Unit_Name__c,
                                                Account.Sales_Channel__r.Segment_Desc__c ,LOT_Large_Opportunity__c,
                                                LOT_Large_Opportunity_Potential__c, Delta_bet_Customer_req_n_calculated__c,
                                                Eligible_for_Ocean__c, Potential_Cost_Savings_If_Ocean__c,
                                                Customer_Requested_Delivery_Date__c, Calculated_Delivery_in_Weeks__c,
                                                CloseDate, Ocean_Opportunity_Notification_Pop_Up__c, Confirmed_for_Ocean_by_Finance_Gbl_Ops__c,
                                                Additional_vol_to_team_Quarterly__c,Is_CFI_included__c,
                                                /*14.0 Ocean_Mandatory_Fields__c,*/ LOT_Mandatory_Fields__c, LOT_OCEAN_Email_Notification__c,
                                                Must_Arrive_By_Date__c, Do_you_want_to_pursue_Ocean__c
                                                ,RecordTypeId // CR 9337
                                        FROM Opportunity
                                        WHERE Id IN :opptyIdSet ]);

        return tempMap;
    }

    private void setupEmailMaps() {
        //countryToRegionMap = new Map<String, String>();
        
        emailsByCountryMap = new Map<String, LOT_OCEAN_EMAIL__c> ();
        
        emailsByRegionMap = new Map<String, LOT_OCEAN_EMAIL__c> ();
        
        
             List<LOT_OCEAN_EMAIL__c> emailConfigList = [SELECT Id, Name, Region__c, Country_Consumer_Retail__c,Country_LE__c,
                                                        Country_PUB__c, Country_SMB__c,Region_Consumer_Retail__c,Region_Email_Identifier__c,
                                                        Region_LE__c,Region_PUB__c,Region_SMB__c, Country__r.Name, Country__r.Threshold_Region__c,Country_NA_Commercial__c,Country_LA_Commercial__c,
                                                        Country_APJ_Commercial__c,
                                                        Country_EMEA_Commercial__c,
                                                        Country_Global_Commercial__c,
                                                        Country_Channel_Commercial__c,
                                                        Region_NA_Commercial__c,
                                                        Region_LA_Commercial__c,
                                                        Region_APJ_Commercial__c,
                                                        Region_EMEA_Commercial__c,
                                                        Region_Channel_Commercial__c,
                                                        Region_Global_Commercial__c
                                                    FROM LOT_OCEAN_Email__c];
                                                    

        for(LOT_OCEAN_EMAIL__c cfg : emailConfigList) {

            if(cfg.Country__c != null) {
                 emailsByCountryMap.put(cfg.Country__r.Name.toUpperCase(), cfg);
            }

            if(cfg.Region_Email_Identifier__c && cfg.region__c != null) {
                 emailsByRegionMap.put(cfg.region__c.toUpperCase(), cfg);
            }
        }
    }

    public static void setupCountryToRegionMap() {

        List<LOT_Region__c> regionList;

        if(countryToRegionMap != null && countryToRegionMap.size() > 0) {
            return;
        }

        countryToRegionMap = new Map<String, String>();
        countryToStdRegionMap = new Map<String, String>();

        //Added countrySet != null to fix defect 61175
        if(countrySet != null && countrySet.size() > 0 ) {
            
            for(string s : countrySet){
                if(RMCountryMappingMap!= null && RMCountryMappingMap.containsKey(s))
                {
                    countrySet.add(RMCountryMappingMap.get(s));
                    countrySet.remove(s);
                }
            }
            

            /* 12.0 Start */
            regionList = [Select l.Threshold_Region__c, l.Region__c, l.Name, l.Id , l.RM_Country__c From LOT_Region__c l WHERE l.Name IN :countrySet OR l.RM_Country__c !=  null ];
            /* 12.0 End */ 

        } else {
        
            regionList = [Select l.Threshold_Region__c, l.Region__c, l.Name, l.Id, l.RM_Country__c From LOT_Region__c l];
        
        }

        for(LOT_Region__c lr : regionList) {
            
            
            if(lr.RM_Country__c != null && lr.RM_Country__c != ''){
                RMCountryMappingMap.put(lr.RM_Country__c, lr.Name.toUpperCase());
            }
            
            countryToRegionMap.put(lr.Name.toUpperCase(), StringUtils.defaultString(lr.Threshold_Region__c).toUpperCase());
            countryToStdRegionMap.put(lr.Name.toUpperCase(), StringUtils.defaultString(lr.Region__c).toUpperCase());

        }
    }


        public String getNotificationTargetEmail(String segment, String country, String region) {
        LOT_OCEAN_EMAIL__c tempObj;

        tempObj = emailsByCountryMap.get(country.toUpperCase());

        String targetEmail = '';
        if(tempObj != null) {

            String segmentEmailByCountry = segmentEmailByCountryMap.get(segment.toUpperCase());

            if(segmentEmailByCountry == null) {
                return null;
            }
            targetEmail = (String)tempObj.get(segmentEmailByCountry);

        }
        else if(tempObj == null) {

            tempObj = emailsByRegionMap.get(region);

            if(tempObj != null) {
                targetEmail = (String)tempObj.get(segmentEmailByRegionMap.get(segment));

                /* CR8188 - Fix NULL Pointer Exceptiohn */
                if((targetEmail == null) || (targetEmail.trim().length() <= 0))  {
                    //throw new dellUtil.DellException('Email is blank for  \"LOT OCEAN Email\" that matches segment \"' + segment + '\" and country \"' + country + '\" or region \"' + region + '\"');
                    return null;
                }

            } else {
                //throw new dellUtil.DellException('No record in \"LOT OCEAN Email\" that match country \"' + country + '\" or region \"' + region + '\"');
                return null;
            }
        }
        return targetEmail;

    }

    public List<Opportunity> processLOTQualifiedOppty() {
        //System.debug('###DEBUG### START processLOTQualifiedOppty' + '   :   ' + opptyMap + '    : ' +  quantityByOpptyProd + '    :   ' + opptyLineItemList + '   :    ' + productMap);
        if(opptyMap == null || quantityByOpptyProd == null || opptyLineItemList == null || productMap == null) {
            return null;
        }
        
        Map<Id, Opportunity> opptyToUpdateMap = opptyMap.deepClone();
        List<OpportunityLineItem> lstOppItemToUpdate = new List<OpportunityLineItem>();
        for(Opportunity o : opptyToUpdateMap.values()) {

            Boolean oldLOFlg = o.LOT_Large_Opportunity__c;
            Boolean oldPotentialLOFlg = o.LOT_Large_Opportunity_Potential__c;
            String oldErrorDesc = o.Error_Description__c;
            
            Boolean isLOTEligible = false;
            Boolean isLOTMandatory = false;
            Boolean newLOFlg = false;
            Boolean newPotentialLOFlg = false;
            String newErrorDesc = '';


            if(newOpptyMap != null) {
                o.Primary_Product_Delivery_Address_Country__c = newOpptyMap.get(o.Id).Primary_Product_Delivery_Address_Country__c;
                o.Primary_Product_Delivery_Address_Region__c = newOpptyMap.get(o.Id).Primary_Product_Delivery_Address_Region__c;
                o.Probability = newOpptyMap.get(o.Id).Probability;
                o.LOT_OCEAN_Email_Notification__c = newOpptyMap.get(o.Id).LOT_OCEAN_Email_Notification__c;
            }

           // [Ajay Singh - CR 8347 - Maint: LOT Fix the LOT functionality for "Korea, Repulic of" - 7/6/13 ]
            
            System.Debug('o.Primary_Product_Delivery_Address_Region__c##'+o.Primary_Product_Delivery_Address_Region__c);
            if(o.Primary_Product_Delivery_Address_Region__c =='APJ'
                && !(o.Primary_Product_Delivery_Address_Country__c == 'India' ||  o.Primary_Product_Delivery_Address_Country__c == 'China' || o.Primary_Product_Delivery_Address_Country__c == 'Korea' ||
                o.Primary_Product_Delivery_Address_Country__c == 'Hong Kong' || o.Primary_Product_Delivery_Address_Country__c == 'Japan' ||
                // [Aman Sharma Defect 72651 add Ignore Case Method]
                o.Primary_Product_Delivery_Address_Country__c.equalsIgnoreCase('Korea, Republic of'))) {

                o.LOT_Large_Opportunity__c = false;
                o.LOT_Large_Opportunity_Potential__c = false;
                continue;
            }
            o.Error_Description__c = '';

            System.Debug('o.Account.Sales_Channel__r.Segment_Business_Unit_Name__c##'+o.Account.Sales_Channel__r.Segment_Business_Unit_Name__c);
            if(o.Account.Sales_Channel__r.Segment_Business_Unit_Name__c == null) {
                o.Error_Description__c = System.today().format() + ' - ' + 'Sales Channel\'s \"Segment Business Unit Name\" is empty.';
                o.LOT_Large_Opportunity__c = false;
                o.LOT_Large_Opportunity_Potential__c = false;
                continue;
            }
            
            System.Debug('country##'+StringUtils.defaultString(o.Primary_Product_Delivery_Address_Country__c).toUpperCase());
            String country = StringUtils.defaultString(o.Primary_Product_Delivery_Address_Country__c).toUpperCase();
            String thresholdRegion; // = countryToRegionMap.get(country);
            String region;

            if(country.equalsIgnoreCase('UNITED STATES')) {
                try{
                string segDesc = o.Account.Sales_Channel__r.Segment_Desc__c;
                segDesc = segDesc.toUpperCase();
                region = segDesc.contains('FED') ? 'FED' : 'AMER';
                thresholdRegion = segDesc.contains('FED') ? 'FED' : 'AMER';
                //**Rev 5.0 Changes -- End
                }
                catch(Exception ex){
                  System.Debug('Exception Occured');
                  if(region == null){
                    region = StringUtils.defaultString(o.Primary_Product_Delivery_Address_Region__c).toUpperCase();
                    thresholdRegion = countryToRegionMap.get(country);
                  }
                }

            } else {
                region = StringUtils.defaultString(o.Primary_Product_Delivery_Address_Region__c).toUpperCase();
                thresholdRegion = countryToRegionMap.get(country);
               
            }
            if(thresholdRegion == null) {
                o.Error_Description__c = System.today().format() + ' - ' + 'Unable to identify the threshold region of country \"' + country + '\"';
                o.LOT_Large_Opportunity__c = false;
                o.LOT_Large_Opportunity_Potential__c = false;
                continue;
            }

            String segment = o.Account.Sales_Channel__r.Segment_Business_Unit_Name__c.toUpperCase();
            for(AggregateResult r : quantityByOpptyProd) {

                if((String)r.get('OpportunityId') != o.Id ) {
                    continue;
                }

                Double ttlQty = (Double)r.get('totalQty');
                Product2 currentProd = productMap.get((String)r.get('ProductId'));

                if(thresholdByRegionMap.get(thresholdRegion) == null) {
                    o.Error_Description__c = System.today().format() + ' - ' + 'INVALID Threshold Region - \"' + thresholdRegion + '\"';
                    o.LOT_Large_Opportunity__c = false;
                    o.LOT_Large_Opportunity_Potential__c = false;
                    continue;
                }

                Double threshold = (Double)currentProd.get(thresholdByRegionMap.get(thresholdRegion));

                //3.1
                if(threshold == null || threshold <= 0) {
                    continue;
                }
                
                //CR#8979 - START
                
                integer ActualProbability = 0;
                if(newOpptyMap.get(o.Id).Override_Probability__c != null){
                    if(newOpptyMap.get(o.Id).Override_Probability__c == '1%'){
                        ActualProbability = 1;
                    }
                    else if(newOpptyMap.get(o.Id).Override_Probability__c == '10%'){
                        ActualProbability = 10;
                    }
                    else if(newOpptyMap.get(o.Id).Override_Probability__c == '30%'){
                        ActualProbability = 30;
                    }
                    else if(newOpptyMap.get(o.Id).Override_Probability__c == '60%'){
                        ActualProbability = 60;
                    }
                    else if(newOpptyMap.get(o.Id).Override_Probability__c == '90%'){
                        ActualProbability = 90;
                    }
                }
                
                //CR#8979 - END
                
                System.Debug('Total -'+ttlQty+'Threhold -'+threshold+'Stage-'+newOpptyMap.get(o.Id).StageName+'Probability-'+o.Probability);
                if( ttlQty >= threshold) {                 
                    //if(o.Probability >= 60) {
                    if(newOpptyMap.get(o.Id).StageName == propose || newOpptyMap.get(o.Id).StageName == order_submitted || newOpptyMap.get(o.Id).StageName == comit || newOpptyMap.get(o.Id).StageName == win || (newOpptyMap.get(o.Id).StageName == qualify && ActualProbability >= 60) || (newOpptyMap.get(o.Id).StageName == qualify && o.Probability >= 60 && (newOpptyMap.get(o.Id).Override_Probability__c == null || ActualProbability == 0))){ 
                         newLOFlg = true;
                         newPotentialLOFlg=false;
                         for(OpportunityLineItem oli:mapOLIRecords.get(o.Id)){
                             if(oli.Quote__c==null || oli.Customer_Requested_Date__c ==null && oli.PriceBookEntry.Product2Id == currentProd.Id){
                                 isLOTMandatory = true;
                                 lstOppItemToUpdate.add(oli);
                             }
                         }                       
                         
                    //} else if(o.Probability >= 30 && o.Probability < 60 ) {
                    } else if(newOpptyMap.get(o.Id).StageName == qualify && o.Probability == 30){  
                         newPotentialLOFlg = true;
                         newLOFlg = false;
                    }                     
                }
            }
            
            if(isLOTMandatory) {               
                o.LOT_Mandatory_Fields__c = true;
            } 
            else if(!newLOFlg && oldLOFlg) {
                o.LOT_Large_Opportunity__c = false;
            }
            
            if(!isLOTMandatory) {               
                o.LOT_Mandatory_Fields__c = false;
            } 
            
            if(newLOFlg){
              o.LOT_Large_Opportunity__c = true;
            }
            

            if(newPotentialLOFlg) {
                o.LOT_Large_Opportunity_Potential__c = true;
            } else if(!newPotentialLOFlg && oldPotentialLOFlg) {

                o.LOT_Large_Opportunity_Potential__c = false;
            }

            //TODO: when get email, what if the oppty is already large order
            if(o.LOT_Mandatory_Fields__c || o.LOT_Large_Opportunity_Potential__c || o.LOT_Large_Opportunity__c) {

                String tempEmail = getNotificationTargetEmail(segment, country, region);
                
                if(tempEmail == null) {
                    o.Error_Description__c = System.today().format() + ' - ' + 'Unable to retrieve email.';
                } else {
                    o.LOT_OCEAN_Email_Notification__c = tempEmail;
                }
            }
        }
        if(!lstOppItemToUpdate.isEmpty()){
          //update lstOppItemToUpdate;
        }
        return opptyToUpdateMap.values();
    }

    public List<Opportunity> processOCEANQualifiedOppty() {
        if(opptyMap == null || quantityByOpptyProd == null || opptyLineItemList == null || productMap == null) {
            return null;
        }

        Map<Id, Opportunity> opptyToUpdateMap = opptyMap.deepClone();

        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();

        Map<String, List<OpportunityLineItem>> opptyolitmMap = new Map<String, List<OpportunityLineItem>>();
        Map<String, List<OpportunityLineItem>> OpptyToLineItemMap = new Map<String, List<OpportunityLineItem>>();
        for(OpportunityLineItem oli : opptyLineItemList) {

            String keyStr = oli.opportunityId + '-' + oli.PriceBookEntry.Product2Id;

            if(opptyolitmMap.get(keyStr) == null) {
                List<OpportunityLineItem> tempList = new List<OpportunityLineItem>();
                tempList.add(oli);

                opptyolitmMap.put(keyStr, tempList);
            } else {
                opptyolitmMap.get(keyStr).add(oli);
            }

            if(OpptyToLineItemMap.get(oli.opportunityId) == null) {
                List<OpportunityLineItem> tempList = new List<OpportunityLineItem>();
                tempList.add(oli);

                OpptyToLineItemMap.put(oli.opportunityId, tempList);
            } else {
                OpptyToLineItemMap.get(oli.opportunityId).add(oli);
            }
        }
        
        for(Opportunity o : opptyToUpdateMap.values()) {
            //include LOT functionality for Channel recordtypes. 
            /*** CR 9337 Starts **/
        //    if(o.RecordTypeId == '012A0000000VjtgIAC'){         
        //      continue;           
        //    }
            /*** CR 9337 Ends **/
            List<OpportunityLineItem> majorList = new List<OpportunityLineItem>();
            Boolean oldOEFlg = o.Eligible_for_Ocean__c == 'Yes' ? true : false;

            Boolean newOEFlg = false;
            //Boolean isOCEANEligible = false;

            Double maxWeek = 0;
            Double totalPotentialCostSaving = 0;
            //Populating new values from trigger
            if(newOpptyMap != null) {
                o.Primary_Product_Delivery_Address_Country__c = newOpptyMap.get(o.Id).Primary_Product_Delivery_Address_Country__c;
                o.Primary_Product_Delivery_Address_Region__c = newOpptyMap.get(o.Id).Primary_Product_Delivery_Address_Region__c;
                o.Customer_Requested_Delivery_Date__c =  newOpptyMap.get(o.Id).Customer_Requested_Delivery_Date__c;
                o.CloseDate  =  newOpptyMap.get(o.Id).CloseDate;
                o.Confirmed_for_Ocean_by_Finance_Gbl_Ops__c = newOpptyMap.get(o.Id).Confirmed_for_Ocean_by_Finance_Gbl_Ops__c;
                o.Is_CFI_included__c = newOpptyMap.get(o.Id).Is_CFI_included__c;
                //This field is no longer used - CR 4109 o.CFS_Special_Packaging__c = newOpptyMap.get(o.Id).CFS_Special_Packaging__c;
                o.Additional_vol_to_team_Quarterly__c = newOpptyMap.get(o.Id).Additional_vol_to_team_Quarterly__c;
                o.Adjustment_weeks__c = newOpptyMap.get(o.Id).Adjustment_weeks__c;
                o.Ocean_Opportunity_Notification_Pop_Up__c = newOpptyMap.get(o.Id).Ocean_Opportunity_Notification_Pop_Up__c;
                o.LOT_OCEAN_Email_Notification__c = newOpptyMap.get(o.Id).LOT_OCEAN_Email_Notification__c;
                o.Must_Arrive_By_Date__c = newOpptyMap.get(o.Id).Must_Arrive_By_Date__c;
                o.Do_you_want_to_pursue_Ocean__c = newOpptyMap.get(o.Id).Do_you_want_to_pursue_Ocean__c;
                o.Ocean_Type__c = newOpptyMap.get(o.Id).Ocean_Type__c;
            }

            o.Error_Description__c = '';

            if(o.Account.Sales_Channel__r.Segment_Business_Unit_Name__c == null) {
                o.Error_Description__c = System.today().format() + ' - ' + 'Sales Channel\'s \"Segment Business Unit Name\" is empty.';

                newOEFlg = false;
                resetOpptyAndLineItems(o, OpptyToLineItemMap, oliToUpdate);

                continue;
            }

            String country = StringUtils.defaultString(o.Primary_Product_Delivery_Address_Country__c).toUpperCase();

            String region  = StringUtils.defaultString(o.Primary_Product_Delivery_Address_Region__c).toUpperCase();

            String segment = o.Account.Sales_Channel__r.Segment_Business_Unit_Name__c.toUpperCase();
            Boolean isOceanTypeConsolidated = false;
            Boolean isOceanMandatory = false;
            for(AggregateResult r : quantityByOpptyProd) {

                if((String)r.get('OpportunityId') != o.Id ) {
                   continue;
                }

                Double ttlQty = (Double)r.get('totalQty');
                Product2 currentProd = productMap.get((String)r.get('ProductId'));
  
                Double palletQuantity = currentProd.Pallet_Quantity__c;
                Double containerVolume = currentProd.Container_Volume__c;
                String keystr2 = o.Id + '-' + currentProd.Id;

                String source = currentProd.Source__c;
                if(source == null){
                    o.Error_Description__c = System.today().format() + ' - ' + 'Product Source is empty - ' + currentProd.Name;                     
                    resetOnlyLineItem(keystr2, opptyolitmMap, oliToUpdate);

                    continue;
                }

                String sourceCountry = (source.toUpperCase() + '-' + country.toUpperCase());
                String sourceRegion = (source.toUpperCase() + '-' + region.toUpperCase());

                //3.3
                Ocean_Data__c tempOD = null;
                if(oceanDataMap.get(sourceCountry) != null) {
                    tempOD = oceanDataMap.get(sourceCountry);
                } else {
                    tempOD = oceanDataMap.get(sourceRegion);
                }

                if(tempOD == null) {
                    o.Error_Description__c = System.today().format() + ' - ' + 'No Ocean Data for region - ' + sourceRegion;
                    resetOnlyLineItem(keystr2, opptyolitmMap, oliToUpdate);

                    continue;
                }

                Double shipRate = tempOD.Ship_rate__c;
                Double palletRate = tempOD.Pallet_Rate__c;

                //4.0
                Double containerModifier = tempOD.Container_Multiplier_Factor__c == null ? 1 : tempOD.Container_Multiplier_Factor__c;
                Double palletModifier = tempOD.Pallet_Multiplier_Factor__c == null ? 1 : tempOD.Pallet_Multiplier_Factor__c;

                Double modifiedContainerVol = containerVolume * containerModifier;
                Double modifiedPalletQty = palletQuantity * palletModifier;

                //3.2
                //Double deliveryLeadTime = tempOD.Lead_Time_in_Weeks__c;

                //3.2: skip if the following field is empty
                if(shipRate == null || palletRate == null
                        || currentProd.Standard_OE_to_SC__c == null
                        || tempOD.Days_in_country_Delivery__c == null
                        || tempOD.On_the_sea_by_ODM__c == null) {

                    o.Error_Description__c = System.today().format() + ' - ' + 'Unable to calculate lead time because Ship Rate, Pallet Rate, Standard OE to SC, Days in Country Delivery, On the Sea by ODM may be empty.';
                    resetOnlyLineItem(keystr2, opptyolitmMap, oliToUpdate);
                    continue;

                }

                //3.2: Calculates "On the sea and Land from ODM to Customer" time
                Double timeFromODMtoCustomer = (currentProd.Standard_OE_to_SC__c
                                                    + tempOD.Days_in_country_Delivery__c
                                                    + tempOD.On_the_sea_by_ODM__c)/7;

                //3.2: first set the delivery time to time needed from ODM to Customer
                Double deliveryLeadTime = timeFromODMtoCustomer;

                if(o.Is_CFI_included__c == 'YES' && tempOD.CFI_Delivery_Time_in_Weeks__c != null) {
                    deliveryLeadTime += tempOD.CFI_Delivery_Time_in_Weeks__c;
                }

                if(o.Additional_vol_to_team_Quarterly__c == 'YES' && tempOD.MSP_Incremental_in_Weeks__c != null) {
                    deliveryLeadTime += tempOD.MSP_Incremental_in_Weeks__c;
                }

                if(o.Adjustment_weeks__c != null) {
                    deliveryLeadTime += o.Adjustment_weeks__c;
                }

                if(deliveryLeadTime > maxWeek) {
                    maxWeek = deliveryLeadTime;
                }

                //4.0
                if(currentProd.Volume_to_Dollar_Ratio__c == null || !(ttlQty >= modifiedPalletQty  || ttlQty >= modifiedContainerVol )) {
                    resetOnlyLineItem(keystr2, opptyolitmMap, oliToUpdate);
                    continue;
                }

                Double ttlPotentialCostSavingCurrentProd = calcPotentialCostSavings(ttlQty, modifiedContainerVol, modifiedPalletQty, shipRate, palletRate, currentProd.Volume_to_Dollar_Ratio__c);
                totalPotentialCostSaving += ttlPotentialCostSavingCurrentProd;

                List<OpportunityLineItem> tempList = opptyolitmMap.get(keystr2);
                for(OpportunityLineItem tempOli : tempList) {

                    tempOli.Estimated_Delivery_Lead_Time_Week__c = deliveryLeadTime;
                    tempOli.On_the_Sea_and_Land_from_ODM_to_Customer__c = timeFromODMtoCustomer;

                    if (ttlQty >= modifiedContainerVol) {
                        tempOli.Ocean_Type__c = 'Container';
                    }
                    else {
                        tempOli.Ocean_Type__c = 'Consolidated';
                        isOceanTypeConsolidated = true;
                    }

                    tempOli.Potential_Cost_Savings_if_Ocean__c = ttlPotentialCostSavingCurrentProd * tempOli.Quantity / ttlQty;
                }
                newOEFlg = true;
                majorList.addAll(tempList);
                //Modified Code
                for(OpportunityLineItem oli:mapOLIRecords.get(o.Id)){
                    if((oli.Quote__c==null || oli.Customer_Requested_Date__c ==null) && oli.PriceBookEntry.Product2Id == currentProd.Id && (ttlQty >= modifiedPalletQty  || ttlQty >= modifiedContainerVol )){
                            isOceanMandatory = true;
                    }
                }         

            }
            
            o.Calculated_Delivery_in_Weeks__c = maxWeek == 0 ? null : maxWeek;
            if (o.Adjustment_Potential_Cost_Saving__c == null) {
                o.Adjustment_Potential_Cost_Saving__c = 0;
            }
            o.Potential_Cost_Savings_If_Ocean__c = totalPotentialCostSaving == 0 ? null : totalPotentialCostSaving + totalPotentialCostSaving*o.Adjustment_Potential_Cost_Saving__c/100;
            if(newOEFlg || oldOEFlg) {
                if(o.Customer_Requested_Delivery_Date__c != null && o.Calculated_Delivery_in_Weeks__c != null ) {
                    if((o.CloseDate.daysBetween(o.Customer_Requested_Delivery_Date__c)) < o.Calculated_Delivery_in_Weeks__c*7) {
                            newOEFlg = false;
                        if (o.Must_Arrive_By_Date__c){
                            o.Do_you_want_to_pursue_Ocean__c = 'No';
                        }
                    }
                }
            }

            System.Debug('newOpptyMap.get(o.Id).StageName##'+newOpptyMap.get(o.Id).StageName);
            System.Debug('Probability##'+newOpptyMap.get(o.Id).Probability);
            
            if(newOpptyMap.get(o.Id).StageName == propose || newOpptyMap.get(o.Id).StageName == order_submitted ||  newOpptyMap.get(o.Id).StageName == comit || newOpptyMap.get(o.Id).StageName == win || (newOpptyMap.get(o.Id).StageName == qualify && newOpptyMap.get(o.Id).Probability >= 60)){
                if(newOEFlg ) {
                    o.Eligible_for_Ocean__c = 'Yes';
                    if (isOceanTypeConsolidated) {
                        o.Ocean_Type__c = 'Consolidated';
                    }
                    else {
                        o.Ocean_Type__c = 'Container';
                    }
                } else {
                    o.Eligible_for_Ocean__c = 'No';
                }
            }
            else{
                o.Eligible_for_Ocean__c = 'No';
                o.Do_you_want_to_pursue_Ocean__c = 'No';
            }
            System.Debug('o.Eligible_for_Ocean__c##'+o.Eligible_for_Ocean__c);
            System.Debug('o.Do_you_want_to_pursue_Ocean__c##'+o.Do_you_want_to_pursue_Ocean__c);
            System.Debug('Stage##'+newOpptyMap.get(o.Id).StageName);
            System.Debug('GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION##'+GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION);
            System.Debug('o.Ocean_Opportunity_Notification_Pop_Up__c###'+o.Ocean_Opportunity_Notification_Pop_Up__c);
            
            if(!(newOEflg && oldOEFlg && GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION) && !(!newOEFlg && !oldOEFlg) && (newOpptyMap.get(o.Id).StageName == propose || newOpptyMap.get(o.Id).StageName == order_submitted || newOpptyMap.get(o.Id).StageName == comit || newOpptyMap.get(o.Id).StageName == win || (newOpptyMap.get(o.Id).StageName == qualify && newOpptyMap.get(o.Id).Probability >= 60)) && isOceanMandatory) {
                o.Ocean_Opportunity_Notification_Pop_Up__c = true;
            }
            else{
                o.Ocean_Opportunity_Notification_Pop_Up__c = false;
            }
            
            System.Debug('o.Ocean_Opportunity_Notification_Pop_Up__c###'+o.Ocean_Opportunity_Notification_Pop_Up__c);
            

            if((o.Eligible_for_Ocean__c == 'Yes' || newOEFlg) && (newOpptyMap.get(o.Id).StageName == propose || newOpptyMap.get(o.Id).StageName == order_submitted || newOpptyMap.get(o.Id).StageName == comit || newOpptyMap.get(o.Id).StageName == win || (newOpptyMap.get(o.Id).StageName == qualify && newOpptyMap.get(o.Id).Probability >= 60))) {

                String tempEmail = getNotificationTargetEmail(segment, country, region);

                System.debug('###DEBUG### OCEAN Email = ' + tempEmail  + ' - Country = ' + country + ' segment = ' + segment + ' - region = ' + region);

                if(tempEmail == null) {
                    o.Error_Description__c = System.today().format() + ' - ' + 'Unable to retrieve email.';
                } else {
                    o.LOT_OCEAN_Email_Notification__c = tempEmail;
                }
            }
        
            if(oliToUpdate.size() + majorList.size() > 10000) {
                oliToUpdate.addAll(majorList);
                GlobalVariables.BYPASS_LOT_OCEAN_CALCULATION = true;
                
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
                update oliToUpdate;
                GlobalVariables.BYPASS_LOT_OCEAN_CALCULATION = false;
                
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                oliToUpdate.clear();
            }
            else {
                oliToUpdate.addAll(majorList);
            }
        }
        
        GlobalVariables.BYPASS_LOT_OCEAN_CALCULATION = true;
        
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        GlobalVariables.BYPASS_LOT_OCEAN_CALCULATION = false;
        
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        return opptyToUpdateMap.values();
        }

    public void resetOpptyAndLineItems(Opportunity o, Map<String, List<OpportunityLineItem>> opptyLineItemMap, List<OpportunityLineItem> opptyToUpdateList) 
    {
        
        if(o.Eligible_for_Ocean__c == 'Yes') {
            o.Ocean_Opportunity_Notification_Pop_Up__c = true;
        }
        o.Calculated_Delivery_in_Weeks__c = null;
        o.Potential_Cost_Savings_If_Ocean__c = null;

        List<OpportunityLineItem> tempList = opptyLineItemMap.get(o.Id);

        if(tempList != null) {
            for(OpportunityLineItem tempOli : tempList) {
                tempOli.Estimated_Delivery_Lead_Time_Week__c = null;
                tempOli.Potential_Cost_Savings_if_Ocean__c = null;
                tempOli.On_the_Sea_and_Land_from_ODM_to_Customer__c = null;   //3.2
            }

            opptyToUpdateList.addAll(tempList);
        }

    }

    public void resetOnlyLineItem(String keyStr, Map<String, List<OpportunityLineItem>> opptyLineItemMap, List<OpportunityLineItem> opptyToUpdateList) {

        List<OpportunityLineItem> tempList = opptyLineItemMap.get(keyStr);

        if(tempList != null) {
            for(OpportunityLineItem tempOli : tempList) {
                tempOli.Estimated_Delivery_Lead_Time_Week__c = null;
                tempOli.Potential_Cost_Savings_if_Ocean__c = null;
                tempOli.On_the_Sea_and_Land_from_ODM_to_Customer__c = null;  //3.2
            }

            opptyToUpdateList.addAll(tempList);
        }
    }

    private List<OpportunityLineItem> getOpptyLineItemList(Set<String> opptyIdSet) {

        //3.2: added On_the_Sea_and_Land_from_ODM_to_Customer__c
        List<OpportunityLineItem> oliList = [SELECT On_the_Sea_and_Land_from_ODM_to_Customer__c, PriceBookEntry.Product2Id, PriceBookEntry.Product2.Volume_to_Dollar_Ratio__c, OpportunityId, Quantity, Estimated_Delivery_Lead_Time_Week__c, Potential_Cost_Savings_if_Ocean__c
                                                FROM OpportunityLineItem WHERE OpportunityId IN :opptyIdSet];
        return oliList;
    }

    private Double calcPotentialCostSavings(Decimal quantity, Decimal containerVolume, Double palletSize, Double shipRate, Double palletRate, Decimal volumeToDollarRatio)
    {
        Integer noOfContainer = (quantity/containerVolume).intValue();
        Double containerQty = noOfContainer*containerVolume;
        Integer noOfPallet = ((quantity - containerQty)/palletSize).intValue();
        Double palletQty = noOfPallet*palletSize;
        Double remainingQty = quantity - containerQty - palletQty;
        return (shipRate*containerQty + palletRate*palletQty + palletRate*0.5*remainingQty) * volumeToDollarRatio;
    }
    
    public Map<Id,List<OpportunityLineItem>> queryLineItems(Set<String> idSet){
        Map<Id,List<OpportunityLineItem>> mapOliProducts = new Map<Id,List<OpportunityLineItem>>();
        for(OpportunityLineItem opp:[Select Id,LOT_Indicator__c,Customer_Requested_Date__c,Ocean_Indicator__c,Quote__c,PriceBookEntry.Product2Id,OpportunityId from OpportunityLineItem Where OpportunityId =:idSet]){
            if(!mapOliProducts.containsKey(opp.OpportunityId)){
                List<OpportunityLineItem> lstTemp = new List<OpportunityLineItem>();
                lstTemp.add(opp);
                mapOliProducts.put(opp.OpportunityId,lstTemp);
            }
            else{
                List<OpportunityLineItem> lstTemp = new List<OpportunityLineItem>();
                lstTemp.addAll(mapOliProducts.get(opp.OpportunityId));
                lstTemp.add(opp);
                mapOliProducts.put(opp.OpportunityId,lstTemp);
            }
        }
        return mapOliProducts;
    }
 }
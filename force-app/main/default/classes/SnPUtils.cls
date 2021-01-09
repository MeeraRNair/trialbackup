/***********************************************************
* Name          : SnPUtils 
* Description   : All methods for S&P Vendor record creation and update.
* ---------------------------------------------------------------------------------
* Revision      Release Name        Date            Description
* 1.0           11.10   MenMee      09.08.2010      CR2688 Migrate Dell Portal functionality to SFDC to capture Software and Peripherals deals         
* 1.1           11.10   MenMee      18.10.2010      Defect65018 Null Pointer exception while adding a product to a deal ()
* 1.2           11.10   MenMee      22.10.2010      CR5428 Based on Opp. Prod Brand Desc hidden field look for existing vendor to update
* 1.3           11.10   MenMee      09.11.2010      Defect65946 Currency code in Net Amount field in Vendor page is displaying incorrect currency code
* 1.4           11.10   MenMee      29.11.2010      use escapeSingleQuotes in Database.Query to handle SQL injection
* 1.5           11.10   MenMee      09.12.2010      solve issue referencing to null value.
* 2.0           12.1    MenMee      24.11.2010      CR5540 Handle for multicurrencies
* 2.1           12.1    MenMee      24.11.2010      Enhancement
* 2.2           12.1    MenMee      24.11.2010      Change recalculation logic
* 2.3           12.1    MenMee      16.12.2010      CR4444 Addition of Distributor field in S&P DR Criteria object
* 2.4           12.1    MenMee      12.01.2011      Create RT for Criteria object. Distributor field will based on RT.
* 2.5           12.1    MenMee      29.01.2011      Defect67600 Cater for case sensitive of vendor name
* 2.6           12.1    Ray         07.01.2011      Convert Custom Setting name to lower case before adding to map
* 2.7           12.7    Nooryati    13.06.2011      CR6253 - Expiration date email notification
* 3.1           12.7    MenMee      22.07.2011      Defect71565 1) include brand desc into criteria filter
* 4.0           13.7    Patrick     19.06.2012      CR7114 - determine the value of Automated field for S&P Vendor before inserting
* 4.1           14.5    Patrick     10.04.2013      Auto-populate Region field during creation of SV record based on Primary Product Delivery Address Region
* 4.2           14.10   Patrick     04.16.2013      Auto-populate SV Record's Shipping Address components
* 4.3                   Emily       12.11.2013      CR8914 - SAR-8017 SonicWall - Dell Main integration Error
* 5.0   FY18-DCS-1001   Jessie      15.08.2017      CR14654 - Story 3382308:VMware Next Gen CR-00140306: Product Additions
* 6.0   FY19-DCS-0802   Swathi      29/06/2018      Defect - 5199627 to control not to overwritten distributor name 
* 6.1   FY19 DCS-0102   Swathi      15/11/2018      CR 16821 - Not to update Distributor Name field once record is created.
* 6.3   FY20 DCS-0202   Swathi      06/12/2018      Tech debt story to remove soql from loop.
*****************************************************************************************************************************************************/

public class SnPUtils {
    
    //Opp Id => Prod Line Desc => Opp Prod Details
    private static Map<String, Map<String, pProductLine>> oppIdToProdLineListMap = new Map<String, Map<String, pProductLine>>();
    //Rev 2.2
    //Opp Id => Vendor Record Type Id => vVendor Details    
    private static Map<String, Map<String, vVendor>> oppIdToVendorNameToVendorMap = new  Map<String, Map<String, vVendor>>();
    //Rev 2.0
    //Key(Region:Country:ProdLineDesc:Segment) => Key(Currency) => Criteria Details 
    private static Map<String, Map<String, S_P_DR_Criteria__c>> regCtryLineSegmentCurrToCriteriaMap = new Map<String, Map<String, S_P_DR_Criteria__c>>();
    private static Map<String, Opportunity> oppIdToOppMap = new Map<String, Opportunity>();
    private static Map<String, String> vendorNameToRecTypeIdMap = new Map<String, String>();
    private static String oliWhereClause = null;
    private static String criteriaWhereClause = null;   
    private static boolean isPrimary = false;   
    
    private static final String S_P_REGISTERABLE_YES = 'TRUE';  
    private static final String PRIMARY_RECORD = 'Primary';
    private static final String QUALIFIED_YES = 'Yes';
    private static final String QUALIFIED_NO = 'No';
    private static final String DEAL_STATUS_PENDING = 'Pending';
    private static final String VENDOR_STD_RECORDTYPE_ID = '012A0000000VMfl';
    public static boolean skipSnPRecalculate = false;
    public enum TriggerType {ISINSERT,ISUPDATE,ISDELETE, NOTTRIGGER}
    
    public class oOppLineItem {
        public OpportunityLineItem oli {get; set;}
        public TriggerType triggerType {get; set;}

        public oOppLineItem(OpportunityLineItem o, TriggerType tt) {
            oli = o;            
            triggerType = tt;
        }
    }

    public class pProductLine {
        public decimal totalNET {get; set;}     
        public decimal totalOldNET {get; set;}
        public decimal totalQuantity {get; set;}        
        public List<oOppLineItem> oOliList {get; set;}
        
        public pProductLine(decimal qty, decimal net, decimal oldNet, oOppLineItem oO) {            
            totalNET = net;         
            totalOldNET = oldNet;
            totalQuantity = qty;        
                    
            if (oOliList == null) oOliList = new List<oOppLineItem>();
            oOliLIst.add(oO);
        }
    }
    
    //Rev 2.2
    public class vVendor {
        public decimal totalNet {get; set;}
        public S_P_Vendors__c vdr {get; set;}
        
        public vVendor(S_P_Vendors__c v, decimal net) {
            totalNet = net;
            vdr = v;
        }           
    }
    //Rev 2.2-end
    
    /*
    This revision history is only applicable to the below initiateSnPCalculations()
    
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR2688      11.10       09.08.2010      MenMee          Migrate Dell Portal functionality to SFDC to capture Software and Peripherals deals       
    2.0         CR6253      12.7        25.07.2011      MenMee          Don't exclude opp prod that don't have change on margin, unit price and qty
    3.0         CR10496     15.10       21-Sep-2014     Ragu            This logic is separated from opptyLineItemBeforeInsertUpdateDeleteTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void initiateSnPCalculations(SnPUtils.TriggerType trigType, list<OpportunityLineItem> lstLineItems, map<Id, OpportunityLineItem> mapOldLineItems) {
        String excludeOliWhereClause = '';
        list<OpportunityLineItem> lstLineItemsToProcess = new list<OpportunityLineItem>();
        for(OpportunityLineItem oliIterator : lstLineItems) {
            if(StringUtils.equalsIgnoreCase(oliIterator.S_P_Registerable__c, 'true')) { 
                if(trigType == SnPUtils.TriggerType.ISINSERT) {      
                    lstLineItemsToProcess.add(oliIterator);
                }
                else {
                    OpportunityLineItem oldLineItem;
                    if(trigType == SnPUtils.TriggerType.ISUPDATE) {
                        oldLineItem = mapOldLineItems.get(oliIterator.Id);
                    }
                    if(trigType == SnPUtils.TriggerType.ISDELETE || (oldLineItem != null && (oliIterator.Quantity != oldLineItem.Quantity || oliIterator.Mrgn__c != oldLineItem.Mrgn__c || oliIterator.UnitPrice != oldLineItem.UnitPrice))) {
                        lstLineItemsToProcess.add(oliIterator);
                        
                        if(excludeOliWhereClause.length() > 0) {
                            excludeOliWhereClause += '\', \'';
                        }
                        excludeOliWhereClause += oliIterator.Id;
                    }
                }
            }
        }
        if(lstLineItemsToProcess.size() > 0) {
            try {
                SnPUtils.calculateQualifiedSnPDRProg(lstLineItemsToProcess, excludeOliWhereClause, trigType);
            }
            catch(Exception e) {
                System.debug('Exception Caught in initiateSnPCalculations() : ' + e.getMessage());
                throw e;
            }
        }
    }   
        
    //Call from Refresh button
    public static void recalculateQualifiedSnPDRProg(Opportunity opp) {
        oppIdToOppMap = new Map<String, Opportunity>();
        
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, Description, Quantity, NET__c, UnitPrice, Mrgn__c,  Product_Line_Desc__c, Brand_Desc__c,
                                                S_P_Registerable__c, S_P_Deal_Status__c, Qualified_for_S_P_Deal_Reg_Program__c 
                                             FROM OpportunityLineItem
                                             WHERE OpportunityId =:opp.Id AND S_P_Registerable__c = 'TRUE'];
                        
        if (oliList.size() > 0) { //Rev 2.1
            oppIdToOppMap.put(opp.Id, opp);
        
            calculateQualifiedSnPDRProg(oliList, '', TriggerType.NOTTRIGGER);
        }           
    }
    
    public static void calculateQualifiedSnPDRProg(List<OpportunityLineItem> oliList, String excludeOliWhereClause, TriggerType tt) {
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
        
        if (skipSnPRecalculate) return;
        
        //Prepare Data Set for new insert/new update
        prepareDataSet(oliList, excludeOliWhereClause, tt);
                
        //Compare with criteria
        if(oppIdToProdLineListMap.size() > 0) checkCriteriaAndVendor(oppIdToOppMap, oppIdToProdLineListMap, regCtryLineSegmentCurrToCriteriaMap, tt);
        
        clearAll();     
        
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
    }
    
    private static void prepareDataSet(List<OpportunityLineItem> oliList, String excludeOliWhereClause, TriggerType tt) {
        String queryString;     
        String vdrName; //Rev 2.5
        Map<String, Product2> prodIdToProdMap = new Map<String, Product2>();        
    
        //1. Filter non-SnP Opp Prod, only add SnP Opp Prod to oppIdToProdLineListMap
        setOliToMap(oliList, tt);   
                
        //Exit if no SnP Opp Prod   
        if (oppIdToProdLineListMap.size() == 0) return;
                        
        //2. Query Opp details
        if (tt != TriggerType.NOTTRIGGER) {
            for(Opportunity opp : [SELECT Id, CloseDate, CreatedDate, CurrencyIsoCode, Primary_Product_Delivery_Address_Region__c, 
                                        Primary_Product_Delivery_Address_Country__c, Account.Segment_Name_lookup__c,
                                        Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingCountry,
                                        Account.ShippingPostalCode
                                   FROM Opportunity WHERE Id IN :oppIdToProdLineListMap.keySet()]){
                oppIdToOppMap.put(opp.Id, opp);
            }
        }
        
        //3 .Get Record Type Id of vendor from custom settings
        List<SnP_Vendor_RecordType__c> vendorRecordTypeList = SnP_Vendor_RecordType__c.getAll().values();
        for(SnP_Vendor_RecordType__c  vrt: vendorRecordTypeList) {
            vdrName = StringUtils.lowerCase(vrt.Name);
            vendorNameToRecTypeIdMap.put(StringUtils.lowerCase(vrt.Name), vrt.Record_Type_ID__c);  //2.6 convert to lowercase        
        }       
                                
        //Rev 2.3
        //Rev 2.7
        //Rev 4.3
        //4. Query Vendor details
        for(S_P_Vendors__c vendor : [SELECT Id, name, S_P_Vendors_name__c, S_P_Vendors_Name_Hidden__c, Opportunity__r.Id, RecordTypeId, Qualified_for_S_P_Deal_Reg_Program__c, 
                                        S_P_Deal_Status__c, Product_Line_Desc__c, Qualified_Product_Line_Desc__c, Missing_Segment__c, Special_instructions__c, 
                                        PM1__c, PM2__c, PM3__c, PM4__c, PM5__c, Total_NET__c, Distributor_Name__c, Renewal_Instruction_to_Sales_Rep__c 
                                     FROM S_P_Vendors__c
                                     WHERE Opportunity__c IN :oppIdToProdLineListMap.keySet()]){             
            vVendor vVdr = new vVendor(vendor, 0.0);
                
            //Rev 2.5
            vdrName = StringUtils.lowerCase(vendor.S_P_Vendors_Name_Hidden__c);
            //Rev 2.2
            if (oppIdToVendorNameToVendorMap.get(vendor.Opportunity__r.Id) == null) {               
                oppIdToVendorNameToVendorMap.put(vendor.Opportunity__r.Id, new Map<String, vVendor> {vdrName => vVdr});
            }
            else {
                if (oppIdToVendorNameToVendorMap.get(vendor.Opportunity__r.Id).get(vdrName) == null) {                  
                    oppIdToVendorNameToVendorMap.get(vendor.Opportunity__r.Id).put(vdrName, vVdr);
                }               
                
                else {
                    oppIdToVendorNameToVendorMap.get(vendor.Opportunity__r.Id).get(vdrName).vdr = vendor;
                }               
            }
            //Rev 2.5-end
            
            //Select other existing Prod Line Desc that tied to this vendor, to recalculate the total amount 
            String [] plList = StringUtils.split(StringUtils.subString(vendor.Product_Line_Desc__c, 1, StringUtils.length(vendor.Product_Line_Desc__c)-1), ';;');           
            System.debug('plList: '+plList);
            //Rev 2.2 if (tt == TriggerType.ISDELETE &&  plList != null) {          
            if (plList != null) {               
                for (String pl : plList) {                  
                    //Rev 2.5, Rev 3.1
                    string pld = vdrName + ':' + StringUtils.lowerCase(pl);
                    if (oppIdToProdLineListMap.get(vendor.Opportunity__r.Id).get(pld) == null)
                        oppIdToProdLineListMap.get(vendor.Opportunity__r.Id).put(pld, null);
                }
            }                               
        }
        System.debug('oppIdToVendorNameToVendorMap: '+oppIdToVendorNameToVendorMap);
        
        //5. Generate where clause to select existing records
        generateWhereClause(oppIdToProdLineListMap, oppIdToOppMap);     
                
        //6. Query existing Opp Prod and add existing Opp Prod to oppIdToProdLineListMap
        if (tt != TriggerType.NOTTRIGGER) {     
                                                
            queryString ='SELECT Id, OpportunityId, Description, Quantity, NET__c, UnitPrice, Mrgn__c,  Product_Line_Desc__c, Brand_Desc__c, '+
                                         'S_P_Registerable__c, S_P_Deal_Status__c, Qualified_for_S_P_Deal_Reg_Program__c '+
                                     'FROM OpportunityLineItem '+
                                     (StringUtils.isNotBlank(oliWhereClause)? 'WHERE ' + oliWhereClause +
                                     (StringUtils.isNotBlank(excludeOliWhereClause)? ' AND Id NOT IN (\'' + excludeOliWhereClause + '\')':'') : '');
                                     
            System.debug('Existing OLI Query: '+ queryString);          
            List<OpportunityLineItem> existingOliList = Database.query(queryString);            
            //Rev 2.1                                        
            if (existingOliList!= null && existingOliList.size() > 0) setOliToMap(existingOliList, TriggerType.NOTTRIGGER);
        }
        
        //Rev 2.4
        //Rev 2.3
        //Rev 2.7
        //6. Set criteria to regCtryLineSegmentCurrToCriteriaMap
        queryString = 'Select Id, Name, Country_Name__c, Region__c, Segment__c, Segment_Required__c, Primary_Record__c, '+
                        'Min_Qty__c, Min_days_before_Book_Date__c, Min_NET__c, Special_instructions__c, CurrencyIsoCode, ' +
                        'Product_Line_Desc__c, Brand_Desc__c,  PM1__c, PM2__c, PM3__c, PM4__c, PM5__c, '+
                        'Distributor_Name__c, Distributor_Name_Region__c, RecordTypeId, Renewal_Instruction_to_Sales_Rep__c '+ 
                      'From S_P_DR_Criteria__c '+
                      (StringUtils.isNotBlank(criteriaWhereClause)? 'WHERE ' + criteriaWhereClause : '');
        
        System.debug('Criteria query: '+queryString);                     
        List<S_P_DR_Criteria__c> criteriaList = Database.query(queryString);            
        //Rev 2.1
        if (criteriaList !=  null && criteriaList.size() > 0) setCriteriaToMap(criteriaList);                                                       
    }
    
    private static void setOliToMap(List<OpportunityLineItem> oliList, TriggerType tt) {
        pProductLine pProd = null;  
        vVendor vVdr = null;    
                
        for(OpportunityLineItem oli : oliList) {

            Double calcNet = 0.0;
            Double oldNet = 0.0;
            Double mrgn = 0.0; //Rev 1.1
            string vdrName = ''; //Rev 2.5
            string prdLineDesc = ''; //Rev 2.5
                            
            if (oli.S_P_Registerable__c == S_P_REGISTERABLE_YES) {
                //Rev 1.1
                mrgn = (oli.Mrgn__c == null? 0.0: oli.Mrgn__c);
                
                //Rev 1.5
                Double totalPrice = (oli.Quantity == null? 0.0:oli.Quantity) * (oli.UnitPrice == null? 0.0:oli.UnitPrice);
                calcNet = totalPrice - (totalPrice * mrgn / 100);               
                oldNet = (oli.Net__c == null? 0.0:oli.NET__c);
                
                //Rev 2.5, Rev 3.1 
                prdLineDesc = StringUtils.lowerCase(oli.Brand_Desc__c + ':' + oli.Product_Line_Desc__c);
                
                System.debug('## Data: ('+ oli.Quantity + ' * ' + oli.UnitPrice + ') - ' + mrgn + ' = ' + calcNet);
                
                if (tt == TriggerType.ISDELETE) {
                    pProd = new pProductLine(0.0, 0.0, oldNet, new oOppLineItem(oli, tt));
                }
                else {          
                    vVdr = new vVendor(null, calcNet);  //Rev 2.2
                    pProd = new pProductLine(oli.Quantity, calcNet, oldNet, new oOppLineItem(oli, tt));
                }       
            
                if (oppIdToProdLineListMap.get(oli.OpportunityId) == null) {                                
                    oppIdToProdLineListMap.put(oli.OpportunityId, new Map<String, pProductLine> {prdLineDesc => pProd});                
                }
                else {
                    if (oppIdToProdLineListMap.get(oli.OpportunityId).get(prdLineDesc) == null) {                       
                        oppIdToProdLineListMap.get(oli.OpportunityId).put(prdLineDesc, pProd);
                    }
                    else {
                        //Rev 2.2
                        //if (tt == TriggerType.ISDELETE) {
                        //  oppIdToProdLineListMap.get(oli.OpportunityId).get(oli.Product_Line_Desc__c).totalQuantity += -oli.Quantity;
                        //  oppIdToProdLineListMap.get(oli.OpportunityId).get(oli.Product_Line_Desc__c).totalNET += -calcNet;
                        //  oppIdToProdLineListMap.get(oli.OpportunityId).get(oli.Product_Line_Desc__c).totalOldNET += oldNet;  
                        //}
                        //else {
                        if (tt != TriggerType.ISDELETE) {
                            oppIdToProdLineListMap.get(oli.OpportunityId).get(prdLineDesc).totalQuantity += oli.Quantity;
                            oppIdToProdLineListMap.get(oli.OpportunityId).get(prdLineDesc).totalNET += calcNet;
                        //  oppIdToProdLineListMap.get(oli.OpportunityId).get(oli.Product_Line_Desc__c).totalOldNET += oldNet;                                                                  
                        }
                        oppIdToProdLineListMap.get(oli.OpportunityId).get(prdLineDesc).oOliList.add(new oOppLineItem(oli, tt));
                    }
                }   
                                
                vdrName = StringUtils.lowerCase(oli.Brand_Desc__c);
                //Rev 2.2
                if (oppIdToVendorNameToVendorMap.get(oli.OpportunityId) == null) {
                    oppIdToVendorNameToVendorMap.put(oli.OpportunityId, new Map<String, vVendor> {vdrName => vVdr});
                }
                else {
                    if (oppIdToVendorNameToVendorMap.get(oli.OpportunityId).get(vdrName) == null) {
                        oppIdToVendorNameToVendorMap.get(oli.OpportunityId).put(vdrName, vVdr);
                    }
                    else {
                        if (tt != TriggerType.ISDELETE) {
                            oppIdToVendorNameToVendorMap.get(oli.OpportunityId).get(vdrName).totalNet += calcNet;
                        }
                    }
                }
                //Rev 2.2-end
                //Rev 2.5-end
            }
        }
        System.debug('oppIdToProdLineListMap: '+ oppIdToProdLineListMap);
    }

    private static void setCriteriaToMap(List<S_P_DR_Criteria__c> criteriaList) {
        string key = null;
        string[] segmentKey = null;
            
        for (S_P_DR_Criteria__c cl : criteriaList) {
            
            //Rev 3.1
            key = cl.Region__c + ':' + cl.Country_Name__c + ':' + cl.Brand_Desc__c + ':' + cl.Product_Line_Desc__c;
            
            if (cl.Segment_Required__c && cl.Segment__c != null) { 
                segmentKey = StringUtils.split(cl.Segment__c , ';');
            
                for(string sKey : segmentKey) {
                    //Rev 2.0
                    if (!regCtryLineSegmentCurrToCriteriaMap.containsKey(StringUtils.lowerCase(key + ':' + sKey))) {
                        regCtryLineSegmentCurrToCriteriaMap.put(StringUtils.lowerCase(key + ':' + sKey), new Map <string, S_P_DR_Criteria__c> {cl.CurrencyIsoCode => cl});                  
                    }   
                    else {
                        regCtryLineSegmentCurrToCriteriaMap.get(StringUtils.lowerCase(key + ':' + sKey)).put(cl.CurrencyIsoCode, cl);
                    }       
                    //Rev 2.0-end
                }
            }
            
            if (cl.Primary_Record__c) {                 
                //Rev 2.0
                //if (regCtryLineSegmentCurrToCriteriaMap.get(StringUtils.lowerCase(key + ':' + PRIMARY_RECORD)) == null) regCtryLineSegmentCurrToCriteriaMap.put(StringUtils.lowerCase(key + ':' + PRIMARY_RECORD), cl);
                if (!regCtryLineSegmentCurrToCriteriaMap.containsKey(StringUtils.lowerCase(key + ':' + PRIMARY_RECORD))) {
                    regCtryLineSegmentCurrToCriteriaMap.put(StringUtils.lowerCase(key + ':' + PRIMARY_RECORD), new Map <string, S_P_DR_Criteria__c> {cl.CurrencyIsoCode => cl});                    
                }   
                else {
                    regCtryLineSegmentCurrToCriteriaMap.get(StringUtils.lowerCase(key + ':' + PRIMARY_RECORD)).put(cl.CurrencyIsoCode, cl);
                }
                //Rev 2.0-end
            }
                        
        }
        System.debug('regCtryLineSegmentCurrToCriteriaMap: '+regCtryLineSegmentCurrToCriteriaMap);
    }   
    
    private static void generateWhereClause(Map<String, Map<String, pProductLine>> oppIdToProdLineList, Map<String, Opportunity> oppIdToOpp) {
        
        if (oppIdToProdLineListMap.size() <= 0) return ;
        
        oliWhereClause = '';
        criteriaWhereClause = '';      
        String oppIdNprodLineDescClause = '';
        String regCtryProdLineDescClause = '';
        
        //Example Opportunity Prod: 
        //'((OpportunityId = \'006R0000006DtRv\' AND Product_Line_Desc__c IN (\'Acrobat\', \'Creative Suites\'))) AND S_P_Registerable__c = \'TRUE\'
        
        //Example Criteria: 
        //((Region__c = \'APJ\' 
        //AND (Country_Name__c = \'MALAYSIA\' OR Country_Name__c = \'null\') 
        //AND Product_Line_Desc__c IN (\'Acrobat\',\'Creative Suites\') 
        //AND (Segment__c includes (\'BSD\', \'FED') OR Primary_Record__c = TRUE) 
        //AND (CurrencyISOCode = \'USD\' OR Primary_Record__c = TRUE)))
        
        //Rev 1.4
        for (String oppId :  oppIdToProdLineList.keySet()) {
            String prodLineDescClause = '';
            String region = '';
            String country = '';
            
            try{     
                if(String.escapeSingleQuotes(StringUtils.defaultString(oppIdToOppMap.get(oppId).Primary_Product_Delivery_Address_Region__c)) != '')
                    region = String.escapeSingleQuotes(StringUtils.defaultString(oppIdToOppMap.get(oppId).Primary_Product_Delivery_Address_Region__c));
                if(String.escapeSingleQuotes(StringUtils.defaultString(oppIdToOppMap.get(oppId).Primary_Product_Delivery_Address_Country__c)) != '')
                    country = String.escapeSingleQuotes(StringUtils.defaultString(oppIdToOppMap.get(oppId).Primary_Product_Delivery_Address_Country__c));
            } catch(NullPointerException npe){
            }
            
            //Opportunity Prod
            if (oppIdNprodLineDescClause.length() > 0) oppIdNprodLineDescClause += ' OR ';
            oppIdNprodLineDescClause += '(OpportunityId = \'' + String.escapeSingleQuotes(StringUtils.defaultString(oppId)) + '\' '; //Rev 3.1 AND (Product_Line_Desc__c IN (';
                        
            //Criteria
            if (regCtryProdLineDescClause.length() > 0) regCtryProdLineDescClause += ' OR ';
            regCtryProdLineDescClause += '(Region__c =\'' + region + '\' ' + 
                                         'AND (' +(StringUtils.isNotBlank(country)? 'Country_Name__c = \'' + country + '\' OR ':'') + 'Country_Name__c = \'\') ';
                                         //' AND Product_Line_Desc__c IN (';
                                                    
            for (String prodLineDesc : oppIdToProdLineListMap.get(oppId).keySet()) {                
                //Opportunity Prod & Criteria                
                string[] vdrProdLineDesc = StringUtils.split(prodLineDesc, ':');
                system.debug('## vdrProdLineDesc: '+vdrProdLineDesc);
                if (vdrProdLineDesc != null && vdrProdLineDesc.size() == 2) {
                    if (prodLineDescClause.length() > 0) prodLineDescClause += 'OR ';
                    prodLineDescClause += '(Brand_Desc__c = \'' + String.escapeSingleQuotes(StringUtils.defaultString(vdrProdLineDesc[0])) + '\' AND Product_Line_Desc__c = \'' + String.escapeSingleQuotes(StringUtils.defaultString(vdrProdLineDesc[1])) + '\') ';
                }            
            }      
                        
            if (prodLineDescClause.length() > 0) {
                //Opportunity Prod                                
                //oppIdNprodLineDescClause += prodLineDescClause + '))';
                oppIdNprodLineDescClause += 'AND (' + prodLineDescClause + ')';
                
                //Criteria
                //regCtryProdLineDescClause += prodLineDescClause + ') AND (' +            
                regCtryProdLineDescClause += 'AND (' + prodLineDescClause + ') ';          
                //Rev 2.1-end   
            }
            
            //Opportunity Prod
            oppIdNprodLineDescClause += ')';
            
            //Criteria
            //Rev 2.1
            //regCtryProdLineDescClause += prodLineDescClause + ') AND (Segment__c includes (\'' + oppIdToOppMap.get(oppId).Account.Segment_Name_lookup__c + '\') OR Primary_Record__c = TRUE)'+
            //                          'AND (CurrencyISOCode = \''+ oppIdToOppMap.get(oppId).currencyISOCode + '\' OR Primary_Record__c = TRUE))';            
            String segment = '';
            if(oppIdToOppMap.get(oppId).Account.Segment_Name_lookup__c != null)
                segment = oppIdToOppMap.get(oppId).Account.Segment_Name_lookup__c;
            regCtryProdLineDescClause += 'AND (' + (StringUtils.isNotBlank(segment)? 'Segment__c includes (\'' + String.escapeSingleQuotes(segment) + '\') OR ' : '') + 'Primary_Record__c = TRUE)'+
                                            ' AND (CurrencyISOCode = \''+ String.escapeSingleQuotes(StringUtils.defaultString(oppIdToOppMap.get(oppId).currencyISOCode)) + '\' OR Primary_Record__c = TRUE))';
           
        }
        
        if (oppIdNprodLineDescClause.length() > 0) oliWhereClause = '(' + oppIdNprodLineDescClause + ') AND S_P_Registerable__c = \'TRUE\'';
        
        if (regCtryProdLineDescClause.length() > 0) criteriaWhereClause = '(' + regCtryProdLineDescClause + ')'; 
    }
    
    //Parameters:
    //1. Opp details map
    //2. Opp Prod details map
    //3. Criteria details map 
    //4. Trigger Type
    private static void checkCriteriaAndVendor(Map<String, Opportunity> oppIdToOpp, Map<String, Map<String, pProductLine>> oppIdToProdLineList, Map<String, Map<String, S_P_DR_Criteria__c>> regCtryLineSegmentToCriteria, TriggerType tt) {        
        string regKey = null;
        string countryKey = null;       
        string segmentKey = null;   
        string currencyKey = null;  //Rev 2.0   
        string brandName = null;        
                        
        S_P_DR_Criteria__c criteria;        
        //Rev 3.1
        //Map<Id, S_P_Vendors__c> upsertVendorMap = new Map<Id, S_P_Vendors__c>();
        Map<String, S_P_Vendors__c> upsertVendorMap = new Map<String, S_P_Vendors__c>();
        //Rev 3.1-end
        List<S_P_Vendors__c> deleteVendorList = new List<S_P_Vendors__c>();
        List<OpportunityLineItem> updateOliList = new List<OpportunityLineItem>();
        
        // 4.0
        Map<String, Double> exchangeRateMap = new Map<String, Double>();
        List<S_P_Vendor_Automation__c> svAutoList = [SELECT Vendor_Name__c, Automation_Type__c, Is_Active__c 
                                                        FROM S_P_Vendor_Automation__c];
        Map<String, S_P_Vendor_Automation__c> svAutoMap = new Map<String, S_P_Vendor_Automation__c>();
        SnPDealRegistrationProcessSelector sps = new SnPDealRegistrationProcessSelector();
        
        //Rev 2.4
        //7. Get record type id of criteria
        //Id criteriaByCountryRecTypeId = IdLookupUtils.getRecordTypeId('Criteria by Country', 'S_P_DR_Criteria__c', true);   
        Id criteriaByCountryRecTypeId = StaticDataUtils.getRecordTypeIdByName('S_P_DR_Criteria__c', 'Criteria by Country');
         //4.0
        for(S_P_Vendor_Automation__c svAuto : svAutoList){
            svAutoMap.put(svAuto.Vendor_Name__c.toLowerCase().trim(), svAuto);
        }
        
        //* 6.3   FY20 DCS-0202   Swathi      06/12/2018      Tech debt story to remove soql from loop
            List<DatedConversionRate> listDatedConversionRate = [SELECT ConversionRate,Id,IsoCode,NextStartDate,StartDate 
                                                                       FROM DatedConversionRate where IsoCode != 'USD'];
        
        for (String oppId : oppIdToProdLineListMap.keySet())     {
            
            /************** Criteria Check *****************/
            System.debug('########## CRITERIA CHECK ##########');
            
            regKey = oppIdToOpp.get(oppId).Primary_Product_Delivery_Address_Region__c;
            countryKey = oppIdToOpp.get(oppId).Primary_Product_Delivery_Address_Country__c;     
            segmentKey = oppIdToOpp.get(oppId).Account.Segment_Name_lookup__c;                                  
            currencyKey = oppIdToOpp.get(oppId).CurrencyISOCode;
            
            integer dayDiff = oppIdToOpp.get(oppId).CreatedDate.date().daysBetween(oppIdToOpp.get(oppId).CloseDate);
            System.debug('dayDiff: '+ oppIdToOpp.get(oppId).CreatedDate.date() + ' - ' + oppIdToOpp.get(oppId).CloseDate + ' = '+ dayDiff);
            
            for(String prodLineDescKey : oppIdToProdLineListMap.get(oppId).KeySet()) {
                string isQualified = QUALIFIED_NO;
                string dealStatus = null;                
                string distributor = '';    //Rev 2.4
                String vendorProdLine = '';         //Rev 3.1
                boolean isMissingSegment = false;
                boolean skipCriteriaCheck = false;
                boolean removeVendorCheck = false;          
                boolean skipVendorCheck = false;    //Rev 2.5
                
                //Rev 3.1
                String[] vdrProdLineDesc = StringUtils.split(prodLineDescKey, ':');
                if (vdrProdLineDesc != null && vdrProdLineDesc.size() == 2) {
                    vendorProdLine = ';'+ vdrProdLineDesc[1] + ';';
                }
                //Rev 3.1-end
                
                if (oppIdToProdLineListMap.get(oppId).get(prodLineDescKey) == null || oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).oOliList == null) continue;
                
                //1a. Finding matched Criteria
                criteria = selectCriteria(regKey, countryKey, SegmentKey, ProdLineDescKey, currencyKey);                    
                            
                //1e. If still can't find a matched criteria, will skip for criteria check for this Prod Line Desc
                if (criteria != null) {

                    //2a. Criteria Segment is required but Opp Segment is not matched, so get primary record and no need check for criteria
                    if (criteria.Segment_Required__c && isPrimary) {                
                        skipCriteriaCheck = true;
                        if (StringUtils.isEmpty(segmentKey)) isMissingSegment = true;   
                        System.debug('Skip criteria - missing segment '+segmentKey);
                    }       
                                            
                    //Rev 2.0                                           
                    //2b. Check for currency
                    //if (criteria.currencyISOCode != oppIdToOpp.get(oppId).currencyISOCode) {
                    //  skipCriteriaCheck = true;
                    //  System.debug('Skip criteria - currency not matched');
                    //}                             
                    //Rev 2.0-end
                    
                    //3. Check criteria here, update oliProdLineCriteria.isQualified and call upsertOli later to update OLI accordingly
                    if (!skipCriteriaCheck) {   
                        System.debug('Quantity: '+ oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalQuantity + '-' + criteria.Min_Qty__c +  
                                    ' NET: ' + oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNET + '-' + criteria.Min_NET__c +
                                    ' Day: ' + dayDiff + '-' + criteria.Min_days_before_Book_Date__c);
                                
                        if ((oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalQuantity >= criteria.Min_Qty__c) &&
                            (oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNET >= criteria.Min_NET__c) &&
                            (dayDiff >= criteria.Min_days_before_Book_Date__c)) {
                            System.debug('Criteria met');
                            isQualified = QUALIFIED_YES;
                            dealStatus = DEAL_STATUS_PENDING;                                       
                        }
                    }
                }
                
                //4. Update Opp Prod
                List<oOppLineItem> ooList = oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).oOliList;
                for (oOppLineItem oo : ooList) {                
                    System.debug('Update Opp Prod: '+oo.oli.Qualified_for_S_P_Deal_Reg_Program__c + '->' +isQualified);
                    if (oo.oli.Qualified_for_S_P_Deal_Reg_Program__c != isQualified && oo.triggerType != TriggerType.ISDELETE) {
                        if (oo.TriggerType == TriggerType.NOTTRIGGER) {
                            OpportunityLineItem oli = new OpportunityLineItem(Id = oo.oli.Id, Qualified_for_S_P_Deal_Reg_Program__c = isQualified);                             
                            oli.S_P_Deal_Status__c = dealStatus;
                            updateOliList.add(oli);
                        }
                        else {                      
                            oo.oli.Qualified_for_S_P_Deal_Reg_Program__c = isQualified;
                            oo.oli.S_P_Deal_Status__c = dealStatus;
                        }
                    }
                }   
                
                //5. If still can't find a matched criteria and no existing vendor, will skip vendor creation/updates for this Prod Line Desc
                if (criteria == null) {                   
                    
                    //Rev 1.2, Rev 2.5             
                    brandName = StringUtils.lowerCase(oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).oOliList[0].oli.Brand_Desc__c);
                    System.debug('## Criteria not met and check existing vendor:'+brandName);
                    
                    //Rev 2.2 if (oppIdToVendorNameToVendorMap == null || oppIdToVendorNameToVendorMap.get(oppId) == null || oppIdToVendorNameToVendorMap.get(oppId).get(brandName) == null) continue;
                    if (oppIdToVendorNameToVendorMap.get(oppId).get(brandName) == null || oppIdToVendorNameToVendorMap.get(oppId).get(brandName).vdr == null) {
                        //Rev 3.1
                        if (oppIdToVendorNameToVendorMap.get(oppId).get(brandName) != null) 
                            oppIdToVendorNameToVendorMap.get(oppId).get(brandName).totalNet -= oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNet;
                        System.debug('## no existing vendor found and skip');
                        continue;
                    } 
                    //Rev 3.1 deduct total net amount from vendor if can't find criteria for this prod line
                    else {
                        System.debug('## Deduct: '+ oppIdToVendorNameToVendorMap.get(oppId).get(brandName).totalNet +'-'+oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNet);
                        oppIdToVendorNameToVendorMap.get(oppId).get(brandName).totalNet -= oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNet;
                        if (oppIdToVendorNameToVendorMap.get(oppId).get(brandName).totalNet == 0) removeVendorCheck = true;
                    }  
                    //Rev 3.1-end                
                    //Rev 1.2-end
                }
                else {
                    //Rev 2.5                   
                    if (StringUtils.equalsIgnoreCase(criteria.Brand_Desc__c, oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).oOliList[0].oli.Brand_Desc__c))                     
                        brandName = StringUtils.lowerCase(criteria.Brand_Desc__c);
                    else
                        skipVendorCheck = true;
                    //Rev 2.5-end
                    
                    //Rev 2.4
                    System.debug('#### criteriaByCountryRecTypeId:' +criteriaByCountryRecTypeId + '-' + criteria.RecordTypeId + '==' + criteria.Distributor_Name__c + '/' + criteria.Distributor_Name_Region__c);
                    if (criteriaByCountryRecTypeId != null) distributor = (criteria.RecordTypeId == criteriaByCountryRecTypeId? criteria.Distributor_Name__c:criteria.Distributor_Name_Region__c);                  
                }
                                
                /************** Vendor Check *****************/ 
                System.debug('########## VENDOR CHECK ##########');
                
                //1. No more Opp Prod for this Prod Line Desc in this Opp
                //Might need to delete vendor if no other Prod Line Desc with the same vendor
                if (tt == TriggerType.ISDELETE &&(oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalQuantity == 0)){                                          
                    System.debug('Remove Vendor: '+brandName);
                    removeVendorCheck = true;                   
                } 
                
             String vendorRecordTypeId = vendorNameToRecTypeIdMap.containsKey(brandName)? vendorNameToRecTypeIdMap.get(brandName): VENDOR_STD_RECORDTYPE_ID;
                                        
                //Rev 2.2
                //2. If no vendor found for this opp, will create a new vendor and add into oppIdToVendorNameToVendorMap        
                //if (oppIdToVendorNameToVendorMap == null || oppIdToVendorNameToVendorMap.get(oppId) == null || oppIdToVendorNameToVendorMap.get(oppId).get(brandName) == null) {
                if (oppIdToVendorNameToVendorMap.get(oppId).get(brandName) == null || oppIdToVendorNameToVendorMap.get(oppId).get(brandName).vdr == Null) { 
                                    
                    //Rev 2.5
                    //Rev 1.3 Update currency field with Opp's currency
                    if (tt != TriggerType.ISDELETE && criteria != null && !skipVendorCheck) {   
                        System.debug('Create vendor');  
                        
                        //Rev 2.3
                        S_P_Vendors__c newVendor = new S_P_Vendors__c(Opportunity__c = oppId, S_P_Vendors_Name__c = criteria.Brand_Desc__c, S_P_Vendors_Name_Hidden__c = criteria.Brand_Desc__c, 
                                                                Qualified_for_S_P_Deal_Reg_Program__c = isQualified, S_P_Deal_Status__c = dealStatus,
                                                                RecordTypeId = vendorRecordTypeId, Missing_Segment__c = isMissingSegment, Product_Line_Desc__c = vendorProdLine, //Rev 3.1
                                                                PM1__c = criteria.PM1__c, PM2__c = criteria.PM2__c, PM3__c = criteria.PM3__c, PM4__c = criteria.PM4__c, PM5__c = criteria.PM5__c,
                                                                Equipment_will_reside_at_this_address_L__c = true, Total_NET__c = oppIdToVendorNameToVendorMap.get(oppId).get(brandName).totalNet, 
                                                                CurrencyISOCode = oppIdToOpp.get(oppId).CurrencyISOCode, Special_instructions__c = criteria.Special_instructions__c, 
                                                                Distributor_Name__c = distributor, Renewal_Instruction_to_Sales_Rep__c = criteria.Renewal_Instruction_to_Sales_Rep__c,
                                                                Region__c = oppIdToOpp.get(oppId).Primary_Product_Delivery_Address_Region__c, 
                                                                Ship_to_Address__c = (oppIdToOpp.get(oppId).Account.ShippingStreet != null) ? oppIdToOpp.get(oppId).Account.ShippingStreet : '',
                                                                City__c = (oppIdToOpp.get(oppId).Account.ShippingCity != null) ? oppIdToOpp.get(oppId).Account.ShippingCity : '', 
                                                                Zip__c = (oppIdToOpp.get(oppId).Account.ShippingPostalCode != null) ? oppIdToOpp.get(oppId).Account.ShippingPostalCode : '', 
                                                                Country__c = oppIdToOpp.get(oppId).Primary_Product_Delivery_Address_Country__c); // 4.1 Added Region field during creation
                                                                                                                                                                                    // 4.2 Added SV Shipping Address
                        //4.1 Country and State Picklist Options check
                        Schema.sObjectType sobject_type = S_P_Vendors__c.getSObjectType(); //grab the sobject that was passed
                        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
                        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for S&P Vendors
                        List<Schema.PicklistEntry> state_pick_list_values = field_map.get('State__c').getDescribe().getPickListValues(); //grab the list of picklist values for State
                        
                        for (Schema.PicklistEntry state : state_pick_list_values) { //for all values in the picklist list                                    
                            if(oppIdToOpp.get(oppId).Account.ShippingState != null && oppIdToOpp.get(oppId).Account.ShippingState.trim().toLowerCase() == state.getLabel()) { //add the value and label to our final list
                                newVendor.State__c = state.getLabel();
                                break;
                            }
                        }
                        
                        field_map.clear();
                        state_pick_list_values.clear();
                        
                        // Rev 4.0 START
                        // Check for currency and exchange rates. Total Net in USD should always be updated.;
                        //* 6.3   FY20 DCS-0202   Swathi      06/12/2018      Tech debt story to remove soql from loop
                       Map<string,double> mapDatedConversionRate = new Map<string,double>();
                       for(DatedConversionRate d:listDatedConversionRate){
                            mapDatedConversionRate.put(d.IsoCode,d.ConversionRate);
                        }                                                   
                          if(newVendor.CurrencyISOCode != 'USD') {
                              if(exchangeRateMap.get(newVendor.CurrencyISOCode) == null) {
                                  exchangeRateMap.put(newVendor.CurrencyISOCode, mapDatedConversionRate.get(newVendor.CurrencyISOCode));   
                           
                              } 
                              newVendor.Total_Net_in_USD__c = newVendor.Total_NET__c / exchangeRateMap.get(newVendor.CurrencyISOCode);
                          } else  
                              newVendor.Total_Net_in_USD__c = newVendor.Total_NET__c;               
                                              
                        if(svAutoMap.get(criteria.Brand_Desc__c.toLowerCase().trim()) != null)
                            newVendor  = sps.checkAutomation(newVendor, 
                                            svAutoMap.get(criteria.Brand_Desc__c.toLowerCase().trim()));
                        // Rev 4.0 END
                        
                        if (isQualified == QUALIFIED_YES) newVendor.Qualified_Product_Line_Desc__c = vendorProdLine;                    
                        upsertVendorMap.put(newVendor.S_P_Vendors_Name_Hidden__c, newVendor);
                        
                        //Rev 2.2
                        //if (oppIdToVendorNameToVendorMap == null) oppIdToVendorNameToVendorMap.put(oppId, new Map<String, vVendor> {newVendor.S_P_Vendors_Name_Hidden__c =>newVendor});
                        //if (oppIdToVendorNameToVendorMap.get(oppId) == null) oppIdToVendorNameToVendorMap.put(oppId, new Map<String, S_P_Vendors__c> {newVendor.S_P_Vendors_Name_Hidden__c => newVendor});
                        //Rev 2.5                        
                        if (oppIdToVendorNameToVendorMap.get(oppId).get(brandName) == null) oppIdToVendorNameToVendorMap.get(oppId).put(brandName, new vVendor(newVendor, oppIdToVendorNameToVendorMap.get(oppId).get(brandName).totalNet));                        
                        if (oppIdToVendorNameToVendorMap.get(oppId).get(brandName).vdr == Null) oppIdToVendorNameToVendorMap.get(oppId).get(brandName).vdr = newVendor;
                        //Rev 2.2-end
                    }
                }
                else {
                    //Rev 2.2
                    //3. Vendor is found and update vendor accordingly              
                    S_P_Vendors__c updateVendor = oppIdToVendorNameToVendorMap.get(oppId).get(brandName).vdr;
                                    
                    System.debug('Qualified product line 1: '+updateVendor.Qualified_Product_Line_Desc__c);
                    System.debug('product line 1: '+updateVendor.Product_Line_Desc__c);
                    
                    //Rev 2.2 updateVendor.Total_NET__c = (updateVendor.Total_NET__c == null)?0.0:updateVendor.Total_NET__c;
                                                    
                    //3a. If Opp Prod delete from Opp and no other Opp Prod/Prod Line Desc linked with this vendor then delete the vendor as well
                    if (removeVendorCheck) {
                        //If no more Opp prod for this vendor, delete vendor as well                             
                         updateVendor.Product_Line_Desc__c = StringUtils.remove(updateVendor.Product_Line_Desc__c, vendorProdLine);
                         System.debug(oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNET);
                        
                         System.debug(updateVendor.Total_NET__c);                        
                         //Rev 2.2 updateVendor.Total_NET__c = updateVendor.Total_NET__c - oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalOldNET + oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNET;
                         updateVendor.Total_NET__c = oppIdToVendorNameToVendorMap.get(oppId).get(brandName).totalNET;
                         
                         //3b. Still have other Opp Prod/Prod Line Desc linked with this Opp, set removeVendorCheck = false and don't delete vendor
                         if (updateVendor.Product_Line_Desc__c != null) {
                            removeVendorCheck = false;
                            boolean reCheckMissingSegment = false;
                                     
                            //3c. May need to re-check MissingSegment field for other Prod Line Desc                        
                            if (isMissingSegment || updateVendor.Missing_Segment__c) {                              
                                String[] prodList = StringUtils.split(StringUtils.subString(updateVendor.Product_Line_Desc__c, 1, StringUtils.length(updateVendor.Product_Line_Desc__c)-1), ';;');
                                System.debug('reCheckMissingSegment: '+prodList);
                                if (prodList !=null) {
                                    for (String pl:prodList) {                                      
                                        pl = brandName + ':' + pl; //Rev 3.1
                                        S_P_DR_Criteria__c tempCriteria = selectCriteria(regKey, countryKey, segmentKey, pl, currencyKey);
                                    
                                        if (tempCriteria != null && tempCriteria.Segment_Required__c && isPrimary && StringUtils.isEmpty(segmentKey)) {                                 
                                            reCheckMissingSegment = true;
                                            break;  //Rev 2.1
                                        }
                                    }
                                }                               
                            }
                            isMissingSegment = reCheckMissingSegment;               
                         }           
                    }
                    else {  
                        
                        //if (tt == TriggerType.NOTTRIGGER)
                        //  updateVendor.Total_NET__c = oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNET;
                        //else
                            System.debug('Calc total net: '+updateVendor.Total_NET__c + '-' + oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalOldNET + '+' + oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNET);
                            //Rev 2.2 updateVendor.Total_NET__c = updateVendor.Total_NET__c - oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalOldNET + oppIdToProdLineListMap.get(oppId).get(prodLineDescKey).totalNET;
                            updateVendor.Total_NET__c = oppIdToVendorNameToVendorMap.get(oppId).get(brandName).totalNET;
                                                 
                        if (!StringUtils.contains(updateVendor.Product_Line_Desc__c, vendorProdLine)) {                             
                            updateVendor.Product_Line_Desc__c += vendorProdLine;                                                            
                        }
                    }
                            
                    //4. Update vendor fields accordingly 
                    if (!removeVendorCheck) {   
                                                                    
                        if (isQualified == QUALIFIED_YES) {
                            if (!StringUtils.contains(updateVendor.Qualified_Product_Line_Desc__c, vendorProdLine)) {                                   
                                updateVendor.Qualified_Product_Line_Desc__c = (updateVendor.Qualified_Product_Line_Desc__c == null? '': updateVendor.Qualified_Product_Line_Desc__c) + vendorProdLine;                              
                            }                           
                            
                            if (updateVendor.Qualified_for_S_P_Deal_Reg_Program__c != isQualified) {
                                updateVendor.Qualified_for_S_P_Deal_Reg_Program__c = isQualified;
                                updateVendor.S_P_Deal_Status__c = dealStatus;
                            }
                        }
                        else {                      
                            if (StringUtils.contains(updateVendor.Qualified_Product_Line_Desc__c, vendorProdLine)) {
                                System.debug('remove prod line');                                   
                                updateVendor.Qualified_Product_Line_Desc__c = StringUtils.remove(updateVendor.Qualified_Product_Line_Desc__c, vendorProdLine);
                            }
                            System.debug(updateVendor.Qualified_Product_Line_Desc__c == null);
                            //Only set Qualified_for_S_P_Deal_Reg_Program__c to false when no other Prod Line Desc is qualified for this vendor
                            //Only update Deal Status to blank if it is un-qualified
                            //v5.0 - start
                            if (updateVendor.Qualified_Product_Line_Desc__c == null && updateVendor.S_P_Deal_Status__c !='Approved' && updateVendor.S_P_Deal_Status__c !='Sent to Vendor') {                              
                                updateVendor.Qualified_for_S_P_Deal_Reg_Program__c = isQualified;
                                updateVendor.S_P_Deal_Status__c = '';
                            }
                            //v5.0 - end 
                        }
                                                        
                        System.debug('Qualified product line 2: '+updateVendor.Qualified_Product_Line_Desc__c);
                        System.debug('product line 2: '+updateVendor.Product_Line_Desc__c);
                                            
                        if (criteria != null) {                                         
                            //Only update Missing Segment field if Segment is required
                            if (criteria.Segment_Required__c) updateVendor.Missing_Segment__c = isMissingSegment;
                        
                            //Always reflect with the latest info
                            updateVendor.PM1__c = criteria.PM1__c;
                            updateVendor.PM2__c = criteria.PM2__c;
                            updateVendor.PM3__c = criteria.PM3__c;
                            updateVendor.PM4__c = criteria.PM4__c;
                            updateVendor.PM5__c = criteria.PM5__c;
                                                                        
                            updateVendor.Special_instructions__c = criteria.Special_instructions__c;
                            //Rev 2.7
                            updateVendor.Renewal_Instruction_to_Sales_Rep__c = criteria.Renewal_Instruction_to_Sales_Rep__c;
                            
                            //Rev 2.4
                            //Rev 2.3
                            // Rev 6.0 VMware  Defect - 5199627 to control not to overwritten distributor name
                            //6.1 CR 16821 - Not to update Distributor Name field once record is created.
                            if(updateVendor.Distributor_Name__c == ''){
                                    updateVendor.Distributor_Name__c = distributor;
                            }                          
                        }
                        
                        upsertVendorMap.put(updateVendor.S_P_Vendors_Name_Hidden__c, updateVendor);     
                    } 
                    else {
                        deleteVendorList.add(updateVendor);
                    }                           
                }
            }             
        }
        
        System.debug('upsertVendorMap: '+upsertVendorMap.values());     
        if (upsertVendorMap != null && upsertVendorMap.size() > 0) databaseInsertOrUpdate(upsertVendorMap.values());
        
        System.debug('deleteVendorList:'+deleteVendorList);
        if (deleteVendorList != null && deleteVendorList.size() > 0) delete deleteVendorList;
        
        skipSnPRecalculate = true;      
        System.debug('updateOliList: ' + updateOliList);        
        if (updateOliList != null && updateOliList.size() > 0) databaseInsertOrUpdate(updateOliList);
        skipSnPRecalculate = false;             
    }

    private static S_P_DR_Criteria__c selectCriteria(String regKey, String countryKey, String SegmentKey, String prodLineDescKey, String currencyKey) {
        
        isPrimary = false;
        
        /* 
        //Rev 2.0
        //1a. Get criteria 
        string key = StringUtils.lowerCase(regkey + ':' + countryKey + ':' + prodLineDescKey+ ':' + segmentKey);            
        if (regCtryLineSegmentCurrToCriteriaMap.containsKey(key)) {
            System.debug('Criteria Selected 1: '+key);
            return regCtryLineSegmentCurrToCriteriaMap.get(key);
        }
        
        //1b. If can't find a matched criteria, will get primary record (key=region:country:ProdLineDesc:PRIMARY)
        key = StringUtils.lowerCase(regkey + ':' + countryKey + ':' + prodLineDescKey+ ':' + PRIMARY_RECORD);       
        if (regCtryLineSegmentCurrToCriteriaMap.containsKey(key)) {
            isPrimary = true;               
            System.debug('Criteria Selected 2: '+key);                  
            return regCtryLineSegmentCurrToCriteriaMap.get(key);        
        }
            
        //1c. Get criteria if country field is blank(key=region:blank:ProdLineDesc:Segment)
        key = StringUtils.lowerCase(regkey + ':null:' + prodLineDescKey+ ':' + segmentKey);     
        if (regCtryLineSegmentCurrToCriteriaMap.containsKey(key)) { 
            isPrimary = false;                              
            System.debug('Criteria Selected 3: '+key);
            return regCtryLineSegmentCurrToCriteriaMap.get(key);            
        }
            
        //1d. If can't find a matched criteria, will get primary record (key=region:null:ProdLineDesc:PRIMARY)
        key = StringUtils.lowerCase(regkey + ':null:' + prodLineDescKey+ ':' + PRIMARY_RECORD);     
        if (regCtryLineSegmentCurrToCriteriaMap.containsKey(key)) { 
            isPrimary = true;                               
            System.debug('Criteria Selected 4: '+key);
            return regCtryLineSegmentCurrToCriteriaMap.get(key);
        }
        */
        
        List<String> keyList = new List<String>();
        //1a. Get criteria
        keyList.add(StringUtils.lowerCase(regkey + ':' + countryKey + ':' + prodLineDescKey+ ':' + segmentKey));
        //1b. If can't find a matched criteria, will get primary record (key=region:country:ProdLineDesc:PRIMARY)
        keyList.add(StringUtils.lowerCase(regkey + ':' + countryKey + ':' + prodLineDescKey+ ':' + PRIMARY_RECORD));    
        //1c. Get criteria if country field is blank(key=region:blank:ProdLineDesc:Segment)
        keyList.add(StringUtils.lowerCase(regkey + ':null:' + prodLineDescKey+ ':' + segmentKey));  
        //1d. If can't find a matched criteria, will get primary record (key=region:null:ProdLineDesc:PRIMARY)
        keyList.add(StringUtils.lowerCase(regkey + ':null:' + prodLineDescKey+ ':' + PRIMARY_RECORD));
        
        for(String key : keyList) {         
            if (regCtryLineSegmentCurrToCriteriaMap.containsKey(key)) {
                if (regCtryLineSegmentCurrToCriteriaMap.get(key).containsKey(currencyKey)) {            
                    isPrimary = StringUtils.contains(key, StringUtils.lowerCase(PRIMARY_RECORD));
                    System.debug('### Criteria selected: '+ key+':'+currencyKey+':'+isPrimary);
                    return regCtryLineSegmentCurrToCriteriaMap.get(key).get(currencyKey);
                }
            }
        }
        //Rev 2.0-end
        System.debug('### No criteria selected');
        return null;
    }   
        
    private static void clearAll() {
        oppIdToProdLineListMap.clear();
        oppIdToVendorNameToVendorMap.clear();
        regCtryLineSegmentCurrToCriteriaMap.clear();
        oppIdToOppMap.clear();
        vendorNameToRecTypeIdMap.clear();
    }
    
    private static void databaseInsertOrUpdate(List<SObject> updateList) {
        
        Database.UpsertResult[] lur = Database.upsert(updateList,false);
        
        for(Database.UpsertResult ur : lur){
            if (!ur.isSuccess()) { 
                System.debug('###DEBUG### update error - ' + ur);
            }
        }
    }
    
}
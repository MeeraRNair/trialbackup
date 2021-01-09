/* 
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to OpportunityLineItem object. 
 *          Please create separate classes and use it for complex logics.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10496     15.10       05-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */ 

public class OpportunityLineItemUtilities {
    public static String ISOPPPRODDELETE = 'NO';
    /*
    Revision    CR Number   Release No     Date            Modified By     Description
    --------    ---------   ----------     -----------     ------------    -----------
    1.0                     Quest          13-Dec-2012     Patrick         Prevent Delete process for Opportunity Products that has been sent to Quest SFDC
    2.0         CR10496     15.10          21-Sep-2014     Ragu            This logic is separated from opptyLineItemBeforeInsertUpdateDeleteTrigger trigger and rewritten as part of trigger redesign.
    3.0         CR13097     Sprint 8       09-May-2016     AFiq            Prevent from Opportunity with EMC CRUD Behavior = R
    4.0         D2574554    Sprint19       10-Oct-2016     Vasavi.M        Allow deleteion of DSG related Oppty products, for profiles other than admin profiles 
                                                                           - to support open oppty, after Cast Iron integration stops
    5.0         CR13762     Sprint 23      28-Nov-2016     AFiq            Prevent from Opportunity Syched with EMC and it is Business Family = EMC
    6.0         CR13980     FY18-DCS-0302  14-Feb-2017     Harsha          Remove exception for Cast Iron Integration API profile.
    7.0         D3398057    SP08-May08     22-MAY-2017     Pawan V         Added method to trigger off pop up alert when incumbent products are added to opportunities as line items
    8.0         CR 14471    FY18-DCS-0802  13-June-2017    Akshita         Replaced the Hard-coded stage names to the names given in OWD__c custom settings and added the value for 'Order-Submitted - 99%' stage
    8.0         CR14931     DCS-FY18-1101  20-Sep-2017     Naga            Code cleanup for savo functionality, removed all refferences of Product_Group_Hidden__c and Product_Brand_Hidden__c fields from code.
    9,0         16088       FY19-DCS-0802  04-July-2018    Vivek           Related to VMware defect 0602 defect (5149683) fixing to overcome New product status update isssue
    10.0        CR 16577    FY19-DCE-1102  28-Sept-2018    Vasavi.M        Prevent deletion of myquotes synced olis (exclude few profiles & users with permission)
    11.0        CR 17088    FY20-DCE-0402  23rd-Jan-2019   Vasavi.M        Fix the null pointer exception, with countries that are in the bucket Other on the Primary Product Delivery Adress Region 
    12.0        CR17974     FY20-DCE-1002   30-Aug-2019    Shubham B       updated the updateLOTIndicator(Adding checks to bypass the method for APOS opportunities)
    13.0        CR18399     FY21-DCE-0202   14-Dec-2019    Shubham B       replaced the RenewalOpportunity_Utils with RenewalsConstants so that any package classes can be deployed independetly with the help of RenewalsConstants as it presents in Base package
    */          

    
    
    public static void validateDeletion(list<OpportunityLineItem> lstLineItems, map<Id, OpportunityLineItem> mapRelatedRecords) {
        // Get current user Profile Name
         //String strCurrentUserProfile = StaticFactory.getCurrentUserDetails().Profile.Name;     //v10.0 Reduce running query 2 times
        //for getting picklist values from custom setting
        OWD__c obj = OWD__c.getOrgDefaults();
    
        String lost_cancelled = obj.Oppty_Stage0__c; 
        String win = obj.Oppty_Stage100__c; 
        String order_submitted = obj.Oppty_Stage99__c;
        
        //v10.0 Start
        EMC_General_Settings__c emcGCSObject = EMC_General_Settings__c.getInstance();
        String strBypassProfiles = emcGCSObject.ProfilesBypassMyquotesOpptyValidation__c;
        List<String> listBypassProfiles = new list<string>();
        if(strBypassProfiles != null && strBypassProfiles != '') {
            listBypassProfiles =strBypassProfiles.split(';');
        }
        User objCurrentUser = StaticFactory.getCurrentUserDetails();
        String strCurrentUserProfile = objCurrentUser.Profile.Name;
        Boolean blnPreventDelPermission = objCurrentUser.Product_Quote_Permission__c;
        //v10.0 End
        
        // Validate to delete the product 

        Set<Id> oppIdSet = new Set<Id>();
        for(OpportunityLineItem oppLinteItem: lstLineItems){
            oppIdSet.add(oppLinteItem.OpportunityId);
        }
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([Select Id, CloseDate, StageName, Primary_Product_Delivery_Address_Region__c, Synced_with_EMC_Quote__c,MyQuotes_Quote_Number__c
 from Opportunity where ID IN: oppIdSet]);

        for(OpportunityLineItem oliIterator : lstLineItems){
            ISOPPPRODDELETE = 'YES';
            Opportunity opp = new Opportunity();
            opp = opportunityMap.get(oliIterator.OpportunityId);

        
            If( opp.Primary_Product_Delivery_Address_Region__c != NULL && oliIterator.REGIONAL_EOL_DATE__c != NULL ){
            if(opp.CloseDate < system.today() && oliIterator.REGIONAL_EOL_DATE__c >= system.today()  && (opp.StageName != win || opp.StageName != lost_cancelled )){    
                    oliIterator.addError('Error: You cannot save an open opportunity where the Book Date is prior to today’s date. Please either change the Book Date to a future one or move the Stage to Won or Lost and then save.');
                }
            }
            // 3.0 Start Added EMC_CRUD_Behavior__c checking 
            // 5.0 Start, remove EMC_CRUD_Behavior checking and add business family flaag and syched with emc quote
            //v10.0 Start
            /*else if(oliIterator.Business_Family_Flag__c =='EMC' && opp.Synced_with_EMC_Quote__c == true && StaticFactory.getUserDetails(UserInfo.getUserId()).Profile.Name != 'Boomi Integration API Only'){
                oliIterator.addError('Error: You are not allowed to delete an Opportunity Product which already synced with EMC. Please contact your System Administrator');                            
            }*/
            else if(oliIterator.Business_Family_Flag__c =='EMC' && opp.MyQuotes_Quote_Number__c != null && (!listBypassProfiles.contains(strCurrentUserProfile)) && !blnPreventDelPermission){
                oliIterator.addError('Error: You are not allowed to delete an Opportunity Product which already synced with EMC. Please contact your System Administrator');                            
            }
            //v10.0 End
            // 5.0 End
            // 3.0 End
            else {
                if(opp.CloseDate < system.today() && (oliIterator.EOL_Date__c >= system.today() || oliIterator.EOL_Date__c == NULL) && (opp.StageName != win || opp.StageName != lost_cancelled )){    
                oliIterator.addError('Error: You cannot save an open opportunity where the Book Date is prior to today’s date. Please either change the Book Date to a future one or move the Stage to Won or Lost and then save.');
                }
            } 
        } 
    }
    
  /*  Revision  CR Number       Release No      Date            Modified By       Description
    --------     ---------      ----------     -----------     ------------      -----------
    1.0           11624          16.07         29-June-2015    Samridh Manucha    To do realtime update on OSC when product gets added,deleted .
   
    */    
    
    public static void RealTimeProductUpdate(List<Opportunitylineitem> OppLineLst){
       
    List<id> AddOppLineItem = new List<id>();
    String OSCActionIdentifier = 'ProductSync';
       
       for(OpportunityLineItem opp:OppLineLst){
               AddOppLineItem.add(opp.OpportunityId);
           }        
       
     if( AddOppLineItem.size() > 0){
                    
       List<solution__c> solutions = [select id, Opportunity__c, OSC_Regional_Id__c from solution__c where Opportunity__c IN : AddOppLineItem];
         
         if(solutions.size()>0){
         
              set<id> oppidfrmsol = new set<id>();
              List<id> Listoppid = new List<id>();

                      for(solution__c sl: solutions){
           
                            oppidfrmsol.add(sl.Opportunity__c); 
           
                        }
           
             Listoppid.addAll(oppidfrmsol);
             OSCWebServiceCallout.sendNotification(Listoppid,OSCActionIdentifier);// sending ProdSync because we have to generate product list in JSON during realtime product delete,insert
         }
       }
    }
       
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR7326      SW M&A          12.07.2012      Jiji            To Update the Product Brand (for rollup) field = ‘SonicWall’, if the Brand Desc contains 'SonicWall'
    2.0         CR10496     15.10           21-Sep-2014     Ragu            This logic is separated from opptyLineItemBeforeInsertUpdateDeleteTrigger trigger and rewritten as part of trigger redesign.
    3.0         CR10826     16.03           23-Dec-2014     Meghana         To comment code written based on product description = 'SonicWall'
    3.1         CR10826     16.03           24-Dec-2014     Meghana         Populate new text field 'DSG Sales Motion (for rollup) with value from formula field 'DSG Sales Motion'
    3.2         CRQ 1166    16.03           17-Mar-2015     Meghana         Uncomment changes done for version 3.0
    3.3         CRQ 11436   16.07           07-May-2015     Krishna         Added dropbox value to Brand desc.
    4.0         CR13171     FY17-DCS-0701   03-Jun-2016     Fenny           Implement "CR3463 - Update Product Type in Opp Product" Oppty Product WF to this code
    */
    public static void populateFields(TriggerHandler.TriggerEvent trigEvent, list<OpportunityLineItem> lstLineItems, map<Id, sObject> mapOldLineItems) {
        // 4.0: Start
        Set<Id> setProduct2Id = new Set<Id>();
        for(OpportunityLineItem oppLI : lstLineItems){
            setProduct2Id.add(oppLI.Product2Id);
        }
        Map<Id, Product2> mapProduct2 = null;
        If(!setProduct2Id.isEmpty()){
            mapProduct2 = new Map<Id, Product2>([SELECT Family FROM Product2 WHERE Id IN :setProduct2Id]);
        }
        // 4.0: End
        
        for(OpportunityLineItem oliIterator : lstLineItems) {
            if(oliIterator.SOC_Qualified_F__c == 'true') {
                oliIterator.SOC_Qualified__c = true;
            }
            else {
                oliIterator.SOC_Qualified__c = false;
            }
            //3.2 -uncomment changes
            /*v3.0 - Comment code logic using product description as 'SonicWall'*/
            // v1.0 Start
            /* CR11549 Comment code for Sonicwall decommisioning
            if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT && (oliIterator.Brand_Desc__c + '').toLowerCase().contains('sonicwall')) {
                oliIterator.Product_Brand_for_rollup__c = 'SonicWall';
            } CR11549 End */ 
            //V3.3 CR11436 Start -Updated by krishnakumar to populate for dropbox product
            if((oliIterator.Brand_Desc__c + '').toLowerCase().contains('dropbox')) {
                oliIterator.Product_Brand_for_rollup__c = 'Dropbox';
            }//V3.3 CR11436 End-Updated by krishnakumar to populate for dropbox product
            // v1.0 End
            /*v3.0 - end*/
            //v3.1 - start if old DSG_Sales_motion Value <> new DSG_Sales_motion value
            if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                oliIterator.DSG_Sales_motion_for_rollup__c = oliIterator.DSG_Sales_motion_Flag__c;
            }
            else{
                if (oliIterator.DSG_Sales_motion_Flag__c != oliIterator.DSG_Sales_motion_for_rollup__c){
                    oliIterator.DSG_Sales_motion_for_rollup__c = oliIterator.DSG_Sales_motion_Flag__c;
                }
            }
            //v3.1-end 
            
            // 4.0: Start
            if((oliIterator.UnitPrice > 0) && (oliIterator.Quantity > 0) && (mapProduct2 != null) && (mapProduct2.size() > 0)){
                Product2 prd2 = mapProduct2.get(oliIterator.Product2Id);
                if(prd2 != null){
                    oliIterator.Product_Type__c = prd2.Family;
                }
            }
            // 4.0: End
        }
    }     
    
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR2559      11.5            20-Apr-2010     Raymond         Created for CR2559 & CR2560
    2.0         CR7011                      03-Apr-2012     Jessie          Check whether there is any Opportunity Product eligible for DGR (a new field - Contain_DGR_Eligible_Product__c) for an Opportunity
    3.0         CR7670                      23-Nov-2012     Sathish         Modifying brand desc hidden field in opp level while add/update products
    4.0         CR8132                      10-Mar-2013     Sathish         Auto populate Dell Defined LOB in opportunity based on product added       
    5.0         CR9557                      24-Jun-2013     Mohammad        DML Exception- Commented one line in Catch Block.
    6.0         CR10496     15.10           21-Sep-2014     Ragu            This logic is combined from opptyLineItemAfterInsertUpdateTrigger & opptyLineItemAfterDeleteUndeleteTrigger triggers and rewritten as part of trigger redesign.
    7.0         13171       FY17-DCS-0701   26-May-2016     Fenny           Skip opportunity triggers
    8.0         14761       FY17-DCS-1001   16-July-2017    Sumit kumar     Commented the method related to LOB as part of Seal code cleanup.
	9.0			CR18307		FY20-0102		25-Nov-2019		Fenny			Accessible OpportunityLineItem RecordSelector
    */
    public static void initiateDGRCalculations(list<OpportunityLineItem> lstLineItems, OpportunityLineItemTriggerHandler oliTriggerHandler) {
        try {
            // v2.0 - Start
            DgrEligibleOppProdSummary oppWithDgrProdSummary = new DgrEligibleOppProdSummary();
            //V8.0 Start
            //oppWithDgrProdSummary.loadDgrEligibleProdInfo(oliTriggerHandler.oliRecordSelector.setOpportunityIds);
            //V8.0 End
            // Concat products brand desc into map
            // MARKER - Ragu on 10-Oct-2014 (Valid till 16.03): Order is changed as part of CR10496
            //V8.0 Start
            //oppWithDgrProdSummary.loadServicesLOBCrossRefData(); // 4.0
            //V8.0 End
            oppWithDgrProdSummary.concatenateBrandDescAndLOB(OpportunityLineItemTriggerHandler.oliRecordSelector.mapAllRelatedOLIs.values());           
            
            list<Opportunity> lstOppsToUpdate = new list<Opportunity>();
            for(Opportunity oppIterator : [select Id, Recalculate_LOT_OCEAN__C, Products_Brand_Desc_Hidden__c, Dell_Defined_LOB__c, ServiceProductCount__c 
                                           from Opportunity where Id in :OpportunityLineItemTriggerHandler.oliRecordSelector.setOpportunityIds]) {
                // v4.0 - Start
                //V8.0 Start
                //oppWithDgrProdSummary.modifyOppLOBField(oppIterator);
                //V8.0 End
                // v4.0 - End
                if(oliTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE || oliTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUNDELETE) {
                    oppIterator.Recalculate_LOT_OCEAN__C = true;
                }
                else {
                    // If the list contains the opp id, the opp will be excluded to set the Recalculate_LOT_OCEAN__C = true
                    if(!OpportunityLineItemTriggerHandler.oliRecordSelector.setExcludedOppIdsForLO.contains(oppIterator.Id)) {
                        oppIterator.Recalculate_LOT_OCEAN__C = true;
                    }
                }
                // Add brand desc into opp hidden field
                oppWithDgrProdSummary.modifyOppBrandDescHiddenField(oppIterator);
                // Check every opp whether contains any dgr eligible product
                //V8.0 Start
                // oppWithDgrProdSummary.checkIfOppContainsDgrEligibleProduct(oppIterator);
                //V8.0 End
                Opportunity oppDetails = OpportunityLineItemTriggerHandler.oliRecordSelector.mapRelatedOpportunities.get(oppIterator.Id);
      
                if(oppIterator.Recalculate_LOT_OCEAN__C != oppDetails.Recalculate_LOT_OCEAN__C 
                    || oppIterator.Products_Brand_Desc_Hidden__c != oppDetails.Products_Brand_Desc_Hidden__c || oppIterator.Dell_Defined_LOB__c != oppDetails.Dell_Defined_LOB__c) {
                    lstOppsToUpdate.add(oppIterator);
                    System.debug('Inside if condition');
                }
            }
            // v2.0 - End 
             
            if(!lstOppsToUpdate.isEmpty()) {
                if (!Test.isrunningTest()){
                    TriggerExecutionController.setSkipOpportunityTriggers(true);//7.0
                }
                Database.SaveResult[] lstSaveResults = Database.update(lstOppsToUpdate, false);
                if (!Test.isrunningTest()){
                    TriggerExecutionController.setSkipOpportunityTriggers(false);//7.0
                }
                
                // MARKER - Ragu on 10-Oct-2014 (Valid till 16.03): Introduced SaveResult as part of CR10496 to handle errors individually.
                for(integer i=0; i<lstSaveResults.size(); i++) {
                   Database.SaveResult sResult = lstSaveResults[i];
                    if(!sResult.isSuccess()) {
                        for(OpportunityLineItem oliIterator : lstLineItems) {
                            if(oliIterator.OpportunityId == sResult.getId()) {
                                oliIterator.addError(sResult.getErrors()[0].getMessage());
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            //emailUtils.sendSupportEmail(e.getMessage() + 'The opportunity line items being insert/update were ' + lstLineItems, dellConfig.errorEmail);
            System.debug('Exception in initiateDGRCalculations - ' + e.getMessage());
            // MARKER - Ragu on 10-Oct-2014 (Valid till 16.03): Commented all the v5.0 changes as part of CR10496 as this doesn't make sense.
            //if(oliTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || oliTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {          
                // v5.0 - Start
                //for(OpportunityLineItem oliIterator : lstLineItems) {
                //  oliIterator.addError('You cannot save an open opportunity where the Book Date is older than the current date. Please either future date the Book Date or move the Stage to Won or Lost and save.');
                //}
                // Commented Below Line to avoid DML>Exception created from this trigger when trying to add/update Product.
                throw e;
                // v5.0 - End
            //}
        }
    }
    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR7150                  25-AUG-2011     Jiji            Created for CR7150 AppAssure M&A: To update the Opportunity
                                                                        AppAssure Product Flag based on the type of products added to the Opportunity.
                                                                            - AppAssure Product Flag = 0 => No AppAssure Product,  1 => Only AppAssure Products, 2 => Both AppAssure and other Products.
    2.0         CR7963                  08-Feb-2013     Devika          Updated for CR7963 - AppAssure Phase III: To update the Opportunity
                                                                            - AppAssure Product Flag for DL4000 product.
    3.0         CR8049                  13-Mar-2013     Devika          Updated for CR8049 - AppAssure Phase III: To update the Opportunity
                                                                            - AppAssure Product Flag for deleted products by Dell Users. 
    4.0                                 10-Jun-2013     Devika          AA Code Fix - Update flag to 3 only if AA products are deleted. Edited existing code to make string check case insensitive
    5.0         CR10496     15.10       21-Sep-2014     Ragu            This logic is separated from OpportunityLineItemAfterTrigger trigger and rewritten as part of trigger redesign.  
    6.0         CR10825     16.03       14-Jan-2015     Meghana         Corrected map.put statement to get correct value in AppAssure_Product_Flag__c
    6.1         CR10825     16.03       09-Mar-2015     Meghana         Corrected if condition so that AppAssure flag is set to 3 only if Bidirectional product is removed                      
    */
    public static void updateAppAssureProductFlag(set<Id> setOpportunityIds, set<Id> setDeletedOLIsOppIds) {
        if(setOpportunityIds != null && !setOpportunityIds.isEmpty()) {
            map<Id, OpportunityLineItem> mapAppAssureProducts = New map<Id, OpportunityLineItem>();
            map<Id, OpportunityLineItem> mapOtherProducts = New map<Id, OpportunityLineItem>();
            
            // v2.0 Added PricebookEntry.Product2.Name
            map<Id, Opportunity> mapOpportunities = new map<Id, Opportunity>([select Id,AppAssure_Product_Flag__c, (select Id, OpportunityId, DSG_CBO_Opportunity_Product__c from OpportunityLineItems) from Opportunity where Id in :setOpportunityIds]);       
            for(Opportunity oppIterator : mapOpportunities.values()) {
                for(OpportunityLineItem oliIterator : oppIterator.OpportunityLineItems) {
                    if(oliIterator.DSG_CBO_Opportunity_Product__c == 1) {
                        mapAppAssureProducts.put(oppIterator.Id, oliIterator);
                    }
                    else {
                        //v6.0 - start
                        //mapOtherProducts.put(oliIterator.Id, oliIterator);             
                        mapOtherProducts.put(oppIterator.Id, oliIterator);             
                        //v6.0 - end
                    }
                }
            }
            list<Opportunity> lstOppsToUpdate = new list<Opportunity>();
            for(Opportunity oppIterator : mapOpportunities.values()) {
            
                if(mapAppAssureProducts.get(oppIterator.Id) != null && mapOtherProducts.get(oppIterator.Id) == null) {
                    if(oppIterator.AppAssure_Product_Flag__c != 1) {
                        oppIterator.AppAssure_Product_Flag__c = 1;
                        lstOppsToUpdate.add(oppIterator);
                    }
                }
                else if(mapAppAssureProducts.get(oppIterator.Id) != null && mapOtherProducts.get(oppIterator.Id) != null) {
                    if(oppIterator.AppAssure_Product_Flag__c != 2) {
                        oppIterator.AppAssure_Product_Flag__c = 2;
                        lstOppsToUpdate.add(oppIterator);
                    }
                }
                //v6.1
                else if(setDeletedOLIsOppIds != null ) {
                    if (setDeletedOLIsOppIds.contains(oppIterator.Id) == true){
                       // v3.0 - Added this else if block
                        if(oppIterator.AppAssure_Product_Flag__c != 3) {
                            oppIterator.AppAssure_Product_Flag__c = 3;
                            lstOppsToUpdate.add(oppIterator);
                        }
                    }
                }
                else {
                    if(oppIterator.AppAssure_Product_Flag__c != 0) {
                        oppIterator.AppAssure_Product_Flag__c = 0;
                        lstOppsToUpdate.add(oppIterator);
                    }
                }
            }
            if(!lstOppsToUpdate.isEmpty()) {
                // MARKER - Ragu on 10-Oct-2014 (Valid till 16.03): setSkipOpportunityTriggers introduced as part of CR10496
                if (!Test.isrunningTest()){
                    TriggerExecutionController.setSkipOpportunityTriggers(true);
                }
                //update lstOppsToUpdate;
                Database.SaveResult[] lstSaveResults = Database.update(lstOppsToUpdate, false);
                for(integer i=0; i<lstSaveResults.size(); i++) {
                    Database.SaveResult sResult = lstSaveResults[i];
                    if(!sResult.isSuccess()) {
                        for(Opportunity oppIterator : mapOpportunities.values()) {
                            for(OpportunityLineItem oliIterator : oppIterator.OpportunityLineItems) {
                                if(oliIterator.OpportunityId == sResult.getId()) {
                                    oliIterator.addError(sResult.getErrors()[0].getMessage());
                                }
                            }
                        }
                    }
                }
                if (!Test.isrunningTest()){
                    TriggerExecutionController.setSkipOpportunityTriggers(false);
                }
            }
        }
    }
    
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         11464       16.07           14/05/2015      krishnakumar     Logic show the Export complaince message in Opportunity Page.
    2.0         13171       FY17-DCS-0701   3-Jun-2016      Fenny           To resolve "Too many SOQL queries: 101"
    */

   public static void checkEI_Products(set<Id> setOpportunityIds,list<OpportunityLineItem> lstLineItems,map<Id, Opportunity> mapRelatedOpportunities,list<OpportunityLineItem> selectedLineItems){
        
        Set<Opportunity> oppToUpdateFlag = new Set<Opportunity>();
        List<OpportunityLineItem> oppLineItemToUpdateFlag = new List<OpportunityLineItem>();
        Map<String,String> countryMap = new Map<String,String>();
        Opportunity opp;
        OpportunityLineItem oppLineItemObj;
        set<Id> setAccountIds = new set<Id>();
        map<Id, Account> mapRelatedAcc = null;
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [ SELECT Id,Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'SNP_Deal_Reg_EI_Third_Party_Controlled_Products_V2'];
        String htmlBody = null;
        String plainBody = null;
        String subject = null;
        String billingAddr = null;
        String shippingAddr = null;
        String quantity = null;
        String unitPrice = null;
        String[] toAddresses = null;
        Set<String> emailIds = new Set<String>();
        String hostname = URL.getSalesforceBaseUrl().toExternalForm();
        
        List<OrgWideEmailAddress> orgWideAddress = null;
        List<Country__c> countryList = null;
        ID emeaUsrId = null;
        ID snpUsrId = null;
        map<Id, String> mapEIProducts = new map<id,String>();
        
        for(OpportunityLineItem oplineItem :selectedLineItems){
            if(oplineItem.product2.EI_Product__c || test.isRunningTest()){
                 mapEIProducts.put(oplineItem.product2Id,oplineItem.product2.name);           
            }
         }
        
        if(!mapEIProducts.isEmpty()){
            List<String> emailList = new List<String>();
            orgWideAddress = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox'];
            countryList = new List<Country__c>([select id,Name from Country__c where region__c in ('EC-EMEA','EC -EMEA')]);
            if(Environment.isProduction()){
                emailList.add('EMEA_Export_Licensing@dell.com');
                emailList.add('SnP_OPS_Emerging@Dell.com');
                }else{
                    emailList.add('EMEA_Export_Licensing@dell.com.sit2');
                    emailList.add('SnP_OPS_Emerging@Dell.com.sit2');
                } 
            for(User usr:[select id,name,email from user where email in :emailList]){
                if('EMEA'.contains(usr.email)){
                    emeaUsrId = usr.id;
                }else if('SnP'.contains(usr.email)){
                    snpUsrId = usr.id;
                }
            }
            //Query email users.
            for(Country__c countryObj:countryList){
                countryMap.put(countryObj.name, countryObj.name);
            }
            
            
            for(Opportunity oppObj:mapRelatedOpportunities.values()){
                setAccountIds.add(oppObj.accountId);
            }  
            
            mapRelatedAcc = new map<id,Account>([Select id,(Select User.Email, TeamMemberRole From AccountTeamMembers) From Account where id in :setAccountIds]); 
        
        }
            
          
              
        for(OpportunityLineItem oplineItem : lstLineItems){
            if(mapEIProducts.containsKey(oplineItem.Product2Id) ||test.isRunningTest()){
                opp = mapRelatedOpportunities.get(oplineItem.OpportunityId);
                if((!countryMap.isEmpty() && countryMap.containsKey(opp.account.Account_Country__c)  && !'Turkey'.equalsIgnoreCase(opp.account.Account_Country__c)) || test.isrunningtest()){
                    oppLineItemObj = new OpportunityLineItem();
                    oppLineItemObj.id=oplineItem.id;
                    oppLineItemObj.exportRequired__c=true;
                    oppLineItemObj.Opportunity_Owner_Email__c = opp.Owner.Email;
                    oppLineItemToUpdateFlag.add(oppLineItemObj);
                    
                    opp.exportRequired__c = true;
                    oppToUpdateFlag.add(opp); 
                    if(opp.Account.BillingCountry != null ){
                        billingAddr = opp.Account.BillingStreet+' '+opp.Account.BillingCity+' '+opp.Account.BillingState+' '+opp.Account.BillingPostalCode+' '+opp.Account.BillingCountry;
                    }else{
                        billingAddr='';
                    }
                    if(opp.Account.ShippingCountry!=null){
                        shippingAddr = opp.Account.ShippingStreet+' '+opp.Account.ShippingCity+' '+opp.Account.ShippingState+' '+opp.Account.ShippingPostalCode+' '+opp.Account.ShippingCountry;
                    }else{
                        shippingAddr='';
                    }
                    
                    if(oplineItem.Quantity !=null){
                        quantity = String.valueOf(oplineItem.Quantity);
                    }else{
                        quantity='0';
                    }
                    if(oplineItem.UnitPrice !=null){
                        unitPrice = String.valueOf(oplineItem.UnitPrice);
                    }else{
                        unitPrice='0';
                    }
                    toAddresses = new String[]{};
                    emailIds.add(opp.Owner.id);
                    emailIds.add(opp.Account.Owner.id);
                    if(emeaUsrId!=null)
                    emailIds.add(emeaUsrId);
                    if(snpUsrId!=null)
                    emailIds.add(snpUsrId);
                                        
                    toAddresses = getAccTeamMembers(opp.AccountId,mapRelatedAcc,emailIds);
                    for(Integer x=0;x<toAddresses.size();x++){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     mail.setTargetObjectId(toAddresses[x]);
                     mail.setOrgWideEmailAddressId(orgWideAddress[0].Id);
                     subject = template.subject.replace('{!Opportunity.Name}', (opp.Name == null ? '' : opp.Name));
                     mail.setSubject(subject);
                     mail.saveAsActivity = false;
                     htmlBody = template.HTMLValue.replace('{!Opportunity.OwnerFullName}',(opp.Owner.Name == null ? '':opp.Owner.Name ));
                     htmlBody = htmlBody.replace('{!Opportunity.Deal_ID__c}', (opp.Deal_ID__c == null ? '' : opp.Deal_ID__c));
                     htmlBody = htmlBody.replace('{!Opportunity.Account}', (opp.account.Name == null ? '' : opp.account.Name));
                     htmlBody = htmlBody.replace('{!Account.BillingAddress}', billingAddr);
                     htmlBody = htmlBody.replace('{!Account.ShippingAddress}', shippingAddr);
                     htmlBody = htmlBody.replace('{!Opportunity.End_User_First_Name__c}', (opp.End_User_First_Name__c == null ? '' : opp.End_User_First_Name__c));
                     htmlBody = htmlBody.replace('{!Opportunity.End_User_Last_Name__c}', (opp.End_User_Last_Name__c == null ? '' : opp.End_User_Last_Name__c));
                     htmlBody = htmlBody.replace('{!Opportunity.End_User_Mailing_Street__c}', (opp.End_User_Mailing_Street__c == null ? '' : opp.End_User_Mailing_Street__c));
                     htmlBody = htmlBody.replace('{!Opportunity.End_User_Mailing_City__c}', (opp.End_User_Mailing_City__c == null ? '' : opp.End_User_Mailing_City__c));
                     htmlBody = htmlBody.replace('{!Opportunity.End_User_Mailing_State_Province_Region__c}', (opp.End_User_Mailing_State_Province_Region__c == null ? '' : opp.End_User_Mailing_State_Province_Region__c));
                     htmlBody = htmlBody.replace('{!Opportunity.End_User_Mailing_Country__c}', (opp.End_User_Mailing_Country__c == null ? '' : opp.End_User_Mailing_Country__c));
                     htmlBody = htmlBody.replace('{!Opportunity.End_User_Mailing_Zip_Postal_Code__c}', (opp.End_User_Mailing_Zip_Postal_Code__c == null ? '' : opp.End_User_Mailing_Zip_Postal_Code__c));
                     htmlBody = htmlBody.replace('{!OpportunityLineItem.Brand_Desc__c}', (oplineItem.Brand_Desc__c == null ? '' : oplineItem.Brand_Desc__c));
                     htmlBody = htmlBody.replace('{!OpportunityLineItem.Quantity}', quantity);
                     htmlBody = htmlBody.replace('{!OpportunityLineItem.UnitPrice}', unitPrice);
                     htmlBody = htmlBody.replace('{!OpportunityLineItem.CurrencyIsoCode}', (oplineItem.CurrencyIsoCode == null ? '' : oplineItem.CurrencyIsoCode));
                     htmlBody = htmlBody.replace('{!Opportunity.Distributor_ID__c}', (opp.Distributor_ID__c == null ? '' : opp.Distributor_ID__c));
                     htmlBody = htmlBody.replace('{!Opportunity.OwnerEmail}', (opp.Owner.Email == null ? '' : opp.Owner.Email));
                     htmlBody = htmlBody.replace('{!Opportunity.OwnerPhone}', (opp.Owner.Phone == null ? '' : opp.Owner.Phone));
                     htmlBody = htmlBody.replace('{!Opportunity.Quote_Numbers__c}', (opp.Quote_Numbers__c == null ? '' : opp.Quote_Numbers__c));
                     htmlBody = htmlBody.replace('{!Opportunity.Order_Number__c}', (opp.Order_Number__c == null ? '' : opp.Order_Number__c));
                     htmlBody = htmlBody.replace('{!Opportunity.Link}', (hostname == null ? '' : hostname+'/'+opp.id));
                     
                     
                     plainBody = template.body.replace('{!Opportunity.OwnerFullName}',(opp.Owner.Name == null ? '':opp.Owner.Name ));
                     plainBody = plainBody.replace('{!Opportunity.Deal_ID__c}', (opp.Deal_ID__c == null ? '' : opp.Deal_ID__c));
                     plainBody = plainBody.replace('{!Opportunity.Account}', (opp.account.Name == null ? '' : opp.account.Name));
                     plainBody = plainBody.replace('{!Account.BillingAddress}', billingAddr);
                     plainBody = plainBody.replace('{!Account.ShippingAddress}', shippingAddr);
                     plainBody = plainBody.replace('{!Opportunity.End_User_First_Name__c}', (opp.End_User_First_Name__c == null ? '' : opp.End_User_First_Name__c));
                     plainBody = plainBody.replace('{!Opportunity.End_User_Last_Name__c}', (opp.End_User_Last_Name__c == null ? '' : opp.End_User_Last_Name__c));
                     plainBody = plainBody.replace('{!Opportunity.End_User_Mailing_Street__c}', (opp.End_User_Mailing_Street__c == null ? '' : opp.End_User_Mailing_Street__c));
                     plainBody = plainBody.replace('{!Opportunity.End_User_Mailing_City__c}', (opp.End_User_Mailing_City__c == null ? '' : opp.End_User_Mailing_City__c));
                     plainBody = plainBody.replace('{!Opportunity.End_User_Mailing_State_Province_Region__c}', (opp.End_User_Mailing_State_Province_Region__c == null ? '' : opp.End_User_Mailing_State_Province_Region__c));
                     plainBody = plainBody.replace('{!Opportunity.End_User_Mailing_Country__c}', (opp.End_User_Mailing_Country__c == null ? '' : opp.End_User_Mailing_Country__c));
                     plainBody = plainBody.replace('{!Opportunity.End_User_Mailing_Zip_Postal_Code__c}', (opp.End_User_Mailing_Zip_Postal_Code__c == null ? '' : opp.End_User_Mailing_Zip_Postal_Code__c));
                     plainBody = plainBody.replace('{!OpportunityLineItem.Brand_Desc__c}', (oplineItem.Brand_Desc__c == null ? '' : oplineItem.Brand_Desc__c));
                     plainBody = plainBody.replace('{!OpportunityLineItem.Quantity}', quantity);
                     plainBody = plainBody.replace('{!OpportunityLineItem.UnitPrice}', unitPrice);
                     plainBody = plainBody.replace('{!OpportunityLineItem.CurrencyIsoCode}', (oplineItem.CurrencyIsoCode == null ? '' : oplineItem.CurrencyIsoCode));
                     plainBody = plainBody.replace('{!Opportunity.Distributor_ID__c}', (opp.Distributor_ID__c == null ? '' : opp.Distributor_ID__c));
                     plainBody = plainBody.replace('{!Opportunity.OwnerEmail}', (opp.Owner.Email == null ? '' : opp.Owner.Email));
                     plainBody = plainBody.replace('{!Opportunity.OwnerPhone}', (opp.Owner.Phone == null ? '' : opp.Owner.Phone));
                     plainBody = plainBody.replace('{!Opportunity.Quote_Numbers__c}', (opp.Quote_Numbers__c == null ? '' : opp.Quote_Numbers__c));
                     plainBody = plainBody.replace('{!Opportunity.Order_Number__c}', (opp.Order_Number__c == null ? '' : opp.Order_Number__c));
                     plainBody = plainBody.replace('{!Opportunity.Link}', (hostname == null ? '' : hostname+'/'+opp.id));
                     
                     mail.setHtmlBody(htmlBody);
                     mail.setPlainTextBody(plainBody);
                     mails.add(mail);
                    }
                }
            }
        }
                
        if(!oppLineItemToUpdateFlag.isEmpty() && !oppToUpdateFlag.isEmpty()) {
            if (!Test.isrunningTest()){
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(true); // 2.0: Skip trigger when it is not test context. If to skip trigger during test context, control in test method
            }
            GlobalVariables.SKIP_OPP_LINEITEM_TRIGGERS = true;
            update oppLineItemToUpdateFlag;
            update new List<Opportunity>(oppToUpdateFlag);
            GlobalVariables.SKIP_OPP_LINEITEM_TRIGGERS = false;
            if (!Test.isrunningTest()){
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(false); // 2.0: Skip trigger when it is not test context. If to skip trigger during test context, control in test method
            }
            
            if(mails.size() > 0){
                Messaging.sendEmail(mails);                
            }            
        }
    }
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0          11498        16.07         22-May-2015     Prateek         Update LOT indicator on Opportunity Product
    2.0         13171       FY17-DCS-0701   3-Jun-2016      Fenny           To resolve "Too many SOQL queries: 101"
    3.0         CR 14471    FY18-DCS-0802   13-June-2017    Akshita         Replaced the Hard-coded stage names to the names given in OWD__c custom settings and added the value for 'Order-Submitted - 99%' stage
    4.0        CR 17088     FY20-DCE-0402   23rd-Jan-2019   Vasavi.M        Fix the null pointer exception, with countries that are in the bucket Other on the Primary Product Delivery Adress Region 
    5.0         CR17974     FY20-DCE-1002   30-Aug-2019     Shubham B   updated the updateLOTIndicator(Adding checks to bypass the method for APOS opportunities)
    */ 
    public static void updateLOTIndicator(TriggerHandler.TriggerEvent trigEvent, map<Id, Opportunity> mapOppData)
    {         
        system.debug('Entered into updateLOTIndicator == >> mapOppData : '+mapOppData.values());
        /********************START***Added by Shubham B ***STORY 7163735 - To remove APOS opportunities from the whole method****************************/
        map<id, opportunity> mapNonRenewalsOpties = new map<id, opportunity>();
        for(Opportunity opp:mapOppData.values()){
            If (!((opp.recordtypeid == RenewalsConstants.aposRecordTypeId) && (opp.Source_System__c == RenewalsConstants.strsourceSystemEMCCore || opp.Source_System__c == RenewalsConstants.strsourceSystemRenewalsEBIA ||opp.type == RenewalsConstants.strtypeEMCRenewalsDirect || opp.type == RenewalsConstants.strtypeEMCRenewalsInDirect))){
                if(!mapNonRenewalsOpties.containsKey(opp.id)){
                    mapNonRenewalsOpties.put(opp.id,opp);
                }
            }
            
        }        
        if(mapNonRenewalsOpties.isEmpty()){
            return;
        }
          /********************STOP***Added by Shubham B ***STORY 7163735 - To remove APOS opportunities from the whole method****************************/
        set<Id> setPBEId = new Set<Id>();
        set<Id> setOppId = new Set<Id>();

        
        //Map to collect records from ocean data object
        Map<String, Ocean_Data__c> oceanDataMap = new Map<String, Ocean_Data__c>();
        
        Map<String, Lot_Region__c> mapLotRegion = new Map<String, Lot_Region__c>();
        
        //Query Lot Region__c
        for(Lot_Region__c objLR : [SELECT Name,Region__c,RM_Country__c,Threshold_Region__c FROM LOT_Region__c])
        {
           mapLotRegion.put(objLR.Name.toUpperCase() + '|' + objLR.Region__c.toUpperCase(), objLR);
        }  
                
       // system.debug('Map : '+mapLotRegion);
        //Query Ocean Data
        List<Ocean_Data__c> oceanRecords = [SELECT Source__c, Ship_Rate__c, Pallet_Rate__c, Region__c, Exception_Country__c,
                                        CFS_Delivery_Time_in_Weeks__c, CFI_Delivery_Time_in_Weeks__c, MSP_Incremental_in_Weeks__c,
                                        Days_in_country_Delivery__c,On_the_sea_by_ODM__c,Pallet_Multiplier_Factor__c,Container_Multiplier_Factor__c
                                        FROM Ocean_Data__c];
                                        
        for(Ocean_Data__c obj : oceanRecords) {
            if(obj.Exception_Country__c != null) {
                oceanDataMap.put((obj.Source__c.toUpperCase() + '-' + obj.Exception_Country__c.toUpperCase()), obj);
            } else { 
                oceanDataMap.put((obj.Source__c.toUpperCase() + '-' + obj.region__c.toUpperCase()), obj);
            }
        }
             // system.debug('oceanDataMap :'+oceanDataMap);
        
        if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT || trigEvent == TriggerHandler.TriggerEvent.ISUPDATE)
        {
            for(Opportunity opp:mapNonRenewalsOpties.values()){//STORY 7163735 - changing map variable here - using the non renewal opportuinities map 
               
                    for(OpportunityLineItem oliIterator : opp.OpportunityLineItems)
                    {
                        setPBEId.add(oliIterator.PricebookEntryId);
                    }
            }
        }
        //system.debug('setPBEId :'+setPBEId);
         //for getting picklist values from custom setting
        OWD__c obj = OWD__c.getOrgDefaults();
   
        String win = obj.Oppty_Stage100__c;  
        String propose = obj.Oppty_Stage60__c;    
        String comit = obj.Oppty_Stage90__c;         
        String order_submitted = obj.Oppty_Stage99__c;
        
        List<OpportunityLineItem> lstOpportunityToUpdate = new List<OpportunityLineItem>();
        if(!setPBEId.isEmpty())
        {                   
            Map<Id, PricebookEntry> mapPBEIdTOPBE = new Map<Id, PricebookEntry>([SELECT Id, Product2Id, Product2.Source__c, Product2.Pallet_Quantity__c, Product2.Container_Volume__c, Product2.AMER__c, Product2.APJ_ASIA__c, Product2.APJ_China__c, Product2.APJ_ICC__c, Product2.APJ_HK_JPN_KOR__c, Product2.Brazil__c, Product2.EMEA__c, Product2.FED__c, Product2.LATAM__c FROM PricebookEntry WHERE Id IN : setPBEId]);
            for(Opportunity opp:mapNonRenewalsOpties.values()){
                for(OpportunityLineItem oliIterator : opp.OpportunityLineItems)
                {
                    if((trigEvent == TriggerHandler.TriggerEvent.ISINSERT || trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) && (mapNonRenewalsOpties.get(oliIterator.OpportunityId).StageName == propose || mapNonRenewalsOpties.get(oliIterator.OpportunityId).StageName == order_submitted || mapNonRenewalsOpties.get(oliIterator.OpportunityId).StageName == comit || mapNonRenewalsOpties.get(oliIterator.OpportunityId).StageName == win))
                    {
                        if(mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c != null && mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c != null)
                        {
                            String s = mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c;
                            string s1 = mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c;
                            String s2 = s1+ '|' +s;
                            
                            //V4.0
                            //String thresholdRegion = mapLotRegion.get(mapOppData.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c + '|' + mapOppData.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c).Threshold_Region__c;
                            String thresholdRegion = mapLotRegion.get((mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c).touppercase() + '|' + 
                                                                      (mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c).touppercase()).Threshold_Region__c;
                            
                            //System.debug('***thresholdRegion is--->'+ ''+thresholdRegion);
                            
                            if(thresholdRegion == 'AMER' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.AMER__c != null)
                            {
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.AMER__c <= oliIterator.Quantity) ? true : false;
                            }
                            else if(thresholdRegion == 'APJ ASIA' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.APJ_ASIA__c != null)
                            {
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.APJ_ASIA__c <= oliIterator.Quantity) ? true : false;
                            }
                            else if(thresholdRegion == 'APJ China' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.APJ_China__c != null)
                            {
                                
                                
                                
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.APJ_China__c <= oliIterator.Quantity) ? true : false;
                            }
                            else if(thresholdRegion == 'APJ India' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.APJ_ICC__c != null)
                            {
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.APJ_ICC__c <= oliIterator.Quantity) ? true : false;
                            }
                            else if(thresholdRegion == 'APJ HONG KONG, JAPAN & KOREA' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.APJ_HK_JPN_KOR__c != null)
                            {
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.APJ_HK_JPN_KOR__c <= oliIterator.Quantity) ? true : false;
                            }
                            else if(thresholdRegion == 'Brazil' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Brazil__c != null)
                            {
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Brazil__c <= oliIterator.Quantity) ? true : false;
                            }
                            else if(thresholdRegion == 'EMEA' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.EMEA__c != null)
                            {
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.EMEA__c <= oliIterator.Quantity) ? true : false;
                            }
                            else if(thresholdRegion == 'FED' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.FED__c != null)
                            {
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.FED__c <= oliIterator.Quantity) ? true : false;
                            }
                            else if(thresholdRegion == 'LATAM' && mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.LATAM__c != null)
                            {
                                oliIterator.LOT_Indicator__c = (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.LATAM__c <= oliIterator.Quantity) ? true : false;
                            }
                        }
                         
                         //Collect pallet multiplier factor and container multiplier factor from ocean data based on source, country and region.
                         
                         Double pallet_multiplier_factor;
                         Double container_multiplier_factor;    
                         if(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c !=null && mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c !=null){
                             if(oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c.toUpperCase()) != null)
                             {
                                pallet_multiplier_factor = oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c.toUpperCase()).Pallet_Multiplier_Factor__c;
                                container_multiplier_factor = oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c.toUpperCase()).Container_Multiplier_Factor__c;
                             } 
                             else{
                                if(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c != null && mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c != null){
                                    if(oceanDataMap.size()> 0){
                                        if(oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c.toUpperCase()) != null){
                                          pallet_multiplier_factor = oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c.toUpperCase()).Pallet_Multiplier_Factor__c;
                                        }
                                        if(oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c.toUpperCase()) != null){
                                          container_multiplier_factor = oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c.toUpperCase()).Container_Multiplier_Factor__c;
                                        }
                                    }
                                }
                             }
                         }
                         
                         //Check if pallet multiplier factor is null
                         if(pallet_multiplier_factor == null){
                             pallet_multiplier_factor = 1;
                         }
                         
                         //Check if container multiplier factor is null
                         if(container_multiplier_factor == null){
                             container_multiplier_factor = 1;
                         }
                         
                         //Check if opportunity product quantity is grater than or equal to product pallet quantity * pallet multiplier factor or container volume * container multiplier factor.
                         try{
                             if(mapPBEIdTOPBE.size() > 0 && (oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapNonRenewalsOpties.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Region__c.toUpperCase()) != null||oceanDataMap.get(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Source__c.toUpperCase()+'-'+mapOppData.get(oliIterator.OpportunityId).Primary_Product_Delivery_Address_Country__c.toUpperCase()) != null)){
                                  if(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Pallet_Quantity__c != null){
                                         if(oliIterator.Quantity >= (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Pallet_Quantity__c * pallet_multiplier_factor)){
                                           //Assign the Ocean Indicator true for ocean.
                                           oliIterator.Ocean_Indicator__c = true;      
                                         }
                                         else
                                         {
                                           oliIterator.Ocean_Indicator__c = false;
                                         }
                                   }
                                   else if(mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Container_Volume__c != null)
                                   {
                                        if(oliIterator.Quantity >= (mapPBEIdTOPBE.get(oliIterator.PricebookEntryId).Product2.Container_Volume__c * container_multiplier_factor)){
                                           //Assign the Ocean Indicator true for ocean.
                                           oliIterator.Ocean_Indicator__c = true;  
                                        }
                                        else
                                        {
                                           oliIterator.Ocean_Indicator__c = false;
                                        }
                                   }
                            }
                            else{
                                oliIterator.Ocean_Indicator__c = false;
                            }
                        }
                        catch(Exception ex){
                            oliIterator.Ocean_Indicator__c = false;
                        }
                    }
                    else{
                        oliIterator.Ocean_Indicator__c = false;
                        oliIterator.LOT_Indicator__c = false;
                    }
                    lstOpportunityToUpdate.add(oliIterator);
                }//For loop ends here
            }
            if(!lstOpportunityToUpdate.isEmpty()){
               //skip lineitem trigger
               if (!Test.isrunningTest()){ // 2.0: Skip trigger when it is not test context. If to skip trigger during test context, control in test method
                    TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
               }
               
               //update lstOpportunityToUpdate;
               Database.SaveResult[] sr =  Database.update(lstOpportunityToUpdate,false);
               if (!Test.isrunningTest()){ // 2.0: Skip trigger when it is not test context. If to skip trigger during test context, control in test method
                    TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
               }
               
               for (Database.SaveResult srObj : sr) {
                    if (srObj.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated Opportunity Line Item: ' + srObj.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : srObj.getErrors()) {
                            System.debug('Error:'+err.getMessage());
                        }
                    }
               }
            }
        }
    }
    
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         11559       16.07           02-June-2015    Prateek         Update Supportability Indicator on Opportunity
    2.0         13171       FY17-DCS-0701   26-May-2016     Fenny           Skip opportunity triggers
    3.0         13449       FY17-DCS-1002   29-Aug-2016     Afiq            Place rollup precedence__c of status in the following order: Not Supportable, Expired, Risk, Under Review, Supportable
    */    
    public static void updateSupportabilityIndicator(TriggerHandler.TriggerEvent trigEvent, list<OpportunityLineItem> lstLineItems, map<Id, sObject> mapOldLineItems)
    {        
        set<Id> setOppId = new Set<Id>();
        
        if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT)
        {
            for(OpportunityLineItem oliIterator : lstLineItems)
            {
                setOppId.add(oliIterator.OpportunityId);
            }
        }
        else if(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE)
        {
            for(OpportunityLineItem oliIterator : lstLineItems)
            {
                if(oliIterator.Supportability_Status__c != ((Map<Id, OpportunityLineItem>)mapOldLineItems).get(oliIterator.Id).Supportability_Status__c)
                {
                    setOppId.add(oliIterator.OpportunityId);
                }
            }
        }
        
        if(!setOppId.isEmpty())
        {
            Map<String, Supportability_Status_Mapping__c> mapSupportabilityStatusToPrecedence = new Map<String, Supportability_Status_Mapping__c>();
            if(!Test.isrunningTest())
            {
                mapSupportabilityStatusToPrecedence = Supportability_Status_Mapping__c.getAll();
            }
            else
            {
                Map<String, Supportability_Status_Mapping__c> mapSupportabilityStatusToPrecedence_test = new Map<String, Supportability_Status_Mapping__c>{//3.0 Starts here
                                                                                                                                            'Not Supportable'=>new Supportability_Status_Mapping__c(Name='Not Supportable', Precedence__c=0.0),
                                                                                                                                            'Expired'=>new Supportability_Status_Mapping__c(Name='Expired', Precedence__c=1.0),
                                                                                                                                            'Risk'=>new Supportability_Status_Mapping__c(Name='Risk', Precedence__c=2.0),
                                                                                                                                            'Under Review'=>new Supportability_Status_Mapping__c(Name='Under Review', Precedence__c=3.0),
                                                                                                                                            'Supportable'=>new Supportability_Status_Mapping__c(Name='Supportable', Precedence__c=4.0)                                                                                                                              
                                                                                                                                            //3.0 Ends Here
                                                                                                                                            };
                mapSupportabilityStatusToPrecedence = mapSupportabilityStatusToPrecedence_test;
            }
            
            Map<Integer, String> mapPrecedenceToSupportabilityStatus = new Map<Integer, String>();
            
            for(Supportability_Status_Mapping__c objSSM : mapSupportabilityStatusToPrecedence.values())
            {
                mapPrecedenceToSupportabilityStatus.put(Integer.valueOf(objSSM.Precedence__c), objSSM.Name);
            }
            
            Map<Id, Opportunity> mapOppData = new Map<Id, Opportunity>([SELECT Id, Supportability_Status__c, (SELECT Id, Supportability_Status__c FROM OpportunityLineItems WHERE Supportability_Status__c != null) FROM Opportunity WHERE Id IN : setOppId]);
        
            Map<Id, Integer> mapOppIdToPrecedence = new Map<Id, Integer>();
            List<Opportunity> lstOpp = new List<Opportunity>();
            for(Opportunity objOpp : mapOppData.values())
            {   
                if(objOpp.OpportunityLineItems.size() > 0)
                {     
                    for(OpportunityLineItem objOLI : objOpp.OpportunityLineItems)
                    {
                        if(objOLI.Supportability_Status__c != null){
                            if(!mapOppIdToPrecedence.containsKey(objOpp.Id))
                            {
                                mapOppIdToPrecedence.put(objOpp.Id, Integer.valueOf(mapSupportabilityStatusToPrecedence.get(objOLI.Supportability_Status__c).Precedence__c));
                            }                    
                            else if(mapOppIdToPrecedence.containsKey(objOpp.Id) && mapOppIdToPrecedence.get(objOpp.Id) > Integer.valueOf(mapSupportabilityStatusToPrecedence.get(objOLI.Supportability_Status__c).Precedence__c))
                            {
                                mapOppIdToPrecedence.put(objOpp.Id, Integer.valueOf(mapSupportabilityStatusToPrecedence.get(objOLI.Supportability_Status__c).Precedence__c));
                            }
                        }
                    }
                }
                else
                {
                    lstOpp.add(new Opportunity(Id = objOpp.Id, Supportability_Status__c = ''));
                }
            }

            
            if(!mapOppIdToPrecedence.isEmpty())
            {               
                
                for(Id OppId : mapOppIdToPrecedence.keySet())
                {
                    if(mapOppData.get(OppId).Supportability_Status__c != mapPrecedenceToSupportabilityStatus.get(mapOppIdToPrecedence.get(OppId)))
                    {
                        lstOpp.add(new Opportunity(Id = OppId, Supportability_Status__c = mapPrecedenceToSupportabilityStatus.get(mapOppIdToPrecedence.get(OppId))));
                    }                   
                }
            }
            if(!lstOpp.isEmpty())
            {
                if (!Test.isrunningTest()){
                    TriggerExecutionController.setSkipOpportunityTriggers(true); // 2.0
                }
                
                String strCurrentUserProfile = StaticFactory.getCurrentUserDetails().Profile.Name;
                if(strCurrentUserProfile == 'Boomi Integration API Only' || strCurrentUserProfile == 'IT Integration API Only')
                {
                    Database.SaveResult[] results = Database.Update(lstOpp, false);
                }
                else
                {
                    update lstOpp;
                }
                if (!Test.isrunningTest()){
                    TriggerExecutionController.setSkipOpportunityTriggers(false); // 2.0
                }
                
            }
        }
    }
    private static ID[] getAccTeamMembers(Id accountId,map<id,Account> mapRelatedAcc,Set<String> emailIds){
        ID[] emailStr = new ID[]{};
        
        if(mapRelatedAcc.containsKey(accountId)){
            Account acc = mapRelatedAcc.get(accountId);
            List<AccountTeamMember> accTeam = acc.AccountTeamMembers;
            for(AccountTeamMember accTeamObj:accTeam){
                if(accTeamObj.User.Email !=null && ('Account Executive'.equalsIgnoreCase(accTeamObj.TeamMemberRole) || 'Inside Sales Rep'.equalsIgnoreCase(accTeamObj.TeamMemberRole))){
                    emailIds.add(accTeamObj.User.ID);
                }
            }
            
            for(String emails:emailIds){
                emailStr.add(emails);
            }
        }
        return emailStr;
    }   
     /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0          CR11598        16.07     02-July-2015     Azwanti      to track field history of OpportunityLineItem
    */    
     
    public static void generateSupportabilityFieldHistory(Map<Id, sObject> newOpportunityLineItemRec){
        set<Id> setOpportunityIds = new set<Id>();
        List<sObject> newOpptyLineItemList = new List<sObject>();
        Map<Id, sObject> newOLIMap = new Map<Id, sObject>();
        
        //get OpportunityId 
        for(Id oliId : newOpportunityLineItemRec.keySet()) {
            
            setOpportunityIds.add(oliId);   
        }
        
        //get all OpportunityLineItem fields then query
        Map<String, Schema.SObjectType> mapSObjectNameToSObjects = Schema.getGlobalDescribe();
        Schema.SObjectType source_ObjType = mapSObjectNameToSObjects.get('OpportunityLineItem');
        Schema.DescribeSObjectResult source_DescribeResult = source_ObjType.getDescribe();
        Map<String, Schema.SObjectField> mapSourceFieldNameToFields = source_DescribeResult.fields.getMap();
        
        String query = 'SELECT ';
        
        for(String fieldName : mapSourceFieldNameToFields.keySet())
        {
            query = query + fieldName + ', ';
        }
        
        query = query.removeEnd(', ');
        query = query + ' FROM OpportunityLineItem Where Id In (';
        
        for(string opptyLineItemID: setOpportunityIds){
            query = query + '\'' + opptyLineItemID + '\'';
            query = query + ', ';
        }
        query = query.removeEnd(', '); 
        query = query + ')'; 
        
        newOLIMap = new Map<Id, sObject>(Database.query(query));
        //create Supportability Field History
        CustomFieldHistoryTracker.trackFieldHistory('OpportunityLineItem', 'Supportability_Field_History__c', 'Supportability_Field_Tracking__c', 'OpportunityId', 'Opportunity__c', trigger.oldMap, newOLIMap);
    }
    
    
     /*
    
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR11414     16.07(MAJ-S-01) 30-Apr-2015     Krishnamoorthi  Created this method to populate Opportunity fields Product_Group_Hidden and Product_Brand_Hidden         
    2.0			CR18307		FY20-0102		25-Nov-2019		Fenny			Accessible OpportunityLineItem RecordSelector
    */
    
      public static void updateFieldsForSAVO(OpportunityLineItemTriggerHandler oliTriggerHandler) {
   
          Map<Id, Opportunity> mapRelatedOpps = OpportunityLineItemTriggerHandler.oliRecordSelector.mapRelatedOpportunities;
          Map<Id, OpportunityLineItem> mapOLI = OpportunityLineItemTriggerHandler.oliRecordSelector.mapAllRelatedOLIs;
          Map<Id, Opportunity> mapoppToUpdate = new Map<Id, Opportunity>();
          
          Id standardOppRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');
          Id channelOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId();
          for(Opportunity opp : mapRelatedOpps.values()) {        
              //Select only "Standard Opportunity"for update
              if(opp.RecordTypeId == standardOppRTId || opp.RecordTypeId == channelOppRTId) {
                  mapoppToUpdate.put(opp.Id, opp);
              }    
          }                  
          try {
                
                if(!mapoppToUpdate.isEmpty())
                    if (!Test.isrunningTest()){
                        TriggerExecutionController.setSkipOpportunityTriggers(true);
                    }
                    update mapoppToUpdate.values();
                    if (!Test.isrunningTest()){
                        TriggerExecutionController.setSkipOpportunityTriggers(false);
                    }
            }  
            catch(Exception e) {
                System.debug('###DEBUG### caught exception in updateFieldsForSAVO- ' + e.getMessage());
            
            }    
      } //CR11414 -- End
      
     /*
    Revision    Defect Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0          184551         16.07     28-July-2015     Krishnakumar M      Updating Supportablility last update. - mo
    */      
    
    public static void updateSupportability_Last_Updated(TriggerHandler.TriggerEvent trigEvent, list<OpportunityLineItem> lstLineItems, map<Id, OpportunityLineItem> mapOldLineItems) {
        OpportunityLineItem oldOppli = null;
        for(OpportunityLineItem oliObj :lstLineItems){
            if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                    if(String.isNotBlank(oliObj.Supportability_Comments__c) || 
                        String.isNotBlank(oliObj.Supportability_Status__c) || 
                            oliObj.Support_by_Date__c != null || 
                                oliObj.Supported_Quantity__c!=null || 
                                    String.isNotBlank(oliObj.Alternate_Item__c)){
                        oliObj.Supportability_Last_Updated__c = System.now();
                    }
            }else{
                if(mapOldLineItems.containsKey(oliObj.id)){
                    oldOppli = mapOldLineItems.get(oliObj.id);
                    if( (oliObj.Supportability_Comments__c!=oldOppli.Supportability_Comments__c) ||
                            (oliObj.Supportability_Status__c!=oldOppli.Supportability_Status__c) ||
                                (oliObj.Support_by_Date__c!=oldOppli.Support_by_Date__c) ||
                                    (oliObj.Supported_Quantity__c!=oldOppli.Supported_Quantity__c) ||
                                        (oliObj.Alternate_Item__c!=oldOppli.Alternate_Item__c))
                    {
                            oliObj.Supportability_Last_Updated__c = System.now();
                    }
                    
                }
                
            }
        }
        
        
    }
    
    /*
    Revision    Defect Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0                         16.10   21-Oct-2015     Azwanti         validate Quote # if updates come from Boomi
    */ 

    public static void validateQuoteFromBoomi(list<OpportunityLineItem> lstLineItems, map<Id, OpportunityLineItem> mapOldLineItems){
        
        OpportunityLineItem oldOli = null;
        String strCurrentUserProfile = StaticFactory.getCurrentUserDetails().Profile.Name;
        
        for(OpportunityLineItem oliObj :lstLineItems){
            if(strCurrentUserProfile.contains('Boomi Integration API Only')){
                if(mapOldLineItems.containsKey(oliObj.id)){
                    oldOli = mapOldLineItems.get(oliObj.id);
                    if(oliObj.Quote__c != oldOli.Quote__c){
                        oliObj.addError('Quote Number mismatch between SFDC and LOW tool.');        
                    }    
                }
            }        
        }    
    } 
    /*  Revision     CR Number      Release No      Date            Modified By       Description
        --------     ---------      ----------      -----------     ------------      -----------
        1.0          12306          16.12           09-Nov-2015     Jiji              Restrict Partners from adding new Channel LOBs to existing approved deals
   
    */    
    
    public static void RestrictNewlineItemsforApproveddeals(TriggerHandler.TriggerEvent trigEvent, list<OpportunityLineItem> lstLineItems, map<Id, sObject> mapOldLineItems){        
        //Variable declaration
        set<Id> OppIdSet = new Set<Id>();
        Map<Id, Set<String>> relatedOLIMap = new Map<Id, Set<String>>();
        Map<Id, Opportunity> relatedOpportunityMap = new Map<Id, Opportunity>();
        //Query the current user details to check whether he is a Partner user or not
        List<User> loggedInUserList = [Select Id, IsActive, IsPortalEnabled From USer where Id = :UserInfo.getUserId()];
        try{
            //The validation is available only for Partner users
            If(loggedInUserList[0].IsPortalEnabled == TRUE  ){
                if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                    //collect the opportunity Ids of new products
                    for(OpportunityLineItem oliIterator : lstLineItems){
                        OppIdSet.add(oliIterator.OpportunityId);
                    }
                    system.debug(LoggingLevel.Error,'@@@OppIdSet@@'+OppIdSet);
                    If(OppIdSet.Size() > 0 ){
                        //Query the respective opportunity to get the deal registration status
                        for (Opportunity o : [Select Id, Deal_Registration_Status__c From Opportunity Where Id IN :OppIdSet]){
                            relatedOpportunityMap.Put(o.Id, o);
                        }
                        //Query the opportunity line item to get all tehh line items correponding to the opportunity associated to the new opp prod
                        for (OpportunityLineItem oli : [select Id, Channel_Product_LOB__c,  OpportunityId, Opportunity.Deal_Registration_Status__c
                                                        from OpportunityLineItem
                                                        where  OpportunityId In :OppIdSet
                                                        ]
                        ) {
                        system.debug(LoggingLevel.Error,'@@@oli @@'+oli );
                            Set<String> oliCPLOBStringSet = new Set<String>();
                            String newOLICPLString = oli.Channel_Product_LOB__c;
                            //convert the chnalle product LOB value to lower case as the check is case insensitive
                            If(newOLICPLString != NULL && newOLICPLString != ''){
                                newOLICPLString= newOLICPLString.toLowerCase();
                            
                                if(newOLICPLString.contains(',')){ 
                                     //Split the values in channel product LOB field if it contains multiple values    
                                     String[] newStringSet = newOLICPLString.split('\\,');
                                     oliCPLOBStringSet.addAll(newStringSet);
                                }
                                else{
                                     oliCPLOBStringSet.add(newOLICPLString);
                                }
                                //Create a map of Opportunity to the set of values in the channel product LOB field in the related opportunity line items
                                if(relatedOLIMap.containsKey(oli.OpportunityId)) {
                                    relatedOLIMap.get(oli.OpportunityId).addAll(oliCPLOBStringSet);
                                } 
                                else {
                                    relatedOLIMap.put(oli.OpportunityId, oliCPLOBStringSet);
                                }
                            }
                        }    
                    }
                    for(OpportunityLineItem oliIterator : lstLineItems){
                    system.debug(LoggingLevel.Error,'@@@oliIterator@@'+oliIterator);
                        String oppApprovalStatusString = relatedOpportunityMap.get(oliIterator.OpportunityId).Deal_Registration_Status__c;
                        //Validation is available only for approved deals
                        If(oppApprovalStatusString == 'Approved'){ 
                            String cplString = oliIterator.Channel_Product_LOB__c; 
                            Set<String> cplStringSetfornewoli = new Set<String>();
                            system.debug(LoggingLevel.Error,'@@@cplString @@'+cplString );
                            //Validation message will be shown, if the Channel Product LOB field in new product is blank
                           
                            If(cplString == NULL || cplString == ''){
                                     
                                oliIterator.addError(system.Label.RestrictNewProductsinApprovedDeals);
                            }
                            else{
                                cplString =  cplString.toLowerCase();
                                If(cplString.Contains(',') ){
                                    //Split the values in channel product LOB field of existing products, if it contains multiple values    
                                    String[] cplStringSet= cplString.split('\\,'); 
                                    cplStringSetfornewoli.addAll(cplStringSet);
                                }
                                else{
                                    cplStringSetfornewoli.add(cplString);
                                }
                                
                                If(relatedOLIMap.get(oliIterator.OpportunityId) != NULL ){
                                    Set<String> stringSet = relatedOLIMap.get(oliIterator.OpportunityId); 
                                  
                                    for(String s : cplStringSetfornewoli){
                                        //Check if the channel product LOB Value in new product is available in any of the existing products or not.
                                        //If not available, throw an error message.
                                        If(!stringSet.Contains(s)){
                                            oliIterator.addError(system.Label.RestrictNewProductsinApprovedDeals);
                                        }
                                    } 
                                }
                                else{
                                    //oliIterator.addError('Please contact your Channel Sales team or Deal Registration team to add additional Product Lines of Business to the approved deal registration.');
                                    oliIterator.addError(system.Label.RestrictNewProductsinApprovedDeals);
                                }
                            }
                        }
                    }
                }
            }
    
        } 
        Catch(exception e){
            System.debug('---Exception occured in RestrictNewlineItemsforApproveddeals---'+e);
        }
    }
    
    /*  Revision  CR Number       Release No      Date            Modified By       Description
    --------     ---------      ----------     -----------     ------------      -----------
    1.0           12348          16.12         16-Nov-2015      Dipin Raju       To validate Customer Requested Date based on Book Date
   
    */  

     public static void validateCustReqDate(TriggerHandler.TriggerEvent trigEvent, list<OpportunityLineItem> lstLineItems, map<Id, sObject > mapOldLineItems){
 
        String BoomiProfile = UserInfo.getProfileId();  

        if(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
            
                for(OpportunityLineItem oliObj :lstLineItems){
                    If (!(BoomiProfile.contains('00eA0000000hNqF') || BoomiProfile.contains('005A0000006Tulp'))){ 
                        if(oliObj.Request_Type__c=='Ship' && oliObj.Customer_Requested_Date__c <(oliObj.Opportunity_Book_Date__c+14)){
                            oliObj.addError('For Ship Request Type, Customer Requested Date must be 2 weeks greater than Book Date');
                        }
                         if(oliObj.Request_Type__c=='Delivery' && oliObj.Customer_Requested_Date__c <(oliObj.Opportunity_Book_Date__c+21)){
                            oliObj.addError('For Delivery Request Type, Customer Requested Date must be 3 weeks greater than Book Date');
                        }
                    }
                }
            
        }
     }
    
    /*
        Revision    CR Number   Release No     Date           Modified By     Description
        --------    ---------   ------------   -----------    ------------    -----------
        1.0         CR13201     FY17-Sprint9   02-06-2016     Kenny Chong     Create entry in Oppty_Product_Deleted__c object for each deleted EMC Product.
        1.1         CR13201     FY17-Sprint10  07-06-2016     Afiq            Added the logic to check on Sales Motion of the deleted opportunity line item
        1.2         CR          FY17-Sprint26  18-01-2017     Afiq            Change the logic from checking sales motion flag to EMC Opportunity Product ID
        1.3         CR14110     FY18-SP05      29-03-2017     Syidah          Rename Dell Changed to Waiting Sync  
    */
    public static void backupEMCOpportunityLineItem(list<OpportunityLineItem> lstOppLineItems) {
        
        
        String BoomiProfile = UserInfo.getProfileId();  
        list<Oppty_Product_Deleted__c> lstProductDeleted = new list<Oppty_Product_Deleted__c>();
        for(OpportunityLineItem oplineItem : lstOppLineItems) {
                System.Debug('EMC'+oplineItem.Brand_Desc__c.toLowerCase().contains('EMC'));
                
            if(oplineItem.EMC_Opportunity_Product_ID__c != null){   
               
                Oppty_Product_Deleted__c productDeleted = new Oppty_Product_Deleted__c();
                productDeleted.Product_Name__c = oplineItem.Brand_Desc__c;
                productDeleted.Dell_Opportunity_Line_Item_ID__c =  oplineItem.Id;
               //Added to copy EMC Opportunity Product ID from Opportunity Line Item
                productDeleted.EMC_Opportunity_Line_Item_ID__c =  oplineItem.EMC_Opportunity_Product_ID__c;
                productDeleted.Dell_Opportunity_ID__c = oplineItem.OpportunityId;
                ProductDeleted.EMC_Sales_Motion_Flag__c = oplineItem.EMC_Sales_Motion_Flag__c;
                // v 1.3 CR 14110 - Rename 'Dell Changed' to 'Waiting Sync'
                If (!(BoomiProfile.contains('00eA0000000hNqF'))){ 
                    productdeleted.EMC_Opportunity_Line_Item_Deleted__c = 'Waiting Sync';
                }
                
                lstProductDeleted.add(productDeleted);
            }
        }
        if(!lstProductDeleted.isEmpty()) {
            insert lstProductDeleted;
        }     
    }
    
    /*
        Revision    CR Number   Release No      Date           Modified By     Description
        --------    ---------   ------------    -----------    ------------    -----------
        1.0         CR14654     FY18-DCS-1001   19-07-2017     Jessie Tan      Story 3382308:VMware Next Gen CR-00140306: Product Additions
        2.0         CR16585     FY19-DCS-0102   23-10-2019     Vivek           STORY 4192857: S&P VMware Product Additions Gap
        
    */    
    public static void populateNewProductFlagForVMware (list<OpportunityLineItem> lstLineItems, OpportunityLineItemRecordSelector recordSelector) {
        
        //if no VMware S&P Vendor record, return out from function
        if (recordSelector.mapOppIdSPVendorOfVMware.size()<=0){
            return;
        }
        
        //if the current opp product and corresponding S&P Vendor record meet the criteria, then update New_Product__c field (this field is for Boomi to identify if there is additional product ever since initial registration of current opp/S&P Vendor                          
        for(OpportunityLineItem oliIterator : lstLineItems) {
            
            if(oliIterator.S_P_Registerable__c == 'true' && oliIterator.Brand_Desc__c == 'VMware' && recordSelector.mapOppIdSPVendorOfVMware.get(oliIterator.OpportunityId) != null){
                oliIterator.Lead_on_Services__c = recordSelector.mapOppIdSPVendorOfVMware.get(oliIterator.OpportunityId).Dell_Leading_Professional_Services__c;
                
                if( (recordSelector.mapOppIdSPVendorOfVMware.get(oliIterator.OpportunityId).S_P_Deal_Status__c == 'Approved'
                 && recordSelector.mapOppIdSPVendorOfVMware.get(oliIterator.OpportunityId).Vendor_Approval_Number__c!=null)
                 || recordSelector.mapOppIdSPVendorOfVMware.get(oliIterator.OpportunityId).S_P_Deal_Status__c == 'Sent to Vendor' ){            
                    oliIterator.New_Product__c = true;          
                }
            }       
        }
    }  
    
    /*
        Revision    CR Number   Release No      Date           Modified By     Description
        --------    ---------   ------------    -----------    ------------    -----------
        1.0         CR14654     FY18-DCS-1001   02-08-2017     Jessie Tan      Story 3382308:VMware Next Gen CR-00140306: Product Additions
        2.0         XXXXXXX     FY19-DCS-0602   12-06-2018     Vivek  
        
    */    
    public static void updateOppVMwareFlag (list<OpportunityLineItem> lstLineItems, OpportunityLineItemRecordSelector recordSelector) {
        
        //if no VMware S&P Vendor record, return out from function      
        if (recordSelector.mapRelatedOpportunities.size() <= 0){
            return;
        }
        
        //check if any opp product with New_Product__c flag turned on for current opportunity, turn on/off the flag accordingly
        // Related to 0602 defect fixing to overcome New product status update isssue
        
        set<Id> setOppoId_NewProductOLICounts = new set<Id>();
        set<Id> setOppoId_PendingApproveOLICounts = new set<Id>();
           
        AggregateResult[] arrResult = [select opportunityId, count(id) cnt, New_Product__c newproduct from OpportunityLineItem
                                        where opportunityId In :recordSelector.mapRelatedOpportunities.keySet() and (New_Product__c = true OR (Approved__c = false AND Rejected__c = false))
                                        group by opportunityId, New_Product__c];
        
        for(Integer i=0; i<= arrResult.size()-1; i++){            
            
            if( Boolean.valueOf(arrResult[i].get('newproduct')) == true)
                setOppoId_NewProductOLICounts.add((Id)arrResult[i].get('opportunityId'));
            if( Boolean.valueOf(arrResult[i].get('newproduct')) == false)
                setOppoId_PendingApproveOLICounts.add((Id)arrResult[i].get('opportunityId'));
                
        }
        
        for(Opportunity objOpp: recordSelector.mapRelatedOpportunities.values()){
            
            objOpp.New_Product_Added__c = (setOppoId_NewProductOLICounts.contains(objOpp.Id))?true:false;
            objOpp.Pending_OLI_Updates__c = (setOppoId_NewProductOLICounts.contains(objOpp.Id))?true:false;
            
            if(setOppoId_PendingApproveOLICounts.contains(objOpp.Id))
            {
                objOpp.Pending_OLI_Updates__c = true;
            }
            
            if( !setOppoId_NewProductOLICounts.contains(objOpp.id) && !setOppoId_PendingApproveOLICounts.contains(objOpp.Id))
            {
                objOpp.New_Product_Added__c  = false;
                objOpp.Pending_OLI_Updates__c = false;
            }
        }
       
       
        try {
                
            if(!recordSelector.mapRelatedOpportunities.isEmpty()){
            
                if (!Test.isrunningTest()){
                    TriggerExecutionController.setSkipOpportunityTriggers(true);
                }
                    
                update recordSelector.mapRelatedOpportunities.values();
                
                if (!Test.isrunningTest()){
                    TriggerExecutionController.setSkipOpportunityTriggers(false);
                }
                
            }
          
        }catch(Exception e) {
            System.debug('###DEBUG### caught exception in updateOppVMwareFlag- ' + e.getMessage());
        
        }
            
        
    }  
    
    /*
    Revision    CR Number   Release No     Date            Modified By     Description
    --------    ---------   ----------     -----------     ------------    -----------
    1.0         DCS0602     FY18-DCS-0602  28-Apr-2017     Kenny           Update Opportunity Owner Email to Opportunity Owner's Email field when the value is different from Opportunity Owner Email    
    1.1         DCS0602     FY18-DCS-0602  17-May-2017     Kenny           Update Opportunity Partner Account Lookup Account Owner Email to Account Owner's Email field when the value is difference
    */
    
    public static void UpdateOpportunityOwnerEmail(TriggerHandler.TriggerEvent trigEvent, list<OpportunityLineItem> lstLineItems, map<Id, OpportunityLineItem> mapOldLineItems) {           
        //Variable declaration
        Set<Id> oppIdSet = new Set<Id>();
        //collect the opportunity Ids of new products
        for(OpportunityLineItem oppLinteItem: lstLineItems){
            oppIdSet.add(oppLinteItem.OpportunityId);
        }
        // Query the respective opportunity to get the Opportunity Type 
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([Select Id, Type, Owner.email, partneraccount.owner.email from Opportunity where ID IN: oppIdSet]);
        
        for(OpportunityLineItem oliObj : lstLineItems){
            Opportunity opp = new Opportunity();
            opp = opportunityMap.get(oliObj.OpportunityId);
            
            // Update Opportunity Owner Email to Opportunity Owner's Email field when the value is different from Opportunity Owner Email
            if(trigEvent == TriggerHandler.TriggerEvent.isupdate){
                   if(oliObj.Opportunity_Owner_s_Email__c != opp.Owner.Email) {                 
                        oliObj.Opportunity_Owner_s_Email__c = opp.Owner.Email;    
                    }
            }            
           
            // 1.1 Start            
            // Update Opportunity Partner Account Lookup Account Owner Email to Account Owner's Email field when the value is difference
            if(trigEvent == TriggerHandler.TriggerEvent.isupdate){
                   if(oliObj.Account_Owner_s_Email__c != opp.PartnerAccount.Owner.Email) {                 
                        oliObj.Account_Owner_s_Email__c = opp.PartnerAccount.Owner.Email;    
                        }
            }  
            // 1.1 End
            }               
    }
    
     /*Revision    CR Number   Release No  Date            Modified By     Description*/
   // --------    ---------   ----------  -----------     ------------    -----------//
   /* 1.0         D3398057  SP08-May08  22-MAY-2017      Pawan V         Added method to trigger off pop up alert when incumbent products are added to opportunities as line items*/
   /* 2.0                                                   Uday            Modification of complete logic                      */
    
    public static void checkForPopupForIncumbentProducts(Map<Id,sObject> newMap,map<Id, OpportunityLineItem> mapRelatedOppLi,map<Id, Opportunity> mapRelatedOpportunities) {
        
        String recordTypeId =  '012300000004zf2AAA';
        
        List<opportunity> optyToUpdate = new list<opportunity>();
        Map<id,String> OptyIdandLineitemIds = new Map<id,String>();
        
        for(OpportunityLineItem oppLi : (list<OpportunityLineItem>)newMap.values()){
        String lineItemIds = '';
            if(OptyIdandLineitemIds.containsKey(oppLi.OpportunityId)){
            
                   lineItemIds +=  OptyIdandLineitemIds.get(oppLi.OpportunityId)+','+oppLi.id+',';
                  
                  OptyIdandLineitemIds.put(oppLi.OpportunityId,lineItemIds);
            }else{
                    OptyIdandLineitemIds.put(oppLi.OpportunityId,oppLi.Id);
            }
        }
        
        for(ID oppId:mapRelatedOpportunities.keyset()){
            opportunity opp =  mapRelatedOpportunities.get(oppId);
           opp.Latest_product_id__c = OptyIdandLineitemIds.get(oppId).replaceAll(',,',',');
            
            if(recordTypeId == opp.RecordTypeId){
            optyToUpdate.add(opp);
            
            }
        }
        
        if(optyToUpdate.size()>0){
           
            TriggerExecutionController.setSkipOpportunityTriggers(true);            
            update optyToUpdate;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
        }
        
    }
    
   // Added By Rajashekar kura to Update Specialty Queue flag Check on Opportunity    
   public static void OpportunitySpecialtyQueueFlagUpdate(list<OpportunityLineItem> lstLineItems) {
        
       Id NewOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity', TRUE);
       Id ExistingECOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer','Opportunity', TRUE);
       Id SubmittedOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted','Opportunity', TRUE);
       Id ChannleOppRecordTypeID = IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity', TRUE);
       
       Set<id> oppidset = new Set<id>();
       Set<id> Modifiedoppset = new Set<id>();
       Set<Opportunity> oppset = new Set<Opportunity>();
       List<Opportunity> oppList = new List<Opportunity>();
       Map<id,Opportunity> OppMap;
       for(OpportunityLineItem  oli : lstLineItems){
            oppidset.add(oli.OpportunityId);
        }
        
       OppMap = new Map<id,Opportunity>([Select id, Specialty_Queue__c, RecordTypeId from Opportunity where id IN: oppidset]);
       
       for(OpportunityLineItem  oli  : lstLineItems){
            if(test.isrunningtest() || (OppMap != null && OppMap.get(oli.OpportunityId) != null && OppMap.get(oli.OpportunityId).Specialty_Queue__c == 'yes') || (oli.Channel_Product_LOB__c!= null && ((oli.Channel_Product_LOB__c).toLowerCase().contains('storage') || ((oli.Channel_Product_LOB__c).toLowerCase().contains('solution')))))
            {
                if(OppMap != null && OppMap.get(oli.OpportunityId) != null && (OppMap.get(oli.OpportunityId).RecordTypeId == NewOppRecordTypeID || OppMap.get(oli.OpportunityId).RecordTypeId == ExistingECOppRecordTypeID || OppMap.get(oli.OpportunityId).RecordTypeId == SubmittedOppRecordTypeID || OppMap.get(oli.OpportunityId).RecordTypeId == ChannleOppRecordTypeID))
                {
                    Modifiedoppset.add(oli.OpportunityId);
                    Opportunity Opp = OppMap.get(oli.OpportunityId);
                    Opp.Specialty_Queue__c = 'yes';
                    oppset.add(Opp);
                }
            }
       }
       
       oppidset.removeall(Modifiedoppset);
       for(ID oppid : oppidset)
       {
                    Opportunity Opp = OppMap.get(oppid);
                    Opp.Specialty_Queue__c = 'No';
                    oppset.add(Opp);           
       }

       if(oppset.size() > 0 && oppset.size() != null)
       {
       oppList.addAll(oppset);
       TriggerExecutionController.setSkipAllTriggers(true);
       database.update(oppList,false);
       TriggerExecutionController.setSkipAllTriggers(false);
       }
   }


   // Added By Rajashekar kura to Update Specialty Queue flag Check on Opportunity when OpportunityLineItem is deleted   
   public static void OpportunitySpecialtyQueueFlagUncheck(list<OpportunityLineItem> lstLineItems) {
        
       Id NewOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity', TRUE);
       Id ExistingECOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer','Opportunity', TRUE);
       Id SubmittedOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted','Opportunity', TRUE);
       Id ChannleOppRecordTypeID = IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity', TRUE);
       
       Set<id> oppidset = new Set<id>();
       Set<Opportunity> oppset = new Set<Opportunity>();
       List<Opportunity> oppList = new List<Opportunity>();
       Map<id,Opportunity> OppMap;
       Map<id, List<OpportunityLineItem>> ExistingOliMap = new Map<id, List<OpportunityLineItem>>();
   
       for(OpportunityLineItem  oli : lstLineItems){
            oppidset.add(oli.OpportunityId);
        }
        
       OppMap = new Map<id,Opportunity>([Select id, Specialty_Queue__c, RecordTypeId from Opportunity where id IN: oppidset]);
               
       for(OpportunityLineItem  oli : [Select id, OpportunityId, Channel_Product_LOB__c from OpportunityLineItem where OpportunityId In : oppidset]){
           if(ExistingOliMap.containsKey(oli.OpportunityId))
               (ExistingOliMap.get(oli.OpportunityId)).add(oli);
           else
                {
                List<OpportunityLineItem> newlist = new List<OpportunityLineItem>();
                newlist.add(oli);
                ExistingOliMap.put(oli.OpportunityId,newlist);
                }
       }
    
       for(OpportunityLineItem  oli : lstLineItems){
            Opportunity Opp = OppMap.get(oli.OpportunityId);
            if(test.isrunningtest() || (Opp.Specialty_Queue__c != 'no' && (Opp.RecordTypeId == NewOppRecordTypeID || Opp.RecordTypeId == ExistingECOppRecordTypeID || Opp.RecordTypeId == SubmittedOppRecordTypeID || Opp.RecordTypeId == ChannleOppRecordTypeID)))
            {
                boolean checkpoint = false;
                if(ExistingOliMap.get(oli.OpportunityId) != null)
                {
                    for(OpportunityLineItem ExistingOli : ExistingOliMap.get(oli.OpportunityId))
                    {
                        if(ExistingOli.Channel_Product_LOB__c!= null && ((ExistingOli.Channel_Product_LOB__c).toLowerCase().contains('storage')||(ExistingOli.Channel_Product_LOB__c).toLowerCase().contains('solution')))
                        checkpoint = true;
                    }
                }
                if(!checkpoint)
                {
                    Opp.Specialty_Queue__c = 'no';
                    oppset.add(Opp);
                }
            }
       }
       
       if(oppset.size() > 0 && oppset.size() != null)
       {
       oppList.addAll(oppset);
       TriggerExecutionController.setSkipAllTriggers(true);
       database.update(oppList,false);
       TriggerExecutionController.setSkipAllTriggers(false);
       }
   }
    
}
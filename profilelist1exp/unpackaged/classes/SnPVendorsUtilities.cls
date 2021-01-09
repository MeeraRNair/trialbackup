/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0       13902    FY17-DCS-0202   18-Jan-2017      Ismail         Update SnPVendor roll up summary in Opportunity by invoke a flow
 * 2.0       14618    FY18-DCS-0802   07-Jul-2017      Jessie         Update Lead_on_Services__c of Opp Product with value of Dell_Leading_Professional_Services__c of S&P Vendor (for Record Type = 'VMware')
 * 3.0       14789    FY18-DCS-1101   23-Aug-2017      Jessie         Story 3686076:VMware API – Registration Extensions (button logic)
 * 4.0       14654    FY18-DCS-1101   02-Oct-2017      Jessie         Story 3382308:VMware Next Gen CR-00140306: Product Additions
 * 5.0       16400    FY19-DCS-1002   29-Aug-2018      Swathi         Story 4399335:VVMware Opportunity Stage Values 
       
*/

public class SnPVendorsUtilities {
    public static boolean isTest = false;
    /* -- Consolidate beforeInsertUpdateSnPVendor Trigger   */  //Begin
     
   public static String strasciiRegEx = '[\\x20-\\x7F]*$';// \\x20-\\x7F, 
   public static Pattern myPattern = Pattern.compile(strasciiRegEx);
    public static String strerrorMsg = 'VMware accepts English characters only. Please review, update and save.';
 
    public static Boolean checkAscii(String strtoCheck){
        Matcher myMatcher = myPattern.matcher(strtoCheck);
        Boolean bresult = myMatcher.matches();
        return bresult;
    }
    // END
    
    // 1.0: Call this method to invoke the flow that update SnPVendor Rollup Summary in Opportunity. 
    // 1.0: To add new roll up summary field(s), no changes would be here, instead, changes might be done to the flow S_P_Vendor_Rollup_To_Opportunity_Flow
    public static void updateRollUpSummaryInOpportunity(Map<Id, SObject> mapOldSnPVendor, Map<Id, SObject> mapNewSnPVendor){
        // 1.0:
        if((mapOldSnPVendor != null) && (mapOldSnPVendor.size() > 0)){
            Map<string, object> mapOpportunityId = null;
            Flow.Interview.S_P_Vendor_Rollup_To_Opportunity_Flow flowRUSOOpportunity = null;
            
            if (!Test.isrunningTest() || isTest){
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                //TriggerExecutionController.setSkipAllTriggers(true);
            }

            for(SObject sObj : mapOldSnPVendor.values()){
                S_P_Vendors__c sV = (S_P_Vendors__c)sObj;
                
                mapOpportunityId = new Map<string, object>();
                mapOpportunityId.put('strOpportunityId', sV.Opportunity__c);
                flowRUSOOpportunity = new Flow.Interview.S_P_Vendor_Rollup_To_Opportunity_Flow(mapOpportunityId);
                
                if (!System.Test.isRunningTest() || isTest){
                    flowRUSOOpportunity.start();
                }
            }

            if (!Test.isrunningTest() || isTest){
                TriggerExecutionController.setSkipOpportunityTriggers(false);
               // TriggerExecutionController.setSkipAllTriggers(false);
            }
        }
    }
    
    //v4.0 - start
    //v2.0 - start
    public static void updateLeadOnServicesOfOppProduct (List<S_P_Vendors__c> listNewSnPVendor){
    
        Id idVmwareRecordType = IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true);
         
        Set<Id> setOppId = new Set<Id>();
        Map<Id, String> mapOppIdLeadOnServices = new Map<Id, String>();
        Map<Id, Set<Id>> mapOppIdProductId = new Map<Id, Set<Id>>();
        
        for(S_P_Vendors__c objNewSnPVendor: listNewSnPVendor){
        
            System.debug('@@@@@@@@ S&P Vendor Record Type Id : ' + objNewSnPVendor.RecordTypeId );
            System.debug('@@@@@@@@ S&P Vendor Automated : ' + objNewSnPVendor.Automated__c );
            
            //gather the opp id (of automated VMware S&PVendor record)
            //gather the opp id and Dell_Leading_Professional_Services__c into a map (of automated VMware S&PVendor record)      
            if (objNewSnPVendor.RecordTypeId == idVmwareRecordType && objNewSnPVendor.Automated__c == true && 
                objNewSnPVendor.Dell_Leading_Professional_Services__c != ((S_P_Vendors__c)Trigger.oldMap.get(objNewSnPVendor.Id)).Dell_Leading_Professional_Services__c
            ){            
                setOppId.add(objNewSnPVendor.Opportunity__c);
                mapOppIdLeadOnServices.put(objNewSnPVendor.Opportunity__c, objNewSnPVendor.Dell_Leading_Professional_Services__c);
                
                System.debug('$$$$$$$$$$$$$$$$$$$$$ Lead on Services : ' + objNewSnPVendor.Dell_Leading_Professional_Services__c);
                
            }
            
            //gather the opp id (of automated VMware S&PVendor record)
            //gather the opp id and list of oppLineItem Id (that have been added into vmware side as additional products) into a map (of automated VMware S&PVendor record)      
            if (objNewSnPVendor.RecordTypeId == idVmwareRecordType && objNewSnPVendor.Automated__c == true && 
                objNewSnPVendor.Product_Add_Success_Msg__c!= ((S_P_Vendors__c)Trigger.oldMap.get(objNewSnPVendor.Id)).Product_Add_Success_Msg__c
            ){            
                setOppId.add(objNewSnPVendor.Opportunity__c);
                
                //use the regular expression to extract the id of opportunityLineItem        
                Pattern p = Pattern.compile('(Product3PSId=)(\\w+)');
                Matcher m = p.matcher(objNewSnPVendor.Product_Add_Success_Msg__c);
                
                System.debug('$$$$$$$$$$$$$$$$$$$$$ Product Addition Success Msg : ' + objNewSnPVendor.Product_Add_Success_Msg__c);
                
                While (m.find()) {
                
                   if (!mapOppIdProductId.containsKey(objNewSnPVendor.Opportunity__c)){
                       mapOppIdProductId.put (objNewSnPVendor.Opportunity__c,  new Set<Id>());
                   }
                   
                   mapOppIdProductId.get(objNewSnPVendor.Opportunity__c).add(m.group(2));
                   
                   System.debug('$$$$$$$$$$$$$$$$$$$$$ Opp Product Id extracted : ' + mapOppIdProductId.get(objNewSnPVendor.Opportunity__c));
                
                }
                
            }
            
        }
        
        if(setOppId.size() <= 0)
           { return; }           
            
        //query opp product (related to automated VMware S&PVendor record)  
        List<OpportunityLineItem> listOppLineItem = [Select Id, OpportunityId, Lead_on_Services__c, New_Product__c from OpportunityLineItem WHERE OpportunityId =: setOppId AND S_P_Registerable__c = 'TRUE' and Brand_Desc__c = 'VMware'];
        
        List<OpportunityLineItem> listUpdatedOppLineItem = new List<OpportunityLineItem>();
        
        if(listOppLineItem.size()<=0)
           { return;}
        
        for (OpportunityLineItem objOppLineItem: listOppLineItem){
        
            if (
                    mapOppIdLeadOnServices.containsKey(objOppLineItem.OpportunityId) ||     
                    (mapOppIdProductId.containsKey(objOppLineItem.OpportunityId) && mapOppIdProductId.get(objOppLineItem.OpportunityId).contains(objOppLineItem.Id))
                ){
                
                if (mapOppIdLeadOnServices.containsKey(objOppLineItem.OpportunityId)){
                    objOppLineItem.Lead_on_Services__c = mapOppIdLeadOnServices.get(objOppLineItem.OpportunityId);
                }
                
                //if the map of product id contains the opportunityLineItem id, then reset the New_Product__c flag to false            
                if (mapOppIdProductId.containsKey(objOppLineItem.OpportunityId) && mapOppIdProductId.get(objOppLineItem.OpportunityId).contains(objOppLineItem.Id)){
                    objOppLineItem.New_Product__c = false;
                }
            
                 listUpdatedOppLineItem.add(objOppLineItem);
            }
            
        }
        
        if(!listUpdatedOppLineItem.isEmpty())
           { update listUpdatedOppLineItem;    }        
    
    }
    //v2.0 - end
    //v4.0 - end 
    
    //v3.0 - start
    public static void resetExtendRegistrationFlag (List<S_P_Vendors__c> listNewSnPVendor){
    
        Id idVmwareRecordType = IdLookupUtils.getRecordTypeId('VMware','S_P_Vendors__c',true);
        
        //retrieve list of Registration Opportunity Stage 
        Schema.DescribeFieldResult objStageResult = S_P_Vendors__c.Registration_Opportunity_Stage__c.getDescribe();
        List<Schema.PicklistEntry> listStage = objStageResult.getPicklistValues();
        Map<String, Integer> mapStageIndex = new Map<String, Integer>();
        
        for(Integer inti=0; inti<=listStage.size()-1; inti++){
            mapStageIndex.put (listStage.get(inti).getValue(), inti);            
            
        }
        
        String strOldRegOppStage ;
        
        //loop through the S&P Vendor
        //if changes happen to Deal Expiration Date and the modifier is Boomi user, reset the flag and get the next Registration Opportunity Stage in sequence
        for(S_P_Vendors__c objNewSnPVendor: listNewSnPVendor){
        
            if (objNewSnPVendor.RecordTypeId == idVmwareRecordType && objNewSnPVendor.Automated__c == true && 
                objNewSnPVendor.Deal_Expiration_Date__c != ((S_P_Vendors__c)Trigger.oldMap.get(objNewSnPVendor.Id)).Deal_Expiration_Date__c &&
                objNewSnPVendor.Deal_Expiration_Date__c != null &&
                ((S_P_Vendors__c)Trigger.oldMap.get(objNewSnPVendor.Id)).Deal_Expiration_Date__c != null &&
                userinfo.getProfileId() == '00eA0000000hNqFIAU'  
            ){            
                objNewSnPVendor.Extend_Registration__c = false;
                strOldRegOppStage = ((S_P_Vendors__c)Trigger.oldMap.get(objNewSnPVendor.Id)).Registration_Opportunity_Stage__c;
                
                //max value is 07. Ideal scenario: it wont go up higher than 07
                //5.0     -CR 16400-  To rename '07 – Agreement to Purchase' to '07 - Agreement to Purchase' - picklist value
                if (strOldRegOppStage != '07 - Agreement to Purchase'){
                    objNewSnPVendor.Registration_Opportunity_Stage__c = listStage.get(mapStageIndex.get(strOldRegOppStage) + 1).getValue() ;
                }
                
            }
         
        }
       
    }
    //v3.0 - end
    
    /* consolidated beforeInsertUpdateSnPVendor Trigger */  // Begin Line No :14-26
    
    Public static void updateSendNotification(list<S_P_Vendors__c> listOldSnpVendor, list<S_P_Vendors__c> listSnpVendor )
    {
        System.debug('#### inside Trigger beforeInsertUpdateSnPVendor');

        for (Integer inti=0; inti < listSnpVendor.size(); inti++){
            if(listSnpVendor[inti].Deal_Expiration_Date__c != null &&
                listSnpVendor[inti].Deal_Expiration_Date__c != listOldSnpVendor[inti].Deal_Expiration_Date__c){
                
                system.debug('######################## Associated Oppty Stage   ' + listSnpVendor[inti].Opportunity__r.StageName);
                if(listSnpVendor[inti].Opportunity__r.StageName == 'Win - 100%' || listSnpVendor[inti].Opportunity__r.StageName == 'Lost, Cancelled - 0%'){
                    listSnpVendor[inti].Send_Notification__c = false;
                } else {
                    listSnpVendor[inti].Send_Notification__c = true;
                }
            }
        }    
    }  // END

     /* consolidated  trigger beforeInsertUpdateSnPVendor    */ // Begin Line No : 40- 198 
 Public static void checkValidation(list<S_P_Vendors__c> listSnpVendor )
 {
         for(S_P_Vendors__c sv : listSnpVendor ){
            Integer intchecker = 0;
            if(sv.S_P_Vendors_Name__c == 'VMware' && sv.Contact_Name__c != null){
                
                if(sv.Automated__c == true){
                
                    /*if(sv.Special_instructions__c != null && !(checkAscii(sv.Special_instructions__c))){
                        sv.Special_instructions__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }*/
                    
                    if(sv.City__c != null && !(checkAscii(sv.City__c))){
                        sv.City__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    /*if(sv.Rejection_Reason__c != null && !(checkAscii(sv.Rejection_Reason__c))){
                        sv.Rejection_Reason__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }*/
                    
                    if(sv.Contact_Name__c != null && !(checkAscii(sv.Contact_Name__c))){
                        sv.Contact_Name__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Customer_Decision_Maker__c != null && !(checkAscii(sv.Customer_Decision_Maker__c))){
                        sv.Customer_Decision_Maker__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Customer_Decision_Maker_Title__c != null && !(checkAscii(sv.Customer_Decision_Maker_Title__c))){
                        sv.Customer_Decision_Maker_Title__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Customer_Name__c != null && !(checkAscii(sv.Customer_Name__c))){
                        sv.Customer_Name__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Email__c != null && !(checkAscii(sv.Email__c))){
                        sv.Email__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Final_Approver_in_Customer_Organization__c != null && !(checkAscii(sv.Final_Approver_in_Customer_Organization__c))){
                        sv.Final_Approver_in_Customer_Organization__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Final_Approver_Title__c != null && !(checkAscii(sv.Final_Approver_Title__c))){
                        sv.Final_Approver_Title__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.How_did_you_uncover_this_opportunity1__c != null && !(checkAscii(sv.How_did_you_uncover_this_opportunity1__c))){
                        sv.How_did_you_uncover_this_opportunity1__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Other__c != null && !(checkAscii(sv.Other__c))){
                        sv.Other__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Phone__c != null && !(checkAscii(sv.Phone__c))){
                        sv.Phone__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Role__c != null && !(checkAscii(sv.Role__c))){
                        sv.Role__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.S_P_Vendors_Name__c != null && !(checkAscii(sv.S_P_Vendors_Name__c))){
                        sv.S_P_Vendors_Name__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Ship_to_Address__c != null && !(checkAscii(sv.Ship_to_Address__c))){
                        sv.Ship_to_Address__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    /*if(sv.Vendor_Approval_Number__c != null && !(checkAscii(sv.Vendor_Approval_Number__c))){
                        sv.Vendor_Approval_Number__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Vendor_Tracking_Number__c != null && !(checkAscii(sv.Vendor_Tracking_Number__c))){
                        sv.Vendor_Tracking_Number__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }*/
                    
                    if(sv.VMware_Are_you_the_Primary_Sales_Contact__c != null && !(checkAscii(sv.VMware_Are_you_the_Primary_Sales_Contact__c))){
                        sv.VMware_Are_you_the_Primary_Sales_Contact__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.VMware_Is_VMware_Sales_Engaged__c != null && !(checkAscii(sv.VMware_Is_VMware_Sales_Engaged__c))){
                        sv.VMware_Is_VMware_Sales_Engaged__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.VMware_Job_Role__c != null && !(checkAscii(sv.VMware_Job_Role__c))){
                        sv.VMware_Job_Role__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    
                    if(sv.VMware_Preferred_Channel__c != null && !(checkAscii(sv.VMware_Preferred_Channel__c))){
                        sv.VMware_Preferred_Channel__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.VMware_Product_Mapping__c != null && !(checkAscii(sv.VMware_Product_Mapping__c))){
                        sv.VMware_Product_Mapping__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.What_is_the_Customer_Initial_Order__c != null && !(checkAscii(sv.What_is_the_Customer_Initial_Order__c))){
                        sv.What_is_the_Customer_Initial_Order__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Is_VMware_Sales_Engaged__c != null && !(checkAscii(sv.Is_VMware_Sales_Engaged__c))){
                        sv.Is_VMware_Sales_Engaged__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Zip__c != null && !(checkAscii(sv.Zip__c))){
                        sv.Zip__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    if(sv.Sales_Rep_s_Phone__c != null && !(checkAscii(sv.Sales_Rep_s_Phone__c))){
                        sv.Sales_Rep_s_Phone__c.addError('This field contains non-English character.');
                        intchecker = 1;
                    }
                    
                    //start 4.0
                    //if(sv.Contact_Name__c != null){
                        if(sv.VMware_Custom_Created_By__c != null && !(checkAscii(sv.VMware_Custom_Created_By__c))){
                            sv.VMware_Custom_Created_By__c.addError('This field contains non-English character.');
                            intchecker = 1;
                        }
                    //}
                    //end 4.0
                    
                    if(intchecker == 1)
                       { sv.addError(strerrorMsg); }
                    }
                
                }            
        }
    }   // END
 
 /* Consolidated trigger SnPVendorAfterUpdateBeforeInsertUpdateTrigger   */   //Begin  Line No :  29 - 157 
 
    Public static void beforeInsertUpdate(list<S_P_Vendors__c> listSnpVendor )
    {

             S_P_Vendor_Automation__c svAutomationRec = new S_P_Vendor_Automation__c();
             Map<String, S_P_Vendor_Automation__c> mapsvAutomation = new Map<String, S_P_Vendor_Automation__c>();
             Map<String, S_P_Vendor_Partner_Information__c> mapsvpi = new Map<String, S_P_Vendor_Partner_Information__c>();
             Map<String, Double> mapexchangeRate = new Map<String, Double>();
                                                    
             
             // 2.1 START
             List<OpportunityLineItem> listoliVMwareProd;
             Set<Id> setoppIds = new Set<Id>();
             Set<String> setvmwareProds = new Set<String>();
             String strtmpProdMapping = '';
             
             for(S_P_Vendors__c svRec : listSnpVendor)
                 {setoppIds.add(svRec.Opportunity__c); }       
             
             listoliVMwareProd = new List<OpportunityLineItem>([SELECT Id, Brand_Desc__c, OpportunityId,PricebookEntry.Product2.Description 
                                                                      FROM OpportunityLineItem 
                                                                      WHERE OpportunityId IN :setoppIds]);
             // 2.1 TO BE CONTINUED
             
             // Instantiate mapsvAutomation with the Vendor Name as its key
             System.debug('TEST SNP svAutoList value: ' + SnPHelperClass.svAutoList);
             for(S_P_Vendor_Automation__c svAuto : SnPHelperClass.svAutoList) //3.3
                                                     /*[SELECT Vendor_Name__c, Is_Active__c, Automation_Type__c, CreatedDate 
                                                     FROM S_P_Vendor_Automation__c])*/ 
               {  mapsvAutomation.put(svAuto.Vendor_Name__c.toLowerCase(), svAuto);}
             
             // Instantiate mapsvpi with the combination of Country and Segment Name as its key
             System.debug('TEST SNP svpiList value: ' + SnPHelperClass.svpiList);
             for(S_P_Vendor_Partner_Information__c svpi : SnPHelperClass.svpiList){ //3.3
                                                             /*[SELECT Id, Name, Partner_ID__c, Segment__c, Country__c,  
                                                             Partner_Username__c, Is_Active__c, S_P_Vendor_Automation_ID__r.Vendor_Name__c 
                                                             FROM S_P_Vendor_Partner_Information__c]) {*/ 
                 System.debug('***TEST IT*** ' + svpi.S_P_Vendor_Automation_ID__r.Vendor_Name__c + '**' + svpi.Country__c + '**' + svpi.Segment__c + '**' + mapsvpi.get(svpi.Country__c + svpi.Segment__c));
                 // Duplicate Country + Segment Key will not be included
                 if(svpi.Segment__c != null) {
                     if(mapsvpi.get(svpi.S_P_Vendor_Automation_ID__r.Vendor_Name__c.toLowerCase().trim() + svpi.Country__c.toLowerCase().trim() + svpi.Segment__c.toLowerCase().trim()) == null && svpi.Is_Active__c == true)
                        { mapsvpi.put(svpi.S_P_Vendor_Automation_ID__r.Vendor_Name__c.toLowerCase().trim() + svpi.Country__c.toLowerCase().trim() + svpi.Segment__c.toLowerCase().trim(), svpi);}
                     else 
                        { mapsvpi.remove(svpi.S_P_Vendor_Automation_ID__r.Vendor_Name__c.toLowerCase().trim() + svpi.Country__c.toLowerCase().trim() + svpi.Segment__c.toLowerCase().trim());}
                 } else {
                     if(mapsvpi.get(svpi.S_P_Vendor_Automation_ID__r.Vendor_Name__c.toLowerCase().trim() + svpi.Country__c.toLowerCase().trim()) == null && svpi.Is_Active__c == true)
                        { mapsvpi.put(svpi.S_P_Vendor_Automation_ID__r.Vendor_Name__c.toLowerCase().trim() + svpi.Country__c.toLowerCase().trim(), svpi); }
                     else 
                        { mapsvpi.remove(svpi.S_P_Vendor_Automation_ID__r.Vendor_Name__c.toLowerCase().trim() + svpi.Country__c.toLowerCase().trim());
                        }
                 } 
                     
             }
             set<String> setIsoCode = new set<String>();
             for(S_P_Vendors__c svRec : ListSnpVendor) {
                setIsoCode.add(svRec.CurrencyISOCode);
             }
             //get Currency code - to fix p1 PMD error. 
             if(setIsoCode != null){
                 for(DatedConversionRate dcR : [SELECT ConversionRate,Id,IsoCode,NextStartDate,StartDate FROM DatedConversionRate where IsoCode in :setIsoCode  order by StartDate Desc]){                                      
                      if(mapexchangeRate.get(dcR.IsoCode) == null){ 
                           mapexchangeRate.put(dcR.IsoCode, dcR.ConversionRate);
                      }
                 }    
             } 
             
             // Iterate and check for each new or updated records
             for(S_P_Vendors__c svRec : listSnpVendor) {
             
                 // 2.1 CONTINUATION
                 if(svRec.S_P_Vendors_Name__c.trim().equalsIgnoreCase('VMware')){
                     for(OpportunityLineItem oli : listoliVMwareProd){
                         if(svRec.Opportunity__c == oli.OpportunityId &&
                            svRec.S_P_Vendors_Name__c.trim().equalsIgnoreCase(oli.Brand_Desc__c.trim()))
                            { setvmwareProds.add(oli.PricebookEntry.Product2.Description); }
                     }
                     
                     strtmpProdMapping = '';
                     
                     for(String strprod : setvmwareProds){
                         //strprod = strprod.replace('VMware ', '');
                         strtmpProdMapping += strprod + '; ';
                     }
                     
                     svRec.VMware_Product_Mapping__c = strtmpProdMapping;
                 }
                 // 2.1 END
             
                 svAutomationRec = mapsvAutomation.get(svRec.S_P_Vendors_Name__c.toLowerCase());
                 
                 // Check if the vendor has an entry in the S&P Vendor Automation object
                 if(svAutomationRec != null && (svRec.CreatedDate >= svAutomationRec.CreatedDate)){
                     // Assign the returned SV Record from executing checkAutomation()
                           SnPDealRegistrationProcessSelector sps;

                     if(sps==null){
                         sps = new SnPDealRegistrationProcessSelector();//v3.2 on-demand initialization. 
                     }
                     svRec = sps.checkAutomation(svRec, svAutomationRec);
                 }
                 
                 // Check for currency and exchange rates. Total Net in USD should always be updated.
                  try {
                      if(svRec.CurrencyISOCode != 'USD') {
                          /*if(mapexchangeRate.get(svRec.CurrencyISOCode) == null) {
                              mapexchangeRate.put(svRec.CurrencyISOCode, [SELECT ConversionRate,Id,IsoCode,NextStartDate,StartDate FROM DatedConversionRate 
                                              WHERE IsoCode = :svRec.CurrencyISOCode ORDER BY StartDate DESC LIMIT 1].ConversionRate);
                          }*/
                          if(mapexchangeRate !=null && mapexchangeRate.get(svRec.CurrencyISOCode) != null){
                           svRec.Total_Net_in_USD__c = svRec.Total_NET__c / mapexchangeRate.get(svRec.CurrencyISOCode);
                          }
                      } else {
                          svRec.Total_Net_in_USD__c = svRec.Total_NET__c;}
                  } catch (NullPointerException npe) {
                      // Ignore exception
                  }
                  
                 // Check for Segment Name in the Related Account
                 if(svRec.S_P_Vendors_Name__c == 'CommVault')
                     {svRec = SnPDealRegistrationProcessSelector.checkCommVaultFederal(svRec);}
                 
                 // 2.0 Select Partner Id
                     // 1st level partner info validation
                 if(svRec.S_P_Vendors_Name__c == 'VMware')
                    { svRec = SnPDealRegistrationMainClass.updatePartnerId(svRec, mapsvpi);}
                 
                     // 2nd level partner info validation - If Partner Id is null, try matching country only
                 if(svRec.Partner_ID__c == null && svRec.S_P_Vendors_Name__c == 'VMware'){
                     try {
                            String strsvKey = svRec.S_P_Vendors_Name__c.toLowerCase().trim() + svRec.Country__c.toLowerCase().trim();
                                
                            if(mapsvpi.get(strsvKey) != null)
                               { svRec.Partner_ID__c = mapsvpi.get(strsvKey).Id;}
                         } catch(NullPointerException npe){ }
                 }
                // 2.0 END
                
                // 3.0 START
                if(svRec.Ready_to_submit_to_vendor__c == 'Yes' && userinfo.getProfileId() != '00eA0000000hNqFIAU' &&  //4.0 added profile checking in the criteria
                   svRec.Automated__c == True && 
                   ((svRec.S_P_Deal_Status__c == 'Pending' || svRec.S_P_Deal_Status__c == 'Incomplete') ||
                   (((S_P_Vendors__c)Trigger.oldMap.get(svRec.Id)).S_P_Deal_Status__c != 'Sent to Vendor' && 
                   svRec.S_P_Deal_Status__c == 'Unsuccessful Sent to Vendor')) && 
                  //3.1 Vendor Name not equal to F5
                  svRec.S_P_Vendors_Name__c != 'F5')
                  {svRec = SnPDRSubmitToVendorExtension.updateDealStatusAndSubmitFlag(svRec);}
                // 3.0 END
             }
         }  // END


     /*  consolidated trigger SnPVendorAfterUpdateBeforeInsertUpdateTrigger  */ // Line No  160- 184
   
        

Public static void validationCheck(list<S_P_Vendors__c> listSnpVendor )
    {
             // Iterate and check for each new or updated records
             for(S_P_Vendors__c svRec : listSnpVendor){
                 // Check if there was a change in the Deal Status and if implementing Automated Process
                 if(svRec.S_P_Deal_Status__c != ((S_P_Vendors__c)Trigger.oldMap.get(svRec.Id)).S_P_Deal_Status__c && svRec.Automated__c == True){
                     // Check if Deal status was changed to 'Sent to Vendor' and old value is equal to 'Approved' or 'Rejected'
                     
                     if((svRec.S_P_Deal_Status__c == 'Sent to Vendor') && 
                        (((S_P_Vendors__c)Trigger.oldMap.get(svRec.Id)).S_P_Deal_Status__c == 'Approved' || 
                         ((S_P_Vendors__c)Trigger.oldMap.get(svRec.Id)).S_P_Deal_Status__c == 'Rejected')){
                         svRec.addError(' Use the \'Submit to Vendor\' button to submit the form.');
                     }
                     // Check if Deal status was changed to 'Sent to Vendor' and old value is not equal to 'Approved' or 'Rejected'
                     else if((svRec.S_P_Deal_Status__c == 'Sent to Vendor') && 
                        (((S_P_Vendors__c)Trigger.oldMap.get(svRec.Id)).S_P_Deal_Status__c != 'Approved' || 
                         ((S_P_Vendors__c)Trigger.oldMap.get(svRec.Id)).S_P_Deal_Status__c != 'Rejected')){
                         SnPDealRegistrationProcessSelector.lockUnlockRecord(svRec, 'Approve');
                     } 
                     // Check if the Deal Status was changed FROM 'Sent to Vendor' to another deal status
                     else if((svRec.S_P_Deal_Status__c != 'Sent to Vendor') && 
                         (((S_P_Vendors__c)Trigger.oldMap.get(svRec.Id)).S_P_Deal_Status__c == 'Sent to Vendor')){ 
                         SnPDealRegistrationProcessSelector.lockUnlockRecord(svRec, 'Reject');
                     }      
                 }
             }
    }
}
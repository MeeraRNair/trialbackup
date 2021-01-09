/*
History:
Version     Date                Modified By         CR#                Description     
--------------------------------------------------------------------------------------
1.0                                                                    Created
1.2         08-Apr-2019         Abhinav                                Modified conditions
1.3         24-Jun-2019         Abhinav                                Added myquote links
1.4         05-Aug-2019         Abhinav             CR#17870           Commented Threshold logic
*/
public class OpportunityQuoteController {
    
    public static final String ADDPRODUCTS = 'Add Products';
    public static final String ADDQUOTES = 'Add Quote numbers to Products';
     public static final String ADDCONTACT = 'Add Contact';
    
     @AuraEnabled
    public static wrapperClass initmethod(String strOpptyId){
        boolean bContactsCheck = false;
        boolean bProductsAdditioncheck = false;
        boolean bQuotestoProductscheck = false;
        wrapperClass wrap = new wrapperClass();
        //Map<String, Opportunity_Guidelines__mdt> opguideLineNameVsguideline = new Map<String, Opportunity_Guidelines__mdt>();//bof - v1.2
        opportunity opp = getOpportunity(strOpptyId);
        wrap.opp = opp;
        
        //Check for contacts
        bContactsCheck = checkforContacts(strOpptyId);
        
        //check for products added or not
         List<OpportunityLineItem> listOppProducts = new List<OpportunityLineItem>();
         listOppProducts = getOpportunityProducts(strOpptyId);
          if(!listOppProducts.isEmpty()){
            wrap.listOpproduct = listOppProducts;
            bProductsAdditioncheck = true;
        }
        
        
        //check for Quotes to the products
         List<OpportunityLineItem> listQuoteProducts = new List<OpportunityLineItem>();
        Boolean bQuotesEligible = False;
        Boolean bQuotesNotAdded = False;
        
         
        // Get all LATAM Region country codes (from Custom settings: LATAM_Country_Codes__c)
        List<LATAM_Country_Codes__c> listLatamCountryCodes = LATAM_Country_Codes__c.getall().values();
        set<String> setLatamCodes = new set<String>();
        
        for(LATAM_Country_Codes__c latam: listLatamCountryCodes){
            setLatamCodes.add(latam.Name);
        }
        
        
        Boolean bIsPendingQuote  = false;
        Integer intPendingQuotes = 0;
        if(!listOppProducts.isEmpty() && !wrap.listOpproduct.isEmpty()){
            for(OpportunityLineItem oli : wrap.listOpproduct){
               // listQuoteProducts.add(oli);
                //          bQuotesEligible = True;
                //          if(oli.Quote__c == NULL){
                //              bQuotesNotAdded = True;
                     
                //          }
                
                //v1.2 - BOF
                /*if(oli.LOT_Indicator__c || oli.Ocean_Indicator__c || oli.Product2.Order_Compliant_Product__c) {
                      if( (oli.Opportunity.Account_Country__c == 'United States' && oli.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US)) 
                            || ( setLatamCodes.contains(oli.Opportunity.Account_Country_Code__c) == true  && oli.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_LATAM))
                         || ( oli.Opportunity.Account_Country__c != 'United States' && setLatamCodes.contains(oli.Opportunity.Account_Country_Code__c) == false && oli.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_Others ))){
                             //Need to add condition for Quote Eligible Products
                            listQuoteProducts.add(oli);
                            bQuotesEligible = True;
                            if(oli.Quote__c == NULL){
                                bQuotesNotAdded = True;
                     
                            }
                         }
                }*/
                bQuotesEligible = false;
                bIsPendingQuote = false;
                //1.4 - BOF
                /*if(
                    (oli.Opportunity.Account_Country__c == 'United States' && oli.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US)) || 
                    (setLatamCodes.contains(oli.Opportunity.Account_Country_Code__c) == true  && oli.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_LATAM)) || 
                    (oli.Opportunity.Account_Country__c != 'United States' && setLatamCodes.contains(oli.Opportunity.Account_Country_Code__c) == false && oli.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_Others ))
                ) {
                    bQuotesEligible = true;
                    if(oli.Quote__c == null || oli.Quantity == null || oli.Configuration_Services__c == null || oli.Customer_Requested_Date__c == null) {
                        bQuotesNotAdded = true;
                        bIsPendingQuote  = true;
                    }
                }*/
                //1.4 - EOF
                if(
                    oli.LOT_Indicator__c || 
                    oli.Ocean_Indicator__c || 
                    (oli.Product2.Order_Compliant_Product__c && oli.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US))
                ) {
                    bQuotesEligible = true;
                    if(oli.Quote__c == null || oli.Quantity == null || oli.Configuration_Services__c == null || oli.Customer_Requested_Date__c == null) {
                        bQuotesNotAdded = true;
                        
                        bIsPendingQuote  = true;
                    }
                }
                //Need to add condition for Quote Eligible Products
                if(bQuotesEligible == true) {
                    listQuoteProducts.add(oli);                 
                }

                if(bIsPendingQuote == true) {
                    intPendingQuotes++;
                }
                //v1.2 - EOF
            }
        }
        system.debug('@@@@@listQuoteProducts'+listQuoteProducts);
        if(!listQuoteProducts.isEmpty()){
            wrap.listQuoteProducts = listQuoteProducts;
        }
        if(bQuotesEligible && !bQuotesNotAdded){
           bQuotestoProductscheck = true;
        }
        
        /*if(bIsPendingQuote && bIsPendingQuote == true) {
            wrap.bIsPendingQuote  = bIsPendingQuote;
        }*/
        
        if(intPendingQuotes > 0) {
            wrap.bIsPendingQuote  = true;
            wrap.intPendingQuotes = intPendingQuotes;
        }
        
        wrap.listBtn = getBtnList(opp);//1.3
        
        //bof - v1.2
        /*List<Opportunity_Guidelines__mdt > opportunityGuideLines = new List<Opportunity_Guidelines__mdt >();
        opportunityGuideLines = getOpportunityGuidelines(opp.RecordType.Name);
        system.debug('@@@@opportunityGuideLines'+opportunityGuideLines);
        for(Opportunity_Guidelines__mdt oppGuideline : opportunityGuideLines){
            oppGuideline.Status__c = 'New';
            Integer childActionscheckscount = 0;
            Boolean firstActive = true;
            if(!oppGuideline.Opportunity_Guideline_Actions__r.isEmpty()){
                
                for(Opportunity_Guideline_Action__mdt gAction : oppGuideline.Opportunity_Guideline_Actions__r){
                     if(gAction.MasterLabel == ADDPRODUCTS){
                        gAction.isChecked__c = bProductsAdditioncheck;
                    }
                    else if(gAction.MasterLabel == ADDQUOTES){
                        gAction.isChecked__c = bQuotestoProductscheck;
                    }
                    
                    if(gAction.isChecked__c){
                        childActionscheckscount++;
                    }
                    
                    if(!gAction.isChecked__c && firstActive){
                        gAction.Active_Step__c = true;
                        firstActive = false;
                    }
                    
                }
                
                if(oppGuideline.Opportunity_Guideline_Actions__r.size() == childActionscheckscount){
                    oppGuideline.Status__c = 'Completed';
                }
                else if(childActionscheckscount > 0){
                    oppGuideline.Status__c = 'In Progress';
                }
               
            }
            else{
                if(oppGuideline.MasterLabel == ADDCONTACT && bContactsCheck){
                    oppGuideline.Status__c = 'Completed';
                }
            }
        }*/
        //eof - v1.2

      /*
        if(!opportunityGuideLines.isEmpty()){
            for(Opportunity_Guidelines__mdt oppguideline : opportunityGuideLines) {
                opguideLineNameVsguideline.put(oppguideline.MasterLabel, oppguideline);
            }
            wrap.optyGuidelines = opportunityGuideLines;
        }
        
       if(opguideLineNameVsguideline.containsKey(ADDCONTACT)){
             opguideLineNameVsguideline.get(ADDCONTACT).isChecked__c = checkforContacts(strOpptyId);
        }
        
        
        
         List<OpportunityLineItem> listOppProducts = new List<OpportunityLineItem>();
         listOppProducts = getOpportunityProducts(strOpptyId);
        if(!listOppProducts.isEmpty()){
            wrap.listOpproduct = listOppProducts;
            if(opguideLineNameVsguideline.containsKey(ADDPRODUCTS)) {
                opguideLineNameVsguideline.get(ADDPRODUCTS).isChecked__c = True;
            }
        }
        
        
        List<OpportunityLineItem> listQuoteProducts = new List<OpportunityLineItem>();
        Boolean bQuotesEligible = False;
        Boolean bQuotesNotAdded = False;
        if(!wrap.listOpproduct.isEmpty()){
            for(OpportunityLineItem oli : wrap.listOpproduct){
                //Need to add condition for Quote Eligible Products
                listQuoteProducts.add(oli);
                bQuotesEligible = True;
                if(oli.Quote__c == NULL){
                    bQuotesNotAdded = True;
                     
                }
            }
        }
        
        if(bQuotesEligible && !bQuotesNotAdded){
            if(opguideLineNameVsguideline.containsKey(ADDQUOTES)
                         && !opguideLineNameVsguideline.get(ADDQUOTES).isChecked__c) {
                        opguideLineNameVsguideline.get(ADDQUOTES).isChecked__c = True;
                    }
        }
        */
        //bof - v1.2
        /*if(!opportunityGuideLines.isEmpty()){
            wrap.optyGuidelines = opportunityGuideLines;
            
            //checking for overall status here
            for(Opportunity_Guidelines__mdt singleGuideline : wrap.optyGuidelines) {
                if(singleGuideline.isChecked__c == False){
                    wrap.bOverallStatus = False;
                    break;
                }
            }
        }*/
        //eof - v1.2
        
        return wrap;
        
    }

    public static Opportunity getOpportunity(String strOpportunityId) {
        Opportunity opp = new Opportunity();
        opp   = [select id, Name, StageName,
                        RecordType.Name,
                        Order_Compliance_Product__c,
                        How_many_shipments__c,
                       CloseDate,//Total_Aggregated_Volume__c,
                       Needed_Quote_Notification_Pop_Up__c, LOT_Large_Opportunity__c, Probability,
                       Deal_ID__c, Account.Account_ID__c, Account.Account_Country_Code__c
                        From Opportunity
                        WHERE Id=:strOpportunityId];
        return opp;
    }

   @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityProducts(String strOpptyId){
       List<OpportunityLineItem> listOppLineItems = new List<OpportunityLineItem>();
        listOppLineItems = [SELECT Id, OpportunityId, PricebookEntryId,Total_Price_in_USD__c,
                                   Ocean_Indicator__c,Opportunity.Account_Country_Code__c,
                                   Opportunity.Account_Country__c, Quantity, ListPrice, 
                                   PricebookEntry.UnitPrice, TotalPrice, Quote__c, 
                                   PricebookEntry.Name, PricebookEntry.Product2Id, 
                                   Product2.Order_Compliant_Product__c,LOT_Indicator__c,
                                   Configuration_Services__c, Customer_Requested_Date__c, 
                                   Request_Type__c, Supportability_Status__c, Support_by_Date__c,Supported_Quantity__c,
                                   Alternate_Item__c, Supportability_Comments__c,
                                   Opportunity.RecordType.Name 
                            FROM OpportunityLineItem 
                            WHERE OpportunityId =: strOpptyId ];
        return listOppLineItems;
    }

    @AuraEnabled
    public static boolean updateOpportunityItems(List<OpportunityLineItem> listEditedOLI){
        try{
            system.debug('@@@@@listEditedOLI'+listEditedOLI);
                
            Map<Id, OpportunityLineItem> mapIdVsOpplineItem = new Map<Id, OpportunityLineItem>();
            for(OpportunityLineItem oli :listEditedOLI ){
                mapIdVsOpplineItem.put(oli.id, oli);
            }
            update mapIdVsOpplineItem.values();
            return true;
        } catch(Exception e){
            system.debug('@@@exception'+ e);
            return false;
        }
    }

     @AuraEnabled
    public static Boolean getOpportunityQuoteStatus(String strOpptyId){
       List<OpportunityLineItem> listOppLineItems = new List<OpportunityLineItem>();
        listOppLineItems = [SELECT Id, OpportunityId, PricebookEntryId,Total_Price_in_USD__c, Ocean_Indicator__c,Opportunity.Account_Country_Code__c, Opportunity.Account_Country__c, Quantity, ListPrice, PricebookEntry.UnitPrice, TotalPrice, Quote__c, 
                    PricebookEntry.Name, PricebookEntry.Product2Id, Product2.Order_Compliant_Product__c,LOT_Indicator__c,Configuration_Services__c, Customer_Requested_Date__c, Request_Type__c, Supportability_Status__c, Support_by_Date__c,Supported_Quantity__c,
                    Alternate_Item__c, Supportability_Comments__c FROM OpportunityLineItem WHERE OpportunityId =: strOpptyId 
                           and Quote__c != NULL];
        if(!listOppLineItems.isEmpty()){
            return True;
        }
        return false;
       
    }

    //bof - v1.2
    /*public static List<Opportunity_Guidelines__mdt > getOpportunityGuidelines(String OptyRecordType){
       List<Opportunity_Guidelines__mdt> optyguidelines = new List<Opportunity_Guidelines__mdt>();
        optyguidelines = [select Id, MasterLabel, Opportunity_RecordType__c,
                                  Step_Number__c, isChecked__c,Status__c,
                                   Child_Action_Available__c,
                                  (select Id, MasterLabel,Step_Number__c, isChecked__c,
                                        Linkable__c
                                         From Opportunity_Guideline_Actions__r
                                          order by Step_Number__c ASC)
                                 From Opportunity_Guidelines__mdt
                                 WHERE Opportunity_RecordType__c =:OptyRecordType 
                                Order by  Step_Number__c ASC];
       
        return optyguidelines;
       
    }*/
    //eof - v1.2

    // wrapper or Inner class with @AuraEnabled {get;set;} properties*    
    public class wrapperClass{
        @AuraEnabled public opportunity opp{get;set;}
        //@AuraEnabled public List<Opportunity_Guidelines__mdt > optyGuidelines{get;set;}//bof - v1.2
        @AuraEnabled public List<OpportunityLineItem> listOpproduct{get;set;}
        @AuraEnabled public List<OpportunityLineItem> listQuoteProducts{get;set;}
        @AuraEnabled public Boolean bIsQuotesAdded{get;set;}
        @AuraEnabled public Boolean bIsProductsAdded {get;set;}
        @AuraEnabled public Boolean bOverallStatus{get;set;}
        //v1.2 - EOF
        @AuraEnabled public Needed_Quote_GS__c nqgs = Needed_Quote_GS__c.getOrgDefaults();
        @AuraEnabled public Boolean bIsPendingQuote{get;set;}
        @AuraEnabled public Integer intPendingQuotes{get;set;}
        @AuraEnabled public List<List<btnAttrWrap>> listBtn {get;set;}//1.3
        public wrapperClass(){
            this.bIsProductsAdded = false;
            this.bOverallStatus   = true;
            //v1.2 - EOF
            this.bIsPendingQuote  = false;
            this.intPendingQuotes   = 0;
        }
    }

    //1.3
    public static List<List<btnAttrWrap>> getBtnList(Opportunity opp) {         
        // Get all LATAM Region country codes (from Custom settings: Create_Quote_Profiles__c)
        List<Create_Quote_Profiles__c> listCreateQuoteProfile = Create_Quote_Profiles__c.getall().values();
        Boolean bIsDSP = false;
        Boolean bIsUSP = false;
        Id profileId = userinfo.getProfileId();
        String strUserProfileName = [SELECT Id, Name FROM Profile WHERE Id =: profileId].Name;
        for(Create_Quote_Profiles__c cqp : listCreateQuoteProfile) {
            if(strUserProfileName == cqp.ProfileName__c) {
                if(cqp.isUSP__c == true) {
                    bIsUSP = true;
                }
                if(cqp.isDSP__c == true) {
                    bIsDSP = true;
                }
            }
        }

        Needed_Quote_GS__c nqgs = Needed_Quote_GS__c.getOrgDefaults();
        
        List<List<btnAttrWrap>> listBtn = new List<List<btnAttrWrap>>();
        List<btnAttrWrap> listBtnAttr = new List<btnAttrWrap>();
        btnAttrWrap btnAttrObj;
        
        //Using logic based on formula field - Opportunity.OpptyToCOM__c
        if(
            bIsUSP == true &&
            opp.Deal_ID__c != null && 
            opp.Account.Account_Country_Code__c != null && 
            opp.Account.Account_ID__c != null && 
            Label.COMCountry.contains(opp.Account.Account_Country_Code__c)
        ) {
            //OpptyToCOM__c - View Opportunity in USP Button
            btnAttrObj = new btnAttrWrap();
            btnAttrObj.bIsVisible = bIsUSP;
            btnAttrObj.strName = 'Oppty_COM_ViewQuotes';
            btnAttrObj.strLabel = nqgs.btn_oppty_com_viewquotes__c;
            btnAttrObj.strUrl = '/apex/COM_RedirectToCOM?id='+opp.Id+'&dealid='+opp.Deal_ID__c+'&action=viewopportunity&country='+opp.Account.Account_Country_Code__c;
            listBtnAttr.add(btnAttrObj);
            
            listBtn.add(listBtnAttr);
            listBtnAttr = new List<btnAttrWrap>();

            //OpptyToCOM__c - Create Quote Button
            btnAttrObj = new btnAttrWrap();
            btnAttrObj.bIsVisible = bIsUSP;
            btnAttrObj.strName = 'Oppty_COM_CreateQuote';
            btnAttrObj.strLabel = nqgs.btn_oppty_com_createquote__c;
            btnAttrObj.strUrl = '/apex/COM_RedirectToCOM?id='+opp.Id+'&country='+opp.Account.Account_Country_Code__c+'&action=createquote&dealid='+opp.Deal_ID__c+'&accountid='+opp.Account.Account_ID__c;
            btnAttrObj.strHeader = nqgs.btn_oppty_head_createquote__c;
            listBtnAttr.add(btnAttrObj);
        }

        //Using logic based on formula field - Opportunity.OpptytoDSP__c
        if(
            bIsDSP == true &&
            opp.Deal_ID__c != null && 
            opp.Account.Account_Country_Code__c != null && 
            opp.Account.Account_ID__c != null && 
            Label.DSPCountry.contains(opp.Account.Account_Country_Code__c)
        ) {
            //OpptytoDSP__c - View Opportunity in USP Button
            btnAttrObj = new btnAttrWrap();
            btnAttrObj.bIsVisible = bIsDSP;
            btnAttrObj.strName = 'Oppty_DSP_ViewQuotes';
            btnAttrObj.strLabel = nqgs.btn_oppty_dsp_viewquotes__c ;
            btnAttrObj.strUrl = '/apex/COM_redirecttoDSP?redirectvalue=opportunity/details/&id='+opp.Id+'&dealid='+opp.Deal_ID__c+'&country='+opp.Account.Account_Country_Code__c;
            listBtnAttr.add(btnAttrObj);
            
            listBtn.add(listBtnAttr);
            listBtnAttr = new List<btnAttrWrap>();

            //OpptytoDSP__c - Create Quote Button
            btnAttrObj = new btnAttrWrap();
            btnAttrObj.bIsVisible = bIsDSP;
            btnAttrObj.strName = 'Oppty_DSP_CreateQuote';
            btnAttrObj.strLabel = nqgs.btn_oppty_dsp_createquote__c;
            btnAttrObj.strUrl = '/apex/COM_redirecttoDSP?id='+opp.Id+'&country='+opp.Account.Account_Country_Code__c+'&dealId='+opp.Deal_ID__c+'&AffinityAccountId='+opp.Account.Account_ID__c+'&redirectvalue=quote/create';
            btnAttrObj.strHeader = nqgs.btn_oppty_head_createquote__c;
            listBtnAttr.add(btnAttrObj);
        }

        //Create_MyQuote - Create MyQuote | Opportunity Custom Button
        btnAttrObj = new btnAttrWrap();
        btnAttrObj.bIsVisible = true;
        btnAttrObj.strName = 'Oppty_MY_CreateQuote';
        btnAttrObj.strLabel = nqgs.btn_oppty_my_createquote__c;
        btnAttrObj.strUrl = '/apex/OpportunityCreateQuote?id='+opp.Id;
        btnAttrObj.strHeader = nqgs.btn_oppty_head_createquote__c;
        if(listBtnAttr.size() == 0) {
            btnAttrObj.strLabel = nqgs.btn_oppty_head_createquote__c;
        }
        listBtnAttr.add(btnAttrObj);
        
        listBtn.add(listBtnAttr);

        return listBtn;
    }

    //1.3
    public class btnAttrWrap {
        @AuraEnabled public Boolean bIsVisible{get;set;}
        @AuraEnabled public String strName {get; set;}
        @AuraEnabled public String strLabel {get; set;}
        @AuraEnabled public String strUrl {get; set;}
        @AuraEnabled public String strHeader {get; set;}
    }

    public static Boolean checkforContacts(String strOpptyId){
        List<OpportunityContactRole> listOpcontactsrole = new List<OpportunityContactRole>();
        listOpcontactsrole = [select id from OpportunityContactRole
                                 Where OpportunityId=:strOpptyId];
        if(!listOpcontactsrole.isEmpty()){
            return true;
        }
        return false;
    }

    // Sharath
    // To get picklist values dynamically
    @AuraEnabled 
    public static List<String>getAllPicklistValues(string strObjName, string strGivenfieldName){
        List<String> listOption = new List<String>();
        //get changeFreeze TimeField Field Describe
        // Get the describe for the object
        Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(strObjName).getDescribe();
        // Get the field dynamically
            Schema.DescribeFieldResult fieldResult = objResult.fields.getMap().get(strGivenfieldName).getDescribe();
        //Schema.DescribeFieldResult fieldResult = strObjName.strGivenfieldName.getDescribe();
        List<Schema.PicklistEntry> listP = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: listP) {
            //Put Picklist Value & Label in Map
            listOption.add(p.getValue());
        }
        return listOption;
    }

    @AuraEnabled
    public static Needed_Quote_GS__c getNeededQuoteGS(){
        return Needed_Quote_GS__c.getOrgDefaults();
    }
}
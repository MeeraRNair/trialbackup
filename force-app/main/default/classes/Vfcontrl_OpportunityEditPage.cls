/*
History:
    Version Date            Modified By       CR#                Description     
--------------------------------------------------------------------------------------
1.0                                                              Created
...     ...             ...                                      ...
2.0     13-May-2015     Azwanti                                  MAJ16.07:Consolidate LOT form into Needed Quote
2.1     22-Mar-2016     Afiq                 CR12751             Added logic to check other fields to popup Needed Quote popup
3.0     05-Jun-2017     Abhinav              CR14471             Skipped to reset old StageName if value is "Order Submitted - 99%"
3.1     12-Jun-2017     Abhinav              CR14471             Introduced custom settings for StageName picklist values
4.0     07-Jun-2018     Akshita              CR15930             Removed Commented lines and, system.debug statements as part of Opportunity code reduce story
        12-Dec-2018     Hari A                                   STORY 5907651 Removed reference for the field total_aggregated_volume__c
        10-Sep-2019     Sai                                      STORY 7161520 Prod Issue : Mismatched of Probability and Forecast Category (occurs randomly)
*/
public class Vfcontrl_OpportunityEditPage {

    public Opportunity opp {get;set;}
    String oldOppStageName ;
    String oldOppProbability ;
    String oppId ;
    public list<OpportunityLineItem> lineItems {get;set;}
    public list<OpportunityLineItem> UpdatedOppLineItems {get;set;}
    String oldStageName ;
    String oldProbability ;
    
    //CR11453 - consolidate Ocean/LOT function
    public boolean toPursue = false;
    private boolean noPursueOption = false;  
    public list<OpportunityLineItem> tempLineItem;
    //CR11453 - consolidate Ocean/LOT function

    //3.1 Introduced custom settings
    private OWD__c owd = OWD__c.getOrgDefaults();

    public Vfcontrl_OpportunityEditPage() {
        oldOppStageName = ApexPages.currentPage().getParameters().get('OldOppStage');
        oldOppProbability = ApexPages.currentPage().getParameters().get('oldProbability');
        list<String> probAndStage = oldOppProbability.split('\\$');
        if(probAndStage.size() >= 1){
            oldProbability = probAndStage[0];
        }
        
        if(probAndStage.size() == 2){
            //3.1 - Start
            if(probAndStage[1] == 'propose60') {
                oldStageName = owd.Oppty_Stage60__c;
            } else if(probAndStage[1] == 'plan1') {
                oldStageName = owd.Oppty_Stage1__c;
            } else if(probAndStage[1] == 'discover10') {
                oldStageName = owd.Oppty_Stage10__c;
            } else if(probAndStage[1] == 'qualify30') {
                oldStageName = owd.Oppty_Stage30__c;
            } else if(probAndStage[1] == 'commit90') {
                oldStageName = owd.Oppty_Stage90__c;
            }
            //3.1 - End
        }
        
        //CR11453 create temporary LineItems record for Cancel function
        tempLineItem = new list<OpportunityLineItem>(UpdatedOppLineItems) ;
        //CR11453 added for if User select Save from Ocean Confirmation popup.
        PageReference pageRef = ApexPages.currentPage();
        Map<String, String> params = pageRef.getParameters();

        if(params.get('pursue') == 'true') {    
            toPursue = true;
        } else if(params.get('pursue') == null) {           
            noPursueOption = true;          
        }
        //end: CR11453
        oppId = ApexPages.currentPage().getParameters().get('id'); //newid');
        opp = [Select Id,RecordTypeId,Probability,Amount,StageName,ForecastCategoryName,Account_Country__c,Skip_Calculate_LOT_OCEAN__c,order_Compliance_Product__c,Needed_Quote_Notification_Pop_Up__c,LOT_Mandatory_Fields__c, 
              Eligible_for_Ocean__c, Do_you_want_to_pursue_Ocean__c, How_many_shipments__c, CloseDate, LOT_Large_Opportunity__c, Ocean_Opportunity_Notification_Pop_Up__c from Opportunity where id =: oppId];
    }
      
    public pageReference redirectToDetail(){
        String redirectURL;
        pagereference page ;
        
        lineItems = new list<OpportunityLineItem>();
        //Modified by Shivam
        if(ApexPages.CurrentPage().getParameters().get('readOnly')== 'true' || ApexPages.CurrentPage().getParameters().get('readOnly')=='false'){
        lineItems = [SELECT Id, OpportunityId, PricebookEntryId,Total_Price_in_USD__c,Ocean_Indicator__c, Opportunity.Account_Country_Code__c, Opportunity.Account_Country__c, Quantity, ListPrice, PricebookEntry.UnitPrice, TotalPrice, Quote__c, 
                    PricebookEntry.Name, PricebookEntry.Product2Id, Product2.Order_Compliant_Product__c,LOT_Indicator__c,Configuration_Services__c, Customer_Requested_Date__c, Request_Type__c, Supportability_Status__c, Support_by_Date__c,
                    Supported_Quantity__c, Alternate_Item__c, Supportability_Comments__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        }
        else{
        lineItems = [SELECT Id, OpportunityId, PricebookEntryId,Total_Price_in_USD__c, Ocean_Indicator__c,Opportunity.Account_Country_Code__c, Opportunity.Account_Country__c, Quantity, ListPrice, PricebookEntry.UnitPrice, TotalPrice, Quote__c, 
                    PricebookEntry.Name, PricebookEntry.Product2Id, Product2.Order_Compliant_Product__c,LOT_Indicator__c,Configuration_Services__c, Customer_Requested_Date__c, Request_Type__c, Supportability_Status__c, Support_by_Date__c,Supported_Quantity__c,
                    Alternate_Item__c, Supportability_Comments__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id AND (Quantity = null OR Configuration_Services__c = null OR Quote__c = null OR Customer_Requested_Date__c = null)];
        }
        
        Decimal totalPrice = 0; 
        
        set<PricebookEntry> priceBookIds = new set<PricebookEntry>();
        boolean isCountryValid = false;
        UpdatedOppLineItems = new list<OpportunityLineItem>();
        
        // Get all LATAM Region country codes (from Custom settings: LATAM_Country_Codes__c)
        List<LATAM_Country_Codes__c> latamCountryCodes = LATAM_Country_Codes__c.getall().values();
        set<String> latamCodes = new set<String>();
        
        for(LATAM_Country_Codes__c latam: latamCountryCodes){
            latamCodes.add(latam.Name);
        }
        if(lineItems.size() > 0){
            for(OpportunityLineItem oppProd: lineItems){
                System.Debug('Price'+oppProd.Total_Price_in_USD__c);
                System.Debug('Price'+Decimal.valueOf(System.Label.Threshold_US));
                
                boolean showOppLineItem = false;
                
                //Needed Quote threshold
               if( (oppProd.Opportunity.Account_Country__c == 'United States' && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US)) || ((latamCodes.contains(oppProd.Opportunity.Account_Country_Code__c) == true ) && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_LATAM))
                     || ((oppProd.Opportunity.Account_Country__c != 'United States' && (latamCodes.contains(oppProd.Opportunity.Account_Country_Code__c) == false ) ) && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_Others) )){
                    
                    isCountryValid = true;
                    priceBookIds.add(oppProd.PricebookEntry);
                    showOppLineItem = true;
                }
                if(ApexPages.CurrentPage().getParameters().get('readOnly')== 'true' || ApexPages.CurrentPage().getParameters().get('readOnly')=='false'){
                        if(oppProd.LOT_Indicator__c || oppProd.Ocean_Indicator__c || (oppProd.Product2.Order_Compliant_Product__c && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US) )){
                          UpdatedOppLineItems.add(oppProd);
                        }                    
                }
                else{
                    //Ocean/LOT
                    //CR12751 Added check Configuration Services and Quantity
                    if(oppProd.Quote__c == null || oppProd.Customer_Requested_Date__c == null || oppProd.Configuration_Services__c == null || oppProd.Quantity == null){
                        showOppLineItem = true;    
                    }
                    
                    if(showOppLineItem){    
                        //CR12751 Added check Configuration Services and Quantity
                        if((oppProd.LOT_Indicator__c || oppProd.Ocean_Indicator__c ||  (oppProd.Product2.Order_Compliant_Product__c && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US)))  && (oppProd.Quote__c == null||oppProd.Customer_Requested_Date__c== null || oppProd.Quantity == null || oppProd.Configuration_Services__c==null)){
                          UpdatedOppLineItems.add(oppProd);
                        }
                    }
                }
            }
        } 
        else{ //no line items with blank 'Quote #' or blank 'Customer Requested Date'
            //Modified by Shivam
            if(ApexPages.CurrentPage().getParameters().get('readOnly')=='true' || ApexPages.CurrentPage().getParameters().get('readOnly')=='false'){
                return null;
            }
        }
        
        if(ApexPages.CurrentPage().getParameters().get('readOnly')=='true' || ApexPages.CurrentPage().getParameters().get('readOnly')=='false'){
                return null;
        }
        else{
            set<Id> productIds = new set<Id>();
            for(PricebookEntry priceBok: priceBookIds){
                productIds.add(priceBok.Product2Id);
            }
            list<Product2> prod2List = new list<Product2>();
            prod2List = [Select Id, Order_Compliant_Product__c,EOL_Date__c  from Product2 where Id IN: productIds];
            
            boolean orderCompProduct = false;
            
            for(Product2 prod2: prod2List){
                if(prod2.Order_Compliant_Product__c == true){
                    orderCompProduct = true;
                }    
            }
            redirectURL = '/' + oppId;
            page = new pagereference(redirectURL);
            
            if((opp.RecordTypeId != '012300000004zf2' || opp.RecordTypeId != '012A0000000Vhy7' ||
                opp.RecordTypeId != '012A0000000TWOi' ) && UpdatedOppLineItems.size() == 0){
                Opportunity opp = new Opportunity(Id=opp.Id);
                opp.Needed_Quote_Notification_Pop_Up__c = false;
                update opp;               
                page.setRedirect(TRUE);
                return page;
            }
            else if(UpdatedOppLineItems.size() > 0)
            {
                if(opp.Probability >= 60 && (opp.RecordTypeId == '012300000004zf2' || opp.RecordTypeId == '012A0000000Vhy7' ||
                opp.RecordTypeId == '012A0000000TWOi' ) && orderCompProduct == true && isCountryValid == true ){            
                    return null;
                }
            }
        }
        return null;
    }
    
    //CR11453 added Ocean/LOT notification function
    public String getEligibleToMessage() {
        
        String str = '';
        
        if(opp.LOT_Mandatory_Fields__c) {  //LOT but decided not to pursue OCEAN
            str='This Opportunity has been identified as a Large Order and requires Quote Number, Quantity, Configuration Services and Customer Requested Date to be populated. Clicking \'Cancel\' will result in the Opportunity not being marked as LOT and the Stage / Probability will not be updated.';
        }
        
        //OCEAN ONLY
        if(opp.Eligible_for_Ocean__c == 'Yes' && opp.Do_you_want_to_pursue_Ocean__c == 'Yes'&& !opp.LOT_Mandatory_Fields__c) {
            for(OpportunityLineItem lineItems : UpdatedOppLineItems){
                //CR12751 Added check Configuration Services and Quantity
                if(lineItems.Customer_Requested_Date__c == null || lineItems.Quote__c == null || lineItems.Configuration_Services__c == null || lineItems.Quantity == null){
                    str = 'You have chosen to pursue Ocean shipping and this requires Quote #, Quantity, Configuration Services and Customer Requested Date to be populated.';
                }
            }
        }
        //LOT and OCEAN
        if(opp.LOT_Mandatory_Fields__c && opp.Eligible_for_Ocean__c == 'Yes' && opp.Do_you_want_to_pursue_Ocean__c == 'Yes' && !opp.Ocean_Opportunity_Notification_Pop_Up__c) {
            for(OpportunityLineItem lineItems : UpdatedOppLineItems){
                //CR12751 Added check Configuration Services and Quantity
                if(lineItems.Customer_Requested_Date__c == null || lineItems.Quote__c == null || lineItems.Configuration_Services__c == null || lineItems.Quantity == null){
                    str = 'This Opportunity has been identified as a Large Order and selected to pursue Ocean shipping. Please populate Quote #, Quantity, Configuration Services and Customer Requested Date. Clicking \'Cancel\' will result in the Opportunity not being marked as LOT, not being marked to pursue Ocean, and the Stage / Probability will not be updated.';
                }
            } 
        }
        return str;
    }
    
    public PageReference save(){   
        //CR11453 
        //1. for each line item
        for(OpportunityLineItem lineItems : UpdatedOppLineItems){
            //CR12751 Added check Configuration Services and Quantity
            if(lineItems.Quote__c == null || lineItems.Customer_Requested_Date__c == null || lineItems.Quantity == null || lineItems.Configuration_Services__c == null) {
                Boolean returnNull = false;
                
                //Added LOT_Mandatory_Fields__C for CR4118, to remove dependency of Quote Numbers and OCEAN
                if(lineItems.Quote__c == null && opp.LOT_Mandatory_Fields__c) {
                    ApexPages.addMessages(new dellUtil.dellException('Quote #: This field must not be null'));
                    returnNull = true;
                }
                 /*******Modification for CR 2810*****************/
                if(lineItems.Customer_Requested_Date__c == null && opp.Eligible_for_Ocean__c == 'Yes' && opp.Do_you_want_to_pursue_Ocean__c == 'Yes') {
                    ApexPages.addMessages(new dellUtil.dellException('Customer Requested Date: This field must not be null'));
                    returnNull = true;
                }
                if(opp.How_many_shipments__c == null) {                
                    ApexPages.addMessages(new dellUtil.dellException('Number of Shipments / Deliveries?: This field must not be null'));
                    returnNull = true;
                }                      
                if(opp.How_many_shipments__c > 1) {             
                    ApexPages.addMessages(new dellUtil.dellException('Largest Volume to be Delivered is mandatory when Number of Shipments / Deliveries is more than 1'));
                    returnNull = true;
                }
                if (returnNull) {
                    return null;
                }
            }  
            if(lineItems.Customer_Requested_Date__c != null && lineItems.Customer_Requested_Date__c <= opp.CloseDate) {
                ApexPages.addMessages(new dellUtil.dellException('Customer Requested Date: Customer Requested Date should not be earlier than the Book Date.'));
                return null;
            }             
        }
        //end for(OpportunityLineItem lineItems : UpdatedOppLineItems)
        
        if(opp.LOT_Mandatory_Fields__c) {
            opp.LOT_Large_Opportunity__c = true;
            opp.LOT_Mandatory_Fields__c = false;
        }
        
        if(opp.Eligible_for_Ocean__c == 'Yes' && opp.Ocean_Opportunity_Notification_Pop_Up__c) {
            opp.Ocean_Opportunity_Notification_Pop_Up__c = false;
            
            if(!noPursueOption) {                  
                if (toPursue)
                {
                    opp.Do_you_want_to_pursue_Ocean__c = 'Yes';
                }
                else
                {        
                    opp.Do_you_want_to_pursue_Ocean__c = 'No';
                }
            }
        }   
        try {
            Database.SaveResult[] ObjOLIResult = Database.update(UpdatedOppLineItems,false);
            for(Database.SaveResult objOLIUpdate:ObjOLIResult ){
                if (!objOLIUpdate.isSuccess()){
                    for (Database.Error error : objOLIUpdate.getErrors()) {
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error.getMessage());
                          ApexPages.addMessage(myMsg); 
                          return null;
                    }
                }
            }
            //update UpdatedOppLineItems; // lineItems;
            
            opp.order_Compliance_Product__c = false;
            GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION = true;
            Database.SaveResult ObjOppResult = Database.update(opp,false);
            if (!ObjOppResult.isSuccess()){
                for (Database.Error error : ObjOppResult.getErrors()) {
                      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error.getMessage());
                      ApexPages.addMessage(myMsg); 
                      return null;
                }
            }
            //update opp;
            GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION = false;
            
            //Modified by Shivam
            if(ApexPages.CurrentPage().getParameters().get('readOnly')=='true' || ApexPages.CurrentPage().getParameters().get('readOnly')=='false'){
                PageReference p = ApexPages.CurrentPage();
                p.getParameters().put('readOnly','true');
                p.setRedirect(true);
                return p;
            }
            else{
                return new PageReference('/'+opp.Id);
            }
            
        } catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    //Added by shangeetha - 
    public pagereference editURL()
    {
        PageReference p = ApexPages.CurrentPage();
        p.getParameters().put('readOnly', 'false');
        p.setredirect(true);
        return p;
    }
    
    public PageReference cancel(){
        
        if(ApexPages.CurrentPage().getParameters().get('readOnly')=='true' || ApexPages.CurrentPage().getParameters().get('readOnly')=='false'){
                PageReference p = ApexPages.CurrentPage();
                p.getParameters().put('readOnly','true');
                p.setRedirect(true);
                return p;
        }
        else
        {
                //CR11453 revert lineItems changes
                //CR#8979 - Defect#97050 - Sree Prakash on 25 Feb 2014.
            if(opp.StageName == owd.Oppty_Stage30__c){ //3.1
                opp.Probability = 30;
                // Sai changes for Forecast Category also Updating While using Forecast Category Override.
                opp.ForecastCategoryName = 'Pipeline';
                opp.Probability_Currently_Overridden__c = false;
                }
            System.Debug('========ForecastCategoryName========'+opp.ForecastCategoryName);
            System.Debug('========Probability======'+opp.Probability);              
            // Sai changes for Forecast Category also Updating
            if(opp.StageName == owd.Oppty_Stage60__c){ //3.1
                opp.StageName = 'Qualify - 30%';  
                opp.Probability = 30;
                opp.ForecastCategoryName = 'Pipeline';
                opp.Probability_Currently_Overridden__c = false;    
            
            System.Debug('========ForecastCategoryName========'+opp.ForecastCategoryName);
            System.Debug('========Probability======'+opp.Probability);
            }
            //CR 4188: Cancelling LOT sets Stage to 30% when Deal is actually less than that 
            if (opp.LOT_Mandatory_Fields__c )
            {
                opp.Region__c='APJ';
                opp.Competitor_Lost_To__c='Unknown';
                //LOT and Ocean fields manipulated on cancel
                opp.LOT_Mandatory_Fields__c = false;
                opp.LOT_Large_Opportunity_Potential__c = true;                                  
            }
            if(opp.order_Compliance_Product__c){
                opp.order_Compliance_Product__c = false;
            }
            if(opp.Eligible_for_Ocean__c == 'Yes'){
                opp.order_Compliance_Product__c = false;
                opp.Do_you_want_to_pursue_Ocean__c = 'No';
                opp.Ocean_Opportunity_Notification_Pop_Up__c = false;
            }
            for(OpportunityFieldHistory obj:[SELECT CreatedDate,Field,Id,NewValue,OldValue,OpportunityId FROM OpportunityFieldHistory where OpportunityId =:opp.Id and Field='StageName' order by CreatedDate DESC LIMIT 1]){
                if(opp.StageName != owd.Oppty_Stage99__c && opp.StageName == obj.NewValue){//3.0
                     string oldStageName = (string)obj.OldValue;
                     String[] oldprob = oldStageName.split('-');
                     string newStageName = opp.StageName;
                     String[] newprob = newStageName.split('-');
                     if(Decimal.valueOf(oldprob[1].removeEnd('%').trim()) < Decimal.valueOf(newprob[1].removeEnd('%').trim())){             
                        opp.StageName = (string)obj.OldValue;
                        opp.probability = Decimal.valueOf(oldprob[1].removeEnd('%').trim()); 
                     }
                }
            }
            opp.Needed_Quote_Notification_Pop_Up__c =false; 
            Database.SaveResult ObjResult = Database.update(opp,false);
            if (!ObjResult.isSuccess()){
                for (Database.Error error : ObjResult.getErrors()) {
                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error.getMessage());
                       ApexPages.addMessage(myMsg); 
                       return null;
                }
            }
            GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION = false; 
            return new PageReference('/'+opp.Id);
        }
    }
}
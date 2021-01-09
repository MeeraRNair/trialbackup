/* 
REVISION HISTORY
================
Version    Author    Date            Release#    CR#     Description
-------    ------    ----            --------    ---     -----------
1.0        Rap   03-Dec-2012           14.2      ---     Controller for SnPMSAdditionalInfo page (and the other wizard pages)
2.0        Rap   14-Mar-2013           14.3  8051 & 8052 Added the delete function and the additional products for EAP
3.0        Rap   08-Apr-2013           14.3      ---     Added Currency converter and reporting fields
4.0        Rap   16-Apr-2013           14.3      ---     Added the reporting fix
5.0        Rap   17-Apr-2013           14.5  8210 & 8211 Added the Minimum THreshold column. Untied SIP Incentive for EA, EAP, ECI. Add the $50k cap on SIP Fees
6.0        Rap   21-Jul-2013           14.10     ---     Added the EAS product
7.0        Rap   21-May-2014           15.07     9456    Added the SCE product
*/

public class SnP_MSAdditionalInfoController {
    
    /*
        Variable declarations. If you notice, we have a lot of list variables declared. This is because some of them are manipulated, while some of them are
        for display only. The others are for the other datatables (Threshold, Summary, etc.).
    */
    S_P_Vendors__c spVendors;
    
    Integer eaCount, wizCounter=0, moreProd = 0, eaSizeCount = 0, eaNullCount = 0, dupeCheck = 0, SQLCounter = 0, SQLEAPCounter = 0, deleteCheck = 0, currencyCheck = 0;
    Decimal totalProd = 0, totalEa = 0, totalAll = 0, currencyMultiplier = 1, minRevConverter = 1, convertedTotalProd = 0, convertedTotalEa = 0, sipFeeLimit = 0, nonUsdRate = 1;
    String currentProfile, userCurrency, errorMsg;
    PageReference newPage;
    
    List<CurrencyType> conversionRate = new List<CurrencyType>();
    
    List<S_P_Vendor_Additional_Information__c> addlInfoQuery = new List<S_P_Vendor_Additional_Information__c>();
    List<S_P_Vendor_Additional_Information__c> addlInfoQuerySVSip = new List<S_P_Vendor_Additional_Information__c>();
    List<S_P_Vendor_Additional_Information__c> addlInfoQuerySVEa = new List<S_P_Vendor_Additional_Information__c>();
    List<S_P_Vendor_Additional_Information__c> addlInfoQueryToInsert = new List<S_P_Vendor_Additional_Information__c>();
    List<S_P_Vendor_Additional_Information__c> addlNewInfoQueryToInsert = new List<S_P_Vendor_Additional_Information__c>();
    List<S_P_Vendor_Additional_Information__c> addlInfoQueryMain = new List<S_P_Vendor_Additional_Information__c>();
    List<S_P_Vendor_Additional_Information__c> addlInfoQueryToDelete = new List<S_P_Vendor_Additional_Information__c>();
    
    List<S_P_Vendor_Product_Selection__c> prodSelQuery = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> prodSelQueryToInsert = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> prodSelQueryToInsertTmp = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> prodSelQueryToDelete = new List<S_P_Vendor_Product_Selection__c>();
    
    List<S_P_Vendor_Product_Threshold__c> threshQuery = new List<S_P_Vendor_Product_Threshold__c>();
    
    List<S_P_Vendor_Product_Selection__c> eaProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> eaAddlProducts = new List<S_P_Vendor_Product_Selection__c>(); 
    List<S_P_Vendor_Product_Selection__c> eapProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> eapAddlProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> eciProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> eciAddlProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> easProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> easAddlProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> sceProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> sceAddlProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> eaAddlProductsToDelete = new List<S_P_Vendor_Product_Selection__c>();
    
    List<S_P_Vendor_Product_Selection__c> sipProducts = new List<S_P_Vendor_Product_Selection__c>();    
    List<S_P_Vendor_Product_Selection__c> sipAddlProducts = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> sipAddlProductsToDisplay = new List<S_P_Vendor_Product_Selection__c>();
    
    List<S_P_Vendor_Product_Selection__c> eaAddlProductsToDisplay = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> eapAddlProductsToDisplay = new List<S_P_Vendor_Product_Selection__c>(); 
    List<S_P_Vendor_Product_Selection__c> eciAddlProductsToDisplay = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> easAddlProductsToDisplay = new List<S_P_Vendor_Product_Selection__c>();
    List<S_P_Vendor_Product_Selection__c> sceAddlProductsToDisplay = new List<S_P_Vendor_Product_Selection__c>();
    
    List<eaThrshldRow> eaThrshldMet = new List<eaThrshldRow>();
    List<eaThrshldRow> eapThrshldMet = new List<eaThrshldRow>();
    List<eaThrshldRow> eciThrshldMet = new List<eaThrshldRow>();
    List<eaThrshldRow> easThrshldMet = new List<eaThrshldRow>();
    List<eaThrshldRow> sceThrshldMet = new List<eaThrshldRow>();
    List<eaThrshldRow> sipThrshldMet = new List<eaThrshldRow>();
    List<eaThrshldRow> allThrshMet = new List<eaThrshldRow>();
    List<eaThrshldRow> prodSummaryTmp = new List<eaThrshldRow>();
    
    List<S_P_Vendor_Product_Selection__c> prodSelThreshold = new List<S_P_Vendor_Product_Selection__c>();
    
    /*
        These getter-setters are mostly used for the buttons on the page.
    */
    public Boolean closeMoreProducts {get; set;}
    public Boolean closeMoreProductSip {get; set;}
    public Boolean closeAddProductsText {get; set;}
    public Boolean closeAddProductsTextSip {get; set;} 
    public Boolean closeDelButton {get; set;}
    public Boolean closeDelButtonSip {get; set;} 
    public Boolean displayPopup {get; set;}
    public Boolean refreshPage {get; set;}
    
    /*
        Constructor method.
    */
    public SnP_MSAdditionalInfoController(ApexPages.StandardController stdController){
        
        this.spVendors = (S_P_Vendors__c)stdController.getRecord();
        
        /*
            Query the 3 main objects: S&P Vendor Additional Information, S&P Vendor Product Selection, S&P Vendor Product Threshold.
        */
        addlInfoQuery = [SELECT EA_Type__c, Agreement_Level__c, Total__c, Level__c, Approval_Number__c, Comments__c, Deal_Reg_Status__c, CurrencyIsoCode,
                        EA_Fees_Total__c, Expiry_Date__c, Opportunity_Name__c, Products_Included__c, SIP_Incentive__c, SnP_Vendor_ID__c, SIP_Threshold_Met__c, S_P_Vendor_Product_Threshold__c,
                        EA_Enterprise_Product__c, EA_Enterprise_Product_Quantity__c, EA_Enterprise_Product_Unit_Price__c, EA_Enterprise_Product_Total__c
                        FROM S_P_Vendor_Additional_Information__c WHERE S_P_Vendors_ID__c = :spVendors.Id];
        
        prodSelQuery = [SELECT Type__c, EA_Enterprise_Product__c, Quantity__c, Unit_Price__c, Total__c, SIP_Incentive__c, Remove__c,
                            Additional_Product_Type__c, New_Products_Only__c, SIP_Fees__c, S_P_Vendor_Product_Threshold__c, SIP_Threshold_Met__c, S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c
                            FROM S_P_Vendor_Product_Selection__c WHERE S_P_Vendor_Additional_Information_ID__r.S_P_Vendors_ID__c = :spVendors.Id Order By Id ];
        
        threshQuery = [SELECT Agreement_Level__c, Level__c, Minimum_Revenue__c, Percentage__c, Product_Description__c,
                            Product_Family__c, Threshold_Required__c
                            FROM S_P_Vendor_Product_Threshold__c];
        
        /*
            Query the Profile object to check the profile name for the Edit button in the Additional SV Screen tab.
        */
        currentProfile = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()].Name;
        
        /*
            Query the user's currency for manual conversion.
        */
        userCurrency = [SELECT DefaultCurrencyIsoCode FROM User WHERE Id = :Userinfo.getUserId()].DefaultCurrencyIsoCode;
        
        /*
            Query the conversion rate from CurrencyType object. Get the currency multiplier for currency conversion .
        */
        
        conversionRate = [SELECT IsoCode, ConversionRate, IsActive FROM CurrencyType WHERE IsActive = true];
        if(userCurrency != spVendors.Opportunity__r.CurrencyIsoCode){
            currencyCheck = 1;
            getCurrencyMultiplier();
        }
        
        
        
        if(spVendors.Opportunity__r.CurrencyIsoCode == 'USD')
            sipFeeLimit = 25000;
            
            else{
                for(CurrencyType cu : conversionRate)
                    if(cu.IsoCode == spVendors.Opportunity__r.CurrencyIsoCode)
                        
                        nonUsdRate = cu.ConversionRate;
                
                
                sipFeeLimit = 25000 * nonUsdRate;
                minRevConverter = nonUsdRate;
                
            }
                
        /*
            If prodSelQuery is not empty, it means products are already entered for the particular SV. These values must be assigned to the variables so that it appears in the pages.
        */
        if(!(prodSelQuery.isEmpty())) 
            assignEaProducts();
            
        /*
            EA Detail (if Enterprise Agreement = Yes).
        */
        if(spVendors.Is_this_an_Enterprise_Agreement__c == 'Yes'){
            for(S_P_Vendor_Additional_Information__c ea : addlInfoQuery )
                    if(ea.Level__c == 'EA' && ea.EA_Fees_Total__c != null){
                        addlInfoQuerySVEa.add(ea);
                        addlInfoQueryMain.add(ea);
                        totalEa += ea.EA_Fees_Total__c;
                    }
            
            convertedTotalEa = totalEa * currencyMultiplier;
            
            /*
                The 3 initial rows in EA Detail tab. now 4, EAS is added.
                
            */
            if(addlInfoQueryMain.isEmpty()){
                eaCount = 4 - addlInfoQueryMain.size();
                    while (eaCount > 0){
                        addlInfoQueryMain.add(new S_P_Vendor_Additional_Information__c(S_P_Vendors_ID__c = this.spVendors.Id, Level__c = 'EA' )); 
                        eaCount--;
                    }
            }
            
            /*
                This will prevent to display SQL products from EA and/or EAS if SQL also exists in EAP (in Additional SV Screen tab) .
            */
            for(S_P_Vendor_Additional_Information__c ea : addlInfoQuery){
                if(ea.SIP_Threshold_Met__c == 'Yes' && ea.EA_Fees_Total__c == null){//&& ea.SIP_Incentive__c != 'Product Not Eligible for SIP' && ea.EA_Fees_Total__c == null){
                    addlInfoQuerySVEa.add(ea);
                    if(ea.Products_Included__c == 'SQL')
                        SQLCounter++;
                    if(ea.EA_Type__c == 'EAP')
                        SQLEAPCounter++;
                }
            }
            
            if(SQLEAPCounter > 0){
                for(Integer i = 0; i < addlInfoQuerySVEa.size(); i++){
                    if((addlInfoQuerySVEa.get(i).EA_Type__c == 'EA' || addlInfoQuerySVEa.get(i).EA_Type__c == 'EAS') && addlInfoQuerySVEa.get(i).Products_Included__c == 'SQL' && (SQLCounter == 2 || SQLCounter == 3)){
                        addlInfoQuerySVEa.remove(i);
                        i--;
                    }
                }
            }
            SQLCounter = 0;
        
        }
        
        /*
            Product Detail (if Enterprise Agreement = No).
        */
        if(spVendors.Is_this_an_Enterprise_Agreement__c == 'No'){
            eaCount = 1 - sipProducts.size();
            while (eaCount > 0){
                sipProducts.add(new S_P_Vendor_Product_Selection__c(Type__c = 'SIP' )); 
                eaCount--;
            }
            
            if(!(addlInfoQuery.isEmpty())){
                for(S_P_Vendor_Additional_Information__c ea : addlInfoQuery)
                    if(ea.SIP_Threshold_Met__c == 'Yes' && ea.SIP_Incentive__c != 'Product Not Eligible for SIP')
                        addlInfoQuerySVSip.add(ea);
            }
        }
    }
    
    /*
        This method gets the currency multiplier. Works especially when both opp and user currency are not USD.
    */
    public void getCurrencyMultiplier(){
        Decimal userRate = 1, oppRate = 1;
        
        for(CurrencyType cu : conversionRate){
            if(cu.IsoCode == userCurrency)
                userRate = cu.ConversionRate;
            if(cu.IsoCode == spVendors.Opportunity__r.CurrencyIsoCode)
                oppRate = cu.ConversionRate;
        }
        
        currencyMultiplier = userRate/oppRate;
    }
    
    //////////////////////////////////////////////
    public PageReference showNewSipPage(){
        moreProd = sipAddlProducts.size();
        if(moreProd > 0)
            closeMoreProductSip = true;
        return Page.SnPMSAdditionalInfoNewEditEA;
    }
    
    public PageReference showEditSVPage(){
        return Page.SnPMSAdditionalSVforEdit;
    }
    
    public PageReference saveEaSV(){
        upsert addlInfoQuerySVEa;
        refreshPage = true;
        return null;
        
    }
    
    public PageReference saveSipSV(){
        upsert addlInfoQuerySVSip;
        refreshPage = true;
        return null;
    }
    ////////////////////////////////////////////
    
    /*
        Method for the first part of the wizard which checks the inputs on the very first page where user chooses EA, EAP, or ECI. This method has validation checks,
        and also checks which product page will be shown first as per the order of input in the first page.
    */
    public PageReference wizardStart(){
        
        for(Integer i = 0; i < addlInfoQueryMain.size(); i++){
            if(addlInfoQueryMain.get(i).EA_Type__c != null){
                if(addlInfoQueryMain.get(i).Agreement_Level__c == null || addlInfoQueryMain.get(i).Total__c == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Agreement Level and EA Year 1 Total must have a value.'));
                    eaSizeCount = 0;
                    return null;    
                }
                eaSizeCount++;
            }
            
            if((addlInfoQueryMain.get(i).Agreement_Level__c != null || addlInfoQueryMain.get(i).Total__c != null)&& addlInfoQueryMain.get(i).EA_Type__c == null ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'EA Type must have a value.'));
                eaSizeCount = 0;
                return null;
            }
                
            for(Integer j = i + 1; j < addlInfoQueryMain.size(); j++){
                if(addlInfoQueryMain.get(j).EA_Type__c != null && addlInfoQueryMain.get(j).EA_Type__c == addlInfoQueryMain.get(i).EA_Type__c){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'EA Type must be unique.'));
                    eaSizeCount = 0;
                    return null;
                }
                        
            }
            
            if(addlInfoQueryMain.get(i).EA_Type__c == null)
                eaNullCount++;
            
        }
        
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c != null ){
        
            checkNextPreviousPage();
            return newPage;
                                
        }   
            else{   
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'First EA input row must have a value.'));
                eaSizeCount = 0;
                return null;
            }
        
        return null;        

    }
    
    
    /*
        Method that runs when the user hits the Back button when the wizard is started.
    */
    public PageReference previousPage(){
        
        wizCounter--;
        
        if(wizCounter >= 0 ){
            
            for(Integer i = wizCounter; i < addlInfoQueryMain.size(); i--){
                if(addlInfoQueryMain[wizCounter].EA_Type__c != null)
                    break;
                if(addlInfoQueryMain[wizCounter].EA_Type__c == null){
                    wizCounter--;
                    eaSizeCount--;
                }
            }
            
            checkNextPreviousPage();
            return newPage;
                        
        }   
        
        else{
                
            wizCounter = 0;
            eaSizeCount = 0;
            return Page.SnPMSAdditionalInfoNewEditEA;
        
        }
        
        return null;
        
    }
    
    /*
        Method that runs when the user hits the Next button when the wizard is started. Has validation checks for the products entered, and also has a check where the
        final/summary page will be displayed when the last Next button is hit.
    */
    public PageReference nextPage(){
        
        if(wizCounter >= 0){
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EA'){
                productValidations(eaProducts, eaAddlProducts, eaAddlProductsToDisplay, 'EA');
                if(errorMsg != null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
                    return null;
                }
            }
            
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAP'){
                productValidations(eapProducts, eapAddlProducts, eapAddlProductsToDisplay, 'EA');
                if(errorMsg != null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
                    return null;
                }
            }
            
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'ECI'){
                productValidations(eciProducts, eciAddlProducts, eciAddlProductsToDisplay, 'EA');
                if(errorMsg != null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
                    return null;
                }
            }
            
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAS'){
                productValidations(easProducts, easAddlProducts, easAddlProductsToDisplay, 'EA');
                if(errorMsg != null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));
                    return null;
                }
            }
            
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'SCE'){
                productValidations(sceProducts, sceAddlProducts, sceAddlProductsToDisplay, 'EA');
                if(errorMsg != null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));               
                    return null;
                }
            }
            
            
        }
            wizCounter++;
        
        if(wizCounter == eaSizeCount){
            
            /*
                This "ToDelete" list contains all the products that are flagged for deletion.
            */
            eaAddlProductsToDelete.clear();
            
            for(Integer i = 0; i < eaAddlProducts.size() ; i++){
                if(eaAddlProducts.get(i).Remove__c == TRUE && eaAddlProducts.get(i).Id != null)
                    eaAddlProductsToDelete.add(eaAddlProducts[i]);     
            }
            
            for(Integer i = 0; i < eapAddlProducts.size() ; i++){
                if(eapAddlProducts.get(i).Remove__c == TRUE && eapAddlProducts.get(i).Id != null)
                    eaAddlProductsToDelete.add(eapAddlProducts[i]);     
            }
            
            for(Integer i = 0; i < eciAddlProducts.size() ; i++){
                if(eciAddlProducts.get(i).Remove__c == TRUE && eciAddlProducts.get(i).Id != null)
                    eaAddlProductsToDelete.add(eciAddlProducts[i]);     
            }
            
            for(Integer i = 0; i < easAddlProducts.size() ; i++){
                if(easAddlProducts.get(i).Remove__c == TRUE && easAddlProducts.get(i).Id != null)
                    eaAddlProductsToDelete.add(easAddlProducts[i]);     
            }
            
            for(Integer i = 0; i < sceAddlProducts.size() ; i++){
                if(sceAddlProducts.get(i).Remove__c == TRUE && sceAddlProducts.get(i).Id != null)
                    eaAddlProductsToDelete.add(sceAddlProducts[i]);     
            }
            
            eaThrshldMet.clear();
            eapThrshldMet.clear();
            eciThrshldMet.clear();
            easThrshldMet.clear();
            sceThrshldMet.clear();
            prodSelThreshold.clear();
            prodSelQueryToInsert.clear();
            addlInfoQueryToInsert.clear();
            addlNewInfoQueryToInsert.clear();
            
            /*
                These are the methods that calculates the entered products and computes the threshold.
            */
            upsertEaType();
            upsertEaProducts();
            checkThresholdSummary();
            
            
            return Page.SnPMSWizardPageFinal;
        }
        
        else{
            
            /*
                This "else" will go to the currentPage() when the Next button that is hit is not yet the last one.
            */
            
            for(Integer i = wizCounter; i < addlInfoQueryMain.size(); i++){
                if(addlInfoQueryMain[wizCounter].EA_Type__c != null)
                    break;
                if(addlInfoQueryMain[wizCounter].EA_Type__c == null){
                    wizCounter++;
                    eaSizeCount++;
                }
            }
            
            
            checkNextPreviousPage();
            return newPage;
                        
        }   
        
        return null;
        
    }
    
    /*
        Method for product validations on each page
    */
    
    public void productValidations(List<S_P_Vendor_Product_Selection__c> enterpriseProds, List<S_P_Vendor_Product_Selection__c> addlProds, List<S_P_Vendor_Product_Selection__c> addlProdsToDisplay, String type){   
        
        errorMsg = null;
        
        if(type == 'SIP'){
            for(S_P_Vendor_Product_Selection__c prod : enterpriseProds){
                for(S_P_Vendor_Product_Selection__c addl : addlProds) {
                    if(prod.New_Products_Only__c == addl.New_Products_Only__c){
                        errorMsg ='Duplicate New Products Only has been chosen , please correct to proceed';
                    }
                }
            }
        }
        
        if(type == 'EA'){
            for(S_P_Vendor_Product_Selection__c prod : enterpriseProds ){
                
                if(prod.EA_Enterprise_Product__c == null || prod.Quantity__c == null || prod.Unit_Price__c == null){
                    errorMsg = 'EA Enterprise Product, Quantity, and Unit Price must have a value.';
                }
            }
        }
        
        if(!(addlProds.isEmpty())){
            for(S_P_Vendor_Product_Selection__c prod : addlProds){
                if(prod.Additional_Product_Type__c == null || prod.New_Products_Only__c == null || prod.Quantity__c == null || prod.Unit_Price__c == null){
                    if(type == 'EA')
                        errorMsg ='Additional Product Type, New Products Only, Quantity, and Unit Price must have a value.';
                    if(type == 'SIP')
                        errorMsg ='SIP Deal Reg Type, New Products Only, Quantity, and Unit Price must have a value';
               }
            }
            
            if(addlProds.size() > 1){
                for(Integer i = 0; i < addlProds.size(); i++){
                    for(Integer j = i+1; j < addlProds.size(); j++){
                        if(addlProds.get(j).New_Products_Only__c == addlProds.get(i).New_Products_Only__c){
                            errorMsg ='Duplicate New Products Only has been chosen , please correct to proceed';
                        }
                    }
                }
            }
            
            /*
                addlProdsToDisplay are additional products that already exists, therefore this validation will check it against the eaAddlProducts list if the newly entered
                product is already Approved, Sent to Vendor, Limited Approval, Expired, Rejected, or Not Eligible. The same will go on for EAP and ECI.
            */
            if(!(addlProdsToDisplay.isEmpty())){
                for(Integer i = 0; i < addlProds.size(); i++){
                    for(Integer j = 0; j < addlProdsToDisplay.size(); j++){
                        if(addlProdsToDisplay.get(j).Additional_Product_Type__c == addlProds.get(i).Additional_Product_Type__c && 
                        (addlProdsToDisplay.get(j).S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Approved' || 
                        addlProdsToDisplay.get(j).S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Sent to Vendor' || 
                        addlProdsToDisplay.get(j).S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Limited Approval' || 
                        addlProdsToDisplay.get(j).S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Expired' || 
                        addlProdsToDisplay.get(j).S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Rejected' ||
                        addlProdsToDisplay.get(j).S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Not Eligible')){
                            errorMsg ='You have chosen a product that is either Approved, Sent to Vendor, Limited Approval, Expired, Rejected, or Not Eligible. Please correct to proceed';
                        }
                    }
                }
            }
            
        }
        
    }
    
    /*
        Method to check which page to display
    */
    
    public void checkNextPreviousPage(){
    
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EA'){
            currentPage();
            newPage = Page.SnPMSWizardPageEA;
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAP'){
            currentPage();
            newPage = Page.SnPMSWizardPageEAP;
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'ECI'){
            currentPage();
            newPage = Page.SnPMSWizardPageECI;
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAS'){
            currentPage();
            newPage = Page.SnPMSWizardPageEAS;
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'SCE'){
            currentPage();
            newPage = Page.SnPMSWizardPageSCE;
        }
        
    
    }
    
    /*
        This method displays the content for the current wizard page that is displayed. The logic whether the additional products and the delete button are displayed or not is also here.
    */
    public void currentPage(){
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EA'){
            Integer eaCheck = 0;
            moreProd = eaAddlProducts.size();
            if(eaProducts.isEmpty()){
                closeAddProductsText = false;
                eaProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                
            }
            else if(!(eaProducts.isEmpty())){
                    if(eaProducts.get(eaProducts.size()-1).EA_Enterprise_Product__c == null)
                        closeAddProductsText = false;
                        else
                            closeAddProductsText = true;
            }
                
            
            if(eaAddlProducts.isEmpty()){
                    closeMoreProducts = false;
                    closeDelButton = false;
            }        
                else{
                    closeMoreProducts = true;
                    closeDelButton = false;
            }
            
            if(eaAddlProducts.size() > 0){
                for(Integer i = 0; i < eaAddlProducts.size(); i++){
                    if(eaAddlProducts.get(i).Remove__c == TRUE)
                        eaCheck = 1;
                }
            }
            
            if(eaCheck == 1)
                closeDelButton = true;
            else
                closeDelButton = false;    
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAP'){
            Integer eapCheck = 0;
            moreProd = eapAddlProducts.size();
            if(eapProducts.isEmpty()){
                closeAddProductsText = false;
                eapProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                
            }
            else if(!(eapProducts.isEmpty())){
                    if(eapProducts.get(eapProducts.size()-1).EA_Enterprise_Product__c == null)
                        closeAddProductsText = false;
                        else
                            closeAddProductsText = true;
            }
                
            if(eapAddlProducts.isEmpty()){
                    closeMoreProducts = false;
                    closeDelButton = false;
            }        
                else{
                    closeMoreProducts = true;
                    closeDelButton = false;
            }
            
            if(eapAddlProducts.size() > 0){
                for(Integer i = 0; i < eapAddlProducts.size(); i++){
                    if(eapAddlProducts.get(i).Remove__c == TRUE)
                        eapCheck = 1;
                }
            }
            
            if(eapCheck == 1)
                closeDelButton = true;
            else
                closeDelButton = false;  
                
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'ECI'){
            Integer eciCheck = 0;
            moreProd = eciAddlProducts.size();
            if(eciProducts.isEmpty()){
                closeAddProductsText = false;
                eciProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                
            }
            else if(!(eciProducts.isEmpty())){
                    if(eciProducts.get(eciProducts.size()-1).EA_Enterprise_Product__c == null)
                        closeAddProductsText = false;
                        else
                            closeAddProductsText = true;
            }
                
            if(eciAddlProducts.isEmpty()){
                    closeMoreProducts = false;
                    closeDelButton = false;
            }        
                else{
                    closeMoreProducts = true;
                    closeDelButton = false;
            }
            
            if(eciAddlProducts.size() > 0){
                for(Integer i = 0; i < eciAddlProducts.size(); i++){
                    if(eciAddlProducts.get(i).Remove__c == TRUE)
                        eciCheck = 1;
                }
            }
            
            if(eciCheck == 1)
                closeDelButton = true;
            else
                closeDelButton = false;  
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAS'){
            Integer easCheck = 0;
            moreProd = easAddlProducts.size();
            if(easProducts.isEmpty()){
                closeAddProductsText = false;
                easProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                
            }
            else if(!(easProducts.isEmpty())){
                    if(easProducts.get(easProducts.size()-1).EA_Enterprise_Product__c == null)
                        closeAddProductsText = false;
                        else
                            closeAddProductsText = true;
            }
                
            
            if(easAddlProducts.isEmpty()){
                    closeMoreProducts = false;
                    closeDelButton = false;
            }        
                else{
                    closeMoreProducts = true;
                    closeDelButton = false;
            }
            
            if(easAddlProducts.size() > 0){
                for(Integer i = 0; i < easAddlProducts.size(); i++){
                    if(easAddlProducts.get(i).Remove__c == TRUE)
                        easCheck = 1;
                }
            }
            
            if(easCheck == 1)
                closeDelButton = true;
            else
                closeDelButton = false;    
        }
        
                if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'SCE'){
            Integer sceCheck = 0;
            moreProd = sceAddlProducts.size();
            if(sceProducts.isEmpty()){
                closeAddProductsText = false;
                sceProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                
            }
            else if(!(sceProducts.isEmpty())){
                    if(sceProducts.get(sceProducts.size()-1).EA_Enterprise_Product__c == null)
                        closeAddProductsText = false;
                        else
                            closeAddProductsText = true;
            }
                
            
            if(sceAddlProducts.isEmpty()){
                    closeMoreProducts = false;
                    closeDelButton = false;
            }        
                else{
                    closeMoreProducts = true;
                    closeDelButton = false;
            }
            
            if(sceAddlProducts.size() > 0){
                for(Integer i = 0; i < sceAddlProducts.size(); i++){
                    if(sceAddlProducts.get(i).Remove__c == TRUE)
                        sceCheck = 1;
                }
            }
            
            if(sceCheck == 1)
                closeDelButton = true;
            else
                closeDelButton = false;    
        }
        
    }
    
    /*
        This method will be the final method called that will do much of the database statements.
    */
    public PageReference finishWizard(){
        
            try{
                
                delete eaAddlProductsToDelete;
                evaluateProducts();
                
                /*
                    You can notice here that the Total is being calculated again. This is because the Total is getting affected in the threshold computation method even though it is
                    using another list. Root cause of why that happens is still unknown.
                */
                for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert){
                    if(prod.EA_Enterprise_Product__c == null)
                        prod.Total__c = prod.Unit_Price__c * prod.Quantity__c;
                    if(prod.EA_Enterprise_Product__c != null){
                        prod.Quantity__c = null;
                        prod.Unit_Price__c = null;
                    }
                }
                    
                upsert prodSelQueryToInsert;
                delete prodSelQueryToDelete;
                
                /*
                    This is a method to delete the Additional Information records that has no more child/products.
                */
                deleteNoChild();
                delete addlInfoQueryToDelete;
                
                
            }catch(DMLException e){
                ApexPages.addMessages(e);
            }
        
        refreshPage=true;

        return null;
    }
    
    /*
        This method checks whether the text that instructs user to add more products is displayed or not. Same for SIP below
    */
    public PageReference openAddProductsText(){
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EA')
            if(eaProducts.get(eaProducts.size()-1).EA_Enterprise_Product__c != null)
                closeAddProductsText = true;
        
        else
            closeAddProductsText = false;
        
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAP')
            if(eapProducts.get(eapProducts.size()-1).EA_Enterprise_Product__c != null)
                closeAddProductsText = true;
        
        else
            closeAddProductsText = false;
        
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'ECI')
            if(eciProducts.get(eciProducts.size()-1).EA_Enterprise_Product__c != null)
                closeAddProductsText = true;
        
        
        else
            closeAddProductsText = false;
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAS')
            if(easProducts.get(easProducts.size()-1).EA_Enterprise_Product__c != null)
                closeAddProductsText = true;
        
        else
            closeAddProductsText = false;
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'SCE')
            if(sceProducts.get(sceProducts.size()-1).EA_Enterprise_Product__c != null)
                closeAddProductsText = true;
        
        else
            closeAddProductsText = false;
        
        return null;
    }
    
    /*
        This method displays the additional product table. Same for SIP below
    */
    public PageReference openMoreProducts(){
        
        if(moreProd != 0){
            
            for(Integer i = 0; i < moreProd; i++){
                
                if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EA')
                    eaAddlProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                    
                if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAP')
                    eapAddlProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
        
                if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'ECI')   
                    eciAddlProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                
                if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAS')
                    easAddlProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                
                if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'SCE')
                    sceAddlProducts.add(new S_P_Vendor_Product_Selection__c(/*S_P_Vendor_Additional_Information_ID__c = addlInfoQueryMain.get(wizCounter).Id,*/  Type__c = addlInfoQueryMain.get(wizCounter).EA_Type__c));
                
            }
                
            closeMoreProducts = true;
        
        }
        else{
            
            
            closeMoreProducts = false;
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EA'){
                for(S_P_Vendor_Product_Selection__c prod : eaAddlProducts)
                    if(prod.Id != null)
                        prodSelQueryToDelete.add(prod);
                
                eaAddlProducts.clear();
            }
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAP'){
                for(S_P_Vendor_Product_Selection__c prod : eapAddlProducts)
                    if(prod.Id != null)
                        prodSelQueryToDelete.add(prod);
                eapAddlProducts.clear();
            }
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'ECI'){
                for(S_P_Vendor_Product_Selection__c prod : eciAddlProducts)
                    if(prod.Id != null)
                        prodSelQueryToDelete.add(prod);
                eciAddlProducts.clear();
            }    
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAS'){
                for(S_P_Vendor_Product_Selection__c prod : easAddlProducts)
                    if(prod.Id != null)
                        prodSelQueryToDelete.add(prod);
                
                easAddlProducts.clear();
            }
            if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'SCE'){
                for(S_P_Vendor_Product_Selection__c prod : sceAddlProducts)
                    if(prod.Id != null)
                        prodSelQueryToDelete.add(prod);
                
                sceAddlProducts.clear();
            }
        
        
                
        
        }
        return null;
    }
    
    
    /*
        Checks whether the delete button will be displayed or not. The variable deleteCheck is referenced in a javascript in the pages. Same for SIP below
    */
    public PageReference checkDeleteAddlProducts(){
        
        deleteCheck = 0;
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EA'){      
            if(eaAddlProducts.size() > 0){
                for(Integer i = 0; i < eaAddlProducts.size(); i++){
                    if(eaAddlProducts.get(i).Remove__c == TRUE)
                        deleteCheck = 1;
                }
            }
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAP'){      
            if(eapAddlProducts.size() > 0){
                for(Integer i = 0; i < eapAddlProducts.size(); i++){
                    if(eapAddlProducts.get(i).Remove__c == TRUE)
                        deleteCheck = 1;
                }
            }
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'ECI'){      
            if(eciAddlProducts.size() > 0){
                for(Integer i = 0; i < eciAddlProducts.size(); i++){
                    if(eciAddlProducts.get(i).Remove__c == TRUE)
                        deleteCheck = 1;
                }
            }
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAS'){      
            if(easAddlProducts.size() > 0){
                for(Integer i = 0; i < easAddlProducts.size(); i++){
                    if(easAddlProducts.get(i).Remove__c == TRUE)
                        deleteCheck = 1;
                }
            }
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'SCE'){      
            if(sceAddlProducts.size() > 0){
                for(Integer i = 0; i < sceAddlProducts.size(); i++){
                    if(sceAddlProducts.get(i).Remove__c == TRUE)
                        deleteCheck = 1;
                }
            }
        }
        
        return null;
    }
    
    /*
        This method removes the flagged product from the display and adds the record to the list that will delete it later on. Same for SIP below
    */
    public PageReference deleteAddlProducts(){
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EA'){
            for(Integer i = 0; i < eaAddlProducts.size(); i++){
                if(eaAddlProducts.get(i).Remove__c == TRUE){
                    if(eaAddlProducts.get(i).Id != null)
                        prodSelQueryToDelete.add(eaAddlProducts[i]);
                    eaAddlProducts.remove(i);
                    i--;
                }
            }
            if(eaAddlProducts.size() == 0){
                closeMoreProducts = false;
                closeDelButton = false;
            }
            
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAP'){
            for(Integer i = 0; i < eapAddlProducts.size(); i++){
                if(eapAddlProducts.get(i).Remove__c == TRUE){
                    if(eapAddlProducts.get(i).Id != null)
                        prodSelQueryToDelete.add(eapAddlProducts[i]);
                    eapAddlProducts.remove(i);
                    i--;
                }
            }
            if(eapAddlProducts.size() == 0){
                closeMoreProducts = false;
                closeDelButton = false;
            }
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'ECI'){
            for(Integer i = 0; i < eciAddlProducts.size(); i++){
                if(eciAddlProducts.get(i).Remove__c == TRUE){
                    if(eciAddlProducts.get(i).Id != null)
                        prodSelQueryToDelete.add(eciAddlProducts[i]);
                    eciAddlProducts.remove(i);
                    i--;
                }
            }
            if(eciAddlProducts.size() == 0){
                closeMoreProducts = false;
                closeDelButton = false;
            }
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'EAS'){
            for(Integer i = 0; i < easAddlProducts.size(); i++){
                if(easAddlProducts.get(i).Remove__c == TRUE){
                    if(easAddlProducts.get(i).Id != null)
                        prodSelQueryToDelete.add(easAddlProducts[i]);
                    easAddlProducts.remove(i);
                    i--;
                }
            }
            if(easAddlProducts.size() == 0){
                closeMoreProducts = false;
                closeDelButton = false;
            }
            
        }
        
        if(addlInfoQueryMain.get(wizCounter).EA_Type__c == 'SCE'){
            for(Integer i = 0; i < sceAddlProducts.size(); i++){
                if(sceAddlProducts.get(i).Remove__c == TRUE){
                    if(sceAddlProducts.get(i).Id != null)
                        prodSelQueryToDelete.add(sceAddlProducts[i]);
                    sceAddlProducts.remove(i);
                    i--;
                }
            }
            if(sceAddlProducts.size() == 0){
                closeMoreProducts = false;
                closeDelButton = false;
            }
            
        }
        return null;    
    }
    
    
    /*
        One of the methods called when the last Next button is hit. This method inserts the 3 main Additional Information records. It also does the name customization and updates the other
        field. EA Fees Total is calculated as well.
    */
    public void upsertEaType(){
        
        for(S_P_Vendor_Additional_Information__c ea : addlInfoQueryMain ){
            if(ea.EA_Type__c != null){
                ea.Opportunity_Name__c = this.spVendors.Opportunity__r.Name + ' - NN' + ea.EA_Type__c;
                ea.Products_Included__c = ea.EA_Type__c;
                ea.Level__c = 'EA';
                ea.SnP_Vendor_ID__c = checkSnPVendorId(this.spVendors.Name, ea.EA_Type__c, ea.Agreement_Level__c, null);
                ea.CurrencyIsoCode = spVendors.Opportunity__r.CurrencyIsoCode;
                
                addlNewInfoQueryToInsert.add(ea);
            }
            
            
        }
        for(S_P_Vendor_Additional_Information__c ea : addlNewInfoQueryToInsert ){
            ea.EA_Fees_Total__c = ea.Total__c;
            for(S_P_Vendor_Product_Threshold__c thresh : threshQuery ){
                if(ea.Agreement_Level__c == thresh.Agreement_Level__c){
                    ea.S_P_Vendor_Product_Threshold__c = thresh.Id;
                    if(thresh.Percentage__c != 0)
                        ea.EA_Fees_Total__c = ea.Total__c * (thresh.Percentage__c / 100);
                }   
            }
        }
        
    }
    
    
    /*
        The method name of this one might be misleading because of the word "upsert" but this method does not really perform any dml statements yet. What this does is it compiles all the
        products in one list, match each product against threshold records, and do the necessary computations.
    */
    public void upsertEaProducts(){
        
        Integer checkEA = 0, checkEAP = 0, checkECI = 0, checkEAS = 0, checkSCE = 0;
        for(S_P_Vendor_Additional_Information__c ea : addlInfoQueryMain){
            if(ea.EA_Type__c == 'EA')
                checkEA = 1;
            if(ea.EA_Type__c == 'EAP')
                checkEAP = 1;
            if(ea.EA_Type__c == 'ECI')
                checkECI = 1;
            if(ea.EA_Type__c == 'EAS')
                checkEAS = 1;
            if(ea.EA_Type__c == 'SCE')
                checkSCE = 1;
        }
        
        if(checkEA == 0){
            eaProducts.clear();
            eaAddlProducts.clear();
        }
        
        if(checkEAP == 0){
            eapProducts.clear();
            eapAddlProducts.clear();
        }
        
        if(checkECI == 0){
            eciProducts.clear();
            eciAddlProducts.clear();
        }
        
        if(checkEAS == 0){
            easProducts.clear();
            easAddlProducts.clear();
        }
        
        if(checkSCE == 0){
            sceProducts.clear();
            sceAddlProducts.clear();
        }
        
        prodSelQueryToInsert.addAll(eaProducts);
        prodSelQueryToInsert.addAll(eaAddlProducts);
        prodSelQueryToInsert.addAll(eapProducts);
        prodSelQueryToInsert.addAll(eapAddlProducts);
        prodSelQueryToInsert.addAll(eciProducts);
        prodSelQueryToInsert.addAll(eciAddlProducts);
        prodSelQueryToInsert.addAll(easProducts);
        prodSelQueryToInsert.addAll(easAddlProducts);
        prodSelQueryToInsert.addAll(sceProducts);
        prodSelQueryToInsert.addAll(sceAddlProducts);
        
        if(!(eaAddlProductsToDisplay.isEmpty())){ 
            Integer checkEaProd = 0;
            for(S_P_Vendor_Product_Selection__c prod : eaAddlProductsToDisplay ){
                for(S_P_Vendor_Product_Selection__c prod1 : eaAddlProducts)
                    if(prod.Id != null && prod1.Id != null && prod.Id == prod1.Id)
                        checkEaProd = 1;
                        
                if(checkEaProd == 0)
                    prodSelQueryToInsert.add(prod);
                
                checkEaProd = 0;
            }
        }
        
        if(!(eapAddlProductsToDisplay.isEmpty())){ 
            Integer checkEapProd = 0;
            for(S_P_Vendor_Product_Selection__c prod : eapAddlProductsToDisplay ){
                for(S_P_Vendor_Product_Selection__c prod1 : eapAddlProducts)
                    if(prod.Id != null && prod1.Id != null && prod.Id == prod1.Id)
                        checkEapProd = 1;
                        
                if(checkEapProd == 0)
                    prodSelQueryToInsert.add(prod);
                
                checkEapProd = 0;
            }
        }
        
        if(!(eciAddlProductsToDisplay.isEmpty())){ 
            Integer checkEciProd = 0;
            for(S_P_Vendor_Product_Selection__c prod : eciAddlProductsToDisplay ){
                for(S_P_Vendor_Product_Selection__c prod1 : eciAddlProducts)
                    if(prod.Id != null && prod1.Id != null && prod.Id == prod1.Id)
                        checkEciProd = 1;
                        
                if(checkEciProd == 0)
                    prodSelQueryToInsert.add(prod);
                
                checkEciProd = 0;
            }
        }
        
        if(!(easAddlProductsToDisplay.isEmpty())){ 
            Integer checkEasProd = 0;
            for(S_P_Vendor_Product_Selection__c prod : easAddlProductsToDisplay ){
                for(S_P_Vendor_Product_Selection__c prod1 : easAddlProducts)
                    if(prod.Id != null && prod1.Id != null && prod.Id == prod1.Id)
                        checkEasProd = 1;
                        
                if(checkEasProd == 0)
                    prodSelQueryToInsert.add(prod);
                
                checkEasProd = 0;
            }
        }
        
        if(!(sceAddlProductsToDisplay.isEmpty())){ 
            Integer checkSceProd = 0;
            for(S_P_Vendor_Product_Selection__c prod : sceAddlProductsToDisplay ){
                for(S_P_Vendor_Product_Selection__c prod1 : sceAddlProducts)
                    if(prod.Id != null && prod1.Id != null && prod.Id == prod1.Id)
                        checkSceProd = 1;
                        
                if(checkSceProd == 0)
                    prodSelQueryToInsert.add(prod);
                
                checkSceProd = 0;
            }
        }
            
        for(Integer i = 0; i < prodSelQueryToInsert.size(); i++){
            if(prodSelQueryToInsert.get(i).Remove__c == TRUE){
                prodSelQueryToInsert.remove(i);
                i--;
            }
            else
                prodSelQueryToInsert.get(i).Total__c = prodSelQueryToInsert.get(i).Unit_Price__c * prodSelQueryToInsert.get(i).Quantity__c;
            
            
        }
        
        for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert){
            for(S_P_Vendor_Product_Threshold__c thresh : threshQuery ){
                if(prod.EA_Enterprise_Product__c == null){
                    if(prod.New_Products_Only__c == thresh.Product_Description__c){
                        prod.SIP_Incentive__c = thresh.Product_Family__c;
                        prod.S_P_Vendor_Product_Threshold__c = thresh.Id;
                        if(thresh.Percentage__c != null)    
                            prod.SIP_Fees__c = prod.Total__c * (thresh.Percentage__c / 100);    
                    }
                }
                
                    
            }
        }
            
        prodSelThreshold.addAll(prodSelQueryToInsert);
            
    }
    
    /*
        This is one of the tricky methods again, as this is where the threshold is calculated. This is also a universal method same as assignSipId.
    */
    public void checkThresholdSummary(){
            
        //first of course, is removing the not eligible sip incentives
        for(Integer i = 0; i < prodSelThreshold.size(); i++){
            if(prodSelThreshold.get(i).SIP_Incentive__c == 'Product Not Eligible for SIP' || prodSelThreshold.get(i).Remove__c == TRUE ){
                prodSelThreshold.remove(i);
                i--;
            }
            
        }
        
        
        //second is cleaning the prodSelThreshold list by removing the same SIP Incentive. however, we are not just removing the others, the Total is being aggregated.
        for(Integer i = 0; i < prodSelThreshold.size(); i++){
            
            for(Integer j = i + 1; j < prodSelThreshold.size(); j++){
                if(prodSelThreshold.get(i).Type__c == prodSelThreshold.get(j).Type__c){
                    if(prodSelThreshold.get(i).SIP_Incentive__c == prodSelThreshold.get(j).SIP_Incentive__c){
                        prodSelThreshold.get(i).Total__c += prodSelThreshold.get(j).Total__c;   
                        prodSelThreshold.remove(j);
                        j--;
                    }   
                }
                    
            }
        }
        
        String thresholdMet;    
        
        //here is where the results get sorted whether it is EA, EAP, ECI, or SIP. a wrapper class is used because of some miscalculation issues.       
        for(S_P_Vendor_Product_Selection__c prod : prodSelThreshold){
            for(S_P_Vendor_Product_Threshold__c thresh : threshQuery ){
                if((thresh.Product_Description__c == prod.New_Products_Only__c) && thresh.Product_Description__c != null ){   
                    if((prod.Total__c / nonUsdRate) >= thresh.Minimum_Revenue__c)
                        thresholdMet = 'Yes';
                    else
                        thresholdMet = 'No';
                        
                    if(prod.Type__c == 'EA')
                        eaThrshldMet.add(new eaThrshldRow(prod.Type__c, prod.SIP_Incentive__c, prod.Total__c, thresholdMet, prod.Additional_Product_Type__c, prod.New_Products_Only__c, prod.S_P_Vendor_Product_Threshold__c, prod.EA_Enterprise_Product__c, prod.Total__c * currencyMultiplier, thresh.Minimum_Revenue__c * minRevConverter));
                    if(prod.Type__c == 'EAP')
                        eapThrshldMet.add(new eaThrshldRow(prod.Type__c, prod.SIP_Incentive__c, prod.Total__c, thresholdMet, prod.Additional_Product_Type__c, prod.New_Products_Only__c, prod.S_P_Vendor_Product_Threshold__c, prod.EA_Enterprise_Product__c, prod.Total__c * currencyMultiplier, thresh.Minimum_Revenue__c * minRevConverter));
                    if(prod.Type__c == 'ECI')
                        eciThrshldMet.add(new eaThrshldRow(prod.Type__c, prod.SIP_Incentive__c, prod.Total__c, thresholdMet, prod.Additional_Product_Type__c, prod.New_Products_Only__c, prod.S_P_Vendor_Product_Threshold__c, prod.EA_Enterprise_Product__c, prod.Total__c * currencyMultiplier, thresh.Minimum_Revenue__c * minRevConverter));
                    if(prod.Type__c == 'EAS')
                        easThrshldMet.add(new eaThrshldRow(prod.Type__c, prod.SIP_Incentive__c, prod.Total__c, thresholdMet, prod.Additional_Product_Type__c, prod.New_Products_Only__c, prod.S_P_Vendor_Product_Threshold__c, prod.EA_Enterprise_Product__c, prod.Total__c * currencyMultiplier, thresh.Minimum_Revenue__c * minRevConverter));
                    if(prod.Type__c == 'SCE')
                        sceThrshldMet.add(new eaThrshldRow(prod.Type__c, prod.SIP_Incentive__c, prod.Total__c, thresholdMet, prod.Additional_Product_Type__c, prod.New_Products_Only__c, prod.S_P_Vendor_Product_Threshold__c, prod.EA_Enterprise_Product__c, prod.Total__c * currencyMultiplier, thresh.Minimum_Revenue__c * minRevConverter));    
                    if(prod.Type__c == 'SIP')
                        sipThrshldMet.add(new eaThrshldRow(prod.Type__c, prod.SIP_Incentive__c, prod.Total__c, thresholdMet, prod.Additional_Product_Type__c, prod.New_Products_Only__c, prod.S_P_Vendor_Product_Threshold__c, prod.EA_Enterprise_Product__c, prod.Total__c * currencyMultiplier, thresh.Minimum_Revenue__c * minRevConverter)); 
                       
                    
                }
            
            }
        }
        
        
        //here, the Total for each product is being calculated again. for the same aforementioned reason (way above), the Total gets messed up when being manipulated in threshold calculation.
        for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert){
                prod.Total__c = prod.Unit_Price__c * prod.Quantity__c;
        }
        
        if(!(prodSelQuery.isEmpty())){
            for(S_P_Vendor_Product_Selection__c prod : prodSelQuery){
                    prod.Total__c = prod.Unit_Price__c * prod.Quantity__c;
            }
        }
        
    }
    
    /*
        This is the wrapper class that I created
    */
    public class eaThrshldRow{
        
        public String contract{get; set;}
        public String sipProducts{get; set;}
        public Decimal total{get; set;}
        public String sipThrshldMet{get; set;}
        public String addlProducts{get; set;}
        public String newProducts{get; set;}
        public String threshId{get; set;}
        public String enterpriseProd{get; set;}
        public Decimal convertedTotal{get; set;}
        public Decimal minimumRev{get; set;}
        
        public eaThrshldRow(String con, String sip, Decimal tot, String met, String addlProductsTmp, String newProductsTmp, String threshIdTmp, String enterpriseProdTmp, Decimal convert, Decimal minRev){
            contract = con;
            sipProducts = sip;
            total = tot;
            sipThrshldMet = met;
            addlProducts = addlProductsTmp;
            newProducts = newProductsTmp;
            threshId = threshIdTmp;
            enterpriseProd = enterpriseProdTmp;
            convertedTotal = convert;
            minimumRev = minRev;
        }
        
    }
    
    
    
    /*
        This is one of the tricky methods/logic of the whole process. Aside from the main Additional Information records (from the first wizard page where user is asked to input
        EA, EAP and/or ECI), more Additional Info records will be created based on the products entered. This is also tied up to the checking of the threshold whether it is met or not.
    */
    public void evaluateProducts(){
        
        prodSelThreshold.clear();
        /*
            This method is called first before proceeding. What it does is it eliminates all the duplicate Additional Product Types to be able to create 1 parent record for the products.
        */
        checkProductsToInsert();
        
        /*
            I took advantage of the wrapper class I created, eaThrshldRow, to create the parent records.
        */
        for(eaThrshldRow prod : allThrshMet)
            prodSelThreshold.add(new S_P_Vendor_Product_Selection__c(Type__c = prod.contract, SIP_Incentive__c = prod.sipProducts, Total__c = prod.total, SIP_Threshold_Met__c = prod.sipThrshldMet, Additional_Product_Type__c = prod.addlProducts, New_Products_Only__c = prod.newProducts, S_P_Vendor_Product_Threshold__c = prod.threshId, EA_Enterprise_Product__c = prod.enterpriseProd));
        
        /*
            When all the sorted records are added to the prodSelThresdhold list, it is now time to add them to the addlNewInfoQueryToInsert list, which is basically the list for all
            the parent records of the products added.
        */
        if(addlInfoQuery.isEmpty()){
            for(S_P_Vendor_Product_Selection__c prod : prodSelThreshold )   
                addlNewInfoQueryToInsert.add(new S_P_Vendor_Additional_Information__c(S_P_Vendors_ID__c = this.spVendors.Id, Level__c = 'Product', Products_Included__c = prod.Additional_Product_Type__c, /*SIP_Incentive__c = prod.SIP_Incentive__c, Total__c = prod.Total__c, S_P_Vendor_Product_Threshold__c = prod.S_P_Vendor_Product_Threshold__c,*/ EA_Type__c = prod.Type__c, Opportunity_Name__c = this.spVendors.Opportunity__r.Name + ' - ' + prod.Additional_Product_Type__c, EA_Enterprise_Product__c = prod.EA_Enterprise_Product__c/*, SnP_Vendor_ID__c = checkSnPVendorId(this.spVendors.Name, prod.Additional_Product_Type__c, null, prod.SIP_Incentive__c)*/));         
        }   
        
        /*
            This is where it gets a bit complicated, if the query to the Additional Information object returns values or not empty. If it's not empty and new products are entered, then a
            new parent record should be created. If a product that has the same type in the parents is entered, then the Total of the parent should be updated.
        */
        if(!(addlInfoQuery.isEmpty())){
            
            for(S_P_Vendor_Product_Selection__c prod : prodSelThreshold ){
                for(S_P_Vendor_Additional_Information__c ea : addlInfoQuery){
                    if(prod.Type__c == ea.EA_Type__c)
                        //checks if it already has a parent
                        if(prod.Additional_Product_Type__c == ea.Products_Included__c)
                            //updates the Total
                            ea.Total__c = prod.Total__c;
                    
                        else
                            //insert a new parent
                            addlNewInfoQueryToInsert.add(new S_P_Vendor_Additional_Information__c(S_P_Vendors_ID__c = this.spVendors.Id, Level__c = 'Product', Products_Included__c = prod.Additional_Product_Type__c, /*SIP_Incentive__c = prod.SIP_Incentive__c, Total__c = prod.Total__c, S_P_Vendor_Product_Threshold__c = prod.S_P_Vendor_Product_Threshold__c,*/ EA_Type__c = prod.Type__c, Opportunity_Name__c = this.spVendors.Opportunity__r.Name + ' - ' + prod.Additional_Product_Type__c/*, SnP_Vendor_ID__c = checkSnPVendorId(this.spVendors.Name, prod.Additional_Product_Type__c, null, prod.SIP_Incentive__c)*/)); 
                }
            }
            
            //just to make sure, dupes are removed from addlInfoQuery and addlNewInfoQueryToInsert
            for(Integer i = 0; i < addlInfoQuery.size(); i++){
                for(Integer j = 0; j < addlNewInfoQueryToInsert.size(); j++){
                    if(addlInfoQuery.get(i).EA_Type__c == addlNewInfoQueryToInsert.get(j).EA_Type__c && addlInfoQuery.get(i).Products_Included__c == addlNewInfoQueryToInsert.get(j).Products_Included__c){ 
                        addlNewInfoQueryToInsert.remove(j);
                        j--;
                    }
            }
                    
            
            }
            
            //just like the process from the checkProductsToInsert method, dupes are removed from addlNewInfoQueryToInsert
            for(Integer i = 0; i < addlNewInfoQueryToInsert.size(); i++){
                for(Integer j = i+1; j < addlNewInfoQueryToInsert.size(); j++){
                    if(addlNewInfoQueryToInsert.get(i).EA_Type__c == addlNewInfoQueryToInsert.get(j).EA_Type__c && addlNewInfoQueryToInsert.get(i).Products_Included__c == addlNewInfoQueryToInsert.get(j).Products_Included__c){ 
                        addlNewInfoQueryToInsert.remove(j);
                        j--;
                    }
                }
                    
            
            }
        }
        addlNewInfoQueryToInsert.addAll(addlInfoQuery);
        
        for(S_P_Vendor_Additional_Information__c ea : addlNewInfoQueryToInsert){
            ea.CurrencyIsoCode = spVendors.Opportunity__r.CurrencyIsoCode;
            for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert){
                if(ea.Level__c == 'Product'){
                    if(prod.Type__c == ea.EA_Type__c && prod.Additional_Product_Type__c == ea.Products_Included__c && prod.SIP_Incentive__c != 'Product Not Eligible for SIP'){
                        ea.S_P_Vendor_Product_Threshold__c = prod.S_P_Vendor_Product_Threshold__c;
                        ea.SnP_Vendor_ID__c = checkSnPVendorId(this.spVendors.Name, prod.Additional_Product_Type__c, null, prod.SIP_Incentive__c);
                        break;
                    }
                    else
                        ea.S_P_Vendor_Product_Threshold__c = null;
                }
            }
            if(ea.Level__c == 'Product' && ea.S_P_Vendor_Product_Threshold__c == null)
                ea.SnP_Vendor_ID__c = checkSnPVendorId(this.spVendors.Name, ea.Products_Included__c, null, null);
        }
        
        for(S_P_Vendor_Additional_Information__c ea : addlNewInfoQueryToInsert){
            if(ea.Level__c == 'Product')
                ea.Total__c = 0;
            for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert){
                if(ea.Level__c == 'Product'){
                    if(prod.Type__c == ea.EA_Type__c && prod.Additional_Product_Type__c == ea.Products_Included__c && prod.SIP_Incentive__c != 'Product Not Eligible for SIP')
                        ea.Total__c += prod.Total__c;
                    if(ea.EA_Enterprise_Product__c != null && ea.EA_Enterprise_Product__c == prod.EA_Enterprise_Product__c){
                        //these fields are filled for reporting purposes
                        ea.EA_Enterprise_Product_Quantity__c = prod.Quantity__c;
                        ea.EA_Enterprise_Product_Unit_Price__c = prod.Unit_Price__c;
                        ea.EA_Enterprise_Product_Total__c = ea.EA_Enterprise_Product_Quantity__c * ea.EA_Enterprise_Product_Unit_Price__c;
                        ea.SIP_Threshold_Met__c = 'Yes';
                    }
                }
                if(ea.Level__c == 'EA'){
                    if(ea.EA_Type__c == prod.Type__c && prod.EA_Enterprise_Product__c != null){
                        //these fields are filled for reporting purposes
                        ea.EA_Enterprise_Product__c = prod.EA_Enterprise_Product__c;
                        ea.EA_Enterprise_Product_Quantity__c = prod.Quantity__c;
                        ea.EA_Enterprise_Product_Unit_Price__c = prod.Unit_Price__c;
                        ea.EA_Enterprise_Product_Total__c = ea.EA_Enterprise_Product_Quantity__c * ea.EA_Enterprise_Product_Unit_Price__c;
                        ea.SIP_Threshold_Met__c = 'Yes';
                    }
                }
            }
        }
        
        //this determines if SIP Threshold Met is Yes or No based on the minimum revenue from the matching Threshold record
        for(S_P_Vendor_Additional_Information__c ea : addlNewInfoQueryToInsert){
            for(S_P_Vendor_Product_Threshold__c thresh : threshQuery){
                if(ea.Level__c == 'Product' && ea.S_P_Vendor_Product_Threshold__c == thresh.Id){
                    if((ea.Total__c / nonUsdRate) >= thresh.Minimum_Revenue__c)
                        ea.SIP_Threshold_Met__c = 'Yes';
                    else
                        ea.SIP_Threshold_Met__c = 'No';
                    
                }
                if(ea.Level__c == 'Product' && ea.S_P_Vendor_Product_Threshold__c == null)
                    ea.SIP_Threshold_Met__c = 'No';
            }
        }
        
        
        for(S_P_Vendor_Additional_Information__c ea : addlNewInfoQueryToInsert)
            if(ea.SIP_Threshold_Met__c == 'Yes' && ea.Deal_Reg_Status__c == null)
                ea.Deal_Reg_Status__c = 'Pending';
        
        
        upsert addlNewInfoQueryToInsert;
        
        //when the parent records are now upserted, it is now time to assign ID's to their respective children/products. *NOTE: some misnaming happened here as you can notice it says
        //"assignSipId" but we're still in EA. Apparently, this method is universal for both EA (EA Detail) and SIP (Product Detail).
        assignSipId();
        
        
    }
    
    
    
    /*
        In this method, a tmp list is created which is used to compare if Additional Product Type is the same and then remove the duplicate. The resulting records are then added to the
        public variable allThrshMet.
    */
    public void checkProductsToInsert(){
        List<eaThrshldRow> productsToUpsert = new List<eaThrshldRow>();
        List<S_P_Vendor_Product_Selection__c> prodSelQueryToInsertTmp = new List<S_P_Vendor_Product_Selection__c>(prodSelQueryToInsert);
        
        
        for(Integer i = 0; i < prodSelQueryToInsertTmp.size(); i++){
            
            for(Integer j = i + 1; j < prodSelQueryToInsertTmp.size(); j++){
                if(prodSelQueryToInsertTmp.get(i).Type__c == prodSelQueryToInsertTmp.get(j).Type__c){
                    if(prodSelQueryToInsertTmp.get(i).Additional_Product_Type__c == prodSelQueryToInsertTmp.get(j).Additional_Product_Type__c){
                        
                        prodSelQueryToInsertTmp.remove(j);
                        j--;
                    }   
                }
                    
            }
        }
        
        for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsertTmp){
                productsToUpsert.add(new eaThrshldRow(prod.Type__c, prod.SIP_Incentive__c, prod.Total__c, prod.SIP_Threshold_Met__c, prod.Additional_Product_Type__c, prod.New_Products_Only__c, prod.S_P_Vendor_Product_Threshold__c, prod.EA_Enterprise_Product__c, prod.Total__c * currencyMultiplier, null));
        }   
        
        allThrshMet.addAll(productsToUpsert);
        
    
    }
    
    /*
        This method deletes the parent of the deleted products, if all products in one parent are deleted.
    */
    public void deleteNoChild(){
        
        Integer checkParent = 0;
        
        for(S_P_Vendor_Additional_Information__c ea : addlNewInfoQueryToInsert ){
            for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert ){
                if(ea.Id == prod.S_P_Vendor_Additional_Information_ID__c)
                    checkParent = 1;
                        
            }
            if(checkParent == 0){
                if(ea.Level__c == 'Product'){
                    addlInfoQueryToDelete.add(ea);
                }
            }
            
            checkParent = 0;
            
        }
        
    }
    
    /*
        This is a method for the Product Detail. Since products are only entered as they are (no choosing of EA, EAP, or ECI), the wizard is fairly simple. The start of the wizard loads
        initially, then when the user clicks Next this is the method that is called. This method includes validation checks as well.
    */
    public PageReference showFinalSIP(){
        
        if(!(sipAddlProducts.isEmpty())){
            
            productValidations(sipProducts, sipAddlProducts, sipAddlProductsToDisplay, 'SIP');
                if(errorMsg != null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMsg));               
                    return null;
                }
        }   
        
        
        if(sipProducts.get(0).Additional_Product_Type__c != null && sipProducts.get(0).New_Products_Only__c != null && sipProducts.get(0).Quantity__c != null && sipProducts.get(0).Unit_Price__c != null){
            sipThrshldMet.clear();
            prodSelThreshold.clear();
            prodSelQueryToInsert.clear();
            
            upsertSipType();
            return Page.SnPMSWizardPageSIP;
        }
        else 
        
        if(sipProducts.get(0).Additional_Product_Type__c == null || sipProducts.get(0).New_Products_Only__c == null || sipProducts.get(0).Quantity__c == null || sipProducts.get(0).Unit_Price__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'SIP Deal Reg Type, New Products Only, Quantity, and Unit Price must have a value'));
            return null;
        }
            
        
        
        return null;
    }
    
    /*
        This method is called when the user clicks Back. The page, SnPMSAdditionalInfoNewEditEA, is the editable page. If you notice, in EA Detail, this is what it calls when user wants to 
        edit EA, EAP, or ECI.
    */
    public PageReference previousPageSIP(){
        return Page.SnPMSAdditionalInfoNewEditEA;
    }
    
    /*
        The finish method much like the same as the one for EA Detail.
    */
    public PageReference finishWizardSIP(){
        
        evaluateProducts();
        
        try{
            upsert addlNewInfoQueryToInsert;
            assignSipId();
            for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert)
                prod.Total__c = prod.Quantity__c * prod.Unit_Price__c;
            upsert prodSelQueryToInsert;
            delete prodSelQueryToDelete;
            deleteNoChild();
            delete addlInfoQueryToDelete;  
        }
        catch(DmlException e){
            ApexPages.addMessages(e);
        }
        
        refreshPage = true;
        return null;
    }
    
    
    /*
        This method is also much like the same as upsertEaProducts().
    */
    public void upsertSipType(){
        
        
        prodSelQueryToInsert.addAll(sipProducts);
        prodSelQueryToInsert.addAll(sipAddlProducts);
        
        if(!(sipAddlProductsToDisplay.isEmpty())){
            Integer checkSipProd = 0;
            for(S_P_Vendor_Product_Selection__c prod : sipAddlProductsToDisplay ){
                for(S_P_Vendor_Product_Selection__c prod1 : sipAddlProducts)
                    if(prod.Id != null && prod1.Id != null && prod.Id == prod1.Id)
                        checkSipProd = 1;
                        
                if(checkSipProd == 0)
                    prodSelQueryToInsert.add(prod);
                
                checkSipProd = 0;
            }
        }
        
        
        
        for(Integer i = 0; i < prodSelQueryToInsert.size(); i++){
            if(prodSelQueryToInsert.get(i).Remove__c == TRUE){
                    prodSelQueryToInsert.remove(i);
                    i--;
            }
            else
                prodSelQueryToInsert.get(i).Total__c = prodSelQueryToInsert.get(i).Quantity__c * prodSelQueryToInsert.get(i).Unit_Price__c;
            
        }
        
        for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert){
            for(S_P_Vendor_Product_Threshold__c thresh : threshQuery ){
                if(thresh.Product_Description__c == prod.New_Products_Only__c && thresh.Product_Description__c != null ){
                    prod.SIP_Incentive__c = thresh.Product_Family__c;
                    prod.S_P_Vendor_Product_Threshold__c = thresh.Id;
                    if(thresh.Percentage__c != null)
                        prod.SIP_Fees__c = prod.Total__c * (thresh.Percentage__c / 100);    
                }
            }
        }
        
        prodSelThreshold.addAll(prodSelQueryToInsert);
        
        //you can notice the universal method is called here.
        checkThresholdSummary();
        
        
    }
    
    /*
        One of the universal methods for this class. This method assigns parent Id's to the products.
    */
    public void assignSipId(){
    
        for(S_P_Vendor_Additional_Information__c ea : addlNewInfoQueryToInsert ){
            for(S_P_Vendor_Product_Selection__c prod : prodSelQueryToInsert ){
                prod.CurrencyIsoCode = spVendors.Opportunity__r.CurrencyIsoCode;
                if(ea.Level__c == 'Product')
                    if(ea.EA_Type__c == prod.Type__c)
                        if((prod.EA_Enterprise_Product__c == null && ea.Products_Included__c == prod.Additional_Product_Type__c) || (prod.EA_Enterprise_Product__c != null && ea.EA_Enterprise_Product__c == prod.EA_Enterprise_Product__c))
                            
                                prod.S_P_Vendor_Additional_Information_ID__c = ea.Id;
            }
        }   
        
        
    }
    
    public PageReference openAddProductsTextSip(){
   
        if(sipProducts.get(sipProducts.size()-1).Additional_Product_Type__c != null)
            closeAddProductsTextSip = true;
        
        else
            closeAddProductsTextSip = false;
        
        return null;
    }
    
    
    public PageReference openMoreProductSip(){
        
        if(moreProd != 0){
            
            for(Integer i = 0; i < moreProd; i++)
        
                sipAddlProducts.add(new S_P_Vendor_Product_Selection__c(Type__c = 'SIP'));

                
            closeMoreProductSip = true;
        
        }
        else{
            
            
            closeMoreProductSip = false;
            for(S_P_Vendor_Product_Selection__c prod : sipAddlProducts)
                if(prod.Id != null)
                    prodSelQueryToDelete.add(prod);
            sipAddlProducts.clear();
        
        }
        return null;
    }
    
    
    public PageReference checkDeleteAddlProductsSip(){
        
        deleteCheck = 0;
        
        if(sipAddlProducts.size() > 0){
            for(Integer i = 0; i < sipAddlProducts.size(); i++){
                if(sipAddlProducts.get(i).Remove__c == TRUE)
                    deleteCheck = 1;
            }
        }
        
        return null;
        
    }
    
    public PageReference deleteAddlProductsSip(){
        
        for(Integer i = 0; i < sipAddlProducts.size(); i++){
                if(sipAddlProducts.get(i).Remove__c == TRUE){
                    if(sipAddlProducts.get(i).Id != null)
                        prodSelQueryToDelete.add(sipAddlProducts[i]);
                    sipAddlProducts.remove(i);
                    i--;
                }
            }
            if(sipAddlProducts.size() == 0){
                closeMoreProductSip = false;
                closeDelButtonSip = false;
            }
        
        
       
        return null;    
    }
    
    /*
        This method assigns the letter appended to the names of the records.
    */
    public String checkSnPVendorId(String Id, String name, String agrmntLevel, String incentive){
        if (name == 'EA' || name == 'EAS'){
            if (agrmntLevel == 'A1' || agrmntLevel == 'A2' )
                return Id + 'A';
            if (agrmntLevel == 'B')
                return Id + 'B';
            if (agrmntLevel == 'C')
                return Id + 'C';
            if (agrmntLevel == 'D')
                return Id + 'D';
        }
        
        if (name == 'ECI')
            return Id + 'E';
        
        if (name == 'EAP')
            return Id + 'F';
            
        if (name == 'SCE')
            return Id + 'N';    
        
        if (name == 'Windows')
            return Id + 'G';
            
        if (name == 'SQL')
            return Id + 'H';
        
        if (name == 'Lync')
            return Id + 'I';
        
        if (name == 'CIS')
            return Id + 'J';
        
        if (name == 'SystemCenter')
            return Id + 'K';
        
        if (name == 'Forefront')
            return Id + 'L';
        
        if (name == 'VDI')
            return Id +  'M';
        
        if(name == null){
            if (incentive == 'Windows 7')
                return Id + 'G';
            
            if (incentive == 'Application Platform')
                return Id + 'H';
            
            if (incentive == 'Management & Virtualization')
                return Id + 'J';
        }
        
        
        return Id;
    }
    
    /*
        This method assigns the already existing record values to the lists for display. If you notice, we have a lot of list variables declared up top. This is because some of them are manipulated, while some of them are
        for display only. The others are for the other datatables (Threshold, Summary, etc.).
        
        This method also includes the calculation for the SIP and Corp Fee Summary tab. As well as the implementation of the 50000 USD limit.
    */
    public void assignEaProducts(){
        
        Integer firstRec = 0;
        
        prodSelThreshold.addAll(prodSelQuery);
        
        if(!(prodSelQuery.isEmpty())){
            for(S_P_Vendor_Product_Selection__c prod : prodSelQuery)
                for(S_P_Vendor_Additional_Information__c ea : addlInfoQuery){
                    if(ea.EA_Enterprise_Product__c != null && ea.EA_Type__c == prod.Type__c && ea.EA_Enterprise_Product__c == prod.EA_Enterprise_Product__c){
                        //these fields are filled again for reporting purposes
                        prod.Quantity__c = ea.EA_Enterprise_Product_Quantity__c;
                        prod.Unit_Price__c = ea.EA_Enterprise_Product_Unit_Price__c;
                    }
                    if(prod.Type__c == ea.EA_Type__c && prod.Additional_Product_Type__c == ea.Products_Included__c && ea.SIP_Threshold_Met__c == 'Yes' && prod.SIP_Incentive__c != 'Product Not Eligible for SIP' )//&& ea.SIP_Incentive__c != 'Product Not Eligible for SIP' )
                        //this prodSummaryTmp list holds the temp list for the summary tab
                        prodSummaryTmp.add(new eaThrshldRow(null, prod.SIP_Incentive__c, prod.SIP_Fees__c, null, prod.Additional_Product_Type__c, null, null, null, prod.SIP_Fees__c * currencyMultiplier, null ));
                }
             
            //Sort out the temp list per SIP Incentive and Additional Product Type, aggregate the total
            for(Integer i = 0; i < prodSummaryTmp.size(); i++){
                for(Integer j = i + 1; j < prodSummaryTmp.size(); j++){
                    if(prodSummaryTmp.get(i).addlProducts == prodSummaryTmp.get(j).addlProducts){// && prodSummaryTmp.get(i).sipProducts == prodSummaryTmp.get(j).sipProducts){   
                        prodSummaryTmp.get(i).total += prodSummaryTmp.get(j).total; 
                        prodSummaryTmp.get(i).convertedTotal += prodSummaryTmp.get(j).convertedTotal;
                        prodSummaryTmp.remove(j);
                        j--;
                    }
                    
                }
            }
            
            //Sort out the temp list per SIP Incentive, aggregate the total
            for(Integer i = 0; i < prodSummaryTmp.size(); i++){
                for(Integer j = i + 1; j < prodSummaryTmp.size(); j++){
                    if(prodSummaryTmp.get(i).sipProducts == prodSummaryTmp.get(j).sipProducts){
                        prodSummaryTmp.get(i).total += prodSummaryTmp.get(j).total; 
                        prodSummaryTmp.get(i).convertedTotal += prodSummaryTmp.get(j).convertedTotal;
                        prodSummaryTmp.remove(j);
                        j--;
                        
                    }   
                
                }
            }
            
            //implement the limit
            for(Integer i = 0; i < prodSummaryTmp.size(); i++){
                if(prodSummaryTmp.get(i).total > sipFeeLimit){
                    prodSummaryTmp.get(i).total = sipFeeLimit;
                    prodSummaryTmp.get(i).convertedTotal = prodSummaryTmp.get(i).total * currencyMultiplier;
                }
            }
            
        }
        
        /*
            This is the part where the records are assigned to the list. It is important to note here that only Pending and Incomplete products are displayed in Edit mode. Hence, two
            different lists per Type.
        */
        for(S_P_Vendor_Product_Selection__c prod : prodSelQuery ){
            if(prod.Type__c == 'EA'){
                if(prod.EA_Enterprise_Product__c != null)
                    eaProducts.add(prod);
                
                if(prod.EA_Enterprise_Product__c == null){
                    eaAddlProductsToDisplay.add(prod);
                    if(prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Pending' || 
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Incomplete' ||
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == null)
                        eaAddlProducts.add(prod);
                }
            }
            
            if(prod.Type__c == 'EAP'){
                
                if(prod.EA_Enterprise_Product__c != null)
                    eapProducts.add(prod);
                  
                if(prod.EA_Enterprise_Product__c == null){
                    eapAddlProductsToDisplay.add(prod);
                    if(prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Pending' || 
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Incomplete' ||
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == null)
                        eapAddlProducts.add(prod);
                }             
            
            }
            
            if(prod.Type__c == 'ECI'){
                
                
                if(prod.EA_Enterprise_Product__c != null)
                    eciProducts.add(prod);
                  
                if(prod.EA_Enterprise_Product__c == null){
                    eciAddlProductsToDisplay.add(prod);
                    if(prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Pending' || 
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Incomplete' ||
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == null)
                        eciAddlProducts.add(prod);
                }
            }
            
            if(prod.Type__c == 'EAS'){
                if(prod.EA_Enterprise_Product__c != null)
                    easProducts.add(prod);
                
                if(prod.EA_Enterprise_Product__c == null){
                    easAddlProductsToDisplay.add(prod);
                    if(prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Pending' || 
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Incomplete' ||
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == null)
                        easAddlProducts.add(prod);
                }
            }
            
            if(prod.Type__c == 'SCE'){
                if(prod.EA_Enterprise_Product__c != null)
                    sceProducts.add(prod);
                
                if(prod.EA_Enterprise_Product__c == null){
                    sceAddlProductsToDisplay.add(prod);
                    if(prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Pending' || 
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Incomplete' ||
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == null)
                        sceAddlProducts.add(prod);
                }
            }
            
            if(prod.Type__c == 'SIP'){
                if(firstRec == 0){
                    sipProducts.add(prod);
                    firstRec = 1;
                }
                else{
                    sipAddlProductsToDisplay.add(prod);
                    if(prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Pending' || 
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == 'Incomplete' || 
                    prod.S_P_Vendor_Additional_Information_ID__r.Deal_Reg_Status__c == null)
                        sipAddlProducts.add(prod);
                }
            } 
                
        }
        
        
        
        checkThresholdSummary();
        
        for(eaThrshldRow prod : prodSummaryTmp)
            totalProd += prod.total;
        
        convertedTotalProd = totalProd * currencyMultiplier;
        
        
    }
    
    
    /*
        The following getter-setter methods are declared for the custom pages.
    */
    
    public void closePopup() {
        displayPopup = false;
    }
 
    public void showPopup() {
        displayPopup = true;
    }
     
    public Integer getMoreProd(){
        return moreProd;
    }

    public void setMoreProd(Integer num){
        moreProd = num;
    }
    
    public Boolean getCheckEaProductsEmpty(){
        if( prodSelQuery.isEmpty() )
            return true;
        else
            return false;   
    }
    
    public Boolean getCheckEaProductsEmptyEdit(){
        if( !(prodSelQuery.isEmpty()) && currentProfile != 'GBL Manage S&P – Non SSO' )
            return true;
        else
            return false;   
    }
    
    public Boolean getCheckSipProductsEmpty(){
        if( addlInfoQuery.isEmpty() )
            return true;
        else
            return false;   
    }
    
    public Boolean getCheckSipProductsEmptyEdit(){
        if( !(addlInfoQuery.isEmpty()) && currentProfile != 'GBL Manage S&P – Non SSO' )
            return true;
        else
            return false;   
    }
    
    
    public Boolean getIsThisEa(){
        if(spVendors.Is_this_an_Enterprise_Agreement__c == 'Yes')
            return true;
            
        else
            return false;
    }
    
    public Boolean getIsThisNotEa(){
        if(spVendors.Is_this_an_Enterprise_Agreement__c == 'No')
            return true;
            
        else
            return false;
    }
    
    public Boolean getIsThisEaNotBlank(){
        if(spVendors.Is_this_an_Enterprise_Agreement__c != null)
            return true;
            
        else
            return false;
    }
    
    
    public Boolean getIsProdManagerEa(){
        if(!(addlInfoQuery.isEmpty()) && (currentProfile == 'GBL Manage S&P – Non SSO' || currentProfile == 'System Administrator' ))
            return true;
        else
            return false;       
    }
    
    public Boolean getEaProductsNotEmpty(){
        if(!(eaProducts.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEaAddlProductsNotEmpty(){
        if(!(eaAddlProductsToDisplay.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEapProductsNotEmpty(){
        if(!(eapProducts.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    
    public Boolean getEapAddlProductsNotEmpty(){
        if(!(eapAddlProducts.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEciProductsNotEmpty(){
        if(!(eciProducts.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEciAddlProductsNotEmpty(){
        if(!(eciAddlProductsToDisplay.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEasProductsNotEmpty(){
        if(!(easProducts.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEasAddlProductsNotEmpty(){
        if(!(easAddlProductsToDisplay.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getSceProductsNotEmpty(){
        if(!(sceProducts.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getSceAddlProductsNotEmpty(){
        if(!(sceAddlProductsToDisplay.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getSipThreshNotEmpty(){
        if(!(sipThrshldMet.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEaThreshNotEmpty(){
        if(!(eaThrshldMet.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEapThreshNotEmpty(){
        if(!(eapThrshldMet.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEciThreshNotEmpty(){
        if(!(eciThrshldMet.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getEasThreshNotEmpty(){
        if(!(easThrshldMet.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getSceThreshNotEmpty(){
        if(!(sceThrshldMet.isEmpty()))
            return true;
            
        else
            return false;
    }
    
    public Boolean getShowNoIncentiveMsg(){
        if(eaThrshldMet.isEmpty() && eapThrshldMet.isEmpty() && eciThrshldMet.isEmpty() && easThrshldMet.isEmpty() && sceThrshldMet.isEmpty())
            return true;
            
        else
            return false;
    }
    
    public Boolean getShowNoIncentiveMsgSIP(){
        if(sipThrshldMet.isEmpty())
            return true;
            
        else
            return false;
    }
    
    
    public String getCurrentProfile(){
        return currentProfile;
    }
    
    public List<S_P_Vendor_Additional_Information__c> getAddlInfoQuery(){
        return addlInfoQueryMain;
    }
    
    public List<S_P_Vendor_Additional_Information__c> getEaDisplaySV(){
        return addlInfoQuerySVEa;
    }
    
    public List<S_P_Vendor_Additional_Information__c> getSipDisplaySV(){
        return addlInfoQuerySVSip;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getProdSelQuery(){
        return prodSelQuery;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getSipProducts(){
        return sipProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getSipAddlProducts(){
        return sipAddlProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getSipAddlProductsToDisplay(){
        return sipAddlProductsToDisplay;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEaProducts(){
        return eaProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEaAddlProducts(){
        return eaAddlProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEapProducts(){
        return eapProducts;
    }
    
    
    public List<S_P_Vendor_Product_Selection__c> getEapAddlProducts(){
        return eapAddlProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEciProducts(){
        return eciProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEciAddlProducts(){
        return eciAddlProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEasProducts(){
        return easProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEasAddlProducts(){
        return easAddlProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getSceProducts(){
        return sceProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getSceAddlProducts(){
        return sceAddlProducts;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEaAddlProductsToDisplay(){
        return eaAddlProductsToDisplay;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEapAddlProductsToDisplay(){
        return eapAddlProductsToDisplay;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEciAddlProductsToDisplay(){
        return eciAddlProductsToDisplay;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getEasAddlProductsToDisplay(){
        return easAddlProductsToDisplay;
    }
    
    public List<S_P_Vendor_Product_Selection__c> getSceAddlProductsToDisplay(){
        return sceAddlProductsToDisplay;
    }
    
    public List<eaThrshldRow> getAddlInfoProdEa(){
        
                
        return eaThrshldMet;
    }
    
    public List<eaThrshldRow> getAddlInfoProdEap(){
        
                
        return eapThrshldMet;
    }
    
    public List<eaThrshldRow> getAddlInfoProdEci(){
        
                
        return eciThrshldMet;
    }
    
    public List<eaThrshldRow> getAddlInfoProdEas(){
        
                
        return easThrshldMet;
    }
    
    public List<eaThrshldRow> getAddlInfoProdSce(){
        
                
        return sceThrshldMet;
    }
    
    public List<eaThrshldRow> getSipThresholdSummary(){
        
                
        return sipThrshldMet;
    }
    
    public List<eaThrshldRow> getSipSumDisplay(){
        
                
        return prodSummaryTmp;
    }
    
    public Decimal getTotalProd(){
        return totalProd;
    }
    
    public Decimal getTotalEa(){
        return totalEa;
    }
    
    public Decimal getTotalAll(){
        return totalProd + totalEa;
    }
    
    public Integer getDeleteCheck(){
        
        return deleteCheck;
    }
    
    public String getUserCurrency(){
        return userCurrency;
    }
    
    public Decimal getConvertedTotalProd(){
        return convertedTotalProd;
    }
    
    public Decimal getConvertedTotalEa(){
        return convertedTotalEa;
    }
    
    public Decimal getconvertedTotalAll(){
        return convertedTotalProd + convertedTotalEa;
    }
    
    public Boolean getCurrencyCheck(){
        if(currencyCheck == 1)
            return true;
            else
            return false;
    }
    
    /*
        End of the controller class.
    */
}
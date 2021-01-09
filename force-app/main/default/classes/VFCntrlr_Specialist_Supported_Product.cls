/*
Author: Sathish Selvaraj
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.1         10618                       12-Jan-2015     Hari Jakkala    Created for Specialist Supported Product visual force page which can navigate from opportunity related list.
2.0         16136       FY19-DCE-0802   12-July-2018    Venkat Sharan   Removed debug statements and made code genric as part of code Reduce for the story 5240538
*/ 
public class VFCntrlr_Specialist_Supported_Product {
    
    public boolean canProceed = true;
    public String oppId = null;
    public String oppTeamMemSelected{get; set;}
    public String oppProductsSelected{get; set;}
    public String oppTeamMemId;
    public boolean goBtnRender{get; set;}
        
    public Specialist_Supported_Products__c objSplSupporPrd;
    public list<OpportunityTeamMember> oppTeamMemListToLoad = new list<OpportunityTeamMember>();
    public list<OpportunityLineItem> oppPrdListToLoad = new list<OpportunityLineItem>();
    public list<specialistSupportPrdWrapper> splSuppotedPrdList{get; set;}
    public map<string, SpecialistSupportPrdWrapper> currentSplSupportPrdMap = new map<string, SpecialistSupportPrdWrapper>();
    
    public VFCntrlr_Specialist_Supported_Product(){    
        try{           
            initialize();            
        }catch (Exception e){            
            System.debug('### error : ' + e.getStackTraceString());
        }             
    }
    
    private void initialize(){        
        oppId = ApexPages.currentPage().getParameters().get('oppId');                
        goBtnRender = true;            
        loadOppTeamMember();
        loadOppProduct();
        loadPreSelectedSSPRecord(); // Fenny added for CR10618
    }
    
    private void loadOppTeamMember() {        
        oppTeamMemListToLoad = [ SELECT UserId, User.Name FROM OpportunityTeamMember WHERE OpportunityId=:oppId ORDER BY User.Name];        
    }
    
    private void loadOppProduct() {
        oppPrdListToLoad = [ Select Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, PricebookEntry.Product2.Product_Line_Desc__c From OpportunityLineItem WHERE OpportunityId=: oppId];                   
    }
    
    // Fenny added [10150116] for CR10618
    private void loadPreSelectedSSPRecord(){
       String sspId = ApexPages.currentPage().getParameters().get('sspId');
       
       if(sspId<>null){
           Specialist_Supported_Products__c ssp = [Select id, Product__r.Name,Opportunity_Team_Member__r.name from Specialist_Supported_Products__c where id=:sspId];
           oppTeamMemSelected = ssp.Opportunity_Team_Member__r.Name;
           oppProductsSelected = ssp.Product__r.Name;

           loadCurrentSplSuppPrdBasedOnFilter(oppTeamMemSelected, oppProductsSelected);
           goBtnRender = false;
            splSuppotedPrdList = currentSplSupportPrdMap.values();
            splSuppotedPrdList.sort();
       }
    }
    
   public List<Specialist_Supported_Products__c> sspList {get; set;}                         
   
   private void loadCurrentSplSuppPrdBasedOnFilter(string oppTemMemName, string prdName) {
        
        list<Specialist_Supported_Products__c> currSplSuppPrdByFilter = new list<Specialist_Supported_Products__c>();
        string querySplSupportPrdWithFilter = '';        
        querySplSupportPrdWithFilter = 'select Id, Opportunity_Product_GUID__c, Opportunity__c, Opportunity_Team_Member__c, Product__c, Supporting__c, Opportunity_Team_Member__r.Name, Product__r.Name, Product__r.Product_Line_Desc__c from Specialist_Supported_Products__c where Opportunity__c=\'' + oppId +'\'';
        
        if(oppTemMemName != null && oppTemMemName != '--None--') {
            querySplSupportPrdWithFilter += ' and Opportunity_Team_Member__r.Name =\'' + oppTemMemName + '\'';
        }
        
        if(prdName != null && prdName != '--None--') {
            querySplSupportPrdWithFilter += ' and Product__r.Name =\'' + prdName + '\'';
        }
        
        currSplSuppPrdByFilter = Database.query(querySplSupportPrdWithFilter);
        
        if(currSplSuppPrdByFilter != null && currSplSuppPrdByFilter.size() > 0) {
            for(Specialist_Supported_Products__c objSplSupp : currSplSuppPrdByFilter) {
                string teamMemAndPrdStr = objSplSupp.Opportunity_Team_Member__c + '_' + objSplSupp.Product__c;
                currentSplSupportPrdMap.put(teamMemAndPrdStr, new specialistSupportPrdWrapper(objSplSupp));
            }
        }
    }
    
    public boolean getCanProceed(){
        return canProceed;        
    }
    
    public PageReference cancel(){    
       return PageUtils.redirect ('/' + oppId);           
    }
    
    public List<selectOption> getOppTeamMembersList() {
        Set<String> oppTeamMemSet = new Set<String>();        
        if(oppTeamMemListToLoad != null && oppTeamMemListToLoad.size() > 0) {               
            for(OpportunityTeamMember oppTeammObj: oppTeamMemListToLoad) {
                oppTeamMemSet.add(oppTeammObj.User.Name);
            }
            return genericBuildSelectList(oppTeamMemSet);
        }
        return new List<SelectOption>();
    }
    
    public List<SelectOption> genericBuildSelectList(Set<String> genericSet){
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('--None--', ''));         
        if(genericSet.size() > 0){
            for (String obj: genericSet) {             
                options.add(new selectOption(obj, obj)); 
            }
        }
        else{
            options.add(new SelectOption('Yes','Yes'));
        }
        return options;
    }
    
    public List<selectOption> getOppProductsList() {
        Set<String> oppPrdSet = new Set<String>();                    
        if(oppPrdListToLoad != null && oppPrdListToLoad.size() > 0) {        
            for(OpportunityLineItem oppLineItObj: oppPrdListToLoad) {
                oppPrdSet.add(oppLineItObj.PricebookEntry.Product2.Name);
            }
			return genericBuildSelectList(oppPrdSet);            
        }
        return new List<SelectOption>();
    }
    
    //create error message to be displayed on VF UI
    private void createError(boolean canProceedBool, String errMsg){    
        apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMsg));         
        canProceed = canProceedBool;        
    }
    
    public void nextAction() {
       
       loadCurrentSplSuppPrdBasedOnFilter(oppTeamMemSelected, oppProductsSelected);
       goBtnRender = false;            
                if(oppTeamMemListToLoad != null && oppTeamMemListToLoad.size() > 0 && oppPrdListToLoad != null && oppPrdListToLoad.size() > 0 ) {
                    
                    for(OpportunityTeamMember oppTeamMemItr : oppTeamMemListToLoad) {
                        for(OpportunityLineItem oppLineItemItr: oppPrdListToLoad) {
                            
                             if(currentSplSupportPrdMap.containsKey(oppTeamMemItr.UserId + '_' + oppLineItemItr.PricebookEntry.Product2Id))
                                continue;
                            
                            if(oppTeamMemSelected!= null && oppTeamMemSelected!= '--None--' && oppTeamMemItr.User.Name != oppTeamMemSelected)    
                               continue;    
                            
                            if(oppProductsSelected!= null && oppProductsSelected!= '--None--' && oppLineItemItr.PricebookEntry.Product2.Name != oppProductsSelected) 
                               continue;
      
                            currentSplSupportPrdMap.put(oppTeamMemItr.UserId + '_' + oppLineItemItr.PricebookEntry.Product2Id, new specialistSupportPrdWrapper(oppTeamMemItr, oppLineItemItr, ''));                          
                        }
                    }
        
                }
                
            splSuppotedPrdList = currentSplSupportPrdMap.values();
            splSuppotedPrdList.sort();
    }
    
    public List<SelectOption> getSupporingPicklistItems(){
        return genericBuildSelectList(new Set<String>());        
    }
    
    public pageReference Save() {        
        if(insertOrDeleteSplSupportProduct()==false){
           return null;
        }
        else{
            return PageUtils.redirect ('/' + oppId);
        }        
    }
    
    public pageReference cancelListView() {
        goBtnRender = true;
        oppTeamMemSelected = '--None--';
        oppProductsSelected = '--None--';
        currentSplSupportPrdMap = new map<string, specialistSupportPrdWrapper >();
        splSuppotedPrdList.clear();        
        return null;
    }
    
    public boolean insertOrDeleteSplSupportProduct() {
        try{
            list<Specialist_Supported_Products__c> splSupportedProductListToSave = new list<Specialist_Supported_Products__c>();
            list<Specialist_Supported_Products__c> splSupportedProductListToDelete = new list<Specialist_Supported_Products__c>();            
            if(splSuppotedPrdList != null && splSuppotedPrdList.size()>0){
                for(Integer index=0;index<splSuppotedPrdList.size();index++){                    
                    if(splSuppotedPrdList[index].supportingSelection== 'Yes' && splSuppotedPrdList[index].specialist_Supported_Product == null ) {
                        Specialist_Supported_Products__c objSplSupportPrd = new Specialist_Supported_Products__c(Opportunity__c = oppId, 
                                                        Opportunity_Team_Member__c = splSuppotedPrdList[index].oppTeamMemId, 
                                                        Product__c = splSuppotedPrdList[index].prdId, 
                                                        Opportunity_Product_GUID__c = splSuppotedPrdList[index].oppProdId, // Fenny edited for defect 149900
                                                        Supporting__c = splSuppotedPrdList[index].supportingSelection);
                        splSupportedProductListToSave.add(objSplSupportPrd);                                                        
                    }
                    else if (splSuppotedPrdList[index].supportingSelection != 'Yes' && splSuppotedPrdList[index].specialist_Supported_Product  != null) {
                            splSupportedProductListToDelete.add(splSuppotedPrdList[index].specialist_Supported_Product);               
                    }  
                }
            }
            
            if(splSupportedProductListToSave != null && splSupportedProductListToSave.size() > 0) {
                insert splSupportedProductListToSave;
            }            
            if(splSupportedProductListToDelete != null && splSupportedProductListToDelete.size() > 0) {
                delete splSupportedProductListToDelete; 
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());                      
            ApexPages.addMessages(e);                
            return False;                
        }
        return True;
    }
    
    public class specialistSupportPrdWrapper implements Comparable {
                
        public Id oppTeamMemId{get;set;}
        public Id prdId{get;set;}
        public String oppTeamMemName{get;set;}
        public String prdName{get;set;}
        public String prdLineDesc{get;set;}
        public String supportingSelection{get;set;}
        public String id {get;set;}
        public String oppProdId {get;set;} // Fenny added for CR10618
        public Specialist_Supported_Products__c specialist_Supported_Product {get;set;}  
        
        
        public specialistSupportPrdWrapper(OpportunityTeamMember objOppTeamMem, OpportunityLineItem objOppLineItm, string supportingWrap) {
            this.oppTeamMemId = objOppTeamMem.UserId;
            this.oppTeamMemName = objOppTeamMem.User.Name;
            this.prdId = objOppLineItm.PricebookEntry.Product2Id;
            this.prdName = objOppLineItm.PricebookEntry.Product2.Name;
            this.prdLineDesc = objOppLineItm.PricebookEntry.Product2.Product_Line_Desc__c;
            this.oppProdId = objOppLineItm.Id; // Fenny added for CR10618
            
            //Start: Code block to set Supporting? field as Yes if user already selected for supporting
            if(supportingWrap != null && supportingWrap != '') {
                this.supportingSelection = supportingWrap;
            }
            system.debug('supportingWrap supportingWrap###' + supportingWrap);
            //End: Code block to set Supporting? field as Yes if user already selected for supporting
        }
        
        public specialistSupportPrdWrapper(Specialist_Supported_Products__c objSplSupportPrd) {
            this.oppTeamMemId = objSplSupportPrd.Opportunity_Team_Member__c;
            this.oppTeamMemName = objSplSupportPrd.Opportunity_Team_Member__r.Name;
            this.prdId = objSplSupportPrd.Product__c;
            this.prdName = objSplSupportPrd.Product__r.Name;
            this.prdLineDesc = objSplSupportPrd.Product__r.Product_Line_Desc__c;
            this.supportingSelection = objSplSupportPrd.Supporting__c;
            this.id = objSplSupportPrd.id;
            this.specialist_Supported_Product  = objSplSupportPrd;
            this.oppProdId = objSplSupportPrd.Opportunity_Product_GUID__c; // Fenny added for CR10618
            
        }
        
        public Integer compareTo(Object compareTo) {
            specialistSupportPrdWrapper sW = (specialistSupportPrdWrapper)compareTo;            
            return oppTeamMemName.compareTo(((specialistSupportPrdWrapper)compareTo).oppTeamMemName);
        }        
    }
}
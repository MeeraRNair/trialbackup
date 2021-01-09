/***********************************************************
    * Name          : MassOpportunityUpdate
    * Description   : Controller for MassOpportunityUpdate
    
    History:
    Version     Date            Modified By     CR          Description     
    --------------------------------------------------------------------------------------
    1.0         Unknown         Unknown         Unknown     Class creation 
    2.0         14-Dec-2015     Shue            12427       Shue add history. Add CR12427 functionality - Mass Update Edit?, Mass Update Edit Date
    2.0         15-Dec-2015     Shue            12427       Mass Update Edit Field
    3.0         02-Feb-2017     Vasavi.M        13964       Remove cast iron condition from book date checking
    4.0         05-Jul-2017     Abhinav         14471       To exclude 'Order Submitted - 99%' opportunities from the list
    4.1         05-Jul-2017     Abhinav         14471       Introduced custom settings for StageName picklist values
    4.2         22-Dec-2017     Abhinav         15346       Removed Override_Probability__c and added Forecast_Category_Override__c
    4.3         04-Jan-2018     Abhinav         15346       Removed Probability and added Forecast_Category_RO__c
    4.4         22-Mar-2018     Sakshi          15568       Reduce Code
    4.5         26-Aug-2019     Monisha         08184       Update on selected records only.
    4.6         22-OCT-2019     Monisha         7569003     Defect temporary changes to prevent it from SOQL 101 Error.
    */
    
    
    public with sharing class MassOpportunityUpdate{
        @testVisible
        private ApexPages.StandardSetController standardController{get;set;}
        private List<Opportunity> selectedOppTest = new List<Opportunity>();
        public Map<id,oppWrapper> oppWrapperMap {get;set;}
        public List<ID> wrapperList = new List<ID>();
        public List<oppWrapper> wrapperList25 {get;set;}    
        public boolean ShowBackButton {get; set;}
        public boolean HasPermissionToView {get; set;}
        public Map<ID,Boolean> mapAccess {get; set;}
        public boolean isModified {get;set;}
        public Boolean isErrorRec{get;set;}
        public Map<ID,String> errorMap {get; set;} 
        public boolean showPagination {get;set;}
        public Integer totalPages { get; set; }
        public Boolean isSavedSuccessfully {get;set;}
        public String strgetOppIds{get;set;}
        List<Opportunity> listgetOppSelRecs = new List<Opportunity>();
       //2.0
        Set<id> modifiedOpptyIdSet = new Set<id>();
      
        //4.1 Introduced custom settings
        private OWD__c owd = OWD__c.getOrgDefaults();
       
    public MassOpportunityUpdate(ApexPages.StandardSetController standardController){ 
        
        
        this.standardController = standardController;
        //4.6 Defect:7569003 changes- Introduced the label to hold the count of records to display per page.
        String strRecordCount='';
        Integer iRecordsPerPage;
         if (Test.isRunningTest()){
             iRecordsPerPage=10;
         }
         else{
             strRecordCount=Label.Opp_MassUpdateCount;
             iRecordsPerPage = Integer.ValueOf(strRecordCount.trim());
         }
        Decimal dtotalPages;
        Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
       if (Schema.sObjectType.Opportunity.isUpdateable() &&  (!profileName.contains('PRM') || !profileName.contains('Portal')) && !profileName.contains('Strategic Partner User')) {   
            HasPermissionToView = true;
            ShowBackButton = false;
            showPagination = false;       
             oppWrapperMap =new Map<id,oppWrapper>();
             wrapperList25 = new List<oppWrapper>();
             errorMap = new Map<ID,String>();
             mapAccess =  new Map<ID,Boolean>();
             strgetOppIds=ApexPages.currentPage().getParameters().get('idOpps');
             this.standardController = new ApexPages.StandardSetController(getRecords());
            initializeParentWrapper(); 
            recordPermission();
            
            standardController.setPageSize(iRecordsPerPage);
            
            dtotalPages = (wrapperList.size() / standardController.getPageSize());
            dtotalPages = Math.floor(dtotalPages) + ((Math.mod(wrapperList.size(), iRecordsPerPage)>0) ? 1 : 0);
            totalPages = Integer.valueOf(dtotalPages);
            if(wrapperList.size() > 25)
                showPagination = true;
        }else{
                    HasPermissionToView = false;
                    ShowBackButton = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You don\'t have permission to access this functionality.'));
       }
       if(wrapperList.size() == 0 && HasPermissionToView == true){
            HasPermissionToView = false;
            ShowBackButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No records to display.'));                
        }
        //4.6 Defect:7569003 changes: If selected more than 10 records to update show warning. 
        if(wrapperList.size() > iRecordsPerPage && HasPermissionToView == true){
            HasPermissionToView = false;
            ShowBackButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'A maximum of&nbsp;'+Label.Opp_MassUpdateCount+'&nbsp;records at a time may be selected for mass update.'));                
        }
    }
    
    public void saveAndReturn(){
        try{
            List<Opportunity> opp2Update = new List<Opportunity>();
            List<Opportunity> lstOpp = new List<Opportunity>(); 
            List<ID> successIds = new List<ID>(); 
            isSavedSuccessfully = true;
            for(oppWrapper oppWrap:oppWrapperMap.values()){
                isErrorRec = false;
                if(oppWrap.isModified){
                     if(oppWrap.opp.CloseDate < system.today() && (oppWrap.opp.StageName != owd.Oppty_Stage100__c && oppWrap.opp.StageName != owd.Oppty_Stage0__c) ) {//4.1
                        isErrorRec = true;
                        isSavedSuccessfully = false;
                        oppWrap.opp.CloseDate.addError('You cannot save an open opportunity where the Book Date is prior to today’s date. Please either change the Book Date to a future one or move the Stage to Won or Lost and then save.',true);
                    }
                    if(!isErrorRec) {
                        //4.3:bof - to provide default probability value based on stage value
                        if(oppWrap.opp.StageName ==  owd.Oppty_Stage1__c) {
                            oppWrap.opp.Probability = 1;
                        } else if(oppWrap.opp.StageName ==  owd.Oppty_Stage10__c) {
                            oppWrap.opp.Probability = 10;
                        } else if(oppWrap.opp.StageName ==  owd.Oppty_Stage30__c) {
                            oppWrap.opp.Probability = 30;
                        } else if(oppWrap.opp.StageName ==  owd.Oppty_Stage60__c) {
                            oppWrap.opp.Probability = 60;
                        } else if(oppWrap.opp.StageName ==  owd.Oppty_Stage90__c) {
                            oppWrap.opp.Probability = 90;
                        } else if(oppWrap.opp.StageName ==  owd.Oppty_Stage99__c) {
                            oppWrap.opp.Probability = 99;
                        } else if(oppWrap.opp.StageName ==  owd.Oppty_Stage100__c) {
                            oppWrap.opp.Probability = 100;
                        } else if(oppWrap.opp.StageName == owd.Oppty_Stage0__c) {
                            oppWrap.opp.Probability = 0;
                        }
                        //4.3:eof
                        //2.0 STARTS
                        modifiedOpptyIdSet.add(oppWrap.opp.id);
                        //2.0 ENDS
                        opp2Update.add(oppWrap.opp);
                    }
                }
                lstOpp.add(oppWrap.opp);
            }
            //2.0 STARTS
            setMassUpdateFields(opp2Update);
            //2.0 ENDS
            if(opp2Update.size()>0){
                Database.SaveResult[] results = Database.update(opp2Update,false);
                for(Integer i=0; i < results.size();i++){
                    if (!results.get(i).isSuccess()) {
                        for(Database.Error err : results.get(i).getErrors()) {
                            isSavedSuccessfully = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage()));
                        }
                        errorMap.put(opp2Update.get(i).id,'Error');
                        
                    }else
                        successIds.add(results.get(i).getId());
                }           
            }
            if(successIds.size()>0 && !isSavedSuccessfully)
                refreshTable(successIds);
    
            if(isSavedSuccessfully){
                    refreshTable(wrapperList);
                    getRecordPermission(wrapperList);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success: All modified records have been updated successfully. To return to your previous View, click Cancel, or to continue with Mass Updates, choose another page of records.'));
                }
        
        }catch(Exception e){
                GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
                isSavedSuccessfully = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + e.getMessage()));
            }
    }
    
    //2.0 STARTS
    public void setMassUpdateFields(List<Opportunity> oppWrap){
        Set<String> setOrdKey = new Set<String>();
        //Get old values        
        for(Opportunity oldOppValues:[SELECT id,Name,Account.Name,StageName,CloseDate,Quote_Numbers__c,Probability,Forecast_Category_RO__c,Forecast_Category_Override__c,Unweighted_Rev_Formula__c,Description,NextStep,PartnerAccount.Name FROM Opportunity  Where id IN:modifiedOpptyIdSet]){
            setOrdKey.add(oldOppValues.id+' StageName '+oldOppValues.StageName);
            setOrdKey.add(oldOppValues.id+' CloseDate '+oldOppValues.CloseDate);
            setOrdKey.add(oldOppValues.id+' Quote_Numbers__c '+oldOppValues.Quote_Numbers__c);
            setOrdKey.add(oldOppValues.id+' Probability '+oldOppValues.Probability);
            setOrdKey.add(oldOppValues.id+' Forecast_Category_Override__c '+oldOppValues.Forecast_Category_Override__c);
            if(oldOppValues.Description == null){
                oldOppValues.Description ='';
            }
            setOrdKey.add(oldOppValues.id+' Description '+oldOppValues.Description);
            if(oldOppValues.NextStep == null){
                oldOppValues.NextStep ='';
            }
            setOrdKey.add(oldOppValues.id+' NextStep '+oldOppValues.NextStep);    
        }
        //Compare with new values
        for(Opportunity newOppValues:oppWrap){
            newOppValues.Mass_Update_Edit_Field__c = '';
            String massUpdateField = '';
            
            if(!setOrdKey.contains(newOppValues.id+' StageName '+newOppValues.StageName)){
                massUpdateField += Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('StageName').getDescribe().getLabel()+', ';
            }
            if(!setOrdKey.contains(newOppValues.id+' CloseDate '+newOppValues.CloseDate)){
                massUpdateField += 'Book Date, '; //this field label is Close Date, so hardcode for Book Date
            }
            if(!setOrdKey.contains(newOppValues.id+' Quote_Numbers__c '+newOppValues.Quote_Numbers__c)){
                massUpdateField += Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('Quote_Numbers__c').getDescribe().getLabel()+', ';
            }
            if(!setOrdKey.contains(newOppValues.id+' Probability '+newOppValues.Probability)){
                massUpdateField += Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('Probability').getDescribe().getLabel()+', ';
            }    
            if(!setOrdKey.contains(newOppValues.id+' Forecast_Category_Override__c '+newOppValues.Forecast_Category_Override__c)){
                massUpdateField += Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('Forecast_Category_Override__c').getDescribe().getLabel()+', ';
            }
            if(!setOrdKey.contains(newOppValues.id+' Description '+newOppValues.Description)){
                massUpdateField +=  Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('Description').getDescribe().getLabel()+', ';
            }
            if(!setOrdKey.contains(newOppValues.id+' NextStep '+newOppValues.NextStep)){
                massUpdateField +=  Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('NextStep').getDescribe().getLabel()+', ';
            }
            if(newOppValues.Mass_Update_Edit__c != true){
                newOppValues.Mass_Update_Edit__c = true;    
            }
            newOppValues.Mass_Update_Edit_Date__c = System.today();
            massUpdateField = massUpdateField.removeEnd(', ');
            newOppValues.Mass_Update_Edit_Field__c = massUpdateField;
        }
    }
    //2.0 ENDS
     //4.5 method to return list of selected records.
       public List<Opportunity> getRecords() {
        if(String.isNotBlank(strgetOppIds)){
        List<String> listOppIds = strgetOppIds.split(':');
        listgetOppSelRecs = [SELECT id,CloseDate FROM Opportunity  Where id IN:listOppIds];
        }
        return listgetOppSelRecs;
        }
        //4.5 ENDS
    
    public class oppWrapper  implements Comparable {
        public Opportunity opp {get;set;}
        public Boolean isModified {set;get;}
        oppWrapper(Opportunity opp,Boolean isModified){
            this.opp = opp;
            this.isModified = isModified;
        }
         public Integer compareTo(Object o) {
            oppWrapper wrapObj= (oppWrapper) o;
            if (this.opp.CloseDate > wrapObj.opp.CloseDate) return 1;
            else return -1;            
        }   
    }
    
    public void initializeParentWrapper(){
    System.debug(standardController.getSelected());
     
        oppWrapper  wrapperObj = null;
        wrapperList.clear();
        List<Opportunity> selectedOpp = new List<Opportunity>();
        Set<ID> setIds= new Set<ID>(); 
        standardController.setPageSize(1000);
         do{
                for(Opportunity oppRec : (List<Opportunity>)getRecords()){
                    setIds.add(oppRec.Id);           
                }
                standardController.next();
            }while(standardController.getHasNext());
            
            standardController.last();
            for(Opportunity oppRec : (List<Opportunity>) getRecords()){
                    setIds.add(oppRec.Id);           
                }
            standardController.first();  
            standardController.setPageSize(25);
           // standardOpportunityRT=StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');
         for(Opportunity oppObj:[SELECT id,CloseDate FROM Opportunity  Where id IN:setIds AND (LOT_Large_Opportunity__c = false and LOT_Large_Opportunity_Potential__c = false AND StageName != :owd.Oppty_Stage99__c) order by Number_of_Line_Items__c asc ]){  
               wrapperList.add(oppObj.id); 
         }       
         selectedOpp = null;
         setIds = null;
    }
    
    public void initializeWrapper(List<ID> totalIds){
         oppWrapper  wrapperObj = null;
         oppWrapperMap.clear(); 
         wrapperList25.clear();
         errorMap.clear();
         List<ID> lstIds = new List<ID>();  
         Integer startingRec = getStartPageRecords();
         Integer endingRec = getEndPageRecords();
         for(Integer x=(startingRec-1);x<endingRec;x++){
                lstIds.add(totalIds.get(x));
                errorMap.put(totalIds.get(x),'');
         }
    
         for(Opportunity oppObj:[SELECT id,Name,Account.Name,StageName,CloseDate,Quote_Numbers__c,Probability,Forecast_Category_RO__c,Forecast_Category_Override__c,Unweighted_Rev_Formula__c,Description,NextStep,PartnerAccount.Name FROM Opportunity  Where id IN:lstIds]){
              wrapperObj = new oppWrapper(oppObj,false);
              oppWrapperMap.put(oppObj.id,wrapperObj);
              wrapperList25.add(wrapperObj);
         }
         wrapperList25.sort();
    }
    
    public void getRecordPermission(List<ID> parentWrapper){
            mapAccess.clear();
            List<ID> lstIds = new List<ID>();  
            Integer startingRec = getStartPageRecords();
            Integer endingRec = getEndPageRecords();
            for(Integer x=(startingRec-1);x<endingRec;x++){
                lstIds.add(parentWrapper.get(x));
            }
            List<UserRecordAccess> conList=[SELECT HasEditAccess,MaxAccessLevel,RecordId FROM UserRecordAccess Where UserId=:userInfo.getUserId() and RecordId IN:lstIds];
            for(UserRecordAccess con:conList){
              mapAccess.put(con.RecordId, con.HasEditAccess);
            }
    }
    
    public void refreshTable(List<ID> lstIds){
        oppWrapper  wrapperObj = null;
        for(Opportunity oppObj:[SELECT id,Name,Account.Name,StageName,CloseDate,Quote_Numbers__c,Probability,Forecast_Category_RO__c,Forecast_Category_Override__c,Unweighted_Rev_Formula__c,Description,NextStep,PartnerAccount.Name FROM Opportunity  Where id IN:lstIds]){
              if(oppWrapperMap.containsKey(oppObj.id)){
                wrapperObj = new oppWrapper(oppObj,false);
                oppWrapperMap.put(oppObj.id,wrapperObj);
              }
              if(errorMap.containsKey(oppObj.id)){
                  errorMap.put(oppObj.Id,'');
              }
         }
    }
    
    public PageReference cancelAndReturn() {
        standardController.cancel();
        PageReference newPage;
        newPage = new PageReference('/006?fcf=' + standardController.getFilterId().substring(0, 15));
        return newPage.setRedirect(true);
    }
        public Integer getTotalPages(){ 
            Decimal totalSize = wrapperList.size();
            Decimal pageSize = this.standardController.getPageSize(); 
            Decimal pages = totalSize/pageSize; 
            return (Integer)pages.round(System.RoundingMode.CEILING);
        }      
    
        public Integer getPageNumber(){ 
            if(standardController.getHasNext()){
               return this.standardController.getPageNumber();
            }else{
                Integer lastPageNum = getTotalPages();
                return lastPageNum;
            }
        }
    
        public Integer getPageSize(){ 
            return this.standardController.getPageSize(); 
        }
    
        public Integer getTotalRecords(){ 
            return this.wrapperList.size(); 
        }
    
        public Integer getStartPageRecords(){
            integer StartPageRecords;
            StartPageRecords = (this.standardController.getPageNumber() * this.standardController.getPageSize()) + 1;
            if(this.standardController.getPageNumber() == 1)
                StartPageRecords = 1;
            else
                StartPageRecords = ((this.standardController.getPageNumber() * this.standardController.getPageSize()) - (this.standardController.getPageSize())) + 1;    
            return StartPageRecords; 
        }
    
        public Integer getEndPageRecords(){
            integer EndPageRecords;
            EndPageRecords = this.standardController.getPageNumber() * this.standardController.getPageSize();  
            if(this.wrapperList.size() < EndPageRecords)
                EndPageRecords = this.wrapperList.size();   
            return EndPageRecords; 
        }
        
            public Integer PageNumber1 {
            get {
                if(getPageNumber() <= 2) 
                    return 1;
                else if(getPageNumber() == getTotalPages()) 
                    return getPageNumber() - 2;
                else 
                    return getPageNumber() - 1;           
            }
            set;        
        }
    
        public Integer PageNumber2 {
            get {        
                if(getPageNumber() == 1) 
                    return 2;
                else if(getPageNumber() == getTotalPages() && getTotalPages() != 2) 
                    return getTotalPages() - 1;
                else 
                    return getPageNumber();          
            }
            set;
        }
    
        public Integer PageNumber3 {
            get {        
                if(getPageNumber() == 1) 
                    return 3;
                else if(getPageNumber() == getTotalPages()) 
                    return getTotalPages();
                else 
                    return getPageNumber() + 1;           
            }
            set;
        }
    
    /**
                Pagination Codes
    **/
    
        public void Page1() {
            try{
                standardController.setPageNumber(PageNumber1);
                recordPermission();
            }
            catch(Exception e){
                system.debug(e);
            }
        }
    
        public void Page2() {
            try{
                standardController.setPageNumber(PageNumber2);
                recordPermission();
            }
            catch(Exception e){
                system.debug(e);
            }
        }
        
        public void Page3() {
            try{
                standardController.setPageNumber(PageNumber3);
                recordPermission();
            }
            catch(Exception e){
                system.debug(e);
            }   
        }    
    
         public void FirstPage() {
            try{   
                 standardController.first(); 
                 recordPermission();
            }catch(Exception e){
                system.debug(e);
            }
         }
    
         public void PreviousPage() {
            try{
                if(standardController.getHasPrevious()){
                    standardController.previous();
                    recordPermission();
                }
            }catch(Exception e){
                system.debug(e);
            }
         }
    
         public void NextPage() {
            try{
                if(standardController.getHasNext()){
                    standardController.next();
                    recordPermission();
                }
            }catch(Exception e){
                system.debug(e);
            }
         }
         
         public void LastPage() {
            try{
                    Integer lastPage = getTotalPages();
                    standardController.setPageNumber(lastPage);
                    recordPermission();
            }catch(Exception e){
                system.debug(e.getStackTraceString());
            }
         }
        
        public void SaveAndPage1() {
            pageNumberSet('one');
        }
        
        public void SaveAndPage2() {  
            pageNumberSet('two');   
        }
        
        public void SaveAndPage3() { 
            pageNumberSet('three');    
        }
         
        public void SaveAndFirstPage() { 
            pageNumberSet('first');   
        }
    
        public void SaveAndPrevPage() { 
             pageNumberSet('previous');   
        }    
        public void SaveAndNextPage() { 
            pageNumberSet('next');   
        } 
    
        public void SaveAndLastPage() { 
            pageNumberSet('last');   
        }
        
        public PageReference idleSaveRedirect(){
            saveAndReturn();
                PageReference newPage;
                newPage = new PageReference('/apex/MassOpportunityUpdate?fcf=' + standardController.getFilterId().substring(0, 15));
                return newPage.setRedirect(true);
              
        }
        
        public PageReference idleRedirect(){
            PageReference newPage;
            newPage = new PageReference('/apex/MassOpportunityUpdate?fcf=' + standardController.getFilterId().substring(0, 15));
            return newPage.setRedirect(true);
        }
        
        private void recordPermission(){
            getRecordPermission(wrapperList);
            initializeWrapper(wrapperList);
        }
        
        private void pageNumberSet(String str){
            try{
                Integer pageNum = standardController.getPageNumber();
                saveAndReturn();
                if(!isSavedSuccessfully){
                    standardController.setPageNumber(pageNum);
                }else{
                    if(str == 'one')
                        Page1();
                    else if(str == 'two')
                        Page2();
                    else if(str == 'three')
                        Page3();
                    else if(str == 'first')   
                        FirstPage();
                    else if(str == 'previous')
                        PreviousPage();
                    else if(str == 'next') 
                        NextPage();
                    else if(str == 'last')   
                        LastPage();
                }
            }catch(Exception ex){
                system.debug(ex);
            }   
        }
    }
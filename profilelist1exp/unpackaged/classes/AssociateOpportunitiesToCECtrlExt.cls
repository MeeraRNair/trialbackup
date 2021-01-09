/*****************************************************************************************************************
* Name          : AssociateOpportunitiesToCECtrlExt
* Description   : Associate Existing Opportunities related to Account to Customer Engagement.
* ---------------------------------------------------------
* Revision  Name                Date            Description
* 1.0       Manikandan          12.08.2011      CR 6345 - Defect ID : 71878.
* 2.0       Krishnamoorthi      26.06.2012      R13.7 CR 6948 - Restructured the code to fix the view state error for large volume of opportunities
* 3.0       TK Chin             08.12.2012      R14.2 CR 7716 - Add search/filter functionality (Deal ID, Stage) 
* 4.0       Meghana Gupta       15.08.2013      R14.10 CR 8577 - Channel Template (creating new oppportunity record type )
* 5.0       Syidah              12.06.2017      CR 14509 - Added "Order Submitted - 99%" picklist value under StageName and introduced custom settings for StageName picklist values
* 6.0       Naga Boyina         14.09.2017      Defect#3923631 removed ", Customer_Engagement_Event__c = null" at "Customer_Engagement_Event_CSC__c = customerEngagement.Id" at Dell Solution Centers
* 7.0       Rahul Mishra        29.07.2018      Code Reduce!
******************************************************************************************************************/

global class AssociateOpportunitiesToCECtrlExt implements al.ObjectPaginatorListener {
        
    public List<Opportunity> oppListToUpdate = new List<Opportunity>();
    public Customer_Engagement__c customerEngagement {get; set;}
    public List<OpportunityWrapper> opportunityWrappers {get;set;}
    public boolean nullOppList {get; set;} 
    set<id> accountsIDset = new set<id>();
    set<id> oppRcdIDset = new set<id>();  
    
    set<id> selectedOppIdSet = new set<id>(); 
    public Boolean nullId {get; set;} 
    public Boolean nullRecords {get; set;}
    
    //R14.2 CR 7716
    public String strSearchDealID { get; set; }
    public String strSearchStage { get; set; }
    public Boolean hasExistingOpps { get; set; }
    
    //5.0 - Introduced custom settings for StageName
    private OWD__c owd = OWD__c.getOrgDefaults();
    
    
    //5.0 - Introduced custom settings for StageName
   public List<SelectOption> getListStageNames() {     
        List<SelectOption> listStageNames = new List<SelectOption>();
        listStageNames.add(new SelectOption('None', 'None'));
        listStageNames.add(new SelectOption(owd.Oppty_Stage1__c, owd.Oppty_Stage1__c));
        listStageNames.add(new SelectOption(owd.Oppty_Stage10__c, owd.Oppty_Stage10__c));
        listStageNames.add(new SelectOption(owd.Oppty_Stage30__c, owd.Oppty_Stage30__c));
        listStageNames.add(new SelectOption(owd.Oppty_Stage60__c, owd.Oppty_Stage60__c));
        listStageNames.add(new SelectOption(owd.Oppty_Stage90__c, owd.Oppty_Stage90__c));
        listStageNames.add(new SelectOption(owd.Oppty_Stage99__c, owd.Oppty_Stage99__c)); //5.0 - Added "Order Submitted - 99%" picklist value under StageName
        listStageNames.add(new SelectOption(owd.Oppty_Stage100__c, owd.Oppty_Stage100__c));
        listStageNames.add(new SelectOption(owd.Oppty_Stage0__c, owd.Oppty_Stage0__c));
        return listStageNames;
    } 
        
    //SObject Paginator
    public al.ObjectPaginator paginator {get;private set;} 
    public Integer pageSize; 
      
    public Integer getPAGE_SIZE(){ 
        return pageSize;
    }
    
    public void setPAGE_SIZE(Integer value){ 
        pageSize = value; 
        paginator.setPageSize(pageSize);
    }

    /* ************************
     * Constructor & Set Controller Methods
     * *************************/
     
    public AssociateOpportunitiesToCECtrlExt() {
        
        //R14.2 CR 7716
        strSearchDealID = null;
        strSearchStage = 'None';
        hasExistingOpps = false;
        
        nullOppList = false;
        init();
        
        List<Customer_Engagement__c> customerEngagementList; 
        String  recordId =  ApexPages.currentPage().getParameters().get('id');
        nullId = false;
                
        if (recordId == null){ 
                nullId = true;
                return;
        }
        else {
                customerEngagementList = [SELECT Id,Name,Primary_Account__c,RecordType.Name FROM Customer_Engagement__c
                                WHERE id = :ApexPages.currentPage().getParameters().get('id')]; 
               
               if(customerEngagementList.size() > 0) {
                   customerEngagement = customerEngagementList[0];
               }
               else {
                        nullId = true;
                        return;
               }                
        
                                
                for(Attending_Accounts__c aaID : [Select Id, Name, Account__c FROM Attending_Accounts__c where Customer_Engagement__c =: customerEngagement.Id]){
                    accountsIDset.add(aaID.Account__c);
                }
                //14.10 - CR 8577 - Include new oppty record type 'Channel Opportunity'
                for(RecordType rt : [Select Name,Id From RecordType where sObjectType='Opportunity' and (name=:'Standard Opportunity' or name=:'SMB Opportunity' or name=:'Run Rate Opportunity' or name =:'Channel Opportunity')]){
                    oppRcdIDset.add(rt.Id);
                }
        }
        
    }
    
    private void init() { 
        pageSize = 10;
        paginator = new al.ObjectPaginator(pageSize,this);
    }

    public String makeQuery(){
        //Query only ID to avoid View state Error
        
        String qry = 'Select Id, Name, AccountId, StageName FROM Opportunity where RecordtypeId in :oppRcdIDset and AccountId in :accountsIDset and (Customer_Engagement_Event__c != \''+customerEngagement.Id+'\' or Customer_Engagement_Event_CSC__c!= \''+customerEngagement.Id+'\')'; 
        
        //R14.2 CR 7716 - Search/filter by Deal ID and/or Stage
        if(strSearchDealID != null && strSearchDealID.length() > 0) {
            qry = qry + ' AND Deal_ID__c LIKE \'%' + strSearchDealID + '%\'';
        }
        if(strSearchStage != 'None') {
            qry = qry + ' AND StageName = \'' + strSearchStage + '\'';
        }
        
        qry = qry + ' Order By Name LIMIT 1000' ; 
        return qry; 
    }
        
    /* ************************
     * Paginator Methods
     * *************************/
    
       global void handlePageChange(List<Object> newPage){
        
        set<id> oppIDset = new set<id>();
        
        for(Object obj : newPage) {
                Opportunity opp = (Opportunity)obj;
                oppIDset.add(opp.Id);           
        }
        
       List<Opportunity> opplist = database.query(makequery());
        
        if(opportunityWrappers == null) {
            opportunityWrappers = new List<OpportunityWrapper>();
        }

        //Clear the current page
        opportunityWrappers.clear();
                
        if(!opplist.isEmpty()) {
            for(Opportunity o : opplist) {
                OpportunityWrapper tw = new OpportunityWrapper((Opportunity)o);
                if(selectedOppIdSet.contains(o.Id)){
                        tw.selected = true;
                }
                opportunityWrappers.add(tw);
            }
        }
    }

    /* ************************
     * Action Methods
     * *************************/
    
    //R14.2 CR 7716 - To render Message and Opportunities pageBlockSections
    public PageReference cmdSearch() {
        hasExistingOpps = true;
        return search();
    }
    
    public PageReference search() {
                
                nullRecords = false;
        opportunityWrappers =null;
        if(opportunityWrappers == null) {                
                List<SObject> allRecords;                
                try {                                                                                 
                    allRecords = Database.query(makeQuery());                                       
                } catch (Exception exp) {
                    al.PageUtils.addError('Exception with query: ' + exp.getMessage()); 
                    return null;                
                }

                if(paginator == null) {
                    paginator = new al.ObjectPaginator(pageSize,this);
                }

                paginator.setPageSize(pageSize);

                if(!allRecords.isEmpty()){                        
                        paginator.setRecords(allRecords);
                }
                else {
                        nullRecords = true;
                }
        }
        
        return null;        
    }
    
    public class OpportunityWrapper {
        public Opportunity oppty {get;set;} 
        public Boolean selected {get;set;}
        public OpportunityWrapper(Opportunity t) {
            oppty = t;
            selected = false;
        }
    }

        public void getSelectedRecords(){
                for (opportunityWrapper ow : opportunityWrappers) {
                        if (ow.selected){
                                selectedOppIdSet.add(ow.oppty.Id);
                        }
                }
        }
        
        public void Next(){
        getSelectedRecords();
        paginator.next();
    }

    public void Previous(){
        getSelectedRecords();
        paginator.Previous();
    }
        
        //Associate selected Opportunities
    public PageReference associateOpportunity() {
        getSelectedRecords();
        //6.0
        for(Id oppId : selectedOppIdSet) {
            Opportunity opp = null;
            if(customerEngagement.RecordType.Name == 'Dell Solution Centers') {//Customer Solution Center
                opp = new Opportunity(Id = oppId, Customer_Engagement_Event_CSC__c = customerEngagement.Id);
            } else if(customerEngagement.RecordType.Name == 'Executive Briefing Center') {            
                opp = new Opportunity(Id = oppId, Customer_Engagement_Event__c = customerEngagement.Id);
            }
            if(opp != null)
                oppListToUpdate.add(opp);
        }
        if (oppListToUpdate.size() == 0){
            nullOppList = true;
            return null;
        } 
                
        update oppListToUpdate;
        return new PageReference('/'+customerEngagement.Id); 
    }
    
    public PageReference cancel() {
        return new PageReference('/'+customerEngagement.Id); 
    }
    
    public PageReference ok() {
        return new PageReference('/home/home.jsp'); 
    }
}
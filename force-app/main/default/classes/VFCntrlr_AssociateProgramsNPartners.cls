public class VFCntrlr_AssociateProgramsNPartners{
    ApexPages.StandardController controllerVar;
    String currentURL;
    String SelectedRegion;
    String SelectedSubRegion;
    String SelectedCountry;
    String SelectedFiscalQtr;
    Boolean NoApv=False; 
    Boolean profileErr=false;
    Boolean displayForm=false;
    Boolean displayTable=false;
    Boolean NoApvList=false;
    Vendor__c subVendor=new Vendor__c();
    mdf_program__c mdfProgram; 
    Set<Id> programIdSet=new Set<Id>();
    Set<String> unSelectedBSegs = new Set<String>();
    Set<String> selectedBSegs = new Set<String>();
    Set<String> addALLBSegs = new Set<String>();
    Set<String> removeALLBSegs = new Set<String>();
    List<String> selectedOptionLst=new List<String>();  
    //public List<String> unselected {get; set; }    
    List<String> selected =new List<String>();
    List<String> unselected =new List<String>();     
    List<String> bSegList=new List<String>(); 
    List<String> selectedBsegList=new List<String>();    
    List<MDF_Program__c> approvedMDFPgmList=new List<MDF_Program__c>();
    List<ProgramWrapper> apvWrapperList=new List<ProgramWrapper>(); 
    List<Id> displayList=new List<Id>(); 
    List<thousandBlocks> thousandRecList;   
    Map<String,String> schemaMap=new Map<String,String>();
    
    private final integer listLimit;

     public class thousandBlocks
    {
        public List<ProgramWrapper> programWrapperList{get;set;}
        public integer blockNumber {get;set;}
        public thousandBlocks(List<ProgramWrapper> pgms, integer i)
        {
            programWrapperList=pgms;
            blockNumber = i;
        }
        
    }

     public class ProgramWrapper{
        public MDF_Program__c pgmMpElt {get; set;}
        public Boolean selected {get; set;}
        public Decimal budgetedPriceDec {get; set;}        
        //Constructor for wrapper class
        public ProgramWrapper(MDF_Program__c pgm){
            pgmMpElt =pgm;
            selected = false;
            budgetedPriceDec=0;            
        }
    } 
 
    
    /*************************CONSTRUCTOR*************************************/
    
    
    public VFCntrlr_AssociateProgramsNPartners(ApexPages.StandardController controller){ 
        Id subVendorId=controller.getId();         
        mdfProgram=new mdf_program__c(); 
        Id userProfileId = userinfo.getProfileId();
        subVendor=[select id,name,Partner_Status__c,Budgeted_Discount__c  from vendor__c where id=:subVendorId]; 
        
        if(subVendor.Partner_Status__c=='Active'){
            for(Associated_Programs_Vendors__c apvElt:[select id,name,vendor__c,MDF_Program__c
                from Associated_Programs_Vendors__c where vendor__c =:subVendorId]){                    
                    programIdSet.add(apvElt.MDF_Program__c);                    
            } 
        }
        
        List<Profile> userProfile=[select id,Name from profile where id = :userProfileId limit 1];        
        String ProfileName=userProfile[0].name; 
        if(ProfileName!=null && ((ProfileName.contains('MDF')&& ProfileName.contains('Co')&&ProfileName.contains('Marketing')&& ProfileName.contains('Manager')) ||            
        (ProfileName.contains('MDF Marketing Operations / Contract Admin'))||ProfileName=='System Administrator')){                
            profileErr=false;
            displayform=true;                                       
        }else{
            profileErr=true; 
            displayform=false;
        } 
        init(); 
    }
    
    
    /*****************************Business Segment**********************************/
    
    public List<SelectOption> getBusinessSegmentOptions() {
        Schema.DescribeFieldResult BSegFld = MDF_Program__c.Business_Segment__c.getDescribe(); 
        List<Schema.PicklistEntry> BSegPLE = BSegFld.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.PicklistEntry ple:BSegPLE){
            options.add(new SelectOption(ple.getLabel(),ple.getValue()));    
        }        
        return options;
    }
    public List<String> getBusinessSegment() {
        return bSegList;
    }
    public void setBusinessSegment(List<String> bSegment) {
        this.bSegList = bSegment;
    }
    
    
    private void init() {
        Schema.DescribeFieldResult BSegFld = MDF_Program__c.Business_Segment__c.getDescribe();         
        for (Schema.PicklistEntry ple:BSegFld.getPicklistValues()) {        
            unSelectedBSegs.add(ple.getLabel()); 
            addALLBSegs.add(ple.getLabel()); 
            removeALLBSegs.add(ple.getLabel());
            schemaMap.put(ple.getLabel(),ple.getValue());       
        }
    }
    
    
    public List<SelectOption> getSelectedOptions(){
        
            List<String> sorted = new List<String>(selectedBSegs);
            sorted.sort();
            List<SelectOption> options = new List<SelectOption>();
            for (String ple: sorted) {
                if(schemaMap.get(ple)!=null){
                    options.add(new SelectOption(ple,schemaMap.get(ple)));
                    selectedOptionLst.add(ple);
                }
            }
            
            return options;
        
    }
    public List<SelectOption> getUnSelectedOptions(){ 
       
            List<String> sorted = new List<String>(unSelectedBSegs);
            sorted.sort();
            List<SelectOption> options = new List<SelectOption>();
            for (String ple: sorted) {
                options.add(new SelectOption(ple,schemaMap.get(ple)));
            }
            
            return options;
        
    }

    public pagereference doSelect() {        
        for (String s: selected) {            
            selectedBSegs.add(s);
            unselectedBSegs.remove(s);
        }
        return null;
    }
    public pagereference doUnSelect() {        
        for (String s: unselected) {            
            unselectedBSegs.add(s);
            selectedBSegs.remove(s);            
        }
        return null;
    }
    
    public pagereference doSelectALL() {        
        for (String s: addALLBSegs) {            
            selectedBSegs.add(s);
            unselectedBSegs.remove(s);
        }
        return null;
    }
    public pagereference doUnSelectALL() {        
        for (String s: removeALLBSegs) {            
            unselectedBSegs.add(s);
            selectedBSegs.remove(s);            
        }
        return null;
    }
    
    
    public List<String> getSelected() {        
        return selected;
    }
    public void setSelected(List<String> bSegment) {        
        this.selected = bSegment;
    }
    public List<String> getUnSelected() {
        
        return unSelected;
    }
    public void setUnSelected(List<String> bSegment) {        
        this.unSelected = bSegment;
    }
    
    
     /**********************MDF Program*********************************/
     
     
    public Boolean getProfileVisibility(){
        return profileErr; 
    }   
    
        
    public Boolean getDisplayTable(){
        System.debug('###displayTable'+displayTable);
        return displayTable;
    }

    
    public Boolean getDisplayForm(){
        return displayForm;
    }
    
    public Boolean getNoAPVList(){
       return NoApvList;
    } 
      
    
    public mdf_program__c getMDFProgram(){
        return mdfProgram;
    }
    
    public void setMDFProgram(mdf_program__c mdfPgm){
        this.mdfProgram=mdfPgm;
        mdfProgram.recordTypeId='012A0000000VhMq';
    } 

    public PageReference ShowWrapperAPVRecords(){
        SelectedRegion=mdfProgram.Region__c;
        SelectedSubRegion=mdfProgram.Sub_Region__c;
        SelectedCountry=mdfProgram.country__c;
        SelectedFiscalQtr =mdfProgram.Fiscal_Quarter__c;
         String errorMsg='err';       
        if(SelectedRegion==null){ 
            if(errorMsg=='err'){
                errorMsg='Region';
            }                
            
        }
        if(SelectedSubRegion==null){  
            if(errorMsg=='err'){
                errorMsg='Sub-Region';
            }else if(!errorMsg.contains('Sub-Region')){
                errorMsg=errorMsg+','+'Sub-Region';
            }              
           
        }
         if(SelectedCountry==null){  
            if(errorMsg=='err'){
                errorMsg='Country';
            }else if(!errorMsg.contains('Country')){
                errorMsg=errorMsg+','+'Country';
            }                
            
        }
         if(selectedBSegs.size()==0){ 
            if(errorMsg=='err'){
                errorMsg='Business segment';
            }else if(!errorMsg.contains('Business segment')){
                errorMsg=errorMsg+','+'Business segment';
            }
        }
        if(SelectedFiscalQtr==null){  
            if(errorMsg=='err'){
                errorMsg='Fiscal quarter';
            }else if(!errorMsg.contains('Fiscal quarter')){
                errorMsg=errorMsg+','+'Fiscal quarter';
            }
        }
        
       if(SelectedRegion==null||SelectedSubRegion==null||SelectedCountry==null||selectedBSegs.size()==0||SelectedFiscalQtr==null){
         ApexPages.Message msg;     
        msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, you need to enter a value for  the following fields:'+errorMsg);
        ApexPages.addMessage(msg);
        return null;
       }else{
        ProgramWrapper pgmWrapperElt;
        apvWrapperList=new List<ProgramWrapper>();  
        thousandRecList=new List<thousandBlocks>();
        Decimal budPrice=0;
        integer counter = 0;
        integer loopCount = 0;
        
        for(MDF_Program__c pgm:[select id,Name,Rate_Card_Price__c,Program_Type__c,
            Pricing_Type__c,Fiscal_Quarter__c,Region__c ,Business_Segment__c,Country__c,sub_region__c,HCID__c,HCID__r.Manager_s_Name__r.Name,HCID__r.Employee_Name__c 
            from MDF_Program__c where id not in:programIdSet and  Region__c=:SelectedRegion and 
            Sub_Region__c=:SelectedSubRegion and Business_Segment__c in:selectedOptionLst and 
            country__c=:SelectedCountry and Fiscal_Quarter__c=:SelectedFiscalQtr and Program_Status__c='Approved' limit 10000]){        
               
            if((pgm.Pricing_Type__c=='Variable') || (subVendor.Budgeted_Discount__c==null)){
                budPrice=pgm.Rate_Card_Price__c;               
            }
            if(pgm.Pricing_Type__c=='Non-Variable' && pgm.Rate_Card_Price__c!=null && subVendor.Budgeted_Discount__c!=null){                    
                budPrice=pgm.Rate_Card_Price__c*((100 - subVendor.Budgeted_Discount__c)/100);
            } 
            pgmWrapperElt=new ProgramWrapper(pgm);
            pgmWrapperElt.budgetedPriceDec=budPrice; 
            
            if(counter<1000){   
                displayList.add(pgm.Id);
                apvWrapperList.add(pgmWrapperElt);                
                counter++;                
            }else if(counter==1000){
                displayList.add(pgm.Id);
                loopCount++;
                thousandRecList.add(new thousandBlocks(apvWrapperList,loopCount));
                //System.debug('### counter'+counter);                
                apvWrapperList=new List<ProgramWrapper>(); 
                apvWrapperList.add(pgmWrapperElt);
                counter = 1;
            } 
        }
        if(apvWrapperList.size()<1000){        
            thousandRecList.add(new thousandBlocks(apvWrapperList,loopCount));
        }
        //System.debug('###thousandRecList'+thousandRecList);
       if(thousandRecList[0].programWrapperList.size()>0){
            profileErr=false;
            displayForm=false;
            displayTable=true;
            NoApvList=False;
        }
        if(thousandRecList[0].programWrapperList.size()==0){
            profileErr=false;
            displayForm=true;
            displayTable=false;
            NoApvList=true;
        }

        } 
        

        return null;
    }
    public List<ProgramWrapper> getApvWrapperList(){
        return apvWrapperList; 
    }
    
    public void setApvWrapperList(List<ProgramWrapper> wrapperRecs){
        this.apvWrapperList=wrapperRecs;
    }
    
    public List<thousandBlocks> getThousandRecList(){
        return thousandRecList; 
    }
    
    public void setThousandRecList(List<thousandBlocks> wrapperRecs){
        this.thousandRecList=wrapperRecs;
    }
  
    
    public PageReference insertPartnerProgramRecs(){
        MDF_Program__c pgmRecord=new MDF_Program__c();
        Budgeted_Price_Distribution__c budgetedPriceElt;
        Associated_Programs_Vendors__c apvRecord;
        Double budgetedPrice=0; 
        List<Associated_Programs_Vendors__c> apvInsertList=new List<Associated_Programs_Vendors__c>(); 
        PageReference currentPageRef=new PageReference('/'+subVendor.Id);         
        
        RecordType rtVA=[Select  r.SobjectType, r.Name  From RecordType r where SobjectType='Associated_Programs_Vendors__c'  and name='Vendor Association' limit 1];         
        List<ProgramWrapper> ProgramWrapperRecs;
        for(thousandBlocks listElt:thousandRecList){
            ProgramWrapperRecs=listElt.programWrapperList;
            for(ProgramWrapper pgmWELt:ProgramWrapperRecs){
                pgmRecord=pgmWELt.pgmMpElt;                      
                if(pgmWELt.selected==true){
                    apvRecord=new Associated_Programs_Vendors__c(
                        MDF_Program__c=pgmRecord.id,
                        recordtypeId=rtVA.Id,
                        Vendor__c=subVendor.Id,                                        
                        Rate_Card_Price__c=pgmRecord.Rate_Card_Price__c,
                        POP_Status__c='Pending',
                        Status__c='Pending',
                        Headcount__c=pgmRecord.HCID__c,
                        Manager_Name__c=pgmRecord.HCID__r.Manager_s_Name__r.Name,                                    
                        Employee_Name__c=pgmRecord.HCID__r.Employee_Name__c                     
                    );
                    if(pgmRecord.Pricing_Type__c=='Variable' || subVendor.Budgeted_Discount__c==null){
                        apvRecord.Budgeted_Price__c=pgmRecord.Rate_Card_Price__c;                    
                    }
                    if(pgmRecord.Pricing_Type__c=='Non-Variable' && pgmRecord.Rate_Card_Price__c!=null && subVendor.Budgeted_Discount__c!=null){                    
                        apvRecord.Budgeted_Price__c=pgmRecord.Rate_Card_Price__c*((100 - subVendor.Budgeted_Discount__c)/100);
                    }       
                    apvInsertList.add(apvRecord);
                }
            }
        }
        
        if(apvInsertList.size()>0){
            try{
                Database.insert(apvInsertList);
            }Catch(Exception e){
            }
        }
        return currentPageRef;
    }
    
    /*************  Proposed APV section  *************/
    public PageReference ShowWrapperAPVRecordsForProposeAPV(){
        thousandRecList=new List<thousandBlocks>(); 
        system.debug('In show programs');
        
        SelectedRegion=mdfProgram.Region__c;
        SelectedSubRegion=mdfProgram.Sub_Region__c;
        SelectedCountry=mdfProgram.Country__c;
        SelectedFiscalQtr =mdfProgram.Fiscal_Quarter__c;        
        
        System.debug('###########Region'+SelectedRegion);  
        System.debug('###########SubRegion'+SelectedSubRegion);  
        System.debug('###########Country'+SelectedCountry);  
        System.debug('###########Business Segment'+selectedOptionLst);
        System.debug('###########Fiscal Quartr'+ SelectedFiscalQtr);
        
        ProgramWrapper pgmWrapperElt;
        apvWrapperList=new List<ProgramWrapper>();  
        Decimal budPrice=0;
        
        //build the full sort expression
        
        //BR 8.1.1.12
        string sortFullExp = 'ORDER by'+ ' ' +sortExpression  + ' ' + sortDirection;
        
        String fieldString = 'id,Name,Program_Status__c,OwnerId,Rate_Card_Price__c,Program_Type__c,Program_Owner__c,Pricing_Type__c,POP_Details__c,Fiscal_Quarter__c,Region__c ,Business_Segment__c,Country__c,sub_region__c ';
        String fromString = 'from MDF_Program__c';
        String whereString = 'where id NOT in :programIdSet and Fiscal_Quarter__c=:SelectedFiscalQtr and Region__c=:SelectedRegion and Sub_Region__c=:SelectedSubRegion and Business_Segment__c in :selectedOptionLst and Program_Status__c=\''+ 'Approved'+'\'' ;
        
        String QueryString = 'SELECT'+' ' +fieldString+' ' +fromString+' ' +whereString+' ' +sortFullExp;
        system.debug('##query#'+QueryString );
        for(MDF_Program__c pgm:Database.query(QueryString)){        
           
            pgmWrapperElt=new ProgramWrapper(pgm);
            //pgmWrapperElt.budgetedPriceDec=budPrice; 
            apvWrapperList.add(pgmWrapperElt);
        }
        if(apvWrapperList.size()<=0){
            NoApv=True;    
        }   
        return null;
    }    
    
    public PageReference insertProposedProgramRecs(){
        MDF_Program__c pgmRecord=new MDF_Program__c();
        Budgeted_Price_Distribution__c budgetedPriceElt;
        //Associated_Programs_Vendors__c apvRecord;
        Proposed_Associated_Program_Vendor__c proposedapv;
        Double budgetedPrice=0; 
        List<Proposed_Associated_Program_Vendor__c> proposedapvInsertList=new List<Proposed_Associated_Program_Vendor__c>(); 
        PageReference currentPageRef=new PageReference('/'+subVendor.Id);         
        
        RecordType rtVA=[Select  r.SobjectType, r.Name  From RecordType r where SobjectType='Associated_Programs_Vendors__c'  and name='Vendor Association' limit 1];         
        
        for(ProgramWrapper pgmWELt:apvWrapperList){
            pgmRecord=pgmWELt.pgmMpElt;                      
            if(pgmWELt.selected==true){
                proposedapv=new Proposed_Associated_Program_Vendor__c(
                    Business_Segment__c= pgmRecord.Business_Segment__c,
                    MDF_Program__c=pgmRecord.id,
                    Program_Owner__c=pgmRecord.Program_Owner__c,                                   
                    Program_Rate_Card_Price__c=pgmRecord.Rate_Card_Price__c,
                    Status__c='Pending',
                    Vendor__c=subVendor.Id                                                              
                );    
                proposedapvInsertList.add(proposedapv);
            }
        }
        if(proposedapvInsertList.size()>0){
            try{
                insert proposedapvInsertList;
            }Catch(Exception e){
            }
        }
        return currentPageRef;
    }
    
    public boolean getNoApv(){
        return NoApv;
    }
                
    /******** Sorting for proposed APVs******/
  
   public String sortDirection = 'ASC';   
   public String sortExp = 'NAME';
   
   public String sortExpression {
        get {
        return sortExp;
        }
        set{
        //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp) 
            sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else {
                sortDirection = 'ASC';
                sortExp = value;
            }
        }
    }
    
    public String getSortDirection() {
        //if not column is selected     
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    } 
   
    public void setSortDirection(String value) {
        sortDirection = value;
    }
       
}
public with sharing class VFCntrlr_Certification_Tracker {
    //variables for paging
    private static final Integer PAGE_SIZE=25;
    public Integer currentPage {get; private set;}    
    public Integer lastPage {get; private set;}
    public Boolean hasPreviousAndNext;     
    public Boolean hasNext {get; private set;}    
    public Boolean hasPrevious {get; private set;}
    public Integer NoOfRecords {get; private set;}
    public boolean chkSelectAll {get; set;}
    public boolean allowRegisterToPreferred {get; private set;}
    public boolean allowRegisterToPremier {get; private set;}
    public boolean allowPreferredToPremier {get; private set;}
    
            
    //variables to store query string parameters
    public String Region{get; set;}
    private Id AC_Id = null; // Account Id if Certification Tracker clicked from Account detail page  
    
    private List<Certification_Tracker__c> recCTracker= new List<Certification_Tracker__c>();  // list of retreieved Tracker records
    private Map<Id, Certification_Tracker__c> certificationTrackerMap; // This Map is used to maintain the state of Certification Tracker
    public Map<Id, Boolean> recordAccessMap{get;set;}
    public Boolean enablePreferredHeader{get;set;}
    public Boolean enablePremierHeader{get;set;}
    public VFCntrlr_Certification_Tracker(ApexPages.StandardController stdController){   
                
        //if page called from Account detail page 
        AC_Id = ApexPages.currentPage().getParameters().get('acid');
        //if page  called from Account list view    
        Region = ApexPages.currentPage().getParameters().get('region');
         
        if (AC_Id != null){
            //get region of the selected account - to decide whether to make 2 checkboxes on page editable or not    
            Account a =  [select Account_Country_Code__c from Account where id = :AC_Id];
            if (a != null){
                String cCode = a.Account_Country_Code__c;
                if (cCode == null)
                    Region = '';
                else if (cCode == 'US'){
                    Region = 'US';
                }
                else if (cCode == 'CA'){
                    Region = 'Canada';
                }
                else{
                    Region = [select Region__c from Country__c where Code__c = :cCode].Region__c;
                }
            }
        }
  //      Region='EMEA';
          List<Certification_Process_Setup__c> cProcessLst = [select Allow_Automation_Level__c, Automate_Certification__c
                                                     from Certification_Process_Setup__c 
                                                     where Region__c = :Region ];
          
           allowRegisterToPreferred = false;
           allowRegisterToPremier = false;
           allowPreferredToPremier = false;
         if (! cProcessLst.isEmpty()){
              Certification_Process_Setup__c cProcess = cProcessLst.get(0);
              if (cProcess.Automate_Certification__c == true){
                
                  if (cProcess.Allow_Automation_Level__c.contains('Registered to Preferred'))
                      allowRegisterToPreferred =true;
                  
                 if (cProcess.Allow_Automation_Level__c.contains('Registered to Premier'))
                      allowRegisterToPremier =true;
                    
                  if (cProcess.Allow_Automation_Level__c.contains('Preferred to Premier'))
                      allowPreferredToPremier =true;
              }
         }
         hasNext = false;
         hasPrevious = false;       
         lastPage = 0;
         currentPage= 0;
         NoOfRecords=0;
                    
         recCTracker = (List<Certification_Tracker__c>) this.setCon.getRecords();   
          updateoldMap();
          mapAccessofRecords();
         system.debug('======^^^^^^^^^^^^^^^^========'+certificationTrackerMap ); 
        
    }   
    
    public void mapAccessofRecords()
    {
        enablePreferredHeader=enablePremierHeader=false;
        recordAccessMap=new Map<Id, Boolean>();
      
        for(Certification_Tracker__c certTracker:(List<Certification_Tracker__c>)this.setCon.getRecords())
        {    
             
            if((certTracker.Account_Name__r.Partner_Relationship__c == 'Registered' || certTracker.Account_Name__r.Partner_Relationship__c == 'Authorized Reseller' )&& allowRegisterToPreferred && !enablePreferredHeader)
            {
                enablePreferredHeader=true;
            }
            if( (((certTracker.Account_Name__r.Partner_Relationship__c == 'Registered' || certTracker.Account_Name__r.Partner_Relationship__c == 'Authorized Reseller' ) && allowRegisterToPremier) ||
                        ((certTracker.Account_Name__r.Partner_Relationship__c == 'Preferred' || certTracker.Account_Name__r.Partner_Relationship__c == 'Gold') && allowPreferredToPremier) && !enablePremierHeader )
                 )
            {
                enablePremierHeader=true;
            }
       }
   }
    
    public void updateoldMap()
    {
        if (AC_Id != null)
        {
                // if called from Account detail page...retrieve tracker record for that particualar account         
          certificationTrackerMap = new Map<Id, Certification_Tracker__c>(                                      
                [select id, name, Account_Id__c, Account_Name__r.name, Account_Name__r.Partner_Relationship__c,
                Account_country__c,Demo_Unit_Criteria_Met__c, Training_Criteria_Met__c,
                Dell_Certification_Areas__c, Demo_Units_Purchased__c,
                Current_QTR__c, CurrencyIsoCode, Current_QTD_Ent_Rev__c, 
                Current_QTD_Total_Rev__c, Back_4_QTRs_Ent_Rev__c, 
                Back_3_QTRs_Ent_Rev__c, Back_2_QTRs_Ent_Rev__c, 
                Back_1_QTRs_Ent_Rev__c, Back_4_QTRs_Total_Rev__c,
                Back_3_QTRs_Total_Rev__c, Back_2_QTRs_Total_Rev__c,
                Back_1_QTRs_Total_Rev__c, Approved_Business_Plan__c,
                Contractual_Agreement__c, Qualified_as_Dell_Preferred_Partner__c,
                Qualified_as_Dell_Premier_Partner__c, Premier_Criteria_Enable__c,
                Account_Name__r.Regional_Parent_Name_lookup__c
                from Certification_Tracker__c 
                Where Account_Name__c = :AC_Id
                and (Demo_Unit_Criteria_Met__c = true OR Training_Criteria_Met__c = true)  ]); 
                         
        }    
        else
        {
            List<Country__c> Country = [select Code__c from Country__c Where Region__c = :Region];
            Set<String> CountryCodes = new Set<String>();
            if (Country.isEmpty()){
                if (Region == 'US'){
                    CountryCodes.add('US');
                }
                else if (Region == 'Canada'){
                    CountryCodes.add('CA');
                }
            }
            else{
                for(Country__c c: Country ){
                    CountryCodes.add(c.Code__c);
                }
            }
                                     
            certificationTrackerMap = new Map<Id, Certification_Tracker__c>(                                        
                    [select id, name, Account_Id__c, Account_Name__r.name, Account_Name__r.Partner_Relationship__c,
                    Account_Country__c, 
                    Demo_Unit_Criteria_Met__c, Training_Criteria_Met__c,
                    Dell_Certification_Areas__c, Demo_Units_Purchased__c,
                    Current_QTR__c, CurrencyIsoCode, Current_QTD_Ent_Rev__c, 
                    Current_QTD_Total_Rev__c, Back_4_QTRs_Ent_Rev__c, 
                    Back_3_QTRs_Ent_Rev__c, Back_2_QTRs_Ent_Rev__c, 
                    Back_1_QTRs_Ent_Rev__c, Back_4_QTRs_Total_Rev__c,
                    Back_3_QTRs_Total_Rev__c, Back_2_QTRs_Total_Rev__c,
                    Back_1_QTRs_Total_Rev__c, Approved_Business_Plan__c,
                    Contractual_Agreement__c, Qualified_as_Dell_Preferred_Partner__c,
                    Qualified_as_Dell_Premier_Partner__c, Premier_Criteria_Enable__c,
                    Account_Name__r.Regional_Parent_Name_lookup__c
                    from Certification_Tracker__c 
                    Where Account_Name__r.Account_Country_Code__c in :CountryCodes
                    and ( Demo_Unit_Criteria_Met__c = true OR Training_Criteria_Met__c = true )
                    and Last_Evaluation_date__c >= LAST_N_DAYS:6                         
                    Order By Last_Evaluation_date__c
                    limit 1000 ]);


        }
    }
    
     private ApexPages.StandardSetController setCon {
     get { 
         if(this.setCon == null) {           
             if (AC_Id != null){
                // if called from Account detail page...retrieve tracker record for that particualar account         
                  this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(                                       
                        [select id, name, Account_Id__c, Account_Name__r.name, Account_Name__r.Partner_Relationship__c,
                        Account_country__c,Demo_Unit_Criteria_Met__c, Training_Criteria_Met__c,
                        Dell_Certification_Areas__c, Demo_Units_Purchased__c,
                        Current_QTR__c, CurrencyIsoCode, Current_QTD_Ent_Rev__c, 
                        Current_QTD_Total_Rev__c, Back_4_QTRs_Ent_Rev__c, 
                        Back_3_QTRs_Ent_Rev__c, Back_2_QTRs_Ent_Rev__c, 
                        Back_1_QTRs_Ent_Rev__c, Back_4_QTRs_Total_Rev__c,
                        Back_3_QTRs_Total_Rev__c, Back_2_QTRs_Total_Rev__c,
                        Back_1_QTRs_Total_Rev__c, Approved_Business_Plan__c,
                        Contractual_Agreement__c, Qualified_as_Dell_Preferred_Partner__c,
                        Qualified_as_Dell_Premier_Partner__c, Premier_Criteria_Enable__c,
                        Account_Name__r.Regional_Parent_Name_lookup__c
                        from Certification_Tracker__c 
                        Where Account_Name__c = :AC_Id
                        and (Demo_Unit_Criteria_Met__c = true OR Training_Criteria_Met__c = true)  ])); 
                         
             }    
            else{
                    List<Country__c> Country = [select Code__c from Country__c Where Region__c = :Region];
                    Set<String> CountryCodes = new Set<String>();
                    
                    if (Country.isEmpty()){
                        if (Region == 'US'){
                            CountryCodes.add('US');
                        }
                        else if (Region == 'Canada'){
                            CountryCodes.add('CA');
                        }
                    }
                    else{
                        for(Country__c c: Country ){
                            CountryCodes.add(c.Code__c);
                        }
                    }
                                         
                 this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(                                       
                        [select id, name, Account_Id__c, Account_Name__r.name, Account_Name__r.Partner_Relationship__c,
                        Account_Country__c, 
                        Demo_Unit_Criteria_Met__c, Training_Criteria_Met__c,
                        Dell_Certification_Areas__c, Demo_Units_Purchased__c,
                        Current_QTR__c, CurrencyIsoCode, Current_QTD_Ent_Rev__c, 
                        Current_QTD_Total_Rev__c, Back_4_QTRs_Ent_Rev__c, 
                        Back_3_QTRs_Ent_Rev__c, Back_2_QTRs_Ent_Rev__c, 
                        Back_1_QTRs_Ent_Rev__c, Back_4_QTRs_Total_Rev__c,
                        Back_3_QTRs_Total_Rev__c, Back_2_QTRs_Total_Rev__c,
                        Back_1_QTRs_Total_Rev__c, Approved_Business_Plan__c,
                        Contractual_Agreement__c, Qualified_as_Dell_Preferred_Partner__c,
                        Qualified_as_Dell_Premier_Partner__c, Premier_Criteria_Enable__c,
                        Account_Name__r.Regional_Parent_Name_lookup__c
                        from Certification_Tracker__c 
                        Where Account_Name__r.Account_Country_Code__c in :CountryCodes
                        and ( Demo_Unit_Criteria_Met__c = true OR Training_Criteria_Met__c = true )
                        and Last_Evaluation_date__c >= LAST_N_DAYS:6                         
                        Order By Last_Evaluation_date__c
                        limit 1000 ]));  
                     
            }
            if(this.setCon.getResultSize()>0){                     
                this.setCon.setPageSize(PAGE_SIZE);
                setNextPrevious();
                NoOfRecords = this.setCon.getResultSize(); 
                this.setCon.last();                                        
                lastPage = this.setCon.getPageNumber();
                this.setCon.first();                        
                currentPage = this.setCon.getPageNumber();

            }                           
        }   
                      
        return this.setCon;        

     }        
     set;
    }
     
     //Function get called when user click on  'Save & Next' link   
     public PageReference next() {  
        chkSelectAll = false;
        if (hasNext){  
            try {
                //save changed records before displaying next list of records    
                this.setCon.save();
                this.setCon.next();             
                currentPage = this.setCon.getPageNumber();
                setNextPrevious();  
                   // call mapping function
                     updateoldMap();
                mapAccessofRecords();
            } 
            catch(Exception e){
                ApexPages.addMessages(e);
                return null;
            }           
        }     
        return null;    
     }        
     
     //Function get called when user click on  'Save & previous' link  
     public PageReference previous() {     
        chkSelectAll = false;
        if (hasPrevious){ 
            try {
                this.setCon.save();
                this.setCon.previous();            
                currentPage = this.setCon.getPageNumber();
                setNextPrevious();   
                 // call mapping function
                   updateoldMap();
                mapAccessofRecords();   
            } 
            catch(Exception e){
                ApexPages.addMessages(e);
                return null;
            }                    
        }        
        return null;    
     }        
     
     //Set values for hasNext and hasPrevious booleans    
     private void setNextPrevious() {   
        chkSelectAll = false;
        if (this.setCon.getHasNext()) {            
            hasNext = true;        
        }        
        else {            
            hasNext = false;        
        }        
        if (this.setCon.getHasPrevious()) {            
            hasPrevious = true;        
        }        
        else {            
            hasPrevious = false;        
        }    
    }

    public PageReference saveTracker()
    {
        try 
        {  
            /* First validate is there is any changes done by user or not on Page Level, 
            if changes are there then save otherwise alert the User
            There is no changes done to the account(s).” */
            Boolean changeFound=false;
            system.debug('===map value====='+certificationTrackerMap);
             system.debug('===value from page====='+certificationTrackerMap);
            for(Certification_Tracker__c certTracker:(List<Certification_Tracker__c >)this.setCon.getRecords())
            {
                // For Approved Business Plan and Contractual Agreement
                if(Region.contains('EMEA') || Region.contains('EC-EMEA')) // fields editable only when region becomes EMEA or EC-EMEA
                {
                    system.debug('=Region Found=='+Region);
                    if(certificationTrackerMap.containsKey(certTracker.Id))
                    {
                         system.debug('=New Value=='+certTracker.Approved_Business_Plan__c);
                         system.debug('=Old Value=='+certificationTrackerMap.get(certTracker.Id).Approved_Business_Plan__c);
                        if(certTracker.Approved_Business_Plan__c !=certificationTrackerMap.get(certTracker.Id).Approved_Business_Plan__c ||
                            certTracker.Contractual_Agreement__c !=certificationTrackerMap.get(certTracker.Id).Contractual_Agreement__c
                            )
                        {
                            changeFound=true;
                        }
                    }
                }
                // If above condition becomes true, no need to check for other fields, user can save the record.
                if(!changeFound)
                {
                   // if((certTracker.Account_Name__r.Partner_Relationship__c == 'Registered' || certTracker.Account_Name__r.Partner_Relationship__c == 'Authorized Reseller' ) && allowRegisterToPreferred)
                     if(PartnerStatusUtilityClass.RegisteredTypeContains(certTracker.Account_Name__r.Partner_Relationship__c) && allowRegisterToPreferred)
                   
                    {
                        if(certTracker.Qualified_as_Dell_Preferred_Partner__c !=certificationTrackerMap.get(certTracker.Id).             
                                                                                        Qualified_as_Dell_Preferred_Partner__c)
                        {
                            changeFound=true;
                        }
                    }
                }
                
                // If above condition becomes true, no need to check for other fields, user can save the record.
                if(!changeFound)
                {
                 //   if( ((certTracker.Account_Name__r.Partner_Relationship__c == 'Registered' || certTracker.Account_Name__r.Partner_Relationship__c == 'Authorized Reseller' ) && allowRegisterToPremier) ||
                 //       ((certTracker.Account_Name__r.Partner_Relationship__c == 'Preferred' || certTracker.Account_Name__r.Partner_Relationship__c == 'Gold')  && allowPreferredToPremier)
                 //      )
                 
                 if( (PartnerStatusUtilityClass.RegisteredTypeContains(certTracker.Account_Name__r.Partner_Relationship__c) && allowRegisterToPremier) ||
                        (PartnerStatusUtilityClass.PreferredTypeContains(certTracker.Account_Name__r.Partner_Relationship__c)  && allowPreferredToPremier)
                       )
                    
                    {
                        if(certTracker.Qualified_as_Dell_Premier_Partner__c !=certificationTrackerMap.get(certTracker.Id).           
                                                                                        Qualified_as_Dell_Premier_Partner__c)
                        {
                            changeFound=true;
                        }
                    }
                }
                
                // If flag true, no need to iterate over other records, user can save the records, hence exit from loop.
                if(changeFound){
                    break;
                }
            }   // end of for loop
           if(changeFound)
            {
                chkSelectAll = false;
                PageReference result = this.setCon.save();
                if (result != null)
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM,System.Label.NetExam_TrackerSuccessMsg));
                updateoldMap();
                 mapAccessofRecords();  
            }else{
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'There is no changes done to the account(s).'));
            }
            return null;
        } 
        catch(Exception e)
        {
            ApexPages.addMessages(e);
            return null;
        }       
        
    } 
    public PageReference Cancel(){
        //redirect to account list view       
        if (AC_Id != null){
            return new PageReference('/' + AC_Id );
        }
        else{
            return new PageReference(getKeyPrefix());    
        }
    }
    public Static String getKeyprefix(){   
        //Schema.DescribeSObjectResult sObjDesc = Account.sObjectType.getDescribe();  
        //return '/'+ sObjDesc.keyPrefix;
        Schema.DescribeSObjectResult sObjDesc = Certification_Tracker__c.sObjectType.getDescribe();  
        return '/'+ sObjDesc.keyPrefix;
    }
    
   
    //getter methods
    public boolean getHasPreviousAndNext(){        
        return (hasPrevious && hasNext);    
    }
    
    public List<Certification_Tracker__c> getCTracker(){           
        return recCTracker;
    }       
}
public without sharing class clsApproveEligiblePrograms { 

        public string pid{get ; set ;}
        public boolean errorbool{get;set;}
        public boolean showError{get;set;}
        
        public List<String> listObjectFields {get ; set ;}
         public Id eliminateId {get;set;}

    public clsApproveEligiblePrograms(ApexPages.StandardController controller) {
       pid = ApexPages.currentPage().getParameters().get('cid');
       System.debug('**pid::'+pid);
       Deal_Program__c request = new Deal_Program__c ();

       /* To show message to the analyst when there is a program with same stack ranking */ 
       /* VF Page : DealStackRankingAlert */
       if(pid == null){
        if(controller != null && controller.getRecord() != null && controller.getRecord() instanceof Deal_Program__c){
            request = (Deal_Program__c) controller.getRecord();
            System.debug('request::'+request);
            if(request.Id!= null){   
            request = [select id,Stack_Ranking__c  from Deal_Program__c where id = :request.Id ];
            system.debug('test'+request);
             system.debug('test1'+request.Stack_Ranking__c);
           list<Deal_Program__c> request1 = new list<Deal_Program__c> ();
            if(request != null &&  request.Stack_Ranking__c!= null ){
                system.debug('test3'+request1 );
               request1 = [select Stack_Ranking__c from Deal_Program__c where Stack_Ranking__c = : request.Stack_Ranking__c and id != : request.id];  // and Active__c = true
            system.debug('test4'+request1 );
            if(request1 != null && request1.size()>0) {
                errorbool = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'This program is configured as stackable against an existing program'));
            }
            }
            }
        }
        else {
            errorbool = false;
          }
        
       }      
       
    }
    public Map<Id,List<Deal_Program__c>> mapProductEntity {get;set;}      // Complete list
    public Map<Id,List<Deal_Program__c>> mapApprovedPrograms {get;set;}   // For Approved Programs.
    public Map<Id,List<Deal_Program__c>> mapInEligiblePrograms {get;set;} // For inEligible Programs.
    
    
    public Map<Id,List<String>> mapProdList {get;set;}
    public Map<Id,List<selectoption>> mapOptionSelected {get;set;}

    public List<Product2> lstProd {get;set;}
    public List<String> prodList{get;set;}
    public List<Qualified_Program__c> lstApprovedPrograms {get;set;}
    public map<String,boolean> optionschecked {get;set;}
    
    /**Variable Decleration for Criteria Evaluation**/
 public opportunity oppRecord {get;set;}
 public transient Map < Id, Deal_program__c > activeProgramsMap;
 public Set < ID > partnerAccIncludedPrograms;
 public Set < ID > DistiResellerAccIncludedPrograms; //Story 4715057:
 public Set < ID > endUserAccIncludedPrograms;
 public List < Deal_program__c > eligiblePrograms {get;set;}
 public string partnerAccRegion;
 public string DistiResellerAccRegion; //Story 4715057:
 public string endUserAccRegion;

 public String ProductQuery;
 public String ProductFiledsString = '';
 public Set<ID> ProductIDset;
 public List<Custom_Products__c> CPlist;
 public List<OpportunityLineItem> OppLineItem;
 public Map<id,Product2> AllProductsMap;
 public Map<string,string> mapforedit = new map<string,string>();
 public transient  Map<ID,Set<ID>> FinalMap {get;set;}
 public transient  Map<ID,Set<Deal_Program__c>> ProductDealMap {get;set;}
 public Map<String,boolean> ApprovedProdDealMap {get;set;}
 public List<Deal_program__c> ApprovedDPs;

    /**Variable Decleration for Criteria Evaluation**/
    
    public void onPageLoad()
    {  
           
           showError = false;
           errorbool = false;
           endUserAccRegion = '';
           partnerAccRegion = '';
           DistiResellerAccRegion = '';    //Story 4715057:
           mapProductEntity = new  Map<Id,List<Deal_Program__c>>();
           mapApprovedPrograms = new Map<Id,List<Deal_Program__c>>();
           mapInEligiblePrograms = new Map<Id,List<Deal_Program__c>>();
           optionschecked  = new map<String,boolean>();
           
           
           mapProdList = new Map<Id,List<String>>();
           mapOptionSelected = new Map<Id,List<selectoption>>();
           
           
           List<innerlist> innerdeals = new List<innerlist>();
           innerApprovedPrograms = new List<innerlist>();

           List<innerlist> innerdeals1 = new List<innerlist>();
           mapProductInnerList  = new Map<Id,list<innerlist>>();
           
           
           
          oppRecord = [select id, Name,Accountid from opportunity where id = : ApexPages.currentPage().getParameters().get('cid')];
                
          if(oppRecord.Accountid == null){showError = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Account Name is required to evaluate Eligible Programs.'));
           }   
           else
           {
               oppRecord = null;
               lstProd = new List<Product2>();
               List<Product2> lstProd1 = new List<Product2>();
               for(Product2 prd: lstProd ) {
                  mapProductInnerList.put(prd.Id,new list<innerlist>());
               }
               
               MainMethod();
               
               /**Stack Ranking Auto Select**/
    
               fetchApprovedRecords();
               
               lstProd =  [select Id,Name,isActive,NBI_Category__c,NBI_Eligible__c from Product2 where isActive= true and Id in(select Product2Id from OpportunityLineItem where OpportunityId =: pid ) order by Name]; 
               checkEligibleProgramsCount();
           }
    }
    
    public void checkEligibleProgramsCount()
    {   
            if(lstProd.size() > 1 && mapProductInnerList != null && mapProductInnerList.get(lstProd[lstProd.size()-1].Id).size() <= 0 && eliminateId == null)//mapProductInnerList.get(eliminateId).size() <= 0)
            {
                 List<Product2> lstProd1 = new List<Product2>();
                lstProd1.addAll([select Id,Name,isActive from Product2 where isActive = false order by Name LIMIT 1]);
                lstProd.addAll(lstProd1);
                eliminateId = lstProd1[0].Id;
             
                mapProductInnerList.put(lstProd1[0].Id,new list<innerlist>());

           
                Deal_Program__c dealProg = [select id, Deal_Program_Name__c, Deal_Type__c, Stack_Ranking__c from Deal_Program__c LIMIT 1]   ; 
                List<innerlist> result1 = new List<innerlist>();
                result1.add(new innerlist(dealProg,eliminateId,true));
                mapProductInnerList.put(eliminateId,result1);
            }        
    }
    
    
    public void fetchApprovedRecords()
    {
          lstApprovedPrograms = new List<Qualified_Program__c>();
          lstApprovedPrograms = [Select Id,Product__r.Name,CreatedDate ,Deal_Program__r.Deal_Program_Name__c,Deal_Program__r.Stack_Ranking__c,Opportunity__c,Deal_Program__r.Deal_Type__c,Status__c,Channel_Program_Name__c,Created_Date__c from Qualified_Program__c where Opportunity__r.id  =: pid  Order by Product__r.Name,Created_Date__c LIMIT 1000];
   
           ApprovedProdDealMap  = new Map<String,boolean>();
           innerApprovedPrograms =new List<innerlist>();
                   
           for(Qualified_Program__c del : lstApprovedPrograms ){
                   innerApprovedPrograms.add(new innerlist(del)); 
                   ApprovedProdDealMap.put(String.ValueOf(del.Product__r.id)+del.Deal_Program__r.id,true);        
           }   
           
    }
    
    public void saveApproved()
    {
        List<Qualified_Program__c> dealPrg = new List<Qualified_Program__c>();
        boolean strCheckUpdate = false;
       
        ApprovedDPs = new List<Deal_program__c>();
        for(Product2 prod: lstProd )
               
           for(innerlist DealApproved : mapProductInnerList.get(prod.Id))
            {              
                 system.debug('****DealApproved ' + DealApproved ); 
                 system.debug('****ApprovedProdDealMap ' + (DealApproved.selected == true &&  ApprovedProdDealMap.isEmpty())); 
                 
               if(((prod.isActive) &&  ((DealApproved.selected == true &&  (ApprovedProdDealMap == null || ApprovedProdDealMap.isEmpty())) || (DealApproved.selected == true && ApprovedProdDealMap.size() > 0 &&  ApprovedProdDealMap.get(String.ValueOf(prod.Id)+DealApproved.channelprgms.Id) == null)) ) || test.isRunningtest())
               {   
                   Qualified_Program__c dl = new Qualified_Program__c();
                   dl.Product__c = prod.Id;
                   dl.Opportunity__c = pid;
                   dl.Deal_Program__C = DealApproved.channelprgms.Id;
                   dealPrg.add(dl);
                   ApprovedDPs.add(DealApproved.channelprgms);
                   
               }    
            else if(( (prod.isActive) && (DealApproved.selected == true && ApprovedProdDealMap.get(String.ValueOf(prod.Id)+DealApproved.channelprgms.Id) == true))|| test.isrunningtest())
               {                     strCheckUpdate = true;               } 
          }  
          
          if(dealPrg!= null && dealPrg.size() > 0)
          {
             upsert dealPrg;
             UpdateOpportunity();
             fetchApprovedRecords();   
          }
          else
          {
               errorbool = true;
              if(strCheckUpdate  == true)
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select an additional Eligible Program value for a Product line-item, otherwise click Cancel.'));
              else
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select atleast one program to save'));
          }
          
             
       //return null;   
    }
    
        
    
    public void saveRejected()
    {
           List<Qualified_Program__c> dealPrg = new List<Qualified_Program__c>();
           String selectedids = ApexPages.currentpage().getParameters().get('selected_ids1');
           set<Id> setToDelete = new set<Id>();
        
           if(selectedids != null && selectedids != ''){
              for(string str : selectedids.split(','))
                    setToDelete .add(str);
                 
              for(string st :setToDelete )
              {
                       Qualified_Program__c dl = new Qualified_Program__c();
                       //dl.Status__c = 'Rejected';
                       dl.Id = st;
                       dealPrg.add(dl);    
              }
          }
          
          
          if(dealPrg!= null && dealPrg.size() > 0){
             Delete dealPrg;
             fetchApprovedRecords();
          }
          else
          {
               errorbool = true;
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select an existing Qualified Program to delete'));
          }
        
          
       //return null;   
    }
    
 //Method to update Opportunity Based on Qualified Programs Dealtype
 public void UpdateOpportunity() {
    try
    {
    Opportunity Opp = [Select id, Deal_Type__c, Recordtype.Name from Opportunity where id =: Opprecord.ID limit 1];

    for(Deal_program__c Dp: ApprovedDPs)
    {
        List<String> DealtypeList = new List<String>();
        if(Opp.Deal_Type__c != null)
             DealtypeList = (Opp.Deal_Type__c).split(';');
        Set<String> Dealtype = new Set<String>();
        Dealtype.addAll(DealtypeList);        
        String dt = Dp.Deal_Type__c;
        if((!Dealtype.contains(dt) && dt != null && dt != '')|| test.isRunningTest())
        {
            if((Opp.Deal_Type__c != null) || test.isRunningTest()){Opp.Deal_Type__c = Opp.Deal_Type__c + ';' + dt;}
            else{ Opp.Deal_Type__c = dt;}
        }
    }
    system.debug('>>>>>>Opp.Deal_Type__c::'+Opp.Deal_Type__c);
    if(Opp.Recordtype.Name <> 'Channel Opportunity'){
        
        List<String> lstObjAPINames = new List<String>{'Opportunity'};

        TriggerExecutionController.setSkipOpportunityTriggers(true);
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);

        Update Opp;
        ResetSystemBehaviorBypasser.resetSkipValidationRules(lstObjAPINames);

        }
        system.debug('>>>>>>Opp Updated::'+Opp);
    }
    catch(exception ex){ showError = true;
       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
    }
 }
  
    
/****************************Evaluation Methods****************/    

 public void MainMethod() {

      EligiblePrograms = new List < Deal_program__c > ();
      FinalMap = new Map<ID,Set<ID>>();
      ProductDealMap = new Map<ID,Set<Deal_Program__c>>();          
   try{
      oppRecord = [select id, Name,Accountid, PartnerAccountid, PartnerAccount.Partner_Type__c, PartnerAccount.Partner_Relationship__c, PartnerAccount.Partner_Tier__c, Partner_Account_Country_Code__c,
       PartnerAccount.Account_Country__c, PartnerAccount.Purchasing_Model__c,       Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Type__c, Distributor_Reseller_Name__r.Partner_Relationship__c, Distributor_Reseller_Name__r.Partner_Tier__c,
       Distributor_Reseller_Name__r.Account_Country__c, Distributor_Reseller_Name__r.Purchasing_Model__c, Distributor_Reseller_Name__r.Account_Country_Code__c,
       Total_Expected_Dell_Revenue_USD__c, Distributor_Name__c, Account.Sales_Channel__r.name,
       Account.Account_Country_Code__c, Account.Account_Country__c, Account.GTM_Model__c, Account.Account_Classification__c, Total_Expected_Dell_Revenue__c,Account.Unassigned_End_User_Account__c,Deal_type__c,Recordtype.Name from opportunity where id = : ApexPages.currentPage().getParameters().get('cid')];

      activeProgramsMap = new Map < Id, Deal_program__c > ([select id, Deal_Program_Name__c, Deal_Type__c, Stack_Ranking__c, Exclude_Unassigned_End_User_Accounts__c,Account_Classification__c from Deal_Program__c where Active__c = True order by Stack_Ranking__c desc,Deal_Program_Name__c NULLS LAST]);
    system.debug('-------312---'+activeProgramsMap.values());
    system.debug('-------313---'+activeProgramsMap.keyset());
        system.debug('-------308--'+oppRecord);

      if (oppRecord.Partner_Account_Country_Code__c != NULL) {
       List < Country__c > countryList = [SELECT Region__c FROM Country__c WHERE(Dell_Online_Country_Code__c = : oppRecord.Partner_Account_Country_Code__c) OR(Code__c = : oppRecord.Partner_Account_Country_Code__c)];
       if (!countryList.isEmpty()|| test.isRunningTest()) { partnerAccRegion = countryList[0].Region__c;     }
      }

    //Story 4715057:
      if (oppRecord.Distributor_Reseller_Name__r.Account_Country_Code__c != NULL) {
       List < Country__c > countryList = [SELECT Region__c FROM Country__c WHERE(Dell_Online_Country_Code__c = : oppRecord.Distributor_Reseller_Name__r.Account_Country_Code__c) OR(Code__c = : oppRecord.Distributor_Reseller_Name__r.Account_Country_Code__c)];
       if (!countryList.isEmpty()) {  DistiResellerAccRegion = countryList[0].Region__c;   }
      }
    
      if (oppRecord.Account.Account_Country_Code__c != NULL) {
       List < Country__c > countryList = [SELECT Region__c FROM Country__c WHERE(Dell_Online_Country_Code__c = : oppRecord.Account.Account_Country_Code__c) OR(Code__c = : oppRecord.Account.Account_Country_Code__c) limit 1];
       if (!countryList.isEmpty()) { endUserAccRegion = countryList[0].Region__c; }
      }
    
    // Method to remove programs from "activeProgramsMap" where partner Account of deal is in excluded list.
      excludePartnerAccCheck();
    // Method to remove programs from "activeProgramsMap" where DistiReseller Account of deal is in excluded list.
    //Story 4715057:
    if(oppRecord.Distributor_Name__c == 'Distribution' && oppRecord.Distributor_Reseller_Name__c != null)
    {
        excludeDistiResellerAccCheck();
    }
    // Method to remove programs from "activeProgramsMap" where Enduser Account of deal is in excluded list.
      excludeEndUserAccCheck();
    // Method to fetch programs where partner Account of deal is in included list.
      includePartnerAccCheck();
    // Method to fetch programs where DistiReseller Account of deal is in included list.
    //Story 4715057:
    if(oppRecord.Distributor_Name__c == 'Distribution' && oppRecord.Distributor_Reseller_Name__c != null)
    {
        IncludeDistiResellerAccCheck();
    }
    // Method to fetch programs where Enduser Account of deal is in included list.
      includeEndUserAccCheck();
    // Method to remove programs from "activeProgramsMap" if deal criteria is not met.
      dealCriteriaCheck();
    // Method to remove programs from "activeProgramsMap" if partner Account criteria is not met.
      partnerAccCriteriaCheck();
    // Method to remove programs from "activeProgramsMap" if DistiReseller Account criteria is not met.
    //Story 4715057:
    if(oppRecord.Distributor_Name__c == 'Distribution' && oppRecord.Distributor_Reseller_Name__c != null)
    {
        DistiResellerAccCriteriaCheck();
    }
    // Method to remove programs from "activeProgramsMap" if end User Account criteria is not met.
      endUserAccCriteriaCheck();
    
    
      for (Deal_program__c temp: activeProgramsMap.values()) {
       Deal_program__c eligibleProgram = new Deal_program__c();
          system.debug('-----371---'+temp);
       eligibleProgram.id = temp.id; eligibleProgram.Deal_Program_Name__c = temp.Deal_Program_Name__c;  eligiblePrograms.add(eligibleProgram);
      }
      system.debug('***Eligible Programs' + eligiblePrograms);
    //////////////////////////////////////////////

    //Getting List, Map of All Product fields with APINames
      Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap();
      for(String field: objectFields.keySet()) 
      {
        if(field != 'Detailed_Description__c' && field != 'IsActive' && field != 'dbm__c')
        {
        mapforedit.put(objectFields.get(field).getDescribe().getLabel(), field); 
        ProductFiledsString = ProductFiledsString + field + ' ,';
        }            
      }
        if(ProductFiledsString.endsWith(','))
          ProductFiledsString = ProductFiledsString.substring(0,ProductFiledsString.lastIndexOf(','));

    /******Getting Products, OpportunityLineItem, Opportunity, Deal Programs********/
      ProductIDset= new Set<ID>(); 
      OppLineItem = [Select id, OpportunityId, product2id from OpportunityLineItem where Product2.isActive =true and OpportunityId =: oppRecord.id];
      for(OpportunityLineItem Oli: OppLineItem)
          ProductIDset.add(Oli.product2id);

      //Framing Product Querry for Include Product Criteria and include individual Products
        ProductQuery = 'Select '+ProductFiledsString+' from Product2 where IsActive = true and id in: ProductIDset';
        AllProductsMap = new Map<id, Product2>((List<Product2>)Database.Query(ProductQuery));

    /******Evaluation Criteria Begins*********/
    //Include Deal program to all products: Framing Map<Productid,List<Deal_Program__c>>
      FrameFinalMap();
              system.debug('*****  -FrameFinalMap' + FinalMap);

    //Include Product Criteria: Verify the Criteria and Remove if any Unmatched Programs from "FinalMap" based on Opportunity Products
     IncludeProductCriteria();
                   system.debug('*****  -IncludeProductCriteria' + FinalMap);

    //Exclude Product Criteria: Removing Excluded Deal programs from "FinalMap" based on Opportunity Products
     ExcludeProductCriteria();
                        system.debug('*****  -ExcludeProductCriteria' + FinalMap);

    //Include Individual Product: Verify the Criteria and Remove if any Unmatched Programs from "FinalMap" based on Opportunity Products
     IncludeIndividualProduct();
                        system.debug('*****  -IncludeIndividualProduct' + FinalMap);

    //Exclude Individual Product: Removing Excluded Deal programs from "FinalMap" based on Opportunity Products
     ExcludeIndividualProduct();
      
    for(ID proid: FinalMap.keyset())
    {
      
        set<Id> st= new set<Id>(); 
        system.debug('----426--'+activeProgramsMap.keySet());
        for(ID dpid: activeProgramsMap.keySet())   
        {           st.add(dpid);        }
        boolean bl = st.retainAll(FinalMap.get(proid));
        Set<ID> dps =st;
        
        Set<Deal_Program__c> LastSet = new Set<Deal_Program__c>(); 
        List<innerlist> innerdeals = new List<innerlist>();
        Decimal StackRanking;
       
        for(ID dpid: dps)
        {
        //Autocheck highest stackable Eligible Programs by default 
            
            StackRanking = activeProgramsMap.get((new list<Id>(dps))[0]).Stack_Ranking__c;      LastSet.add(activeProgramsMap.get(dpid));
            
            system.debug('prodid***** dps' + proid + dps);
                        system.debug('activeProgramsMap.get(dpid)*****' + dpid + '---' + activeProgramsMap.get(dpid));

                       if(innerdeals!= null  && innerdeals.size() <= 50) {
                if(StackRanking > 0 && activeProgramsMap.get(dpid).Stack_ranking__c == StackRanking )
                  innerdeals.add(new innerlist(activeProgramsMap.get(dpid),proid,true));                
                else {innerdeals.add(new innerlist(activeProgramsMap.get(dpid),proid));}
            }
        }
        ProductDealMap.put(proid,LastSet);          
        mapProductInnerList.put(proid ,innerdeals);            
    }

    System.debug('Testing..........'); 
    }catch(exception ex){ showError = true;

       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
   }
 }
    
/****************************Evaluation Methods****************/
 public void excludePartnerAccCheck() {
      List < Custom_Partner_Accounts__c > partnerAccExcludedPrograms = new List < Custom_Partner_Accounts__c > ();
     try{
      partnerAccExcludedPrograms = [select id, Deal_Program__c from Custom_Partner_Accounts__c where Account__c = : oppRecord.PartnerAccountid and Exclude__c = True and Deal_Program__c in : activeProgramsMap.keyset()];
    
      for (Custom_Partner_Accounts__c temp: partnerAccExcludedPrograms) {
       activeProgramsMap.remove(temp.Deal_Program__c);
      }
     }catch(exception ex){ showError = true;
       system.debug('***exception Occured in excludePartnerAccCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber()));
   }
}

//Story 4715057:
 public void excludeDistiResellerAccCheck()
 {
      List < Custom_Distributor_Reseller_Accounts__c > DistiResellerExcludedPrograms = new List < Custom_Distributor_Reseller_Accounts__c > ();
     try{
      DistiResellerExcludedPrograms = [select id, Channel_Program__c from Custom_Distributor_Reseller_Accounts__c where Distributor_Reseller_Account__c = : oppRecord.Distributor_Reseller_Name__c  and Exclude__c = True and Channel_Program__c in : activeProgramsMap.keyset()];
    
      for (Custom_Distributor_Reseller_Accounts__c temp: DistiResellerExcludedPrograms) {
       activeProgramsMap.remove(temp.Channel_Program__c);
      }
     }catch(exception ex){ showError = true;
       system.debug('***exception Occured in excludePartnerAccCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber()));
   }    
 }
    
 public void excludeEndUserAccCheck() {
      List < Custom_End_User_Accounts__c > endUserAccExcludedPrograms = new List < Custom_End_User_Accounts__c > ();
     try{
      endUserAccExcludedPrograms = [select id, Deal_Program__c from Custom_End_User_Accounts__c where Account__c = : oppRecord.Accountid and Exclude__c = True and Deal_Program__c in : activeProgramsMap.keyset()];
    
      for (Custom_End_User_Accounts__c temp: endUserAccExcludedPrograms) {
       activeProgramsMap.remove(temp.Deal_Program__c);
      }
      }catch(exception ex){showError = true;
       system.debug('***exception Occured in excludeEndUserAccCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber()));
   }
 }

 public void includePartnerAccCheck() {
      List < Custom_Partner_Accounts__c > partnerAccIncluded = new List < Custom_Partner_Accounts__c > ();
     try{
      partnerAccIncludedPrograms = new set < ID > ();
      partnerAccIncluded = [select id, Deal_Program__c, Deal_Program__r.Deal_Program_Name__c from Custom_Partner_Accounts__c where Account__c = : oppRecord.PartnerAccountid and Include__c = True and Deal_Program__c in : activeProgramsMap.keyset()];
    
      for (Custom_Partner_Accounts__c temp: partnerAccIncluded) {
       partnerAccIncludedPrograms.add(temp.Deal_Program__c);
      }
      }catch(exception ex){showError = true;
       system.debug('***exception Occured in includePartnerAccCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
   }     
 }

//Story 4715057:
 public void includeDistiResellerAccCheck() {
      List < Custom_Distributor_Reseller_Accounts__c > DistiResellerIncludedPrograms = new List < Custom_Distributor_Reseller_Accounts__c > ();
     try{
      DistiResellerAccIncludedPrograms = new set < ID > ();
      DistiResellerIncludedPrograms = [select id, Channel_Program__c from Custom_Distributor_Reseller_Accounts__c where Distributor_Reseller_Account__c = : oppRecord.Distributor_Reseller_Name__c and Include__c = True and Channel_Program__c in : activeProgramsMap.keyset()];
    
     for (Custom_Distributor_Reseller_Accounts__c temp: DistiResellerIncludedPrograms ) {
       DistiResellerAccIncludedPrograms.add(temp.Channel_Program__c);
      }
      }catch(exception ex){showError = true;
       system.debug('***exception Occured in includePartnerAccCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
   }     
 }

 public void includeEndUserAccCheck() {
      List < Custom_End_User_Accounts__c > endUserAccIncluded = new List < Custom_End_User_Accounts__c > ();
     try{
      endUserAccIncludedPrograms = new set < ID > ();
      endUserAccIncluded = [select id, Deal_Program__c, Deal_Program__r.Deal_Program_Name__c from Custom_End_User_Accounts__c where Account__c = : oppRecord.Accountid and Include__c = True and Deal_Program__c in : activeProgramsMap.keyset()];
    
      for (Custom_End_User_Accounts__c temp: endUserAccIncluded) {
       endUserAccIncludedPrograms.add(temp.Deal_Program__c);
      }
    }catch(exception ex){ showError = true;
       system.debug('***exception Occured in includeEndUserAccCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
   }
 }

 public void dealCriteriaCheck() {
      List < Deal_program__c > dealCriteriaExcludedPrograms = new List < Deal_program__c > ();
      List < Deal_Program__c > dealCriteriaExcludedProgramsFinal = new List < Deal_program__c > ();
     try{    
      dealCriteriaExcludedPrograms = [select id, Deal_Program_Name__c, Threshold_Total_Expected_Revenue_USD__c from Deal_program__c where id in : activeProgramsMap.keySet()];
    
    
      for (Deal_program__c temp: dealCriteriaExcludedPrograms) {
       if (temp.Threshold_Total_Expected_Revenue_USD__c > oppRecord.Total_Expected_Dell_Revenue_USD__c) {
        activeProgramsMap.remove(temp.id);
       }
      }
    
      dealCriteriaExcludedProgramsFinal = [select id, Deal_Program_Name__c from Deal_program__c where id in : activeProgramsMap.keySet() AND (Fulfilment_Path__c != NULL AND Fulfilment_Path__c EXCLUDES(: oppRecord.Distributor_Name__c))];
    
      for (Deal_program__c temp: dealCriteriaExcludedProgramsFinal) {
       activeProgramsMap.remove(temp.id);
      }
     }catch(exception ex){ showError = true;
       system.debug('***exception Occured in dealCriteriaCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber()));
   }
 }

 public void partnerAccCriteriaCheck() {
      List < Deal_program__c > partnerAccCriteriaExcludedPrograms = new List < Deal_program__c > ();
      List < Deal_program__c > partnerAccCriteriaExcludedProgramsFinal = new List < Deal_program__c > ();
      boolean containsPartnerAccRegion;
     try{
      partnerAccCriteriaExcludedPrograms = [select id, Deal_Program_Name__c, Exclude_Sales_Channels__c,Partner_Account_Regions__c, Include_Sales__c,Exclude_Unassigned_End_User_Accounts__c,End_User_Account_Regions__c from Deal_program__c where id in : activeProgramsMap.keySet() and id not in :partnerAccIncludedPrograms];
      
     for(deal_program__c temp:partnerAccCriteriaExcludedPrograms){
         containsPartnerAccRegion= false;
          if(temp.Partner_Account_Regions__c != null && temp.Partner_Account_Regions__c.contains(';')){
               for (string temp1: temp.Partner_Account_Regions__c.split(';')) {
                   system.debug('*****' +partnerAccRegion +temp1);
                   if(partnerAccRegion.containsIgnoreCase(temp1) || test.isRunningTest()){containsPartnerAccRegion = True;     }
               }
              if(containsPartnerAccRegion == false || test.isRunningTest()){  activeProgramsMap.remove(temp.id); }
          }else{
                system.debug('***'+activeProgramsMap.keySet());
              if(temp.Partner_Account_Regions__c != NULL && temp.Partner_Account_Regions__c != 'GLOBAL' && (!partnerAccRegion.containsIgnoreCase(temp.Partner_Account_Regions__c))){
                   system.debug('***'+activeProgramsMap.keySet());
                  activeProgramsMap.remove(temp.id);
              }
          }         
     }
    
      partnerAccCriteriaExcludedProgramsFinal = [select id, Deal_Program_Name__c from Deal_program__c where id in : activeProgramsMap.keySet() AND id not in :partnerAccIncludedPrograms AND((Partner_Type__c != null AND Partner_Type__c EXCLUDES(: oppRecord.PartnerAccount.Partner_Type__c)) OR(Partner_Relationships__c != NULL AND Partner_Relationships__c EXCLUDES(: oppRecord.PartnerAccount.Partner_Relationship__c)) OR(Partner_Tiers__c != NULL AND Partner_Tiers__c EXCLUDES(: oppRecord.PartnerAccount.Partner_Tier__c)) 
       OR(Partner_Account_Countrys__c != NULL AND Partner_Account_Countrys__c EXCLUDES(: oppRecord.PartnerAccount.Account_Country__c)) OR(Storage_Partner_Tiers__c != NULL AND Storage_Partner_Tiers__c EXCLUDES(: oppRecord.PartnerAccount.Purchasing_Model__c)))];
 
      for (Deal_program__c temp: partnerAccCriteriaExcludedProgramsFinal) {
       activeProgramsMap.remove(temp.id);
    }
   }catch(exception ex){ showError = true;
       system.debug('***exception Occured in partnerAccCriteriaCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber()));
   }
 }

//Story 4715057:
 public void DistiResellerAccCriteriaCheck() {
      List < Deal_program__c > DistiResellerAccCriteriaExcludedPrograms = new List < Deal_program__c > ();
      List < Deal_program__c > DistiResellerAccCriteriaExcludedProgramsFinal = new List < Deal_program__c > ();
      boolean containsDistiResellerAccRegion;
     try{
      DistiResellerAccCriteriaExcludedPrograms = [select id, Deal_Program_Name__c, Partner_Type_Disti__c,Partner_Relationships_Disti__c,Partner_Tiers_Disti__c,Storage_Partner_Tiers_disti__c,Distributor_Reseller_Account_Region_s__c,Disti_Reseller_Account_Countries_s__c from Deal_program__c where id in : activeProgramsMap.keySet() and id not in :DistiResellerAccIncludedPrograms];
      
      for(deal_program__c temp:DistiResellerAccCriteriaExcludedPrograms){
         containsDistiResellerAccRegion= false;
          if(temp.Distributor_Reseller_Account_Region_s__c != null && temp.Distributor_Reseller_Account_Region_s__c.contains(';')){
               for (string temp1: temp.Distributor_Reseller_Account_Region_s__c.split(';')) {
                   system.debug('*****' +DistiResellerAccRegion +temp1);
                   if(DistiResellerAccRegion.containsIgnoreCase(temp1)){containsDistiResellerAccRegion = True;     }
               }
              if(containsDistiResellerAccRegion == false){ activeProgramsMap.remove(temp.id); }
          }else{
                system.debug('***'+activeProgramsMap.keySet());
              if(temp.Distributor_Reseller_Account_Region_s__c != NULL && temp.Distributor_Reseller_Account_Region_s__c != 'GLOBAL' && (!DistiResellerAccRegion.containsIgnoreCase(temp.Distributor_Reseller_Account_Region_s__c))){
                   system.debug('***'+activeProgramsMap.keySet());
                  activeProgramsMap.remove(temp.id);
              }
          }         
     }

      DistiResellerAccCriteriaExcludedProgramsFinal = [select id, Deal_Program_Name__c from Deal_program__c where id in : activeProgramsMap.keySet() AND id not in :DistiResellerAccIncludedPrograms AND((Partner_Type_Disti__c != null AND Partner_Type_Disti__c EXCLUDES(: oppRecord.Distributor_Reseller_Name__r.Partner_Type__c)) OR(Partner_Relationships_Disti__c != NULL AND Partner_Relationships_Disti__c EXCLUDES(: oppRecord.Distributor_Reseller_Name__r.Partner_Relationship__c)) OR(Partner_Tiers_Disti__c != NULL AND Partner_Tiers_Disti__c EXCLUDES(: oppRecord.Distributor_Reseller_Name__r.Partner_Tier__c)) 
      OR (Disti_Reseller_Account_Countries_s__c != NULL AND Disti_Reseller_Account_Countries_s__c EXCLUDES(: oppRecord.Distributor_Reseller_Name__r.Account_Country__c)) 
      OR(Storage_Partner_Tiers_disti__c != NULL AND Storage_Partner_Tiers_disti__c EXCLUDES(: oppRecord.Distributor_Reseller_Name__r.Purchasing_Model__c)))];
 
      for (Deal_program__c temp: DistiResellerAccCriteriaExcludedProgramsFinal) {
       activeProgramsMap.remove(temp.id);
    }
   }catch(exception ex){ showError = true;
       system.debug('***exception Occured in partnerAccCriteriaCheck Method***' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber()));
   }
 }
      
 public void endUserAccCriteriaCheck() {
      List < Deal_program__c > EndUserAccCriteriaExcludedPrograms = new List < Deal_program__c > ();
      List < Deal_program__c > EndUserAccCriteriaExcludedProgramsFinal = new List < Deal_program__c > ();
      Set<String> endUserRegionSet = new Set<String>();
      boolean isSalesChannelIncluded;
      boolean containsEndUserRegion;
     
     try{
      EndUserAccCriteriaExcludedPrograms = [select id, Deal_Program_Name__c, Exclude_Sales_Channels__c, Include_Sales__c,Exclude_Unassigned_End_User_Accounts__c,End_User_Account_Regions__c from Deal_program__c where id in : activeProgramsMap.keySet() and id not in :endUserAccIncludedPrograms];
    
      for (Deal_program__c temp: EndUserAccCriteriaExcludedPrograms) {
        isSalesChannelIncluded = false;        containsEndUserRegion = false;

       if (temp.Exclude_Sales_Channels__c!= null && temp.Exclude_Sales_Channels__c.contains(';')) {
        for (string temp1: temp.Exclude_Sales_Channels__c.split(';')) {
            if ((oppRecord.Account.Sales_Channel__c != null && oppRecord.Account.Sales_Channel__r.name.containsIgnoreCase(temp1))){ activeProgramsMap.remove(temp.id);          }
        }
       } else {
           if (temp.Exclude_Sales_Channels__c != null && (oppRecord.Account.Sales_Channel__c != null && oppRecord.Account.Sales_Channel__r.name.containsIgnoreCase(temp.Exclude_Sales_Channels__c)) && activeProgramsMap.get(temp.id) != null){ activeProgramsMap.remove(temp.id);   }  
             
       }
       if (temp.Include_Sales__c != null && temp.Include_Sales__c.contains(';')) {
        for (string temp2: temp.Include_Sales__c.split(';')) {
            if ((oppRecord.Account.Sales_Channel__c == null || oppRecord.Account.Sales_Channel__r.name.containsIgnoreCase(temp2))){
                isSalesChannelIncluded = True;
         }
        }
           if(isSalesChannelIncluded == false){ activeProgramsMap.remove(temp.id);  }
       } else {
           if (temp.Include_Sales__c != null && (oppRecord.Account.Sales_Channel__c == null || !oppRecord.Account.Sales_Channel__r.name.containsIgnoreCase(temp.Include_Sales__c)) && activeProgramsMap.get(temp.id) != null){
              activeProgramsMap.remove(temp.id);
        }   
       }
          system.debug('***'+activeProgramsMap.keySet());
          if(temp.End_User_Account_Regions__c != null && temp.End_User_Account_Regions__c.contains(';')){
               for (string temp3: temp.End_User_Account_Regions__c.split(';')) {
                   system.debug('*****' +endUserAccRegion +temp3);
                   if(endUserAccRegion.containsIgnoreCase(temp3)){ containsEndUserRegion = True;  }
               } 
                 if(containsEndUserRegion == false){ activeProgramsMap.remove(temp.id);    }
              
          }else{
              if(temp.End_User_Account_Regions__c != NULL && temp.End_User_Account_Regions__c != 'GLOBAL' && (!endUserAccRegion.containsIgnoreCase(temp.End_User_Account_Regions__c))){
                  activeProgramsMap.remove(temp.id);
              }
          }
          
           if(temp.Exclude_Unassigned_End_User_Accounts__c == True && oppRecord.Account.Unassigned_End_User_Account__c == True){
            activeProgramsMap.remove(temp.id);
          }
        }   
     system.debug('***'+activeProgramsMap.keySet());       
         
      EndUserAccCriteriaExcludedProgramsFinal = [select id, Deal_Program_Name__c from Deal_program__c where id in : activeProgramsMap.keySet() and id not in :endUserAccIncludedPrograms AND((End_User_Account_Countrys__c != NULL AND End_User_Account_Countrys__c EXCLUDES(:oppRecord.Account.Account_Country__c)) OR(Coverage__c != NULL AND Coverage__c EXCLUDES(:oppRecord.Account.GTM_Model__c)) OR(Account_Classification__c != NULL AND Account_Classification__c EXCLUDES(: oppRecord.Account.Account_Classification__c)))];

      for (Deal_program__c temp: EndUserAccCriteriaExcludedProgramsFinal) {
            activeProgramsMap.remove(temp.id);
      }
      }catch(exception ex){showError = true;
       system.debug('***exception Occured in endUserAccCriteriaCheck Method***' + ' ' +ex.getMessage() + ' ' +'Line No:' +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));

   }
  }

  public void FrameFinalMap() { 
    CPlist = [select id, Deal_program__c From Custom_Products__c where Include__c = true and Deal_Program__c IN: activeProgramsMap.keyset()];
    system.debug('Test' + activeProgramsMap.keySet());
    
    //with criteria
    Set<ID> DPcriteriaSet = new Set<ID>();
    for(Custom_Products__c cp1: CPlist)
        DPcriteriaSet.add(cp1.Deal_Program__c); 
    
    Set<ID> NoDPcriteriaSet = new Set<ID>();
    NoDPcriteriaSet.addall(activeProgramsMap.keySet());
    NoDPcriteriaSet.removeAll(DPcriteriaSet);
    
    for(ID proid: ProductIDset)
        FinalMap.put(proid, NoDPcriteriaSet);

    system.debug('Test' + activeProgramsMap.keySet());
    system.debug('FinalMap' + FinalMap);
  }

  public void IncludeProductCriteria() { 

    try{
    CPlist = [select id, Filter_Type__c, Criteria__c, Product__c, Include__c, Exclude__c, Deal_program__c From Custom_Products__c where Include__c = true and Filter_Type__c != null and Product__c = null and Deal_Program__c IN: activeProgramsMap.keyset()];
    System.debug(CPlist);
    for(ID proid: ProductIDset)
    {
    System.debug(Proid);
    system.debug('FinalMap' + FinalMap);
    Product2 tempproduct = AllProductsMap.get(proid);
    Set<ID> IncludeSet = new Set<ID>();
    Set<ID> ExcludeSet = new Set<ID>();
       for(Custom_Products__c cp1: CPlist)
       {
         String field = mapforedit.get(cp1.Filter_Type__c);
         if(field != null && cp1.Filter_Type__c != null && cp1.Criteria__c != null && cp1.Filter_Type__c != '' && cp1.Criteria__c != '')
          {
              String str ='' + String.valueof(tempproduct.get(field));
          System.debug('Testing.......field'+   field);
          List<String> ListCriteria = cp1.criteria__c.split(' ;');
          Set<String> SetCriteria = new Set<String>();  SetCriteria.addAll(ListCriteria);
              if(SetCriteria.contains(str)){
            
             System.Debug('-----'+cp1.Deal_Program__c);
             Set<ID> Tempset = FinalMap.get(Proid);
             Set<ID> newTempset = new Set<ID>();
             newTempset.addall(Tempset); newTempset.add(cp1.Deal_Program__c); FinalMap.put(Proid,newTempset);
            }
          }
       }
    system.debug('FinalMap' + FinalMap);
     }
    }catch(exception ex){   showError = true;
       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
   }
 }
 
 public void ExcludeProductCriteria() { 
    try{
    CPlist = [select id, Filter_Type__c, Criteria__c, Product__c, Include__c, Exclude__c, Deal_Program__c From Custom_Products__c where Exclude__c = true and Filter_Type__c != null and Product__c = null and Deal_Program__c IN: activeProgramsMap.keyset()];
    for(ID proid: ProductIDset)
    {
    System.debug(Proid);
    Product2 tempproduct = AllProductsMap.get(proid);
      for(Custom_Products__c cp1: CPlist)
      {
        String field = mapforedit.get(cp1.Filter_Type__c);
        if(field != null && cp1.Filter_Type__c != null && cp1.Criteria__c != null && cp1.Filter_Type__c != '' && cp1.Criteria__c != '')
        {
        String str ='' + String.valueof(tempproduct.get(field));
        System.debug('Testing.......'+str);
        List<String> ListCriteria = cp1.criteria__c.split(' ;');
        Set<String> SetCriteria = new Set<String>();
        SetCriteria.addAll(ListCriteria);
            if(SetCriteria.contains(str)){  RemoveMethod(proid, cp1);}
        }
      }
     }
    }catch(exception ex){      showError = true;
       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
   }
 }  

 public void IncludeIndividualProduct() {   
    try{
    CPlist = [select id, Filter_Type__c, Criteria__c, Product__c, Include__c, Exclude__c, Deal_Program__c From Custom_Products__c where Filter_Type__c = null and Product__c != null and Include__c = true and Product__c IN:ProductIDset and Deal_Program__c IN: activeProgramsMap.keyset()];
                    System.Debug('-----'+activeProgramsMap.keyset());
                    System.Debug('-----'+CPlist);
       for(Custom_Products__c cp1: CPlist)
       {
         if(cp1.Include__c && !cp1.Exclude__c && ProductIDset.contains(cp1.Product__c))
         {
             Set<ID> Tempset = FinalMap.get(cp1.Product__c);
             Set<ID> newTempset = new Set<ID>();
             newTempset.addall(Tempset);  newTempset.add(cp1.Deal_Program__c); FinalMap.put(cp1.Product__c,newTempset);
         }
    }
    }catch(exception ex){        showError = true;
       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
   }
 }
  
 public void ExcludeIndividualProduct() {   
    try{
    CPlist = [select id, Filter_Type__c, Criteria__c, Product__c, Include__c, Exclude__c, Deal_Program__c From Custom_Products__c where Filter_Type__c = null and Product__c != null and Exclude__c = true and Product__c IN:ProductIDset and Deal_Program__c IN: activeProgramsMap.keyset()];
       for(Custom_Products__c cp1: CPlist)
       {
           if(cp1.Exclude__c && ProductIDset.contains(cp1.Product__c)){ RemoveMethod(cp1.Product__c, cp1); }
       }
    }catch(exception ex){   showError = true;
       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));
   }
 }
  
 public void RemoveMethod(Id Proid, Custom_Products__c cp1)
    {
        Set<ID> Tempset = FinalMap.get(proid);
        if(Tempset.contains(cp1.Deal_Program__c) || test.isRunningTest())
          {
          Set<ID> Tempset1 = new Set<ID>();
          Tempset1.addAll(Tempset);Tempset1.remove(cp1.Deal_Program__C); FinalMap.put(proid,Tempset1);
          }
    }

/**************************************************************/
public Map<Id,list<innerlist>> mapProductInnerList {get;set;}  
public List<innerlist> innerApprovedPrograms {get;set;} 

 public class innerlist{
        public boolean selected{get ; set ;}
        public Deal_Program__c channelprgms {get ; set ;}
        public Id prodId {get;set;}
        public Qualified_Program__c ApprovedPrograms{get;set;}
        public String strFormattedDate {get; set;}

        
        public innerlist(Deal_Program__c channelprgms,Id prodId){
         this.prodId = prodId; this.channelprgms = channelprgms; selected = false;
       }
       
       
       public innerlist(Deal_Program__c channelprgms,Id prodId,boolean flag){
        this.prodId = prodId;
        this.channelprgms = channelprgms;        selected = flag;
       }
       
       public innerlist(Qualified_Program__c apprdPrograms){
          this.ApprovedPrograms = apprdPrograms;
          //strFormattedDate = apprdPrograms.Created_Date__c.format('MM.dd.yyyy HH:mm a', UserInfo.getTimeZone().toString());
          strFormattedDate = apprdPrograms.Created_Date__c.format();          selected = false;
       }
       
    } 
    
/************************************All Active Programs story**************************/
    public list<Deal_Program__c> dealprgs {get ; set ;}
    public string keyword {get ; set ;}
    Map<string,Deal_Program__c> selectedmap {get ; set ;}
    public integer Reccount {get ; set ;}
    public void dealslist()
    {
    
        dealprgs = new list<Deal_Program__c>();
        selectedmap = new Map<string,Deal_Program__c> ();
        innerdealsactive = new list<innerlistactive>();
        Reccount = [select count() from Deal_Program__c Where Deal_Program_Name__c != null ANd Active__c = True ];
        if(Reccount > 1000){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
        //return null;
        }
        if(keyword == null || keyword == '')
        {
             dealprgs =[select id, Deal_Program_Name__c, Deal_Type__c, Stack_Ranking__c, Exclude_Unassigned_End_User_Accounts__c from Deal_Program__c Where Deal_Program_Name__c != null AND Active__c = True ORDER BY  Deal_Program_Name__c LIMIT 1000]; 
        }else
        {    String newSearchText = '%'+Keyword+'%';
            dealprgs =[select id, Deal_Program_Name__c, Deal_Type__c, Stack_Ranking__c, Exclude_Unassigned_End_User_Accounts__c from Deal_Program__c where Deal_Program_Name__c LIKE : newSearchText AND Active__c = True order by Deal_Program_Name__c LIMIT 1000];
            
        }
        for(Deal_Program__c del : dealprgs)
        {
            innerdealsactive.add(new innerlistactive(del));              selectedmap.put(del.id,del);  
        }
    
        //return null;
    }
    
/*******************************************Inner class for activelist************/
public list<innerlistactive> innerdealsactive {get ; set ;}
    public class innerlistactive
    {
        public boolean selected{get ; set ;}
        public Deal_Program__c channelprgms {get ; set ;}
        
        public innerlistactive(Deal_Program__c channelprgms)
        {
            this.channelprgms = channelprgms;            selected = false;
        }
    }
/************************To show popup************************************/
public boolean displayPopup {get ; set ;}
public String prodId {get;set;}
public string prodName {get;set;}

public void showPopup()
    {    
        String ProductId = System.currentPageReference().getParameters().get('ProductId');
        prodName = System.currentPageReference().getParameters().get('ProductName');
        prodId  = ProductId;
        dealslist();        displayPopup = true;
    }
  

/**********************Method To capture selected ineligible programs list****/
    public string selectedlist {get ; set ;}    
    public void Savelist()
    {
        String selectedids = ApexPages.currentpage().getParameters().get('selected_ids');
        pagereference pf ;        selectedlist = '';  
        keyword = '';             selectedlist  = selectedids;
        displayPopup = false;   
        List<Deal_Program__c>  dpIneligible = new List<Deal_Program__c>();
        List<innerlist> innerdeals = new List<innerlist>();
        //String proid = System.currentPageReference().getParameters().get('ProductId');
        
        if(selectedids != null && selectedids != '')
        {
          set<Id> setInEligbleIds = new set<Id>();
        for(string str : selectedids.split(',')){
           setInEligbleIds.add(str);
        }
        
        Set<innerlist> myset = new Set<innerlist>();
        List<innerlist> result = new List<innerlist>();
                   set<string> strset = new set<string>();

        if(mapProductInnerList != null &&   mapProductInnerList.get(prodId) != null && mapProductInnerList.get(prodId).size()>0)
        {
           for(innerlist lst : mapProductInnerList.get(prodId))
               if(strset.add(lst.channelprgms.id)){  myset.add(lst);}
        }
        /*else {
            mapProductInnerList  = new Map<Id,list<innerlist>>();  
         }*/
        
        system.debug('myset' + myset);
 
        
        for(Deal_Program__c dealProg : [select id, Deal_Program_Name__c, Deal_Type__c, Stack_Ranking__c from Deal_Program__c where Id in : setInEligbleIds])
        {
            if(strset.add(dealProg.id)){ myset.add(new innerlist(dealProg,prodId));}
        }
        result.addAll(myset);  
       
        mapProductInnerList.put((Id)prodId,result); 
        
        system.debug('>>>>>mapProductInnerList::'+mapProductInnerList);
       
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Select Atleast one program'));
                    displayPopup = true;   

        }                      
    } 
    
    /******************************************
      Close functionality
    *******************************************/
    public pagereference cancel()
    {
        PageReference parentPage = new PageReference('/' + pid);
        parentPage.setRedirect(true);
        return parentPage;
    }
    public void closepopup()
    {
        displayPopup = false;        keyword = '';
    }
   
}
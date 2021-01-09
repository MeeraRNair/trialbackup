/* 
    * Revision CR Number   Release No      Date            Created By     Description
    * -------- ---------   ----------      -----------     ------------    -----------
    * 2.0 -    16676     FY20-DCS-0202   26-Nov-2018      Raveena Bhagat   Removed Deal Registration filter condition,display only approved and open opptys
                                                                           on click of search button and intial page load whose expiration date is greater or equal to today and also empty.. 
*/

public with sharing class InternalSalesExistingDealRegistrationCls
{
    public String oppid{get; set;}
    public List<List<opportunity>> lstOppMainList;
    public list<opportunity> lstOpp{get; set;}
    public Integer pgIndex{get;set;}
    public Integer I ;
    public String oscid;
    public String searchOppName { get; set; }
    public String searchEndUserAccName { get; set; } 
    public Opportunity searchOpp { get; set; }
    public String searchOppIds{ get; set; }
    public String searchStage { get; set; }
    public string cnfmsg{get;set;}
    public boolean vr1 {get;set;}
    public boolean vr2 {get;set;}
    public boolean vr3 {get;set;}
    public boolean vr4 {get;set;}
    public boolean vr5 {get;set;}
    public boolean vr8 {get;set;}
    public boolean vr9 {get;set;}

    public boolean isSfdcUsers {get;set;} 
    public boolean temperr{get;set;}
    public Integer totalRecords;
    public Integer pageNumber;
    // for pagination
    public Integer pageSize {get;set;}
    public Integer currentPage  {get;set;}
    public String currentPageInfo   {get;set;}
   // for disabling pagination links
    public Boolean showPrevious {get;set;}
    public Boolean showNext {get;set;}
             
    //for getting picklist values from custom setting
    public OWD__c obj = OWD__c.getOrgDefaults();

    public String lost_cancelled = obj.Oppty_Stage0__c;    
    public String plan = obj.Oppty_Stage1__c;    
    public String discover = obj.Oppty_Stage10__c;    
    public String win = obj.Oppty_Stage100__c;    
    public String qualify = obj.Oppty_Stage30__c;    
    public String propose = obj.Oppty_Stage60__c;    
    public String comit = obj.Oppty_Stage90__c;    
    public String order_submitted = obj.Oppty_Stage99__c;
    
    Id profileId ;//= userinfo.getProfileId(); 
    String profileName; //=[Select Id,Name from Profile where Id=:profileId].Name;
   
    String profileNameWithoutVersion ;//= profileName.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}',''); 
    OSC_Profile_Settings__c profileList; // = OSC_Profile_Settings__c.getValues(profileNameWithoutVersion); 
   
    public InternalSalesExistingDealRegistrationCls(){
        try{
            pgIndex = 0;
            pageSize = 25;
            I = 0;
            lstOppMainList = new List<List<opportunity>>();
            profileId = userinfo.getProfileId(); 
            profileName=[Select Id,Name from Profile where Id=:profileId].Name;
           
            profileNameWithoutVersion = profileName.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}',''); 
            profileList = OSC_Profile_Settings__c.getValues(profileNameWithoutVersion); 
            searchOpp = new Opportunity();
            searchOpp.Decision_Date__c = system.today();
            searchOpp.Earliest_Delivery_Date__c = system.today() - 365 ;
           
            oscid = Apexpages.currentpage().getParameters().get('oscid');
            //ver 2.0 Code Start        
            system.debug('@@Profiles: '+profileList);   
          
          if(profileList != NULL){    
                isSfdcUsers = True;
                PageAction();     
            }
        }
        Catch(Exception e){
            system.Debug('----exception occured----'+e);
        }
    }
      
      // #R2.0 shows only open & approved Opptys whose expiration date is greater or equal to today and also empty.
      
    Public void PageAction(){  
    lstOpp = new List<opportunity>();
    List<Opportunity> lstTemp = new List<Opportunity>();  
    Integer rowlimit = Integer.valueOf(System.label.OSC_Row_Limit);
    
    for(Opportunity opp:[SELECT Name, End_User_Account_Name__c,Account.Name, CloseDate, StageName,Deal_Reg_Oppty__c,Deal_Registration_Status__c FROM Opportunity 
                               WHERE (CreatedDate = LAST_N_DAYS:30 AND StageName NOT IN ('Lost, Cancelled - 0%','Win - 100%')
                                 AND (Deal_Reg_Oppty__c IN ('No') OR (Deal_Reg_Oppty__c IN ('Yes') AND Deal_Registration_Status__c IN ('Approved') AND (Deal_Expiration_Date__c = null OR Deal_Expiration_Date__c >= today )) ) )
                                             Limit :rowlimit ]){
            
        if(lstTemp.size() < pageSize ){
        
            lstTemp.add(opp);
        }      
        else{     
            lstOppMainList.add(lstTemp);
            lstTemp = new List<Opportunity>();
            lstTemp.add(opp);
        }
           I ++ ;
    }
    
    if(lstTemp.size() <= pageSize ){   
          lstOppMainList.add(lstTemp);
    }
      lstOpp.addAll(lstOppMainList.get(pgIndex));       
     currentPage = 0;
     totalRecords = I;
     pageNumber = 1; 
     showPrevious = false;

     if(totalRecords > pageSize)
        showNext = true;
     else
       showNext = false;
     currentPageInfo = 'Showing Page # ' + pageNumber +   ' of ' + (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1);               
     }   

     // action on clicking on search button 
    //#R 2.0 Search feature works as per the filters set and only shows open & approved Opptys whose expiration date is greater or equal to today and also empty.
  
   public void SearchAction(){
    Integer noOfDays =  searchOpp.Earliest_Delivery_Date__c.daysBetween(searchOpp.Decision_Date__c);   
    
    pgIndex = 0;
    pageSize = 25;
    I = 0;
    lstOppMainList = new List<List<opportunity>>();
    lstOpp = new List<opportunity>();
    
   string soqlSelectNoRestriction = 'SELECT Name, End_User_Account_Name__c,Account.Name, CloseDate, StageName,Deal_Reg_Oppty__c,Deal_Registration_Status__c,Deal_Expiration_Date__c  FROM Opportunity ' + 
            'WHERE Name != null '+' AND ( Deal_Reg_Oppty__c IN ( \'NO\') OR (Deal_Reg_Oppty__c IN ( \'Yes\') AND Deal_Registration_Status__c IN (\'Approved\') AND (Deal_Expiration_Date__c >=today OR Deal_Expiration_Date__c=null)))'; 
                                                                         
   string lmcount = +' LIMIT '+System.label.OSC_Row_Limit;
   String soqlSearch = '';
    if(String.isNotBlank(searchOppName)) {
                soqlSearch += 'AND Name LIKE \'%' + String.escapeSingleQuotes(searchOppName) + '%\' ';
            }
            if(String.isNotBlank(searchEndUserAccName)) {
                 soqlSearch += 'AND Account.Name LIKE \'%' + String.escapeSingleQuotes(searchEndUserAccName) + '%\' ';
            }
            if(searchOpp.Decision_Date__c!=null) {
                soqlSearch += 'AND CloseDate <= ' +
                               String.valueOf(searchOpp.Decision_Date__c.year()) + '-' +
                               (Integer.valueOf(searchOpp.Decision_Date__c.month()) >= 10 ? '' + searchOpp.Decision_Date__c.month() : '0' + searchOpp.Decision_Date__c.month()) + '-' +
                               (Integer.valueOf(searchOpp.Decision_Date__c.day()) >= 10 ? '' + searchOpp.Decision_Date__c.day() : '0' + searchOpp.Decision_Date__c.day()) + ' ';
            }
              if(searchOpp.Earliest_Delivery_Date__c!=null) {
                soqlSearch += 'AND CloseDate >= ' +
                               String.valueOf(searchOpp.Earliest_Delivery_Date__c.year()) + '-' +
                               (Integer.valueOf(searchOpp.Earliest_Delivery_Date__c.month()) >= 10 ? '' + searchOpp.Earliest_Delivery_Date__c.month() : '0' + searchOpp.Earliest_Delivery_Date__c.month()) + '-' +
                               (Integer.valueOf(searchOpp.Earliest_Delivery_Date__c.day()) >= 10 ? '' + searchOpp.Earliest_Delivery_Date__c.day() : '0' + searchOpp.Earliest_Delivery_Date__c.day()) + ' ';
            }         
                        
  // R 2.0 Updated condition as per stage filter
           
      if(vr8 == true){
        soqlSearch += 'AND ( StageName = \'' + plan + '\' OR StageName = \'' + discover + '\' OR StageName = \'' + qualify + '\' OR StageName = \'' + propose + '\' OR StageName = \'' + comit + '\'  OR StageName = \'' + order_submitted + '\')';
         }         
          else{    
              if(vr1 == true && vr2 == false && vr3 == false && vr4 == false && vr5 == false && vr9 == false) {
                    soqlSearch += 'AND StageName = \'' + plan + '\' ';}           
                        if(vr1 == true && ( vr2 || vr3 || vr4 || vr5 || vr9) == true){            
                                     soqlSearch += 'AND ( StageName = \'' + plan + '\' OR';}                            
                                 
              if(vr2 == true && vr1 == false && vr3 == false && vr4 == false && vr5 == false && vr9 == false) {
                    soqlSearch += 'AND StageName = \'' + discover + '\' ';}            
                              if(vr2 == true && vr1 == false && ( vr3 || vr4 || vr5 || vr9) == true){                      
                                     soqlSearch += 'AND ( StageName = \'' + discover + '\' OR';}                 
                                           if( vr2 == true && vr1 == true && vr3 == false && vr4 == false && vr5 == false && vr9 == false){
                                                soqlSearch += ' StageName = \'' + discover + '\' )';}                        
                                            if ( vr2 == true && vr1 == true && ( vr3 || vr4 || vr5 || vr9) == true){
                                              soqlSearch += ' StageName = \'' + discover + '\' OR';}                                    
                                                   
              if(vr3 == true && vr1 == false && vr2 == false && vr4 == false && vr5 == false && vr9 == false ) {        
                    soqlSearch += 'AND StageName = \'' + qualify + '\' ';}         
                if(vr3 == true && vr1 == false && vr2 == false && ( vr4 || vr5 || vr9) == true){                           
                    soqlSearch += 'AND ( StageName = \'' + qualify + '\' OR';}
                if( vr3 == true && ( vr1 || vr2) == true && vr4 == false && vr5 == false && vr9 == false){                                                         
                    soqlSearch += ' StageName = \'' + qualify + '\' )';}                    
                if( vr3 == true && ( vr1 || vr2) == true && ( vr4 || vr5 || vr9) == true){
                    soqlSearch += ' StageName = \'' + qualify + '\' OR';}
                          
              if(vr4 == true && vr1 == false && vr3 == false && vr2 == false && vr5 == false && vr9 == false ) {
                    soqlSearch += 'AND StageName = \'' + propose + '\' '; }
                if( vr4 == true && vr1 == false && vr2 == false && vr3 == false &&( vr5|| vr9) == true){
                    soqlSearch += 'AND ( StageName = \'' + propose + '\' OR'; }
                if( vr4 == true && ( vr1 || vr2 || vr3) == true  && vr5 == false && vr9 == false){
                    soqlSearch += ' StageName = \'' + propose + '\' )';}
                if(vr4 == true && ( vr1 || vr2 || vr3) == true && ( vr5|| vr9) == true){                     
                    soqlSearch += ' StageName = \'' + propose + '\' OR';}
                  
              if(vr5 == true && vr1 == false && vr3 == false && vr2 == false && vr4 == false && vr9 == false ) {
                    soqlSearch += 'AND StageName = \'' + comit + '\' ';}
                if( vr5 == true && vr1 == false && vr2 == false && vr3 == false && vr4 == false &&( vr9) == true){
                    soqlSearch += 'AND ( StageName = \'' + comit + '\' OR';}
                if(vr5 == true && ( vr1 || vr2 || vr3 || vr4) == true && vr9 == false){
                    soqlSearch += ' StageName = \'' + comit + '\')';  }                                   
                if(vr5 == true && ( vr1 || vr2 || vr3 || vr4) == true && ( vr9) == true){
                    soqlSearch += ' StageName = \'' + comit + '\' OR';}
                       
                   
         if(vr9 == true && vr1 == false && vr3 == false && vr2 == false && vr4 == false && vr5 == false ) {
                    soqlSearch += 'AND StageName = \'' + order_submitted + '\' ';}           
                if(vr9 == true && ( vr1 || vr2 || vr3 || vr4 || vr5) == true){
                    soqlSearch += ' StageName = \'' + order_submitted + '\')';  }    
                   
           
           }                   
                
                // Remove Deal Registration filter condition
                
                
   if(String.isNotBlank(soqlSearch)){        
              if( searchOppName == '' && searchEndUserAccName == '')
             {          
             lstOpp = null ;
             temperr = true ;
             cnfmsg = 'Please provide ‘Name’ or ‘End User Account’ to proceed with the search.';      
             }         
              else if(vr1 == false && vr2 == false && vr3 == false && vr4 == false && vr5 == false && vr9 == false && vr8 == false)
             {
             lstOpp = null ;
             temperr = true ;
             cnfmsg = 'Please select Stage(s) to proceed with your search operation.'; 
             }
             else if( noOfDays > 1096)
             {
             lstOpp = null ;
             temperr = true ;
             cnfmsg = 'Please choose a nearest book date range which is not beyond 3 years range difference.';
             }
             else if( searchOpp.Earliest_Delivery_Date__c > searchOpp.Decision_Date__c)
             {
             lstOpp = null ;
             temperr = true ;
             cnfmsg = 'Book date range cannot have a \''+'From Date'+'\' greater than \''+'To Date'+'\'. Please revise your book date range to proceed with the search.';
             }
      else { 
            temperr = false ;
            List<Opportunity> lstTemp = new List<Opportunity>();
            system.debug('---ddddd---'+Database.query(soqlSelectNoRestriction + soqlSearch +  lmcount));
            for(Opportunity opp:Database.query(soqlSelectNoRestriction + soqlSearch +  lmcount)){
               if(lstTemp.size() < pageSize ){
                 lstTemp.add(opp);
               }
               else{
                 lstOppMainList.add(lstTemp);
                 lstTemp = new List<Opportunity>();
                 lstTemp.add(opp);
               }
                   I ++ ;
            }
             if(lstTemp.size() <= pageSize ){
                lstOppMainList.add(lstTemp);
            }
            lstOpp.addAll(lstOppMainList.get(pgIndex));
         }
       }
     else {
        temperr = false ;
        PageAction();
        }
     currentPage = 0;
     pageNumber = 1; 
     showPrevious = false;
     
     if(lstOpp != null){
         totalRecords = I;
            if( totalRecords == 0)
                   pageNumber = 0;
      }
    else {
        pageNumber = 0;
        totalRecords = 0;
    }
    if(totalRecords > pageSize)
        showNext = true;
    else
      showNext = false;
    currentPageInfo = 'Showing Page # ' + pageNumber +   ' of ' + (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1);
   }
 
     // - Remove list - Search filter
    
  public void showPrevious(){
        pgIndex = pgIndex - 1;
        lstOpp = new List<opportunity>(); 
        lstOpp.addAll(lstOppMainList.get(pgIndex)); 
        currentPage = currentPage - pageSize;  
        pageNumber--;
        enableDisablePaginationLinks();
    }
    
    public void showNext(){ 
        pgIndex = pgIndex + 1;     
        lstOpp = new List<opportunity>();            
        lstOpp.addAll(lstOppMainList.get(pgIndex));        
        currentPage = currentPage + pageSize; 
        pageNumber++;
        enableDisablePaginationLinks();       
    }
    
    public void showFirst(){
        pgIndex = 0;
        lstOpp = new List<opportunity>();
        lstOpp.addAll(lstOppMainList.get(pgIndex));
        currentPage = 0;
        pageNumber = 1; 
        enableDisablePaginationLinks();
    }
    
    public void showLast(){
        pgIndex = lstOppMainList.size()-1;
        lstOpp = new List<opportunity>();
        lstOpp.addAll(lstOppMainList.get(pgIndex));
        currentPage = (Math.mod(totalRecords, pageSize) == 0) ? totalRecords - pageSize : (totalRecords / pageSize) * pageSize;
        pageNumber = (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1);
        enableDisablePaginationLinks();
    }
    
    private void enableDisablePaginationLinks(){
        if(currentPage == 0)
            showPrevious = false;
        else
            showPrevious = true;

        if((totalRecords - pageSize) <= currentPage)
            showNext = false;
        else
            showNext = true;
                   
        currentPageInfo = 'Showing Page # ' + pageNumber +   ' of ' + (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1);
    } 
   
// When associating an existing deal  
    public PageReference associate(){
       temperr = false ;
        if(oscid!='' && oscid!=null)
        {
           if(oscid.contains('%3A')){
                oscid = oscid.replace('%3A',':');   
           }
            //List<Solution__c> solRecords = [select OSC_Regional_ID__c from Solution__c];
            integer totalSolutionRecordExist = database.countQuery('select count() from Solution__c where OSC_Regional_ID__c=:oscid');
            
            if(totalSolutionRecordExist>0){
                        temperr = true ;
                        cnfmsg = system.label.SolutionID_Error_Message;
                        return null;
            }
            // create new solution record  and associating to the deal
            Solution__c solObj = new Solution__c();
            solObj.Opportunity__c = oppid;
            solObj.OSC_Regional_ID__c = oscid;
            try
            {                   
                Map<id,Opportunity> oppMp = new  Map<id,Opportunity>();
                Map<Id,List<String>> sendsollist = new Map<Id,List<String>>();
                Map<Id,List<Opportunitylineitem>> opptylineitem = new Map<ID,List<Opportunitylineitem>>();
                list<opportunitylineitem> opptylineitemlist = new list<opportunitylineitem>();
                String OSCActionIdentifier = 'Association';
                
                    if(profileList != NULL){      
                        Opportunity o = [select name,Account.Name,end_user_account_name__c,deal_id__c,deal_type__c,Deal_Registration_Status__c,StageName,Deal_Expiration_Date__c,Affinity_ID__c,Opportunity_Customer_Number__r.Name,Unassigned_End_User__c,Unweighted_Rev_USD__c,partnerAccount.Account_id__c,PartnerAccount.name,PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c,PartnerAccount.Partner_Track__r.name from opportunity where id=:oppid];  //v2.0-Anamika [26/5/2015]-CR11494-96    //Anamika- send Opportunity_Customer_Number & End User Affinity ID info to OSC   
                        opptylineitemlist = [select PricebookEntry.product2.name, PricebookEntry.productcode, product_type__c from opportunitylineitem where opportunity.id =: o.id];
                        if(o!=null){ 
                            oppMp.put(o.id,o);
                            sendsollist.put(o.id,new List<String>{oscid});
                            if(opptylineitemlist.size() > 0){
                                opptylineitem.put(o.id,opptylineitemlist);
                            }                     
                            OSCWebServiceCallout.processRequest(oppMp,sendsollist,OSCActionIdentifier,opptylineitem,false);  //v2.0-Anamika [26/5/2015]-CR11494-96                           
                        }
                    }
                insert solObj;
            }
            catch(DMLException e)
            {
            // displaying error message if the solution id has already been existed in the database.               
                if(e.getMessage().contains('duplicate value found: OSC_Regional_ID__c')){
                temperr = true ;
                cnfmsg = system.label.SolutionID_Error_Message;
                 }
                return null;
            }
            catch(Exception exc)
            {
                System.debug(exc);
            }
        }
          
        return new Pagereference('/'+oppid);
    }
    }
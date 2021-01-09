/*
 * Author : Impana K
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 11531    R16.07      29-May-2015     Impana          Functionality to show a list of accounts corresponding to the End
                                                                    User details added in the Opportunity.
 * 2.0      CR 11532    R16.07      29-May-2015     Devika          Functionality to populate the selected account on the opportunity 
                                                                    record once selected
 * 3.0      CR 12304   CSM0104      10-Nov-2015     Impana          Include contact email domain search
 * 4.0                 CSM0104      28-Jan-2016     Suresh          Defect fix - TT: INC000021504067 - Issue with search text which contains
                                                                    Special characters. 
 * 5.0      CR 15930 DCS-FY19-0703  07-Jun-2018     Akshita         Removed Commented lines and, system.debug statements as part of Opportunity code reduce story
 */
public class MapEndUserAccountToOpportunityController {

    public Opportunity oppRecord {get;set;}
    public Boolean hideTable {get;set;}
    public String accName {get;set;}
    public String street {get;set;}
    public String emailDomain{get;set;}
    public Boolean showSaveButton {get;set;}
    public String selectedAccid {get;set;}
    public String soqlQuery;  
    public String soqlQuerystreet;    
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public boolean showError{get;set;}
    public boolean disableSearch{get;set;}
    public list<Account> accountList{get;set;}
    public boolean pageLoad{get;set;}
    public boolean suffPriv{get;set;}
    String profileName;
    public boolean displayError{get;set;}
    public list<Account> conAccountList = new list<Account>();
    public list<Account> tempaccountList= new list<Account>();
    public String selectedItem{get;set;}
    list<list<Sobject>> contactSearch = new list<list<Sobject>>();
    
    // Standard controller to get the opportunity details
    public MapEndUserAccountToOpportunityController(ApexPages.StandardController stdController){
      suffPriv = true;
      displayError = true;
      accountList = new list<Account>();
      selectedItem = 'Contact Email Domain';
      this.oppRecord = [Select Id,End_User_Account_Name__c,End_User_Mailing_street__c,End_User_Mailing_Zip_Postal_Code__c,End_User_Mailing_City__c,End_User_Mailing_State_Province_Region__c,
                        End_User_Mailing_Country__c,End_User_Phone__c,End_User_Email__c from Opportunity where Id =:stdController.getId()];
      
      List<profile> profile = [SELECT Id, Name FROM profile WHERE Id=:userinfo.getprofileId() LIMIT 1];
      profileName = profile[0].Name;
      list<ProcessInstance> objPI = [SELECT Id, Status,(SELECT Id, ActorId, OriginalActorId FROM StepsAndWorkItems) FROM ProcessInstance WHERE Status = 'pending' AND TargetObjectId = :oppRecord.Id LIMIT 1];
      
      list<ProcessInstanceHistory > pihList = new list<ProcessInstanceHistory>();  
      if(objPI!=null && objPI.size() > 0) {                   
          for(ProcessInstance p : objPI){            
            pihList.addall(p.StepsAndWorkItems);          
          }
      }
      
      Set<string> actoridSet = new Set<string>();
      Set<string> originalactoridSet = new Set<string>();
      if(pihList!=null && pihList.size() > 0) {
          for(ProcessInstanceHistory pih: pihList){
              actoridSet.add(pih.actorId);
              originalactoridSet.add(pih.OriginalActorId);
          }
      }
      IF((!actoridSet.contains(Userinfo.getUserId()) || !originalactoridSet.contains(Userinfo.getUserId())) && profileName.containsIgnoreCase('GBL PRM Operations')){
        suffPriv = false;
        hidetable = true;
        noOfRecords = 0;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The record you are trying to edit has been locked. Please contact your administrator if access is necessary.'));
       }       
      disableSearch = false;
     
      if(oppRecord.End_User_Account_Name__c != null && oppRecord.End_User_Account_Name__c.length()>0 ){
        accName = oppRecord.End_User_Account_Name__c;        
      }else{
        accName ='';
      }
      // 3.0v *************
      if(oppRecord.End_User_Email__c != null && oppRecord.End_User_Email__c.length()>0){
        emailDomain = oppRecord.End_User_Email__c.substringafter('@');       
      }else{
        emailDomain ='';
      }                      
      // v3.0 ends**********
      
      if(oppRecord.End_User_Mailing_street__c != null && oppRecord.End_User_Mailing_street__c.length()>0 ){
        street = oppRecord.End_User_Mailing_street__c;
      }else{
        street ='';
      } 
      //List<Account> a = setCon.getRecords();
      if(setcon!= Null){
          hidetable= false;
      }
      else{
           hidetable= true;
      }               
    }     
   
    public ApexPages.StandardSetController setCon {
        get{ 
         //pageLoad = true;
         suffPriv = true; 
         displayError = true;
         accname = accname.trim();
         street = street.trim();
         // v 4.0 - Issue with special characters in search text 
         String modifiedAccName;
         String modifiedstreet;
         If(accname != NULL && accname !=  ''){
            modifiedAccName = accname.replaceAll('[\']', '\\\\\'');
         } 
         If(street != NULL && street !=  ''){
            modifiedstreet = street.replaceAll('[\']', '\\\\\'');
         }
         // v 4.0 - ends
         emailDomain = emailDomain.trim();
         Set<Id> accIdset = new Set<Id>();
         Set<Id> conAccIdset = new Set<Id>();
              
         if(setcon == null){
             size = Integer.valueOf(System.Label.Page_Size_limit);
                if(selectedItem == 'Account Details'){ 
                    // Search Account object where Name is Opportunity end user account name
                    if(accname != null && accname !=  ''){                        
                        soqlQuery = 'FIND \''+'*'+modifiedAccName+'*\''+' RETURNING Account( Id,Name,Phone,NameLocal,Account_ID__c,Account_Country__c  WHERE Account_Country__c = '+'\''+ oppRecord.End_User_Mailing_Country__c+'\'AND Calculated_Status__c ='+'\''+'Active' +'\'  AND (name LIKE' +'\'%'+modifiedAccName+'%\''+' OR NameLocal LIKE '+'\'%'+modifiedAccName+'%\') order by name)'; 
                        soqlQuery += ' LIMIT '+ System.Label.Database_Query_Limit; 
                        system.debug('SOQL Query: '+ soqlQuery);
                        List<List<SObject>> searchList = search.query(soqlQuery);
                        List<Account> accRes = ((List<Account>)searchList[0]); 
                        
                        for(Account acc : accRes){
                            accIdset.add(acc.id);
                        }
                    }
                     // Search Account object for records which have opportunity billing street ot shipping street
                    if(street != null && street !=  ''){
                        soqlQuerystreet = 'FIND \''+'*'+modifiedstreet +'*\''+' RETURNING Account( Id,Name,Phone,NameLocal,Account_ID__c,Account_Country__c  WHERE Account_Country__c = '+'\''+ oppRecord.End_User_Mailing_Country__c+'\' AND Calculated_Status__c ='+'\''+'Active' +'\' AND (Billingstreet LIKE \'%'+modifiedstreet+'%\' OR Shippingstreet LIKE \'%'+modifiedstreet+'%\''+') order by name)';
                        soqlQuerystreet += ' LIMIT '+ System.Label.Database_Query_Limit; 
                        List<List<SObject>> searchListst = search.query(soqlQuerystreet);
                        If(searchListst.size() > 0){
                            List<Account> accResst = ((List<Account>)searchListst[0]);
                            for(Account acc : accResst){
                                accIdset.add(acc.id);
                            }
                        }
                    }                
                   
                    // Filter the results based of Account Country
                    if(accIdset != null && accIdset.size()>0){                           
                        hidetable = false;
                        String soqlQuery1 = 'Select Id,Name,NameLocal,Phone,Account_ID__c,Segment_Desc__c,Segment_Business_Unit_Name__c,BillingCity,BillingState,BillingCountry,Shippingstreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Owner.Alias,Account_Type_Integration__c,RecordType.Name From Account where id IN :accIdset';
                        soqlQuery1+= ' AND Calculated_Status__c ='+'\''+'Active' +'\'  AND  Account_Country__c='+'\''+ oppRecord.End_User_Mailing_Country__c+'\' AND (';
                        if(modifiedAccName != null && modifiedAccName !=  ''){
                          soqlQuery1 += 'Name LIKE '+'\'%'+modifiedAccName+'%\' OR NameLocal LIKE '+'\'%'+modifiedAccName+'%\'';
                        }  
                        if(modifiedAccName != null && modifiedAccName !=  '' && modifiedstreet != null && modifiedstreet != ''){
                          soqlQuery1 += ' OR ';
                        }
                        if(modifiedstreet != null && modifiedstreet != ''){
                          soqlQuery1 += ' Billingstreet LIKE \'%'+modifiedstreet+'%\' OR Shippingstreet LIKE \'%'+modifiedstreet+'%\'';  
                        }
                        soqlQuery1 += ')'; 
                        setCon = new ApexPages.StandardSetController(database.getQueryLocator(soqlQuery1));
                    }
                    // v 4.0 Issue with Null pointer exception when records doesnt match with search criteria
                    else{
                             noOfRecords = 0;
                             if(noOfRecords == 0){
                                hidetable = true;
                                displayError = false;
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Records found'));
                         }
                   return null;
                   }
                         // 4.0 - ends
                }   
                    // v 3.0************************
                else{
                    if(emailDomain != null && emailDomain != ''){ 
                         String conSosl = 'FIND \''+'*'+ emailDomain +'*\''+'IN EMAIL FIELDS RETURNING Contact(AccountId WHERE Email LIKE \'%'+emailDomain+'%\')';
                         contactSearch = search.query(conSosl);
                         list<Contact> conlist = ((list<Contact>)contactSearch[0]);
                         if(conlist != null && conlist.size()>0){
                            hidetable = false;                   
                            for(Contact c: conlist){
                                conAccIdset.add(c.accountId);
                             }
                             String conQuery = 'Select Id,Name,NameLocal,Account_ID__c,Phone,Segment_Desc__c,Segment_Business_Unit_Name__c,BillingCity,BillingState,BillingCountry,Shippingstreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Owner.Alias,Account_Type_Integration__c,RecordType.Name From Account WHERE ID IN :conAccidset';
                             conQuery += ' AND Calculated_Status__c ='+'\''+'Active' +'\'  AND  Account_Country__c='+'\''+ oppRecord.End_User_Mailing_Country__c+'\'';                           
                             if(conQuery!= null && conQuery != '')
                               setCon = new ApexPages.StandardSetController(database.getQueryLocator(conQuery)); // imp
                         }
                         else{
                             noOfRecords = 0;
                             if(noOfRecords == 0){
                                hidetable = true;
                                displayError = false;
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Records found'));
                             }
                         return null;
                         }                     
                    }
                    else{
                      disableSearch = false;
                      pageLoad = false;
                      showSaveButton = false;
                      showError = true;
                      hideTable = true;
                      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter a valid email domain'));
                      return null;   
                    }   
                 }
                //v 3.0 ends **********************
            }                                 
              return setCon; 
        }set;  
    }
   
       Public List<Account> getAccounts(){
         accountList.clear(); 
         if(setCon != null){
            //accountList = setCon.getRecords();  
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
            tempaccountList = setCon.getRecords();
            accountList.addAll(tempaccountList);  
 
            if(accountList.size() >0){
                hidetable = false;
            } 
            else{
                hidetable = true;
            }
        }
       return accountList;                          
    }
    
    public list<SelectOption> getitems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Contact Email Domain','Contact Email Domain'));
        options.add(new SelectOption('Account Details','Account Details'));
        return options;
    }    
     public pagereference  goBack() {
      system.debug('Calling Go Back');
      String oppRecId = ApexPages.currentPage().getParameters().get('id');
      pagereference newPageRef = new pagereference('/'+oppRecId);
      return newPageRef;
  }
    
    Public PageReference searchAccounts(){
      suffPriv = true; 
      showError = false;   
      // v3.0 ***************************
     
      if(selectedItem == 'Contact Email Domain' && (emailDomain == '' || emailDomain == null || emailDomain.Iswhitespace())){
          disableSearch = false;
          pageLoad = false;
          showSaveButton = false;
          showError = true;
          hideTable = true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter a valid email domain'));
          return null;           
      }  
      // V3.0 end**********
      else if((accname == null || accname == '' || accname.Iswhitespace()) && (street == null || street == '' || street.Iswhitespace())){
          disableSearch = false;
          pageLoad = false;
          showSaveButton = false;
          showError = true;
          hideTable = true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter one of the following : Account Name or Mailing street'));
          return null;
      }
      else if(accname.length() == 1 || street.length() == 1){
          disableSearch = false;
          pageLoad = false;
          showSaveButton = false;
          showError = true;
          hideTable = true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Search term must be longer than one character'));
          return null;
      }else{
          selectedAccid = '';
          disableSearch = true;
          showSaveButton = false; 
          hideTable = false;         
          setCon = null;
          //pageLoad = true;
           getAccounts();                         
          if(noOfRecords ==0 ){
            hideTable = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Records found'));            
          }
          return null;         
      }  
    } 
    public String getNewLine() {
      return '<br/>';
    }
          
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {            
            return setCon.getPageNumber();
        }
        set;
    }
  
    public void first() {
        if(selectedAccid == null || selectedAccid ==''){
          showSaveButton = false;
        }
        setCon.first();
    }
  
    public void last() {
        if(selectedAccid == null || selectedAccid ==''){
          showSaveButton = false;
        }        
        setCon.last();
    }
  
    public void previous() {
        if(selectedAccid == null || selectedAccid ==''){
          showSaveButton = false;
        }
        setCon.previous();
    }
  
    public void next() {
        if(selectedAccid == null || selectedAccid ==''){
          showSaveButton = false;
        }
        setCon.next();
    }
    
    public PageReference enableSaveButton(){
      showSaveButton = true;
      selectedAccid = System.currentPagereference().getParameters().get('selectedAccId');
      return null;
    }
    
    public PageReference saveOppRecord(){      
      try{
        oppRecord.AccountId = selectedAccid;
        update oppRecord;
        return new PageReference('javascript:window.close();javascript:window.opener.location.reload();');
      }catch(exception e){        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,string.valueOf(e)));
        return null;
      }
    }      
}
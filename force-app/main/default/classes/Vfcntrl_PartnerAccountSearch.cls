public class Vfcntrl_PartnerAccountSearch {
  User loggedInUser;
  public case caseRecord;  
  public List<Account> accData{get;set;}
  public String loggedInUserCountry {get;set;}  
  public string searchString {get;set;}
  public string searchBy{get;set;}
  public boolean alphaNumericCheck ;
 //Error Check     
  public boolean showTable {get; set;}  
  public boolean invalidInput {get; set;}  
  public String selectedAccId {get; set;}  
  public boolean beforeSave {get; set;}    
  Id selectedRecordId;
  public Vfcntrl_PartnerAccountSearch(ApexPages.StandardController controller) {
   loggedInUser = [select Id,Profile_Name__c,contact.account_country__c,contact.Account.Account_Country__c from user where id = : UserInfo.getUserId()];
   caseRecord = [select id,Partner_Account_Name__c  from case where id = : ApexPages.currentPage().getParameters().get('id')];   
   loggedInUserCountry = loggedInUser.contact.account_country__c;
   }
  
  Public pagereference fetchResults() {
      
    If(searchString != NULL && searchString != '') {
    If(searchString.length() > 2) {
        String modifiedsearchString = searchString.replace('\\', '\\\\'); 
        if(modifiedsearchString.contains('\'')){
            modifiedsearchString = modifiedsearchString.replaceAll('[\\\\\']','\\\\\'');      
          }
        
   List<Account> accQueryList = new List<Account>(); 
   accData = new List<Account>();
   String recid = '012A0000000TR6Y'; 
   String searchquery = 'Select id,name,Billingcity,Account_ID__c,Billingstate,Billingcountry,NameLocal,Purchasing_Model__c,Account_Country__c, Calculated_Status__c,Partner_Registration__c from account where  RecordTypeId = :recid' ;

   //Search by Account
   if (searchBy == 'Name') {
    searchquery += ' And (name LIKE' + '\'%' + modifiedsearchString + '%\'' + ' OR NameLocal LIKE ' + '\'%' + modifiedsearchString + '%\' ) AND Account_Country__c = :loggedInUserCountry  AND Partner_Registration__c <> null AND Calculated_Status__c = ' + '\'' + 'Active' + '\' AND (Partner_Tier__c  = ' + '\'' + 'Direct Partner Purchase' + '\'' + ' or Partner_Tier__c  = ' + '\'' + 'Indirect Partner Purchase' + '\''+ ' ) order by name limit 1000'; 
    accData = Database.query(searchquery); //
       system.debug('****'+accData);
    }
        
   //Search by Affinity Id     
       else if (searchBy == 'Affinity') {  
       alphaNumericCheck = pattern.matches('[0-9]+', modifiedsearchString);
        if (alphaNumericCheck == false) {
        showtable = false;
        invalidInput = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Affinity_Error_Message ));
         } else {
         searchquery += ' AND Partner_Registration__c <> null AND Calculated_Status__c = ' + '\'' + 'Active' + '\' AND Account_ID__c = : modifiedsearchString ';  
         }
         accData = Database.query(searchquery);    
         }  
        if(accData.size() == 1000){
          showTable = true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.DealReg_searchLimit));
     }
      else if (accData.size() == 0 ) {
      showTable = false;
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.no_records_found));
     } else if (invalidInput == true){
      showTable = false;
     }else{
      showTable = true;
     }
    }
        else {
     showTable = false;
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_search));
    }
   } else {
    showTable = false;
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_cannot_be_blank));
   
     }return null;
   }  
  public pagereference saveFunction() {
    selectedRecordId = System.currentPagereference().getParameters().get('selectedAccId');  
     system.debug('***Record Id' +selectedRecordId); 
   if (selectedRecordId == null) {
   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Account_Select));
   showTable = true;
  } else {
   caseRecord.Partner_Account_Name__c = selectedRecordId;
   update caseRecord;
     system.debug('***PartnerAcc' +caseRecord.Partner_Account_Name__c); 
      
  }
    return null;  

  }
    
}
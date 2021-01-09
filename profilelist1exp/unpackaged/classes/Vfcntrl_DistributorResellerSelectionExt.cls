/***************************************************************************************************************************************************************
* 
* Name          : Vfcntrl_DistributorResellerSelectionExt
* Description   : controller class to support vfpage "DistributorResellerSelectionPage" 
* ---------------------------------------------------------------------------------------
* Revision  Name            Date                 CR                                         Description
* 1.0       Yeswanth      08.03.2016      12702,12739,12740,
                                              12770                       Added logic to implement account search and Distributor/Reseller contact search.
* 1.1       Suresh        15.03.2016        12771                         Added logic to insert selected contacts into opportunity team members.
* 2.0       Srikanth      28.03.2016        12991                         Added logic to search account based on the contact email.
* 2.1       Srikanth      13.04.2016        13034                         Added logic to search account based on the Account Affinity Id.
* 3.0       Yeswanth      29.03.2016        12987                         Modified controller to support tab option UI.
* 4.0       Yeswanth      07.07.2016                                      Defect fix - 2091916
* 5.0       Yeswanth      05.01.2017        13886                         Added logic to auto populate contracted disti when reseller submits deal
* 6.0       Yeswanth      11.04.2017        14159                         Added logic to allow only Storage Distributor to be added to storage Deal Reg
* 7.0       Sajid         16.05.2017        14325                         Added logic to display storage partner tier in Distributor/Reseller Account Search results
* 8.0       Mythily       17.05.2017        14324                         Added logic to display List of all available contracted resellers for the disti should be displayed on load. 
* 9.0       Yeswanth      14.06.2017        14478                         Restrict EMC Storage reseller from submitting direct fulfilment deal.
* 10.0      Yeswanth      26.10.2017     Story 3989864                    Deal Reg: GC 2.0 - Enable Storage Disti Lookup for GC EMC Storage Deal Registrations.
***************************************************************************************************************************************************************/


public without sharing class Vfcntrl_DistributorResellerSelectionExt {
 public Boolean bIsStorage {get;set;}
 public Opportunity oppRecord { get; set; }
 public string searchString { get; set; }
 public string emailSearchString;
 public string resellercontactSearchString { get; set; }
 public string distributorcontactSearchString { get; set; }
 public list < Account > accList { get; set; }
 public list < Disti_Relationship__c > distiList { get; set; }
 Public list <user> userList;   
 public List < wrapContacts > conList { get; set; }
 public Id contactQuerySearchid { get; set; }
 public Id selectedRecordId;
 public String selectedAccId { get; set; }
 public List < Contact > addedContactsList { get; set; }
 public boolean showAddedContactstable { get; set; }
 public boolean recordSelected { get; set; }
 public boolean showTable { get; set; }
 public boolean showContactTable { get; set; }
 public boolean isTier1 { get; set; }
 public boolean isRefresh { get; set; }
 public boolean isDistributor { get; set; }
 public boolean bisSubDistributor { get; set; }
 public boolean distributorContactSelection { get; set; }
 public boolean isTier1orTier2 { get; set; }
 public boolean isAccountSearchValid { get; set; }
 public boolean showOppTeamSection { get; set; }
 public boolean showContctAddtionSection { get; set; }
 public boolean hideResellerContactAddtiontab { get; set; }
 public boolean hideDistributorContactAddtiontab { get; set; }
 public boolean hideAccountselectiontab {get;set;}
 public boolean showInfoMsg{get; set; }
 public String loggedInUserCountry { get; set; }
 public List<OpportunityTeamMember> oppTeamMembers {get;set;}
 public Id loggedInUserContact;
 public Id oppOwnerContactid;  
 public boolean showDistributorContBtn {get;set;}
 public boolean isContactSelected;
 public String selectedTab {get;set;}
 public string accName{get;set;}
 Id submittedRT;
 public string distributorName{get;set;}
 public string paramOpportunityId {get; set;}
 public Boolean oppTeamEdit {get; set;}
 public Boolean distioppTeamEdit {get; set;}
 public Boolean reselleroppTeamEdit {get; set;}
 public opportunityTeamMember oppTeamMember {get; set;}
 public list<opportunityTeamMember> oppTeamMembersList {get; set;}
 public string distiparamOpportunityId {get; set;}
 public string resellerparamOpportunityId {get; set;}
 public string distiselectedAccess {get; set;}
 public string resellerselectedAccess {get; set;}
 public string selectedAccess {get; set;}
 public id deloppId{get;set;}
 public map<string, opportunityTeamMember> mapOppTeamIdAndTeamMem = new map<string, opportunityTeamMember>();
 public boolean isValidProfile {get; set;}
 public boolean isDistiValidUser {get; set;}
 public boolean isresellerValidUser {get; set;}
 public boolean isDistiPartneradminchecked{get;set;}
 public boolean isResellerPartneradminchecked{get;set;}
  //public boolean showlabel{get; set;}    
 user loggedInUser;
 public boolean alphaStringCheck ;
 public string selectedDistiCountry{get;set;}
 List<string> disticountrieslist;  
 public string accountName{get;set;}
 public Boolean disableSearchButton{get;set;}
 public Boolean isGCdeal{get;set;}
 public Boolean has2distis{get;set;}
 public Boolean isValidContractedDisti{get;set;}
 public boolean showError{get;set;}
 public boolean isValuedeal;
 public map < Id, string > validAccSearchRTs = new map < Id, string >();
 public boolean hasContractedReseller{get;set;}
 public boolean showSubmittedSection{get;set;}
 public List<Disti_Relationship__c> contractedDisti {get;set;}
 List<Id> conIds;
 Account salesAccountObj;
 set<id> masterGrouppingIds;
   
 // Constuctor
 public Vfcntrl_DistributorResellerSelectionExt(ApexPages.StandardController controller) {
 Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=9');
 } 

// Method execute on page load
public void onPageLoad(){
bIsStorage =false;
      isDistributor = false;
      bisSubDistributor =false;
      isTier1orTier2 = false;
      showTable = false;
      showOppTeamSection = false;
      showContctAddtionSection = false;
      isTier1 = false;
      isAccountSearchValid = false;
      showAddedContactstable = false;
      addedContactsList = new List < Contact > ();
      oppTeamMembers = new List < OpportunityTeamMember > ();
      showDistributorContBtn = true;
      isContactSelected = false;
      hideResellerContactAddtiontab = false;
      hideDistributorContactAddtiontab = false;
      hideAccountselectiontab = false;
      showInfoMsg = false;
     // oppTeamEdit = true;
      distioppTeamEdit = true;
      reselleroppTeamEdit = true;
      paramOpportunityId = '';
      isDistiPartneradminchecked = false;
      isResellerPartneradminchecked = false;
      disableSearchButton = true;
      isGCdeal = false;
      has2distis = false;
      isValidContractedDisti = false;
      isValuedeal = false;
      showError = false;
      hasContractedReseller = false;
     
     
  try {

   //Get recordtypeidsbyname
    validAccSearchRTs = StaticFactory.getRecordTypeIdNameMapByNames('Opportunity', new set < string > {
    'Deal Registration',
    'Deal Registration for Existing End Customer',
    'Create New Deal From LOB'
   });
   submittedRT = StaticFactory.getRecordTypeIdByName('Opportunity', 'Deal Registration-Submitted');

   oppRecord = [select id,Ownerid,name,Distributor_Name__c,partneraccount.account_country__c,partneraccount.Distribution_Sell_To_Countries__c,End_User_Mailing_Country__c, Recordtypeid, Deal_Registration_Status__c, Distributor_Reseller_Name__c,Number_of_Line_Items__c,Distributor_Reseller_Name__r.Name, PartnerAccountId,owner.contactid, (Select Channel_Product_LOB__c From OpportunityLineItems)  from opportunity where id = : ApexPages.currentPage().getParameters().get('id')];
   if(oppRecord.Number_of_Line_Items__c != 0 ){
   loggedInUser = [select Id,Profile_Name__c,contact.selected_track_account__r.account_country__c,ContactId,contact.selected_track_account__r.Distribution_Sell_To_Countries__c,contact.selected_track_account__r.Purchasing_Model__c,contact.selected_track_account__r.Partner_Tier__c  from user where id = : UserInfo.getUserId()];
   loggedInUserContact = loggedInUser.ContactId;
   oppOwnerContactid = oppRecord.owner.contactid;
      
   oppTeamMembers = getOppTeamMembers(oppRecord.Id);
    
   isValidProfile();
   isValidUser();   
      

      
    for (opportunityTeamMember tm: oppTeamMembers) {
        mapOppTeamIdAndTeamMem.put(tm.id, tm);
    }
    
   If(oppTeamMembers.size() > 0) {
    showAddedContactstable = true;
   } else {
    showInfoMsg = true;
    showAddedContactstable = false;
   }

   If(oppRecord.Distributor_Reseller_Name__c != NULL) {
    distributorName = oppRecord.Distributor_Reseller_Name__r.Name;
    selectedRecordId = oppRecord.Distributor_Reseller_Name__c;
    showOppTeamSection = true;
   } else {
    distributorName = '';
    hideResellerContactAddtiontab = true;
    hideDistributorContactAddtiontab = true;
   }  

   loggedInUserCountry = oppRecord.partneraccount.account_country__c;
    has2distis = ((Label.DealReg_GcCountries).Containsignorecase(loggedInUserCountry) || Label.DealReg_GcCountries == 'ALLCOUNTRIES')? true: false;

   String partnerType = DistiVisibilityHelperClass.getPartnerType(loggedInUser.Id);

    if (partnerType == 'Sub Distributor') {
   bisSubDistributor = true;
   
    }
   if (partnerType == 'Distributor') {
   isDistributor = true;
     
     //**10.0  if(!isGCdeal){
           hasContractedDistiorReseller();           
    //**10.0  }
    if(oppRecord.partneraccount.Distribution_Sell_To_Countries__c != Null)
    {
    disticountrieslist = new List<string>(oppRecord.partneraccount.Distribution_Sell_To_Countries__c.split(';')); 
    }
     
  // } else if (partnerType == 'Tier2' || (partnerType == 'Tier1' && oppRecord.Distributor_Name__c == 'Distribution')) {
   }
   
   else if ((partnerType == 'Tier2' || partnerType == 'Indirect Partner Purchase' || partnerType == 'Distribution') || ((partnerType == 'Tier1'||partnerType == 'Direct Partner Purchase' || partnerType == 'Direct') && oppRecord.Distributor_Name__c == 'Distribution') || (partnerType == 'Sub Distributor')) {
     isTier1orTier2 = true;
     // check for contracted disti
 //**10.0 if(!isGCdeal && (validAccSearchRTs.keySet().contains(oppRecord.Recordtypeid) || (oppRecord.Recordtypeid == submittedRT && oppRecord.Deal_Registration_Status__c == 'Recalled')) && loggedInUser.contact.selected_track_account__c == opprecord.PartnerAccountId){
     if((validAccSearchRTs.keySet().contains(oppRecord.Recordtypeid) || (oppRecord.Recordtypeid == submittedRT && oppRecord.Deal_Registration_Status__c == 'Recalled')) && loggedInUser.contact.selected_track_account__c == opprecord.PartnerAccountId){ 
           hasContractedDistiorReseller();     
       }   
   } else {
    isTier1 = True;
    hideDistributorContactAddtiontab = true;
    resellercontactAddition();
   }

   if ((validAccSearchRTs.keySet().contains(oppRecord.Recordtypeid) || (oppRecord.Recordtypeid == submittedRT && oppRecord.Deal_Registration_Status__c == 'Recalled')) && loggedInUser.contact.selected_track_account__c == opprecord.PartnerAccountId && !isValidContractedDisti) { // 4.0 - added check for logged in user account
    isAccountSearchValid = true;
   }

   If(oppRecord.Recordtypeid == submittedRT && oppRecord.Deal_Registration_Status__c == 'Submitted') {
    showOppTeamSection = true;
   }
  }else{
      showError = true;
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Add_Product_To_Opportunity));
    }
  }catch (Exception ex) {
   system.debug('----catch 1---' + ex.getMessage());
   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
  }            
}

// method to pass disti authorized countries into drop down  
public List<SelectOption> getdistiCountriesdropdown(){
   List<SelectOption> countryList = new List<SelectOption>();
    if(loggedInUserCountry != NUll) {
   countryList.add(new selectOption(loggedInUserCountry.toUpperCase(),loggedInUserCountry.toUpperCase()));
    
     if(disticountrieslist != NUll ){
         for(string temp: disticountrieslist)
              {

    if(temp!=loggedInUserCountry.toUpperCase()){
        countryList.add(new SelectOption(temp.toUpperCase(),temp.toUpperCase()));
          }
        }     
     }
    }
        return countryList;        
     
}

public pagereference  goBack() {
          system.debug('Calling Go Back');
          String stroppRecId = ApexPages.currentPage().getParameters().get('id');
          pagereference newPageRef = new pagereference('/'+stroppRecId);
          return newPageRef;
      }

   // Search functionality
 public pagereference fetchResults() {
 
  showOppTeamSection = false;
  try {
  accList  = new List<Account>();
   If(searchString == NULL || searchString == '') {
       showTable = false;
    showInfoMsg = false;
        system.debug('---276--'+searchString  );

       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_cannot_be_blank));
       return null;
   }
   If(searchString.length() <= 2) {
        showTable = false;
     showInfoMsg = false;
         system.debug('---276--'+searchString  );

     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_search));
    return null; }
    
        String modifiedsearchString = searchString.replace('\\', '\\\\'); 
        if(modifiedsearchString.contains('\'')){
            modifiedsearchString = modifiedsearchString.replaceAll('[\\\\\']','\\\\\'');      
        }
     system.debug('***modifiedsearchString: ' + modifiedsearchString);
     boolean invalidInput = false;
    
//**** Version 2.0 start*******// 

// Search by Account Name
 List<string> listsubdistributorPartnerTypes = system.label.subdisti_partner_types.split(',');
 List<string> listdistributorPartnerTypes = system.label.Distibutor_Partner_Types.split(',');
 List<string> listResellerPartnerTypes = system.label.Reseller_Partner_Types.split(',');
 
List<Account> accQueryList = new List<Account>(); 
accList = new List<Account>();
String recid = '012A0000000TR6Y' ; 

String searchquery = 'Select id,name,Billingcity,Account_ID__c,Partner_Type__c ,Billingstate,Billingcountry,NameLocal,Purchasing_Model__c,Account_Country__c, Calculated_Status__c,Partner_Registration__c from account where Sales_Motion_Deal_Registration__c = True and RecordTypeId = :recid' ;

if (accName == 'Name') {
searchquery += ' And (name LIKE' + '\'%' + modifiedsearchString + '%\'' + ' OR NameLocal LIKE ' + '\'%' + modifiedsearchString + '%\' )';

         If(isDistributor == true) {
         searchquery += ' AND Account_Country__c = :selectedDistiCountry AND (Partner_Type__c IN:listResellerPartnerTypes)';
        //  searchquery += ' AND Account_Country__c = :selectedDistiCountry AND (Partner_Type__c = ' + '\'' + 'Global Alliance' + '\'' + ' or Partner_Type__c = ' + '\'' + 'GSI' + '\''+ ' or Partner_Type__c = ' + '\'' + 'US Federal' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Solution Provider'  + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Systems Integrator' + '\''  + ' or Partner_Type__c = ' + '\'' + 'Solution Provider' + '\''+ ' or Partner_Type__c = ' + '\'' + 'System Integrator (Global Alliances)' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'MSP/CSP/Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Managed Service Provider' + '\'' + ' or  Partner_Type__c = ' + '\'' + 'Commercial General' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM' + '\')';
             if(isValueDeal){
                 searchquery += 'AND (Purchasing_Model__c LIKE ' + '\'%' + 'Indirect' + '%\' or Purchasing_Model__c LIKE ' + '\'%' + 'Distribution' + '%\') order by name limit 1000';
             }
             else{
                 searchquery += 'order by name limit 1000';
             }
         }else If(isTier1orTier2 == true || isTier1 == true) {  
           // searchquery += ' AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.partneraccount.Account_Country__c +'\'' +') AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.End_User_Mailing_Country__c +'\''+') AND (Partner_Type__c = ' + '\'' + 'Federal OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Commercial Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + '' + '\')';
              searchquery += ' AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.partneraccount.Account_Country__c +'\'' +') AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.End_User_Mailing_Country__c +'\''+') AND (Partner_Type__c IN:listdistributorPartnerTypes)';
             System.debug('>>>>>>searchquery'+searchquery);
             if(isValueDeal){
                 searchquery += 'AND Partner_Relationship__c LIKE ' + '\'%' + 'Storage' + '%\' order by name limit 1000';
             }
             else{
                 searchquery += 'order by name limit 1000';
             }
         }
         accQueryList = Database.query(searchquery);              
            If(accQueryList.size() > 0){
                for(Account acc: accQueryList){
                    If(acc.Calculated_Status__c == 'Active' && acc.Partner_Registration__c <> null ){
                        accList.add(acc);
                     }
                }
            }
 
}
// Search by Affinity ID

else if (accName == 'Affinity') {
    
 boolean alphaStringCheck = pattern.matches('[0-9]+', modifiedsearchString);

 if (alphaStringCheck == false) {
  showtable = false;
  invalidInput = true;
  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Affinity_Error_Message ));
 } else {
  searchquery += ' AND Partner_Registration__c <> null AND Calculated_Status__c = ' + '\'' + 'Active' + '\' AND Account_ID__c = : modifiedsearchString ';
system.debug('***affinitid:' +modifiedsearchString);
     system.debug('***isDistributor' +isDistributor);
     system.debug('***isTier1orTier2' +isTier1orTier2);
     system.debug('***isTier1' +isTier1);
          If(isDistributor == true) {
          //  searchquery += ' AND (Partner_Type__c = ' + '\'' + 'Global Alliance' + '\'' + ' or Partner_Type__c = ' + '\'' + 'GSI' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Solution Provider' + '\''+ ' or Partner_Type__c = ' + '\'' + 'System Integrator (Global Alliances)' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'MSP/CSP/Service Provider' + '\'' 
         //   + ' or Partner_Type__c = ' + '\'' + 'Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Managed Service Provider' + '\''+ ' or Partner_Type__c = ' + '\'' + 'US Federal' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Solution Provider'  + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Systems Integrator' + '\'' + ' or  Partner_Type__c = ' + '\'' + 'Commercial General' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Commercial General' + '\') order by name';          }
             searchquery += ' AND (Partner_Type__c IN:listResellerPartnerTypes) order by name';          }
          
            else If(isTier1orTier2 == true || isTier1 == true) {
            System.debug('>>>>>>searchquery'+searchquery);
                 // searchquery += ' AND (Partner_Type__c = ' + '\'' + 'Federal OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Commercial Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Distributor (GCC)' + '\') order by name';
                          searchquery += ' AND (Partner_Type__c IN:listdistributorPartnerTypes) order by name';
  
          }
      //** 10.0  }
          accList = Database.query(searchquery);
     system.debug('####accList' +accList);
         }
        }


//**** Search by Email  

else if (accName == 'Email') {

 If(modifiedsearchString.startsWithIgnoreCase('.com') || modifiedsearchString.startsWithIgnoreCase('.net') || modifiedsearchString.startsWithIgnoreCase('.co'))
 {  
 invalidInput = true;
  showtable = false;
  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Email_Domain_Error));
  return null;
  }
   masterGrouppingIds = new set<id>();
   masterGrouppingIds = DistiVisibilityHelperClass.getMasterGroupAccnts(modifiedsearchString); 
   String searchEmail = 'select id,name,Billingcity,Purchasing_Model__c,Partner_Type__c ,Billingstate, Billingcountry, NameLocal, Account_Country__c,Master_Group_Id__c, Account.Account_ID__c,Calculated_Status__c,Partner_Registration__c from Account where RecordTypeId = :recid AND Partner_Registration__c <> null AND Sales_Motion_Deal_Registration__c = True and Calculated_Status__c = ' + '\'' + 'Active' + '\'  and Master_Group_Id__c in :masterGrouppingIds';
 

     If(isDistributor == true) {
           searchEmail += ' AND Account_Country__c = :selectedDistiCountry AND (Partner_Type__c IN:listResellerPartnerTypes)';
   
      // searchEmail += ' AND Account_Country__c = :selectedDistiCountry AND (Partner_Type__c = ' + '\'' + 'Global Alliance' + '\'' + ' or Partner_Type__c = ' + '\'' + 'GSI' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Solution Provider' + '\''+ ' or Partner_Type__c = ' + '\'' + 'System Integrator (Global Alliances)' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'MSP/CSP/Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Managed Service Provider' + '\''+ ' or Partner_Type__c = ' + '\'' + 'US Federal' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Solution Provider'  + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Systems Integrator' + '\'' + ' or  Partner_Type__c = ' + '\'' + 'Commercial General' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Commercial General' + '\')';
         if(isValueDeal){
                 searchEmail += 'AND Purchasing_Model__c LIKE ' + '\'%' + 'Indirect' + '%\' or Purchasing_Model__c LIKE ' + '\'%' + 'Distribution' + '%\') order by name limit 1000';
             }
             else{
                 searchEmail += 'order by name';
             } 
     } else If(isTier1orTier2 == true || isTier1 == true) { 
                searchEmail += ' AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.partneraccount.Account_Country__c +'\'' +') AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.End_User_Mailing_Country__c +'\''+') AND (Partner_Type__c IN:listdistributorPartnerTypes)';
   System.debug('>>>>>>searchquery'+searchquery);
       //   searchEmail += ' AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.partneraccount.Account_Country__c +'\'' +') AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.End_User_Mailing_Country__c +'\''+') AND (Partner_Type__c = ' + '\'' + 'Federal OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Commercial Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Distributor (GCC)' + '\')';
             if(isValueDeal){
                 searchEmail += 'AND Partner_Relationship__c LIKE ' + '\'%' + 'Storage' + '%\' order by name limit 1000';
             }
             else{
                 searchEmail += 'order by name limit 1000';
             }
         }
 //** 10.0 }
    
list<Account> accountList = new list<Account>();    
 accList = Database.query(searchEmail);
 /* Set<Id> accIds = new Set<Id>();
     if(accountList.size() > 0){
         for(Account acc: accountList){
             If(acc.Calculated_Status__c == 'Active'){
                 accIds.add(acc.Master_Group_Id__c);
             }
         }
     }

String searchEmailMainQuery = 'select Email,contact.selected_track_account__c,contact.AccountId,ContactId,contact.Account.Master_Group_Id__c from user where contact.Account.Master_Group_Id__c IN: accIds AND (Email LIKE ' + '\'%' + modifiedsearchString + '%\') AND IsActive = true AND Enable_Partner_Deal_Registration__c = true';
  List<User> users = new List<User>();
  users = Database.query(searchEmailMainQuery);

  set < Id > accountIds = new set < Id > ();
  for (User u: users) {
      if(u.contactid != loggedInUserContact){
          accountIds.add(u.contact.Account.Master_Group_Id__c);
      }
   
  }

  accList = [Select Id, name, Account_ID__c, Billingcity,Purchasing_Model__c,Partner_Type__c , Billingstate, Billingcountry, NameLocal, Account_Country__c from Account where Master_Group_Id__c IN: accountIds ];   */ 
// } 
 /* else {
  invalidInput = true;
  showtable = false;
  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Email_Domain_Error));
 } */
}
else if (accName == 'sName') {

searchquery += ' And (name LIKE' + '\'%' + modifiedsearchString + '%\'' + ' OR NameLocal LIKE ' + '\'%' + modifiedsearchString + '%\' )';
  If(isDistributor == true) {
          // searchquery += ' AND Account_Country__c = :selectedDistiCountry AND (Partner_Type__c = ' + '\'' + 'Sub Distributor' + '\' )';
              searchquery += ' AND Account_Country__c = :selectedDistiCountry AND (Partner_Type__c IN:listsubdistributorPartnerTypes)';
         
                 searchquery += 'order by name limit 1000';
            
         }else If(isTier1orTier2 == true || isTier1 == true) {  
         //   searchquery += ' AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.partneraccount.Account_Country__c +'\'' +') AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.End_User_Mailing_Country__c +'\''+') AND (Partner_Type__c = ' + '\'' + 'Sub Distributor' + '\' )';
             searchquery += ' AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.partneraccount.Account_Country__c +'\'' +') AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.End_User_Mailing_Country__c +'\''+') AND (Partner_Type__c IN:listsubdistributorPartnerTypes)';
                System.debug('>>>>>>searchquery'+searchquery);
                 searchquery += 'order by name limit 1000';
             
         }

accQueryList = Database.query(searchquery);              
            If(accQueryList.size() > 0){
                for(Account acc: accQueryList){
                    If(acc.Calculated_Status__c == 'Active' && acc.Partner_Registration__c <> null ){
                        accList.add(acc);
                     }
                }
            }
  }
  
  else if (accName == 'sAffinity') {
    
 boolean balphaStringCheck = pattern.matches('[0-9]+', modifiedsearchString);

 if (balphaStringCheck == false) {
  showtable = false;
  invalidInput = true;
  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Affinity_Error_Message ));
 } else {
  searchquery += ' AND Partner_Registration__c <> null AND Calculated_Status__c = ' + '\'' + 'Active' + '\' AND Account_ID__c = : modifiedsearchString ';
system.debug('***saffinitid:' +modifiedsearchString);
     system.debug('***isDistributor' +isDistributor);
     system.debug('***isTier1orTier2' +isTier1orTier2);
     system.debug('***isTier1' +isTier1);
         
          searchquery += ' AND (Partner_Type__c IN: listsubdistributorPartnerTypes)';
System.debug('>>>>>>searchquery'+searchquery);
                 searchquery += 'order by name limit 1000';
             
         


    
      //** 10.0  }
          accList = Database.query(searchquery);
     system.debug('####accList' +accList);
         }
         
  }
 else if (accName == 'sEmail') {

 If(!modifiedsearchString.startsWithIgnoreCase('.com') && !modifiedsearchString.startsWithIgnoreCase('.net') && !modifiedsearchString.startsWithIgnoreCase('.co'))
 {  
   masterGrouppingIds = new set<id>();
   masterGrouppingIds = DistiVisibilityHelperClass.getMasterGroupAccnts(modifiedsearchString); 
   String strsearchEmail = 'select id,name,Billingcity,Purchasing_Model__c,Partner_Type__c,Billingstate, Billingcountry, NameLocal, Account_Country__c,Master_Group_Id__c, Account.Account_ID__c,Calculated_Status__c,Partner_Registration__c from Account where RecordTypeId = :recid AND Partner_Registration__c <> null AND Sales_Motion_Deal_Registration__c = True and Calculated_Status__c = ' + '\'' + 'Active' + '\'  and Master_Group_Id__c in :masterGrouppingIds';
 

     If(isDistributor == true) {
       //strsearchEmail += ' AND Account_Country__c = :selectedDistiCountry AND (Partner_Type__c = ' + '\'' + 'Sub Distributor' + '\')';
         strsearchEmail += ' AND Account_Country__c = :selectedDistiCountry AND (Partner_Type__c IN: listsubdistributorPartnerTypes)';
                 strsearchEmail += 'order by name limit 1000';
             
     } else If(isTier1orTier2 == true || isTier1 == true) { 
        //  strsearchEmail += ' AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.partneraccount.Account_Country__c +'\'' +') AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.End_User_Mailing_Country__c +'\''+') AND (Partner_Type__c = ' + '\'' + 'Sub Distributor' + '\')';
            strsearchEmail += ' AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.partneraccount.Account_Country__c +'\'' +') AND Distribution_Sell_To_Countries__c includes('+ '\''+ oppRecord.End_User_Mailing_Country__c +'\''+') AND (Partner_Type__c IN:listsubdistributorPartnerTypes)';
             System.debug('>>>>>>searchquery'+searchquery);
                 strsearchEmail += 'order by name limit 1000';
             
         }
 //** 10.0 }
    
//list<Account> accountList = new list<Account>();    
 accList = Database.query(strsearchEmail);
 
 } 
  else {
  invalidInput = true;
  showtable = false;
  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Email_Domain_Error));
 }
}

        
        
//**** Version 2.0 End*******// 
     //handle 1000 records VF error
     if(accList.size() == 1000){
          showTable = true;
          showInfoMsg = false;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.DealReg_searchLimit));

     }
     else if (accList.size() == 0 && invalidInput == false ) {
      showTable = false;
      showInfoMsg = false;
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.no_records_found));
     } else if (invalidInput == true){
      showTable = false;
      showInfoMsg = false;
     }else{
      showTable = true;
      showInfoMsg = false; 
     }
    } /*else {
     showTable = false;
     showInfoMsg = false;
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_search));
    } */
  /* } else {
    showTable = false;
    showInfoMsg = false;
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_cannot_be_blank));
   } 
  }*/ catch (Exception ex) {
   system.debug('----catch 2---' + ex.getMessage());
  }
  return null;
 }

 // Save functionality
 public PageReference saveFunction() {
  recordSelected = true;
 try{
  selectedRecordId = System.currentPagereference().getParameters().get('selectedAccId');
  if (selectedRecordId == null) {
   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Account_Select));
   isRefresh = false;
   showTable = true;
   showOppTeamSection = false;
  } else {
   oppRecord.Distributor_Reseller_Name__c = selectedRecordId;
   update oppRecord;
   hideResellerContactAddtiontab = false;
   if (isTier1 == true) {
    hideDistributorContactAddtiontab = true;
   } else {
    hideDistributorContactAddtiontab = false;
   }
   showInfoMsg = true;

   opportunity oppUpdate = [Select Id, Distributor_Reseller_Name__r.Name from Opportunity where Id = : oppRecord.Id];
 //  searchString = oppUpdate.Distributor_Reseller_Name__r.Name;
   distributorName= oppUpdate.Distributor_Reseller_Name__r.Name;
   showtable = false;
   showOppTeamSection = true;
   oppTeamMembers = getOppTeamMembers(oppRecord.Id);
   If(oppTeamMembers.size() > 0) {
    showAddedContactstable = true;
   } else {
    showAddedContactstable = false;
   }
  }
 }   
   catch (Exception ex) {
   system.debug('----catch 3---' + ex.getMessage());
  }    
 return null;
 }

 public void backtoAccountSearch() {
  selectedTab = 'Accountselectiontab';
  showtable = false;
  showContctAddtionSection = false;
  //showInfoMsg = true;
 }

 // Add Reseller Contacts Tab action in account search page
 public pagereference resellercontactAddition() {
     try{
  reselleroppTeamEdit = true; 
  showAddedContactstable = true;
  isResellerPartneradminchecked = false;
  distributorContactSelection = false;
  selectedTab = 'resellerTab';
  showContctAddtionSection = true;
  resellercontactSearchString = '';
  showContactTable = false;
  showOppTeamSection = true;
  opportunity oppUpdate = [Select Id,Distributor_Reseller_Name__c,Distributor_Reseller_Name__r.Name,PartnerAccount.name from Opportunity where Id = : oppRecord.Id];

            /*******Defect fix - 4.0 Start*******/
      //  if(DistiVisibilityHelperClass.getPartnerTypeFromAccount(oppUpdate.Distributor_Reseller_Name__c) == 'Distributor') {
        if(DistiVisibilityHelperClass.getPartnerTypeFromAccount(oppUpdate.PartnerAccount.id) != 'Distributor') {
       
                contactQuerySearchid = oppRecord.PartnerAccountId;
                accountName = oppUpdate.PartnerAccount.name;
         } else{        
             contactQuerySearchid = oppUpdate.Distributor_Reseller_Name__c;
             accountName = oppUpdate.Distributor_Reseller_Name__r.name;
         }
        /******4.0 End******/
     }
      catch (Exception ex) {
   system.debug('----catch 4---' + ex.getMessage());
  }
  return null;

 }

 // Add Distributor Contacts Tab action in account search page  
 public pagereference distributorContactAddition() {
     try{
         
   showAddedContactstable = true;
   distioppTeamEdit = true;
  isDistiPartneradminchecked = false;
   distributorContactSelection = true;  
  selectedTab = 'distributorTab';
  distributorcontactSearchString = '';
  showContctAddtionSection = true; 
  showContactTable = false;
  showOppTeamSection = true;
  opportunity oppUpdate = [Select Id,Distributor_Reseller_Name__c,Distributor_Reseller_Name__r.Name,PartnerAccount.name from Opportunity where Id = : oppRecord.Id];
         
         
         /*******Defect fix - 4.0 Start*******/
            if(DistiVisibilityHelperClass.getPartnerTypeFromAccount(oppUpdate.Distributor_Reseller_Name__c) == 'Distributor' || (IsDistributor==False && DistiVisibilityHelperClass.getPartnerTypeFromAccount(oppUpdate.Distributor_Reseller_Name__c) == 'Sub Distributor')) {
                contactQuerySearchid = oppUpdate.Distributor_Reseller_Name__c;
                accountName = oppUpdate.Distributor_Reseller_Name__r.Name;   
         } else{
             contactQuerySearchid = oppRecord.PartnerAccountId;
             accountName = oppUpdate.PartnerAccount.name;
         }
        /******4.0 End******/   
     }
   catch (Exception ex) {
   system.debug('----catch 5---' + ex.getMessage());
  }
  return null;
 }

 // contact Search functionality
 public pagereference contactSearch(){
 
  showTable = false;
  isAccountSearchValid = false;
  conIds = new list<id>();
 
  conList = new List < wrapContacts > ();
   if (distributorContactSelection == true) {
   emailSearchString = distributorcontactSearchString;
  } else if (distributorContactSelection == false) {
   emailSearchString = resellercontactSearchString;
  }
  try {
      salesAccountObj = [SELECT Id,Name,Master_Group_Id__c,Partner_Type__c ,Partner_Track__c FROM Account WHERE id =: contactQuerySearchid];
       conIds = DistiVisibilityHelperClass.getContactsUnderSalesMotion(salesAccountObj);              
 if((distributorContactSelection == true && isDistiPartneradminchecked == false) || (distributorContactSelection == false && isResellerPartneradminchecked == false)){ 
   if (emailSearchString != NULL && emailSearchString != '') {
    if (emailSearchString.length() > 2) {
     string modifiedemailSearchString = emailSearchString.replaceAll('[\']', '\\\\\'');      
     String userQuery = 'Select Id, Name, Contact.Name, Contact.Phone, contact.selected_track_account__c, contact.selected_track_account__r.name, contact.MobilePhone, contact.Email, contact.Title, contact.selected_track_account__r.partner_type__c from User where IsActive = true  AND Enable_Partner_Deal_Registration__c = true and ContactId !=: loggedInUserContact AND ContactId !=: oppOwnerContactid AND ContactId IN : conIds AND (Contact.Email LIKE' + '\'%' + modifiedemailSearchString + '%\'' + ' OR Contact.Name LIKE ' + '\'%' + modifiedemailSearchString + '%\') AND Contact.Job_Function__c != ' + '\'' + 'Executives' + '\' order by Contact.name';
     List < User > userContactList = Database.query(userQuery);

     If(userContactList.size() != 0) {
      for (User userObj: userContactList) {
       wrapContacts wrapObj = new wrapContacts();
       wrapObj.contactName = userObj.contact.Name;
       wrapObj.contactAccName = salesAccountObj.name;
       wrapObj.contactPhone = userObj.contact.Phone;
       wrapObj.contactMobilePhone = userObj.contact.MobilePhone;
       wrapObj.contactEmail = userObj.contact.Email;
       wrapObj.contactTitle = userObj.contact.Title;
       wrapObj.userWrapObj = userObj;
       conList.add(wrapObj);
       showContactTable = true;
       showOppTeamSection = false;
      }
     } else {
      showContactTable = false;
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.no_records_found));
     }
    } else {
     showContactTable = false;
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Search_term));
    }
   } else {
    showContactTable = false;
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Contact_email_name));

   }
  }
    else{
        distributorcontactSearchString = '';
        resellercontactSearchString = '';
      string partnerAdminquery = 'Select Id, Name, Contact.Name, Contact.Phone, contact.selected_track_account__c, contact.selected_track_account__r.name, contact.MobilePhone, contact.Email, contact.Title, contact.selected_track_account__r.partner_type__c from User where IsActive = true  AND Enable_Partner_Deal_Registration__c = true and ContactId !=: loggedInUserContact AND ContactId !=: oppOwnerContactid and contactId = : conIds AND Enable_Partner_Admin__c = true AND Contact.Job_Function__c != ' + '\'' + 'Executives' + '\' order by Contact.name';
      List < User > partnerAdminList = Database.query(partnerAdminquery);
      If(partnerAdminList.size() != 0) {
      for (User userObj: partnerAdminList) {
       wrapContacts wrapObj = new wrapContacts();
       wrapObj.contactName = userObj.contact.Name;
       wrapObj.contactAccName = salesAccountObj.name;
       wrapObj.contactPhone = userObj.contact.Phone;
       wrapObj.contactMobilePhone = userObj.contact.MobilePhone;
       wrapObj.contactEmail = userObj.contact.Email;
       wrapObj.contactTitle = userObj.contact.Title;
       wrapObj.userWrapObj = userObj;
       conList.add(wrapObj);
       showContactTable = true;
       showOppTeamSection = false;
      }
     } else {
      showContactTable = false;
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.no_partner_admins_found));
     }
    }
  }
   catch (Exception ex) {
   system.debug('----catch 6---' + ex.getMessage());
  }
 
  return null;
 }

 // Add Distributor/Reseller action in contact search page
 public pagereference contactAddition() {
   
  isContactSelected = false;
  List < OpportunityTeamMember > oppTeamList = new List < OpportunityTeamMember > ();
  List < OpportunityShare > oppShareList = new List < OpportunityShare > ();

     
  try{
  for (wrapContacts wrapCon: conList) {
   If(wrapCon.isresellerSelected == true || wrapCon.isdistributorSelected == true) {
    isContactSelected = true;
    showContctAddtionSection = true;
    showContactTable = false;
    showOppTeamSection = true;

    // Insert OpportunityTeamMember
    OpportunityTeamMember oppteam = new OpportunityTeamMember();
    oppteam.Opportunityid = oppRecord.Id;
    oppteam.UserId = wrapCon.userWrapObj.Id;

    If(salesAccountObj.partner_type__c == 'Distributor (GCC)' || salesAccountObj.partner_type__c == 'OEM Distributor' || salesAccountObj.partner_type__c == 'Commercial Distributor' || salesAccountObj.partner_type__c == 'Federal Distributor' || salesAccountObj.partner_type__c == 'Federal OEM Distributor' ) {
     oppteam.TeamMemberRole = 'Distributor Contact';
      } else {
     oppteam.TeamMemberRole = 'Reseller Contact';
    }
    oppTeamList.add(oppteam);

    //  Insert OpportunityShare
    //OpportunityShare oppShare = new OpportunityShare();
    //oppShare.OpportunityId = oppRecord.Id;
    //oppShare.UserOrGroupId = wrapCon.userWrapObj.Id;

   If(distributorContactSelection == true) 
 {
     If(wrapCon.distributorassignedPermission == 'Read') {
      oppteam.OpportunityAccessLevel = 'Read';
     } else If(wrapCon.distributorassignedPermission == 'Write') {
      oppteam.OpportunityAccessLevel = 'Edit';
     }
    } else {
     If(wrapCon.resellerassignedPermission == 'Read') {
      oppteam.OpportunityAccessLevel = 'Read';
     } else If(wrapCon.resellerassignedPermission == 'Write') {
      oppteam.OpportunityAccessLevel = 'Edit';
     }
    }

   // oppShareList.add(oppShare);
   }
  }

  insert oppTeamList;
   //insert oppShareList;

  If(isContactSelected == false) {
   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Contact_select));
  }
  oppTeamMembers = getOppTeamMembers(oppRecord.Id);
  If(oppTeamMembers.size() > 0) {
   showAddedContactstable = true;
  } else {
   showAddedContactstable = false;
  }
  }
   catch (Exception ex) { 
   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Oops. Something went wrong. Please try again.'));
   showContactTable = false;
  }
  return null;
 }

 public List < OpportunityTeamMember > getOppTeamMembers(Id oppId) {
  List < String > teamMemberRoles = new List < String > {
   'Distributor Contact',
   'Reseller Contact'
  };
        

  return [Select Id, Opportunityid,opportunity.name, UserId, TeamMemberRole, User.Name,user.Enable_Partner_Admin__c, OpportunityAccessLevel, User.Contact.Name
   from OpportunityTeamMember where Opportunityid = : oppId and TeamMemberRole IN: teamMemberRoles
  ];
 }

 // Wrapper Class 
 public class wrapContacts {
  public User userWrapObj { get;set;}
  public Boolean isresellerSelected { get;set;}
  public Boolean isdistributorSelected { get;set;}
  public String contactName {get;set;}
  public String contactAccName {get;set;}
  public String contactPhone { get;set;}
  public String contactMobilePhone {get;set;}
  public String contactEmail {get;set;}
  public String contactTitle {get;set;}
  public String resellerassignedPermission { get;set;}
  public String distributorassignedPermission { get; set;}
     
  // Constructor    
  public wrapContacts() {
   userWrapObj = new User();
   isresellerSelected = false;
   isdistributorSelected = false;
   resellerassignedPermission = NULL;
   distributorassignedPermission = NULL;
  }
 }
 public void editOppTeamMem() {
// showlabel = True;
//  oppTeamEdit = false;
 // showAddedContactstable = true;
 
     List < User > userContactList = new List<USer>();
  for (opportunityTeamMember tm: oppTeamMembers) {
   mapOppTeamIdAndTeamMem.put(tm.id, tm);
  }  


  if (distributorContactSelection == true) {
       distioppTeamEdit = false;
       showAddedContactstable = false;
   if (mapOppTeamIdAndTeamMem != null && mapOppTeamIdAndTeamMem.containsKey(distiparamOpportunityId) && mapOppTeamIdAndTeamMem.get(distiparamOpportunityId) != null) {

    oppTeamMember = mapOppTeamIdAndTeamMem.get(distiparamOpportunityId);
    distiselectedAccess = oppTeamMember.OpportunityAccessLevel;

   }   
      }
   else if (distributorContactSelection == false) {
       reselleroppTeamEdit = false;
       showAddedContactstable = false;
   if (mapOppTeamIdAndTeamMem != null && mapOppTeamIdAndTeamMem.containsKey(resellerparamOpportunityId) && mapOppTeamIdAndTeamMem.get(resellerparamOpportunityId) != null) {

    oppTeamMember = mapOppTeamIdAndTeamMem.get(resellerparamOpportunityId);
    resellerselectedAccess = oppTeamMember.OpportunityAccessLevel;
   }   
  }
 }
    
 public void updateTeamrole() {
 try{ 
  if (distributorContactSelection == true) {
   oppTeamMember.OpportunityAccessLevel = distiselectedAccess;
   distioppTeamEdit = true;
  } else if (distributorContactSelection == false) {
   oppTeamMember.OpportunityAccessLevel = resellerselectedAccess;
   reselleroppTeamEdit = true;
  }  
 update oppTeamMember;
  //oppTeamEdit = true;
  showAddedContactstable = True;
    }
   catch (Exception ex) {
   system.debug('----catch 7---' + ex.getMessage());
  }    
 }

 public void cancel() {
  showAddedContactstable = true;
  showOppTeamSection = true;
 distioppTeamEdit = true;
 reselleroppTeamEdit = true;
 }
  
public void delRow(){ 
    
    try{
        for (opportunityTeamMember tm: oppTeamMembers) {
            mapOppTeamIdAndTeamMem.put(tm.id, tm);
        }
      
        If( distributorContactSelection == false ){
            If(mapOppTeamIdAndTeamMem != null && mapOppTeamIdAndTeamMem.containsKey(resellerparamOpportunityId) && mapOppTeamIdAndTeamMem.get(resellerparamOpportunityId) != null){
              delete mapOppTeamIdAndTeamMem.get(resellerparamOpportunityId);
            }
        }else {
            If(mapOppTeamIdAndTeamMem != null && mapOppTeamIdAndTeamMem.containsKey(distiparamOpportunityId) && mapOppTeamIdAndTeamMem.get(distiparamOpportunityId) != null){
              delete mapOppTeamIdAndTeamMem.get(distiparamOpportunityId);
            }
        }  
        oppTeamMembers = getOppTeamMembers(oppRecord.Id); 
    }catch(System.DmlException dmlex){
        System.debug('---------DML Exception on Remove link---'+ dmlex.getMessage() );
    }catch(Exception ex){
        System.debug('---------Generic Exception on Remove link---'+ ex.getMessage() );
    }
}
    
 public boolean isValidProfile(){
        isValidProfile = false;
        String profileName = StaticFactory.getCurrentUserDetails().Profile.Name;
        if(profileName.contains('GBL PRM Operations') || profileName == 'System Administrator' || loggedInUser.id == oppRecord.Ownerid) 
        {
            isValidProfile = true;
        }
        return isValidProfile;
    }
    
 public void isValidUser(){
  isresellerValidUser =false;
  isDistiValidUser = false;
   Set<id> resellerPartnerAdmins = new Set<id>();
   Set<id> distiPartnerAdmins = new Set<id>();   
         oppTeamMembers = getOppTeamMembers(oppRecord.Id);
     if(oppTeamMembers.size() > 0){
            for(opportunityteammember otm:oppTeamMembers) {
                if(otm.TeamMemberRole == 'Reseller Contact' && otm.user.Enable_Partner_Admin__c == true){
                            resellerPartnerAdmins.add(otm.userid); 
                }
               else if(otm.TeamMemberRole == 'Distributor Contact' && otm.user.Enable_Partner_Admin__c == true){
                            distiPartnerAdmins.add(otm.userid);   
                }
            }
     }
       if((resellerPartnerAdmins.size() > 0 && resellerPartnerAdmins.contains(loggedInUser.id )))
         {
            isresellerValidUser =true;
         }
     else if (distiPartnerAdmins.size() > 0 &&  distiPartnerAdmins.contains(loggedInUser.id)){
           isDistiValidUser = true;
     }
     else{
         isresellerValidUser =false;
         isDistiValidUser = false;
     }
    }
 
//Method to validate contractedDisti
 public void hasContractedDistiorReseller(){
  showTable = false;
  accList = new list<account>();
  Set<String> channelProductLob = new Set<String>(); 
 channelProductLob = new Set<String>(); 
 
  contractedDisti = new list<Disti_Relationship__c>();
  list<string> listlOBsToCheck = system.label.DealReg_Value_Deal_Check.split(',');

     try{
           for(OpportunityLineItem oppLineItem : oppRecord.OpportunityLineItems){
            if(oppLineItem.Channel_Product_LOB__c != null && (oppLineItem.Channel_Product_LOB__c.containsIgnoreCase('EMC')|| oppLineItem.Channel_Product_LOB__c.containsIgnoreCase('STORAGE'))){
                channelProductLob.add(oppLineItem.Channel_Product_LOB__c.touppercase());
               }
         //      if(isTier1orTier2){
               for(string temp:listlOBsToCheck){
                  if(oppLineItem.Channel_Product_LOB__c != null && oppLineItem.Channel_Product_LOB__c.containsIgnoreCase(temp)){
                  isValuedeal = true; 
                                    
                  }
                } 
           //   }   
           }  
                             
               if(channelProductLob.size() > 0){
               bIsStorage = true;
                   if(isTier1orTier2){
                   // Query on Disti_Relationship__c object to fetch the contracted disti associated with partner account
                     contractedDisti = [select id,Disti_Account__c,Disti_Account_Name__c,Contracted_Disti__c,Disti_Account__r.Name,Disti_Account__r.NameLocal,Disti_Account__r.Account_ID__c,Disti_Account__r.Account_Country__c,Disti_Account__r.Billingcity,Disti_Account__r.Billingstate,Disti_Account__r.BillingCountry,Disti_Account__r.Id,Requested_Distributor__c,Requested_Distributor_Status__c,Requested_Distributor_By__c,Requested_Distributor_Date__c,Secondary_Storage_Preferred_Distributor__c, Requested_Secondary_Distributor__c, Requested_Secondary_Distributor_Status__c from Disti_Relationship__c where Reseller_Account__c = :oppRecord.PartnerAccountId];
                   if(contractedDisti!= null && contractedDisti.size() > 0 && contractedDisti[0].Contracted_Disti__c == TRUE){
                          if(has2distis){
                          accList = [select  id,Name, NameLocal,Partner_Type__c ,Account_ID__c, Account_Country__c, Purchasing_Model__c,Billingcity, Billingstate, BillingCountry from account where id=:contractedDisti[0].Disti_Account__c OR id=:contractedDisti[0].Secondary_Storage_Preferred_Distributor__c];          
                          isValidContractedDisti = true;                    
                          showTable = true;   
                          showInfoMsg = false;  
                          }else{
                          isValidContractedDisti = true;                    
                          oppRecord.Distributor_Reseller_Name__c = contractedDisti[0].Disti_Account__c;
                          update oppRecord; 
                          distributorName= contractedDisti[0].Disti_Account_Name__c;
                          hideResellerContactAddtiontab = false;
                          hideDistributorContactAddtiontab = false;                        
                          }
                   }else if(contractedDisti!= null && contractedDisti.size() > 0 && contractedDisti[0].Contracted_Disti__c == FALSE && (contractedDisti[0].Disti_Account__c != null || contractedDisti[0].Secondary_Storage_Preferred_Distributor__c != null) && isValuedeal){               
                        accList = [select  id,Name, NameLocal,Partner_Type__c ,Account_ID__c, Account_Country__c, Purchasing_Model__c,Billingcity, Billingstate, BillingCountry from account where id=:contractedDisti[0].Disti_Account__c];          
                        if(has2distis){
                        accList = [select  id,Name, NameLocal,Partner_Type__c ,Account_ID__c, Account_Country__c, Purchasing_Model__c,Billingcity, Billingstate, BillingCountry from account where id=:contractedDisti[0].Disti_Account__c OR id=:contractedDisti[0].Secondary_Storage_Preferred_Distributor__c];          
                        }
                        showTable = true;   
                        isAccountSearchValid = true;
                        showInfoMsg = false;  
                    /****9.0 Start****/                     
                    } else if((contractedDisti.size() == 0 || (contractedDisti.size() > 0 && (contractedDisti[0].Disti_Account__c == null && contractedDisti[0].Secondary_Storage_Preferred_Distributor__c == null))) && isValuedeal ){
                          if(contractedDisti.size() > 0 && (contractedDisti[0].Disti_Account__c == null && contractedDisti[0].Secondary_Storage_Preferred_Distributor__c == null) && (contractedDisti[0].Requested_Distributor__c != null || contractedDisti[0].Requested_Secondary_Distributor__c != null) && (contractedDisti[0].Requested_Distributor_Status__c == 'Submitted' || contractedDisti[0].Requested_Distributor_Status__c == 'In Progress' || contractedDisti[0].Requested_Secondary_Distributor_Status__c == 'Submitted' || contractedDisti[0].Requested_Secondary_Distributor_Status__c == 'In Progress' )){
                              showSubmittedSection = true;
                               showError = true;
                               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Deal_Reg_Distributor_Setup_Req_Msg));                            
                            }else{
                              showError = true;                      
                         List<String> listSwitchmsg = Label.DealReg_Setup_Link.split('##');
                              String err = listSwitchmsg[0];
                              err = err+'<a href="/apex/DistributorSetupRequestForm?id=' + oppRecord.id + '" target="_top" style="color:blue;">'+listSwitchmsg[1]+'</a>';
                              err = err+listSwitchmsg[2];
                              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err)); 
                      }  
                   }  
                   /****9.0 End****/              
                }
                   else if(isDistributor){
                       contractedDisti = [select id,Reseller_Account__c,Reseller_Account__r.Purchasing_Model__c,Reseller_Account__r.name,Reseller_Account__r.Billingcity,Reseller_Account__r.Account_ID__c,Reseller_Account__r.Billingstate,Reseller_Account__r.Billingcountry,Reseller_Account__r.NameLocal,Reseller_Account__r.Account_Country__c,Reseller_Account__r.calculated_Status__c,Reseller_Account__r.Partner_Registration__c from Disti_Relationship__c where (Disti_Account__c = :oppRecord.PartnerAccountId OR Secondary_Storage_Preferred_Distributor__c = :oppRecord.PartnerAccountId) and Contracted_Disti__c = TRUE and Reseller_Account__c != null order by name limit 1000];
                       if(contractedDisti!= null && contractedDisti.size() > 0){
                           hasContractedReseller = true;
                       //these lines are added for CR 14324 to show resellers on page load
                       distiList  = new List<Disti_Relationship__c>();
                       distiList.addall(contractedDisti ); 
                       showTable = true; 
                       showInfoMsg = false;
                       }           
                }            
            }         
       }
       catch (Exception ex) {
       system.debug('----catch 8---' + ex.getMessage() + ex.getLineNumber());
     }   
   }
   
public void fetchContractedResellers(){
  id partnerAccId = oppRecord.PartnerAccountId;      
  showOppTeamSection = false;
  try {
   distiList  = new List<Disti_Relationship__c>();
   If(searchString != NULL && searchString != '') {
    If(searchString.length() > 2) {
        String modifiedsearchString = searchString.replace('\\', '\\\\'); 
        if(modifiedsearchString.contains('\'')){
            modifiedsearchString = modifiedsearchString.replaceAll('[\\\\\']','\\\\\'');      
        }
     system.debug('***modifiedsearchString: ' + modifiedsearchString);
     boolean invalidInput = false;
    
// Search by Account Name

List<Disti_Relationship__c> accQueryList = new List<Disti_Relationship__c>(); 
        
if (accName == 'Name') { 
String searchquery = 'Select id,Reseller_Account__c,Reseller_Account__r.Purchasing_Model__c,Reseller_Account__r.name,Reseller_Account__r.Billingcity,Reseller_Account__r.Account_ID__c,Reseller_Account__r.Billingstate,Reseller_Account__r.Billingcountry,Reseller_Account__r.NameLocal,Reseller_Account__r.Account_Country__c,Reseller_Account__r.calculated_Status__c,Reseller_Account__r.Partner_Registration__c from Disti_Relationship__c where (Disti_Account__c = :partnerAccId OR Secondary_Storage_Preferred_Distributor__c = :partnerAccId) AND Contracted_Disti__c = TRUE';
searchquery += ' AND (Reseller_Account__r.name LIKE' + '\'%' + modifiedsearchString + '%\'' + ' OR Reseller_Account__r.NameLocal LIKE ' + '\'%' + modifiedsearchString + '%\' ) AND Reseller_Account__r.Account_Country__c = :selectedDistiCountry order by name limit 1000';
         System.debug('start account name first query:'+DateTime.now()) ; 
         distiList = Database.query(searchquery);
         System.debug('end account name first query:'+DateTime.now()) ;    
}


// Search by Affinity ID

else if (accName == 'Affinity') {

 boolean alphaStringCheck = pattern.matches('[0-9]+', modifiedsearchString);

 if (alphaStringCheck == false) {
  showtable = false;
  invalidInput = true;
  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Affinity_Error_Message ));
 } else {
  String affinityQuery = 'Select id,Reseller_Account__r.name,Reseller_Account__r.Purchasing_Model__c,Reseller_Account__r.Billingcity,Reseller_Account__r.Account_ID__c,Reseller_Account__r.Billingstate,Reseller_Account__r.Billingcountry,Reseller_Account__r.NameLocal,Reseller_Account__r.Account_Country__c,Reseller_Account__r.Calculated_Status__c,Reseller_Account__r.Partner_Registration__c from Disti_Relationship__c where (Disti_Account__c = :partnerAccId OR Secondary_Storage_Preferred_Distributor__c = :partnerAccId) AND Reseller_Account__r.Account_ID__c = : modifiedsearchString AND Contracted_Disti__c = TRUE order by name' ;
    distiList = Database.query(affinityQuery);
         }
  }

//**** Search by Email  

else if (accName == 'Email') {

 If(!modifiedsearchString.startsWithIgnoreCase('.com') && !modifiedsearchString.startsWithIgnoreCase('.net') && !modifiedsearchString.startsWithIgnoreCase('.co'))
 {
  String searchEmail = 'select Reseller_Account__c,Reseller_Account__r.name from Disti_Relationship__c where (Disti_Account__c = :partnerAccId OR Secondary_Storage_Preferred_Distributor__c = :partnerAccId) AND Contracted_Disti__c = TRUE AND Reseller_Account__r.Account_Country__c = :selectedDistiCountry order by name' ;
    
list<Disti_Relationship__c> distisList = new list<Disti_Relationship__c>();     
 distisList = Database.query(searchEmail);
  Set<Id> accIds = new Set<Id>();
     if(distisList.size() > 0){
         for(Disti_Relationship__c temp: distisList){
                 accIds.add(temp.Reseller_Account__c);
         }
     }
   
String searchEmailMainQuery = 'select Email,contact.selected_track_account__c,contact.Account.Master_Group_Id__c,ContactId from user where contact.Account.Master_Group_Id__c IN: accIds AND (Email LIKE ' + '\'%' + modifiedsearchString + '%\') AND IsActive = true AND Enable_Partner_Deal_Registration__c = true';
 
  List<User> users = new List<User>();
  users = Database.query(searchEmailMainQuery);
  set < Id > accountIds = new set < Id > ();
  for (User u: users) {
      if(u.contactid != loggedInUserContact){
          accountIds.add(u.contact.Account.Master_Group_Id__c);
      }  
  }
  String distiquery = 'Select Reseller_Account__c,Reseller_Account__r.name,Reseller_Account__r.Purchasing_Model__c,Reseller_Account__r.Account_ID__c,Reseller_Account__r.Billingcity,Reseller_Account__r.Billingstate,Reseller_Account__r.Billingcountry,Reseller_Account__r.NameLocal,Reseller_Account__r.Account_Country__c from Disti_Relationship__c where Reseller_Account__c IN: accountIds and (Disti_Account__c = :partnerAccId OR Secondary_Storage_Preferred_Distributor__c = :partnerAccId) and Contracted_Disti__c = TRUE';
  distiList = Database.query(distiquery);    
 }  else {
  invalidInput = true;
  showtable = false;
  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Email_Domain_Error));
 }
}
     //handle 1000 records VF error
     if(distiList.size() == 1000){
          showTable = true;
          showInfoMsg = false;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.DealReg_searchLimit));

     }
     else if (distiList.size() == 0 && invalidInput == false ) {
      showTable = false;
      showInfoMsg = false;
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.no_records_found));
     } else if (invalidInput == true){
      showTable = false;
      showInfoMsg = false;
     }else{
        showTable = true;
      showInfoMsg = false; 
     }
    } else {
     showTable = false;
     showInfoMsg = false;
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_search));
    }
   } else {
    showTable = false;
    showInfoMsg = false;
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_cannot_be_blank));
   }
  } catch (Exception ex) {
   system.debug('----catch 9---' + ex.getMessage());
  }
 }
}
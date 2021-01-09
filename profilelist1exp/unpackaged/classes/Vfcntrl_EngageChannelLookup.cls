/***************************************************************************************************************************************************************
 * 
 * Name          : Vfcntrl_EngageChannelLookup
 * Description   : 
 * ---------------------------------------------------------------------------------------
 * Revision  Name            Date                 CR                                         Description
 * 1.0      Srikanth       27-06-2106            13265
 * 2.0      Rajashekar     13-11-2107            15105                                       Removed GC Logic in Partner Account Search
 * 3.0      Sakshi         9-7-2018              16138                                       Reduce code
 * 4.0     Yeswanth        16-12-2018                                                        PAM changes
 ***************************************************************************************************************************************************************/

public class Vfcntrl_EngageChannelLookup {

    public Opportunity oppRecord;
    public Account salesAccountObj;
    public string endUserAccountCountry;
    public string searchString {get;set;}
    public string accName {get;set;}
    public String accountCountry {get;set;}
    public list < Account > accList {get;set;}
    public boolean showTable { get; set; }
    public boolean showPartnerContacts { get; set; }
    public id selectedRecordId;
    public list<wrapContacts> userContactList{get;set;}
    public id selectedContactId;
    public boolean showError{get;set;}
    public Boolean IsAccountTeamMember;
    public Boolean bCheckPoint;
   // Public boolean bProductsadded=false;
    List<Id> conIds;
    set<id> masterGrouppingIds;
    Public list<Disti_Relationship__c> listdistaccounts;


     // Constuctor
     public Vfcntrl_EngageChannelLookup(ApexPages.StandardController controller) {
     bCheckPoint=false;
      showTable = false;
      showPartnerContacts = false;
      showError = false;
       listdistaccounts=new list<Disti_Relationship__c>();
      Id CurrentUserId = UserInfo.getUserId();
      Id ChannelOppRTypeId = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', TRUE);
      Id EndUSerRecordTypeId = IdLookupUtils.getRecordTypeId('End-User Account', 'Account', TRUE);
      IsAccountTeamMember = false;

      oppRecord = [Select id, Ownerid, name, Account_Country__c, CloseDate,Number_of_Line_Items__c, Account.Account_Country__c, Customer_consent_to_engage_partner__c, Deal_Reg_Oppty__c, AccountId, Engage_Channel_Opportunity__c, RecordTypeId
                        from opportunity where id = : ApexPages.currentPage().getParameters().get('id')];
       for(opportunitylineitem objOpportunity:[Select id,Channel_Product_LOB__c from opportunitylineitem where Opportunityid =:oppRecord.id and Channel_Product_LOB__c !=null]) {
   //    bProductsadded=true;
       if(objOpportunity !=null && (objOpportunity.Channel_Product_LOB__c).toLowerCase().contains('emc') && objOpportunity.Channel_Product_LOB__c!= null){
          bCheckPoint=true;
            }
           } 
      endUserAccountCountry = oppRecord.Account.Account_Country__c;

      if (oppRecord.CloseDate < System.Today()) {
       showError = true;
       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Segement Opportunity Book Date is less than Today Date, Please go back and change the Book Date.'));
      }
        if(oppRecord.Number_of_Line_Items__c==0){
               showErrorMsg(System.Label.Add_Product_To_Opportunity);
           }
      if (oppRecord.Customer_consent_to_engage_partner__c == false) {
          showErrorMsg('Customer consent is required to route an opportunity to a channel partner');
      }
      
  /*    if(bProductsadded==false){
          showErrorMsg('Kindly add products to the Opportunity to proceed further');
      } */

      if (oppRecord.Deal_Reg_Oppty__c == 'Yes' && oppRecord.RecordTypeId == ChannelOppRTypeId) {
       showErrorMsg('The Channel Engagement feature is not available for existing Deal Registration opportunities');
      }

      if (CurrentUserId == oppRecord.OwnerId) {
       IsAccountTeamMember = true;
      }

      List < AccountTeamMember > AccTeamMember = [SELECT TeamMemberRole, UserId FROM AccountTeamMember WHERE AccountId = : oppRecord.AccountId AND TeamMemberRole IN: (Label.Deal_Opportunity_Valid_Acc_Team_Roles).split(',') AND Account.RecordTypeId = : EndUSerRecordTypeId];
      for (AccountTeamMember temp: AccTeamMember) {
       if (CurrentUserId == temp.UserId) {
        IsAccountTeamMember = true;
       }
      }

      If(IsAccountTeamMember == false) {
          showErrorMsg('Insufficient privileges. You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary');
      }
     }
     
     private void showErrorMsg(String strMsg){
         showError = true;
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strMsg));
     }
     // Account Countries PickList
     public List < SelectOption > getaccountCountries() {
      List < SelectOption > DistiCountriesList = new List < SelectOption > ();
      If(endUserAccountCountry != null) {
       DistiCountriesList.add(new selectOption(endUserAccountCountry.toUpperCase(), endUserAccountCountry.toUpperCase()));
      }
      Schema.DescribeFieldResult fieldResult = Account.Distribution_Sell_To_Countries__c.getDescribe();
      List < Schema.picklistEntry > ple = fieldResult.getPicklistValues();
      for (Schema.picklistEntry temp: ple) {
       if (temp.getLabel() != endUserAccountCountry) {
        DistiCountriesList.add(new selectOption(temp.getLabel(), temp.getValue()));
       }
      }
      return DistiCountriesList;
     }

     // Search function
     Public pagereference fetchResults() {
      // clearing the list of account records that we are showing in vf page after clicking on the "search" button.
      if (accList != null) {
       accList.clear();
       showTable = false;
      }
      /************************  Modified code for Engache Channel ********************************************/
              
       showPartnerContacts = false;
        list<string> listResellerPartnerTypes = system.label.Reseller_Partner_Types.split(',');
       If(searchString != NULL && searchString != '') {
        If(searchString.length() > 2) {
         String modifiedsearchString = searchString.replace('\\', '\\\\');
         if (modifiedsearchString.contains('\'')) {
          modifiedsearchString = modifiedsearchString.replaceAll('[\\\\\']', '\\\\\'');
         }
         boolean invalidInput = false;
            
    // Search By 
         List < Account > accQueryList = new List < Account > ();
         accList = new List < Account > ();
         String recid = '012A0000000TR6Y';
     //   String searchquery = 'Select id,name,Billingcity,Account_ID__c,Billingstate,Billingcountry,NameLocal,Account_Country__c, Calculated_Status__c,Partner_Registration__c from account where Sales_Motion_Deal_Registration__c = True AND RecordTypeId = :recid AND (Partner_Tier__c = ' + '\'' + 'Tier 1' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Direct' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Direct Partner Purchase' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'Tier 2' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Distribution' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'InDirect Partner Purchase' + '\'' + ')' + 'AND (Partner_Type__c = ' + '\'' + 'Global Alliance' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'System Integrator (Global Alliances)' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'MSP/CSP/Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'GSI' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Managed Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Systems Integrator' + '\'' + ' or  Partner_Type__c = ' + '\'' + 'Commercial General' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM' + '\'' + ' or  Partner_Type__c = ' + '\'' + 'OEM Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'US Federal' + '\'' + ' ) ';
           String searchquery = 'Select id,name,Billingcity,Account_ID__c,Billingstate,Billingcountry,NameLocal,Account_Country__c, Calculated_Status__c,Partner_Registration__c from account where Sales_Motion_Deal_Registration__c = True AND RecordTypeId = :recid AND (Partner_Tier__c = ' + '\'' + 'Tier 1' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Direct' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Direct Partner Purchase' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'Tier 2' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Distribution' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'InDirect Partner Purchase' + '\'' + ')' + 'AND (Partner_Type__c IN:listResellerPartnerTypes)';
          if (accName == 'Affinity') {
           boolean alphaStringCheck = pattern.matches('[0-9]+', modifiedsearchString);
           if (alphaStringCheck == false) {
            showtable = false;
            invalidInput = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Affinity_Error_Message));
           } else {
            searchquery += ' AND Partner_Registration__c <> null  AND Calculated_Status__c = ' + '\'' + 'Active' + '\' AND Account_ID__c = : modifiedsearchString ';
            searchquery += '  order by name limit 1000';
            accList = Database.query(searchquery);
           }
          }  

          // Search By AccountName        
          else if (accName == 'Name') {
           searchquery += ' AND Account_Country__c = :accountCountry And (name LIKE' + '\'%' + modifiedsearchString + '%\'' + ' OR NameLocal LIKE ' + '\'%' + modifiedsearchString + '%\' )';
           searchquery += ' order by name limit 1000';
           accQueryList = Database.query(searchquery);
           If(accQueryList.size() > 0) {
            for (Account acc: accQueryList) {
             If(acc.Calculated_Status__c == 'Active' && acc.Partner_Registration__c <> null) {
              accList.add(acc);
             }
            }
           }
          } 

          // Search by Email
          else if (accName == 'Email') {
           If(!modifiedsearchString.startsWithIgnoreCase('.com') && !modifiedsearchString.startsWithIgnoreCase('.net') && !modifiedsearchString.startsWithIgnoreCase('.co')) {
             masterGrouppingIds = new set<id>();
             masterGrouppingIds = DistiVisibilityHelperClass.getMasterGroupAccnts(modifiedsearchString); 
            String searchEmail = 'select id,name,Account_ID__c, Billingcity,Purchasing_Model__c, Billingstate, Billingcountry, NameLocal, Account_Country__c ,Master_Group_Id__c,Calculated_Status__c,Partner_Registration__c from Account where Sales_Motion_Deal_Registration__c = True AND RecordTypeId = :recid AND Partner_Registration__c <> null  and Calculated_Status__c = ' + '\'' + 'Active' + '\'  and Master_Group_Id__c in :masterGrouppingIds';
        //    searchEmail += ' AND Account_Country__c = :accountCountry AND (Partner_Tier__c = ' + '\'' + 'Tier 1' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Direct' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'Direct Partner Purchase' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'Tier 2' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Distribution' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'InDirect Partner Purchase' + '\'' + ')' + ' AND (Partner_Type__c = ' + '\'' + 'Global Alliance' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'System Integrator (Global Alliances)' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'MSP/CSP/Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'GSI' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Managed Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Cloud Service Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal OEM Systems Integrator' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Systems Integrator' + '\'' + ' or  Partner_Type__c = ' + '\'' + 'Commercial General' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM' + '\'' + ' or  Partner_Type__c = ' + '\'' + 'OEM Solution Provider' + '\'' + ' or Partner_Type__c = ' + '\'' + 'US Federal' + '\'' + ' ) ';
              searchEmail += ' AND Account_Country__c = :accountCountry AND (Partner_Tier__c = ' + '\'' + 'Tier 1' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Direct' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'Direct Partner Purchase' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'Tier 2' + '\'' + ' or Partner_Tier__c= ' + '\'' + 'Distribution' + '\'' + ' or Partner_Tier__c = ' + '\'' + 'InDirect Partner Purchase' + '\'' + ')' + ' AND (Partner_Type__c IN:listResellerPartnerTypes)';

            list < Account > accountList = new list < Account > ();
            accList = Database.query(searchEmail);
          /*  Set < Id > accIds = new Set < Id > ();
            if (accountList.size() > 0) {
             for (Account acc: accountList) {
              If(acc.Calculated_Status__c == 'Active') {
               accIds.add(acc.Master_Group_Id__c);
              }
             }
            }
          String searchEmailMainQuery = 'select Email,contact.selected_track_account__c,contact.Master_Group_Id__c,ContactId from user where contact.Account.Master_Group_Id__c IN: accIds AND (Email LIKE ' + '\'%' + modifiedsearchString + '%\') AND IsActive = true AND Enable_Partner_Deal_Registration__c = true';
            List < User > users = new List < User > ();
            users = Database.query(searchEmailMainQuery);
            Set < Id > accountIds = new Set < Id > ();
            for (User u: users) {
          accountIds.add(u.contact.Account.Master_Group_Id__c);
            }
           accList = [Select Id, name, Account_ID__c, Billingcity,Purchasing_Model__c, Billingstate, Billingcountry, NameLocal, Account_Country__c from Account where Master_Group_Id__c IN: accountIds];    */
           } else {
            invalidInput = true;
            showtable = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Email_Domain_Error));
           }
          } 

         if (accList.size() == 1000) {
          showTable = true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.DealReg_searchLimit));

         } else if (accList.size() == 0 && invalidInput == false) {
          showTable = false;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.no_records_found));

         } else if (invalidInput == true) {
          showTable = false;
         } else {
          showTable = true;
         }

        } else {
         showTable = false;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_search));
        }
       } else {
        showTable = false;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_cannot_be_blank));
       }
    //  } // End of Engage chanel modification else.  
      return null;
     }

     // CR:13268  Method to fetch the Partner Contacts from Selected Account results
     public PageReference fetchPartnerContacts() {
       conIds = new list<id>();
 
      try {
       selectedRecordId = System.currentPagereference().getParameters().get('selectedAccId');     
      if (selectedRecordId != null) {
        listdistaccounts=[select id,Disti_Account__c,Disti_Account_Name__c,Contracted_Disti__c,Disti_Account__r.Name,Disti_Account__r.NameLocal,Disti_Account__r.Account_ID__c,Disti_Account__r.Account_Country__c,Disti_Account__r.Billingcity,Disti_Account__r.Billingstate,Disti_Account__r.BillingCountry,Disti_Account__r.Id,Requested_Distributor__c,Requested_Distributor_Status__c,Requested_Distributor_By__c,Requested_Distributor_Date__c,Secondary_Storage_Preferred_Distributor__c, Requested_Secondary_Distributor__c, Requested_Secondary_Distributor_Status__c from Disti_Relationship__c where Reseller_Account__c = :selectedRecordId];
          
          salesAccountObj = [SELECT Id, Name,Master_Group_Id__c,Partner_Track__c,Partner_Track__r.Purchase_Path__c,Partner_Track__r.Speciality_Product_Purchase_Path__c FROM Account WHERE id =: selectedRecordId];
        
          if((listdistaccounts.isEmpty() || (listdistaccounts !=null && listdistaccounts.get(0).Disti_Account__c ==null && listdistaccounts.get(0).Secondary_Storage_Preferred_Distributor__c==null)) && (((salesAccountObj.Partner_Track__r.Purchase_Path__c=='Distribution' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='InDirect Partner Purchase' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='Tier 2') && bCheckPoint == true )|| (bCheckPoint == true && (salesAccountObj.Partner_Track__r.Purchase_Path__c=='Direct' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='Direct Partner Purchase') && (salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='Distribution' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='InDirect Partner Purchase' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c==null)))){
           showTable = false;
         showPartnerContacts = false;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Disti_Setup_Error_Msg));
        
          }
         else{
        conIds = DistiVisibilityHelperClass.getContactsUnderSalesMotion(salesAccountObj);  
           
        User loggedInUser = [select Id, Profile_Name__c, contact.account_country__c, contact.Account.Account_Country__c, ContactId, contact.account.Distribution_Sell_To_Countries__c from user where id = : UserInfo.getUserId()];
        Id loggedInUserContact;
        If(loggedInUser.ContactId != NULL) {
         loggedInUserContact = loggedInUser.ContactId;
        }

        string userconQuery = 'Select Id, Name, Contact.Name, Contact.Phone, Contact.AccountId, contact.account.name, contact.MobilePhone, contact.Email, contact.Title, Contact.Account.partner_type__c,Enable_Partner_Admin__c from User where IsActive = true AND Enable_Partner_Deal_Registration__c = true and ContactId !=: loggedInUserContact and ContactId IN : conIds order by Contact.name limit 1000 ';
        list < User > userList = Database.query(userconQuery);

        If(userList.size() > 0) {
         showTable = false;
         showPartnerContacts = true;
         userContactList = new list < wrapContacts > ();
         for (User usr: userList) {
          wrapContacts wrapCont = new wrapContacts();
          wrapCont.userWrapObj = usr;
          wrapCont.contactName = usr.Contact.Name;
          wrapCont.contactAccName = salesAccountObj.Name;
          wrapCont.contactPhone = usr.Contact.Phone;
          wrapCont.contactMobilePhone = usr.Contact.MobilePhone;
          wrapCont.contactEmail = usr.Contact.Email;
          wrapCont.contactTitle = usr.Contact.Title;
          userContactList.add(wrapCont);
         }
        } 
        else{
        showTable = true;
         showPartnerContacts = false;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Partner Contacts are not available for selected Account'));
        }
       }
       } else {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'You must select Account'));
       }
      } catch (QueryException qex) {
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, qex.getMessage()));
      } catch (Exception ex) {
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
      }
      return null;
     }

     // Wrapper Class  
     public class wrapContacts {
      public User userWrapObj { get;set;}
        public String contactName {get;set;}
        public String contactAccName {get;set;}
        public String contactPhone { get;set;}
        public String contactMobilePhone {get;set;}
        public String contactEmail {get;set;}
        public String contactTitle {get;set;}

      // Constructor    
      public wrapContacts() {
       userWrapObj = new User();
      }
     }

     public PageReference redirectToDealEditPage() {
        selectedContactId = System.currentPagereference().getParameters().get('selectedContUserId');
        if (selectedContactId == null) {
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'You must select atleast one contact'));
      }
      else if((salesAccountObj.Partner_Track__r.Purchase_Path__c=='Distribution' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='InDirect Partner Purchase' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='Tier 2' )|| (bCheckPoint == true && (salesAccountObj.Partner_Track__r.Purchase_Path__c=='Direct' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='Direct Partner Purchase') && (salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='Distribution' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='InDirect Partner Purchase' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c==null))){
       String strredirectToDealStr = '/apex/DealOppCreation?SegmentOppID=' + oppRecord.Id + '&EngageChannelCB=' + true + '&partnerUserId=' + selectedContactId + '&salesmotionID=' + selectedRecordId + '&'+System.Label.PartnerUserLookup+'=PartnerUserLookup' + '&fulfilmentpath=Distribution'+'&checkpoint=' + bCheckPoint; 
      PageReference page = new PageReference(strredirectToDealStr);
       return page;
     }
       else {
      String redirectToDealStr = '/apex/DealOppCreation?SegmentOppID=' + oppRecord.Id + '&EngageChannelCB=' + true + '&partnerUserId=' + selectedContactId + '&salesmotionID=' + selectedRecordId + '&'+System.Label.PartnerUserLookup+'=PartnerUserLookup' + '&fulfilmentpath=Direct Fulfilment'; 
       PageReference page = new PageReference(redirectToDealStr);
       return page;
      }
      return null;
     }

     public PageReference cancelFunction() {
      showPartnerContacts = false;
      showTable = false;
      accList = new List < Account > ();
      userContactList = new list < wrapContacts > ();
      searchstring = '';
      return null;
     }

     public PageReference cancelOppAction() {
      return PageUtils.redirect('/' + oppRecord.Id);
     }
}
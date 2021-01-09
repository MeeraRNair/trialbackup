/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Jiji        05-Nov-2012     14.2                Controller for single lead submission.
2.0         Jiji        08-Aug-2013     14.10       8598    Make Phone or email mandatory instead of Mobile
3.0         Annie       08-Aug-2013     14.10       8602    Modify Lead Submission Success Message
4.0         Annie       26-Sep-2013     14.10        --     SIT Defect 81395
5.0         Annie       20-Jan-2014     15.03        --     SIT Defect 91544
6.0         Jiji        20-Aug-2014     15.10       10022   To Check Solution Provide Can Contact Me check box.
7.0         Sazleen     07-Jan-2015     16.03       10748   Create a way to delineate between Dell internal and Partner loads for leads.
8.0         Josie       13-Aug-2015     17.02       11812   Create & Submit "Channel Lead 2.0" through Partner Portal 
*/

//public with sharing class CMAP_SubmitSingleLeadController {
public class CMAP_SubmitSingleLeadController {
    Public Id campId{get;set;}
    Public Id eCusId {get;set;}
    Public String campName{get;set;}
    Public String campVehicle{get;set;}
    public Lead mylead{get;set;}
    Public Boolean showSecondPage{get;set;}
    Public Boolean showFirstPage{get;set;}
    Public Boolean ShowSuccessmsg {get;set;}
    Public Boolean ShowErrorMsg{get;set;}
    Public Boolean  showSaveContactCheckbox = False;
    Public Boolean  isEndCust{get; set;}
    Public Boolean  notEndCust{get; set;}
    Public End_Customer_Contact__c endContact ;
    Public End_Customer__c endCustomer ;
    Campaign campaignrecord = new Campaign();
    Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
    
    String URL;
    Id userId;
    // for action support
    public Lead ldObj{ get; set; }
    public CMAP_SubmitSingleLeadController(ApexPages.StandardController controller) {
        ldObj = new lead();
        showFirstPage = TRUE;
        showSecondPage = False;
        ShowSuccessmsg  = False;
        ShowErrorMsg = False;
        showSaveContactCheckbox = False;
        isEndCust = False;
        notEndCust = TRUE;
        try{
            mylead= new lead();
            mylead.RecordTypeId = leadRTId;
            campId=ApexPages.currentPage().getParameters().get('campid'); 
            // Ver 5.0: code Start
            // campaignrecord = [select id, Name, Type from Campaign where id = :campId];
            // Ver 5.0: code End
            // Adding Record type
            // campaignrecord = [select id, Name, Campaign_Vehicle__c from Campaign where id = :campId];
            campaignrecord = [select id, Name, Campaign_Vehicle__c, RecordType.Name from Campaign where id = :campId];
            campName=campaignrecord.Name;
            string y = ApexPages.currentPage().getURL();
            if(y.contains('eCusId')){
                isEndCust = TRUE;
                notEndCust = False;
                eCusId = ApexPages.currentPage().getParameters().get('eCusId');
                ldObj.Search_My_Customer__c = eCusId;
                populateCompanyInfo();
                for(End_Customer_Contact__c endCustContact :[select id, Name 
                                                          from End_Customer_Contact__c 
                                                          where End_Customer__c = :eCusId AND Status__c = 'Active'
                                                          order by CreatedDate limit 1]){
               //if(endCustContact.size()> 0){
                   ldObj.Search_My_Customer_Contact__c = endCustContact.Id;
                   populateContactInfo();
               }
            }      
            // Ver 5.0: code Start
            //campVehicle = campaignrecord.Type;
            campVehicle = campaignrecord.Campaign_Vehicle__c;
            // Ver 5.0: code End
            userId = UserInfo.getUserId();
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Lead_submission_error));  
            ShowErrorMsg = TRUE;
            showFirstPage = False;
        } 
    }
    
    public Boolean getshowSaveContactCheckbox (){
        if(ldObj.Search_My_Customer__c!=NULL && ldObj.Search_My_Customer_Contact__c == NULL ){
            showSaveContactCheckbox = TRUE;
        }
        return showSaveContactCheckbox ;    
    }
    
    public void setshowSaveContactCheckbox (Boolean newshowSaveContactCheckbox ){
        this.showSaveContactCheckbox = newshowSaveContactCheckbox ;    
    }
    
    public Lead getmylead(){
        return mylead;    
    }
    
    public void setmylead(Lead newLead){
        this.mylead= newLead;    
    }
    
    public Void nextButton(){
       if(mylead.MobilePhone == NULL && mylead.Phone == NULL && mylead.email == NULL){
           ShowErrorMsg = TRUE;
           //Ver 2.0: code Start
           //pageUtils.AddError(System.Label.CMAP_Phone_or_Mobile_mandatory);
           pageUtils.AddError(System.Label.CMAP_Phone_or_Email_mandatory);
           //Ver 2.0: code End
       }
       else{
            showSecondPage = TRUE;
            showFirstPage = False;
       }   
    }
    
    public Void previousButton(){
         showSecondPage = FALSE;
         showFirstPage = TRUE;
    }
    
    public pagereference submitButton(){
        User currentUser = new User();
        Account  acc = new Account();
        Id superUserId;
        try { 
            if(userId != NULL){
                currentUser = [select Id, AccountId from User where Id = :userId];
            }        
            if(currentUser.AccountId != NULL){
              acc = [select id, ownerId from Account where id = :currentUser.AccountId];
              for(User superUser :[select Id, AccountId from User where AccountId = :currentUser.AccountId 
                              and Enable_As_Partner_Lead_Super_User__c = TRUE 
                              AND Isactive = TRUE order by CreatedDate limit 1]){
                  myLead.Partner_Admin__c = superUser.Id; 
              }
            }
         }
         catch(Exception e){
             system.debug('----excemption---'+e);
         }
         myLead.Campaign__c = campId;
         //myLead.RecordTypeId = leadRTId;
         
         //8.0 - LM2.0
         if(campaignRecord.RecordType.Name == 'Campaign 2.0') {
                Id cl2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
                myLead.RecordTypeId = cl2RTId;
                myLead.Lead_Type__c = 'Inbound';
                myLead.LeadSource = 'Partner';
                myLead.Dell_Partner_can_contact_me__c = True;
         }//End of 8.0 - LM2.0
         
         mylead.Status = 'Open - Channel Lead';
         mylead.Partner_User__c =userId ;
         mylead.Partner_Account__c = currentUser.AccountId;
         mylead.Partner_Account_Owner_ApiOnly__c = acc.ownerId;
         mylead.Solution_provider_Can_contact_Me__c = True; // Ver 6.0: 15.10
         mylead.Are_you_a_Dell_Partner__c = 'Yes'; // v7.0
         
         try {
            insert mylead;
            ShowErrorMsg = False;
         } 
         catch (Exception e) {
             system.debug('----excemption---'+e);
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Lead_submission_error));
             ShowErrorMsg = TRUE;
         }
         
         if(ShowErrorMsg == False){
             displaySuccessMsg ();
         }
         try {
            endContact = new End_Customer_Contact__c();
            if(mylead.Save_Contact_Details_for_selected_Custom__c == TRUE && 
                ldObj.Search_My_Customer_Contact__c == NULL &&
                ldObj.Search_My_Customer__c != NULL){
                endContact.End_Customer__c = ldObj.Search_My_Customer__c;  
                endContact.Name = mylead.FirstName;
                endContact.Email__c = mylead.Email;
                endContact.Last_Name__c = mylead.LastName;
                endContact.Fax__c = mylead.Fax;
                endContact.Mobile__c = mylead.MobilePhone ;
                endContact.Title__c = mylead.Title;
                endContact.Phone__c = mylead.Phone;
                endContact.Status__c = 'Active';
                if(endContact != NULL){
                    insert endContact;
                } 
            }
        } 
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Lead_submission_error));
            ShowErrorMsg = TRUE;
        }            
        if(ShowErrorMsg == False) {  // Ver 4.0: code, Condition added
            mylead.clear();
        }
        return null;
    }
    
    public Void displaySuccessMsg(){
         showSecondPage = False;
         ShowSuccessmsg = True;
         ShowErrorMsg = False;
         Lead newLead = new Lead();
         try{
             if(mylead.Id != Null){
                  newLead= [select id , Lead_Tracking_ID__c  from Lead where Id = :mylead.Id];
             }
         }catch(Exception e){
             system.debug('----excemption---'+e);
         }
         PageUtils.AddConfirm(System.Label.CMAP_Lead_Saved_Successfully+' - '+newLead.Lead_Tracking_ID__c + '<br/><br/>' + System.Label.CMAP_InProgress + '<br/>' + System.Label.CMAP_Success_Message); //Ver 3.0: code, Message added
         //}
    }
  
    public Pagereference populateCompanyInfo(){
        // To clear the contact details if the My Customer value is changed.
        ldObj.Search_My_Customer_Contact__c = NULL ;
        mylead.FirstName = '';
        mylead.Email = '';
        mylead.LastName = '';
        mylead.Fax = '';
        myLead.MobilePhone = '';
        myLead.Title = '';
        myLead.Phone = '';
        if(ldObj.Search_My_Customer__c != NULL){
            endCustomer = [select Name, Website__c,Mailing_street__c,Zip_Code__c,Mailing_country__c,
                          Mailing_city__c,Mailing_State__c,Account_Industry__c  
                          from End_Customer__c where Id = :ldObj.Search_My_Customer__c];
            mylead.Company = endCustomer.Name;
            mylead.Country = endCustomer.Mailing_country__c;
            mylead.Website = endCustomer.Website__c;
            mylead.Street = endCustomer.Mailing_street__c;
            myLead.Industry = endCustomer.Account_Industry__c;
            myLead.City = endCustomer.Mailing_city__c;
            myLead.State = endCustomer.Mailing_State__c;
            myLead.PostalCode  = endCustomer.Zip_Code__c;
            myLead.Search_My_Customer__c = ldObj.Search_My_Customer__c;
        }
        return NULL;
    }
    
    public Pagereference populateContactInfo(){
        if(ldObj.Search_My_Customer_Contact__c != NULL ){
            showSaveContactCheckbox = False;
        }
        if(ldObj.Search_My_Customer_Contact__c != NULL){
            endContact = [select Title__c,Phone__c, Name, Mobile__c, Last_Name__c, Fax__c, Email__c  
                          from End_Customer_Contact__c where Id = :ldObj.Search_My_Customer_Contact__c];
            
            mylead.FirstName = endContact.Name;
            mylead.Email = endContact.Email__c;
            mylead.LastName = endContact.Last_Name__c;
            mylead.Fax = endContact.Fax__c;
            myLead.MobilePhone = endContact.Mobile__c;
            myLead.Title = endContact.Title__c;
            myLead.Phone = endContact.Phone__c;
            myLead.Search_My_Customer_Contact__c = ldObj.Search_My_Customer_Contact__c;
        }
        else{
            mylead.FirstName = '';
            mylead.Email = '';
            mylead.LastName = '';
            mylead.Fax = '';
            myLead.MobilePhone = '';
            myLead.Title = '';
            myLead.Phone = '';
            myLead.Search_My_Customer_Contact__c =NULL;
        }
        return NULL;
    }
    
}
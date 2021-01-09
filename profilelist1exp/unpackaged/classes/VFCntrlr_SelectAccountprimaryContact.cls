/**************************************************************
* Name          : VFCntrlr_SelectAccountprimaryContact
* Description   : Class for  VFC_AccountPlanSummary
*
* Version        Date          Author                 Remark
* -------------------------------------------------------------
* 1.0            xx/xx/xxxx    xxxxx                  Controller creation by unknown
* 2.0            07/07/2015    Shahiruni Wahida       16.07 - Story 171046: Primary Contact lookup filtered on "valid" Status
* 3.0			 07/05/2019		Sneha				  To incoporate PAM Changes
***************************************************************/


public without sharing class VFCntrlr_SelectAccountprimaryContact {
    
    //Declaration
    public List<Contact> listSalesMotionActiveContacts {get;set;}
    private Account AccountRecord;
    public string id;
    public String aAccountId  {get;set;}
    public String masterGroupId{get;set;}
    public String selectedContactId {get;set;}
    public String primaryContact{get;set;}
    public Boolean reShowContact {get;set;}
    public Boolean reExistingprimaryContact {get;set;}
    public Boolean reListOfOtherContact {get;set;}
    public Boolean HideBackButton {get;set;}
    public List<cContact> AllAccountContactList {get; set;}
    public List<cContact> ExistingprimaryContact {get; set;}
    public List<cContact> ListOfOtherContact{get; set;}
    public string SelectedPriContactId {get; set;}
    public string ExistPriContactId {get; set;}
    public string returnUrl;
    public string PartnerTrackID{get;set;}
    string redirectUrl;
    public Boolean showHeader_SideBar{get;set;}        
    // Constructor
    public Id endUserAccountRecordTypeId;
    public Id partnerAccountRecordTypeId;
    public VFCntrlr_SelectAccountprimaryContact(ApexPages.StandardController controller)
    {
        
        System.debug('***************** In the Class Constructor *****************');
        
        endUserAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId();
        partnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        
        // Redirect to the user to RETURL page
        showHeader_SideBar=true;
        if(ApexPages.currentPage().getParameters().containsKey('retUrl'))
        {
            returnUrl=ApexPages.currentPage().getParameters().get('retUrl');
            showHeader_SideBar=false;
        }
        
        
        
        this.AccountRecord = (Account)controller.getRecord();
        aAccountId = AccountRecord.Id; 
        system.debug('>>>aAccountId'+aAccountId );
        Account acc = [SELECT id,Primary_Contact__c,Partner_Track__c,Master_Group_Id__c,RecordTypeId
                       FROM Account 
                       WHERE Id=:aAccountId];
        
        if(acc.RecordTypeId == partnerAccountRecordTypeId){
            if(String.isNotBlank(acc.Master_Group_Id__c)){
                masterGroupId = acc.Master_Group_Id__c;
            }
            if(String.isNotBlank(acc.Partner_Track__c)){
                PartnerTrackID =acc.Partner_Track__c;  
            }
        }
        /* else if(acc.RecordTypeId == endUserAccountRecordTypeId){
masterGroupId = aAccountId; 
}*/
        primaryContact=acc.Primary_Contact__c;
        selectedContactId = ApexPages.currentPage().getParameters().get('selConId');
        
        //Commented for new query of filtered contacts in 2.0
        //AllAccountContactList= getContact();
        
        //2.0
        AllAccountContactList= getFilteredContacts();
        
        
        System.debug('## AllAccountContactList : '+ AllAccountContactList);    
        
        //Get the list of Primary Contact and list of Other Contact for the Account
        ExistingprimaryContact= new List<cContact>();
        ListOfOtherContact = new List<cContact>();
        
        //Iterate all contacts
        for (cContact AccountContact : AllAccountContactList) {
            System.debug('## AccountContact.con.Id : '+ AccountContact.con.Id +primaryContact);
            if(AccountContact.con.Id == primaryContact){
                AccountContact.selected = true;
                ExistingprimaryContact.add(AccountContact);
                ExistPriContactId = AccountContact.con.Id;
            }
            else{
                ListOfOtherContact.add(AccountContact);
                if(ListOfOtherContact != null){
                    for(cContact co : ListOfOtherContact ){
                        co.selected = False;
                    }
                }
                
            }
        }
        System.debug('## ExistingprimaryContact : '+ ExistingprimaryContact);
        System.debug('## ListOfOtherContact : '+ ListOfOtherContact);                        
        //rendered apex:pageMessage
        If (AllAccountContactList.size() > 0) 
            reShowContact = True;
        else
            reShowContact = False;
        //rendered ExistingPrimaryPageBlock
        If (ExistingprimaryContact.size() > 0)
            reExistingprimaryContact = False;
        else
            reExistingprimaryContact= True;
        
        
        //rendered ListOfOtherContactPageBlock
        If (ListOfOtherContact.size() > 0) 
            reListOfOtherContact= False;
        else
            reListOfOtherContact= True;
        
    }
    
    
    //Commented for new query of filtered contacts in 2.0
    //Get all the contacts belong to the Account
    /*
public List<cContact> getContact(){
List<cContact> AccContactList;

if(AccContactList== null){

AccContactList= new List<cContact>();

for(Contact AccContact: [SELECT Id, FirstName, LastName, AccountId, Primary_Contact__c, Email, Account.Primary_Contact__c
FROM Contact
WHERE AccountId =:aAccountId limit 1000]) {
AccContactList.add(new cContact(AccContact,AccContact.Primary_Contact__c));              
}

}

return AccContactList;
}
*/
    
    
    //2.0 Get all the filtered contacts belong to the Account              
    public List<cContact> getFilteredContacts(){
        List<cContact> AccContactList;
        List<String> listEligibleTracksId;
        listSalesMotionActiveContacts = new List<Contact>();          
        if(AccContactList== null){
            AccContactList= new List<cContact>();
            
            if(String.isNotBlank(masterGroupId)){
                
                for(Contact AccContact: [SELECT Id, FirstName, LastName, AccountId, Primary_Contact__c, Email, Account.Primary_Contact__c, Status__c,EligibleTracks__c 
                                         FROM Contact
                                         WHERE Partner_User_Active__c = true 
                                         AND AccountId =:masterGroupId
                                         AND Status__c IN ('Customer','Prospect','Marketing Suspect','marketing suspest')
                                         limit 1000]) {
                                             system.debug('>>>AccContact'+AccContact);   //('Pending Verification','Invalid - Bad Email','Invalid - Bad Phone','Invalid - No longer w/ Company','Invalid - Unmarketable')                                                
                                             if(AccContact !=null && String.isNotBlank(AccContact.EligibleTracks__c) && AccContact.EligibleTracks__c.contains(PartnerTrackID)){
                                                 system.debug('>>>AccContact.EligibleTracks__c'+AccContact.EligibleTracks__c);
                                                 AccContactList.add(new cContact(AccContact,AccContact.Primary_Contact__c));   
                                             }
                                         }
            }
            else{
                for(Contact AccContact: [SELECT Id, FirstName, LastName, AccountId, Primary_Contact__c, Email, Account.Primary_Contact__c, Status__c,EligibleTracks__c 
                                         FROM Contact
                                         WHERE AccountId =:aAccountId
                                         AND Status__c IN ('Customer','Prospect','Marketing Suspect','marketing suspest')
                                         limit 1000]) {
                                             system.debug('>>>AccContact'+AccContact);   //('Pending Verification','Invalid - Bad Email','Invalid - Bad Phone','Invalid - No longer w/ Company','Invalid - Unmarketable')                                                
                                             if(AccContact !=null && String.isBlank(AccContact.EligibleTracks__c)){
                                                 AccContactList.add(new cContact(AccContact,AccContact.Primary_Contact__c));
                                             }
                                         }
            }
            
        }     
        
        return AccContactList;
    }
    
    
    public PageReference doSave()
    {
        
        try {
            
            for(cContact SelprimaryContact : ListOfOtherContact){
                
                if(SelprimaryContact.selected == true){
                    
                    SelectedPriContactId = SelprimaryContact.con.Id;
                    
                    
                    System.debug('## SelectedPriContactId : '+ SelectedPriContactId );
                    break;
                    
                }
            }
            
            if (SelectedPriContactId != null) {
                
                Account updAcc = new Account(Id = aAccountId);
                updAcc.Primary_Contact__c = SelectedPriContactId;
                update updAcc;
                
                List<Contact> updConList = new List<Contact>();
                if (ExistPriContactId != null) {
                    Contact updContact = new Contact(Id=ExistPriContactId);
                    updContact.Primary_Contact__c = false;
                    updConList.add(updContact);
                    
                }
                
                Contact updContactNew = new Contact(Id = SelectedPriContactId);
                updContactNew.Primary_Contact__c = true;
                updConList.add(updContactNew);
                
                update updConList; 
                
            }
            
            else{
                
                if(ExistingprimaryContact.size() > 0) {
                    if(!ExistingprimaryContact[0].selected) {
                        Account updExtAcc = new Account(Id = aAccountId);
                        updExtAcc.Primary_Contact__c  = null;
                        update updExtAcc;
                        
                        Contact updExtContact = new Contact(Id = ExistPriContactId );
                        updExtContact.Primary_Contact__c = false;
                        update updExtContact ; 
                    }
                }
                
            } 
            
        }               
        catch(Exception e){              
            ApexPages.addMessages(e);
        }
        
        if (selectedContactId != null)
        {
            id = selectedContactId;
        }
        else{
            id = aAccountId;
        } 
        redirectUrl= returnUrl!=null && returnUrl!=''?returnUrl:'/'+id;
        return new PageReference(redirectUrl);
        return null;
    }
    
    public class cContact {
        public Contact Con {get; set;}
        public Boolean selected {get; set;}
        
        
        
        public cContact(Contact AccContact){
            Con = AccContact;
            selected = false;
        }
        
        public cContact (Contact AccContact, boolean isSelected) {
            Con = AccContact;
            selected = isSelected;
        }
    }
    
    public PageReference doCancel()
    {
        
        if (selectedContactId != null)
        {
            id = selectedContactId;
        }
        else{
            id = aAccountId;
        }
        redirectUrl= returnUrl!=null && returnUrl!=''?returnUrl:'/'+id;
        return new PageReference(redirectUrl);
    }
    
}
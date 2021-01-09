/*
 * Author   : Ragu
 * Purpose  : Centralize the record selection process for Contact.
 *          Defines the methods which iterate and segregate the Contact records for further use.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 10751    16.03       30-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR 12724    0403        26-Mar-2016     Jessie          Modified to query related Lead record 
 * 
 */

public class ContactRecordSelector extends RecordSelector {

    private TriggerHandler conTriggerHandler;
    public set<Id> setAccountIds = new set<Id>();
    public map<Id, Account> mapRelatedAccounts;
    
    //v2.0 - start
    //get related Lead record
    public set<Id> setLeadIds = new set<Id>();
    public map<Id, Lead> mapRelatedLeads;
    //v2.0 - end 
    
    public ContactRecordSelector(list<sObject> lstContacts, map<Id, sObject> mapOldContacts, TriggerHandler conTriggerHandler) {
        this.conTriggerHandler = conTriggerHandler;
        
        this.getRecords(lstContacts, mapOldContacts);
        
        if(lstContacts != null) {
            this.getRelatedRecords(lstContacts);
        }
        else if(mapOldContacts != null) {
            this.getRelatedRecords(mapOldContacts.values());
        }
        
        removeNulls();
    }
    
    protected override void getRecords(list<sObject> lstContacts, map<Id, sObject> mapOldContacts) {
        if(lstContacts != null) {           
            for(Contact newContact : (list<Contact>)lstContacts) {
                Contact oldContact;
                if(mapOldContacts != null && !mapOldContacts.isEmpty()) {
                    oldContact = (Contact)mapOldContacts.get(newContact.Id);
                }
                
                setAccountIds.add(newContact.AccountId);
                setLeadIds.add(newContact.Source_id__c);
                
                if(oldContact != null) {
                    if(newContact.AccountId != oldContact.AccountId) {
                        setAccountIds.add(oldContact.AccountId);
                    }
                }
            }
        }
        else if(mapOldContacts != null) { // Handling delete events
            for(Contact conIterator : (list<Contact>)mapOldContacts.values()) {
                setAccountIds.add(conIterator.AccountId);
            }
        }
    }
    
    protected override void getRelatedRecords(list<sObject> lstContacts) {
        if(!setAccountIds.isEmpty()) {
            mapRelatedAccounts = new map<Id, Account>([select Id, Name, Type, RecordTypeId, RecordType.Name, Account_Country_Code__c, Account_Id__c 
                                                       from Account where Id in :setAccountIds]);
        }
        
        //v2.0 - start
        //query all related Lead records
        if(!setLeadIds.isEmpty()) {
            mapRelatedLeads = new map<Id, Lead>([ SELECT id,ownerid,RecordTypeId,RecordType.Name, FirstName,LastName,Email,Phone,MobilePhone,Title,Street,State,postalcode,
                         city,fax,country,Language_Code__c,Status, 
                         Decision_Making_Role__c, Purchase_Influence_Over__c, Email_Opt_in__c , Phone_Opt_In__c, Fax_Opt_In__c, Mail_Opt_In__c, LeadSource 
                         FROM Lead WHERE id=:setLeadIds]);
        }
        //v2.0 - end 
        
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        setAccountIds.remove(null);
        setLeadIds.remove(null);
    }

}
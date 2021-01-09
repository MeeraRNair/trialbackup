/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Contact.
 * 
 * Revision CR Number       Release No      Date            Modified By     Description
 * -------- ---------       ----------      -----------     ------------    -----------
 * 1.0      CR 10751        16.03           03-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.03     CR 11561        16.07(MAJ-S-03) 04-Jun-2015     Krishnamoorthi  Calling method to populate 8 fields in Support Request on after update as per user story 162173 
 * 3.0      CR 11631/11643  16.07(MAJ-S-05) 24-Jun-2015     Jessie/Emily    Call method to populate 2 Lookup fields to Account according to the status of Contact record. 
 * 4.0      CR 12683                        01-Mar-2016     Swathi          Call SF1Adoption class to capture user actions(Edit/Create)
 * 5.0      CR 12724                        26-Mar-2016     Jessie          Modified to support the removal of 'Contact Duplication Check VF' and adoption of standard out-of-box Contact Duplication
 * 6.0      CR 15378        02.03           09-Jan-2018     Ravali          Remove the code related to NPS_Criteria_met__c field
 * 7.0                      06.02           05-May-2018     Rahul           Comment out logic ContactUtilities.ssoVendorAssociationHelper
 * 8.0      17548           FY20-0702       24-May-2019     Fenny           ContactTriggerHandler obsolete. Above histories and below methods calls are copied from ContactTriggerHandler
 * 9.0		18305			FY20-0102		26-Nov-2019		Fenny			To make ContactRecordSelector accessible by other features
 */
public class ContactTriggerHandlerBI implements BeforeInsert{
    
    public void handleBeforeInsert(List<sObject> listNew){
        System.debug('Entered Contact handleBeforeInsert');
        
        if(ContactTriggerHandler.conRecordSelector.mapRelatedAccounts != null) {
            // Validate Email address for the Partner Accounts.
            ContactValidator.validatePartnerAccountEmails(Trigger.new, ContactTriggerHandler.conRecordSelector.mapRelatedAccounts);
        }
        
        // Validate Email, Phone, Fax, Firstname and Lastname are in the Contact_Exclusion__c or not
        ContactValidator.validateExclusions(Trigger.new);
        
        // Check for credit card information in Recommend Comment field
        ContactValidator.validateRecommendComment(Trigger.new, null);
        
        // Populate Mailing_Address_Changed__c on Contact
        ContactFieldPopulator.populateMailingAddressChanged(Trigger.new);
        
        /*v6.0--Start
        // Update NPS_Qualified_Contacts__c on Account
        ContactUtilities.updateNPSQualifiedContactsOnAccount(Trigger.new, null);
        v6.0--End*/
        
        //v3.0 - start 
        ContactFieldPopulator.populateActiveInactiveLookupFieldsToAccount(Trigger.new);
        //v3.0 - end
        
        //v5.0 - start 
        if(ContactTriggerHandler.conRecordSelector.mapRelatedLeads != null) {
            ContactFieldPopulator.populateDataFromLead(Trigger.new, ContactTriggerHandler.conRecordSelector.mapRelatedLeads);
        }
        //v5.0 - end
    }

}
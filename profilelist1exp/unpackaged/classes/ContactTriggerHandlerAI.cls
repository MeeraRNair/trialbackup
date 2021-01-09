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
 * 9.0		Story #7200237	FY20-0102		11-Nov-2019		Sushanth		Call method publishContactsFOrSMContacts to create Sales Motion Contact records for respective contact 
 * 10.0		18305			FY20-0102		26-Nov-2019		Fenny			To make ContactRecordSelector accessible by other features
 */
public class ContactTriggerHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){
        System.debug('Entered Contact handleAfterInsert');
        
        // Recalculate No_of_Qualified_NPS_Contacts__c on Accounts
        ContactUtilities.rollupQualifiedNPSContacts((map<Id, Contact>)Trigger.newMap, (map<Id, Contact>)Trigger.oldMap, ContactTriggerHandler.handler);
        
        // Associate Contact to a Channel Lead
        ContactUtilities.associateContactToChannelLead((map<Id, Contact>)Trigger.newMap);
        
        ContactUtilities.updateCTICallLog(ContactTriggerHandler.handler.trigEvent, Trigger.new, null);
        
        //v4.0 - start
        SF1Adoption.trackSF1Usage(Trigger.new, 'AfterInsert');
        //v4.0 - end
		
		// Create SalesMotionContact record
        SalesMotionContactUtilities.publishContactsForSMContacts((map<Id, Contact>)Trigger.oldMap, (map<Id, Contact>)Trigger.newMap);
    }
    
}
/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to sending emails for an Opportunity. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 2.0      CR10496     15.10       10-Sep-2014     Ragu            This logic is separated from SendEmailNotificationonstagechange trigger and rewritten as part of trigger redesign.
 * 
 */
 
public class OpportunityEmailUtilities {

    // v2.0 Start
    // boolean variable to Stop sending duplicate emails
    Public Static boolean Dupemail = true;
    public static void sendEmailNotificationOnStageChange(map<Id, Opportunity> mapOpportunities) {
        if(mapOpportunities != null && !mapOpportunities.isEmpty()) {
            map<Id, Support_Request__c> mapSupportRequests = new map<Id, Support_Request__c>();
            Id supportReqRTId = StaticFactory.getRecordTypeIdByName('Support_Request__c', 'Request Solution Operation Center Support');
            for(Support_Request__c supRequest : [select Id, Name, SOM__C, SOM__r.Name, SOM_Email__c, Opportunity__c, Opportunity__r.Id, Region_F__c, RecordTypeId, Status__c from Support_Request__c 
                                                 where Opportunity__c in :mapOpportunities.keySet() and RecordTypeId = :supportReqRTId and Status__c != 'New']) {
                mapSupportRequests.put(supRequest.Opportunity__c, supRequest);
            }
            if(!mapSupportRequests.isEmpty() && Dupemail== true ) {
                Messaging.sendEmail(OpportunityEmailUtilities.createEmailMessage(mapOpportunities, mapSupportRequests));
                Dupemail= False;
            }
        }
    }
    
    private static list<Messaging.SingleEMailMessage> createEmailMessage(map<Id, Opportunity> mapOpportunities, map<Id, Support_Request__c> mapSupportRequests) {
        list<Messaging.SingleEmailMessage> lstSingleEmails = new list<Messaging.SingleEmailMessage>();
        for(Opportunity oppIterator : mapOpportunities.values()) {
            Support_Request__c supportRequest = mapSupportRequests.get(oppIterator.Id);
            if(supportRequest != null) {
                String supportReqURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + supportRequest.Id;
                
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                if(supportRequest.Region_F__c == 'AMER') {
                    singleEmail.setToAddresses(new String[] {supportRequest.SOM_Email__c, 'ABU_ACES@dell.com'});
                }
                else if(supportRequest.Region_F__c == 'APJ') {
                    singleEmail.setToAddresses(new String[] {supportRequest.SOM_Email__c, 'APJ_ACES@dell.com'});
                }
                else if(supportRequest.Region_F__c == 'EMEA') {
                    singleEmail.setToAddresses(new String[] {supportRequest.SOM_Email__c, 'EMEA_ACES@dell.com'});
                }
                else {
                   singleEmail.setToAddresses(new String[] {supportRequest.SOM_Email__c, 'ABU_ACES@dell.com', 'EMEA_ACES@dell.com', 'APJ_ACES@dell.com'});
                     
                }
                
                
                
                singleEmail.setSubject('Support Request' + supportRequest.Name + ' has been updated by sales');
                String body = 'Dear ' + supportRequest.SOM__r.name + ',\n\n'
                            + 'An update has been made to the opportunity related to Support Request : ' + supportRequest.Name  + '.\n'
                            + ' Support Request LINK: ' + supportReqURL + '\n'
                            + 'The stage field has been updated to : ' + oppIterator.StageName + '.\n'
                            + 'Please follow up with the sales team to assist with this request.\n\n'
                            + 'Thank you. \n'
                            + 'SOC_Engagement@Dell.com';
                singleEmail.setPlainTextBody(body);
                
                lstSingleEmails.add(singleEmail);
            }
        }
        return lstSingleEmails;
    }
    // v2.0 End

}
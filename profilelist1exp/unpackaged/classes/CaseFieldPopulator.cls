/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities for auto populating Case fields. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 10751    16.03       30-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 *  
 */
 
public class CaseFieldPopulator {

    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.1         CR 9025                 22-Jan-2014     Rakesh Muppiri  This Trigger works if Subject is either is Detractor, Passive or Promoter for NPS Cases. If any mathes found from NSS Category Ranges, it will Create task and the task will be 
                                                                        assigned to respective owners from Cross functiona matrix.
    2.0         CR 10751    16.03       30-Dec-2014     Ragu            This logic is separated from AfterInsertCreateNPSCaseTrigger trigger and rewritten as part of the trigger redesign.
    */
    public static void populateFieldsOnBeforeInsert(list<Case> lstNewCases) {
        Id npsCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'NPS Cases');
        set<String> setNPSCategories = new set<String> {'Detractor', 'Passive', 'Promoter'};
        set<String> setAffinityIds = new set<String>();
        list<Case_Management_Queue__c> lstCaseMgmtQueues = [select Id, Name, Country__c, Segment__c, Sub_Segment__c from Case_Management_Queue__c];
        
        for(Case newCase : lstNewCases) {
            // Populate Queue_Name__c
            Boolean bSubSegmentNull = false;
            Boolean bAllNull = true;
            for(Case_Management_Queue__c caseManagementQueue : lstCaseMgmtQueues) {
                if(caseManagementQueue.Country__c == newCase.Country__c && caseManagementQueue.Segment__c == newCase.Segment__c && caseManagementQueue.Sub_Segment__c != newCase.Sub_Segment__c && caseManagementQueue.Sub_Segment__c == null) {
                    bSubSegmentNull = true;
                    bAllNull = false;
                }
                else if(caseManagementQueue.Country__c == newCase.Country__c && caseManagementQueue.Segment__c == newCase.Segment__c && (caseManagementQueue.Sub_Segment__c == newCase.Sub_Segment__c || caseManagementQueue.Sub_Segment__c == null)) {
                    if(bSubSegmentNull == true) {
                        newCase.Sub_Segment__c = '';
                    }
                    newCase.Queue_Name__c = caseManagementQueue.Name;
                    bAllNull = false;
                    break;
                }
            }
            
            // If no matches foung in Case Management Queue Table
            if(bAllNull == true) {
                // Defect 99158 No need to assign Unknown values
                //newCase.Country__c = 'Unknown';
                //newCase.Segment__c = 'Unknown';
                //newCase.Sub_Segment__c = 'Unknown';
                newCase.Queue_Name__c = 'Unknown';
            }
            if(String.isBlank(newCase.Queue_Name__c)) {
                newCase.Queue_Name__c = 'Unknown';
            }
            
            // Populate Origin and Record Type
            if(setNPSCategories.contains(newCase.NPS_Category__c)) {
                newCase.Origin = 'NPS Survey Response';
                newCase.RecordTypeId = npsCaseRTId;
            }

            // Store Affinity Ids
            if(newCase.Account_Affinity_ID__c != null) {
                setAffinityIds.add(newCase.Account_Affinity_ID__c);
            }
        }
        

        // v1.1 - Populate Account and Account Tier details based on Affinity Id
        map<String, Account> mapAffinityIdAccount = new map<String, Account>();
        for(Account accountIterator : [select Id, Account_ID__c, NPS_Account_Tier__c from Account where Account_ID__c in :setAffinityIds]) {
            mapAffinityIdAccount.put(accountIterator.Account_ID__c, accountIterator);
        }
        if(!mapAffinityIdAccount.isEmpty()) {
            for(Case newCase : lstNewCases) {
                if(setNPSCategories.contains(newCase.NPS_Category__c)) {
                    Account accountInstance = mapAffinityIdAccount.get(newCase.Account_Affinity_ID__c);
                    if(accountInstance != null) {
                        newCase.AccountId = accountInstance.Id;
                        if(accountInstance.NPS_Account_Tier__c != null) {
                            newCase.Account_Tier__c = accountInstance.NPS_Account_Tier__c;
                        }
                    }
                }
            }
        }
    }
    
    public static void replytoPartnersWhenCaseisCompleted(list<Case> lstNewCases, map<Id, Case> oldCaseMap) {
        list<Case> lstCases = new list<Case>();
        list<String> recipients = new list<String>();
        list<String> userRecipients = new list<String>();
        
        for(Case caseObj: lstNewCases){
            Case oldCase = oldCaseMap.get(caseObj.Id);
            if(caseObj.Status == 'Completed' && oldCase.Inbound_Email_Message__c != caseObj.Inbound_Email_Message__c && caseObj.Inbound_Email_Message__c == true && caseObj.Recipient__c != null ){
                lstCases.add(caseObj);
                recipients.add(caseObj.Recipient__c);
                String formatUserEmail = caseObj.Recipient__c.split('@')[0].replace('.','_') + '@' + caseObj.Recipient__c.split('@')[1];
                userRecipients.add(formatUserEmail);
                system.debug('Inside 1 For caseObj: '+ formatUserEmail);
            }
        }
        
        if(lstCases.size() > 0){
            
            list<User> userList = [Select Id, Email From User Where Email IN :userRecipients ];
            system.debug('Inside 2 For userList: '+ userList);
            map<String, Id> userMap = new map<String, Id>();
            if(userList.size() > 0){
                for(User usr: userList){
                    userMap.put(usr.Email, usr.Id);
                }
            }
            
            // Send Notofications
            EmailNotification(lstCases, userMap);
            list<Case> updateCases = new list<Case>();
            
            for(Case caseObj: lstCases){
                Case cs = new Case(Id=caseObj.Id, Inbound_Email_Message__c = false, Recipient__c = null);
                updateCases.add(cs);
            }
            
            update updateCases;
        }
    }
    
    public static void EmailNotification(list<Case> lstCases, map<String, Id> userMap){

        list<Messaging.SingleEmailMessage> emails = new list<Messaging.SingleEmailMessage>();
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developername= 'Case_Closed_Partner_VF_Template'];
        
        for(Case caseObj: lstCases){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setWhatId(caseObj.id);
            email.setTemplateId(et.id);
            email.SaveAsActivity= false;
            
            if(userMap.get(caseObj.Recipient__c.split('@')[0].replace('.','_') + '@' + caseObj.Recipient__c.split('@')[1]) != null){
                email.setTargetObjectId(userMap.get(caseObj.Recipient__c.split('@')[0].replace('.','_') + '@' + caseObj.Recipient__c.split('@')[1]));
            }else{
                list<string> emlist=new list<string>();
                emlist.add(caseObj.Recipient__c);
                email.setToAddresses(emlist);
                email.setTargetObjectId(caseObj.OwnerId);
                email.setTreatTargetObjectAsRecipient(false);
            }
            emails.add(email);
        }
        
        Messaging.sendEmail(emails);
    }
    
}
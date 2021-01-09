/*
Author: Carmen 

History:
Version  Date          Modified By     Description      
--------------------------------------------------------------------------------------
1.0      18-Nov-2010   Carmen          Created for CR4460
2.0      02-Dec-2010   Carmen          Added Send Account Suggestion flag
3.0      08-Jan-2011   Carmen          Avoid update PR status if value is Complete/Rejected/Duplicate
4.0      12-Jan-2011   Carmen       Update PR status if value is Lead Draft/Account Suggestion Submitted
*/

global class BatchLinkAccount implements Database.Batchable<sObject>{
    global String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        System.debug('###Debug###Query=' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Lead> linkErrorList = new List<Lead>();
        Set<String> legacyIdSet = new Set<String>();
        Map<Id,Id> leadAccountMap = new Map<Id,Id>();
        List<Lead> statusErrorList = new List<Lead>();
        List<Lead> updateLeadList = new List<Lead>();
        List<Partner_Request__c> updatePRList = new List<Partner_Request__c>();     
        
        for(sobject obj : scope){
            Lead tempLead = (Lead)obj;
            if (tempLead.Suggestion_ID__c == null && (tempLead.RecordType.Name == 'Account Suggestion' || tempLead.RecordType.Name == 'Account Suggestion Locked')) {
                statusErrorList.add(tempLead);
            }
            else { 
                legacyIdSet.add('SFDC_' + tempLead.Id);
                linkErrorList.add(tempLead);
             }
        }
        
        List<Account> acctList = [SELECT Id, Legacy_ID__c 
                                        FROM Account
                                        WHERE Legacy_ID__c IN :legacyIdSet AND Master_Group_Id__c != Null AND Partner_Track__c != null ];

        for (Account acct : acctList) {
            Id leadID = acct.Legacy_ID__c.replace('SFDC_','');
            leadAccountMap.put(leadID, acct.Id);
        }   
        
        System.debug('###DEBUG###linkErrorList=' + linkErrorList);
        System.debug('###DEBUG###leadAccountMap=' + leadAccountMap);
        
        //Fix Issue 1 & 2
        for (Lead tempLead : linkErrorList) {           
            if (leadAccountMap.containsKey(tempLead.Id)) {
                Id accountID = leadAccountMap.get(tempLead.Id);
                //Link Lead
                If (tempLead.Account__c == null) {
                    tempLead.Account__c = accountID;
                    tempLead.Status = 'Account Suggestion Completed';
                    tempLead.RecordTypeId = GlobalVariables.ACCOUNT_SUGGESTION_LOCKED_LEAD_RECTYPE;
                    updateLeadList.Add(tempLead);
                }
                
                //Link PR
                Boolean isPRUpdated = false;
                if (tempLead.Partner_Request__c != null) {          
                    Partner_Request__c tempPR = new Partner_Request__c(Id = tempLead.Partner_Request__c);           
                    if (tempLead.Partner_Request__r.Account__c == null) {                    
                        tempPR.Account__c = accountId;
                        isPRUpdated = true;
                    }
                    if (tempLead.Partner_Request__r.Send_Account_Suggestion_Is_Complete_Flag__c != true) {
                        tempPR.Send_Account_Suggestion_Is_Complete_Flag__c = true;
                        isPRUpdated = true;
                    }                  
                    if (tempLead.Partner_Request__r.Link_to_Account_Record_Is_Complete_Flag__c != true) {
                        tempPR.Link_to_Account_Record_Is_Complete_Flag__c = true;
                        isPRUpdated = true;
                    }                   
                    if (tempLead.Partner_Request__r.Status__c != 'Account Suggestion Completed') {
                        tempPR.Status__c = 'Account Suggestion Completed';
                        isPRUpdated = true;
                    }
                    
                    if (isPRUpdated) {
                        updatePRList.Add(tempPR);
                    }
                }
            }
        }
        
        System.debug('###DEBUG###statusErrorList=' + statusErrorList);
        
        //Fix Issue 3
        for (Lead tempLead : statusErrorList) {
            Boolean isLeadUpdated = false;
            Boolean isPRUpdated = false;
            
            //Update Lead
            if (tempLead.Status != 'Account Suggestion Completed') {
                tempLead.Status = 'Account Suggestion Completed';
                isLeadUpdated = true;
            }       
            if (tempLead.RecordType.Name != 'Account Suggestion Locked') {
                tempLead.RecordTypeId = GlobalVariables.ACCOUNT_SUGGESTION_LOCKED_LEAD_RECTYPE;
                isLeadUpdated = true;
            }
            if (isLeadUpdated) {
                updateLeadList.Add(tempLead);
            }
            
            //Update PR
            Partner_Request__c tempPR = new Partner_Request__c(Id = tempLead.Partner_Request__c);
            if (tempLead.Partner_Request__r.Account__c == null) {
                tempPR.Account__c = tempLead.Account__c;
                isPRUpdated = true;
            }
            if (tempLead.Partner_Request__r.Link_to_Account_Record_Is_Complete_Flag__c != true) {
                tempPR.Link_to_Account_Record_Is_Complete_Flag__c = true;
                isPRUpdated = true;
            }                   
            if (tempLead.Partner_Request__r.Status__c == 'Lead Draft'
            || tempLead.Partner_Request__r.Status__c == 'Account Suggestion Submitted') {
                tempPR.Status__c = 'Account Suggestion Completed';
                isPRUpdated = true;
            }
            if (isPRUpdated) {
                updatePRList.Add(tempPR);
            }
        }
        
        System.debug('###DEBUG###updateLeadList=' + updateLeadList);
        System.debug('###DEBUG###updatePRList=' + updatePRList);
        
        if (updateLeadList.size() > 0) {
            Database.SaveResult[] listOfResult = Database.update(updateLeadList, false);
            DBUtils.processResult(updateLeadList, listOfResult, 'Lead', 'Update', 'Batch Link Account');
        }
        if (updatePRList.size() > 0) {
            Database.SaveResult[] listOfResult = Database.update(updatePRList, false);
            DBUtils.processResult(updatePRList, listOfResult, 'Partner Request', 'Update', 'Batch Link Account');
        }
    }
    
    global void finish(Database.BatchableContext BC){    
    }   
}
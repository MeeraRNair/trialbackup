/**
 * @File Name          : BatchSalesMotionContact.cls
 * @Description        : Batch job to insert Sales Motion contact records for corresponding SM contacts
 * @Author             : Sushanth Dasari
 * @Last Modified By   : Sushanth Dasari
 * @Last Modified On   : 11/8/2019, 3:29:46 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0     11/5/2019     Sushanth Dasari           Initial Version
**/
global class BatchSalesMotionContact implements Database.Batchable<sObject>{
    
    global final String salesMotionAccountsQuery;
    
    global BatchSalesMotionContact(String strQuery){
        // Query would be as follow: 'Select Master_Group_Id__c, Partner_Track__c FROM Account WHERE recordTypeId = \''+Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId()+'\' AND Master_Group_Id__c <> null AND Partner_Track__c <> null AND SMContact_Batch_Processed__c = false'
        salesMotionAccountsQuery=strQuery;
    }
    global Database.QueryLocator start(Database.BatchableContext batchContext){
        return Database.getQueryLocator(salesMotionAccountsQuery);
    }
    
    global void execute(Database.BatchableContext batchContext, List<Account> listSalesMotionAccounts){
        
        List<Sales_Motion_Contact__c> listInsertSMContacts = new List<Sales_Motion_Contact__c>();
        Set<String> setMasterGroupId = new Set<String>();
        Set<String> setPartnerTrackId = new Set<String>();
        Map<String, String> mapPTIdSMAccountId = new Map<String, String>();
        List<Account> listSMAccount = new List<Account>();
        
        Savepoint sp = Database.setSavepoint();
        
        for(Account salesMotionAccountRecord : listSalesMotionAccounts){
            setMasterGroupId.add(salesMotionAccountRecord.Master_Group_Id__c);
            setPartnerTrackId.add(salesMotionAccountRecord.Partner_Track__c);
            Account sMAccount = new Account();
            sMAccount.id = salesMotionAccountRecord.Id;
            sMAccount.SMContact_Batch_Processed__c = true;
            listSMAccount.add(sMAccount);
            mapPTIdSMAccountId.put(salesMotionAccountRecord.Partner_Track__c, salesMotionAccountRecord.Id);
        }
        try{
            for(Contact contactRecord: [SELECT FirstName, LastName, EligibleTracks__c
                                        FROM Contact 
                                        WHERE AccountId =: setMasterGroupId]){
                                            for(String strPartnerTrackId : setPartnerTrackId){
                                                if(String.isNotBlank(contactRecord.EligibleTracks__c) && contactRecord.EligibleTracks__c.contains(strPartnerTrackId)
                                                   && mapPTIdSMAccountId.containsKey(strPartnerTrackId)){
                                                       Sales_Motion_Contact__c salesMotionContact = new Sales_Motion_Contact__c();
                                                       salesMotionContact.Sales_Motion__c = mapPTIdSMAccountId.get(strPartnerTrackId);
                                                       salesMotionContact.Contact__c = contactRecord.Id;
                                                       listInsertSMContacts.add(salesMotionContact);
                                                   }
                                            }
                                        }
            
            if(!listInsertSMContacts.isEmpty() && !listSMAccount.isEmpty()){
                insert listInsertSMContacts;
                TriggerExecutionController.setSkipAllTriggers(true);
                update listSMAccount;
                TriggerExecutionController.setSkipAllTriggers(false);
            }
        }catch(Exception e) {
            Database.rollback(sp);
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'Insert Sales Motion Contacts Batch';
            exceptionRecord.Object_type__c = 'BatchSalesMotionContact';
            exceptionRecord.Notes__c = 'Error occured for SMAccount Id: '+ mapPTIdSMAccountId.values() + ' :: ' + e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
        }
    }
    
    global void finish(Database.BatchableContext batchContext){
    }
}
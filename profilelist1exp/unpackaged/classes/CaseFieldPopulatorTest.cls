/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           22-10-2019         Implimented TestDataFactory        
*/
@isTest(seeAlldata=false)
public Class CaseFieldPopulatorTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        for(Account acc : listAccTdf){
            acc.Partner_Type__c = 'COMMERCIAL';
            acc.Partner_Tier__c = 'Direct Partner Purchase';
            acc.Partner_Relationship__c = 'Registered';
            acc.Account_Country__c = 'United States';
        }
        listAccTdf[1].Account_ID__c='14232423432';
        listAccTdf[1].NPS_Account_Tier__c = 'Priority 1';
        insert listAccTdf;
        Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
        
        list<Case> listCaseTdf=TestDataFactory.createNCases(2);
        listCaseTdf[0].AccountId=listAccTdf[0].id;
        listCaseTdf[1].AccountId=listAccTdf[1].id;
        listCaseTdf[0].Recordtypeid=orderSuppRTId;
        listCaseTdf[1].Recordtypeid=orderSuppRTId;
        listCaseTdf[1].Account_Affinity_ID__c = '14232423432';
        listCaseTdf[1]. NPS_Category__c = 'Detractor';
        insert listCaseTdf;
    }
    
    public static testMethod void sendingMailtoPartner() {
        Test.startTest();
        TriggerExecutionController.setSkipCaseTriggers(true);
        //insert casemanagement data
        Case_Management_Queue__c cq = new Case_Management_Queue__c(Country__c='United States',Segment__c='test',Sub_Segment__c=null);
        insert cq;
        
        list<Case> listCase=[Select id from Case Limit 1];
        system.assertNotEquals(listCase[0].id, null);
        listCase[0].Priority = 'Low';
        listCase[0].Inbound_Email_Message__c = true;
        listCase[0].Recipient__c = 'no_reply@dell.com';
        listCase[0].Status = 'Completed';
        update listCase[0]; 
        
        CaseFieldPopulator.populateFieldsOnBeforeInsert(listCase);//new map<id,case>([select id,Recipient__c from case])
        map<String,id> mapnewMpa = new map<String,id>();
        mapnewMpa.put(listCase[0].id,listCase[0].id);
        try{
            CaseFieldPopulator.EmailNotification(listCase, mapnewMpa);
        }catch(exception ex){}
        CaseFieldPopulator.replytoPartnersWhenCaseisCompleted(listCase,new map<id,case>([select id,Inbound_Email_Message__c,Recipient__c from case]));
        Test.stopTest(); 
    }
    public static testMethod void sendingMailtoPartnerNot() {
        Test.startTest();
        TriggerExecutionController.setSkipCaseTriggers(true);
        Case_Management_Queue__c cq = new Case_Management_Queue__c(Country__c='United States',Segment__c='test',Sub_Segment__c=null);
        insert cq;
        
        list<Case> listCase=[select id,AccountId,ContactId,RecordTypeId,Country__c,Segment__c,Priority,Sub_Segment__c,Order_Number1__c,Recipient__c,Status,Account_Affinity_ID__c,NPS_Category__c from case Limit 2];
        listCase[1].Priority = 'Low';
        listCase[1].Inbound_Email_Message__c = true;
        listCase[1].Recipient__c = 'no_reply@dell.com';
        listCase[1].Status = 'Completed';
        update listCase[1]; 
        system.assertNotEquals(listCase[1].id, null);
        
        CaseFieldPopulator.populateFieldsOnBeforeInsert(listCase);//new map<id,case>([select id,Recipient__c from case])
        map<String,id> mapnewMpa = new map<String,id>();
        mapnewMpa.put(listCase[1].id,listCase[1].id);
        try{
            CaseFieldPopulator.EmailNotification(listCase, mapnewMpa);
        }catch(exception ex){}
        CaseFieldPopulator.replytoPartnersWhenCaseisCompleted(listCase,new map<id,case>([select id,Inbound_Email_Message__c,Recipient__c from case]));
        Test.stopTest(); 
    }
}
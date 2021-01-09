@isTest
public with sharing class SalesMotionContactUtilitiesTest {
    private static testmethod void publishContactsForSMContacts(){
        
        TriggerExecutionController.setSkipContactTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        test.startTest();
        Partner_Track__c pt = new Partner_Track__c();
        pt.Partner_Track_Name__c = 'Test Partner Track';    
        pt.Track_Affinity_Id__c = '432';
        insert pt;
        
        Account masterGroupAccount=new Account();
        masterGroupAccount.name='Test Master Group';
        masterGroupAccount.Account_ID__c='67765768789';
        insert masterGroupAccount;

        Account a=new Account();
        a.Partner_Track__c=pt.id;
        a.name='test';
        a.Account_ID__c='6768789';
        a.Type='Partner';
        a.Master_Group_Id__c = masterGroupAccount.Id;
        a.recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();
        insert a;
        
        Contact cont = new Contact();
        cont.FirstName='TestContact1';
        cont.LastName='TestContactlast'; 
        cont.accountId=masterGroupAccount.Id;
        cont.Email='test@dell.com'; 
        cont.fax='01987645';
        cont.MobilePhone= '8989678';
        cont.Status__c = 'Marketing Suspect';
        cont.EligibleTracks__c=pt.Id;
        insert cont; 
        
        Contact cont2 = new Contact();
        cont2.Id = cont.id;
        cont2.EligibleTracks__c='Removed Id';
        
        map<id,contact> mapNew = new map<id,contact>();
        mapNew.put(cont.id,cont);
        
        SalesMotionContactUtilities.publishContactsForSMContacts(null,mapNew);
        
        map<id,contact> mapOld = new map<id,contact>();
        mapOld.put(cont2.id,cont2);
        
        SalesMotionContactUtilities.publishContactsForSMContacts(mapNew,mapOld);
        
        system.assertEquals(cont.Email,'test@dell.com');  
        test.stopTest();
    }
}
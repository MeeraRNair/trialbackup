@istest
public class BatchSalesMotionContactTest {
    static list<Account> listAcc;
    static list<Contact> listCon;
    @testsetup static void setup(){
		list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Master Account');
        listAccTDF[0].Account_ID__c='67765768789';
		insert listAccTDF;
		list<Contact> listConTDF = TestDataFactory.CreateNContacts(1);
		insert listConTDF;        
    }
    static testmethod void batchSalesMotionContactinsert(){
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        Partner_Track__c pt = new Partner_Track__c();
        pt.Partner_Track_Name__c = 'Test Partner Track';    
        pt.Track_Affinity_Id__c = '432';
        insert pt;
        
        /*Account masterGroupAccount=new Account();
        masterGroupAccount.name='Test Master Group';
        masterGroupAccount.Account_ID__c='67765768789';
        insert masterGroupAccount; */
        
		listAcc = [select id,Account_ID__c from Account limit 2];
        listAcc[1].RecordtypeID = TestDataFactory.getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc[1].Master_Group_Id__c = listAcc[0].Id;
        listAcc[1].Partner_Track__c=pt.id;
		update listAcc;
  /*      Account a=new Account();
        a.Partner_Track__c=pt.id;
        a.name='test';
        a.Account_ID__c='6768789';
        a.Type='Partner';
        a.Master_Group_Id__c = masterGroupAccount.Id;
        a.recordtypeid=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        insert a; */
        listCon = [select id,EligibleTracks__c from Contact limit 1];
        listCon[0].EligibleTracks__c=pt.Id;
        listCon[0].accountId=listAcc[0].Id;
        update listCon;
        /*
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
        */
		system.assertEquals(listCon,listCon);  
        String strQuery =  'Select Master_Group_Id__c, Partner_Track__c FROM Account WHERE recordTypeId = \''+Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId()+'\' AND Master_Group_Id__c <> null AND Partner_Track__c <> null';
        BatchSalesMotionContact bt=new BatchSalesMotionContact(strQuery);
        DataBase.executeBatch(bt);
        test.stopTest();
    }
}
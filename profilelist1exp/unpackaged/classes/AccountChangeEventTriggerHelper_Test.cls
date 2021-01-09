/***********************************************************
* Name          : AccountChangeEventTriggerHelper_Test
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@isTest
public class AccountChangeEventTriggerHelper_Test {
    static list<Account> listAcc;
    @testsetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTDF;
    }
     @isTest static void updateUDAValuesOnAccount() {
        Test.enableChangeDataCapture();
        List<Partner_Track__c> listPartnerTrack = new  List<Partner_Track__c>();
        
         Partner_Track__c partnerTrack = new Partner_Track__c();
         partnerTrack.Partner_Track_Name__c = 'Test Partner Track';
         partnerTrack.partner_Track_affinityId__c  ='123455';
         listPartnerTrack.add(partnerTrack);
         
         Partner_Track__c partnerTrack2 = new Partner_Track__c();
         partnerTrack.Partner_Track_Name__c = 'Test Partner Track Name';
         partnerTrack.partner_Track_affinityId__c  ='12345575';
         listPartnerTrack.add(partnerTrack2);
         insert listPartnerTrack;
        Test.getEventBus().deliver();
  /*       
         List<Account> listOfAccounts = new List<Account>();
         Account acc= new Account();
        acc.Name='Test Assync';
        acc.Distribution_Sell_To_Countries__c ='UNITED STATES';
        acc.Partner_Relationship__c ='Authorized';
        acc.Partner_Type__c ='Commercial Distributor';
        acc.Partner_Tier__c ='Direct';
         listOfAccounts.add(acc);
          Account acc2= new Account();
        acc2.Name='Test Assync';
        acc2.Distribution_Sell_To_Countries__c ='UNITED STATES';
        acc2.Partner_Relationship__c ='Authorized';
        acc2.Partner_Type__c ='Commercial Distributor';
        acc2.Partner_Tier__c ='Direct';
         listOfAccounts.add(acc2);
        insert listOfAccounts;
		*/
       	listAcc = [select id,Partner_Track__c from Account limit 2];
        Test.getEventBus().deliver();
        listAcc[0].Partner_Track__c=listPartnerTrack[1].id;
        listAcc[1].Partner_Track__c=listPartnerTrack[0].id;
        update listAcc;
        
        Test.getEventBus().deliver();
        system.assertEquals(listAcc[0].Partner_Track__c, listPartnerTrack[1].id);
    }
}
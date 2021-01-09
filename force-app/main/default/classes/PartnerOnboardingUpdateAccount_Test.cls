@isTest
public class PartnerOnboardingUpdateAccount_Test {
    
    @testSetup static void setup() {
         list<Account> listpartnerAccout = TestDataFactory.createNAccount(2, 'Partner Account');
         insert listpartnerAccout;
    }
    @isTest static void updateUDAValuesOnAccount() {
        Test.enableChangeDataCapture();
        List<Partner_Track__c> listPartnerTrack = new  List<Partner_Track__c>();
        
         Partner_Track__c partnerTrack = new Partner_Track__c();
         partnerTrack.Partner_Track_Name__c = 'Test Partner Track';
         partnerTrack.partner_Track_affinityId__c  ='123455';
         listPartnerTrack.add(partnerTrack);
         
         Partner_Track__c partnerTrack2 = new Partner_Track__c();
         partnerTrack2.Partner_Track_Name__c = 'Test Partner Track Name';
         partnerTrack2.partner_Track_affinityId__c  ='12345575';
         listPartnerTrack.add(partnerTrack2);
         insert listPartnerTrack;
         //system.assertEquals(partnerTrack.partner_Track_affinityId__c,'12345575');
        Test.getEventBus().deliver();

        List<Account> listOfAccounts = [Select id,name from Account limit 2];
        for(Account acc: listOfAccounts){
            acc.Distribution_Sell_To_Countries__c ='UNITED STATES';
            acc.Partner_Relationship__c ='Authorized';
            acc.Partner_Type__c ='Commercial Distributor';
            acc.Partner_Tier__c ='Direct';
        }
        update listOfAccounts;
        Test.getEventBus().deliver();
        listOfAccounts[0].Partner_Track__c=listPartnerTrack[1].id;
        listOfAccounts[1].Partner_Track__c=listPartnerTrack[0].id;
        update listOfAccounts;
        system.assertEquals(listOfAccounts[0].Partner_Type__c,'Commercial Distributor');
        Test.getEventBus().deliver();
        
    }
        @isTest static void updateUDAValuesOnAccount1() {
        Test.enableChangeDataCapture();
            TriggerExecutionController.setSkipAccountTriggers(true);
        List<Partner_Track__c> listPartnerTrack = new  List<Partner_Track__c>();
        
         Partner_Track__c partnerTrack = new Partner_Track__c();
         partnerTrack.Partner_Track_Name__c = 'Test Partner Track';
         partnerTrack.partner_Track_affinityId__c  ='123455';
         listPartnerTrack.add(partnerTrack);
         
         Partner_Track__c partnerTrack2 = new Partner_Track__c();
         partnerTrack2.Partner_Track_Name__c = 'Test Partner Track Name';
         partnerTrack2.partner_Track_affinityId__c  ='12345575';
         listPartnerTrack.add(partnerTrack2);
         insert listPartnerTrack;
         //system.assertEquals(partnerTrack.partner_Track_affinityId__c,'12345575');
        Test.getEventBus().deliver();

        List<Account> listOfAccounts = [Select id,name from Account limit 2];
        for(Account acc: listOfAccounts){
            acc.Distribution_Sell_To_Countries__c ='UNITED STATES';
            acc.Partner_Relationship__c ='Authorized';
            acc.Partner_Type__c ='Commercial Distributor';
            acc.Partner_Tier__c ='Direct';
            acc.New_Partner_Programme_T_C_s_agreed_on__c = system.today();
            acc.New_Partner_Programme_T_C_s__c = true;
            acc.Partner_Track__c = listPartnerTrack[0].id;
        }
        update listOfAccounts;
        Test.getEventBus().deliver();
        listOfAccounts[0].Partner_Track__c=null;
        listOfAccounts[1].Partner_Track__c=null;    
        update listOfAccounts;
        system.assertEquals(listOfAccounts[0].Partner_Type__c,'Commercial Distributor');
        Test.getEventBus().deliver();
        
    }
}
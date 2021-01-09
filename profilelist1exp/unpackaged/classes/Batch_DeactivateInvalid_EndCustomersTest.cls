/*====================================================================================================================+
|  HISTORY |                                                                 
|                                                                           
| DATE         Modified              Story           DESCRIPTION                               
| ===========  =========           =========          =========== 
| 06-Dec-2019  Venu K 				  0102			   Implemented TDF
+====================================================================================================================*/

@isTest
public class Batch_DeactivateInvalid_EndCustomersTest {
    static List<Account> listAcc;
    static list<Opportunity> listOpp;
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        for(Account acc : listAccTdf){
            acc.Partner_Relationship__c = 'Authorized';
            acc.Status__c = 'Active';
            acc.DMU__c = false;
        }
        listAccTdf[0].Account_Country__c = 'UNITED STATES';
        listAccTdf[0].Type = 'Partner';
        listAccTdf[1].Partner_Type__c = 'Distributor (GCC)';
        listAccTdf[1].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        listAccTdf[1].Account_Country__c = 'UNITED KINGDOM';
        listAccTdf[1].Partner_Tier__c = 'Tier 1';
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        insert listOppTdf;
        list<User> listUserTdf=TestDataFactory.createNPortalUser(1);
        listUserTdf[0].Enable_Partner_Admin__c = true;
        listUserTdf[0].Enable_Partner_Deal_Registration__c = true;
        insert listUserTdf;
    }
    static testMethod void inActivateEndCUstomersScenario1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[SELECT ID FROM Account Limit 2];
        // End Customer Creation
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Source_System__c = 'Deal Registration',
                                                                Partner_Account__c = listAcc[0].id );
        insert endCustomerString;      
        Datetime dtendCusCreDate = Datetime.now().addDays(-45);
        Test.setCreatedDate(endCustomerString.Id, dtendCusCreDate);
        system.assertNotEquals(listAcc[0].id, null);
        Test.startTest();
        Batch_DeactiveInvalid_EndCust_Scheduler dr = new Batch_DeactiveInvalid_EndCust_Scheduler();
        String strsch = '0 0 22 ? * SAT';
        System.schedule('Test',strsch,dr);
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void inActivateEndCUstomersScenario2(){
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[SELECT ID FROM Account Limit 2];
        // End Customer Creation
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Source_System__c = 'Deal Registration',
                                                                Partner_Account__c = listAcc[0].id );
        insert endCustomerString;      
        Datetime dtendCusCreDate = Datetime.now().addDays(-45);
        Test.setCreatedDate(endCustomerString.Id, dtendCusCreDate);
        list<user> listUser=[Select id from user limit 1];
        listOpp=[select id from Opportunity limit 1];
        listOpp[0].AccountId=listAcc[1].id;
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].End_Customer__c = endCustomerString.id;
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        update listOpp;
        system.assertNotEquals(listOpp[0].id, null);
        Test.startTest();
        Batch_DeactiveInvalid_EndCust_Scheduler dr = new Batch_DeactiveInvalid_EndCust_Scheduler();
        String strsch = '0 0 22 ? * Mon';
        System.schedule('Test',strsch,dr);
        Test.stopTest(); 
        TriggerExecutionController.setSkipAllTriggers(false);
    }    
}
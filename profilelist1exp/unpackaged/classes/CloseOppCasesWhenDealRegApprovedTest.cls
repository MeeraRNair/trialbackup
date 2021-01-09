/*====================================================================================================================+
|  HISTORY |                                                                 
|                                                                           
| DATE         Modified              Story           DESCRIPTION                               
| ===========  =========           =========          =========== 
| 06-Dec-2019  Venu K 				  0102			   Implemented TDF
+====================================================================================================================*/

@isTest
private class CloseOppCasesWhenDealRegApprovedTest {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<user> listUserTdf=TestDataFactory.createNPortalUser(1);
        insert listUserTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration-Submitted');
        insert listOppTdf; 
    }
    
    /* public static testmethod void testdata(){
list<User> listUser=[Select id from User Limit 1];
system.runAs(listUser[0]){
list<opportunity> listOpp=[Select id from opportunity Limit 1];
system.assertEquals(listOpp.size(), 0);

try{ CloseOppCasesWhenDealRegApproved.closeOppCases(new map<id,Opportunity>(),new map<Id, Opportunity>());
}catch(Exception ex){}
}
}
*/
    static testMethod void testdata(){
        System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        test.startTest();
        insert cs;
        TriggerExecutionController.setSkipAllTriggers(true);   
        list<Account> listAcc=[SELECT id from Account LIMIT 1];
        list<Opportunity> listOpp=[SELECT id,EMC_sales_motion__c,EMC_Opportunity_updated__c,Opportunity_Details_Extra__c from Opportunity];
        listOpp[0].AccountId=listAcc[0].Id;
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].StageName = 'Plan - 1%';
        listOpp[0].Override_Probability__c = '1';
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Distributor_Reseller_Name__c = listAcc[0].Id;
        update listOpp[0];
        // CR-14160 - Start
        system.assertEquals(Null,listOpp[0].EMC_sales_motion__c);
        system.assertEquals(Null,listOpp[0].EMC_Opportunity_updated__c);
        system.assertEquals(Null,listOpp[0].Opportunity_Details_Extra__c);
        //CR-14160 - End        
        TriggerExecutionController.setSkipAllTriggers(false); 
        TriggerExecutionController.setSkipAccountTriggers(true); 
        ProcessFlowTriggerController.isTest = true; // 5.0
        listOpp[0].StageName = 'Win - 100%';
        listOpp[0].Competitor_Lost_To__c = 'Absolute';
        listOpp[0].Account_ClosedOppurtunity__c = listAcc[0].Id;
        listOpp[0].Distributor_Reseller_Name__c = listAcc[0].Id;
        listOpp[0].Forecast_Category_Override__c = 'Closed';
        //Set skip VRs
        // SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        update listOpp[0];
        //Reset skip VRs
        //  ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        Opportunity opp = [SELECT StageName, Highest_Stage__c, Confidence_Factor__c, Partner_Opportunity_Stage__c FROM Opportunity WHERE Id = :listOpp[0].Id];
        Test.stopTest();
    }
}
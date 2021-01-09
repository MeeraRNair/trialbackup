/*****************************************************************************
*CreatedBy : Shubham Bhatt
*Story: created for 7754350
*Purpose: To cover all the methods related to renewal opportunity async trigger
*Date : 10th Dec 2019
*******************************************************************************/
@isTest
public class RenewalOpportunityChangeEVTHandler_Test{
    //for covering async trigger call
    Public Static testMethod void createRenewalQuotingCaseTest() {
        User usr = RenewalOpportunityTriggerHandlerBI_Test.userSetup();
        insert usr;
        System.runAs(usr){
            RenewalOpportunityTriggerHandlerBI_Test.setup();
            Test.enableChangeDataCapture();
            Test.startTest();
            Opportunity testOpportunity ;
            testOpportunity = RenewalOpportunityTriggerHandlerBI_Test.opptySetupWithoutRole();
            TriggerExecutionController.setSkipAllTriggers(true);
            insert testOpportunity;
            system.assertNotEquals(testOpportunity.id, null);
            TriggerExecutionController.setSkipAllTriggers(false);
            
            Test.stopTest();
            // Deliver test change events
            Test.getEventBus().deliver();
        }
    }  
    
}
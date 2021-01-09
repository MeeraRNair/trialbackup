/*History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0                                     created
2.0     28-July-2015    Azwanti         CR11617 - added test for OpportunityProductNotSupportableCtrl class
*/
@isTest
private class OpptyProdNotSupportCtrlTest {

	private static testMethod void successTest() {
        
        //create acc
        Account testAcc = new Account(Name='CR11453 Test Account', BU_ID__c = '123');
        insert testAcc;
        
        //create Opportunity
        Opportunity testOppty = new Opportunity(StageName='Plan - 1%', Probability=1, AccountId=testAcc.Id, Name='TEST Oppty CR11453', CloseDate = System.today() + 30, 
                                                Primary_Product_Delivery_Address_Region__c = 'REGION1', Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
                                                Region__c='APJ',Competitor_Lost_To__c='Unknown');
        insert testOppty;
        
        OpportunityProductNotSupportableCtrl controller = new OpportunityProductNotSupportableCtrl(testOppty.Id);
        controller.opptyId = testOppty.Id;
        controller.accName = testAcc.Name;
        controller.accBUID = testAcc.BU_ID__c;
        controller.salesRepEmail = testOppty.Owner.Email;
        controller.salesRepName = testOppty.Owner.Name;
        
        controller.getOpptyRec();
	}
 
}
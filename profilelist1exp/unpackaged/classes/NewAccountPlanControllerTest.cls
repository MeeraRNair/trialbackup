/***********************************************************
* Name          : newAccountPlanControllerTest 
* Description   : Controller class for record type selection for lightning
* ---------------------------------------------------------
* Revision      Release     				Name            Date            Description
* 1.0           FY19-DCS-0602(CR 15665)		Meera			20-April-2018   Test class to support lightning compoenent for RT selection                                             
* 1.1			FY20-1101					Kamaal			24-Oct-2019		Changes for the coverage of getRecTypeName method
* 
* 
************************************************************/
@isTest
public class NewAccountPlanControllerTest {
    private static testmethod void testfetchRecordTypeValues(){
        Schema.DescribeSObjectResult objAccSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> mapAccountRecordTypeInfo = objAccSchema.getRecordTypeInfosByName();
        Id accRtId = mapAccountRecordTypeInfo .get('Partner Account').getRecordTypeId();
        Account objAcc = new Account(Name='Test Account',recordtypeid=accRtId);
        insert objAcc;
        Test.startTest();
        System.assert(newAccountPlanController.fetchRecordTypeValues().size()>0);
        System.assertNotEquals(null, newAccountPlanController.getRecTypeId('Account Plan Lite'));
        System.assertNotEquals(null, newAccountPlanController.getRecTypeName(objAcc.id));
        Test.stopTest();
    }
}
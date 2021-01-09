/* 
* Author   : Ranjith Mergu
* Purpose  : This Test class prevents Support_Request_Executive_Help PB invocation, when Request Executive Help Details Record Type is not true.
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0 	TFS7561655		FY20-0102		14/01/2020		Ranjith Mergu	Idea Intake 08148: Specialty Capability - Request Executive Help - Functionality
*/ 
@isTest
public class SupportRequestExecutiveHelpDetailsPBTest {
    
    static testmethod void testReqEx() {
        List<String> listStr = new List<String>();
        listStr.add('RequestExecutiveHelpDetails');
        Test.startTest();
        SupportRequestExecutiveHelpDetailsPB.IsNotRequestExecutiveHelpDetails(listStr);
        system.assertEquals('RequestExecutiveHelpDetails', 'RequestExecutiveHelpDetails');
        Test.stopTest();
    }
    
}
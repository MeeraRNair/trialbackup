/* 
* Author   : Ranjith Mergu
* Purpose  : This class prevents Support_Request_Executive_Help PB invocation, when Request Executive Help Details Record Type is not true.
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0 	TFS7561655		FY20-0102		14/01/2020		Ranjith Mergu	Idea Intake 08148: Specialty Capability - Request Executive Help - Functionality
*/ 
public class SupportRequestExecutiveHelpDetailsPB {
    @InvocableMethod(label='RequestExecutiveHelpDetails' description='Executes only when Request Executive Help Details not true')
    Public Static void isNotRequestExecutiveHelpDetails(List<String> listHelpDetails) {
        system.debug('SupportRequestExecutiveHelpDetailsPB>>>'+listHelpDetails); 
    }
}
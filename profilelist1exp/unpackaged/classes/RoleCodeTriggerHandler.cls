/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionalities implemented on Role_Code__c.
 * 

History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        Role Code TriggerHandler
*/

public class RoleCodeTriggerHandler extends TriggerHandler {

    public static RoleCodeRecordSelector roleCodeRecSelector;
    public static RoleCodeTriggerHandler handler;

    public override void getRecordSelector() {
        handler = this;
        roleCodeRecSelector = new RoleCodeRecordSelector(Trigger.new, Trigger.oldMap, this);
    }
}
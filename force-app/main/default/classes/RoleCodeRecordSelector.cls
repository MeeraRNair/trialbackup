/*
 * Purpose  : Centralize the record selection process for Role_Code__c.
 *          Defines the methods which iterate and segregate the Role Code records for further use.

History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0         04-Nov-2019         Abhinav             CR#18325        Role Code Record Selector

*/

public class RoleCodeRecordSelector extends RecordSelector {
    
    private TriggerHandler roleCodeTrigHandler;
    
    public RoleCodeRecordSelector(list<sObject> listRoleCodes, map<Id, sObject> mapOldRoleCodes, TriggerHandler roleCodeTrigHandler) {
        this.roleCodeTrigHandler = roleCodeTrigHandler;
        this.getRecords(listRoleCodes, mapOldRoleCodes);
        
        if(listRoleCodes != null) {
            this.getRelatedRecords(listRoleCodes);
        }/* else if(mapOldRoleCodes != null) {
            this.getRelatedRecords(mapOldRoleCodes.values());
        }*/
    }
    
    protected override void getRecords(list<sObject> listRoleCodes, map<Id, sObject> mapOldRoleCodes) {
    }
    
    protected override void getRelatedRecords(list<sObject> listRoleCodes) {
    }
}
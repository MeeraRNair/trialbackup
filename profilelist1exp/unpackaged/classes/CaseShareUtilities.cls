/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to CaseShare.
 *
 */
 
public class CaseShareUtilities {
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR 10751    16.03       30-Dec-2014     Ragu            This logic is separated from AfterInsertUpdateCaseTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void shareWithCaseCreator(list<Case> lstNewCases, map<Id, Case> mapOldCases) {
        Id npsRTId = StaticFactory.getRecordTypeIdByName('Case', 'NPS Cases');
        list<CaseShare> lstCaseShares = new list<CaseShare>();
        
        for(Case newCase : lstNewCases) {
            Case oldCase = mapOldCases.get(newCase.Id);
            if(newCase.RecordTypeId != npsRTId && oldCase.OwnerId == newCase.CreatedById && newCase.OwnerId != newCase.CreatedById && newCase.Unauthenticated_Case__c== False) {
                CaseShare cShare = new CaseShare();
                cShare.CaseId = newCase.Id;
                cShare.UserOrGroupId = newCase.CreatedById;
                cShare.CaseAccessLevel = 'Edit';
                lstCaseShares.add(cShare);
            }
        }
       
        if(!lstCaseShares.isEmpty() ) {
            insert lstCaseShares;
        }
    }
    
}
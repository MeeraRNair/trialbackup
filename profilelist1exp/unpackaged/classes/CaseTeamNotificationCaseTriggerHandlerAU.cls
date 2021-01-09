/*
 * Author   : Subhasini Bhosal
 * Purpose  : Send Case Resolved Email Case Team members
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * Story  -7278525      0102        3-Oct-2019      Meenu Sinha     Added In progress cases
 *                     
 */ 

public class CaseTeamNotificationCaseTriggerHandlerAU implements AfterUpdate {
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld) {
        
        Id idCSH = StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk');
        Id idCSHin = StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk (internal only)');
        
        List<Case> listCSHCases = new List<Case>();
        List<Case> listCaseObj = listNew;       
        
        for(Case caseIterator : listCaseObj) {    

            /*Meenu--Added In progress cases*/
            Case objCase = (Case)mapOld.get(caseIterator.id);
      
            if((caseIterator.RecordTypeId == idCSH || caseIterator.RecordTypeId == idCSHin) && (caseIterator.Status == 'Resolved' 
                    || (objCase.Status != caseIterator.Status && caseIterator.Status == 'In Progress'))) {
                listCSHCases.add(caseIterator);
            }
        }
        if(listCSHCases.size() > 0) {
            CSHCaseTeamUtilities.sendEmailToCaseTeam(listCSHCases);
        }
        
    }

}
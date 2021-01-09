/*
 * Author   : Haribabu Adra
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on CSH Case.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0                  FY20 1002   06-Aug-2019     Hari A          Case creator is added to the case team automatically when create case as sfdc user 
 * 2.0                  FY20 0102   24-Oct-2019     Hari A          Notify when case is created in status open    
 */ 
public class CaseTeamCaseTriggerHandlerAI implements AfterInsert{
     
    public void handleAfterInsert(List<sObject> listNew){
        Id idCSH = StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk');
        Id idCSHin = StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk (internal only)');
        List<Case> listCSHCases = new List<Case>();
        List<Case> listCSHCasesNotify = new List<Case>();
        List<Case> listCaseObj = listNew;
        List<User> listPartUsr = [select id,IsPortalEnabled from User where id=:Userinfo.getUserId() and IsPortalEnabled=true limit 1]; 
        if(listPartUsr.isEmpty()){
            for(Case caseIterator:listCaseObj){
                if((caseIterator.RecordTypeId ==idCSH || caseIterator.RecordTypeId ==idCSHin) && caseIterator.Unauthenticated_Case__c<>true && caseIterator.SuppliedEmail== null){
                    listCSHCases.add(caseIterator);
                }
            }
            if(!listCSHCases.isEmpty()){    
                CSHCaseTeamUtilities.addCaseObserverToCaseTeam(listCSHCases);
            } 
        }
        
        for(Case caseIterator:listCaseObj){
            if((caseIterator.RecordTypeId ==idCSH || caseIterator.RecordTypeId ==idCSHin) && caseIterator.Status=='Open'){
                listCSHCasesNotify.add(caseIterator);
            }
        }
        if(!listCSHCasesNotify.isEmpty()){
            CSHCaseTeamUtilities.sendEmailToCaseTeam(listCSHCasesNotify);
        }       
   }
}
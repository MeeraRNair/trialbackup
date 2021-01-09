/*
 * Author   : Rajiv  
 * Purpose  : Trigger handler on SolutionFocusReportingCategory__c Before Delete
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0					1002			27-08-2019		Rajiv			Modify the related hidden Solution_Focus_Reporting_Category__c, Visit Control and Vist records when we delete any SolutionFocusReportingCategory__c record
 */
public class VO_SFRCTriggerHandlerBD implements BeforeDelete{
	public void handleBeforeDelete(List<sObject> listOld){
    	Set<Id> setSFRCValue = new Set<Id>();
        Set<Id> setDeletedSFRCVisits = new Set<Id>();
        
        for(SolutionFocusReportingCategory__c sfrcObj : (List<SolutionFocusReportingCategory__c>)Trigger.old){
            setSFRCValue.add(sfrcObj.Id);
        }
        
        if(setSFRCValue.size()>0){
            List<Solution_Focus_Reporting_Category__c> listSFRCToDelete = [select id, Visit__c from Solution_Focus_Reporting_Category__c where Solution_Focus_Reporting_Category_Value__c IN :setSFRCValue];
            for(Solution_Focus_Reporting_Category__c sfrc : listSFRCToDelete)
            {
               setDeletedSFRCVisits.add(sfrc.Visit__c); 
            }
            delete listSFRCToDelete;
            
            VO_SFRCRecordUpdateBatch bcObj = new VO_SFRCRecordUpdateBatch() ;
            bcObj.setSFRCIdSet = setSFRCValue;
            bcObj.setDeletedSFRCVisits = setDeletedSFRCVisits;
            Database.executeBatch(bcObj, 1);
        }
    }
}
/*
 * Author   : Rajiv  
 * Purpose  : Trigger handler on SolutionFocusReportingCategory__c After Delete
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0					1002			27-08-2019		Rajiv			Modify the related hidden Solution_Focus_Reporting_Category__c, Visit Control and Vist records when we delete any SolutionFocusReportingCategory__c record
 */
public class VO_SFRCTriggerHandlerAD implements AfterDelete{
	public void handleAfterDelete(List<sObject> listOld){
    	Set<Id> setSFRCValue = new Set<Id>();
        for(SolutionFocusReportingCategory__c sfrcObj : (List<SolutionFocusReportingCategory__c>)Trigger.oldMap.values()){
            setSFRCValue.add(sfrcObj.Id);
        }
        if(setSFRCValue.size()>0){
            VO_SFRCRecordUpdateBatch bcObj = new VO_SFRCRecordUpdateBatch() ;
            bcObj.setSFRCIdSet = setSFRCValue;
            Database.executeBatch(bcObj, 1);
        }
    }
}
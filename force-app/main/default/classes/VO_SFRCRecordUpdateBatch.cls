/**
  * Author   : Rajiv  
  * Purpose  : Controller class for page VO_SFRCMultiSelect getting used in Visit Control reord view
  * 
  * Revision CR Number   Release No      Date            Modified By     Description
  * -------- ---------   ----------      -----------     ------------    -----------
  * 1.0					1002			27-08-2019		Rajiv			Display and modify SF/RC COnfig records to support multi select picklist view. Perform all operations  related to the changes
  */
public class VO_SFRCRecordUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
	// This set contains Solution_Focus_Reporting_Category_Value__c records Ids
    public Set<Id> setSFRCIdSet = new Set<Id>();
	// This set contains Id for related visits if any SF/RC COnfig record deleted was getting referenced in those records
    public Set<Id> setDeletedSFRCVisits = new Set<Id>();
    
	/*
	 * start method for batch class:: get all Solution_Focus_Reporting_Category__c records if any for related setSFRCIdSet values
	 */
	public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> setvisitIds = new Set<Id>();// This set contains VisitOps__Visit__c records Ids
        for(Solution_Focus_Reporting_Category__c obj : [select id, Solution_Focus_Reporting_Category_Name__c, Solution_Focus_Reporting_Category_Value__c, SolutionFocusReportingCategoryName__c, Visit__c from Solution_Focus_Reporting_Category__c where Solution_Focus_Reporting_Category_Value__c IN : setSFRCIdSet]){
            setvisitIds.add(obj.Visit__c);
        }
        if(!setDeletedSFRCVisits.isEmpty())
        {
            setvisitIds.addAll(setDeletedSFRCVisits);
        }
        
        return Database.getQueryLocator('select Id from VisitOps__Visit__c where Id IN : setvisitIds');
    }
    
	/*
	 * execute method for batch class, updates the related Solution_Focus_Reporting_Category__c, VisitOps__Visit_Control__c and VisitOps__Visit__c records
	 * if there was any change in the SF/RC Config record
	 */
    public void execute(Database.BatchableContext bc, List<VisitOps__Visit__c> listScope){
        if(listScope!=null && listScope.size()>0){
            VisitOps__Visit__c visitObj = listScope[0]; 
            String strSelectedKeys = '';
            List<Solution_Focus_Reporting_Category__c> listSFRCRelatedList = [select id, Solution_Focus_Reporting_Category_Name__c, SolutionFocusReportingCategoryName__c, Solution_Focus_Reporting_Category_Value__c, Visit__c from Solution_Focus_Reporting_Category__c where Visit__c =: visitObj.Id];
            for(Solution_Focus_Reporting_Category__c obj : listSFRCRelatedList){
                obj.Solution_Focus_Reporting_Category_Name__c = Obj.SolutionFocusReportingCategoryName__c;
                strSelectedKeys = strSelectedKeys + Obj.SolutionFocusReportingCategoryName__c + '; ';
            }
            if(String.isNotBlank(strSelectedKeys)){
                strSelectedKeys = strSelectedKeys.trim();
                strSelectedKeys = strSelectedKeys.substring(0,strSelectedKeys.length()-1);
            }
            
            //Update Visit Record
            visitObj.Solution_Focus_Reporting_Category__c = strSelectedKeys;
            update visitObj;
            
            //Update Solution_Focus_Reporting_Category__c Record
            update listSFRCRelatedList;
            
            //update VisitOps__Visit_Control__c records
            List<VisitOps__Visit_Control__c> listvcs = [select id, Solution_Focus_Reporting_Category__c from VisitOps__Visit_Control__c where VisitOps__VisitControlVisit__c =: visitObj.Id];
            for(VisitOps__Visit_Control__c vcObj : listvcs){
                vcObj.SolutionFocusReportingCategory__c = strSelectedKeys;
            }
            update listvcs;
        }
    }
	/*
	 * finish method for batch class:
	 */
    public void finish(Database.BatchableContext bc){
    }    
}
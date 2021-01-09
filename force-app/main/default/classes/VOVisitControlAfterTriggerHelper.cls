/******************************************************************************************
* Name         :    VOVisitControlAfterTriggerHelper
* Description  :    Helper class for Visist Control After Trigger
* Author       :    Priyanka Challa, VisitOps
*
* Modification Log
* ----------------
*Version        Date         Developer     Chg #         Comments
* ----------- ------------- ------------- ------------------------------------------------
*1.0            04/Sep/18    Krishna       5538206       Customer Engagement: Solution Focus /Reporting Category error on removal of values
*******************************************************************************************/
public class VOVisitControlAfterTriggerHelper {
    
    /**
* Method Name : populateSolutionFocus/ReportingCategory
* Description : Method to create/delete Solution Category based on the selection of the multipick list in visit control
* Parameters  : List<VisitOps__Visit_Control__c>, Map<Id, VisitOps__Visit_Control__c>
* Returns     : None
*/
    public static void populateSolutionFocusReportingCategory (List<VisitOps__Visit_Control__c> newVisitControlList, 
                                                               Map<Id,VisitOps__Visit_Control__c> oldVCMap)
    {
        Set<Id> vControlIds = new set<Id>(); 
        Map<Id, string> vControlSolutionOldMap = new  Map<Id, string>();
        Map<Id, string> vControlSolutionNewMap = new  Map<Id, string>();
        List<Solution_Focus_Reporting_Category__c> lstSolutionCategory = new List<Solution_Focus_Reporting_Category__c>();
        
        //Iterating through new Visit Control List
        for (VisitOps__Visit_Control__c vControl : newVisitControlList) {
            if (oldVCMap.get(vControl.Id).Solution_Focus_Reporting_Category__c != vControl.Solution_Focus_Reporting_Category__c ) {
                vControlIds.add(vControl.VisitOps__VisitControlVisit__c);
                vControlSolutionOldMap.put(vControl.VisitOps__VisitControlVisit__c, oldVCMap.get(vControl.Id).Solution_Focus_Reporting_Category__c);
                vControlSolutionnewMap.put(vControl.VisitOps__VisitControlVisit__c, vControl.Solution_Focus_Reporting_Category__c);
            }        
        }
        
        //Start - CR16173
        List<VisitOps__Visit__c> visitListTobeUpdated= new List<VisitOps__Visit__c>();
        
        List<VisitOps__Visit__c> lstVisitOpsVisit = [select id, Solution_Focus_Reporting_Category__c from  VisitOps__Visit__c where Id in : vControlIds];
        system.debug('lstVisitOpsVisit :: '+lstVisitOpsVisit);
        String[] listOfSf ;
        for(VisitOps__Visit__c eachVisit : lstVisitOpsVisit){
            //add the new Solution Category to the list
            if(vControlSolutionnewMap.get(eachVisit.Id) != null){
                listOfSf = vControlSolutionnewMap.get(eachVisit.Id).split(';');
                 String SfRcValue = String.join(listOfSf, '; ');
                 system.debug('++++++++++++ SfRcValue: '+SfRcValue);
                eachVisit.Solution_Focus_Reporting_Category__c = SfRcValue;
                listOfSf.clear(); 
                visitListTobeUpdated.add(eachVisit);
            }else{
                eachVisit.Solution_Focus_Reporting_Category__c = '';
                visitListTobeUpdated.add(eachVisit);
            }
            
        }
        if(!visitListTobeUpdated.isEmpty()){
            update visitListTobeUpdated;
        }        
        //End - CR16173
        
        
        //Fetch Solution Category for the corresponding Visit Controls
        List<Solution_Focus_Reporting_Category__c> lstSolutionCategories = [select id,Visit__c, Solution_Focus_Reporting_Category_Name__c from Solution_Focus_Reporting_Category__c 
                                                                            where Visit__c in : vControlIds];
        Map<string, Solution_Focus_Reporting_Category__c> SolutionMap= new Map<string, Solution_Focus_Reporting_Category__c>();
        List<Solution_Focus_Reporting_Category__c> lstdtsremove = new List<Solution_Focus_Reporting_Category__c>();
        
        //Iterate through the SolutionCategory list and populate SolutionMap
        for (Solution_Focus_Reporting_Category__c vc : lstSolutionCategories) {
            SolutionMap.put(vc.Solution_Focus_Reporting_Category_Name__c, vc);
        }
        
        //Iterate through visit control ids
        for (id vcId : vControlIds) {
            
            Set<string> SolutionCategoryNewList = new Set<String>();
            Set<string> SolutionCategoryOldList = new Set<String>();
            List<string> SolutionCategorysList = new List<string>();
            
            //add the new Solution Category to the list
            SolutionCategoryNewList.addAll(vControlSolutionnewMap.get(vcId)!=null?vControlSolutionnewMap.get(vcId).split(';'):new List<String>());
            
            //add the old Solution Category to the list
            SolutionCategoryOldList.addAll(vControlSolutionOldMap.get(vcId)!=null?vControlSolutionOldMap.get(vcId).split(';'):new List<String>());
            
            //Iterate through new list, check if it is available in old list, if not add it to the list(to create new Solution topic reocrd)
            for (string dtNew : SolutionCategoryNewList) {
                if (!(SolutionCategoryOldList.contains(dtNew))) {
                    SolutionCategorysList.add(dtNew); 
                    
                } 
            }
            //Iterate through old list, check if it is available in new list, if not add it to the list(to delete that Solution topic reocrd)
            for (string dtOld : SolutionCategoryOldList) {
                if (!(SolutionCategoryNewList.contains(dtOld))) {
                    lstdtsremove.add(SolutionMap.get(dtOld)); 
                    
                } 
            }
            system.debug('SolutionCategorysList'+SolutionCategorysList);
            //iterate through SolutionCategorys 
            for (string SolutionCategory : SolutionCategorysList) { 
                Solution_Focus_Reporting_Category__c dtObj = new Solution_Focus_Reporting_Category__c();
                dtObj.Visit__c = vcId;
                dtObj.Solution_Focus_Reporting_Category_Name__c = SolutionCategory;
                lstSolutionCategory.add(dtObj); 
            }
        }
        //Insert the new Solution topic records
        if(!lstSolutionCategory.isEmpty())
            Insert lstSolutionCategory;
        //remove the old Solution topic records(if any)
        if(!lstdtsremove.isEmpty()){
            Database.DeleteResult[] drList = Database.Delete(lstdtsremove,false);
            for(Integer count = 0;count<drList.size();count++) {
                Database.DeleteResult dr = drList.get(count);
                if (!dr.isSuccess()) {                   
                    for(Database.Error err:dr.getErrors()) {
                        System.debug('Error occured---'+err.getMessage());
                        newVisitControlList[0].addError(err.getMessage());
                    }                    
                }
            }
        }
    }
    
    /**
* US / CR     : 5078684 / 16173    
* Method Name : populateSupportingCscCenter
* Description : Method to update Supporting CSC Centers based on the selection of the multipick list in visit control
* Parameters  : List<VisitOps__Visit_Control__c>, Map<Id, VisitOps__Visit_Control__c>
* Returns     : None
*/
    
    public static void populateSupportingCscCenter (List<VisitOps__Visit_Control__c> newVisitControlList, Map<Id,VisitOps__Visit_Control__c> oldVCMap){
        
        Set<Id> vControlIds = new set<Id>();            
        List<VisitOps__Visit__c> visitListTobeUpdated = new List<VisitOps__Visit__c>(); 
        Map<Id, string> vControlSolutionNewMap = new  Map<Id, string>();
        for (VisitOps__Visit_Control__c vControl : newVisitControlList) {
            if(oldVCMap.get(vControl.Id).Supporting_CSC_Centers__c !=  vControl.Supporting_CSC_Centers__c){
                vControlIds.add(vControl.VisitOps__VisitControlVisit__c);
                vControlSolutionnewMap.put(vControl.VisitOps__VisitControlVisit__c, vControl.Supporting_CSC_Centers__c);
            }
        }
        List<VisitOps__Visit__c> lstVisitOpsVisit = [select id, Supporting_CSC_Centers__c from  VisitOps__Visit__c where Id in : vControlIds];
        
        String[] listOfSf ;
        if(!lstVisitOpsVisit.isEmpty()){        
            for(VisitOps__Visit__c eachVisit : lstVisitOpsVisit){
                if(vControlSolutionnewMap.get(eachVisit.Id)!=null && vControlSolutionnewMap.get(eachVisit.Id)!=''){
                    listOfSf = vControlSolutionnewMap.get(eachVisit.Id).split(';');
                    String SfRcValue = String.join(listOfSf, '; ');
        
                    eachVisit.Supporting_CSC_Centers__c = SfRcValue;
                    listOfSf.clear(); 
                }
                else
                {
                    eachVisit.Supporting_CSC_Centers__c = '';
                }
                visitListTobeUpdated.add(eachVisit);
            }
        }
        if(!visitListTobeUpdated.isEmpty()){
            update visitListTobeUpdated;
        }
    }

}
/**
  * Author   : Rajiv  
  * Purpose  : Controller class for page VO_SFRCMultiSelect getting used in Visit Control reord view
  * 
  * Revision CR Number   Release No      Date            Modified By     Description
  * -------- ---------   ----------      -----------     ------------    -----------
  * 1.0					1002			27-08-2019		Rajiv			Display and modify SF/RC COnfig records to support multi select picklist view. Perform all operations  related to the changes
  */
public with sharing class VO_SFRCMultiSelect_Ctrl  {
    /*
	 * to display all active selected value in custom SF/RC picklist view
	 */
    public list<SelectOption> listSelectedValues { get; set; }
	/*
	 * to display all active value in custom SF/RC picklist view
	 */
    public list<SelectOption> listAllValues { get; set; }
	/*
	 * the Visit Control record in context
	 */
    public VisitOps__Visit_Control__c visitConObj { get; set; }
	/*
	 * key=> SolutionFocusReportingCategory__c record Id, value=> Solution_Focus_Reporting_Category__c record Id
	 */
    public Map<Id, Id> mapExistingSFRC { get; set; }
	/*
	 * Key => SolutionFocusReportingCategory__c record Id, Value => the text field value of Solution_Focus_Reporting_Category_Value__c
	 */
    public Map<id,String> mapAllSFRCMap { get; set; }
	/*
	 * to set width of multiselect picklist component on UI
	 */
    public String strWidth{get;set;}
	/*
	 * to set aize of multiselect picklist component on UI
	 */
    public String strSize{get;set;}
	/*
	 * All inactive selected key
	 */
    public String strInactiveSelectedKeys{get;set;}
	
	
    public String strLeftOptionsHidden {get; 
        set {
        strLeftOptionsHidden = value;
        }
    }
    
    public String strRightOptionsHidden {get; 
        set {
            strRightOptionsHidden = value;
        }
    }
    
	/*
	 * Constructor method, to support extention controller behaviour
	 * perform the initial operation to get vist control, related visit reords and set the picklist view for avaialble and selected values
	 */
    public VO_SFRCMultiSelect_Ctrl (apexPages.StandardController stdcon){
        visitConObj = (VisitOps__Visit_Control__c)stdcon.getRecord();
        visitConObj = [SELECT id,VisitOps__VisitControlVisit__c FROM VisitOps__Visit_Control__c WHERE id=:visitConObj.Id];
        fetchValue(); 
        strWidth = '300px';
        strSize = '8';
    }
	
	/*
	 * fetch related SF/RC Config reords and set the picklist view for avaialble and selected values
	 */
    public void fetchValue(){
        strInactiveSelectedKeys = '';
        listSelectedValues = new List<SelectOption>(); 
        listAllValues = new List<SelectOption>();
        mapAllSFRCMap = new map<id,String>();
        mapExistingSFRC = new map<Id, Id>();
        //Fetch existing records.
        for(Solution_Focus_Reporting_Category__c existingSFRCObj : [Select Id, Solution_Focus_Reporting_Category_Value__c, Visit__c from Solution_Focus_Reporting_Category__c WHERE Visit__c= :visitConObj.VisitOps__VisitControlVisit__c order by Solution_Focus_Reporting_Category_Name__c]){
            if(String.isNotBlank(existingSFRCObj.Solution_Focus_Reporting_Category_Value__c)){
                mapExistingSFRC.put(existingSFRCObj.Solution_Focus_Reporting_Category_Value__c, existingSFRCObj.id);
           }
        }

        //Fetch SF/RC multi-select values.
        for(SolutionFocusReportingCategory__c sfObj : [Select Id, Solution_Focus_Reporting_Category_Value__c,Active__c from SolutionFocusReportingCategory__c order by Solution_Focus_Reporting_Category_Value__c] ) {
            if(sfObj.Active__c){
                if(mapExistingSFRC.containsKey(sfObj.Id)){
                    listSelectedValues.add(new SelectOption(sfObj.Id, sfObj.Solution_Focus_Reporting_Category_Value__c));
                }else{
                    listAllValues.add(new SelectOption(sfObj.Id, sfObj.Solution_Focus_Reporting_Category_Value__c)); 
                }
                mapAllSFRCMap.put(sfObj.Id, sfObj.Solution_Focus_Reporting_Category_Value__c);
                
            }else if(mapExistingSFRC.containsKey(sfObj.Id)){
                strInactiveSelectedKeys = strInactiveSelectedKeys + sfObj.Solution_Focus_Reporting_Category_Value__c + '; ';
                //Remove Inactive record from, so system admin manually deleted this record.
                mapExistingSFRC.remove(sfObj.Id);
            }
        }            
    }
    
	/*
	 * Perform save operation on the selected or de-selected SF/RC Config records
	 */
    public void saveValues() {
        try{
        set<String> setSelectedIds = new set<String>();
        if(String.isNotBlank(StrRightOptionsHidden)){
            setSelectedIds = new set<String>(StrRightOptionsHidden.split(';'));        
        }
  
        list<Solution_Focus_Reporting_Category__c> listNewList =new list<Solution_Focus_Reporting_Category__c>();
        String strKey = '';
        string strSelectedKeys = strInactiveSelectedKeys;
        for(String strObjId : setSelectedIds){
            strKey = '';
            if(mapAllSFRCMap.containsKey(strObjId)){
                Solution_Focus_Reporting_Category__c obj = new Solution_Focus_Reporting_Category__c();
                strKey =  mapAllSFRCMap.get(strObjId);
                strSelectedKeys = strSelectedKeys + strKey + '; ';
                obj.Solution_Focus_Reporting_Category_Name__c = strKey;
                obj.Visit__c = visitConObj.VisitOps__VisitControlVisit__c;
                obj.Solution_Focus_Reporting_Category_Value__c = strObjId;
                if(mapExistingSFRC.containsKey(strObjId)){
                    obj.Id = mapExistingSFRC.get(strObjId);
                    mapExistingSFRC.remove(strObjId);
                }
                listNewList.add(obj);
            } 
        }
        system.debug('listNewList======> ' + listNewList);
        if(listNewList.size()>0){
            //Upsert "Solution Focus/Reporting Category" record.
            upsert listNewList;       
        }
        
        //Update Visit record field(Solution Focus/Reporting Category).
        if(String.isNotBlank(strSelectedKeys)){
            strSelectedKeys = strSelectedKeys.trim();
            strSelectedKeys = strSelectedKeys.substring(0,strSelectedKeys.length()-1);
            
            List<String> listSelectedStr = strSelectedKeys.split(';');
            listSelectedStr.sort();
            strSelectedKeys = String.join(listSelectedStr, ';');
        }
        VisitOps__Visit__c vObj = new VisitOps__Visit__c();
        vObj.Id = visitConObj.VisitOps__VisitControlVisit__c;
        vObj.Solution_Focus_Reporting_Category__c = strSelectedKeys;
        update vObj;
        
        visitConObj.SolutionFocusReportingCategory__c = strSelectedKeys;
        update visitConObj;
         
        //Delete old one "Solution Focus/Reporting Category" record.
        Delete [SELECT id FROM Solution_Focus_Reporting_Category__c Where Id IN :mapExistingSFRC.values()];
        fetchValue();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Successfully saved.'));
            
        }catch(Exception ex){
            system.debug('Exception ==> ' + ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + ex));
        }   
    }
    
}
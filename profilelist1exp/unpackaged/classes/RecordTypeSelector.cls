/***********************************************************
    * Name          : listRecordTypeSelector
    * Description   : Controller class for 'RecordTypeSelection' and 'TaskRecordTypeSelector' VF page
    * ---------------------------------------------------------
    * Revision  Name       Date             Description
    * 1.0       Rahul     29. Nov. 2018     Controller class for 'RecordTypeSelection' and 'TaskRecordTypeSelector' VF page
************************************************************/

public Without Sharing class RecordTypeSelector { 
    
    public CTI_Call_Log__c objCTI{get; set;}
    Public List<RecordType> listRecordType {get;set;}
    Public List<RecordType> listTaskRecordType {get;set;}
    Public Map<String, Id> mapOfNameToId {get;set;}
    Public Map<String, Id> mapOfNameToTaskId {get;set;}
    public string strSelectedRecordType {get;set;}
    public string strSelectedTaskRecordType {get;set;}
    public CTI_Call_Log__c ctiCallLogId {get;set;}
    
    
    public List<SelectOption> getRecordTypes() {
        List<SelectOption> listRecordTypeSelector = new List<SelectOption>();
        
        for(String str : mapOfNameToId.keySet()) {
            listRecordTypeSelector.add(new SelectOption(mapOfNameToId.get(str), str));  
        }
        system.debug(listRecordTypeSelector);
        return listRecordTypeSelector;
    } 
    
    public List<SelectOption> getTasksRecordTypes() {
        List<SelectOption> listRecordTypeSelector = new List<SelectOption>();       
        for(String str : mapOfNameToTaskId.keySet()) {
            listRecordTypeSelector.add(new SelectOption(mapOfNameToTaskId.get(str), str));  
        }
        system.debug(listRecordTypeSelector);
        return listRecordTypeSelector;
    }
    
    public void testMethod1() {
        system.debug('Refresh Block');
    }
    
    public RecordTypeSelector(ApexPages.StandardController controller)
    {   
        strSelectedRecordType = '';
        ctiCallLogId  = new CTI_Call_Log__c();
        objCTI = new CTI_Call_Log__c();
        listRecordType  = new List<RecordType>();
        listTaskRecordType = new List<RecordType>();
        mapOfNameToId = new Map<String, Id>();
        mapOfNameToTaskId  = new Map<String, Id>();
        String strParam = apexpages.currentpage().getparameters().get('paramval2'); 
        ctiCallLogId = [Select Id, Name, Account__c From CTI_Call_Log__c Where Id =:strParam limit 1];
        
        listRecordType  = [Select Id, Name From RecordType where sobjecttype = 'Opportunity'];
        system.debug('list is'+listRecordType);
        for(RecordType rcType : listRecordType ) {
            mapOfNameToId.put(rcType.Name, rcType.Id);
        }
        
        listTaskRecordType  = [Select Id, Name From RecordType where sobjecttype = 'Task'];
        system.debug('list is'+listRecordType);
        for(RecordType rcType : listTaskRecordType) {
          if(rcType.Name != 'Master Record Type') {
            mapOfNameToTaskId.put(rcType.Name, rcType.Id);
          }
        }
    }
}
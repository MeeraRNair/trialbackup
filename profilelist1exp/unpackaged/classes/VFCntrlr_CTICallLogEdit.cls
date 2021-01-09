public Without Sharing class VFCntrlr_CTICallLogEdit
{
    public CTI_Call_Log__c objCTI{get; set;}
    Public List<RecordType> listRecordType {get;set;}
    Public Map<String, Id> mapOfNameToId {get;set;}
    Public String straccId {get;set;}
    public string strselectedRecordType {get;set;}
    
 
    
    public List<SelectOption> getRecordTypes() {
        List<SelectOption> recordTypeOptions = new List<SelectOption>();
        
        for(String str : mapOfNameToId.keySet()) {
            recordTypeOptions.add(new SelectOption(mapOfNameToId.get(str), str));  
        }
        system.debug(recordTypeOptions);
        return recordTypeOptions;
    }
    
    public void testMethod1() {
     system.debug('Refresh the page');
    }
    
    public VFCntrlr_CTICallLogEdit(ApexPages.StandardController controller)
    {   
        strselectedRecordType = '';
        objCTI = new CTI_Call_Log__c();
     //   straccId = apexpages.currentpage().getparameters().get('id');
        listRecordType  = new List<RecordType>();
        mapOfNameToId = new Map<String, Id>();
        
        listRecordType  = [Select Id, Name From RecordType where sobjecttype = 'Opportunity'];
        system.debug('list is'+listRecordType);
        for(RecordType rcType : listRecordType ) {
            mapOfNameToId.put(rcType.Name, rcType.Id);
        }
       system.debug('Record Id is'+objCTI); 
        objCTI = (CTI_Call_Log__c)controller.getRecord();
       List<CTI_Call_Log__c> listCTI = new List<CTI_Call_Log__c>([SELECT Id, Name, Opportunity__c, Call_Type__c, Phone_Number__c, Account__c, Partner_Disti_Account__c, Call_Start_Time__c, Call_End_Time__c, Trip_Report__c, Contact__c, Owner.Name, Comments__c FROM CTI_Call_Log__c WHERE Id =: objCTI.Id LIMIT 1]);
       objCTI = listCTI.get(0);
        
    }
    
    public PageReference createOpportunity() {
  PageReference pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&nooverride=1&save_new_url=%2F006%2Fe');

// //setup/ui/recordtypeselect.jsp?ent=Opportunity&nooverride=1&save_new_url=%2F006%2Fe';
    return pageRef;
  }
    
    public void refreshOpportunity()
    {
         if(objCTI != null) {
        List<CTI_Call_Log__c> listCTI = new List<CTI_Call_Log__c >([SELECT Id, Opportunity__c FROM CTI_Call_Log__c WHERE Id =: objCTI.Id LIMIT 1]);
        if(!listCTI.isEmpty() && listCTI.get(0).Opportunity__c != null)
        {
            objCTI.Opportunity__c = listCTI.get(0).Opportunity__c;
        }
    }
    }  
    public void refreshContact()
    {
        List<CTI_Call_Log__c> listCTI = new List<CTI_Call_Log__c >([SELECT Id, Contact__c FROM CTI_Call_Log__c WHERE Id =: objCTI.Id LIMIT 1]);
        if(!listCTI.isEmpty() && listCTI.get(0).Contact__c != null)
        {
            objCTI.Contact__c = listCTI.get(0).Contact__c ;
        }
    }
    public pageReference saveRecord()
    {
    
 
      Database.SaveResult result = Database.update(objCTI, false);
      PageReference pf = new PageReference('/'+objCTI.Id+'?1=1');
      pf.setRedirect(true);

      return pf;
     /*   if(result.isSuccess())
        {
         ApexPages.StandardController objCTI = new ApexPages.StandardController(objCTI);
         return objCTI.view();
         
        }
        else
        {
            for(Database.Error err : result.getErrors())
            {
                if(err.getFields().get(0) == 'Opportunity__c')
                {
                    objCTI.Opportunity__c.addError(err.getMessage());
                }
                else if(err.getFields().get(0) == 'Contact__c')
                {
                    objCTI.Contact__c.addError(err.getMessage());
                }
            }
        }
        return null; */
    } 
}
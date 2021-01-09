public class CaseAsyncTriggerHandler {
    
    public void updateCaseStatusHistory(List<CaseChangeEvent> listCase) {
        List<Case_Status_History__c> listcaseChangeHistory = new List<Case_Status_History__c>();
        for(CaseChangeEvent cas : listCase) {
            EventBus.ChangeEventHeader header = cas.ChangeEventHeader;
            List<String> listrecordIds = header.getRecordIds();
            system.debug('***listrecordIds' +listrecordIds);
           if (header.changetype == 'CREATE') { 
                system.debug('&&&&in insert');
                for(Id eachRec:listrecordIds){                
                    Case_Status_History__c newCaseChangeHistory = new Case_Status_History__c();
                    
                    newCaseChangeHistory.Time_In__c = system.now();
                    newCaseChangeHistory.Status__c = 'Open';
                    newCaseChangeHistory.case_id__c=eachRec;
                    newCaseChangeHistory.case__c = eachRec;
                    system.debug('***newCaseChangeHistory' +newCaseChangeHistory);
                    listcaseChangeHistory.add(newCaseChangeHistory);
                }
            }
        }
        if(listcaseChangeHistory.size() > 0) {
            insert listcaseChangeHistory; 
        }
    }
    
    
    public void uACaseSendConfirmation(List<CaseChangeEvent> listCaseChange) {
        list<case> listCase = new list<case>();
         List<String> listCaseRecordIds = new List<String>();
         set<String> listofupdatecase = new set<String>();
    
      for(CaseChangeEvent caseChange : listCaseChange){
                if (caseChange.ChangeEventHeader.getChangetype()  == 'CREATE' ) {
                    EventBus.ChangeEventHeader header = caseChange.ChangeEventHeader;
                    System.debug('Received change event for ' + header.entityName +' for the ' + header.changeType + ' operation.'); 
                    
                    Map<String,Object> mapEventChanges = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(caseChange));
                    system.debug('mapEventChanges*****'+mapEventChanges);
                    if(mapEventChanges.containsKey('Unauthenticated_Case__c') && mapEventChanges.get('Unauthenticated_Case__c') == true){
                        listofupdatecase.addall(caseChange.ChangeEventHeader.getRecordIds());
                      }
                    
                }

        }
        system.debug('>>>listofupdatecase'+listofupdatecase);
        if(listofupdatecase.size()>0){
        list<case>  listUAcase = [select id,Unauthenticated_Case__c,Send_Confiramtion_Mail_for_UACase__c from case where id IN :listofupdatecase];
             system.debug('>>>listUAcase'+listUAcase);
             for(case cas:listUAcase ){
                  cas.Send_Confiramtion_Mail_for_UACase__c= true;
                
             }
            listCase.addall(listUAcase); 
        }
        system.debug('>>>listCase'+listCase);
        if(listCase.size()>0){
            update listCase;
        }
        
    }

}
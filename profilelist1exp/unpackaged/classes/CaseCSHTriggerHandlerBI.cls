/*
* Author   : Anuj
* Purpose  : Gives abstract view of all the business logics / functionality implemented on Case for CSH.
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      18158        1101       01-OCT-2019     Anuj            Populate field for CSH case
* 2.0      18203        1101       18-OCT-2019     Anuj            Populate field for CSH case from UA Form
*/ 
public class CaseCSHTriggerHandlerBI implements BeforeInsert{
    CaseTriggerHandler caseTrigHandler = new CaseTriggerHandler();
    
    public void handleBeforeInsert(List<sObject> listNew){
        List<case> listCases = listNew;
        list<Case> listNewCases = new List<Case>();
        list<Case> listUACases = new List<Case>();
        for(Case c : listCases) {
            if(c.Origin == 'EmailESP' && c.Priority == 'Normal' && 
               c.RecordTypeId == StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk (internal only)')) {
                   listNewCases.add(c);
               }
            else if(c.RecordTypeId == StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk') &&
                   	c.Unauthenticated_Case__c == true
                   ) {
                       listUACases.add(c);
                  }
        }
        if(listUACases.size() > 0) {
            CaseCSHEmailPopulator.populateRequestorFieldFromUAForm(listUACases);
        }
        if(listNewCases.size() > 0) {
            CaseCSHEmailPopulator.populateFieldsOnBeforeInsert(listNewCases);
        }
    }
    
}
/*
* Author   : Anuj
* Purpose  : Gives abstract view of all the business logics / functionality implemented on Case for CSH.
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      18158        1102       01-OCT-2019     Anuj            Populate field for CSH case
*/ 
public class EmailMessageCSHTriggerBI implements BeforeInsert{
    
    
    public void handleBeforeInsert(List<sObject> listNew){
        List<EmailMessage> listEmailMessage = listNew;
        if(listEmailMessage[0].parentId<>null){
            Case listCase = [Select id,Origin, Priority, RecordTypeId from Case where id = :listEmailMessage[0].parentId limit 1];
            if (listCase.Origin == 'EmailESP' && listCase.Priority == 'Normal' && 
                listCase.RecordTypeId == StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk (internal only)')){
                System.debug('Entered EmailMessage handleBeforeInsert');
            
            CSHCaseTeamUtilities.addToCaseTeam(listEmailMessage[0]);
            }
        }
    }
    
}
/*
* Author  : Ershad
* Purpose : CPSD trigger to change Flag for CPSD integration status to waiting Sync after update in CPSD Account.
* Objects : Account
*/
public class CPSDAccountTriggerHandlerAU implements AfterUpdate {
//AccountTriggerHandler triggerHandler = new AccountTriggerHandler();
public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
 /// Added by Ershad for CPSD integration status
        CPSDUpdateAccountstatusAU.cpsdAccountupdate(trigger.new, (map<Id, Account>)Trigger.oldMap);
             
 }
}
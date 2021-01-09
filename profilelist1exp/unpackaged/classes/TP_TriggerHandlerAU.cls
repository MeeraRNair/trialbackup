/*
* Author   : 
* Purpose  : 
* 
* Revision CR Number   	Release No      Date            Modified By     Description
* -------- ---------   	----------      -----------     ------------    -----------
* 2.0      17938       FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Method call below copied from TP_TriggerHandler
*/
public class TP_TriggerHandlerAU implements AfterUpdate{
    TP_TriggerHandler trigHandler = new TP_TriggerHandler();

    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){

        trigHandler.run();
        if(trigHandler.tpRecSelector.tpToshareWithManager != null){
            system.debug('#####onAfterUpdate Block##########');
            TP_Sharing.shareWithNewManager(trigHandler.tpRecSelector.tpToshareWithManager, trigHandler.tpRecSelector.mapOldTPAll);
        }
    }
}
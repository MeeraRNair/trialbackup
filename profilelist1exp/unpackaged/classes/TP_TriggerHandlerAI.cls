/*
* Author   : 
* Purpose  : 
* 
* Revision CR Number   	Release No      Date            Modified By     Description
* -------- ---------   	----------      -----------     ------------    -----------
* 2.0      17938       FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Method call below copied from TP_TriggerHandler
*/
public class TP_TriggerHandlerAI implements AfterInsert{
    TP_TriggerHandler trigHandler = new TP_TriggerHandler();

    public void handleAfterInsert(List<sObject> listNew){

        trigHandler.run();
        system.debug('#####onAfterInsert Block##########');
        TP_Sharing.shareWithNewManager(trigHandler.tpRecSelector.tpNewAllList);
    }
}
/*
* Author   : Harsha
* Purpose  : Gives abstract view of all the business logics / functionalities implemented on Territory Plan.
* 
* Revision CR Number   	Release No      Date            Modified By     Description
* -------- ---------   	----------      -----------     ------------    -----------
* 1.0      CR15172    	FY18-DCS-0102   27-Nov-2017     Harsha          Created for implementing "Centralized by Org" trigger architecture - Best practices
* 2.0      17938       FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework
*/

public class TP_TriggerHandler extends TriggerHandler {
    
    public TP_RecordSelector tpRecSelector;
    public override void getRecordSelector() {
        tpRecSelector = new TP_RecordSelector(Trigger.new, Trigger.oldMap, this);
    }
    /*
    public override void onAfterUpdate() {
        if(tpRecSelector.tpToshareWithManager != null){
            system.debug('#####onAfterUpdate Block##########');
            TP_Sharing.shareWithNewManager(tpRecSelector.tpToshareWithManager, tpRecSelector.mapOldTPAll);
        }
    }
    public override void onAfterInsert() {
        system.debug('#####onAfterInsert Block##########');
        TP_Sharing.shareWithNewManager(tpRecSelector.tpNewAllList);
    }*/
}
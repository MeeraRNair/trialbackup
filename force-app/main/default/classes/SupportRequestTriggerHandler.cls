/*
 * Author   : Sarbjeet
 * Purpose  : Gives abstract view of all the business logics / functionalities implemented on Support Request.
 */
 
public class SupportRequestTriggerHandler extends TriggerHandler {

    public static SupportRequestRecordSelector supportRecSelector;
    
    public override void getRecordSelector() {
        supportRecSelector = new SupportRequestRecordSelector(Trigger.new, Trigger.oldMap, this);
    }

}
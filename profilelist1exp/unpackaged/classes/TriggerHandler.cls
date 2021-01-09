/*
 * Author   : Ragu
 * Purpose  : Central handler for all the triggers.
 *          Triggers will delegate the control to run(), TriggerHandler then dispatches the events 
 *          to corresponding <<Object>>TriggerHandler class if that particular event method is overridden.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR10496     15.10           05-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR12722     FY17-DCS-0401   10-Mar-2015     Gan             Expose the ExecutionCounter to the child class
 * 3.0      CR17549     FY20-0702       04-Jun-2019     Fenny           Trigger framework changed, expose getExecutionCounter() to calling class
 * 4.0      CR18197     FY20-0102       31-OCT-2019     Gan             Reset the framework counter
 * 4.1      CR18302     FY20-0102       14-Nov-2019     Fenny           New ToRun() method to be called by Trigger before execute MetadataTriggerManager.Handler()
*/       

public virtual class TriggerHandler {
    
    public enum TriggerType { ISBEFORE, ISAFTER }
    public enum TriggerEvent { ISINSERT, ISUPDATE, ISDELETE, ISUNDELETE }
    public TriggerEvent trigEvent;
    public TriggerType trigType;
    
    private string strCurrentObjectName;
    private static map<string, ExecutionCounter> mapRecursiveDirectory = new map<string, ExecutionCounter>();
    
    // 4.1
    public boolean toRun() {
        if(!validateRun()) {
            return false;
        }
    
        // Dispatch control to the correct handler method
        if(Trigger.isBefore) {
            trigType = TriggerType.ISBEFORE;
            if(Trigger.isInsert) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onBeforeInsert()');
                trigEvent = TriggerEvent.ISINSERT;
            }
            else if(Trigger.isUpdate) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onBeforeUpdate()');
                trigEvent = TriggerEvent.ISUPDATE;
            }
            else if(Trigger.isDelete) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onBeforeDelete()');
                trigEvent = TriggerEvent.ISDELETE;
            }
        }
        else if(Trigger.isAfter) {
            trigType = TriggerType.ISAFTER;
            if(Trigger.isInsert) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onAfterInsert()');
                trigEvent = TriggerEvent.ISINSERT;
            }
            else if(Trigger.isUpdate) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onAfterUpdate()');
                trigEvent = TriggerEvent.ISUPDATE;
            }
            else if(Trigger.isDelete) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onAfterDelete()');
                trigEvent = TriggerEvent.ISDELETE;
            }
            else if(Trigger.isUndelete) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onAfterUndelete()');
                trigEvent = TriggerEvent.ISUNDELETE;
            }
        }
        this.getRecordSelector();
        return true;
    }

    public void run() {
        if(!validateRun()) {
            return;
        }
    
        // Dispatch control to the correct handler method
        if(Trigger.isBefore) {
            trigType = TriggerType.ISBEFORE;
            if(Trigger.isInsert) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onBeforeInsert()');
                trigEvent = TriggerEvent.ISINSERT;
                this.getRecordSelector();
                this.onBeforeInsert();
            }
            else if(Trigger.isUpdate) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onBeforeUpdate()');
                trigEvent = TriggerEvent.ISUPDATE;
                this.getRecordSelector();
                this.onBeforeUpdate();
            }
            else if(Trigger.isDelete) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onBeforeDelete()');
                trigEvent = TriggerEvent.ISDELETE;
                this.getRecordSelector();
                this.onBeforeDelete();
            }
        }
        else if(Trigger.isAfter) {
            trigType = TriggerType.ISAFTER;
            if(Trigger.isInsert) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onAfterInsert()');
                trigEvent = TriggerEvent.ISINSERT;
                this.getRecordSelector();
                this.onAfterInsert();
            }
            else if(Trigger.isUpdate) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onAfterUpdate()');
                trigEvent = TriggerEvent.ISUPDATE;
                this.getRecordSelector();
                this.onAfterUpdate();
            }
            else if(Trigger.isDelete) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onAfterDelete()');
                trigEvent = TriggerEvent.ISDELETE;
                this.getRecordSelector();
                this.onAfterDelete();
            }
            else if(Trigger.isUndelete) {
                Utility.printLimitsConsumption(strCurrentObjectName + ' => onAfterUndelete()');
                trigEvent = TriggerEvent.ISUNDELETE;
                this.getRecordSelector();
                this.onAfterUndelete();
            }
        }
    }

    // Make sure Trigger should continue to run
    private Boolean validateRun() {
        if(!Trigger.isExecuting) {
            throw new NotATriggerContextException('Trigger handler called outside of Trigger execution');
        }
        if(TriggerExecutionController.skipAllTriggers()) {
            return false;
        }
        
        sObject currentObject;
        if(Trigger.isDelete) {
            currentObject = Trigger.old[0];
        }
        else {
            currentObject = Trigger.new[0];
        }
        strCurrentObjectName = String.valueOf(currentObject.getSObjectType());
        
        TriggerExecutionControl__c triggerExeControl = TriggerExecutionControl__c.getInstance(strCurrentObjectName);
        if(triggerExeControl != null) {
            if(skipTriggersOnObject(triggerExeControl)) {
                return false;
            }
            
            // Code Block Start: Recursive execution control. Do not count it for test runs.
            if(!Test.isRunningTest() && triggerExeControl.RecursiveCount__c > 0) {
                ExecutionCounter execCounter = mapRecursiveDirectory.get(strCurrentObjectName);
                
                //added by Gan
                if(strCurrentObjectName.equalsIgnoreCase('Opportunity') && execCounter != null && checkRecursive.getCounter() == 0) {
                    execCounter.resetCounter();
                }
                if(execCounter != null) {
                    if(!execCounter.isValid()) {
                        // MARKER - Ragu on 10-Oct-2014: Need to comment throwing error in Production
                        //throw new MaximumTriggerRecursionExceededException('Maximum loop count of ' + execCounter.iMax + ' reached in ' + strCurrentObjectName);
                        return false;
                    }
                    else {
                        execCounter.incrementCounter();
                    }
                }
                else {
                    mapRecursiveDirectory.put(strCurrentObjectName, new ExecutionCounter(Integer.valueOf(triggerExeControl.RecursiveCount__c)));
                }
            }
            // Code Block End: Recursive execution control.
        }
        return true;
    }
    
    public Boolean skipTriggersOnObject(TriggerExecutionControl__c triggerExeControl) {
        if(triggerExeControl != null) {
            if(triggerExeControl.SkipTriggers__c) {
                return true;
            }
            else if(triggerExeControl.UsersToSkip__c != null && triggerExeControl.UsersToSkip__c.contains(UserInfo.getUserId().substring(0, 15))) {
                return true;
            }
        }
        return false;
    }
    
    public Boolean skipTriggersOnObject(String strObjectName) {
        return skipTriggersOnObject(TriggerExecutionControl__c.getInstance(strObjectName));
    }
    
    // Wrapper class to maintain maximum and current execution details for an Object.
    @TestVisible
    private class ExecutionCounter {
        public integer iMax {public get; private set;}
        public integer iCurrent {public get; private set;}
        
        public ExecutionCounter(integer iMax) {
            this.iMax = iMax;
            iCurrent = 1;
        }
        
        public boolean isValid() {
            // Value 1 in the Custom Setting represents 2 in the execution i.e. 1 for before event and 1 for after event.
            if(iCurrent <= (iMax * 2)) {
                return true;
            }
            return false;
        }
        
        //Added by Gan
        public void resetCounter() {
            System.debug('G1 -> TH iCurrent: ' + iCurrent + ', current limit:' + Limits.getQueries());
            iCurrent = 1;
        }
        
        public void incrementCounter() {
            iCurrent++;
        }
    }
    
    // 2.0 // 3.0
    public integer getExecutionCounter() {
        integer iCounter = 1;
        ExecutionCounter ec = mapRecursiveDirectory.get(strCurrentObjectName);
        if(ec != null) {
            iCounter = ec.iCurrent;
        }
        return iCounter;
    }
    
    protected virtual void getRecordSelector(){}
    protected virtual void onBeforeInsert(){}
    protected virtual void onBeforeUpdate(){}
    protected virtual void onBeforeDelete(){}
    protected virtual void onAfterInsert(){}
    protected virtual void onAfterUpdate(){}
    protected virtual void onAfterDelete(){}
    protected virtual void onAfterUndelete(){}
    
    
    public class NotATriggerContextException extends Exception {}
    public class MaximumTriggerRecursionExceededException extends Exception {}

}
public without sharing class MetadataTriggerManager {

    public class ClassNotFoundException extends Exception {}
    private string strCurrentObjectName;
    private static map<string, ExecutionCounter> mapRecursiveDirectory = new map<string, ExecutionCounter>();

    @TestVisible
    private static List<Trigger_Handler__mdt> listMockMetadata;

    private TriggerEventsToTriggerHandlers theseEventsToTriggerHandlers;
    
    @TestVisible
    private static TriggerObjectToEventsToHandlers sObjectNameToEventsToTriggerHandlers = new TriggerObjectToEventsToHandlers();

    public MetadataTriggerManager() {
        if(Trigger.new != null) {
            init(Trigger.new.getSObjectType());
        } else {
            init(Trigger.old.getSObjectType());
        }
    }

    public MetadataTriggerManager(sObjectType objectType) {
        init(objectType);
    }

    public void init(sObjectType objectType) {
        String strObjectName = objectType.getDescribe().getName();

        theseEventsToTriggerHandlers = sObjectNameToEventsToTriggerHandlers.get(strObjectName);
        sObjectNameToEventsToTriggerHandlers = new TriggerObjectToEventsToHandlers();

        if(theseEventsToTriggerHandlers == null) {
            if(Test.isRunningTest() && listMockMetadata != null) {
                sObjectNameToEventsToTriggerHandlers.putAll(listMockMetadata);
            } else {
                sObjectNameToEventsToTriggerHandlers.putAll(
                [SELECT DeveloperName, NamespacePrefix, Event__c, sObject__c, Class_Name__c, Order__c
                FROM Trigger_Handler__mdt
                WHERE sObject__c = :strObjectName AND Active__c = true
                ORDER BY Order__c ASC]);
            }
            theseEventsToTriggerHandlers = sObjectNameToEventsToTriggerHandlers.get(objectType.getDescribe().getName());
        }
    }

    public static String triggerFlagsToString(boolean bIsBefore, boolean bIsUpdate, boolean bIsInsert, boolean bIsDelete, boolean bIsUndelete) {
        String strReturnVal = bIsBefore ? 'Before' : 'After';

        if(bIsInsert) {
            strReturnVal += 'Insert';
        } else if(bIsUpdate) {
            strReturnVal += 'Update';
        } else if(bIsDelete) {
            strReturnVal += 'Delete';
        } else {
            strReturnVal += 'Undelete';
        }

        return strReturnVal;
    }

    public void handle() {
        if(validateRun()){
            handle(Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert, Trigger.isDelete, Trigger.isUndelete, Trigger.old, Trigger.new, Trigger.oldMap);
        }
    }

    public void handle(boolean bIsBefore, boolean bIsUpdate, boolean bIsInsert, boolean bIsDelete, boolean bIsUndelete, List<sObject> listOld, List<sObject> listNew, Map<Id, sObject> mapOld) {
        if(theseEventsToTriggerHandlers == null) {
            return;
        }
        String strEvent = triggerFlagsToString(bIsBefore, bIsUpdate, bIsInsert, bIsDelete, bIsUndelete);
        List<Trigger_Handler__mdt> listTheseTriggerHandlers = theseEventsToTriggerHandlers.getTriggerHandlers(strEvent);

        if(listTheseTriggerHandlers == null) {
            return;
        }

        for(Trigger_Handler__mdt thisTriggerHandler : listTheseTriggerHandlers) {
            Type handlerType = Type.forName(thisTriggerHandler.NamespacePrefix, thisTriggerHandler.Class_Name__c);
            if(handlerType == null) {
                throw new ClassNotFoundException('MetaDataTriggerManager: handler class not found for ' + thisTriggerHandler);
            } else {
                if(bIsBefore) {
                    if(bIsUpdate) {
                        ((BeforeUpdate)handlerType.newInstance()).handleBeforeUpdate(listNew, mapOld);
                    } else if(bIsInsert) {
                        ((BeforeInsert)handlerType.newInstance()).handleBeforeInsert(listNew);
                    } else if(bIsDelete) {
                        ((BeforeDelete)handlerType.newInstance()).handleBeforeDelete(listOld);
                    } else if(bIsUndelete) {
                        ((BeforeUndelete)handlerType.newInstance()).handleBeforeUndelete(listNew);
                    }
                } else {
                    if(bIsUpdate) {
                        ((AfterUpdate)handlerType.newInstance()).handleAfterUpdate(listNew, mapOld);
                    } else if(bIsInsert) {
                        ((AfterInsert)handlerType.newInstance()).handleAfterInsert(listNew);
                    } else if(bIsDelete) {
                        ((AfterDelete)handlerType.newInstance()).handleAfterDelete(listOld);
                    } else if(bIsUndelete) {
                        ((AfterUndelete)handlerType.newInstance()).handleAfterUndelete(listNew);
                    }
                }
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
            //if(!Test.isRunningTest() && triggerExeControl.RecursiveCount__c > 0) {
            
            if(triggerExeControl.RecursiveCount__c > 0) {
                ExecutionCounter execCounter = mapRecursiveDirectory.get(strCurrentObjectName);
                
                //added by Gan CR18197
                if(strCurrentObjectName.equalsIgnoreCase('Opportunity') && execCounter != null && checkRecursive.getCounter() == 0 ) {
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
    public class NotATriggerContextException extends Exception {}
    public class MaximumTriggerRecursionExceededException extends Exception {}
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
            System.debug('G1 -> MT iCurrent: ' + iCurrent + ', current limit:' + Limits.getQueries());
            iCurrent = 1;
        }
        public void incrementCounter() {
            iCurrent++;
        }
    }
    
}
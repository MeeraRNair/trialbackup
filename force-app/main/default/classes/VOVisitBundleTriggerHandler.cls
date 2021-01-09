public with sharing class VOVisitBundleTriggerHandler{
    //Once Account or Oppourtunity record will updated then we will set "isUpdatedVisitBundle" flag value as true
    //If "isUpdatedVisitBundle" flag value as True then "VOVisitBundleTrigger.trigger" will executed.
    
    public static Boolean bIsUpdatedVisitBundle = false;

}
/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      
 * 2.0      17933       FY20-1002       28-Aug-2019     Fenny           Refactoring trigger framework. Below method calls copied from OpptyTeamTriggerHandler
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */
public with sharing class DealRegOpptyTeamTriggerHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){
    if(!TriggerExecutionController.skipOpportunityTeamTriggers()) {
       OpptyTeamMemberAddedtoDeal.insertOpptyTeamMember(listNew);
    }
    }
}
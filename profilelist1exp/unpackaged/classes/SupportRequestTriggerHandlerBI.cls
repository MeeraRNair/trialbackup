/*
 * Revision CR Number   Release No      Date            Created By        Description
 * -------- ---------   ----------     -----------     ------------        -----------
 * 1.0       7216521    FY20-0102      18-Nov-2019      Sarbjeet Heera     Created SupportRequestTriggerHandlerBI Class Before Insert for Support Request Object
       
*/
public class SupportRequestTriggerHandlerBI implements BeforeInsert {
   
    
    public void handleBeforeInsert(List<sObject> listNew){
        OEMOpptyTeamMembertoSR.populateOEMBDMEmail(listNew,SupportRequestTriggerHandler.supportRecSelector.mapOppTeamMembers);
    
    }
}
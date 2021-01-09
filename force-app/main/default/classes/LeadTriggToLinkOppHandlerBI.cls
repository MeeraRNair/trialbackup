/*
 * Author   : Sonali
 * Purpose  : Gives abstract view Of the business logics / functionalities implemented On Lead To link opportunities With Leads.
*
* Refererences
*=======================================================================
* Version   Dev            Release          Date            CR              Description
*--------   ---------      ------------     -----------     -----------     -------------
* 1.0       Sonali         FY20-0102        15 Nov 2019     18290           Story 3291881: Channel: Embed Deal ID into Channel Lead upon creation
* 2.0       Shue           FY20-0102        15 Nov 2019     18290           Story 3291881: Fix 102 build error
*
*
*/

Public Class LeadTriggToLinkOppHandlerBI Implements BeforeInsert{
    
    Public void handleBeforeInsert(List<sObject> listNew){
        System.debug('Entered Lead handleBeforeInsert');
        
        // VALIDATION BLOCK: ALL YOUR VALIDATION RELATED LOGICS SHOULD BE HERE
        {
            System.debug('Entered Lead handleBeforeInsert '+LeadTriggerHandler.leadRecSelector);
            //v12.0
            If (!LeadTriggerHandler.leadRecSelector.listChannelLeadtoDeal.isEmpty()){
            System.debug('Before Insert Calling LeadValidator ***********');
            LeadValidator.validatePartnertInChannelLead(LeadTriggerHandler.leadRecSelector.listChannelLeadtoDeal, LeadTriggerHandler.leadRecSelector.setChannelDealIds);
            }
        }
        
        // FIELD POPULATION BLOCK: ALL YOUR FIELD POPULATION RELATED LOGICS SHOULD BE HERE
        {
            //v12.0
            If (!LeadTriggerHandler.leadRecSelector.listChannelLeadtoDeal.isEmpty()){
            System.debug('Before Insert Calling LeadFieldPopulator ***********');
            //System.debug('list of Leads ***********'+LeadTriggerHandler.leadRecSelector.listChannelLeadtoDeal);
            //System.debug('Set of Leads ***********'+LeadTriggerHandler.leadRecSelector.setChannelDealIds);
            LeadFieldPopulator.populateRelatedOpportunity(LeadTriggerHandler.leadRecSelector.listChannelLeadtoDeal, LeadTriggerHandler.leadRecSelector.setChannelDealIds);
            //v12.0
            
            }  
        }
    }
}
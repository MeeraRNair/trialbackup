/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 2.0      CR10496     15.10       08-Oct-2014     Ragu            Optimized this class as part of trigger redesign.
 * 
 * 
 */
 
public class OpportunitylineitemUpdateController {

    list<OpportunityLineItem> lstOLIsToUpdate = new list<OpportunityLineItem>();
    map<String, list<String>> mapOpportunityProduct = new map<String, list<String>>();

    public void updateOLI(list<Id> lstOppIds) {
        if(lstOppIds != null && !lstOppIds.isEmpty()) {
            for(OpportunityLineItem oliIterator : [select Id, OpportunityId, Dell_Business_Model__c, Opportunity.Submitter_Profile__c, Pricebookentry.Product2.Dell_Business_Model__c 
                                                   from OpportunityLineItem where OpportunityId in :lstOppIds and Dell_Business_Model__c = null and Opportunity.Submitter_Profile__c != null and Pricebookentry.Product2.Dell_Business_Model__c != null]) {
                if(oliIterator.Opportunity.Submitter_Profile__c.contains('PRM')) {
                    String businessModel = oliIterator.Pricebookentry.Product2.Dell_Business_Model__c;
                    if(businessModel.contains('Smart Selection (Stocked)')) {
                        oliIterator.Dell_Business_Model__c = 'Smart Selection (Stocked)';
                        lstOLIsToUpdate.add(oliIterator);
                    }
                    else if(businessModel.contains('Smart Selection (Non Stocked)')) {
                        oliIterator.Dell_Business_Model__c = 'Smart Selection (Non Stocked)';
                        lstOLIsToUpdate.add(oliIterator);
                    }
                    else if(businessModel.contains('Custom BTO')) {
                        oliIterator.Dell_Business_Model__c = 'Custom BTO';
                        lstOLIsToUpdate.add(oliIterator);
                    }
                }
            }
            try {
                //GlobalVariables.SKIP_OPP_LINEITEM_TRIGGERS = True;
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
                Database.update(lstOLIsToUpdate, false);
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
                //GlobalVariables.SKIP_OPP_LINEITEM_TRIGGERS = False;
            }
            catch(DMLException e) {
                System.debug('Caught DMLException in updateOLI(): ' + e.getDMLMessage(0));
            }
        }
    }
    
}
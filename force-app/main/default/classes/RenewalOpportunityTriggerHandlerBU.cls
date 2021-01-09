/*****************************************************************************
*CreatedBy : Ankur Saxena
* 
* Story: 7350413
* 
* Purpose: To accomodate the changes which needs to be done in before update of Renewal Opportunity
*
*Date : 23rdSeptember2019
* Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 2.0      CR18285    FY20-DCS-0102 08-Nov-2019     Shubham Bhatt     Creating New method setEMCOpportunityUpdated  
*******************************************************************************/
Public Class RenewalOpportunityTriggerHandlerBU Implements BeforeUpdate{
    Public void handlebeforeUpdate(List<sObject> listNew , Map<Id, sObject> mapOld){
        
        
        system.debug('===Ankur==='+UserInfo.getfirstName());
        system.debug(UserInfo.getLastName());
        list<opportunity> listOpty = New list<opportunity> ();
        listOpty = RenewalOpportunity_Utils.checkIfRenewalsOppty(listNew);
        If (!listOpty.isEmpty() && UserInfo.getfirstName() =='Renewals Core' && UserInfo.getLastName()== 'Integration User'){
            Map < id, Opportunity > mapIdOpp = (map < Id, Opportunity >)mapOld;
            // MapIdOpp = (map<Id, Opportunity>)Trigger.oldMap;
            //RenewalOpportunityTriggerHandler.validateEmcOppNumberRenewalbeforeUpdate(listOpty,(map<Id, Opportunity>)listOpty);  
            For (opportunity opp : listOpty)
            {
               If (opp.EMC_Opportunity_Amount__c!= null && (opp.EMC_Opportunity_Amount__c!= mapIdOpp.get(opp.id).EMC_Opportunity_Amount__c ||opp.EMC_Opportunity_Amount__c!= opp.Amount) && opp.Number_of_Line_Items__c == 0  )
                {
                    opp.Amount = opp.EMC_Opportunity_Amount__c ;
                }
            }  
        } 
        
        
        /*********START*********Added by Shubham Bhatt(Rubicon) STORY - 7643105*****************************************/
        If ((UserInfo.getfirstName() != 'Renewals EBIA' && UserInfo.getLastName() != 'Integration User') && (UserInfo.getfirstName() != 'Renewals Core' && UserInfo.getLastName() != 'Integration User')){
            If(!listOpty.isEmpty()){
                Map<id,Opportunity> mapIdOpp = (map<Id, Opportunity>)mapOld;
                RenewalOpportunityTriggerHandler.setEMCOpportunityUpdated(listOpty, mapIdOpp);    
            } 
        }
        /*********STOP*********Added by Shubham Bhatt(Rubicon) STORY - 7643105*****************************************/
        
    }
}
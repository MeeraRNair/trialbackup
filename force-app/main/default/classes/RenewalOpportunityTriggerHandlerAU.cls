/*****************************************************************************
*CreatedBy : Ankur Saxena
* 
* Story: 7350413
* 
* Purpose: To accomodate the changes which needs to be done in After update of Renewal Opportunity
*
*Date : 23rdSeptember2019 
*******************************************************************************/
public class RenewalOpportunityTriggerHandlerAU implements AfterUpdate{
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
    
        system.debug('ankur debug===='+UserInfo.getfirstName());
    system.debug(UserInfo.getLastName());
    
   if(UserInfo.getfirstName() =='Renewals Core' && UserInfo.getLastName()== 'Integration User')
   {   
         If (listNew!= null){ 
         list<opportunity> listOpty = New list<opportunity> ();
                listOpty = RenewalOpportunity_Utils.checkIfRenewalsOppty(listNew);
                If (!listOpty.isEmpty()){
                Map<id,Opportunity> mapIdOpp = (map<Id, Opportunity>)mapOld;
                RenewalOpportunityTriggerHandler.validateEmcOppAmountUpdateRenewal(listOpty, mapIdOpp);
                }
        
       } 
      
     }
     }
     
     }
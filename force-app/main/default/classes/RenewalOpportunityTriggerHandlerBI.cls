/*****************************************************************************
*CreatedBy : Shubham Bhatt
* 
* Story: 6295277
* 
* Purpose: To accomodate the changes which needs to be done in before insertion of Renewal Opportunity
Story 7350413: RE129-Dummy Line Item- Re-process - Ankur 
*
*Date : 13thAug2019

* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      CR17954    FY20-DCS-1002 05-Sep-2019     Shubham Bhatt     Creating New method setOpportunityOwner  
* 2.0      CR18285    FY20-DCS-0102 08-Nov-2019     Shubham Bhatt     Creating New method setEMCOpportunityUpdated  
*******************************************************************************/
Public Class RenewalOpportunityTriggerHandlerBI Implements BeforeInsert{
    
    Public void handleBeforeInsert(List<sObject> listNew){
        /*********START*********Added by Shubham Bhatt****************/
        /*********START*********Added by Shubham Bhatt(Rubicon) STORY - 6295277*****************************************/
        If (listNew != null){ 
            list<opportunity> listOpty = New list<opportunity> ();
            listOpty = RenewalOpportunity_Utils.checkIfRenewalsOppty(listNew);
            
            If (UserInfo.getfirstName() == 'Renewals EBIA' && UserInfo.getLastName() == 'Integration User'){
                If(!listOpty.isEmpty()){
                    RenewalOpportunityTriggerHandler.setOpportunityOwner(listOpty);    
                } 
            }
            /*********STOP*********Added by Shubham Bhatt(Rubicon) STORY - 6295277*****************************************/
            
            /*********START*********Added by Shubham Bhatt(Rubicon) STORY - 7643105*****************************************/
            If ((UserInfo.getfirstName() != 'Renewals EBIA' && UserInfo.getLastName() != 'Integration User') && (UserInfo.getfirstName() != 'Renewals Core' && UserInfo.getLastName() != 'Integration User')){
                If(!listOpty.isEmpty()){
                    RenewalOpportunityTriggerHandler.setEMCOpportunityUpdated(listOpty, null);    
                } 
            }
            /*********STOP*********Added by Shubham Bhatt(Rubicon) STORY - 7643105*****************************************/
            /*********STOP*********Added by Shubham Bhatt****************/
            
            /****************************************Added by Ankur(Story 7350413)*********************************************************************/
            If (UserInfo.getfirstName() == 'Renewals Core' && UserInfo.getLastName() == 'Integration User'){
                If(!listOpty.isEmpty()){
                    system.debug('main class methold called ===Ankur');
                    
                    RenewalOpportunityTriggerHandler.validateEmcOppAmountRenewalbeforeInsert(listOpty);
                    
                } 
            }
            
        }  
    }
    
    
}
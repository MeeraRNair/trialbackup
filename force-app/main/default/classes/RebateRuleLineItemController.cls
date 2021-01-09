/*Class Name --> RebateRuleLineItemController
Created By --> Rahul Mishra
Purpose   ---> Controller class for ResetRebateRuleLineItem VF pafe
Description -> Class is used as controller class for VF page which is used to
               Reset Rebate Rule Line Item on record*/

public class RebateRuleLineItemController {
    
    public String recordId {get;set;}    
    public  RebateRuleLineItemController() {
        recordId = '';
        recordId = apexpages.currentpage().getparameters().get('id');
    }
}
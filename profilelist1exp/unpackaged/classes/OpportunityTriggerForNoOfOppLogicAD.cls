/*
**********************************************************
* Name          : OpportunityTriggerHandlerForNoOfOppLogicAD 
* Description   : count of opportunities by current and next fisical year associated to account obj
* ---------------------------------------------------------
* Revision      Name         Date           Release     Description
* 1.0           Naga   30-Sep-2019    FY20 1101   Calculate the no. of opportunities by current and next fiscal years
************************************************************/
public class OpportunityTriggerForNoOfOppLogicAD implements AfterDelete {
    public void handleAfterDelete(List<sObject> listOld){        
        CountOfOpportunitiesLogic.noOfOpp(Trigger.old);
        
    }
}
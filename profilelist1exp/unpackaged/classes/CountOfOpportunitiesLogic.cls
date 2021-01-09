/*
**********************************************************
* Name          : CountOfOpportunitiesLogic 
* Description   : count of opportunities by current and next fisical year associated to account obj
* ---------------------------------------------------------
* Revision      Name         Date           Release     Description
* 1.0           Naga   30-Sep-2019    FY20 1101   Calculate the no. of opportunities by current and next fiscal years
************************************************************/

public class CountOfOpportunitiesLogic{

    public static void noOfOpp(List<Opportunity > listOpp){
        Set<id> setAccId = new Set<id>();   
        if(listOpp != null){
            for (Opportunity opp: listOpp){
                setAccId.add(opp.AccountId);   
            }    
        }   
        Integer intVal = 0;
        Map<ID, Account> mapAcc= new map<ID, Account>([select id, No_of_Opportunities__c from Account where id IN :setAccId]);
        if(!mapAcc.IsEmpty()){
            for(Id id : setAccId){
                mapAcc.get(id).No_of_Opportunities__c = String.valueOf(intVal);
            }
            for(opportunity opp : [SELECT Id,closedate,AccountId, Account.No_of_Opportunities__c FROM Opportunity WHERE AccountId IN :setAccId and (CloseDate = THIS_FISCAL_YEAR or CloseDate = NEXT_FISCAL_YEAR)]){
                intVal++;
                mapAcc.get(opp.AccountId).No_of_Opportunities__c = String.valueOf(intVal);         
            }
            List<String> listObjAPINames = new List<String>{'Opportunity'};
            try{  
              SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
                TriggerExecutionController.setSkipAccountTriggers(true);
                Database.SaveResult[] results = Database.Update(mapAcc.values(), false);
                TriggerExecutionController.setSkipAccountTriggers(false);
                ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
            }
            catch(Exception ex) {
              System.Debug('Error :' + ex.getMessage());
            }
        }
    }
}
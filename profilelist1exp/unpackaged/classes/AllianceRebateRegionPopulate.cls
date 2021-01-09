Public without sharing class AllianceRebateRegionPopulate{

public static string getCountryRegionByOpportunityEndUserAccount(Id idopportunityId) {
        Country__c cn;
       List<Opportunity> listOpp=[Select id,AccountId,Account.Name,Account.Account_Country__c,Deal_Reg_Oppty__c,PartnerAccountId,PartnerAccount.Name,PartnerAccount.Account_Country__c,PartnerAccount.Account_Country_Code__c from Opportunity where id = : idopportunityId];
       system.debug('$$$$$$$'+listOpp);
        If(listOpp.size() > 0){
        Opportunity opp=listOpp.get(0);
        if(opp !=null && opp.PartnerAccountId !=null && opp.PartnerAccount.Account_Country__c !=null && opp.Deal_Reg_Oppty__c=='Yes'){
         cn=[Select Region__c, Code__c from Country__c where Name =: opp.PartnerAccount.Account_Country__c]; 
         return cn.Region__c; 
         } else If(opp !=null && opp.AccountId !=null && opp.Account.Account_Country__c !=null && opp.Deal_Reg_Oppty__c=='No'){
            cn=[Select Region__c, Code__c from Country__c where Name =: opp.Account.Account_Country__c];
            return cn.Region__c;
           
        }
            
        }
        return null;
    }

}
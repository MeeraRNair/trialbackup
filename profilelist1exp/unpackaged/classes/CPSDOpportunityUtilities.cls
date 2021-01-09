/* 
* Author   : Ranjith Mergu
* Purpose  : CPSDOpportunityUtilities class to hold CPSD Integration Business logics.
*/ 
public class CPSDOpportunityUtilities {
    
    public static void updateCPSDIntegrationStatusToWaitingSync(List<Opportunity> listOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        Id standardOppRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');
        List<Id> listAccountIds = new List<Id>();
        List<Account> listAccountsUpdate = new List<Account>();
        
        for (Opportunity opp: listOpportunities) {
            if (!String.isBlank(opp.Bill_To_Ship_To_Comments__c) && opp.RecordTypeId ==standardOppRTId) { 
                if ((opp.Name != null & opp.Name != mapOldOpportunities.get(opp.Id).Name) ||
                    (opp.StageName != null & opp.StageName != mapOldOpportunities.get(opp.Id).StageName) ||
                    (opp.AccountId != null & opp.AccountId != mapOldOpportunities.get(opp.Id).AccountId) ||
                    (opp.ForecastCategoryName != null & opp.ForecastCategoryName != mapOldOpportunities.get(opp.Id).ForecastCategoryName) ||
                    (opp.CloseDate != null & opp.CloseDate != mapOldOpportunities.get(opp.Id).CloseDate) ||
                    (opp.Deal_ID__c != null & opp.Deal_ID__c != mapOldOpportunities.get(opp.Id).Deal_ID__c) ||
                    (opp.EMC_Opportunity_Number__c != null & opp.EMC_Opportunity_Number__c != mapOldOpportunities.get(opp.Id).EMC_Opportunity_Number__c) ||
                    (opp.Affinity_ID__c != null & opp.Affinity_ID__c != mapOldOpportunities.get(opp.Id).Affinity_ID__c) ||
                    (opp.EMC_ID_Opp__c != null & opp.EMC_ID_Opp__c != mapOldOpportunities.get(opp.Id).EMC_ID_Opp__c) ||
                    (opp.Indirect_Partner_Account__c != null & opp.Indirect_Partner_Account__c != mapOldOpportunities.get(opp.Id).Indirect_Partner_Account__c) ||
                    (opp.Distributor_Direct_Reseller_Account__c != null & 
                     opp.Distributor_Direct_Reseller_Account__c != mapOldOpportunities.get(opp.Id).Distributor_Direct_Reseller_Account__c)) {
                         opp.CPSD_Integration_Status__c ='Waiting Sync';
                     }
                // newly updated AC's
                if (opp.AccountId != null & opp.AccountId != mapOldOpportunities.get(opp.Id).AccountId) {
                    listAccountIds.add(opp.AccountId);
                }
            }
        }
        List<Account> listAccounts = [SELECT Id, Name, CPSD_Account_ID__c, CPSD_Integration_Status__c FROM Account
                                  WHERE Id =: listAccountIds AND CPSD_Account_ID__c = ''];
        
        if (! listAccountIds.isEmpty() && listAccounts.size() > 0) {
            for (Account acc : listAccounts) {
                acc.CPSD_Integration_Status__c = 'Waiting Sync';
                listAccountsUpdate.add(acc);
            }
            
            update listAccountsUpdate;
        }
    }
    public static void cloneOppsWithoutProducts(List<Opportunity> listOpportunities) {
        for (Opportunity newOpportunity: listOpportunities) {
            if (newOpportunity.CPSD_Integration_Status__c != null || newOpportunity.CPSD_Integration_Status__c != '') {
                newOpportunity.CPSD_Integration_Status__c = '';
            }
            if (newOpportunity.Bill_To_Ship_To_Comments__c != null || newOpportunity.Bill_To_Ship_To_Comments__c != '') {
                newOpportunity.Bill_To_Ship_To_Comments__c = '';
            }
        }
    }    
}
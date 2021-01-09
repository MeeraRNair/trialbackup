/* 
* Author   : Ranjith Mergu
* Purpose  : CPSDOpportunityLineItemUtils class to hold CPSD Integration Business logics.
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0 	TFS7189250	FY20-1101		23-Nov-2019		Ranjith Mergu	Idea Intake 08137 - Update Specialty / BU Products field on Opportunity When any Special OpportunityLineItem is insrted
*/ 
public class CPSDOpportunityLineItemUtilities {
    
    public static void updateIntegrationStatusWaitingSync(List<OpportunityLineItem> listLineItems){
        Map<Id, OpportunityLineItem> mapOppIds = new Map<Id, OpportunityLineItem>();
        List<Opportunity> listClonedOpps = new List<Opportunity>();
        Map<Id, Opportunity> mapClonedParentIds = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapClonedOppAccIds = new Map<Id, Opportunity>();
        List<Opportunity> listClonedOppsUpdate = new List<Opportunity>();
        List<Account> listAccsUpdate = new List<Account>();
        
        Id standardOppRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');
        for(OpportunityLineItem oli : listLineItems){  
            if (oli.OpportunityId != null && oli.Sales_Configurator_Identifier__c == 'ACT' && 
                (oli.CPSD_Opportunity_Product_ID__c!=Null || oli.CPSD_Integration_Status__c!=Null)) {
                    mapOppIds.put(oli.OpportunityId, oli);
                }
        }
        if (!mapOppIds.isEmpty()) {
            listClonedOpps = [SELECT Id, Name, Cloned_Parent_Id__c, AccountId, CPSD_Integration_Status__c, Bill_To_Ship_To_Comments__c
                              FROM Opportunity
                              WHERE Cloned_Parent_Id__c != null
                              AND Id IN :mapOppIds.keySet()
                              AND RecordTypeId =:standardOppRTId];
        }
        
        if (!listClonedOpps.isEmpty()) {
            // Update OLI's
            for(OpportunityLineItem opLi : listLineItems){
                if(opLi.CPSD_Opportunity_Product_ID__c != null || opLi.CPSD_Integration_Status__c != null){
                    opLi.CPSD_Opportunity_Product_ID__c='';
                    opLi.CPSD_Integration_Status__c='Waiting Sync';
                }
            }
            // update Opps
            for (Opportunity opp : listClonedOpps) {
                if ((opp.CPSD_Integration_Status__c != null || opp.CPSD_Integration_Status__c != '') && opp.Cloned_Parent_Id__c != null){
                    mapClonedParentIds.put(opp.Cloned_Parent_Id__c, opp);
                    mapClonedOppAccIds.put(opp.AccountId, opp);
                    Opportunity o = new Opportunity();
                    o.Id = opp.Id;
                    opp.CPSD_Integration_Status__c = 'Waiting Sync';
                    opp.Bill_To_Ship_To_Comments__c = '';
                    listClonedOppsUpdate.add(opp);
                    
                }
                
            }
            TriggerExecutionController.setSkipAllTriggers(true);
            if (!listClonedOppsUpdate.isEmpty()) {
                update listClonedOppsUpdate;
            }
            TriggerExecutionController.setSkipAllTriggers(false);
            // Updating Accounts
            Boolean bisAccountChanged = false;
            if (! mapClonedParentIds.isEmpty()) {
                for (Opportunity parentClonedOpp : [SELECT Id, AccountId 
                                                    FROM Opportunity
                                                    WHERE Id IN :mapClonedParentIds.keySet()]) {
                                                        if (parentClonedOpp.AccountId != null && parentClonedOpp.AccountId != mapClonedParentIds.get(parentClonedOpp.Id).AccountId) {
                                                            bisAccountChanged = true;
                                                        }
                                                    }
                List<Account> listnotMappedAccounts = [SELECT Id, CPSD_Account_ID__c, CPSD_Integration_Status__c 
                                                       FROM Account 
                                                       WHERE Id IN :mapClonedOppAccIds.keySet()
                                                       AND CPSD_Account_ID__c = null] ;
                if (bisAccountChanged && ! listnotMappedAccounts.isEmpty() && listnotMappedAccounts.size() > 0) {
                    for (Account acc : listnotMappedAccounts) {
                        Account a = new Account();
                        a.Id = acc.Id;
                        a.CPSD_Integration_Status__c ='Waiting Sync';
                        listAccsUpdate.add(a);
                    } 
                    TriggerExecutionController.setSkipAllTriggers(true);
                    update listAccsUpdate;
                    TriggerExecutionController.setSkipAllTriggers(false);
                }
            }
        }
    }
    // STORY 7189250 -- Idea Intake 08137 - Deal Identifier or Specialty / BU Products field
    public static void updateSpecialityBUProductField(List<OpportunityLineItem> listOppLine) {
        Map<Id, OpportunityLineItem> mapOpportunityIds = new Map<Id, OpportunityLineItem>();
        List<Opportunity> listOppsToUpdate = new List<Opportunity>();
        String strDPS ;
        String strMDC ;
        String strUDS ;
        for(OpportunityLineItem oli : listOppLine) {
            if(oLi.OpportunityId != null) {
                mapOpportunityIds.put(oli.OpportunityId, oli);
            }
            if(oli.FPG_DPS__c == true) {
                strDPS = 'DPS';
            }
            if(oli.FPG_MDC__c == true) {
                strMDC = 'MDC';
            }
            if(oli.FPG_UDS__c == true) {
                strUDS = 'UDS';
            }
        }
        system.debug('strDPS***>>>'+strDPS);
        system.debug('strMDC***>>>'+strMDC);
        system.debug('strUDS***>>>'+strUDS);
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([SELECT ID, Name, Specialty_BU_Products__c FROM Opportunity
                                                                WHERE ID =: mapOpportunityIds.keySet()]);
        for(Opportunity opp : mapOpp.values()) {
            if(opp.Specialty_BU_Products__c == null && strDPS != null && strMDC != null && strUDS != null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == null && strDPS != null && strMDC != null && strUDS == null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC'; 
            }
            if(opp.Specialty_BU_Products__c == null && strDPS != null && strMDC == null && strUDS != null) {
                opp.Specialty_BU_Products__c = 'DPS;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == null && strDPS == null && strMDC != null && strUDS != null) {
                opp.Specialty_BU_Products__c = 'MDC;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == null && strDPS != null && strMDC == null && strUDS == null) {
                opp.Specialty_BU_Products__c = 'DPS'; 
            }
            if(opp.Specialty_BU_Products__c == null && strDPS == null && strMDC != null && strUDS == null) {
                opp.Specialty_BU_Products__c = 'MDC'; 
            }
            if(opp.Specialty_BU_Products__c == null && strDPS == null && strMDC == null && strUDS != null) {
                opp.Specialty_BU_Products__c = 'UDS';  
            }
            
            if(opp.Specialty_BU_Products__c == 'DPS' && strMDC != null && strUDS != null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == 'DPS' && strMDC != null && strUDS == null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC'; 
            }
            if(opp.Specialty_BU_Products__c == 'DPS' && strMDC == null && strUDS != null) {
                opp.Specialty_BU_Products__c = 'DPS;UDS'; 
            }
            
            if(opp.Specialty_BU_Products__c == 'MDC' && strDPS != null && strUDS != null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == 'MDC' && strDPS != null && strUDS == null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC'; 
            }
            if(opp.Specialty_BU_Products__c == 'MDC' && strDPS == null && strUDS != null) {
                opp.Specialty_BU_Products__c = 'MDC;UDS'; 
            }
            
            if(opp.Specialty_BU_Products__c == 'UDS' && strDPS != null && strMDC != null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == 'UDS' && strDPS != null && strMDC == null) {
                opp.Specialty_BU_Products__c = 'DPS;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == 'UDS' && strDPS == null && strMDC != null) {
                opp.Specialty_BU_Products__c = 'MDC;UDS'; 
            }
            
            if(opp.Specialty_BU_Products__c == 'DPS;MDC' && strUDS != null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == 'DPS;UDS' && strMDC != null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == 'MDC;UDS' && strDPS != null) {
                opp.Specialty_BU_Products__c = 'DPS;MDC;UDS'; 
            }
            if(opp.Specialty_BU_Products__c == 'DPS;MDC;UDS') {
                opp.Specialty_BU_Products__c = opp.Specialty_BU_Products__c; 
            }
            listOppsToUpdate.add(opp);
        }
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        if (!listOppsToUpdate.isEmpty()) {
            update listOppsToUpdate;
        }
        TriggerExecutionController.setSkipOpportunityTriggers(false);
    }
}
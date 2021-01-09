/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to Accounts integrations. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR2150                  16-Dec-2009     Raymond         Synchronize to CMI when partner account is updated/created
 * 2.0      CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from accountTrigger trigger and rewritten as part of trigger redesign.
 */

public class AccountIntegrationUtilities {
    
    // v1.0, v2.0
    public static void integratePartnerAccounts(map<Id, Account> mapPartnerAccountsForIntegration) {
        Integer iRecordsProcessed = 0;
        Integer iBatchesProcessed = 0;
        GlobalVariable__c globalVariable = GlobalVariable__c.getInstance('PPIntegration_Account_Batch Size');
        final Integer BATCH_SIZE = Integer.valueOf(globalVariable == null ? '10' : globalVariable.Value__c);
        globalVariable = GlobalVariable__c.getInstance('PPIntegration_Account_Max Calls');
        final Integer MAXIMUM_PARTNER_INTEGRATION_CALL = Integer.valueOf(globalVariable == null ? '5' : globalVariable.Value__c);
        
        map<String, Account> mapAccounts = new map<String, Account>();
        for(Account accIterator : mapPartnerAccountsForIntegration.values()) {
            mapAccounts.put(accIterator.Id, accIterator);
            iRecordsProcessed++;
            
            // Ragu: Marker (Valid thru 16.03) - Changed batch size from 10 to 20
            if(mapAccounts.size() == BATCH_SIZE || iRecordsProcessed == mapPartnerAccountsForIntegration.size()) {
                System.debug('BEFORE FUTURECALL LIMIT = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
                
                // Ragu: Marker (Valid thru 16.03) - Changed MAXIMUM_PARTNER_INTEGRATION_CALL from 5 to 10
                if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls() || iBatchesProcessed >= MAXIMUM_PARTNER_INTEGRATION_CALL) {
                    for(Id tempAccId : mapAccounts.keySet()) {
                        mapAccounts.get(tempAccId).addError('Updates of Partner Account has hit Salesforce.com FutureCall Limit.');
                    }
                }
                else {
                    try {
                        PartnerProfileIntegration.integratePartnerData(Utility.getList(mapAccounts.keySet()));
                        iBatchesProcessed++;
                    }
                    catch(Exception e) {
                        String errorMessage = 'Partner Profile synchronization failed with error: ' + e.getMessage() + '. Account List - ' + mapAccounts;
                        emailUtils.sendSupportEmail(errorMessage, DellConfig.errorEmail);
                    }
                }
                mapAccounts.clear();
                
                System.debug('AFTER FUTURECALL LIMIT = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
            }
        }
    }

}
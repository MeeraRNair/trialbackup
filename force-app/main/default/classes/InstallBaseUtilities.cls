/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      13796       FY17-DCS-0103   09-Dec-2016     Fenny           Update Install Base roll up summary in Account by invoke a flow
*/

public class InstallBaseUtilities{
    public static boolean isTest = false;
    
    // 1.0: Call this method to invoke the flow that update Install Base Rollup Summary in Account. 
    // 1.0: To add new roll up summary field(s), no changes would be here, instead, changes might be done to the flow Install_Base_Roll_Up_To_Account_Flow
    public static void updateRollUpSummaryInAccount(Map<Id, SObject> mapOldInstallBase, Map<Id, SObject> mapNewInstallBase){
        // 1.0:
        if((mapOldInstallBase != null) && (mapOldInstallBase.size() > 0)){
            Map<string, object> mapAccountId = null;
            Flow.Interview.Install_Base_Roll_Up_To_Account_Flow flowRUSOAccount = null;
            
            if (!Test.isrunningTest() || isTest){
                TriggerExecutionController.setSkipAccountTriggers(true);
            }

            for(SObject sObj : mapOldInstallBase.values()){
                Install_Base__c iB = (Install_Base__c)sObj;
                
                mapAccountId = new Map<string, object>();
                mapAccountId.put('strAccountId', iB.Account__c);
                
                flowRUSOAccount = new Flow.Interview.Install_Base_Roll_Up_To_Account_Flow(mapAccountId);
                flowRUSOAccount.start();
            }

            if (!Test.isrunningTest() || isTest){
                TriggerExecutionController.setSkipAccountTriggers(false);
            }
        }
    }
}
/*
 * Author   : Men Mee
 * Purpose  : Utility class to hold simple and reusable functionalities for auto populating Contract fields. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      11722       16.07       23-Jun-2015     Men Mee         Created for implementing "Centralized by Org" trigger architecture - Best practices
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */
  
public class ContractFieldPopulator {
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0
    2.0         11722       16.07       23-Jun-2015     Men Mee         This logic is separated from CSMBbeforeInsertUpdateContract trigger and rewritten as part of trigger redesign.
    */  
    public static void populateFieldsOnBeforeInsertUpdate(List<Contract> lstContracts) {
        Id dummyId;
        map<String, String> approverFields = CSMBUtilClass.mapOfApproverFields;
		
        for(Contract newContract:lstContracts) {       
            dummyId = CSMBUtilClass.getDummyId(newContract);
            for(String fieldAPIName : approverFields.keySet()) {
                if(newContract.get(fieldAPIName) == null) {
                    newContract.put(approverFields.get(fieldAPIName), dummyId);
                }
                else {
                    newContract.put(approverFields.get(fieldAPIName), newContract.get(fieldAPIName));
                }
           	}
        }
    }

    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0
    2.0         11722       16.07       07-Jul-2015     Men Mee         This logic is separated from CSMBafterInsertUpdateContract trigger and rewritten as part of trigger redesign.
    */
    public static void updateSupportRequestStatus(set<Id> setSupportReqIds) {
    	// Taking all the Contracts with Support Requests
    	map<Id, list<Contract>> mapSRIdContractsList = new map<Id, list<Contract>>();
    	for(Contract contractIterator : [select Id, Status, CSMB_Support_Request__c, CreatedDate from Contract where CSMB_Support_Request__c in :setSupportReqIds order by CSMB_Support_Request__c, CreatedDate desc]) {
    		if(mapSRIdContractsList.containsKey(contractIterator.CSMB_Support_Request__c)) {
    			mapSRIdContractsList.get(contractIterator.CSMB_Support_Request__c).add(contractIterator);
    		}
    		else {
    			mapSRIdContractsList.put(contractIterator.CSMB_Support_Request__c, new list<Contract>{contractIterator});
    		}
    	}
		
		// Update Support Request based on the latest Contract and its Status
        list<Support_Request__c> lstSRsToUpdate = new list<Support_Request__c>();
        for(Id srId : mapSRIdContractsList.keySet()) {
        	Contract latestContract = mapSRIdContractsList.get(srId)[0];
        	if(latestContract.Status == 'Approved' || latestContract.Status == 'Rejected' || latestContract.Status == 'Completed' || latestContract.Status == 'Cancelled' || latestContract.Status == 'Finalized') {
        		lstSRsToUpdate.add(new Support_Request__c(Id = srId, Support_Status__c = latestContract.Status));
        	}
        }
        update lstSRsToUpdate; 
    }
    
}
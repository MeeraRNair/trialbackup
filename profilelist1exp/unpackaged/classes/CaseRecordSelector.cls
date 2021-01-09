/*
 * Author   : Ragu
 * Purpose  : Centralize the record selection process for Case.
 *          Defines the methods which iterate and segregate the Case records for further use.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 10751    16.03       01-Jan-2015     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0		CR 12450    16.12       10-Dec-2015     Ragu            LM2_16_1- Sharing new cases with requestor before changing case owner
 * 3.0		18304		FY20-0102	27-Nov-2019		Fenny			To make CaseRecordSelector accessible by all features
 */

public class CaseRecordSelector extends RecordSelector {

	private TriggerHandler casTriggerHandler;
	public set<Id> setAccountIds = new set<Id>();
	public map<Id, Account> mapRelatedAccounts;

    public List<Case> listDellMainNewCase = new List<Case>(); // 3.0
    public Map<Id, sObject> mapDellMainOldCase = new Map<Id, sObject>(); // 3.0
    public Map<Id, sObject> mapDellMainNewCase = new Map<Id, sObject>(); // 3.0
    public static String strCaseRTMigratestrRTIds; // 3.0
	
	// v2.0 - Variable to to hold Global Lead Management Intake cases
	public list<Case> lstGLMICases = new list<Case>();

	public CaseRecordSelector(list<sObject> lstCases, map<Id, sObject> mapOldCases, TriggerHandler casTriggerHandler) {
        // v3.0 - Because moving this class to Base-Code, but CaseManagement and CaseUtililites not exists in Base package.
        //        So, moving the changes from CaseManagement and CaseUtilities into here.
        //        This is to exclude case with managed case record type
        if(String.isBlank(strCaseRTMigratestrRTIds)){
            List<RecordType> listCaseRTMigratelstRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND NamespacePrefix =: Label.CaseRTMigrate_Namespace];
            List<Id> listCaseRTMigratelstRTIds = new List<Id>();
            for(RecordType caseRTMigrateobjRecordType : listCaseRTMigratelstRecordType) {
                listCaseRTMigratelstRTIds.add(caseRTMigrateobjRecordType.Id);
            }
            strCaseRTMigratestrRTIds = string.join(listCaseRTMigratelstRTIds,';'); 
        }

        listDellMainNewCase = caseRTMigrateCheckRTList(lstCases, strCaseRTMigratestrRTIds);
        mapDellMainOldCase = caseRTMigrateCheckRTMap(mapOldCases, strCaseRTMigratestrRTIds);
        mapDellMainNewCase = caseRTMigrateCheckRTMap(Trigger.newMap, strCaseRTMigratestrRTIds);

        this.casTriggerHandler = casTriggerHandler;
        
        this.getRecords(listDellMainNewCase, mapDellMainOldCase);
        
        if(listDellMainNewCase != null) {
            this.getRelatedRecords(listDellMainNewCase);
        }
        else if(mapDellMainOldCase != null) {
            this.getRelatedRecords(mapDellMainOldCase.values());
        }
        
        removeNulls();
    }

    // 3.0: Moved this method from CaseUtilities
    private List<Case> caseRTMigrateCheckRTList(List<Case> listNewCases, String strCaseRTMigrateRTIds){
        
        List<Case> listCases = new List<Case>();
        
        for(Case newCase : listNewCases) {
            if(!strCaseRTMigrateRTIds.contains(newCase.RecordTypeId)) {
                listCases.add(newCase);
            }
        }
        return listCases;
    }

    // 3.0: Moved this method from CaseUtilities
    private Map<Id, sObject> caseRTMigrateCheckRTMap(Map<Id, sObject> mapNewCases, String strCaseRTMigrateRTIds){
        
        Map<Id, Case> mapTemp = new Map<Id, Case>();
        
        if(mapNewCases != null){
            mapTemp = (Map<Id, Case>) mapNewCases;
        }
        
        Map<Id, Case> mapCases = new Map <Id, Case>();
        
        List<Case> listCases = new List<Case>();
        
            for(Id newCase : mapTemp.keySet()) {
                if(!strCaseRTMigrateRTIds.contains(mapTemp.get(newCase).RecordTypeId)) {
                    mapCases.put(newCase, mapTemp.get(newCase));
                }
            } 
        return mapCases;
        
    }

	protected override void getRecords(list<sObject> lstCases, map<Id, sObject> mapOldCases) {
		Id GLMIRTId = StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake');
		if(lstCases != null) {			
            for(Case newCase : (list<Case>)lstCases) {
            	Case oldCase;
                if(mapOldCases != null && !mapOldCases.isEmpty()) {
                    oldCase = (Case)mapOldCases.get(newCase.Id);
                }
                
                setAccountIds.add(newCase.AccountId);
                
                // v2.0 - Start
        		if(newCase.RecordTypeId == GLMIRTId) {
        			lstGLMICases.add(newCase);
        		}
                // v2.0 - End
            }
        }
        else if(mapOldCases != null) { // Handling delete events
            for(Case conIterator : (list<Case>)mapOldCases.values()) {
				setAccountIds.add(conIterator.AccountId);
            }
        }
	}
	
    protected override void getRelatedRecords(list<sObject> lstCases) {
        if(!setAccountIds.isEmpty()) {
            mapRelatedAccounts = new map<Id, Account>([select Id, Name, Type, OwnerId, RecordTypeId, RecordType.Name, Account_ID__c, NPS_Account_Tier__c, Account_Country__c
                                                       from Account where Id in :setAccountIds]);
        }
    }
    
    // Remove nulls from the Set / List / Map.
    private void removeNulls() {
		setAccountIds.remove(null);
    }

}
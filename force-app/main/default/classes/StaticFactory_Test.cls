/*
 * Author   : Ragu
 * Purpose  : Test StaticFactory class
 * 
 * Revision	CR Number	Release No	Date			Modified By  	Description
 * --------	---------	----------	-----------		------------	-----------
 * 1.0      CR10496		15.10		08-Oct-2014		Ragu			Created
 * 
 */
@isTest
private class StaticFactory_Test {

	static testMethod void testUserDetails() {
		StaticFactory.getCurrentUserDetails();
		StaticFactory.getUserDetails(UserInfo.getUserId());
	}
	
	static testMethod void testOrgDetails() {
		StaticFactory.getEnvironment();
	}
	
	static testMethod void testRecordTypeMethods() {
		list<RecordType> lstRecTypes = [select Id, Name, SobjectType from RecordType where IsActive = true limit 1];
		if(lstRecTypes != null) {
			RecordType recType = lstRecTypes[0];
			StaticFactory.getRecordTypes(recType.SobjectType);
			StaticFactory.getRecordTypeIdNameMapByNames(recType.SobjectType, new set<String> {recType.Name});
			StaticFactory.getRecordTypeNameIdMapByNames(recType.SobjectType, new set<String> {recType.Name});
			StaticFactory.getRecordTypeIdNameMapByIds(recType.SobjectType, new set<Id> {recType.Id});
			StaticFactory.getRecordTypeNameIdMapByIds(recType.SobjectType, new set<Id> {recType.Id});
			StaticFactory.getRecordTypeIds(recType.SobjectType);
			StaticFactory.getRecordTypeNames(recType.SobjectType);
			StaticFactory.getRecordTypeIdByName(recType.SobjectType, recType.Name);
			StaticFactory.getRecordTypeIdByDevName(recType.SobjectType, recType.Name);
			StaticFactory.getRecordTypeNameById(recType.SobjectType, recType.Id);
			StaticFactory.getRecordTypeIdsByNames(recType.SobjectType, new set<String> {recType.Name});
			StaticFactory.getRecordTypeIdsByDevNames(recType.SobjectType, new set<String> {recType.Name});
			StaticFactory.getRecordTypeNamesByIds(recType.SobjectType, new set<Id> {recType.Id});
		}
	}
	
	static testMethod void testRecordTypeMethodsDESC() {
		list<RecordType> lstRecTypes = [select Id, Name, SobjectType from RecordType where IsActive = true limit 1];
		if(lstRecTypes != null) {
			RecordType recType = lstRecTypes[0];
			StaticFactory.getRecordTypesDESC(recType.SobjectType);
			StaticFactory.getRecordTypeIdNameMapByNamesDESC(recType.SobjectType, new set<String> {recType.Name});
			StaticFactory.getRecordTypeNameIdMapByNamesDESC(recType.SobjectType, new set<String> {recType.Name});
			StaticFactory.getRecordTypeIdNameMapByIdsDESC(recType.SobjectType, new set<Id> {recType.Id});
			StaticFactory.getRecordTypeNameIdMapByIdsDESC(recType.SobjectType, new set<Id> {recType.Id});
			StaticFactory.getRecordTypeIdsDESC(recType.SobjectType);
			StaticFactory.getRecordTypeNamesDESC(recType.SobjectType);
			StaticFactory.getRecordTypeIdByNameDESC(recType.SobjectType, recType.Name);
			StaticFactory.getRecordTypeNameByIdDESC(recType.SobjectType, recType.Id);
			StaticFactory.getRecordTypeIdsByNamesDESC(recType.SobjectType, new set<String> {recType.Name});
			StaticFactory.getRecordTypeNamesByIdsDESC(recType.SobjectType, new set<Id> {recType.Id});
		}
	}
	
	static testMethod void testQueueMethods() {
		map<Id, Group> mapQueuesTest = StaticFactory.getQueueMap();
		if(mapQueuesTest != null && !mapQueuesTest.isEmpty()) {
			Group queueInst = mapQueuesTest.values()[0];
			StaticFactory.getQueueIdNameMap();
			StaticFactory.getQueueNameById(queueInst.Id);
			StaticFactory.getQueueById(queueInst.Id);
			StaticFactory.getQueueIdByName(queueInst.Name);
		}
	}
	
	static testMethod void testPublicGroupMethods() {
		map<Id, Group> mapGroupTest = StaticFactory.getGroupMap();
		if(mapGroupTest != null && !mapGroupTest.isEmpty()) {
			Group grpInst = mapGroupTest.values()[0];
			StaticFactory.getGroupIdNameMap();
			StaticFactory.getGroupNameById(grpInst.Id);
			StaticFactory.getGroupById(grpInst.Id);
			StaticFactory.getGroupIdByName(grpInst.Name);
		}
	}
	
	static testMethod void testOpportunityStageMethods() {
		map<string, set<string>> mapOppStage = StaticFactory.getOpportunityStageByGrouping();
	}
	
}
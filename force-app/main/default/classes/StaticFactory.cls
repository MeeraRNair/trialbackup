/*
 * Author   : Ragu
 * Purpose  : Contains members which can be used in static context across the execution.
 *          Please do not add any members which cannot be stored in a static context and served across the execution.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10496     15.10       05-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices.
 * 1.1      CR10634     15.10       14-Nov-2014     Ragu            Added utility methods related to Opportunity Stage - not used in this release but can be used in future.
 * 2.0      TFS 156484  16.03       12-Mar-2015     Ragu            Introduced SOQL's instead of describe methods for solving translation related issues for record type label's.
 * 3.0      11555       16.07       29-May-2015     Ragu            Added back describe method - SOQL's not returning CampaignMember record types when it is created via code.
 * 4.0      CR 16577                28-Sep-2018     Vasavi.M        Added Product_Quote_Permission__c to getCurrentUserDetails method query
 */

public class StaticFactory {

    // Current User Related Details
    private static User currentUser;
    public static User getCurrentUserDetails() {
        if(currentUser == null) {
            currentUser = [select Id, Name, Email, Username, ProfileId, UserRoleId, Profile.Name, UserRole.Name,
                                ContactId, Contact.Phone, Contact.MobilePhone,Badge_Number__c,HR_Location_Country_Desc__c,Product_Quote_Permission__c 
                           from User where Id = :UserInfo.getUserId()];
        }
        return currentUser;
    }
    
    private static map<Id, User> mapUsers = new map<Id, User>();
    public static User getUserDetails(Id userId) {
        User userInstance = mapUsers.get(userId);
        if(userInstance == null) {
            userInstance = [select Id, Name, Email, Username, LastName, FirstName, ProfileId, UserRoleId, Profile.Name, UserRole.Name, 
                                ContactId, Contact.Phone, Contact.MobilePhone, Badge_Number__c
                            from User where Id = :userId];
            mapUsers.put(userInstance.Id, userInstance);
        }
        return userInstance;
    }
    
    // Current Environment (Sandbox / Production)
    private static Organization orgDetail;
    public static Organization getOrgDetail() {
        if(orgDetail == null) {
            orgDetail = [select Id, IsSandbox from Organization limit 1];
        }
        return orgDetail;
    }
    public static String getEnvironment() {
        String strEnvironment = 'Production';
        if(getOrgDetail().IsSandbox) {
            strEnvironment = 'Sandbox';
        }
        return strEnvironment;
    }
    
    // Record Types Related Utilities
    // v2.0 - Start
    private static map<string, map<Id, RecordType>> mapAllRecordTypes;
    private static map<string, map<Id, RecordType>> loadRecordTypes(string objectName) {
        if(mapAllRecordTypes == null) {
            mapAllRecordTypes = new map<string, map<Id, RecordType>>();
        }
        
        if(!mapAllRecordTypes.containsKey(objectName)) {
            map<Id, Schema.RecordType> mapRecordType = new map<Id, Schema.RecordType>();
            for(RecordType recType : [select Id, Name, DeveloperName, SobjectType from RecordType where sObjectType = :objectName]) {
                mapRecordType.put(recType.Id, recType);
            }
            mapAllRecordTypes.put(objectName, mapRecordType);
        }
        return mapAllRecordTypes;
    }
    
    public static map<Id, RecordType> getRecordTypes(string objectName) {
        return (loadRecordTypes(objectName)).get(objectName);
    }
    
    public static map<Id, string> getRecordTypeIdNameMapByNames(string objectName, set<string> setRecordTypeNames) {
        map<Id, string> mapRecordTypes = new map<Id, string>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(recType.Name)) {
                mapRecordTypes.put(recType.Id, recType.Name);
            }
        }
        return mapRecordTypes;
    }
    
    public static map<string, Id> getRecordTypeNameIdMapByNames(string objectName, set<string> setRecordTypeNames) {
        map<string, Id> mapRecordTypes = new map<string, Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(recType.Name)) {
                mapRecordTypes.put(recType.Name, recType.Id);
            }
        }
        return mapRecordTypes;
    }
    
    public static map<Id, string> getRecordTypeIdNameMapByIds(string objectName, set<Id> setRecordTypeIds) {
        map<Id, string> mapRecordTypes = new map<Id, string>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(recType.Id)) {
                mapRecordTypes.put(recType.Id, recType.Name);
            }
        }
        return mapRecordTypes;
    }
    
    public static map<string, Id> getRecordTypeNameIdMapByIds(string objectName, set<Id> setRecordTypeIds) {
        map<string, Id> mapRecordTypes = new map<string, Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(recType.Id)) {
                mapRecordTypes.put(recType.Name, recType.Id);
            }
        }
        return mapRecordTypes;
    }

    public static set<Id> getRecordTypeIds(string objectName) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            setRecordTypeIds.add(recType.Id);
        }
        return setRecordTypeIds;
    }
    
    public static set<string> getRecordTypeNames(string objectName) {
        set<string> setRecordTypeNames = new set<string>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            setRecordTypeNames.add(recType.Name);
        }
        return setRecordTypeNames;
    }
    
    public static Id getRecordTypeIdByName(string objectName, string recordTypeName) {
        Id recordTypeId;
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(recType.Name == recordTypeName) {
                recordTypeId = recType.Id;
                break;
            }
        }
        return recordTypeId;
    }
    public static Id getRecordTypeIdByDevName(string objectName, string recordTypeName) {
        Id recordTypeId;
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(recType.DeveloperName == recordTypeName) {
                recordTypeId = recType.Id;
                break;
            }
        }
        return recordTypeId;
    }
    
    public static string getRecordTypeNameById(string objectName, Id recordTypeId) {
        return ((loadRecordTypes(objectName)).get(objectName)).get(recordTypeId).Name;
    }
    
    public static set<Id> getRecordTypeIdsByNames(string objectName, set<string> setRecordTypeNames) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(recType.Name)) {
                setRecordTypeIds.add(recType.Id);
            }
        }
        return setRecordTypeIds;
    }
    public static set<Id> getRecordTypeIdsByDevNames(string objectName, set<string> setRecordTypeDevNames) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeDevNames.contains(recType.DeveloperName)) {
                setRecordTypeIds.add(recType.Id);
            }
        }
        return setRecordTypeIds;
    }
    
    public static set<string> getRecordTypeNamesByIds(string objectName, set<Id> setRecordTypeIds) {
        set<string> setRecordTypeNames = new set<string>();
        for(RecordType recType : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(recType.Id)) {
                setRecordTypeNames.add(recType.Name);
            }
        }
        return setRecordTypeNames;
    }
    
    // v3.0 - Start
    private static map<string, map<Id, RecordTypeInfo>> mapAllRecordTypesDESC;
    private static map<string, map<Id, RecordTypeInfo>> loadRecordTypesDESC(string objectName) {
        if(mapAllRecordTypesDESC == null) {
            mapAllRecordTypesDESC = new map<string, map<Id, RecordTypeInfo>>();
        }
        if(!mapAllRecordTypesDESC.containsKey(objectName)) {
            list<Schema.DescribeSObjectResult> descSObjectResults = Schema.describeSObjects(new string[] {objectName});
            map<Id, Schema.RecordTypeInfo> mapRecordType = new map<id, Schema.RecordTypeInfo>();
            for(Schema.RecordTypeInfo recordType : descSObjectResults[0].getRecordTypeInfos()) {
                mapRecordType.put(recordType.getRecordTypeId(), recordType);
            }
            mapAllRecordTypesDESC.put(objectName, mapRecordType);
        }
        return mapAllRecordTypesDESC;
    }
    
    public static map<Id, RecordTypeInfo> getRecordTypesDESC(string objectName) {
        return (loadRecordTypesDESC(objectName)).get(objectName);
    }
    
    public static map<Id, string> getRecordTypeIdNameMapByNamesDESC(string objectName, set<string> setRecordTypeNames) {
        map<Id, string> mapRecordTypes = new map<Id, string>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(rTypeInfo.getName())) {
                mapRecordTypes.put(rTypeInfo.getRecordTypeId(), rTypeInfo.getName());
            }
        }
        return mapRecordTypes;
    }
    
    public static map<string, Id> getRecordTypeNameIdMapByNamesDESC(string objectName, set<string> setRecordTypeNames) {
        map<string, Id> mapRecordTypes = new map<string, Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(rTypeInfo.getName())) {
                mapRecordTypes.put(rTypeInfo.getName(), rTypeInfo.getRecordTypeId());
            }
        }
        return mapRecordTypes;
    }
    
    public static map<Id, string> getRecordTypeIdNameMapByIdsDESC(string objectName, set<Id> setRecordTypeIds) {
        map<Id, string> mapRecordTypes = new map<Id, string>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                mapRecordTypes.put(rTypeInfo.getRecordTypeId(), rTypeInfo.getName());
            }
        }
        return mapRecordTypes;
    }
    
    public static map<string, Id> getRecordTypeNameIdMapByIdsDESC(string objectName, set<Id> setRecordTypeIds) {
        map<string, Id> mapRecordTypes = new map<string, Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                mapRecordTypes.put(rTypeInfo.getName(), rTypeInfo.getRecordTypeId());
            }
        }
        return mapRecordTypes;
    }

    public static set<Id> getRecordTypeIdsDESC(string objectName) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            setRecordTypeIds.add(rTypeInfo.getRecordTypeId());
        }
        return setRecordTypeIds;
    }
    
    public static set<string> getRecordTypeNamesDESC(string objectName) {
        set<string> setRecordTypeNames = new set<string>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            setRecordTypeNames.add(rTypeInfo.getName());
        }
        return setRecordTypeNames;
    }  
    
    public static Id getRecordTypeIdByNameDESC(string objectName, string recordTypeName) {
        Id recordTypeId;
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(rTypeInfo.getName() == recordTypeName) {
                recordTypeId = rTypeInfo.getRecordTypeId();
                break;
            }
        }
        return recordTypeId;
    }
    
    public static string getRecordTypeNameByIdDESC(string objectName, Id recordTypeId) {
        return ((loadRecordTypesDESC(objectName)).get(objectName)).get(recordTypeId).getName();
    }
    
    public static set<Id> getRecordTypeIdsByNamesDESC(string objectName, set<string> setRecordTypeNames) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            System.debug('rTypeInfo.getName():'+rTypeInfo.getName());           
            if(setRecordTypeNames.contains(rTypeInfo.getName())) {
                setRecordTypeIds.add(rTypeInfo.getRecordTypeId());
            }
        }
        return setRecordTypeIds;
    }
    
    public static set<string> getRecordTypeNamesByIdsDESC(string objectName, set<Id> setRecordTypeIds) {
        set<string> setRecordTypeNames = new set<string>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypesDESC(objectName)).get(objectName).values()) {
            if(setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                setRecordTypeNames.add(rTypeInfo.getName());
            }
        }
        return setRecordTypeNames;
    }
    // v2.0 - End
    // v3.0 - End
    
    
    // Queue Related Methods
    private static map<Id, Group> mapQueues;
    public static map<Id, Group> getQueueMap() {
        if(mapQueues == null || mapQueues.isEmpty()) {
            mapQueues = new map<Id, Group>([select Id, Name, Email, DoesSendEmailToMembers from Group where Type = 'Queue']);
        }
        return mapQueues;
    }

    public static Group getQueueById(Id queueId) {
        return (getQueueMap()).get(queueId);
    }

    public static map<Id, string> getQueueIdNameMap() {
        map<Id, string> mapQueueIdName = new map<Id, string>();
        for(Group queueIterator : (getQueueMap()).values()) {
            mapQueueIdName.put(queueIterator.Id, queueIterator.Name);
        }
        return mapQueueIdName;
    }

    public static string getQueueNameById(Id queueId) {
        return (getQueueIdNameMap()).get(queueId);
    }

    public static map<string, Id> getQueueNameIdMap() {
        map<string, Id> mapQueueNameId = new map<string, Id>();
        for(Group queueIterator : (getQueueMap()).values()) {
            mapQueueNameId.put(queueIterator.Name, queueIterator.Id);
        }
        return mapQueueNameId;
    }

    public static string getQueueIdByName(string queueName) {
        return (getQueueNameIdMap()).get(queueName);
    }


    // Public Group Related Methods
    private static map<Id, Group> mapGroups;
    public static map<Id, Group> getGroupMap() {
        if(mapGroups == null || mapGroups.isEmpty()) {
            mapGroups = new map<Id, Group>([select Id, Name from Group where Type = 'Regular' limit 50000]);
        }
        return mapGroups;
    }

    public static Group getGroupById(Id groupId) {
        return (getGroupMap()).get(groupId);
    }

    public static map<Id, string> getGroupIdNameMap() {
        map<Id, string> mapGroupIdName = new map<Id, string>();
        for(Group groupIterator : (getGroupMap()).values()) {
            mapGroupIdName.put(groupIterator.Id, groupIterator.Name);
        }
        return mapGroupIdName;
    }

    public static string getGroupNameById(Id groupId) {
        return (getGroupIdNameMap()).get(groupId);
    }

    public static map<string, Id> getGroupNameIdMap() {
        map<string, Id> mapGroupNameId = new map<string, Id>();
        for(Group groupIterator : (getGroupMap()).values()) {
            mapGroupNameId.put(groupIterator.Name, groupIterator.Id);
        }
        return mapGroupNameId;
    }

    public static string getGroupIdByName(string groupName) {
        return (getGroupNameIdMap()).get(groupName);
    }
    
    
    // v1.1 - Created: Opportunity Stage Related Methods
    private static list<OpportunityStage> lstOpportunityStages;
    public static list<OpportunityStage> getOpportunityStages() {
        if(lstOpportunityStages == null) {
            lstOpportunityStages = [select Id, MasterLabel, IsWon, IsClosed, IsActive from OpportunityStage];
        }
        return lstOpportunityStages;
    }
    
    public static map<string, set<string>> getOpportunityStageByGrouping() {
        map<string, set<string>> mapOppStage = new map<string, set<string>>();
        mapOppStage.put('Open', new set<string>());
        mapOppStage.put('Closed', new set<string>());
        
        for(OpportunityStage oppStage : getOpportunityStages()) {
            if(oppStage.IsActive) {
                if(oppStage.IsClosed) {
                    mapOppStage.get('Closed').add(oppStage.MasterLabel);
                }
                else {
                    mapOppStage.get('Open').add(oppStage.MasterLabel);
                }
            }
        }
        return mapOppStage;
    }
    
}
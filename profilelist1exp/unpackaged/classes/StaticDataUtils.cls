/**
This is a static data supply class. Mainly used for getting the recordTypes, logged in user info etc.

* Revision CR Number           Release No      Date            Modified By     Description
* -------- ---------           ----------      -----------     ------------    -----------
* 1.0      9833(15.07)                         23.07.2014      KP              Creation. Thanks to Ragu for the logic and code snippets.
* 2.0      16149               FY18-DCS-0102   12.07.2018      Pallavi         removed commented logics as part of code reduce story 5240511
*/

public class StaticDataUtils {
    
    // Current User Related Details
    private static User currentUser;
    public static User getCurrentUserDetails() {
        if(currentUser == null) {
            currentUser = [select Id, Name, Email, Username, ProfileId, UserRoleId, Profile.Name, UserRole.Name from User where Id = :UserInfo.getUserId()];
        }
        return currentUser;
    }
    
    // Record Types Related Utilities - [Without SOQL]
    private static map<string, map<Id, RecordTypeInfo>> mapAllRecordTypes;
    private static map<string, map<Id, RecordTypeInfo>> loadRecordTypes(string objectName) {
        if(mapAllRecordTypes == null) {
            mapAllRecordTypes = new map<string, map<Id, RecordTypeInfo>>();
        }
        if(!mapAllRecordTypes.containsKey(objectName)) {
            list<Schema.DescribeSObjectResult> descSObjectResults = Schema.describeSObjects(new string[] {objectName});
            map<Id, Schema.RecordTypeInfo> mapRecordType = new map<id, Schema.RecordTypeInfo>();
            for(Schema.RecordTypeInfo recordType : descSObjectResults[0].getRecordTypeInfos()) {
                mapRecordType.put(recordType.getRecordTypeId(), recordType);
            }
            mapAllRecordTypes.put(objectName, mapRecordType);
        }
        return mapAllRecordTypes;
    }
   
    public static set<Id> getRecordTypeIds(string objectName) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypes(objectName)).get(objectName).values()) {
            setRecordTypeIds.add(rTypeInfo.getRecordTypeId());
        }
        return setRecordTypeIds;
    }
 
    public static Id getRecordTypeIdByName(string objectName, string recordTypeName) {
        Id recordTypeId;
        for(RecordTypeInfo rTypeInfo : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(rTypeInfo.getName() == recordTypeName) {
                recordTypeId = rTypeInfo.getRecordTypeId();
                break;
            }
        }
        return recordTypeId;
    }
    
    public static string getRecordTypeNameById(string objectName, Id recordTypeId) {
        return ((loadRecordTypes(objectName)).get(objectName)).get(recordTypeId).getName();
    }
    
    public static set<Id> getRecordTypeIdsByNames(string objectName, set<string> setRecordTypeNames) {
        set<Id> setRecordTypeIds = new set<Id>();
        for(RecordTypeInfo rTypeInfo : (loadRecordTypes(objectName)).get(objectName).values()) {
            if(setRecordTypeNames.contains(rTypeInfo.getName())) {
                setRecordTypeIds.add(rTypeInfo.getRecordTypeId());
            }
        }
        return setRecordTypeIds;
    }
}
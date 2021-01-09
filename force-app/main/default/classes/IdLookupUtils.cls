/*History:
	1.0
	2.0 - MenMee: 13 Jun 2013: Use sObject describe method to reduce number of SOQL 

*/
public class IdLookupUtils {
	//2.0
	public static List<RecordType> recordTypes {
		get {
			if (recordTypes == null) {
				recordTypes = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType];
			}
			return recordTypes;
		}
		private set;
	}
	
	//2.0
	public static Map<String,RecordType> recordTypeMap {
		get {
			if (recordTypeMap == null) {
				Map<String,RecordType> m = new Map<String,RecordType>();
				for (RecordType rt : recordTypes) {					
					m.put(rt.SObjectType.toLowerCase() + '|' + rt.Name.toLowerCase(), rt);
				}
				recordTypeMap = m;
			}
			return recordTypeMap;
		}
		private set;
	}
	
			
    public static Id getRecordTypeId(String name, String sobjectName, boolean isActive){
        //2.0
        /*
        Id theId = null;
        List<RecordType> records = [
            select id from RecordType
            where SobjectType = :sobjectName and IsActive = :isActive and Name = :name
        ];
        if(records.isEmpty()){
            return null;
        }
        return records.get(0).id;
		*/  		
		String key = sobjectName.toLowerCase() + '|' + name.toLowerCase();
		if (!recordTypeMap.containsKey(key)){
			return null;
		}	
		return recordTypeMap.get(key).Id;
		
			
    }

    public static String getIdFromAccountLegacyId(String legacyId){
        
        legacyId=StringUtils.defaultString(legacyId);
        
        if(StringUtils.startsWith(legacyId,'SFDC_')){
            legacyId = legacyId.substring(5,20);
            return legacyId;
            
        }else {
            return '';
        }
             
    }
    
    public static String getIdPrefix(String recordId){
    
        String recordIdPrefix='';
        
        if(recordId!=null){
            recordIdPrefix = StringUtils.defaultString(StringUtils.substring(recordId, 0, 3));
            return recordIdPrefix;
            
        }else {
            return recordIdPrefix;
        }
         
    }
    
    public static String getShortGUID(String recordId){    
        if(recordId != null) return StringUtils.substring(recordId,0,15);
        return '';
    }    
}
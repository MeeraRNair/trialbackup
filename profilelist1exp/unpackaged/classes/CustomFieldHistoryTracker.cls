/***********************************************************
    * Name          : CustomFieldHistoryTracker 
    * Description   : Class to track field history for any object
    * ---------------------------------------------------------
    * Revision  Name         Date        Description
    * 1.0       Prateek    12.06.2015    MAJ16.07 CR11598: created 
    * 2.0       Azwanti    07.09.2015    MAJ16.10 CR11922: added filter for CampaignMember source object
    * 3.0		Azwanti	   19.10.2016	 CR13624 : Track CM status creation history changes in Campaign Member 2.0	 			
    ************************************************************/
public class CustomFieldHistoryTracker
{
    public static Map<String, sObject> mapFieldToHistoryRecords = new Map<String, sObject>();
    
    public static void trackFieldHistory(String sourceObj, String targetObj, String customSetting, String ParentReferenceField, String ParentReferenceFieldTargetAPI, Map<Id, sObject> mapOldSObjects, map<Id, sObject> mapNewSObjects)
    {
        Map<String, Schema.SObjectType> mapSObjectNameToSObjects = Schema.getGlobalDescribe();
        
        // Custom Setting
        Schema.SObjectType customSetting_ObjType = mapSObjectNameToSObjects.get(customSetting);
        
        // Source Object
        Schema.SObjectType source_ObjType = mapSObjectNameToSObjects.get(sourceObj);
        Schema.DescribeSObjectResult source_DescribeResult = source_ObjType.getDescribe();
        Map<String, Schema.SObjectField> mapSourceFieldNameToFields = source_DescribeResult.fields.getMap();
        
        //Target Object
        Schema.SObjectType target_ObjType = mapSObjectNameToSObjects.get(targetObj);

        List<sObject> lstCustomSetting = Database.query( 'SELECT Name FROM ' + customSetting_ObjType.getDescribe().getName());
        List<sObject> lstHistory = new List<sObject>();
        
        for(SObject sObj : mapNewSObjects.values())
        {            
            for(sObject csObj : lstCustomSetting)
            {                
				sObject objHistory = target_ObjType.newSObject();
				
                //v3.0 when mapOldSObjects = null, means this is an insert action
				if(mapOldSObjects == null){
					
					objHistory.put(ParentReferenceFieldTargetAPI, (String)sObj.get(ParentReferenceField));
                    objHistory.put('Record_Id__c', (String)sObj.get('Id'));
                    if(sourceObj != 'CampaignMember'){ // CR11922 filter out CampaignMember since field Name is not visible in the soql
                        objHistory.put('Record_Name__c', (String)sObj.get('Name'));
                    }
                    
					if(sourceObj != 'CampaignMember' || (sourceObj == 'CampaignMember' && mapSourceFieldNameToFields.get((String)csObj.get('Name')).getDescribe().getLabel() != 'Created Date')){ //v3.0
						objHistory.put('New_Value__c', String.valueOf(sObj.get(mapSourceFieldNameToFields.get((String)csObj.get('Name'))))); 
						objHistory.put('Field_Name__c', mapSourceFieldNameToFields.get((String)csObj.get('Name')).getDescribe().getLabel());
						objHistory.put('Field_Name_API__c', mapSourceFieldNameToFields.get((String)csObj.get('Name')).getDescribe().getName());
						
					}
                    objHistory.put('User__c', UserInfo.getUserId());
                    objHistory.put('Date__c', System.Now());
                    
                    if(!CustomFieldHistoryTracker.mapFieldToHistoryRecords.containsKey((String)csObj.get('Name')))
                    {
                        CustomFieldHistoryTracker.mapFieldToHistoryRecords.put((String)csObj.get('Name'), objHistory);
                        lstHistory.add(objHistory);
                    }
				}
                
                //v3.0 when mapOldSObjects != null, this is an update action
                else if(mapOldSObjects != null && sObj.get(mapSourceFieldNameToFields.get((String)csObj.get('Name'))) != mapOldSObjects.get((Id)sObj.get('Id')).get(mapSourceFieldNameToFields.get((String)csObj.get('Name'))))
                {
                    //v3.0 don't create CM history for CreatedDate field on CampaignMember obj.
                    if((sourceObj == 'CampaignMember' && mapSourceFieldNameToFields.get((String)csObj.get('Name')).getDescribe().getLabel() == 'Created Date')){ //v3.0
                        continue;
                    }
                    else{
                        system.debug('new : '+sObj.get(mapSourceFieldNameToFields.get((String)csObj.get('Name'))) + ' >> Old : '+ mapOldSObjects.get((Id)sObj.get('Id')).get(mapSourceFieldNameToFields.get((String)csObj.get('Name'))));
                        objHistory.put(ParentReferenceFieldTargetAPI, (String)sObj.get(ParentReferenceField));
                        objHistory.put('Record_Id__c', (String)sObj.get('Id'));
                        if(sourceObj != 'CampaignMember'){ // CR11922 filter out CampaignMember since field Name is not visible in the soql
                            objHistory.put('Record_Name__c', (String)sObj.get('Name'));
                        } 
                        objHistory.put('Field_Name__c', mapSourceFieldNameToFields.get((String)csObj.get('Name')).getDescribe().getLabel());
                        objHistory.put('Field_Name_API__c', mapSourceFieldNameToFields.get((String)csObj.get('Name')).getDescribe().getName());
                        objHistory.put('Old_Value__c', String.valueOf(mapOldSObjects.get((Id)sObj.get('Id')).get(mapSourceFieldNameToFields.get((String)csObj.get('Name')))));
                        objHistory.put('New_Value__c', String.valueOf(sObj.get(mapSourceFieldNameToFields.get((String)csObj.get('Name'))))); 
                        objHistory.put('User__c', UserInfo.getUserId());
                        objHistory.put('Date__c', System.Now());
                        
                        if(!CustomFieldHistoryTracker.mapFieldToHistoryRecords.containsKey((String)csObj.get('Name')))
                        {
                            CustomFieldHistoryTracker.mapFieldToHistoryRecords.put((String)csObj.get('Name'), objHistory);
                            lstHistory.add(objHistory);
                        }
                    }//v3.0 end else if
                }
				
            }
        }
        
        if(!lstHistory.isEmpty())
        {
            insert lstHistory;
        }
    }
}
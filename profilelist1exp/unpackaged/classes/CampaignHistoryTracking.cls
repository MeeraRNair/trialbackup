/***********************************************************
    * Name          : CampaignHistoryTracking
    * Description   : Class for to track field history for Campaign
    * ---------------------------------------------------------
    * Revision  Name     Date        Description
    * 1.0       Meghana  19.09.2014  CR 10084 Campaign Field History Tracking 
    
    ************************************************************/

public class CampaignHistoryTracking {
    
    // get fields to track from custom setting
    public static List<Campaign_Field_Tracking__c> CampHist = Campaign_Field_Tracking__c.getall().values(); 
    public static Map<String, List<Id>> ReferenceObject = new Map<String, List<Id>> ();      
    public static List<Campaign_Field_Tracking__c> LookupList = new List<Campaign_Field_Tracking__c> ();    
    public static Map<String, Map<id,sObject>> sObjMap = new Map<String, Map<id,sObject>>();
    
    public static String objectType ='Campaign';
    public static Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    public static Schema.SObjectType campSchema = schemaMap.get(objectType);
    public static Map<String, Schema.SObjectField> fieldMap = campSchema.getDescribe().fields.getMap();
    
    public static boolean CheckLookupRef(){
        // check if any field that needs to be trakced for changes is a Lookup field
        for (Campaign_Field_Tracking__c ch : CampHist){
            if (ch.Type__c == 'Lookup'){
                LookupList.add(ch);
            }
        }
        if (LookupList.size() > 0)
            return true;
        else
            return false;
    }
    
    public static void GetReferenceObject(Campaign newCamp, Campaign oldCamp){
        // If any lookup field needs to be tracked then get the object names and references record Ids      
        try{
            for (Campaign_Field_Tracking__c ch : LookupList){
                if (ch.Type__c == 'Lookup'){
                    List<Id> tempIds = new List<Id>();                  
                    Id new_objId = String.valueof(newCamp.get(ch.Name));
                    
                    if (ReferenceObject.ContainsKey(ch.referencename__c))
                        tempIds = ReferenceObject.get(ch.referencename__c);
                    
                    if (new_objId != null)
                        tempIds.add(new_objId);
                    
                    if (oldCamp != null){
                        Id old_objId = String.valueof(oldCamp.get(ch.Name));                        
                        if (old_objId != null)
                            tempIds.add(old_objId);
                    }
                    ReferenceObject.put(ch.referencename__c, tempIds);
                }
            }       
        }
        catch(exception e){
            System.debug(e);
        }
    }
    
    public static void GetReferenceObjectData(){      
        // If any lookup field needs to be tracked then do SOQl on the required objects to get Name field of the referenced record
        for (String ch : ReferenceObject.keySet()){
            List<ID> tempIds = ReferenceObject.get(ch);
            String soql = 'Select id,name from ' + ch + ' where id in :tempIds';
            Map<id,sObject> sObj = new Map<id,sObject>((List<sObject>)Database.query(soql));
            sObjMap.put(ch, sObj);
        } 
    }

    public static List<Campaign_Field_History__c> CreateCampHistoryRec(Campaign newCamp, Campaign oldCamp){
        List<Campaign_Field_History__c> CampFieldHistory = new List<Campaign_Field_History__c>();

        if (oldCamp == null){
            Campaign_Field_History__c cfh = new Campaign_Field_History__c();    
            cfh.Campaign__c = newCamp.Id;                   
            cfh.User__c     = newCamp.LastModifiedById;
            cfh.Date__c     = Datetime.now();                           
            CampFieldHistory.add(cfh);
        }
        else{  
            for (Campaign_Field_Tracking__c chField : CampHist){
                
                if (newCamp.get(chField.Name) != oldCamp.get(chField.Name) ){
                    Campaign_Field_History__c cfh = new Campaign_Field_History__c();
    
                    cfh.Campaign__c =newCamp.Id;
                    if (chField.Name == 'ParentId')
                        cfh.Field_Name__c = 'Parent Campaign';
                    else
                        cfh.Field_Name__c = fieldMap.get(chField.name).getDescribe().getLabel();
                    
                    cfh.User__c  = newCamp.LastModifiedById;
                    cfh.Date__c  = Datetime.now();
                                    
                    if (chField.Type__c == 'Lookup'){
                        Map<id,sobject> tempObjList = sObjMap.get(chField.ReferenceName__c);
                        if (newCamp.get(chField.Name) != null && tempObjList != null)
                            cfh.Field_Value_New__c = String.valueof(tempObjList.get(String.valueof(newCamp.get(chField.Name))).get('Name'));
                        
                        if (oldCamp.get(chField.Name) != null && tempObjList != null)
                            cfh.Field_Value_Old__c = String.valueof(tempObjList.get(String.valueof(oldCamp.get(chField.Name))).get('Name'));
                    }
                    else if (chField.Type__c != 'Text Area' && chField.Type__c != 'Text Area Long' && chField.Type__c != 'Text Area Rich') {
                        cfh.Field_Value_New__c = String.valueof(newCamp.get(chField.Name));
                        cfh.Field_Value_Old__c = String.valueof(oldCamp.get(chField.Name));                     
                    }
                    CampFieldHistory.add(cfh);
                }
            }
        }
        return CampFieldHistory;
    }    
}
/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR18117     FY20-1101   14-Sept-2019     Hari A         Update attachment/Date Attached on sObject(Account Plan) when File is added/deleted
                                                                    Use this util class for uploading multiple Files for same object, but not for multiple Sobjects                                                              
 * 
 */ 
public class ContentDocLinkUtilities{

   public static void updateFilesAI(List<ContentDocumentLink> listFiles){
      
        Set<id> setIds = new Set<id>();
        Set<id> setCDIds = new Set<id>();
        for(ContentDocumentLink att:listFiles){            
           setIds.add(att.Linkedentityid);        
        }
       
       string strObjName = string.valueOf(getsObjectName(setIds));
       
       if(strObjName<>null){
           string strCommonQuery ; 
           strCommonQuery= ' SELECT Attachment__c , Date_Attached__c from '+String.escapeSingleQuotes(strObjName)+' where id in:setIds';
           List<sObject> listsObjUpdate =Database.query(strCommonQuery);  
           for(sObject sObj:listsObjUpdate){        
                sObj.put('Attachment__c' ,true);
                sObj.put('Date_Attached__c',system.now().dateGMT());            
           }
           if(!listsObjUpdate.isEmpty()){
              update listsObjUpdate;
           }
       }
   }
   
   public static string getsObjectName(set<id> setObjIds){
       string strObject;
       if(setObjIds<>null){
           for(Id idObj:setObjIds) {
               if(!string.valueof(idObj).startsWith('005')){
                     strObject =idObj.getSObjectType().getDescribe().getName();
                 }
            }
        }
        if(strObject<>null){
            Set<string> setFields;
            Map<String, Schema.SObjectField> mapObjectFields = Schema.getGlobalDescribe().get(strObject).getDescribe().fields.getMap();
            setFields = new set<String>(mapObjectFields.keySet());
            if(setFields.contains('attachment__c') && setFields.contains('date_attached__c')){
                   return strObject;
                }
        }
      
    return null;
   }
   public static void updateFilesAD(List<ContentDocumentLink> listFiles){
       
        Set<id> setIds = new Set<id>();
        Set<id> setCDIds = new Set<id>();
        for(ContentDocumentLink att:listFiles){            
           setIds.add(att.LinkedEntityId);        
        }
       string strObjName = getsObjectName(setIds);
       if(strObjName<>null){ 
           string strCommonQuery = 'SElECT';
           strCommonQuery= strCommonQuery+' id, Attachment__c, Date_Attached__c, (select id from ContentDocumentLinks) from '+String.escapeSingleQuotes(strObjName)+' where id in:setIds'; 
           List<sObject> listsObjUpdate =Database.query(strCommonQuery); 
           list<ContentDocumentLink> listAttach = new list<ContentDocumentLink>([select id,SystemModstamp,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:setIds order by SystemModstamp desc ]);
           map<id,ContentDocumentLink> mapAccPlanIDToAttach = new  map<id,ContentDocumentLink>();       
            for(ContentDocumentLink obj: listAttach) {
                if(mapAccPlanIDToAttach.containskey(obj.LinkedEntityId)){
                    continue;
                }
                else{
                  mapAccPlanIDToAttach.put(obj.LinkedEntityId,obj);
                }
            }
            
            for (sObject sObj:listsObjUpdate) {
                List<SObject> listObjAtt = sObj.getSObjects('ContentDocumentLinks');    
                if(listObjAtt<>null && listObjAtt.size()>0){
                  sObj.put('Attachment__c',true);           
                  sObj.put('Date_Attached__c', Date.valueOf(mapAccPlanIDToAttach.get(sObj.id).SystemModstamp));    
                } 
                else { 
                  sObj.put('Attachment__c',false);
                  sObj.put('Date_Attached__c', null);
                }            
            }
        
            if(!listsObjUpdate.isEmpty()){
               update listsObjUpdate;
            } 
        }   
    }
   

}
/*
* Revision CR Number   Release No      Date            Modified By     Description
* 1.0       7501119    FY20101         10/7/2019        Sunil H        Update BOS Email Field in Inventory Request based on account
*                                                                      country code/ and ISG record types
*/
public class InventoryRequestHelper {
    public static void beforeInsert(list<Dell_Sales_FIM__Inventory_Request__c> listInvRequest){
        map<string,FIM_BOS_Email_Settings__mdt> mapFIMBOSEmailSettings = getCustomMetadata();
        Set<String> setInventoryRequestRecordType = Dell_Sales_FIM__Inventory_Request_Record_Type_Id__c.getAll().keySet();
        for(Dell_Sales_FIM__Inventory_Request__c invReq:listInvRequest){
            if((setInventoryRequestRecordType !=null && setInventoryRequestRecordType.contains(invReq.recordTypeId)) &&
               invReq.Account_Country_Code__c!= null && mapFIMBOSEmailSettings.containskey(invReq.Account_Country_Code__c) 
                && mapFIMBOSEmailSettings.get(invReq.Account_Country_Code__c).BOS_Email__c != null){
                    invReq.BOS_Email__c = mapFIMBOSEmailSettings.get(invReq.Account_Country_Code__c).BOS_Email__c;
            }
        }
    }
    public static void beforeUpdateBosEmail(List<Dell_Sales_FIM__Inventory_Request__c> listInvRequest, Map<Id, Dell_Sales_FIM__Inventory_Request__c> mapOldInvRequest) {
        map<string,FIM_BOS_Email_Settings__mdt> mapFIMBOSEmailSettings = getCustomMetadata();
        Set<String> setInventoryRequestRecordType = Dell_Sales_FIM__Inventory_Request_Record_Type_Id__c.getAll().keySet();
        for(Dell_Sales_FIM__Inventory_Request__c invReq:listInvRequest){
            if((setInventoryRequestRecordType !=null && setInventoryRequestRecordType.contains(invReq.recordTypeId)) &&
               invReq.Account_Country_Code__c!= null && mapFIMBOSEmailSettings.containskey(invReq.Account_Country_Code__c) 
                && mapFIMBOSEmailSettings.get(invReq.Account_Country_Code__c).BOS_Email__c != null){
                invReq.BOS_Email__c = mapFIMBOSEmailSettings.get(invReq.Account_Country_Code__c).BOS_Email__c;
            }
        }
    }  
    public static map<string,FIM_BOS_Email_Settings__mdt> getCustomMetadata(){
        map<string,FIM_BOS_Email_Settings__mdt> mapFIMBOSEmailSettings= new map<string,FIM_BOS_Email_Settings__mdt>();
        for(FIM_BOS_Email_Settings__mdt emailBos:[select BOS_Email__c,Country_Code__c,DeveloperName from FIM_BOS_Email_Settings__mdt]){
            mapFIMBOSEmailSettings.put(emailBos.Country_Code__c,emailBos);
        }
        return mapFIMBOSEmailSettings;
    }
}
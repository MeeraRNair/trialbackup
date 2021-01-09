public class ExtendedAssetController {
    
   @AuraEnabled
    public static List <Dell_Asset_RMA__Asset__c> sFetchAvamarNodes(String gridId) {
        List<Dell_Asset_RMA__Asset__c> assetList = [SELECT Id,Dell_Asset_RMA__Serial_Number__c, 
                                    Dell_Asset_RMA__Install_Base_Status__c,Dell_Asset_RMA__Ship_Date__c  from Dell_Asset_RMA__Asset__c
                                    where asset_parent__c = :gridId];
        return assetList ;
    }
    
    @TestVisible private static List<public_assets_extobj__x> mockedRequests = new List<public_assets_extobj__x>();
    
   @AuraEnabled
     public static public_assets_extobj__x getExtAssetObj(String assetId) {
	
      if(Test.isRunningTest()) {
            return (mockedRequests.size() > 0) ? mockedRequests[0] : null;
        }

     public_assets_extobj__x extAsset = [Select Id,external_asset_id_c__c,External_Asset_ID_c__r.Dell_Asset_RMA__Customer_Name__r.Owner.Name FROM public_assets_extobj__x Where external_asset_id_c__c = :assetId limit 1];
     return extAsset;
    }
}
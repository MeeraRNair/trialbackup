public class AssetPassToRenewalsController{
    public List<Dell_Asset_RMA__Asset__c> assetList {get;set;}
    private ApexPages.StandardSetController standardController;
    private List<Id> assetIds = new List<Id>();

    public AssetPassToRenewalsController(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
        assetList = new List<Dell_Asset_RMA__Asset__c>();
        for (Dell_Asset_RMA__Asset__c asset : (List<Dell_Asset_RMA__Asset__c>)standardController.getSelected()){ 
            assetIds.add(asset.Id);
        }

    }
    
    public PageReference deferAsset() {
        Dell_Asset_RMA.R2R_AssetStatus.deferAsset(assetIds);
        PageReference back = standardController.cancel();
        return back;
    }
    

}
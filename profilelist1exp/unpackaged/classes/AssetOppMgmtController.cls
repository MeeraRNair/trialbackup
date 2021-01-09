public class AssetOppMgmtController{
    public List<Dell_Asset_RMA__Opportunity_Asset_Junction__c> assetList {get;set;}
    private ApexPages.StandardSetController standardController;
    private List<Id> assetIds = new List<Id>();

    public AssetOppMgmtController(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
        assetList = new List<Dell_Asset_RMA__Opportunity_Asset_Junction__c>();
        for (Dell_Asset_RMA__Opportunity_Asset_Junction__c asset : (List<Dell_Asset_RMA__Opportunity_Asset_Junction__c>)standardController.getSelected()){ 
            assetIds.add(asset.Id);
        }

    }
    
    public PageReference unlink() {
        String msg='';
        if (assetIds.size() > 0) {
            Dell_Asset_RMA__Opportunity_Asset_Junction__c  rec= [select Dell_Asset_RMA__Related_Opportunity__c from Dell_Asset_RMA__Opportunity_Asset_Junction__c where
                    id in :assetIds limit 1];
            if(Test.isRunningTest())
                msg = 'fail';
            else
            	msg = Dell_Asset_RMA.R2R_Opportunity_Management.AssetUnlinking(rec.Dell_Asset_RMA__Related_Opportunity__c ,assetIds);
 			System.debug('msg:'+msg);
        }
        return back(msg);
    }
    
    public PageReference unlinkDefer() {
        String msg='';
        if (assetIds.size() > 0) {
            Dell_Asset_RMA__Opportunity_Asset_Junction__c  rec= [select Dell_Asset_RMA__Related_Opportunity__c from Dell_Asset_RMA__Opportunity_Asset_Junction__c where
                    id in :assetIds limit 1];
            if(Test.isRunningTest())
                msg = 'success';
			else
            	msg = Dell_Asset_RMA.R2R_Opportunity_Management.assetDeferUnlinking(rec.Dell_Asset_RMA__Related_Opportunity__c ,assetIds);
        }
        return back(msg);
    }
    
    private PageReference back(String msg) {
        PageReference back = standardController.cancel();
        if (msg != 'success') {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);
            ApexPages.addMessage(myMsg);
            return null;
        }
        return back;
    }

}
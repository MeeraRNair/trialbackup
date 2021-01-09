public class CMAP_MLUROverrideNewButtonCntrlr{
    
    Mass_Upload_Lead_Request__c mlur; 
    Boolean isPartner;
    Pagereference newPage;
    Schema.DescribeSObjectResult sObj;
    
    Public CMAP_MLUROverrideNewButtonCntrlr(ApexPages.StandardController stdController){
        mlur = (Mass_Upload_Lead_Request__c)stdController.getRecord();
        isPartner = [SELECT IsPortalEnabled FROM User WHERE Id =: userInfo.getUserId()].IsPortalEnabled;
    }
    
    public pageReference redirect(){
        //newPage = new Pagereference ('/apex/CMAP_SubmitSingleLead');
        if(isPartner){
            newPage = new Pagereference ('/apex/CMAP_LeadGenerationInterface');
        }
        
        else{
            sObj = this.mlur.getSObjectType().getDescribe(); 
            PageReference pr = ApexPages.currentPage();
            Map<String, String> params = pr.getParameters();
            String stringToAppend = '';
            for(String keyStr : params.keySet()){
                if(keyStr != 'core.apexpages.devmode.url' && keyStr != 'sfdc.override' && keyStr != 'save_new'
                    && keyStr != 'scontrolCaching'){
                    if(stringToAppend != '') {
                        stringToAppend += '&';
                    } 
                    System.debug('********************stringToAppend*** 01 '+stringToAppend); 
                    System.debug('****************************keyStr*** 01 '+keyStr); 
                    System.debug('****************params.get(keyStr)*** 01 '+params.get(keyStr)); 
                    // stringToAppend += keyStr + '=' +params.get(keyStr);
                    stringToAppend += keyStr + '='+pageUtils.encodeVariable(params.get(keyStr));
                }
            }
            newPage = new Pagereference('/' + sObj.getKeyPrefix() + '/e?nooverride=1&' + stringToAppend);
            /*sObj = this.mlur.getSObjectType().getDescribe();         
            if(mlur.Campaign__c != null){
                String campName = [SELECT Name FROM Campaign WHERE Id =:mlur.Campaign__c LIMIT 1].Name;
                newPage = new Pagereference('/' + sObj.getKeyPrefix() + '/e?nooverride=1&CF00NA0000009ZFtV=' + campName + '&CF00NA0000009ZFtV_lkid=' + mlur.Campaign__c + '&retURL=' + mlur.Campaign__c);
            }
            else
                newPage = new Pagereference ('/' + sObj.getKeyPrefix() + '/e?nooverride=1&retURL=' + sObj.getKeyPrefix());*/
        }
        
        return newPage;
    }


}
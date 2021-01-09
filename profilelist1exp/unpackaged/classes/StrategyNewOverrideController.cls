/***********************************************************
* Name          : StrategyNewOverrideController 
* Description   : Controller class for StrategyNewOverride
* ---------------------------------------------------------
* Revision      Release     Name            Date            Description   
* 1.0           13.1        Raymond Yip     15-Nov-2011     Created
* 2.0           0502        Rahul Mishra    03-April-2017   Optimized the code
************************************************************/
public class StrategyNewOverrideController {

    Map<String, String> params;
    public StrategyNewOverrideController (ApexPages.StandardController controller) {
        params = ApexPages.currentPage().getParameters();
    }
    
    public boolean getHasMessage() {
        return ApexPages.hasMessages();
    }
  
    public PageReference createNewStrategy(){

        params.put('nooverride','1');
        params.put('CF00NK0000000PLRX_lkid', UserInfo.getUserId());
        
        params.remove('sfdc.override');
        params.remove('save_new');
     
        String url = '/a0G/e?nooverride=1';
        for(String s : params.KeySet()) {
            url += '&' + s + '=' + EncodingUtil.URLEncode(params.get(s),'UTF-8');
        }

        PageReference pr = new PageReference(url);
        pr.getParameters().put('CF00NA00000063VJ1', UserInfo.getName()); //Have to do it here, else get encoded twice
        return pr;
    }
}
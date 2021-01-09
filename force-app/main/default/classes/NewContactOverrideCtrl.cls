/***********************************************************
* Name          : NewContactOverrideCtrl
* Description   : Controller class for New Contact Overriding
* ---------------------------------------------------------
* Revision      Release     Name            Date            Description   
* 1.0           R0403       Jessie Tan      21-Mar-2016     Created
* 2.0           Sprint7     Jessie Tan      25-Apr-2016     Modified (CR13073) to solve lightning error ( Record Type Id : The ID isn't valid for the User)
* 3.0           0502            Rahul       04-April-2018   To Optimize the code
*******************************************************************/
public class NewContactOverrideCtrl {

    Map<String, String> params = new Map<String, String>();
    public String rtName {get;set;}
    
    public NewContactOverrideCtrl(ApexPages.StandardController controller) {
        params = ApexPages.currentPage().getParameters();
        rtName = '';
        List<RecordType> objRT = new List<RecordType>([Select Id From RecordType where sobjecttype = 'Contact' AND DeveloperName = 'GBL_Standard_RT' LIMIT 1]);
        rtName = objRT[0].Id;
    }
    
    public boolean getHasMessage() {
        return ApexPages.hasMessages();
    }
    
    
    public String createURL() {
        
        if(!params.containsKey('CF00NA00000064sQh'))
            params.put('CF00NA00000064sQh', UserInfo.getName());
        
        if(!params.containsKey('saveURL'))
            params.put('saveURL', '/apex/AVSContactSuggestion');
        
        if(!params.containsKey('retURL'))
            params.put('retURL', '/003/o');
        
        params.remove('sfdc.override');
        params.remove('save_new');
     
        String url = '/003/e?nooverride=1';
        for(String s : params.KeySet()) {
            url += '&' + s + '=' + EncodingUtil.URLEncode(params.get(s),'UTF-8');
        }
        return url;
    }
    
    public PageReference createNewContact(){
        String strURL = createURL();
        PageReference pr = new PageReference(strURL);
        return pr;
    }

    //v2.0 - start
    public String getNewContact(){
        String strURL = createURL();
        return strURL;

    }   //2.0 - end 
}
/***********************************************************
* Name          : VFCntrlr_SFDCtoCOM 
* Description   : To redirect to COM
* ---------------------------------------------------------
* Revision      CR#								Release      Name                             Date              Description
* 3.0          	8553, 8570, 8671, 8572	 		14.10        Che Saidi, Shahiruni Wahida      28 Aug 2013       Modification after first code review
*
*
************************************************************/

public class VFCntrlr_SFDCtoCOM {
    private Map<String,String> paramMap = null;
    private String newCurrentParams;
    private String url;
    private String returnURL;
    private String id;
    
    
	public VFCntrlr_SFDCtoCOM() {
    	id = ApexPages.currentPage().getParameters().get('id');   
        url = Label.COM_URL;
        paramMap = ApexPages.currentPage().getParameters();
        paramMap.remove('id');
        
        newCurrentParams = '?'+string.valueOf(paramMap).replace('{','').replace('}','').replace(', ', '&');
        newCurrentParams  = constructParams();
    }        
        
        
    public String constructParams(){
        if(paramMap.get('country') != null){
            List<Country__c> countryList = [
                SELECT Region__c 
                FROM Country__c 
                WHERE Code__c =:paramMap.get('country') 
            ];
        
            if(countryList != null && countryList.size() == 1){
                if(countryList[0].region__c != null){
                    paramMap.remove('country');
                    paramMap.put('region', PageUtils.encodeVariable(countryList[0].region__c.toLowerCase()));
                    return '?'+string.valueOf(paramMap).replace('{','').replace('}','').replace(', ', '&');
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Region not set up correctly'));
                    return null;
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Country/Region not set up correctly'));
                return null;
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Account Country Code is empty'));
            return null;
        }
    }
    
    
    //to redirect to COM
    public PageReference navToCOM (){
        PageReference pr = null;
        returnURL = url;
        try{
            if(url != null && newCurrentParams != null){
                returnURL = returnURL+newCurrentParams;
                pr = new PageReference(returnURL);
                system.debug('shue returnURL ------------ '+returnURL);
                pr.setRedirect(true);
                return pr;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Not be able to connect to COM'));
                return pr;
            }
        }catch(Exception e){
        	System.debug('Invalid URL exception ' + e.getMessage());
        }
        return pr;
    }
    
    
    //back to previous page
    public PageReference back (){
        PageReference pr = null;
        pr = new PageReference('/'+id);
        return pr;
    }
}
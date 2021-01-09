/***********************************************************
* Name          : VFCntrlr_SFDCtoDSP 
* Description   : To redirect to DSP
* ---------------------------------------------------------
* Revision      CR#       Release      Name           Date             Description
* 1.0           9012      15.03        Nisha C O      23 Jan 2014      Modification after first code review
* 2.0           9012      15.03        Nisha C O      04 Feb 2014      Modification after second code review in order to include sfdc account id and opportunity id along with anchor character in the url.
*
************************************************************/
public class VFCntrlr_SFDCtoDSP {
    private MAp<string,string> paramMap = null;
    private String newCurrentParams;
    private String url;
    private String returnURL;
    private String id;
    private set<string> keys;
    private String dealidtext;

    public VFCntrlr_SFDCtoDSP() {
        id = apexpages.currentpage().getparameters().get('id');
        paramMap = apexpages.currentpage().getparameters();
        keys = paramMap.keyset();
        system.debug('************keys**************' + keys);
        system.debug('-------- parameters of the current page --------' + paramMap);
      //  paramMap.remove('id');
        
        newCurrentParams = '?'+ string.valueof(paramMap).replace('{','').replace('}','').replace(', ','&');
        system.debug('-------------- new parameters---------' + newCurrentParams);
        newCurrentParams = constructParams();
    }

    public string constructParams(){
          if(paramMap.size()> 0 && paramMap.get('country') != null) {
            string countrycode = paramMap.get('country');
            string redirectvalue = paramMap.get('redirectvalue');
              system.debug('***'+countrycode);
              system.debug('****'+redirectvalue);
            if( Label.DSPCountry.contains(countrycode) && redirectvalue == 'account/details'){
                system.debug('---------9999999999------------');
                url = Label.SFDCtoDSP;
                system.debug('$$$$$$$$$$$$$' + url);
                paramMap.remove('country');
                system.debug('###########' + paramMap);
               //  string redirectvalue2 = paramMap.get('redirectvalue');
                paramMap.remove('redirectvalue');
                system.debug('@@@@@@@@@@@@' + paramMap);
                
                newCurrentParams = '/'+redirectvalue+'?'+string.valueof(paramMap).replace('{','').replace('}','').replace(', ','&');
                system.debug('!!!!!!!!!!!!!!!!!!' +newCurrentParams);
                system.debug('---------- url of the new page---------' + url);
            }
            else if( Label.DSPCountry.contains(countrycode) && redirectvalue == 'opportunity/details/'){
                for(string s:keys){ 
                    if(s.contains('dealid')){
                        dealidtext = s;
                        system.debug('---------------dealid retrieved as text------' + dealidtext);
                    }
                }
                url = Label.SFDCtoDSP;
                paramMap.remove('country');
              //  string redirectvalue2 = paramMap.get('redirectvalue');
                paramMap.remove('redirectvalue');
                string idvalue = paramMap.get('id');
                string dealidvalue = paramMap.get('dealid');
                newCurrentParams = '/'+redirectvalue+dealidtext+'/'+dealidvalue;
                system.debug('-----------url of the new page---------' + url);
            }
            else if( Label.DSPCountry.contains(countrycode) && redirectvalue == 'quote/create'){
                url = Label.SFDCtoDSP;
                paramMap.remove('id');
                paramMap.remove('country');
              //  string redirectvalue2 = paramMap.get('redirectvalue');
                paramMap.remove('redirectvalue');
                newCurrentParams = '/'+redirectvalue+'?'+string.valueof(paramMap).replace('{','').replace('}','').replace(', ','&');
                system.debug('------------url of the new page-----------' + url);
            }
            else{
                apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Account country code needs to be set and mapped to a country'));
                return null;
            }

            return newCurrentParams;
            } 
            else {
                Apexpages.addmessage(new apexpages.message(Apexpages.severity.Error,'Account country code is empty'));
                return null;
             }
            
    }

    public pagereference navtoDSP () {
        pagereference pr = null;
        returnURL = url;
        try{ 
        if(URL!= null && newCurrentparams != null){
         //   returnURL = returnURL+newCurrentparams;
            system.debug('------- this is the new url----' + returnURL);
            pr = new pagereference(URL);
            pr.setAnchor(newCurrentparams);
            system.debug('--------- 888888 ----------' + pr);
            pr.setRedirect(true);
            return pr;
            } 
            else{
                apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, 'Not be able to connect to DSP'));
                return pr;
            }
            }
            catch(exception e) {
            system.debug('invalid url exception' + e.getMessage());
            }
            return pr;
        }

    public pagereference back() 
    {
        pagereference pr = null;
        pr = new pagereference('/' + id);
        system.debug('-----------' + pr);
        return pr;
    }
}
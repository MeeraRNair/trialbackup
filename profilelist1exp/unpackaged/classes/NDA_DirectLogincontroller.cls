public with sharing class NDA_DirectLogincontroller {
    public String strProfileName { get;set;}
    public string  getCommunication() {
        user userObjLoggeduser=[select id,Profile.Name,email,FederationIdentifier from user WHERE id=:userinfo.getUserId() and isactive=:true limit 1];
        system.debug('User Email ==>>'+userObjLoggeduser.email);
        // string emailId=userObjLoggeduser.email;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:NDA_Direct/services/apexrest/NDA_redirectLink/'+userObjLoggeduser.email);
        request.setMethod('GET');
        HttpResponse response = http.send(request); 
        system.debug('Get status code ==>>'+response.getStatusCode() );     
        if (response.getStatusCode() == 200) {
            System.debug('Response received ==>'+response.getBody());
            system.JSONParser json= JSON.createParser(response.getBody());
            while(json.nextToken()!=null){
                if(json.getText()=='Name'){
                    json.nextToken();
                    strProfileName =json.getText();
                }
            }
            system.debug('strProfileName ==>>'+strProfileName);
            return strProfileName;
        } else {
            return strProfileName;   
         }        
    } 
    public PageReference getCall(){
        strProfileName='';
        getCommunication();
        if(String.isNotBlank(strProfileName)){
            if(strProfileName=='NDA End User'){
                string url1=Label.NDA_Redirect_Portal;
                //string url1 = 'https://pf-uat.us.dell.com/idp/startSSO.ping?PartnerSpId=SFDC.Corp.Ptl.SP&IdpAdapterId=CorpIWA&IWADomain=DELL.COM&SpSessionAuthnAdapterId=SFDC.Corp.Ptl.IdP&TargetResource=https://cs11.salesforce.com/secur/login_portal.jsp?orgId%3D00DZ000000NEA2S%26portalId%3D0607000000054T0%26Action%3DloginAction%26jse%3D0%26loginType%3D2%26useSecure%3Dtrue';
                PageReference pagerefer1 = new PageReference(url1);
                pagerefer1.setRedirect(true);
                return pagerefer1 ; 
            } else {
                string url2=Label.NDA_Redirect_Classic;
                //string url2 = 'https://dellapps--corpuat2.cs11.my.salesforce.com/home/home.jsp';
                PageReference pagerefer2 = new PageReference(url2);
                pagerefer2.setRedirect(true);
                return pagerefer2; 
            }
        }
        else {
            return null;
        }
    }      
}
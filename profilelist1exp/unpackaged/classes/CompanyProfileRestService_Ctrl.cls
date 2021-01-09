/*************************************************************************************************************
 * @Author      : Sarveswara Gupta P
 * Purpose      : To update Mup Profile id in lead(From MUP Env) and to pass Update MUP Details step 
 *                in Partner Request. 
 * Calling      : This class will be call from Partner Request object MUP Details step.
 **************************************************************************************************************/
public class CompanyProfileRestService_Ctrl {
 private Partner_Request__c partnerRequest;
 final string SANDBOX = 'Sandbox';
 public string strCompleteFlag;
 public class RequestBodyWrap { //Wrapper Class to send Request to MUP Env
  integer ucid;
  string affinityId;
  string siteDUNS;
  string globalDUNS;
  string companyName;
  list < string > emailDomains = new list < string > ();
  string restrictedProfile = 'Y';
  //list<string> plinkEntitlements=new list<string>();
  // list<string> dellEmcEntitlements=new list<string>();
  integer adminEmployeeId;
  integer masterGroupId;
 }
 public class ResponseBodyWrap { //Wrapper Class to hold Responce from MUP Env
  string message;
  string status;
  string companyProfileId;
 }
 public CompanyProfileRestService_Ctrl(ApexPages.StandardController controller) {
  strCompleteFlag = apexpages.currentpage().getparameters().get('complete'); // flag to know this class is called from mark as complete or mark as not required
  partnerRequest = (Partner_Request__c) controller.getRecord();
  partnerRequest = [SELECT Lead__c, Website__c, name FROM Partner_Request__c WHERE id =: partnerRequest.id];
 }
 public PageReference companyProfileWebservice() {
  System.PageReference returnPage;
  try {
   system.debug(strCompleteFlag + ' : Lead Id : ' + partnerRequest.Lead__c);
   Lead leadRec = [select id, Universal_Customer_ID_UCID__c, Mg_Name__c, Mg_Website__c, Product_Focus__c,Partner_Request__r.Email__c from Lead where id =: partnerRequest.Lead__c];
   if (strCompleteFlag == 'true') //if it is true it will fire web service
   {
    String strDomain = leadRec.Partner_Request__r.Email__c.split('@').get(1);
    system.debug('****EmailDom :-'+ strDomain);   
    RequestBodyWrap rw = new RequestBodyWrap();
    rw.ucid = integer.valueOf(leadRec.Universal_Customer_ID_UCID__c);
    rw.affinityId = null;
    rw.siteDUNS = null;
    rw.globalDUNS = null;
    rw.companyName = leadRec.Mg_Name__c;
    rw.emailDomains.add(strDomain);
    rw.restrictedProfile = 'Y';
    rw.adminEmployeeId = Integer.valueOf([select Badge_Number__c from User where id =: UserInfo.getUserId()].Badge_Number__c);
    rw.masterGroupId = 23231;
    system.debug('Request Body : ' + JSON.serialize(rw));
    string strUsername;
    string strPassword;
    string strEndPoint;
    string strAuthenticationApi;   
    if (StaticFactory.getEnvironment() == SANDBOX) {
   //  strUsername = Label.MUP_Integration_User_Name_SB;
   //  strPassword = Label.MUP_Integration_User_Pwd_SB;
     strEndPoint = Label.MUP_CompanyProfileCreation_EndPoint_SB;
     strAuthenticationApi = Label.MupLayer7ApiKey_SB;   
        
    } else {
    // strUsername = Label.MUP_Integration_User_Name_Prod;
   //  strPassword = Label.MUP_Integration_User_Pwd_Prod;
     strEndPoint = Label.MUP_CompanyProfileCreation_EndPoint_Prod;
     strAuthenticationApi = Label.MupLayer7ApiKey_PROD;
    }
   // string strEndPoint=Label.MUP_CompanyProfileCreation_EndPoint;
  //  Blob blbHeaderValue = Blob.valueOf(strUsername + ':' + strPassword);
  //  String strAuthorizationHeader = 'Basic ' + EncodingUtil.base64Encode(blbHeaderValue);
    Http h = new Http();
    system.debug('Status Code 26: ');
    HttpRequest req = new HttpRequest();
    system.debug('Status Code 28: ');
    req.setMethod('POST');
 // req.setHeader('Authorization', strAuthorizationHeader);
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('ApiKey', strAuthenticationApi);
    req.setTimeout(120000);

    String testBody = JSON.serialize(rw);
    System.debug('Status Code Body ' + testBody);

    req.setBody(testBody);
    system.debug('Status Code : ' + rw);
    req.setEndpoint(strEndPoint);
    // req.setEndpoint('https://ssgosgtst.emc.com/CompanyProfileRestService/api/create');
    System.debug('Status Code Req ' + req.getBody());
    System.debug('Status Code Res ' + h.send(req));
    HttpResponse response = h.send(req);
    system.debug('Status Code res**: ' + response);
    ResponseBodyWrap resp;
    if (response.getStatusCode() == 201) {
     resp = (ResponseBodyWrap) JSON.deserialize(response.getBody(), ResponseBodyWrap.class);
     system.debug('resp : ' + resp.message);
     leadRec.MUP_Company_Profile_ID__c = resp.companyProfileId;
     update leadRec;
     partnerRequest.MUP_Profile_Creation__c = true;
     returnPage = new PageReference('/' + partnerRequest.ID);
    } else if (response.getStatusCode() == 302) {
     resp = (ResponseBodyWrap) JSON.deserialize(response.getBody(), ResponseBodyWrap.class);
     system.debug('resp warning : ' + resp.message);
     if (resp.message == 'Company Profile already exists') {
      leadRec.MUP_Company_Profile_ID__c = resp.companyProfileId;
      update leadRec;
      partnerRequest.MUP_Profile_Creation__c = true;
      returnPage = new PageReference('/' + partnerRequest.ID);
     } else {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, resp.message));
     }
    } else if (response.getStatusCode() == 424 || response.getStatusCode() == 400) {
     resp = (ResponseBodyWrap) JSON.deserialize(response.getBody(), ResponseBodyWrap.class);
     system.debug('resp warning : ' + resp.message);
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, resp.message));
    } else if (response.getStatusCode() == 500) {
     resp = (ResponseBodyWrap) JSON.deserialize(response.getBody(), ResponseBodyWrap.class);
     system.debug('resp warning : ' + resp.message);
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, resp.status + ',' + resp.message));
    } else if (response.getStatusCode() == 404) {
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Status 404-Connection to MUP Failed'));
    } else {
     // partnerRequest.MUP_Profile_Creation__c=false;;
     system.debug('resp body : ' + response.getBody());
     WebServiceExceptionHandling.insertException(string.valueof(req.getBody()), response.getBody(), response.getStatusCode(), 'MUPProfileId', partnerRequest.name);
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, response.getBody()));
    }
    system.debug('Status  : ' + response.getStatus());
    system.debug('Body : ' + response.getBody());
   } else {
    partnerRequest.MUP_Profile_Creation__c = true;
    returnPage = new PageReference('/' + partnerRequest.ID);
   }
  } catch (exception e) {
   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
   system.debug('Exception : ' + e);
  }
  update partnerRequest;
  return returnPage;
 }
 public PageReference goBacktoPRPage() {
  PageReference returnPage = new PageReference('/' + partnerRequest.ID);
  return returnPage;

 }
}
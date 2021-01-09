/*---------------------------------------------
Description: Class to send data to SQL DB2016 if sending of data is failed from 
             'PartnerPortalProfilingserviceIntegration' class this class scheduled 
              after 10 seconds of failure to send data to SQL DB2016    
CR# 13831              

Author: Uday



--------------------------------------------*/

global class PartnerPortalProfilingserviceIntg_Sch implements Schedulable, Database.AllowsCallouts {

 public String RequestData;
 public string PassedRecId;
 global PartnerPortalProfilingserviceIntg_Sch(String RequestDatais, String PassedRecId) {
  this.RequestData = RequestDatais;
  this.PassedRecId = PassedRecId;

 }

 // Execution Start
 global void execute(SchedulableContext sc) {

  senddata(RequestData, PassedRecId);

 }

 @future(callout = true)
 global static void senddata(String RequestData, String PassedRecId) {
  String USERNAME;
  String PASSWORD;

  if (UserInfo.getOrganizationId() == '00D300000006urqEAA') {
   //this is for Production
            USERNAME=System.Label.DP_API_PP_PROD_UNAME;  //for PRODUCTION env
            PASSWORD=System.Label.DP_API_PP_PROD_PASSWORD; // to be filled in later
          

  } else {
   //this is for Sand box
            USERNAME=System.Label.DP_API_PP_SB_UNAME;
            PASSWORD=System.Label.DP_API_PP_SB_PASSWORD;
  }
  Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
  String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
  Http http = new Http();
  HttpRequest req = new HttpRequest();
  req.setmethod('POST');
  req.setHeader('Authorization', authorizationHeader);
  req.setHeader('Content-Type', 'application/json');
  req.setTimeout(60000);
  if (UserInfo.getOrganizationId() == '00D300000006urqEAA') {
   //this is production
   req.setendpoint(System.Label.DP_API_PP_PROD);
  } else {
   //this is for Sandbox
   req.setendpoint(System.Label.DP_API_PP_SB);
  }

  req.setBody(RequestData);

  HttpResponse res = new HttpResponse();
  try {
   res = http.send(req);
  } catch (Exception ex) {}
  String statusis = res.getBody();
  if (res.getStatusCode() !=200) {
   DateTime n = datetime.now().addSeconds(5);
   String cron = '';

   cron += n.second();
   cron += ' ' + n.minute();
   cron += ' ' + n.hour();
   cron += ' ' + n.day();
   cron += ' ' + n.month();
   cron += ' ' + '?';
   cron += ' ' + n.year();


   System.schedule(datetime.now() + ' ' + PassedRecId, cron, new PartnerPortalProfilingserviceIntg_Sch(RequestData, PassedRecId));


  }

 }


}
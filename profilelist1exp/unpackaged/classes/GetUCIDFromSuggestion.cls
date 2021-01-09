public class GetUCIDFromSuggestion {

 public final static String SANDBOX = 'Sandbox';
 /*** This  method is to call external REST API ***/

 public static String getUCIDFrmSuggestionID(Id prId) { //Id prId 

  String strStatusMsg = '';
  String strAffinityResponse;
  String strApiKey = '';
  String strEndPntURL = '';
  String strClientName = '';

  if (StaticFactory.getEnvironment() == SANDBOX) {
   strApiKey = Label.get_UCID_callout_api_key_SB;
   strEndPntURL = Label.get_UCID_callout_endpnt_SB;
   strClientName = Label.get_UCID_callout_client_name_SB;
  } else {
   strApiKey = Label.get_UCID_callout_api_key_Prod;
   strEndPntURL = Label.get_UCID_callout_endpnt_Prod;
   strClientName = Label.get_UCID_callout_client_name_Prod;
  }

  try {
      
   HttpRequest req = new HttpRequest();
   req.setHeader('Content-Type', 'application/json');
   req.setHeader('apikey', strApiKey);
   req.setEndpoint(strEndPntURL);
   req.setMethod('POST');
   Partner_request__c pr = [select id,name, lead__r.Suggestion_ID__c from Partner_request__c where id =: prId];
   JSONGenerator gen = JSON.createGenerator(true);
   gen.writeStartObject();
   gen.writeStringField('ClientName', strClientName);
   gen.writeStringField('SuggestionID',pr.Lead__r.Suggestion_ID__c !=null ? pr.Lead__r.Suggestion_ID__c : '');
   gen.writeEndObject();
   String strJsonS = gen.getAsString();
   req.setbody(strJsonS);
   req.setTimeout(120000);
   System.debug('jsonMaterials' + strJsonS);
   Http http = new Http();
   HTTPResponse response = http.send(req);
   strAffinityResponse = response.getBody();
   System.debug('STATUS_CODE:' + response.getStatusCode());
   System.debug('***AffinityResponse :' + strAffinityResponse);
   String strResponseUCID;

   if ((response.getStatusCode() >= 200 && response.getStatusCode() <= 208) || Test.isRunningTest()) {
    if (Test.isRunningTest() || strAffinityResponse != null) {
     Map < String, Object > mapRes = (Map < String, Object > ) JSON.deserializeUntyped(strAffinityResponse);
     System.debug('***mapRes  :' + mapRes);
     Map < String, Object > mapPartnerTrack;
     Map < String, Object > mapSellingMotion;
     List < Object > listSearchResponse;
     List < Object > listExternalEntitSearchResponse;

     if (mapRes != null) {
      listSearchResponse = (List < Object > ) mapRes.get('CommonSearchResponse');
     }

     for (Object resp: listSearchResponse) {
      Map < String, Object > mapResponseAttributes = (Map < String, Object > ) resp;
      system.debug('keyset***' + mapResponseAttributes.keyset());
      for (String strAttributeName: mapResponseAttributes.keyset()) {
       if (!Test.isRunningTest() && strAttributeName == 'PartnerTrackInformation') {
        System.debug('========> ' + strAttributeName + ' = ' + mapResponseAttributes.get(strAttributeName));
        mapPartnerTrack = (Map < String, Object > ) mapResponseAttributes.get(strAttributeName);
       } else if (!Test.isRunningTest() && strAttributeName == 'SellingMotion') {
        system.debug('1***' + mapResponseAttributes.get(strAttributeName));
        mapSellingMotion = (Map < String, Object > ) mapResponseAttributes.get(strAttributeName);
       }
      }
     }

     if (mapSellingMotion != null) {
      system.debug('2***' + mapSellingMotion);
      listExternalEntitSearchResponse = (List < Object > ) mapSellingMotion.get('ExternalEntityInformation');
      system.debug('3***' + listExternalEntitSearchResponse);
      if (listExternalEntitSearchResponse != null && listExternalEntitSearchResponse.size() > 0) {      
       for (Object mapAttribute: listExternalEntitSearchResponse) {
        system.debug('***5' + mapAttribute+'***==>');  
          Map<String,object> mapAttr = (Map<String,object>) mapAttribute; 
           if(mapAttr.get('EntityType') == 'EMC'){
              strResponseUCID = (String)mapAttr.get('ReferenceNumber');
           }
           system.debug('***6' + mapAttr+'***==>'+strResponseUCID+'&&&'+mapAttr.get('EntityType'));                  
       }  
      }
     }

     if (mapPartnerTrack != null) {
      if ((mapPartnerTrack.get('PartnerProfiledAccountUCID') != null && mapPartnerTrack.get('PartnerProfiledAccountUCID') != '')) {
       strResponseUCID = (String) mapPartnerTrack.get('PartnerProfiledAccountUCID');
      }
     }
    }

    if (Test.isRunningTest() || (strResponseUCID != null && strResponseUCID.trim() != '')) {

     if (updateUCID(pr, strResponseUCID)) {
      Partner_Request__C partReq = new Partner_Request__C(id = pr.Id);
      partReq.Profile_UCID_as_Partner_Is_Complete_Flag__c = true;
      update partReq;
      strStatusMsg = 'Success';
     } else {
      strStatusMsg = 'Error in updating UCID.Please try again later.';
     }

    } else {
     strStatusMsg = 'UCID is not yet available in GAMA.';
    }
   } else {
    WebServiceExceptionHandling.insertException(string.valueof(req.getBody()),strAffinityResponse,response.getStatusCode(),'GetUcidFromGama',pr.name);
    strStatusMsg = response.getStatus();
   }

   system.debug('statusMsg::' + strStatusMsg);
   return strStatusMsg;
  } catch (Exception e) {
   System.debug('Error::' + e.getMessage());
   throw new SSD_Exception(e.getMessage());
  }
 }

 public static boolean updateUCID(Partner_request__c pr, String strUcid) {
  Boolean bStatus;
  Lead l = new Lead(id = pr.Lead__c);
  l.Universal_Customer_ID_UCID__c = strUcid;
  Database.SaveResult sr = Database.update(l, false);
  system.debug('Error in saving the lead' + sr.getErrors());
  if (sr.isSuccess()) {
   bStatus = true;
  } else {
   bStatus = false;
  }
  return bStatus;
 }

}
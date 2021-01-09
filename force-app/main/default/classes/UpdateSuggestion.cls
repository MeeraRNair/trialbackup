/*
* @Author      : Prasanthi.M
* Purpose      : To update PPAUCID and otherInfo to SuggestionAPI 
* Created Date : 17/1/2019
*/
public class UpdateSuggestion { 
    public static String invokeUpdateSuggestion(Id prId){
        final String SANDBOX = 'Sandbox';
        String apiKey;
        String endPoint;
        String statusMsg = '';
        String response;
        try{
            if (StaticFactory.getEnvironment() == SANDBOX) {
                apiKey = System.Label.PartnerUpdate_SandBox_APIKey;
                endPoint = System.Label.PartnerUpdate_SandBox_Endpoint;
            }
            else{
                apiKey = System.Label.PartnerUpdate_Production_APIKey;
                endPoint = System.Label.PartnerUpdate_Production_Endpoint;
            }
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type','application/json');
            req.setHeader('apikey', System.Label.PartnerUpdate_SandBox_APIKey);
            req.setEndpoint(System.Label.PartnerUpdate_SandBox_Endpoint);
            req.setMethod('POST');
            
            Partner_request__c pr = [select id,name,lead__r.MUP_Company_Profile_ID__c,lead__r.Suggestion_ID__c,lead__r.Partner_Master_Grouping_id__c,lead__r.Partner_Grouping_id__c,lead__r.PPA_UCID__c from Partner_request__c where id=:prId];
            system.debug('1');
            JSONGenerator generator = JSON.createGenerator(true);
            system.debug('2');
            generator.writeStartObject();
            system.debug('3');
            if(pr.lead__r.Suggestion_ID__c != null){
                system.debug('4');
                generator.writeStringField('SuggestionID',pr.lead__r.Suggestion_ID__c);
            }
            if(pr.lead__r.Partner_Master_Grouping_id__c != null){
                generator.writeStringField('PartnerMasterGroupingID',pr.lead__r.Partner_Master_Grouping_id__c);
            }
            if(pr.lead__r.Partner_Grouping_id__c != null){
                generator.writeStringField('PartnerGroupingID',pr.lead__r.Partner_Grouping_id__c);
            }
            if(pr.lead__r.PPA_UCID__c  != null){ 
                generator.writeStringField('PartnerProfiledAccountUCID',pr.lead__r.PPA_UCID__c);
            }
            if(pr.lead__r.MUP_Company_Profile_ID__c != null){
                generator.writeStringField('MUPCompanyProfileID',pr.lead__r.MUP_Company_Profile_ID__c);
            }
            generator.writeStringField('ErrorText', '');
            generator.writeStringField('ClientName', 'SFDC');
            generator.writeEndObject();
            String jsonString = generator.getAsString();
            system.debug('Request'+jsonString);
            req.setBody(jsonString);
            req.setTimeout(120000);
            system.debug('Request Body'+req);
            Http http = new Http();
            HttpResponse res = http.send(req);
            response = res.getBody();
            System.debug('Initial Response:'+res);
            System.debug('Response:'+response);
            System.debug('STATUS_CODE:'+res.getStatus());
            //Based on the conditions need to return proper status message
            //statusMsg = 'Success';
            if(response!=null && res.getStatusCode()==200){
                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response); 
                Integer sugId;
                String err;
                if(resMap!=null){
                    sugId =(Integer)resMap.get('SuggestionID');
                    err = (String)resMap.get('Error');
                    if(sugId==0 && err!=null){
                        statusMsg = err;
                    }else{
                        statusMsg = 'Success';
                        Partner_Request__C partnerReq= new Partner_Request__C(id=pr.Id); 
                        partnerReq.Update_Account_In_GAMA_Is_Complete_Flag__c = true;
                        update partnerReq;
                    }
                }
                else{
                    statusMsg = 'Result could not be Processed';
                }
            }else{
                WebServiceExceptionHandling.insertException(string.valueof(req), res.getBody(), res.getStatusCode(), 'UpdateGamaSuggestion', pr.name);
                statusMsg = 'Result could not be Processed';
            }
        }catch(Exception e){
            statusMsg=e.getMessage();
            system.debug('Exception is'+e);
        }
        return statusMsg;
    }
    
    public Static String returnAccessTokenToUpdateSuggestion () {
        String straccessToken;
        try{   
            String strclientId; 
            String strclientSecret;  
            String strdomurl;
            if (StaticFactory.getEnvironment() == 'SANDBOX') {
                strclientId     =   System.Label.ClientID_UpdateSuggetsion_Sandbox;
                strclientSecret =   System.Label.ClientSecret_UpdateSuggetsion_Sandbox;
                strdomurl       =   System.Label.Domainurl_updatesuggetsion_Sandbox;
            }else{
                strclientId     =    System.Label.ClientID_UpdateSuggetsion_Prod;
                strclientSecret =    System.Label.ClientSecret_UpdateSuggetsion_Prod;
                strdomurl       =    System.Label.Domainurl_UpdateSuggetsion_Prod;
            }
            
            String strreqbody =   'grant_type=client_credentials&client_id='+strclientId+'&client_secret='+strclientSecret;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setBody(strreqbody);
            request.setTimeout(120000);
            request.setMethod('POST');
            request.setEndpoint(strdomurl); 
            HttpResponse response = http.send(request);
            Map<String, Object > mapresults = (Map<String, Object >) JSON.deserializeUntyped(response.getBody());
            straccessToken = (String) mapresults.get('access_token');
        }
        catch(Exception e){}
        return straccessToken;      
    }
    
    
    
    public static string updateGamaSuggestionWhenLinkToAccountisUsed(Id strprId){
        system.debug('***PRID' +strprId);
        String strStatusMsg;
        try{ 
            string strendPointURL = System.Label.EndPointURL_UpdateSuggetsion;
            string straccessToken = UpdateSuggestion.returnAccessTokenToUpdateSuggestion();
            system.debug('***AccessToken' +straccessToken);
            if(straccessToken!=null || (Test.isRunningTest()) ) {
                Partner_request__c pr = [select id,name,Account__r.Account_ID__c,Account__r.Partner_Track__r.Partner_Track_AffinityId__c,Account__r.Master_Group_Id__r.Master_Group_Affinity_ID__c,
                                         lead__c,lead__r.Master_Group_Affinity_ID__c,lead__r.Partner_Track_Affinity_ID__c,lead__r.Partner_Master_Grouping_id__c,
                                         lead__r.Partner_Grouping_id__c,lead__r.PPA_UCID__c,lead__r.MUP_Company_Profile_ID__c,EMC_Attributes_Flag__c,Org_Country__r.Region__c
                                         from Partner_request__c where id=:strprId];
                
                User currentUser = [SELECT Id, Badge_Number__c, FirstName, LastName, Email,HR_Location_Country_Desc__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1][0];
                String strregionVal;
                if(pr.Org_Country__r.Region__c!=Null){
                    strregionVal = AccountSuggestionIntegrationCIL.mapregion.get(pr.Org_Country__r.Region__c); 
                }
                HttpRequest req = new HttpRequest();
                req.setHeader('Authorization','Bearer '+straccessToken);
                req.setHeader('Content-Type','application/json'); 
                req.setHeader('x-dell-dais-sa-subscriber-id', System.Label.APIKey_UpdateSuggestion);
                req.setHeader('client-app-name','SFDC');
                req.setEndpoint(strendPointURL);
                req.setMethod('POST');
                req.setTimeout(120000);
                JSONGenerator generator = JSON.createGenerator(true);
                generator.writeStartObject();
                
                If(pr.EMC_Attributes_Flag__c == true){
                    generator.writeNumberField('PartnerTrackID',Long.valueOf(pr.Account__r.Partner_Track__r.Partner_Track_AffinityId__c !=null ? (pr.Account__r.Partner_Track__r.Partner_Track_AffinityId__c.replace(',','')) :''));
                    generator.writeNumberField('MasterGroupID', Integer.valueOf(0));
                    generator.writeStringField('PartnerMasterGroupingID','');
                    generator.writeStringField('PartnerGroupingId','');
                    generator.writeStringField('PartnerProfiledAccountUCID','');
                    generator.writeStringField('MUPCompanyProfileID','');
                    generator.writeNumberField('AccountId',Integer.valueOf(0)); 
                }else{
                    generator.writeNumberField('MasterGroupID', Long.valueOf(pr.Account__r.Master_Group_Id__r.Master_Group_Affinity_ID__c !=null ? (pr.Account__r.Master_Group_Id__r.Master_Group_Affinity_ID__c.replace(',',''))  : ''));
                    generator.writeNumberField('PartnerTrackID',Long.valueOf(pr.Account__r.Partner_Track__r.Partner_Track_AffinityId__c !=null ? (pr.Account__r.Partner_Track__r.Partner_Track_AffinityId__c.replace(',','')) : ''));
                    generator.writeStringField('PartnerMasterGroupingID',pr.lead__r.Partner_Master_Grouping_id__c !=null ? pr.lead__r.Partner_Master_Grouping_id__c : '');
                    generator.writeStringField('PartnerGroupingId',pr.lead__r.Partner_Grouping_id__c !=null ? pr.lead__r.Partner_Grouping_id__c : '');
                    generator.writeStringField('PartnerProfiledAccountUCID',pr.lead__r.PPA_UCID__c !=null ? pr.lead__r.PPA_UCID__c : '');
                    generator.writeStringField('MUPCompanyProfileID',pr.lead__r.MUP_Company_Profile_ID__c !=null ? pr.lead__r.MUP_Company_Profile_ID__c : '');
                    generator.writeNumberField('AccountId',Long.valueOf(pr.Account__r.Account_ID__c !=null ? (pr.Account__r.Account_ID__c.replace(',','')) : '')); 
                    
                }
                
                generator.writeStringField('PartnerRegistrationNumber',pr.Name);
                generator.writeFieldName('SuggestionInformation');      
                generator.writeStartObject();
                generator.writeStringField('CreatedByModule','SFDC'); 
                generator.writeStringField('SuggestionReason','Information_Change'); 
                generator.writeStringField('SuggestionComments','SFDC Update'); 
                generator.writeNumberField('BadgeNumber',Integer.valueOf(currentUser.Badge_Number__c)); 
                generator.writeStringField('Region',strregionVal !=null ? strregionVal :'');
                generator.writeEndObject();
                generator.writeEndObject();  
                String strJson = generator.getAsString();
                req.setBody(strJson);
                Http http = new Http();
                HttpResponse response = http.send(req);
                system.debug('****response' +strJson);
                system.debug('****response' +req);
                
                if(response!=null && response.getStatusCode()==200){
                    Map<String, Object> mapReponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody()); 
                    Integer intsugId;
                    String strError;
                    intsugId =(Integer)mapReponse.get('SuggestionID');
                    strError = (String)mapReponse.get('Error');
                    if(intsugId==0 && strError!=null){
                        strStatusMsg = strError;
                    }else{
                        strStatusMsg = 'Success';
                        Partner_Request__C partnerReq= new Partner_Request__C(id=pr.Id); 
                        partnerReq.Update_Account_In_GAMA_Is_Complete_Flag__c = true;
                        partnerReq.Link_to_Account_Record_Is_Complete_Flag__c = true;
                        partnerReq.Status__c = 'Account Suggestion Completed';
                        update partnerReq;
                    }
                    
                }else{
                    WebServiceExceptionHandling.insertException(string.valueof(req), response.getBody(), response.getStatusCode(), 'UpdateGamaSuggestion', pr.name);
                    strStatusMsg =  +response.getStatus() +', AND ' + 'Status Code is :' +response.getStatusCode();
                }
            }
        }catch(Exception e){
            strStatusMsg=e.getMessage();
            system.debug('Exception is'+e);
        }
        return strStatusMsg;
    }
    
    
}
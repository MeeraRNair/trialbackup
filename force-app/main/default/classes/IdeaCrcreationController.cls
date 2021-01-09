/**********************************************************************************************
 * Name         : IdeaCrcreationController
 * Description  : IdeaCrcreationController
 * Created      : 
 * Created By   : 
 ***********************************************************************************************
 * Revision History:
  Version    Release    CR         Name        Description
 *---------------------------------------------------------------------------------------------
 * 1.0       R16.03     10828      Devika      Update to get values from idea intake instead of 
                                               account storm
 **********************************************************************************************/
public class IdeaCrcreationController {
       
    public static PageReference ideaCrcreationmethod() {
     
      Id powerUser = [SELECT Id FROM PermissionSet WHERE Name =: 'Idea_Power_User'].Id;      
      Set<Id> userPermissionSet = new Set<Id>();
      for(PermissionSetAssignment permSetList : [SELECT PermissionSetId FROM PermissionSetAssignment 
                                                        WHERE AssigneeId =: UserInfo.getUserId()]){
        userPermissionSet.add(permSetList.PermissionSetId );
      }
      
      if(userPermissionSet.contains(powerUser)){
      
        Idea_Intake__c ideaRecord= [select Id,Business_Objective__c,Business_Justification__c,Name,Original_Requester__r.Name,TT__c,
                                           PMO_CR__c,CR_Status__c,Requesting_region__c,Regions_Impacted__c,
                                           TFS_ID__c
                                           From Idea_Intake__c Where id=: Apexpages.Currentpage().getparameters().get('id')];
        PageReference ideaPage = new PageReference('/'+ideaRecord.Id);
        
        if(ideaRecord.PMO_CR__c == null){

         Id recordId;         
         String serverUrl,sessionId;                
         String crNo,crStatus;
         String requestBody;           
         
         String accountlink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ideaRecord.Id;         
         String requestor = ideaRecord.Original_Requester__c != null ? ideaRecord.Original_Requester__r.name : UserInfo.getName();
         String description = ideaRecord.Business_Objective__c != null ? ideaRecord.Business_Objective__c.replaceAll('(</{0,1}[^>]+>)', ' ') : '';        
         String CRreason =  ideaRecord.Business_Justification__c != null ? ideaRecord.Business_Justification__c.replaceAll('(</{0,1}[^>]+>)', ' ') : '';           
         String requestingRegion = ideaRecord.Business_Justification__c != null ? ideaRecord.Requesting_region__c : '';                         
         String regionsImpacted = ideaRecord.Regions_Impacted__c != null ?ideaRecord.Regions_Impacted__c : '';
         String TTNo = ideaRecord.TT__c != null ? ideaRecord.TT__c : '';
         String tfsId = ideaRecord.TFS_ID__c != null ? ideaRecord.TFS_ID__c : '';
              
          //Login Request
          Http h = new Http();
          HttpRequest req = new HttpRequest();
          HttpResponse res = new HttpResponse();
          req.setMethod('POST');
          req.setEndPoint(Label.PIMPSessionURL); 
          req.setHeader('Content-type','text/xml');
          req.setHeader('SoapAction','<se:Header xmlns:sfns=\'partner.soap.sforce.com\'><sfns:CallOptions><sfns:client></sfns:client></sfns:CallOptions><sfns:SessionHeader><sessionId></sessionId></sfns:SessionHeader></se:Header>');
          req.setBody('<se:Envelope xmlns:sfdc=\'urn:enterprise.soap.sforce.com\' xmlns:se=\'http://schemas.xmlsoap.org/soap/envelope/\'><se:Body><login xmlns=\'urn:partner.soap.sforce.com\' xmlns:ns1=\'sobject.partner.soap.sforce.com\'><username>'+Label.DellPimpUsername+'</username><password>'+Label.DellPimpIntegrationPassword+'</password></login></se:Body></se:Envelope>');         
          res = h.send(req);          
         system.debug('*****'+res.getbody());
          
          //Login Parse
          XmlStreamReader reader = res.getXmlStreamReader();
          while(reader.hasNext()){                
              if ( reader.getEventType()== XmlTag.START_ELEMENT){
                if(reader.getLocalName() =='serverUrl'){
                  reader.next(); 
                  serverUrl = reader.gettext();
                }else if(reader.getLocalName() =='sessionId'){
                  reader.next(); 
                  sessionId =reader.gettext(); 
                }  
              }
              reader.next();
         }
               
         
         
         requestBody ='<se:Envelope xmlns:sfdc=\'urn:partner.soap.sforce.com\' xmlns:se=\'http://schemas.xmlsoap.org/soap/envelope/\'>><se:Header><SessionHeader xmlns=\'urn:partner.soap.sforce.com\'><sessionId>';
         requestBody += sessionId+'</sessionId></SessionHeader></se:Header><se:Body><create xmlns=\'urn:partner.soap.sforce.com\'><sObjects><type xmlns=\'sobject.partner.soap.sforce.com\'>Dell_Change_Request__c</type><recordtypeid>';
         requestBody += Label.DellChangeRequestRecordtypeid+'</recordtypeid><Request_Title__c>'+ideaRecord.Name+'</Request_Title__c><Requestor__c>'+requestor+'</Requestor__c><Request_Description__c>'+description;
         requestBody += '</Request_Description__c><Request_Type__c>Salesforce</Request_Type__c><Development_Type__c>Configuration</Development_Type__c><Requesting_Region__c>'+requestingRegion+'</Requesting_Region__c>';
         requestBody += '<Business_Segment_Requesting__c>All Segments</Business_Segment_Requesting__c><Impacted_GEOs__c>'+regionsImpacted+'</Impacted_GEOs__c><Status__c>Identify: Submit for Global SME Review</Status__c>';
         requestBody += '<Created_from_AccountStorm__c>true</Created_from_AccountStorm__c><Capacity_Type__c>Sustaining Change</Capacity_Type__c><AccountStorm_Link__c>'+accountlink+'</AccountStorm_Link__c><Business_Case_ROI__c>';
         requestBody += CRreason+'</Business_Case_ROI__c><TT__c>'+TTNo+'</TT__c><TFS_Work_Item_ID__c>'+tfsId+'</TFS_Work_Item_ID__c><Project_Overview__c>'+Label.DellChangeRequestProjectOverwiew+'</Project_Overview__c></sObjects></create></se:Body></se:Envelope>';
        
         Http h1 = new Http();
         HttpRequest req1 = new HttpRequest();
         HttpResponse res1 = new HttpResponse();
         req1.setMethod('POST');
         req1.setEndPoint(serverUrl); 
         req1.setHeader('Content-type','text/xml');
         req1.setHeader('SoapAction','<soapenv:Envelope xmlns:soapenv=\'http://schemas.xmlsoap.org/soap/envelope/\' xmlns:urn=\'urn:partner.soap.sforce.com\' xmlns:urn1=\'urn:sobject.partner.soap.sforce.com\'><soapenv:Header><urn:SessionHeader><urn:sessionId>'+sessionId+'</urn:sessionId><urn:CallOptions></urn:CallOptions></soapenv:Header></soapenv:Envelope>');
         req1.setBody(requestBody);          
         res1 = h1.send(req1);
         system.debug('*****'+res1.getbody());

         XmlStreamReader reader1 = res1.getXmlStreamReader();
         while(reader1.hasNext()) {                       
             if(reader1.getEventType()== XmlTag.START_ELEMENT){
               if(reader1.getLocalName() =='id'){
                 reader1.next();
                 recordId = reader1.gettext();
               }         
            }  
            reader1.next();
        }
     
        Http h2 = new Http();
        HttpRequest req2 = new HttpRequest();
        HttpResponse res2 = new HttpResponse();
        req2.setMethod('GET');
        req2.setEndPoint(serverUrl); 
        req2.setHeader('Content-type','text/xml');
        req2.setHeader('SoapAction','<soapenv:Envelope xmlns:soapenv=\'http://schemas.xmlsoap.org/soap/envelope/\' xmlns:urn=\'urn:partner.soap.sforce.com\' xmlns:urn1=\'urn:sobject.partner.soap.sforce.com\'><soapenv:Header><urn:SessionHeader><urn:sessionId>'+sessionId+'</urn:sessionId><urn:CallOptions></urn:CallOptions></soapenv:Header></soapenv:Envelope>');
        req2.setBody('<soap:Envelope xmlns:soap=\'http://schemas.xmlsoap.org/soap/envelope/\' xmlns:xsi=\'http://www.w3.org/2001/XMLSchema-instance\' xmlns:xsd=\'http://www.w3.org/2001/XMLSchema\'><soap:Header><QueryOptions xmlns=\'urn:partner.soap.sforce.com\'><batchSize>3</batchSize></QueryOptions><SessionHeader xmlns=\'urn:partner.soap.sforce.com\'><sessionId>'+sessionId+'</sessionId></SessionHeader></soap:Header><soap:Body><query xmlns=\'urn:partner.soap.sforce.com\'><queryString>SELECT Name,Status__c FROM Dell_Change_Request__c WHERE id =\'' +recordId  + '\'  LIMIT 1</queryString></query></soap:Body></soap:Envelope>');          
        res2 = h2.send(req2);
        system.debug('*****'+res1.getbody());
        
        XmlStreamReader reader2 = res2.getXmlStreamReader();
        while(reader2.hasNext()) {                                       
            if ( reader2.getEventType()== XmlTag.START_ELEMENT){
              if(reader2.getLocalName() =='Name'){
                reader2.next();
                crNo =reader2.gettext();             
              }else if(reader2.getLocalName() =='status__c'){
                reader2.next();
                crStatus=reader2.gettext(); 
              }   
            }
            reader2.next();
        } 
        
        ideaRecord.CR_Status__c =crStatus;
        ideaRecord.PMO_CR__c =crNo;
        update ideaRecord;    
        return ideaPage;
      }else{
        return ideaPage;      
      }
    }else{
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, '<b>Insufficient Privileges</b>'+'<br/>'+'You do not have the level of access you requested.Please contact the owner of the record or administrator if access is necessary.');
      ApexPages.addmessage(myMsg);
      return null;
    }
  }
}
/**********************************************************************************************
 * Name         : Batch_UpdateStatusOnIdeaIntake
 * Description  : Make an Rest API callout to Dell PMO to get Status for all Idea records.
 * Created      : 14-01-2015
 * Created By   : Devika Pujari

 ***********************************************************************************************
 * 
 **********************************************************************************************/
global class Batch_UpdateStatusOnIdeaIntake implements Database.Batchable<sObject>,Database.AllowsCallouts{

   
    global Database.QueryLocator start(Database.BatchableContext bc){
            
      return Database.getQueryLocator([Select Id,CR_Status__c,PMO_CR__c From Idea_Intake__c 
                                        Where PMO_CR__c != null ]);
    }

    global void execute(Database.BatchableContext BC,List<Idea_Intake__c> ideaRecordList){
      
      Map<String,List<Idea_Intake__c>> ideaId2RecordMap  = new Map<String,List<Idea_Intake__c>>();
      List<Idea_Intake__c>ideaUpdateList = new List<Idea_Intake__c>();
      
      for(Idea_Intake__c ideaRecord : ideaRecordList){     
        if(!ideaId2RecordMap.containsKey(ideaRecord.PMO_CR__c)){
          ideaId2RecordMap.put(ideaRecord.PMO_CR__c,new List<Idea_Intake__c>{ideaRecord});
        }else{
          List<Idea_Intake__c> ideaList = ideaId2RecordMap.get(ideaRecord.PMO_CR__c);
          ideaList.add(ideaRecord);
          ideaId2RecordMap.put(ideaRecord.PMO_CR__c,ideaList);
        }  
      }  
             
      String serverUrl,sessionId;
      Http h = new Http();
      HttpRequest req = new HttpRequest();
      HttpResponse res = new HttpResponse();
      req.setMethod('POST');
      req.setEndPoint(Label.PIMPSessionURL); 
      req.setHeader('Content-type','text/xml');
      req.setHeader('SoapAction','<se:Header xmlns:sfns=\'partner.soap.sforce.com\'><sfns:CallOptions><sfns:client></sfns:client></sfns:CallOptions><sfns:SessionHeader><sessionId></sessionId></sfns:SessionHeader></se:Header>');
      req.setBody('<se:Envelope xmlns:sfdc=\'urn:enterprise.soap.sforce.com\' xmlns:se=\'http://schemas.xmlsoap.org/soap/envelope/\'><se:Body><login xmlns=\'urn:partner.soap.sforce.com\' xmlns:ns1=\'sobject.partner.soap.sforce.com\'><username>'+Label.DellPimpUsername+'</username><password>'+Label.DellPimpIntegrationPassword+'</password></login></se:Body></se:Envelope>');      
      res = h.send(req);      
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
      
      for(String ideaPMOName :ideaId2RecordMap.keyset()){
        Http h2 = new Http();
        HttpRequest req2 = new HttpRequest();
        HttpResponse res2 = new HttpResponse();
        req2.setMethod('GET');
        req2.setEndPoint(serverUrl); 
        req2.setHeader('Content-type','text/xml');
        req2.setHeader('SoapAction','<soapenv:Envelope xmlns:soapenv=\'http://schemas.xmlsoap.org/soap/envelope/\' xmlns:urn=\'urn:partner.soap.sforce.com\' xmlns:urn1=\'urn:sobject.partner.soap.sforce.com\'><soapenv:Header><urn:SessionHeader><urn:sessionId>'+sessionId+'</urn:sessionId><urn:CallOptions></urn:CallOptions></soapenv:Header></soapenv:Envelope>');
        req2.setBody('<soap:Envelope xmlns:soap=\'http://schemas.xmlsoap.org/soap/envelope/\' xmlns:xsi=\'http://www.w3.org/2001/XMLSchema-instance\' xmlns:xsd=\'http://www.w3.org/2001/XMLSchema\'><soap:Header><QueryOptions xmlns=\'urn:partner.soap.sforce.com\'><batchSize>3</batchSize></QueryOptions><SessionHeader xmlns=\'urn:partner.soap.sforce.com\'><sessionId>'+sessionId+'</sessionId></SessionHeader></soap:Header><soap:Body><query xmlns=\'urn:partner.soap.sforce.com\'><queryString>SELECT Status__c FROM Dell_Change_Request__c WHERE Name  =\'' +ideaPMOName+ '\' </queryString></query></soap:Body></soap:Envelope>');  
        res2 = h2.send(req2);
        
        XmlStreamReader reader2 = res2.getXmlStreamReader();        
        Integer k=0;
        String crStatus;
        while(reader2.hasNext()) {                                       
            if ( reader2.getEventType()== XmlTag.START_ELEMENT){
              if(reader2.getLocalName() =='status__c'){
                reader2.next();
                crStatus=reader2.gettext(); 
              }   
            }
            reader2.next();
        }  

        for(Idea_Intake__c ideaRecord: ideaId2RecordMap.get(ideaPMOName)){
          if(ideaRecord.CR_Status__c != crStatus){
            ideaRecord.CR_Status__c = crStatus;
            ideaUpdateList.add(ideaRecord);
          }
        }         
      }      
      if(ideaUpdateList.size() >0){
        update ideaUpdateList; 
      }  

    }
    global void finish(Database.BatchableContext BC){
       
    }
}
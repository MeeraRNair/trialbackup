/*
* Version   Date            Author     Release     		CR#      	Description
* -------   ----            ------     -------     		---      	-----------
* 1.0       19-Oct-2015     Fenny      CSM1102     		12076    	Redesign the SFDC - MyDeal integration via Boomi to make it real time
* 2.0       15-Sep-2016     Jaya       1007        		US#2382050  Made SOAPAction 'getGSD_Request' name retrieve from custom label. 
* 3.0       08-Nov-2017     Krishna    0203        		15108       PSA006 - Files to myDeal - create logic
* 3.1		09-Jan-2018		Gan		   FY19-DCS-0203	15372		To get field data from oppty that are not referenceable from Support Req
*/

//** CODE COVERAGE FOR THIS CLASS WILL BE HANDLED BY MyDealFileIntegrationTest and afterInsertUpdateSupportRequestTest.integrateMyDealTest **//
public class SuppReqMyDealIntegration{
    private static string ENDPOINT;
    private static string USERNAME;
    private static string PASSWORD;
     
    private static Support_Request__c suppReq;
    private static HttpRequest request;
    private static HttpResponse response;
    private static Map<String, Schema.SObjectField> srFieldMap;
    
    private static string soapenvUri = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static string wssUri = 'http://www.boomi.com/connector/wss';
    
    public static  boolean AUTHENTICATIONREQUIRED = true;
    public static final Integer TIMEOUT = 120000; // May need to check with BOOMI the timeout ms
    private static Set<string> mappedFields = null;
    
    public static boolean REQUIRE_CALLOUT = true;
    
    public string ResponseMessage;
    //3.0
    private static Map<id,Set<ContentDocumentLink>> mapOpptyFiles;
    private static Map<id,Set<ContentDocumentLink>> mapSRFileSet;

    //3.1
    private static map<id, opportunity> mapOppty;
    private static Set<string> mappedOpptyFields = null;
	private static Map<String, Schema.SObjectField> mapOpptySchema;
    
    private static void constructHttpRequestHeader(){
        try{
            request = new HttpRequest();
            //Set endpoint URL      
            request.setEndpoint(ENDPOINT);
            
            request.setHeader('content-type', 'text/xml;charset=UTF-8');        
            request.setHeader('SOAPAction',System.Label.BOOMI_MyDeal_Endpoint_getGSD_Request);        
             
            //Set the method Type
            request.setMethod('POST');
            
            // Specify the required user name and password to access the endpoint
            // As well as the header and header information 
            if(AUTHENTICATIONREQUIRED){ 
                Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                request.setHeader('Authorization', authorizationHeader);
            }
            
            //Set the timeout value for the Request
            request.setTimeout(TIMEOUT);
        }catch(Exception ex){
            throw ex;
        }
    }
    
    private static Map<String, Schema.SObjectField> suppReqFieldMap{
        get{
            if(srFieldMap == null){
                String objectName ='Support_Request__c';
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType srSchema = schemaMap.get(objectName);
                srFieldMap = srSchema.getDescribe().fields.getMap();
            }
            return srFieldMap;
        }
    }
    
    //3.1
    private static Map<String, Schema.SObjectField> opptyFieldMap{
        get{
            if(mapOpptySchema == null){
                String objectName ='Opportunity';
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType srSchema = schemaMap.get(objectName);
                mapOpptySchema = srSchema.getDescribe().fields.getMap();
            }
            return mapOpptySchema;
        }
    }
    
    private static void constructHttpRequestBody(){
        try{

            XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartElement('soapenv', 'Envelope', soapenvUri);
            w.writeNamespace('soapenv', soapenvUri);
            w.writeNamespace('wss', wssUri);
            
            //Header
            w.writeEmptyElement('soapenv','Header','');
            w.writeStartElement('soapenv', 'Body', '');
            w.writeStartElement('wss', System.Label.BOOMI_MyDeal_Endpoint_getGSD_Request, '');
            w.writeStartElement('', 'GSDSR', '');
            
            //3.1
            string strValue;
            for(string fieldName : FIELDS){
                strValue = null;
                if(suppReqFieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.DATETIME){
                    if(suppReq.get(fieldName) != null){
                        strValue = ((Datetime)suppReq.get(fieldName)).format('yyyyMMdd HHmmss.SSS', 'GMT');
                    }
                }else{
                    strValue = string.valueOf(suppReq.get(fieldName));
                }
                //w = IntegrationUtilities.addElementAndValue(w, fieldName, obj, fieldName,null, null);
                w = IntegrationUtilities.addElementAndValueString(w, fieldName, strValue, null, null);
            }
            
            //3.1
            if(mapOppty!=null && mapOppty.containsKey(suppReq.Opportunity__c)){
                opportunity objOppty = mapOppty.get(suppReq.Opportunity__c);
                for(string strFieldName : OPPTYFIELDS){
                    strValue = null;
                    if(opptyFieldMap.get(strFieldName).getDescribe().getType() == Schema.DisplayType.DATETIME){
                        if(objOppty.get(strFieldName) != null){
                            strValue = ((Datetime)objOppty.get(strFieldName)).format('yyyyMMdd HHmmss.SSS', 'GMT');
                        }
                    }else{
                        strValue = string.valueOf(objOppty.get(strFieldName));
                    }
                    
                    w = IntegrationUtilities.addElementAndValueString(w, strFieldName, strValue, null, null);
                }
            }
            // 3.0 - Populating Support Request Related Files in input request.
            w.writeStartElement('', 'SrFiles', '');
            if(mapSRFileSet.containsKey(suppReq.id)){
                for(ContentDocumentLink docLink:mapSRFileSet.get(suppReq.id)){
                    w.writeStartElement('', 'File', '');
                    w = IntegrationUtilities.addElementAndValueString(w,'Id', docLink.ContentDocumentId, null, null);
                    w = IntegrationUtilities.addElementAndValueString(w,'Name', docLink.ContentDocument.title, null, null);
                    w.writeEndElement(); // End of Files
                }
            }
            w.writeEndElement(); // End of SrFiles
            // 3.0 - Populating Opportunity Related Files in input request.
            w.writeStartElement('', 'OpportunityFiles', '');
            if(mapOpptyFiles.containsKey(suppReq.Opportunity__c)){
                for(ContentDocumentLink docLink:mapOpptyFiles.get(suppReq.Opportunity__c)){
                    w.writeStartElement('', 'File', '');
                    w = IntegrationUtilities.addElementAndValueString(w,'Id', docLink.ContentDocumentId, null, null);
                    w = IntegrationUtilities.addElementAndValueString(w,'Name', docLink.ContentDocument.title, null, null);
                    w.writeEndElement(); // End of Files
                }
            }
            w.writeEndElement(); // End 3.0 - OpportunityFiles 
            w.writeEndElement(); // End of GSDSR
            w.writeEndElement(); // End of wss:getGSD_Request
            w.writeEndElement(); // End of soapenv:Body
            w.writeEndElement(); // End of soapenv:Envelope
            
            string requestBody = w.getXmlString();
            w.close();
            
            system.debug('>>>>> HttpRequest body - ' + requestBody);
            request.setBody(requestBody);
            
        }catch(Exception ex){
            throw ex;
        }
    }

    private static string processHttpResponse(){
        string msg = '';
        XMLStreamReader reader = response.getXmlStreamReader();

        while(reader.hasNext()){
            reader.next();
            if((reader.getEventType() == XmlTag.START_ELEMENT) && (reader.getLocalName().toUpperCase() == 'MESSAGE')){
                reader.next();
                if(reader.getEventType() == XmlTag.CHARACTERS){
                    msg = reader.getText().toUpperCase();
                    break;
                }
            }
        }
        // if the http callout is successful, then msg = 'SUCCESS', else error message returned from BOOMI
        return msg;
    }

    // Return TRUE is no service call error. 
    // This returned boolean not indicating whether the transaction success/fail, but the HttpResponse does.
    private static void sendHttpRequest(Support_Request__c obj){
        try{
            suppReq = obj;
            if((suppReq != null) && (ENDPOINT != null) && (USERNAME != null) && (PASSWORD != null)){
                constructHttpRequestHeader();
                constructHttpRequestBody();
                
                Http p = new Http();
                if(Test.isRunningTest()){
                        response = new HttpResponse();
                        response.setBody('<MESSAGE>SUCCESS</MESSAGE>');
                    }else{
                        response = p.send(request);        
                    }
                
                system.debug('>>>>> HttpResponse body - ' + response.getBody());
                
                string msg = processHttpResponse();
                if(!StaticFactory.getOrgDetail().IsSandbox && ((msg == null) || (!msg.equals('SUCCESS')))){
                    string emailContent = 'Failed to integrate MyDeal, issue details below: ';
                    emailContent += 'Support Request GUID = ' + suppReq.Id + '; ';
                    emailContent += 'Response XML = ' + response.getBody();
                    emailUtils.sendSupportEmails(emailContent, new string[]{'SFDC-ApexDev@Dell.com'}); 
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    
    @future (callout=true)
    public static void integrateMyDeal(Set<Id> srSet){
        try{
            system.debug('>>>>>>>>>>>>>> CALLOUT ? - ' + REQUIRE_CALLOUT);
            string endpointDetails = StaticFactory.getOrgDetail().IsSandbox ? System.Label.BOOMI_MyDeal_Endpoint_Details_Sandbox : System.Label.BOOMI_MyDeal_Endpoint_Details_PROD;
            mapOpptyFiles = new Map<id,Set<ContentDocumentLink>>();
            mapSRFileSet = new Map<id,Set<ContentDocumentLink>>();
            system.debug(endpointDetails);
            if(endpointDetails != null){
                string[] details = endpointDetails.split('~');
                ENDPOINT = details[0];
                USERNAME = details[1];
                PASSWORD = details[2];
            }
            
            string ids = '';
            for(string id : srSet){
                ids += (ids.length()>0?',':'') + '\''+id+'\'';
            }
    
            string soql = 'SELECT '; // Construct the SOQL
            Integer i = 1;
            for(string fieldName : SuppReqMyDealIntegration.FIELDS){
                soql += fieldName + ((i == SuppReqMyDealIntegration.FIELDS.size())?'':', ');
                i++;
            }
            soql += ' FROM Support_Request__c WHERE Id IN (' + ids + ')';
            system.debug('##### soql - ' + soql);
            List<Support_Request__c> srList = Database.query(soql);
            
            //3.1 Looping and initialize fields needed for other object from SR object
            string strOpptyIds = '';
            Set<ID> setParentID = new Set<ID>();
            for(Support_Request__c objSR:srList){
                strOpptyIds += (strOpptyIds.length()>0?',':'') + '\''+objSR.Opportunity__c+'\'';
                setParentID.add(objSR.Opportunity__c);
                setParentID.add(objSR.id);            
                mapSRFileSet.put(objSR.Id,new Set<ContentDocumentLink>());
                mapOpptyFiles.put(objSR.Opportunity__c,new Set<ContentDocumentLink>());
            }
           
            //3.1
            getOpptyDetails(strOpptyIds);
            getFileDetails(srList, setParentID);
            for(Support_Request__c sr : srList){
                sendHttpRequest(sr);
            }
        }catch(Exception ex){
            system.debug('##MN: Caught APEX exception ' + ex.getMessage());
            system.debug(ex.getStackTraceString());
            if(!StaticFactory.getOrgDetail().IsSandbox){
                string emailContent = 'Failed to integrate MyDeal, issue details below: ';
                emailContent += 'Support Request GUID = ' + suppReq.Id + '; ';
                emailContent += 'Errored line of code = ' + ex.getLinenumber() + '; ';
                emailContent += 'Exception message = ' + ex.getMessage() + '; ';
                emailContent += 'Exception Stacktrace = ' + ex.getStackTraceString();
                emailUtils.sendSupportEmails(emailContent, new string[]{'SFDC-ApexDev@Dell.com'}); 
            }
        }
    }
    
    public static Set<string> FIELDS{
        get{
            if(mappedFields == null){
                mappedFields = new Set<string>(System.Label.Support_Request_Field_to_MyDeal_1.split(','));
                mappedFields.addAll(System.Label.Support_Request_Field_to_MyDeal_2.split(','));
                mappedFields.addAll(System.Label.Support_Request_Field_to_MyDeal_3.split(','));
            }
            return mappedFields;
        }
    }
    
    //3.1 to get long text area field
    public static Set<string> OPPTYFIELDS{
        get{
            if(mappedOpptyFields == null){
                mappedOpptyFields = new Set<string>(System.Label.Support_Request_OpptyField_to_MyDeal_1.split(','));
            }
            return mappedOpptyFields;
        }
    }

    //3.1
    private static void getOpptyDetails(string strOpptyIds) {
        string strSoql = 'SELECT '; // Construct the SOQL
        integer intCount = 1;
        for(string strFieldName : SuppReqMyDealIntegration.OPPTYFIELDS){
            strSoql += strFieldName + ((intCount == SuppReqMyDealIntegration.OPPTYFIELDS.size())?'':', ');
            intCount++;
        }
        strSoql += ' FROM Opportunity WHERE Id IN (' + strOpptyIds + ')';
        system.debug('##### soql - ' + strSoql);
        mapOppty = new map<id, Opportunity>((List<Opportunity>)Database.query(strSoql));    
    }
    
    //3.0 - Getting Files related to opportunity and support request.
    private static void getFileDetails(List<Support_Request__c> srList, set<ID> setParentID){       
        System.debug('Number of Files--'+setParentID.size());
        //How to map 
        for(ContentDocumentLink objDocLink:[Select ContentDocumentId, ContentDocument.title,LinkedEntityId From ContentDocumentLink where ContentDocument.LatestPublishedVersion.isLatest = TRUE and LinkedEntityId in :setParentID order by LinkedEntityId asc]){
            if(mapSRFileSet.containsKey(objDocLink.LinkedEntityId)){
                (mapSRFileSet.get(objDocLink.LinkedEntityId)).add(objDocLink);
            }else if(mapOpptyFiles.containsKey(objDocLink.LinkedEntityId)){
                (mapOpptyFiles.get(objDocLink.LinkedEntityId)).add(objDocLink);
            }          
        }
    }
}
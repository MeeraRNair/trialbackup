/*
 * Author   : Ranjit
 * Purpose  : 
 *       
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      16868       FY19-0101   19-Nov-2018     Ranjit          Initial Version
 * 2.0      17126       FY20-0204   14-Feb-2019     Sajith          INC7967167
*/

public class CPDBXmlGenerator {
    public final static string START_URL = 'http://schemas.xmlsoap.org/soap/envelope/';
    public final static string TEMNAMESPACE_URL = 'http://tempuri.org/';
    public final static string DELLNAMESPACE_URL = 'http://schemas.datacontract.org/2004/07/Dell.CMI.Core.PrimaryContact';
    public static final Integer TIMEOUT = 120000;
    public static final String METHOD = 'POST';
    public final static string START_TAG = 'dell';
    public static String endPoint;
    public final static string STATUSCODECPDB = '200';
    public final static string CREATEEXCEPTIONCPDB = 'True';
    public static User currentUser;
    public static String contactId;
    
    public static void getContactDataforCPDB(String recordid){
        
        List<Contact> cpdbContactList = [select id, Account.Account_Country_Code__c,Partner_My_Account_GUID__c,CPDB_Segment__c, CPDB_Updated_By__c from Contact 
                                         where id=:recordid AND Partner_My_Account_GUID__c!=null];
        contactId = recordid;
        String xmlBody = generateCpdbXmlrequest(cpdbContactList[0]);
        System.debug('-------Generated XML--------------- ' + xmlBody);
        cpdbPostCallout(xmlBody);
        
    }
    
    
    public static HttpResponse cpdbPostCallout(String xmlBody){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setAuthenticationInfo();
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '\"http://tempuri.org/IPrimaryContactServices/UpdatePrimaryContactWithSegment\"');
        request.setTimeout(TIMEOUT);

        //String XmlBody = generateCpdbXmlrequest(recordid);
        //System.debug('-------Generated XML--------------- ' + XmlBody);
        request.setBody(xmlBody);
        
        HttpResponse response = http.send(request);
        
         System.debug('###### CPDB Request is :'+xmlBody);
         System.debug('>>>>>>>>>>>> CPDB Response is : '+response);
         //2.0 INC7967167 Hotfix - Start
         if(!STATUSCODECPDB.contains(String.ValueOf( response.getStatusCode()))){
         //2.0 INC7967167 Hotfix - End
         try{
           if(CREATEEXCEPTIONCPDB=='True'){  
            System.debug('inserting exception');
            //if Responce we got is not success insert a record in EXCEPTION Object
            //and Attach the Request JSON STRING As Attachment to That Particular Record
            
             Exception__c exc = new Exception__c();
             exc.Process_Name__c = 'CPDB Integration';
             exc.Error_Messages__c  = String.valueOf(response.getStatusCode());
             exc.Object_type__c = 'Contact';
             exc.Object_ID__c = contactId;
             exc.Notes__c = response.getBody();
             PartnerProfileIntegration.lstException.add(exc);
             //insert exc;
            
             Attachment attachment = new Attachment();
             attachment.Body = Blob.valueOf(xmlBody);
             attachment.Name = String.valueOf(contactId+'.txt');
             PartnerProfileIntegration.lstAttachment.add(attachment);
             //attachment.ParentId = exc.id; 
             //insert attachment;
            
            }
            }catch(exception ex){
             System.debug('Failed to insert Exception');
             }
         
         }
        
        return response;  
     
    }    
    
      //authentication Method   
   private static void setAuthenticationInfo() {

      //Set endpoint parameters for Production    
        if(UserInfo.getOrganizationId() == '00D300000006urqEAA') { 
            endPoint= System.Label.CPDB_API_EP_PROD;
     
        }
        //Set endpoint parameters for Sandbox 
        else{
            endPoint= System.Label.CPDB_API_EP_SB;
            //SFDC to DP endpoint 'https://sit.apidp.dell.com/cpdb/primarycontactservice?apikey=d08a4f14-f1df-4d93-b1e9-d03d1ab5114b';
            //DP to CPDB endpoint 'http://u4vmcpssit1.aus.amer.dell.com/GUP/PrimaryContactServices.svc'
        }   
       
        
    }
    
    public static String generateCpdbXmlrequest(Contact contactRecord) {
        
        XmlStreamWriter cpdbxmlwriter = new XmlStreamWriter();
        cpdbxmlwriter.writeStartDocument('UTF-8', '1.0');
        cpdbxmlwriter.writeStartElement('soapenv', 'Envelope', START_URL);
        cpdbxmlwriter.writeNamespace('soapenv', START_URL);
        cpdbxmlwriter.writeNamespace('tem',TEMNAMESPACE_URL);
        cpdbxmlwriter.writeNamespace('dell',DELLNAMESPACE_URL);
        cpdbxmlwriter.writeEmptyElement('soapenv', 'Header', START_URL);
        cpdbxmlwriter.writeStartElement('soapenv', 'Body', START_URL);
            cpdbxmlwriter.writeStartElement('tem', 'UpdatePrimaryContactWithSegment', START_URL);
                cpdbxmlwriter.writeStartElement('tem', 'primaryContactWithSegmentRequest', START_URL);
                    cpdbxmlwriter.writeStartElement('dell', 'CountryCode', START_URL);
                        cpdbxmlwriter.writeCharacters(contactRecord.Account.Account_Country_Code__c);
                    cpdbxmlwriter.writeEndElement();
                    cpdbxmlwriter.writeStartElement('dell', 'ProfileID', START_URL);
                        cpdbxmlwriter.writeCharacters(contactRecord.Partner_My_Account_GUID__c); 
                    cpdbxmlwriter.writeEndElement();
                    cpdbxmlwriter.writeStartElement('dell', 'Segment', START_URL);
                        cpdbxmlwriter.writeCharacters('PD'); 
                    cpdbxmlwriter.writeEndElement();  
                    cpdbxmlwriter.writeStartElement('dell', 'UpdatedBy', START_URL);
                        cpdbxmlwriter.writeCharacters('SFDCApex'); 
                    cpdbxmlwriter.writeEndElement();        
                cpdbxmlwriter.writeEndElement();
            cpdbxmlwriter.writeEndElement();
        cpdbxmlwriter.writeEndElement(); 
        cpdbxmlwriter.writeEndElement();
        cpdbxmlwriter.writeEndDocument();
        String cpdbxmlOutput = cpdbxmlwriter.getXmlString();
        cpdbxmlwriter.close();
        return cpdbxmlOutput;
    }
}
/*---------------------------------------------
Description: Class to assisst the webService call to Send information to
             Partner Profile database(CR# 1389)

History:
    1.0 - 25-June-2009: Creation.
    2.0 - 17-July-2009: Raymond: Added functions for CR1616
    3.0 - 07-Dec-2009: MenMee: CR2093  
        - Partner Profile Contact Update WS 
        - Includes Need_Campaign_Builder_Access__c, Premier_Partner__c, Is_Transactional_Store__c, Has_Warranty_parts_Info__c
        - Remove Partner_Application_Access__c
    4.0 - 16-Dec-2009: MenMee: CR2094
        - Partner Profile Contact Update WS: include Is_Admin_for_Partner_Finder_Profile__c
        - Partner Profile Account Update WS: include Account.Approved_for_Partner_Finder__c 
    5.0 - 31-Dec-2009: Ray: Modified for CR2186. Will now handle contacts without querying user record
    6.0 - 20-01-2010: MenMee: API name changed
    7.0 - 02-02-2010: Ray: Fix for defect #55487. Restructured the codes to have non-@future version of methods, with response.
                           NOTE: Only code for Contacts are modified. Account callout doesn't support response
    8.0 - 05-03-2010: Ray: Added condition to filter contacts with empty Partner My Account GUID when querying COntact
    9.0 - 10-03-2010: Krishna: Added updateKey functionality for CR 2431
   10.0 - 30-04-2010: Men Mee: CR2568  
   11.0 - 09-07-2010: Azwanti: CR2566 - added User.LastLoginDate & Account.Dell_Certification_Areas__c
   12.0 - 22-12-2010: Azwanti: CR5549 - added Account.Account_Country_Code__c & Account.Regional_Area_Name__c
   13.0 - 10-12-2011: Krishna: CR6708 (R13.1)- Added End Customers and End Customer contact details in the Account XML
   14.0 - 11-06-2012: Krishnamoorthi: R13.7 CR6183 PRM - CMI Sync Issue - Disabling Partners security issue
   15.0 - 06-08-2012: Krishnamoorthi: R13.10 CR7291 - To send the End Customer Mailing Country to CMI
   16.0 - 12-12-2012: Krishnamoorthi: R14.2 Maintenance CR 7777 - Moved the 2 "addIntegrationException" methods from BachCMIdataIntegration to this class
   17.0 - 28-11-2012: Meera: 14.2 SSO field Additions related to SSO 
   18.0 - 14-01-2013: Bikram: 14.2 SSO removed field Is Country Enabled for Incentives
   19.0 - 25-10-2013: Meera:  15.3 CMAP Addition to pass lead management fields from country and user
   20.0 - 27-02-2014: Marina: CR 9349 - SAR 8334 Comment out the endCustomerList query 
   21.0 - 27-02-2014: Marina: CR 9349 - SAR 8334 Undo other code change done in the revision 13.0
   22.0 - 27-02-2014: Marina: CR 9349 - SAR 8334 Remove EndUserCusomters node from XML strings 
   23.0 - 17-09-2014: Jessie: CR10476 - Modified to convert hardcoded Data Power URL to Custom Label
*Revision Date        Modified By      CR Number                  Release No      Description  
   24.1 - 06-06-2018: khanm37, manip4  CR15997,CR16000, CR16007 - FY19-DCS-0802   Decommisioned netexam and Provisioned_in_Netexam_on__c as Part of Story# 4988554   
   25.2 - 06-06-2018  JatinPuri1       CR16018                    FY19-DCS-0802   Decommisioned netexam and Feature_Request_Training__c as part of story# 4988542
   26.0   21-11-2018   Sazleen                                    FY19-DCS-0102  Integration with CPDB
---------------------------------------------*/
public class PartnerProfileIntegration {
    
    //constant Variables
    public static final Integer TIMEOUT=60000;
    public static final String METHOD='POST';
    public static  String USERNAME;
    public static  String PASSWORD;
    public static  String ENDPOINT;
    public static  boolean authenticationRequired = true;  
    public static boolean isRunTest = false;
    public static Set<Id> contactIdSetForTesting = new Set<Id>();
    /* Jaya 20/July/2016 */ private static String REQUEST_BODY; // Added private REQUEST_BODY to obtain CMI method from requestBody, to support DataPower GE1 policy
    
    
    //Methods to hit New SQl DB 2016 End point
    //CR 13831
    public static void sendDatatoDpApiFromFutureFromAccount(List<String> Accountids){
       for(String  eachAcc : Accountids){
          if(!Test.isRunningtest()){
          if(System.Label.Do_CallOut == 'True'){
          sendDatatoDpApiFromAccountfuture(eachAcc );
          }
          }
      }
    }
    
    
    public static void sendDatatoDpApiFromFuture(List<String> contactids){
       for(String  eachCon : contactids){
       if(System.Label.Do_CallOut == 'True'){
      sendDatatoDpApiFromFuture(eachCon );
      if(!Test.isRunningtest()){
        PMCIntegration.pmcPostCallout(eachCon);
      }      
      }
      }
    }
    @future (callout=true)
    public static void sendDatatoDpApiFromFuture(String ContactId){
         if(!Test.isRunningtest()){
       PartnerPortalProfilingserviceIntegration.integratePartnerDataWithContact(ContactId);
       //v26.0
       CPDBXmlGenerator.getContactDataforCPDB(ContactId); 
       }
    }
    @future (callout=true)
    public static void sendDatatoDpApiFromAccountfuture(String Accid){
          if(!Test.isRunningtest()){
       sendDatatoDpApiFromAccount(Accid);
       }
    }
    //end of Methods calling SQL DB 2016 End Point
    
    public static void integratePartnerData(List<String> recordIds) {
    
    sendDatatoDpApiFromFutureFromAccount(recordIds);
             
        integratePartnerData(recordIds, null);
    }
    
    public static void sendDatatoDpApi(String ContactId){
   
       PartnerPortalProfilingserviceIntegration.integratePartnerDataWithContact(ContactId);
       CPDBXmlGenerator.getContactDataforCPDB(ContactId); //v26.0
    }
    public static void sendDatatoDpApiFromAccount(String AccId){
     String recordIdPrefix;  
        recordIdPrefix = StringUtils.defaultString(StringUtils.substring(AccId, 0, 3));
         if(recordIdPrefix.equals(Contact.sObjectType.getDescribe().getKeyPrefix())){      
         sendDatatoDpApi(AccId);
         }
    else{
         PartnerPortalProfilingserviceIntegration.integratePartnerDataWithAccount(AccId);
         }
    }
    
    //2186 added new arguments
    @future (callout=true)
    public static void integratePartnerData(List<String> recordIds, String userId){    
    
   
        //for storing the recordId prefix
        String recordIdPrefix;
        
        //raymond 20100202: Added
        setAuthenticationInfo();
        
        for(Integer count=0; count<recordIds.size(); count++){
            //get the first three characters of the ID passed to this controller
            recordIdPrefix = StringUtils.defaultString(StringUtils.substring(recordIds[count], 0, 3));
            try{
                String respBody;
                //Determine if the recordid is of a Contact     
                if(recordIdPrefix.equals(Contact.sObjectType.getDescribe().getKeyPrefix())){                    
                    //"user provisioning" for a Contact. Sends the contact Profile info.
                    respBody = sendContactInfo(recordIds[count], userId);
                }
                
                //Determine if the recordid is of an Account
                else if(recordIdPrefix.equals(Account.sObjectType.getDescribe().getKeyPrefix())){
                    //Method to send Account Profile info
                    sendAccountInfo(recordIds[count]);                  
                }
                
            }catch(Exception e){
                emailUtils.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);                     
            }//end of catch
        }//end of for loop
    }//end of method integratePartnerData
    
    //Rev 14.0 -- @future method to send disabled partner user info to CMI -- start
    @future (callout=true)
    public static void disablePartnerUsers(List<String> contactIds, List<String> userIds){        
       
          setAuthenticationInfo();
               
        for(Integer count=0; count<userIds.size(); count++){
            try{
                sendContactInfo(contactIds[count], userIds[count], true);
            }
            catch(Exception e){
                emailUtils.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);                     
            }
       }
    }
    //Rev 14.0 -- end
    
    //Raymond 20100202: This version of integratePartnerData will return the response text from the callout
    public static String integratePartnerDataWithResponse(String recordId) {
        return integratePartnerDataWithResponse(recordId, null);
    }
    
    //Raymond 20100202: This version of integratePartnerData will return the response text from the callout
    public static String integratePartnerDataWithResponse(String recordId, String userId) {
        String recordIdPrefix;
        
        setAuthenticationInfo();
        
        recordIdPrefix = StringUtils.defaultString(StringUtils.substring(recordId, 0, 3));
        try{
            //Determine if the recordid is of a Contact     
            if(recordIdPrefix.equals(Contact.sObjectType.getDescribe().getKeyPrefix())){                    
                return sendContactInfo(recordId, userId);
            }
            
            //WARNING: NOT IMPLEMENTED FOR ACCOUNT
            //Determine if the recordid is of an Account. Not implemented
            else if(recordIdPrefix.equals(Account.sObjectType.getDescribe().getKeyPrefix())){
            }
       
            return null;
            
        }catch(Exception e){
            emailUtils.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);     
            return null;                
        }//end of catch
    }
    
    
    //raymond 20100202: Created. Call this method to set authentication information
    private static void setAuthenticationInfo() {
    //Set header parameters for Production    
        if(UserInfo.getOrganizationId() == '00D300000006urqEAA') { 
            USERNAME='ServiceSOASFDC';  //for PRODUCTION env
            PASSWORD='2R8tHu93PuKUcHe'; // to be filled in later
            //Rev 23.0 - start
            ENDPOINT= System.Label.Partner_DP_Prod_Server_URL;
            //Rev 23.0 - end 
        }
        //Set header parameters for Sandbox 
        else{
            USERNAME='ServiceSOASFDC';
            PASSWORD='33Zyp+P+:Lx2X7$z';
            //Rev 23.0 - start          
            ENDPOINT= System.Label.Partner_DP_Sandbox_Server_URL;
            //Rev 23.0 - end 
            authenticationRequired = true;
        }   
    }
    
    //Method to send Account Profile info
    public static void sendAccountInfo(String recordId){
        sendAccountInfoWithResponse(recordId);
    }
    //Method to send Account Profile info and returns the response XML
    public static String sendAccountInfoWithResponse(String recordId){
    
        
        //Query Account to get data to be passed           
        //CR2094 
        //Meera:15.3 CMAP Addition
        List<Account> accountList=[Select States_Provinces_doing_business__c, Software_Revenue_Percent__c, Service_Revenue_Percent__c, Product_Focus__c, 
                                Primary_Channel_Model__c, Premier_Page_s_ID__c, Percent_Technical_Professionals__c, 
                                Partner_Registration__r.Percent_Sales_Force__c, Partner_Type__c, Partner_Tier__c, Partner_Relationship__c, Partner_Registration__r.Other_Customers__c, 
                                Partner_Registration__c, Partner_Primary_Customer__c, Partner_Description__c, Name, Last_4_Closed_Qtr_Rev_Workstations__c, 
                                Last_4_Closed_Qtr_Rev_Servers__c, Last_4_Closed_Qtr_Rev_Notebooks__c, Last_4_Closed_Qtr_Rev_Imaging__c,Last_4_Closed_Qtr_Rev_PowerVault__c, 
                                Last_4_Closed_Qtr_Rev_Desktops__c, Hardware_Revenue_Percent__c, Form_of_Organization__c, Dell_Revenue_Percent__c, Account_ID__c,Last_4_Closed_Qtr_Rev_EMC__c,
                                Preferred_Dell_Distribution_Partner__c, Percent_Sales_Force__c, Other_Customers__c,
                                Partner_Registration__r.Export_Compliance_Agreed__c, Partner_Registration__r.Partner_Terms_Conditions__c,Partner_Registration__r.Preferred_Dell_Distribution_Partner__c,
                                //remove for FAP packaging 
                                Approved_for_Partner_Finder__c, 
                                Dell_Certification_Areas__c,Account_Country_Code__c,Regional_Area_Name__c
                                ,Is_Enabled_for_Incentives__c ,Vendor_Update_Datetime__c,Is_Incentive_Updated__c,Is_Vendor_Updated__c ,last_Operation_Performed__c,
                                Sales_Channel__r.name
                                From Account where id=:recordId];
        
        if(accountList.size()>0){
            
            //create request body from the Account record
            String requestBody = createAccountHTTPRequestBodyString(accountList[0]);

            //Raymond 20100202; method sendHttpRequest is modified, will return HTTPResponse value
            HTTPResponse res = sendHttpRequest(requestBody);
            return res.getBody();
        }
        return null;       
    }
    
    
    
    //Method to create Account Info HTTP Request body
    public static String createAccountHTTPRequestBodyString(Account accountRecord){
        //14.2 SSO Modifications        
        PartnerCountry pc = new PartnerCountry();
        Map<String, Country__c> countryMap = pc.returnCountryCodeMap();
        boolean enabledforIncentives = false;
        boolean isCountryEnabled = false;
        String vendorName;
        Country__c country = countryMap.get(StringUtils.uppercase((accountRecord.Account_Country_Code__c).trim()));
            if(country != null){
                vendorName = country.Inc_Vendor_Name__c;
                if ((vendorName == 'Partner Direct Rewards Center') || (vendorName == 'Partner Advantage') ||  (vendorName == 'Dell Achievers')){                       
                    isCountryEnabled = true;
                }else{
                    isCountryEnabled = false;
                }
            }
        //not created in vendor system
        if (accountRecord.Vendor_Update_Datetime__c == NULL){
            enabledforIncentives = false;       
        }
        //record is there in vendor system and now incentive flag is getting modified but that is not synched with vendor system
        else if(accountRecord.Is_Incentive_Updated__c == true && accountRecord.Vendor_Update_Datetime__c != NULL && accountRecord.Is_Vendor_Updated__c == false 
                && accountRecord.last_Operation_Performed__c == 'SFDC Updated'){
            
                if(accountRecord.Is_Enabled_for_Incentives__c == true){
                    enabledforIncentives = false;
                }
                else{
                    enabledforIncentives = true;
                }
        }       
                    
        else{
            enabledforIncentives = accountRecord.Is_Enabled_for_Incentives__c;      
        }
        //Meera:15.3CMAP Modification
        boolean isleadmanagementenabled = false;
        //for OEM Accounts
            if(accountRecord.Sales_Channel__r != null && country != null){
                if((accountRecord.Sales_Channel__r.Name).contains('OEM') && country.Lead_Management_Enabled_for_OEM__c == 'Yes' ){
                        isleadmanagementenabled = true;
                }
            
            //for other Accounts
            
                else if(country.Lead_Management_Enabled__c == 'Yes'){
                        isleadmanagementenabled = true;
                }
            }  
        //Create Request XML
        XmlStreamWriter w = new XmlStreamWriter();
        
        //Envelop
        w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('cmi', 'http://cmi.us.dell.com');
        
        //Header
        w.writeEmptyElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');
        
        //Body
        w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        
        //InsertSegmentationData
        w.writeStartElement('cmi', 'InsertSegmentationData', 'http://cmi.us.dell.com');
        
        //partyId
        w.writeStartElement('cmi', 'partyId', 'http://cmi.us.dell.com');
        w.writeCharacters(''+ accountRecord.Account_ID__c);
        w.writeEndElement(); 
        
        //cesrId
        w.writeStartElement('cmi', 'cesrId', 'http://cmi.us.dell.com');
        w.writeCharacters('');
        w.writeEndElement();
        
        //contactId
        w.writeStartElement('cmi', 'contactId', 'http://cmi.us.dell.com');
        w.writeCharacters('');
        w.writeEndElement(); 
        
        //locationId
        w.writeStartElement('cmi', 'locationId', 'http://cmi.us.dell.com');
        w.writeCharacters('');
        w.writeEndElement();  
        
        //data
        w.writeStartElement('cmi', 'data', 'http://cmi.us.dell.com');
        
        w.writeStartElement(null, 'Root', null);
        
        w.writeAttribute(null,null,'schemaVersion','1.0');
        w.writedefaultNamespace('http://dell.com/cmi');
        w.writeNamespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance');       
        w.writeAttribute(null,null,'xsi:schemaLocation','http://dell.com/cmi SFDC_v1.0.xsd');
        
        w.writeStartElement(null, 'Partner', null);     
        
        w = addElementAndValue(w, 'Id', accountRecord, 'Account_ID__c');        
        w = addElementAndValue(w, 'AccountName', accountRecord, 'Name');        
        w = addElementAndValue(w, 'PartnerType', accountRecord, 'Partner_Type__c');     
        w = addElementAndValue(w, 'PartnerDescription', accountRecord, 'Partner_Description__c');
        w = addElementAndValue(w, 'PartnerTier', accountRecord, 'Partner_Tier__c');     
        w = addElementAndValue(w, 'PartnerRelationship', accountRecord, 'Partner_Relationship__c');     
        w = addElementAndValue(w, 'FormOfOrganization', accountRecord, 'Form_of_Organization__c');
        w = addElementAndValue(w, 'PremierPageLink', accountRecord, 'Premier_Page_s_ID__c');            
                
        w = addElementAndValue(w, 'CurrentPercentageOfRevenueIsDell', accountRecord, 'Dell_Revenue_Percent__c');        
        //Rev : 12.0 for CR5549
        w = addElementAndValue(w, 'AccountCountry', accountRecord, 'Account_Country_Code__c');
        w = addElementAndValue(w, 'RegionalAreaName', accountRecord, 'Regional_Area_Name__c');  
        
        
        //Rev : 12.0 for CR5549
        
        /* Multi picklist */
        w.writeStartElement(null, 'AreasOfOperation', null);
        w = addMultiSelectPicklistValues( w, 'AreaOfOperation', accountRecord.States_Provinces_doing_business__c);
        w.writeEndElement();
        
        //CR2566 - added Account.Dell_Certification_Areas__c multi picklist
        w.writeStartElement(null, 'DellCertificationAreas', null);
        w = addMultiSelectPicklistValues( w, 'DellCertificationArea', accountRecord.Dell_Certification_Areas__c);
        w.writeEndElement();
                
        w.writeStartElement(null, 'DellProductFoci', null);
        w = addMultiSelectPicklistValues( w, 'DellProductFocus', accountRecord.Product_Focus__c);
        w.writeEndElement();        

        /*----- */
        
        w.writeStartElement(null, 'RevenueBreakdown', null);        
        
        w = addElementAndValue(w, 'ServiceRevenuePercentage', accountRecord, 'Service_Revenue_Percent__c');
        w = addElementAndValue(w, 'SoftwareRevenuePercentage', accountRecord, 'Software_Revenue_Percent__c');
        w = addElementAndValue(w, 'HardwareRevenuePercentage', accountRecord, 'Hardware_Revenue_Percent__c');       
        
        w.writeStartElement(null, 'HardwareRevenueBreakdown', null);    
                
        w = addElementAndValue(w, 'DesktopRevenue', accountRecord, 'Last_4_Closed_Qtr_Rev_Desktops__c');
        w = addElementAndValue(w, 'NotebookRevenue', accountRecord, 'Last_4_Closed_Qtr_Rev_Notebooks__c');      
        w = addElementAndValue(w, 'WorkstationRevenue', accountRecord, 'Last_4_Closed_Qtr_Rev_Workstations__c');
        w = addElementAndValue(w, 'ServerRevenue', accountRecord, 'Last_4_Closed_Qtr_Rev_Servers__c');      
        w = addElementAndValue(w, 'PowervaultRevenue', accountRecord, 'Last_4_Closed_Qtr_Rev_PowerVault__c');
        w = addElementAndValue(w, 'EMCRevenue', accountRecord, 'Last_4_Closed_Qtr_Rev_EMC__c');
        w = addElementAndValue(w, 'PrinterRevenue', accountRecord, 'Last_4_Closed_Qtr_Rev_Imaging__c');
        
        w.writeEndElement();// end HardwareRevenueBreakdown
        w.writeEndElement(); //end RevenueBreakdown
        
        w.writeStartElement(null, 'SegmentBreakdown', null);
        
        w = addElementAndValue(w, 'PrimarySegment', accountRecord, 'Partner_Primary_Customer__c');
        
        /* Modified as part of CR #1938 for 10.10 */
        w.writeStartElement(null, 'OtherSegments', null);
        w = addMultiSelectPicklistValues( w, 'OtherSegment', accountRecord.Other_Customers__c);
        w.writeEndElement();
        
        w.writeEndElement(); //end SegmentBreakdown
        
        w.writeStartElement(null, 'BusinessModelBreakdown', null);
                
        w = addElementAndValue(w, 'PrimaryChannelBusinessModel', accountRecord, 'Primary_Channel_Model__c');
                
        w.writeEndElement();//end BusinessModelBreakdown        
        
        w.writeStartElement(null, 'EmployeeBreakdown', null);       
        w = addElementAndValue(w, 'TechnicalProfessionalsPercentage', accountRecord, 'Percent_Technical_Professionals__c'); 
        
        /* Modified as part of CR #1938 for 10.10 */
        w = addElementAndValue(w, 'SalesForcePercentage', accountRecord, 'Percent_Sales_Force__c');    
        w.writeEndElement(); //end EmployeeBreakdown                
        
        w.writeStartElement(null, 'VendorBreakdown', null);   
        
        /* Modified as part of CR #1938 for 10.10 */
        w = addElementAndValue(w, 'PrimaryDistributionVendor', accountRecord, 'Preferred_Dell_Distribution_Partner__c');      
        w.writeEndElement();  //end VendorBreakdown
        
        w.writeStartElement(null, 'Status', null);              
        w = addElementAndValue(w, 'Contract', accountRecord, 'Partner_Registration__r.Partner_Terms_Conditions__c');        
        w = addElementAndValue(w, 'ExportComplianceAgreed', accountRecord, 'Partner_Registration__r.Export_Compliance_Agreed__c');              
        w.writeEndElement();//end Status
        
        w.writeEmptyElement(null,'Contact',null);
        
        // CR#2094 - new section 
        w.writeStartElement(null, 'PartnerApplicationAccess', null);   //start PartnerApplicationAccess  
        w = addElementAndValue(w, 'PartnerFinder', accountRecord, 'Approved_for_Partner_Finder__c');
         
        w.writeEndElement();//end PartnerApplicationAccess
        
        //Removed the refrence of Is_Country_Enabled__c - Bikram
        w = addElementAndValueString(w,'EnabledforIncentives',''+enabledforIncentives);
        w = addElementAndValueString(w,'IsCountryEnabledForIncentives',''+isCountryEnabled);        
        //Meera:15.3 CMAP Addition
        w = addElementAndValueString(w,'IsCountryEnabledForLeadManagement',''+isleadmanagementenabled);
        
        //  [/Rev 13.0]
        
        w.writeEndElement();//end Partner
        
        w.writeEndElement(); //end Root
        w.writeEndElement(); //end Data
        
        w.writeStartElement('cmi', 'group', 'http://cmi.us.dell.com');
        w.writeCharacters('Partner');
        w.writeEndElement();
        
        w.writeStartElement('cmi', 'application', 'http://cmi.us.dell.com');
        w.writeCharacters('SFDC');
        w.writeEndElement();
        
        w.writeEndElement(); //end InsertSegmentation data
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }
    // Added by Sneha
    // Inorder to perform DML After all the callouts are done.
    public static List<Exception__c> lstException = new List<Exception__c>();
    public static List<Attachment> lstAttachment = new List<Attachment>();
    //Method to send Contact Info
    //Raymond 20100202: Modified to return String value.
    public static String sendContactInfo(String recordId, String userId){
         try{
             PartnerPortalProfilingserviceIntegration.integratePartnerDataWithContact(recordId);
             CPDBXmlGenerator.getContactDataforCPDB(recordId);   //v26.0
             // Creating System.callout exception at line number 842
             /*if(lstException.size() > 0){
                 System.debug('Exception Occured'+lstException);
                 
                 insert lstException;
                 System.debug('Exception inserted::'+lstException);
                 
             }*/
            
        }catch(Exception ex){}
        return sendContactInfo(recordId, userId, false);
     }
      
      public static String sendContactInfo(String recordId, String userId, boolean isDisabled){
        String requestBody = getContactRequestBody(recordId, userId);
        
        if(requestBody != null) { 
            // Check for the disabled user and change the IsActive field in the request body to false
            if(isDisabled) {
                requestBody = requestBody.replace('<IsActive>true</IsActive>', '<IsActive>false</IsActive>');
            }
            return sendHttpRequest(requestBody).getBody();
             
             
         
        }   
        return null;
     }
     //Rev 14.0 - end
    
    //Raymond 20100202: Created
    private static String getContactRequestBody(String recordId, String userId) {
        List<User> userList = new List<User>();
        List<Partner_Request__c> partnerRequestList = new List<Partner_Request__c>();
        
        //Query Contact to get info to be passed
        //CR2093
        //6.0
        List<Contact> contactList=[SELECT id,Partner_My_Account_GUID__c,Account.Partner_Registration__c,Account.Account_ID__c, AccountId, 
                                    Is_Rebate_User__c, 
                                   Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_parts_Info__c
                                   ,Is_Enabled_for_Incentives__c,Is_Incentives_Updated__c,Vendor_Update_Datetime__c,Last_Operation_Performed__c,Is_Vendor_Updated__c
                                   FROM Contact 
                                   WHERE id=:recordId AND Partner_My_Account_GUID__c != null];
        if(contactList.size()>0){
           
            //2186
            if(userId == null) {
            //Get Corresponding User info
                //Meera 15.3 CMAP Modification - Added lead management field in query
                userList=[Select IsActive, LastName, LanguageLocaleKey, FirstName,ContactId,Enable_Partner_Deal_Registration__c, 
                          Enable_Partner_Admin__c,Enable_Partner_Lead_Management__c,
                          //remove for FAP packaging 
                          Is_Admin_for_Partner_Finder_Profile__c,
                          LastLoginDate,TimeZoneSidKey 
                          From User where ContactId=:recordId];
            }
            else {
                userList=[Select IsActive, LastName, LanguageLocaleKey, FirstName,ContactId,Enable_Partner_Deal_Registration__c, 
                          Enable_Partner_Admin__c,Enable_Partner_Lead_Management__c,
                          //remove for FAP packaging
                          Is_Admin_for_Partner_Finder_Profile__c,
                          LastLoginDate,TimeZoneSidKey 
                          From User where Id=:userId];                 
            }  
       
            //Get corresponding Partner Request info
            partnerRequestList=[Select Feature_Request_Deal_Registration__c,Account__c 
                                From Partner_Request__c where Id= : contactList[0].Account.Partner_Registration__c];
            //Rev 14.0
            if( userList.size()==0){
                 return null;
            }
            //craete request body for Contact profile  
            String requestBody = createContactHTTPRequestBodyString(contactList[0],userList[0],null);  
            
            return requestBody;
        }
        else {
            return null;
        }
     }

    //Method to create Contact Info HTTP Request body
    public static String createContactHTTPRequestBodyString(Contact contactRecord,User userRecord,Partner_Request__c partnerRequestRecord){
        //14.2 SSO Modifications
        boolean enabledforIncentives = false;       
        //not created in vendor system
        if (contactRecord.Vendor_Update_Datetime__c == NULL){
            enabledforIncentives = false;           
        }
        
        //record is there in vendor system and now incentive flag is getting modified but that is not synched with vendor system
        else if(contactRecord.Is_Incentives_Updated__c == true && contactRecord.Vendor_Update_Datetime__c != NULL && contactRecord.Is_Vendor_Updated__c == false 
                && contactRecord.Last_Operation_Performed__c == 'SFDC Updated'){
            
            
                if(contactRecord.Is_Enabled_for_Incentives__c == true){
                    enabledforIncentives = false;
                }
                else{
                    enabledforIncentives = true;
                }
            
        }
        else{//none of the incentive related flags are updated or it is already synched with vendor system so pass the current value
            enabledforIncentives = contactRecord.Is_Enabled_for_Incentives__c;          
        }
        
        XmlStreamWriter w = new XmlStreamWriter();
        
        //Envelope
        w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('cmi', 'http://cmi.us.dell.com');
        
        //Header
        w.writeEmptyElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');
        
        //Body
        w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        
        //InsertSegmentationData
        w.writeStartElement('cmi', 'InsertSegmentationData', 'http://cmi.us.dell.com');
        
        //partyId
        w.writeStartElement('cmi', 'partyId', 'http://cmi.us.dell.com');
        w.writeCharacters('' + contactRecord.Account.Account_ID__c);
        w.writeEndElement(); 
        
        //cesrId
        w.writeStartElement('cmi', 'cesrId', 'http://cmi.us.dell.com');
        w.writeCharacters('');
        w.writeEndElement();
        
        //contactId
        w.writeStartElement('cmi', 'contactId', 'http://cmi.us.dell.com');
        w.writeCharacters(''+contactRecord.Partner_My_Account_GUID__c);
        w.writeEndElement(); 
        
        //locationId
        w.writeStartElement('cmi', 'locationId', 'http://cmi.us.dell.com');
        w.writeCharacters('');
        w.writeEndElement(); 
        
        //data
        w.writeStartElement('cmi', 'data', 'http://cmi.us.dell.com');
        //Root
        w.writeStartElement(null, 'Root', null);
        
        w.writeAttribute(null,null,'schemaVersion','1.0');
        w.writedefaultNamespace('http://dell.com/cmi');
        w.writeNamespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance');       
        w.writeAttribute(null,null,'xsi:schemaLocation','http://dell.com/cmi SFDC_v1.0.xsd');
        
        w.writeStartElement(null, 'Partner', null);
        w.writeStartElement(null, 'Contact', null);     
        
        w = addElementAndValue(w, 'Id', contactRecord, 'Partner_My_Account_GUID__c');       
        String fullname = userRecord.FirstName +' '+ userRecord.LastName;
        w.writeStartElement(null, 'FullName', null);
        w.writeCharacters(fullname);
        w.writeEndElement();    
        w = addElementAndValue(w, 'PreferredLanguageCode', userRecord, 'LanguageLocaleKey');
                
        w.writeStartElement(null, 'ApplicationAccess', null);
        /* Modified as part of CR #1938 for 10.10 */     
        Boolean netExamEnabled =false; //assigned boolean value to false as part of NET Exam decommissioning story
        w = addElementAndValueString(w, 'TrainingAndCertification', ''+ netExamEnabled);         
        
        /* Modified as part of CR #1938 for 10.10 */
        w = addElementAndValue(w, 'DealRegistration', userRecord, 'Enable_Partner_Deal_Registration__c');
        //Meera:CMAP 15.3 added Lead management flag
        w = addElementAndValue(w, 'LeadManagement', userRecord, 'Enable_Partner_Lead_Management__c');
        
        w = addElementAndValueString(w,'SelfService',''+ userRecord.Enable_Partner_Admin__c);
        w = addElementAndValueString(w,'TransactionalStore',''+contactRecord.Transactional_Store__c);
        // CR2093-end
        
        //as per R10.10, changed mapping for Rebates tag
        w = addElementAndValueString(w,'Rebates', ''+ BooleanUtils.isTrue(contactRecord.Is_Rebate_User__c)); 
        
        // CR2093 Partner Application Access
        w = addElementAndValueString(w,'CampaignBuilder',''+contactRecord.Campaign_Builder__c);
        w = addElementAndValueString(w,'Premier',''+contactRecord.Premier_Partner__c);
        w = addElementAndValueString(w,'WarrantyPartsInfo',''+contactRecord.Warranty_parts_Info__c);
        // CR2093-end       
        
        // CR2094
        //remove for FAP packaging 
        w = addElementAndValueString(w, 'PartnerFinder',''+userRecord.Is_Admin_for_Partner_Finder_Profile__c);
        w.writeEndElement();//end ApplicationAccesspartnerApplicationAccess
        
        //2150        IsActive
        w = addElementAndValueString(w,'IsActive',''+userRecord.IsActive);
        //end 2150
        
        //CR2566 - Added   
        if(userRecord.LastLoginDate != null){
            w = addElementAndValueString(w,'LastLogin',''+ userRecord.LastLoginDate.format('MM/dd/yyyy hh:mm:ss aaa z',userRecord.TimeZoneSidKey));
        }
        else{
            w = addElementAndValueString(w,'LastLogin','');
        }
        w = addElementAndValueString(w,'EnabledforIncentives',''+enabledforIncentives);
        
        w.writeEndElement(); //end Contact                  
        w.writeEndElement();//end Partner
        
        w.writeEndElement();//end Root 
        w.writeEndElement(); //end Data
        
        //group
        w.writeStartElement('cmi', 'group', 'http://cmi.us.dell.com');
        w.writeCharacters('Partner');
        w.writeEndElement();
        
        //Application
        w.writeStartElement('cmi', 'application', 'http://cmi.us.dell.com');
        w.writeCharacters('SFDC');
        w.writeEndElement();//end 
        
        w.writeEndElement(); //end InsertSegmentation data
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }

    //Method to create HTTPRequest Header
    public static HttpRequest createHttpRequestHeader(){
        HttpRequest req = new HttpRequest();
        
        /* Start Jaya 20/July/2016 - Added below 3 lines header to support DataPower GE1 policy */
        List<String> cmiSOAPActionList = new List<String>();
        cmiSOAPActionList.add('GetDescriptions');
        cmiSOAPActionList.add('GetSegmentationData');
        cmiSOAPActionList.add('GetTranslations');
        
        cmiSOAPActionList.add('InsertDescriptions');
        cmiSOAPActionList.add('InsertSegmentationData');
        cmiSOAPActionList.add('InsertTranslations');
        
        cmiSOAPActionList.add('UpdateDescriptions');
        cmiSOAPActionList.add('UpdateSegmentationData');
        cmiSOAPActionList.add('UpdateTranslations');
        
        cmiSOAPActionList.add('UpdateKeys');
        
        String cmiSOAPAction_toCall = '';
        for(String cmiSoapAction: cmiSOAPActionList){
        REQUEST_BODY = REQUEST_BODY.toLowerCase();
        if(REQUEST_BODY.contains(cmiSoapAction.toLowerCase()+'>'))
        cmiSOAPAction_toCall = cmiSoapAction;
        }
        
        req.setMethod('POST');
        req.setHeader('Content-Type','text/xml;charset=utf-8');
        req.setHeader('SOAPAction','http://cmi.us.dell.com/CustomerService/'+cmiSOAPAction_toCall);
        /* [Krishna 9-Mar-2010] Added setAuthenticationInfo() call */ 
        setAuthenticationInfo();
        
        //Set endpoint URL      
        req.setEndpoint(ENDPOINT);
        if(authenticationRequired){
                        
            // Specify the required user name and password to access the endpoint
            // As well as the header and header information     
            Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            
        }
        //Set the timeout value for the Request
        req.setTimeout(TIMEOUT);
        return req; 
    }   
        
    
    //Method to process multipicklist values
    public static XmlStreamWriter addMultiSelectPicklistValues(XmlStreamWriter w, string tagName, string multiSelectPicklistValue){
    
        if(multiSelectPicklistValue != null && multiSelectPicklistValue != ''){
        
            list<string> extractedListofValues = multiSelectPicklistValue.split(';');
            for(string eachValue : extractedListofValues){
                w.writeStartElement(null, tagName, null);
                w.writeCharacters(eachValue);
                w.writeEndElement();
            }   
        }
        return w;
    }   
    //Method to add elemenet and value of type String to the XmlStreamWriter
    public static XmlStreamWriter addElementAndValueString(XmlStreamWriter w, String tagName, String value){
        w.writeStartElement(null, tagName, null);
        if(value == null){
            w.writeCharacters('');  
        }
        else{
            w.writeCharacters(value);
        }
        
        w.writeEndElement();
        return w;
    }
    
    //Method to add elemenet and value to the XmlStreamWriter
    public static XmlStreamWriter addElementAndValue(XmlStreamWriter w, string tagName, sObject record, string fieldName){
    
        String valueToBeAdded = '';     
        
        if(fieldName.contains('Partner_Registration__r.')){
            //Typecast to Account
            Account accountRecord =(Account) record;
            fieldName = fieldName.replace('Partner_Registration__r.','');
            
            if(accountRecord.Partner_Registration__r!= null){
                if(accountRecord.Partner_Registration__r.get(fieldName)!= null){                
                    valueToBeAdded += accountRecord.Partner_Registration__r.get(fieldName);
                }
            }
        }
        else{
            if(record.get(fieldName)!=null){
                valueToBeAdded += record.get(fieldName);
            }
        }
        
        if(valueToBeAdded != ''){
            w.writeStartElement(null, tagName, null);
            w.writeCharacters(valueToBeAdded);
            w.writeEndElement();
                
        }
        return w;
    }
    
    
    
    //Method to send HTTPRequest
    //raymond 20100202: Modified to return HTTPResponse
    public static HTTPResponse sendHttpRequest(String requestBody){
        REQUEST_BODY = requestBody;
        //method call to create HttpRequest
        HttpRequest req=createHttpRequestHeader();      
        //sets the request body
        req.setBody(requestBody);
    
        Http http = new Http();
        
        //Sending the HTTP request
        if(System.Label.SyncToCMI == 'True'){
        HTTPResponse res = http.send(req);
        //The response is not processed.  
        insertExceptionRecordCreatedDuringCallouts();
        return res;     
        }else{
            insertExceptionRecordCreatedDuringCallouts();
        return new HTTPResponse();
        } 
    }
    
    public static void insertExceptionRecordCreatedDuringCallouts(){
        if(lstException.size() > 0){
            try{
                System.debug('Exception Occured'+lstException.size());
                insert lstException;
                System.debug('Exception inserted::'+lstException);
                System.debug('Attachment inserted::'+lstAttachment.size());
                List<Attachment> lstNewAttach= new List<Attachment>();
                for(Attachment att : lstAttachment){
                    String[] attName = att.Name.split('\\.');
                    System.debug('attName'+attName);
                    for(Exception__c e : lstException){
                        if(e.Object_ID__c == attName[0]){
                            if(e.Process_Name__c =='Partner profile Integration'){
                               att.ParentId = e.id;
                               //lstNewAttach.add(att);
                               System.debug('in pp'+lstAttachment);
                            }
                            else if(e.Process_Name__c == 'CPDB Integration'){
                                att.ParentId = e.id;
                               // lstNewAttach.add(att); 
                                System.debug('in cp'+lstAttachment);
                            }
                        }
                    }
                 }
                System.debug('in overall3'+lstAttachment);
                if(lstAttachment.size() > 0){
                    System.debug('lstNewAttach block'+lstAttachment.size());
                    insert lstAttachment;
                    System.debug('lstNewAttach'+lstAttachment);
                }
            }
            catch(Exception ex){
                System.debug('Failed to insert Exception');
            }
             
                 
             }
    }
    
    //Raymond 20090717: Added for CR1616. This function will filter out the contacts
    //                  that are tie to account with IsPartner <> true and 
    //                  recordType <> Partner Account   
    public static Set<Id> filterNonPartnerAccountContact(Set<Id> contactSet) {
        
        /*[Krishna 10-Mar-2010] added this check */
        if(contactSet.isEmpty())return contactSet;
        Map<Id, Contact> tempMap = new Map<Id, Contact>(
                                                [SELECT Id, Name, Account.IsPartner, Account.RecordTypeId
                                                FROM Contact
                                                WHERE Account.IsPartner = true
                                                AND Account.RecordTypeId = :System.Label.RecType_Partner_Account
                                                AND Id IN :contactSet
                                                ORDER BY Id]);                                    
        return tempMap.KeySet();
    }
    
    //Raymond 20090717: Added for CR1616. This function will filter out the contacts
    //                  that are not tie to any user.
    public static Set<Id> filterNonPartnerUserContact(Set<Id> contactSet) {
        
        
        Set<Id> contactIdSet = new Set<id>();
        
        /*[Krishna 10-Mar-2010] added this check */
        if(contactSet.isEmpty())return contactIdSet;
        
        for(User u : [SELECT ContactId FROM User WHERE  ContactId IN :contactSet ORDER BY ContactId]) {
            contactIdSet.add(u.ContactId);
        }
        return contactIdSet;    
    }   
    
    //Raymond 20100202: Created
    public static List<String> parseCMIResponse(String xmlBody, String localName, XMLTag tagType) {
        
        List<String> valueList = new List<String>();
        
        Boolean isTargetLocalName = false;
        
        XMLStreamReader xlr = new XMLStreamReader(xmlBody);
        
        while(xlr.hasNext()) {
            if(xlr.isStartElement()) {
                if(xlr.getLocalName() == localName){
                isTargetLocalName = true;
                }
            }
            else if(xlr.isEndElement()) {
                if(xlr.getLocalName() == localName){
                isTargetLocalName = false;
                break;
                }
            }            
            if(isTargetLocalName && xlr.getEventType() == tagType) {
                valueList.add(xlr.getText());
                
            }
            
            xlr.next();
        }
        
        return valueList;
    }
    
    
    /* [Krishna 8-Mar-2010] Methods for UpdateKey Invocations Part of CR 2431 R11.2 */
    
    public static Set<Id> processUpdateKeyRequestForAcctChange(Map<Id, Contact> triggerNewMap, 
                                                                    Map<Id, Contact> triggerOldMap, 
                                                                    Set<Id> partnerContactIdSet){        
        Integer possibleFutureCalls = getPossibleUpdateKeyFutureCalls();
        Integer iterationCounter = 0;
        
        Set<Id> unProcessedIdSet = new Set<Id>();
        
        
        List<String> oldAccountGUIDlist = new List<String>();
        List<String> newAccountGUIDlist = new List<String>();
        List<String> oldContactMyAccGUIDlist = new List<String>();
        List<String> newContactMyAccGUIDlist = new List<String>();
        List<String> processingContactIdList = new List<String>();
        
        
        
        for(Id contactId: partnerContactIdSet){
            if (isRunTest) contactIdSetForTesting.add(contactId);   //Rev 10.0
            
            //counts the iteration
            iterationCounter++;
            
            
            //until one call remains
            if(possibleFutureCalls >= 1){           
                if((triggerOldMap.get(contactId).AccountId != triggerNewMap.get(contactId).AccountId)&& 
                        triggerNewMap.get(contactId).Partner_My_Account_GUID__c != null){
                    
                    oldAccountGUIDlist.add(triggerOldMap.get(contactId).AccountId);
                    newAccountGUIDlist.add(triggerNewMap.get(contactId).AccountId);
                    oldContactMyAccGUIDlist.add(triggerOldMap.get(contactId).Partner_My_Account_GUID__c);
                    newContactMyAccGUIDlist.add(triggerNewMap.get(contactId).Partner_My_Account_GUID__c);
                    processingContactIdList.add(contactId);                    
                }//end of if 'Account changed?' if block    
                
                if(processingContactIdList.size()>0 && 
                  (processingContactIdList.size() == (Limits.getLimitCallouts()/2) || iterationCounter == partnerContactIdSet.size())){
                    
                    /* Invoking the future method */                    
                    invokeUpdateKeyCallforBatch(oldContactMyAccGUIDlist, 
                                                newContactMyAccGUIDlist, 
                                                oldAccountGUIDlist, 
                                                newAccountGUIDlist,
                                                processingContactIdList);
                    
                    possibleFutureCalls = getPossibleUpdateKeyFutureCalls();
                    
                    //clear the temporary lists                 
                    oldAccountGUIDlist.clear();
                    newAccountGUIDlist.clear();
                    oldContactMyAccGUIDlist.clear();
                    newContactMyAccGUIDlist.clear();
                    processingContactIdList.clear();                    
                }
                    
                
                else if(triggerNewMap.get(contactId).Partner_My_Account_GUID__c != null){
                    unProcessedIdSet.add(contactId);
                }
                else {
                    System.debug('#### Found no valid My Account GUID for this contact ('+ contactId +'). So ignored');
                }
            } //end of if block possibleFutureCalls >= 1
            else{
                triggerNewMap.get(contactId).addError('Partner Contacts Updates has hit SFDC FutureCall Limit.Please reduce the batch size');
            }   
        }//end of for loop
        if (!isRunTest)
            return unProcessedIdSet;
        else
            return contactIdSetForTesting;          
    
    }// end of method               
            
        
    //change the logic
    public static Integer getPossibleUpdateKeyFutureCalls(){
        //Sharing the callout limits with the Partner profile integartion.
        return (Limits.getLimitFutureCalls() - Limits.getFutureCalls());                
    }
    
    @future(callout=true)
    public static void invokeUpdateKeyCallforBatch(List<String> oldContactMyAccGUIDlist, 
                                                   List<String> newContactMyAccGUIDlist,
                                                   List<String> oldAccountGUIDlist,
                                                   List<String> newAccountGUIDlist,
                                                   List<String> processingContactIdList){
            
            String ErrorMessage = '';
            Boolean result = false;
            Integer BatchSize = newContactMyAccGUIDlist.size();
            Map<Id, Account> IdToAccountMap = new Map<Id, Account>([SELECT Id, Account_ID__c 
                                                                    FROM Account
                                                                    WHERE Id IN :newAccountGUIDlist 
                                                                    OR Id IN :oldAccountGUIDlist]);
            
            
            
            for(Integer i = 0; i < BatchSize ; i++){
                //Invoke callout for each set.
                try{
                    result = sendUpdateKeyInfo(oldContactMyAccGUIDlist[i],
                                               newContactMyAccGUIDlist[i],
                                               IdToAccountMap.get(oldAccountGUIDlist[i]).Account_ID__c,
                                               IdToAccountMap.get(newAccountGUIDlist[i]).Account_ID__c);
                    
                    
                    
                    if(!result){
                        ErrorMessage += '\n Contact::'+ newContactMyAccGUIDlist[i] + '::Error response';
                    }
                    else{
                        integratePartnerDataWithResponse(processingContactIdList[i]);
                    }
                }
                catch(Exception e){
                    ErrorMessage += '\n Contact::'+ newContactMyAccGUIDlist[i] + ':: Exception:'+e.getMessage();
                }               
            }//end of for loop  
            if(ErrorMessage != ''){
                System.debug('#### Error List for updateKey invocation on Contact update ####'+ ErrorMessage );
            }                               
                
            
        }//end of the method
    
    public static Boolean sendUpdateKeyInfo(String oldMyAccountGUID,String newMyAccountGUID,String oldPartyId, String newPartyId){
        String requestBody = getUpdateKeyHTTPRequestBody(oldMyAccountGUID, newMyAccountGUID, oldPartyId, newPartyId);
        String responseString;
        Boolean result = false;
        if(requestBody != null) {
            //calls the method to send the request.
            responseString = sendHttpRequest(requestBody).getBody();
            result = StringUtils.defaultString(responseString).contains('<UpdateKeysResult>true</UpdateKeysResult>'); 
            return result;
        }   
        return result;
     }
     
     //Method to create UpdateKeys HTTP Request body
    public static String getUpdateKeyHTTPRequestBody(String oldMyAccountGUID,String newMyAccountGUID,String oldPartyId, String newPartyId){
        //Create Request XML
        XmlStreamWriter w = new XmlStreamWriter();
        
        //Envelop
        w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('cmi', 'http://cmi.us.dell.com');
        
        //Header
        w.writeEmptyElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');
        
        //Body
        w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        
        //InsertSegmentationData
        w.writeStartElement('cmi', 'UpdateKeys', 'http://cmi.us.dell.com');
        
        //oldPartyId
        w.writeStartElement('cmi', 'oldPartyId', 'http://cmi.us.dell.com');
        w.writeCharacters(''+ oldPartyId);
        w.writeEndElement();         
        
        //oldContactId
        w.writeStartElement('cmi', 'oldContactId', 'http://cmi.us.dell.com');
        w.writeCharacters(''+ oldMyAccountGUID);
        w.writeEndElement(); 
        
        //newPartyId
        w.writeStartElement('cmi', 'newPartyId', 'http://cmi.us.dell.com');
        w.writeCharacters('' + newPartyId);
        w.writeEndElement();  
        
        //newContactId
        w.writeStartElement('cmi', 'newContactId', 'http://cmi.us.dell.com');
        w.writeCharacters(''+ newMyAccountGUID);
        w.writeEndElement(); 
        
        w.writeStartElement('cmi', 'group', 'http://cmi.us.dell.com');
        w.writeCharacters('Partner');
        w.writeEndElement();
        
        w.writeStartElement('cmi', 'application', 'http://cmi.us.dell.com');
        w.writeCharacters('SFDC');
        w.writeEndElement();
        
        w.writeEndElement(); //end UpdateKeys
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }
    
    //Rev 10.0
    public static boolean isValueChanged(SObject oldValue, SObject newValue, List<String> fieldList) {
            
        for (String fieldAPIName: fieldList) {
            if (oldValue.get(fieldAPIName) <> newValue.get(fieldAPIName)) {             
                return true;
            }
        }        
        //implies no change 
        return false;
    }
    //Rev 10.0-end
    
    //Rev 10.0
    public static List<String> valueChangedList(Map<Id, SObject> oldValueMap, Map<Id, SObject> newValueMap, List<String> fieldList) {
        SObject oldValue;
        SObject newValue;
        List<String> batchList = new List<String>();
        
        for(Id recordid: oldValueMap.keySet()) {
            oldValue = oldValueMap.get(recordid);
            newValue = newValueMap.get(recordid);
            
            if (isValueChanged(oldValue, newValue, fieldList)) {
                batchList.add(recordId);      
            }           
        }
        return batchList;
    }   
    //Rev 10.0-end
    
    //Rev 16.0 changes start
    public static string addIntegrationException(String objectType,String objectId,String response){
        return  DBUtils.addSingleException('CMI Integration', 
                                        objectType, 
                                        objectId, 
                                        'Integration', 
                                        'CMI_INTEGRATION_FAILED',
                                        'CMI integration failed. Response XML is in Notes field' , 
                                        'Response from CMI\n--------------\n' +response );
    }

    public static string addIntegrationException(String objectType,String objectId,String ErrorCodes,String ErrorMessages, String response){
        return  DBUtils.addSingleException('CMI Integration', 
                                        objectType, 
                                        objectId, 
                                        'Integration', 
                                        ErrorCodes,
                                        ErrorMessages , 
                                        'Response from CMI\n--------------\n' +response );
    }   //Rev 16.0 changes End      
}
/***********************************************************
* Name          : GoalIntegrationUtils
* Description   : All methods for Goal Integration
* ---------------------------------------------------------
* Revision      Release     Name    Date            Description
* 1.0                       MenMee  08.03.2010      Creation
* 2.0                       MenMee  14.09.2010      CR4379 Change field reference from vState to Status
* 3.0                       MenMee  19.11.2010      Defect63927 Status (level 1) get overwritten by Status (level 2)
* 4.0           12.3        MenMee  31.03.2011      Defect69674 Don't display error code
* 4.1           12.3        MenMee  05.04.2011      Defect69687 Customize error message
* 5.0           12.10       Jessie  09.09.2011      CR6458 'Commit -90%' will update to Goal as 'Win', StageToGoalStatus is introduced
* 6.0           13.4        RP      22.03.2012      CR6458 'Commit -90%' will update to Goal as 'Win', StageToGoalStatus is Re-introduced
* 7.0           16.07       Carrie  24.06.2015      CR11394 Populate Competitor_Lost_To__c value to GOAL PrimaryCompetitor whenever the value is updated in SFDC
* 8.0           DCS-0401    Emily   05-Mar-2018     CR15486 Field Trip clean up for Opportunity
* 9.0       FY20-DCE-0202   Meenu   08-Jan-2019     16970   Field Trip clean up for Opportunity (remove/comment cfi_cfs_yes_no__c field)
* 10.0          FY20-1101   Arti    19-Sep-2019     6347751 07804 – GOAL Format Updates (Converted PCF goal functionality from soap to rest API)
* 11.0         FY21-0202    Arti    16-Dec-2019     Story 7795876- modified code for Goal Field mapping 
************************************************************/

public class GoalIntegrationUtils {

    public class GoalDeal {
        public string vid {get; set;}
        public string sfdcdealid {get; set;}
        public string goalId {get; set;}
        public string goalName {get; set;}
        public string status {get; set;}    //Rev 2.0
        public string submitDate {get; set;}
        public string dealWinLoss {get; set;}
        public string lastModified{get; set;}
        public string totalRevenue {get; set;}
        public string marginPercent {get; set;}
        //public string vCode {get; set;}
        //public string vMessage {get; set;}
        public string strsfdcwinloss {get; set;}
        public string strmsgId {get; set;}
        public string AccountName {get; set;}

    }

    //Class Variables
    public static final Integer TIMEOUT = 60000;
    public static final String METHOD = 'POST';
    public static boolean AUTHENTICATIONREQUIRED = false;
    public static String USERNAME;
    public static String PASSWORD;
    public static String ENDPOINT;
    public static String SERVICE_NAME;
    public static GoalDeal[] goalDealList;
    public static boolean isErrorResponse = false;
    public static boolean isRunTest = false;
    public static String faultCode;
    public static String faultString;

    private static boolean blnWinLoss = false;
    private static final String RESPONSE_SUCCESS = 'return';
    private static final String RESPONSE_ERROR = 'fault';
    private static final String RESPONSE_GET_SUCCESS = 'NestedAgreement';
    private static final String SERVICE_CREATE = 'SERVICE_CREATE';
    private static final String SERVICE_GET = 'SERVICE_GET';
    private static final String SERVICE_UPDATE = 'SERVICE_UPDATE';
    private static final String GOAL_DEAL_STATUS_APPROVED = 'APPROVED';
    
    /*
    This revision history is only applicable to the below processGoalIntegration()
    
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR2487                  26-Apr-2010                     Win/Loss update to GOAL
    2.0         CR3331                  08-Jul-2010                     Fix GOAL Related issue
    3.0         CR6089                  11-Apr-2011                     Limit 10 CallOuts to VendavoCallOutService each time
    4.0         CR6458                  22-Mar-2012                     'Commit -90%' will update to Goal as 'Win', StageToGoalStatus is introduced (R13.4)
    5.0         CR8577                  16-Aug-2013                     New record type 'Channel Opportunity' should have same functionality as Standard Opportunity
    6.0         CR10496     15.10       22-Sep-2014     Ragu            This logic is separated from opportunityTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void processGoalIntegration(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities) {
        boolean skipSendSupportMail = false;
        list<String> lstDealIds = new list<String>();
        // v5.0 - Added Channel Opportunity in the below record type get method
        set<Id> setStdAndChannelRTIds = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set<String>{'Standard Opportunity', 'Channel Opportunity'});
        try {
            // v2.0 - Start
            //Map<String,String> SFDCStageToGoalStatusMap = new Map<String, String> {'Win - 100%' => 'Win', 'Lost, Cancelled - 0%' => 'Loss'};
            // v4.0 - Start: JC
            map<String, String> SFDCStageToGoalStatusMap = GoalIntegrationUtils.getStageToGoalStatusMap();
            // v4.0 - End
            // v2.0 - End
            for(Opportunity newOpportunity : lstNewOpportunities) {
                Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
                // v2.0 - Start
                if(setStdAndChannelRTIds.contains(newOpportunity.RecordTypeId)) {                    
                    // v3.0 - Only invoke VendavoCallOutService when Stage change from 1) Win<=>Loss, 2) Win/Loss<=>Other values
                    String newStage = SFDCStageToGoalStatusMap.get(newOpportunity.StageName);
                    String oldStage = SFDCStageToGoalStatusMap.get(oldOpportunity.StageName); 
                     System.debug('DEBUG: BEFORE LIMIT FUTURECALL = '+newStage);
                      System.debug('DEBUG: BEFORE LIMIT FUTURECALL = '+oldStage);
                    System.debug('@@@95DEBUG: BEFORE LIMIT FUTURECALL = '+(!StringUtils.equalsIgnoreCase(newOpportunity.Competitor_Lost_To__c, oldOpportunity.Competitor_Lost_To__c)));  
                    if(!StringUtils.equalsIgnoreCase(newStage, oldStage) ||(!StringUtils.equalsIgnoreCase(newOpportunity.Competitor_Lost_To__c, oldOpportunity.Competitor_Lost_To__c))) {                        
                       
                        lstDealIds.add(newOpportunity.Deal_Id__c); 
                         System.debug('DEBUG: BEFORE LIMIT FUTURECALL = '+lstDealIds);
                    }
                }
            }
            boolean goalIsEnabled = boolean.valueOf(System.label.GOAL_Is_Enabled);
            if(goalIsEnabled && !lstDealIds.isEmpty()) {
                skipSendSupportMail = true;
                list<String> lstDealIdsLocal = new list<String>();
                // v3.0 - Start
                for(integer i=0; i<lstDealIds.size(); i++) {
                    lstDealIdsLocal.add(lstDealIds[i]);
                    if(lstDealIdsLocal.size() == 10 || lstDealIds.size() == (i+1)) {
                        System.debug('DEBUG: BEFORE LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
                        if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls()) {
                            System.debug('GOAL VendavoCallOutService has hit Salesforce.com FutureCall Limit.');
                        }
                        else {
                            GoalIntegrationUtils.updateWinLossWS(lstDealIdsLocal);
                            System.debug('DEBUG: AFTER LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
                            System.debug('@@@113DEBUG: AFTER LIMIT FUTURECALL = ' + lstDealIdsLocal + ' of ' + GoalIntegrationUtils.updateWinLossWS(lstDealIdsLocal));

                            
                        }
                        lstDealIdsLocal.clear();
                    }
                }
                // v3.0 End
            }
        }
        catch(Exception e) {
            system.debug('KP: Caught APEX Exception : ' + e.getMessage());
            if(!skipSendSupportMail) {
                emailUtils.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
            }
        }
    }
    
    //Method to call "Create New Goal Deal" web service
    // Modified query added- PartnerAccountid, PartnerAccount.Account_ID__c,End_User_Account_Name__c as partof Story 7795876
    public static string createNewGoalDealURL(String dealId){
        String vendavoURL = null;
        String response = null;
        System.debug('## In createNewGoalDealURL ##');
        if (!isRunTest) {
            /*9.0       FY20-DCE-0202   Meenu   08-Jan-2019     16970   Field Trip clean up for Opportunity, removed CFI_CFS_Yes_No__c from query */
            //Query Opportunity to get data to be passed
            List<Opportunity> oppList = [SELECT /*8.0 Special_Packaging_Yes_No__c,*/ //Single_Delivery_Yes_No__c,
                                            Primary_Product_Delivery_Address_Region__c,
                                            Primary_Product_Delivery_Address_Country__c, 
                                            Partner_Account_Name__c, Name, Justification_Statement__c, Id,Competitor_Lost_To__c,
                                            Delivery_Date__c, Deal_Registration_Status__c, Deal_ID__c,Secondary_Competitor_CI__c,
                                            End_User_Account_Name__c, Account.Account_ID__c, Account.Name, AccountId, Session_Id__c, StageName,Quote_Numbers__c,PartnerAccountid, PartnerAccount.Account_ID__c,
                                         Is_CFI_included__c,CFS_Special_Packaging__c,How_many_shipments__c,Unweighted_Rev_Formula__c,createdby.email,
                                         CloseDate FROM Opportunity
                                         WHERE Deal_Id__c = :dealId];

            if(oppList.size()>0){
                //create request body from the Account record
                String requestBody = createGoalDealHTTPRequestBodyString(oppList[0]);
                System.debug('## RequestBody: ' + requestBody);
                SERVICE_NAME = 'SFADeal/DealCreateVendavoService';
                response = sendHttpRequest(requestBody);   
            }
            GoalDeal[] goalDeals = parseGoalDeals(response);
            if (goalDeals != null && goalDeals.size() > 0 && goalDeals[0].vid!= null) {//added 
                //vendavoURL = 'http://pensptdev01/vendavo/pc?page=vx.deals.NestedAgreement.OpenDetailWSForNestedAgreement&vid='+goalDeals[0].vid;
                  vendavoURL = System.Label.GOAL_Page_URL + goalDeals[0].vid;//added
            }
        }
        System.debug('## vendavoURL: '+vendavoURL);
        return vendavoURL;
    }

    //Method to construct Body for create new Goal Deal
    /*public static String createGoalDealHTTPRequestBodyString(Opportunity opptyRecord){
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('urn', 'urn:enterprise.soap.sforce.com');
        w.writeStartElement('soapenv', 'Header', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeStartElement('urn', 'SessionHeader', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeStartElement('urn', 'sessionId', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeCharacters(opptyRecord.Session_Id__c);
        w.writeEndElement();    //SessionId
        w.writeEndElement();    //SessionHeader
        w.writeEndElement();    //header
        w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeStartElement('urn', 'query', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeStartElement('urn', 'queryString', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeCharacters(opptyRecord.Deal_Id__c);
        w.writeEndElement(); //queryString
        w.writeEndElement(); //query
        w.writeEndElement(); //Body
        w.writeEndElement(); //Envelope
        return w.getXmlString();
    }*/

    public static String createGoalDealHTTPRequestBodyString(Opportunity opptyRecord){
   
  JSONGenerator gen = JSON.createGenerator(true);    
  /*<!--
  gen.writeStartObject();      
  gen.writeStringField('Content-Type','application/json' );
  gen.writeStringField('username','ServiceSOASFDC');
  gen.writeStringField('password','Passw0rd_');
  gen.writeEndObject(); 
  -->*/
  //Added by Arti as part of Story 7795876   ---- start --
  String strPartneraccount =''; 
  String strPartneraccountName =''; 
  String strSFDCEndUserAccountName ='';
  if(opptyRecord.PartnerAccount!=null){
     strPartneraccount=  opptyRecord.PartnerAccount.Account_ID__c;
     strPartneraccountName= opptyRecord.PartnerAccount.Account_ID__c;
     strSFDCEndUserAccountName= opptyRecord.End_User_Account_Name__c;
  }
  else {
   strPartneraccount=opptyRecord.Account.Account_ID__c;
   strPartneraccountName='';
   strSFDCEndUserAccountName='';
  }
  //Added by Arti as part of Story 7795876   ---- End --
   map<String, String> mapSFDCStageToGoalStatus = getStageToGoalStatusMap();
  String[] strEmail= UserInfo.getUserEmail().split('@');
  gen.writeStartObject(); 
  gen.writeStringField('SFDCDealId',opptyRecord.Deal_ID__c );
  gen.writeStringField('SFDCOppName',opptyRecord.Name);
  //gen.writeStringField('AccountName',opptyRecord.Account.Account_ID__c);
  gen.writeStringField('AccountName',strPartneraccount);//Added by Arti as part of Story 7795876 mapping changes
  gen.writeStringField('EndUserAccountName' , checkfieldvalues(opptyRecord.Account.Account_ID__c)); 
  gen.writeStringField('SFDCOppId',opptyRecord.id);
  gen.writeStringField('PrimaryCompetitor',checkfieldvalues(opptyRecord.Competitor_Lost_To__c));
  gen.writeStringField('SecondCompetitor' , checkfieldvalues(opptyRecord.Secondary_Competitor_CI__c));
  //gen.writeStringField('PartnerAccount' , checkfieldvalues(opptyRecord.Account.Account_ID__c));
  gen.writeStringField('PartnerAccount' , checkfieldvalues(strPartneraccountName));//Added by Arti as part of Story 7795876 mapping changes
  //gen.writeStringField('SFDCEndUserAccount' , checkfieldvalues(opptyRecord.Account.Account_ID__c));
  gen.writeStringField('SFDCEndUserAccount' , checkfieldvalues(strSFDCEndUserAccountName));//Added by Arti as part of Story 7795876 mapping changes
  gen.writeStringField('Justification' , checkfieldvalues(opptyRecord.Justification_Statement__c));
  gen.writeStringField('DealRegStatus' ,checkfieldvalues(opptyRecord.Deal_Registration_Status__c)); 
  gen.writeStringField('LotNumber' , checkfieldvalues(opptyRecord.Quote_Numbers__c));
  gen.writeStringField('PrimaryAddressRegion' , checkfieldvalues(opptyRecord.Primary_Product_Delivery_Address_Region__c));
  gen.writeStringField('PrimaryAddressCountry' , checkfieldvalues(opptyRecord.Primary_Product_Delivery_Address_Country__c)); 
  gen.writeStringField('SingleDelivery' , checkfieldvalues(String.valueOf(opptyRecord.How_many_shipments__c)));
  gen.writeStringField('CFICFS' ,  checkfieldvalues(opptyRecord.Is_CFI_included__c));
  gen.writeStringField('SpecialPackaging' ,checkfieldvalues(opptyRecord.CFS_Special_Packaging__c));
  gen.writeStringField('DealWinLoss' ,opptyRecord.StageName);
  //gen.writeStringField('SFDCWinLoss' ,opptyRecord.StageName);
  gen.writeStringField('wsCreatedBy' , strEmail[0]);
  gen.writeStringField('wsLastModifiedBy' ,strEmail[0]);
  //gen.writeStringField('ExpectedOrderDate' , ''); 
  gen.writeStringField('SFDCDealSize' , checkfieldvalues(opptyRecord.Unweighted_Rev_Formula__c));
  gen.writeStringField('ExpectedOrderDate' , checkfieldvalues(String.valueOf(opptyRecord.CloseDate)));
  gen.writeEndObject();
  String strjsonS = gen.getAsString();    
  return strjsonS;
  
    }
  
    //R5.0 - start
    public static Map<String,String> getStageToGoalStatusMap(){
        Map<String,String> InternalStageToGoalStatusMap = new Map<String, String>();
        System.debug('## 233 stageToGoalStatusList size : ' + System.Label.StageToGoalStatus);
        List<String> stageToGoalStatusList = StringUtils.split(System.Label.StageToGoalStatus, '|');
        System.debug('## stageToGoalStatusList size :' + stageToGoalStatusList.size());
        for(String stageToGoalStatus:stageToGoalStatusList){
            List<String> tokens = StringUtils.split(stageToGoalStatus, ':');
            InternalStageToGoalStatusMap.put(tokens[0], tokens[1]);
            System.debug('## stage [' + tokens[0] +'] map with goal status [' + tokens[1] +']');
        }
        return InternalStageToGoalStatusMap;
    }
    //R5.0 - end
    //Method to call "Find Goal Deal List" web service
    public static GoalDeal[] getGoalDealBySFDCDealId(Opportunity opp, Integer pageNumber, Integer batchSize) {
        System.debug('## In getGoalDealBySFDCDealId method ##');
        if (!isRunTest) {
            String requestBody = goalDealListingHTTPRequestBodyString(opp.Deal_Id__c, pageNumber, batchSize);
            System.debug('## RequestBody for getGoalDealBySFDCDealId: ' + requestBody);
            SERVICE_NAME = 'SFADeal/DealQueryAllBySFDCDealIdService';
            string response = sendHttpRequest(requestBody);
            //response = processResponseJson (response);
            goalDealList = parseGoalDeals(response);
            System.debug('##262 RequestBody for getGoalDealBySFDCDealId: ' + response);
            map<String, String> SFDCStageToGoalStatusMap = getStageToGoalStatusMap();
            
            for(goalDeal gd: goalDealList) {
                if (gd.vid != null && (!StringUtils.equalsIgnoreCase(SFDCStageToGoalStatusMap.get(opp.StageName), gd.dealWinLoss)) && (blnWinLoss == false)){
                    blnWinLoss = false;
                }
                     System.debug('## 255 Opp(stageName): '+blnWinLoss +'->'+ SFDCStageToGoalStatusMap.get(opp.StageName) + ' Goal: ' + gd.dealWinLoss);
                     System.debug('## 256 Opp(stageName): '+gd.vid);
             }
        }
        return goalDealList;
    }

    //Method to process Response XML
    /*public static string processResponseJson (string jSonResponse){
        // Uncomment this if anything wrong - This is the backup logic
        //system.debug('### XMLResponse before Processing is    ' + xmlResponse.length());
       // xmlResponse = xmlResponse.replaceAll('<VItems[^>]*>.*?</VItems>', '');
       // system.debug('### XMLResponse after Processing is    ' + xmlResponse.length());
        
        // Start of XML clipping
            if(jSonResponse.contains('<SFDCDealId>')) {
            system.debug('##### BeforeLength' + jSonResponse.length());
            list<string> jsonSplit = jSonResponse.split('<SFDCDealId>');
            List<string> jsonSplitNew = new List<string>();
            for(String str : jsonSplit  ){
               str = str.replaceAll('(?s)<VItems[^>]*>.*?</VItems>', '');
              str  = str.replaceAll('(?m)^[ \t]*\r?\n', '');
                jsonSplitNew.add(str);
            }
        string reformedJSON = '';
        Integer i = 0 ;
        for(String str : jsonSplitNew){
             if(i == 0)
                reformedJSON = reformedJSON + str ;
            else
                reformedJSON = reformedJSON + '<SFDCDealId>' + str ;
            i++;
        }
        jSonResponse = reformedJSON ;
        //nameFile = nameFile.replaceAll('(?s)<VItems[^>]*>.*?</VItems>', '');
        system.debug('##### AfterLength' + jSonResponse.length());
        system.debug('##### AfterXML' + jSonResponse);
        } // End of XML clipping
        return jSonResponse;
    }*/
    //Method to construct Body for getting Goal Deal Listing
   /* public static String goalDealListingHTTPRequestBodyString(String dealId, Integer pageNumber, Integer batchSize){
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('typ', 'http://www.vendavo.com/ws/types');
        w.writeEmptyElement('soapenv', 'Header', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeStartElement('typ', 'find', 'http://www.vendavo.com/ws/types');
        w= addElementAndValueString(w, 'entityQuery', dealId);
        w= addElementAndValueString(w, 'pageNumber', string.valueOf(pageNumber));
        w= addElementAndValueString(w, 'batchSize', string.valueOf(batchSize));
        w.writeEndElement(); //find
        w.writeEndElement(); //Body
        w.writeEndElement(); //Envelope
        return w.getXmlString();
    }*/
    
    public static String goalDealListingHTTPRequestBodyString(String strdealId, Integer intpageNumber, Integer intbatchSize){  
      
  JSONGenerator gen = JSON.createGenerator(true);    
  /*<!--
  gen.writeStartObject();      
  gen.writeStringField('Content-Type','application/json' );
  gen.writeStringField('username','ServiceSOASFDC');
  gen.writeStringField('password','Passw0rd_');
  gen.writeEndObject();
  --> */  
  gen.writeStartObject(); 
  //gen.writeStringField('entityQuery','select * from NestedAgreement where sfdcdealid = '+ strdealid );
  //gen.writeStringField('entityQuery','select * from NestedAgreement where sfdcdealid = \'' + strdealid + '\''+'and vstate_vname = \'approved\' ');
  gen.writeStringField('entityQuery','select * from NestedAgreement where sfdcdealid = \'' + strdealid + '\'');
  gen.writeStringField('currentPage',string.valueOf(intpageNumber) );  
  gen.writeStringField('pageSize',string.valueOf(intbatchSize) );  
  
  gen.writeEndObject();
  String strjsonS = gen.getAsString();
    return strjsonS;
  
    }
    //Method to update all goal deals
    @future(callout=true)
    public static void updateWinLossWS(List<String> SFDCDealIdList) {
        system.debug('## START OF FUTURE METHOD #');
        system.debug('## DMLStatements#: ' + Limits.getDMLStatements());
        system.debug('## DMLStatements Limit#: ' + Limits.getLimitDMLStatements());
        system.debug('## DMLRows#: ' + Limits.getDMLRows());
        system.debug('## DMLRows Limit#: ' + Limits.getLimitDMLRows());
        system.debug('## START OF FUTURE METHOD #');
        try {
            system.debug('## 352 SFDCDealIdList'+SFDCDealIdList);
            updateWinLoss(SFDCDealIdList);
        }
        catch (Exception e) {
            System.debug('## [Code: GoalIntegationUtils:updateWinLossWS] '+e.getMessage());
        }
        system.debug('## END OF FUTURE METHOD #');
        system.debug('## DMLStatements#: ' + Limits.getDMLStatements());
        system.debug('## DMLStatements Limit#: ' + Limits.getLimitDMLStatements());
        system.debug('## DMLRows#: ' + Limits.getDMLRows());
        system.debug('## DMLRows Limit#: ' + Limits.getLimitDMLRows());
        system.debug('## END OF FUTURE METHOD #');
    }

    //Method to update all goal deals
    public static void updateWinLoss(List<String> SFDCDealIdList) {
        System.debug('## In updateWinLoss method ##');

        if (!isRunTest) {
            blnWinLoss = false;
            List<Opportunity> oppList = [SELECT Id, Deal_Id__c, StageName, Competitor_Lost_To__c,Secondary_Competitor_CI__c
                                         FROM Opportunity
                                         WHERE Deal_Id__c IN :SFDCDealIdList];
            for(Opportunity opp: oppList) {
                String requestBody = updateWinLossHTTPRequestBodyString(opp.Deal_Id__c, opp.StageName, opp.Competitor_Lost_To__c, opp.Secondary_Competitor_CI__c);
                System.debug('## RequestBody for updateWinLoss: ' + requestBody);
                SERVICE_NAME = 'SFADeal/VendavoCallOutService';
                string response = sendHttpRequest(requestBody);
                //Rev 4.1
                System.debug('##376 In updateWinLoss method ##'+response);
                GoalDeal[] goalDeals = parseGoalDeals(response);
            }
        }
    }

    //Method to construct Body for updte Goal Deal Status
   /* public static String updateWinLossHTTPRequestBodyString(String dealId, String stageName, string primaryCompetitor) {
        map<String, String> SFDCStageToGoalStatusMap = getStageToGoalStatusMap();
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('typ', 'http://www.vendavo.com/ws/types');
        w.writeEmptyElement('soapenv', 'Header', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeStartElement('soapenv', 'Body','http://schemas.xmlsoap.org/soap/envelope/');
        w.writeStartElement('typ', 'UpdateWinLoss', 'http://www.vendavo.com/ws/types');
        w.writeStartElement(null, 'entities', null);
        w.writeStartElement(null, 'NestedAgreement', null);
        w = addElementAndValueString(w, 'SFDCDealId', dealId);
        //w = addElementAndValueString(w, 'DealWinLoss', SFDCStageToGoalStatusMap.get(stageName));
        //R5.0 - start
        w = addElementAndValueString(w, 'DealWinLoss', SFDCStageToGoalStatusMap.get(stageName));
        w = addElementAndValueString(w, 'PrimaryCompetitor', primaryCompetitor);
        //R5.0 - end
        String userNameWithoutDomain = StringUtils.split(UserInfo.getUserName(), '@')[0];
        System.debug('##: '+userNameWithoutDomain);
        w = addElementAndValueString(w, 'wsCreatedBy', userNameWithoutDomain);
        w = addElementAndValueString(w, 'wsLastModifiedBy', userNameWithoutDomain);
        w.writeEndElement(); //NestedAgreement
        w.writeEndElement(); //entities
        w.writeEndElement(); //UpdateWinLoss
        w.writeEndElement(); //Body
        w.writeEndElement(); //Envelope
        return w.getXmlString();
    }*/
    
    public static String updateWinLossHTTPRequestBodyString(String strdealId, String strstageName, string strprimaryCompetitor, string strSecondaryCompetitor) {
        map<String, String> mapSFDCStageToGoalStatus = getStageToGoalStatusMap();
        JSONGenerator gen = JSON.createGenerator(true);    
    /*<!--
    gen.writeStartObject();      
    gen.writeStringField('Content-Type','application/json' );
    gen.writeStringField('username','ServiceSOASFDC');
    gen.writeStringField('password','Passw0rd_');
    gen.writeEndObject(); 
    -->*/
    
    gen.writeStartObject(); 
    gen.writeStringField('SFDCDealId', strdealId );
    gen.writeStringField('DealWinLoss',checkfieldvalues(mapSFDCStageToGoalStatus.get(strstageName)));
    gen.writeStringField('PrimaryCompetitor',checkfieldvalues(strprimaryCompetitor));
    gen.writeStringField('SecondCompetitor' , checkfieldvalues(strSecondaryCompetitor));
   // String struserNameWithoutDomain = StringUtils.split(UserInfo.getUserName(), '@')[0];
    //    System.debug('##: '+struserNameWithoutDomain);
    //gen.writeStringField('wsCreatedBy' , struserNameWithoutDomain); 
    //gen.writeStringField('wsLastModifiedBy',struserNameWithoutDomain);
    gen.writeEndObject();
    String strjsonS = gen.getAsString();
    return strjsonS;
    }

    //Method to parse XML repsonse string into GoalDealList
    public static GoalDeal[] parseGoalDeals(string strresponse) {
        GoalDeal[] listgoalDeals = new list<GoalDeal>();
        System.JSONParser parser = System.JSON.createParser(strresponse);
        if (parser.getCurrentToken() == null) parser.nextToken();
        
        Integer i=1;
        while (parser.nextToken() != System.JSONToken.END_ARRAY) {
            i=i+1;
         System.debug('##----------------i: '+i);   
            listgoalDeals.add(parseGoalDeal(parser));
        }
        
        System.debug('##----------------size: '+listgoalDeals.size());
        return listgoalDeals;
    }

    //Method to parse XML repsonse string into GoalDeal
    //Set all elements in lower case
   /* public static GoalDeal parseGoalDeal(XmlStreamReader reader) {
        GoalDeal goalDeal = new GoalDeal();
        string currentElement;
        boolean isSkipElement = false;
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                currentElement = reader.getLocalName().toLowerCase();
                System.debug('## Start Element 1: '+ currentElement);
            }
            else if (reader.getEventType() == XmlTag.END_ELEMENT) {
                System.debug('## End Element: '+ currentElement);
                if (StringUtils.equalsIgnoreCase(reader.getLocalName(), RESPONSE_SUCCESS) ||
                    StringUtils.equalsIgnoreCase(reader.getLocalName(), RESPONSE_ERROR) ||
                    StringUtils.equalsIgnoreCase(reader.getLocalName(), RESPONSE_GET_SUCCESS)) {
                    break;
                }
            }
            else if (reader.getEventType() == XmlTag.CHARACTERS){
                if(isSkipElement){
                    reader.next();
                    continue;
                }
                System.debug('## value: '+reader.getText());
                //Rev 3.0 Only get value of first level
                // Parse response from DealQueryAllBySFDCDealIdService
                if (currentElement == 'vid'){
                    if (goalDeal.vid == null) goalDeal.vid = reader.getText();
                }
                else if (currentElement == 'goalid'){
                    if (goalDeal.goalId == null) goalDeal.goalId = reader.getText();
                }
                else if (currentElement == 'goalname'){
                    if (goalDeal.goalName == null) goalDeal.goalName = reader.getText();
                }
                //Rev 2.0
                else if (currentElement == 'status'){
                    if (goalDeal.status == null) goalDeal.status = StringUtils.capitalize(reader.getText());
                }
                else if (currentElement == 'lastmodified'){
                    if (goalDeal.lastModified == null) goalDeal.lastModified = convertDateToLocaleFormat(reader.getText());
                }
                else if (currentElement == 'submitdate'){
                    if (goalDeal.submitDate == null) goalDeal.submitDate = convertDateToLocaleFormat(reader.getText());
                }
                else if (currentElement == 'totalrevenue'){
                    if (goalDeal.totalRevenue == null) goalDeal.totalRevenue = convertCurrencyFormat(reader.getText());
                }
                else if (currentElement == 'marginpercent'){
                    if (goalDeal.marginPercent == null) goalDeal.marginPercent = reader.getText();
                }
                //R5.0 - start
                //else if (currentElement == 'dealwinloss'){
               //     if (goalDeal.dealWinLoss == null) goalDeal.dealWinLoss = reader.getText();
               // }
                else if (currentElement == 'sfdcwinloss'){
                    if (goalDeal.dealWinLoss == null) goalDeal.dealWinLoss = reader.getText();
                }
                //R5.0 - end

                //Parse response from VendavoCallOutService
                else if (currentElement == 'vcode'){
                    if (GoalDeal.vCode == null) goalDeal.vCode = reader.getText();
                }
                else if (currentElement == 'vmessage'){
                    if (goalDeal.vMessage == null) {
                        goalDeal.vMessage = reader.getText();

                        //Rev 4.1
                        if (StringUtils.contains(goalDeal.vMessage, 'VEN-CL-1079')) {
                            faultCode = 'VEN-CL-1079';
                            isErrorResponse = true;
                        }
                    }
                }
                //Parse error code and error string return from Goal (faultCode, faultString)
                //Parse error code and error string return from service bus (errorCode, reason)
                //Unknown error code and error string return from Data Power (Value, Text)
                else if (currentElement == 'faultcode' || currentElement == 'errorcode' || currentElement == 'value'){
                    if (faultCode == null)
                        faultCode = reader.getText();
                    else
                        faultCode = faultCode + '<br /> ' + reader.getText();
                }
                else if (currentElement == 'faultstring' || currentElement == 'reason' || currentElement == 'text'){
                    if (faultString == null)
                        faultString = reader.getText();
                    else
                        faultString = faultString + '<br /> ' + reader.getText();
                }
            }
            reader.next();
        }

        //Rev 2.0
        //blank off totalRevenue and marginPercent if vState <> 'Approved'
        //Do it here instead of above, to cater if both totalRevenue and marginPercent element is locate before vState
        if (!StringUtils.equalsIgnoreCase(goalDeal.status, GOAL_DEAL_STATUS_APPROVED)) {
            goalDeal.totalRevenue = '';
            goalDeal.marginPercent = '';
        }
        return goalDeal;
    }*/


public static GoalDeal parseGoalDeal(JSONParser parser) {
        GoalDeal objgoal = new GoalDeal();
        string strcurrentElement;
        boolean strStatus=false;
        boolean strNoOppAssociated=false;
        //HTTPResponse res = new HTTPResponse();
       
        while(parser.nextToken() != System.JSONToken.END_OBJECT) {
            
            //if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
            //if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                
                strcurrentElement = parser.getText().toLowerCase();
                
            
            if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
             
               
                if (strcurrentElement == 'sfdcdealid'){
                     objgoal.sfdcdealid = parser.getText();
                    
                }
                else if (strcurrentElement == 'goalid'){
                      objgoal.goalId = parser.getText();
                    
                }
                 else if (strcurrentElement == 'vid'){
                        objgoal.vid = parser.getText();
                    
                }
               
                else if (strcurrentElement == 'goalname'){
                        objgoal.goalName = parser.getText();
                    
                }
                 else if (strcurrentElement == 'sfdcwinloss'){
                    if (objgoal.dealWinLoss == null){
                     objgoal.dealWinLoss = parser.getText();
                    }
                
                }
                //Rev 2.0
                else if (strcurrentElement == 'status'){
                       objgoal.status = StringUtils.capitalize(parser.getText());
                       strStatus= true;
                       /*if(StringUtils.contains(objgoal.status.toLowerCase(), 'fault:ven-omi-1012')){
                         faultCode = 'fault:ven-omi-1012';
                         isErrorResponse = true;  
                           
                       }*/
                       
                }
                else if (strcurrentElement == 'lastmodified'){
                        objgoal.lastModified = convertDateToLocaleFormat(parser.getText());
                    
                }
                /*else if (strcurrentElement == 'dealwinloss'){
                        if (objgoal.dealWinLoss == null){
                     objgoal.dealWinLoss = parser.getText();
                    }
                    
                }*/
               
                else if (strcurrentElement == 'submitdate'){
                        objgoal.submitDate = convertDateToLocaleFormat(parser.getText());
                    
                }
                else if (strcurrentElement == 'TotalRevenue'){
                  if (objgoal.totalRevenue == null) {
                      objgoal.totalRevenue = 'USD '+String.valueof(convertCurrencyFormat(parser.getDecimalValue()));
                    
                }
                }
                
                else if (strcurrentElement == 'marginpercent'){
                        objgoal.marginPercent = String.valueof(convertCurrencyFormat(parser.getDecimalValue()));
                }
                else if (strcurrentElement == 'AccountName'){
                        objgoal.AccountName = parser.getText();
                }
                else if (strcurrentElement == 'msgId'){
                    if (objgoal.strmsgId == null) {
                        objgoal.strmsgId = parser.getText();
                          //isErrorResponse = true;
                        // strNoOppAssociated=true;
                        //Rev 4.1
                        if (StringUtils.contains(objgoal.strmsgId, '')) {
                            faultCode = 'fault:ven-query-1008';
                            isErrorResponse = true;
                        }
                    }
                }
                /*else if(StringUtils.contains(objgoal.status.toLowerCase(), 'fault:ven-omi-1012')){
                         faultCode = 'fault:ven-omi-1012';
                         isErrorResponse = true;  
                           
                       }*/
                       
                else{
                   consumeObject(parser); 
                    
                }
                /*else if (strcurrentElement == 'submitdate'){
                    if (objgoal.submitDate == null) {
                        objgoal.submitDate = convertDateToLocaleFormat(parser.getText());
                    }
                }
                else if (strcurrentElement == 'totalrevenue'){
                    if (objgoal.totalRevenue == null) {
                        objgoal.totalRevenue = convertCurrencyFormat(parser.getText());
                    }
                }
                else if (strcurrentElement == 'marginpercent'){
                    if (objgoal.marginPercent == null) {
                        objgoal.marginPercent = parser.getText();
                    }
                }
                //R5.0 - start
                //else if (strcurrentElement == 'dealwinloss'){
               //     if (goalDeal.dealWinLoss == null) goalDeal.dealWinLoss = parser.getText();
               // }
                else if (strcurrentElement == 'sfdcwinloss'){
                    if (objgoal.dealWinLoss == null) {
                        objgoal.dealWinLoss = parser.getText();
                    }
                }
                //R5.0 - end

                //Parse response from VendavoCallOutService
                else if (strcurrentElement == 'vcode'){
                    if (objgoal.vCode == null) {
                        objgoal.vCode = parser.getText();
                    }
                }*/
               /* else if (strcurrentElement == 'AccountName'){
                    if (objgoal.AccountName == null) {
                    System.debug('####652 errorMessage'+strcurrentElement);
                        objgoal.AccountName = parser.getText();
                        //faultCode = 'please provide account';
                    }
                }*/
                
                /*else if (strcurrentElement == 'vmessage'){
                    if (objgoal.vMessage == null) {
                        objgoal.vMessage = parser.getText();

                        //Rev 4.1
                        if (StringUtils.contains(objgoal.vMessage, 'VEN-CL-1079')) {
                            faultCode = 'VEN-CL-1079';
                            isErrorResponse = true;
                        }
                    }
                }*/
                //Parse error code and error string return from Goal (faultCode, faultString)
                //Parse error code and error string return from service bus (errorCode, reason)
                //Unknown error code and error string return from Data Power (Value, Text)
                /*else if (strcurrentElement == 'faultcode' || strcurrentElement == 'errorcode' || strcurrentElement == 'value'){
                    if (faultCode == null){
                        faultCode = parser.getText();
                    }
                    else {
                        faultCode = faultCode + '<br /> ' + parser.getText();
                    }
                }
                else if (strcurrentElement == 'faultstring' || strcurrentElement == 'reason' || strcurrentElement == 'text'){
                    if (faultString == null) {
                        faultString = parser.getText();
                    }
                    else {
                        faultString = faultString + '<br /> ' + parser.getText();
                    }
                }*/
                
               } 
            }
            
        }
        if (!StringUtils.equalsIgnoreCase(objgoal.status, GOAL_DEAL_STATUS_APPROVED)) {
            objgoal.totalRevenue = '';
            objgoal.marginPercent = '';
        }
       if (strStatus= true){
           if(StringUtils.contains(objgoal.status.toLowerCase(), 'fault:ven-omi-1012')){
                         faultCode = 'fault:ven-omi-1012';
                         isErrorResponse = true;  
                           
                       }
       /*if(strNoOppAssociated=true){
        if (StringUtils.contains(objgoal.strmsgId, '')) {
            faultCode = 'fault:ven-query-1008';
            isErrorResponse = true;
         }   
        }*/
       }
        //Rev 2.0
        //blank off totalRevenue and marginPercent if vState <> 'Approved'
        //Do it here instead of above, to cater if both totalRevenue and marginPercent element is locate before vState
        /*if (!StringUtils.equalsIgnoreCase(objgoal.status, GOAL_DEAL_STATUS_APPROVED)) {
            objgoal.totalRevenue = '';
            objgoal.marginPercent = '';
        }*/
        return objgoal;
    }
    //Added for PCF
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    //Defined whether to show "Refresh GOAL Win/Loss" button
    public static boolean showWinLossButton() {
        return blnWinLoss;
    }

    public static string handleFaultString(string errorCode) {
        return handleFaultString(errorCode, null);
    }

    //Rev 4.1
    public static string handleFaultString(string errorCode, string serviceType) {
        System.debug('## handleFaultString(IN): '+faultCode+':'+faultString);
        string errorString = null;
        string errorMessage = null;
        if(StringUtils.length(errorCode) > 0 ) {
            //Custom error string
            errorCode = StringUtils.lowerCase(errorCode.trim());
             if (serviceType == SERVICE_CREATE) {
                //Rev 4.1
                if (errorCode.contains('fault:ven-omi-1012')) errorString = 'You either currently do not have a profile in GOAL, or the Account you have selected is not valid in GOAL. Please try again or log a TT via Remedy.';
            }
            else if (serviceType == SERVICE_GET) {
                if (errorCode.contains('fault:ven-query-1008')) errorString = 'There is no GOAL deal associated with this opportunity';
            }
            else if (serviceType == SERVICE_UPDATE) {
                if (errorCode == 'ven-cl-1079') errorString = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';
            }
            if (errorString == null) {
                //Return connection fail if unknown error thrown by from data power/goal/sfdc service bus
                if (errorCode.contains('bea-') ||
                    errorCode.contains('error code provided by dataPower')) {
                    errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';
                }
                //Return original message
                else {
                    //Rev 4.1
                    errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';
                }
            }
            //Rev 4.0
            //if (errorMessage == null) errorMessage = '<b>'+ errorCode + '</b><br /><br />'+ errorString;
            if (errorMessage == null) errorMessage = errorString;
        }
        System.debug('## handleFaultString(OUT): '+ errorMessage);
        return errorMessage;
    }

    private static void setAuthenticationInfo() {

        //Set header parameters for Production
        System.debug('## Production: '+Environment.isProduction()+'->'+UserInfo.getOrganizationId());
        if (Environment.isProduction()) {
            ENDPOINT = System.Label.GOAL_DP_Prod_Server_URL + SERVICE_NAME;
            USERNAME = System.Label.GOAL_HTTP_Prod_Username;  //for PRODUCTION env
            PASSWORD = System.Label.GOAL_HTTP_Prod_Password; // to be filled in later
            authenticationRequired = true;
            System.debug('## PROD: '+ENDPOINT +': '+ USERNAME +' -> '+ PASSWORD);
        }
        //Set header parameters for Sandbox
        else{
            ENDPOINT = System.Label.GOAL_DP_Sandbox_Server_URL + SERVICE_NAME;
            USERNAME = System.Label.GOAL_HTTP_Sandbox_Username;
            PASSWORD = System.Label.GOAL_HTTP_Sandbox_Password;
            authenticationRequired = true;
            System.debug('## SANDBOX: '+ENDPOINT +': '+ USERNAME +' -> '+ PASSWORD);
        }
    }

    //Method to create HTTPRequest Header
    private static HttpRequest createHttpRequestHeader(){
        setAuthenticationInfo();
        HttpRequest req = new HttpRequest();
        //Set endpoint URL
        req.setEndpoint(ENDPOINT);
        //Set the method Type
        req.setMethod(METHOD);
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

    //Method to send HTTPRequest
    public static String sendHttpRequest(String requestBody){
            //method call to create HttpRequest
            HttpRequest req=createHttpRequestHeader();
            //sets the request body
            req.setBody(requestBody);
            Http http = new Http();
            System.debug('## Authorization Header: '+req.getHeader('Authorization'));
            //Sending the HTTP request
            HTTPResponse res = http.send(req);
            System.debug('## Response:'+res.getBody());
            //The response is not processed.
            return res.getBody();
    }

    //Method to add elemenet and value of type String to the XmlStreamWriter
    /*private static JSONGenerator addElementAndValueString(JSONGenerator w, String tagName, String value){
        w.writeObjectField(tagName, null);
        if(value == null){
            w.writeFieldName('');
        }
        else{
            w.writeFieldName(value);
        }
        w.writeEndObject();
        return w;
    }*/
     
    public static Decimal convertCurrencyFormat(Decimal myCurrency) {
        if (myCurrency == null) {
            return null;
        }
        //XML Amount is in the format xxx,xxx USD
        system.debug('inside currency: ');
        Decimal example = myCurrency.setScale(2);
        //String convertedCurrency = stringCurrency[1] + ' ' + stringCurrency[0];
        return example;
    }
    //Method to convert Date to Locale Format
    public static String convertDateToLocaleFormat(String strmyDate) {
        if (strmyDate == null) {
            return null;
        }
        //XML Date String is in the format yyyy-mm-dd
        String[] stringDate = strmyDate.split('-');
        Integer inty = Integer.valueOf(stringDate[0]);
        Integer intm = Integer.valueOf(stringDate[1]);
        Integer intd =  Integer.valueOf(stringDate[2]);
        Date dconvertedDate = date.newInstance(inty,intm,intd);
        return dconvertedDate.format();
    }
     public static string checkfieldvalues(string strval)
    {
        if(strval == null){        
        return '';        
        }return strval;
    }
    
}
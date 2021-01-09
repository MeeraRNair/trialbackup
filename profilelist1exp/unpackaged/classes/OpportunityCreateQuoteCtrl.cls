/***********************************************************
* Name          : OpportunityCreateQuoteCtrl
* ---------------------------------------------------------
* Revision       Release                   Name           Date                    CR            Description   
* 1.0           FY18-DCS-1101             Jatin/Sakshi  27 Sep 2017              14975          Encrypt the url before creating my quotes.
* 2.0           FY19-DCS-0203             Sakshi        11 Jan 2018              15020          Removed Account Country code
* 3.0           FY20-0202                 Abhishek      24 Dec 2018              16953          Adding Win/Lost clause to avoid creating quote
* 4.0           FY20-0802                 Abhinav       24 June 2019             S6735740       changed from override to url id
* 4.1           FY20-0802                 Dan Q         25 June 2019             6735740        fix parameters for Indirect Oppty
***************************************************************/
public class OpportunityCreateQuoteCtrl{
    //public Opportunity currentOppty                                  { get; set; }
    public Opportunity quriedOppty                                   { get; set; }
    public Boolean bShowBackLink                                     { set; get; }
    public String strCreateQuoteEncryptKey;
    public static EMC_General_Settings__c gCS;
    public static EMC_MyQuotes_URL_ParamNames__c myQuoteUrlParamNames;
    private Blob blbKey;
    private String strIv;
    private Blob blbIvBinary;
    private Blob blbDataValue;
    private Blob blbEncrypted;
    private String strEncryptedb64;
    private String strIvb64;
    private String strQueryString = '?';
    private List<String> listErrMsgs;
    public String strRecordId  = '';
   
    public OpportunityCreateQuoteCtrl(ApexPages.StandardController controller) {
        //this.currentOppty=(Opportunity)controller.getRecord();
        this.strRecordId  = ApexPages.currentPage().getParameters().get('id').escapeHtml4();//4.0
        gCS = EMC_General_Settings__c.getInstance();
        myQuoteUrlParamNames = EMC_MyQuotes_URL_ParamNames__c.getInstance();
        strCreateQuoteEncryptKey = gCS.Create_Quote_Encrypt_Key__c;
        strIv = generateRandomString(16);
        blbIvBinary = Blob.valueOf(strIv); 
        strIvb64 = EncodingUtil.base64encode(blbIvBinary);
        
    }
    
    public PageReference validate() {
        
        listErrMsgs = new List<String>();
        
        //Story - 06995 Starts
        Id opptyStandardRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('StandardOpportunity').getRecordTypeId();
        Id opptySMBRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SMB_Opportunity').getRecordTypeId();
        Id opptyChannelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Channel_Opportunity').getRecordTypeId();
        //Story - 06995 Ends
        
        //if(currentOppty.Id != null) {
        if(strRecordId  != null) {//4.0
            //String opportId = currentOppty.id+''; 
            String strOpportId = strRecordId ;//4.0
            if(strOpportId.subString(0,3) == '006') {
                quriedOppty = [select   Id, Name, Account_Country__c, EMC_Opportunity_Number__c, EMC_Sales_Channel__c, EMC_Sales_Force__c, 
                                        MyQuotes_Quote_Number__c, EMC_ID_Opp__c, Account.EMC_ID__c, CloseDate,StageName,RecordTypeID,
                                        Distributor_Direct_Reseller_Account__r.Partner_Quoting_Account_SAP_UCID__c, Distributor_Direct_Reseller_Account__r.Partner_Track__r.PPA_UCID__c,
                                        Indirect_Partner_Account__r.Partner_Quoting_Account_SAP_UCID__c , Indirect_Partner_Account__r.Partner_Track__r.PPA_UCID__c
                                from    Opportunity 
                                where   Id =: strRecordId ];
            }
        } else {
            return null;
        }
            
        //Story - 06995 Starts
        if((quriedOppty.StageName == 'Win - 100%' || quriedOppty.StageName == 'Lost, Cancelled - 0%') && (quriedOppty.RecordTypeID == opptyStandardRecordTypeId || quriedOppty.RecordTypeID == opptySMBRecordTypeId || quriedOppty.RecordTypeID == opptyChannelRecordTypeId)){
            listErrMsgs.add('Quote creation is not allowed on closed opportunities');
            bShowBackLink = true;
        }
        //Story - 06995 Ends
        
        if(quriedOppty.CloseDate < Date.today()){
            
            listErrMsgs.add(label.EMC_MyQuotes_Closed_Date);
            bShowBackLink = true;    
        }
        
        if(String.isEmpty(quriedOppty.EMC_Opportunity_Number__c)){            
            listErrMsgs.add(label.EMC_MyQuotes_Opportunity_Number);
            bShowBackLink = true;
        } else {
            addQueryString(myQuoteUrlParamNames.opportunityNumber__c , quriedOppty.EMC_Opportunity_Number__c);
        }
        
        if(String.isEmpty(quriedOppty.EMC_Sales_Channel__c)){        
            listErrMsgs.add(label.EMC_MyQuotes_Sales_Channel);
            bShowBackLink = true;
        } else {
            addQueryString(myQuoteUrlParamNames.distributionChannel__c , quriedOppty.EMC_Sales_Channel__c);
        }        
        
        if(String.isEmpty(quriedOppty.EMC_Sales_Force__c)){            
            listErrMsgs.add(label.EMC_MyQuotes_sales_force);
            bShowBackLink = true;
        } else if(quriedOppty.EMC_Sales_Force__c == 'ESG') {
            addQueryString(myQuoteUrlParamNames.quoteSource__c,'IIG');
        } else {
            addQueryString(myQuoteUrlParamNames.quoteSource__c , quriedOppty.EMC_Sales_Force__c );
        }
            
        
        if(!String.isEmpty(quriedOppty.MyQuotes_Quote_Number__c)){            
            listErrMsgs.add(label.EMC_MyQuotes_Quote_Number);
            bShowBackLink = true;
        }
            
         
        String strHybrisURL = gCS.Hybris_URL__c;
            
        if(quriedOppty.Name != null && quriedOppty.Name != ''){
            addQueryString(myQuoteUrlParamNames.quoteName__c, quriedOppty.Name);
        }
        
        
        if(!String.isEmpty(quriedOppty.Account.EMC_ID__c)){
            addQueryString(myQuoteUrlParamNames.account__c , quriedOppty.Account.EMC_ID__c);
        }
        //Prepare encrypted 'tier1' parameter to send as query string.
        if (quriedOppty.Distributor_Direct_Reseller_Account__r.Partner_Quoting_Account_SAP_UCID__c != null && quriedOppty.Distributor_Direct_Reseller_Account__r.Partner_Quoting_Account_SAP_UCID__c != ''){
            addQueryString(myQuoteUrlParamNames.tier1__c,quriedOppty.Distributor_Direct_Reseller_Account__r.Partner_Quoting_Account_SAP_UCID__c);
        } else if (quriedOppty.Distributor_Direct_Reseller_Account__r.Partner_Track__r.PPA_UCID__c != null && quriedOppty.Distributor_Direct_Reseller_Account__r.Partner_Track__r.PPA_UCID__c != '' ){
            addQueryString(myQuoteUrlParamNames.tier1__c,quriedOppty.Distributor_Direct_Reseller_Account__r.Partner_Track__r.PPA_UCID__c);
        }
        
        //Prepare encrypted 'tier2' parameter to send as query string.
        if (quriedOppty.Indirect_Partner_Account__r.Partner_Quoting_Account_SAP_UCID__c != null && quriedOppty.Indirect_Partner_Account__r.Partner_Quoting_Account_SAP_UCID__c != ''){
            addQueryString(myQuoteUrlParamNames.tier2__c,quriedOppty.Indirect_Partner_Account__r.Partner_Quoting_Account_SAP_UCID__c);
        } else if (quriedOppty.Indirect_Partner_Account__r.Partner_Track__r.PPA_UCID__c != null && quriedOppty.Indirect_Partner_Account__r.Partner_Track__r.PPA_UCID__c != ''){
            addQueryString(myQuoteUrlParamNames.tier2__c,quriedOppty.Indirect_Partner_Account__r.Partner_Track__r.PPA_UCID__c);
        }
        
        strQueryString += '&iv=' + strIvb64;
        PageReference redirectPage = new PageReference(strHybrisURL + strQueryString);
        system.debug('Emily redirectPage: ' + redirectPage);
        
        //Return errors if validation fails
        if(!listErrMsgs.isEmpty()){
            for(String strErrMsg : listErrMsgs){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,strErrMsg));
            }
            return null;
        }

        try{
            return redirectPage;            
        }catch(Exception e){
            ApexPages.addmessages(e);
            bShowBackLink = true; 
            return null;
        }           
    }
    
    //Method to return to Opportunity
    public PageReference redirectToOppty(){
        return new PageReference('/'+quriedOppty.Id);
    }   
        
    //Generates 16 digit random string
    public String generateRandomString(Integer intLen){
        final string chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String strRandStr = '';
        while(strRandStr.length()<intLen){
            Integer intIdx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
            strRandStr += chars.substring(intIdx, intIdx+1);
        }
        system.debug('Emily strRandStr: ' + strRandStr);
        return strRandStr;
    }
    
    //Encrypts value passed
    private String encriptValue(String strValue){
        // key should be in a custom setting
        if(strCreateQuoteEncryptKey != null && strCreateQuoteEncryptKey != ''){
            blbKey = EncodingUtil.base64Decode(strCreateQuoteEncryptKey);
            blbDataValue = Blob.valueOf(strValue);
            blbEncrypted = Crypto.encrypt('AES128', blbKey, blbIvBinary, blbDataValue);
            strEncryptedb64 = EncodingUtil.base64Encode(blbEncrypted); // this is the parameter value that is sent to Hybris
        }
        system.debug('Emily strEncryptedb64: ' + strEncryptedb64);
        return strEncryptedb64;
    }
    
    //Checks and adds new query string
    public void addQueryString(String strName, String strValue){
        if(strQueryString.endsWith('?')){
            strQueryString += strName + '=' + EncodingUtil.urlEncode(encriptValue(strValue), 'UTF-8');
        }
        else{
            strQueryString +='&' + strName + '=' + EncodingUtil.urlEncode(encriptValue(strValue), 'UTF-8');
        }
    }
}
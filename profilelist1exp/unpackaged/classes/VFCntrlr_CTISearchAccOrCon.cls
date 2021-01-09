/***********************************************************
* Name          : VFCntrlr_CTISearchAccOrCon
* Description   : Controller class for CTISearchAccOrCon
* ---------------------------------------------------------
* Revision      Release     Name    Date            Description
* 1.0           12.7        MenMee  13.06.2011      CR5944, CR5945, CR5947 SFDC-CTI Integration
* 1.1           12.7        MenMee  11.08.2011      Defect71853 Append (0*) in front of the phone no to search
* 1.2           12.7        MenMee  16.08.2011      Defect71965 Trunccate (9) in front of the phone no to search
* 1.3           15.03       Samridh 15.01.2014      CR9038
***********************************************************/

public with sharing class VFCntrlr_CTISearchAccOrCon 
{
            
    public String qsPartyId;
    public String qsPhoneNo;
    public String qsStartTime;
    public String qsEndTime;
    public String qsRouterCallKey;
    public String qsRouterCallDay;
    public String qsAccId;
    public String qsConId;
    //public String qsRetURL;
    public String qsCallType;
    public String accId;
    public String conId;
        
    public String errorMessage {get; set;}
    public String retURL {get; set;}
    
    private static final string CALL_INBOUND = 'I';
    private static final string CALL_OUTBOUND = 'O';
    public static boolean runCTITrigger=true;    
    public VFCntrlr_CTISearchAccOrCon() {
        
        try {
            //1. Get all parameter from query string
            qsPartyId = ApexPages.currentPage().getParameters().get('partyId');
            qsPhoneNo = ApexPages.currentPage().getParameters().get('phoneNo');
            qsRouterCallKey = ApexPages.currentPage().getParameters().get('key');
            qsRouterCallDay = ApexPages.currentPage().getParameters().get('keyDay');
            qsStartTime = ApexPages.currentPage().getParameters().get('start');
            qsEndTime = ApexPages.currentPage().getParameters().get('end');
            qsAccId = ApexPages.currentPage().getParameters().get('accountId');
            qsCallType = ApexPages.currentPage().getParameters().get('type');           
            qsConId = ApexPages.currentPage().getParameters().get('contactId');
                        
            System.debug('##### URL: '+ApexPages.currentPage().getUrl());                       
            System.debug('##### PartyId: '+qsPartyId + ' PhoneNo: '+qsPhoneNo);
            System.debug('##### RouterCallKey: '+qsRouterCallKey + ' RouterCallDay: '+qsRouterCallDay);
            System.debug('##### StartTime: '+qsStartTime + ' EndTime: '+qsEndTime);
            System.debug('##### AccId: '+qsAccId + ' CallType: '+qsCallType);           
        }
        catch (Exception e) {
            errorMessage = 'A problem has occured: ' + e.getMessage();  
            return ;    
        }
    }
    
    public PageReference searchAccOrUpsertCallLog() {
        List<Account> acc = new List<Account>();
        List<CTI_Call_Log__c> callLogList = new List<CTI_Call_Log__c>();
        CTI_Call_Log__c callLog;  
        String searchPhone = '';
        try {                       
            //2. Phone is ringing / Answer call             
            if (qsCallType == null) {               
                
                //2.1 Search Account             
                if (!StringUtils.isBlank(qsPartyId)) { 
                    System.debug('##### Search Account: '+qsPartyId);
                    acc = [SELECT Id FROM Account WHERE Account_Id__c = :qsPartyId LIMIT 1];
                
                    if (acc.size() > 0) {
                        retURL = '/'+acc[0].Id;                 
                        return PageUtils.redirect(retURL);
                    }
                }
                
                //2.2 Can't find account and redirect to standard search page
                if (acc.size() == 0 && qsPhoneNo != null) {
                    searchPhone = qsPhoneNo + ' OR 0*' + qsPhoneNo;
                    
                    //Rev 1.2
                    if (StringUtils.startsWith(qsPhoneNo, '9'))
                        searchPhone += ' OR ' + StringUtils.subString(qsPhoneNo, 1);
                    
                    System.debug('##### Redirect to standard search page: '+searchPhone);
                                                
                    //retURL = '/search/SearchResults?sen=001&sen=003&str='+EncodingUtil.urlEncode(qsPhoneNo, 'UTF-8');
                    //retURL = '/_ui/common/search/client/ui/UnifiedSearchResults?sen=001&sen=003&str='+EncodingUtil.urlEncode(searchPhone , 'UTF-8'); 
                    retURL = Label.Global_Search_URL+'&sen=001&sen=003&str='+EncodingUtil.urlEncode(searchPhone , 'UTF-8');                     
                }
                    /*
                    PageReference pageRef = new PageReference('/_ui/common/search/client/ui/UnifiedSearchResults');
                    pageRef.getParameters().put('sen0', '001');
                    pageRef.getParameters().put('sen1', '003');
                    pageRef.getParameters().put('str', '123');
                    pageRef.setRedirect(true);
                    return pageRef;
                    */
                        
            }
            //3. End call - Create / update call log
            else {
                //3.1a For Inbound call, search for matching call log with unique key to update (if any)
                if (qsCallType == CALL_INBOUND) {
                    if ((qsRouterCallKey != '0' || qsRouterCallDay != '0') && (StringUtils.isNotBlank(qsRouterCallKey) || StringUtils.isNotBlank(qsRouterCallDay))) {
                        callLogList = [SELECT Id, Call_End_Time__c FROM CTI_Call_Log__c 
                                         WHERE Router_Call_Key__c = :qsRouterCallKey AND Router_Call_Day__c =:qsRouterCallDay
                                         LIMIT 1];
                        System.debug('##### Call log: '+callLogList);
                    }
                                    
                    //3.2 If can't find existing call log, then going to create new call log, need to find account id
                    if (callLogList.isEmpty() && StringUtils.isNotBlank(qsPartyId)) {  
                        acc = [SELECT Id FROM Account WHERE Account_Id__c = :qsPartyId LIMIT 1];
                    
                        if (acc.size() > 0) {
                            accId = acc[0].Id;                      
                        }
                        
                         conId = qsConId;
                    } 
                    
                    if (callLogList.isEmpty() && StringUtils.isBlank(qsPartyId)) {
                    
                    conId = qsConId;
                    accId = qsAccId;
                    
                    }
                    
                }                        
           
                //3.1b For outbound call, will create new call log everytime
                else if (qsCallType == CALL_OUTBOUND) {
                    conId = qsConId;
                    accId = qsAccId;
                            
                }
                    
                //3.3 Either insert or update call log
                if (callLogList != null && callLogList.size() > 0) {
                    System.debug('##### Update call log');
                    callLog = new CTI_Call_Log__c(Id = callLogList[0].Id, Call_End_Time__c = convertStringToDateTimeGMT(qsEndTime));                
                }
                else {
                    System.debug('##### Insert call log');
                    callLog = new CTI_Call_Log__c(Call_Start_Time__c = convertStringToDateTimeGMT(qsStartTime),
                                    Call_End_Time__c = convertStringToDateTimeGMT(qsEndTime),
                                    Phone_Number__c = qsPhoneNo,
                                    Call_Type__c = (qsCallType==CALL_INBOUND? 'Incoming':'Outgoing'),
                                    Router_Call_Key__c = qsRouterCallKey,
                                    Router_Call_Day__c = qsRouterCallDay,
                                    Account__c = (StringUtils.isNotBlank(accId)? accId: null),
                                    Contact__c = (StringUtils.isNotBlank(conId)? conId: null)); 
                                    system.debug('####'+callLog);      
                }
                runCTITrigger=false;
                if (callLog != null) upsert callLog;
                
                //3.4 Rediect User to call log edit page
                retURL = '/'+callLog.Id+'/e?retURL='+(StringUtils.isNotBlank(conId)?conId:(StringUtils.isNotBlank(accId)? accId: '/home/home.jsp'));               
                return new PageReference(retURL);               
            }
        }
        catch (Exception e) {
            errorMessage = e.getMessage();  
            return null;    
        }
        return null;                
    }
    
    private DateTime convertStringToDateTimeGMT(String sDate) {
        //sDate = 2011-06-15 09:30:44Z
        DateTime convertedDT; 
        
        if (!StringUtils.isBlank(sDate)) 
            convertedDT = datetime.valueOfGMT(sDate);       
        
        System.debug('Converted Datetime: '+convertedDT);       
        return convertedDT;
    }
}
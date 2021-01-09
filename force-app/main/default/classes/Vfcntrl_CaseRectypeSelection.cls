/*
 * Author   : Jay
 * Purpose  : Case Recordtype Selection - Controller Class
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0                              24-June-2017         Jay        When the Case Type is "Deal Registration" & "Order Support", redirected to the case creation custom VF pages.
  
  */


public class Vfcntrl_CaseRectypeSelection {
    
    public Id recTypId;
    public Id caseId {get;set;}
    public Id caseParentId {get;set;}
    public case caseObj {get;set;}
    Public String strRecordTypeName;
    User loggedInUser;
    String OrderSupportRecord = System.Label.Order_Support_Id;
    String DealRegRecord = System.Label.Deal_Registration_Id;
    
    //Added by Hari 22/02/19
    public string strOppId;
    public string strOppName;
    public string strAccId;
    public string strAccName;
    public string strRetURL;   
    private CaseRTMigrate__CSAT_Image__c csatSetting = CaseRTMigrate__CSAT_Image__c.getOrgDefaults();
    
    Public Vfcntrl_CaseRectypeSelection(ApexPages.StandardController controller){
           loggedInUser = [select Id,Profile_Name__c from user where id = : UserInfo.getUserId()];
           caseId = ApexPages.currentPage().getParameters().get('id');
           caseParentId = ApexPages.currentPage().getParameters().get('def_parent_id');
           recTypId = ApexPages.currentPage().getParameters().get('RecordType').escapeHtml4();
           strRecordTypeName = [SELECT id, name from RecordType where Id = : recTypId].name;
           //Added by Hari 22/02/19
          strOppId = ApexPages.currentPage().getParameters().get('OppId');
          strOppName= ApexPages.currentPage().getParameters().get('OppName');
          strAccId= ApexPages.currentPage().getParameters().get('AccId');
          strAccName = ApexPages.currentPage().getParameters().get('AccName'); 
          strRetURL =  ApexPages.currentPage().getParameters().get('retURL');
          system.debug('@@@@returl'+strRetURL);
    }
    Public PageReference caseRecordredirect(){
       PageReference casePage;
       If(loggedInUser.Profile_Name__c.contains('Portal') ){ 
           /*Meenu : Story 7059159 added recordtype Channel Services Helpdesk*/
          If(strRecordTypeName == 'Order Support' || strRecordTypeName == 'Deal Registration' || strRecordTypeName == 'On Boarding' || strRecordTypeName == 'Distribution' ||
                          strRecordTypeName == 'Application Support' ||  strRecordTypeName == 'Partner Program' || strRecordTypeName == 'Channel Services Helpdesk'){
            casePage = new PageReference ('/apex/Case_SalesMotionSelection?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo'); 
          }
       }else if (!loggedInUser.Profile_Name__c.contains('Portal')){
        If(strRecordTypeName == 'Order Support'){
           if(strAccId<>null){
           casePage = new PageReference ('/apex/OrderSupportVfPage?RecordType=' +recTypId+ '&AccID=' +strAccId.removeEnd(' ')+'&ent=Case&retURL=%2F500%2Fo');
           }else{
            casePage = new PageReference ('/apex/OrderSupportVfPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
           }  
            
        }else if(strRecordTypeName == 'Deal Registration'){
            if(strOppId<>null){
            casePage = new PageReference ('/apex/DealRegVFPage?RecordType=' + recTypId + '&accId='+strAccId.removeEnd(' ')+'&oppId='+strOppId.removeEnd(' ')+ '&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/DealRegVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }           
        }else if(strRecordTypeName == 'Deal Registration - Internal only case types'){
            if(strOppId<>null){
                casePage = new PageReference ('/apex/DealRegVFPage?RecordType=' + recTypId + '&accId='+strAccId.removeEnd(' ')+'&oppId='+strOppId.removeEnd(' ')+ '&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/DealRegVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }
        }else if(strRecordTypeName == 'On Boarding'){
            if(strAccId<>null){
                 casePage = new PageReference ('/apex/OnBoardingVFPage?RecordType=' + recTypId +'&accid='+strAccId.removeEnd(' ')+ '&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/OnBoardingVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }
        }else if(strRecordTypeName == 'On Boarding Internal'){
            if(strAccId<>null){
               casePage = new PageReference ('/apex/OnBoardingVFPage?RecordType=' + recTypId +'&accid='+strAccId.removeEnd(' ')+ '&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/OnBoardingVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }
        }else if(strRecordTypeName == 'Distribution'){
            if(strAccId<>null){
            casePage = new PageReference ('/apex/DistributionVFPage?RecordType=' + recTypId +'&accid='+strAccId.removeEnd(' ')+  '&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/DistributionVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }
        }else if(strRecordTypeName == 'Application Support'){
            if(strAccId<>null){
                casePage = new PageReference ('/apex/ApplicationSupportVFPage?RecordType=' + recTypId +'&accid='+strAccId.removeEnd(' ')+ '&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/ApplicationSupportVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }
        }else if(strRecordTypeName == 'Application Support - Internal only case types'){
            if(strAccId<>null){
                casePage = new PageReference ('/apex/ApplicationSupportVFPage?RecordType=' + recTypId +'&accid='+strAccId.removeEnd(' ')+ '&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/ApplicationSupportVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }
        }else if(strRecordTypeName == 'Partner Program'){
            if(strAccId<>null){
                casePage = new PageReference ('/apex/ApplicationSupportVFPage?RecordType=' + recTypId +'&accid='+strAccId.removeEnd(' ')+'&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/ApplicationSupportVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }
        }/*Meenu : Story 7059159 added recordtype Channel Services Helpdesk vf page redirection*/
        else if(strRecordTypeName == 'Channel Services Helpdesk (internal only)' || strRecordTypeName == 'Channel Services Helpdesk'){
            if(strAccId<>null){
                casePage = new PageReference ('/apex/ChannelServicesHelpdeskVFPage?RecordType=' + recTypId +'&accid='+strAccId.removeEnd(' ')+'&ent=Case&retURL=%2F500%2Fo');
            }else{
            casePage = new PageReference ('/apex/ChannelServicesHelpdeskVFPage?RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
            }
        }else{
            if(String.isBlank((String) caseParentId)) {
                //Added by Hari 22/02/19
                if(strOppId<>null){
                system.debug('@@@@urlrlrl');
                    string strURL = '/500/e?nooverride=1&RecordType=' + recTypId+'&';
                        strURL = strURL+csatSetting.CaseRTMigrate__Opportunity_Id__c+'='+strOppId.escapeHtml4()+'&';
                        strURL = strURL+csatSetting.CaseRTMigrate__Opportunity_Name__c+'='+strOppName.escapeHtml4()+'&';
                        strURL = strURL+csatSetting.CaseRTMigrate__Account_Id__c+'='+strAccId.escapeHtml4()+'&';
                        strURL = strURL+csatSetting.CaseRTMigrate__Account_Name__c+'='+strAccName.escapeHtml4()+'&';   
                        strURL = strURL+'ent=Case&retURL=%2F500%2Fo';
                    casePage = new PageReference(strURL);
                }
                else if(strRetURL<>null && strRetURL.substring(1,4)=='001'){
                     Account ac = [select id,name from Account where id =:strRetURL.substring(1,16)];
                     string strURL = '/500/e?nooverride=1&RecordType=' + recTypId+'&';
                            strURL = strURL+csatSetting.CaseRTMigrate__Account_Id__c+'='+ac.id+'&';
                            strURL = strURL+csatSetting.CaseRTMigrate__Account_Name__c+'='+ac.name+'&';   
                            strURL = strURL+'ent=Case&retURL=%2F500%2Fo';
                     casePage = new PageReference(strURL);       
                 }else{
                    casePage = new PageReference('/500/e?nooverride=1&RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo');
                 }
            } else {
                casePage = new PageReference('/500/e?nooverride=1&RecordType=' + recTypId + '&ent=Case&retURL=%2F500%2Fo&def_parent_id=' + caseParentId);
            }
        }
    }
    return casePage;
   } 
}
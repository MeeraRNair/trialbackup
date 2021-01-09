/*
 * Author   : Jay
 * Purpose  : Trigger for Email Message which handles all the events.
 * 
 * Revision     CR Number       Release No       Date            Created By     Description
 * --------             -----------              ----------      -----------         ------------            -----------
 * 1.0                        14603            -----            11th Jul '17         Jay             EmailMessage Utility Class, to update
 * 2.0                                                           28th Aug 17         Vasavi.M        Modify to support Deal reg records also                                                                                                               the custom field "New Email" whenever a new mail is recieved on Case.
 * 3.0                                                          29 th Nov 17         Pradeep         Modified to uncheck New Email field when replied
 * 
 */




Public class emailMessageUtilities {
    
    Public static void updateEmailflag(List<EmailMessage> newCaseEmail){
        List<Id> emailPrtId = New List<Id> ();
        for(EmailMessage em: newCaseEmail){
            if(em.status == '0' && em.Incoming == true){
                emailPrtId.add(em.ParentId);
                }
            }
        List<Case> newEmailCaseList = new List<Case>();
        List<String> recTypeList = new List<String>();
        String supportedRectypes = System.Label.Case_Record_Types_New_Email;
        if (supportedRectypes != null && supportedRectypes  != '') {
            recTypeList  = supportedRectypes.split(',');
        }
                
        newEmailCaseList = [Select id,new_email_flag__C From Case Where Id IN :emailPrtId and recordtype.name IN :recTypeList];
  
        if(newEmailCaseList.size() > 0) {
          for(Case newEmailObj : newEmailCaseList) {
              newEmailObj.new_email_flag__C = true;              
          }
          System.debug('Insert updated list : '+newEmailCaseList);
          update newEmailCaseList;
      }
      
    }
    
    Public static void UncheckNewEmailflag(List<EmailMessage> CaseEmail){
        List<Id> emailReplyId = New List<Id> ();
        for(EmailMessage emr: CaseEmail){
            if(emr.status == '1'  || emr.status == '2') {
            //if((emr.status == '1' && emr.Incoming == true) || (emr.status == '2' && emr.Incoming == false)) {
                emailReplyId.add(emr.ParentId);
                }
            }
        List<Case> RepliedEmailCaseList = new List<Case>();//Added for Newemail field uncheck for replied emails
        List<String> recTypeList = new List<String>();
        String supportedRectypes = System.Label.Case_Record_Types_New_Email;
        if (supportedRectypes != null && supportedRectypes  != '') {
            recTypeList  = supportedRectypes.split(',');
        }
                
        RepliedEmailCaseList = [Select id,new_email_flag__C From Case Where Id IN :emailReplyId and recordtype.name IN :recTypeList];
      
        if(RepliedEmailCaseList.size() > 0) {
          for(Case newEmailObj1 : RepliedEmailCaseList) {
              newEmailObj1.new_email_flag__C = false;              
          }
          System.debug('Insert Replied updated list : '+RepliedEmailCaseList);
          update RepliedEmailCaseList;
      }
        
    }
    
}
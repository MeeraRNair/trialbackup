public class ExceptionHelper {
    //change the variable Exceptiontypelist to strexceptiontypelist
    Public static string strexceptiontypelist='SFDC_PIM_Integration';
    public static void logException(String strobjectAPIName, Exception ex,String strreqresponse,string strexecptionClass, String stroperation){
        
        // Exceute the code in asynchronously if it is close to governor limit.
        if(Limits.getDMLStatements()>150){
            insertLog(strobjectAPIName,ex.getMessage(), strreqresponse,ex.getStackTraceString(),strexecptionClass,stroperation);
        }else{
            Exception__c  log = createLog(strobjectAPIName, ex.getMessage(), strreqresponse, ex.getStackTraceString(), strexecptionClass,stroperation);
            system.debug('inside log exception else------->>>>>');
            insert log;
            Exception__c exx=[select name,Notes__c,id,Process_Name__c from Exception__c where id=:log.Id limit 1];
            createAttachment(exx.Name,exx.Notes__c,exx.Id,exx.Process_Name__c,ExceptionHelper.getMailAddresses());
        }
    }
    
    public static void logException(String strobjectAPIName,string strmessage,String strreqresponse,string strexecptionClass, String stroperation){
        if(Limits.getDMLStatements()>150){
            insertLog(strobjectAPIName,strmessage, strreqresponse,'',strexecptionClass,stroperation);
        }else{
            Exception__c  log = createLog(strobjectAPIName, strmessage, strreqresponse, '', strexecptionClass,stroperation);
            insert log;
            Exception__c exx=[select name,Notes__c,id,Process_Name__c from Exception__c where id=:log.Id limit 1];
            createAttachment(exx.Name,exx.Notes__c,exx.Id,exx.Process_Name__c,ExceptionHelper.getMailAddresses());
        }
    }
    
    @future
    public static void insertLog(String strobjectAPIName, String strmessage, String strreqresponse, String strstackTrace, string strexecptionClass, String stroperation){   
        Exception__c  log = createLog(strobjectAPIName, strmessage, strreqresponse, strstackTrace, strexecptionClass, stroperation);
        insert log;
        Exception__c exx=[select name,Notes__c,id,Process_Name__c from Exception__c where id=:log.Id ];
        createAttachment(exx.Name,exx.Notes__c,exx.Id,exx.Process_Name__c,ExceptionHelper.getMailAddresses());
    }
    
    public static Exception__c  createLog(String strobjectAPIName,string strmessage,String strreqresponse, String strstackTrace,string strexecptionClass, String stroperation){
        Exception__c  log = new Exception__c ();
        log.Object_type__c=strobjectAPIName;
        string strtemp ='Class & Method Name: '+strexecptionClass +' strmessage: '+strmessage;
        if(strtemp.length()>255){
            log.Error_Messages__c=strtemp.substring(0, 254);
        }
        else{   
            log.Error_Messages__c= strtemp;
        }
        string strtemperr =strstackTrace;
        if(strtemperr.length()>250){
            log.Error_Codes__c=strtemperr.substring(0, 249);
        }
        else{   
            log.Error_Codes__c= strtemperr;
        }
        //log.Error_Codes__c=strstackTrace;
        log.Process_Name__c =strexceptiontypelist;
        log.Operation__c= stroperation;
        log.Email__c ='no_reply@dell.com'; //this should be a custom label
        log.Notes__c = strreqresponse;
        return log;
    }
    
    Public static void createAttachment( string strname,String strmessage, Id recordId,String strprocessname,List<String> listemail){
        Attachment exceptionAttachment = new Attachment();
        //Body = Blob.valueOf(strmessage), Name = name, ParentId = recordId
        exceptionAttachment.Name=strname+'.txt';
        exceptionAttachment.Body=Blob.valueOf(strmessage);
        exceptionAttachment.contenttype='text/plain;charset=UTF-8';
        exceptionAttachment.ParentId=recordId;
        insert exceptionAttachment;  
        if(exceptionAttachment.Id!=Null){
            List<Messaging.SingleEmailMessage> listmails=new List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> listorgWideEmailLst = [select id, address from OrgWideEmailAddress where displayname = :'No_Reply Mailbox' limit 1];
            String strorgWideEmailId = listorgWideEmailLst.size()>0?listorgWideEmailLst[0].id:'no-reply@dell.com';    
            for(String strel:listemail){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> listtoAddresses = new List<String>();
                listtoAddresses.add(strel); 
                mail.setToAddresses(listtoAddresses);
                if(strprocessname=='SFDC_DSA_Integration'){
                    mail.setSubject('Common Catalog DSA Integration Exception occurred : '+strname);   
                    mail.setHtmlBody('Hi Team,<br/> </br>  Common Catalog DSA SFDC Integration exception occurred.<br/> Please check the attachment for more information .<br/><br/><br/> Thanks,<br/> Common Catalog Support Team');   
                }
                else{
                    mail.setSubject('Common Catalog PIM Integration Exception occurred : '+strname);
                    mail.setHtmlBody('Hi Team,<br/> </br>  Common Catalog PIM SFDC Integration exception occurred.<br/> Please check the attachment for more information .<br/><br/><br/> Thanks,<br/> Common Catalog Support Team');
                }
                mail.setOrgWideEmailAddressId(strorgWideEmailId);
                List<Messaging.Emailfileattachment> strfileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(exceptionAttachment.Name);
                efa.setBody(exceptionAttachment.Body);
                strfileAttachments.add(efa);
                mail.setFileAttachments(strfileAttachments);
                listmails.add(mail);
            }                         
            Messaging.sendEmail(listmails); 
        }
        
    } 
    public static List<String> getMailAddresses()
    {
        List<String> listmailList = new List<String>();
        List<String> listmailAddresses = new List<String>(); 
        
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name ='CC_Exception_Emailgroup'];
        for (GroupMember gm : g.groupMembers) 
        {
            listmailList.add(gm.userOrGroupId);
        }
        User[] listusr = [SELECT email FROM user WHERE id IN :listmailList];
        for(User u : listusr) 
        {
            listmailAddresses.add(u.email);
        } 
        return listmailAddresses;
    }    
}
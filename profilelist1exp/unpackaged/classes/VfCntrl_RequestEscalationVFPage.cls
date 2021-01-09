/***************************************************************************************************************************************************************
* 
* Name          : VfCntrl_RequestEscalationVFPage
* Description   : controller class to support vfpage "RequestEscalationVFPage" 
* ---------------------------------------------------------------------------------------
* Revision  Name            Date                 CR                                         Description
* 1.0       Naresh      12.29.2017                                          Added logic on Request Escalation for unauthenticated web from
***************************************************************************************************************************************************************/


public class VfCntrl_RequestEscalationVFPage {

    public VfCntrl_RequestEscalationVFPage(ApexPages.StandardController controller) {
        
        //displayLanguageCode='pl';
        displayLanguageCode=ApexPages.currentPage().getParameters().get('language');
        system.debug('check language' +displayLanguageCode);
    }

    public case caseObj {get;set;}
    public boolean requestEscalationCheck {get;set;}
    public boolean statusCompltedReqEscaIsfalse{get;set;}
    public boolean statusCompltedReqEscaIsTrue{get;set;}    
    public boolean cannotEscalateCaseWhenAssig{get;set;}
    public string CaseNumber{get;set;}
    public string EscalateJustification{get;set;}
    public string CaseId{get;set;} 
    public string displayLanguageCode{get;set;} 
    
    Boolean ErrorDisplay=false;
    Public Void escalateValidations(){
        caseObj=new case();
        ErrorDisplay=false;
        CaseNumber=CaseNumber.trim();
        EscalateJustification=EscalateJustification.trim();
        if(CaseNumber!=null && CaseNumber!=''){
            list<case> clist=[select id,Escalation_Justification__c,Status,Time_of_escalation_request__c, Request_Escalation__c,Re_Open_Status_Flag__c,Is_Escalated_After_Close__c,Unauthenticated_Case__c from case where casenumber=:casenumber and Unauthenticated_Case__c=true];
               if(!clist.IsEmpty() && (EscalateJustification=='' || EscalateJustification==null)){
                   ErrorDisplay=true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.UnAuth_ReqEsc_Mandatory));
               }else if(clist.IsEmpty()){
                    ErrorDisplay=true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.UnAuth_Invalid_CaseNumber));
               }
               else if(!clist.IsEmpty() && EscalateJustification!=null){
                    caseObj=clist[0];
               }
        
        }
        system.debug('check case id' +caseObj);
        /*if(CaseId!=null && CaseId!=''){
            caseObj = [select id, Escalation_Justification__c,Status,Time_of_escalation_request__c, Request_Escalation__c,Re_Open_Status_Flag__c,Is_Escalated_After_Close__c,Unauthenticated_Case__c from case where id = :CaseId];
            system.debug('check caseObj status' +caseObj.status);
        }*/
        if(caseobj!=null){
        if (caseObj.status == 'Assigned') {
            ErrorDisplay=true;
            cannotEscalateCaseWhenAssig = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.NoEscaltionBeforeInProgress));
        }else if(caseObj.Status != 'Completed' && caseObj.Request_Escalation__c == True) {
        
             ErrorDisplay=true;
             requestEscalationCheck = True;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.OrderSupportCaseEscalate));
        }
        
        if(caseObj.Status == 'Completed' && caseObj.Request_Escalation__c == false){
            ErrorDisplay=true;
            statusCompltedReqEscaIsFalse = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.OrderSupportCaseCompleted));
        }else if(caseObj.Status == 'Completed' && caseObj.Request_Escalation__c == True){
             ErrorDisplay=true;
             statusCompltedReqEscaIsTrue = true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.OrderSupportCaseEscalate_Completed)); 
        }
        
        if (requestEscalationCheck != true  && statusCompltedReqEscaIsTrue != true && statusCompltedReqEscaIsFalse != true && caseObj.Re_Open_Status_Flag__c == true && caseObj.Status == 'Closed (Resolved)'){
            ErrorDisplay=true;
            statusCompltedReqEscaIsTrue = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.RequestEscalationReopen));
         }
     }
    }
    
    public pagereference okSave() {
        EscalateValidations();
        system.debug('check caseObj status save' +caseObj.status);
        if(CaseNumber==''|| EscalateJustification==''){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.UnAuth_ReqEsc_Mandatory));
        }else if(caseObj!=null && ErrorDisplay==false){
              if(caseObj.Status != 'Completed' && caseObj.Status != 'Closed (Resolved)' ){
                  caseObj.Request_Escalation__c = True;
                  caseObj.Escalation_Justification__c=EscalateJustification;
                  caseObj.Time_of_escalation_request__c = System.now();
                  update caseObj;
                  cannotEscalateCaseWhenAssig=true;
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Case_Unauth_Escalate+CaseNumber));
              }else if(caseObj.Status == 'Closed (Resolved)'){
                  caseObj.Request_Escalation__c = True;
                  caseObj.Escalation_Justification__c=EscalateJustification;
                  caseobj.Is_Escalated_After_Close__c=true;
                  caseObj.Time_of_escalation_request__c = System.now();
                  caseObj.Re_Open_Status_Flag__c = True; 
                  caseObj.Status = 'Re-Open';  
                  update caseObj;
                  cannotEscalateCaseWhenAssig=true;
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Case_Unauth_Escalate+CaseNumber));
             }      
        }
       return null;
        }
        
        public pagereference cancel(){
              // pagereference page= new PageReference('/apex/RequestEscalationVFPage');
              string lng = (null!=displayLanguageCode)?'?language='+displayLanguageCode:'';
               pagereference page= new PageReference('/apex/RequestEscalationVFPage'+lng);
              page.setRedirect(TRUE);
              return page;
        }
        
        
    }
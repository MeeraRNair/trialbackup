/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Jiji        12-Nov-2012     14.10         --     Controller To Route Direct Leads to Channel.
2.0         Jiji        19-Sep-2013     14.10       CRQ#0796 Remove Industry mapping from URL
3.0         Jiji        19-Sep-2013     14.10       CRQ0797  Remove Cancel button from the PL.
4.0         Jiji        01-Apr-2014     15.07        --      R2C from AP
*/

public with sharing class CMAP_RouteDirectLeadsController {
    public String dirlId{get;set;}
    public Lead dirlRecord{get;set;}
    Id leadRTId;
    public Lead clRecord { get; set; }
    public Id newId;
    String retURL;
    Public Boolean ShowSecondBlock{get;set;}
    public CMAP_RouteDirectLeadsController(ApexPages.StandardController controller) {
      try{
         ShowSecondBlock= False;
         leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
         dirlId = ApexPages.currentPage().getParameters().get('dirlId');
         newId = ApexPages.currentPage().getParameters().get('newId');
         retURL= ApexPages.currentPage().getParameters().get('retURL');
         if(dirlId != NULL){
            dirlRecord = [Select Id, Name, FirstName,LastName, Title, 
                                Phone, MobilePhone, email, fax, Company,
                                Purchase_timeframe__c, Decision_Making_Role__c, 
                                AnnualRevenue, Employees__c,
                                Questions_Comments__c, Sales_Comments__c, 
                                Marketing_Comments__c,
                                //Ver2.0: Comment Start
                                //Salutation, Industry, Channel_Lead__c,
                                //Ver2.0: Comment End
                                //Ver2.0: Code Start
                                Salutation, Channel_Lead__c,
                                //Ver2.0: Code End
                                Dell_can_contact_me_in_the_future__c,
                                Consent_to_engage_Dell_Channel_Partner__c, 
                                Street,  City, State, PostalCode, Country
                          from  Lead 
                          where Id = :dirlId];
            
         }
         if(newId != NULL){
             ShowSecondBlock = TRUE;
             clRecord = [Select Id, Questions_Comments__c, 
                         Sales_Comments__c, Marketing_Comments__c
                         from  Lead 
                         where Id = :newId];
         }
         
      }
      catch (Exception e) {
          system.debug('----exception---'+e);
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Default_Error_Message));
      } 

    }
    public pagereference redirect(){
        
        if(dirlId != NULL){    
            String Status = pageUtils.encodeVariable('Qualified - Channel Ready');
            String R2CSource  = pageUtils.encodeVariable('Segment Lead');//Ver 4.0: Update R2C source
            string saveURLstring ='/apex/CMAP_RouteDirectLead?retURL='+dirlRecord.Id;
            String URL = '/00Q/e?lea13='+Status+'&RecordType='+leadRTId+'&nooveride=1&retURL='+dirlRecord.Id+
                     '&saveURL='+saveURLstring+'&sLeadId='+dirlRecord.Id+
                     '&00NA00000064hVv='+R2CSource+  //Ver 4.0:  Update R2C source
                     '&CF00NA0000006442I_lkid='+dirlRecord.Id+'&CF00NA0000006442I='+dirlRecord.Name+
                     (dirlRecord.FirstName!=NULL?'&name_firstlea2='+pageUtils.encodeVariable(dirlRecord.FirstName):'')+
                     (dirlRecord.LastName!=NULL?'&name_lastlea2='+pageUtils.encodeVariable(dirlRecord.LastName):'')+
                     (dirlRecord.Salutation!=NULL?'&name_salutationlea2='+pageUtils.encodeVariable(dirlRecord.Salutation):'')+
                     (dirlRecord.Company!=NULL?'&lea3='+pageUtils.encodeVariable(dirlRecord.Company):'')+
                     (dirlRecord.MobilePhone!=NULL?'&lea9='+pageUtils.encodeVariable(dirlRecord.MobilePhone):'')+
                     (dirlRecord.Fax!=NULL?'&lea10='+pageUtils.encodeVariable(dirlRecord.Fax):'')+
                     //Ver2.0: Comment Start
                     // (dirlRecord.Industry!=NULL?'&lea6='+pageUtils.encodeVariable(dirlRecord.Industry):'')+
                     //Ver2.0: Comment End
                     (dirlRecord.AnnualRevenue!=NULL?'&lea7='+dirlRecord.AnnualRevenue:'')+
                     (dirlRecord.Employees__c!=NULL?'&00N70000002MSoA='+pageUtils.encodeVariable(dirlRecord.Employees__c):'')+
                     (dirlRecord.Title!=NULL?'&lea4='+pageUtils.encodeVariable(dirlRecord.Title):'')+
                     (dirlRecord.Email!=NULL?'&lea11='+pageUtils.encodeVariable(dirlRecord.Email):'')+
                     (dirlRecord.City!=NULL?'&lea16city='+pageUtils.encodeVariable(dirlRecord.City):'')+
                     (dirlRecord.State!=NULL?'&lea16state='+pageUtils.encodeVariable(dirlRecord.State):'')+
                     (dirlRecord.Country!=NULL?'&lea16country='+pageUtils.encodeVariable(dirlRecord.Country):'')+
                     (dirlRecord.PostalCode!=NULL?'&lea16zip='+pageUtils.encodeVariable(dirlRecord.PostalCode):'')+
                     (dirlRecord.Phone!=NULL?'&lea8='+pageUtils.encodeVariable(dirlRecord.Phone):'')+
                     (dirlRecord.Purchase_Timeframe__c!=NULL?'&00N70000002MSnl='+pageUtils.encodeVariable(dirlRecord.Purchase_Timeframe__c):'')+
                     (dirlRecord.Dell_can_contact_me_in_the_future__c!=NULL?'&00N70000002MSnq='+pageUtils.encodeVariable(dirlRecord.Dell_can_contact_me_in_the_future__c):'')+
                     (dirlRecord.Decision_Making_Role__c!=NULL?'&00N70000002MSo0='+pageUtils.encodeVariable(dirlRecord.Decision_Making_Role__c):'');
            System.debug('************************************ URL ::: '+URL);
            pagereference page = new pagereference(URL);
            page.setRedirect(TRUE);
            return page;
        //return NULL;
        }
       //} 
        return NULL;
       
    }
     public pagereference saveButton(){
        update clRecord;
        String URL= '/'+newId;
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;
        
    }
    /*Ver 3.0:Code Start: CRQ 0797: Remove Cancel button from PL
    public pagereference cancelButton(){
        
        String URL= '/'+newId;
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;
        
    }
    Ver 3.0:Code End: CRQ 0797: Remove Cancel button from PL*/
    
}
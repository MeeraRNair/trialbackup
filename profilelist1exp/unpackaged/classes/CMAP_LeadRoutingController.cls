/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Jiji        12-Nov-2012     14.2         --     Controller for Route to Channel.
2.0         Sandhya     29-jan-2013     14.2                CRQ -0637
3.0         Jiji        13-Feb-2013     14.2         --     CRQ -0655
4.0         Jiji        05-Aug-2013     14.10        --     FR7.1 to FR7.19
5.0         Annie       17-Sep-2013     14.10               CRQ - 0786
6.0         Jiji        19-Sep-2013     14.10       CRQ0797  Remove Cancel button from the PL.
7.0         Manju       07-Nov-2-13     15.3         8840    To map Lead Score from RL to CL
8.0         Jiji        01-Apr-2014     15.07        --      Update R2C source
*/
public class CMAP_LeadRoutingController {
    String rlId{get;set;}
    Relationship_Lead__c rlRecord =  new Relationship_Lead__c();
    Lead leadRecord = new Lead();
    //Ver4.0: Code Start: CMAP FR-7.1: Autopopulate Values to New Channel Lead
    Lead DirLeadRecord = new Lead();
    public Lead clRecord { get; set; }
    public Id newId;
    String retURL;
    Public Boolean Show2ndBlock{get;set;}
    //Ver4.0: Code End: CMAP FR-7.1: Autopopulate Values to New Channel Lead
    Id leadRTId;
    Public Boolean showFirstBlock {get;set;}
    public Relationship_Lead__c rLeadObj{ get; set; }
    
    public CMAP_LeadRoutingController(ApexPages.StandardController controller) {
      try{
        
        showFirstBlock = TRUE;
        rLeadObj = new Relationship_Lead__c();
        leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        rlId = ApexPages.currentPage().getParameters().get('rlId');
        //Ver 4.0: FR7.13
        Show2ndBlock = False;
        newId = ApexPages.currentPage().getParameters().get('newId');
        
        retURL= ApexPages.currentPage().getParameters().get('retURL');
        if(newId != NULL){
             Show2ndBlock = TRUE;
             showFirstBlock = False;
             clRecord = [Select Id, Questions_Comments__c, 
                         Sales_Comments__c
                         from  Lead 
                         where Id = :newId];
        }
        
        //Ver 4.0: FR7.13
        if(rlId != NULL){
             //Ver4.0: Code Start: CMAP FR-7.1: Autopopulate Values to New Channel Lead
             rlRecord = [Select Id, Contact__r.FirstName,Contact__r.LastName,
                               Contact__r.Title, 
                               Contact__r.Email, 
                               Contact__r.Phone, 
                               Contact__r.MobilePhone, 
                               Contact__r.Fax,
                               Contact__r.MailingStreet, 
                               Contact__r.MailingState, 
                               Contact__r.MailingPostalCode, 
                               Contact__r.MailingCountry, 
                               Contact__r.MailingCity,
                               //Ver 5.0
                               Contact__r.Salutation,
                               Account_Name__r.Industry, 
                               Account_Name__r.BillingStreet, 
                               Account_Name__r.BillingState, 
                               Account_Name__r.BillingPostalCode,
                               Account_Name__r.BillingCountry,
                               Account_Name__r.BillingCity,
                               //Ver 7.0 Code start
                               Relationship_Lead_Score__c,
                               //Ver 7.0 Code end
                               //Code Start:Defect 80411
                               Account_Name__r.Name,
                               //Code End: Defect 80411
                               Lead_ID_Do_Not_Edit__c, Name,
                               Consent_to_engage_Dell_Channel_Partner__c, 
                               Purchase_Timeframe__c, Employee__c, 
                               Dell_can_contact_me_in_the_future__c, 
                               Decision_Making_Role__c
                         From  Relationship_Lead__c 
                         where Id = :rlId];
             //Ver4.0: CMAP FR-7.1: Autopopulate Values to New Channel Lead
             //ver 5.0 : CRQ 0786 : Commented
            /*If(rlRecord.Lead_ID_Do_Not_Edit__c != NULL){
                DirLeadRecord = [Select Salutation From Lead Where Id = :rlRecord.Lead_ID_Do_Not_Edit__c];
            }*/
             //ver 5.0 : CRQ 0786 : Commented 
             //Ver4.0: Code End: CMAP FR-7.1: Autopopulate Values to New Channel Lead
            //if(rlRecord){
            rLeadObj = rlRecord;
            //}
        }
      }
      catch (Exception e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Default_Error_Message));
      } 
    }
    
    public pagereference cancelButton(){
        String URL = '/'+rlId ;
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;
    }  
    
    public pagereference redirect(){
        //new change with page display
        if(rLeadObj.Consent_to_engage_Dell_Channel_Partner__c == FALSE){
            showFirstBlock = True;
            pageUtils.AddError('Customer consent is required to route a Dell lead to a channel partner; upon checking the box, click “continue” to complete the “route to channel” process.');
        }
        else{
           //new change with page display
           String Status = pageUtils.encodeVariable('Qualified - Channel Ready');
           String cityString;
           String stateString;
           String postalString;
           String countryString;
           String R2CSource  = pageUtils.encodeVariable('Relationship Lead');//Ver 8.0:  Update R2C source
           if(rlRecord.Contact__r.MailingStreet == NULL &&
              rlRecord.Contact__r.MailingState == NULL && 
              rlRecord.Contact__r.MailingPostalCode == NULL && 
              rlRecord.Contact__r.MailingCountry== NULL  && 
              rlRecord.Contact__r.MailingCity == NULL){
                cityString = rlRecord.Account_Name__r.BillingCity;
                stateString = rlRecord.Account_Name__r.BillingState;
                postalString = rlRecord.Account_Name__r.BillingPostalCode;
                countryString = rlRecord.Account_Name__r.BillingCountry;
           }
           else{
                cityString = rlRecord.Contact__r.MailingCity;
                stateString = rlRecord.Contact__r.MailingState;
                postalString = rlRecord.Contact__r.MailingPostalCode;
                countryString = rlRecord.Contact__r.MailingCountry;
           }
           string saveURLstring ='/apex/CMAP_RouteToChannel?retURL='+rlRecord.Id;
           String URL = '/00Q/e?lea13='+Status+'&RecordType='+leadRTId+
                     '&nooverride=1&retURL='+rlRecord.Id+
                     '&saveURL='+saveURLstring+
                     '&00NA00000064hVv='+R2CSource+  //Ver 8.0:  Update R2C source
                     '&CF00NA00000063aoO_lkid='+rlRecord.Id+'&CF00NA00000063aoO='+rlRecord.Name+
                     //(rlRecord.Name!=NULL?'&CF00NZ0000000bA0S='+pageUtils.encodeVariable(rlRecord.Name):'')+
                     (rlRecord.Contact__r.FirstName!=NULL?'&name_firstlea2='+pageUtils.encodeVariable(rlRecord.Contact__r.FirstName):'')+
                     (rlRecord.Contact__r.LastName!=NULL?'&name_lastlea2='+pageUtils.encodeVariable(rlRecord.Contact__r.LastName):'')+
                     
                     //Ver4.0: Code Start: CMAP FR-7.1: Autopopulate Values to New Channel Lead
                     //Ver 5.0
                     (rlRecord.Contact__r.Salutation!=NULL?'&name_salutationlea2='+pageUtils.encodeVariable(rlRecord.Contact__r.Salutation):'')+
                     //ver 5.0
                     (rlRecord.Contact__r.MobilePhone!=NULL?'&lea9='+pageUtils.encodeVariable(rlRecord.Contact__r.MobilePhone):'')+
                     (rlRecord.Contact__r.Fax!=NULL?'&lea10='+pageUtils.encodeVariable(rlRecord.Contact__r.Fax):'')+
                     (rlRecord.Account_Name__r.Industry!=NULL?'&lea6='+pageUtils.encodeVariable(rlRecord.Account_Name__r.Industry):'')+
                     (cityString!=NULL?'&lea16city='+pageUtils.encodeVariable(cityString):'')+
                     (stateString!=NULL?'&lea16state='+pageUtils.encodeVariable(stateString):'')+
                     (postalString!=NULL?'&lea16zip='+pageUtils.encodeVariable(postalString):'')+
                     (countryString!=NULL?'&lea16country='+pageUtils.encodeVariable(countryString):'')+
                     //Ver 7.0 Code start
                     (rlRecord.Relationship_Lead_Score__c!=NULL?'&00NA0000009ZFtB='+pageUtils.encodeVariable(rlRecord.Relationship_Lead_Score__c):'')+
                     //Ver 7.0 Code end
                     //Ver4.0: Code End: CMAP FR-7.1: Autopopulate Values to New Channel Lead
                     //Code start: Defect 80411: To populate Company through URL
                     (rlRecord.Account_Name__r.Name!=NULL?'&lea3='+pageUtils.encodeVariable(rlRecord.Account_Name__r.Name ):'')+
                     //Code End: Defect 80411: To populate Company through URL
                     (rlRecord.Contact__r.Title!=NULL?'&lea4='+pageUtils.encodeVariable(rlRecord.Contact__r.Title):'')+
                     (rlRecord.Contact__r.Email!=NULL?'&lea11='+pageUtils.encodeVariable(rlRecord.Contact__r.Email):'')+
                     (rlRecord.Contact__r.Phone!=NULL?'&lea8='+pageUtils.encodeVariable(rlRecord.Contact__r.Phone):'')+
                     /*Ver2.0(rlRecord.Marketing_Comments__c!=NULL?'&00NA00000063WGw='+pageUtils.encodeVariable(rlRecord.Marketing_Comments__c):'')+
                     (rlRecord.Sales_Comments__c!=NULL?'&00NA00000063UTv='+pageUtils.encodeVariable(rlRecord.Sales_Comments__c):'')+
                     (rlRecord.Data_Center_Optimization__c!=NULL?'&00N70000002MSmi='+pageUtils.encodeVariable(rlRecord.Data_Center_Optimization__c):'')+
                     (rlRecord.End_user_Productivity__c!=NULL?'&00N70000002MSmn='+pageUtils.encodeVariable(rlRecord.End_user_Productivity__c):'')+
                     (rlRecord.IT_Process_Simplification__c!=NULL?'&00N70000002MSnb='+pageUtils.encodeVariable(rlRecord.IT_Process_Simplification__c):'')+ Ver 2.0*/
                     
                     (rlRecord.Purchase_Timeframe__c!=NULL?'&00N70000002MSnl='+pageUtils.encodeVariable(rlRecord.Purchase_Timeframe__c):'')+
                     (rlRecord.Dell_can_contact_me_in_the_future__c!=NULL?'&00N70000002MSnq='+pageUtils.encodeVariable(rlRecord.Dell_can_contact_me_in_the_future__c):'')+
                     (rlRecord.Decision_Making_Role__c!=NULL?'&00N70000002MSo0='+pageUtils.encodeVariable(rlRecord.Decision_Making_Role__c):'');
        
            pagereference page = new pagereference(URL);
            page.setRedirect(TRUE);
            return page;
        }
        return NULL;
    }
    public pagereference saveButton(){
        system.debug('----clRecord--'+clRecord);
        update clRecord;
        String URL= '/'+newId;
        system.debug('----URL--'+URL);
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;
        
    }
     /*Ver 6.0: Code Start: CRQ0797:  Remove Cancel button from the PL.
     public pagereference cancelButton2(){
        String URL = '/'+newId;
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;
    }
    Ver 6.0: Code Start: CRQ0797:  Remove Cancel button from the PL.*/
}
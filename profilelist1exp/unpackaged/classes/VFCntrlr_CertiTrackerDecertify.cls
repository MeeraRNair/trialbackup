public class VFCntrlr_CertiTrackerDecertify{ 
public static boolean isTestExecution = false;
    public PageReference confirm() {
        displayPopup = false;    
        Id RecordId = ApexPages.currentPage().getParameters().get('id');
        PageReference oRef = new PageReference('/' + RecordId);
        return oRef;        

  
        /*Updated with Current Date
        ctracker.De_Certification_Date__c = system.today();
        update ctracker;*/        
       // Sending emails. 
        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Certification_Process_Setup__c> lstRecords = [SELECT Send_Email_to_Partner_Admin__c,Region__c,Certification_Admin_Mailbox__c FROM Certification_Process_Setup__c where Send_Email_to_Partner_Admin__c =: true];
        List<String> lstEmails = new List<string>();
        if(lstRecords !=null && lstRecords.size()>0){
        for(Certification_Process_Setup__c oCPS : lstRecords){
        if(oCPS.Send_Email_to_Partner_Admin__c == true && oCPS.Certification_Admin_Mailbox__c != null){
                    lstEmails.add(oCPS.Certification_Admin_Mailbox__c);
        }
      }
      
      system.debug('==lstEmails===' + lstEmails);
                    String smail ='De-certification process';
                    mail.setSubject('De-certification process');    
                    mail.setToAddresses(lstEmails);                      
                    mail.setSenderDisplayName(userinfo.getUserName()); 
                    mail.setBccSender(true);  
                    mail.setPlainTextBody(smail); 
                    mail.setHtmlBody(smail);
      system.debug('==mail===' + mail);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      
     }   */   
    
  } 

    public VFCntrlr_CertiTrackerDecertify(){

    }

    private final Certification_Tracker__c ctracker;
    
    public VFCntrlr_CertiTrackerDecertify(ApexPages.StandardController stdController) {
        this.ctracker = (Certification_Tracker__c)stdController.getRecord();
    }    

    public boolean displayPopup {get; set;}     
    
    public PageReference closePopup() {        
        displayPopup = false;    
        Id RecordId = ApexPages.currentPage().getParameters().get('id');
        PageReference oRef = new PageReference('/' + RecordId);
        return oRef;
       
    } 
         
    public void confirmPopup(){        
        displayPopup = true;  
        PageReference oRef = null;
        Id AcctId = ApexPages.currentPage().getParameters().get('Acct');
        Id RecordId = ApexPages.currentPage().getParameters().get('id');
        
        Map<ID, String> mapAccIdStatus = new Map<ID, String>(); 
        Map<Id, Lead> leadToUpdate = new Map<Id, Lead>();
        List<ID> leadIds = new List<ID>();
        List<ID> accountIds = new List<ID>();
        system.debug('==RecordId==' + AcctId );  
        
        Account oAcct =[select id,Partner_Relationship__c from Account where id=: AcctId ];
        
        if(oAcct != null){
           //Update the Account Record.               
          // if(oAcct.Partner_Relationship__c == 'Premier' ){
          if(PartnerStatusUtilityClass.PremierTypeContains(oAcct.Partner_Relationship__c) ){
                  mapAccIdStatus.put(oAcct.id,'Preferred');
           }
           else 
           //if (oAcct.Partner_Relationship__c == 'Preferred' ){
           if (PartnerStatusUtilityClass.PreferredTypeContains(oAcct.Partner_Relationship__c) ){
                  mapAccIdStatus.put(oAcct.id,'Registered');
                   
           }
           }
           
        if(mapAccIdStatus.size()>0){
            leadToUpdate = CertificationTracker_UpdateSuggestion.LeadUpdate(mapAccIdStatus);
            System.debug('##Sudh## Leadto update' +leadToUpdate);
        }
    for(Id accId :mapAccIdStatus.keySet()){
        accountIds.add(accId);
        leadIds.add(leadToUpdate.get(accId).id);
        if(accountIds.size()==10){
            System.debug('###DEBUG### BEFORE LIMIT FUTURECALL = ' 
               + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls()); //Done 0 of 10
            if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls()) {
                //System.debug('###DEBUG### Reaching Limit, adding errors to ' + batchList);
                /*for(String tempId : accountIds) {
                    certTrackerMap.get(tempId).addError(
                    'Updates of Certification Tracker has hit Salesforce.com FutureCall Limit.');    
                }*/
            }
            else{
                //System.debug('###DEBUG### Processing ' + batchList);
                System.debug('###DEBUG### Processing  else' ); 
                if(isTestExecution == false){
                CertificationTracker_UpdateSuggestion.TrackerUpdateSuggestion(leadIds);
                }
            }
                        
                System.debug('###DEBUG### AFTER LIMIT FUTURECALL = ' + Limits.getFutureCalls() 
                     + ' of ' + Limits.getLimitFutureCalls());                
                        accountIds.clear();
                        leadIds.clear();
        }
    }
        
    //if no:of records <10    
    if(accountIds.size()>0){
        System.debug('###DEBUG### BEFORE LIMIT FUTURECALL = ' 
            + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
        if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls()) {
                //System.debug('###DEBUG### Reaching Limit, adding errors to ' + batchList);
                /*for(String tempId : accountIds) {
                    certTrackerMap.get(tempId).addError(
                    'Updates of Certification Tracker has hit Salesforce.com FutureCall Limit.');    
                }*/
         }
            else{
                //System.debug('###DEBUG### Processing ' + batchList);
                System.debug('###DEBUG### Processing  else' ); 
                if(isTestExecution == false){
                CertificationTracker_UpdateSuggestion.TrackerUpdateSuggestion(leadIds);
                }
            }
    }
                               
                  
        
        }
                   
    }
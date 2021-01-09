/*
 * Author   : Ismail
 * Purpose  : The batch class to notify channel leads (come from Zift to SFDC ) to Partner Users weekly basis.
 *        
 * Revision   CR Number    Release No       Date            Modified By     Description
 * --------   --------    -----------      ------            ------------    -----------
 * 1.0         16838       FY20-0202       9/1/2019
*/


global class BatchWeeklyZiftLeadNotifification implements Database.Batchable<sObject>{
    
    global EmailTemplate ziftEmailTemplate = null;
    private Integer intHeapSizeLimit; 
    private Integer intHeapSizeMaxUsage;
   
    
        
    public BatchWeeklyZiftLeadNotifification () {
    
        
        ziftEmailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = 'Weekly Channel Lead Notification to Zift'];
        
                
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Fetching all Leads which has been pushed from Zift to SFDC and passing to execute method
        
            String strquery = 'Select OwnerId, Owner.Name, Owner.Email From Lead '+
                                            'Where '+ 
                                            'Zift_Unique_ID__c != null ' +
                                            'and owner.type = \'user\' '+
                                            'and (CreatedDate >= LAST_n_DAYS:7) '+
                                            'and Owner.IsActive = TRUE ';
       
       return Database.getQueryLocator(strquery);

    }
    
    global void execute(Database.BatchableContext bc, list<sObject> listscope) {
        processLeads(listscope);
           
    }
    
    public void processLeads(List<sObject> listscope){
        Map<String, String> mapEmail = new Map<String, String>();
        
        for(Lead leadst: (List<Lead>)listscope ){
            mapEmail.put(leadst.OwnerId, leadst.Id);    
        }
        
        if(mapEmail.size() > 0){
            sendMail(mapEmail);
        }        
    }
    
   public void sendMail(Map<String, String> mapEmail ) {
      // Create an email message object
      list<Messaging.SingleEmailMessage> listMail= new list<Messaging.SingleEmailMessage>();
      OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'No_reply@dell.com'];
      for(String strleadOwnerId : mapEmail.keySet()){
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setOrgWideEmailAddressId(owea.Id);
          mail.setWhatId(mapEmail.get(strleadOwnerId));
          mail.setTargetObjectId(strleadOwnerId);
          mail.setTemplateId(ziftEmailTemplate.Id);
          mail.setSaveAsActivity(false);
          listMail.add(mail);
      }
       
      List<Messaging.SendEmailResult> listresults = new List<Messaging.SendEmailResult>();
      
      if(!Test.isRunningTest()){
          listresults = Messaging.sendEmail (listMail);
      } 
         
      // Call a helper method to inspect the returned results
      inspectResults(listresults);
   
       
   }
   // Helper method
   private static Boolean inspectResults(Messaging.SendEmailResult[] listresults ) {
      Boolean bsendResult = true;
      // sendEmail returns an array of result objects.
      // Iterate through the list to inspect results. 
      // In this class, the methods send only one email, 
      // so we should have only one result.
      for (Messaging.SendEmailResult res : listresults ) {
         if (res.isSuccess()) {
            System.debug('Email sent successfully');
         }
         else {
            bsendResult = false;
            System.debug('The following errors occurred: ' + res.getErrors());                 
         }
      }
      return bsendResult;
   }         
    global void finish(Database.BatchableContext bc) {
        //v4.0 clear the map
        //mapManagerInfo.clear();
    }
    
}
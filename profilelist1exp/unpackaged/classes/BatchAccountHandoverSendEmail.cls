/* 
History:
Version     Date            Modified By     CR          Description     
--------------------------------------------------------------------------------------
1.0         19-Aug-2015     Shue            11838       Batch created to Reduce emails-combining emails 
2.0         03-Sep-2015     Shue            11838       To send email to Incoming Rep and AE
3.0
4.0         02-Mar-2016     Shue            12700       1275965:Account Handover Email Issue fix for SAR-13691
5.0         19-May-2016     Rajkumar        14340       Commented query
6.0         23-May-2016     Rajkumar        14445       recipients should be Account Transition Owner
*/

global class BatchAccountHandoverSendEmail implements Database.Batchable<SObject>{
    public String query;
    public DateTime theDate;
    
    //1-- Query for Account_Handover__c created 24hours from now
    global Database.QueryLocator start(Database.BatchableContext BC) {
        theDate = DateTime.now().addDays(-1);
        System.debug('### BatchAccountHandoverSendEmail STARTS ###');
        //5.0 - Commented Query
        // query= 'Select User.Id from User where User.Id in (SELECT Incoming_rep__c FROM Account_Handover__c WHERE Incoming_rep__c != null AND Transition_Start_date__c != null AND day_only(CreatedDate) >= :theDate) Limit 1';
        return Database.getQueryLocator(query);
    }
    
    //2-- Get all unique ATO from 24 hours before now
    private void consolidateATOIdList(List<SObject> scope, List<id> accountTransitionIDList){
        for(SObject AccountTransitionOwner : scope){
            accountTransitionIDList.add(AccountTransitionOwner .id);
        }
    }
    
    //3-- Get Accounts of all unique ATO from 24 hours before now
    private void constructATOAccountIdMap(List<id> accountTransitionIDList, Set<id> setAcc, Map<Id, Set<Id>> accountTransitionIDMap){
        // 5.0 Added Account Transition Owner Field in Query
        for(Account_Handover__c ahAccount : [SELECT Account__c, Account_Transition_Owner__c  FROM Account_Handover__c WHERE Transition_Start_date__c != null AND CreatedDate >= :thedate AND Account_Transition_Owner__c IN :accountTransitionIDList]){
            if(!accountTransitionIDMap.containsKey(ahAccount.Account_Transition_Owner__c)){
                accountTransitionIDMap.put(ahAccount.Account_Transition_Owner__c, new Set<id>{});
            }
            accountTransitionIDMap.get(ahAccount.Account_Transition_Owner__c).add(ahAccount.Account__c);
            //3.0
            setAcc.add(ahAccount.Account__c);
        }
    }
  
    
    //2.0
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        //2.0
        List<id> accountTransitionIDList = new List<id>();
        Map<Id, Set<Id>> accountTransitionIDMap = new Map<Id, Set<Id>>();
        
        //3.0
        Set<id> setAcc = new Set<id>();
        Map<Id, String> AccountAEMap = new Map<Id, String>();
        
        //4.0
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        
        try{
            //4.0 Story 1275965:Account Handover Email Issue fix for SAR-13691
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no_reply@dell.com'];
            
            consolidateATOIdList(scope, accountTransitionIDList);
            constructATOAccountIdMap(accountTransitionIDList, setAcc, accountTransitionIDMap);
            
            //5-- Iterate each Incoming Rep
            for (Id IRid : accountTransitionIDMap.keySet()){
                Set<Id> accSet = accountTransitionIDMap.get(IRid);
                List<String> ATOemails = new List<String>();

                try{
                    if(accSet == null){
                        continue;
                    }
                    
                    for (Id accId : accSet){
                        if(AccountAEMap.get(accId) !=null){
                            ATOemails.add(AccountAEMap.get(accId));  
                        }
                    }

                    //6-- Construct Emails
                    //4.0 Story 1275965:Account Handover Email Issue fix for SAR-13691
                    Messaging.SingleEmailMessage mail = getEmail(); 
                    if (owea.size() > 0) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    mail.setTargetObjectId(IRid);
                    mail.setToAddresses(ATOemails);
                    mail.setReplyTo('No_Reply@Dell.com');
                    mail.setSaveAsActivity(false);
                    mail.setUseSignature(false);
                    mail.setTemplateId(Label.Account_Handover_Incoming_Rep_Email_Template);
                    lstMails.add(mail);
                }catch (Exception e){
                    handleError(e);        
                }
            }
        }catch (Exception e){
            handleError(e);
        }

        //7-- Send Emails
        //4.0 Story 1275965:Account Handover Email Issue fix for SAR-13691
        try{
            System.debug('BatchAccountHandoverSendEmail Send email size-- '+lstMails.size());
            Messaging.sendEmail(lstMails);   
        }catch (Exception e){
            handleError(e);
        }
    }

    // Handle all exceptions
    @TestVisible private void handleError(Exception e) {
        System.debug('### Error Stack Trace : ' + e.getStackTraceString());
        System.debug('### Message : ' + e.getMessage());
    }

    //4.0 Story 1275965:Account Handover Email Issue fix for SAR-13691
    public static Messaging.SingleEmailMessage getEmail() {
        Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
        mailMessage.setSaveAsActivity(false);
        return mailMessage;
    }

    global void finish(Database.BatchableContext info) {
        system.debug ('BatchAccountHandoverSendEmail finish at ' + theDate );
    }
}
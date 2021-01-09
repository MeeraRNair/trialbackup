/*
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12485    16.12       16 Dec 2015     Dipin Raju      Batch class to trigger FAP Annual reminder to Partner Admins
 * 2.0      CR 15931    FY19-DCE-0602   18-May-2018 Abhinav         Created utility method and moved email logic under AccountUtils class
 * 
 */
 
global class BatchFAPAnualReminder2PartnerAdmins implements Database.Batchable <sObject> , Database.Stateful {
    
    public BatchFAPAnualReminder2PartnerAdmins () {
      
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
       return Database.getQueryLocator([select Id, Name from Account where IsPartner=True and Approved_for_Partner_Finder__c = True and Profile_Published_to_Partner_Finder__c = 'Yes' and DAY_ONLY(Date_of_Profile_Update__c)=:System.Today()-365]);
    
    }
    
    global void execute(Database.BatchableContext bc, list<sObject> scope) {
        List<Id> accList = new List<Id>();
        for(Account acc: (list<Account>) scope) {
            accList.add(acc.Id);
        }
        
        //V2.0 BOF
        AccountUtils.SendEmailToPartnerAdminUtils('BatchFAPAnualReminder2PartnerAdmins', 'FAP_Annual_Reminder_', 'en_US', accList, new List<User>(), new PartnerRegistrationDomainDuplicateCheck.PartnerInfo());
    }
    
    global void finish(Database.BatchableContext bc) {
      
    }
}
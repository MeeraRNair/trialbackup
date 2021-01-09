public class CPSDUpdateAccountstatusAU {
// Added by Ershad for CPSD Account Flag to make waiting sync
    public static void cpsdAccountupdate(list<Account> listAccounts,map<Id, Account> mapAccounts){
        List<Account> listaccnt=new List<Account>();
        if(Recursion_check.bisFirstTime)
         {
           Recursion_check.bisFirstTime = false;
		   for(Account acc : listAccounts){
               if(acc.CPSD_Account_ID__c!=Null && acc.CPSD_Integration_Status__c!=Null){
                   Account accd=mapAccounts.get(acc.id);
                   if(acc.Phone!=accd.Phone||acc.Website!=accd.Website||acc.Account_Classification__c!=accd.Account_Classification__c||acc.EMC_ID__c!=accd.EMC_ID__c||acc.Account_ID__c!=accd.Account_ID__c){
                       Account ann=new Account();
                       ann.Id=acc.Id;
                       ann.CPSD_Integration_Status__c='Waiting Sync';
                       listaccnt.add(ann);
                   }
               }
           }
             
             if(!listaccnt.isEmpty() && listaccnt.size()>0){
                 try{
                     TriggerExecutionController.setSkipAllTriggers(true);
                     Database.update(listaccnt,False);
                     TriggerExecutionController.setSkipAllTriggers(false);
                 }catch(Exception ex) {
                System.Debug('Error :' + ex.getMessage());
                }
             }
         }
    }
    
}
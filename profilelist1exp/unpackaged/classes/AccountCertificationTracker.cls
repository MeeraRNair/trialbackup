/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to Account and Certification_Tracker__c object. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 8012     14.05       07-May-2013     Aditya          Create Certification Tracker record if the Account meet the condition
 * 2.0      CR 10751    16.03       19-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 *
 */

public class AccountCertificationTracker {

    // This logic is separated from afterInsertUpdatePartnerStatus trigger and rewritten as part of trigger redesign.
    public static void updateCertificationTrackerDetails(map<Id, Account> mapAccountsForCertificationProcess, map<Id, Account> mapNewAccounts, map<Id, Account> mapOldAccounts) {
        list<Certification_Tracker__c> lstCertificationTrackers = new list<Certification_Tracker__c>();
        
        for(Certification_Tracker__c certificationTracker : [select Id, Account_Name__c, Certification_Date__c, Audit_Date__c, Certification_Changed_Date__c, 
                                                                Previous_Partner_Relationship_Type__c, De_Certification_Date__c 
                                                             from Certification_Tracker__c where Account_Name__c in :mapAccountsForCertificationProcess.keySet()]) {
            Account newAccount = mapNewAccounts.get(certificationTracker.Account_Name__c);
            Account oldAccount = mapOldAccounts.get(certificationTracker.Account_Name__c);
            
            // Updating certification date and audit date
           // if((oldAccount.Partner_Relationship__c != 'Preferred' && oldAccount.Partner_Relationship__c != 'Premier') && (newAccount.Partner_Relationship__c == 'Preferred' || newAccount.Partner_Relationship__c == 'Premier')) {
             //new centralized logic
             System.debug('>>> '+oldAccount.Partner_Relationship__c);
             System.debug('>>>>>>> '+newAccount.Partner_Relationship__c);
             System.debug('Old value Not contains '+PartnerStatusUtilityClass.PreferredTypeNotContains(oldAccount.Partner_Relationship__c));
             System.debug('Old value Not contains '+PartnerStatusUtilityClass.PremierTypeNotContains(oldAccount.Partner_Relationship__c));
             
             System.debug('new value contains '+PartnerStatusUtilityClass.PreferredTypeNotContains(newAccount.Partner_Relationship__c));
             System.debug('new value  contains '+PartnerStatusUtilityClass.PremierTypeNotContains(newAccount.Partner_Relationship__c));
              
              if((PartnerStatusUtilityClass.PreferredTypeNotContains(oldAccount.Partner_Relationship__c) && PartnerStatusUtilityClass.PremierTypeNotContains(oldAccount.Partner_Relationship__c)) &&( (PartnerStatusUtilityClass.PremierTypeContains(newAccount.Partner_Relationship__c))|| (PartnerStatusUtilityClass.PreferredTypeContains(newAccount.Partner_Relationship__c)))){
                   System.debug('In side if');
                 if(certificationTracker.Certification_Date__c == null) {
                    certificationTracker.Certification_Date__c = System.today();
                    
                    Integer cYear= certificationTracker.Certification_Date__c.year();
                    Date certDate = Date.newInstance(cYear, 06, 30);
                    Integer newYear = cYear + 1;
                    if(certificationTracker.Certification_Date__c <= certDate) { 
                        certificationTracker.Audit_Date__c = Date.newInstance(newYear, 06, 30); 
                    }
                    else {
                        certificationTracker.Audit_Date__c = Date.newInstance(newYear, 12, 31);    
                    }
                }
            }
            
            // Updating certification changed date and previous partner relationship
            certificationTracker.Certification_Changed_Date__c = System.today();
            certificationTracker.Previous_Partner_Relationship_Type__c = oldAccount.Partner_Relationship__c;
            
            // Updating De-Certification_Date
            //if((oldAccount.Partner_Relationship__c == 'Premier' && newAccount.Partner_Relationship__c == 'Preferred')   || (oldAccount.Partner_Relationship__c == 'Preferred' && newAccount.Partner_Relationship__c == 'Registered')) {
            //new centralized logic
            if((PartnerStatusUtilityClass.PremierTypeNotContains(oldAccount.Partner_Relationship__c)  && PartnerStatusUtilityClass.PreferredTypeContains(newAccount.Partner_Relationship__c))   || (PartnerStatusUtilityClass.PreferredTypeContains(oldAccount.Partner_Relationship__c) && PartnerStatusUtilityClass.RegisteredTypeContains (newAccount.Partner_Relationship__c))) {
                
                certificationTracker.De_Certification_Date__c = System.today();
            }
            
            lstCertificationTrackers.add(certificationTracker);
        }
        
        if(!lstCertificationTrackers.isEmpty()) {
            update lstCertificationTrackers;
        }
    }
    
    // v1.0 - Method for creating Certification_Tracker__c whenever Partner Account of Type 'Partner' is updated and it already has Certification_Tracker__c
    // v2.0 - This logic is separated from accountTrigger
    public static void checkAndCreateCertificationTrackers(set<Id> setAccountIds) {
        set<Id> setAccIdsToSkip = new set<Id>();
        for(AggregateResult aggregate : [select Account_Name__c, count(Id) from Certification_Tracker__c where Account_Name__c in :setAccountIds group by Account_Name__c]) {
            setAccIdsToSkip.add((Id)aggregate.get('Account_Name__c'));
        }
        setAccountIds.removeAll(setAccIdsToSkip);
        if(!setAccountIds.isEmpty()) {
            AccountCertificationTracker.createCertificationTrackers(setAccountIds);
        }
    }
    
    // v1.0 - Method for creating Certification_Tracker__c
    // v2.0 - This logic is separated from accountTrigger
    public static void createCertificationTrackers(set<Id> setAccountIds) {
        list<Certification_Tracker__c> lstCertificationTrackers = new list<Certification_Tracker__c>();
        for(Id accId : setAccountIds) {
            Certification_Tracker__c certificationTracker = new Certification_Tracker__c(Account_Name__c = accId, Evaluate_Criteria__c = true);
            lstCertificationTrackers.add(certificationTracker);
        }
        
        if(!lstCertificationTrackers.isEmpty()) {
            try {
                Database.insert(lstCertificationTrackers);
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

}
/*
 * Author  : Nagaraju Yelluri
 * Purpose : Buddy Cleanup Functionality
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR14846      10.01      25-Aug-2017     Nagaraju        Deletes old Buddy ATM requests which are in Access Removed Status.
   2.0      CR15639                  18-Apr-2018    Jatin           Modify Batch Size of the class from 50K to 10k and added Order By GDM_Request__r.Buddy_Access_End_Date__c. 
 */
global class BuddyCleanUpScheduler implements Schedulable   {
    
    global void execute(SchedulableContext sc) {
        Integer intCleanDays = Integer.valueof(System.Label.BuddyCleanupDays);
        // Modify Batch Size of the class from 50K to 10k and added Order By Buddy_Access_End_Date__c(by jatin)
        String strQuery = 'SELECT Id FROM GDM_Request__c WHERE recordtype.developerName = \'ATM_History_For_Buddy_Access\' and GDM_Request__r.Buddy_Access_Status__c = \'Access removed\' AND GDM_Request__r.Buddy_Access_End_Date__c < last_n_days:'+intCleanDays+' order by GDM_Request__r.Buddy_Access_End_Date__c  limit 10000';
        system.debug('sstrQuery---'+strQuery);
        List<GDM_Request__c> listToDelete = Database.query(strQuery);
        if (listToDelete != null) {
            try{
                System.debug('Total records1 :' + listToDelete.size());            
                Database.delete(listToDelete,false);
            }catch(Exception e){
                System.debug('Exception Message :'+e.getMessage());
            }
        }
    }
}
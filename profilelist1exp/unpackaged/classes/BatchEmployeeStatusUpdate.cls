/*************************************************************************************************************
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Jiji        5-July-2013     14.5        8413    Batch Apex to Clear 
                                                            ISM/RSM/Director Users, 
                                                            if the ISM/RSM/Directors are 
 
 
2.0      Rahul        2-July-2018                           Code Reduce!                           
-------------------------------------------------------------------------------------------                               
************************************************************************************************************/
global class BatchEmployeeStatusUpdate implements Database.Batchable<sObject> {
    public Boolean isTest = False;
    public String query;
    public string uniqueName;
    global database.querylocator start(Database.BatchableContext BC){
        //system.debug('---11111----'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<String, PeopleSoft_User_View__c> psHierchyMap = new Map<String, Peoplesoft_User_View__c> ();
        List<PeopleSoft_User_View__c> psHierchyListToUpd = new List<Peoplesoft_User_View__c> ();
        peoplesoft_user_view__c peopleSoftRec;
        List<User> userListToUpd = new List<User> ();
       try{
            for(sObject obj :scope){
                peopleSoftRec = (peoplesoft_user_view__c)obj;
                psHierchyMap.put(peopleSoftRec.Employee_Name__c, peopleSoftRec);
            }
                if(psHierchyMap.Size() > 0){
                for(User u :[Select Id, Name, ISM__c, RSM__c, Director__c from User where ISM__c IN :psHierchyMap.keySet() OR
                            RSM__c IN :psHierchyMap.keySet() OR
                            Director__C IN :psHierchyMap.keySet()]){
                    if(psHierchyMap.get(u.ISM__c) != NULL){
                        u.ISM__c= NULL;
                    }
                    if(psHierchyMap.get(u.RSM__c) != NULL){
                        u.RSM__c= NULL;
                    }
                    if(psHierchyMap.get(u.Director__c) != NULL){
                        u.Director__c= NULL;
                    }
                    userListToUpd.add(u);
                }
            }
                if(userListToUpd.size()> 0){
                database.SaveResult[] updateExcResults;
                updateExcResults = database.update(userListToUpd, false);
             }
       }
       catch (System.DmlException e){
           system.debug('----Exception Occured--'+e);
          }  
       }
    global void finish(Database.BatchableContext info){  
        datetime systime = system.now();
        integer dueHours = integer.ValueOf(System.Label.UserEmployeeStatus);
        String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;
        datetime todayPlusSec = systime.addHours(dueHours); 
        seconds = string.valueOf(todayPlusSec.second());
        minutes = string.valueOf(todayPlusSec.minute()); 
        hours = string.valueOf(todayPlusSec.hour());      
        dayOfMonth = string.valueOf(todayPlusSec.day());
        month = string.valueOf(todayPlusSec.month());
        dayOfWeek = '?';
        year = string.valueOf(todayPlusSec.year()); 
        String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
        systime = systime.addHours(dueHours);
        BatchEmployeeStatusUpdateScheduler b = new BatchEmployeeStatusUpdateScheduler (); //this is the name of the scheduler of the next batch class i need to call
        system.schedule('BatchEmployeeStatusUpdate' + (uniqueName != null ? uniqueName : '') + string.valueof(systime), schTime, b); //here i am schedulling the next batch class. batch class name - updatinguserRecord2
    } 
}
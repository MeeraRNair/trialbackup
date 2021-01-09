global class SOM_GroupBatch implements Database.Batchable<sObject> {

    public String query;
    global database.querylocator start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(query);
    }

    List <SOM_Boomi_Log__c> logrecords = new List <SOM_Boomi_Log__c>();
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject obj :scope){
            SOM_Boomi_Log__c somBoomiLobRec = (SOM_Boomi_Log__c)obj;
            logrecords.add(somBoomiLobRec);
        }

        database.Deleteresult[] deleteGMResults = database.delete(logrecords, false);
     }
     global void finish(Database.BatchableContext BC){
        if(LimitUtils.getAllowableQueries() > 0){
            AsyncApexJob a = [SELECT 
                                Id, 
                                Status, 
                                NumberOfErrors, 
                                JobItemsProcessed,
                                TotalJobItems, 
                                CreatedBy.Email,
                                CompletedDate,
                                ExtendedStatus,                         
                                JobType,
                                MethodName                                  
                              FROM AsyncApexJob
                              WHERE Id = :BC.getJobId()];
       }

       datetime systime = system.now();
       integer dueHours = 24;
       String cmap_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
       String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;
       // add 24 Hrs before scheduling the next job
       datetime TodayPlusSec = systime.addHours(dueHours); 
       seconds = string.valueOf(TodayPlusSec.second()); 
       minutes = string.valueOf(TodayPlusSec.minute()); 
       hours = string.valueOf(TodayPlusSec.hour());      
       dayOfMonth = string.valueOf(TodayPlusSec.day());
       month = string.valueOf(TodayPlusSec.month());
       dayOfWeek = '?';
       year = string.valueOf(TodayPlusSec.year()); 
       //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
       String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;

       SOM_BoomiLogScheduler schJob = new SOM_BoomiLogScheduler();   
       datetime TodayDate = datetime.now();

       system.schedule('SOM_GroupBatch' +String.valueOf(TodayDate), schTime, schJob);
    }
    
}
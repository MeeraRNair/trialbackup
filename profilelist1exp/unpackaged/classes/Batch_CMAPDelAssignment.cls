/* 
REVISION HISTORY
======================================================================================================================
Version    Author    Date           Release#    CR#    Description
-------    ------    ----           --------    ---    -----------
1.0        Jiji      03-Jun-2014     15.07      9355   Batch class to delete permissionset assignment during R2C/R2S
*/
global class Batch_CMAPDelAssignment implements Database.Batchable<sObject> {
    public String query;
    global database.querylocator start(Database.BatchableContext BC){
      DBUtils.flushOutTheJobsQueue();
      return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
              List<PermissionSetAssignment> assignmentListToDel = new List<PermissionSetAssignment>();
              for(sObject sObj : scope){        
                  PermissionSetAssignment assignmentObj= (PermissionSetAssignment)sObj;
                  datetime systime = datetime.now();
                  system.debug('---systime ---'+systime );
                  datetime TodayPlusSec = systime.addMinutes(-30);
                  String systemtimestamp = assignmentObj.SystemModstamp.format('yyyy-MM-dd\'T\'HH:mm:Ss\'Z\'');
                  String dateperiod = TodayPlusSec.format('yyyy-MM-dd\'T\'HH:mm:Ss\'Z\'');
                  if(systemtimestamp <= dateperiod){
                      assignmentListToDel.add(assignmentObj);
                  }
              }
              if(assignmentListToDel.Size() > 0){
                  system.debug('### leadToUpdate:' + assignmentListToDel);
                  delete assignmentListToDel;
              }
        }catch (Exception e){
              system.debug('----System.Debug----'+e);
        } 
      
    }// end of execute method
    global void finish(Database.BatchableContext BC){
       String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;
       datetime systime = datetime.now();
       datetime TodayPlusSec = systime.addMinutes(30);
       seconds = string.valueOf(TodayPlusSec.second());
       minutes = string.valueOf(TodayPlusSec.minute()); 
       hours = string.valueOf(TodayPlusSec.hour());      
       dayOfMonth = string.valueOf(TodayPlusSec.day());
       month = string.valueOf(TodayPlusSec.month());
       dayOfWeek = '?';
       year = string.valueOf(TodayPlusSec.year()); 
       String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
       Batch_CMAPDelAssignmentScheduler u = new Batch_CMAPDelAssignmentScheduler (); 
       system.schedule('Batch_CMAPDelAssignmentScheduler' + string.valueof(TodayPlusSec), schTime, u);
       
    }
}
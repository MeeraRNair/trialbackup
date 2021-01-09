/*
 * Author  : Gan
 * Purpose : BatchUserTerminationWeeklyScheduler to terminate non chatter user on a weekly basic 
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      15073       FY18-DCS-0102   22-Dec-2017     Gan                                                                     
 * 1.1		TFS4530549	FY18-DCS-0102   17-Jan-2018		Gan
 * 2.0		15610		FY19-DCS-0502	10-Apr-2018		Gan				restructure the query for unit test to pass
 * 3.0      15736       FY19-DCE-0602   04-May-2018     Gan			    Fix the error where integration user being terminated due to data error
 
 */
global class BatchUserTerminationWeeklyScheduler implements Schedulable {
    //2.0
    DateTime dtToday = system.Today();
    String strFormatedDts = dtToday.format('yyyy-MM-dd');
    Integer intTerminationBackDate = integer.ValueOf(System.Label.UserTerminationWeeklyBackDate);
    String dtToDate = (dtToday - intTerminationBackDate).format('yyyy-MM-dd');
    public String strSql = 'select License_Used__c, Badge_Number__c,email,username, Title, userRoleId, IsActive, Due_to_Deactivate__c'+
                              ' FROM user'+ 
                              ' WHERE Due_to_Deactivate__c <= ' + strFormatedDts +
          					  ' AND Due_to_Deactivate__c >= ' + dtToDate +
                              //3.0
                              ' and IsActive = TRUE AND License_Used__c in (\'Salesforce\',\'Chatter Only\') ';
    
    global void execute(SchedulableContext SC) {
      BatchUserTerminationWeekly userBatchRecord = new BatchUserTerminationWeekly ();
      //2.0
      userBatchRecord.strQuery = strSql; 
                      
      system.debug('###userBatchRecord.query####' +userBatchRecord.strQuery);
      integer intRecordCount  = integer.ValueOf(System.Label.UserTerminationWeeklyBatchSize);
 	  database.executebatch(userBatchRecord,intRecordCount); 
   }
}
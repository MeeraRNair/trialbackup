/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 8586                 18-Aug-2013     Sandhya         Partner receives a daily summary email once lead assigned to Partner - same day, 2day and 5 day
 * 2.0      CR 9528                 12-May-2014     Meera           
 * 3.0      CR 10742    16.03       02-Jan-2015     Anamika/Ragu    Allow the partner admin or partner company to indicate who receives the notices for “Leads are ready” and who doesn't.
 * 4.0      CR 15057    DCS0203     13-Jan-2018     Naga Boyina     Added enable notification to channel lead condition to restrict email trigger when the field is unchecked
 * 5.0      CR 16091  FY19-DCS-0802 27-June-2018    Pallavi         Removed comments as part of code reduce for the story 5101935
 * 6.0      xxxxx       FY20-0402   26-Mar-2019     Shue            PMD violations fix
 */

global class CMAP_PartnerDailySummaryScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        Integer intScheduleTime = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_Time) - 8; 
        DateTime dtTime10 = Datetime.newInstance(System.today(), Time.newInstance(intScheduleTime, 0, 0, 0)); // 10PM CDT
        String strCdtTime10formatedDt = dtTime10.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        Integer intHourRange = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_HourRange);
        Datetime dtMinus24 = dtTime10.addHours(-intHourRange);
        String strMinus24formatedDt = dtMinus24.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        CMAP_PartnerDailySummaryBatch dailySummaryBatch = new CMAP_PartnerDailySummaryBatch();
        // v3.0 - Start
        //dailySummaryBatch.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c, Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' and Lead_Assigned_Date__c >= ' + strMinus24formatedDt + ' and Lead_Assigned_Date__c <= ' + dtTime10_formatedDt + ' order by Partner_User__c';
        dailySummaryBatch.query = 'Select Id, RecordTypeId, Lead_Assigned_Date__c, Partner_User__c, Partner_User__r.Enable_notifications_about_Channel_Leads__c From Lead Where Status = \'Assigned to Channel partner\' and Lead_Assigned_Date__c >= ' + strMinus24formatedDt + ' and Lead_Assigned_Date__c <= ' + strCdtTime10formatedDt + ' order by Partner_User__c';
        // v3.0 - End
        
        dailySummaryBatch.type = null;
        Database.executeBatch(dailySummaryBatch, 20);
    }   
}
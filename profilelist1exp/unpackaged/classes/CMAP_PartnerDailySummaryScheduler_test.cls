/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
  * 1.0      CR 16091  FY19-DCS-0802 27-June-2018   Pallavi         Removed commented and debug statement as part of code reduce for the story 5101935
  * 2.0      xxxxxx     FY20-0402                   Shue            CMAP-PAM - PMD Violations Fix
 */
@isTest
public class CMAP_PartnerDailySummaryScheduler_test{


  static testMethod void myTestOneDay(){
  
      Test.startTest();
        String strCRONEXP = '0 0 0 * * ?';
        CMAP_PartnerDailySummaryScheduler  sch = new CMAP_PartnerDailySummaryScheduler();
        String strJobId = System.schedule('batchWeeklyEmail TestScheduledApex',strCRONEXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :strJobId];
        System.assertEquals(strCRONEXP,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
  }
}
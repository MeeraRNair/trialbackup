/**
History:
Version     Date            Modified By             CR          Description     
--------------------------------------------------------------------------------------
1.0         10-Jan-2019     Shahiruni Wahida        16957       STORY 4983053: Lead 2.0 - Campaign Status enhancements (Aborted status) 
 */

@isTest
private class BatchUpdateCampaignMemberExecuteTest{
    static testMethod void invoke() {
        Test.startTest();
            String strCronEXP = '0 0 0 1 1 ? 2025';  
            String strJobId = System.schedule('test BatchUpdateCMExecuteTest', strCronEXP , new BatchUpdateCampaignMemberExecute() );

            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :strJobId];

            System.assertEquals(strCronEXP, ct.CronExpression);
            
        Test.stopTest();
    }
}
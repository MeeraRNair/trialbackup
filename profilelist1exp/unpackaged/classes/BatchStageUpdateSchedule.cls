global class BatchStageUpdateSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        
        BatchStageUpdate batchObj = new BatchStageUpdate();
        Id protectedDealRT=PageUtils.getRecordTypeId('Opportunity','Protected Deal', true);
        Date pastDate = Date.today()-7;
        String formattedDate = pastDate.year() + '-';
        if(pastDate.month() < 10) {
            formattedDate += '0';
        }
        formattedDate += pastDate.month() + '-';
        if(pastDate.day() < 10) {
            formattedDate += '0';
        }
        formattedDate += pastDate.day();
        String dateRange=formattedDate+'T00:00:00.000Z';
            batchObj.query = 'SELECT Id,RecordTypeId, StageName,Deal_Registration_status__c,Reason_Won_Lost__c,Other_Competitor_Lost_To__c,Competitor_Lost_To__c,Region__c,Partner_Opportunity_Stage__c '+
                         'FROM Opportunity '+
                        'WHERE Deal_Created_Date_Time__c != null AND RecordTypeId != \''+protectedDealRT+'\' AND ((((Partner_Opportunity_Stage__c =\'Plan - 1%\' OR Partner_Opportunity_Stage__c =\'Discover - 10%\' OR Partner_Opportunity_Stage__c =\'Qualify - 30%\' OR Partner_Opportunity_Stage__c =\'Propose - 60%\' OR Partner_Opportunity_Stage__c =\'Commit - 90%\')AND ( StageName =\'Propose - 60%\' OR StageName =\'Commit - 90%\' OR StageName =\'Qualify - 30%\' OR StageName =\'Discover - 10%\' OR StageName =\'Plan - 1%\' )) AND Deal_Expiration_Date__c<='+formattedDate+
                        ') OR( Deal_Registration_status__c=\'New\' AND StageName!=\'Lost, Cancelled - 0%\' AND CreatedDate<='+dateRange+'))';
                       
        database.executebatch(batchObj,1);
    }
}
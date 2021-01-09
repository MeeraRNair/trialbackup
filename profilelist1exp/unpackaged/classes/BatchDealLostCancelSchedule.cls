global class BatchDealLostCancelSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        
        BatchDealLostCancel batchObj = new BatchDealLostCancel();
        Id ChannelOpportunity=PageUtils.getRecordTypeId('Opportunity','Channel Opportunity', true); 
        Id DealRegistration=PageUtils.getRecordTypeId('Opportunity','Deal Registration', true); 
        Id DealRegExistingEndCustomer=PageUtils.getRecordTypeId('Opportunity','Deal Registration for Existing End Customer', true); 
        Id DealRegSubmitted =PageUtils.getRecordTypeId('Opportunity','Deal Registration-Submitted', true);
        
        Date pastDate1 = Date.today()-1;
        String formattedDate1 = pastDate1.year() + '-';
         if(pastDate1.month() < 10) {
            formattedDate1 += '0';
        }
        formattedDate1 += pastDate1.month() + '-';
        if(pastDate1.day() < 10) {
            formattedDate1 += '0';
        }
        formattedDate1 += pastDate1.day();
       
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
            batchObj.query = 'SELECT Id,RecordTypeId,StageName,Deal_Registration_status__c,Reason_Won_Lost__c,Other_Competitor_Lost_To__c,Competitor_Lost_To__c,Region__c,Partner_Opportunity_Stage__c '+ 
            'FROM Opportunity '+ 
            'WHERE  Deal_Created_Date_Time__c != null  AND (RecordTypeId = \''+ChannelOpportunity+'\' OR  RecordTypeId = \''+DealRegistration+'\' OR RecordTypeId = \''+DealRegSubmitted+'\' OR RecordTypeId = \''+DealRegExistingEndCustomer+'\') AND ((((Partner_Opportunity_Stage__c =\'Plan - 1%\' OR Partner_Opportunity_Stage__c =\'Discover - 10%\' OR Partner_Opportunity_Stage__c =\'Qualify - 30%\' OR Partner_Opportunity_Stage__c =\'Propose - 60%\' OR Partner_Opportunity_Stage__c =\'Commit - 90%\')AND ( StageName =\'Propose - 60%\' OR StageName =\'Commit - 90%\' OR StageName =\'Qualify - 30%\' OR StageName =\'Discover - 10%\' OR StageName =\'Plan - 1%\' )) AND Deal_Expiration_Date__c <='+formattedDate1+') OR ( Deal_Registration_status__c=\'New\' AND StageName!=\'Lost, Cancelled - 0%\' AND CreatedDate <='+dateRange+'))';
                               
        System.debug ('@@@@@@@@@@@@@@@' + batchObj.query);
        database.executebatch(batchObj,1);
    }
}
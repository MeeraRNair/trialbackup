/********************************************
Name   : VOVisitBundleTriggerTest
Description   : test class for VOVisitBundleTrigger trigger
Author   : Priyanka Challa, VisitOps

*********************************************/
@isTest
private class VOVisitBundleTriggerTest {
    
    private static testMethod void test() {
        TriggerExecutionController.setSkipAccountTriggers(true);
    	TriggerExecutionController.setSkipOpportunityTriggers(true);
    	TriggerExecutionController.setSkipUserTriggers(true);
        account acc= new account();
        acc.name='test';
        insert acc;
        
        account acc1= new account();
        acc1.name='test';
        insert acc1;
        
        opportunity opp= new opportunity();
        opp.name='test';
        opp.accountId=acc.id;
        opp.closedate=date.today();
        opp.StageName='Plan - 1%';
        opp.ForecastCategoryName='Omitted';
        opp.Forecast_Category_Override__c='Omitted';
        opp.Probability=0.01;
        opp.Amount=5;
        opp.VisitOps__MainCompetitors__c='test';
        insert opp;
        
        VisitOps__Location__c loc = new VisitOps__Location__c();
        loc.name='Banglore';
        loc.VisitOps__Time_Zone__c='(GMT+14:00) Line Islands Time (Pacific/Kiritimati)';
        insert loc;
        
        VisitOps__VisitType__c  vType= new VisitOps__VisitType__c   ();
        vType.name='Community Visit Type';
        vType.VisitOps__Category__c ='Community';
        insert vType;
        
        VisitOps__Status__c status= new VisitOps__Status__c();
        status.name='Submitted';
        insert status;
        
        visitops__visit__c visit= new visitops__visit__c();
        visit.VisitOps__VisitName__c='test';
        visit.VisitOps__VisitType__c=vType.id;
        visit.VisitOps__TotalNoOfAttendees__c=1;
        visit.VisitOps__Location__c=loc.id;
        visit.VisitOps__DepartureDateTimeLocationTZ__c= '2017-09-11 02:02:42';
        visit.VisitOps__ArrivalDateTimeLocationTZ__c= '2017-09-11 02:02:42';
        visit.VisitOps__ArrivalDateTime__c=datetime.now()+1;
        visit.VisitOps__DepartureDateTime__c=datetime.now()+2;
        visit.VisitOps__VisitOwner__c=userinfo.getUserId();
        visit.VisitOps__VisitStatus__c  =status.id;
        insert visit;
        
        visitops__company__c company= new visitops__company__c();
        company.VisitOps__Company_Name__c='test';
        company.visitops__visit__c=visit.id;
        company.Child_Parent_Company_Number__c='C00';
        company.VisitOps__Account__c = acc.id; 
        insert company;
        
        test.startTest();
        
        VisitOps__VisitBundle__c bundle= new VisitOps__VisitBundle__c();
        bundle.VisitOps__Opportunity__c=opp.id;
        bundle.VisitOps__Visit__c=visit.id;
        insert bundle;
        
        System.assertEquals(bundle.VisitOps__Opportunity__c,opp.id);
        
        acc.D_U_N_S__c = '1212';
        update acc;
        
        opp.Reason_Won_Lost__c = 'Incumbent';
        update opp;
            
        test.stopTest();
    }
}
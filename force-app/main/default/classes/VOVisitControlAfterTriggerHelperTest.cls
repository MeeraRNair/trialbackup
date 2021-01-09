@isTest
private class VOVisitControlAfterTriggerHelperTest {
    
    private static testMethod void test() {
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
        
        //Insert Visit
        visitops__visit__c visit= new visitops__visit__c();
        visit.VisitOps__VisitName__c='test';
        visit.VisitOps__VisitType__c=vType.id;
        visit.VisitOps__TotalNoOfAttendees__c=1;
        visit.VisitOps__Location__c=loc.id;
        visit.VisitOps__DepartureDateTimeLocationTZ__c= '2017-09-11 02:02:42';
        visit.VisitOps__ArrivalDateTimeLocationTZ__c= '2017-09-11 02:02:42';
        visit.VisitOps__ArrivalDateTime__c=datetime.newInstance(2017, 9, 15, 12, 30, 0);
        visit.VisitOps__DepartureDateTime__c=datetime.newInstance(2017, 9, 15, 13, 30, 0);
        visit.VisitOps__VisitOwner__c=userinfo.getUserId();
        visit.VisitOps__VisitStatus__c  =status.id;
        insert visit;
        
        Solution_Focus_Reporting_Category__c Solution= new Solution_Focus_Reporting_Category__c();
        Solution.Solution_Focus_Reporting_Category_Name__c='Cloud - Hybrid Cloud - MS';
        solution.Visit__c=visit.id;
        insert solution;
        
        test.startTest();
        
        VisitOps__Visit_Control__c vControl = new VisitOps__Visit_Control__c();
        vControl.VisitOps__Visit__c=visit.id;
        vControl.VisitOps__VisitControlVisit__c=visit.id;
        vControl.Solution_Focus_Reporting_Category__c='Cloud - Hybrid Cloud - MS';
        insert vControl;
        vControl.Solution_Focus_Reporting_Category__c='Cloud - Enterprise Hybrid Cloud';
        update vControl;
        
        test.stopTest();
    }    
}
@isTest
public class VOVisitBundleUpdateBatchTest {
    
    @testSetup
    private static void setupData()
    {
        TriggerExecutionController.setSkipAccountTriggers(true);
    	TriggerExecutionController.setSkipOpportunityTriggers(true);
    	TriggerExecutionController.setSkipUserTriggers(true);
        account acc= new account();
        acc.name='test';
        insert acc;
        
        opportunity opp= new opportunity();
        opp.name='test';
        opp.accountId=acc.id;
        opp.closedate=date.today() + 10;
        opp.StageName='Plan - 1%';
        opp.ForecastCategoryName='Omitted';
        opp.Forecast_Category_Override__c='Omitted';
        opp.Probability=0.01;
        opp.EMC_Opportunity_Number__c = 'OP-0001';
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
        TriggerExecutionController.setSkipAccountTriggers(false);
    	TriggerExecutionController.setSkipOpportunityTriggers(false);
    	TriggerExecutionController.setSkipUserTriggers(false);
        
        List<VisitOps__VisitBundle__c> listVBs = new List<VisitOps__VisitBundle__c>();
        
        VisitOps__VisitBundle__c bundle= new VisitOps__VisitBundle__c();
        bundle.VisitOps__Opportunity__c=opp.id;
        bundle.VisitOps__Visit__c=visit.id;
        listVBs.add(bundle);
        
        VisitOps__VisitBundle__c bundle1= new VisitOps__VisitBundle__c();
        bundle1.VisitOps__Opportunity__c=opp.id;
        bundle1.VisitOps__Visit__c=visit.id;
        listVBs.add(bundle1);
        
        insert listVBs;
    }
    
	private static testMethod void test() {
        test.startTest();
        
        List<VisitOps__VisitBundle__c> listVBs = new List<VisitOps__VisitBundle__c>();
        
        for(VisitOps__VisitBundle__c vbl : [Select Id From VisitOps__VisitBundle__c limit 50])
        {
            vbl.VisitOps__Opportunity__c = null;
            vbl.VO_Account_SFDC_ID__c = null;
            vbl.VisitOps__VB_OppSalesStage__c = 'Discover - 10%';
            listVBs.add(vbl);
        }
        update listVBs;
        
        //Run batch apex	
        Database.executeBatch(new VOVisitBundleUpdateBatch());
        test.stopTest();
        
        map<Id, Opportunity> mapOpps = new map<Id, Opportunity>([Select Id, AccountId, StageName From Opportunity]);
        
        for(VisitOps__VisitBundle__c vbl : [Select Id, VisitOps__Opportunity__c, VO_Account_SFDC_ID__c, VisitOps__VB_OppSalesStage__c From VisitOps__VisitBundle__c limit 100])
        {
            if(mapOpps.containsKey(vbl.VisitOps__Opportunity__c))
            {
                System.assert(mapOpps.get(vbl.VisitOps__Opportunity__c).AccountId == vbl.VO_Account_SFDC_ID__c);
                System.assert(mapOpps.get(vbl.VisitOps__Opportunity__c).StageName == vbl.VisitOps__VB_OppSalesStage__c);
            }
        }
    }
}
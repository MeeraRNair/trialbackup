/**
 * Test class for Opportunity change event Utility class,
 * 
 * @author: Rajiv Ranjan
 * @since: 09-12-2019
 * */
@isTest
public class OpportunityChangeUtilityTest {
    
    /**
     * Setup test data
     * 
     * @author: Rajiv Ranjan
     * @since: 09-12-2019
     * */
    @testSetup
    private static void setupData()
    {
        TriggerExecutionController.setSkipAccountTriggers(true);
    	TriggerExecutionController.setSkipOpportunityTriggers(true);
    	TriggerExecutionController.setSkipUserTriggers(true);
        account acc= new account();
        acc.name='test';
        insert acc;
		
		account acc1= new account();
        acc1.name='test1';
        insert acc1;
        
        opportunity opp= new opportunity();
        opp.name='test';
        opp.accountId=acc.id;
        opp.closedate=date.today() + 10;
        opp.StageName='Plan - 1%';
        opp.ForecastCategoryName='Omitted';
        opp.Forecast_Category_Override__c='Omitted';
        opp.Probability=0.01;
        opp.Amount=5;
        opp.VisitOps__MainCompetitors__c='test';
        opp.Competitor_Lost_To__c = 'Acando';
        opp.Primary_Competitor_Product_Type__c = 'Client';
        opp.Name = 'Changed Opp Name';
        opp.Primary_Competitor__c = 'Unknown';
        //oppty.Sales_Channel_Region_Name__c = 'Test Region';
        //oppty.Affinity_ID__c = '121';
        opp.EMC_Opportunity_Number__c = 'OP-0001';
        insert opp;
        update opp;
        
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
        bundle.VO_Opportunity_Deal_ID_Number__c = 'OP-0001';
        listVBs.add(bundle);
        
        VisitOps__VisitBundle__c bundle1= new VisitOps__VisitBundle__c();
        bundle1.VisitOps__Opportunity__c=opp.id;
        bundle1.VisitOps__Visit__c=visit.id;
        listVBs.add(bundle1);
        insert listVBs;
    }
    
    /**
     * Test method for Opportunity change event validation, to check if opportunity changes are correctly synced
     * 
     * @author: Rajiv Ranjan
     * @since: 09-12-2019
     * */
	private static testMethod void testVBChangeEvent() {
        TriggerExecutionController.setSkipAccountTriggers(true);
    	TriggerExecutionController.setSkipOpportunityTriggers(true);
    	TriggerExecutionController.setSkipUserTriggers(true);
        
        //Enable new feature behaviour
        insert new ToggleFeature__c(Name = 'VISIT_BUNDLE_SYNC_PLATFORM', Enable_Feature__c = true);
        
		List<Account> listAccs = [Select Id, Name From Account];
		List<VisitOps__VisitBundle__c> listVBs = new List<VisitOps__VisitBundle__c>();
        
        for(VisitOps__VisitBundle__c vbl : [Select Id From VisitOps__VisitBundle__c limit 50])
        {
            vbl.VisitOps__Opportunity__c = null;
            vbl.VO_Account_SFDC_ID__c = null;
			vbl.Corresponding_Opportunity_ID__c = null;
            listVBs.add(vbl);
        }
        update listVBs;
        
        //Enable test method to handle change events
        Test.enableChangeDataCapture();
        test.startTest();
        
        List<Opportunity> listOpps = new List<Opportunity>();
        
        for(Opportunity oppty : [Select Id From Opportunity limit 50])
        {
            oppty.StageName = 'Win - 100%';
            oppty.Competitor_Lost_To__c = 'Acando';
            oppty.Primary_Competitor_Product_Type__c = 'Client';
            oppty.Probability=1;
            oppty.ForecastCategoryName='Closed';
            oppty.Forecast_Category_Override__c = 'Closed';
            oppty.Name = 'Changed Opp Name';
            oppty.CloseDate = date.today() + 5;
            oppty.Primary_Competitor__c = 'Unknown';
            oppty.OwnerId = UserInfo.getUserId();
            //oppty.Sales_Channel_Region_Name__c = 'Test Region';
            oppty.AccountId = listAccs[1].Id;
            //oppty.Affinity_ID__c = '121';
            oppty.EMC_Opportunity_Number__c = 'OP-0001';
            listOpps.add(oppty);
        }
        update listOpps;
        
        test.stopTest();
        Test.getEventBus().deliver();
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
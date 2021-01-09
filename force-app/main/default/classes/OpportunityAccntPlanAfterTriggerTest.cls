/* 
Author: Raymond Yip

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     25-AUG-2011   	Raymond Yip     Created for CR6525.
2.0		30-JAN-2012		MenMee			CR6689 & CR6771
*/
public with sharing class OpportunityAccntPlanAfterTriggerTest {
	
	public static testmethod void testOpportunityAccntPlanAfterInsertYodate() {
		// Create account
	    Account testAccount = new Account(Name='Test Account OpportunityAccntPlanAfterTriggerTest');
	
	    insert testAccount;
		
		//Rev 2.0
		List<Profile> userProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];        
        User tempUser = new User(
            Username='testUser1'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test1@dell.com', 
            FirstName='Tfirst A', 
            LastName='TLast',
            ProfileId = userProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345',
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        insert tempUser;
        
		SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Plan OpportunityAccntPlanAfterTriggerTest', Account__c = testAccount.Id,
											Sales_Manager__c = tempUser.Id );	
		
		insert testAccntPlan;
		
		List<SFDC_Strategy__c> testStrategyList = new List<SFDC_Strategy__c>();
		
		for(integer i = 1; i <= 2; i ++) {
			
			SFDC_Strategy__c temp = new SFDC_Strategy__c(Name='Test Strategy - ' + i, SFDC_Acct_Plan__c = testAccntPlan.Id);
			testStrategyList.add(temp);
		}
		
		insert testStrategyList;
		
		
		List<Opportunity> testOpportunityList = new List<Opportunity>();
		

		Integer nextYear = System.Today().Year() + 1;
		Integer currentYear = System.Today().Year();

		
		Opportunity testOpptyOpenFirstHalf1 = new Opportunity(Name = 'Test testOpptyOpenFirstHalf1', 
																AccountId = testAccount.Id, 
																Probability = 10,
																Amount = 1000,
																related_strategy__c = testStrategyList[0].Id,
																StageName='Discover - 10%',
																//CloseDate = Date.newInstance(currentYear, 4, 4)); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
																CloseDate = Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
		testOpportunityList.add(testOpptyOpenFirstHalf1);
		
		
		Opportunity testOpptyOpenFirstHalf2 = new Opportunity(Name = 'Test testOpptyOpenFirstHalf2', 
																AccountId = testAccount.Id, 
																Probability = 10,
																Amount = 1000, 
																StageName='Discover - 10%',
																related_strategy__c = testStrategyList[0].Id,
																//CloseDate = Date.newInstance(currentYear, 5, 14)); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
																CloseDate = Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
		testOpportunityList.add(testOpptyOpenFirstHalf2);
		
		Opportunity testOpptyOpenSecondHalf1 = new Opportunity(Name = 'Test testOpptyOpenSecondHalf1', 
																AccountId = testAccount.Id, 
																Probability = 10,
																Amount = 1000, 
																StageName='Discover - 10%',
																related_strategy__c = testStrategyList[1].Id,
																//CloseDate = Date.newInstance(currentYear, 8, 14)); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
																CloseDate = Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
		testOpportunityList.add(testOpptyOpenSecondHalf1);
		
		Opportunity testOpptyOpenSecondHalf2 = new Opportunity(Name = 'Test testOpptyOpenSecondHalf2', 
																AccountId = testAccount.Id, 
																Probability = 10,
																Amount = 1000, 
																StageName='Discover - 10%',
																related_strategy__c = testStrategyList[0].Id,
																//CloseDate = Date.newInstance(currentYear, 10, 14)); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
																CloseDate = Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
		testOpportunityList.add(testOpptyOpenSecondHalf2);
	
	
		Opportunity testOpptyOpenNextFY1 = new Opportunity(Name = 'Test testOpptyOpenNextFY1', 
																AccountId = testAccount.Id, 
																Probability = 10,
																Amount = 1000, 
																StageName='Discover - 10%',
																related_strategy__c = testStrategyList[1].Id,
																//CloseDate = Date.newInstance(nextYear, 8, 14)); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
																CloseDate = Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
		testOpportunityList.add(testOpptyOpenNextFY1);
		
		Opportunity testOpptyOpenNextFY2 = new Opportunity(Name = 'Test testOpptyOpenNextFY2', 
																AccountId = testAccount.Id, 
																Probability = 10,
																Amount = 1000, 
																StageName='Discover - 10%',
																related_strategy__c = testStrategyList[1].Id,
																//CloseDate = Date.newInstance(nextYear, 10, 14)); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
																CloseDate = Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
		testOpportunityList.add(testOpptyOpenNextFY2);
		
		//close
		
		Opportunity testOpptyCloseFirstHalf1 = new Opportunity(Name = 'Test testOpptyCloseFirstHalf1', 
																AccountId = testAccount.Id, 
																Probability = 100,
																Amount = 1000, 
																StageName='Win - 100%',
																Primary_Competitor__c = 'Accenture',
																Competitor_Lost_To__c = 'CA',	//Rev 2.0
																related_strategy__c = testStrategyList[0].Id,
																CloseDate = Date.newInstance(currentYear, 4, 4));
		testOpportunityList.add(testOpptyCloseFirstHalf1);
		
		
		Opportunity testOpptyCloseFirstHalf2 = new Opportunity(Name = 'Test testOpptyCloseFirstHalf2', 
																AccountId = testAccount.Id, 
																Probability = 100,
																Amount = 1000,  
																StageName='Win - 100%',
																Primary_Competitor__c = 'Accenture',
																Competitor_Lost_To__c = 'CA',	//Rev 2.0
																related_strategy__c = testStrategyList[1].Id,
																CloseDate = Date.newInstance(currentYear, 5, 14));
		testOpportunityList.add(testOpptyCloseFirstHalf2);
		
		Opportunity testOpptyCloseSecondHalf1 = new Opportunity(Name = 'Test testOpptyCloseSecondHalf1', 
																AccountId = testAccount.Id, 
																Probability = 100,
																Amount = 1000,   
																StageName='Win - 100%',
																Primary_Competitor__c = 'Accenture',
																Competitor_Lost_To__c = 'CA',	//Rev 2.0
																related_strategy__c = testStrategyList[0].Id,
																CloseDate = Date.newInstance(currentYear, 8, 14));
		testOpportunityList.add(testOpptyCloseSecondHalf1);
		
		Opportunity testOpptyCloseSecondHalf2 = new Opportunity(Name = 'Test testOpptyCloseSecondHalf2', 
																AccountId = testAccount.Id, 
																Probability = 100,
																Amount = 1000,   
																StageName='Win - 100%',
																Competitor_Lost_To__c = 'CA',	//Rev 2.0
																related_strategy__c = testStrategyList[0].Id,
																CloseDate = Date.newInstance(currentYear, 10, 14));
		testOpportunityList.add(testOpptyCloseSecondHalf2);
	
			
		Opportunity testOpptyCloseNextFY1 = new Opportunity(Name = 'Test testOpptyCloseNextFY1', 
																AccountId = testAccount.Id, 
																Probability = 100, 
																Amount = 10,  
																StageName='Win - 100%',
																Competitor_Lost_To__c = 'Accenture',
																related_strategy__c = testStrategyList[0].Id,
																CloseDate = Date.newInstance(nextYear, 8, 14));
		testOpportunityList.add(testOpptyCloseNextFY1);
		
		Opportunity testOpptyCloseNextFY2 = new Opportunity(Name = 'Test testOpptyCloseNextFY2', 
																AccountId = testAccount.Id,  
																Probability = 100,
																Amount = 1000,  
																StageName='Win - 100%',
																Competitor_Lost_To__c = 'Accenture',
																related_strategy__c = testStrategyList[1].Id,
																CloseDate = Date.newInstance(nextYear, 10, 14));
		testOpportunityList.add(testOpptyCloseNextFY2);
		
		
		Opportunity testOpptyNotCounted1 = new Opportunity(Name = 'Test testOpptyNotCounted1', 
																AccountId = testAccount.Id,  
																Probability = 0,
																Amount = 1000,  
																StageName='Lost, Cancelled - 0%',
																Competitor_Lost_To__c='Barron McCann',
																related_strategy__c = testStrategyList[1].Id,
																CloseDate = Date.newInstance(currentYear, 10, 14));
		testOpportunityList.add(testOpptyNotCounted1);
		
		Opportunity testOpptyNotCounted2 = new Opportunity(Name = 'Test testOpptyNotCounted2', 
																AccountId = testAccount.Id,  
																Probability = 100,
																Amount = 0,  
																StageName='Win - 100%',
																Competitor_Lost_To__c = 'CA',	//Rev 2.0
																related_strategy__c = testStrategyList[1].Id,
																CloseDate = Date.newInstance(currentYear, 10, 14));
		testOpportunityList.add(testOpptyNotCounted2);
		
		Opportunity testOpptyNotCounted3 = new Opportunity(Name = 'Test testOpptyNotCounted3', 
																AccountId = testAccount.Id,  
																Probability = 100,
																Amount = 1000,   
																StageName='Win - 100%',
																Competitor_Lost_To__c = 'CA',	//Rev 2.0
																related_strategy__c = null,
																CloseDate = Date.newInstance(currentYear, 10, 14));
		testOpportunityList.add(testOpptyNotCounted3);
		
		Test.startTest();
		insert testOpportunityList;
		Test.stopTest(); 
		
		List<SFDC_Strategy__c> resultList = [SELECT Id,
													Closed_Opportunity_Value_1st_Half__c,
													Closed_Opportunity_Value_2nd_Half__c,
													Closed_Opportunity_Value_Next_Year__c,
													Open_Opportunity_Value_1st_Half__c,
													Open_Opportunity_Value_2nd_Half__c,
													Open_Opportunity_Value_Next_FY__c
												FROM SFDC_Strategy__c
												WHERE Id IN :testStrategyList];
		
		System.assertEquals(2, resultList.size());
		
		/*
		for(SFDC_Strategy__c s : resultList) { 
			if(s.Id == testStrategyList[0].Id) {
				system.debug('##################   ' +  s.Open_Opportunity_Value_1st_Half__c);
				system.assertEquals(2000, s.Open_Opportunity_Value_1st_Half__c);
				system.assertEquals(1000, s.Open_Opportunity_Value_2nd_Half__c);
				system.assertEquals(0, s.Open_Opportunity_Value_Next_FY__c);
				system.assertEquals(1000, s.Closed_Opportunity_Value_1st_Half__c);
				system.assertEquals(2000, s.Closed_Opportunity_Value_2nd_Half__c);
				//system.assertEquals(1000, s.Closed_Opportunity_Value_Next_Year__c);
			}
			
			if(s.Id == testStrategyList[1].Id) {
				
				system.assertEquals(0, s.Open_Opportunity_Value_1st_Half__c);
				system.assertEquals(1000, s.Open_Opportunity_Value_2nd_Half__c);
				system.assertEquals(2000, s.Open_Opportunity_Value_Next_FY__c);
				system.assertEquals(1000, s.Closed_Opportunity_Value_1st_Half__c);
				system.assertEquals(0, s.Closed_Opportunity_Value_2nd_Half__c);
				//system.assertEquals(1000, s.Closed_Opportunity_Value_Next_Year__c);
			}
		} */
		
	
	}
	
	

}
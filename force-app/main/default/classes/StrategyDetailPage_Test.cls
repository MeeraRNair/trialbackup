@isTest
public class StrategyDetailPage_Test {
    
    public Static testMethod void updateStrategy() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         User u = new User(Alias = 'testt', Email='standarduser@dell.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1234', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Badge_Number__c='127856789',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser9898@dell.com');
        insert u;
         Account acc = new Account(name = 'Test Account');
        insert acc;
        SFDC_Acct_Plan__c accPlan = new SFDC_Acct_Plan__c(Name='Test AccPlan',Account__c=acc.id,Virtustream__c='N',VMware__c='N',Storage_Strategy__c='N',Services__c='N',Pivotal__c='N',Networking_Strategy__c='N',Enterprise_Infrastructure__c='N',Boomi__c='N',Client_S_P__c='N',
        Compute_Servers__c='N',Client_Strategy__c='N',CS__c='N',ESG__c='N',RSA__c='N',SecureWorks__c='N',DPS__c='N',Account_Plan_Owner__c =u.Id);
        insert accPlan;
         System.runAs(u){
        Test.startTest();
        SFDC_Strategy__c strategy = new SFDC_Strategy__c(Name='Test Strategy',RecordTypeId='012A0000000GXk4IAG',When_do_you_plan_to_realize_Strategy__c='FY21 Q3',SFDC_Acct_Plan__c=accPlan.id,Strategy_Summary__c='Test',Potential_Strategy_Value__c=1234,Transformation__c='IT Transformation',
                                                         Strategy_Status__c='Created', Customer_Business_Challenges_Objectives__c='Test',Dell_s_Strategy_Response__c='Test',IT_Implications__c='Test',Which_LOB_will_you_offer__c='Boomi',
                                                         Strengths__c='Test',Threats__c='Test',Opportunities__c='Test',SWOT_Threats__c='Test',Strategy_Owner__c=u.Id);
        insert strategy;
       
		SFDC_Strategy__c strat = [SELECT Id FROM SFDC_Strategy__c WHERE Name='Test Strategy' Limit 1]; 
        system.debug('str'+strat.id);
        String retnValue=StrategyDetailPage.submitForReview(strat.Id,'Testing Update');
        
        System.assertEquals('Test Strategy',retnValue);
         Test.StopTest();
        }
    }

}
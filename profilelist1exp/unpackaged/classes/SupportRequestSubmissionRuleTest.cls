@isTest
class SupportRequestSubmissionRuleTest{
    static List<Support_Request_Submission_Rule__c> listSRRule;
    @testSetup static void setup() { 
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].name = 'test opportunity';
        listOppTdf[0].StageName = 'Qualification';
        listOppTdf[0].CloseDate = System.Today();
        insert listOppTdf;
        listSRRule = new List<Support_Request_Submission_Rule__c>();
        
        Support_Request_Submission_Rule__c sRRule1 = new Support_Request_Submission_Rule__c();
        SRRule1.name = 'Test SRRule';
        SRRule1.Resource_Type__c = 'Services Finance Support';
        SRRule1.Condition__c = '<';
        SRRule1.Unweighted_Rev_Services_Only__c = 30;
        SRRule1.Stage__c = 'Discover - 10%';
        listSRRule.add(sRRule1);
        
        Support_Request_Submission_Rule__c sRRule2 = new Support_Request_Submission_Rule__c();
        SRRule2.name = 'Test SRRule';
        SRRule2.Resource_Type__c = 'Services Proposal Support';
        SRRule2.Condition__c = '<';
        SRRule2.Unweighted_Rev_Services_Only__c = 30;
        SRRule2.Stage__c = 'Discover - 10%';
        listSRRule.add(sRRule2);
        
        Support_Request_Submission_Rule__c sRRule3 = new Support_Request_Submission_Rule__c();
        SRRule3.name = 'Test SRRule';
        SRRule3.Resource_Type__c = 'Services Legal Support';
        SRRule3.Condition__c = '<';
        SRRule3.Unweighted_Rev_Services_Only__c = 30;
        SRRule3.Stage__c = 'Discover - 10%';
        listSRRule.add(sRRule3);
        
        Support_Request_Submission_Rule__c sRRule4 = new Support_Request_Submission_Rule__c();
        SRRule4.name = 'Test SRRule';
        SRRule4.Resource_Type__c = 'Solution Architect';
        SRRule4.Condition__c = '<';
        SRRule4.Unweighted_Rev_Services_Only__c = 30;
        SRRule4.Stage__c = 'Discover - 10%';
        listSRRule.add(sRRule4);
        
        insert listSRRule;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //static Support_Request_Submission_Rule__c SRRule2;
    /* static void createTestData(){
SRRuleList = new List<Support_Request_Submission_Rule__c>();
op = new opportunity();
op.name = 'test opportunity';
op.StageName = 'Qualification';
op.CloseDate = System.Today();
insert op;

Support_Request_Submission_Rule__c SRRule1 = new Support_Request_Submission_Rule__c();
SRRule1.name = 'Test SRRule';
SRRule1.Resource_Type__c = 'Services Finance Support';
SRRule1.Condition__c = '<';
SRRule1.Unweighted_Rev_Services_Only__c = 30;
SRRule1.Stage__c = 'Discover - 10%';
SRRuleList.add(SRRule1);

Support_Request_Submission_Rule__c SRRule2 = new Support_Request_Submission_Rule__c();
SRRule2.name = 'Test SRRule';
SRRule2.Resource_Type__c = 'Services Proposal Support';
SRRule2.Condition__c = '<';
SRRule2.Unweighted_Rev_Services_Only__c = 30;
SRRule2.Stage__c = 'Discover - 10%';
SRRuleList.add(SRRule2);

Support_Request_Submission_Rule__c SRRule3 = new Support_Request_Submission_Rule__c();
SRRule3.name = 'Test SRRule';
SRRule3.Resource_Type__c = 'Services Legal Support';
SRRule3.Condition__c = '<';
SRRule3.Unweighted_Rev_Services_Only__c = 30;
SRRule3.Stage__c = 'Discover - 10%';
SRRuleList.add(SRRule3);

Support_Request_Submission_Rule__c SRRule4 = new Support_Request_Submission_Rule__c();
SRRule4.name = 'Test SRRule';
SRRule4.Resource_Type__c = 'Solution Architect';
SRRule4.Condition__c = '<';
SRRule4.Unweighted_Rev_Services_Only__c = 30;
SRRule4.Stage__c = 'Discover - 10%';
SRRuleList.add(SRRule4);

insert SRRuleList;
}
*/
    static testMethod void testSubmissionRule1(){
        // createTestData();
        list<Opportunity> listOpp=[select id from Opportunity limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        SupportRequestSubmissionRule srcls = new SupportRequestSubmissionRule();
        Id recordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
        srcls.initialize();              
        Support_Request__c sr = new Support_Request__c();
        sr.Opportunity__c = listOpp[0].id;
        sr.Services_Finance_Support__c = 'Yes';        
        sr.RecordTypeId = recordTypeId;       
        try{
            Test.Starttest();
            insert sr;
            Test.Stoptest();
        }catch(Exception e){}    
        
    }
    static testMethod void testSubmissionRule2(){
        //createTestData();
        list<Opportunity> listOpp=[select id from Opportunity limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        SupportRequestSubmissionRule srcls = new SupportRequestSubmissionRule();
        Id recordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
        srcls.initialize();              
        Support_Request__c sr = new Support_Request__c();
        sr.Opportunity__c = listOpp[0].id;
        sr.Services_Proposal_Support__c = 'Yes';        
        sr.RecordTypeId = recordTypeId;       
        try{
            Test.Starttest();
            insert sr;
            Test.Stoptest();
        }catch(Exception e){}    
        
    }
    static testMethod void testSubmissionRule3(){
        //createTestData();
        list<Opportunity> listOpp=[select id from Opportunity limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        SupportRequestSubmissionRule srcls = new SupportRequestSubmissionRule();
        Id recordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
        srcls.initialize();              
        Support_Request__c sr = new Support_Request__c();
        sr.Opportunity__c = listOpp[0].id;
        sr.Services_Legal_Support__c= 'Yes';        
        sr.RecordTypeId = recordTypeId;       
        try{
            Test.Starttest();
            insert sr;
            Test.Stoptest();
        }catch(Exception e){}    
        
    }
    static testMethod void testSubmissionRule4(){
        //createTestData();
        list<Opportunity> listOpp=[select id from Opportunity limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        SupportRequestSubmissionRule srcls = new SupportRequestSubmissionRule();
        Id recordTypeId =[Select Id,Name from RecordType where sObjectType ='Support_Request__c'and isActive=true and Name ='Request Custom Service Support' LIMIT 1].Id;
        srcls.initialize();              
        Support_Request__c sr = new Support_Request__c();
        sr.Opportunity__c = listOpp[0].id;
        sr.Solution_Architect__c= 'Yes';        
        sr.RecordTypeId = recordTypeId;       
        try{
            Test.Starttest();
            insert sr;
            Test.Stoptest();
        }catch(Exception e){}    
        
    }
}
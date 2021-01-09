/* 
Author: Devika Pujari
Description:  To update Original Requestor and Owner of an Idea Record
History:
Version     Date                Modified By         Description     
--------------------------------------------------------------------------------------
1st         Feb 2016            Sazleen             Commented owner updates and replace with Process builder
2.0         27 Oct 2016         Shahiruni           CR13636 - populate values for Days_to_Closure__c, Initial_Response_Days__c, On_Hold_Duration__c
*/

@Istest(seealldata=false)
Private Class beforeInsertIdeaIntakeTriggerTest{
    
    static Idea_Intake__c objIdea;


    private static testmethod void beforeInsertIdeaIntakeTrigger(){
    
        Id ideaRecordType = [Select Id From RecordType WHERE SobjectType = 'Idea_Intake__c' AND Name = 'Idea' LIMIT 1].Id;
        Id userSusan = [Select Id From User WHERE id='005A00000016mlp' LIMIT 1].Id;
        
        Idea_Intake__c IdeaIntk = new Idea_Intake__c();
        
        IdeaIntk.Name = 'Test';
        IdeaIntk.Regions_Impacted__c = 'ABU';
        IdeaIntk.Requesting_organization__c = 'IT';
        IdeaIntk.Requesting_region__c = 'ABU';
        IdeaIntk.Business_Challenge__c='Test';
        IdeaIntk.Business_Objective__c = 'Test';
        IdeaIntk.Business_Justification__c = 'Test';
        insert IdeaIntk ;
    }
    
    //2.0 starts
    private static testMethod void testInitialResponseDays() {
        createTestData();
        objIdea.Status__c = 'Approved';
        update objIdea;
    }
    
    private static testMethod void testDaysToClosure() {
        createTestData();
        objIdea.status__c = 'Resolved';
        update objIdea;
    }
    
    private static testMethod void testOnHold() {
        createTestData();
        objIdea.status__c = 'On Hold';
        update objIdea;
        objIdea.status__c = 'In Progress';
        update objIdea;
    }
    
    static void createTestData(){
        objIdea = new Idea_Intake__c(
        Name = 'Test',
        Status__c = 'New',
        Regions_Impacted__c = 'ABU',
        Requesting_organization__c = 'IT',
        Requesting_region__c = 'ABU',
        Business_Challenge__c='Test',
        Business_Objective__c = 'Test',
        Business_Justification__c = 'Test');
        insert objIdea;
    }
    //2.0 ends
}
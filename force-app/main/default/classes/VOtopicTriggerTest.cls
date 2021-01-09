/********************************************
Name   : VOtopicTriggerTest
Description   : test class for topic trigger
Author   : Priyanka Challa, VisitOps

*********************************************/
@isTest
private class VOtopicTriggerTest {
    
    private static testMethod void topicTriggerTest() {
        test.startTest();
        visitOps__topic__c topic= new visitOps__topic__c();
        topic.visitOps__TopicName__c    ='test';
        topic.visitOps__TopicCategory__c    ='Instructions';
        topic.Auto_Create_Expertise_Area__c=true;
        insert topic;
        
        system.assertEquals('test',topic.visitOps__TopicName__c);
        
        topic.visitOps__TopicName__c='sample';
        update topic;
        
        system.assertEquals('sample',topic.visitOps__TopicName__c);
        
        delete topic;
        test.stopTest();
    }
    
}
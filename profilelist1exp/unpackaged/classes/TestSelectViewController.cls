@isTest
private class TestSelectViewController { 

    static testMethod void TestSelectView() {
        SelectViewController controller = new SelectViewController();
        Profile p1 = [SELECT Id FROM profile WHERE name='Standard User'];
        User u1 = new User(alias = 'newUser', email='user1@dellteam.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',
                timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        System.runAs(u1){
            controller.decision();
        }
        Profile p2 = [SELECT Id FROM profile WHERE name='System Administrator'];
        User u2 = new User(alias = 'newUser', email='user2@dellteam.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p2.Id,Badge_Number__c='badge2',
                timezonesidkey='America/Los_Angeles', username='user2@dellteam.com');
        System.runAs(u2){
                controller.decision();
        }
    }
}
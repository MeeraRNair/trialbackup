@Istest(seealldata=false)
Private Class IdeaCRCreationControllerTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        listUserTdf[0].ProfileID=profileId;
        insert listUserTdf;
        list<Idea_Intake__c> listIdeaIntakeTdf=TestDataFactory.createNIdeaIntake(1,'Idea');
        insert listIdeaIntakeTdf;
    }
    private static testmethod void powerUserTestMethod1(){
        Id powerUserPS = [SELECT Id FROM PermissionSet WHERE Name = 'Idea_Power_User'].Id;
        /* Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
User powerUser = new User(LastName ='testLastName',Email='test@dell.com',UserName='test421@dell.com',EmailEncodingKey='ISO-8859-1',
Alias = 'testAl',TimeZoneSidKey= 'Asia/Kolkata',LocaleSidKey='en_US',ProfileId=profileId,LanguageLocaleKey='en_US');
insert powerUser;
*/
        User powerUser=[select id from user where profile.Name = 'System Administrator' and isActive=true Limit 1];
        PermissionSetAssignment powerUserAss = new PermissionSetAssignment();
        powerUserAss.AssigneeId = powerUser.Id;
        powerUserAss.PermissionSetId = powerUserPS;
        insert powerUserAss;
        system.assertNotEquals(powerUser.id, null);
        system.runAs(powerUser){
            /*Id ideaRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Idea' AND SobjectType = 'Idea_Intake__c'].Id;
Idea_Intake__c ideaIntakeRecord = new Idea_Intake__c (RecordTypeId = ideaRecordType,Regions_Impacted__c ='testRegion',Requesting_organization__c='testReqOrg',
Requesting_region__c  ='testReqReg',Business_Challenge__c = 'testBusCha',Business_Justification__c ='testBusJus',
Business_Objective__c ='testBusObj');
insert ideaIntakeRecord ;
*/
            Idea_Intake__c ideaIntakeRecord=[select id,Regions_Impacted__c from Idea_Intake__c where RecordType.name='Idea' Limit 1];
            PageReference testPage = page.ideacrcreationpage;
            testPage.getParameters().put('id',ideaIntakeRecord.id);        
            Test.setCurrentPage(testPage);
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());     
            IdeaCrcreationcontroller.ideaCrcreationmethod();    
            Test.StopTest();
        }
    }
    private static testmethod void powerUserTestMethod2(){
        
        Id powerUserPS = [SELECT Id FROM PermissionSet WHERE Name = 'Idea_Power_User'].Id;
        /* Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
User powerUser = new User(LastName ='testLastName',Email='test@dell.com',UserName='test513@dell.com',EmailEncodingKey='ISO-8859-1',
Alias = 'testAl',TimeZoneSidKey= 'Asia/Kolkata',LocaleSidKey='en_US',ProfileId=profileId,LanguageLocaleKey='en_US');
insert powerUser;
*/
        User powerUser=[select id from user where profile.Name = 'System Administrator' and isActive=true Limit 1];
        system.assertNotEquals(powerUser.id, null);
        PermissionSetAssignment powerUserAss = new PermissionSetAssignment();
        powerUserAss.AssigneeId = powerUser.Id;
        powerUserAss.PermissionSetId = powerUserPS;
        insert powerUserAss; 
        system.runAs(powerUser){
            
            /* Id ideaRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Idea' AND SobjectType = 'Idea_Intake__c'].Id;
Idea_Intake__c ideaIntakeRecord = new Idea_Intake__c (RecordTypeId = ideaRecordType,Regions_Impacted__c ='testRegion',Requesting_organization__c='testReqOrg',
Requesting_region__c  ='testReqReg',Business_Challenge__c = 'testBusCha',Business_Justification__c ='testBusJus',
Business_Objective__c ='testBusObj',PMO_CR__c ='1232' );
insert ideaIntakeRecord ;
*/
            Idea_Intake__c ideaIntakeRecord=[select id,Regions_Impacted__c from Idea_Intake__c where RecordType.name='Idea' Limit 1];
            PageReference testPage = page.ideacrcreationpage;
            testPage.getParameters().put('id',ideaIntakeRecord.id);      
            Test.setCurrentPage(testPage);
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());   
            IdeaCrcreationcontroller.ideaCrcreationmethod();    
            Test.StopTest();
        }
    }
}
@isTest
private class MarkasCompleted_SendEmailTest {

    @testSetup static void setup() {
       
        
         Account testAccount = new Account(Name='Test Account',Type = 'End User');
                                              
         insert testAccount;
        
         Contact testContact = new Contact(FirstName='first', LastName='last', Phone='123223667788',
                                                Email='test@test.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                                Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                                AccountId=testAccount.Id);
         insert testContact;
        
        Sponsoring_Distributor__c spDistr=new Sponsoring_Distributor__c();
        spDistr.Name='Test123';
        spDistr.Primary_Email__c='test@gmail.com';
        spDistr.Secondary_Email__c='test@gmail.com';
        
        insert spDistr;
        
        Group testGroup = new Group(Name = 'Queue', Type = 'Queue');
        insert testGroup;
        
        QueueSobject testQueue = new QueueSObject(QueueId = testGroup.Id,SobjectType = 'Partner_Request__c');
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert testQueue;
        } 
        Partner_Request__c preuqest=new Partner_Request__c();
        preuqest.OwnerId = testGroup.Id;
        preuqest.First_Name__c = 'John';
        preuqest.Last_Name__c = 'Doe';
        preuqest.Email__c = 'john.doe@acme.com';
        preuqest.Company__c = 'ACME Computers';
        preuqest.Status__c='In Review';
        preuqest.Sponsoring_Distributor__c='Test123';
        preuqest.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER, 'Partner_Request__c', true);
        insert preuqest;         
        
    } 
    
    @isTest static void testMethod1() {
       
        Partner_Request__c patnerRequest= [Select id,Sponsoring_Distributor__c From Partner_Request__c LIMIT 1];
        User u=[select id,name from User limit 1];
       // System.debug('@@@@Sponsoring_Distributor__c'+patnerRequest.Sponsoring_Distributor__c);
        ApexPages.currentPage().getParameters().put('Id',patnerRequest.id);
        MarkasComplete_SendEmail marSend=new MarkasComplete_SendEmail();
        marSend.doPageLoad();
       
    }

}
@isTest(seeAllData = False)
public class OrderSupportEmailNotifications_Test {
    
        static testmethod void createCase(){
          TriggerExecutionController.setSkipAccountTriggers(True);
          TriggerExecutionController.setSkipContactTriggers(True);
          TriggerExecutionController.setSkipUserTriggers(True);
        
          Account portalAccount = createAccount();
          Contact portalCont_1 = createContact(portalAccount.id,'test.user@gmail.com');
          User portalUser_1 = createUser(portalCont_1.id,'test.user@dell.com','test.user@gmail.com','test','user','nsid',String.valueOf(System.currentTimeMillis()),false);
          
              Case testCase;
              List<ID> caseId = new List<ID>();
          Test.startTest();
        
            System.runAs(portalUser_1){
                testCase = queueAlert(portalAccount.id,portalCont_1.id);
                caseId.add(testCase.Id);
                OrderSupportEmailNotifications.CaseCreatedNotification(caseId);
            }
            
        Test.stopTest();
          }
        Static Case queueAlert(Id accountId,Id contactId){
        
        Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
        Case c = new Case();
        c.AccountId = accountId;
        c.ContactId = contactid;
        c.RecordTypeId = orderSuppRTId;
        c.Status = 'Open';
        c.Priority = 'Low';
        c.Sub_Type_Order_Support__c = 'Credit Request';
        c.Order_Number1__c = '9876543';
        c.Subject = 'Test';
        c.Description = 'Case queue test';
        insert c;
    return c;
    }
    
    static Account createAccount(){
        
        Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        
        Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
                                           RecordTypeId = accRTyId,
                                           Partner_Type__c = 'COMMERCIAL',
                                           Partner_Tier__c = 'Tier',
                                           Partner_Relationship__c = 'Registered',
                                           Account_Country__c = 'Sweden');
                                           
       insert testAccount;
       return testAccount;
    }
    
    static Contact createContact(Id accountId,String email){
        Contact newCont = new Contact(FirstName = 'TestCon',
                                      LastName = 'TestCon',
                                      AccountId = accountId,
                                      Status__c = 'Marketing Suspect',
                                      Email = email,
                                      Fax = '555555',
                                      Last_Operation_Performed__c = 'test');
       insert newCont;
       return newCont;
    }
    
    static User createUser(Id contactId,String userName,String emailId,String firstName,String LastName,String alias,String badgeNum,Boolean isPortalAdmin){
    
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

        User partnerUserGC = new User(Username = userName,
        Alias = alias,
        Email = emailId,
        FirstName = firstName,
        LastName = lastName,
        ProfileId = p.Id,
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        Badge_Number__c = badgeNum,
        isActive = TRUE,
        ContactId = contactId,
        Enable_Partner_Admin__c = isPortalAdmin);
        
        insert partnerUserGC;
        return partnerUserGC;
    }
}
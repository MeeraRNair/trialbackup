@isTest
public Class NewCaseCommentsCtrlTest{
    public static testMethod void testNewCaseCommentsCtrl() {
        Id accountRecordTypeId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
                                            RecordTypeId = accountRecordTypeId,
                                            Partner_Type__c = 'COMMERCIAL',
                                            Partner_Tier__c = 'Tier',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'United States');
                                       
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'MyTestContact',
                                            LastName = 'MyTestContact',
                                            AccountId = testAccount.id,
                                            Status__c = 'Marketing Suspect',
                                            Email = 'test@test.com',
                                            Fax = '12344567',
                                            Last_Operation_Performed__c = 'testing');
        insert testContact;
        
        Id orderSupportRecordId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
        
        Case newCase = new Case(AccountId = testAccount.id,
                                    ContactId = testContact.id,
                                    Status = 'Open',
                                    Priority = 'High',
                                    Sub_Type_Order_Support__c = 'Box Recycling',
                                    RecordTypeId = orderSupportRecordId,
                                    Order_Number1__c = '123432',
                                    Alternate_Phone__c = '745476',
                                    Description = 'Test Description',
                                    Subject = 'Test Subject',
                                    Origin = 'Partner Portal',
                                    Case_Category__c = 'Partner');
        insert newCase;
        
        CaseComment testComment = new CaseComment(ParentId = newCase.Id, CommentBody = 'test');
        insert testComment;
        
        Test.startTest();
        NewCaseCommentsCtrl ctrl = new NewCaseCommentsCtrl();
        ctrl.caseId = newCase.id;
        CaseComment comment = ctrl.comment ;
        Case caseObj = ctrl.caseObj;
        Test.stopTest();
    }
}
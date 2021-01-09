@istest
Public Class DealReg_NotifyEMCSalesRepTest {
        static list<case> listCase;
    static list<user> listuser;
    @testSetup static void setup(){
        list<Case> listCaseTDF = TestDataFactory.createNCases(1);
        insert listCaseTDF;
        list<user> listuserTDF = TestDataFactory.CreateNGenralUsers(1);
        insert listuserTDF;
    }

    Static testMethod void notifyEMCSalesRepTest() {
        
    /*     Id emcRtId = StaticFactory.getRecordTypeIdByName('Case', 'EMC DR'); 
         Id sysProfileId = [Select Id FROM Profile WHERE Name = 'system Administrator'].Id; */
  /*      
         User u = New User(Alias = 'test1', 
                           Email='testEmail@dell.com', 
                           EmailEncodingKey='UTF-8',
                           LastName='Testing', 
                           LanguageLocaleKey='zh_CN', 
                           LocaleSidKey='zh_CN', 
                           ProfileId = sysProfileId,
                           Badge_Number__c = 'test0909', 
                           TimeZoneSidKey='America/Los_Angeles', 
                           Username = strUniqueName + '@test' + strOrgId + '.org'
                           );
         insert u;
        
         Case newCase = New case(Priority = 'High',
                              Status = 'Open',
                              RecordTypeId = emcRtId,
                              Subject ='Request for Deal Approval/Rejected',
                              Description = 'Approval Request has been sent to Enterprise Sales Team');
             TriggerExecutionController.setSkipAllTriggers(True);
             insert newCase;
             TriggerExecutionController.setSkipAllTriggers(false);
             
             newCase.Enterprise_Sales_Approver_1__c = 'testEmail1@test.com';
             newCase.Enterprise_Sales_Approver_2__c = 'testEmail2@test.com';
             newCase.Enterprise_Sales_Approver_3__c = 'testEmail3@test.com';
             newCase.Enterprise_Sales_Approver_7__c= 'testEmail4@test.com';
             newCase.Enterprise_Sales_Approver_4__c = u.id;
             newCase.Enterprise_Sales_Approver_5__c = u.id;
             newCase.Enterprise_Sales_Approver_6__c = u.id;
             newCase.Enterprise_Sales_Approver_8__c = u.id;
              System.assertEquals(newCase.Enterprise_Sales_Approver_1__c, 'testEmail1@test.com'); 
             update newCase;
*/
        listuser = [select id from user limit 1];
        listcase = [select id from case limit 2];
        listcase[0].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('EMC DR', 'Case');
        listcase[0].Description = 'Approval Request has been sent to Enterprise Sales Team';
        listcase[0].Enterprise_Sales_Approver_1__c = 'testEmail1@test.com';
        listcase[0].Enterprise_Sales_Approver_2__c = 'testEmail2@test.com';
        listcase[0].Enterprise_Sales_Approver_3__c = 'testEmail3@test.com';
        listcase[0].Enterprise_Sales_Approver_7__c= 'testEmail4@test.com';
        listcase[0].Enterprise_Sales_Approver_4__c = listuser[0].id;
        listcase[0].Enterprise_Sales_Approver_5__c = listuser[0].id;
        listcase[0].Enterprise_Sales_Approver_6__c = listuser[0].id;
        listcase[0].Enterprise_Sales_Approver_8__c = listuser[0].id;
        System.assertEquals(listcase[0].Enterprise_Sales_Approver_1__c, 'testEmail1@test.com'); 
		update listcase;
    }
    String strOrgId = UserInfo.getOrganizationId();
        String strDate = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer intRandom = Integer.valueOf(math.rint(math.random() * 1000000));
        String strUniqueName = strOrgId + strDate + intRandom;

}
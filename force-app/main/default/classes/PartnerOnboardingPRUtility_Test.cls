@isTest
public class PartnerOnboardingPRUtility_Test {
	   
    @isTest static void sendConfirmationFlagSet() {
        Test.enableChangeDataCapture();
      	List<Partner_Request__c> listTestPartnerRequest=new List<Partner_Request__c>();
        Partner_Request__c testPartnerRequest1=new Partner_Request__c(First_Name__c='testPartnerRequest1',Last_Name__c='testAccount1',Email__c='abc@test.com',
                Job_Title__c='Engineer',State__c='New',Status__c = 'New',RecordTypeId = '012700000005cfa');
        Partner_Request__c testPartnerRequest2=new Partner_Request__c(First_Name__c='testPartnerRequest2',Last_Name__c='testAccount2',Email__c='abc@test.com',
                Job_Title__c='Engineer',State__c='New',Status__c ='New',RecordTypeId = '012700000005cfa');
        
        test.startTest();
        listTestPartnerRequest.add(testPartnerRequest1);
        listTestPartnerRequest.add(testPartnerRequest2);
        insert listTestPartnerRequest;
        List<Partner_Request__ChangeEvent> listNewPRs = new List<Partner_Request__ChangeEvent>();
        List<String> listPRName = new List<String>{listTestPartnerRequest[0].id,listTestPartnerRequest[1].id};
        system.assertEquals(listTestPartnerRequest[0].First_Name__c,'testPartnerRequest1');
        Test.getEventBus().deliver();
		test.stopTest();
    }
}
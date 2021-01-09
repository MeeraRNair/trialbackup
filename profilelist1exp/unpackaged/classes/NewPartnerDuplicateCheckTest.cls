/* 
Author: Devika Pujari

History: Test Class for NewPartnerDuplicateCheck & PartnerRequestTrigger.
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
*/
@isTest(seealldata=false)
private class NewPartnerDuplicateCheckTest{

  static testMethod void createData() {
    
      Id NEW_PARTNER_REQUEST = [SELECT Id FROM RecordType WHERE SobjectType = 'Partner_Request__c' AND DeveloperName = 'New_Partner'].Id;
      List<Partner_Request__c> existingpartnerRequestRecords = new List<Partner_Request__c>();
      List<Partner_Request__c> newpartnerRequestRecords = new List<Partner_Request__c>();

      Country__c unitedStates = new Country__c();
      unitedStates.Name = 'UNITED STATES';
      unitedStates.Code__c = 'US';
      unitedStates.Region__c = 'NA';
      insert unitedStates;
      
      Account account = new Account();
      account.Name = 'testAccount';
      insert account;
      
      Contact contact = new Contact();
      contact.AccountId= account.Id;
      contact.lastname ='testLast';
      contact.Email  = 'test@test.com';
      contact.Phone ='124421';
      contact.MobilePhone ='124421';
      contact.Eloqua_ID__c ='124421';
      insert contact;
      
      Partner_Onboarding_Mailboxes__c mailbox = new Partner_Onboarding_Mailboxes__c();
      mailbox.Name = 'NA'; 
      mailbox.Mailbox__c = 'test@test.com';
      insert mailbox;
      
      for(integer i=0;i<10;i++){
        Partner_Request__c PRRecord = new Partner_Request__c();
        PRRecord.Company__c = 'testCompany'+i;
        PRRecord.Address_Line_1__c = 'AddressLine1'+i;
        PRRecord.Address_Line_2__c = 'AddressLine2'+i;
        PRRecord.Address_Line_3__c = 'AddressLine3'+i;
        PRRecord.City__c = 'City'+i;
        PRRecord.State__c ='State'+i;
        PRRecord.Country__c = unitedStates.Id;
        PRRecord.Postal_Code__c = '1242142';
        PRRecord.Reseller_Tax_ID__c ='12454354';
        PRRecord.Email__c = 'test@test.com';
        PRRecord.Website__c ='www.google'+i+'.com';
        PRRecord.RecordTypeId = NEW_PARTNER_REQUEST; 
        existingpartnerRequestRecords .add(PRRecord);
      }
      insert existingpartnerRequestRecords;
      
      for(integer i=0;i<200;i++){
        Partner_Request__c PRRecord = new Partner_Request__c();
        PRRecord.Company__c = 'testCompany'+i;
        PRRecord.Address_Line_1__c = 'AddressLine1'+i;
        PRRecord.Address_Line_2__c = 'AddressLine2'+i;
        PRRecord.Address_Line_3__c = 'AddressLine3'+i;
        PRRecord.City__c = 'City'+i;
        PRRecord.State__c ='State'+i;
        PRRecord.Country__c = unitedStates.Id;
        PRRecord.Postal_Code__c = '1242142';
        PRRecord.Reseller_Tax_ID__c ='12454354';
        PRRecord.Email__c = 'test@test.com';
        PRRecord.Website__c ='www.google'+i+'.com';
        PRRecord.RecordTypeId = NEW_PARTNER_REQUEST; 
        newpartnerRequestRecords.add(PRRecord);
      }
      Test.StartTest();
      insert newpartnerRequestRecords;
      Test.StopTest();
      
  }

}
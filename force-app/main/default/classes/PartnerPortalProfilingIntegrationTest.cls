/*---------------------------------------------
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0 -     16018      FY18-DCS-0102   12.06.2018:     Jatin           Commented NET exam logic statements as part of NET003 story
* 1.1 -     16001      FY18-DCS-0102   18-06-2018:     manip4          removed NET exam reference, story #5171130   
*/
@isTest(seealldata = true)
public class PartnerPortalProfilingIntegrationTest {

 private static testmethod void MethodOne() {
  Test.startTest();
  
  TriggerExecutionController.setSkipUserTriggers(true);
TriggerExecutionController.setSkipContactTriggers(true);
TriggerExecutionController.setSkipAccountTriggers(true);

    Country__c country = [select id,name,Code__c,User_Language_Locale_Key__c from Country__c limit 1];
  //creating PR data
  Partner_Request__c request = new Partner_Request__c();

  request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
   'Partner_Request__c', true);
  request.email__c = 'test@dell.com';
  request.Export_Compliance_Agreed__c = true;
  request.Partner_Terms_Conditions__c = true;
  request.Other_Customers__c = 'test1';
  request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
  request.Feature_Request_Deal_Registration__c = true;
  request.country__c = country .id;
  insert request;

  //Creating test data for partner account. IsPartner=true and recordtype = Partner Account
  Map < String, String > paraMap = new Map < String, String > {
   'str_RecordTypeId' => System.Label.RecType_Partner_Account
  };
  List < Account > validAccount = (List < Account > ) TestDataGenerator.getObject(new Account(), 1, paraMap);

  validAccount[0].isPartner = true;
  validAccount[0].Partner_Registration__c = request.id;
  validAccount[0].Account_Country_Code__c = 'AI';
  validAccount[0].Account_Country__c = 'ANGUILIA';
  validAccount[0].Account_ID__c = '12345';
  validAccount[0].States_Provinces_doing_business__c = 'Test';
  update validAccount;
  request.Account__c = validAccount[0].id;
  update request;

  System.debug('###DEBUG### validAccount = ' + validAccount);



  Contact testcontact = new Contact(FirstName = 'cmapmodifiedfirst',
   LastName = 'cmapmodified',
   Status__c = 'Active',
   AccountId = validAccount[0].Id,
   EMEA_Decision_Making_Role__c = 'End User',
   Decision_Making_Role__c = 'Business User',
   Job_Function_Role__c = 'CFO',
   Job_Function__c = 'IT',
   Purchaser_Influence_over_Merged__c = 'Other',
   Partner_My_Account_GUID__c = 'test-test-test',
   Phone = '11111111',
   Email = 'abc@abc1.com');


  insert testcontact;


  final List < Profile > partnerProfiles = [select id, name from Profile where Name LIKE '%PRM Portal%'
   limit 1
  ];
  //The user is tied to the first contact 
  User testUser = new User(
   Username = 'testuser126753324@dell.com',
   Alias = 'test1',
   Email = '1@test.com',
   FirstName = 'Test',
   LastName = 'User',
   ProfileId = partnerProfiles.get(0).Id,
   LanguageLocaleKey = 'en_US',
   LocaleSidKey = 'en_US',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = null,
   ContactId = testcontact.id,
   Enable_Partner_Admin__c = true);
  insert testUser;
  PartnerPortalProfilingserviceIntegration.integratePartnerDataWithContact(String.valueOf(testcontact.id));
  PartnerPortalProfilingserviceIntegration.sendAccountInfo(String.valueOf(validAccount[0].id), String.valueOf(testUser.id));
  PartnerPortalProfilingserviceIntegration.integratePartnerDataWithAccount(String.valueOf(validAccount[0].id));
 }


}
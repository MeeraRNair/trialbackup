@isTest
public class PartnerSalesTeamVFTest {
    
    static Opportunity OpptyA;
    public static testMethod void method1() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Map<Id, Opportunity> mapOldOpportunity = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapNewOpportunity = new Map<Id, Opportunity>();
        
        List<Profile> userProfile = [select id,name from profile where name like '%Portal%' order by name limit 2 ];   
        Id AccRt = IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Profile> partnerProfiles = [select Id, Name from Profile where name like '%Portal%' limit 1];
        Account testAcc = new Account(Name='Deal Registration Test Account',
                                      Account_Country__c = 'United States', 
                                      Partner_Type__c = 'Distributor (GCC)',
                                      Partner_Tier__c = 'Tier 1',
                                      Partner_Relationship__c = 'Authorized',
                                      RecordTypeId = AccRt,
                                      GTM_MOdel__c = 'Dell DIRECT FIELD'
                                     );  
        Test.startTest();
        insert testAcc;
        
        
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                                  MailingCountry='test',AccountId=testAcc.Id,Selected_Track_Account__c = testAcc.Id, Phone='12345',MobilePhone='999998665', Eloqua_ID__c='test123213');
        insert con; 
        User partnerUser = new User(Username='MyUsername' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='Email@dell.com', 
                                    FirstName='MyUserFirstName', 
                                    LastName='MyUserLastName',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='796011', 
                                    isActive = TRUE,
                                    ContactId = con.Id);
        insert partnerUser;
        // creating Account team members
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        AccountTeamMember accTM1 = new AccountTeamMember();
        accTM1.AccountId = testAcc.id;
        accTM1.UserId = partnerUser.Id;
        accTM1.TeamMemberRole = 'Account Executive';
        atmList.add(accTM1);
        insert atmList;
        
         system.runAs(partnerUser ){
        PartnerSalesTeamVF PVf =new PartnerSalesTeamVF();
        PartnerSalesTeamVF.AcountTeamWrapperCls pvfWrapper = new PartnerSalesTeamVF.AcountTeamWrapperCls();
        pvfWrapper.accTeamName  = 'test';
        pvfWrapper.accTeamEmail  = 'test';
        pvfWrapper.accTeamRole  = 'test';
        }
      

}
}
/**
* Version 1 : 21-MArch-2013 : Meera : Test class for CMAP_Helper
*             11-July-2018  : Naga  : Deleted method permissionsetInsertTest() as code cleanup process, after method deleted the code coverage is 100% for the respected main class
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
private class CMAP_HelperTest {
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Country__c> listCountryTdf=TestDataFactory.createNCountry(1);
        insert listCountryTdf;
        list<Sales_Channel_Group__c> listSaleChaTdf=TestDataFactory.createNSalesChannelGroups(1);
        insert listSaleChaTdf;
        
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        listAccTdf[0].Is_Rebate_Partner__c = true;
        listAccTdf[0].Sales_Channel__c=listSaleChaTdf[0].Id;
        listAccTdf[0].Account_Country_Code__c = listCountryTdf[0].Code__c;
        listAccTdf[0].Account_Country__c = listCountryTdf[0].Name;
        listAccTdf[0].Partner_Relationship__c='Registered';
        insert listAccTdf;
        
        list<Contact> listConTdf=TestDataFactory.createNContacts(1);
        listConTdf[0].Status__c='Active';
        listConTdf[0].AccountId=listAccTdf[0].Id;
        insert listConTdf;
        Profile prof = [select id from Profile where name like '%System Admin%' limit 1];
        Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
        
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(2);
        listUserTdf[0].profileId=profile.id;
        listUserTdf[0].ContactId = listConTdf[0].Id;
        listUserTdf[1].profileId=prof.id;
        insert listUserTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void permissionsetDeleteTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        //Create test data
        Test.startTest();
        
        /*  Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');




insert testCountry;
Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
insert testSalesChanGrp;              
Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
insert testAcc;
testAcc.IsPartner = true;
update testAcc;

Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
insert testContact; 

//Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
// Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 

User testUser = new User(Username='testvaliduser' +'@dell.com',
Alias = 'Test', 
Email='Test'+'@dell.com',            
LastName='Test', 
ProfileId = profile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test'+System.currentTimeMillis(),
ContactId = testContact.Id);
insert testUser;
Profile prof = [select id from Profile where name like '%System Admin%' limit 1];
User u = [Select id from User where profileid=:prof.id AND isactive = true  limit 1];
*/
        list<User> listUser=[select id from User where Profile.name like '%System Admin%' and isActive=true limit 1];
        list<User> listUser1=[select id from User where Profile.name like '%PRM Portal%' limit 1];
        
        System.runAs(listUser[0]){
            //Query and get active user and pass to function
            // Map<String,User> usermap = new Map<String,User>([Select id,isactive from User where isActive=true AND usertype = 'PowerPartner' limit 1]);
            CMAP_Helper.enable_DisableLeadAccess(new Set<String>{listUser1[0].id}, new Set<String>());       
            
            CMAP_Helper.enable_DisableLeadAccess(new Set<String>(),new Set<String>{listUser1[0].id});
            TriggerExecutionController.setSkipAllTriggers(true);
            
            Test.stopTest();
        }       
        List<PermissionSet> listpermSet = [SELECT Id FROM PermissionSet WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];
        List<PermissionSetAssignment> listAssignments2 = [SELECT AssigneeId,PermissionSetId from PermissionSetAssignment where PermissionSetId = :listpermSet[0].id AND 
                                                          AssigneeId=:listUser1[0].id];
        System.assert(listAssignments2.size()==0);                                          
    }
}
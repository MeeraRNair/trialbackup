/*
 * Author   : Ragu
 * Purpose  : Utility test class for creating User related data. 
 *
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      11555       16.07       	02-Jun-2015     Ragu            Created.
 * 1.1      16621       csm0203     	16-Feb-2016     Azwanti         Added Milisecond
 * 2.0		13002		FY17-DCS-0502	05-Apr-2016		Azwanti			added createSalesUsers method
 * 3.0		13156		FY17-DCS-0701	24-May-2016		Azwanti			added createCommonUsers method
 * 4.0                  FY17-DCS-0103	09-Jan-2017		Azwanti         change from Math.round(Math.random()*1000) to Math.round(Math.random()*1000000000), to fix duplicate Badge_Number__c
 */

@isTest
public class UserTestData {

    public static boolean bCreate = true;
    public static integer iNumberOfUsers = 5;
    public static list<User> lstUsers;
    
    public static testMethod void createPartnerUsers() {
        ContactTestData.iNumberOfContacts = iNumberOfUsers;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        
        list<Profile> partnerProfile = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' limit 1];

        populateCommonUserFields();
        for(Integer iterator=0; iterator<iNumberOfUsers; iterator++) {
            User userIterator = lstUsers[iterator];
            userIterator.ContactId = lstContacts[iterator].Id; 
            userIterator.ProfileId = partnerProfile[0].Id;
            
            /*
            userIterator.Enable_Partner_Lead_Management__c = true;
            userIterator.Enable_Partner_Deal_Registration__c = true;
            userIterator.Enable_As_Partner_Lead_Super_User__c = true;
            */
        }
        if(bCreate) {
            insert lstUsers;
        }
    }
    
    public static testMethod void createInternalUsers() {
        populateCommonUserFields();
        Profile sysAdminProfile = [select Id from Profile where Name = 'System Administrator' limit 1];
        
        for(User userIterator : lstUsers) {
            userIterator.ProfileId = sysAdminProfile.Id;
        }
        if(bCreate) {
            insert lstUsers;
        }
    }
    
    //v2.0
    public static testMethod void createSalesUsers() {    
        Profile salesProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name LIKE '%Sales%' limit 1];

        populateCommonUserFields();
        for(User userIterator : lstUsers) {
            userIterator.ProfileId = salesProfile.Id;
        }
        if(bCreate) {
            insert lstUsers;
        }
    }
    //v2.0 end    
    
    //v2.0
    public static testMethod void createCommonUsers() {    
        Profile salesProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' limit 1];

        populateCommonUserFields();
        for(User userIterator : lstUsers) {
            userIterator.ProfileId = salesProfile.Id;
        }
        if(bCreate) {
            insert lstUsers;
        }
    }
    //v2.0 end 
    
    private static testMethod void populateCommonUserFields() {
        lstUsers = new list<User>();
        for(integer i=0; i<iNumberOfUsers; i++) {
            User userIterator = new User();
            userIterator.Username = 'MyTestUser' + i + System.currentTimeMillis() + '@dell.com';
            String strRight = String.valueOf(System.currentTimeMillis());
            userIterator.Alias = 'U' + i + strRight.right(4);
            userIterator.Email = 'MyTestUser' + i +'@dell.com';
            userIterator.FirstName = 'My Test';
            userIterator.LastName = 'User ' + i;
            userIterator.LanguageLocaleKey = 'en_US';
            userIterator.LocaleSidKey = 'en_US';
            userIterator.EmailEncodingKey = 'UTF-8';
            userIterator.TimeZoneSidKey = 'America/Los_Angeles';
            userIterator.Badge_Number__c = String.valueOf(Math.round(Math.random()*1000000000)) + '00' + i + system.now().millisecond(); //v1.1 v4.0
            userIterator.IsActive = true;

            lstUsers.add(userIterator);
        }
    }

}
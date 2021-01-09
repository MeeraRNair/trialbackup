@IsTest
public class UserTriggerHandlerAITest {
public static boolean bCreate = true;
    public static integer iNumberOfUsers = 5;
    public static list<User> lstUsers;
    
    public static testMethod void createPartnerUsers() {
       Account acc = new Account();
      acc.Name = 'testAccount';
      acc.NPS_Qualified_Contacts__c = 1;
      insert acc;
     
        List<Contact> listCon = new List<Contact>();
        for(Integer iterator=0; iterator<iNumberOfUsers; iterator++) {
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.Email = 'test@test.com';
            con.phone = '6739';
            con.LastName = 'conLastName';
            con.FirstName = 'conFirstName';
            con.Status__c = 'Customer';
            con.Email_Opt_In__c = 'yes';
            con.Survey__c = 'yes';
            con.Decision_Making_Role__c = 'Technical Buyer';
            //con.NPS_Criteria_Met__c = True; //v2.0
            listCon.add(con);
        }
        insert listCon;
        
        list<Profile> partnerProfile = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' limit 1];

        populateCommonUserFields();
        for(Integer iterator=0; iterator<iNumberOfUsers; iterator++) {
            User userIterator = lstUsers[iterator];
            userIterator.ContactId = listCon[iterator].Id; 
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
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "User", "Class_Name__c": "UserTriggerHandlerAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'User';
        tec.RecursiveCount__c = 2;
        insert tec;
        
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
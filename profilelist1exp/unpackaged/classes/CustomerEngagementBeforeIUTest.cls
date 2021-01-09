@isTest

private class CustomerEngagementBeforeIUTest {
    //Test method for EBC Customer Engagement
    static testMethod void testCEBeforeIUForEBC() {
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Executive Briefing Center'];
        Account primaryAccount = new Account(Name = 'Test Account');
        insert primaryAccount;    
        Contact primaryContact = new Contact(FirstName = 'ContactExcSafeWord1', LastName = 'ContactExcSafeWord1', 
                                 AccountId = primaryAccount.Id, Phone = '999994567812', 
                                 Decision_Making_Role__c = 'Influencer', Job_Function__c = 'IT',
                                 Purchaser_Influence_over_Merged__c = 'Client-Desktops' );
        insert primaryContact;
        Profile profile = [select id from profile where name = 'System Administrator' order by name limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;        
        System.runAs(testUser){
            Group grpObj = [SELECT Name FROM Group WHERE Name='Executive Briefing Scheduling Queue'];
            Id recTypeSite = IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
            Event_Location__c testSite = new Event_Location__c(Name='Test Site',Region__c = 'Americas',
                                                               Engagement_Type__c='EBC', Event__c='Briefing',
                                                               Email__c='s@s.com',Offer_Transportation__c='No', Offer_Catering__c='No',
                                                               RecordTypeId = recTypeSite, Active__c=true);
            insert testSite;
            Customer_Engagement__c testCustEngObj = new Customer_Engagement__c(Name = 'Mytest CE',
                                                    Requestor_Name__c = testUser.Id, 
                                                    Estimated_no_of_Customer_Attendees__c = 11,
                                                    Primary_Account__c = primaryAccount.Id,
                                                    Primary_Contact__c = primaryContact.Id,
                                                    NDA__c = 'Yes',
                                                    Event_Status__c = 'Pending',
                                                    Submitted_Date__c = System.today(),
                                                    Site_Email__c = testSite.Email__c,
                                                    OwnerId = grpObj.Id,
                                                    RecordTypeId = recordType.Id);
            insert testCustEngObj;
            system.assertEquals(testCustEngObj.OwnerId, grpObj.Id);
        }
    }
    
    //Test method for DSC Customer Engagement
    static testMethod void testCEBeforeIUForDSC() {
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Executive Briefing Center'];
        Account primaryAccount = new Account(Name = 'Test Account');
        insert primaryAccount;    
        Contact primaryContact = new Contact(FirstName = 'ContactExcSafeWord1', LastName = 'ContactExcSafeWord1', 
                                 AccountId = primaryAccount.Id, Phone = '999994567812', 
                                 Decision_Making_Role__c = 'Influencer', Job_Function__c = 'IT',
                                 Purchaser_Influence_over_Merged__c = 'Client-Desktops' );
        insert primaryContact;
        Profile profile = [select id from profile where name = 'System Administrator' order by name limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;         
        System.runAs(testUser){
            Id recTypeSite = IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
            Event_Location__c testSite = new Event_Location__c(Name='Test Site',Region__c = 'Americas',
                                                               Engagement_Type__c='EBC', Event__c='Briefing',
                                                               Email__c='s@s.com',Offer_Transportation__c='No', Offer_Catering__c='No',
                                                               RecordTypeId = recTypeSite, Active__c=true);
            insert testSite;
            Customer_Engagement__c testCustEngObj = new Customer_Engagement__c(Name = 'Mytest CE',
                                                    Requestor_Name__c = testUser.Id, 
                                                    Estimated_no_of_Customer_Attendees__c = 11,
                                                    Primary_Account__c = primaryAccount.Id,
                                                    Primary_Contact__c = primaryContact.Id,
                                                    NDA__c = 'Yes',
                                                    Event_Status__c = 'Pending',
                                                    Submitted_Date__c = System.today(),
                                                    Site_Email__c = testSite.Email__c,
                                                    RecordTypeId = recordType.Id);
            insert testCustEngObj;
            testCustEngObj.CE_Email_Recipient__c = testUser.Email;
            system.assertEquals(testCustEngObj.CE_Email_Recipient__c, testUser.Email);
        }
    }
}
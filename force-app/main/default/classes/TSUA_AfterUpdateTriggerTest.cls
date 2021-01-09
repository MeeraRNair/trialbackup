/***********************************************************
* Name          : TSUA_AfterUpdateTriggerTest
* Description   : Relationship Lead / Account Play Re-Calculation Test Class
* ---------------------------------------------------------
* Revision  Name    Date                  Release Description
* 1.0       Impana  July 10 2014          Test class for TerritorySalesUserAssignmentAfterUpdateTrigger
* **********************************************************/

@istest
Private class TSUA_AfterUpdateTriggerTest{
    static Account testAcc;
    static Campaign testCampaign;
    static Campaign testCampaign2;
    static Campaign testCampaign1;
    static AccountTeamMember testISR;
    static AccountTeamMember testISM;
    static AccountTeamMember testAE;
    static List<User> testUserList = new List<User>();
    static List<CampaignMember> testCMList = new List<CampaignMember>();
    static List<Contact> testContactList = new List<Contact>();
    static Role__c CCCrole;
    static Geography__c CCCgeo;
    static Territory__c CCCterritory;
    static Territory_Geo_Assignment__c testTGA;
    static Territory_Sales_User_Assignment__c testTSUA;
    static Relationship_Lead__c GeoRL;



    //Geo Assignment re-calculation for RL
    Static testmethod void ReCalculation_RL(){
        TestDataCreation(false);
        
        testAcc.Account_Country__c = 'CCCGeo';
        update testAcc;
        
        GeoRL = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign1.Id,
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');     
      
        test.starttest();
        insert GeoRL;  
        testTSUA.User__c = testUserList[1].Id;
        update testTSUA;
        test.stoptest();
       
        Relationship_Lead__c RLtest = [SELECT Relationship_Lead_Owner__c, Inside_Sales_Rep__c, Account_Executive__c,
                                            System_Auto_Populated_RL_Owner__c, System_Auto_Populated_ISR__c, System_Auto_Populated_AE__c,
                                            Geo_populated__c
                                            FROM Relationship_Lead__c where ID =: GeoRL.Id LIMIT 1];
        
        System.assertequals(RLtest.Relationship_Lead_Owner__c , testTSUA.User__c);
        System.assertequals(RLtest.Geo_populated__c , true);
        System.assertEquals(true, RLtest.System_Auto_Populated_RL_Owner__c);
    
    }
    
     // Test : Geo process assignment - Account Play
    static testmethod void ReCalculation_AP() {
        
        TestDataCreation(false);
        testAcc.Account_Country__c = 'CCCGeo';
        update testAcc;
     
        Account_Play__c testAccountPlayGeo = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign2.Id );
        
        Test.starttest();
        insert testAccountPlayGeo;
        testTSUA.User__c = testUserList[1].Id;
        update testTSUA;
        test.Stoptest();
        
        Account_Play__c APtest = [SELECT Account_Play_Owner__c, Inside_Sales_Rep__c, Account_Executive__c,
                                  System_Auto_Populated_AP_Owner__c, System_Auto_Populated_ISR__c, System_Auto_Populated_AE__c,Geo_populated__c
                                  FROM Account_Play__c where ID =: testAccountPlayGeo.Id LIMIT 1];
                                            
        System.assertequals(testTSUA.User__c , APtest.Account_Play_Owner__c);
        System.assertequals(APtest.Geo_populated__c , true);
        System.assertEquals(true, APtest.System_Auto_Populated_AP_Owner__c);
    
    
    }
    
   
    static void TestDataCreation(boolean isAccountCampaign) {
                        
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
                                
        for (integer i = 0; i < 3; i++) {
            User testUser = new User(Username='Test'+i+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test'+i, 
                                        Email='Test'+i+'@dell.com',            
                                        LastName='Test'+i, 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+i+System.currentTimeMillis());
            testUserList.add(testUser);
        }
        insert testUserList;
        
        testAcc = new Account(name = 'testAccount'+System.currentTimeMillis()); 
        insert testAcc;     

        testISR = new AccountTeamMember (AccountId = testAcc.Id, UserId = testUserList[0].Id, TeamMemberRole = 'Inside Sales Rep');
        insert testISR;
        
        testAE = new AccountTeamMember (AccountId = testAcc.Id, UserId = testUserList[1].Id, TeamMemberRole = 'Account Executive');
        insert testAE;

        testContactList.clear();
        for (integer i = 0; i < 3; i++) {
            
            Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+i);
            testContactList.add(testContact);
        }                                            
        insert testContactList;
                
        if (isAccountCampaign) {  
            testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                        IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                        Name='Test Campaign', Follow_Up_Role__c = 'Inside Sales Rep',
                                                        Is_this_Account_Play_Campaign__c = True, Account_Play_Expiry_Date__c = System.today() + 60);
             insert testCampaign;
        }
        else {
            testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign', Follow_Up_Role__c = 'Inside Sales Rep',
                                                    Next_Steps__c = 'Next Steps', Supporting_Information__c = 'Supporting Info'); //Rev 4.0
            
            insert testCampaign;
            
            testcampaign1 = new Campaign(Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign', Follow_Up_Role__c = 'CCCrole');
            insert testCampaign1;
            
            testcampaign2 = new Campaign(Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign2', Follow_Up_Role__c = 'CCCrole',Is_this_Account_Play_Campaign__c = true, 
                                                    Account_Play_Expiry_Date__c=System.today()+20);
            insert testCampaign2;
            
                       
            RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = true;
            testCMList.clear();   
            for (integer i = 0; i < 3; i++) {
                CampaignMember testCampaignMember = new CampaignMember(CampaignId = testCampaign.Id, Campaign_Vehicle__c = 'eSeminar/Webcast/Webinar',
                                                            ContactId = testContactList[i].Id, CM_Status__c = 'Requires Follow-Up');
                testCMList.add(testCampaignMember);
            }                   
            insert testCMList;
            RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = false;                  
        }              
        //testUserList.clear();  
        
        RecordType CountryRT = [select ID from RecordType where name =: 'Country' LIMIT 1];
        
        CCCterritory = new territory__c(name='CCCterritory' , group__c='Cloud Client Computing' , Geography_type__c = 'Country',Is_active__c =true);
        Insert CCCterritory;
        
        CCCgeo = new Geography__c(name='CCCgeo', RecordTypeId = CountryRT.Id);
        insert CCCgeo;
        
        CCCrole = new Role__c(name='CCCrole', group__c = 'Cloud client Computing', Is_active__c =true);
        insert CCCrole;
        
        testTGA = new Territory_Geo_Assignment__c(Territory__c = CCCterritory.Id , Geography__c = CCCgeo.Id);
        insert testTGA;
        
        testTSUA = new Territory_Sales_User_Assignment__c(Territory__c = CCCterritory.Id,Group__c='Cloud Client Computing' ,
                   Role__c = CCCrole.Id, User__c = testUserList[0].Id, Is_Active__c = true);
        insert testTSUA;
    }
}
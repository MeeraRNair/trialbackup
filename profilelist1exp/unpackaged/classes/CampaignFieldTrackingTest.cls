@isTest
public class CampaignFieldTrackingTest{

    static testMethod void UpdCampTracking_TestMethod(){
        //User testuser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
                //Insert records to custom settings object
        List<Campaign_Field_Tracking__c> customSetting = new list<Campaign_Field_Tracking__c>();
        Campaign_Field_Tracking__c cs1 = new Campaign_Field_Tracking__c(Name='IsActive', Type__c = 'Boolean');
        customSetting.add(cs1);
        
        Campaign_Field_Tracking__c cs2 = new Campaign_Field_Tracking__c(Name='Follow_Up_Role__c', Type__c = 'Picklist');
        customSetting.add(cs2);
        
        Campaign_Field_Tracking__c cs3 = new Campaign_Field_Tracking__c(Name='Name', Type__c = 'Text');
        customSetting.add(cs3);
        
        Campaign_Field_Tracking__c cs4 = new Campaign_Field_Tracking__c(Name='ParentId', Type__c = 'Lookup',ReferenceName__c = 'Campaign' );
        customSetting.add(cs4);

        insert customSetting; 
        
        // Create Change Campaign
        List<Campaign> lst_Camp = new List<Campaign> ();
        
        Campaign ParentCamp1 = new Campaign (Name = 'Parent Camp1',
                                            Campaign_Objective__c = 'Action',
                                            Type = 'DM',
                                            Segment_Business_Unit__c = 'PUB',
                                            Follow_Up_Role__c = 'Account Executive',
                                            StartDate=System.Today() - 10,
                                            EndDate = System.Today(),
                                            Description = 'This is Test Campaign',                                            
                                            Account_Play_Expiry_Date__c=System.today() + 60,
                                            IsActive=true);
        lst_Camp.add(ParentCamp1);                                    

        Campaign ParentCamp2 = new Campaign (Name = 'Parent Camp2',
                                            Campaign_Objective__c = 'Action',
                                            Type = 'DM',
                                            Segment_Business_Unit__c = 'PUB',
                                            Follow_Up_Role__c = 'Account Executive',
                                            StartDate=System.Today() - 10,
                                            EndDate = System.Today(),
                                            Description = 'This is Test Campaign',                                            
                                            Account_Play_Expiry_Date__c=System.today() + 60,
                                            IsActive=true);
        lst_Camp.add(ParentCamp2);  
        insert lst_camp;
        

        
        Test.startTest();
        Campaign testCampaign = new Campaign(Name='Test Campaign',
                                    Campaign_Objective__c = 'Action',
                                    Type = 'DM',
                                    Segment_Business_Unit__c = 'PUB',
                                    Follow_Up_Role__c = 'Account Executive',
                                    StartDate=System.Today() - 10,
                                    EndDate = System.Today(),
                                    Description = 'This is Test Campaign',                                            
                                    Account_Play_Expiry_Date__c=System.today() + 60,
                                    IsActive=true);

        insert testCampaign;

        testCampaign.ParentId = lst_camp[0].Id;
        update testCampaign;

        testCampaign.Name = 'Test Campaign2';
        testCampaign.isActive = false;
        testCampaign.Follow_Up_Role__c = 'Account Owner';
        testCampaign.ParentID = lst_camp[1].Id;
        update testCampaign;
        
        Test.stopTest();

    }
}
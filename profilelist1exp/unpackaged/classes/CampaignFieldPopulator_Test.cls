/*
* Author   : Ragu
* Purpose  : Test class for CampaignFieldPopulator. 
*
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      11480        16.07       18-May-2015     Ragu            Created.
* 
*/
@isTest(SeeAllData=false)
private class CampaignFieldPopulator_Test { 
    public static list<Campaign> listcamp;
    
    @testsetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Campaign> listcampTDF = TestDataFactory.createNCampaign(3, 'Campaign 2.0');
        insert listcampTDF;
    }
    
    static testMethod void testSendNotificationPopulation() {
        listcamp = [Select Id from Campaign limit 3];
        //CampaignTestData.iNumberOfCampaigns = 3;
        //CampaignTestData.createStandardCampaign();
        //list<Campaign> lstCampaigns = CampaignTestData.listCampaigns;
        
        for(Campaign campaignIterator : listcamp) {
            campaignIterator.Account_Play_Expiry_Date__c = System.today() + 90;
        }
        update listcamp;
        System.assertequals(System.today() + 90,listcamp[0].Account_Play_Expiry_Date__c);
    }
    
    static testMethod void testCampaignOwnerPopulation() {
        listcamp = [Select Id,Follow_Up_Role__c from Campaign limit 3];
        //CampaignTestData.iNumberOfCampaigns = 3;
        //CampaignTestData.createCampaign2();
        //list<Campaign> lstCampaigns = CampaignTestData.listCampaigns;
        
        User newOwner = [Select Id, Name From User Where IsActive = true and Profile.UserLicense.Name = 'Salesforce' and Id != :UserInfo.getUserId() limit 1];
        for(Campaign campaignIterator : listcamp) {
            campaignIterator.OwnerId = newOwner.Id;
        }
        update listcamp;
        System.assertequals(newOwner.Id,listcamp[0].OwnerId);
    }
    
    static testMethod void testSendMascotUpdateFlagPopulation() {
        listcamp = [Select Id from Campaign limit 3];
        //CampaignTestData.iNumberOfCampaigns = 3;
        //CampaignTestData.createStandardCampaign();
        //list<Campaign> lstCampaigns = CampaignTestData.listCampaigns;
        
        for(Campaign campaignIterator : listcamp) {
            campaignIterator.Follow_Up_Role__c = 'Account Owner';
        }
        update listcamp;
        System.assertequals('Account Owner',listcamp[0].Follow_Up_Role__c);
    }
    
    static testMethod void testCampaignMemberRecordTypeIdPopulation() {
        listcamp = [Select Id,Follow_Up_Role__c from Campaign limit 3];  
        //CampaignTestData.iNumberOfCampaigns = 1;
        //CampaignTestData.createCampaign2();
        System.assertNotequals('Account Owner',listcamp[0].Follow_Up_Role__c);
    }
    
}
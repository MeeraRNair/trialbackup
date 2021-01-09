/***********************************************************
* Name          : VFCntrlr_RelationshipLeadAccPlayEditTest
* Description   : Test class for VFCntrlr_RelationshipLeadAccPlayEditTest
* ---------------------------------------------------------
* Revision  Name        Date        Description
* 1.0       MenMee      28.09.2009  Test class for VFCntrlr_RelationshipLeadAccPlayEditTest
* 1.1       MenMee      11.11.2009  DF53194 Update test method accordingly
*                                   Only allow to create RL for CM with Status='Requires follow-up'
* 1.2       MenMee      29.12.2009  Campaign is mandatory for a RL
*                                   CR 2279 Set disableRLAutoCreation = true to skip creating new RL when new CM get inserted
************************************************************/

@isTest
private class VFCntrlr_RelationshipLeadAccPlayEditTest{

    static boolean isDataCreated = false;
    static Relationship_Lead__c testRelationshipLead;
    
    // Test condition:
    // Click on particular record and go to the detail page
    static testMethod void navigateToDetail_goToDetailPage() {
        System.debug('***************** START navigateToDetail_goToDetailPage *****************');
        
        if (!isDataCreated) testDataCreation();
        
        PageReference pageRef = Page.RelationshipLeadEditOverridePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testRelationshipLead.Id);
        
        Test.startTest();
        
        ApexPages.Standardcontroller stdCon = new ApexPages.Standardcontroller(testRelationshipLead);
        VFCntrlr_RelationshipLeadAccPlayEdit controller = new VFCntrlr_RelationshipLeadAccPlayEdit(stdCon);       
        String actualURL = controller.navigateToDetail().getUrl();
        
        Test.stopTest();
        
        System.assertEquals('/' + testRelationshipLead.Id, actualURL);
        
        System.debug('***************** END navigateToDetail_goToDetailPage *****************'); 
    }
    
    // Test condition:
    // Click back to return to list view
    static testMethod void navigateToList_goBackToListView() {
        System.debug('***************** START navigateToList_goBackToListView *****************');
        
        if (!isDataCreated) testDataCreation();
        String sRetURL = '/a0V?page=1&rolodexIndex=-1';
        
        PageReference pageRef = Page.RelationshipLeadEditOverridePage;
        Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('Id', testRelationshipLead.Id);
        ApexPages.currentPage().getParameters().put('retURL', sRetURL);
                
        Test.startTest();
        
        ApexPages.Standardcontroller stdCon = new ApexPages.Standardcontroller(testRelationshipLead);
        VFCntrlr_RelationshipLeadAccPlayEdit controller = new VFCntrlr_RelationshipLeadAccPlayEdit(stdCon);       
        String actualURL = controller.navigateToList().getUrl();
        
        Test.stopTest();
        
        System.assertEquals(actualURL, sRetURL);
        
        System.debug('***************** END navigateToList_goBackToListView *****************'); 
    }
    
    static void TestDataCreation() {
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1)[0];
        
        Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact');
        insert testContact;
        
        Campaign testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign', Follow_Up_Role__c = 'Inside Sales Rep');
            
        insert testCampaign;
        
        // Rev 1.1        
        RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = true;   // Rev 1.2
        CampaignMember testCampaignMember = new CampaignMember(CampaignId = testCampaign.Id, Campaign_Vehicle__c = 'eSeminar/Webcast/Webinar',
                                                            ContactId = testContact.Id, CM_Status__c = 'Requires Follow-Up');
        insert testCampaignMember;
        RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = false;  // Rev 1.2
                    
        // Rev 1.2            
        testRelationshipLead = new Relationship_Lead__c(Contact__c = testContact.Id, Campaign__c = testCampaign.Id, 
                                                        Status__c = 'Requires Follow-Up', CM_Source__c = testCampaignMember.Id);  
        insert testRelationshipLead;
                              
        System.debug('RelationshipLead created: '+ testRelationshipLead.id);                                    
        isDataCreated = true;
    }
}
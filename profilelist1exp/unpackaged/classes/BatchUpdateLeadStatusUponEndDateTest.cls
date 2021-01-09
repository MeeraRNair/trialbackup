/* ------------------------------------------------------------------------------------------------------------------------
Version   Date             CR     By            Purpose
1.0     18 Aug 2015      11856  Dipin Raju    test class for BatchUpdateLeadStatusUponEndDate
2.0     30-June-2016     13216  Azwanti     added assert
3.0     01-Sept-2016     13438  Azwanti     LM2_17- Disable code in Lead 2.0 object to update leads to "Cancelled - LQR inactivity" when campaign reaches close date
4.0     28-Nov-2017             Ashok       Marketing LTO - Updating cancel process with new status    

--------------------------------------------------------------------------------------------------------------------------- */
@isTest(SeeAllData=false)
private class BatchUpdateLeadStatusUponEndDateTest {
    
    static testMethod  void Test_BatchUpdateLeadStatusUponEndDate() {
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        Id lead2RTId = IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        
        //create Sales & Marketing User
        UserTestData.iNumberOfUsers = 3;
        UserTestData.bCreate = false;
        UserTestData.createCommonUsers();
        
        Profile marketingProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name LIKE '%Marketing%' limit 1];
        Profile salesProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name LIKE '%Sales%' limit 1];
            
        list<User> listUsers = UserTestData.lstUsers;
        listUsers[0].ProfileId = marketingProfile.Id;
        listUsers[1].ProfileId = salesProfile.Id;
        insert listUsers;
        
        List<Id> listUserId = new List<Id>();
        for(User u: listUsers){
            listUserId.add(u.Id);
        }
        
        Campaign testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', StartDate=date.newInstance(2009, 12, 1), EndDate=System.Today(), 
                                              IsActive=true, Description='Test Campaign 007',
                                              Name='Test Camp 1', Follow_Up_Role__c = 'Inside Sales Rep', RecordTypeId =campRTId, 
                                              Allocation_Source__c='Dell Allocation APJ', Nurture_Source__c='Dell Nurturing',
                                              Secondary_Role__c='Account Owner', Status='In Progress', Close_Date_for_Leads__c=System.Today(),
                                              Lead_Routing__c = 'Not Applicable'); //v3.0 added Lead Routing field to avoid the Mandatory field error message
        insert testCampaign ;        
        
        List<Lead> testLeadList = new List<Lead>();
        
        Lead SLead = new Lead(LastName = 'Test Sales Lead', OwnerId = listUsers[1].Id,
                              Lead_Type__c = 'Inbound',
                              RecordTypeId =lead2RTId, 
                              Email = 'testcmap@test.com',
                              Status = 'New', //V4.0 - changed from Accepted to New
                              Phone = '88967544',
                              Country = 'United States',//v4.0
                              Country_Code__c = 'US',//v4.0
                              Campaign__c = testCampaign.Id,
                              Company = 'Test Company',
                              LeadSource='Partner',
                              Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
        testLeadList.add(SLead);
        
        Lead MLead = new Lead(LastName = 'Test Marketing Lead', OwnerId=listUsers[0].Id,
                              Lead_Type__c = 'Inbound',
                              RecordTypeId =lead2RTId, 
                              Email = 'testcmap@test.com',
                              Status = 'New', //v4.0 
                              Phone = '88967544',
                              Country = 'United States',//v4.0
                              Country_Code__c = 'US',//v4.0
                              Campaign__c = testCampaign.Id,
                              Company = 'Test Company',
                              LeadSource='Partner',
                              Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
        testLeadList.add(MLead);
        
        TriggerExecutionController.setSkipAllTriggers(true); 
        insert testLeadList;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        List<String> lstLeadIds = new List<String>();
        for(Lead obj:testLeadList){
            lstLeadIds.add(obj.Id);
        }        
        
        BatchUpdateLeadStatusUponEndDate batchObj = new BatchUpdateLeadStatusUponEndDate();         
        
        Test.startTest();                                                          
        database.executeBatch(batchObj);
        Test.stopTest();
        
        /*4.0 Commenting the below assertion becuase the cancelled status is now assigned by the system
        List<Lead> actualLeadList = [SELECT Owner.Profile.Name, Status FROM Lead WHERE Id in :lstLeadIds];
        for(Lead actualLead: actualLeadList){
            if(actualLead.Owner.Profile.Name.contains('Sales')){
                system.assertequals('Cancelled - Sales Inactivity', actualLead.Status);   //v2.0
            }
            //v3.0 - remove assert on below since the function for Marketing profile, is disabled from BatchUpdateLeadStatusUponEndDate job. 
            else if(actualLead.Owner.Profile.Name.contains('Marketing')){
                system.assertequals('Cancelled - LQR Inactivity', actualLead.Status);     //v2.0   

            } 
        } */
    }
}
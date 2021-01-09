@isTest(SeeAllData = false)
private class Test_SalesCoachController {
    
    
    public static testmethod void controllerMethod(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity oppRecord = new Opportunity();
        oppRecord.StageName = 'Plan - 1%';
        oppRecord.CloseDate = System.Today();
        oppRecord.Name = 'Test Opp';
        insert oppRecord;
        TriggerExecutionController.setSkipAllTriggers(false);
        Sales_Coach_Setup__c salesCoachRecord = new Sales_Coach_Setup__c();
        salesCoachRecord.Name = 'Plan - 1%';
        salesCoachRecord.Language__c = 'English';
        salesCoachRecord.LanguageCode__c = 'en_US';
        salesCoachRecord.Active__c = true;
        salesCoachRecord.Goal_Stage__c = 'Goal Sales Coach';
        insert salesCoachRecord;
        
        List<Sales_Coach_Activity__c> salesActivityList = new List<Sales_Coach_Activity__c>();
        for(integer i =0 ; i<6 ; i++){
            Sales_Coach_Activity__c salesActivityRecord = new Sales_Coach_Activity__c();
            salesActivityRecord.Activity_Details__c ='Sales Activity'+i;
            salesActivityRecord.Ordering_Number__c = i;
            salesActivityRecord.Sales_Coach_Setup__c= salesCoachRecord.Id;
            salesActivityList.add(salesActivityRecord);
        }  
        insert salesActivityList;
        
        Profile AdminProfile = [select Id, Name from Profile where Name LIKE 'System Administrator' Limit 1];
        User testUser = new User(FirstName='Test12',IsActive = TRUE,
                                 LastName='TestUser21', Title='CEO', UserName='pegasus_'+System.currentTimeMillis()+'_TestUser1@test.com',
                                 Is_SSO_User__c = FALSE,
                                 Is_Integrated_User__c = FALSE,
                                 Email='pegasus_TestUser1@dell.com',                                
                                 Alias='tBatcwh1', CommunityNickName='tBatwch1', 
                                 ProfileId = AdminProfile.Id,
                                 LanguageLocaleKey='en_US', LocaleSidKey='en_CA', 
                                 EmailEncodingKey='UTF-8', TimeZoneSidKey='Asia/Kuala_Lumpur',
                                 Badge_Number__c='tBatch1', 
                                 System_Admin_or_Delegated_User_Admin__c = TRUE);  
        
        insert testUser;
        
        PageReference pageRef =Page.SalesCoach;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', oppRecord.id);
        System.runAs(testUser){
            SalesCoachController controller = new SalesCoachController(); 
            controller.getOpptyStages();
            controller.updateStageData();
            controller.getOpportunityStage();
            controller.getSalesCoachStage();
            controller.getSalesCoachActivities();
            controller.countClick();      
        }
        
    }
    
    public static testmethod void controllerMethodNoActivites(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity oppRecord = new Opportunity();
        oppRecord.StageName = 'Plan - 1%';
        oppRecord.CloseDate = System.Today();
        oppRecord.Name = 'Test Opp';
        insert oppRecord;
        TriggerExecutionController.setSkipAllTriggers(false);
        Sales_Coach_Setup__c salesCoachRecord = new Sales_Coach_Setup__c();
        salesCoachRecord.Name = 'Plan - 1%';
        salesCoachRecord.Language__c = 'English';
        salesCoachRecord.LanguageCode__c = 'en_US';
        salesCoachRecord.Active__c = true;
        salesCoachRecord.Goal_Stage__c = 'Goal Sales Coach';
        insert salesCoachRecord;
        
        PageReference pageRef =Page.SalesCoach;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', oppRecord.id);
        SalesCoachController controller = new SalesCoachController(); 
        controller.getOpptyStages();
        controller.updateStageData();
    }
}
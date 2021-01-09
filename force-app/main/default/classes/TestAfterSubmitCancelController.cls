@isTest
private class TestAfterSubmitCancelController{

    static testMethod void TestAfterSubmitCancelControllerTest() {
        Date tempStartDate = system.today();
        Date tempEndDate = system.today();
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,
                                 Phone='11111', Decision_Making_Role__c='Influencer',
                                 Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
 
        Id siteId=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='No',Offer_Transportation__c='No',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=siteId);
        insert testSite;
        
        Id custId=IdLookupUtils.getRecordTypeId('Dell Solution Centers','Customer_Engagement__c',true);                         
        Test.startTest();
        Customer_Engagement__c CEDetail = new Customer_Engagement__c(Name = 'Pending CE',
                                                Requestor_Name__c = testUser.Id, 
                                                Cost_Center__c = '1111-1111-111111', 
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = newaccount.Id,
                                                Primary_Contact__c = con.Id,
                                                NDA__c = 'No',
                                                Event_Status__c = 'Pending',
                                                GSL_Start_Date__c=tempStartDate,
                                                GSL_End_Date__c=tempEndDate,
                                                Event_Type__c='Design Sessions',
                                                Dell_Solution_Center_Site__c=testSite.Id,
                                                Trade_Compliant__c='No',
                                                RecordTypeId = custId);
        insert CEDetail;
        Test.stopTest();
        //PageReference  pr = new PageReference('/apex/AfterSubmitCancel?id='+CEDetail.Id);
        //PageReference  pr = new PageReference('/apex/AfterSubmitCancel?id='+CEDetail.Id);
        //Test.setCurrentPage(pr);
        AfterSubmitCancelController controller = new AfterSubmitCancelController(new ApexPages.StandardController(CEDetail));
        controller.updateCE.Cancel_Request__c='Change Request';
        controller.checkRequest();
        controller.getCEUpdateDetails();
        controller.getRequestFlag();
        controller.getSiteNameList();
        PageReference  pageRefExpected=new PageReference('/'+CEDetail.Id);
        PageReference  pageRefActual=controller.SaveButtonAction();  
        System.assertEquals(pageRefExpected.getURL(),pageRefActual.getURL()); 
        
        PageReference  pageRefCancelActual=controller.cancelButtonAction();  
        System.assertEquals(pageRefExpected.getURL(),pageRefCancelActual.getURL()); 
        
        controller.updateCE.Cancel_Request__c='Cancel Request'; 
        controller.checkRequest();
        controller.getCEUpdateDetails();
        controller.getRequestFlag();
        PageReference  pageRefRequestlActual=controller.SaveButtonAction();  
        System.assertEquals(pageRefExpected.getURL(),pageRefRequestlActual.getURL()); 
    }
}
@isTest
private class TestCreateCancelViewController{ 
    
    public static testMethod void TestCreateCancelViewControllerTest() {
        Date tempStartDate = system.today();
        Date tempEndDate = system.today();
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
 
        Id siteId=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='No',Offer_Transportation__c='No',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=siteId);
        insert testSite;
        
        Test.startTest();
        Id custId=IdLookupUtils.getRecordTypeId('Dell Solution Centers','Customer_Engagement__c',true);                         
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
        
        Customer_Engagement__c CEDetailReq = new Customer_Engagement__c(Name = 'Requested CE',
                                                Requestor_Name__c = testUser.Id, 
                                                Cost_Center__c = '1111-1111-111111',  
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = newaccount.Id,
                                                Primary_Contact__c = con.Id,
                                                NDA__c = 'No',
                                                Event_Status__c = 'Requested',
                                                GSL_Start_Date__c=tempStartDate,
                                                GSL_End_Date__c=tempEndDate,
                                                Event_Type__c='Design Sessions',
                                                Dell_Solution_Center_Site__c=testSite.Id,
                                                Trade_Compliant__c='No',
                                                RecordTypeId = custId);
        insert CEDetailReq ;
        
        PageReference  pr = new PageReference('/apex/CreateCancelRequest?id='+CEDetail.Id);
        Test.setCurrentPage(pr);
        CreateCancelViewController controller = new CreateCancelViewController(new ApexPages.StandardController(CEDetail));
        controller.submitStatus();
        
        PageReference  pageRefExpected=new PageReference('/apex/CancelRequest?id='+CEDetail.Id);
        PageReference  pageRefActual=controller.submitStatus();
        System.assertEquals(pageRefExpected.getURL(),pageRefActual.getURL());
        
        PageReference  prreq = new PageReference('/apex/CreateCancelRequest?id='+CEDetailReq.Id);
        Test.setCurrentPage(prreq);
        CreateCancelViewController controllerReq = new CreateCancelViewController(new ApexPages.StandardController(CEDetailReq));
        
        PageReference  pageRefReqExpected=new PageReference('/apex/AfterSubmitCancel?id='+CEDetailReq.Id);
        PageReference  pageRefReqActual=controllerReq.submitStatus();
        System.assertEquals(pageRefReqExpected.getURL(),pageRefReqActual.getURL());
        Test.stopTest();
    }
}
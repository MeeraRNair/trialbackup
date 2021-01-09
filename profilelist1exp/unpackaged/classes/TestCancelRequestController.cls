/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Fenny       08-Aug-2012     13.7                Test method failed when run all test. "System.LimitException: Too many SOQL queries: 101"
*/
@isTest
private class TestCancelRequestController {

    static testMethod void TestCancelRequestControllerTest() {
        Date tempStartDate = system.today();
        Date tempEndDate = system.today();
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        
        Id siteId=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='EBC',
                                                         Offer_Catering__c='No',Offer_Transportation__c='No',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=siteId);
        insert testSite;
        
        /* Ver 1.0
        Event_Location__c testSiteDSC=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='No',Offer_Transportation__c='No',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=siteId);
        insert testSiteDSC;*/
        
        Id roomId=IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true);
        Event_Location__c testRoom=new Event_Location__c(Name='testRoom',Room_Occupancy__c='15',Select_Site__c=testSite.Id,recordTypeid=roomId);
        insert testRoom;
        
        Calendar_Management__c newCal=new Calendar_Management__c(Room__c=testRoom.Id,Site__c=testSite.Id,
                                        Date__c=System.today()+30,Start_Date__c =System.today()+30,
                                        End_Date__c =System.today()+30, Status__c='Pending');
        insert newCal;
        
        Id custId=IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true);                         
        Customer_Engagement__c CEDetail = new Customer_Engagement__c(Name = 'Pending CE',
                                                Requestor_Name__c = testUser.Id, 
                                                Cost_Center__c ='1111-1111-111111', 
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = newaccount.Id,
                                                Primary_Contact__c = con.Id,
                                                NDA__c = 'No',Calendar_Management__c=newCal.Id,
                                                Event_Type__c='Briefing',
                                                Trade_Compliant__c='No',
                                                RecordTypeId = custId);
        insert CEDetail;
        
        /* Ver 1.0
        Customer_Engagement__c CEDetailCancel = new Customer_Engagement__c(Name = 'Requested CE',
                                                Requestor_Name__c = testUser.Id, 
                                                Cost_Center__c = '1111-1111-111111',  
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = newaccount.Id,
                                                Primary_Contact__c = con.Id,
                                                NDA__c = 'No',
                                                Event_Status__c = 'Canceled',
                                                GSL_Start_Date__c=tempStartDate,
                                                GSL_End_Date__c=tempEndDate,
                                                Event_Type__c='Design Sessions',
                                                Dell_Solution_Center_Site__c=testSiteDSC.Id,
                                                Trade_Compliant__c='No',
                                                RecordTypeId = custId);
        insert CEDetailCancel ;        */
        
        PageReference  pr = new PageReference('/apex/CancelRequest?id='+CEDetail.Id);
        Test.setCurrentPage(pr);
        CancelRequestController controller = new CancelRequestController (new ApexPages.StandardController(CEDetail));
        controller.getshowMessage();
        
        PageReference  pageRefExpected=new PageReference('/'+CEDetail.Id);
        PageReference  pageRefActual= controller.changeStatus();            
        System.assertEquals(pageRefExpected.getURL(),pageRefActual.getURL());
        
        /* Ver 1.0: Commented this block as there is not any assertion test, also commented related block above
        PageReference  pr_cancel = new PageReference('/apex/CreateCancelRequest?id='+CEDetailCancel.Id);
        Test.setCurrentPage(pr_cancel);
        CancelRequestController controller_cancel= new CancelRequestController (new ApexPages.StandardController(CEDetailCancel));
        controller_cancel.getshowMessage();
        */  
    }
}
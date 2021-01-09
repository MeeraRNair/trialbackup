/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestNavigationController {
        
        private static String recordTypename;
        private static String URL;
        private static String CERecord;
        private static String CERecordName;
        
        //Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        RecordType listRT= [Select id, SobjectType, Name From RecordType  where SobjectType='Attendees__c'];
      
    private static testMethod void myUnitTestforaccountteam() {

        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                   Active__c=true,Engagement_Type__c='DSC',
                                                   Offer_Catering__c='No',Offer_Transportation__c='No',
                                                   Email__c='test_user@dell.com',
                                                   recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;
        CERecord=testCE1.Id;
        CERecordName=testCE1.Name;
        recordTypename='Account Team';
        URL='/apex/AttendeePage?CF00NA00000063PNB_lkid='+CERecord+'&CF00NA00000063PNB='+CERecordName ;
    
        PageReference pageRef = new PageReference('/apex/navigation?CF00NA00000063PNB='+testCE1.Name+'&CF00NA00000063PNB_lkid='+testCE1.Id+'&nooverride=1');
        Test.setCurrentPage(pageRef);
        //String rtName = controller.getrecordTypename();
        NavigationController  controller = new NavigationController (new ApexPages.StandardController(testCE1));
        controller.setrecordTypename('Account Team');
        String nextPage = controller.Continuebutton().getUrl();
        System.assert(nextPage!= NULL);
                  
    }
    private static testMethod void myUnitTestforDI() {

        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                       Active__c=true,Engagement_Type__c='DSC',
                                                       Offer_Catering__c='No',Offer_Transportation__c='No',
                                                       Email__c='test_user@dell.com',
                                                       recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;
    
        PageReference pageRef = new PageReference('/apex/navigation?CF00NA00000063PNB='+testCE1.Name+'&CF00NA00000063PNB_lkid='+testCE1.Id+'&nooverride=1');
        Test.setCurrentPage(pageRef);
        
        NavigationController  controller = new NavigationController (new ApexPages.StandardController(testCE1));
        controller.setrecordTypename('Dell Internal');
        String nextPage = controller.Continuebutton().getUrl();
        System.assert(nextPage!=NULL);
              
    }
    private static testMethod void myUnitTestforCustomer() {
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                       Active__c=true,Engagement_Type__c='DSC',
                                                       Offer_Catering__c='No',Offer_Transportation__c='No',
                                                       Email__c='test_user@dell.com',
                                                       recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;
    
        PageReference pageRef = new PageReference('/apex/navigation?CF00NA00000063PNB='+testCE1.Name+'&CF00NA00000063PNB_lkid='+testCE1.Id+'&nooverride=1');            
        Test.setCurrentPage(pageRef);
            
        NavigationController  controller = new NavigationController (new ApexPages.StandardController(testCE1));
        controller.setrecordTypename('Customer');
        String nextPage = controller.Continuebutton().getUrl();
        System.assert(nextPage!= NULL);
           
    }
    private static testMethod void myUnitTestforVendor() {
    
    Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                       Active__c=true,Engagement_Type__c='DSC',
                                                       Offer_Catering__c='No',Offer_Transportation__c='No',
                                                       Email__c='test_user@dell.com',
                                                       recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;
      
        PageReference pageRef = new PageReference('/apex/navigation?CF00NA00000063PNB='+testCE1.Name+'&CF00NA00000063PNB_lkid='+testCE1.Id+'&nooverride=1');
        Test.setCurrentPage(pageRef);
            
        NavigationController  controller = new NavigationController (new ApexPages.StandardController(testCE1));
        controller.setrecordTypename('Vendor/Partner');
        String nextPage = controller.Continuebutton().getUrl();
        System.assert(nextPage != NULL);
           
    }
    private static testMethod void myUnitTestforRTId() {
        
    Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                       Active__c=true,Engagement_Type__c='DSC',
                                                       Offer_Catering__c='No',Offer_Transportation__c='No',
                                                       Email__c='test_user@dell.com',
                                                       recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;
        
        PageReference pageRef = new PageReference('/apex/navigation?CF00NA00000063PNB='+testCE1.Name+'&CF00NA00000063PNB_lkid='+testCE1.Id+'&nooverride=1');
        Test.setCurrentPage(pageRef);
        
        NavigationController  controller = new NavigationController (new ApexPages.StandardController(testCE1));
        List<SelectOption> options = new List<SelectOption>();
        options = controller.getrecordTypenames();
        System.assertEquals(options.size(),4); 
              
    }

    private static testMethod void myUnitTestforCancel() {
        
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                       Active__c=true,Engagement_Type__c='DSC',
                                                       Offer_Catering__c='No',Offer_Transportation__c='No',
                                                       Email__c='test_user@dell.com',
                                                       recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;
    
        PageReference pageRef = new PageReference('/apex/navigation?CF00NA00000063PNB='+testCE1.Name+'&CF00NA00000063PNB_lkid='+testCE1.Id+'&nooverride=1');
        Test.setCurrentPage(pageRef);
        
        NavigationController  controller = new NavigationController (new ApexPages.StandardController(testCE1));
        String nextPage = controller.Cancelbutton().getUrl();
        System.assert(nextPage!=NULL);
        String RTName = controller.getrecordTypename();
        List<RecordType> rtList= controller.getrecordTypelist();
        
    }

}
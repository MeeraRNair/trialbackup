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
private class TestCustomerController{

    static testMethod void myUnitTest() {
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
    
        PageReference pageRef = new PageReference('/apex/CustomerPage?CEId='+testCE1.Id);
        Test.setCurrentPage(pageRef);
        
        /* CR 6602 : Governor Limit issue fix */
        //CustomerController controller = new CustomerController(new ApexPages.StandardController(testCE1));
        CustomerController controller = new CustomerController();
        
        List<SelectOption> options = new List<SelectOption>();
        options = controller.getaccountNames();
        System.assertEquals(options.size(),1);
        controller.setPAGE_SIZE(5);
    }

    private static testMethod void myUnitTestnext() {
        //Fenny moved this line to below before insert CE record : Test.startTest();
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact contact= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert contact;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='No',Offer_Transportation__c='No',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=rtSite);
        insert testSite;
        Test.startTest();// Fenny added to resolve 'Too many SOQL queries: 101' issue
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=contact.Id,NDA__c='Yes');
        insert testCE1;
    
        Contact newcontact1 = new Contact(Purchaser_Influence_Over__c= 'Client', Phone ='666666', Title='AE',LastName = '56', Job_Function__c ='Operations', Job_Function_Role__c ='Quality Manager', FirstName ='Contact', Decision_Making_Role__c = 'Influencer', AccountId =newaccount.Id);
        Contact newcontact2 = new Contact(Purchaser_Influence_Over__c= 'Client1', Phone ='666667', Title='AE',LastName = '157', Job_Function__c ='Operations', Job_Function_Role__c ='Quality Manager', FirstName ='Contact1', Decision_Making_Role__c = 'Influencer', AccountId =newaccount.Id);
        insert newcontact1;
        insert newcontact2;
        
        Test.stopTest();
        
        Attendees__c newAtt = new Attendees__c(Customer_Attendee__c=newcontact2.Id,Role__c=newcontact2.Title,Customer_Engagement__c=testCE1.Id, Attendee_Name__c=newcontact2.Name );
        insert newAtt;
       
        
        //Test.startTest();
        //Contact[] con =[select Id from Contact where AccountId =:testCE1.Primary_Account__c];
        Account acc =[select Name from Account where Id =:testCE1.Primary_Account__c];
        
        PageReference pageRef = new PageReference('/apex/CustomerPage?CEId='+testCE1.Id);
        Test.setCurrentPage(pageRef);

        /* CR 6602 : Governor Limit issue fix */
        //CustomerController controller = new CustomerController(new ApexPages.StandardController(testCE1));
        CustomerController controller = new CustomerController();
        
        controller.setaccountName(acc.Name);
        String accname = controller.getaccountName();
        system.assertEquals(accname, acc.Name);
        
        pageReference nextPage = controller.Next();
        
        controller.contactPresent=TRUE;
        Boolean contactPresent = controller.getcontactPresent();
        system.assertEquals(contactPresent, TRUE);
        
        Boolean errorMsg = controller.geterrorfornoaccountteam();
                    
        Attendees__c contactattendeeList = new Attendees__c();    
        contactattendeeList.Customer_Engagement__c=testCE1.Id;
        List<Attendees__c> newattendeeList = new List<Attendees__c>();
        newattendeeList.add(contactattendeeList);
        
        pageReference nextPage1 = controller.addnewContact();
    
        List<Attendees__c> attendee= controller.getattendee();
        
        controller.externalContactPresent=TRUE;
        Boolean externalContactPresent = controller.getexternalContactPresent();
        system.assertEquals(externalContactPresent, TRUE);
        
        contactattendeeList.Attendee_Name__c='Test Exteranl';
        contactattendeeList.Role__c='Executive';
        contactattendeeList.Email__c='j.j@y.n';
        contactattendeeList.Phone__c='876987';
        pageReference nextPage2 = controller.addnew();

        /* CR 6602 : Governor Limit issue fix */
        //List<CustomerController.TeamDetails> TeamDetaillist= controller.TeamDetail ;
        //List<CustomerController.TeamDetails> TeamDetaillist1= controller.getCustomerTeamMember();
        //system.assert(TeamDetaillist!=NULL);

        //TeamDetaillist[0].selected=TRUE;
        String nextPages = controller.Save().getUrl();
        
        System.assert(nextPages!=NULL);
        //Test.stopTest();
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
    
        PageReference pageRef = new PageReference('/apex/CustomerPage?CEId='+testCE1.Id);
        Test.setCurrentPage(pageRef);

        /* CR 6602 : Governor Limit issue fix */
        //CustomerController controller = new CustomerController(new ApexPages.StandardController(testCE1));
        CustomerController controller = new CustomerController();
        
        /*CR 6372 : Search function for Customer and account team attendees*/
        controller.getsearchListSizeNotZero();
        controller.getsearcherrorfornoaccountteam();
        controller.Search(); 
        
        /* CR 6602 : Governor Limit issue fix */
        controller.getPAGE_SIZE();
        controller.getSetController();
        controller.getPageCounter();

        String nextPage = controller.Cancel().getUrl();
        System.assert(nextPage != NULL);
                  
    }

}
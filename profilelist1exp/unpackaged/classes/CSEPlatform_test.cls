/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         -           -                  -                -                -                                                 
2.0         16136       FY19-DCE-0802   13-July-2018    Venkat Sharan   Fixed test class as part of the story 5240538
*/
@isTest
private class CSEPlatform_test { 
static VFCntrlr_CSEPlatform controller;

static User user;
static Account account;
static Opportunity testOpportunity;
static Support_Request__c SupportRequest;

         @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        system.assertEquals('Qualify - 30%',owdSetting.Oppty_Stage30__c );
    }
 
    static testMethod void test_initializeControllerPlarform() {  
       createTestData();
       test_Platfrom();
    }    
    
    static testMethod void test_initializeControllerStorages() {  
       createTestData();
       test_Storages();
    }  
    
    static testMethod void test_initializeControllerPeripheral() {  
       createTestData();
       test_Peripheral();
    }  
    
    static testMethod void test_initializeControllerOperating() {  
       createTestData();
       test_Operating();
    }
    
    static testMethod void test_initializeControllerNetwork() {  
       createTestData();
       test_Network();
    }
    
    static testMethod void test_initializeControllerHBA() {  
       createTestData();
       test_HBA();
    }
    static testMethod void test_initializeControllerOpnull() {  
       createTestData();
       test_Opnull();
    } 
    static testMethod void test_initializeControllerPlatformnull() {  
       createTestData();
       test_Platformnull();
    }
    static testMethod void test_initializeControllercse() {  
       createTestDatacse();
    }
    static testMethod void test_csetriggerupdate() {  
       createTestData();
       test_triggercseupdate();
    }   
    static void createTestData(){    
        TriggerExecutionController.setSkipAllTriggers(true);
        //Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep - Non SSO' order by name limit 1 ];        
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep' order by name limit 1 ];        
        UserRole userRole= [select id, name from userrole where name like 'WW_Exec' order by name limit 1];
                 
        user = new User( Username='test' + System.currentTimeMillis() + '@test.com',   
                                Alias = 'test',
                                Email='test' +'@dell.com',                               
                                FirstName='Tfirst',                               
                                LastName='TLast',                                
                                ProfileId = userProfile.Id, 
                                UserRoleId = userRole.Id,
                                LanguageLocaleKey='en_US',                               
                                LocaleSidKey='en_US',                       
                                EmailEncodingKey='UTF-8',      
                                TimeZoneSidKey='America/Los_Angeles',                               
                                Badge_Number__c='TEST12345' );                          
                       
                 
                         
        insert user;         
         
        //Create Account
        account=new Account(name='Test Account');
        //insert account;
        //Create Opportunity
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];         
        
        testOpportunity = new Opportunity(RecordTypeId=rectype.Id,
                                        Name='Test Opportunity', AccountId= account.Id, 
                                        CurrencyIsoCode='USD',Type='Deal/Bid Direct', 
                                        CloseDate= system.today(),
                                        Solution_Type__c='Business Processing',StageName='Plan - 1%');   
        //insert testOpportunity;                                
        
        System.RunAs(user){  
         	SystemBehaviorBypasser.setSkipValidationRules(new List<string>{'Opportunity'});
            insert account;
            insert testOpportunity;
            ResetSystemBehaviorBypasser.resetSkipValidationRules(new List<string>{'Opportunity'});
        } 
         
        //ID CstmSolnEnggSprtRT=IdLookupUtils.getRecordTypeId('Request PG Custom Solutions Engineering  Support','Support_Request__c', true); 
        List<RecordType> rectypeSR=[Select Name, Id From RecordType where Name='Request PG Custom Solutions Engineering Support' AND SobjectType='Support_Request__c' Limit 1];
        SupportRequest=new Support_Request__c(
                                            RecordTypeId=rectypeSR[0].id,
                                            Opportunity__c=testOpportunity.Id,
                                            Buying_Power__c=1000,
                                            Request_Type__c = 'CSE',
                                            Pre_Post_Sales__c = 'Pre-Sales',
                                            Sales_Type__c = 'Retention',
                                            NDA__c = 'NA',
                                            Request_Description__c = 'testreq',
                                            Level_of_Support__c = 'other',
                                            CFI__c = 'No',
                                            Customer_Facing_SOW_needed__c = 'No',
                                            OEM_Request__c = 'No',
                                            Export_Compliant__c = 'No',
                                            Overall_Situation__c = 'testover',
                                            Receive_Notification__c = 'No',
                                            Scope__c = 'testscope',
                                            Status__c = 'Unassigned',
                                            Account_Executive__c = user.id,
                                            Solution_Architect_Lookup__c = user.id,
                                            Customer_Contact_Name__c ='test customer',
                                            Customer_Address__c ='test add',
                                            Customer_Email__c ='test@test.com',
                                            Security_Clearance__c ='Yes',                 
                                            Customer_Phone_Number__c = '0123333445', 
                                            Engagement_Type__c ='AIM POD Demo', 
                                            Cost_Center_Number__c='0123344556',                                 
                                            Primary_Competitor__c='test competitor', 
                                            Requested_By_Phone__c ='0128899887', 
                                            Operating_Systems_List__c = 'TestOp1', 
                                            Platform_List__c = 'TestPlatform',
                                            Network_Switches_List__c = 'TestNetwork',
                                            Peripherals_List__c = 'TestPeripherals',
                                            Storage_List__c = 'TestStorage',
                                            HBA_List__c = 'TestHba',
                                            Solution_Architect__c = 'Yes'
                                            );
                                           
       Sales_Motion_User_Role__c SMUserRole=new Sales_Motion_User_Role__c(                                       
                                            Username__c=user.id,      
                                            name='SM User Role Test+i',        
                                            CurrencyIsoCode='USD'   );
                                                       
  
                            
        //insert SupportRequest;
        //test.startTest();
        System.RunAs(user){ 
           
            insert SupportRequest;
            insert SMUserRole;

        }
      }
     static void createTestDatacse(){    
       List<User> testUserList = new List<User>(); 
        //Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep - Non SSO' order by name limit 1 ]; 
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep' order by name limit 1 ];  
        UserRole userRole= [select id, name from userrole where name like 'WW_Exec' order by name limit 1];
         for (integer i=0; i<2;i++){            
            User user1 = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',   
                                Alias = 'test'+i,
                                Email='test'+ i +'@dell.com',                               
                                FirstName='Tfirst'+i,                               
                                LastName='TLast'+i,                                
                                ProfileId = userProfile.Id, 
                                UserRoleId = userRole.Id,
                                LanguageLocaleKey='en_US',                               
                                LocaleSidKey='en_US',                       
                                EmailEncodingKey='UTF-8',      
                                TimeZoneSidKey='America/Los_Angeles',                               
                                Badge_Number__c='TEST12345'+i );                          
            testUserList.add(user1);           
        }           
                         
        insert testUserList;               
         
        //Create Account
        account=new Account(name='Test Account');
        //insert account;
        //Create Opportunity
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];         
        
        testOpportunity = new Opportunity(RecordTypeId=rectype.Id,
                                        Name='Test Opportunity', AccountId= account.Id, 
                                        CurrencyIsoCode='USD',Type='Deal/Bid Direct', 
                                        CloseDate= system.today(),
                                        Solution_Type__c='Business Processing',StageName='Plan - 1%');   
        //insert testOpportunity;                                
        
        System.RunAs(testUserList[0]){  
         	SystemBehaviorBypasser.setSkipValidationRules(new List<string>{'Opportunity'});
            insert account;
            insert testOpportunity;
            ResetSystemBehaviorBypasser.resetSkipValidationRules(new List<string>{'Opportunity'});
        }  
         
        //ID CstmSolnEnggSprtRT=IdLookupUtils.getRecordTypeId('Request PG Custom Solutions Engineering  Support','Support_Request__c', true); 
        List<RecordType> rectypeSR=[Select Name, Id From RecordType where Name='Request PG Custom Solutions Engineering Support' AND SobjectType='Support_Request__c' Limit 1];
        SupportRequest=new Support_Request__c(
                                            RecordTypeId=rectypeSR[0].id,
                                            Opportunity__c=testOpportunity.Id,
                                            Buying_Power__c=1000,
                                            Request_Type__c = 'CSE',
                                            Pre_Post_Sales__c = 'Pre-Sales',
                                            Sales_Type__c = 'Retention',
                                            NDA__c = 'NA',
                                            Request_Description__c = 'testreq',
                                            Level_of_Support__c = 'other',
                                            CFI__c = 'No',
                                            Customer_Facing_SOW_needed__c = 'No',
                                            OEM_Request__c = 'No',
                                            Export_Compliant__c = 'No',
                                            Overall_Situation__c = 'testover',
                                            Receive_Notification__c = 'No',
                                            Scope__c = 'testscope',
                                            Status__c = 'In Review',
                                            Account_Executive__c = testUserList[0].id,
                                            Solution_Architect_Lookup__c = testUserList[0].id,
                                            Customer_Contact_Name__c ='test customer',
                                            Customer_Address__c ='test add',
                                            Customer_Email__c ='test@test.com',
                                            Security_Clearance__c ='Yes',                 
                                            Customer_Phone_Number__c = '0123333445', 
                                            Engagement_Type__c ='AIM POD Demo', 
                                            Cost_Center_Number__c='0123344556',                                 
                                            Primary_Competitor__c='test competitor', 
                                            Requested_By_Phone__c ='0128899887', 
                                            Operating_Systems_List__c = 'TestOp1', 
                                            Platform_List__c = 'TestPlatform',
                                            Network_Switches_List__c = 'TestNetwork',
                                            Peripherals_List__c = 'TestPeripherals',
                                            Storage_List__c = 'TestStorage',
                                            HBA_List__c = 'TestHba',
                                            Solution_Architect__c = 'Yes',
                                            Category__c = 'Testcategory',                            
                                            Reason__c = 'Test Reason',
                                            Project_Priority__c ='Test Pri',
                                            Consulting_Weeks__c = 2.0,
                                            Intake_Comments__c = 'Commentim',
                                            Exit_Report_Submitted__c ='TestExit',
                                            Sustaining_Start_Date__c = System.today(),
                                            Sustaining_End_Date__c = System.today(),
                                            Send_SOW_back_to_BC__c = 'Yes',
                                            Send_SOW_to_PM__c = 'No',
                                            SOW_Delivery_Date__c = System.today(),
                                            AT_Customer_Feedback_on_SOW__c = 'Testfeed',
                                            Related_Projects__c = 'TestRelated',
                                            Hours_Worked__c = 2,
                                            BC_Comments__c = 'Testcomments',
                                            Engineers_Comments__c = 'Testengcomments',
                                            PM_Comments__c = 'Testpmcomments',
                                            Payment_Deferral__c = 'Testpay',
                                            PM_Feedback_on_SOW__c = 'Testpmfeed',                  
                                            CSE_Revenue_Quoted__c = 10.0,
                                            CSE_Revenue_Received__c = 12.0

                                            );
                                            
 //List<Sales_Motion_User_Role__c> SMUserRoleList =new List<Sales_Motion_User_Role__c >();                                         
 //for(integer i=0; i<6;i++){                
  //Sales_Motion_User_Role__c SMUserRole=new Sales_Motion_User_Role__c(                                       
                                            //Username__c=testUserList[1].id,      
                                            //name='SM User Role Test+i',        
                                            //CurrencyIsoCode='USD'
                                             //  );
            //if(i==0)SMUserRole.Role__c='Project Manager';
            //if(i==1)SMUserRole.Role__c='Business Consultant';
            //if(i==2)SMUserRole.Role__c='Engineer 1';
            //if(i==3)SMUserRole.Role__c='Engineer 2';
            //if(i==4)SMUserRole.Role__c='Engineer 3';
            //if(i==5)SMUserRole.Role__c='Engineer 4'; 
  //SMUserRoleList.add(SMUserRole); 
 //}                                              
        System.RunAs(testUserList[0]){ 
         try{
            //insert SMUserRole;
            insert SupportRequest;
            }
           catch(Exception e){
                system.debug('######################-Got Validation error in test class:--'+e.getmessage());
            }   

        }
      }
     static void test_Platfrom(){
        GlobalVariables.SM_SOC_ISINSERT = false;
     
        PageReference pr = Page.SupportRequestCSEplatform;
         
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());  
       // System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/SalesMotionCountryConfig'));
        test.startTest();
        //Testing initialization without passing in 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITHOUT ID PARAMETER.');  
        try 
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );    
        } 
        catch(Exception e)
        {           
            //Should throw an error 
            System.assert(e.getMessage().contains('There was a problem retrieving Support Request.'));
        }

        //Testing initialization with a invalid 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITH INVALID ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', '0000000'); 

        try
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        }
        catch(Exception e)
        {
            //Should throw an error 
            System.assert(e.getMessage().contains('Invalid id'));
        }
        System.RunAs(user){ 
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');
        List<String> platformsSelected= new List <String>(); 
        platformsSelected.add('Platform1');
        System.Debug('Debug: Platform');
        
        
        String passedpage ='Platforms'; 
        ApexPages.currentPage().getParameters().put('page', passedpage );
        controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        ApexPages.currentPage().getParameters().put('id', supportrequest.Id);
        controller.getpassedpage();
        controller.getSupportRequestId();
        controller.getallAvailablePlatforms();
        controller.addPlatforms();
        controller.getAvailablePlatforms();
        controller.getSelectedPlatforms();
        controller.getSmPlatformsToAdd();
        controller.setsmPlatformsToAdd(platformsSelected);
        controller.addAllPlatforms();
        controller.getPlatformsToRemove();
        controller.setPlatformsToRemove(platformsSelected);
        controller.removePlatforms();
        controller.savePlatforms();
        controller.redirectBack();
        
        test.stopTest();
        }
     }  
     
     static void test_Storages(){
        GlobalVariables.SM_SOC_ISINSERT = false;
     
        PageReference pr = Page.SupportRequestCSEplatform;
         
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());  
       // System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/SalesMotionCountryConfig'));
        test.startTest();
        //Testing initialization without passing in 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITHOUT ID PARAMETER.');  
        try 
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );    
        } 
        catch(Exception e)
        {           
            //Should throw an error 
            System.assert(e.getMessage().contains('There was a problem retrieving Support Request.'));
        }

        //Testing initialization with a invalid 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITH INVALID ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', '0000000'); 

        try
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        }
        catch(Exception e)
        {
            //Should throw an error 
            System.assert(e.getMessage().contains('Invalid id'));
        }
        System.RunAs(user){ 
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');
        List<String> storagesSelected= new List <String>(); 
        storagesSelected.add('Storage1');
        
        System.Debug('Debug: Storage');
        String passedpage = 'storage';     
        ApexPages.currentPage().getParameters().put('page', passedpage);  
        System.Debug('Ambickaa####' + passedpage); 
        controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        ApexPages.currentPage().getParameters().put('id', supportrequest.Id);
        controller.getallAvailableStorages();
        controller.addStorages();
        controller.getAvailableStorages();
        controller.getSelectedStorages();
        controller.getSmStoragesToAdd();
        controller.setsmStoragesToAdd(storagesSelected);
        controller.addAllStorages();
        controller.getStoragesToRemove();
        controller.setStoragesToRemove(storagesSelected);
        controller.removeStorages();
        controller.saveStorages();
        
       test.stopTest();
       }
     }  
     
     static void test_Peripheral(){
        GlobalVariables.SM_SOC_ISINSERT = false;
     
        PageReference pr = Page.SupportRequestCSEplatform;
         
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());  
       // System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/SalesMotionCountryConfig'));
        test.startTest();
        //Testing initialization without passing in 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITHOUT ID PARAMETER.');  
        try 
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );    
        } 
        catch(Exception e)
        {           
            //Should throw an error 
            System.assert(e.getMessage().contains('There was a problem retrieving Support Request.'));
        }

        //Testing initialization with a invalid 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITH INVALID ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', '0000000'); 

        try
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        }
        catch(Exception e)
        {
            //Should throw an error 
            System.assert(e.getMessage().contains('Invalid id'));
        }
        System.RunAs(user){ 
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');
        List<String> peripheralsSelected= new List <String>(); 
        peripheralsSelected.add('peripherals1');

        System.Debug('Debug: peripherals');
        String passedpage = 'peripherals'; 
        ApexPages.currentPage().getParameters().put('page', passedpage);  
        System.Debug('Ambickaa####' + passedpage); 
        controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        ApexPages.currentPage().getParameters().put('id', supportrequest.Id);
        controller.getallAvailablePeripherals();
        controller.addPeripherals();
        controller.getAvailablePeripherals();
        controller.getSelectedPeripherals();
        controller.getSmPeripheralsToAdd();
        controller.setsmPeripheralsToAdd(peripheralsSelected);
        controller.addAllPeripherals();
        controller.getPeripheralsToRemove();
        controller.setPeripheralsToRemove(peripheralsSelected);
        controller.removePeripherals();
        controller.savePeripherals();
        test.stopTest();
       }
     }  
     
    static void test_Operating(){
        GlobalVariables.SM_SOC_ISINSERT = false;
     
        PageReference pr = Page.SupportRequestCSEplatform;
         
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());  
       // System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/SalesMotionCountryConfig'));
        test.startTest();
        //Testing initialization without passing in 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITHOUT ID PARAMETER.');  
        try 
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );    
        } 
        catch(Exception e)
        {           
            //Should throw an error 
            System.assert(e.getMessage().contains('There was a problem retrieving Support Request.'));
        }

        //Testing initialization with a invalid 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITH INVALID ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', '0000000'); 

        try
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        }
        catch(Exception e)
        {
            //Should throw an error 
            System.assert(e.getMessage().contains('Invalid id'));
        }
        System.RunAs(user){ 
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');
        List<String> operatingsystemsSelected= new List <String>(); 
        operatingsystemsSelected.add('operatingsystems1');

        System.Debug('Debug: Operating');
        String passedpage = 'operatingsystems'; 
        ApexPages.currentPage().getParameters().put('page', passedpage);  
        System.Debug('Ambickaa####' + passedpage); 
        controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        ApexPages.currentPage().getParameters().put('id', supportrequest.Id);
        controller.getallAvailableOperatingsystems();
        controller.addOperatingsystems();
        controller.getAvailableOperatingsystems();
        controller.getSelectedOperatingsystems();
        controller.getSmOperatingsystemsToAdd();
        controller.setsmOperatingsystemsToAdd(operatingsystemsSelected);
        controller.addAllOperatingsystems();
        controller.getOperatingsystemsToRemove();
        controller.setOperatingsystemsToRemove(operatingsystemsSelected); 
        controller.removeOperatingsystems();
        controller.saveOperatingsystems();
        test.stopTest();
       }
     } 
     
     static void test_Network(){
        GlobalVariables.SM_SOC_ISINSERT = false;
     
        PageReference pr = Page.SupportRequestCSEplatform;
         
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());  
       // System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/SalesMotionCountryConfig'));
        test.startTest();
        //Testing initialization without passing in 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITHOUT ID PARAMETER.');  
        try 
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );    
        } 
        catch(Exception e)
        {           
            //Should throw an error 
            System.assert(e.getMessage().contains('There was a problem retrieving Support Request.'));
        }

        //Testing initialization with a invalid 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITH INVALID ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', '0000000'); 

        try
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        }
        catch(Exception e)
        {
            //Should throw an error 
            System.assert(e.getMessage().contains('Invalid id'));
        }
        System.RunAs(user){ 
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');
        List<String> networkSelected= new List <String>(); 
        networkSelected.add('network1');

        System.Debug('Debug: Network');
        String passedpage = 'networkswitches'; 
        ApexPages.currentPage().getParameters().put('page', passedpage);  
        System.Debug('Ambickaa####' + passedpage); 
        controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        ApexPages.currentPage().getParameters().put('id', supportrequest.Id);
        controller.getallAvailableNetwork();
        controller.addNetwork();
        controller.getAvailableNetwork();
        controller.getSelectedNetwork();
        controller.getSmNetworkToAdd();
        controller.setsmNetworkToAdd(networkSelected);
        controller.addAllNetwork();
        controller.getNetworkToRemove();
        controller.setNetworkToRemove(networkSelected);
        controller.removeNetwork();
        controller.saveNetwork();
        test.stopTest();
       }
     } 
     
     static void test_HBA(){
        GlobalVariables.SM_SOC_ISINSERT = false;
     
        PageReference pr = Page.SupportRequestCSEplatform;
         
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());  
       // System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/SalesMotionCountryConfig'));
        test.startTest();
        //Testing initialization without passing in 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITHOUT ID PARAMETER.');  
        try 
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );    
        } 
        catch(Exception e)
        {           
            //Should throw an error 
            System.assert(e.getMessage().contains('There was a problem retrieving Support Request.'));
        }

        //Testing initialization with a invalid 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITH INVALID ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', '0000000'); 

        try
        {
            controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        }
        catch(Exception e)
        {
            //Should throw an error 
            System.assert(e.getMessage().contains('Invalid id'));
        }
        System.RunAs(user){ 
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');
        List<String> hbaSelected= new List <String>(); 
        hbaSelected.add('hba1');
        
        System.Debug('Debug: HBA');
        String passedpage = 'HBA'; 
        ApexPages.currentPage().getParameters().put('page', passedpage);  
        System.Debug('Ambickaa####' + passedpage); 
        controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        ApexPages.currentPage().getParameters().put('id', supportrequest.Id);
        controller.getallAvailableHba();
        controller.addHba();
        controller.getAvailableHba();
        controller.getSelectedHba();
        controller.getSmHbaToAdd();
        controller.setsmHbaToAdd(hbaSelected);
        controller.getHbaToRemove();
        controller.setHbaToRemove(hbaSelected);
        controller.addAllHba();
        controller.removeHba();
        controller.saveHba();
        test.stopTest();
       }
     }

     static void test_Opnull(){
        GlobalVariables.SM_SOC_ISINSERT = false;
     
        PageReference pr = Page.SupportRequestCSEplatform;
         
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());  
       // System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/SalesMotionCountryConfig'));
        test.startTest();
        System.RunAs(user){ 
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');
        SupportRequest.Operating_Systems_List__c = null;
        update SupportRequest;
        System.Debug('Debug: Operating');
        String passedpage = 'operatingsystems'; 
        ApexPages.currentPage().getParameters().put('page', passedpage);  
        System.Debug('Ambickaa####' + passedpage); 
        controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        ApexPages.currentPage().getParameters().put('id', supportrequest.Id);
        controller.getallAvailableOperatingsystems();
        controller.saveOperatingsystems();
        test.stopTest();
        }
     }
     
      static void test_Platformnull(){
        GlobalVariables.SM_SOC_ISINSERT = false;
        PageReference pr = Page.SupportRequestCSEplatform;
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl()); 
        test.startTest();
        System.RunAs(user){
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');
        System.Debug('Debug: Platform');
        SupportRequest.Platform_List__c  = null;
        update SupportRequest;        
        String passedpage ='Platforms'; 
        ApexPages.currentPage().getParameters().put('page', passedpage );
        controller = new VFCntrlr_CSEPlatform(new ApexPages.StandardController(supportrequest) );
        ApexPages.currentPage().getParameters().put('id', supportrequest.Id);
        controller.getpassedpage();
        controller.getSupportRequestId();
        controller.getallAvailablePlatforms();
        controller.savePlatforms();
        test.stopTest();
        }
     }
     
     static void test_triggercseupdate(){
       System.RunAs(user){
            GlobalVariables.SM_SOC_ISINSERT = false;
            SupportRequest.Status__c ='In Sustaining';
            SupportRequest.Consulting_Weeks__c = 2.0; 
            try{
                update SupportRequest;
            }catch(Exception e){
                system.debug('######################-Got Validation error in test class:--'+e.getmessage());
            }
        } 
     }
     

     
}
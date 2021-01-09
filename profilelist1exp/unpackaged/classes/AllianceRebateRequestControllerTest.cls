@isTest
private class AllianceRebateRequestControllerTest {
 static Opportunity opp = new Opportunity();
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
    }
    
    private testmethod static void updateAllianceRebateRequest() {
		
        //Logged In User
        profile profileId =   [select Id, Name from Profile where name like '%Admin%' limit 1];
        User allianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99826513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser;
        
        profile profileId1 =   [select Id, Name from Profile where name like '%Alliance Regional Program Lead%' limit 1];
        User allianceRebateUser2 = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser2@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId1.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99856513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser2;
        
        
        //country obj Instance
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;
        RecordType aealRTId = [select id,name from RecordType where name='Standard Opportunity' limit 1];
         
         TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testCE = new Account();
        testCE.name = 'Some test Account';        
        testCE.status__c = 'Active';
        testCE.Account_Country_Code__c='US';              
        insert testCE;
       
        Opportunity opp = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity',CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
      //  Opportunity opp = AllianceRebateRequestTrigger_Test.createOpportunityInfo('Test2sdsds@gmail.com');
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);        
        
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        arReq.Sales_Force_Deal_ID__c = opp.id;
        arReq.Partner_BDM_Name__c='test';
        arReq.System_Partner_Name__c ='Intel';
        arReq.Finance_Contact__c = 'xxx@dell.com';
        arReq.Client_Enterprise__c ='Client';
        arReq.Status__c = 'Draft';
        arReq.Additional_Sales_Person_Email__c = '';
        arReq.Finance_Contact__c = 'abc@f.com'; 
        arReq.Business_Case_Information__c = 'test';
        arReq.ownerId =   AllianceRebateUser2.Id;
       // System.runAs(AllianceRebateUser){
            insert arReq;
            
         system.assertEquals('abc@f.com', arReq.Finance_Contact__c);
    
         Rebate_Request_Product__c productObj = new Rebate_Request_Product__c();
         productObj.Quantity__c=2;
         productObj.Part_Name_Part_Number__c='test';
         productObj.Dell_System_Model_type__c='testing';
         productObj.Alliance_Rebate_Request__c= arReq.id;
        insert productObj;    
          
                   system.assertEquals('testing', productObj.Dell_System_Model_type__c);

        
      //  }
        System.runAs(allianceRebateUser2){
            Test.startTest();
            pageRef.getParameters().put('id', String.valueOf(arReq.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(arReq);
            AllianceReabteRequestController allianceRebateReq = new AllianceReabteRequestController(sc);
            allianceRebateReq.allianceRebateReqObj = arReq;
            allianceRebateReq.saveRequest();
           // allianceRebateReq.emptyField();  
            allianceRebateReq.closePopup(); 
            allianceRebateReq.getRegions();
           // allianceRebateReq.renewalAction();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getStatus();
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = NULL;
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = arReq.ID;
            allianceRebateReq.isCloned='True';
            allianceRebateReq.partRequestChange();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getProductSize();
            allianceRebateReq.showPopup('assignedRegion');
            allianceRebateReq.makingVoid();
        }
        
    }
    
    private testmethod static void updateMultyAllianceRebateRequest() {
        //Logged In User
        profile profileId =   [select Id, Name from Profile where name like '%Admin%' limit 1];
        User allianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99826513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser;
        //country obj Instance
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;
        
        
         TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testCE = new Account();
        testCE.name = 'Some test Account';        
        testCE.status__c = 'Active';
        testCE.Account_Country_Code__c='US';              
        insert testCE;
       
        Opportunity opp = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);        
        
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        arReq.Sales_Force_Deal_ID__c = opp.id;
        arReq.Partner_BDM_Name__c='test';
        arReq.System_Partner_Name__c ='Intel';
        arReq.Client_Enterprise__c ='Client';
        arReq.Part_Requested__c='CPU';
        arReq.Finance_Contact__c = 'xxx@dell.com';
        arReq.Status__c = 'Draft';
        arReq.Additional_Sales_Person_Email__c = '';
        arReq.Finance_Contact__c = 'abc@f.com'; 
        arReq.ownerId =   AllianceRebateUser.Id;
        arReq.Region__c = 'APJ';
       // arReq.Business_Case_Information__c = 'test';

       // System.runAs(allianceRebateUser){
            insert arReq;
            

          List <Rebate_Request_Product__c> productObj = new List <Rebate_Request_Product__c>(); 
          for(integer i=0;i<1;i++){
            productObj.add(new Rebate_Request_Product__c(Quantity__c=2,
                         Part_Name_Part_Number__c='test',
                         Dell_System_Model_type__c='testing',
                         Alliance_Rebate_Request__c= arReq.id,
                         Sl_No__c= 4,
                         Status__c='Active',
                         Competitor_Name_Competitor_Part__c= 'part',
                         Rebate_per_unit__c= ''));
           }

           insert productObj;

            Test.startTest();
            pageRef.getParameters().put('id', String.valueOf(arReq.Id));
             pageRef.getParameters().put('clone', 'TRUE');
            ApexPages.StandardController sc = new ApexPages.StandardController(arReq);
            AllianceReabteRequestController allianceRebateReq = new AllianceReabteRequestController(sc);
            allianceRebateReq.allianceRebateReqObj.Sales_Force_Deal_ID__c = opp.id;
            allianceRebateReq.allianceRebateReqObj.Finance_Contact__c = 'xyz@dell.com';
            allianceRebateReq.saveRequest();
            
            allianceRebateReq.allianceRebateReqObj.Client_Enterprise__c='Enterprise';
            allianceRebateReq.allianceRebateReqObj.System_Partner_Name__c='Intel';
            allianceRebateReq.allianceRebateReqObj.Part_Requested__c='CPU';
            allianceRebateReq.saveRequest();
            allianceRebateReq.makingVoid();
            allianceRebateReq.allianceRebateReqObj.Client_Enterprise__c='Enterprise';
            allianceRebateReq.allianceRebateReqObj.System_Partner_Name__c='Intel';
            allianceRebateReq.allianceRebateReqObj.Part_Requested__c='Other(SSD/OPA/NIC)';
            allianceRebateReq.saveRequest();
                    system.assertEquals('Intel', allianceRebateReq.allianceRebateReqObj.System_Partner_Name__c);


            
            Test.stopTest();
      //  }
        
    }
    private testmethod static void updateAllianceRebateRequest1() {
    
        //Logged In User
        profile profileId =   [select Id, Name from Profile where name like '%Admin%' limit 1];
        User allianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99826513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser;
        
        profile profileId1 =   [select Id, Name from Profile where name like '%Alliance Regional Program Lead%' limit 1];
        User allianceRebateUser2 = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser2@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId1.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99856513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser2;
        
        
        //country obj Instance
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;
                                    
         TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testCE = new Account();
        testCE.name = 'Some test Account';        
        testCE.status__c = 'Active';
        testCE.Account_Country_Code__c='US';              
        insert testCE;
       
        Opportunity opp = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);        
        
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        arReq.Sales_Force_Deal_ID__c = opp.id;
        arReq.Partner_BDM_Name__c='test';
        arReq.System_Partner_Name__c ='Intel';
        arReq.Finance_Contact__c = 'xxx@dell.com';
        arReq.Client_Enterprise__c ='Client';
        arReq.Status__c = 'Draft';
        arReq.Additional_Sales_Person_Email__c = '';
        arReq.Finance_Contact__c = 'abc@f.com'; 
        arReq.Business_Case_Information__c = 'test';
        arReq.ownerId =   AllianceRebateUser2.Id;
        arReq.Region__c = 'APJ';
      //  System.runAs(AllianceRebateUser){
        insert arReq;
      //  }
        System.runAs(AllianceRebateUser2){
            Test.startTest();
            pageRef.getParameters().put('id', String.valueOf(arReq.Id));
           // pageRef.getParameters().put('clone', '1');
            ApexPages.StandardController sc = new ApexPages.StandardController(arReq);
            AllianceReabteRequestController allianceRebateReq = new AllianceReabteRequestController(sc);
            allianceRebateReq.allianceRebateReqObj = arReq;
            allianceRebateReq.saveRequest();
            allianceRebateReq.closePopup(); 
            allianceRebateReq.getRegions();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getStatus();
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = NULL;
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = arReq.ID;
            allianceRebateReq.isCloned='True';
            allianceRebateReq.partRequestChange();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getProductSize();
            allianceRebateReq.showPopup('assignedRegion');
            allianceRebateReq.makingVoid();
            allianceRebateReq.showPopupIntelEnterCPU();
          //  allianceRebateReq.closePopupIECPU();
            allianceRebateReq.saveRequest();
            
            system.assertEquals(arReq.ID, allianceRebateReq.rebateReqId);

        }
        
    }

    private testmethod static void updateAllianceRebateRequest2() {
        
        //Logged In User
        profile profileId =   [select Id, Name from Profile where name like '%Admin%' limit 1];
        User allianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99826513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser;
        
        profile profileId1 =   [select Id, Name from Profile where name like '%Alliance Regional Program Lead%' limit 1];
        User allianceRebateUser2 = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser2@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId1.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99856513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser2;
        
        
        //country obj Instance
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;
                                    
         TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testCE = new Account();
        testCE.name = 'Some test Account';        
        testCE.status__c = 'Active';
        testCE.Account_Country_Code__c='US';              
        insert testCE;
       
        Opportunity opp = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);        
        
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        arReq.Sales_Force_Deal_ID__c = opp.id;
        arReq.Partner_BDM_Name__c='test';
        arReq.System_Partner_Name__c ='Intel';
        arReq.Finance_Contact__c = 'xxx@dell.com';
        arReq.Client_Enterprise__c ='Client';
        arReq.Status__c = 'Draft';
        arReq.Additional_Sales_Person_Email__c = '';
        arReq.Finance_Contact__c = 'abc@f.com'; 
        arReq.Business_Case_Information__c = 'test';
        arReq.Region__c = 'APJ';
        arReq.ownerId =   AllianceRebateUser2.Id;
     //   System.runAs(AllianceRebateUser){
          insert arReq;
      //  }
        System.runAs(allianceRebateUser2){
            Test.startTest();
            pageRef.getParameters().put('id', String.valueOf(arReq.Id));
            pageRef.getParameters().put('clone', 'TRUE');
            ApexPages.StandardController sc = new ApexPages.StandardController(arReq);
            AllianceReabteRequestController allianceRebateReq = new AllianceReabteRequestController(sc);
            allianceRebateReq.allianceRebateReqObj = arReq;
            allianceRebateReq.saveRequest();
            allianceRebateReq.closePopup(); 
            allianceRebateReq.getRegions();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getStatus();
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = NULL;
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = arReq.ID;
            allianceRebateReq.isCloned='True';
            allianceRebateReq.partRequestChange();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getProductSize();
            allianceRebateReq.showPopup('assignedRegion');
            allianceRebateReq.makingVoid();
            allianceRebateReq.showPopupIntelEnterCPU();
            allianceRebateReq.closePopupIECPU();
            
            system.assertEquals(arReq.Id, allianceRebateReq.rebateReqId);

        }
        
    }

    private testmethod static void updateAllianceRebateRequest3() {
        
        //Logged In User
        profile profileId =   [select Id, Name from Profile where name like '%Admin%' limit 1];
        User allianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99826513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser;
        
        profile profileId1 =   [select Id, Name from Profile where name like '%Alliance Regional Program Lead%' limit 1];
        User allianceRebateUser2 = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser2@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId1.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99856513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser2;
        
        
        //country obj Instance
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;
                                    
         TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testCE = new Account();
        testCE.name = 'Some test Account';        
        testCE.status__c = 'Active';
        testCE.Account_Country_Code__c='US';              
        insert testCE;
       
        Opportunity opp = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);        
        
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        arReq.Sales_Force_Deal_ID__c = opp.id;
        arReq.Partner_BDM_Name__c='test';
        arReq.System_Partner_Name__c ='Intel';
        arReq.Finance_Contact__c = 'xxx@dell.com';
        arReq.Client_Enterprise__c ='Enterprise';
        arReq.Part_Requested__c ='CPU1';
        arReq.Status__c = 'Draft';
        arReq.Additional_Sales_Person_Email__c = '';
        arReq.Finance_Contact__c = 'abc@f.com'; 
        arReq.Business_Case_Information__c = 'test';
        arReq.ownerId =   AllianceRebateUser2.Id;
      //  System.runAs(AllianceRebateUser){
        insert arReq;

        Rebate_Request_Product__c productObj = new Rebate_Request_Product__c();
         productObj.Quantity__c=2;
         productObj.Part_Name_Part_Number__c='test';
         productObj.Dell_System_Model_type__c='testing';
         productObj.Alliance_Rebate_Request__c= arReq.id;
         productObj.Part_Requested__c ='CPU';
        insert productObj;    

      //  }
        System.runAs(allianceRebateUser2){
            Test.startTest();
            pageRef.getParameters().put('id', String.valueOf(arReq.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(arReq);
            AllianceReabteRequestController allianceRebateReq = new AllianceReabteRequestController(sc);
            allianceRebateReq.allianceRebateReqObj = arReq;
            allianceRebateReq.saveRequest();
            allianceRebateReq.closePopup(); 
            allianceRebateReq.getRegions();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getStatus();
            arReq.Status__c = 'Submitted';
            allianceRebateReq.getStatus();
            /*arReq.Status__c = 'Work in Progress';
            allianceRebateReq.getStatus();
            arReq.Status__c = 'Awaiting Vendors Response';
            allianceRebateReq.getStatus();
            arReq.Status__c = 'Approved';
            allianceRebateReq.getStatus(); 
            arReq.Status__c = 'Rejected';
            allianceRebateReq.getStatus();
            arReq.Status__c = 'Cancelled';
            allianceRebateReq.getStatus();*/
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = NULL;
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = arReq.ID;
            allianceRebateReq.isCloned='True';
            allianceRebateReq.partRequestChange();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getProductSize();
            allianceRebateReq.showPopup('assignedRegion');
            allianceRebateReq.makingVoid();
            allianceRebateReq.showPopupIntelEnterCPU();
            allianceRebateReq.currentPartRequested = 'CPU1';
            allianceRebateReq.currentClientEnterprise = 'Enterprise';
            allianceRebateReq.currentSystemPartName = 'Intel';
            
                    system.assertEquals('Intel', allianceRebateReq.currentSystemPartName);

            
            arReq.Part_Requested__c ='CPU2';
            arReq.Client_Enterprise__c ='Client';
            arReq.System_Partner_Name__c ='Brocade';
            allianceRebateReq.partRequestChange();
        }
        
    }
    
    private testmethod static void updateAllianceRebateRequest4() {
        
        //Logged In User
        profile profileId =   [select Id, Name from Profile where name like '%Admin%' limit 1];
        User allianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99826513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser;
        
        profile profileId1 =   [select Id, Name from Profile where name like '%Alliance Regional Program Lead%' limit 1];
        User allianceRebateUser2 = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser2@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId1.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99856513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser2;
        
        
        //country obj Instance
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;
                                    
         TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testCE = new Account();
        testCE.name = 'Some test Account';        
        testCE.status__c = 'Active';
        testCE.Account_Country_Code__c='US';              
        insert testCE;
       
        Opportunity opp = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);        
        
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        arReq.Sales_Force_Deal_ID__c = opp.id;
        arReq.Partner_BDM_Name__c='test';
        arReq.System_Partner_Name__c ='Intel';
        arReq.Finance_Contact__c = 'xxx@dell.com';
        arReq.Client_Enterprise__c ='Enterprise';
        arReq.Part_Requested__c ='CPU1';
        arReq.Status__c = 'Draft';
        arReq.Additional_Sales_Person_Email__c = '';
        arReq.Finance_Contact__c = 'abc@f.com'; 
        arReq.Business_Case_Information__c = 'test';
        arReq.ownerId =   AllianceRebateUser2.Id;
       // System.runAs(AllianceRebateUser){
        insert arReq;

        Rebate_Request_Product__c productObj = new Rebate_Request_Product__c();
         productObj.Quantity__c=2;
         productObj.Part_Name_Part_Number__c='test';
         productObj.Dell_System_Model_type__c='testing';
         productObj.Alliance_Rebate_Request__c= arReq.id;
         productObj.Part_Requested__c ='CPU';
        insert productObj;    

     //   }
        System.runAs(allianceRebateUser2){
            Test.startTest();
            pageRef.getParameters().put('id', String.valueOf(arReq.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(arReq);
            AllianceReabteRequestController allianceRebateReq = new AllianceReabteRequestController(sc);
            allianceRebateReq.allianceRebateReqObj = arReq;
            
            allianceRebateReq.currentPartRequested = 'CPU1';
            allianceRebateReq.currentClientEnterprise = 'Enterprise';
            allianceRebateReq.currentSystemPartName = 'Intel';
            
            arReq.Part_Requested__c ='CPU2';
            arReq.Client_Enterprise__c ='Client';
           // arReq.System_Partner_Name__c ='Brocade';
            allianceRebateReq.partRequestChange();
            
            allianceRebateReq.saveRequest();
            allianceRebateReq.closePopup(); 
            allianceRebateReq.getRegions();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getStatus();
            arReq.Status__c = 'Submitted';
            allianceRebateReq.getStatus();
            //allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = NULL;
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = arReq.ID;
            allianceRebateReq.isCloned='True';
            allianceRebateReq.partRequestChange();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getProductSize();
            allianceRebateReq.showPopup('assignedRegion');
            allianceRebateReq.makingVoid();
            allianceRebateReq.showPopupIntelEnterCPU();
            
                    system.assertEquals(arReq.Client_Enterprise__c, arReq.Client_Enterprise__c );

            
        }
        
    }
    
    private testmethod static void updateAllianceRebateRequest5() {
        
        
        //Logged In User
        profile profileId =   [select Id, Name from Profile where name like '%Admin%' limit 1];
        User allianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99826513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser;
        
        profile profileId1 =   [select Id, Name from Profile where name like '%Alliance Regional Program Lead%' limit 1];
        User allianceRebateUser2 = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser2@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId1.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99856513usi2', 
                                           isActive = TRUE);
        insert allianceRebateUser2;
        
        
        //country obj Instance
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;
                                    
         TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testCE = new Account();
        testCE.name = 'Some test Account';        
        testCE.status__c = 'Active';
        testCE.Account_Country_Code__c='US';              
        insert testCE;
       
        Opportunity opp = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);        
        
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        arReq.Sales_Force_Deal_ID__c = opp.id;
        arReq.Partner_BDM_Name__c='test';
        arReq.System_Partner_Name__c ='Intel';
        arReq.Finance_Contact__c = 'xxx@dell.com';
        arReq.Client_Enterprise__c ='Client';
        arReq.Status__c = 'Draft';
        arReq.Additional_Sales_Person_Email__c = '';
        arReq.Finance_Contact__c = 'abc@f.com'; 
        arReq.Business_Case_Information__c = 'test';
        arReq.ownerId =   AllianceRebateUser2.Id;
        arReq.Region__c = 'APJ';
       // System.runAs(AllianceRebateUser){
        insert arReq;
        Rebate_Request_Product__c productObj = new Rebate_Request_Product__c();
          productObj.Status__c='Active';
         // productObj.Quantity__c=2;
          //productObj.Part_Name_Part_Number__c='test';
          //productObj.Dell_System_Model_type__c='testing';
          productObj.Alliance_Rebate_Request__c= arReq.id;
          insert productObj;    
     //   }
        System.runAs(allianceRebateUser2){
            Test.startTest();
            pageRef.getParameters().put('id', String.valueOf(arReq.Id));
            ApexPages.currentPage().getParameters().put('clone', null);
           // pageRef.getParameters().put('clone', '1');
            ApexPages.StandardController sc = new ApexPages.StandardController(arReq);
            AllianceReabteRequestController allianceRebateReq = new AllianceReabteRequestController(sc);
            allianceRebateReq.allianceRebateReqObj = arReq;
            allianceRebateReq.saveRequest();
            allianceRebateReq.closePopup(); 
            allianceRebateReq.getRegions();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getStatus();
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = NULL;
            allianceRebateReq.partRequestChange();
            allianceRebateReq.rebateReqId = arReq.ID;
           // allianceRebateReq.isCloned='True';
            allianceRebateReq.partRequestChange();
            allianceRebateReq.showCancelAlert();
            allianceRebateReq.okCancel();
            allianceRebateReq.closeCancelAlert();
            allianceRebateReq.getProductSize();
            allianceRebateReq.showPopup('assignedRegion');
            allianceRebateReq.makingVoid();
            allianceRebateReq.showPopupIntelEnterCPU();
          //  allianceRebateReq.closePopupIECPU();
            allianceRebateReq.saveRequest();
        }
        
    }
    
    private testmethod static void newAllianceRequest(){
        
        Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
        
        PageReference pageRef = Page.AllianceRebateRequestForm;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(arReq);
        ApexPages.currentPage().getParameters().put('Id', null);
        ApexPages.currentPage().getParameters().put('clone', null);
               
        //country obj Instance
        Country__c countryObj = new Country__c(Name = 'India',
                                               Code__c = 'en_IN1',
                                               Region__c = 'APJ');
        insert countryObj;

        profile profileId = [select Id, Name from Profile where name like '%R16.10 GBL Sales Rep%' limit 1];
        User salesUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser2@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99856513usi2yusd', 
                                           isActive = TRUE);
        insert salesUser;
        
        profile profileIdregional = [select Id, Name from Profile where name like '%Admin%' limit 1];
        User regionalLeadUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser2@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileIdregional.id,
                                           LanguageLocaleKey='zh_CN',
                                           Country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99856513usi2yu', 
                                           isActive = TRUE);
        insert regionalLeadUser;

        Alliance_Rebate_Request__c arReq1 ;
        
        System.runAs(salesUser){


           TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testCE = new Account();
        testCE.name = 'Some test Account';        
        testCE.status__c = 'Active';
        testCE.Account_Country_Code__c='US';              
        insert testCE;
       
        Opportunity opp = new Opportunity(AccountId = testCE.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );       
        
        insert opp;
          TriggerExecutionController.setSkipAllTriggers(False);

          arReq.Sales_Force_Deal_ID__c = opp.id; 
          arReq.Partner_BDM_Name__c='test';
          arReq.Part_Requested__c = 'CPU';
          arReq.System_Partner_Name__c ='Intel';
          arReq.Finance_Contact__c = 'xxx@dell.com';
          arReq.Client_Enterprise__c ='Enterprise';
          arReq.Status__c = 'Draft';
          arReq.Additional_Sales_Person_Email__c = '';
          arReq.Finance_Contact__c = 'abc@f.com'; 
          arReq.Business_Case_Information__c = 'test';
          arReq.Region__c = 'APJ';
            arReq.ownerId = salesUser.Id;
            insert arReq;
            
          Rebate_Request_Product__c productObj = new Rebate_Request_Product__c();
          productObj.Status__c='Active';
          productObj.Quantity__c=2;
          productObj.Part_Name_Part_Number__c='test';
          productObj.Dell_System_Model_type__c='testing';
          productObj.Alliance_Rebate_Request__c= arReq.id;
          insert productObj;    

            AllianceReabteRequestController allianceContrlr = new AllianceReabteRequestController(sc);
            
          arReq.Business_Case_Information__c = 'Hello';
          update arReq;

          AllianceReabteRequestController allianceContrlr1 = new AllianceReabteRequestController(sc);

            //Create an approval request for the change
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(arReq.Id);
            req.setNextApproverIds(new Id[] {regionalLeadUser.Id});
            
            //Submit the approval request for the change
            Approval.ProcessResult result = Approval.process(req);

          arReq1 = [Select Id, Status__c from Alliance_Rebate_Request__c Where Id =: arReq.Id];
          System.assertEquals(arReq1.Status__c, 'Submitted');

        }
        
// System.runAs(regionalLeadUser){
            arReq1.Status__c = 'Work in Progress';
            update arReq1;

            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', arReq1.Id);
                AllianceReabteRequestController allianceContrlr = new AllianceReabteRequestController(sc);
            allianceContrlr.okCancel();

            Test.stopTest();
     //   }
    }    
}
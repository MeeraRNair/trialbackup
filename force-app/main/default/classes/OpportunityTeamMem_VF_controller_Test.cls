/* Revision  Name            Date                 CR         Release No              Description
* 1.0       Jatin         12.06.2018             16018       FY-19-DCS-0802         Commented NET exam logic statements as part of NET003 story
*/


@isTest
private class  OpportunityTeamMem_VF_controller_Test{

    //Added custom settings to populate StageName values.
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
     
    static testMethod void  teammembers(){
       // TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c partnerReq = createPartnerRequest();

        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
       //Login Account
        Account testAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTId, 
                                            Partner_Type__c = 'Distributor (GCC)',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Registration__c = partnerReq.Id );        

        Insert testAccount1;
        
        // Distributor Reseller Account Team Member
        Profile distiResellerProfile = [select Id, Name from Profile where Name like '%GBL Sales Rep%' limit 1];
        User distiResellerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                Alias = 'MTU9', 
                                Email='MyTestUser12@dell.com', 
                                FirstName='MyTestUser12', 
                                LastName='MyTestUser12',  
                                ProfileId = distiResellerProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='970133', 
                                isActive = TRUE);
        Insert distiResellerUser;
    
        // Test Account Team Members
        AccountTeamMember testAccTeam = new AccountTeamMember(AccountId = testAccount1.id,
                                                                    UserId = distiResellerUser.Id,
                                                                    TeamMemberRole = 'Technical Sales Rep');
        
        Insert testAccTeam;

        //Login Account -- Contact
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount1.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        insert newCont;
        
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Enable_Partner_Admin__c = true,
                            Badge_Number__c='970233', 
                            isActive = TRUE,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Distributor_Reseller_Name__c = testAccount1.Id,  
                                                Justification_Statement__c = 'Statement1Statement1Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Distribution',
                                                Distributor_ID__c = 'Test Disti User' );        
        System.runAs(PartnerUser){
            TriggerExecutionController.setSkipAllTriggers(true);
            insert testOppty;
        }  
        List<OpportunityTeamMember> oppTeamMembList = new List<OpportunityTeamMember>();
        
        OpportunityTeamMember optm = new OpportunityTeamMember();
        optm.TeamMemberRole='Reseller Contact';           
        optm.OpportunityId=testOppty.id ;
        optm.userId= partnerUser.id;
        oppTeamMembList.add(optm);
        insert optm;
        
        OpportunityTeamMember optm1 = new OpportunityTeamMember();
        optm1.TeamMemberRole='Technical Sales Rep';           
        optm1.OpportunityId=testOppty.id ;
        optm1.userId= distiResellerUser.id;
        oppTeamMembList.add(optm1);
        
        /*OpportunityTeamMember optm2 = new OpportunityTeamMember();
        optm2.TeamMemberRole='Technical Sales Rep';           
        optm2.OpportunityId=testOppty.id ;
        optm2.userId= gblSalesRepUser.id;
        oppTeamMembList.add(optm2);*/
    
        Insert oppTeamMembList;
                
        ApexPages.currentPage().getParameters().put('id', testOppty.id);              
        ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
        OpportunityTeamMem_VF_controller otvc = new OpportunityTeamMem_VF_controller(sc);
        //OpportunityTeamMem_VF_controller.wrapperCls wrcon = new OpportunityTeamMem_VF_controller.wrapperCls();
    }
    
    static testMethod void  resellerTeamMembers(){
      //  TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c partnerReq = createPartnerRequest();

        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Test.startTest();
       //Login Account
        Account testAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTId, 
                                            Partner_Type__c = 'Distributor (GCC)',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Registration__c = partnerReq.Id );        

        Insert testAccount1;
        
        // Distributor Reseller Account Team Member
        Profile distiResellerProfile = [select Id, Name from Profile where Name like '%GBL Sales Rep%' limit 1];
        User distiResellerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                Alias = 'MTU9', 
                                Email='MyTestUser12@dell.com', 
                                FirstName='MyTestUser12', 
                                LastName='MyTestUser12',  
                                ProfileId = distiResellerProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='1203434', 
                                isActive = TRUE);
        Insert distiResellerUser;

        // Test Account Team Members
        AccountTeamMember testAccTeam = new AccountTeamMember(AccountId = testAccount1.id,
                                                                    UserId = distiResellerUser.Id,
                                                                    TeamMemberRole = 'Technical Sales Rep');
        
        Insert testAccTeam;

        //Login Account -- Contact
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount1.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        insert newCont;
        
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Enable_Partner_Admin__c = true,
                            Badge_Number__c='970433', 
                            isActive = TRUE,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                //AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Distributor_Reseller_Name__c = testAccount1.Id,  
                                                Justification_Statement__c = 'Statement1Statement1Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Distribution',
                                                Distributor_ID__c = 'Test Disti User' );        
        System.runAs(PartnerUser){
            TriggerExecutionController.setSkipAllTriggers(true);
            insert testOppty;
        }  
        List<OpportunityTeamMember> oppTeamMembList = new List<OpportunityTeamMember>();
        
        OpportunityTeamMember optm = new OpportunityTeamMember();
        optm.TeamMemberRole='Reseller Contact';           
        optm.OpportunityId=testOppty.id ;
        optm.userId= partnerUser.id;
        oppTeamMembList.add(optm);
        insert optm;
        
        OpportunityTeamMember optm1 = new OpportunityTeamMember();
        optm1.TeamMemberRole='Technical Sales Rep';           
        optm1.OpportunityId=testOppty.id ;
        optm1.userId= distiResellerUser.id;
        oppTeamMembList.add(optm1);
        
        /*OpportunityTeamMember optm2 = new OpportunityTeamMember();
        optm2.TeamMemberRole='Technical Sales Rep';           
        optm2.OpportunityId=testOppty.id ;
        optm2.userId= gblSalesRepUser.id;
        oppTeamMembList.add(optm2);*/
    
        Insert oppTeamMembList;
        Test.stopTest();
        ApexPages.currentPage().getParameters().put('id', testOppty.id);              
        ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
        OpportunityTeamMem_VF_controller otvc = new OpportunityTeamMem_VF_controller(sc);
        //OpportunityTeamMem_VF_controller.wrapperCls wrcon = new OpportunityTeamMem_VF_controller.wrapperCls();
    }
    
    static testMethod void  distiTeamMembers(){
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c partnerReq = createPartnerRequest();

        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
       //Login Account
        Account testAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTId, 
                                            Partner_Type__c = 'Distributor (GCC)',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Registration__c = partnerReq.Id );        

        Insert testAccount1;
        
        // Distributor Reseller Account Team Member
        Profile distiResellerProfile = [select Id, Name from Profile where Name like '%GBL Sales Rep%' limit 1];
        User distiResellerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                Alias = 'MTU9', 
                                Email='MyTestUser12@dell.com', 
                                FirstName='MyTestUser12', 
                                LastName='MyTestUser12',  
                                ProfileId = distiResellerProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='970533', 
                                isActive = TRUE);
        Insert distiResellerUser;

        // Test Account Team Members
        AccountTeamMember testAccTeam = new AccountTeamMember(AccountId = testAccount1.id,
                                                                    UserId = distiResellerUser.Id,
                                                                    TeamMemberRole = 'Technical Sales Rep');
        
        Insert testAccTeam;

        //Login Account -- Contact
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount1.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        insert newCont;
        
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Enable_Partner_Admin__c = true,
                            Badge_Number__c='970633', 
                            isActive = TRUE,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                //AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                //Distributor_Reseller_Name__c = testAccount1.Id,  
                                                Justification_Statement__c = 'Statement1Statement1Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Distribution',
                                                Distributor_ID__c = 'Test Disti User' );        
        System.runAs(PartnerUser){
            TriggerExecutionController.setSkipAllTriggers(true);
            insert testOppty;
        }  
        List<OpportunityTeamMember> oppTeamMembList = new List<OpportunityTeamMember>();
        
        OpportunityTeamMember optm = new OpportunityTeamMember();
        optm.TeamMemberRole='Reseller Contact';           
        optm.OpportunityId=testOppty.id ;
        optm.userId= partnerUser.id;
        oppTeamMembList.add(optm);
        insert optm;
        
        OpportunityTeamMember optm1 = new OpportunityTeamMember();
        optm1.TeamMemberRole='Technical Sales Rep';           
        optm1.OpportunityId=testOppty.id ;
        optm1.userId= distiResellerUser.id;
        oppTeamMembList.add(optm1);
        
        /*OpportunityTeamMember optm2 = new OpportunityTeamMember();
        optm2.TeamMemberRole='Technical Sales Rep';           
        optm2.OpportunityId=testOppty.id ;
        optm2.userId= gblSalesRepUser.id;
        oppTeamMembList.add(optm2);*/
    
        Insert oppTeamMembList;
                
        ApexPages.currentPage().getParameters().put('id', testOppty.id);              
        ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
        OpportunityTeamMem_VF_controller otvc = new OpportunityTeamMem_VF_controller(sc);
        //OpportunityTeamMem_VF_controller.wrapperCls wrcon = new OpportunityTeamMem_VF_controller.wrapperCls();
    }
    
    /*static testMethod void  nondistiTeamMembers(){
       // TriggerExecutionController.setSkipOpportunityTriggers(true);
       TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c partnerReq = createPartnerRequest();

        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
       //Login Account
        Account testAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTId, 
                                            Partner_Type__c = 'Commercial General',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Registration__c = partnerReq.Id );        

        Insert testAccount1;
        
        // Distributor Reseller Account Team Member
        Profile distiResellerProfile = [select Id, Name from Profile where Name like '%GBL Sales Rep%' limit 1];
        User distiResellerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                Alias = 'MTU9', 
                                Email='MyTestUser12@dell.com', 
                                FirstName='MyTestUser12', 
                                LastName='MyTestUser12',  
                                ProfileId = distiResellerProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='970933', 
                                isActive = TRUE);
        Insert distiResellerUser;

        // Test Account Team Members
        //AccountTeamMember testAccTeam = new AccountTeamMember(AccountId = testAccount1.id,
                                                                    UserId = distiResellerUser.Id,
                                                                    TeamMemberRole = 'Technical Sales Rep');
        
        Insert testAccTeam;

        //Login Account -- Contact
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount1.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        insert newCont;
        
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Enable_Partner_Admin__c = true,
                            Badge_Number__c='970834', 
                            isActive = TRUE,
                            ContactId = newCont.Id);
        insert partnerUser;
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                //AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                //Distributor_Reseller_Name__c = testAccount1.Id,  
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Distribution',
                                                Distributor_ID__c = 'Test Disti User' );        
        System.runAs(PartnerUser){
            TriggerExecutionController.setSkipAllTriggers(true);
            insert testOppty;
        }  
        List<OpportunityTeamMember> oppTeamMembList = new List<OpportunityTeamMember>();
        
        OpportunityTeamMember optm = new OpportunityTeamMember();
        optm.TeamMemberRole='Reseller Contact';           
        optm.OpportunityId=testOppty.id ;
        optm.userId= partnerUser.id;
        oppTeamMembList.add(optm);
        insert optm;
        
        OpportunityTeamMember optm1 = new OpportunityTeamMember();
        optm1.TeamMemberRole='Technical Sales Rep';           
        optm1.OpportunityId=testOppty.id ;
        optm1.userId= distiResellerUser.id;
        oppTeamMembList.add(optm1);
        
        /*OpportunityTeamMember optm2 = new OpportunityTeamMember();
        optm2.TeamMemberRole='Technical Sales Rep';           
        optm2.OpportunityId=testOppty.id ;
        optm2.userId= gblSalesRepUser.id;
        oppTeamMembList.add(optm2);*/
    
       /* Insert oppTeamMembList;
                
        ApexPages.currentPage().getParameters().put('id', testOppty.id);              
        ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
        OpportunityTeamMem_VF_controller otvc = new OpportunityTeamMem_VF_controller(sc);
        OpportunityTeamMem_VF_controller.wrapperCls wrcon = new OpportunityTeamMem_VF_controller.wrapperCls();
    }*/

    static Partner_Request__c createPartnerRequest(){
        //create Account
        Account testAccount = new Account(
        name='Test 1',
        Account_Country_Code__c = 'AI',
        Account_Country__c = 'ANGUILIA',            
        Account_ID__c =''+System.currentTimeMillis()
        );
        insert testAccount;

        //Create country
        Country__c testCountry = new Country__c(
        Name = 'TestCountry',
        Code__c = 'TY',
        User_Currency_Iso_Code__c = 'INR',
        Region__c = 'APJ');
        insert testCountry;
        
        //Create User
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        User userRecord = new User(
        Username='testUser'+System.currentTimeMillis()+'@test.com',
        Alias = 'test', 
        Email='test@dell.com', 
        FirstName='Tfirst', 
        LastName='TLast',
        ProfileId = userProfile.Id, 
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', 
        EmailEncodingKey='UTF-8', 
        TimeZoneSidKey='America/Los_Angeles',
        Badge_Number__c='TEST12345'
        );
        insert userRecord;

        //Create Partner Request
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = testAccount.id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
        'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        //request.Contact__c=contact.id;
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.Org_State__c = 'state';
        request.Org_Postal_Code__c = 'postalcode';      
        request.Address_Line_1__c = 'Address 1';
        request.Address_Line_2__c = 'Address 2';
        request.Address_Line_3__c = 'Address 3';
        request.City__c = 'city';
        request.State__c = 'state';
        request.Postal_Code__c = 'postalcode';
        request.Last_Name__c = 'Test Last Name';
        request.Country__c = testCountry.id;
        request.OwnerId = userRecord.Id;
        insert request;

        return request;
    }
}
/* ---------------------------------------------------------
* Revision  Name    Date        Release Description
* 1.0                                   Creation
* 2.0       MenMee  28.12.2010  12.1    CR5472
* 2.1       MenMee  21.02.2011  12.1    Duplicate GBL PRM Operations Profile, so rename GBL PRM Operations Service to GBL PRM Operations
* 3.0       Jessie  28.10.2011  12.10   When Partner Account's Owner 'contact changes account, deletion of existing OTM from all the opportunity should exclude Support Request's Sys Eng
* 4.0       Meghana 20.12.2013  15.03   OMGO CR 8973 - Remove use of field Verifiable_Outcome__c in Test Methods
* 5.0       Anamika         19.05.2015  S-02    CR11490: SAR 11644 
* 6.0       Emily   08.01.2019  FY20-0202   CR 16970 - Remove virtualization__c

************************************************************/

@IsTest
    private class OpportunityPartnerAccountChangeCtrlTest{
    
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
        
        public static Id contactNewPA;
        public static contact contactObject=new contact();   
        public static  List<Account> partnerAccounts = new List<Account>();
        public static  List<Account> updateList = new List<Account>();
        public static  List<Contact> partnerContactList = new List<Contact>();  //Rev 2.0
        public static  List<User> userList = new List<User>();                  //Rev 2.0
        public static  List<AccountTeamMember> atmList = new List<AccountTeamMember>();//Rev 2.0
        public static  List<AccountShare> atmasList = new List<AccountShare>(); //Rev 2.0
        public static Account endUserAccount;        
        public static Contact partnercontact;
        public static User userObject;
        public static User gblPRMUserObject1;          
        static Date dCloseDate= system.Today()+1;
        static Date dealCreatedDate= system.Today();
        
        public static testmethod void testOpportunityPartnerAccountChange(){

            
            //RecordType opptyrectype=[Select Name,Id From RecordType where Name='Standard Opportunity' Limit 1];
            Opportunity opportunityObject;
            List<Opportunity> opportunityList=new List<Opportunity>();
            String partnerAccountId1;
            String partnerAccountId2;

            
            Profile p = [select id from profile where name=: system.label.SAR11644_Profile_name]; //Rev 2.1    //5.0
            UserRole userRoleObject=[Select  PortalAccountId,Name,Id
                                    From UserRole  where  
                                    name like '%WW_Exec'
                                    Limit 1];
                                    
                
                gblPRMUserObject1=new User(
                    Username='testuserGBLPRM201'+'@dell.com',
                    Alias = 'tGBLPR21', 
                    Email='testuserGBLPRM201'+'@dell.com', 
                    FirstName='TEST', 
                    LastName='AP Operations', 
                    ProfileId = p.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='testuserGBLPRM001',
                    userRoleId=userRoleObject.id
                    //ContactId = partnercontact.id 
                );
    
                insert gblPRMUserObject1;
    
            System.runAs(gblPRMUserObject1) {
               TriggerExecutionController.setSkipAllTriggers(true);
                GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
                
                for(integer i=0;i<3;i++){
                    Account accountObj=new Account(
                    name='TestAccount'+i,
                    Account_Country_Code__c = 'AI',
                    Account_Country__c = 'ANGUILIA'
                    ); 
                    partnerAccounts .add(accountObj);
                }

                insert partnerAccounts ;

                for(Account account:partnerAccounts ){
                    account.IsPartner = true;
                    account.Is_GTM_Partner__c=true;
                    account.RecordTypeId= System.Label.RecType_Partner_Account;
                    updateList.add(account);
                }
    
                update updateList; 

                
                //Test.startTest();
                
                string accId;
                //Rev 2.0 - Create 2 more partner contacts tied to updateList[3]
                for (integer i = 0; i< 3;i++) {
                    accId = ((i==0)? updateList.get(0).id : updateList.get(2).id);
                    partnercontact=new Contact(
                        AccountId=accId,
                        Email='John'+'@dell.com', 
                        FirstName = 'John', 
                        LastName = 'Doe',
                        Title='VP',
                        MailingStreet='123 Main',
                        MailingCity='Peoria',
                        MailingState='IL',
                        MailingPostalCode='33333',
                        Phone='3213213211',
                        MobilePhone='3213213211',
                        Fax='3213123211',                    
                        Decision_Making_Role__c='Power Sponsor/Decision Maker',  
                        Purchaser_Influence_over_Merged__c='Enterprise - Networking',
                        Status__c='Prospect',
                        Job_Function__c='Executives',  
                        Job_Function_Role__c='CEO'                   
                    );
                    partnerContactList.add(partnercontact);
                }
                insert partnerContactList;

                
                System.debug('###partnercontact'+partnercontactList);
                //System.debug('###partnercontact.AccountId'+partnercontact.AccountId);
               
                Profile partnerProfile=[select id,name from Profile where UserType= 'PowerPartner' LIMIT 1];
                //and  name like 'R11.7%' limit 1];
                                
                //Rev 2.0 - create 2 more partner users.
                for(integer i=0; i<3; i++) {                
                    userObject=new User(
                        Username='testuser001'+i+'@dell.com',
                        Alias = 'test', 
                        Email='testuser'+i+'@test.com', 
                        FirstName='John', 
                        LastName='Doe', 
                        ProfileId = partnerProfile.Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='test001'+i, 
                        ContactId = partnercontactList[i].id); 
                    userList.add(userObject);
                }         
        
                insert userList;
            }

            Test.startTest();
            
            User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
    
            System.runAs(adminusr) {  
                //Rev 2.0 - Assign team member to updateList[0] and updateList[1]               
                for (integer i=0; i<2; i++) {
                    AccountTeamMember atm = new AccountTeamMember();    
                    atm.AccountId = updateList[i].Id;
                    atm.UserId = userList[i+1].Id;
                    atm.TeamMemberRole = 'Test';
                    
                    atmList.add(atm);
                    
                    if (updateList[i].OwnerId != userList[i+1].Id) {
                        AccountShare atmas = new AccountShare();
                        atmas.AccountId = updateList[i].Id;
                        atmas.UserOrGroupId = userList[i+1].Id;
                        atmas.AccountAccessLevel = 'Edit';
                        atmas.OpportunityAccessLevel = 'Edit';
                        atmas.CaseAccessLevel = 'Edit';
                        atmasList.add(atmas);
                    }                   
                }
                insert atmList;
                insert atmasList;
                //Rev 2.0-end  
            }               

            
                System.runAs(gblPRMUserObject1) {
                    contactNewPA=updateList.get(1).id;  
                    
                    endUserAccount=new Account(
                        name='TestendUserAccountt',
                        Account_Country_Code__c = 'AI',
                        Account_Country__c = 'ANGUILIA'
                    ); 
    
                    insert endUserAccount;
                    //reduced to 50 (from 120) to to limitation of CR6089                  
                    for(integer i=0;i<2;i++){
                        opportunityObject=new Opportunity(
                            name='test opportunity',
                            stagename='Plan - 1%',
                            closedate=dCloseDate,
                            Solution_Type__c='IT Simplification',
                            Solution_Name__c='Systems Management',
                            Type='Deal/Bid-Direct',
                            Primary_Product_Delivery_Address_Region__c='NORTH AMERICA',
                            Primary_Product_Delivery_Address_Country__c='UNITED STATES',
                            //Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                            accountid=endUserAccount.id,How_many_shipments__c=1,
                            RecordTypeId=GlobalVariables.STANDARD_OPP_RECTYPE,
                            CurrencyIsoCode='USD',
                            OwnerId=userList[0].id,
                            OS_Type__c='Solaris',
                            //6.0 Virtualization__c='Microsoft Hyper-V',
                            Won_Lost_Comment__c='ggg',
                            Reason_Won_Lost__c='Incumbent',
                            Materials_Used_to_Help_Close_Deal__c='Case Study',
                            Customer_Willing_To__c='Complete a case Study',
                            Deal_Created_Date_Time__c=dealcreateddate,
                            Total_Expected_Dell_Revenue__c=1236,
                            Justification_Statement__c='ddd',
                            End_User_Account_Name__c=endUserAccount.name,
                            End_User_Account_Department__c='dasjdfhd',
                            Total_of_End_of_User_Employees__c='100-199',
                            End_User_Mailing_City__c='dsffddf',
                            End_User_Mailing_Country__c='dsffddf',
                            Deal_Registration_Status__c='Approved',
                            End_User_First_Name__c='dsffddf',
                            End_User_Last_Name__c='dsffddf',
                            End_User_Phone__c='2222',
                            Solution_Scope__c='Hardware and support only',
                            Competitor_Lost_To__c='ddd'
                        ) ;
        
                        opportunityList.add(opportunityObject);
                    }
                    //Test.startTest();
                      
                    Database.SaveResult[] opptyInsertresults=Database.insert(opportunityList, false); 
                    //insert opportunityList;          
                    
                    partnerContactList[0].accountid=contactNewPA;
        
                    update partnerContactList; 

                    //Test.startTest();
                    
                    PageReference  pr=new PageReference('/apex/ChangeOpportunityPartnerAccount?id='+partnerContactList[0].id);
                    Test.setCurrentPage(pr);
        
                    System.debug('DEBUG: Current Page URL: '+ ApexPages.currentPage().getUrl()); 
        
                    //String contactId15Char=partnercontact.id;
                    //contactId15Char=contactId15Char.substring(0,15);
        
                    OpportunityPartnerAccountChangeCtrl controller = new OpportunityPartnerAccountChangeCtrl(new ApexPages.StandardController(partnerContactList[0]));
        
                    String[] selectedArr=new String[]{'closed'};
                    controller.setSelectedOptions(selectedArr);

                    PageReference  pageRefExpected=new PageReference('/'+partnerContactList[0].id);
                    
                    //Test.startTest();
                    //PageReference  pageRefActual=controller.changePartnerAccount();
                    PageReference  pageRefActual=controller.updateContactobj();

                    String expected=pageRefExpected.getUrl();
                    //String actual=pageRefActual.getUrl();
        
                    //System.assertEquals(expected,actual);
        
                    /*oppty=[select partnerAccountId from opportunity where id=:opportunityObject.id];
                    for(Opportunity opportunityElt:[select partnerAccountId from opportunity where 
                                                accountId=:endUserAccount.id and OwnerId=:userObject.id]){
                                            
                         System.assertEquals(partnerAccounts.get(1).id,opportunityElt.partnerAccountId);                               
                    }
                    */
        
                    //PageReference backToContactURL=controller.backToContact();
                    List<SelectOption> optionsList=controller.getOptions();
                    String[] selectedOptionsArr=controller.getSelectedOptions();
                    controller.setSelectedOptions(selectedOptionsArr);
                    Boolean displayNoPartnerUserMessage=controller.getDisplayNoPartnerUserMessage();
                    controller.setDisplayNoPartnerUserMessage(displayNoPartnerUserMessage);
                    Boolean displayOptionScreen=controller.getDisplayOptionScreen();
                    controller.setDisplayOptionScreen(displayOptionScreen);
                    Boolean displayNoOpportunityMessage=controller.getDisplayNoOpportunityMessage();
                    controller.setDisplayNoOpportunityMessage(displayNoOpportunityMessage); 
                    PageReference pageRef=controller.updateContact(); 

                    
                    Test.stopTest();

                    Boolean displayNoOpenOpportunity=controller.getDisplayNoOpenOpportunity();
                    controller.setDisplayNoOpenOpportunity(false);
                    Boolean displayNoClosedOpportunity=controller.getDisplayNoClosedOpportunity();
                    controller.setDisplayNoOpportunityMessage(false); 
                    
                    controller.setDisplayNoClosedOpportunity(false);
                    
                    controller.removeOTMsExceptSysEngOfOpps();
                    controller.changePartnerAccount(); 

                    //Test.stopTest(); 
                    //Rev 2.0
                    List<OpportunityTeamMember> otm = [SELECT UserId FROM OpportunityTeamMember WHERE OpportunityId = :opportunityList[0].Id];

                    //System.debug('### OTM: '+otm.size() +' '+otm[0].UserId);
                    //System.assertEquals(1, otm.size());
                    //System.assertEquals(userList[2].Id, otm[0].UserId); 
                              
                    //Rev 2.0-end
               // }
            
            }       

            
        }
        
         public static testmethod void testAssignedSystemEngineer(){
        
            Profile partnerProfile=[select id,name from Profile where UserType= 'PowerPartner' Order by CreatedDate ASC LIMIT 1];
            
            endUserAccount=new Account(
                        name='TestendUserAccountt',
                        Account_Country_Code__c = 'AI',
                        Account_Country__c = 'ANGUILIA'
                    ); 
    
            insert endUserAccount;
            
            /*
            Account accountObj=new Account(
                    name='TestAccount',
                    Account_Country_Code__c = 'AI',
                    Account_Country__c = 'ANGUILIA');
                    
            insert accountObj;
    
            accountObj.IsPartner = true;
            accountObj.Is_GTM_Partner__c=true;
            accountObj.RecordTypeId= System.Label.RecType_Partner_Account;
                
            update accountObj;
                    
            Contact partnercontactObject=new Contact(
                        AccountId=accountObj.Id,
                        Email='John'+'@dell.com', 
                        FirstName = 'John', 
                        LastName = 'Doe',
                        Title='VP',
                        MailingStreet='123 Main',
                        MailingCity='Peoria',
                        MailingState='IL',
                        MailingPostalCode='33333',
                        Phone='3213213211',
                        MobilePhone='3213213211',
                        Fax='3213123211',                    
                        Decision_Making_Role__c='Power Sponsor/Decision Maker',  
                        Purchaser_Influence_over_Merged__c='Enterprise - Networking',
                        Status__c='Prospect',
                        Job_Function__c='Executives',  
                        Job_Function_Role__c='CEO'                   
                    );
            
            insert partnercontactObject;
                    
            User user=new User(
                        Username='testuser001@dell.com',
                        Alias = 'test', 
                        Email='testuser@test.com', 
                        FirstName='John', 
                        LastName='Doe', 
                        ProfileId = partnerProfile.Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='test001', 
                        ContactId = partnercontactObject.id); 
              
            insert user;
            
            Profile p = [select id from profile where name='GBL PRM Operations']; //Rev 2.1 
            UserRole userRoleObject=[Select  PortalAccountId,Name,Id
                                    From UserRole  where  
                                    name like '%WW_Exec'
                                    Limit 1];
                                    
                
            gblPRMUserObject1=new User(
                    Username='testuserGBLPRM201'+'@dell.com',
                    Alias = 'tGBLPR21', 
                    Email='testuserGBLPRM201'+'@dell.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId = p.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='testuserGBLPRM001',
                    userRoleId=userRoleObject.id
                    //ContactId = partnercontact.id 
                );
            
            insert gblPRMUserObject1;    
            */
            
            User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
                    
            Opportunity opportunityObject=new Opportunity(
                            name='test opportunity',
                            stagename='Plan - 1%',
                            closedate=dCloseDate,
                            Solution_Type__c='IT Simplification',
                            Solution_Name__c='Systems Management',
                            Type='Deal/Bid-Direct',
                            Primary_Product_Delivery_Address_Region__c='NORTH AMERICA',
                            Primary_Product_Delivery_Address_Country__c='UNITED STATES',
                            //Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                            accountid=endUserAccount.id,How_many_shipments__c=1,
                            RecordTypeId=GlobalVariables.STANDARD_OPP_RECTYPE,
                            CurrencyIsoCode='USD',
                            OwnerId=adminusr .id,
                            OS_Type__c='Solaris',
                            //6.0 Virtualization__c='Microsoft Hyper-V',
                            Won_Lost_Comment__c='ggg',
                            Reason_Won_Lost__c='Incumbent',
                            Materials_Used_to_Help_Close_Deal__c='Case Study',
                            Customer_Willing_To__c='Complete a case Study',
                            Deal_Created_Date_Time__c=dealcreateddate,
                            Total_Expected_Dell_Revenue__c=1236,
                            Justification_Statement__c='ddd',
                            End_User_Account_Name__c=endUserAccount.name,
                            End_User_Account_Department__c='dasjdfhd',
                            Total_of_End_of_User_Employees__c='100-199',
                            End_User_Mailing_City__c='dsffddf',
                            End_User_Mailing_Country__c='dsffddf',
                            Deal_Registration_Status__c='Approved',
                            End_User_First_Name__c='dsffddf',
                            End_User_Last_Name__c='dsffddf',
                            End_User_Phone__c='2222',
                            Solution_Scope__c='Hardware and support only',
                            Competitor_Lost_To__c='ddd'
                            ) ;
            
            
                             
            insert opportunityObject;                
                            
            //Rev 3.0 -- CR6513 -- start 
            
            Test.startTest();
                    
            String PPT_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Pre-Sales Product Technologist Support', 'Support_Request__c', true); 

            Support_Request__c request = 
                new Support_Request__c(RecordTypeId=PPT_RECORDTYPEID, Opportunity__c=opportunityObject.Id,  Customer_Contact_Name__c ='test customer', 
                Customer_Address__c ='test add', Customer_Email__c ='test@test.com', Security_Clearance__c ='Yes', 
                Customer_Phone_Number__c = '0123333445', Engagement_Type__c ='AIM POD Demo', Cost_Center_Number__c='0123344556', 
                Primary_Competitor__c='test competitor', Requested_By_Phone__c ='0128899887');
     
            insert request;
            
            Profile profile = [SELECT id from profile WHERE Name LIKE '%GBL Sales Rep' ORDER BY Name DESC NULLS LAST LIMIT 1];
            
            
             
            User testUser = new User(Username='testvaliduser001' +'@dell.com',
                            Alias = 'Test', 
                            Email='Test'+'@dell.com',            
                            LastName='Test',
                            Title='GCC Program Manager', 
                            ProfileId = profile.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test'+System.currentTimeMillis());
                            
            insert testUser;
            
             User testUser2 = new User(Username='testvaliduser002' +'@dell.com',
                                        Alias = 'Test2', 
                                        Email='Test2'+'@dell.com',            
                                        LastName='Test2',
                                        Title='GCC Program Manager', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test2'+System.currentTimeMillis());
                                        
            insert testUser2;
            
            
             
            request.Request_meets_requirement__c = 'Yes';

            request.Assigned_System_Engineer_1__c = testUser.Id;
            
            request.Assigned_System_Engineer_2__c = testUser2.Id;
            
            update request;
            
            Test.stopTest();
                        
            //Rev 3.0 - CR6513 - end 
   
            //Rev 3.0 - start--CR6513
            
            List<OpportunityTeamMember> otm = [SELECT UserId FROM OpportunityTeamMember WHERE OpportunityId = :opportunityObject.Id];
                    
            if (otm.size()==2)
            {                
                System.debug('##################################### OTM: '+otm.size() +' '+otm);
                System.debug('##################################### testUser: '+testUser.Id);
                System.debug('##################################### testUser2: '+testUser2.Id);
                System.debug('##################################### otm[0].UserId: '+otm.get(0).UserId);
                System.debug('##################################### otm[1].UserId: '+otm.get(1).UserId);
            }
            
            /*
            System.assertEquals(2, otm.size());
            System.assert( (otm.get(0).UserId==testUser.Id)?
                (otm.get(1).UserId==testUser2.Id):
                ((otm.get(0).UserId==testUser2.Id)&&(otm.get(1).UserId==testUser.Id))
                ); */
            //Rev 3.0 - end --CR6513
        
        }
        
        public static testmethod void testUpdateAssignedSystemEngineer(){
        
            Profile partnerProfile=[select id,name from Profile where UserType= 'PowerPartner' Order by CreatedDate ASC LIMIT 1];
            
            endUserAccount=new Account(
                        name='TestendUserAccountt',
                        Account_Country_Code__c = 'AI',
                        Account_Country__c = 'ANGUILIA'
                    ); 
    
            insert endUserAccount;
            
            /*
            Account accountObj=new Account(
                    name='TestAccount',
                    Account_Country_Code__c = 'AI',
                    Account_Country__c = 'ANGUILIA');
                    
            insert accountObj;
    
            accountObj.IsPartner = true;
            accountObj.Is_GTM_Partner__c=true;
            accountObj.RecordTypeId= System.Label.RecType_Partner_Account;
                
            update accountObj;
                    
            Contact partnercontactObject=new Contact(
                        AccountId=accountObj.Id,
                        Email='John'+'@dell.com', 
                        FirstName = 'John', 
                        LastName = 'Doe',
                        Title='VP',
                        MailingStreet='123 Main',
                        MailingCity='Peoria',
                        MailingState='IL',
                        MailingPostalCode='33333',
                        Phone='3213213211',
                        MobilePhone='3213213211',
                        Fax='3213123211',                    
                        Decision_Making_Role__c='Power Sponsor/Decision Maker',  
                        Purchaser_Influence_over_Merged__c='Enterprise - Networking',
                        Status__c='Prospect',
                        Job_Function__c='Executives',  
                        Job_Function_Role__c='CEO'                   
                    );
            
            insert partnercontactObject;
                    
            User user=new User(
                        Username='testuser001@dell.com',
                        Alias = 'test', 
                        Email='testuser@test.com', 
                        FirstName='John', 
                        LastName='Doe', 
                        ProfileId = partnerProfile.Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='test001', 
                        ContactId = partnercontactObject.id); 
              
            insert user;
            
            Profile p = [select id from profile where name='GBL PRM Operations']; //Rev 2.1 
            UserRole userRoleObject=[Select  PortalAccountId,Name,Id
                                    From UserRole  where  
                                    name like '%WW_Exec'
                                    Limit 1];
                                    
                
            gblPRMUserObject1=new User(
                    Username='testuserGBLPRM201'+'@dell.com',
                    Alias = 'tGBLPR21', 
                    Email='testuserGBLPRM201'+'@dell.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId = p.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='testuserGBLPRM001',
                    userRoleId=userRoleObject.id
                    //ContactId = partnercontact.id 
                );
            
            insert gblPRMUserObject1;    
            */
            
            User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
                    
            Opportunity opportunityObject=new Opportunity(
                            name='test opportunity',
                            stagename='Plan - 1%',
                            closedate=dCloseDate,
                            Solution_Type__c='IT Simplification',
                            Solution_Name__c='Systems Management',
                            Type='Deal/Bid-Direct',
                            Primary_Product_Delivery_Address_Region__c='NORTH AMERICA',
                            Primary_Product_Delivery_Address_Country__c='UNITED STATES',
                           // Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                            accountid=endUserAccount.id,How_many_shipments__c=1,
                            RecordTypeId=GlobalVariables.STANDARD_OPP_RECTYPE,
                            CurrencyIsoCode='USD',
                            OwnerId=adminusr .id,
                            OS_Type__c='Solaris',
                            //6.0 Virtualization__c='Microsoft Hyper-V',
                            Won_Lost_Comment__c='ggg',
                            Reason_Won_Lost__c='Incumbent',
                            Materials_Used_to_Help_Close_Deal__c='Case Study',
                            Customer_Willing_To__c='Complete a case Study',
                            Deal_Created_Date_Time__c=dealcreateddate,
                            Total_Expected_Dell_Revenue__c=1236,
                            Justification_Statement__c='ddd',
                            End_User_Account_Name__c=endUserAccount.name,
                            End_User_Account_Department__c='dasjdfhd',
                            Total_of_End_of_User_Employees__c='100-199',
                            End_User_Mailing_City__c='dsffddf',
                            End_User_Mailing_Country__c='dsffddf',
                            Deal_Registration_Status__c='Approved',
                            End_User_First_Name__c='dsffddf',
                            End_User_Last_Name__c='dsffddf',
                            End_User_Phone__c='2222',
                            Solution_Scope__c='Hardware and support only',
                            Competitor_Lost_To__c='ddd'
                            ) ;
            
            
                             
            insert opportunityObject;                
                            
            //Rev 3.0 -- CR6513 -- start 
            
            Test.startTest();
                    
            String PPT_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Pre-Sales Product Technologist Support', 'Support_Request__c', true); 

            Profile profile = [SELECT id from profile WHERE Name LIKE '%GBL Sales Rep' ORDER BY Name DESC NULLS LAST LIMIT 1];
            
            
             
            User testUser = new User(Username='testvaliduser001' +'@dell.com',
                            Alias = 'Test', 
                            Email='Test'+'@dell.com',            
                            LastName='Test',
                            Title='GCC Program Manager', 
                            ProfileId = profile.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test'+System.currentTimeMillis());
                            
            insert testUser;
            
             User testUser2 = new User(Username='testvaliduser002' +'@dell.com',
                                        Alias = 'Test2', 
                                        Email='Test2'+'@dell.com',            
                                        LastName='Test2',
                                        Title='GCC Program Manager', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test2'+System.currentTimeMillis());
                                        
            insert testUser2;
            
            Support_Request__c request = 
                new Support_Request__c(RecordTypeId=PPT_RECORDTYPEID, Opportunity__c=opportunityObject.Id,  Customer_Contact_Name__c ='test customer', 
                Customer_Address__c ='test add', Customer_Email__c ='test@test.com', Security_Clearance__c ='Yes', 
                Customer_Phone_Number__c = '0123333445', Engagement_Type__c ='AIM POD Demo', Cost_Center_Number__c='0123344556', 
                Primary_Competitor__c='test competitor', Requested_By_Phone__c ='0128899887', 
                Assigned_System_Engineer_1__c = testUser2.Id, Assigned_System_Engineer_2__c = testUser.Id);
     
            insert request;
             
            request.Request_meets_requirement__c = 'Yes';

            request.Assigned_System_Engineer_1__c = testUser.Id;
            
            request.Assigned_System_Engineer_2__c = testUser2.Id;
            
            update request;
            
            Test.stopTest();
            
            
            //Rev 3.0 - CR6513 - end 
   
            //Rev 3.0 - start--CR6513
            
            List<OpportunityTeamMember> otm = [SELECT UserId FROM OpportunityTeamMember WHERE OpportunityId = :opportunityObject.Id];
                    
            if (otm.size()==2)
            {
                System.debug('##################################### OTM: '+otm.size() +' '+otm);
                System.debug('##################################### testUser: '+testUser.Id);
                System.debug('##################################### testUser2: '+testUser2.Id);
                System.debug('##################################### otm[0].UserId: '+otm.get(0).UserId);
                System.debug('##################################### otm[1].UserId: '+otm.get(1).UserId);    
            }            
            
            /*
            System.assertEquals(2, otm.size());
            System.assert( (otm.get(0).UserId==testUser.Id)?
                (otm.get(1).UserId==testUser2.Id):
                ((otm.get(0).UserId==testUser2.Id)&&(otm.get(1).UserId==testUser.Id))
                ); */
            //Rev 3.0 - end --CR6513
        
        }
        

    }
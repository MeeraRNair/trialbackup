@IsTest
public class OpportunityTriggerHandlerBUTest {

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
    
    
    
    
    Static Opportunity oppnew = new Opportunity();
    
    //Test class for Monthly Sprint CRs related to opportunity object
    // CR 8548,8681
/*
    static testmethod void myTest()
    {
        TriggerExecutionController.setSkipAllTriggers(true); // 1.0
        // CR 8681
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity',true);
        Opportunity opp=new Opportunity (name='teset opp SR', Total_Expected_Dell_Revenue__c=5000,CloseDate=System.Today(),Engagement_Type__c='Public Tender',
            Solution_Type__c='Campus',Solution_Name__c='Wired Chassis Switches',Justification_Statement__c='test Justification_Statement__c',
            End_User_Account_Name__c='test End_User_Account_Name__c', End_User_Mailing_City__c='mailing city',End_User_Mailing_State_Province_Region__c='mailing state',
            End_User_Mailing_Country__c='INDIA',Save_End_Customer_to_my_list__c='Yes',End_User_First_Name__c='end fist name',End_User_Last_Name__c='end last name',
            End_User_Email__c='test@gmail.com',Is_the_Customer_Part_of_a_Larger_Group__c='Yes',StageName='Plan - 1%',Primary_Product_Delivery_Address_Region__c ='LATAM',
            Primary_Product_Delivery_Address_Country__c= 'INDIA');
        insert opp;
        TriggerExecutionController.setSkipAllTriggers(false); // 1.0
        
        TriggerExecutionController.setSkipAccountTriggers(true); // 1.0
        opp.closeDate =opp.closeDate.addDays(15);
        update opp;
    
        system.Test.startTest();
            opp.closeDate =opp.closeDate.addDays(12);
            update opp;
        system.Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false); // 1.0
    }
    
    static testmethod void myTest_1()
    {
        // CR 8548
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity',true);
        Opportunity opp=new Opportunity (name='teset opp SR', Total_Expected_Dell_Revenue__c=5000,CloseDate=System.Today(),Engagement_Type__c='Public Tender',
            Solution_Type__c='Campus',Solution_Name__c='Wired Chassis Switches',Justification_Statement__c='test Justification_Statement__c',
            End_User_Account_Name__c='test End_User_Account_Name__c', End_User_Mailing_City__c='mailing city',End_User_Mailing_State_Province_Region__c='mailing state',
            End_User_Mailing_Country__c='INDIA',Save_End_Customer_to_my_list__c='Yes',End_User_First_Name__c='end fist name',End_User_Last_Name__c='end last name',
            End_User_Email__c='test@gmail.com',Is_the_Customer_Part_of_a_Larger_Group__c='Yes',StageName='Plan - 1%',Primary_Product_Delivery_Address_Region__c ='LATAM',
            Primary_Product_Delivery_Address_Country__c= 'INDIA');
        insert opp;
     
        PageReference pageRef = Page.opportunityProjectTag;
        Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('id', opp.Id);
        ApexPages.StandardController std=new ApexPages.StandardController(opp);
        opptyProjectTagCtlr  oppObj=new opptyProjectTagCtlr ();
        oppObj.doSave();
        oppObj.doCancel();
    }*/
    
    static testmethod void myTest_2()
    {    
        TriggerExecutionController.setSkipAllTriggers(true);  
		String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerBU"},'; 
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 1;
        insert tec;
        Account acc = new Account();
        acc.Name = 'testAccount';
        acc.NPS_Qualified_Contacts__c = 1;
       // acc.OwnerId = portalAccountOwner1.Id;
        insert acc;
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.Email = 'test@test.com';
        con1.phone = '6739';
        con1.LastName = 'conLastName';
        con1.FirstName = 'conFirstName';
        con1.Status__c = 'Customer';
        con1.Email_Opt_In__c = 'yes';
        con1.Survey__c = 'yes';
        con1.Decision_Making_Role__c = 'Technical Buyer';
        //con.NPS_Criteria_Met__c = True; //v2.0
        
        insert con1;
       Profile PRMprofile = [select id from profile where name like '%PRM Operations%' Limit 1];
       User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = PRMprofile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;

        Account testAcc = new Account(name='testaccount');
        insert testAcc;
        
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAcc.Id,Phone='12345');
        insert con; 
        
        System.runas(testuser){
                      
        
        oppnew = new Opportunity(name='teset opp SR1',CloseDate=System.Today(),StageName = 'Plan - 1%',Primary_Product_Delivery_Address_Region__c ='LATAM',
        Primary_Product_Delivery_Address_Country__c= 'INDIA',Submitter_Profile__c = 'PRM', description = 'test opp',Services_Sales_Owner__c = testuser.id,
        source_id__c = 'testSI',Marketing_Created_Opportunity__c = false); //,Quest_Software_Contact__c= con.id          
        insert oppnew;        
        
        Services_Project__c testSP = new Services_Project__c(Project_Name__c = 'testSPrec',Opportunity__c = oppnew.id);
        insert testSP;
                   
        //Pricebook2 standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];// 1.0: Commented
        Id pbk1 = Test.getStandardPricebookId();
        
        Product2 prod = new product2(name='Prod1', Product_ID__c='test prod id1', dell_business_model__c= 'Smart Selection (Stocked);Custom BTO' ,productcode = 'test pd code1one');
        insert prod;
        
        PricebookEntry PBE=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prod.Id, UnitPrice=112.00, Isactive = true, 
                                              UseStandardPrice=false);
        //PricebookEntry PBE=new PricebookEntry(Pricebook2Id= standardPb.Id, Product2Id=prod.Id, UnitPrice=112.00, Isactive = true, 
                                              //UseStandardPrice=false);
        insert PBE;
                
        User testSysUser = [Select id,name from User where Profile.name like '%System administrator' AND Isactive=true LIMIT 1];
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        
        test.starttest();
        ProcessFlowTriggerController.isTest = true;
        oppnew.Submitter_Profile__c = 'PRM';
        oppnew.source_id__c = 'testSI';
        oppnew.Marketing_Created_Opportunity__c = true;
        oppnew.Lattice_Source_Id__c = 'testLSI';        
        oppnew.Lattice_PreLead_External_Id__c = 'testtext';
        update oppnew;   
        
        Oppt_Description_History__c ODH = new Oppt_Description_History__c(Opportunity__c=oppnew.Id,description__c='test desc');
        insert ODH;  
              
        SOM_Boomi_Log__c logRecord = new SOM_Boomi_Log__c(Opportunity_Owner__c = oppnew.OwnerId,
                Services_Sales_Owner__c = oppnew.Services_Sales_Owner__c);
        insert logrecord;         
        
        test.stoptest();         
              
       }
    }
    
    private static testmethod void unitTest3()
    {
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerBU"},'; 
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 1;
        insert tec;
        Account acc = new Account();
        acc.Name = 'testAccount';
        acc.NPS_Qualified_Contacts__c = 1;
       // acc.OwnerId = portalAccountOwner1.Id;
        insert acc;
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.Email = 'test@test.com';
        con1.phone = '6739';
        con1.LastName = 'conLastName';
        con1.FirstName = 'conFirstName';
        con1.Status__c = 'Customer';
        con1.Email_Opt_In__c = 'yes';
        con1.Survey__c = 'yes';
        con1.Decision_Making_Role__c = 'Technical Buyer';
        //con.NPS_Criteria_Met__c = True; //v2.0
        
        insert con1;
        Profile PRMprofile = [select id from profile where name like '%PRM Operations%' Limit 1];
       User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = PRMprofile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;

        Account testAcc = new Account(name='testaccount');
        insert testAcc;
        
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAcc.Id,Phone='12345');
        insert con; 
        
        //User testSysUser = [Select id,name from User where Profile.name like '%System administrator' AND Isactive=true LIMIT 1];
        
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User testSysUser = [SELECT id FROM User WHERE profileid = :AdminProfile.id AND isactive = true limit 1];
        System.runas(testuser)
        {
            
            oppnew = new Opportunity(name='teset opp SR1',CloseDate=System.Today(),StageName='Plan - 1%',Primary_Product_Delivery_Address_Region__c ='APJ',
            Primary_Product_Delivery_Address_Country__c= 'INDIA',Submitter_Profile__c = 'PRM', description = 'test opp',Services_Sales_Owner__c = testuser.id,
            source_id__c = 'testSI',Marketing_Created_Opportunity__c = false);  //,Quest_Software_Contact__c= con.id
            insert oppnew;        
            Services_Project__c testSP = new Services_Project__c(Project_Name__c = 'testSPrec',Opportunity__c = oppnew.id);
            insert testSP;
            
            
            //PriceBook2 standardPb = new PriceBook2(Name='Test PriceBook');
            //Pricebook2 standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1]; // 1.0: Commented
            Id pbk1 = Test.getStandardPricebookId();
            
            Product2 prod = new product2(name='Prod1', Product_ID__c='test prod id2',dell_business_model__c= 'Smart Selection (Stocked);Custom BTO' ,productcode = 'test pd code1one');
            insert prod;
            
            PricebookEntry PBE=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prod.Id, UnitPrice=112.00, Isactive = true, 
                                                  UseStandardPrice=false);
            //PricebookEntry PBE=new PricebookEntry(Pricebook2Id= standardPb.Id, Product2Id=prod.Id, UnitPrice=112.00, Isactive = true, 
                                                  //UseStandardPrice=false);
            insert PBE;
            
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem >();       
            for(integer i=0;i<10;i++){
              OpportunityLineItem oli = new OpportunityLineItem(PriceBookEntryId=pbe.Id, OpportunityId=oppnew.Id, Quantity=1, TotalPrice=99);
              oliList.add(oli);
            }
            
            insert oliList;
            TriggerExecutionController.setSkipAllTriggers(false);
            TriggerExecutionController.setSkipAccountTriggers(true);
            TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
            GlobalVariables.SKIP_OPP_LINEITEM_TRIGGERS = true;
            test.startTest();
            ProcessFlowTriggerController.isTest = true;
            
            Opportunity oppAfterInsert = [Select Services_Project_Count__c,ownerid,description,deal_registration_status__c,Services_Sales_Owner__c,source_id__c,Marketing_Created_Opportunity__c,Lattice_Source_Id__c,Lattice_PreLead_External_Id__c  from Opportunity where Id= :oppnew.Id];

            System.assertEquals(oppAfterInsert.Services_Project_Count__c, 1);

            oppAfterInsert.description  = 'test description';
            oppAfterInsert.deal_registration_status__c = 'Approved';
            oppAfterInsert.ownerid = testSysUser.id;
            oppAfterInsert.Services_Sales_Owner__c = testSysUser.id;
            oppAfterInsert.source_id__c = 'testSI';
            oppAfterInsert.Marketing_Created_Opportunity__c = true;
            oppAfterInsert.Lattice_Source_Id__c = 'testLSI';        
            oppAfterInsert.Lattice_PreLead_External_Id__c = 'testtext';
            TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
            update oppAfterInsert;
            TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
            test.stopTest();  
        }
    }
    private static testmethod void unitTest4() 
    {
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerBU"},'; 
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 1;
        insert tec;
        Account acc = new Account();
        acc.Name = 'testAccount';
        acc.NPS_Qualified_Contacts__c = 1;
       // acc.OwnerId = portalAccountOwner1.Id;
        insert acc;
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.Email = 'test@test.com';
        con1.phone = '6739';
        con1.LastName = 'conLastName';
        con1.FirstName = 'conFirstName';
        con1.Status__c = 'Customer';
        con1.Email_Opt_In__c = 'yes';
        con1.Survey__c = 'yes';
        con1.Decision_Making_Role__c = 'Technical Buyer';
        //con.NPS_Criteria_Met__c = True; //v2.0
        
        insert con1;
        Profile PRMprofile = [select id from profile where name like '%PRM Operations%' Order By CreatedDate Desc Limit 1];
       User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = PRMprofile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        
         insert testUser;
        //Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity',true);
        Id oppsubmittedRecordTypeId= IdLookupUtils.getRecordTypeId('Deal Registration-Submitted','Opportunity',true);
        Id channelOppRecordTypeId= IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity',true);
        Opportunity opp=new Opportunity (name='teset opp SR', Total_Expected_Dell_Revenue__c=5000,
                                         CloseDate=System.Today(),
                                         //Engagement_Type__c='Public Tender',
                                         Solution_Type__c='Campus',Solution_Name__c='Wired Chassis Switches',
                                         Justification_Statement__c='test Justification_Statement__c',
                                         End_User_Account_Name__c='test End_User_Account_Name__c', 
                                         End_User_Mailing_Street__c='mailing Street', End_User_Mailing_City__c='mailing city',
                                         End_User_Mailing_State_Province_Region__c='mailing state',
                                         End_User_Mailing_Country__c='INDIA',Save_End_Customer_to_my_list__c='No',
                                         End_User_First_Name__c='end fist name',End_User_Last_Name__c='end last name',
                                         End_User_Email__c='test@gmail.com',
                                         //Is_the_Customer_Part_of_a_Larger_Group__c='Yes',
                                         StageName='Plan - 1%',Primary_Product_Delivery_Address_Region__c ='APJ',
                                         //RecordtypeId = oppRecordTypeId,
                                         RecordtypeId = oppsubmittedRecordTypeId,
                                         Primary_Product_Delivery_Address_Country__c= 'INDIA');
        insert opp;
        system.Debug('---test opp:1111 ---'+opp);
        //Pricebook2 standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1]; // 1.0: Commented
        Id pbk1 = Test.getStandardPricebookId();
            
        Product2 prod = new product2(name='Prod1', Product_ID__c='test prod id3',Dell_Business_Model__c= 'Smart Selection (Stocked)' ,productcode = 'test pd code1one');
        insert prod;
        
        PricebookEntry PBE=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prod.Id, UnitPrice=112.00, Isactive = true, 
                                              UseStandardPrice=false);
        //PricebookEntry PBE=new PricebookEntry(Pricebook2Id= standardPb.Id, Product2Id=prod.Id, UnitPrice=112.00, Isactive = true, 
                                              //UseStandardPrice=false);
        insert PBE;
        
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();       
        for(integer i=0;i<2;i++){
          OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=opp.Id,TeamMemberRole = 'Sales Support',UserId=testUser.Id);
          oppTeamMemberList.add(otm);
        }
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=opp.Id,TeamMemberRole = 'Account Executive',UserId=testUser.Id);
        oppTeamMemberList.add(otm);
        insert otm;
        system.Debug('---test otm:2222 ---'+otm);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem >();       
        for(integer i=0;i<10;i++){
          OpportunityLineItem oli = new OpportunityLineItem(PriceBookEntryId=pbe.Id, OpportunityId=opp.Id, Quantity=1, TotalPrice=99, Dell_Business_Model__c = 'Smart Selection (Stocked)');
          oliList.add(oli);
        }
        insert oliList;
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        GlobalVariables.SKIP_OPP_LINEITEM_TRIGGERS = true;
         test.startTest();
         ProcessFlowTriggerController.isTest = true;
       
        //opp.deal_registration_status__c = 'Submitted';
       // opp.RecordtypeId = oppsubmittedRecordTypeId;
       // update opp;
        system.Debug('---test opp:2222 ---'+opp);
       
                opp.description  = 'test description';
                opp.deal_registration_status__c = 'Approved';
                opp.RecordtypeId = channelOppRecordTypeId;
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
                update opp;
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
                system.Debug('---test opp:3333 ---'+opp);
       test.stopTest(); 

    }
    /*static testmethod void myTest_3()
    {
        TriggerExecutionController.setSkipAccountTriggers(true);
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerBU"},'; 
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 1;
        insert tec;
        List<Opportunity> oppList = new List<Opportunity>();
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
        test.startTest();
        ProcessFlowTriggerController.isTest = true;
        system.debug('Record Type id--'+oppRecordTypeId);
        Opportunity opp=new Opportunity (name='teset opp SR', Total_Expected_Dell_Revenue__c=5000,CloseDate=System.Today(),Description='Test Desc',StageName='Plan - 1%',RecordtypeId = oppRecordTypeId);
        insert opp;
        oppList.add(opp);
        GlobalVariables.override_first_run = false;
        OpportunityUtilities.createOpportunityDescriptionHistory('');
       
        test.stopTest();
    }    */
       
   /*
    CR          Date            Created By      Description
    ---         -----------     -----------     ------------
    CR12116     21-Oct-2015     Krishnamoorthi  The below test method will cover the createSOMBoomiLogs method in OpportunityUtilities
    */
    public static testMethod void testcreateSOMBoomiLogs() {
        
		String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerBU"},'; 
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 1;
        insert tec;
        Map<Id, Opportunity> mapOldOpportunity = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapNewOpportunity = new Map<Id, Opportunity>();

        List<Profile> userProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];        
        User tempUser = new User(
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev',
            Alias = 'test', 
            Email='test109@dell.com', 
            FirstName='Tfirst A1', 
            LastName='TLast2',
            ProfileId = userProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+System.currentTimeMillis(),
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        insert tempUser;
        
        User tempUser2 = new User(
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev' +1,
            Alias = 'test1a', 
            Email='test19@dell.com', 
            FirstName='Tfirst A11', 
            LastName='TLast2q',
            ProfileId = userProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+System.currentTimeMillis()+1,
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        insert tempUser2;
        
        Account testAcc = new Account(name='testaccount');
        insert testAcc;
        
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAcc.Id,Phone='12345');
        insert con; 
        
        Opportunity testOpp = new Opportunity(Name='Test Opportunity', 
                                                AccountId=testAcc.Id,
                                                RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,   
                                                StageName='Discover - 10%',
                                                CloseDate = System.Today() + 30 );
       
        insert testOpp;
        mapOldOpportunity.put(testOpp.Id, testOpp);
        
        //Insert Services Project for the Opportunity
        Services_Project__c testSP = new Services_Project__c(Project_Name__c = 'testSP',Opportunity__c = testOpp.id);
        insert testSP;
                
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Opportunity testOpp2 = [SELECT Id, StageName, OwnerId, Services_Sales_Owner__c, Services_Project_Count__c, Deal_ID__c FROM Opportunity WHERE Id =: testOpp.Id];
        //Update the Opportunity Stage with  Lost, Cancelled - 0%
        testOpp2.StageName = 'Lost, Cancelled - 0%';
        testOpp2.Competitor_Lost_To__c = 'HCL';
        testOpp2.OwnerId = tempUser.Id;
        testOpp2.Services_Sales_Owner__c = tempUser2.Id;
        mapNewOpportunity.put(testOpp2.Id, testOpp2);
        //Call the createSOMBoomiLogs from OpportunityUtilities
        OpportunityUtilities.createSOMBoomiLogs(mapNewOpportunity.values(), mapOldOpportunity, mapNewOpportunity);
        Test.stopTest();
        
        //Assert the Opportunity Stage value populated in SOM Boomi Log object
        SOM_Boomi_Log__c SBM = [SELECT Opportunity_Stage__c FROM SOM_Boomi_Log__c WHERE Opportunity_Stage__c != null AND Deal_ID__c =: testOpp2.Deal_ID__c];
        System.assertEquals(SBM.Opportunity_Stage__c,testOpp2.StageName);
    }
}
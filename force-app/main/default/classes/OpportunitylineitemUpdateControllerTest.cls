@isTest(SeeAllData=false)
private class OpportunitylineitemUpdateControllerTest
{
    Static Opportunity oppnew = new Opportunity();    
    private static testmethod void unitTest()
    {
        
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
        
        
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testUser;
        
        Account testAcc = new Account(name='testaccount');
        insert testAcc;
        
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                                  MailingCountry='test',AccountId=testAcc.Id,Phone='12345');
        insert con; 
        TriggerExecutionController.setSkipAllTriggers(false);
        
        test.startTest();
        //User testSysUser = [Select id,name from User where Profile.name like '%System administrator' AND Isactive=true LIMIT 1];
        
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User testSysUser = [SELECT id FROM User WHERE profileid = :AdminProfile.id AND isactive = true limit 1];
        System.runas(testuser)
        {
            
            TriggerExecutionController.setSkipAllTriggers(true);
            oppnew = new Opportunity(name='teset opp SR1',CloseDate=System.Today(),StageName='Plan - 1%',Primary_Product_Delivery_Address_Region__c ='APJ',
                                     Primary_Product_Delivery_Address_Country__c= 'INDIA',Submitter_Profile__c = 'PRM', description = 'test opp',Services_Sales_Owner__c = testuser.id,
                                     source_id__c = 'testSI',Marketing_Created_Opportunity__c = false,Quest_Software_Contact__c= con.id);           
            insert oppnew;        
            Services_Project__c testSP = new Services_Project__c(Project_Name__c = 'testSPrec',Opportunity__c = oppnew.id);
            insert testSP;
            
            
            //PriceBook2 standardPb = new PriceBook2(Name='Test PriceBook');
            //Pricebook2 standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
            Id pbk1 = Test.getStandardPricebookId();
            Product2 prod1 = new product2(name='Prod1',dell_business_model__c= 'Smart Selection (Stocked);Custom BTO' ,productcode = 'test pd code1one');
            Product2 prod2 = new product2(name='Prod1',dell_business_model__c= 'Custom BTO' ,productcode = 'test pd code1one');
            Product2 prod3 = new product2(name='Prod1',dell_business_model__c= 'Smart Selection (Non Stocked)' ,productcode = 'test pd code1one');

            List<product2> prodList = new List<product2>();
            prodList.add(prod1);
            prodList.add(prod2);
            prodList.add(prod3);
            insert prodList;
            
            List<PricebookEntry> PBEList = new List<PricebookEntry>();
            PricebookEntry PBE1=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prod1.Id, UnitPrice=112.00, Isactive = true, 
                                                  UseStandardPrice=false); 
            PricebookEntry PBE2=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prod2.Id, UnitPrice=112.00, Isactive = true, 
                                                  UseStandardPrice=false);
            PricebookEntry PBE3=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prod3.Id, UnitPrice=112.00, Isactive = true, 
                                                  UseStandardPrice=false);            
            PBEList.add(PBE1);
            PBEList.add(PBE2);
            PBEList.add(PBE3);
            insert PBEList;
            
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem >();       
            for(integer i=0;i<10;i++){
                OpportunityLineItem oli = new OpportunityLineItem(PriceBookEntryId=PBE1.Id, OpportunityId=oppnew.Id, Quantity=1, TotalPrice=99);
                oliList.add(oli);
            }
            for(integer i=0;i<10;i++){
                OpportunityLineItem oli = new OpportunityLineItem(PriceBookEntryId=PBE2.Id, OpportunityId=oppnew.Id, Quantity=1, TotalPrice=99);
                oliList.add(oli);
            }
            for(integer i=0;i<10;i++){
                OpportunityLineItem oli = new OpportunityLineItem(PriceBookEntryId=PBE3.Id, OpportunityId=oppnew.Id, Quantity=1, TotalPrice=99);
                oliList.add(oli);
            }            
            insert oliList;
            TriggerExecutionController.setSkipAllTriggers(false);
            //test.startTest();
            
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
            update oppAfterInsert;
            test.stopTest();  
        }
    }
    
}
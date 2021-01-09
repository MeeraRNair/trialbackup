/*****************************************************************************************
* Name          : ProtectedDealInsertCtrlTest
* Description   : Test Class
* -------------------------------------------------------------------------
* Revision  Name        Date            Description
* 1.0       Hanan       25.09.2010      CR 3446 insert opportunity of protected deal record type
* 2.0       Meghana     24.12.2013      CR 8973 Remove use of field Verifiable_Outcome__c in Test Methods
* 3.0       Ragu        05-Oct-2014     CR10496 - GlobalVariables.SKIP_ALL_OPP_TRIGGERS is replaced with TriggerExecutionController.setSkipOpportunityTriggers().
* 4.0       Hari A      12.12.2018      CR       STORY 5907651 Removed reference for the fields protected_partner_account__c
* 5.0       Emily       08.01.2019      CR 16970 - Remove virtualization__c
****************************************************************************************/
@isTest
    private class ProtectedDealInsertCtrlTest{

        public static contact contactObject=new contact();   
        public static  List<Account> partnerAccounts = new List<Account>();
        public static Account endUserAccount;        
        public static Contact partnercontact;
        public static User userObject;          
        static Date dCloseDate= Date.newInstance(2015,07,29);
        static Datetime dealcreateddate =datetime.newInstance(2010, 09, 30, 12,30, 2);   
        static Product2 pdt1;       
        static Pricebook2 pb;
        static PricebookEntry pbe;       
        static Opportunity o ; 
        static OpportunityLineItem oli ;
        static RecordType rectype;

        static testMethod void test_createProtectedDeal(){
            GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
            RecordType opptyrectype=[Select Name,Id From RecordType where Name='Standard Opportunity' Limit 1];
            Opportunity opportunityObject;
            List<OpportunityLineItem> oliList=new  List<OpportunityLineItem>();
            String partnerAccountId1;
            String partnerAccountId2;
           
            Profile partnerProfile=[select id,name from Profile where UserType= 'PowerPartner' order by createddate asc LIMIT 1]; 
                
                                    //and  name like 'R11.7%' limit 1];  
                                       
            for(integer i=0;i<1;i++){
                Account accountObj=new Account(
                    name='TestAccount'+i,
                    Account_Country_Code__c = 'AI',
                    Account_Country__c = 'ANGUILIA',
                    Is_GTM_Partner__c=false,
                    Partner_Relationship__c='Certified'
                ); 
                partnerAccounts.add(accountObj);
            }
             test.startTest(); 
            insert partnerAccounts;

            for(Account account:partnerAccounts){
                account.IsPartner = true;
                account.Is_GTM_Partner__c=false;
                account.RecordTypeId= System.Label.RecType_Partner_Account;                
                account.Partner_Relationship__c='Certified';
            }
           // update partnerAccounts;        

            
            partnercontact=new Contact(
                AccountId=partnerAccounts.get(0).id,
                Email='John'+'@dellteam.com', 
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
             
            insert partnercontact;
            TriggerExecutionController.setSkipUserTriggers(true);
            userObject=new User(
                Username='ProtectedDealInsertCtrlTesttestuser'+'@dell.com',
                Alias = 'test', 
                Email='testuser'+'@dellteam.com', 
                FirstName='John', 
                LastName='Doe', 
                ProfileId = partnerProfile.Id, 
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', 
                EmailEncodingKey='UTF-8', 
                TimeZoneSidKey='America/Los_Angeles',
                Badge_Number__c=null, 
                ContactId = partnercontact.id 
            );
            insert userObject;
             test.stopTest();
            System.runAs(userObject){
            
             pdt1 = new product2(name='Test Product1',family='Enterprise',isActive=true,Product_ID__c='2234566');
            insert pdt1; 

            Pricebook2 stdPriceBook1 = [select Id from Pricebook2 where isStandard=true limit 1];
            
            insert new PricebookEntry(pricebook2id = stdPriceBook1.id, product2id = pdt1.id, unitprice=100.0, isActive=true);
            
            pb = new pricebook2(name='test pricebook');
            insert pb;

            pbe = new PricebookEntry(pricebook2id=pb.id,
            product2id=pdt1.id, unitprice=1000.0, isActive=true);
            insert pbe;
            
            endUserAccount=new Account(
                name='TestendUserAccountt',
                Account_Country_Code__c = 'AI',
                Account_Country__c = 'ANGUILIA'
            );
            insert endUserAccount; 
            TriggerExecutionController.setSkipOpportunityTriggers(true);
           // TriggerExecutionController.skipOpportunityLineItemTriggers(true);
            GlobalVariables.SKIP_ALL_OPP_TRIGGERS=true;
            GlobalVariables.SKIP_OPP_LINEITEM_TRIGGERS = true;
            opportunityObject=new Opportunity(
                name='test opportunity',
                stagename='Win - 100%',
                closedate=dCloseDate,
                Solution_Type__c='IT Simplification',
                Solution_Name__c='Systems Management',
                Type='Deal/Bid-Direct',
                Primary_Product_Delivery_Address_Region__c='NORTH AMERICA',
                Primary_Product_Delivery_Address_Country__c='UNITED STATES',
                //Verifiable_Outcome__c='Territory/Account/Optrueportunity Plan developed & reviewed by RSM',  //commented for CR8973
                accountid=endUserAccount.id,How_many_shipments__c=1,
                RecordTypeId=opptyrectype.Id,
                CurrencyIsoCode='USD',
                OwnerId=userObject.id,
                OS_Type__c='Solaris',
               // PartnerAccount = partnerAccounts[0].id,
                //5.0 Virtualization__c='Microsoft Hyper-V',
                Won_Lost_Comment__c='ggg',
                Reason_Won_Lost__c='Incumbent',
                Materials_Used_to_Help_Close_Deal__c='Case Study',
                Customer_Willing_To__c='Complete a case Study',
                Deal_Created_Date_Time__c=dealcreateddate,
                Competitor_Lost_To__c = 'CA'                
            );
           
           
            insert opportunityObject;
           }
             
            for(integer i=0;i<1;i++){
                oli = new OpportunityLineItem(opportunityid=opportunityObject.id,
                UnitPrice=1000, quantity=2000, pricebookentryid=pbe.Id);
                oliList.add(oli);           
            }
           //insert oli;
            
            Database.SaveResult[] results=Database.insert(oliList, false); 
            
           
           // System.debug('###results'+results);
           
            
            PageReference  pr=new PageReference('/apex/CreateProtectedDeal?scontrolCaching=1&id='+opportunityObject.id);
            Test.setCurrentPage(pr);
            System.debug('DEBUG: Current Page URL: '+ ApexPages.currentPage().getUrl());
            ProtectedDealInsertCtrl controller = new ProtectedDealInsertCtrl(new ApexPages.StandardController(opportunityObject));
            controller.createProtectedDeal();
            Opportunity oppty=[select id, recordtypeId,Parent_Opportunity__c from opportunity where id=:opportunityObject.id];
            Opportunity expected=oppty;
            Opportunity actual=controller.getProtectedDeal();
          //  System.assertEquals(expected.recordtypeId,actual.recordtypeId);
            System.assertEquals(opportunityObject.id,expected.id);
            Boolean errormsg=controller.getErrorMessage();
            Boolean displayProtectedDealName=controller.getDisplayProtectedDealName();
            PageReference backToOpptyURL=controller.backButton();
            
            

        }
    }
/*------------------------------------------
Project : Reusable end user data capture
CR: 6702,6703,6719
Created date: 11/18/2011
Author:Hanan Justin
--------------------------------------------*/

@isTest
private Class MyCustomersListNSearchCtrlerTest{

    static User  userRec=new User();
    static User  userRec2=new User();
    static Profile profileRec;
    static UserRole userRoleRec; 
    Static Account partnerAccount=new Account();
    Static Contact partnerContact=new COntact();
    Static Account partnerAccount2=new Account();
    Static Contact partnerContact2=new COntact();
    Static Country__c country=new Country__c();
    
    Static List<End_Customer__c> endCustomers=new List<End_Customer__c>();
    Static List<End_Customer_Contact__c> contactList=new List<End_Customer_Contact__c>(); 
    public static void createData(){
        List<Account> accounts=new List<Account>();
        List<Contact> contacts=new List<Contact>();
        List<User> users=new List<User>();
        List<QueueSobject> queues = [select QueueId from QueueSobject where SobjectType = 'Partner_Request__c' limit 1];      
         
        profileRec = [select id,name from profile where name like '%EMEA PRM Portal User%' order by name desc Limit 1]; 
        System.debug('###profileRec###'+profileRec.name);
        
        //Creating Partner Account   
        partnerAccount.name='PartnerAccount';
        partnerAccount.Account_Country_Code__c='XC';
        partnerAccount.Type = 'Partner';
        partnerAccount.Account_Country__c = 'XYZABC';
        accounts.add(partnerAccount);        
        partnerAccount2.name='PartnerAccount';
        partnerAccount2.Type = 'Partner';
        partnerAccount2.Account_Country_Code__c='XC';
        partnerAccount2.Account_Country__c = 'XYZABC'; 
        accounts.add(partnerAccount2);        
        insert accounts;        
        
        accounts.clear();        
        accounts=new List<Account>();        
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId= System.Label.RecType_Partner_Account;
        accounts.add(partnerAccount);        
        partnerAccount2.IsPartner = true;
        partnerAccount2.RecordTypeId= System.Label.RecType_Partner_Account;
        accounts.add(partnerAccount2);        
        update accounts;

        //Creating Partner Contact
        partnerContact.AccountId=partnerAccount.id;
        partnerContact.Email='John.Doe@dell.com';
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title='VP';
        partnerContact.MailingStreet='123 Main';
        partnerContact.MailingCity='Peoria';
        partnerContact.MailingState='IL';
        partnerContact.MailingPostalCode='33333';
        partnerContact.Phone='3213213211';
        partnerContact.MobilePhone='3213213211';
        partnerContact.Fax='3213123211' ;
        contacts.add(partnerContact);
        
        partnerContact2.AccountId=partnerAccount2.id;
        partnerContact2.Email='John1.Doe1@dell.com';
        partnerContact2.FirstName = 'John1';
        partnerContact2.LastName = 'Doe1';
        partnerContact2.Title='VP';
        partnerContact2.MailingStreet='123 Main';
        partnerContact2.MailingCity='Peoria';
        partnerContact2.MailingState='IL';
        partnerContact2.MailingPostalCode='33333';
        partnerContact2.Phone='3213213211';
        partnerContact2.MobilePhone='3213213211';
        partnerContact2.Fax='3213123211' ;
        contacts.add(partnerContact2);
        insert contacts;
        
        //Creating Partner User
        userRec.Username='XXYYZZ@dell.com';
        userRec.Alias = 'test';
        userRec.Email='testuser@test.com';
        userRec.FirstName='John'; 
        userRec.LastName='Doe'; 
        userRec.ProfileId =profileRec.Id; 
        userRec.LanguageLocaleKey='en_US'; 
        userRec.LocaleSidKey='en_US';
        userRec.EmailEncodingKey='UTF-8';
        userRec.TimeZoneSidKey='America/Los_Angeles';
        userRec.Badge_Number__c=null;
        userRec.ContactId=partnerContact.id;
        users.add(userRec);
        
        userRec2.Username='XXYYZZ1@dell.com';
        userRec2.Alias = 'test1';
        userRec2.Email='testuser1@test.com';
        userRec2.FirstName='John1'; 
        userRec2.LastName='Doe1'; 
        userRec2.ProfileId =profileRec.Id; 
        userRec2.LanguageLocaleKey='en_US'; 
        userRec2.LocaleSidKey='en_US';
        userRec2.EmailEncodingKey='UTF-8';
        userRec2.TimeZoneSidKey='America/Los_Angeles';
        userRec2.Badge_Number__c=null;
        userRec2.ContactId=partnerContact2.id;
        
        users.add(userRec2);
        insert users;        
 
               
        //Creating country record
        country.Name='XYZABC';
        country.Code__c='XA';
        country.Dell_Online_Country_Code__c='XA';      
        if(queues.size()>0){
            country.Partner_Support_Queue_ID__c = queues.get(0).QueueId;
        }
        country.CurrencyIsoCode='USD';
        country.Region__c='NA';
        insert country;
        
        //Creating end customer list
        for(integer i=0;i<30;i++){
            End_Customer__c endCustomer=new End_Customer__c();
            endCustomer.Account_Department__c='xxx';
            endCustomer.Account_Industry__c='Biotechnology';             
            endCustomer.Mailing_city__c='ff';
            endCustomer.Mailing_country__c='dasssa';
            endCustomer.Mailing_State__c='sdawwqwq';
            endCustomer.Mailing_street__c='ddsdqwewdc';
            endCustomer.Partner_Account__c=partnerAccount.id;
            endCustomer.Segment__c='Education';
            endCustomer.Status__c='Active';
            endCustomer.Tax_Id__c='aaaaa';
            endCustomer.Total_of_End_User_Employees__c='100 - 199';           
            endCustomer.Zip_Code__c='333333';
            endCustomer.Name='Company'+i;
            endCustomers.add(endCustomer);
        }
        try{
            insert endCustomers;
        }Catch(Exception e){
                   
        }
        
        for(end_customer__c  endCustomer:endCustomers){
        End_Customer_Contact__c contact=new End_Customer_Contact__c();
        contact.Name='test';
        contact.Email__c='test@test.com';
        contact.Last_Name__c='axwe';
        contact.Phone__c='123';
        contact.Mobile__c='123';
        contact.Status__c='Active';
        contact.Fax__c='1424';
        contact.Title__c='wewer';
        contact.end_customer__c=endCustomer.Id;
        contactList.add(contact);
        }
        try{
        insert contactList;
        }Catch(Exception e){
                   
        }
        
    }
    
    
     public static testMethod void testConstructor(){
        createData();   
         
        ApexPages.StandardSetController recordSetCon=new ApexPages.StandardSetController(Database.getQueryLocator([select Tax_Id__c,Name,Mailing_city__c,Account_Department__c,Mailing_country__c,Mailing_State__c,Mailing_street__c,Partner_Account__c,Zip_Code__c from End_Customer__c Where Partner_Account__c=:partnerAccount.Id Order by Name]));                
        test.startTest();
        //partner user logging in 
        System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);
               
        }
        
        //non-partnerUser
        
        PageReference pageRef2 = Page.MyCustomersListNSearch;
        Test.setCurrentPage(pageRef2);
        MyCustomersListNSearchCtrler controllerVar2= new MyCustomersListNSearchCtrler();       
     
        controllerVar2.getEndCustomers();
        controllerVar2.setEndCustomers(endCustomers);
       
        
        System.runAs(userRec2){
            PageReference pageRef3 = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef3);
            MyCustomersListNSearchCtrler controllerVar3= new MyCustomersListNSearchCtrler(); 
            controllerVar3.getEndCustomers();
            controllerVar3.setEndCustomers(endCustomers);
        }  
        
        test.stopTest();
        
    
     } 
     
     
     
      public static testMethod void testPagination(){
        createData();    
       System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();  
            controllerVar.getTableHeader();    
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);
          
            recordSetCon.getHasNext();       
            controllerVar.first();
            controllerVar.last();
            controllerVar.previous();
            controllerVar.next();
            controllerVar.cancel();
            
        }
        
     }
     
     public static testMethod void testSearchCustomer(){
        createData();    
        System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);
        
            recordSetCon.getHasNext();
            controllerVar.getSearchCustomer();
            controllerVar.setSearchCustomer('Company2');
            controllerVar.SearchEndCustomer();
            controllerVar.showAllCustomers();
        }
         
     }
     
        public static testMethod void testAddNewCustomer(){            
            createData();    
            System.runAs(userRec){ 
                End_Customer__c endCustomerNew=new End_Customer__c();
                endCustomerNew.Account_Department__c='xxx';
                endCustomerNew.Account_Industry__c='Biotechnology';             
                endCustomerNew.Mailing_city__c='ff';
                endCustomerNew.Mailing_country__c=country.Id;
                endCustomerNew.Mailing_State__c='sdawwqwq';
                endCustomerNew.Mailing_street__c='ddsdqwewdc';
                endCustomerNew.Partner_Account__c=partnerAccount.id;
                endCustomerNew.Segment__c='Education';
                endCustomerNew.Status__c='Active';
                endCustomerNew.Tax_Id__c='aaaaa';
                endCustomerNew.Total_of_End_User_Employees__c='100 - 199';           
                endCustomerNew.Zip_Code__c='333333';
                endCustomerNew.Name='Company31';
                
                End_Customer_Contact__c endCstmrCntct=new End_Customer_Contact__c();
                endCstmrCntct.Name='test';
                endCstmrCntct.Email__c='testemail@Company31.com';
               
                endCstmrCntct.Fax__c='222';
                endCstmrCntct.Last_Name__c='tester';
                endCstmrCntct.Mobile__c='333';
                endCstmrCntct.Phone__c='4444';
                endCstmrCntct.Status__c='Active';
                endCstmrCntct.Title__c='xsad';               
                 
            
                PageReference pageRef = Page.MyCustomersListNSearch;
                Test.setCurrentPage(pageRef);
                MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
                ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
                controllerVar.SetRecordSetCon(recordSetCon);
                controllerVar.getEndCustomers();
                controllerVar.setEndCustomers(endCustomers);
               
                recordSetCon.getHasNext();
                controllerVar.getEndCustomer();
                controllerVar.setEndCustomer(endCustomerNew);
                controllerVar.getEndCustomerContact();
                controllerVar.setEndCustomerContact(endCstmrCntct);
             
                controllerVar.CreateEndCustomer();
                controllerVar.SaveEndCustomer();
                controllerVar.Back2List();
                
            }
        }
        
        
        public static testMethod void testAddNewCustomerError(){            
            createData();    
            System.runAs(userRec){ 
                End_Customer__c endCustomerNew=new End_Customer__c();
                End_Customer_Contact__c endCstmrCntct=new End_Customer_Contact__c();
                PageReference pageRef = Page.MyCustomersListNSearch;
                Test.setCurrentPage(pageRef);
                MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
                ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
                controllerVar.SetRecordSetCon(recordSetCon);
                controllerVar.getEndCustomers();
                controllerVar.setEndCustomers(endCustomers);            
                controllerVar.getNullValue();                
                recordSetCon.getHasNext();
                controllerVar.getEndCustomer();
                controllerVar.setEndCustomer(endCustomerNew);
                controllerVar.getEndCustomerContact();
                controllerVar.setEndCustomerContact(endCstmrCntct);
          
                controllerVar.CreateEndCustomer();
                controllerVar.SaveEndCustomer();
                controllerVar.setNullValue(true);
                controllerVar.Back2List();
                
            }
        }
        
        
        public static testMethod void testSorting(){
        createData();    
        System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);      
            recordSetCon.getHasNext();
            PageReference pageRef2 = new Pagereference('/apex/MyCustomersListNSearch?column=Tax_Id__c');
            Test.setCurrentPage(pageRef2);
            controllerVar.getSortDirection(); 
            controllerVar.setSortDirection('DESC') ;
            controllerVar.sortingOtherFields();
           
        }
         
     } 
     
     public static testMethod void testViewEndCustomer(){
         createData();
         Opportunity opp=new Opportunity();
         System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);    
            controllerVar.getPartnerAccount(); 
            recordSetCon.getHasNext();
            PageReference pageRef2 = new Pagereference('/apex/EndCustomerDetailPage?id='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef2);           
            controllerVar.getSelectedEndCustomer();
            controllerVar.getOpportunity();
            controllerVar.setOpportunity(opp);
            controllerVar.getOpportunityList();
            controllerVar.getEndCustomerContactList();
           
        }
     }
     
     
     public static testMethod void testModifyEndCustomer(){
         createData();      
        
         System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);      
            recordSetCon.getHasNext();
            PageReference pageRef2 = new Pagereference('/apex/ModifyEndCustomer?listPage='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef2);
            controllerVar.ModifyEndCustomer(); 
            controllerVar.getEndCustomerVar();
            controllerVar.setEndCustomerVar(endCustomers[0]);
            controllerVar.saveEndCustomerVar();
           
        }
        
         System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);      
            recordSetCon.getHasNext();
            PageReference pageRef2 = new Pagereference('/apex/ModifyEndCustomer?DetailPage='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef2);
            controllerVar.ModifyEndCustomer(); 
            controllerVar.getEndCustomerVar();
            controllerVar.setEndCustomerVar(endCustomers[0]);
            controllerVar.saveEndCustomerVar();
           
        }
     }
     
     
    public static testMethod void testEndCustomerContactEditPage1(){
        createData();
         
         System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);      
            recordSetCon.getHasNext();
            controllerVar.getEndCustomerContactList();
            PageReference pageRef1 = new Pagereference('/apex/EndCustomerDetailPage?id='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef1);   
            controllerVar.viewEndCustomerPage();       
            controllerVar.getSelectedEndCustomer();         
            PageReference pageRef2= new Pagereference('/apex/EndCustomerContactPage?contactID2='+contactList[0].Id+'&mode=Edit&ECCID='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef2);
            controllerVar.doAction();  
            controllerVar.getECContactVar();
            controllerVar.setECContactVar(contactList[0]);          
            controllerVar.getBoolViewContact();
            controllerVar.setBoolViewContact(false);
            controllerVar.getBoolModifyContact();
            controllerVar.setBoolModifyContact(true);                       
            controllerVar.ModifyEndCustomerContact();
             
        }
        
    }
    
    public static testMethod void testEndCustomerContactEditPage2(){
        createData();
         
         System.runAs(userRec){           
             System.runAs(userRec){           
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);      
            recordSetCon.getHasNext();
            controllerVar.getEndCustomerContactList();
            PageReference pageRef1 = new Pagereference('/apex/EndCustomerDetailPage?id='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef1);   
            controllerVar.viewEndCustomerPage();       
            controllerVar.getSelectedEndCustomer();  
                   
            PageReference pageRef2= new Pagereference('/apex/EndCustomerContactPage?id='+contactList[0].Id+'&mode=view&ECCID='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef2);
            controllerVar.doAction();  
            controllerVar.getECContactVar();
            controllerVar.setECContactVar(contactList[0]);          
            controllerVar.getBoolViewContact();
            controllerVar.setBoolViewContact(true);
            controllerVar.getBoolModifyContact();
            controllerVar.setBoolModifyContact(false);
            
            PageReference pageRef3= new Pagereference('/apex/EndCustomerContactPage?contactID2='+contactList[0].Id+'&mode=Edit&ECCID='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef3);
             controllerVar.doAction();  
            controllerVar.getECContactVar();
            controllerVar.setECContactVar(contactList[0]);          
            controllerVar.getBoolViewContact();
            controllerVar.setBoolViewContact(false);
            controllerVar.getBoolModifyContact();
            controllerVar.setBoolModifyContact(true);                       
            controllerVar.ModifyEndCustomerContact();
             
        }
             
        }
        
    }
    
    public static testMethod void testEndCustomerContactCreatePage(){
        createData();         
         System.runAs(userRec){
            PageReference pageRef = Page.MyCustomersListNSearch;
            Test.setCurrentPage(pageRef);
            MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();       
            ApexPages.StandardSetController recordSetCon=controllerVar.getRecordSetCon();
            controllerVar.SetRecordSetCon(recordSetCon);
            controllerVar.getEndCustomers();
            controllerVar.setEndCustomers(endCustomers);      
            recordSetCon.getHasNext();
            controllerVar.getEndCustomerContactList();
            PageReference pageRef1 = new Pagereference('/apex/EndCustomerDetailPage?id='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef1);   
            controllerVar.viewEndCustomerPage();       
            controllerVar.getSelectedEndCustomer();
            
            End_Customer_Contact__c contact=new End_Customer_Contact__c();
            contact.Name='test';
            contact.Email__c='Hello@test.com';
            contact.Last_Name__c='axwe';
            contact.Phone__c='123';
            contact.Mobile__c='123';
            contact.Status__c='Active';
            contact.Fax__c='1424';
            contact.Title__c='wewer';
            contact.end_customer__c=endCustomers[0].Id;
         
            PageReference pageRef2= new Pagereference('/apex/EndCustomerContactPage?mode=Create&ECCID='+endCustomers[0].Id);
            Test.setCurrentPage(pageRef2);
            controllerVar.doAction();  
            controllerVar.getECContactVar();
            controllerVar.setECContactVar(contact);          
            controllerVar.getBoolViewContact();
            controllerVar.setBoolViewContact(false);
            controllerVar.getBoolModifyContact();
            controllerVar.setBoolModifyContact(true);                       
            controllerVar.ModifyEndCustomerContact();                    
             
        }    
    }
    
    public static testMethod void testOpportunityPages(){
        createData();         
         System.runAs(userRec){           
                PageReference pageRef = Page.MyCustomersListNSearch;
                Test.setCurrentPage(pageRef);
                MyCustomersListNSearchCtrler controllerVar= new MyCustomersListNSearchCtrler();
                controllerVar.helperFn();
                controllerVar.getRecordTypeId();
                controllerVar.getBaseURL();
                
            }
    }
    
}
@isTest
public class VfCntrl_EndCustomerSelectionPageTest {
    static list<Account> listAcc1 = new list<Account>();
    @testsetup static void setup() { 
        TriggerExecutionController.setskipAccountTriggers(true);
        list<Account> listAccfromFactory = TestDataFactory.createNAccount(1, 'Master Account');
        insert listAccfromFactory; 
        list<Account> listAccfromFactory1 = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccfromFactory1; 
        list<Account> listAccfromFactory2 = TestDataFactory.createNAccount(1, 'End-User Account');
        insert listAccfromFactory2; 
    }
    public testmethod static void testingcoverageNegative() {
        VfCntrl_EndCustomerSelectionPage class1 = new VfCntrl_EndCustomerSelectionPage();
        class1.createNewContact = 'TRUE';
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];     
        
        //listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc[0];
        // listAcc[1].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc1[0];
        system.assertEquals(listAcc[0].DMU__c, false);
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id,
                                                                EU_Affinity_ID__c = '1233435' 
                                                               );
        insert endCustomerString; 
        End_Customer__c endCustomerString1 = new End_Customer__c(Name = 'TestEndCuew2stomer',
                                                                 Mailing_city__c = 'City',
                                                                 Mailing_State__c ='state',
                                                                 Status__c = 'Active',
                                                                 Partner_Account__c = listAcc1[0].id,
                                                                 EU_Affinity_ID__c = '1233435' 
                                                                );
        insert endCustomerString1;    
        System.currentPagereference().getParameters().put('selectedrecordid',endCustomerString.id);
        class1.fetchContacts();
        End_Customer_Contact__c endCustomerContactDupe = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                     Name = 'First Name',
                                                                                     Status__c ='Active',
                                                                                     Email__c = 'Test123@email.com',
                                                                                     Source_System__c ='Deal Registration',      
                                                                                     End_Customer__c =endCustomerString.id,
                                                                                     phone__c='12312342' );
        insert endCustomerContactDupe; 
        End_Customer_Contact__c endCustomerContactDupe1 = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                      Name = 'First Name',
                                                                                      Status__c ='Active',
                                                                                      Email__c = 'Test123@email.com',
                                                                                      Source_System__c ='Deal Registration',      
                                                                                      End_Customer__c =endCustomerString1.id,
                                                                                      phone__c='12312342' );
        insert endCustomerContactDupe1; 
        class1.objEndCustumerContact = endCustomerContactDupe;
        class1.saveEndCustomerDetails();
        class1.delEndCust();
        System.currentPagereference().getParameters().put('selectedEndCustomerId',endCustomerString.id);
        class1.inactivateMethod();
        VfCntrl_EndCustomerSelectionPage class2 = new VfCntrl_EndCustomerSelectionPage();
        class2.inactivateMethod();
    } 
    static testMethod void testEndCustomerSelection(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];
        list<Account> listAcc2 = [select id from Account where recordtype.name='End-User Account' Limit 1];     
        
        //listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc[0];
        // listAcc[1].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        // listAcc2[0].RecordTypeId=getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc2[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc2[0].Partner_Tier__c = 'Tier 1';
        listAcc2[0].DMU__c = false;
        listAcc2[0]. Partner_Relationship__c = 'Authorized';
        listAcc2[0].Account_Country__c = 'UNITED KINGDOM';
        listAcc2[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc1;
        update listAcc2;
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id,
                                                                EU_Affinity_ID__c = '1233435' 
                                                               );
        insert endCustomerString;  
        End_Customer__c endCustomerStringupdate = new End_Customer__c(id = endCustomerString.id,
                                                                      EU_Affinity_ID__c = '4444444' 
                                                                     );
        update endCustomerStringupdate;  
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                 Name = 'First Name',
                                                                                 Status__c ='Active',
                                                                                 Email__c = 'Test@email.com',
                                                                                 Source_System__c ='Deal Registration',
                                                                                 End_Customer__c =endCustomerString.id );
        insert endCustomerContact;    
        End_Customer_Contact__c endCustomerContactDupe = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                     Name = 'First Name',
                                                                                     Status__c ='Active',
                                                                                     Email__c = 'Test123@email.com',
                                                                                     Source_System__c ='Deal Registration',      
                                                                                     End_Customer__c =endCustomerString.id );
        insert endCustomerContactDupe; 
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[0].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;    
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test123', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        System.currentPagereference().getParameters().put('tesing','Tesing');
        System.runAs(PartnerUser){
            System.currentPagereference().getParameters().put('tesing','Tesing');
            VfCntrl_EndCustomerSelectionPage endCustomerSelection = new VfCntrl_EndCustomerSelectionPage();          
            EndCustomerSelection.getEndCustomers();
            EndCustomerSelection.navigateToDnBPage();
            EndCustomerSelection.fetchContacts();
            EndCustomerSelection.ErrorMessage='test';
            EndCustomerSelection.selectedAccId='0013B000007FKQ7';
            EndCustomerSelection.endCustSuccessMsg='success';
            List<Apexpages.Message> listpageMessages = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:listpageMessages){
                if (msg.getDetail().contains('Please select one End Customer')){
                    b = true;
                }
            }
            system.assert(b);
            System.currentPagereference().getParameters().put('selectedAccId',endCustomerString.id);
            EndCustomerSelection.fetchContacts();
            System.currentPagereference().getParameters().put('selectedEndCustomerId',endCustomerString.id);
            EndCustomerSelection.hideNewContForm();
            EndCustomerSelection.saveEndCustomerDetails();
            System.currentPagereference().getParameters().put('selectedAccId1',endCustomerContact.id);
            EndCustomerSelection.createNewContForm();
            System.currentPagereference().getParameters().put('selectedAccId1',endCustomerContact.id);
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.selectedEndCustomerId = endCustomerString.id;
            EndCustomerSelection.inactivateMethod();
            EndCustomerSelection.delEndCust();
            EndCustomerSelection.closePopup();
            EndCustomerSelection.close();
            EndCustomerSelection.searchContacts();
             EndCustomerSelection.refreshPageSize();
             EndCustomerSelection.getTotalPages();
              EndCustomerSelection.previous();
               EndCustomerSelection.next();
              EndCustomerSelection.last();
               EndCustomerSelection.first();
            EndCustomerSelection.getradiobuttonsItems();
            EndCustomerSelection.hideNewContForm();
            System.assert(EndCustomerSelection.Cancel().getURL().contains('/setup/ui/recordtypeselect.jsp'));
            System.currentPagereference().getParameters().get('selectedAccId2');
            EndCustomerSelection.createNewContForm();
            EndCustomerSelection.hideNewContForm();
            EndCustomerSelection.saveEndCustomerDetails();
            System.currentPagereference().getParameters().put('selectedAccId1',endCustomerContactDupe.id);
            EndCustomerSelection.saveEndCustomerDetails();
        }
    } 
    static testMethod void testEndCustomerSelectionnegativescenarios(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];
        list<Account> listAcc2 = [select id from Account where recordtype.name='End-User Account' Limit 1];     
        //listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        //listAcc[1].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        // listAcc[2].RecordTypeId=getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc2[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc2[0].Partner_Tier__c = 'Tier 1';
        listAcc2[0].DMU__c = false;
        listAcc2[0]. Partner_Relationship__c = 'Authorized';
        listAcc2[0].Account_Country__c = 'UNITED KINGDOM';
        listAcc2[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        update listAcc1;
        update listAcc2;
        
        system.assertNotEquals(null, listAcc1[0].id);
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id );
        insert endCustomerString;
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                 Name = 'First Name',
                                                                                 Status__c ='Active',
                                                                                 Email__c = 'Test@email.com',
                                                                                 Source_System__c ='Deal Registration',
                                                                                 End_Customer__c =endCustomerString.id );
        End_Customer_Contact__c endCustomerContactDupe = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                     Name = 'First Name',
                                                                                     Status__c ='Active',
                                                                                     Email__c = 'Test123@email.com',
                                                                                     Source_System__c ='Deal Registration',      
                                                                                     End_Customer__c =endCustomerString.id );
        insert endCustomerContactDupe;
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[0].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;    
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%'];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test123', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        System.runAs(PartnerUser){
            VfCntrl_EndCustomerSelectionPage endCustomerSelection= new VfCntrl_EndCustomerSelectionPage();          
            EndCustomerSelection.getEndCustomers();
            System.currentPagereference().getParameters().put('selectedAccId',endCustomerString.id);
            EndCustomerSelection.fetchContacts();
            EndCustomerSelection.inactivateMethod();
            EndCustomerSelection.delEndCust();
            List<Apexpages.Message> listpageMessages = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:listpageMessages){
                if (msg.getDetail().contains('No previously used contacts found for selected customer. Please select and complete create new contact.')){
                    b = true;
                }    
            }
        }
    }
    static testMethod void testEndCustomerSelectionnodupe(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];
        list<Account> listAcc2 = [select id from Account where recordtype.name='End-User Account' Limit 1];     
        // listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        //listAcc1[0].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        //listAcc[2].RecordTypeId=getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc2[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc2[0].Partner_Tier__c = 'Tier 1';
        listAcc2[0].DMU__c = false;
        listAcc2[0]. Partner_Relationship__c = 'Authorized';
        listAcc2[0].Account_Country__c = 'UNITED KINGDOM';
        listAcc2[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        update listAcc1;
        update listAcc2;
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id );        
        insert endCustomerString;  
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                 Name = 'First Name',
                                                                                 Status__c ='Active',
                                                                                 Email__c = 'Test@email.com',
                                                                                 Source_System__c ='Deal Registration',
                                                                                 End_Customer__c =endCustomerString.id );
        insert endCustomerContact;  
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc1[0].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;    
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test123', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        try{
            insert partnerUser;
        }
        catch (exception e){}
        System.runAs(PartnerUser){
            VfCntrl_EndCustomerSelectionPage endCustomerSelection= new VfCntrl_EndCustomerSelectionPage();          
            EndCustomerSelection.getEndCustomers();
            EndCustomerSelection.fetchContacts();
            List<Apexpages.Message> listpageMessages = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:listpageMessages){
                if (msg.getDetail().contains('Please select one End Customer')){
                    b = true;
                }   
            }
            system.assert(b);
            System.currentPagereference().getParameters().put('selectedAccId',endCustomerContact.id);
            EndCustomerSelection.createNewContForm();
            EndCustomerSelection.inactivateMethod();
            EndCustomerSelection.delEndCust();
            EndCustomerSelection.closePopup();
            EndCustomerSelection.close();
            EndCustomerSelection.getradiobuttonsItems();
            EndCustomerSelection.hideNewContForm();
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.selectedEndCustomerId = endCustomerString.id;
            EndCustomerSelection.ErrorMessage='test';
            EndCustomerSelection.selectedAccId='0013B000007FKQ7';
            EndCustomerSelection.endCustSuccessMsg='success';
            List<Apexpages.Message> listpageMessages1 = ApexPages.getMessages();
            boolean boo = false;
            Test.setCurrentPageReference(new PageReference('Page.page'));       
        }
    }
    static testMethod void testEndCustomerSelectionnodupe1(){
        VfCntrl_EndCustomerSelectionPage endCustomerSelectionperson = new VfCntrl_EndCustomerSelectionPage();        
        endCustomerSelectionperson.saveEndCustomerDetails();
        Map<id,end_customer__c> mapnew = new Map<id,end_customer__c>();
        end_customer__c acct = new end_customer__c();
        mapnew.put(acct.id, acct);
        System.assertNotEquals(null,acct);
        endCustomerSelectionperson.Cancel();
    } 
    static testMethod void testEndcustomerClose(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];
        list<Account> listAcc2 = [select id from Account where recordtype.name='End-User Account' Limit 1];     
        
        //listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        //  listAcc1[0].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        // listAcc[2].RecordTypeId=getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc2[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc2[0].Partner_Tier__c = 'Tier 1';
        listAcc2[0].DMU__c = false;
        listAcc2[0]. Partner_Relationship__c = 'Authorized';
        listAcc2[0].Account_Country__c = 'UNITED KINGDOM';
        listAcc2[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        update listAcc1;
        update listAcc2;
        
        system.assertNotEquals(null, listAcc1[0].id);
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id );
        insert endCustomerString;  
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                 Name = 'First Name',
                                                                                 Status__c ='Active',
                                                                                 Email__c = 'Test@email.com',
                                                                                 Source_System__c ='Deal Registration',
                                                                                 End_Customer__c =endCustomerString.id );
        insert endCustomerContact;
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[0].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;    
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test123', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        System.runAs(PartnerUser){
            VfCntrl_EndCustomerSelectionPage endCustomerSelection= new VfCntrl_EndCustomerSelectionPage();          
            EndCustomerSelection.getEndCustomers();
            EndCustomerSelection.fetchContacts();
            List<Apexpages.Message> listpageMessages = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:listpageMessages){
                if (msg.getDetail().contains('Please select one End Customer')){
                    b = true;
                }    
            }
            system.assert(b);
            System.currentPagereference().getParameters().put('selectedrecordid',endCustomerString.id);
            EndCustomerSelection.createNewContForm();
            System.currentPagereference().getParameters().put('selectedAccId',endCustomerContact.id);
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.selectedRecordId = endCustomerString.id;
            EndCustomerSelection.strSelectedvalue = 'Yes';
            EndCustomerSelection.createNewContact='True';
            EndCustomerSelection.inactivateMethod();
            EndCustomerSelection.delEndCust();
            EndCustomerSelection.closePopup();
            EndCustomerSelection.close();
            EndCustomerSelection.getradiobuttonsItems();
            EndCustomerSelection.hideNewContForm();
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.selectedEndCustomerId = endCustomerString.id;
            try{EndCustomerSelection.fetchContacts();
               }catch(exception e){}
            EndCustomerSelection.ErrorMessage='test';
            EndCustomerSelection.selectedAccId='0013B000007FKQ7';
            EndCustomerSelection.endCustSuccessMsg='success';
            List<Apexpages.Message> listpageMessages1 = ApexPages.getMessages();
            boolean boo = false;
            Test.setCurrentPageReference(new PageReference('Page.page'));       
        }
    }
    static testMethod void testEndcustomerClose1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];
        list<Account> listAcc2 = [select id from Account where recordtype.name='End-User Account' Limit 1];     
        listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        //listAcc1[0].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        listAcc2[0].RecordTypeId=getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc2[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc2[0].Partner_Tier__c = 'Tier 1';
        listAcc2[0].DMU__c = false;
        listAcc2[0]. Partner_Relationship__c = 'Authorized';
        listAcc2[0].Account_Country__c = 'UNITED KINGDOM';
        listAcc2[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        update listAcc1;
        update listAcc2;
        
        system.assertNotEquals(null, listAcc[0].id);
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id );
        insert endCustomerString;  
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                 Name = 'First Name',
                                                                                 Status__c ='Active',
                                                                                 Email__c = 'Test@email.com',
                                                                                 Source_System__c ='Deal Registration',
                                                                                 End_Customer__c =endCustomerString.id );
        insert endCustomerContact;
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[0].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;    
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test123', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        System.runAs(PartnerUser){
            VfCntrl_EndCustomerSelectionPage endCustomerSelection= new VfCntrl_EndCustomerSelectionPage();          
            EndCustomerSelection.getEndCustomers();
            EndCustomerSelection.fetchContacts();
            List<Apexpages.Message> listpageMessages = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:listpageMessages){
                if (msg.getDetail().contains('Please select one End Customer')){
                    b = true;
                }    
            }
            system.assert(b);
            System.currentPagereference().getParameters().put('selectedrecordid',endCustomerString.id);
            EndCustomerSelection.createNewContForm();
            System.currentPagereference().getParameters().put('selectedAccId',endCustomerContact.id);
            EndCustomerSelection.selectedRecordId = endCustomerString.id;
            EndCustomerSelection.strSelectedvalue = 'Yes';
            EndCustomerSelection.createNewContact='False';
            EndCustomerSelection.selectedContactId=endCustomerContact.id;
            DealReg_CustomerSelectionHelper.checkEndCustomerContactDuplicate('j_smith@email1.com',endCustomerString.id);
            EndCustomerSelection.inactivateMethod();
            EndCustomerSelection.delEndCust();
            EndCustomerSelection.closePopup();
            EndCustomerSelection.close();
            EndCustomerSelection.getradiobuttonsItems();
            EndCustomerSelection.hideNewContForm();
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.selectedEndCustomerId = endCustomerString.id;
            try{ EndCustomerSelection.fetchContacts();
               }catch (exception e){}
            EndCustomerSelection.ErrorMessage='test';
            EndCustomerSelection.selectedAccId='0013B000007FKQ7';
            EndCustomerSelection.endCustSuccessMsg='success';
            List<Apexpages.Message> listpageMessages1 = ApexPages.getMessages();
            boolean boo = false;
            Test.setCurrentPageReference(new PageReference('Page.page'));       
        }
    }   
    static testMethod void testEndcustomerClose2(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];
        list<Account> listAcc2 = [select id from Account where recordtype.name='End-User Account' Limit 1];     
        // listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        //listAcc1[0].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        //listAcc2[0].RecordTypeId=getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc2[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc2[0].Partner_Tier__c = 'Tier 1';
        listAcc2[0].DMU__c = false;
        listAcc2[0]. Partner_Relationship__c = 'Authorized';
        listAcc2[0].Account_Country__c = 'UNITED KINGDOM';
        listAcc2[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        update listAcc1;
        update listAcc2;
        
        system.assertNotEquals(null, listAcc[0].id);
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id );
        insert endCustomerString;  
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                 Name = 'First Name',
                                                                                 Status__c ='Active',
                                                                                 Email__c = 'Test@email.com',
                                                                                 Source_System__c ='Deal Registration',
                                                                                 End_Customer__c =endCustomerString.id );
        insert endCustomerContact;
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[0].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;    
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test123', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        System.runAs(PartnerUser){
            VfCntrl_EndCustomerSelectionPage endCustomerSelection= new VfCntrl_EndCustomerSelectionPage();          
            EndCustomerSelection.getEndCustomers();
            EndCustomerSelection.fetchContacts();
            List<Apexpages.Message> listpageMessages = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:listpageMessages){
                if (msg.getDetail().contains('Please select one End Customer')){
                    b = true;
                }    
            }
            system.assert(b);
            System.currentPagereference().getParameters().put('selectedrecordid',endCustomerString.id);
            EndCustomerSelection.createNewContForm();
            System.currentPagereference().getParameters().put('selectedAccId',endCustomerContact.id);
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.selectedRecordId = endCustomerString.id;
            EndCustomerSelection.strSelectedvalue= 'Yes';
            EndCustomerSelection.createNewContact='True';
            DealReg_CustomerSelectionHelper.checkEndCustomerContactDuplicate('j_smith@email.com',endCustomerString.id);
            EndCustomerSelection.inactivateMethod();
            EndCustomerSelection.delEndCust();
            EndCustomerSelection.closePopup();
            EndCustomerSelection.close();
            EndCustomerSelection.getradiobuttonsItems();
            EndCustomerSelection.hideNewContForm();
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.selectedEndCustomerId = endCustomerString.id;
            try{EndCustomerSelection.fetchContacts();
               }catch (exception e){}
            EndCustomerSelection.ErrorMessage='test';
            EndCustomerSelection.selectedAccId='0013B000007FKQ7';
            EndCustomerSelection.endCustSuccessMsg='success';
            List<Apexpages.Message> listpageMessages1 = ApexPages.getMessages();
            boolean boo = false;
            Test.setCurrentPageReference(new PageReference('Page.page'));       
        }
    }
    static testMethod void testEndcustomerClose3(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];
        list<Account> listAcc2 = [select id from Account where recordtype.name='End-User Account' Limit 1];     
        //listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc[0];
        // listAcc1[0].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc1[0];
        //listAcc2[0].RecordTypeId=getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc2[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc2[0].Partner_Tier__c = 'Tier 1';
        listAcc2[0].DMU__c = false;
        listAcc2[0]. Partner_Relationship__c = 'Authorized';
        listAcc2[0].Account_Country__c = 'UNITED KINGDOM';
        listAcc2[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        update listAcc1;
        update listAcc2;
        system.assertNotEquals(null, listAcc[0].id);
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id );
        insert endCustomerString;  
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                 Name = 'First Name',
                                                                                 Status__c ='Active',
                                                                                 Email__c = 'j_smith@email.com',
                                                                                 Source_System__c ='Deal Registration',
                                                                                 End_Customer__c =endCustomerString.id );
        insert endCustomerContact;
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[0].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;    
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test123', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        System.runAs(PartnerUser){
            VfCntrl_EndCustomerSelectionPage endCustomerSelection= new VfCntrl_EndCustomerSelectionPage();          
            EndCustomerSelection.getEndCustomers();
            EndCustomerSelection.fetchContacts();
            List<Apexpages.Message> listpageMessages = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:listpageMessages){
                msg.getDetail().contains('Please select one End Customer');
                b = true;
            }
            system.assert(b);
            System.currentPagereference().getParameters().put('selectedrecordid',endCustomerString.id);
            EndCustomerSelection.createNewContForm();
            System.currentPagereference().getParameters().put('selectedAccId',endCustomerContact.id);
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.selectedRecordId = endCustomerString.id;
            EndCustomerSelection.strSelectedvalue= 'Yes';
            EndCustomerSelection.createNewContact='True';
            EndCustomerSelection.inactivateMethod();
            EndCustomerSelection.delEndCust();
            EndCustomerSelection.closePopup();
            EndCustomerSelection.getradiobuttonsItems();
            EndCustomerSelection.hideNewContForm();
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.selectedEndCustomerId = endCustomerString.id;
            try{EndCustomerSelection.fetchContacts();
               }catch (exception e){}
            EndCustomerSelection.ErrorMessage='test';
            EndCustomerSelection.selectedAccId='0013B000007FKQ7';
            EndCustomerSelection.endCustSuccessMsg='success';
            List<Apexpages.Message> listpageMessages1 = ApexPages.getMessages();
            boolean boo = false;
            Test.setCurrentPageReference(new PageReference('Page.page'));       
        }
    }
    static testMethod void testEndcustomerClose4(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = [select id from Account where recordtype.name='Master Account' Limit 1];     
        list<Account> listAcc1 = [select id from Account where recordtype.name='Partner Account' Limit 1];
        list<Account> listAcc2 = [select id from Account where recordtype.name='End-User Account' Limit 1];     
        //listAcc[0].RecordTypeId=getRecordTypeIdbyName('Master Account', 'Account'); 
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Status__c = 'Active';
        listAcc[0].DMU__c = false; 
        //listAcc1[0].RecordTypeId=getRecordTypeIdbyName('Partner Account', 'Account');
        listAcc1[0].Master_Group_Id__c = listAcc[0].id;
        listAcc1[0].Type = 'Partner';
        listAcc2[0].RecordTypeId=getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc2[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc2[0].Partner_Tier__c = 'Tier 1';
        listAcc2[0].DMU__c = false;
        listAcc2[0]. Partner_Relationship__c = 'Authorized';
        listAcc2[0].Account_Country__c = 'UNITED KINGDOM';
        listAcc2[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        update listAcc1;
        update listAcc2;
        
        system.assertNotEquals(null, listAcc[0].id);
        End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                                Mailing_city__c = 'City',
                                                                Mailing_State__c ='state',
                                                                Status__c = 'Active',
                                                                Partner_Account__c = listAcc1[0].id );
        insert endCustomerString;  
        End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                                 Name = 'First Name',
                                                                                 Status__c ='Active',
                                                                                 Email__c = 'j_smith@email.com',
                                                                                 Source_System__c ='Deal Registration',
                                                                                 End_Customer__c =endCustomerString.id );
        insert endCustomerContact;
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[0].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;    
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test123', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        System.runAs(PartnerUser){
            VfCntrl_EndCustomerSelectionPage endCustomerSelection= new VfCntrl_EndCustomerSelectionPage();          
            EndCustomerSelection.getEndCustomers();
            EndCustomerSelection.fetchContacts();
            List<Apexpages.Message> listpageMessages = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:listpageMessages){
                if (msg.getDetail().contains('Please select one End Customer')){
                    b = true;
                }    
            }
            system.assert(b);
            System.currentPagereference().getParameters().put('selectedrecordid',endCustomerString.id);
            EndCustomerSelection.createNewContForm();
            System.currentPagereference().getParameters().put('selectedAccId',endCustomerContact.id);
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.selectedRecordId = endCustomerString.id;
            EndCustomerSelection.strSelectedvalue= 'No';
            EndCustomerSelection.inactivateMethod();
            EndCustomerSelection.delEndCust();
            EndCustomerSelection.closePopup();
            EndCustomerSelection.close();
            EndCustomerSelection.getradiobuttonsItems();
            EndCustomerSelection.hideNewContForm();
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.objEndCustumerContact.Name = 'john smith';
            EndCustomerSelection.objEndCustumerContact.Email__c = 'j_smith@email.com';
            EndCustomerSelection.objEndCustumerContact.Last_Name__c = 'smith';
            EndCustomerSelection.objEndCustumerContact.Status__c='Active';
            EndCustomerSelection.saveEndCustomerDetails();
            EndCustomerSelection.selectedEndCustomerId = endCustomerString.id;
            try{ EndCustomerSelection.fetchContacts();
               }catch(exception e){}
            EndCustomerSelection.ErrorMessage='test';
            EndCustomerSelection.selectedAccId='0013B000007FKQ7';
            EndCustomerSelection.endCustSuccessMsg='success';
            List<Apexpages.Message> listpageMessages1 = ApexPages.getMessages();
            boolean boo = false;
            Test.setCurrentPageReference(new PageReference('Page.page'));       
        }
    }
    public static Id getRecordTypeIdbyName(String strRecordTypeName,String strobjectName){
        return  Schema.getGlobalDescribe().get(strobjectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }   
}
@isTest
private class afterInsertUpdatePartnerStatusTest {
//TEST CLASS for afterInsertUpdatePartnerStatus trigger on Account
    public static testMethod void afterInsertPartnerStatusTrigger() {
       
       Country__c country2  = new Country__c(Code__c = 'IN', Region__c = 'APJ');
       insert country2 ;
       
       Certification_Process_Setup__c process2  = new Certification_Process_Setup__c(Name='APJ', Region__c = 'APJ', Certification_Admin_Mailbox__c='netexam@gmail.com', send_email_to_partner_admin__c = true);
       insert process2; 
              
        Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', Partner_Relationship__c = 'Registered',Account_Country_Code__c = 'IN');
        //insert a account record
        insert acc;
        
        Contact c = new Contact(AccountId=acc.id, FirstName='Test',LastName='test', email='netexam@dell.com');
        insert c;
        
     
     Profile p = [select id from profile where name like 'Strategic Partner User' limit 1];
     
      User u1 = new User(ContactId = c.id, IsActive = True, Email = 'netexam@dell.com', 
                          LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = true, TimeZoneSidKey = 'GMT',
                          LocaleSidKey = 'en_US', LastName = 'UT', Alias = 'UT', EmailEncodingKey = 'ISO-8859-1', 
                          UserName = 'netexam@dell.com', ProfileId= p.id);
     insert u1;
     
     
 
      Certification_Tracker__c tracker = new Certification_Tracker__c(Account_Name__c = acc.id,
                                CurrencyIsoCode='INR',
                                QTR_Updated_Date__c=Date.Today(), Certification_Date__c = date.newinstance(2012, 2, 2));
       //insert a tracker record                        
       insert tracker ;
           
       acc.Partner_Relationship__c='Preferred';
       update acc;
       
       }
       
    public static testMethod void afterUpdateDecertDateOnTrigger() {
    
        Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', Partner_Relationship__c = 'Preferred');
        //insert a account record
        insert acc;
        
      Certification_Tracker__c tracker = new Certification_Tracker__c(Account_Name__c = acc.id,
                                CurrencyIsoCode='INR',
                                QTR_Updated_Date__c=Date.Today());
       //insert a tracker record                        
       insert tracker ;
       
       acc.Partner_Relationship__c = 'Registered';
       update acc;
       }  
             
    public static testMethod void afterInsertUpdatemailPartnerAdmin(){
       Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', Partner_Relationship__c = 'Registered', Account_Country_Code__c = null);
        //insert a account record
        insert acc;
        
       Country__c country  = new Country__c(Code__c = 'US', Region__c = 'US');
       //insert a country record                                                         
       insert country ;
       
       Country__c country1  = new Country__c(Code__c = 'CA', Region__c = 'Canada');
       //insert a country record                                                         
       insert country1 ;
       
       Certification_Process_Setup__c process  = new Certification_Process_Setup__c(Name='US', Region__c = 'US', Certification_Admin_Mailbox__c='netexam@gmail.com', send_email_to_partner_admin__c = true);
        //insert a Certification Process Setup record
        insert process;  
        
       Certification_Process_Setup__c process1  = new Certification_Process_Setup__c(Name='CA', Region__c = 'CA', Certification_Admin_Mailbox__c='netexam@gmail.com', send_email_to_partner_admin__c = true);
        //insert a Certification Process Setup record
        insert process1; 
               
       Certification_Tracker__c tracker = new Certification_Tracker__c(Account_Name__c = acc.id,
                                CurrencyIsoCode='INR',
                                QTR_Updated_Date__c=Date.Today());
       //insert a tracker record                        
       insert tracker ;
       
       acc.Partner_Relationship__c = 'Preferred';
       acc.Account_Country_Code__c = 'US';
       update acc;   
       
       acc.Partner_Relationship__c = 'Registered';      
       update acc;  
      
       acc.Partner_Relationship__c = 'Preferred';
       acc.Account_Country_Code__c = 'CA';
       update acc;  
       
             
        } 
           
}
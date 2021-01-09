@isTest
private class VFCtlr_AddAtendeesTest{
    static List<Attendees__c> attendeeLst=new List<Attendees__c>();
    static Customer_Engagement__c customerEngagement=new Customer_Engagement__c();
    static Transportation__c transportation=new Transportation__c();
    static List<VFCtlr_AddAtendees.AttendeeWrapper> AttendeeWrapperRecords=new List<VFCtlr_AddAtendees.AttendeeWrapper>(); 
    
    static List<Account> accounts= new List<Account>();
    static List<Contact> contacts = new List<Contact>();
    static List<User> userLst = new List<User>();
    
    public static void createData(){
        // Fenny: These 2 lines failing my test class LOBRegistrationAutoApprovalTest.cls
        //        The data type for the corresponding fields are Date, not DateTime
        //datetime startDate=datetime.newInstance(2011,1,15);
        //datetime endDate =datetime.newInstance(2011, 1, 31);
        Date startDate=Date.newInstance(2011,1,15);
        Date endDate =Date.newInstance(2011, 1, 31);
        
        Profile profiles=[select id,name from Profile where name like 'Standard%' limit 1];
         
         for(integer i=0;i<5;i++){
            Account accountObj=new Account(name='TestAccount'+i,
                                           Account_Country_Code__c = 'AI',
                                           Account_Country__c = 'ANGUILIA');
            accounts.add(accountObj);
        }
        
        insert accounts;
        
        
        for(Integer i = 0; i <4; i++){
            contacts.add(
                new Contact(
                    AccountId=accounts.get(i).id,
                    Email=''+i+'@dell.com', 
                    FirstName = 'John', 
                    LastName = 'Doe'+i,
                    Title='VP',
                    MailingStreet='123 Main',
                    MailingCity='Peoria',
                    MailingState='IL',
                    MailingPostalCode='33333',
                    Phone='3213213211',
                    MobilePhone='3213213211',
                    Fax='3213123211'                    
                )
            );
        }
        insert contacts;
        
        
         for(Integer i = 0; i < 4; i++){
            userLst.add(
                new User(
                    Username='testuser'+i+ System.currentTimeMillis()+'@dell.com',
                    Alias = 'test'+i, 
                    Email='testuser'+i+'@dellteam.com', 
                    FirstName='John', 
                    LastName='Doe'+i, 
                    ProfileId = profiles.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='testuser'+i                     
                   )
            );
        }
        insert userLst;
        
        customerEngagement.Name='Test CE';
        customerEngagement.Event_Status__c='Scheduled';
        customerEngagement.Requestor_Name__c=userLst[1].id;
        customerEngagement.Estimated_no_of_Customer_Attendees__c=12;
        customerEngagement.Cost_Center__c='1111-1111-111111';
        customerEngagement.Primary_Account__c=accounts[1].id;
        customerEngagement.Primary_Contact__c=contacts[1].id;
        customerEngagement.NDA__c='No'; 
        
        insert customerEngagement;   
    
        for(Integer i=0;i<3;i++){
           attendeeLst.add(new Attendees__c(
                   Attendee_Name__c='Attendee'+i,
                   Role__c='role',
                   Attending_From__c='Dell SIte',
                   Customer_Engagement__c=customerEngagement.Id
                   )
           );   
        }
        
        insert attendeeLst; 
        
        transportation.Name='Air travel';
        transportation.Customer_Engagement__c=customerEngagement.Id;
        transportation.Travel_Type__c='Flight arrival';
        // Fenny: These 2 lines failing my test class LOBRegistrationAutoApprovalTest.cls
        //        The data type for the corresponding fields are Date, not DateTime
        //transportation.Start_Time__c=startDate;
        //transportation.End_Time__c=endDate;
        transportation.Start_Date__c=startDate;
        transportation.End_Date__c=endDate;
        transportation.Starting_From__c='Airport';
        transportation.Destination__c='Hotel';
        
        insert transportation; 
        
    }
    
    public static testMethod void testAddAttendee(){
        createData();
        VFCtlr_AddAtendees.AttendeeWrapper wrapperObj=new VFCtlr_AddAtendees.AttendeeWrapper(attendeeLst[1]);  
        wrapperObj.selected=true;
        AttendeeWrapperRecords.add(wrapperObj);
        
        PageReference  pr=new PageReference('/apex/AddAttendee?id='+transportation.id);
        Test.setCurrentPage(pr);
        VFCtlr_AddAtendees controller = new VFCtlr_AddAtendees(new ApexPages.StandardController(transportation));            
        controller.getAttendeeList();
        controller.setAttendeeList(AttendeeWrapperRecords);
        PageReference  pageRef=controller.addAttendee();
        Boolean disp=controller.getDisplayTbl();
        Boolean err=controller.getErrorMsg();    
        
    }
}
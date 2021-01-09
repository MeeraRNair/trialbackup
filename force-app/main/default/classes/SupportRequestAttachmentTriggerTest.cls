/*
 * Name            : SupportRequestAttachmentTriggerTest
 * Description     : test class for SupportRequestAttachmentTrigger and AttachmentUtilities
 * Revision  Name           Date                Description
 ----------------------------------------------------------------------------
 * 1.0                                          Created
 * 2.0      Krishnamoorthi  19-Aug-2015         CR 11835: To update the field "Attachment Count" in Support Request 
                                                whenever an Attachment is added or deleted 
 */

@isTest
private class SupportRequestAttachmentTriggerTest{
static User user;
static Account account;
static Opportunity testOpportunity;
public static Support_Request__c SupportRequest;
public static Attachment attach =new Attachment ();

    static testMethod void test_attachmentyes() {  
       createTestData();
       test_sowyes();
    } 
    
    static testMethod void test_attachmentno() {  
       createTestData();
       test_sowno();
    } 
    
    public static void createTestData(){    
        
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep' order by name limit 1 ];        
        UserRole userRole= [select id, name from userrole where name like 'WW_Exec' order by name limit 1];
                 
        user = new User( Username='test' + System.currentTimeMillis() + '@test.com',   
                                Alias = 'test',
                                Email='test' +'@dell.com',                               
                                FirstName='Tfirst',                               
                                LastName='TLast',                                
                                ProfileId = userProfile.Id, 
                                UserRoleId = userRole.Id,
                                LanguageLocaleKey='en_US',                               
                                LocaleSidKey='en_US',                       
                                EmailEncodingKey='UTF-8',      
                                TimeZoneSidKey='America/Los_Angeles',                               
                                Badge_Number__c='TEST12345' );                          
                       
                 
                         
        insert user;         
     /*   System_Behavior_Bypasser__c sbb = System_Behavior_Bypasser__c.getInstance(user.id);
		sbb.Bypass_Opportunity_VRs__c = true; 
        //Create Account
      account=new Account(name='Test Account');
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                                  MailingCountry='test',AccountId=account.Id,Phone='12345');
         
        //insert account;
        //Create Opportunity
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];         
        
        testOpportunity = new Opportunity(RecordTypeId=rectype.Id,
                                        Name='Test Opportunity', AccountId= account.Id, 
                                        CurrencyIsoCode='USD',Type='Deal/Bid Direct', 
                                        Quest_Software_Contact__c= con.id,
                                        CloseDate= system.today(),
                                        Solution_Type__c='Business Processing',StageName='Plan - 1%');   */
        //insert testOpportunity;                                
        
        System.RunAs(user){ 
            TriggerExecutionController.setSkipAllTriggers(true);

            account=new Account(name='Test Account');  
            insert account;   
            Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                                   MailingCountry='test',AccountId=account.Id,Phone='12345',Decision_Making_Role__c='Business User');
            insert con;
            
           // Boolean bChecked = sbb.Bypass_Opportunity_VRs__c;
            RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1]; 
            
            testOpportunity = new Opportunity(RecordTypeId=rectype.Id,
                                        Name='Test Opportunity', AccountId= account.Id, 
                                        CurrencyIsoCode='USD',Type='Deal/Bid Direct', 
                                        Quest_Software_Contact__c= con.id,
                                        Forecast_Category_Override__c = 'Test',      
                                        CloseDate= system.today(),
                                        Solution_Type__c='Business Processing',StageName='Plan - 1%');   
            insert testOpportunity; 
    }
         
        //ID CstmSolnEnggSprtRT=IdLookupUtils.getRecordTypeId('Request PG Custom Solutions Engineering  Support','Support_Request__c', true); 
        List<RecordType> rectypeSR=[Select Name, Id From RecordType where Name='Request PG Custom Solutions Engineering Support' AND SobjectType='Support_Request__c' Limit 1];
        SupportRequest=new Support_Request__c(
                                            RecordTypeId=rectypeSR[0].id,
                                            Opportunity__c=testOpportunity.Id,
                                            Buying_Power__c=1000,
                                            Request_Type__c = 'CSE',
                                            Pre_Post_Sales__c = 'Pre-Sales',
                                            Sales_Type__c = 'Retention',
                                            NDA__c = 'NA',
                                            Request_Description__c = 'testreq',
                                            Level_of_Support__c = 'other',
                                            CFI__c = 'No',
                                            Customer_Facing_SOW_needed__c = 'No',
                                            OEM_Request__c = 'No',
                                            Export_Compliant__c = 'No',
                                            Overall_Situation__c = 'testover',
                                            Receive_Notification__c = 'No',
                                            Scope__c = 'testscope',
                                            Status__c = 'Unassigned',
                                            Account_Executive__c = user.id,
                                            Solution_Architect_Lookup__c = user.id,
                                            Customer_Contact_Name__c ='test customer',
                                            Customer_Address__c ='test add',
                                            Customer_Email__c ='test@test.com',
                                            Security_Clearance__c ='Yes',                 
                                            Customer_Phone_Number__c = '0123333445', 
                                            Engagement_Type__c ='AIM POD Demo', 
                                            Cost_Center_Number__c='0123344556',                                 
                                            Primary_Competitor__c='test competitor', 
                                            Requested_By_Phone__c ='0128899887', 
                                            Operating_Systems_List__c = 'TestOp1', 
                                            Platform_List__c = 'TestPlatform',
                                            Network_Switches_List__c = 'TestNetwork',
                                            Peripherals_List__c = 'TestPeripherals',
                                            Storage_List__c = 'TestStorage',
                                            HBA_List__c = 'TestHba',
                                            Solution_Architect__c = 'Yes'
                                            );
                                           
       Sales_Motion_User_Role__c SMUserRole=new Sales_Motion_User_Role__c(                                       
                                            Username__c=user.id,      
                                            name='SM User Role Test+i',        
                                            CurrencyIsoCode='USD',
                                            Role__c='Project Manager' );
                                                       
  
                            
        //insert SupportRequest;
        //test.startTest();
        //test.startTest();
        System.RunAs(user){ 
           
            insert SupportRequest;
            insert SMUserRole;

        }
       // test.stopTest();
      }
      
    static void test_sowyes() {
 
   test.startTest();
    System.RunAs(user){ 
    GlobalVariables.SM_SOC_ISINSERT = false;
            SupportRequest.Send_SOW_to_PM__c = 'Yes';
            update SupportRequest;
            String filecontent='This is a test attachment'; 
            attach.parentId=SupportRequest.id;
            attach.name = 'TestAttach';
            attach.body = Blob.valueOf(filecontent);
            insert attach;
            
   test.stopTest();         
    }
         
}

     static void test_sowno() {
     test.startTest();
     System.RunAs(user){ 
     GlobalVariables.SM_SOC_ISINSERT = false;
            SupportRequest.Send_SOW_to_PM__c = 'No';
            update SupportRequest;
            String filecontent='This is a test attachment'; 
            attach.parentId=SupportRequest.id;
            attach.name = 'TestAttach';
            attach.body = Blob.valueOf(filecontent);
            try{
            insert attach;
            }
            catch(Exception e){
                system.debug('######################-Got Validation error in test class:--'+e.getmessage());
            }
            
     test.stopTest();         
    }
     }
     
     /*
     v2.0 Changes - Start
     To update the field "Attachment Count" in Support Request. The below method will cover the code in
     SupportRequestAttachmentTrigger and
     AttachmentUtilities
     */
     static testMethod void updateSRAttachmentCount() {
         
        Account testAccount = new Account(Name='testAccount');     
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testAccount; 
        
        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = '10%';
        testOpp.Forecast_Category_Override__c = 'Test';
        testOpp.CloseDate = System.Today();
        insert testOpp;
        
        Contact testContactObjt= new Contact(AccountID = testAccount.ID, Email = 'Email_115@dellTeam.Com', FirstName = 'TestContact', LastName = '1', Title='VP',MailingStreet='123 Main', MailingCity='Peoria', MailingState='IL', MailingCountry='US', MailingPostalCode='33333',Phone='3213213211',MobilePhone='3213213211',Fax='3213123211',Status__c = 'Marketing Suspect');      
        insert testContactObjt;             
        //Get  Request Custom Service Support Record type id
        Id  RCSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);    

        Support_Request__c SR = new Support_Request__c(RecordTypeId = RCSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'Yes',
                                    Engagement_Time_Frame__c = System.Today() + 10, Project_Type__c = 'CWS', Project_Duration_months__c = 2, 
                                    Decision_Date__c = System.Today() + 10, Primary_Work_Delivery_Language__c = 'English',
                                    Custom_Service_Support__c = 'Custom Service Solution', Comments__c = 'Test Comments', Deliverable_Due_Date__c = System.Today() + 15, Customer_Contact_InformationName__c = testContactObjt.Id, Suggested_Delivery_Method__c = 'FastTrack',
                                    Solution_Architect_Status__c = 'Resource Requested', Support_Owner_Team_Role__c = 'Services Intake Manager');
        Test.startTest();
        insert SR;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        List<Attachment> aList = new List<Attachment>();
        String filecontent='This is a test attachment'; 
        Attachment a =new Attachment(name = 'TestAttach', parentId = SR.Id, body = Blob.valueOf(filecontent));
        aList.add(a);

        Attachment a1 =new Attachment(name = 'TestAttach', parentId = SR.Id, body = Blob.valueOf(filecontent));
        Attachment a2 =new Attachment(name = 'TestAttach', parentId = SR.Id, body = Blob.valueOf(filecontent));
        Attachment a3 =new Attachment(name = 'TestAttach', parentId = SR.Id, body = Blob.valueOf(filecontent));
        Attachment a4 =new Attachment(name = 'TestAttach', parentId = SR.Id, body = Blob.valueOf(filecontent));
        aList.add(a1);
        aList.add(a2);
        aList.add(a3);
        aList.add(a4);
    
        insert aList;
        
        Support_Request__c SR2 = [SELECT Id, Attachment_Count__c FROM Support_Request__c WHERE Id =: SR.Id];
        System.assertEquals(5, SR2.Attachment_Count__c); //Check the Attachment_Count__c is increased by 1
        
        delete aList;
        Support_Request__c SR3 = [SELECT Id, Attachment_Count__c FROM Support_Request__c WHERE Id =: SR2.Id];
        System.assertEquals(0, SR3.Attachment_Count__c);//Check the Attachment_Count__c is decreased by 1
        
        Test.stopTest();

     }

}
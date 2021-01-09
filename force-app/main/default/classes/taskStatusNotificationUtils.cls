public class taskStatusNotificationUtils{

/*---------------------------------------------
Description: helper class for the afterUpdateTaskTrigger, contains methods to send notification mails 
             to the associated team members(having specified team roles) on change in status of a task.(CR# 0060)
    
Version: 1.0 
    
Author: Krishna / Meera

History:
    1.0 - 24-Nov-2008: Creation.
    2.0 - 19-Jul-2011: REL12.10 CR6493 Sales Role Change (Technical Sales Rep -> Inside Product Specialist)
    3.0 - 29-Sep-2011: REL12.10 CR6493-0182 Sales Role Change (Cross Domain Sales Engineer -> Customer System Engineer, 
                                            Inside Product Specialist -> Technical Sales Rep)
    4.0 - 17-Oct-2011: REL12.10 CR6493-0182 Sales Role Change (Customer System Engineer -> System Consultant)
    5.0 - 31-Jan-2013: R14.2 Fix for UAT defect #57062 to fetch the correct sandbox base URL -- (Krishnamoorthi)  
    6.0 - 27-Jul-2017: incorporate the new GCCS enterprise roles which will act like AE’s and ISR’s do for commercial    
    7.0 - 09-Aug-2017: CR 14764 - Updated the logic to get Production URL dynamically                                   
---------------------------------------------*/

    /*-----Class variables------*/
    
    //List of team roles to which the notifications have to be sent.   
    //6.0 
    static List<String>  eligibleTeamRoles =new List<String> {System.Label.Account_Executive,
                                                       System.Label.Inside_Sales_Rep,
                                                       System.Label.Technical_Sales_Rep,   
                                                       System.Label.System_Consultant,   
                                                       System.Label.Client_Compute_Sales_Exec,
                                                       System.Label.Client_Compute_Inside_Sales_Rep};
                                                       
    
   
    
    /*-----future Method------*/
    @future
    public static void sendNotificationForThisTask(Id TaskId, String taskSub, String taskStatus, String WhatId,String WhoId){
        
        system.debug('##KP: inside future method, processing task : '+ TaskId);
        
        string BASE_URL_FOR_CURRENT_ENVIRONMENT;
       
       if(UserInfo.getOrganizationId() == '00D300000006urqEAA')  
           // BASE_URL_FOR_CURRENT_ENVIRONMENT = system.Label.Base_URL_for_Production;  //for PRODUCTION env 
            BASE_URL_FOR_CURRENT_ENVIRONMENT = URL.getSalesforceBaseUrl().toExternalForm();// CR 14764 -- Updated Production URL dynamically

        else
            //BASE_URL_FOR_CURRENT_ENVIRONMENT = system.Label.Base_URL_for_Sandbox;  //for SANDBOX env 
            BASE_URL_FOR_CURRENT_ENVIRONMENT = URL.getSalesforceBaseUrl().toExternalForm();// Rev 5.0 -- to fetch the correct sandbox base URL
 
        
        
        
        String eMailSubject = 'Task status notification';
        String eMailTextBody = 'This e-mail is to notify you that the status of the task "'+ TaskSub +
                               '" has been updated to "'+ taskStatus+'"'+
                               '\n\nThe task can be found here: '+ BASE_URL_FOR_CURRENT_ENVIRONMENT + '/'+ TaskId +
                               '\n\nこのメールは件名「' + TaskSub + '」のToDoのステータスが「' + taskStatus + '」に変更されたことを通知します。' +
                               '\nToDoは次のリンクよりご覧いただけます：　' + BASE_URL_FOR_CURRENT_ENVIRONMENT + '/'+ TaskId;
                               
        //Map used to avoid resending of mail to the same email.
        Map<String,String> notifiedAddressesMap = new Map<String,String>();
        
        
        if (WhatId != null){ 
            
            //Checks if WhatId is an Account Id
            if (WhatId .startsWith('001')){          
                system.debug('##KP: Task '+TaskId+' is related to Account :'+ WhatId);
                //calls method 
                notifiyAccountTeamMembers(WhatId, eMailSubject, eMailTextBody, notifiedAddressesMap);
            }
            
            
            //Checks if WhatId is an Opportunity Id
            else if(WhatId .startsWith('006')){
                system.debug('##KP: Task '+TaskId+' is related to Opportunity :'+ WhatId);
                
                //calls method
                notifiyOpportunityTeamMembers(WhatId, eMailSubject, eMailTextBody, notifiedAddressesMap);   
            }           
            
        }//end of if (WhatId != null)
        


        //Checks if the WhoId is not null and is a Contact Id
        if (WhoId!= null &&  WhoId.startsWith('003') && ! reachedEmailLimit()){   
            
            system.debug('##KP: Task '+TaskId+' is related to a Contact :'+ WhoId);
            //Selects the AccountId of this contact     
            String AccountGUId = [select AccountId from Contact Where Id = :WhoId limit 1].AccountId;
            notifiyAccountTeamMembers(AccountGUId, eMailSubject, eMailTextBody, notifiedAddressesMap);
            
        } 
        
    }//end of method

    /*-----end of future Method------*/



    

    //Sends Notification mails to the Account team Members
    private static void notifiyAccountTeamMembers(String AccountGUId,String emailSub, String emailBody,Map<String,String> notifiedAddressesMap){

        system.debug('##KP: inside notifiyAccountTeamMembers method');
        
        List<string> eMailAddresslist = new List<string>();
        
        //selects the AccountTeamMembers to get the email Ids
        For(List<AccountTeamMember> AccTeamMemberList: [SELECT User.email FROM AccountTeamMember 
                                                        WHERE AccountId = :AccountGUId 
                                                        AND TeamMemberRole IN :eligibleTeamRoles 
                                                        AND User.email NOT IN :notifiedAddressesMap.KeySet()]){    
                                                                                                    
                
            For(AccountTeamMember AccTeamMemberItem: AccTeamMemberList){
            
                //to avoid resending to the same email Ids,a map records the email that has been notified.
                If (notifiedAddressesMap.get(AccTeamMemberItem.User.Email)==null){
                    eMailAddresslist.add(AccTeamMemberItem.User.Email);             
                    notifiedAddressesMap.put(AccTeamMemberItem.User.Email,'Yes');
                    system.debug('##KP: Added the email Id: '+ AccTeamMemberItem.User.Email);
                }
                
                
                If(eMailAddresslist.size()==10){                                          
                    //if the email invocation limit reached, just quit without sending.
                    if(reachedEmailLimit())
                        return;
                    
                    system.debug('##KP: Sending the notification');
                    
                    //sends notification emails.
                    emailUtils.sendTextEmail(eMailAddresslist, emailSub, emailBody);
                    system.debug('##KP: MAIL HAS BEEN SENT');
                    //clears the address list for preparing for next mail
                    eMailAddresslist.clear();
                    system.debug('##KP: Cleared the Address list');
                }
                
            }//end list-for-loop
          
        }//End query-For-loop
        
        If(eMailAddresslist.size()>0 && !reachedEmailLimit()){             
            emailUtils.sendTextEmail(eMailAddresslist, emailSub, emailBody);
            system.debug('##KP: FINAL MAIL HAS BEEN SENT');
        }
        
        system.debug('##KP: End of method: notifiyAccountTeamMembers');
    }  //end of method
        




    //Sends Notification mails to the Account team Members
    private static void notifiyOpportunityTeamMembers(String OpportunityGUId,String emailSub, String emailBody,Map<String,String> notifiedAddressesMap){

        system.debug('##KP: inside notifiyOpportunityTeamMembers method');
        
        List<string> eMailAddresslist = new List<string>();
        
        //selects the AccountTeamMembers to get the email Ids
        For(List<OpportunityTeamMember> OppTeamMemberList: [SELECT User.email FROM OpportunityTeamMember 
                                                            WHERE OpportunityId = :OpportunityGUId 
                                                            AND TeamMemberRole IN :eligibleTeamRoles 
                                                            AND User.email NOT IN :notifiedAddressesMap.KeySet()]){    
                                                                                                    
            For(OpportunityTeamMember OppTeamMemberItem : OppTeamMemberList){
                
                //to avoid resending to the same email Ids,a map records the email that has been notified.
                If (notifiedAddressesMap.get(OppTeamMemberItem.User.Email)==null){
                    eMailAddresslist.add(OppTeamMemberItem.User.Email);             
                    notifiedAddressesMap.put(OppTeamMemberItem.User.Email,'Yes');
                    system.debug('##KP: Added the email Id: '+ OppTeamMemberItem.User.Email);
                }
                
                
                If(eMailAddresslist.size()==10){                                          
                    //if the email invocation limit reached, just quit without sending.
                    if(reachedEmailLimit())
                        return;
                    
                    system.debug('##KP: Sending the notification');                 
                    emailUtils.sendTextEmail(eMailAddresslist, emailSub, emailBody);
                    system.debug('##KP: MAIL HAS BEEN SENT');
                    
                    //clears the address list for preparing for next mail
                    eMailAddresslist.clear();
                    system.debug('##KP: Cleared the Address list');
                }
              
            }//End list-For-loop
            
        }//End query-For-loop

        
        If(eMailAddresslist.size()>0 && !reachedEmailLimit()){             
            emailUtils.sendTextEmail(eMailAddresslist, emailSub, emailBody);
            system.debug('##KP: FINAL MAIL HAS BEEN SENT');
        }
        
        system.debug('##KP: End of method: notifiyOpportunityTeamMembers');
    }  //end of method
        
    
    
    
    
    
    //method which checks whether the email invocations limit has been reached.
    private static Boolean reachedEmailLimit(){
        
        system.debug('##KP: Checks Limit::(Email Limit,Total Invocations)= ('+ Limits.getLimitEmailInvocations()+','+ Limits.getEmailInvocations()+')');
        
        if (Limits.getEmailInvocations() >= Limits.getLimitEmailInvocations()){
            system.debug('##KP: LIMIT REACHED!');
            return true;
        }
        
        //else          
        return false;
          
    }


    /* ------------------TEST METHODS--------------------*/
    //Test method # 1: test notifiyAccountTeamMembers
    
   public static testMethod void Test_notifiyAccountTeamMembers(){
        
        system.debug('##KP: Start Test_notifiyAccountTeamMembers');
        
        //Create Test Data
        Account testAccount=new Account(name='testAccount');
        insert testAccount;
        
        //Adds new account team Members
        List<AccountTeamMember> AcTeamList= new List<AccountTeamMember>();
        AccountTeamMember AccTeamItem;
        //List<user> UserList = [SELECT Id, name FROM User WHERE IsActive = true LIMIT 15];       
        
        
        /*
        for(integer i=0;i < 15; i++){
            AccTeamItem= new AccountTeamMember(AccountId = testAccount.Id, UserId=UserList[i].Id, TeamMemberRole = 'Account Executive');
            AcTeamList.add(AccTeamItem);
        }
        */
        
        Map<String, String> sParams = new Map<String, String>();
        TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 15));
        sParams.put('str_TeamMemberRole','Account Executive' );
        sParams.put('str_AccountId', testAccount.id);
        AcTeamList = (List<AccountTeamMember>) TestDataGenerator.getObject(new AccountTeamMember(), 15, sParams, false);
        
        
        insert  AcTeamList;
        

        //creates new task                                      
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Task'];
        Task testTask=new Task( Subject='Test Task',Type='Internal Admin',
                                Status='Not Started',RecordTypeId=rectype.Id,Priority='High', 
                                WhatId=testAccount.id,OwnerId=UserInfo.getUserId(),
                                Email_Team_on_Status_Change__c=false);
        
      //  insert testTask;
        Map<string,string> notifiedAddresses = new Map<string,string>();
        
        Test.startTest();
        //calls the method.         
        notifiyAccountTeamMembers(testAccount.Id,'Test Subject','Test email Body',notifiedAddresses);
        Test.stopTest();
        
        
        system.debug('##KP: End Test_notifiyAccountTeamMembers');
        
    }//end of testmethod #1     
    
    
    
    //Test method # 2: test notifiyOpportunityTeamMembers   
    public static testMethod void Test_notifiyOpportunityTeamMembers(){
        TriggerExecutionController.setSkipAllTriggers(true);  
        system.debug('##KP: Start Test_notifiyOpportunityTeamMembers');
        
        //Create Test Data
        Account testAccount=new Account(name='testAccount');
        insert testAccount;
        
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId= rectype.Id, 
                                                        Name='Test Opportunity', AccountId= testAccount.Id, CurrencyIsoCode='USD',
                                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                                        Solution_Type__c='Business Processing', 
                                                        StageName='Plan - 1%');     
        
        insert testOpportunity;
        
    
        //Adds new Opportunity team Members
        List<OpportunityTeamMember> OpTeamList= new List<OpportunityTeamMember>();
        OpportunityTeamMember OppTeamItem;
       
       
        /*
        List<user> UserList = [SELECT Id, name FROM User WHERE IsActive = true LIMIT 15];       
        
        for(integer i=0;i < 15; i++){
            OppTeamItem= new OpportunityTeamMember(OpportunityId = testOpportunity.Id, UserId=UserList[i].Id, TeamMemberRole = 'Inside Sales Rep');
            OpTeamList.add(OppTeamItem);
        }
        */
        
        Map<String, String> sParams = new Map<String, String>();
        TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 15));
        sParams.put('str_TeamMemberRole','Account Executive' );
        sParams.put('str_OpportunityId', testOpportunity.id);
        OpTeamList = (List<OpportunityTeamMember>) TestDataGenerator.getObject(new OpportunityTeamMember(), 15, sParams, false);
        
        insert  OpTeamList;
        Map<string,string> notifiedAddresses = new Map<string,string>();

        
        Test.startTest();
        //calls the method.         
        notifiyOpportunityTeamMembers(testOpportunity.Id,'Test Subject','Test email Body',notifiedAddresses);
        Test.stopTest();        
        
        system.debug('##KP: End Test_notifiyOpportunityTeamMembers');
        
    }//end of testmethod #2     
    
    
    
    //Test method # 3: test the future method   
    public static testMethod void Test_FutureMethod(){
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        system.debug('##KP: Start Test_FutureMethod');        
        
        //List<user> UserList = [SELECT Id, name FROM User WHERE IsActive = true LIMIT 30];   
        
        //----Create new Account---------- 
        Account testAccount_No1=new Account(name='testAccount_No1');
        insert testAccount_No1;
        //-------------------
        
        //----Adds new account team Members to that Account----
        List<AccountTeamMember> AcTeamList= new List<AccountTeamMember>();
        AccountTeamMember AccTeamItem;          
        Map<String, String> sParams = new Map<String, String>();
        TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 30));
        sParams.put('str_TeamMemberRole','Account Executive' );
        sParams.put('str_AccountId', testAccount_No1.id);
        AcTeamList = (List<AccountTeamMember>) TestDataGenerator.getObject(new AccountTeamMember(), 30, sParams, false);
        /*
        for(integer i=0;i < 15; i++){
            AccTeamItem= new AccountTeamMember(AccountId = testAccount_No1.Id, UserId=UserList[i].Id, TeamMemberRole = 'Account Executive');
            AcTeamList.add(AccTeamItem);
        }
        */
        
        insert  AcTeamList;
        //-------------------
        
        //---creates one contact for that Account-------
        Contact testContact=new Contact(Status__c='Active', AccountId=testAccount_No1.Id, 
                                        EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                        Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');
        
        
        insert testContact;
        //-------------------
        
        //----Create an Opportunity----------       
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        Opportunity testOpportunity = new Opportunity(RecordTypeId= rectype.Id, 
                                                        Name='Test Opportunity', AccountId= testAccount_No1.Id, CurrencyIsoCode='USD',
                                                        Type='Deal/Bid Direct', CloseDate= system.today(), 
                                                        Solution_Type__c='Business Processing', 
                                                        StageName='Plan - 1%');     
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        insert testOpportunity;
        TriggerControlHandler.setOpportunityTriggersActive();
        //-------------------
    
        //----Adds new Opportunity team Members to that Opportunity----
        List<OpportunityTeamMember> OpTeamList= new List<OpportunityTeamMember>();
        OpportunityTeamMember OppTeamItem;
        
        /*        
        for(integer i = 15;i < 30; i++){
            OppTeamItem= new OpportunityTeamMember(OpportunityId = testOpportunity.Id, UserId=UserList[i].Id, TeamMemberRole = 'Inside Sales Rep');
            OpTeamList.add(OppTeamItem);
        }
        */
        sParams.clear();
        sParams.put('str_TeamMemberRole','Inside Sales Rep' );
        sParams.put('str_OpportunityId', testOpportunity.id);
        OpTeamList = (List<OpportunityTeamMember>) TestDataGenerator.getObject(new OpportunityTeamMember(), 30, sParams, false);
        
        
        insert  OpTeamList;
        //-------------------
        
        
        //creates new task                                      
        rectype=[Select Name, Id From RecordType where Name='Standard Task'];
        Task testTask=new Task( Subject='Test Task',Type='Internal Admin',
                                Status='Not Started',RecordTypeId=rectype.Id,Priority='High', 
                                WhatId=testOpportunity.Id,OwnerId=UserInfo.getUserId(),
                                Email_Team_on_Status_Change__c=false);
        
       // insert testTask;
        
        
        Test.startTest();
        //future method is called.
    //    sendNotificationForThisTask(testTask.Id, 'Test Task', 'In Progress', testOpportunity.Id , testContact.Id);
        Test.stopTest();        
             
        system.debug('##KP: End Test_FutureMethod');
        
    }//end of testmethod #3     
   

    //Test method # 4: test reachedEmailLimit: returns false    
    public static testMethod void Test_reachedEmailLimit_Case_false(){
        
        system.debug('##KP: Start Test_reachedEmailLimit_Case_false');        
        
        Test.startTest();
        System.assertEquals(false,reachedEmailLimit());
        Test.stopTest();        
        
        system.debug('##KP: End Test_reachedEmailLimit_Case_false');
        
    }//end of testmethod #4     
    
    
    //Test method # 5: test reachedEmailLimit: returns true
    public static testMethod void Test_reachedEmailLimit_Case_true(){
        
        system.debug('##KP: Start Test_reachedEmailLimit_Case_true');    
        
        Test.startTest();
        List<String> recepients=new String[]{'meera.rnair@ust-global.com','Krishnaprasad.Palamangalam@ust-global.com'};
        for(Integer count=0;count<10;count++){          
            emailUtils.sendTextEmail(recepients,'Test email_'+ count, 'This is to test the sendTextNotificationEmail method');
        }
        System.assertEquals(true,reachedEmailLimit());
        Test.stopTest();   
        
        system.debug('##KP: End Test_reachedEmailLimit_Case_true');
        
    }//end of testmethod #5     
    

    //Test method # 6: test Task Trigger : No Exception
    public static testMethod void Test_TaskTrigger_No_Exception(){
        
        system.debug('##KP: Start Test_TaskTrigger_No_Exception');        
        
        //Create Test Data
        integer i;
        Account testAccount=new Account(name='testAccount');
        insert testAccount;
        
        //Adds 100 account team Members for this Account
        List<AccountTeamMember> AcTeamList= new List<AccountTeamMember>();
        AccountTeamMember AccTeamItem;
        Map<String, String> sParams = new Map<String, String>();
        TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 100));
        sParams.put('str_TeamMemberRole','Account Executive' );
        sParams.put('str_AccountId', testAccount.id);
        AcTeamList = (List<AccountTeamMember>) TestDataGenerator.getObject(new AccountTeamMember(), 100, sParams, false);
        
        insert  AcTeamList;

        //creates a new task                                        
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Task'];
        Task testTask=new Task( Subject='Test Task',Type='Internal Admin',
                                Status='Not Started',RecordTypeId=rectype.Id,Priority='High', 
                                WhatId=testAccount.id,OwnerId=UserInfo.getUserId(),
                                Email_Team_on_Status_Change__c=false);
            
    
       insert testTask;
        
        //updates the status of this new task               
        testTask.Email_Team_on_Status_Change__c = true;
        testTask.Status='In Progress';
            
        Test.startTest();
        //upadtes the Tasks
        update testTask;
        Test.stopTest();
                        
        system.debug('##KP: End Test_TaskTrigger_No_Exception');
        
    }//end of testmethod #6


//Test method # 7: test Task Trigger : hits the future execution limit
    public static testMethod void Test_TaskTrigger_hit_Future_limt(){
        
       // ProcessFlowTriggerController.isTest = true;
       TriggerExecutionController.setSkipAllTriggers(true); 
        system.debug('##KP: Start Test_TaskTrigger_hit_Future_limt');        
        
        //Create Test Data
        integer i;
        Account testAccount=new Account(name='testAccount');
        insert testAccount;
        
        //Adds 150 account team Members for this Account
        List<AccountTeamMember> AcTeamList= new List<AccountTeamMember>();
        AccountTeamMember AccTeamItem;
        
        /*
        List<user> UserList = [SELECT Id, name FROM User WHERE IsActive = true LIMIT 150];      
        
        for(i=0;i < 100; i++){
            AccTeamItem= new AccountTeamMember(AccountId = testAccount.Id, UserId=UserList[i].Id, TeamMemberRole = 'Account Executive');
            AcTeamList.add(AccTeamItem);
        }
        */
        Map<String, String> sParams = new Map<String, String>();
        TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 100));
        sParams.put('str_TeamMemberRole','Account Executive' );
        sParams.put('str_AccountId', testAccount.id);
        AcTeamList = (List<AccountTeamMember>) TestDataGenerator.getObject(new AccountTeamMember(), 100, sParams, false);
        
        
        insert  AcTeamList;
        AcTeamList.clear();
        
        TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 50));
        AcTeamList = (List<AccountTeamMember>) TestDataGenerator.getObject(new AccountTeamMember(), 50, sParams, false);
        
        /*
        for(i=100;i < 150; i++){
            AccTeamItem= new AccountTeamMember(AccountId = testAccount.Id, UserId=UserList[i].Id, TeamMemberRole = 'Account Executive');
            AcTeamList.add(AccTeamItem);
        }
        */
        
        insert  AcTeamList;
        

        //creates 15 new tasks                                      
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Task'];
        List<Task> taskList=new List<Task>(); 
        for(i=0;i < 15; i++){           
            Task testTask=new Task( Subject='Test Task'+i,Type='Internal Admin',
                                    Status='Not Started',RecordTypeId=rectype.Id,Priority='High', 
                                    WhatId=testAccount.id,OwnerId=UserInfo.getUserId(),
                                    Email_Team_on_Status_Change__c=false);
            
            taskList.add(testTask);
        }
        insert taskList;
        
        //updates the status of these 15 new tasks 
        for(i=0;i < 15; i++){           
            taskList[i].Email_Team_on_Status_Change__c = true;
            taskList[i].Status='In Progress';           
        }
                
        Test.startTest();
        //upadtes the Tasks
        try{
            update taskList;
        }
        catch(exception e){
            System.assert(e.getMessage().contains('limit the Batch'));
        }
        
        Test.stopTest();
                        
        system.debug('##KP: End Test_TaskTrigger_hit_Future_limt');
        
    }//end of testmethod #7
} //end of class
@isTest(SeeAllData=true)  
private class beforeUpdateSupportRequesttest{
static testmethod  void TestAccept(){
        
        Id partnerAccountRecordTypeId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Id supportReqRTid= IdLookupUtils.getRecordTypeId('Request PG Custom Solutions Engineering Support','Support_Request__c',true);
        Id supportReqRTid2= IdLookupUtils.getRecordTypeId('Request Solution Operation Center Support','Support_Request__c',true);
        Id supportReqRTid3= IdLookupUtils.getRecordTypeId('Request Specialist Support','Support_Request__c',true);
        Account acc=new Account(name='test account support Request', RecordTypeId=partnerAccountRecordTypeId);
        insert acc;
        TriggerExecutionController.setSkipOpportunityTriggers(true); 
         TriggerExecutionController.setSkipOpportunitySplitTriggers(true); 
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity',true);
        Opportunity opp=new Opportunity (name='teset opp SR', Total_Expected_Dell_Revenue__c=5000,CloseDate=System.Today(),Engagement_Type__c='Public Tender',
            Solution_Type__c='Campus',Solution_Name__c='Wired Chassis Switches',Justification_Statement__c='test Justification_Statement__c',
            End_User_Account_Name__c='test End_User_Account_Name__c', End_User_Mailing_City__c='mailing city',End_User_Mailing_State_Province_Region__c='mailing state', End_User_Mailing_Country__c='INDIA',Save_End_Customer_to_my_list__c='Yes',End_User_First_Name__c='end fist name',End_User_Last_Name__c='end last name',End_User_Email__c='test@gmail.com',Is_the_Customer_Part_of_a_Larger_Group__c='Yes',StageName='Plan - 1%');
        insert opp;
        TriggerExecutionController.setSkipOpportunityTriggers(false); 
          User testUser=new User(Username='testvaliduser2' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    Title='GCC Program Manager', 
                                    ProfileId = UserInfo.getProfileId(), 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test2'+System.currentTimeMillis());
                                    
        insert testUser;
        
        List<Support_Request__c> supportRequestRecords=new List<Support_Request__c>();
         
       
        support_request__c reqspecsupportPG=new Support_Request__c(RecordTypeId=supportReqRTid,Opportunity__c=opp.Id,
                    Request_Type__c='CSE',NDA__c='no',Pre_Post_Sales__c='pre-sales',Sales_Type__c='retention',
                    Request_Description__c='jhgdfgh',Target_Due_Date__c=System.today(),
                    Level_of_Support__c='other',CFI__c='yes',Customer_Facing_SOW_needed__c='yes', 
                    Export_Compliant__c='yes',Standardized_Benchmark__c='yes',OEM_Request__c='yes',
                    Receive_Notification__c='yes',Overall_Situation__c='lkjhggf',Scope__c='kjhhgfhjh',
                        Account_Executive__c=UserInfo.getUserId(),
                    System_Consultant__c=UserInfo.getUserId());//Status__c='In Quote');
        supportRequestRecords.add(reqspecsupportPG);
        
         support_request__c reqspecsupportRSO = new Support_Request__c(RecordTypeId=supportReqRTid2, Opportunity__c=opp.Id,
                    Customer_Number__c='8758454',Customer_Due_Date_for_Proposal__c=System.today(),
                    Receive_Notification__c='yes',Consolidated_Invoice_Required__c='yes',
                   Additional_Notes_Comments__c='lkjhh',Status__c='New');
         supportRequestRecords.add(reqspecsupportRSO );
                   
         Support_Request__c reqSpecSupportRSS = new Support_Request__c(RecordTypeId=supportReqRTid3, Opportunity__c=opp.Id, 
                     Receive_Notification__c='No',Requestor_Comments__c='request comments', 
                    Specialist_Role__c='test spec role',Specialist_Name__c=testUser.Id, status__c='Engagement complete');
      supportRequestRecords.add(reqSpecSupportRSS );
       
    
        //Temporary Fix to improve test coverage
        Sales_Motion_User_Role__c som = new Sales_Motion_User_Role__c (Username__c = UserInfo.getUserId(), Role__c = 'SOC Intake Manager');
        insert som;
        
        Set<Id> SHIdSet = new Set<Id> ();
        List<Support_Request__History> sh = new List<Support_Request__History> ();
        sh = [SELECT ParentId FROM Support_Request__History WHERE Field = 'Status__c' AND Parent.RecordTypeId = :supportReqRTid AND Parent.Status__c = 'In Review' ORDER BY CreatedDate DESC LIMIT 1];
        if (sh.size() > 0) SHIdSet.add(sh[0].ParentId);
        
        sh = [SELECT ParentId FROM Support_Request__History WHERE Field = 'Status__c' AND Parent.RecordTypeId = :supportReqRTid2 AND Parent.Status__c = 'Proposal Submitted' ORDER BY CreatedDate DESC LIMIT 1];
        if (sh.size() > 0) SHIdSet.add(sh[0].ParentId);
           
        sh = [SELECT ParentId FROM Support_Request__History WHERE Field = 'Status__c' AND Parent.RecordTypeId = :supportReqRTid2 AND Parent.Status__c = 'Order Mgmt' AND Parent.PO_Receipt__c != null ORDER BY CreatedDate DESC LIMIT 1];
        if (sh.size() > 0) SHIdSet.add(sh[0].ParentId);
        
        sh = [SELECT ParentId FROM Support_Request__History WHERE Field = 'Status__c' AND Parent.RecordTypeId = :supportReqRTid2 AND Parent.Status__c = 'Planning' ORDER BY CreatedDate DESC LIMIT 1];
        if (sh.size() > 0) SHIdSet.add(sh[0].ParentId);
          
        sh = [SELECT ParentId FROM Support_Request__History WHERE Field = 'Status__c' AND Parent.RecordTypeId = :supportReqRTid3 ORDER BY CreatedDate DESC LIMIT 1];
        if (sh.size() > 0) SHIdSet.add(sh[0].ParentId);
        
        supportRequestRecords.addall([SELECT Id, Status__c, RecordTypeId FROM Support_Request__c WHERE Id IN :SHIdSet]);          
        //End
       
        Test.startTest();
        //insert supportRequestRecords;
        upsert supportRequestRecords;
        Test.stopTest();
       
      
        
        
        
}   

}
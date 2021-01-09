@isTest
private class ManageCSESupportRequestTest{
    static Boolean SM_SOC_ISINSERT = false;
    
    static TestMethod  void test_SupportRequestTrigger(){
        
        List<User> testUserList = new List<User>();        
        List<Sales_Motion_User_Role__c> SMUserRoleList =new List<Sales_Motion_User_Role__c >();
        
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep' order by name limit 1 ];        
        UserRole userRole= [select id, name from userrole where name like 'WW_Exec' order by name limit 1];
        
        for (integer i=0; i<2;i++){            
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',   
                                 Alias = 'test'+i,
                                 Email='test'+ i +'@dell.com',                               
                                 FirstName='Tfirst'+i,                               
                                 LastName='TLast'+i,                                
                                 ProfileId = userProfile.Id, 
                                 UserRoleId = userRole.Id,
                                 LanguageLocaleKey='en_US',                               
                                 LocaleSidKey='en_US',                       
                                 EmailEncodingKey='UTF-8',      
                                 TimeZoneSidKey='America/Los_Angeles',                               
                                 Badge_Number__c='TEST12345'+i );                          
            testUserList.add(user);           
        }           
        
        insert testUserList;         
        
        //Create Account
        Account account=new Account(name='Test Account');
        //insert account;
        //Create Opportunity
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];         
       
        Opportunity testOpportunity = new Opportunity(RecordTypeId=rectype.Id,
                                        Name='Test Opportunity', AccountId= account.Id, 
                                        CurrencyIsoCode='USD',Type='Deal/Bid Direct',
                                        Forecast_Category_Override__c = 'Test',      
                                        CloseDate= system.today(),
                                        Solution_Type__c='Business Processing',StageName='Plan - 1%'); 
        //insert testOpportunity;                                
        test.startTest(); 
        System.RunAs(testUserList[0]){  
            TriggerExecutionController.setSkipAllTriggers(true);
            insert account;
            insert testOpportunity;
            
        }    
        //ID CstmSolnEnggSprtRT=IdLookupUtils.getRecordTypeId('Request PG Custom Solutions Engineering  Support','Support_Request__c', true); 
        List<RecordType> rectypeSR=[Select Name, Id From RecordType where Name='Request PG Custom Solutions Engineering Support' AND SobjectType='Support_Request__c' Limit 1];
        Support_Request__c SupportRequest=new Support_Request__c(
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
            Account_Executive__c = testUserList[0].id,
            Solution_Architect_Lookup__c = testUserList[0].id,
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
            Solution_Architect__c = 'Yes'
        );
        
        //insert SupportRequest;
        
        for (integer i=0; i<2;i++){
            Sales_Motion_User_Role__c SMUserRole=new Sales_Motion_User_Role__c(                                       
                Username__c=testUserList[i].Id,      
                name='SM User Role Test+i',        
                CurrencyIsoCode='USD'   );
            
            if(i==0)SMUserRole.Role__c='CSE Intake Manager';  
            if(i==2)SMUserRole.Role__c='Business Consultant';       
            SMUserRoleList.add(SMUserRole);                                                  
        }   
        
        Sales_Motion_CS__c cstmSetting=new Sales_Motion_CS__c();
        cstmSetting.Name='CSE Intake Manager';
        cstmSetting.Editable__c='Project_Priority__c, Category__c, Status__c';
        
        //insert SMUserRoleList;
        
        System.RunAs(testUserList[0]){ 
            
            insert SupportRequest;
            insert SMUserRoleList;
            insert cstmSetting;
            
            
        }
        
        System.RunAs(testUserList[0]){
            GlobalVariables.SM_SOC_ISINSERT = false;
            SupportRequest.Project_Manager__c=null;
            SupportRequest.Status__c ='In Review'; 
            try{
                update SupportRequest;
            }catch(Exception e){
                system.debug('######################-Got Validation error in test class:--'+e.getmessage());
            }
        }
        
        
        
        System.RunAs(testUserList[0]){
            GlobalVariables.SM_SOC_ISINSERT = false;
            SupportRequest.Status__c ='In Quote'; 
            try{
                update SupportRequest;
            }catch(Exception e){
                system.debug('######################-Got Validation error in test class:--'+e.getmessage());
            }
        }
        
        System.RunAs(testUserList[0]){
            GlobalVariables.SM_SOC_ISINSERT = false;
            SupportRequest.Status__c ='In Process'; 
            try{
                update SupportRequest;
            }catch(Exception e){
                system.debug('######################-Got Validation error in test class:--'+e.getmessage());
            }
        } 
        test.stopTest();     
    }
}
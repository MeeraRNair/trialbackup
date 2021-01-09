@isTest
public class AccountPlanFieldPopulatorTest {
    
    //static User userRecord;
    static Integer inti;

    private static testmethod void createAccountforAGLandNONAGL(){
        
      /*1) Create  account with focus aaccount = blank
        1.1) create ap for account for FY19   (expected AGL 19 shud be blank)*/
      TriggerExecutionController.setSkipAllTriggers(true); 
      
      //1) Create  account with focus aaccount = blank
      Account a = new Account(name = 'Test Account',Focus_Account__c = 'Account Growth Lab');
      insert a;      
      
      Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
      
      User salesMgr = new User(Username = 'TestValidUserAccPlan2@dell.com',
                                Alias = 'Test', 
                                Email = 'Test212@dell.com', 
                                LastName = 'Test22',
                                Title = 'GCC Program Manager', 
                                ProfileId = profile.Id, 
                                LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_US', 
                                EmailEncodingKey = 'UTF-8', 
                                TimeZoneSidKey = 'America/Los_Angeles',
                                Country = 'US',
                                Badge_Number__c = 'Test' + System.currentTimeMillis());
        insert salesMgr;
        
       List<SFDC_Acct_Plan__c> listAP = new List<SFDC_Acct_Plan__c>();
       RecordType rectype = [SELECT id,DeveloperName,Name FROM RecordType WHERE Name = 'Direct Relationship Account Plan'];     
        //create fy19 AP for each NON AGL account 
       SFDC_Acct_Plan__c ap = new SFDC_Acct_Plan__c(Name='Test AP ', Account__c=a.id, Plan_Starting_Fiscal_Year__c = 'FY19', RecordTypeId=rectype.id, Sales_Manager__c=salesMgr.id);
       insert ap;
       
       SFDC_Acct_Plan__c ap2 = new SFDC_Acct_Plan__c(Name='Test AP ', Account__c=a.id, Plan_Starting_Fiscal_Year__c = 'FY20', RecordTypeId=rectype.id, Sales_Manager__c=salesMgr.id);
       insert ap2;
       
       SFDC_Acct_Plan__c ap3 = new SFDC_Acct_Plan__c(Name='Test AP ', Account__c=a.id, Plan_Starting_Fiscal_Year__c = 'FY21', RecordTypeId=rectype.id, Sales_Manager__c=salesMgr.id);
       insert ap3; 
       
         
       
        //1.1) INSERT fy19 ap for each account   (expected AGL 19 shud be blank)
        Test.startTest(); 
        
        SFDC_Acct_Plan__c accPlan= [select id, Focus_Account__c, Account__c,RecordType.Name, Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Id = :ap.id and RecordType.Name != 'Account Plan Lite'];
        SFDC_Acct_Plan__c accPlan2= [select id, Focus_Account__c, Account__c,RecordType.Name, Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Id = :ap2.id and RecordType.Name != 'Account Plan Lite'];
        SFDC_Acct_Plan__c accPlan3= [select id, Focus_Account__c, Account__c,RecordType.Name, Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Id = :ap3.id and RecordType.Name != 'Account Plan Lite'];                    
        List<SFDC_Acct_Plan__c> listAccPlan = [select id, Focus_Account__c, Account__c,RecordType.Name, Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Account__c = :a.id and RecordType.Name != 'Account Plan Lite'];
        Map<id,SFDC_Acct_Plan__c> mapAccPlan = new Map<id,SFDC_Acct_Plan__c>();
        mapAccPlan.put(accPlan.id,accPlan);
        mapAccPlan.put(accPlan2.id,accPlan2);       
        mapAccPlan.put(accPlan3.id,accPlan3);
        
        AccountPlanFieldPopulator.updateAGLStatusforAP(listAccPlan,mapAccPlan);  
        AccountPlanFieldPopulator.refreshAGLStatusforAP(listAccPlan,mapAccPlan);      
        
        SFDC_Acct_Plan__c accP = [select id, Focus_Account__c, Account__c,RecordType.Name, Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Account__c = :a.id and RecordType.Name != 'Account Plan Lite' Limit 1];
                             
          //if(accp.Focus_Account__c == 'Account Growth Lab' || accp.Focus_Account__c == 'Partner Growth Lab'){
                if(accPlan.Plan_Starting_Fiscal_Year__c == 'FY19'){
                    ap.AGL_Status_FY19__c = 'AGL 2019';
                }
                if(accPlan2.Plan_Starting_Fiscal_Year__c == 'FY20'){
                    ap2.AGL_Status_FY20__c = 'AGL 2020';
                }
          //}          
            system.debug('ap.AGL_Status_FY19__c:'+ap.AGL_Status_FY19__c);
          system.debug('ap2.AGL_Status_FY19__c:'+ap2.AGL_Status_FY19__c);
            
            update ap;
            System.assertEquals('AGL 2019', ap.AGL_status_FY19__c);
            System.assertEquals('AGL 2020', ap2.AGL_status_FY20__c);
            
             
    }  //end first method

    } // end class
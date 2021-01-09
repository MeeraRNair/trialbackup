@isTest
public class DealSummaryEventTriggerHandler_Test{
    public static Contact con = new Contact();

    //Added custom settings to populate StageName values.
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
    }
    
      
public static testmethod void  testDealSummaryEvents(){
    
     Id idendUserAccountRT = [select Name from RecordType where Name ='End-User Account' limit 1].Id;
     Id idpartnerAccountRT = [select Name from RecordType where Name ='Partner Account' limit 1].Id;
    TriggerExecutionController.setSkipAllTriggers(true);     
     Account eUacc = new Account();
     eUacc.Name = 'Test Account';
     eUacc.Participating_in_LOB_Program__c = true;
     eUacc.RecordTypeId = idendUserAccountRT;
     eUacc.Account_Country__c = 'UNITED STATES';
     eUacc.ShippingStreet = '12';
     eUacc.ShippingCity = 'testStreet';
     eUacc.ShippingState = 'testTexas';
     eUacc.ShippingPostalCode = '1324';
     eUacc.Tax_Registration_Number__c = '124214';
     insert eUacc;
     string strcountryCode = 'US';
        string strlanguageCode = 'ja';
        User u = createPartnerUser(strcountryCode, strlanguageCode);
            
      Profile profile = [select Id, Name from profile where Name LIKE '%Admin%' limit 1];
      User testUser = new User(Username='testvaliduser' +'@DELL.com',
                                        Alias = 'Test', 
                                        Email='Test'+'@dell.com',            
                                        LastName='Test',
                                        Title='GCC Program Manager', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis());
     try {
            insert testUser;
     } catch( Exception e ) {
                return;
     }
     List<AccountTeamMember> listatm = new List<AccountTeamMember>();
     AccountTeamMember accTM = new AccountTeamMember();
     accTM.AccountId = eUacc.Id;
     accTM.UserId = testUser.Id;
     accTM.TeamMemberRole = 'Account Executive';
     listatm.add(accTM);
     //insert accTM;
     AccountTeamMember accTM1 = new AccountTeamMember();
     accTM1.AccountId = con.accountid;
     accTM1.UserId = testUser.Id;
     accTM1.TeamMemberRole = 'Account Executive';
     listatm.add(accTM1);
     insert listatm;
     Id iddealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
     Id idchannelOpp = IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity', TRUE);

     List<Opportunity> listopp = new List<Opportunity>();
     List<Opportunity> listOppUpdate = new List<Opportunity>();
     String strs = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';
     for(integer inti=0;inti<10;inti++){
         Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty1'+inti, 
                                                AccountId=eUacc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = iddealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                ownerid = u.id,
                                                Submission_Status_2__c = strs,
                                                Submission_Status_3__c = strs,
                                                Engage_Channel_Opportunity__c = false,
                                                CloseDate = System.Today() + 30 ); 
        
                                                
            
            listopp.add(testOppty);
           
            }                   
        
        Map<Id, Opportunity> mapOldMapTrigger = new  Map<Id, Opportunity>();                       
           
        Test.StartTest();
        insert listopp;       
        Test.StopTest();
        
     //   List<OpportunityTeamMember> listotm = [SELECT id from OpportunityTeamMember WHERE OpportunityId IN :listoppres AND UserId = :testUser.id];
        SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Plan OpportunityAccntPlanAfterTriggerTest', Account__c = eUacc.Id,
                                            Sales_Manager__c = testUser.Id );   
        
        insert testAccntPlan;
        
        List<SFDC_Strategy__c> listTestStrategy = new List<SFDC_Strategy__c>();
        List<Opportunity> listtoUpdate=new List<Opportunity>();
        for(integer intI = 1; intI <= 2; intI ++) {
            
            SFDC_Strategy__c temp = new SFDC_Strategy__c(Name='Test Strategy - ' + intI, SFDC_Acct_Plan__c = testAccntPlan.Id);
            listTestStrategy.add(temp);
        }
        
        insert listTestStrategy;
        
        listopp[0].related_strategy__c = listTestStrategy[0].Id;
      listtoUpdate.add(listopp[0]);
      listopp[4].StageName = 'Discover - 10%';
       listtoUpdate.add(listopp[4]);
      update listtoUpdate;
      Opportunity_Plan__c testOpptyPlan = new Opportunity_Plan__c(Name='testOpportunityPlanRedirectPage Oppty Plan ', Opportunity__c = listopp[1].Id);
      insert testOpptyPlan;
      List<Deal_Summary__c> listdealsummary =new List<Deal_Summary__c>();
      for(integer intj=0;intj<10;intj++){
      
      Deal_Summary__c testdealsummary = new Deal_Summary__c(Opportunity__c = listopp[intj].id, ForcedCalculation__c = false, Stage__c = listopp[intj].StageName, No_Qualified_NPS__c=0,Stage_Discover__c=0,Stage_Commit__c=0,Stage_Qualify__c=0,Stage_Propose__c=0,Stage_Plan__c=0,
                                                     LastStageChanged__c=System.Today()-1,Opportunity_Plan__c='Test',Scheduled_Opportunity__c='Test',Account__c = eUacc.Id);
        listdealsummary.add(testdealsummary);

                                                     
      }
      Insert listdealsummary;
       TriggerExecutionController.setSkipAllTriggers(false);   
            List<Deal_Summary_Event__e> listdealsummaryevent=new List<Deal_Summary_Event__e>();
          
     Deal_Summary_Event__e dealSummaryRec = new Deal_Summary_Event__e(Deal_Summary_Id__c=listdealsummary[0].Id,Opportunity__c =listdealsummary[0].Opportunity__c,Account__c=eUacc.Id,Last_Activity_Date__c=listdealsummary[0].Opportunity__r.LastActivityDate,Last_Stage_Changed__c=listdealsummary[0].LastStageChanged__c,Old_Stage_Name__c='Discover - 10%',Opportunity_Plan__c=listopp[0].Opportunity_Plan__c,Related_Strategy__c=listopp[0].Related_Strategy__c,Scheduled_Opportunity__c=listopp[0].Scheduled_Opportunity__c,Stage_Commit__c=listdealsummary[0].Stage_Commit__c,Stage_Name__c=listopp[0].StageName,Stage_Plan__c=listdealsummary[0].Stage_Plan__c,Stage_Propose__c=listdealsummary[0].Stage_Propose__c,Stage_Discover__c=listdealsummary[0].Stage_Discover__c,Stage_Qualify__c=listdealsummary[0].Stage_Qualify__c);
     listdealsummaryevent.add(dealSummaryRec);
     
     Deal_Summary_Event__e dealSummaryRec1 = new Deal_Summary_Event__e(Deal_Summary_Id__c=listdealsummary[1].Id,Opportunity__c =listdealsummary[1].Opportunity__c,Account__c=eUacc.Id,Last_Activity_Date__c=listdealsummary[1].Opportunity__r.LastActivityDate,Last_Stage_Changed__c=listdealsummary[1].LastStageChanged__c,Old_Stage_Name__c='Propose - 60%',Opportunity_Plan__c=listopp[1].Opportunity_Plan__c,Related_Strategy__c=listopp[1].Related_Strategy__c,Scheduled_Opportunity__c=listopp[1].Scheduled_Opportunity__c,Stage_Commit__c=listdealsummary[1].Stage_Commit__c,Stage_Name__c=listopp[1].StageName,Stage_Plan__c=listdealsummary[1].Stage_Plan__c,Stage_Propose__c=listdealsummary[1].Stage_Propose__c,Stage_Discover__c=listdealsummary[1].Stage_Discover__c,Stage_Qualify__c=listdealsummary[1].Stage_Qualify__c);   
     listdealsummaryevent.add(dealSummaryRec1);
      
     Deal_Summary_Event__e dealSummaryRec2 = new Deal_Summary_Event__e(Deal_Summary_Id__c=listdealsummary[2].Id,Opportunity__c =listdealsummary[2].Opportunity__c,Account__c=eUacc.Id,Last_Activity_Date__c=listdealsummary[2].Opportunity__r.LastActivityDate,Last_Stage_Changed__c=listdealsummary[2].LastStageChanged__c,Old_Stage_Name__c='Qualify - 30%',Opportunity_Plan__c=listopp[2].Opportunity_Plan__c,Related_Strategy__c=listopp[2].Related_Strategy__c,Scheduled_Opportunity__c=listopp[2].Scheduled_Opportunity__c,Stage_Commit__c=listdealsummary[2].Stage_Commit__c,Stage_Name__c=listopp[2].StageName,Stage_Plan__c=listdealsummary[2].Stage_Plan__c,Stage_Discover__c=listdealsummary[2].Stage_Discover__c,Stage_Qualify__c=listdealsummary[2].Stage_Qualify__c);     
     listdealsummaryevent.add(dealSummaryRec2);
         
     Deal_Summary_Event__e dealSummaryRec3 = new Deal_Summary_Event__e(Deal_Summary_Id__c=listdealsummary[3].Id,Opportunity__c =listdealsummary[3].Opportunity__c,Account__c=eUacc.Id,Last_Activity_Date__c=listdealsummary[3].Opportunity__r.LastActivityDate,Last_Stage_Changed__c=listdealsummary[3].LastStageChanged__c,Old_Stage_Name__c='Commit - 90%',Opportunity_Plan__c=listopp[3].Opportunity_Plan__c,Related_Strategy__c=listopp[3].Related_Strategy__c,Scheduled_Opportunity__c=listopp[3].Scheduled_Opportunity__c,Stage_Commit__c=listdealsummary[3].Stage_Commit__c,Stage_Name__c=listopp[3].StageName,Stage_Plan__c=listdealsummary[3].Stage_Plan__c,Stage_Discover__c=listdealsummary[3].Stage_Discover__c,Stage_Qualify__c=listdealsummary[3].Stage_Qualify__c);     
     listdealsummaryevent.add(dealSummaryRec3);
     
     Deal_Summary_Event__e dealSummaryRec4 = new Deal_Summary_Event__e(Deal_Summary_Id__c=listdealsummary[4].Id,Opportunity__c =listdealsummary[4].Opportunity__c,Account__c=eUacc.Id,Last_Activity_Date__c=listdealsummary[4].Opportunity__r.LastActivityDate,Last_Stage_Changed__c=listdealsummary[4].LastStageChanged__c,Old_Stage_Name__c='Plan - 1%',Opportunity_Plan__c=listopp[4].Opportunity_Plan__c,Related_Strategy__c=listopp[4].Related_Strategy__c,Scheduled_Opportunity__c=listopp[4].Scheduled_Opportunity__c,Stage_Commit__c=listdealsummary[4].Stage_Commit__c,Stage_Name__c=listopp[4].StageName,Stage_Plan__c=listdealsummary[4].Stage_Plan__c,Stage_Discover__c=listdealsummary[4].Stage_Discover__c,Stage_Qualify__c=listdealsummary[4].Stage_Qualify__c,Stage_Order_Submitted__c=0);     
     listdealsummaryevent.add(dealSummaryRec4);
     
   //  insert listdealsummaryevent;     
   //  DealSummaryEventTriggerHandler.updateDealSummaryRecords(listdealsummaryevent);

   List<Database.SaveResult> listresults = EventBus.publish(listdealsummaryevent);
    Test.getEventBus().deliver();
     System.assertEquals(true,listresults[0].isSuccess());
    /*   for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage()+'----'+err.getFields());
                }
             }        
        }  */   
        
    }
     private static User createPartnerUser(string straccountCountryCode, string struserLanguageCode){
        string straccountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Partner Account'][0].Id;
        Account acc = new Account(Name = 'Partner Account', Account_Country_Code__c = straccountCountryCode, Is_GTM_Partner__c = true, RecordTypeId = straccountRTId);//,
                                    //OwnerId = '00530000000n5szAAA'); // TODO: OwnerId
        insert acc;
        acc.IsPartner = true;
        update acc;

        con = new Contact(AccountId = acc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT');
        insert con;

        // Create this user with PowerPartner profile,
        // so that the AccountId will be populated as same as the associated Contact's AccountId
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        //string proid = [SELECT Id FROM Profile WHERE Name = 'R13.1 EMEA PRM Portal User (MOSS)'][0].Id; // TODO: proid // Ver 1.0
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User(ContactId = con.Id, IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = struserLanguageCode,
                            LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        return u;
    }
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
    }
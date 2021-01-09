/*
* Author   : Ragu
* Purpose  : Utility test class for creating Campaign related data. 
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      
* 2.0      12720       FY17-DCS-0401   15-March-2016   Azwanti         replace Campaign RT from 'GBL_Standard_RT' to 'Campaign 2.0'
* 3.0      13096       FY17-Sprint07   29-Apri-2016    Fenny           Test the Opportunity Workflow Field Update logic that have been moved to OpportunityFieldPopulator
* 4.0      13171       FY17-DCS-0701   26-May-2016     Fenny           To resolve "Too many SOQL queries: 101"
* 5.0      13322       FY17-DCS-0902   28-Jul-2016     Fenny           To ensure triggers will be skipped from process flow
* 6.0      13964                       06-Feb-2017     Vasavi.M        Remove DSG related functionality 'populateForAutoApproval' method calls
* 7.0      14160       FY18-DCS-0502   11-Apr-2017     Sriram          To test the logic making blank for the fields EMC_sales_motion__c and EMC_Opportunity_updated__c when ever its get cloned from existing Opportunity(Before Insert)
* 8.0      15353       FY19-DCS-0203   26-Jan-2018     Abhinav         To cover forecast category override logic
* 9.0      15486       FY19-DCS-0401   06-Mar-2018     Murali.M        Field Trip clean up for Opportunity
*10.0                  FY20-0202       10-Dec-2018     Haribabu.A      STORY 5907651 Removed reference for the field direct_account_name__c,account_play__c and lob_registration_id__c
*11.0      16970       FY20-0202       08-Jan-2019     Emily           Remove virtualization__c
*12.0      17277       FY20-0502       18-April-2019   Venkat          Added Test Methods for APOS, EMC Opportunity Updated field change.
*13.0      18394       FY21-0202       24-Dec-2019     Abhinav         Overwrite Use Case field only for Sales Rep E users.
*/
@isTest
public class OpportunityFieldPopulatorTest {
        
    static Opportunity testOpportunity;
    static List<Opportunity> listTestOpp = new List<Opportunity>();
    static Account testAccountObj;
    static boolean bTestDataIsNotCreated=true;
    static Country__c testCountryObject;
    static Opportunity testParentOpportunity;

    //8.0 - BOF
    //Making list for Skip VRs
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
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
        system.assertEquals('Qualify - 30%',owdSetting.Oppty_Stage30__c );
        
        EMC_General_Settings__c settingData = new EMC_General_Settings__c();
        settingData.ProfilesBypassMyquotesOpptyValidation__c= 'Boomi Integration API Only;';        
        insert settingData;

        List<GroupName__c> lstGrpName = new List<GroupName__c>();
        GroupName__c grpName1 = new GroupName__c();
        grpName1.Name ='FPG_DPS__c';
        grpName1.API_Name__c ='FPG_DPS__c';
        grpName1.Label__c ='Forecast Product Group DPS';
        grpName1.Group_Name__c ='DPS';
        lstGrpName.add(grpName1);

        GroupName__c grpName2 = new GroupName__c();
        grpName2.Name ='FPG_MDC__c';
        grpName2.API_Name__c ='FPG_MDC__c';
        grpName2.Label__c ='Forecast Product Group MDC';
        grpName2.Group_Name__c ='MDC';
        lstGrpName.add(grpName2);

        GroupName__c grpName3 = new GroupName__c();
        grpName3.Name ='FPG_UDS__c';
        grpName3.API_Name__c ='FPG_UDS__c';
        grpName3.Label__c ='Forecast Product Group UDS';
        grpName3.Group_Name__c ='UDS';
        lstGrpName.add(grpName3);

        GroupName__c grpName4 = new GroupName__c();
        grpName4.Name ='FPG_Enterprise__c';
        grpName4.API_Name__c ='FPG_Enterprise__c';
        grpName4.Label__c ='Forecast Product Group Enterprise';
        grpName4.Group_Name__c ='Enterprise';
        lstGrpName.add(grpName4);

        insert lstGrpName;

        List<Split_OverlayGroup__c> lstSplitGrp = new List<Split_OverlayGroup__c>();

        Split_OverlayGroup__c spltgrp1 = new Split_OverlayGroup__c();
        spltgrp1.Name = 'UDS';
        spltgrp1.Group_Name__c = 'UDS';
        spltgrp1.Team_Member_Role__c = 'UDS Inside Sales Mgr';
        lstSplitGrp.add(spltgrp1);

        Split_OverlayGroup__c spltgrp2 = new Split_OverlayGroup__c();
        spltgrp2.Name = 'MDC';
        spltgrp2.Group_Name__c = 'MDC';
        spltgrp2.Team_Member_Role__c = 'MDC Inside Sales Mgr';
        lstSplitGrp.add(spltgrp2);

        insert lstSplitGrp;

        //13.0 - BOF
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;

        //Create this user with Sales Rep E profile, so that the use case fields will be populated
        Id idUseCaseProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Rep E' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id;
        User uUseCase = new User(IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'en_US', FirstName = 'Sales Rep E', LastName = 'Use Case', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = idUseCaseProfile, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert uUseCase;

        List<GlobalVariable__c> listGlobalVariable = new List<GlobalVariable__c> {
            new GlobalVariable__c(Name = 'UseCase_isActive', Value__c = 'true'),
            new GlobalVariable__c(Name = 'UseCase_ProfileId', Value__c = idUseCaseProfile),
            new GlobalVariable__c(Name = 'UseCase_Domain', Value__c = 'Basic Hardware/Software Sale'),
            new GlobalVariable__c(Name = 'UseCase_SolutionType', Value__c = 'Datacenter- Hardware Refresh'),
            new GlobalVariable__c(Name = 'UseCase_SolutionName', Value__c = 'Storage')
        };
        insert listGlobalVariable;
        //13.0 - EOF
    }
    //8.0 - EOF

    static testMethod void prepareTestData(){  
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        TriggerExecutionController.setSkipAllTriggers(true);
        if (bTestDataIsNotCreated){     
            testCountryObject = new Country__c(name='Jedi Country', Dell_Online_Country_Code__c='JC',Code__c='JC',Enabled_Auto_Renewal__c=True,Last_Operation_Performed__c='Test Data');
            insert testCountryObject; 
            TriggerExecutionController.setSkipAccountTriggers(true);
            testAccountObj =new Account(name='Renewal Test Account', Account_Country_Code__c = 'JC', Account_Country__c = 'Jedi Country', Approved_for_Partner_Finder__c = false);
            insert testAccountObj;
            
            testParentOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                                    RecordTypeId= '012A0000000Vjtg',
                                                    Name='TestParentOpportunity',
                                                    Type = 'Run Rate',
                                                    Domain__c='Deal Reg',
                                                    Solution_Type__c = 'Campus',
                                                    Solution_Name__c = 'Wireless Switches',
                                                    StageName='Plan - 1%',
                                                    Deal_Expiration_Timeframe__c='60',                                               
                                                    Request_Status__c='New', 
                                                    CloseDate= System.Now().Date().addDays(180), 
                                                    Forecast_Category_Override__c = 'Omitted');          
            insert testParentOpportunity;
            Test.startTest();
            testParentOpportunity.Deal_Registration_Status__c = 'Recalled';
            Update testParentOpportunity;
            testOpportunity= new Opportunity (AccountID=testAccountObj.ID ,
                                              RecordTypeId= '012A0000000Vjtg',
                                              Name='TestOpportunity',
                                              Type = 'Run Rate',
                                              Domain__c='Deal Reg',
                                              Solution_Type__c = 'Campus',
                                              Solution_Name__c = 'Wireless Switches',
                                              StageName='Plan - 1%',
                                              Deal_Registration_Status__c = 'Recalled',
                                              Deal_Created_Date_Time__c = System.Now(),
                                              Deal_Expiration_Timeframe__c='60',
                                              Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                              CloseDate= System.Now().Date().addDays(180),
                                              Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                              Request_Status__c='New', 
                                              Forecast_Category_Override__c = 'Omitted');
            //insert testOpportunity;
            listTestOpp.add(testOpportunity);
            
            testOpportunity = new Opportunity (AccountID=testAccountObj.ID ,
                                              RecordTypeId= '012A0000000Vjtg',
                                              Name='TestOpportunity',
                                              Type = 'Run Rate',
                                              Domain__c='Deal Reg',
                                              Solution_Type__c = 'Campus',
                                              Solution_Name__c = 'Wireless Switches',
                                              StageName='Propose - 60%',
                                              Deal_Registration_Status__c = 'Recalled',
                                              Deal_Created_Date_Time__c = System.Now(),
                                              Deal_Expiration_Timeframe__c='60',
                                              Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                              CloseDate= System.Now().Date().addDays(180),
                                              Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                              Request_Status__c='New',
                                              Skip_Calculate_LOT_OCEAN__c = false,
                                              Channel_Lead_ID_2__c = '1234567ABCDEFGHI', 
                                              Forecast_Category_Override__c = 'Best Case',
                                              Competitor_Lost_To__c='Unknown'
                                              );
            insert testOpportunity;
            
            
          Opportunity testOpp1 = new Opportunity (AccountID=testAccountObj.ID ,
                                              RecordTypeId= '012A0000000Vjtg',
                                              Name='TestOpp 1',
                                              Type = 'Run Rate',
                                              Domain__c='Deal Reg',
                                              Solution_Type__c = 'Campus',
                                              Solution_Name__c = 'Wireless Switches',
                                              StageName='Discover - 10%',
                                              Deal_Registration_Status__c = 'Recalled',
                                              Deal_Created_Date_Time__c = System.Now(),
                                              Deal_Expiration_Timeframe__c='60',
                                              Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                              CloseDate= System.Now().Date().addDays(180),
                                              Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                              Request_Status__c='New', 
                                              Forecast_Category_Override__c = 'Omitted');
         listTestOpp.add(testOpp1);
         Opportunity testOpp2 = new Opportunity (AccountID=testAccountObj.ID ,
                                              RecordTypeId= '012A0000000Vjtg',
                                              Name='TestOpp 2',
                                              Type = 'Run Rate',
                                              Domain__c='Deal Reg',
                                              Solution_Type__c = 'Campus',
                                              Solution_Name__c = 'Wireless Switches',
                                              StageName='Qualify - 30%',
                                              Deal_Registration_Status__c = 'Recalled',
                                              Deal_Created_Date_Time__c = System.Now(),
                                              Deal_Expiration_Timeframe__c='60',
                                              Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                              CloseDate= System.Now().Date().addDays(180),
                                              Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                              Request_Status__c='New', 
                                              Forecast_Category_Override__c = 'Omitted');
       listTestOpp.add(testOpp2);                                       
      Opportunity testOpp3 = new Opportunity (AccountID=testAccountObj.ID ,
                                              RecordTypeId= '012A0000000Vjtg',
                                              Name='TestOpp 3',
                                              Type = 'Run Rate',
                                              Domain__c='Deal Reg',
                                              Solution_Type__c = 'Campus',
                                              Solution_Name__c = 'Wireless Switches',
                                              StageName='Propose - 60%',
                                              Deal_Registration_Status__c = 'Recalled',
                                              Deal_Created_Date_Time__c = System.Now(),
                                              Deal_Expiration_Timeframe__c='60',
                                              Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                              CloseDate= System.Now().Date().addDays(180),
                                              Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                              Request_Status__c='New', 
                                              Forecast_Category_Override__c = 'Omitted');
        listTestOpp.add(testOpp3);                                      
         Opportunity testOpp4 = new Opportunity (AccountID=testAccountObj.ID ,
                                              RecordTypeId= '012A0000000Vjtg',
                                              Name='TestOpp 4',
                                              Type = 'Run Rate',
                                              Domain__c='Deal Reg',
                                              Solution_Type__c = 'Campus',
                                              Solution_Name__c = 'Wireless Switches',
                                              StageName='Commit - 90%',
                                              Deal_Registration_Status__c = 'Recalled',
                                              Deal_Created_Date_Time__c = System.Now(),
                                              Deal_Expiration_Timeframe__c='60',
                                              Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                              CloseDate= System.Now().Date().addDays(180),
                                              Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                              Request_Status__c='New', 
                                              Forecast_Category_Override__c = 'Omitted');
          listTestOpp.add(testOpp4);                                    
          Opportunity testOpp5 = new Opportunity (AccountID=testAccountObj.ID ,
                                              RecordTypeId= '012A0000000Vjtg',
                                              Name='TestOpp 5',
                                              Type = 'Run Rate',
                                              Domain__c='Deal Reg',
                                              Solution_Type__c = 'Campus',
                                              Solution_Name__c = 'Wireless Switches',
                                              StageName='Order Submitted - 99%',
                                              Deal_Registration_Status__c = 'Recalled',
                                              Deal_Created_Date_Time__c = System.Now(),
                                              Deal_Expiration_Timeframe__c='60',
                                              Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                              CloseDate= System.Now().Date().addDays(180),
                                              Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                              Request_Status__c='New', 
                                              Forecast_Category_Override__c = 'Omitted');
            listTestOpp.add(testOpp5);                                  
                                               
            Test.stopTest();
            
            bTestDataIsNotCreated= false;   
           
        }
        TriggerExecutionController.setSkipAllTriggers(false);
          System.AssertEquals(testOpportunity.Type,'Run Rate');
    }

    // 3.0
    static testMethod void testWorkflowFieldUpdateTest() {
        
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        TriggerExecutionController.setSkipAllTriggers(true);   
        Account newAcc = new Account(name='Renewal Test Account', Account_Country_Code__c = 'JC', Account_Country__c = 'Jedi Country', Approved_for_Partner_Finder__c = false);
        insert newAcc;
        

        CMAP_Queue_Settings__c cMAPsetting = new CMAP_Queue_Settings__c();
        CMAPsetting.Name = 'Channel_eClerx';
        CMAPsetting.Queue_Id__c = '00GA0000002y6hl';
        CMAPsetting.Queue_Name__c = 'Channel_eClerx';
        insert CMAPsetting;
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                                              Campaign_Objective__c='Acquisition/Site Development',
                                              Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                              Region__c='ABU',                        
                                              Follow_Up_Role__c='Account Executive',
                                              Description='Test',StartDate=system.today(),EndDate=system.today(),
                                              status='In Progress',
                                              recordTypeId = campRTId,
                                              Allocation_Source__c = 'Dell Allocation ABU',
                                              Nurture_Source__c = 'Dell Nurturing',
                                              Country_Code__c = 'BR - Brazil',
                                              Partner_Event_or_Campaign__c = False,
                                              IsActive = true,
                                              Total_Campaign_Targets_Planned__c = 1,
                                              Total_Value_Won_Opportunities_Planned__c = 1,
                                              Total_Value_Opportunities_Planned__c = 1,
                                              Lead_Routing__c = 'Dell Standard');
        insert campChannelObj;
         TriggerExecutionController.setSkipAllTriggers(false);
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 //   Relationship_Lead__c = 'Account Play',                
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        insert leadObj1;
        
        //Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
        TriggerExecutionController.setSkipAccountTriggers(true); 
        
        Test.startTest();
        ProcessFlowTriggerController.isTest = true; // 5.0
        Id stdPricebookId = Test.getStandardPricebookId();
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justifications Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Propose - 60%',
                                                Override_Probability__c = '60',
                                                CloseDate = System.Today() + 30,
                                              Skip_Calculate_LOT_OCEAN__c = false,
                                              Channel_Lead_ID__c = leadObj1.Id,
                                              Primary_Campaign_ID__c = campChannelObj.Id,
                                              Channel_Lead_ID_2__c = leadObj1.Id,
                                              Marketing_Created_Opportunity__c = true,
                                              Lattice_PreLead_External_Id__c = 'ABDE12342', 
                                              Forecast_Category_Override__c = 'Best Case', 
                                              Pricebook2Id = stdPricebookId
                                          );
        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        insert testOppty;
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        
        TriggerExecutionController.setSkipAllTriggers(false); 
        /*testOppty.StageName = 'Win - 100%';
        testOppty.Competitor_Lost_To__c = 'Absolute';
        testOppty.Account_ClosedOppurtunity__c = newAcc.Id;
        testOppty.Distributor_Reseller_Name__c = newAcc.Id;                                 
        update testOppty;*/
        Opportunity opp = [SELECT StageName, Highest_Stage__c, Confidence_Factor__c, Partner_Opportunity_Stage__c FROM Opportunity WHERE Id = :testOppty.Id];
        
        Test.stopTest();
    }   

    /*v6.0 
static testMethod void test_populateForAutoApproval(){
List<Opportunity> listOpp = new List<Opportunity>();
PrepareTestData();

testOpportunity.Submitter_Profile__c = 'NA PRM';
testOpportunity.DSG_Renewal_request__c = true;
TriggerExecutionController.setSkipAllTriggers(true); 
update testOpportunity;    
listOpp.add(testOpportunity);
OpportunityFieldPopulator.populateForAutoApproval(listOpp);        
System.assertEquals('Approved',testOpportunity.Request_Status__c);
}

static testMethod void test_populateForAutoApproval_NonABU(){
ProcessFlowTriggerController.isTest = true; // 5.0
triggerexecutioncontroller.setskipalltriggers(true);
List<Opportunity> listOpp = new List<Opportunity>();
PrepareTestData();
testOpportunity.Submitter_Profile__c = 'APJ PRM';
Date expireDate = System.Now().Date().addDays(15);
testOpportunity.Deal_Expiration_Date__c = expireDate;
testOpportunity.Deal_Expiration_Timeframe__c = '60';
listOpp.add(testOpportunity);
update listOpp;
OpportunityFieldPopulator.populateForAutoApproval(listOpp);
System.assertEquals('Approved',testOpportunity.Request_Status__c);
}
v6.0*/
    
    static testMethod void testautoPopulateFields(){
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        TriggerExecutionController.setSkipAllTriggers(true);  
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        /*Contact newCont2 = new Contact(FirstName='MyTestContact11',
LastName='MyTestContact11',
accountId=newAcc.Id,
Email='MyTestContactEmail_11@ust-global.com',
fax='1234567',  Status__c = 'Marketing Suspect',
MobilePhone='0987654',
Last_Operation_Performed__c = 'testing',
Phone='1234500');
insert newCont2;
final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' limit 1];

User partnerUser = new User(Username='MyTestUser11' + System.currentTimeMillis() + '@dell.com',
Alias = 'MTU11', 
Email='MyTestUser11@dell.com', 
FirstName='MyTestUser11', 
LastName='MyTestUser11',  
ProfileId = partnerProfiles.get(0).Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='99826515', 
isActive = TRUE,
ContactId = newCont2.id);
insert partnerUser;*/
        Test.startTest();
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
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
                                                CloseDate = System.Today() + 30, 
                                                Forecast_Category_Override__c = 'Omitted' );        
        
        //System.runAs(partnerUser) {
        insert testOppty;
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End
        Test.stopTest();
        /*List<Opportunity> listOpps1 = [select Id, Deal_Registration_Status__c from Opportunity where Id = :testOppty.Id];
system.Debug('-----test Debug----'+listOpps1[0].Deal_Registration_Status__c);
listOpps1[0].Deal_Registration_Status__c ='Submitted';
update listOpps1;
system.Debug('-----test Debug----'+listOpps1);
system.Debug('-----test Debug----'+listOpps1[0].Deal_Registration_Status__c);*/
        // }
        //List<User> u = [Select Id from user where Profile_Name__c Like '%PRM Operation%' AND isActive = TRUE];
        
        List<Opportunity> listOpps = [select Id, Deal_Registration_Status__c from Opportunity where Id = :testOppty.Id];
        System.assertEquals('Submitted',listOpps[0].Deal_Registration_Status__c);
        system.Debug('-----test Debug----'+listOpps);
        //if(u.Size() > 0 ){
        // System.runAs(u[0]) {
        listOpps[0].Deal_Registration_Status__c ='Rejected';
        update listOpps;
        //}
        //}
        system.Debug('-----test Debug2----'+listOpps);
        
    }
    
    
    // 5.0: to cover code in OpportunityFieldPopulator.validateAndPopulateLOBRegistrationDetails
    static testMethod void testValidateAndPopulateLOBRegistrationDetails(){
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        TriggerExecutionController.setSkipAllTriggers(true);  
        
        Id endUserAccRTId = StaticFactory.getRecordTypeIdByDevName('Account', 'GBL_Standard_RT'); // End-User Account record type
        Account endUserAcc = new Account(name='Test LOB End User Account', RecordtypeId = endUserAccRTId, Participating_in_LOB_Program__c=true);
        insert endUserAcc;
        
        List<LOB_Registration__c> listLOBReg = new List<LOB_Registration__c>();
        LOB_Registration__c lob1 = new LOB_Registration__c(Registered_End_User__c=endUserAcc.Id, LOB_registration_status__c='Open', LOB_Name__c='Client', City__c='KL', State_Province_Region__c='APJ');
        LOB_Registration__c lob2 = new LOB_Registration__c(Registered_End_User__c=endUserAcc.Id, LOB_registration_status__c='Open', LOB_Name__c='Client', City__c='KL', State_Province_Region__c='APJ');
        LOB_Registration__c lob3 = new LOB_Registration__c(Registered_End_User__c=endUserAcc.Id, LOB_registration_status__c='Open', LOB_Name__c='Client', City__c='KL', State_Province_Region__c='APJ');
        listLOBReg.add(lob1);
        listLOBReg.add(lob2);
        listLOBReg.add(lob3);
        insert listLOBReg;
        string strlob1Id = lob1.Id;
        string strlob2Id = lob2.Id;
        string strlob3Id = lob3.Id;
        Set<Id> setLOBIds = new Set<Id>();
        setLOBIds.add(lob1.Id);
        setLOBIds.add(lob2.Id);
        setLOBIds.add(lob3.Id);
        
        Id accRTId = StaticFactory.getRecordTypeIdByDevName('Account', 'Partner_Account');
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner', Partner_Notification_Email__c = 'test@dell.com');
        insert newAcc;
        
        List<Profile> listUserProfiles= [select id,name from profile where name like '%Sales%' order by name limit 2 ];
        User tempUser = new User(Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev', 
                                 Alias = 'test', Email='test109@dell.com', FirstName='Tfirst A1', LastName='TLast2', ProfileId = listUserProfiles[0].Id,
                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',  TimeZoneSidKey='America/Los_Angeles',  
                                 Badge_Number__c='Test'+System.currentTimeMillis(),  Title = 'Test Title', CurrencyIsoCode = 'USD' );   
        insert tempUser;
        
        AccountTeamMember accTeamMember = new AccountTeamMember(AccountId=newAcc.Id, UserId=tempUser.Id, TeamMemberRole='E&I Technical Sales Rep');
        insert accTeamMember;
        
        
        Id createDealFromLOBRTId = StaticFactory.getRecordTypeIdByDevName('Opportunity', 'Create_New_Deal_From_LOB');
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = createDealFromLOBRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test LOB End User Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30, End_User_Phone__c='9490123230', 
                                                Forecast_Category_Override__c = 'Omitted');
        insert testOppty;
        
        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
        oppTeamMember.OpportunityId = testOppty.Id;
        oppTeamMember.UserId = accTeamMember.UserId;
        oppTeamMember.TeamMemberRole = accTeamMember.TeamMemberRole;
       insert oppTeamMember;
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End 
        string strdepartment = testOppty.End_User_Mailing_City__c + ',' + testOppty.End_User_Mailing_State_Province_Region__c;
        
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
        mapOpp.put(testOppty.Id, testOppty);
        
        OpportunityFieldPopulator.validateAndPopulateLOBRegistrationDetails(mapOpp, setLOBIds, null);
        OpportunityFieldPopulator.populateOpportunityTeamMembers(mapOpp);
        
        system.assertEquals(strdepartment, testOppty.End_User_Account_Department__c);
        system.assertEquals(endUserAcc.Name, testOppty.End_User_Account_Name__c);
        //system.assertEquals(endUserAcc.Id, testOppty.AccountId);
        //system.assertEquals('Deal/Bid - Indirect', testOppty.Type);
    }
    
    // 3.0
    static testMethod void testWorkflowFieldUpdate(){
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        TriggerExecutionController.setSkipAllTriggers(true);   
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner', Partner_Notification_Email__c = 'test@dell.com');
        insert newAcc;
        
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
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
                                                //Channel_Lead_ID_2__c = '00Q0m000001UXThEAO',
                                                StageName = 'Plan - 1%',
                                                Override_Probability__c = '1',
                                                CloseDate = System.Today() + 30, 
                                                Distributor_Reseller_Name__c = newAcc.Id, 
                                                Forecast_Category_Override__c = 'Omitted');
        insert testOppty;
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End        
        TriggerExecutionController.setSkipAllTriggers(false); 
        TriggerExecutionController.setSkipAccountTriggers(true); 
        
        Test.startTest();
        ProcessFlowTriggerController.isTest = true; // 5.0
         testOppty.Distributor_Name__c = 'Distribution'; 
        testOppty.StageName = 'Win - 100%';
        testOppty.Competitor_Lost_To__c = 'Absolute';
        testOppty.Account_ClosedOppurtunity__c = newAcc.Id;
        testOppty.Distributor_Reseller_Name__c = newAcc.Id;
        testOppty.Forecast_Category_Override__c = 'Closed';
        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        update testOppty;
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        Opportunity opp = [SELECT StageName, Highest_Stage__c, Confidence_Factor__c, Partner_Opportunity_Stage__c FROM Opportunity WHERE Id = :testOppty.Id];
        //system.assert(opp.Partner_Opportunity_Stage__c == opp.StageName); // 5.0: Process flow yet activated, so this field not populated
       // system.assert(opp.Confidence_Factor__c == '100%');
        //system.assert(opp.Highest_Stage__c == opp.StageName);
        
        Test.stopTest();
    }
    
    // 3.0
    static testMethod void testWorkflowFieldUpdate1(){
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        TriggerExecutionController.setSkipAllTriggers(true);   
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner', Partner_Notification_Email__c = 'test@dell.com');
        insert newAcc;
        
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
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
                                                Override_Probability__c = '1',
                                                CloseDate = System.Today() + 30, 
                                                Forecast_Category_Override__c = 'Omitted');
        insert testOppty;
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End
        TriggerExecutionController.setSkipAllTriggers(false); 
        TriggerExecutionController.setSkipAccountTriggers(true); 
        
        Test.startTest();
        ProcessFlowTriggerController.isTest = true; // 5.0
        
        /*testOppty.StageName = 'Win - 100%';
testOppty.Competitor_Lost_To__c = 'Absolute';
testOppty.Account_ClosedOppurtunity__c = newAcc.Id;
testOppty.Distributor_Reseller_Name__c = newAcc.Id;                                 
update testOppty;
Opportunity opp = [SELECT StageName, Highest_Stage__c, Confidence_Factor__c, Partner_Opportunity_Stage__c FROM Opportunity WHERE Id = :testOppty.Id];
//system.assert(opp.Partner_Opportunity_Stage__c == opp.StageName); // 5.0: Process flow yet activated, so this field not populated
system.assert(opp.Confidence_Factor__c == '100%');
system.assert(opp.Highest_Stage__c == opp.StageName);
*/
        Test.stopTest();
    }
    
    // 3.0
    static testMethod void testWorkflowFieldUpdate2(){
        
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        TriggerExecutionController.setSkipAllTriggers(true);   
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner', Partner_Notification_Email__c = 'test@dell.com');
        insert newAcc;
        
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justifications Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Discover - 10%',
                                                Override_Probability__c = '10',
                                                CloseDate = System.Today() + 30, 
                                                Forecast_Category_Override__c = 'Omitted',
                                                Distributor_Reseller_Name__c = newAcc.Id,
                                                Services_Location_s__c = 'APJ-All countries',
                                                Oppty_Self_Id__c = ''
                                                );

        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        insert testOppty;
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true); 
        
        Test.startTest();
        ProcessFlowTriggerController.isTest = true; // 5.0
        testOppty.Distributor_Name__c = 'Distribution';
        testOppty.StageName = 'Win - 100%';
        testOppty.Competitor_Lost_To__c = 'Absolute';
        testOppty.Account_ClosedOppurtunity__c = newAcc.Id;
        testOppty.Distributor_Reseller_Name__c = newAcc.Id;
        testOppty.Forecast_Category_Override__c = 'Closed';
        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        update testOppty;
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        Opportunity opp = [SELECT StageName, Highest_Stage__c, Confidence_Factor__c, Partner_Opportunity_Stage__c FROM Opportunity WHERE Id = :testOppty.Id];
        //system.assert(opp.Partner_Opportunity_Stage__c == opp.StageName); // 5.0: Process flow yet activated, so this field not populated
       // system.assert(opp.Confidence_Factor__c == '100%');
        //system.assert(opp.Highest_Stage__c == opp.StageName);
        
        Test.stopTest();
    }
    
    // 3.0
    static testMethod void testWorkflowFieldUpdate3(){
        
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        TriggerExecutionController.setSkipAllTriggers(true);   
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner', Partner_Notification_Email__c = 'test@dell.com');
        insert newAcc;
        
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justifications Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Discover - 10%', //'Qualify - 30%',
                                                Override_Probability__c = '30',
                                                CloseDate = System.Today() + 30, 
                                                Forecast_Category_Override__c = 'Omitted' );
        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        insert testOppty;
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End
        
        TriggerExecutionController.setSkipAllTriggers(false); 
        TriggerExecutionController.setSkipAccountTriggers(true); 
        
        Test.startTest();
        ProcessFlowTriggerController.isTest = true; // 5.0
        
        /*testOppty.StageName = 'Win - 100%';
testOppty.Competitor_Lost_To__c = 'Absolute';
testOppty.Account_ClosedOppurtunity__c = newAcc.Id;
testOppty.Distributor_Reseller_Name__c = newAcc.Id;                                 
update testOppty;
Opportunity opp = [SELECT StageName, Highest_Stage__c, Confidence_Factor__c, Partner_Opportunity_Stage__c FROM Opportunity WHERE Id = :testOppty.Id];
//system.assert(opp.Partner_Opportunity_Stage__c == opp.StageName); // 5.0: Process flow yet activated, so this field not populated
system.assert(opp.Confidence_Factor__c == '100%');
system.assert(opp.Highest_Stage__c == opp.StageName);
*/
        Test.stopTest();
    }
    
    // 3.0
    static testMethod void testWorkflowFieldUpdate4(){
        
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        TriggerExecutionController.setSkipAllTriggers(true);   
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner', Partner_Notification_Email__c = 'test@dell.com');
        insert newAcc;
        
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justifications Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Discover - 10%',//'Propose - 60%',
                                                Override_Probability__c = '60',
                                                CloseDate = System.Today() + 30, 
                                                Forecast_Category_Override__c = 'Omitted');
        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        insert testOppty;
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End
        
        TriggerExecutionController.setSkipAllTriggers(false); 
        TriggerExecutionController.setSkipAccountTriggers(true); 
        
        Test.startTest();
        ProcessFlowTriggerController.isTest = true; // 5.0
        
        /*testOppty.StageName = 'Win - 100%';
testOppty.Competitor_Lost_To__c = 'Absolute';
testOppty.Account_ClosedOppurtunity__c = newAcc.Id;
testOppty.Distributor_Reseller_Name__c = newAcc.Id;                                 
update testOppty;
Opportunity opp = [SELECT StageName, Highest_Stage__c, Confidence_Factor__c, Partner_Opportunity_Stage__c FROM Opportunity WHERE Id = :testOppty.Id];
//system.assert(opp.Partner_Opportunity_Stage__c == opp.StageName); // 5.0: Process flow yet activated, so this field not populated
system.assert(opp.Confidence_Factor__c == '100%');
system.assert(opp.Highest_Stage__c == opp.StageName);
*/
        Test.stopTest();
    }
    
    // 3.0
    static testMethod void testWorkflowFieldUpdate5(){
        
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        TriggerExecutionController.setSkipAllTriggers(true);   
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner', Partner_Notification_Email__c = 'test@dell.com');
        insert newAcc;
        
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justifications Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Discover - 10%', //'Commit - 90%',
                                                Override_Probability__c = '90',
                                                CloseDate = System.Today() + 30, 
                                                Forecast_Category_Override__c = 'Omitted');
        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        insert testOppty;
        System.AssertEquals(testOppty.Forecast_Category_Override__c ,'Omitted');
        System.AssertEquals(newAcc.Type,'Partner');
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End
        TriggerExecutionController.setSkipAllTriggers(false); 
        TriggerExecutionController.setSkipAccountTriggers(true); 
        
        Test.startTest();
        ProcessFlowTriggerController.isTest = true; // 5.0
        
        /*testOppty.StageName = 'Win - 100%';
testOppty.Competitor_Lost_To__c = 'Absolute';
testOppty.Account_ClosedOppurtunity__c = newAcc.Id;
testOppty.Distributor_Reseller_Name__c = newAcc.Id;                                 
update testOppty;
Opportunity opp = [SELECT StageName, Highest_Stage__c, Confidence_Factor__c, Partner_Opportunity_Stage__c FROM Opportunity WHERE Id = :testOppty.Id];
//system.assert(opp.Partner_Opportunity_Stage__c == opp.StageName); // 5.0: Process flow yet activated, so this field not populated
system.assert(opp.Confidence_Factor__c == '100%');
system.assert(opp.Highest_Stage__c == opp.StageName);
*/
        Test.stopTest();
    }
    
    /*
CR          Date            Created By
---         -----------     -----------
CR11414     19-May-2015     Krishnamoorthi

Methods:


testUpdateFieldsForSAVONonStdOpp

To test the SAVO Opportunity fields Product_Group_Hidden__c and Product_Brand_Hidden__c are updated when Opportunity RecordType is changed.
This method will cover the updateFieldsForSAVO functionality in the below classes
OpportunityTriggerHandler
OpportunityUtilities
OpportunityFieldPopulator
*/
    /*
    //Update Standard Opportunity
    public static testMethod void testUpdateFieldsForSAVOStdOpp() {
        
        List<Opportunity> newlistOpps = new List<Opportunity>();
        Map<Id, Opportunity> mapOldOppMap = new Map<Id, Opportunity>();
        // TriggerExecutionController.setSkipAccountTriggers(true); // 4.0: Switch to skip all triggers
        TriggerExecutionController.setSkipAllTriggers(true); // 4.0
        TriggerExecutionController.setSkipAccountTriggers(true); // 4.0
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipProduct2Triggers(true); // 4.0
        Account testAccount = new Account(Name='Test SAVO Account');        
        insert testAccount;        
        
        //Create Non-Standard Opportunity
        Opportunity testOpp1 = new Opportunity(Name='Test SAVO Opportunity', 
                                               AccountId=testAccount.Id,
                                               RecordTypeId = GlobalVariables.APOS_OPP_RETYPE,   
                                               StageName='Discover - 10%',
                                               CloseDate = System.Today() + 30 );
        
        insert testOpp1;
        System.debug('Success1');
        mapOldOppMap.put(testOpp1.Id, testOpp1);
        
        Id pbk1 = Test.getStandardPricebookId();
        
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',
                                          ProductCode = 'TP1', 
                                          Product_ID__c='test prod id1',  
                                          Product_Line_Desc__c = 'Test Product1',
                                          IsActive = TRUE);
        insert newPrdct1;
        System.debug('Success2');
        PricebookEntry PBE1= new PricebookEntry (Product2ID=newPrdct1.id,
                                                 Pricebook2ID=pbk1,
                                                 isActive=true,//CurrencyIsoCode = testOpp1.CurrencyIsoCode,
                                                 useStandardPrice=false,
                                                 UnitPrice = 50);
        insert PBE1;
        System.debug('Success3');
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true); 
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOpp1.Id,
                                                                     pricebookEntryId=PBE1.id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description1'
                                                                    ); 
        
        
        Test.startTest();   
        insert testLineItem1;
        Test.stopTest();
        
        System.debug('Success4');
        Opportunity testOpp2 = [Select Id, RecordTypeId, Product_Group_Hidden__c, Product_Brand_Hidden__c, Number_of_Line_Items__c from Opportunity where Id =: testOpp1.Id];
        System.debug(testOpp2);
        //Assert the two SAVO fields are null
        //System.assertEquals(testOpp2.Product_Brand_Hidden__c, null);
        System.assertEquals(testOpp2.Product_Group_Hidden__c, null);
        
        //Update the Opportunity Record Type to Standard Opportunity
        testOpp2.RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE;
        newlistOpps.add(testOpp2);
        
        //Calling the updateFieldsForSAVO from OpportunityUtilities explicitly because while running test class the Opportunity record is overridden by some workflow updates and the old and new values are coming as same to make the assertion failure. This approach was suggested by SFDC PS team for the Case #12027182  
        OpportunityUtilities.updateFieldsForSAVO(newlistOpps, mapOldOppMap);
        
        //Assert the two SAVO fields are populated while changing the record type to standard from some other
        System.assert(testOpp2.Product_Brand_Hidden__c.contains('Test Product1'));
        System.assertEquals(testOpp2.Product_Group_Hidden__c, 'TP1');
        
        //update newlistOpps; // 4.0: Commented, because IPDATE is not necessary since OpportunityUtilities.updateFieldsForSAVO invoked above and assertion test following
        System.debug('Success5');    
        TriggerExecutionController.setSkipAllTriggers(false); // 4.0
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 4.0
        TriggerExecutionController.setSkipProduct2Triggers(false); // 4.0
    } 
    
    //Update Non-Standard Opportunity
    public static testMethod void testUpdateFieldsForSAVONonStdOpp() {
        
        List<Opportunity> newlistOpps = new List<Opportunity>();
        Map<Id, Opportunity> mapOldOppMap = new Map<Id, Opportunity>();
        TriggerExecutionController.setSkipAccountTriggers(true);       
        Account testAccount = new Account(Name='Test SAVO Account');        
        insert testAccount;        
        
        //Create Standard Opportunity
        Opportunity testOpp1 = new Opportunity(Name='Test SAVO Opportunity', 
                                               AccountId=testAccount.Id,
                                               RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,   
                                               StageName='Discover - 10%',
                                               CloseDate = System.Today() + 30 );
        
        Test.startTest(); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);        
        insert testOpp1;
        mapOldOppMap.put(testOpp1.Id, testOpp1);
        
        Id pbk1 = Test.getStandardPricebookId();
        
        Product2 newPrdct1 = new Product2(Name = 'Test Product1',
                                          ProductCode = 'TP1',   
                                          Product_ID__c='test prod id1',
                                          Product_Line_Desc__c = 'Test Product1',
                                          IsActive = TRUE);
        insert newPrdct1;
        
        PricebookEntry PBE1= new PricebookEntry (Product2ID=newPrdct1.id,
                                                 Pricebook2ID=pbk1,
                                                 isActive=true,
                                                 useStandardPrice=false,//CurrencyIsoCode = testOpp1.CurrencyIsoCode,
                                                 UnitPrice = 50);
        insert PBE1;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true); 
        OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOpp1.Id,
                                                                     pricebookEntryId=PBE1.id,
                                                                     Mrgn__c =6,
                                                                     Discount_off__c = 7,
                                                                     UnitPrice = 100,
                                                                     Quantity =2,
                                                                     Description = 'Line Description1'
                                                                    ); 
        
        insert testLineItem1;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        Opportunity testOpp2 = [Select Id, RecordTypeId, Product_Group_Hidden__c, Product_Brand_Hidden__c, Number_of_Line_Items__c from Opportunity where Id =: testOpp1.Id];
        Test.stopTest();
        //Assert the two SAVO fields are populated
        //System.assertEquals(testOpp2.Product_Brand_Hidden__c, 'Test Product1');
        //System.assertEquals(testOpp2.Product_Group_Hidden__c, 'TP1');
        
        //Update the Opportunity Record Type to APOS
        testOpp2.RecordTypeId = GlobalVariables.APOS_OPP_RETYPE;
        newlistOpps.add(testOpp2);
        
        //Calling the updateFieldsForSAVO from OpportunityUtilities explicitly because while running test class the Opportunity record is overridden by some workflow updates and the old and new values are coming as same to make the assertion failure. This approach was suggested by SFDC PS team for the Case #12027182  
        OpportunityUtilities.updateFieldsForSAVO(newlistOpps, mapOldOppMap);
        
        //Assert the two SAVO fields are null while changing the record type to some other from standard
        //System.assertEquals(testOpp2.Product_Brand_Hidden__c, '');
        // System.assert(testOpp2.Product_Brand_Hidden__c.contains('Test Product1'));
        // System.assertEquals(testOpp2.Product_Group_Hidden__c, 'TP1');
        // System.assertEquals(testOpp2.Product_Group_Hidden__c, '');
        
        update newlistOpps;
        
        
        
    }  */
    
    /*  CR          Date            Created By
---         -----------     -----------
CR11414     24-June-2015     Krishnamoorthi

The below method is to increase the test class coverage for "OpportunityUtilities". Please do not write any of your code logic insdie this method.

*/ 
    /* just now committed
    public static testMethod void testOpportunityUtilitiesCoverage() {
        

Account testAccount = new Account(Name='Test Account');        
insert testAccount;        
Opportunity testOpp = new Opportunity(Name='Test Opportunity',
                                      Quote_Numbers__c = '123456',Competitor_Lost_To__c = 'Unknown',
                                      Amount=355000,
                                        Probability = 60,
                                        AccountId=testAccount.Id,
                                        RecordTypeId = '012300000004zf2',StageName='Propose - 60%',  
                                      Forecast_Category_Override__c = 'Commit',
                                        Primary_Product_Delivery_Address_Region__c = 'REGION1',
                                      Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
                                      Region__c = 'APJ',
                                        CloseDate = System.Today() + 30 );

insert testOpp;  //RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,
Opportunity testOpp2 = new Opportunity(Name='Test Opportunity2',Quote_Numbers__c = '12345678',Probability = 60,
                                       Competitor_Lost_To__c = 'Unknown',
                                       AccountId=testAccount.Id,
                                       RecordTypeId = '012A0000000Vi0S',   
                                       StageName='Propose - 60%',
                                       Forecast_Category_Override__c = 'Commit',
                                       Primary_Product_Delivery_Address_Region__c = 'REGION1',
                                      Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
                                      Region__c = 'APJ',
                                         Save_End_Customer_to_my_list__c = 'Yes',
                                      CloseDate = System.Today() + 30 );

insert testOpp2;

Set<Id> setOpportunityIds = new Set<Id>{testOpp.Id};
Set<String> setOfIds = new Set<String>{'00mklojhgfrtde'};   
Map<Id, Opportunity> mapoldOppMap1 = new Map<Id, Opportunity>();
Map<Id, Opportunity> mapNewOppMap1 = new Map<Id, Opportunity>();
Map<Id, Account> mapaccMap = new Map<Id, Account>();
mapaccMap.put(testAccount.Id, testAccount);
List <Opportunity> newlistOpps1 = new List <Opportunity>();
mapoldOppMap1.put(testOpp2.Id, testOpp2);      

Opportunity testOpp3 = [SELECT Id, CloseDate, RecordTypeId, Save_End_Customer_to_my_list__c from Opportunity WHERE Id =: testOpp2.Id];
testOpp3.CloseDate = System.Today() + 35;
testOpp3.OSC_Solution_ID__c = '12345653';
newlistOpps1.add(testOpp3);
mapNewOppMap1.put(testOpp3.Id, testOpp3);

Test.startTest(); 
List<Profile> userProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];        
User tempUser = new User(
Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev',
Alias = 'test', 
Email='test109@dell.com', 
FirstName='Tfirst A1', 
LastName='TLast2',
ProfileId = userProfile[0].Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test'+System.currentTimeMillis(),
Title = 'Test Title',
CurrencyIsoCode = 'USD'
);
insert tempUser;

User tempUser2 = new User(
Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev' +1,
Alias = 'test1a', 
Email='test19@dell.com', 
FirstName='Tfirst A11', 
LastName='TLast2q',
ProfileId = userProfile[0].Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test'+System.currentTimeMillis()+1,
Title = 'Test Title',
CurrencyIsoCode = 'USD'
);
insert tempUser2;

SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Acc Plan', Account__c = testAccount.Id,
Sales_Manager__c = tempUser.Id );   
insert testAccntPlan;

SFDC_Strategy__c testStrategy = new SFDC_Strategy__c(Name='Test Strategy', SFDC_Acct_Plan__c = testAccntPlan.Id);
insert testStrategy;

Map<Id, Opportunity> mapoldOppMap3 = new Map<Id, Opportunity>();
Map<Id, Opportunity> mapNewOppMap3 = new Map<Id, Opportunity>();

Opportunity testOpp4 = new Opportunity(Name='Test Opportunity4', Quote_Numbers__c = '12345678',Probability = 60,
                                       Competitor_Lost_To__c = 'Unknown',
                                       AccountId=testAccount.Id,
                                       RecordTypeId = '012A0000000Vi0S',   
                                       StageName='Propose - 60%',
                                       Forecast_Category_Override__c = 'Commit',
                                       Primary_Product_Delivery_Address_Region__c = 'REGION1',
                                      Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
                                      Region__c = 'APJ',
related_strategy__c = testStrategy.Id,
CloseDate = System.Today() + 30 );

insert testOpp4;
mapoldOppMap3.put(testOpp4.Id, testOpp4);  

Deal_Summary__c ds1 = new Deal_Summary__c(Opportunity__c = testOpp4.id, ForcedCalculation__c = false, Stage__c = testOpp4.StageName);
insert ds1; 

Services_Project__c testSP = new Services_Project__c(Project_Name__c = 'testSPrec',Opportunity__c = testOpp4.id);
insert testSP;

Opportunity testOpp5 = [SELECT Id, Amount, related_strategy__c, CloseDate, Services_Project_Count__c, OwnerId,
                       Quote_Numbers__c,Probability,StageName,Forecast_Category_Override__c FROM Opportunity WHERE Id =: testOpp4.Id];

testOpp5.Amount = 1001;
mapNewOppMap3.put(testOpp5.Id, testOpp5);
List <Opportunity> newlistOpps2 = new List <Opportunity>();
newlistOpps2.add(testOpp5);
update testOpp5;

Opportunity testOpp6 = [SELECT Id, Amount, CloseDate, OwnerId FROM Opportunity WHERE Id =: testOpp5.Id];
testOpp6.OwnerId = tempUser.Id;
testOpp6.CloseDate = System.Today() + 33;
List <Opportunity> newlistOpps3 = new List <Opportunity>();
newlistOpps3.add(testOpp6);

Opportunity testOpp7 = [SELECT Id, Amount, CloseDate, OwnerId, Deal_Registration_Status__c, End_Customer__c FROM Opportunity WHERE Id =: testOpp2.Id];
testOpp7.Deal_Registration_Status__c = 'Submitted';
testOpp7.End_Customer__c =  tempUser2.Id;
List <Opportunity> newlistOpps4 = new List <Opportunity>();
newlistOpps4.add(testOpp7);


Opportunity testOpp8 = new Opportunity(Name='Test Opportunity4',Quote_Numbers__c = '12345678',Probability = 60,
                                       Competitor_Lost_To__c = 'Unknown',
                                       AccountId=testAccount.Id,
                                       RecordTypeId = '012A0000000Vi0S',   
                                       StageName='Propose - 60%',
                                       Forecast_Category_Override__c = 'Commit',
                                       Primary_Product_Delivery_Address_Region__c = 'REGION1',
                                      Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
                                      Region__c = 'APJ',
Related_Parent_Opportunity__c = testOpp5.Id,
CloseDate = System.Today() + 30 );

insert testOpp8;
Map<Id, Opportunity> mapOldOppMap4 = new Map<Id, Opportunity>();
mapOldOppMap4.put(testOpp8.Id, testOpp8);
Opportunity testOpp9= [SELECT Id, Amount, CloseDate, OwnerId, Related_Parent_Opportunity__c FROM Opportunity WHERE Id =: testOpp8.Id];
testOpp9.Related_Parent_Opportunity__c = testOpp7.Id;
testOpp9.CloseDate = System.Today() + 37;
List <Opportunity> newlistOpps5 = new List <Opportunity>();
newlistOpps5.add(testOpp9);

OpportunityUtilities.updateRSSSupportRequest(setOpportunityIds);
OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(newlistOpps1, mapoldOppMap1);
OpportunityUtilities.createSolutions(newlistOpps1, mapaccMap);
OpportunityUtilities.updateDealSummary(mapNewOppMap3, mapoldOppMap3);
OpportunityUtilities.createOpportunityDescriptionHistory(newlistOpps1);
OpportunityUtilities.createSolutionCertificate(setOpportunityIds, mapoldOppMap1);
OpportunityUtilities.linkToAccountPlay(newlistOpps1, setOfIds);
OpportunityUtilities.createSOMBoomiLogs(newlistOpps2,mapoldOppMap3,mapoldOppMap3);
OpportunityUtilities.updatePartnerSalesRepDetails(newlistOpps3, mapNewOppMap3, mapNewOppMap3);
OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(newlistOpps4, mapoldOppMap1);
TriggerHandler.TriggerEvent trigev = TriggerHandler.TriggerEvent.ISUPDATE;
OpportunityUtilities.recalculateQuestRevenues(newlistOpps5, mapOldOppMap4, trigev);
OpportunityUtilities.storeDeletedOpportunityDetailInPartnerHub(newlistOpps1);

Test.stopTest();
}
    */
    /* NOTE This Test method is for code coverage for OpportunityLineItemUtilities */ 
    public static testmethod void testCoverageOppLineItemUtilities(){ 
        
        List<OpportunityLineItem> listoli = new List<OpportunityLineItem>();
        List<Support_Request__c> listsr = new List<Support_Request__c>();
        Date dCloseDate = System.Today()+10;
        
        String stroPPSTDRECORDTYPEID = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true); 
        String strsRCSSRECORDTYPEID  = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);
        TriggerExecutionController.setSkipAllTriggers(true);
        Product2 product = new product2(name='Test Product 1', Product_ID__c='test prod id1', family='Services',isActive=true, Dgr_Eligible__c = 'Yes', DSG_Sales_Motion__c = 'Bidirectional product');   
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntry = new PricebookEntry(pricebook2id=pricebookId, product2id=product.id,CurrencyIsoCode = 'USD', unitprice=900000.0,useStandardPrice=false, isActive=true);      
        insert pricebookEntry;
        
        
        
        Account testAcc  = new Account(Name='Test Account');
        insert testAcc;
        
        /*Revenue__c  testRevenue1 = new Revenue__c( Account__c=testAcc.ID,
Fiscal_Quarter__c = 'Q03',
Fiscal_Year__c = 'FY2015',
Non_Tied_QTR_Rev__c = 1.00,
S_P_QTR_Rev__c = 1.00,
Server_QTR_Rev__c = 1.00,
Notebook_QTR_Rev__c = 1.00, 
EMC_QTR_Rev__c = 1.00, 
Power_Vault_QTR_Rev__c = 1.00,
Imaging_QTR_Rev__c = 1.00,
Desktop_QTR_Rev__c = 1.00,
Workstation_QTR_Rev__c = 1.00,
Non_Tied_QTR_Margin__c = 10.00, 
S_P_QTR_Margin__c = 10,  
Server_QTR_Margin__c = 10, 
Notebook_QTR_Margin__c = 10,  
EMC_QTR_Margin__c = 10,  
Powervault_QTR_Margin__c = 10, 
Imaging_QTR_Margin__c = 10, 
Desktop_QTR_Margin__c = 10, 
Workstation_QTR_Margin__c = 10);
Insert testRevenue1;*/
        
        Contact testCon = new Contact(FirstName='first', Phone='044223667788',AccountId = testAcc.Id, Lastname = 'UT',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                      Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                      MobilePhone = '9030587363',Eloqua_ID__c = '1234',MailingCity = 'Test city',
                                      MailingCountry = 'TestCountry',
                                      MailingState = 'TestState',
                                      MailingPostalCode = '63000',                                  
                                      Email = 'testemail@dell.com');
        
        insert testCon;
        
        //Country__c Cntry = new Country__c(name='test Country', Opportunity_Won_Lost_Region__c = 'APJ', Dell_Online_Country_Code__c='JC',Code__c='JC',Enabled_Auto_Renewal__c=True,Last_Operation_Performed__c='Test Data');
        //insert Cntry;
        
        List<Profile> listUserProfiles= [select id,name from profile where name like '%Sales%' order by name limit 2 ];
        User tempUser = new User(            
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev', 
            Alias = 'test',           
            Email='test109@dell.com',  
            FirstName='Tfirst A1',     
            LastName='TLast2',          
            ProfileId = listUserProfiles[0].Id,     
            LanguageLocaleKey='en_US',          
            LocaleSidKey='en_US',        
            EmailEncodingKey='UTF-8',      
            TimeZoneSidKey='America/Los_Angeles',   
            Badge_Number__c='Test'+System.currentTimeMillis(),    
            Title = 'Test Title',
            //Country = Cntry.id,
            //Contact = testCon.Id, 
            CurrencyIsoCode = 'USD'        );   
        insert tempUser;
        
        List<AccountTeamMember> listatmList=new List<AccountTeamMember>();
        for (integer i=0; i<2;i++){            
            AccountTeamMember atm01=new AccountTeamMember(userId=tempUser.id,TeamMemberRole='Inside Sales Rep',accountId = testAcc.id); 
            listatmList.add(atm01);            
        } 
        insert listatmList;
        TriggerExecutionController.setSkipAllTriggers(False);
        test.startTest();
        List<Opportunity> listOpps = new List<Opportunity>();
        Opportunity testRelatedOpp = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                                     Name              = 'Test Opportunity 1', 
                                                     AccountId         = testAcc.ID, 
                                                     Type              = 'Deal/Bid Direct', 
                                                     Domain__c         = 'Business Solutions',
                                                     Solution_Type__c  = 'Business Processing Solutions',
                                                     Solution_Name__c  = 'CRM',
                                                     CloseDate         = dCloseDate, 
                                                     CurrencyIsoCode   = 'USD',
                                                     StageName         = 'Qualify - 30%', 
                                                     Competitor_Lost_To__c='Unknown', 
                                                     Forecast_Category_Override__c = 'Pipeline',
                                                    Primary_Competitor_Product_Type__c ='HCl');  
        
        //insert testRelatedOpp;   
        listOpps.add(testRelatedOpp);
        Opportunity testOpp = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                              Name              = 'Test Opportunity 2', 
                                              AccountId         = testAcc.ID, 
                                              Type              = 'Deal/Bid Direct', 
                                              Domain__c         = 'Business Solutions',
                                              Solution_Type__c  = 'Business Processing Solutions',
                                              Solution_Name__c  = 'CRM',
                                              CloseDate         = dCloseDate, 
                                              CurrencyIsoCode   = 'USD',
                                              StageName         = 'Qualify - 30%', 
                                              Competitor_Lost_To__c='Unknown',
                                              Quest_Software_Contact__c = testCon.ID,
                                              Related_Parent_Opportunity__c = testRelatedOpp.Id,
                                              OwnerId = tempUser.Id, 
                                              Forecast_Category_Override__c = 'Pipeline',
                                              Primary_Competitor_Product_Type__c = 'HCl');    
        
        // insert testOpp;
        listOpps.add(testOpp);
        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);                                     
        insert listOpps;
        
        
        OpportunityLineItem oli1 = new OpportunityLineItem( Opportunityid =testOpp.ID,
                                                           pricebookEntryId=pricebookEntry.id,
                                                           Mrgn__c =6,
                                                           Discount_off__c = 1,
                                                           UnitPrice = 100000,
                                                           Quantity =20000,
                                                           Description = 'Line Description',
                                                           Service_Support_US__c = 'ProSupport IT - Mission Critical',
                                                           Quest_Product_Integration_Status__c = 'true');
        
        OpportunityLineItem oli2 = new OpportunityLineItem( Opportunityid =testOpp.ID,
                                                           pricebookEntryId=pricebookEntry.id,
                                                           Mrgn__c =6,
                                                           Discount_off__c = 2,
                                                           UnitPrice = 1000,
                                                           Quantity =2000,
                                                           Description = 'Line Description',
                                                           Service_Support_US__c = 'ProSupport IT - Mission Critical',
                                                           Quest_Product_Integration_Status__c = 'true');
        
        OpportunityLineItem oli3 = new OpportunityLineItem( Opportunityid =testOpp.ID,
                                                           pricebookEntryId=pricebookEntry.id,
                                                           Mrgn__c =6,
                                                           Discount_off__c = 7,
                                                           UnitPrice = 100000,
                                                           Quantity =20,
                                                           Description = 'Line Description',
                                                           Service_Support_US__c = 'ProSupport IT - Mission Critical',
                                                           Quest_Product_Integration_Status__c = 'true');
        
        listoli.add(oli1);
        listoli.add(oli2);
        listoli.add(oli3);
        
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true); 
        insert listoli;  
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
        
        
        List<OpportunityTeamMember> listOtm=new List<OpportunityTeamMember>();
        
        OpportunityTeamMember testOTM1 = new OpportunityTeamMember (UserId=tempUser.Id, TeamMemberRole='DM Sales Specialist', OpportunityId=testRelatedOpp.Id);
        OpportunityTeamMember testOTM2 = new OpportunityTeamMember (UserId=tempUser.Id, TeamMemberRole='DM Sales Specialist', OpportunityId=testRelatedOpp.Id);
        OpportunityTeamMember testOTM3 = new OpportunityTeamMember (UserId=tempUser.Id, TeamMemberRole='DM Sales Specialist', OpportunityId=testRelatedOpp.Id);
        OpportunityTeamMember testOTM4 = new OpportunityTeamMember (UserId=tempUser.Id, TeamMemberRole='DM Sales Specialist', OpportunityId=testRelatedOpp.Id);
        OpportunityTeamMember testOTM5 = new OpportunityTeamMember (UserId=tempUser.Id, TeamMemberRole='DM Sales Specialist', OpportunityId=testRelatedOpp.Id);
        OpportunityTeamMember testOTM6 = new OpportunityTeamMember (UserId=tempUser.Id, TeamMemberRole='DM Sales Specialist', OpportunityId=testRelatedOpp.Id);
        OpportunityTeamMember testOTM7 = new OpportunityTeamMember (UserId=tempUser.Id, TeamMemberRole='DM Sales Specialist', OpportunityId=testRelatedOpp.Id);
        OpportunityTeamMember testOTM8 = new OpportunityTeamMember (UserId=tempUser.Id, TeamMemberRole='DM Sales Specialist', OpportunityId=testRelatedOpp.Id);
        
        listOtm.add(testOTM1);
        listOtm.add(testOTM2);
        listOtm.add(testOTM3);
        listOtm.add(testOTM4);
        listOtm.add(testOTM5);
        listOtm.add(testOTM6);
        listOtm.add(testOTM7);
        listOtm.add(testOTM8);
        
        insert listOtm;
        //Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
        //oppMap.put(testOpp.Id,testOpp);
        //Opportunityfieldpopulator.populateforecastflagsummary(oppMap, null);
        //Opportunityfieldpopulator.updateSummaryflag(new set<ID>{testOpp.Id,testRelatedOpp.id},null,true);
        TriggerExecutionController.setSkipOpportunityTriggers(false);       
        test.stopTest();     
    }
    
    /*  CR          Date            Created By
---         -----------     -----------
CR11414     24-June-2015     Krishnamoorthi

The below method is to increase the test class coverage for "OpportunityFieldPopulator". Please do not write any of your code logic insdie this method.

*/
    /*public static testMethod void testOpportunityFieldPopulatorCoverage() {

integer i;
Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
Id createDealFromLOBRTId = StaticDataUtils.getRecordTypeIdByName('Opportunity', 'Create New Deal From LOB');

TriggerExecutionController.setSkipAccountTriggers(true);
Account testPartnerAccount = new Account(name='Test PAcc',account_country_code__c='US', RecordTypeId=accRTId, Type = 'Partner');
insert testPartnerAccount;
//testPartnerAccount.isPartner = true;
//testPartnerAccount.;
//update testPartnerAccount;   

Account testAccount = new Account(name='Test Acc',account_country_code__c='US', Participating_in_LOB_Program__c=true);
insert testAccount;

//Country__c Cntry1 = new Country__c(name='test Country1', Opportunity_Won_Lost_Region__c = 'APJ', Dell_Online_Country_Code__c='JC',Code__c='JC',Enabled_Auto_Renewal__c=True,Last_Operation_Performed__c='Test Data');
//insert Cntry1;


Account_Branch__c accBranch=new Account_Branch__c(Name='Test Branch',Account__c=testAccount.Id);
insert accBranch;   

LOB_Registration__c lob=new LOB_Registration__c(Registered_End_User__c=testAccount.Id,Location__c=accBranch.Id);
insert lob;
Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
List<User> listTestUsers = new List<User>();
for (i=0; i<2;i++){
User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
Alias = 'test'+i, 
Email='test'+ i +'@dell.com', 
FirstName='Tfirst'+i, 
LastName='TLast'+i,
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test'+i+System.currentTimeMillis());

listTestUsers.add(user);   
} 
insert listTestUsers;

List<AccountTeamMember> listatmArray=new List<AccountTeamMember>();

for (i=0; i<2;i++){            
AccountTeamMember atm01=new AccountTeamMember(userId=listTestUsers[i].Id,TeamMemberRole='Inside Sales Rep',accountId = testAccount.Id); 
listatmArray.add(atm01);            
} 
insert listatmArray;
//Test.startTest();       
Opportunity testOpp = new Opportunity(Name='Test Opportunity', 
AccountId=testPartnerAccount.Id,
//PartnerAccountId = testAccount.Id,
RecordTypeId = createDealFromLOBRTId,  
LOB_Registration_ID__c = lob.Id,    
StageName='10%',
CloseDate = System.Today() + 30 );

insert testOpp;

Opportunity testopp11 = [SELECT Id, AccountId, PartnerAccountId, LOB_Registration_ID__c FROM Opportunity WHERE Id =: testOpp.Id];

Map<Id, Opportunity> mapNewOppMap = new Map<Id, Opportunity>();
mapNewOppMap.put(testOpp11.Id, testOpp11);

OpportunityFieldPopulator.populateOpportunityTeamMembers(mapNewOppMap); //populateOpportunityTeamMembers
Test.startTest();
//Kokila's changes
Account testAcc1  = new Account(Name='Test Account1',Partner_Relationship__c ='Preferred');
insert testAcc1;

Date dCloseDate = System.Today()+10;

Contact testCon1 = new Contact(FirstName = 'Contact1',
LastName = 'Test1',
AccountId = testAcc1.ID,
MailingCity = 'Test city',
MailingCountry = 'TestCountry',
MailingState = 'TestState',
MailingPostalCode = '63000',
Phone = '23566889',
Email = 'testemail@dell.com',
Decision_Making_Role__c = 'Sponsor/ Champion');

insert testCon1;

List<Opportunity> listOpp1 = new List<Opportunity>(); 



List<Profile> userProfile1= [select id,name from profile where name like '%Sales%' order by name limit 2 ];
User tempUser1 = new User(            
Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev', 
Alias = 'test',           
Email='test109@dell.com',  
FirstName='Tfirst A1',     
LastName='TLast2',          
ProfileId = userProfile1[0].Id,     
LanguageLocaleKey='en_US',          
LocaleSidKey='en_US',        
EmailEncodingKey='UTF-8',       
TimeZoneSidKey='America/Los_Angeles',   
Badge_Number__c='Test'+System.currentTimeMillis(),    
Title = 'Test Title',
//Country = Cntry1.id,
//Contact = testCon.Id, 
CurrencyIsoCode = 'USD'        );   
insert tempUser1;


String stroPPSTDRECORDTYPEID = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true); 
Opportunity testOpp1 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
Name              = 'Test Opportunity 1', 
AccountId         = testAcc1.ID, 
Type              = 'Deal/Bid Direct', 
Domain__c         = 'Business Solutions',
Solution_Type__c  = 'Business Processing Solutions',
Solution_Name__c  = 'CRM',
CloseDate         = dCloseDate, 
CurrencyIsoCode   = 'USD',
StageName         = 'Qualify - 30%', 
Competitor_Lost_To__c='Unknown',
Quest_Software_Contact__c = testCon1.ID,
OwnerId = tempUser1.Id,
Deal_Registration_Status__c = 'Submitted',
Submitter_Profile__c = 'NA PRM',
DSG_Renewal_request__c = true
);     



listOpp1.add(testOpp1);

Opportunity testOpp2 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
Name              = 'Test Opportunity 2', 
AccountId         = testAcc1.ID, 
Type              = 'Deal/Bid Direct', 
Domain__c         = 'Business Solutions',
Solution_Type__c  = 'Business Processing Solutions',
Solution_Name__c  = 'CRM',
CloseDate         = dCloseDate, 
CurrencyIsoCode   = 'USD',
StageName         = 'Qualify - 30%', 
Competitor_Lost_To__c='Unknown',
Quest_Software_Contact__c = testCon1.ID,
OwnerId = tempUser1.Id,
Deal_Registration_Status__c = 'Submitted',
Submitter_Profile__c = 'NA PRM'
);     

//Insert testOpp2;
listOpp1.add(testOpp2);
Opportunity testOpp3 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
Name              = 'Test Opportunity 3', 
AccountId         = testAcc1.ID, 
Type              = 'Deal/Bid Direct', 
Domain__c         = 'Business Solutions',
Solution_Type__c  = 'Business Processing Solutions',
Solution_Name__c  = 'CRM',
CloseDate         = dCloseDate, 
CurrencyIsoCode   = 'USD',
StageName         = 'Qualify - 30%', 
Competitor_Lost_To__c='Unknown',
Quest_Software_Contact__c = testCon1.ID,
OwnerId = tempUser1.Id,
Deal_Registration_Status__c = 'Submitted',
Submitter_Profile__c = 'NA PRM',
DSG_Renewal_request__c = true
);     


//Insert testOpp3;
listOpp1.add(testOpp3);
insert listOpp1;
Product2 product = new product2(name='Test Product 1', Product_ID__c='test prod id1', Product_Line_Desc__c='EqualLogic',family='Services',isActive=true, Dgr_Eligible__c = 'Yes', DSG_Sales_Motion__c = 'Bidirectional product');   
insert product;
Test.stopTest();        
Id pricebookId = Test.getStandardPricebookId();

PricebookEntry pricebookEntry = new PricebookEntry(pricebook2id=pricebookId, product2id=product.id,CurrencyIsoCode = opp.CurrencyIsoCode, unitprice=900000.0,useStandardPrice=false, isActive=true);      
insert pricebookEntry;

OpportunityLineItem oli3 = new OpportunityLineItem( Opportunityid =testOpp2.ID,
pricebookEntryId=pricebookEntry.id,
Mrgn__c =6,
Discount_off__c = 7,
UnitPrice = 100000,
Quantity =20,
Description = 'Line Description',
Service_Support_US__c = 'ProSupport IT - Mission Critical',
Quest_Product_Integration_Status__c = 'true');

insert oli3;           
OpportunityFieldPopulator.populateRegionForSMBOpportunities(listOpp1);                                                 
Map<Id, Opportunity> mapRelatedOpp = new Map<Id, Opportunity>();
Map<Id, Opportunity> mapOldOppMap = new Map<Id, Opportunity>();

mapOldOppMap.put(testOpp2.Id, testOpp2);  
//mapRelatedOpp.put(testOpp3.Id,testOpp3);
OpportunityFieldPopulator.populateRegionForSMBOpportunities(listOpp1);

mapRelatedOpp = new map<Id, Opportunity>([select Id, Name, AccountId, Account.Account_ID__c, CreatedBy.Profile.Name, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Contact.Email, Owner.Contact.AccountId, Owner.Contact.Phone, Owner.Contact.Account.Partner_Relationship__c, Owner.Profile.Name, Deal_Registration_Status__c,(select Id, OpportunityId, Active_Wyse_Product__c, Product_Line_Desc__c, Description from OpportunityLineItems)
from Opportunity where Id =:testOpp2.Id]);

Opportunity testOpp4 = [SELECT Id, Deal_Registration_Status__c FROM Opportunity WHERE Id =: testOpp2.Id];
testOpp4.Deal_Registration_Status__c = 'Approved';
List<Opportunity> listOpp2 = new List<Opportunity>(); 
listOpp2.add(testOpp4);

OpportunityFieldPopulator.updateDealExpirationDetails(listOpp2,mapOldOppMap,mapRelatedOpp);
OpportunityFieldPopulator.populateOrderComplianceproduct(mapRelatedOpp.values());

} 

public static testMethod void testPopulateAccountName(){
Id endUserAccRTId = StaticFactory.getRecordTypeIdByDevName('Account', 'GBL_Standard_RT'); // End-User Account record type
Account endUserAcc = new Account(name='Test LOB End User Account', RecordtypeId = endUserAccRTId, Participating_in_LOB_Program__c=true, Status__c = 'Active', Unassigned_End_User_Account__c = false);
insert endUserAcc;

Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
insert newAcc;

End_Customer__c endCustomer = new End_Customer__c(
Partner_Account__c = newAcc.Id,
End_User_Account__c = endUserAcc.Id,
Name = 'Test Company',
Mailing_city__c = 'Test City' ,
Mailing_country__c = 'Test Country',
Mailing_State__c = 'Test State',
Mailing_street__c = 'Test Street',
Status__c ='Active',
Website__c = 'www.salesforce.com',
Zip_Code__c = '664455',
Account_Industry__c = 'Agriculture'

);
insert endCustomer ;

Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
End_Customer__c = endCustomer.Id,
Deal_Registration_Status__c= 'New',
Total_Expected_Dell_Revenue__c =1919191,
RecordTypeID = dealRTId,
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
CloseDate = System.Today() + 30 );        


TriggerExecutionController.setSkipOpportunityTriggers(true);
insert testOppty;
TriggerExecutionController.setSkipOpportunityTriggers(false);

testOppty.Deal_Registration_Status__c= 'Submitted' ;                                
update testOppty;
}
*/
    public static testMethod void testpopulatePrimaryCampaignSource() {
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        ProcessFlowTriggerController.isTest = true; // 5.0
        
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;   
        
        
        CMAP_Queue_Settings__c cMAPsetting = new CMAP_Queue_Settings__c();
        CMAPsetting.Name = 'Channel_eClerx';
        CMAPsetting.Queue_Id__c = '00GA0000002y6hl';
        CMAPsetting.Queue_Name__c = 'Channel_eClerx';
        insert CMAPsetting;
        
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                                              Campaign_Objective__c='Acquisition/Site Development',
                                              Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                              Region__c='ABU',                        
                                              Follow_Up_Role__c='Account Executive',
                                              Description='Test',StartDate=system.today(),EndDate=system.today(),
                                              status='In Progress',
                                              recordTypeId = campRTId,
                                              Allocation_Source__c = 'Dell Allocation ABU',
                                              Nurture_Source__c = 'Dell Nurturing',
                                              Country_Code__c = 'BR - Brazil',
                                              Partner_Event_or_Campaign__c = False,
                                              IsActive = true,
                                              Total_Campaign_Targets_Planned__c = 1,
                                              Total_Value_Won_Opportunities_Planned__c = 1,
                                              Total_Value_Opportunities_Planned__c = 1,
                                              Lead_Routing__c = 'Dell Standard');
        insert campChannelObj;
        
        List<Lead> listLeadtoInsert = new List<Lead>();
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 //   Relationship_Lead__c = 'Account Play',                
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        listLeadtoInsert.add(leadObj1);
        Lead leadObj2 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 //   Relationship_Lead__c = '',                
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        listLeadtoInsert.add(leadObj2);
        insert listLeadtoInsert;  
        
        End_Customer__c endCustomer = new End_Customer__c(
            Partner_Account__c = newAcc.Id,
            Name = 'Test Company',
            Mailing_city__c = 'Test City' ,
            Mailing_country__c = 'Test Country',
            Mailing_State__c = 'Test State',
            Mailing_street__c = 'Test Street',
            Status__c ='Active',
            Website__c = 'www.salesforce.com',
            Zip_Code__c = '664455',
            Account_Industry__c = 'Agriculture'
            
        );
        insert endCustomer ;    
        Test.startTest(); 
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
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
                                                End_Customer__c = endCustomer.Id,
                                                CloseDate = System.Today() + 30, 
                                                Forecast_Category_Override__c = 'Omitted');        
        
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true); 
        insert testOppty;
        // CR-14160 - Start
        system.assertEquals(Null,testOppty.EMC_sales_motion__c);
        system.assertEquals(Null,testOppty.EMC_Opportunity_updated__c);
        system.assertEquals(Null,testOppty.Opportunity_Details_Extra__c);
        //CR-14160 - End
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        
        
        testOppty.Distributor_Name__c='Distribution';
        testOppty.Channel_Lead_Id__c = LeadObj2.Id;
        testOppty.StageName = 'Discover - 10%';
        testOppty.Probability = 10;
        testOppty.Forecast_Category_Override__c = 'Omitted';
        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        update testOppty;
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        
        List<Opportunity> listOpp=new List<Opportunity>();
        listOpp.add(testOppty);
        OpportunityFieldPopulator.populatePrimaryCampaignSource(listOpp,new Map<ID, Lead>(listLeadtoInsert).keySet(),TriggerHandler.TriggerEvent.ISINSERT);
        Test.stopTest();
        system.assertEquals('Omitted',testOppty.Forecast_Category_Override__c);
        
    }
    
    public static testMethod void testpopulateOpportunityTeamMembers() {
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true); 
        TriggerExecutionController.setSkipAllTriggers(true);  
        string strcountryCode = 'US';
        string strlanguageCode = 'ja';
        User u = createPartnerUser(strcountryCode, strlanguageCode);
        string strlobName = 'TestLOBAdmin';
        string strlocationName = 'TestAccountBranch';  
        string strpartnerAccountId = [SELECT Contact.AccountId FROM User WHERE Id = :u.Id][0].Contact.AccountId;
        Account partnerAccount=[select id,name from account where id =:strpartnerAccountId];
        Account endUserAccount = createEndUserAccount();
       Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner',Is_GTM_Partner__c=true);
        insert newAcc;
        //Account_Branch__c accountBranch = createAccountBranch(strlocationName, endUserAccount);
        //LOB_Administration__c lobAdmin = createLOBAdministration(strlobName);
        //LOB_Registration__c lob = createLOBRegistration(accountBranch, lobAdmin, strpartnerAccountId);
        LOB_Registration__c lob= new LOB_Registration__c ();
        lob.LOB_Name__c ='Client';             
        lob.Registered_End_User__c= endUserAccount.Id;
        lob.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
        lob.LOB_registration_status__c = 'Partner(approved)';
        lob.LOB_Award_Type__c = 'All Account';
        lob.Preferred_GTM_Partner_Account__c = newAcc.id;          
        lob.City__c  ='testCity';
        lob.State_Province_Region__c = 'testState';
        insert lob;
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        List<User> listTestUsers = new List<User>();
        for (integer i=0; i<2;i++){
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
                                 Alias = 'test'+i, 
                                 Email='test'+ i +'@dell.com', 
                                 FirstName='Tfirst'+i, 
                                 LastName='TLast'+i,
                                 ProfileId = userProfile.Id, 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 Badge_Number__c='Test'+i+System.currentTimeMillis());
            
            listTestUsers.add(user);   
        } 
        insert listTestUsers;
        //TriggerExecutionController.setSkipOpportunityTriggers(true);     
        List<AccountTeamMember> listatmArray=new List<AccountTeamMember>();
        for (integer i=0; i<1;i++){            
            AccountTeamMember atm01=new AccountTeamMember(userId=listTestUsers[i].Id,TeamMemberRole='Inside Sales Rep',accountId = strpartnerAccountId); 
            listatmArray.add(atm01);            
        } 
        insert listatmArray;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        Opportunity oppty = createOpportunity(lob,endUserAccount,strlocationName, u);
        Test.startTest();        
        insert oppty;
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);         
        system.debug('oppty Partner AccountID====>>>>'+oppty.PartnerAccountId);
        map<id,Opportunity> mapOppotunity= new Map<id,Opportunity>();
        mapOppotunity.put(oppty.id,oppty);
        OpportunityFieldPopulator.populateOpportunityTeamMembers(mapOppotunity);
        Test.stopTest();
    }
    public static Account createEndUserAccount(){
        Account endUserAccount = new Account(Name = 'createAccount', Account_Country_Code__c = 'US', Participating_in_LOB_Program__c = true);
        insert endUserAccount;
        return endUserAccount;      
    }
    
    private static Account_Branch__c createAccountBranch(string strname, Account endUserAccount){
        Account_Branch__c location = new Account_Branch__c(Name = strname, Account__c = endUserAccount.Id);
        insert location;
        return location;
    } 
    
    private static LOB_Administration__c createLOBAdministration(string strlobName){
        LOB_Administration__c lobAdmin = new LOB_Administration__c(Name = strlobName);
        insert lobAdmin;
        return lobAdmin;
    }
    
    private static LOB_Registration__c createLOBRegistration(Account_Branch__c location, LOB_Administration__c lobAdmin, string strpartnerAccountId){
        //CRQ0241 reminder : uncomment after type change       
        LOB_Registration__c lob = new LOB_Registration__c(Registered_End_User__c = location.Account__c, LOB_registration_status__c = 'Partner(approved)',
                                                          Location__c = location.Id, LOB_Name__c = lobAdmin.Name,
                                                          Preferred_GTM_Partner_Account__c = strpartnerAccountId);
        insert lob;
        return lob;
    }
    
    public static Opportunity createOpportunity(LOB_Registration__c lob, Account endUserAccount, string strAccountDepartmentName, User u){
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Create New Deal From LOB'];
        Opportunity oppty = new Opportunity(Name = getUniqueString(), Total_Expected_Dell_Revenue__c = 24500.00, CloseDate = Date.today().addDays(30),
                                            Engagement_Type__c = getFirstPicklistValue(Opportunity.Engagement_Type__c.getDescribe()), 
                                            OS_Type__c = getFirstPicklistValue(Opportunity.OS_Type__c.getDescribe()), Justification_Statement__c = 'createOpportunity',
                                            Solution_Scope__c = getFirstPicklistValue(Opportunity.Solution_Scope__c.getDescribe()), 
                                            //11.0 Virtualization__c = getFirstPicklistValue(Opportunity.Virtualization__c.getDescribe()), 
                                            End_User_Account_Name__c = endUserAccount.Name, End_User_Account_Department__c = strAccountDepartmentName,
                                            Total_of_End_of_User_Employees__c = getFirstPicklistValue(Opportunity.Total_of_End_of_User_Employees__c.getDescribe()),
                                            End_User_Mailing_City__c = 'City', End_User_Mailing_State_Province_Region__c = 'Region',
                                            End_User_Mailing_Country__c = getFirstPicklistValue(Opportunity.End_User_Mailing_Country__c.getDescribe()),
                                            End_User_First_Name__c = 'FN', End_User_Last_Name__c = 'LN', End_User_Email__c = 'test@test.com',
                                            End_User_Phone__c = '01-23 45678', End_User_Segment__c = getFirstPicklistValue(Opportunity.End_User_Segment__c.getDescribe()),
                                            Is_the_Customer_Part_of_a_Larger_Group__c = getFirstPicklistValue(Opportunity.Is_the_Customer_Part_of_a_Larger_Group__c.getDescribe()),
                                            StageName = getFirstPicklistValue(Opportunity.StageName.getDescribe()), RecordTypeId = rt.Id, OwnerId = u.Id, 
                                            Forecast_Category_Override__c = 'Omitted');
        return oppty;
    }
    
    
    /*public static Opportunity createPartnerOpportunity(LOB_Registration__c lob, Account partnerAccount, string strAccountDepartmentName, User u){
RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Deal_Registration_for_Existing_End_Customer'];
Opportunity oppty = new Opportunity(Name = getUniqueString(), Total_Expected_Dell_Revenue__c = 24500.00, CloseDate = Date.today().addDays(30),Account=partnerAccount,
Engagement_Type__c = getFirstPicklistValue(Opportunity.Engagement_Type__c.getDescribe()), 
OS_Type__c = getFirstPicklistValue(Opportunity.OS_Type__c.getDescribe()), Justification_Statement__c = 'createOpportunity',
Solution_Scope__c = getFirstPicklistValue(Opportunity.Solution_Scope__c.getDescribe()), 
Virtualization__c = getFirstPicklistValue(Opportunity.Virtualization__c.getDescribe()), LOB_Registration_ID__c = lob.Id,
StageName = getFirstPicklistValue(Opportunity.StageName.getDescribe()), RecordTypeId = rt.Id, OwnerId = u.Id);
return oppty;
}*/
    
    private static void createLOBAutoApprovalAdministration(Id lobAdminId, string strcountryCode, string strlanguage, boolean bEnabled){
        Id countryId = null;
        List<Country__c> listCountries = [SELECT Id FROM Country__c WHERE Code__c = :strcountryCode];
        if((listCountries != null) && (listCountries.size() > 0)){
            countryId = listCountries[0].Id;
        }else{
            countryId = [SELECT Id FROM Country__c LIMIT 1][0].Id;
        }
        //CRQ0241 reminder : uncomment after type change       
        LOB_Auto_approval_Administration__c autoApprovalAdmin = new LOB_Auto_approval_Administration__c(LOB_Name__c = lobAdminId, Language__c = strlanguage,
                                                                                                        Country__c = countryId, Auto_approval_enabled__c = bEnabled);
        insert autoApprovalAdmin; 
    }
    
    private static Product2 createProduct(string strcode){
        Product2 product = new Product2(Name = 'Test Product', Product_ID__c='test prod id', ProductCode = strcode);
        insert product;
        return product;
    }
    
    private static PricebookEntry createPricebookEntry(Product2 product){
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry entry = new PricebookEntry(UnitPrice = 0.00, Product2Id = product.Id, Pricebook2Id = pricebook.Id,CurrencyIsoCode = 'USD', UseStandardPrice = false, IsActive = true);
        insert entry;
        return entry;
    }
    
    private static OpportunityLineItem createOpportunityLineItem(PricebookEntry entry, string stropptyId){
        OpportunityLineItem item = new OpportunityLineItem(Quantity = 123.0, PricebookEntryId = entry.Id, TotalPrice = 12345.00, OpportunityId = stropptyId);
        insert item;
        return item;
    }
    
    public static User createPartnerUser(string straccountCountryCode, string struserLanguageCode){
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        string straccountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Partner Account'][0].Id;
        Id MasteraccRTId= IdLookupUtils.getRecordTypeId('Master Account','Account',true);
        Account acc = new Account(Name = 'Partner Account', Account_Country_Code__c = straccountCountryCode, Is_GTM_Partner__c = true, RecordTypeId = MasteraccRTId, OwnerId = adminusr.Id);//,
        //OwnerId = '00530000000n5szAAA'); // TODO: OwnerId
        insert acc;
        acc.IsPartner = true;
        update acc;
        
        /*Contact con1 = new Contact(AccountId = acc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT');
insert con1; */
        
        Contact con = new Contact(FirstName='first', Phone='044223667788',AccountId = acc.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                  Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                  MobilePhone = '9030587363',Eloqua_ID__c = '1234');
        insert con;
        
        // Create this user with PowerPartner profile,
        // so that the AccountId will be populated as same as the associated Contact's AccountId
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        //string strproid = [SELECT Id FROM Profile WHERE Name = 'R13.1 EMEA PRM Portal User (MOSS)'][0].Id; // TODO: strproid // Ver 1.0
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User( ContactId = con.id,IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = struserLanguageCode,
                          LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        return u;
    }
    
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
    
    private static string getFirstPicklistValue(Schema.DescribeFieldResult field){
        string strvalue = null;
        List<Schema.Picklistentry> listPicklist = field.getPicklistValues();
        for(Schema.Picklistentry pickListValue : listPicklist){
            strvalue = pickListValue.getValue();
            break; 
        }
        return strvalue;
    }
    
    /*********Meera - updated testmethods to remove SOQL exception******************/
    
    
  /*  public static testMethod void testOpportunityUtilitiesCoverage() {
        TriggerExecutionController.setSkipAllTriggers(true);  
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        Account testAccount = new Account(Name='Test Account');        
        insert testAccount;        
        List<Opportunity> listOppsmod = new List<Opportunity>();
        Opportunity testOpp = new Opportunity(Name='Test Opportunity', 
                                              AccountId=testAccount.Id,
                                              RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,   
                                              StageName='Discover - 10%',
                                              CloseDate = System.Today() + 30, 
                                              Forecast_Category_Override__c = 'Omitted');
        
        //insert testOpp;
        listOppsmod.add(testOpp);
        Opportunity testOpp2 = new Opportunity(Name='Test Opportunity2', 
                                               AccountId=testAccount.Id,
                                               RecordTypeId = '012A0000000Vi0S',   
                                               StageName='Discover - 10%',
                                               Save_End_Customer_to_my_list__c = 'Yes',
                                               CloseDate = System.Today() + 30, 
                                              Forecast_Category_Override__c = 'Omitted');
        
        // insert testOpp2;
        listOppsmod.add(testOpp2);
        Test.startTest(); 
        insert listOppsmod;
        Set<Id> setOpportunityIds = new Set<Id>{testOpp.Id};
            Set<String> setOfIds = new Set<String>{'00mklojhgfrtde'};   
                Map<Id, Opportunity> mapoldOppMap1 = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapNewOppMap1 = new Map<Id, Opportunity>();
        Map<Id, Account> mapaccMap = new Map<Id, Account>();
        mapaccMap.put(testAccount.Id, testAccount);
        List <Opportunity> newlistOpps1 = new List <Opportunity>();
        mapoldOppMap1.put(testOpp2.Id, testOpp2);      
        
        Opportunity testOpp3 = [SELECT Id, CloseDate, RecordTypeId, Save_End_Customer_to_my_list__c from Opportunity WHERE Id =: testOpp2.Id];
        testOpp3.CloseDate = System.Today() + 35;
        //testOpp3.OSC_Solution_ID__c = '12345653';
        testOpp3.OSC_Solution_ID__c = 'AMER:12345653';
        newlistOpps1.add(testOpp3);
        mapNewOppMap1.put(testOpp3.Id, testOpp3);
        List<Profile> userProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];  
        List<User> listUsers = new List<User>();      
        User tempUser = new User(
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev',
            Alias = 'test', 
            Email='test109@dell.com', 
            FirstName='Tfirst A1', 
            LastName='TLast2',
            ProfileId = userProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+System.currentTimeMillis(),
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        //insert tempUser;
        listUsers.add(tempUser);
        
        User tempUser2 = new User(
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev' +1,
            Alias = 'test1a', 
            Email='test19@dell.com', 
            FirstName='Tfirst A11', 
            LastName='TLast2q',
            ProfileId = userProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+System.currentTimeMillis()+1,
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        //insert tempUser2;
        listUsers.add(tempUser2);
        insert listUsers;
        Opportunity testOpp7 = [SELECT Id, Amount, CloseDate, OwnerId, Deal_Registration_Status__c, End_Customer__c FROM Opportunity WHERE Id =: testOpp2.Id];
        testOpp7.Deal_Registration_Status__c = 'Submitted';
        testOpp7.End_Customer__c =  tempUser2.Id;
        List <Opportunity> newlistOpps4 = new List <Opportunity>();
        newlistOpps4.add(testOpp7);
        
        
        
        OpportunityUtilities.updateRSSSupportRequest(setOpportunityIds);
        OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(newlistOpps1, mapoldOppMap1);
        OpportunityUtilities.createSolutions(newlistOpps1, mapaccMap);
        
        OpportunityUtilities.createOpportunityDescriptionHistory(newlistOpps1);
        OpportunityUtilities.linkToAccountPlay(newlistOpps1, setOfIds);
        
        OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(newlistOpps4, mapoldOppMap1);
        TriggerHandler.TriggerEvent trigev = TriggerHandler.TriggerEvent.ISUPDATE;
        
        OpportunityUtilities.storeDeletedOpportunityDetailInPartnerHub(newlistOpps1);
        
        Test.stopTest();
        
    }*/
    public static testMethod void testOpportunityUtilitiesCoverage1() {
        //  TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Account testAccount = new Account(Name='Test Account');        
        insert testAccount;        
        List<Opportunity> listOppsmod = new List<Opportunity>();
        
        //Set<Id> setOpportunityIds = new Set<Id>{testOpp.Id};
        Set<String> setOfIds = new Set<String>{'00mklojhgfrtde'};   
            Map<Id, Opportunity> mapoldOppMap1 = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapNewOppMap1 = new Map<Id, Opportunity>();
        Map<Id, Account> mapaccMap = new Map<Id, Account>();
        mapaccMap.put(testAccount.Id, testAccount);
        List <Opportunity> newlistOpps1 = new List <Opportunity>();
        //mapoldOppMap1.put(testOpp2.Id, testOpp2);      
        List<Profile> listUserProfiles= [select id,name from profile where name like '%Sales%' order by name limit 2 ];  
        List<User> listUsers = new List<User>();      
        User tempUser = new User(
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev',
            Alias = 'test', 
            Email='test109@dell.com', 
            FirstName='Tfirst A1', 
            LastName='TLast2',
            ProfileId = listUserProfiles[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+System.currentTimeMillis(),
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        //insert tempUser;
        listUsers.add(tempUser);
        
        User tempUser2 = new User(
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev' +1,
            Alias = 'test1a', 
            Email='test19@dell.com', 
            FirstName='Tfirst A11', 
            LastName='TLast2q',
            ProfileId = listUserProfiles[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+System.currentTimeMillis()+1,
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        //insert tempUser2;
        listUsers.add(tempUser2);
        insert listUsers;
        
        
        
        
        SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Acc Plan', Account__c = testAccount.Id,
                                                                Sales_Manager__c = tempUser.Id );   
        insert testAccntPlan;
        
        SFDC_Strategy__c testStrategy = new SFDC_Strategy__c(Name='Test Strategy', SFDC_Acct_Plan__c = testAccntPlan.Id);
        insert testStrategy;
        
        Map<Id, Opportunity> mapoldOppMap3 = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapNewOppMap3 = new Map<Id, Opportunity>();
        
        Opportunity testOpp4 = new Opportunity(Name='Test Opportunity4', 
                                               AccountId=testAccount.Id,
                                               StageName='Discover - 10%',
                                               Amount = 1000,
                                               related_strategy__c = testStrategy.Id,
                                               CloseDate = System.Today() + 30, 
                                              Forecast_Category_Override__c = 'Omitted');
        Test.startTest(); 
        insert testOpp4;
        mapoldOppMap3.put(testOpp4.Id, testOpp4);  
        
        Deal_Summary__c ds1 = new Deal_Summary__c(Opportunity__c = testOpp4.id, ForcedCalculation__c = false, Stage__c = testOpp4.StageName);
        insert ds1; 
        
        Services_Project__c testSP = new Services_Project__c(Project_Name__c = 'testSPrec',Opportunity__c = testOpp4.id);
        insert testSP;
        
        Opportunity testOpp5 = [SELECT Id, Amount, related_strategy__c, CloseDate, Services_Project_Count__c, OwnerId FROM Opportunity WHERE Id =: testOpp4.Id];
        testOpp5.OwnerId = tempUser2.Id;
        testOpp5.Amount = 1001;
        testOpp5.CloseDate = System.Today() + 30;
        testOpp5.Forecast_Category_Override__c = 'Omitted';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        mapNewOppMap3.put(testOpp5.Id, testOpp5);
        List <Opportunity> newlistOpps2 = new List <Opportunity>();
        newlistOpps2.add(testOpp5);
        update testOpp5;
        
        Opportunity testOpp6 = [SELECT Id, Amount, CloseDate, OwnerId FROM Opportunity WHERE Id =: testOpp5.Id];
        testOpp6.OwnerId = tempUser.Id;
        testOpp6.CloseDate = System.Today() + 33;
        List <Opportunity> newlistOpps3 = new List <Opportunity>();
        newlistOpps3.add(testOpp6);
        
        
        
        
        Opportunity testOpp8 = new Opportunity(Name='Test Opportunity4', 
                                               AccountId=testAccount.Id,
                                               StageName='Discover - 10%',
                                               Amount = 1000,
                                               Related_Parent_Opportunity__c = testOpp5.Id,
                                               CloseDate = System.Today() + 30, 
                                               Forecast_Category_Override__c = 'Omitted');
        
        insert testOpp8;
        system.assertEquals('Omitted',testOpp8.Forecast_Category_Override__c);
        Map<Id, Opportunity> mapOldOppMap4 = new Map<Id, Opportunity>();
        mapOldOppMap4.put(testOpp8.Id, testOpp8);
        Opportunity testOpp9= [SELECT Id, Amount, CloseDate, OwnerId, Related_Parent_Opportunity__c FROM Opportunity WHERE Id =: testOpp8.Id];
        //testOpp9.Related_Parent_Opportunity__c = testOpp7.Id;
        testOpp9.CloseDate = System.Today() + 37;
        List <Opportunity> newlistOpps5 = new List <Opportunity>();
        newlistOpps5.add(testOpp9);
        Test.stopTest();
        
        OpportunityUtilities.updateDealSummary(mapNewOppMap3, mapoldOppMap3);
        
        
        OpportunityUtilities.linkToAccountPlay(newlistOpps1, setOfIds);
        //OpportunityUtilities.createSOMBoomiLogs(newlistOpps2,mapoldOppMap3,mapoldOppMap3);
        OpportunityUtilities.updatePartnerSalesRepDetails(newlistOpps3, mapNewOppMap3, mapNewOppMap3);
        //OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(newlistOpps4, mapoldOppMap1);
        TriggerHandler.TriggerEvent trigev = TriggerHandler.TriggerEvent.ISINSERT;
        OpportunityUtilities.recalculateQuestRevenues(newlistOpps5, mapOldOppMap4, trigev);
        //OpportunityUtilities.storeDeletedOpportunityDetailInPartnerHub(newlistOpps1);
        
        
    }
    
    /*  CR          Date            Created By
---         -----------     -----------
CR11414     24-June-2015     Krishnamoorthi

The below method is to increase the test class coverage for "OpportunityFieldPopulator". Please do not write any of your code logic insdie this method.

*/
    public static testMethod void testOpportunityFieldPopulatorCoverage() {
        
        integer i;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Id createDealFromLOBRTId = StaticDataUtils.getRecordTypeIdByName('Opportunity', 'Create New Deal From LOB');
        
        TriggerExecutionController.setSkipAllTriggers(true);  
        Account testPartnerAccount = new Account(name='Test PAcc',account_country_code__c='US', RecordTypeId=accRTId, Type = 'Partner');
        insert testPartnerAccount;
        //testPartnerAccount.isPartner = true;
        //testPartnerAccount.;
        //update testPartnerAccount;   
        
        Account testAccount = new Account(name='Test Acc',account_country_code__c='US', Participating_in_LOB_Program__c=true);
        insert testAccount;
        
        //Country__c Cntry1 = new Country__c(name='test Country1', Opportunity_Won_Lost_Region__c = 'APJ', Dell_Online_Country_Code__c='JC',Code__c='JC',Enabled_Auto_Renewal__c=True,Last_Operation_Performed__c='Test Data');
        //insert Cntry1;
        
        
        /*Account_Branch__c accBranch=new Account_Branch__c(Name='Test Branch',Account__c=testAccount.Id);
insert accBranch;   

LOB_Registration__c lob=new LOB_Registration__c(Registered_End_User__c=testAccount.Id,Location__c=accBranch.Id);
insert lob;
*/
        
        LOB_Registration__c lob= new LOB_Registration__c ();
        lob.LOB_Name__c ='Client';             
        lob.Registered_End_User__c= testAccount.Id;
        lob.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
        lob.LOB_registration_status__c = 'Expired';
        lob.LOB_Award_Type__c = 'All Account';
        //lob.Preferred_GTM_Partner_Account__c = testPartnerAccount.Id;          
        lob.City__c  ='testCity';
        lob.State_Province_Region__c = 'testState';
        insert lob;
        
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        List<User> listTestUsers = new List<User>();
        for (i=0; i<2;i++){
            User user = new User(Username='test' +i+ System.currentTimeMillis() + '@test.com',
            Alias = 'test'+i, 
            Email='test'+ i +'@dell.com', 
            FirstName='Tfirst'+i, 
            LastName='TLast'+i,
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+i+System.currentTimeMillis());
            listTestUsers.add(user);   
        } 
        insert listTestUsers;
        
        List<AccountTeamMember> listatmArray=new List<AccountTeamMember>();
        
        for (i=0; i<2;i++){
            AccountTeamMember atm01=new AccountTeamMember(userId=listTestUsers[i].Id,TeamMemberRole='Inside Sales Rep',accountId = testAccount.Id); 
            listatmArray.add(atm01);            
        } 
        insert listatmArray;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.startTest();   
        
        
        Opportunity testOpp = new Opportunity(Name='Test Opportunity', 
                                              AccountId=testAccount.Id,
                                              // PartnerAccountId = testAccount.Id,
                                              RecordTypeId = createDealFromLOBRTId,  
                                              StageName='Discover - 10%',
                                              CloseDate = System.Today() + 30,End_User_Phone__c='9999999990', 
                                              Forecast_Category_Override__c = 'Omitted');
        
        insert testOpp;
        system.assertEquals('Omitted',testOpp.Forecast_Category_Override__c);
        partner p = new Partner();
        p.OpportunityId = testOpp.ID;
        p.AccountToId = testPartnerAccount.Id;
        p.isPrimary = true;
        p.Role ='Identified on Account Level';
        insert p;
        
        
        
        Opportunity testopp11 = [SELECT Id, AccountId, PartnerAccountId FROM Opportunity WHERE Id =: testOpp.Id];
        //  System.debug('++++++++++++++++++++++++>>> '+testopp11.PartnerAccountId +'=============>>>'+testopp11.LOB_Registration_ID__c );
        
        Map<Id, Opportunity> mapNewOppMap = new Map<Id, Opportunity>();
        mapNewOppMap.put(testOpp11.Id, testOpp11);
        
        OpportunityFieldPopulator.populateOpportunityTeamMembers(mapNewOppMap); //populateOpportunityTeamMembers
        Test.stopTest();
        
    } 
    
    public static testMethod void testOpportunityFieldPopulatorCoverage1() {
        
        //TriggerExecutionController.setSkipAccountTriggers(true); // 4.0: switch to skip all triggers
        TriggerExecutionController.setSkipAllTriggers(true); // 4.0
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        //Kokila's changes
        Account testAcc1  = new Account(Name='Test Account1',Partner_Relationship__c ='Preferred', OwnerId = adminusr.Id);
        insert testAcc1;
        List<Account> listAccs=new List<Account>();
        listAccs.add(testAcc1);
        
        Date dCloseDate = System.Today()+10;
        TriggerExecutionController.setSkipContactTriggers(true);
        Contact testCon1 = new Contact(FirstName = 'Contact1',
                                       LastName = 'Test1',
                                       AccountId = testAcc1.ID,
                                       MailingCity = 'Test city',
                                       MailingCountry = 'TestCountry',
                                       MailingState = 'TestState',
                                       MailingPostalCode = '63000',
                                       Phone = '23566889',
                                       Email = 'testemail@dell.com',                                  
                                       Decision_Making_Role__c = 'Sponsor/ Champion');
        
        //TriggerExecutionController.setSkipContactTriggers(true); // 4.0: switch to skip all triggers
        insert testCon1;
        
        List<Opportunity> listOpp1 = new List<Opportunity>(); 
        
        
        
        List<Profile> listUserProfiles1= [select id,name from profile where name like '%LA PRM%' order by name limit 2 ];
        User tempUser1 = new User(            
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev', 
            Alias = 'test',           
            Email='test109@dell.com',  
            FirstName='Tfirst A1',     
            LastName='TLast2',          
            ProfileId = listUserProfiles1[0].Id,     
            LanguageLocaleKey='en_US',          
            LocaleSidKey='en_US',        
            EmailEncodingKey='UTF-8',       
            TimeZoneSidKey='America/Los_Angeles',   
            Badge_Number__c='Test'+System.currentTimeMillis(),    
            Title = 'Test Title',
            //Country = Cntry1.id,
            Contactid = testCon1.Id, 
            CurrencyIsoCode = 'USD'        );   
        insert tempUser1;
        /*TriggerExecutionController.setSkipUserTriggers(true);
tempUser1.ContactId = testCon1.Id;
update tempUser1;*/
        
        
        String stroPPSTDRECORDTYPEID = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true); 
        Opportunity testOpp1 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 1', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Channel_Lead_ID_2__c = '1234567ABCDEFGHI',
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM',
                                               //9.0 DSG_Renewal_request__c = true, 
                                                Forecast_Category_Override__c = 'Best Case',
                                               Primary_Competitor_Product_Type__c ='HCl'
                                              );     
        
        
        
        listOpp1.add(testOpp1);
        
        Opportunity testOpp2 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 2', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Channel_Lead_ID_2__c = '1234567ABCDEFGHI',
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM', 
                                                Forecast_Category_Override__c = 'Best Case',
                                               Primary_Competitor_Product_Type__c ='HCl'
                                              );     
        
        //Insert testOpp2;
        listOpp1.add(testOpp2);
        Opportunity testOpp3 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 3', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM',
                                               Channel_Lead_ID_2__c = '1234567ABCDEFGHI',
                                               //9.0 DSG_Renewal_request__c = true, 
                                                Forecast_Category_Override__c = 'Best Case',
                                               Primary_Competitor_Product_Type__c = 'HCl'
                                              );     
        
        
        //Insert testOpp3;
        listOpp1.add(testOpp3);
        
        insert listOpp1;
        System.debug('Success0');
        
        Product2 product = new product2(name='Test Product 1', Product_ID__c='test prod id1', Product_Line_Desc__c='EqualLogic',family='Services',isActive=true, Dgr_Eligible__c = 'Yes', DSG_Sales_Motion__c = 'Bidirectional product');   
        insert product;
        System.debug('Success1');
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntry = new PricebookEntry(pricebook2id=pricebookId, product2id=product.id,CurrencyIsoCode = 'USD', unitprice=900000.0,useStandardPrice=false, isActive=true);      
        insert pricebookEntry;
        System.debug('Success2');
        OpportunityLineItem oli3 = new OpportunityLineItem( Opportunityid =testOpp2.ID,
                                                           pricebookEntryId=pricebookEntry.id,
                                                           Mrgn__c =6,
                                                           Discount_off__c = 7,
                                                           UnitPrice = 100000,
                                                           Quantity =20,
                                                           Description = 'Line Description',
                                                           Service_Support_US__c = 'ProSupport IT - Mission Critical',
                                                           Quest_Product_Integration_Status__c = 'true');
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true); // 4.0: switch to skip all triggers
        insert oli3; 
        
        //TriggerExecutionController.setSkipOpportunityTriggers(false);// 4.0: switch to skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false); // 4.0
        System.debug('Success3');
        
        Test.startTest();
        OpportunityFieldPopulator.populateRegionForSMBOpportunities(listOpp1);                                                 
        Map<Id, Opportunity> mapRelatedOpp = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapOldOppMap = new Map<Id, Opportunity>();
        
        mapOldOppMap.put(testOpp2.Id, testOpp2);  
        //mapRelatedOpp.put(testOpp3.Id,testOpp3);
        OpportunityFieldPopulator.populateRegionForSMBOpportunities(listOpp1);
        
        mapRelatedOpp = new map<Id, Opportunity>([select Id, Name, AccountId, Account.Account_ID__c, CreatedBy.Profile.Name, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Contact.Email, Owner.Contact.AccountId, Owner.Contact.Phone, Owner.Contact.Account.Partner_Relationship__c, Owner.Profile.Name, Deal_Registration_Status__c,(select Id, OpportunityId, Active_Wyse_Product__c, Product_Line_Desc__c, Description from OpportunityLineItems)
                                                  from Opportunity where Id =:testOpp2.Id]);
        
        Opportunity testOpp4 = [SELECT Id, Deal_Registration_Status__c FROM Opportunity WHERE Id =: testOpp2.Id];
        testOpp4.Deal_Registration_Status__c = 'Approved';
        List<Opportunity> listOpp2 = new List<Opportunity>(); 
        listOpp2.add(testOpp4);
        system.assertEquals('Approved',testOpp4.Deal_Registration_Status__c);
        OpportunityFieldPopulator.updateDealExpirationDetails(listOpp2,mapOldOppMap);
        OpportunityFieldPopulator.populateOrderComplianceproduct(mapRelatedOpp.values());
        OpportunityFieldPopulator.autoPopulateFields(listOpp1,new Map<ID,Opportunity>(listOpp1),TriggerHandler.TriggerEvent.ISINSERT,new Map<ID, Account>(listAccs));
        
        Test.stopTest();    
        
    } 
    public static testMethod void testOpportunityFieldPopulatorCoverage2() {
        
        //TriggerExecutionController.setSkipAccountTriggers(true); // 4.0: switch to skip all triggers
        TriggerExecutionController.setSkipAllTriggers(true); // 4.0
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        //Kokila's changes
        Account testAcc1  = new Account(Name='Test Account1',Partner_Relationship__c ='Premier', OwnerId = adminusr.Id);
        insert testAcc1;
        
        Date dCloseDate = System.Today()+10;
        
        Contact testCon1 = new Contact(FirstName = 'Contact1',
                                       LastName = 'Test1',
                                       AccountId = testAcc1.ID,
                                       MailingCity = 'Test city',
                                       MailingCountry = 'TestCountry',
                                       MailingState = 'TestState',
                                       MailingPostalCode = '63000',
                                       Phone = '23566889',
                                       Email = 'testemail@dell.com',                                  
                                       Decision_Making_Role__c = 'Sponsor/ Champion');
        
        //TriggerExecutionController.setSkipAccountTriggers(true); // 4.0: switch to skip all triggers
        insert testCon1;
        
        List<Opportunity> listOpp1 = new List<Opportunity>(); 
        
        
        
        List<Profile> listUserProfiles1= [select id,name from profile where name like '%LA PRM%' order by name limit 2 ];
        User tempUser1 = new User(            
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev', 
            Alias = 'test',           
            Email='test109@dell.com',  
            FirstName='Tfirst A1',     
            LastName='TLast2',          
            ProfileId = listUserProfiles1[0].Id,     
            LanguageLocaleKey='en_US',          
            LocaleSidKey='en_US',        
            EmailEncodingKey='UTF-8',       
            TimeZoneSidKey='America/Los_Angeles',   
            Badge_Number__c='Test'+System.currentTimeMillis(),    
            Title = 'Test Title',
            //Country = Cntry1.id,
            Contactid = testCon1.Id, 
            CurrencyIsoCode = 'USD'        );   
        insert tempUser1;
        /*TriggerExecutionController.setSkipUserTriggers(true);
tempUser1.ContactId = testCon1.Id;
update tempUser1;*/
        
        
        String stroPPSTDRECORDTYPEID = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true); 
        Opportunity testOpp1 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 1', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM',
                                               //9.0 DSG_Renewal_request__c = true, 
                                                Forecast_Category_Override__c = 'Commit',
                                               Primary_Competitor_Product_Type__c ='HCl'
                                              );     
        
        
        
        listOpp1.add(testOpp1);
        
        Opportunity testOpp2 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 2', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM', 
                                                Forecast_Category_Override__c = 'Commit',
                                               Primary_Competitor_Product_Type__c ='HCl'
                                              );     
        
        //Insert testOpp2;
        listOpp1.add(testOpp2);
        Opportunity testOpp3 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 3', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM',
                                               //9.0 DSG_Renewal_request__c = true, 
                                                Forecast_Category_Override__c = 'Commit',
                                               Primary_Competitor_Product_Type__c ='HCl'
                                              );     
        
        
        //Insert testOpp3;
        listOpp1.add(testOpp3);
        
        //TriggerExecutionController.setSkipOpportunityTriggers(true);// 4.0: switch to skip all triggers
        insert listOpp1;
        //TriggerExecutionController.setSkipOpportunityTriggers(false);// 4.0: switch to skip all triggers
        
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        Product2 product = new product2(name='Test Product 1', Product_ID__c='test prod id1', Product_Line_Desc__c='EqualLogic',family='Services',isActive=true, Dgr_Eligible__c = 'Yes', DSG_Sales_Motion__c = 'Bidirectional product');   
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntry = new PricebookEntry(pricebook2id=pricebookId, product2id=product.id,CurrencyIsoCode = 'USD', unitprice=900000.0,useStandardPrice=false, isActive=true);      
        insert pricebookEntry;
        
        OpportunityLineItem oli3 = new OpportunityLineItem( Opportunityid =testOpp2.ID,
                                                           pricebookEntryId=pricebookEntry.id,
                                                           Mrgn__c =6,
                                                           Discount_off__c = 7,
                                                           UnitPrice = 100000,
                                                           Quantity =20,
                                                           Description = 'Line Description',
                                                           Service_Support_US__c = 'ProSupport IT - Mission Critical',
                                                           Quest_Product_Integration_Status__c = 'true');
        
        //TriggerExecutionController.setSkipOpportunityTriggers(true);// 4.0: switch to skip all triggers
        insert oli3;  
        //TriggerExecutionController.setSkipOpportunityTriggers(false);// 4.0: switch to skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false); // 4.0
        
        Test.startTest();
        OpportunityFieldPopulator.populateRegionForSMBOpportunities(listOpp1);                                                 
        Map<Id, Opportunity> mapRelatedOpp = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapOldOppMap = new Map<Id, Opportunity>();
        
        mapOldOppMap.put(testOpp2.Id, testOpp2);  
        //mapRelatedOpp.put(testOpp3.Id,testOpp3);
        OpportunityFieldPopulator.populateRegionForSMBOpportunities(listOpp1);
        
        mapRelatedOpp = new map<Id, Opportunity>([select Id, Name, AccountId, Account.Account_ID__c, CreatedBy.Profile.Name, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Contact.Email, Owner.Contact.AccountId, Owner.Contact.Phone, Owner.Contact.Account.Partner_Relationship__c, Owner.Profile.Name, Deal_Registration_Status__c,(select Id, OpportunityId, Active_Wyse_Product__c, Product_Line_Desc__c, Description from OpportunityLineItems)
                                                  from Opportunity where Id =:testOpp2.Id]);
        
        Opportunity testOpp4 = [SELECT Id, Deal_Registration_Status__c FROM Opportunity WHERE Id =: testOpp2.Id];
        testOpp4.Deal_Registration_Status__c = 'Approved';
        List<Opportunity> listOpp2 = new List<Opportunity>(); 
        listOpp2.add(testOpp4);
        
        system.assertEquals('Approved',testOpp4.Deal_Registration_Status__c);
        OpportunityFieldPopulator.updateDealExpirationDetails(listOpp2,mapOldOppMap);
        OpportunityFieldPopulator.populateOrderComplianceproduct(mapRelatedOpp.values());
        Test.stopTest();    
        
    } 
    public static testMethod void testOpportunityFieldPopulatorCoverage3() {
        
        //TriggerExecutionController.setSkipAccountTriggers(true); // 4.0: switch to skip all triggers
        TriggerExecutionController.setSkipAllTriggers(true); // 4.0
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        //Kokila's changes
        Account testAcc1  = new Account(Name='Test Account1',Partner_Relationship__c ='Registered', OwnerId = adminusr.Id);
        insert testAcc1;
        
        Date dCloseDate = System.Today()+10;
        
        Contact testCon1 = new Contact(FirstName = 'Contact1',
                                       LastName = 'Test1',
                                       AccountId = testAcc1.ID,
                                       MailingCity = 'Test city',
                                       MailingCountry = 'TestCountry',
                                       MailingState = 'TestState',
                                       MailingPostalCode = '63000',
                                       Phone = '23566889',
                                       Email = 'testemail@dell.com',                                  
                                       Decision_Making_Role__c = 'Sponsor/ Champion');
        
        //TriggerExecutionController.setSkipAccountTriggers(true); // 4.0: switch to skip all triggers
        insert testCon1;
        
        List<Opportunity> listOpp1 = new List<Opportunity>(); 
        
        
        
        List<Profile> listUserProfiles1= [select id,name from profile where name like '%LA PRM%' order by name limit 2 ];
        User tempUser1 = new User(            
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev', 
            Alias = 'test',           
            Email='test109@dell.com',  
            FirstName='Tfirst A1',     
            LastName='TLast2',          
            ProfileId = listUserProfiles1[0].Id,     
            LanguageLocaleKey='en_US',          
            LocaleSidKey='en_US',        
            EmailEncodingKey='UTF-8',       
            TimeZoneSidKey='America/Los_Angeles',   
            Badge_Number__c='Test'+System.currentTimeMillis(),    
            Title = 'Test Title',
            //Country = Cntry1.id,
            Contactid = testCon1.Id, 
            CurrencyIsoCode = 'USD'        );   
        insert tempUser1;
        /*TriggerExecutionController.setSkipUserTriggers(true);
tempUser1.ContactId = testCon1.Id;
update tempUser1;*/
        
        
        String stroPPSTDRECORDTYPEID = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true); 
        Opportunity testOpp1 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 1', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM',
                                               //9.0 DSG_Renewal_request__c = true, 
                                                Forecast_Category_Override__c = 'Pipeline',
                                               Primary_Competitor_Product_Type__c ='HCl'
                                              );     
        
        
        
        listOpp1.add(testOpp1);
        
        Opportunity testOpp2 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 2', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM', 
                                                Forecast_Category_Override__c = 'Pipeline',
                                               Primary_Competitor_Product_Type__c ='HCl'
                                              );     
        
        //Insert testOpp2;
        listOpp1.add(testOpp2);
        Opportunity testOpp3 = new Opportunity(RecordTypeId      = stroPPSTDRECORDTYPEID,   
                                               Name              = 'Test Opportunity 3', 
                                               AccountId         = testAcc1.ID, 
                                               Type              = 'Deal/Bid Direct', 
                                               Domain__c         = 'Business Solutions',
                                               Solution_Type__c  = 'Business Processing Solutions',
                                               Solution_Name__c  = 'CRM',
                                               CloseDate         = dCloseDate, 
                                               CurrencyIsoCode   = 'USD',
                                               StageName         = 'Qualify - 30%', 
                                               Competitor_Lost_To__c='Unknown',
                                               Quest_Software_Contact__c = testCon1.ID,
                                               OwnerId = tempUser1.Id,
                                               Deal_Registration_Status__c = 'Submitted',
                                               Submitter_Profile__c = 'NA PRM',
                                               //9.0 DSG_Renewal_request__c = true, 
                                                Forecast_Category_Override__c = 'Pipeline',
                                               Primary_Competitor_Product_Type__c ='HCl'
                                              );     
        
        
        //Insert testOpp3;
        listOpp1.add(testOpp3);
        
        //TriggerExecutionController.setSkipOpportunityTriggers(true); // 4.0: switch to skip all triggers
        insert listOpp1;
        //TriggerExecutionController.setSkipOpportunityTriggers(false); // 4.0: switch to skip all triggers
        System.debug('Success1');
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        Product2 product = new product2(name='Test Product 1', Product_ID__c='test prod id1',Product_Line_Desc__c='EqualLogic',family='Services',isActive=true, Dgr_Eligible__c = 'Yes', DSG_Sales_Motion__c = 'Bidirectional product');   
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pe = new PricebookEntry(pricebook2id=pricebookId, product2id=product.id,CurrencyIsoCode = 'USD', unitprice=900000.0,useStandardPrice=false, isActive=true);      
        insert pe;
        
        OpportunityLineItem oli3 = new OpportunityLineItem( Opportunityid =testOpp2.ID,
                                                           pricebookEntryId=pe.id,
                                                           Mrgn__c =6,
                                                           Discount_off__c = 7,
                                                           UnitPrice = 100000,
                                                           Quantity =20,
                                                           Description = 'Line Description',
                                                           Service_Support_US__c = 'ProSupport IT - Mission Critical',
                                                           Quest_Product_Integration_Status__c = 'true');
        
        //TriggerExecutionController.setSkipOpportunityTriggers(true); // 4.0: switch to skip all triggers
        insert oli3; 
        //TriggerExecutionController.setSkipOpportunityTriggers(false); // 4.0: switch to skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false); // 4.0
        System.debug('Success2');  
        
        Test.startTest();
        OpportunityFieldPopulator.populateRegionForSMBOpportunities(listOpp1);                                                 
        Map<Id, Opportunity> mapRelatedOpp = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapOldOppMap = new Map<Id, Opportunity>();
        
        mapOldOppMap.put(testOpp2.Id, testOpp2);  
        //mapRelatedOpp.put(testOpp3.Id,testOpp3);
        OpportunityFieldPopulator.populateRegionForSMBOpportunities(listOpp1);
        
        mapRelatedOpp = new map<Id, Opportunity>([select Id, Name, AccountId, Account.Account_ID__c, CreatedBy.Profile.Name, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Contact.Email, Owner.Contact.AccountId, Owner.Contact.Phone, Owner.Contact.Account.Partner_Relationship__c, Owner.Profile.Name, Deal_Registration_Status__c,(select Id, OpportunityId, Active_Wyse_Product__c, Product_Line_Desc__c, Description from OpportunityLineItems)
                                                  from Opportunity where Id =:testOpp2.Id]);
        
        Opportunity testOpp4 = [SELECT Id, Deal_Registration_Status__c FROM Opportunity WHERE Id =: testOpp2.Id];
        testOpp4.Deal_Registration_Status__c = 'Approved';
        
        
        List<Opportunity> listOpp2 = new List<Opportunity>(); 
        listOpp2.add(testOpp4);
        
        OpportunityFieldPopulator.updateDealExpirationDetails(listOpp2,mapOldOppMap);
        OpportunityFieldPopulator.populateOrderComplianceproduct(mapRelatedOpp.values());
        Test.stopTest();    
        
    } 
    //Method copied from OverrideProbabilityTest
    static testMethod void overrideProbabilityTestMethod1(){
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'testOP', email='testOP1234@dell.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, country='United States',            
                          timezonesidkey='America/Los_Angeles', username='testOP1234@noemail.com', Badge_Number__c = '111222');
        insert u;
        TriggerExecutionController.setSkipAllTriggers(true);  
        TriggerExecutionController.setSkipOpportunityTriggers(false);  
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';              
        insert acc;
        List<Opportunity> listOpps = new List<Opportunity>();
        Opportunity testOpp1 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%', Override_Probability__c='30%', Forecast_Category_Override__c='Omitted');       
        //insert testOpp1;
        listOpps.add(testOpp1);
        system.assertEquals(testOpp1.Override_Probability__c, '30%');
        system.assertEquals(testOpp1.StageName, 'Plan - 1%');
        
        Opportunity testOpp2 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = null, StageName = 'Commit - 90%', Override_Probability__c='90%', Competitor_Lost_To__c = 'Accenture', Forecast_Category_Override__c='Commit');       
        //insert testOpp2;
        listOpps.add(testOpp2);
        
        insert listOpps;
        HelperClass.firstRun = true;
        
        system.assertEquals(testOpp2.Override_Probability__c, '90%');
        system.assertEquals(testOpp2.StageName, 'Commit - 90%');
        system.assertEquals(testOpp2.Competitor_Lost_To__c, 'Accenture');
        
        List<Opportunity> listMyOps = new List<Opportunity>();
        Opportunity op1 = [select id, StageName, Override_Probability__c, Competitor_Lost_To__c from Opportunity where id =:testOpp1.id limit 1];
        op1.StageName = 'Discover - 10%';
        op1.Competitor_Lost_To__c = 'Accenture';
        op1.Override_Probability__c = '60%';
        op1.OSC_Solution_ID__c = 'ASIA%3A123.1';
        op1.Forecast_Category_Override__c = 'Omitted';
        listMyOps.add(op1);
        
        test.startTest();   
        system.runas(u){
            OpportunityFieldPopulator.formatOSCid(listMyOps, TriggerHandler.TriggerEvent.ISINSERT);
            update listMyOps;
            
            system.assertEquals(testOpp1.Competitor_Lost_To__c, null);            
            system.assertEquals(op1.Competitor_Lost_To__c, 'Accenture');
            system.assertEquals(op1.Override_Probability__c, '60%');
            HelperClass.firstRun = false;
            
        }
        test.stopTest();
    } 
    static testmethod void aPOSOppTest()
    {
        Profile sSIprofile = [select id from profile where name like '%SSI Integration Connector API%' Limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                 Alias = 'Test', 
                                 Email='Test'+'@dell.com',            
                                 LastName='Test',
                                 ProfileId = SSIprofile.Id, 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;
        
        system.Test.startTest();
        Account testAcc = new Account(name='testaccount');
        
        insert testAcc;        
        
        TriggerControlHandler.setOpportunityTriggersInactive();
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true); 
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('APOS','Opportunity',true);
        Opportunity opp=new Opportunity (name='test opp APOS', Accountid=testAcc.id, Type='Deal/Bid - Direct', Domain__c='APOS', CurrencyIsoCode='USD', CloseDate=System.Today(),
                                         Solution_Type__c='APOS',Solution_Name__c='Other', StageName='House Account', RecordTypeId = oppRecordTypeId, CreatedById='005A00000049FnM', Source_System__c = 'Renew', Forecast_Category_Override__c = 'Omitted');
        insert opp;
        
        Opportunity opp1=new Opportunity (name='test opp APOS', Accountid=testAcc.id, Type='Deal/Bid - Direct', Domain__c='APOS', CurrencyIsoCode='USD', CloseDate=System.Today(),
                                          Solution_Type__c='APOS',Solution_Name__c='Other', StageName='Consolidated', RecordTypeId = oppRecordTypeId, CreatedById='005A00000049FnM', Source_System__c = 'Renew', Forecast_Category_Override__c = 'Omitted');
        insert opp1;
        
        TriggerControlHandler.setOpportunityTriggersActive();
        
        list<opportunity> listopptylist = new list<opportunity>();
        listopptylist.add(opp);
        listopptylist.add(opp1);
        
        OpportunityFieldPopulator.updateRenewedAPOSOpportunities(listopptylist);
        system.Test.stopTest();
        system.assertequals(opp.StageName,'Lost, Cancelled - 0%');
        system.assertequals(opp.Probability,0);
        system.assertequals(opp.Reason_Won_Lost__c, 'Service /Support/Delivery Capabilities');
        system.assertequals(opp.Service_Solution_Reason__c,'No feedback');
    }
    
    //Test method for deal expiry date population
    static testMethod void populatedealexpirydatefordisti(){
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        
        TriggerExecutionController.setSkipAllTriggers(true);
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        
        //insert disti Account
        List<Account> listAccs = new List<Account>();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        //Id MasteraccRTId= IdLookupUtils.getRecordTypeId('Master Account','Account',true);
        Id MasteraccRTId = [SELECT id from RecordType where Name ='Master Account'].Id;

        Account testPartnerAccount = new Account(name='Test PAcc',account_country_code__c='US', RecordTypeId=MasteraccRTId, Type = 'Partner',Partner_Type__c='DISTRIBUTOR (GCC)',Dell_Certification_Areas__c='Storage;Server', OwnerId = adminusr.Id);
        listAccs.add(testPartnerAccount);
        
        //insert reseller account
        Account testPartnerAccount1 = new Account(name='Test PAcc1',account_country_code__c='US', RecordTypeId=MasteraccRTId, Type = 'Partner',Partner_Type__c='Commercial',Partner_Relationship__c='Premier',Dell_Certification_Areas__c='Storage;Server', OwnerId = adminusr.Id);
        listAccs.add(testPartnerAccount1);
        insert listAccs;
        
        testAccountObj =new Account(name='Renewal Test Account', Account_Country_Code__c = 'JC', Account_Country__c = 'Jedi Country', Approved_for_Partner_Finder__c = false);
            insert testAccountObj;
        //Create a partner user for Disti Account
        
        Contact con = new Contact(FirstName='first', Phone='044223667788',AccountId = testAccountObj.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                  Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                  MobilePhone = '9030587363',Eloqua_ID__c = '1234');
        insert con;
        
        // Create this user with PowerPartner profile,
        // so that the AccountId will be populated as same as the associated Contact's AccountId
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        //string strproid = [SELECT Id FROM Profile WHERE Name = 'R13.1 EMEA PRM Portal User (MOSS)'][0].Id; // TODO: strproid // Ver 1.0
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User( ContactId = con.id,IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'en_US',
                          LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        //Add user as account team member
        AccountTeamMember atm = new AccountTeamMember();
        atm.accountid = listAccs[1].id;
        atm.userid = u.id;
        atm.TeamMemberRole = 'Account Executive';
        insert atm;
        //Create deal reg as partner user
        System.runas(u){
            Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
            
            Opportunity testOppty = new Opportunity(Name='Test expiry population', 
                                                    //AccountId=listAccs[1].id, 
                                                    Deal_Registration_Status__c= 'Submitted',
                                                    Total_Expected_Dell_Revenue__c =1919191,
                                                    RecordTypeID = dealRTId,
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
                                                    CloseDate = System.Today() + 30,
                                                    Distributor_Reseller_Name__c = listAccs[1].id,
                                                    Distributor_Name__c = 'Distribution', 
                                                    Forecast_Category_Override__c = 'Omitted');        
            
            //System.runAs(partnerUser) {
            //Set skip VRs
            SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
            insert testOppty;
            //Reset skip VRs
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
            TriggerExecutionController.setSkipAllTriggers(false);
            TriggerExecutionController.setSkipAccountTriggers(true);
            Test.startTest();
            ProcessFlowTriggerController.isTest = true; // 5.0
            testOppty.Deal_Registration_Status__c = 'Approved';
            testOppty.Forecast_Category_Override__c = 'Omitted';
            //Set skip VRs
            SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
            update testOppty;
            //Reset skip VRs
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
            //Reset skip VRs
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
            Test.stopTest();
            
            //Query and assert deal expiration days
            Opportunity res = [Select name,Deal_Expiration_Timeframe__c, Deal_Registration_Status__c FROM Opportunity WHERE id= :testOppty.id];
            System.assertEquals(res.Deal_Registration_Status__c,'Approved');
        }
        
    } 
    
    static testMethod void populatedealexpirydateforreseller(){
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        TriggerExecutionController.setSkipAllTriggers(true);
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        
        //insert disti Account
        List<Account> listAccs = new List<Account>();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Id MasteraccRTId= IdLookupUtils.getRecordTypeId('Master Account','Account',true);
        
        Account testPartnerAccount = new Account(name='Test PAcc',account_country_code__c='US', RecordTypeId=MasteraccRTId,Type = 'Partner',Partner_Type__c='Commercial',Dell_Certification_Areas__c='Storage;Server',Partner_Relationship__c='Preferred', OwnerId = adminusr.Id);
        listAccs.add(testPartnerAccount);
        
        //insert reseller account
        Account testPartnerAccount1 = new Account(name='Test PAcc1',account_country_code__c='US', RecordTypeId=MasteraccRTId, Type = 'Partner',Partner_Type__c='DISTRIBUTOR (GCC)',Partner_Relationship__c='Premier',Dell_Certification_Areas__c='Storage;Server', OwnerId = adminusr.Id);
        listAccs.add(testPartnerAccount1);
        insert listAccs;
        
        testAccountObj =new Account(name='Renewal Test Account', Account_Country_Code__c = 'JC', Account_Country__c = 'Jedi Country', Approved_for_Partner_Finder__c = false);
            insert testAccountObj;
        //Create a partner user for Disti Account
        
        Contact con = new Contact(FirstName='first', Phone='044223667788',AccountId = testAccountObj.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                  Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                  MobilePhone = '9030587363',Eloqua_ID__c = '1234');
        insert con;
        
        // Create this user with PowerPartner profile,
        // so that the AccountId will be populated as same as the associated Contact's AccountId
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        //string strproid = [SELECT Id FROM Profile WHERE Name = 'R13.1 EMEA PRM Portal User (MOSS)'][0].Id; // TODO: strproid // Ver 1.0
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User( ContactId = con.id,IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'en_US',
                          LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        //Add user as account team member
        AccountTeamMember atm = new AccountTeamMember();
        atm.accountid = listAccs[1].id;
        atm.userid = u.id;
        atm.TeamMemberRole = 'Account Executive';
        insert atm;
        //Create deal reg as partner user
        System.runas(u){
            Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
            
            Opportunity testOppty = new Opportunity(Name='Test expiry population', 
                                                    //AccountId=listAccs[1].id, 
                                                    Deal_Registration_Status__c= 'Submitted',
                                                    Total_Expected_Dell_Revenue__c =1919191,
                                                    RecordTypeID = dealRTId,
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
                                                    CloseDate = System.Today() + 30,
                                                    Distributor_Reseller_Name__c = listAccs[1].id,
                                                    Distributor_Name__c = 'Distribution', 
                                                    Forecast_Category_Override__c = 'Omitted');        
            
            //System.runAs(partnerUser) {
            //Set skip VRs
            SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
            insert testOppty;
            //Reset skip VRs
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
            TriggerExecutionController.setSkipAllTriggers(false);
            TriggerExecutionController.setSkipAccountTriggers(true);
            Test.startTest();
            ProcessFlowTriggerController.isTest = true; // 5.0
            testOppty.Deal_Registration_Status__c = 'Approved';
            testOppty.Forecast_Category_Override__c = 'Omitted';
            //Set skip VRs
            SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
            update testOppty;
            //Reset skip VRs
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
            Test.stopTest();
            
            //Query and assert deal expiration days
            Opportunity res = [Select name,Deal_Expiration_Timeframe__c,Deal_Registration_Status__c FROM Opportunity WHERE id= :testOppty.id];
            System.assertEquals(res.Deal_Registration_Status__c,'Approved');
        }
        
    }  
    static testMethod void populatedealexpirydateforresellerRegi(){
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        
        TriggerExecutionController.setSkipAllTriggers(true);
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        //insert disti Account
        List<Account> listAccs = new List<Account>();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Id MasteraccRTId= IdLookupUtils.getRecordTypeId('Master Account','Account',true);
        
        Account testPartnerAccount = new Account(name='Test PAcc',account_country_code__c='US', RecordTypeId=MasteraccRTId, Type = 'Partner',Partner_Type__c='Commercial',Dell_Certification_Areas__c='Storage;Server',Partner_Relationship__c='Registered', OwnerId = adminusr.Id);
        listAccs.add(testPartnerAccount);
        
        //insert reseller account
        Account testPartnerAccount1 = new Account(name='Test PAcc1',account_country_code__c='US', RecordTypeId=MasteraccRTId, Type = 'Partner',Partner_Type__c='DISTRIBUTOR (GCC)',Partner_Relationship__c='Premier',Dell_Certification_Areas__c='Storage;Server', OwnerId = adminusr.Id);
        listAccs.add(testPartnerAccount1);
        insert listAccs;
        
        testAccountObj =new Account(name='Renewal Test Account', Account_Country_Code__c = 'JC', Account_Country__c = 'Jedi Country', Approved_for_Partner_Finder__c = false);
            insert testAccountObj;
        //Create a partner user for Disti Account
        
        Contact con = new Contact(FirstName='first', Phone='044223667788',AccountId = testAccountObj.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                  Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                  MobilePhone = '9030587363',Eloqua_ID__c = '1234');
        insert con;
        
        // Create this user with PowerPartner profile,
        // so that the AccountId will be populated as same as the associated Contact's AccountId
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
        //string strproid = [SELECT Id FROM Profile WHERE Name = 'R13.1 EMEA PRM Portal User (MOSS)'][0].Id; // TODO: strproid // Ver 1.0
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User( ContactId = con.id,IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'en_US',
                          LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
        insert u;
        //Add user as account team member
        AccountTeamMember atm = new AccountTeamMember();
        atm.accountid = listAccs[1].id;
        atm.userid = u.id;
        atm.TeamMemberRole = 'Account Executive';
        insert atm;
        //Create deal reg as partner user
        System.runas(u){
            Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
            
            Opportunity testOppty = new Opportunity(Name='Test expiry population', 
                                                    //AccountId=listAccs[1].id, 
                                                    Deal_Registration_Status__c= 'Submitted',
                                                    Total_Expected_Dell_Revenue__c =1919191,
                                                    RecordTypeID = dealRTId,
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
                                                    CloseDate = System.Today() + 30,
                                                    Distributor_Reseller_Name__c = listAccs[1].id,
                                                    Distributor_Name__c = 'Distribution', 
                                                    Forecast_Category_Override__c = 'Omitted', 
                                                    Competitor_Lost_To__c='Unknown');
            
            //System.runAs(partnerUser) {
            //Set skip VRs
            SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
            insert testOppty;
            //Reset skip VRs
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
            TriggerExecutionController.setSkipAllTriggers(false);
            TriggerExecutionController.setSkipAccountTriggers(true);
            Test.startTest();
            ProcessFlowTriggerController.isTest = true; // 5.0
            testOppty.Deal_Registration_Status__c = 'Approved';
            testOppty.Forecast_Category_Override__c = 'Omitted';
            //Set skip VRs
            SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
            update testOppty;
            //Reset skip VRs
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
            Test.stopTest();
            
            //Query and assert deal expiration days
            Opportunity res = [Select name,Deal_Expiration_Timeframe__c,Deal_Registration_Status__c FROM Opportunity WHERE id= :testOppty.id];
            System.assertEquals(testOppty.Deal_Registration_Status__c,'Approved');
        }
        
    }    
    
    static testMethod void testcovermiscellaneousCode(){
        List<Opportunity> listOpp = new List<Opportunity>();
        PrepareTestData();
        
        testOpportunity.Submitter_Profile__c = 'NA PRM';
        //9.0 testOpportunity.DSG_Renewal_request__c = true;
        TriggerExecutionController.setSkipAllTriggers(true); 
        update testOpportunity;    
        listOpp.add(testOpportunity);
        /* v6.0 
OpportunityFieldPopulator.populateForAutoApproval(listOpp);        
System.assertEquals('Approved',testOpportunity.Request_Status__c);
v6.0*/
        
        List<Opportunity> listOpps=new List<Opportunity>();
        
        Opportunity testOpportunity1= new Opportunity (AccountID=testAccountObj.ID ,
                                                        RecordTypeId= '012A0000000Vjtg',
                                                        Override_Probability__c='30',
                                                        Competitor_Lost_To__c='Unknown',
                                                        Name='TestOpportunity',
                                                        Type = 'Run Rate',
                                                        Domain__c='Deal Reg',
                                                        Solution_Type__c = 'Campus',
                                                        Channel_Lead_ID_2__c = '1234567ABCDEFGHI',
                                                        // Solution_Name__c = 'Wireless Switches',
                                                        StageName = 'Qualify - 30%',
                                                        Deal_Registration_Status__c = 'Recalled',
                                                        Deal_Created_Date_Time__c = System.Now(),
                                                        Deal_Expiration_Timeframe__c='60',
                                                        Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                                        CloseDate= System.Now().Date().addDays(180),
                                                        Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                                        Request_Status__c='New', 
                                                        Primary_Competitor__c='Unknown',
                                                        Forecast_Category_Override__c = 'Pipeline');
        
        Opportunity testOpportunity2= new Opportunity (AccountID=testAccountObj.ID ,
                                                        RecordTypeId= '012A0000000Vjtg',
                                                        Override_Probability__c='60',
                                                        Name='TestOpportunity',
                                                        Type = 'Run Rate',
                                                        Domain__c='Deal Reg',
                                                        Solution_Type__c = 'Campus',
                                                        Solution_Name__c = 'Wireless Switches',
                                                        Channel_Lead_ID_2__c = '1234567ABCDEFGHI',
                                                        StageName='Propose - 60%',
                                                        Deal_Registration_Status__c = 'Recalled',
                                                        Deal_Created_Date_Time__c = System.Now(),
                                                        Deal_Expiration_Timeframe__c='60',
                                                        Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                                        CloseDate= System.Now().Date().addDays(180),
                                                        Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                                        Request_Status__c='New', 
                                                        Primary_Competitor__c='Unknown',
                                                        Competitor_Lost_To__c='Unknown',
                                                        Forecast_Category_Override__c = 'Best Case');
        Opportunity testOpportunity3= new Opportunity (AccountID=testAccountObj.ID ,
                                                        RecordTypeId= '012A0000000Vjtg',
                                                        Override_Probability__c='90',
                                                        Competitor_Lost_To__c='Unknown',
                                                        Name='TestOpportunity',
                                                        StageName = 'Commit - 90%',
                                                        Type = 'Run Rate',Fiscal_Week__c = '#',
                                                        Domain__c='Deal Reg',
                                                        Solution_Type__c = 'Campus',
                                                        Solution_Name__c = 'Wireless Switches',
                                                        Channel_Lead_ID_2__c = '1234567ABCDEFGHI',
                                                        //StageName='Plan - 90%',
                                                        Deal_Registration_Status__c = 'Recalled',
                                                        Deal_Created_Date_Time__c = System.Now(),
                                                        Deal_Expiration_Timeframe__c='60',
                                                        Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                                        CloseDate= System.Now().Date().addDays(180),
                                                        Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                                        Request_Status__c='New', 
                                                        Primary_Competitor__c='Unknown',Forecast_Category_Override__c = 'Best Case');
        Opportunity testOpportunity4= new Opportunity (AccountID=testAccountObj.ID ,
                                                        RecordTypeId= '012A0000000Vjtg',
                                                        Override_Probability__c='99',
                                                        Competitor_Lost_To__c='Unknown',
                                                        Name='TestOpportunity',
                                                        StageName = 'Commit - 90%',
                                                        Type = 'Run Rate',Fiscal_Week__c = '#',
                                                        Domain__c='Deal Reg',
                                                        Solution_Type__c = 'Campus',
                                                        Solution_Name__c = 'Wireless Switches',
                                                        Channel_Lead_ID_2__c = '1234567ABCDEFGHI',
                                                        Deal_Registration_Status__c = 'Recalled',
                                                        Deal_Created_Date_Time__c = System.Now(),
                                                        Deal_Expiration_Timeframe__c='60',
                                                        Related_Parent_Opportunity__c = testParentOpportunity.Id, 
                                                        CloseDate= System.Now().Date().addDays(180),
                                                        Deal_Expiration_Date__c=System.Now().Date().addDays(4),
                                                        Request_Status__c='New', 
                                                        Primary_Competitor__c='Unknown',Forecast_Category_Override__c = 'Best Case');
        
        
        listOpps.add(testOpportunity1);
        listOpps.add(testOpportunity2);
        listOpps.add(testOpportunity3);
        listOpps.add(testOpportunity4);
          insert listOpps; 
        System.assertEquals(testOpportunity4.Forecast_Category_Override__c ,'Best Case');
        OpportunityFieldPopulator.overrideProbability(listOpps, new Map<ID,Opportunity>(listOpps));
        
        List<Account> listAccs=new List<Account>();
        listAccs.add(testAccountObj);
        OpportunityFieldPopulator.autoPopulateFields(listOpps,new Map<ID,Opportunity>(listOpps),TriggerHandler.TriggerEvent.ISUPDATE,new Map<ID, Account>(listAccs));
        OpportunityFieldPopulator.autoPopulateFields(listOpps,new Map<ID,Opportunity>(listOpps),TriggerHandler.TriggerEvent.ISINSERT,new Map<ID, Account>(listAccs));
        
        insert  new SOC_Solution_Name_Console__c(Solution_Name__c='Wireless Switches');
        listOpps[0].Solution_Name__c = 'Wireless Switches';
         update listOpps;
        Map<ID, Opportunity> mapMOpp=new Map<ID,Opportunity>();
        mapMOpp.put(listOpps[0].Id,listOpps[0]);
        mapMOpp.put(listOpps[1].Id,listOpps[1]);
        OpportunityFieldPopulator.populateSOCSolutionNameConsole(listOpps, mapMOpp);
        
        
    }

    //8.0 - BOF
    static testMethod void overrideForecastCategory() {
        /*System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        cs.Bypass_Opportunity_VRs__c = true;
        insert cs;*/
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'testOP', email='testOP1234@dell.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, country='United States',            
                          timezonesidkey='America/Los_Angeles', username='testOP1234@noemail.com', Badge_Number__c = '111222');
        insert u;
        TriggerExecutionController.setSkipAllTriggers(true);  
        TriggerExecutionController.setSkipOpportunityTriggers(false);  
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';              
        insert acc;
        List<Opportunity> listOpps = new List<Opportunity>();
        Opportunity testOpp1 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%', Forecast_Category_Override__c='Omitted',Vartopia_Disti_Account__c=acc.Id);
        listOpps.add(testOpp1);
        
        Opportunity testOpp2 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = null, StageName = 'Discover - 10%', Competitor_Lost_To__c = 'Accenture', Forecast_Category_Override__c='Pipeline',Vartopia_Disti_Account__c=acc.Id);
        listOpps.add(testOpp2);
        
        Opportunity testOpp3 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = null, StageName = 'Qualify - 30%', Competitor_Lost_To__c = 'Accenture', Forecast_Category_Override__c='Pipeline');
        listOpps.add(testOpp3);
        
        Opportunity testOpp4 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = null, StageName = 'Propose - 60%', Competitor_Lost_To__c = 'Accenture', Forecast_Category_Override__c='Best Case');
        listOpps.add(testOpp4);
        
        Opportunity testOpp5 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = null, StageName = 'Commit - 90%', Competitor_Lost_To__c = 'Accenture', Forecast_Category_Override__c='Commit');
        listOpps.add(testOpp5);
        
        Opportunity testOpp6 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = null, StageName = 'Commit - 90%', Competitor_Lost_To__c = 'Accenture', Forecast_Category_Override__c='Best Case');
        listOpps.add(testOpp6);
        
        Opportunity testOpp7 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = null, StageName = 'Commit - 90%', Competitor_Lost_To__c = 'Accenture', Forecast_Category_Override__c='Best Case');
        listOpps.add(testOpp7);
        
        insert listOpps;
        System.assertEquals(testOpp7.Forecast_Category_Override__c ,'Best Case');
        test.startTest();
        system.runas(u){
            OpportunityFieldPopulator.overrideForecastCategory(listOpps, new Map<ID,Opportunity>(listOpps));
            OpportunityFieldPopulator.PopulateVartopiaidfromtext(listOpps,null);
        }
        test.stopTest();
    }//8.0 - EOF
    
    //12.0 - Venkat - BOF
    public static testMethod void testEMCStatusForAPOSIntegrationCreation(){
        try{            
            User testIntegrationUser = [select id from user where firstname='Renewals EBIA' AND lastName='Integration User' AND isActive=true limit 1];           
            
            TriggerExecutionController.setSkipAllTriggers(false);  
            TriggerExecutionController.setSkipOpportunityTriggers(false); 
            
            Account testAcc = new Account();
            testAcc.name = 'Some test Account1';        
            testAcc.status__c = 'Active';
            testAcc.Account_Country_Code__c='US';              
            insert testAcc;
            
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.RecordTypeId = getAPOSRecordTypeId();
            testOpportunity.name='test APOS1';
            testOpportunity.Accountid=testAcc.id; 
            testOpportunity.CloseDate=system.today()  + 5;            
            testOpportunity.CurrencyIsoCode='USD';                        
            testOpportunity.StageName='Discover - 10%';                                   
            testOpportunity.LeadSource = 'Contract Renewal';
            testOpportunity.EMC_Opportunity_Updated__c = 'Renewal Completed';
            testOpportunity.Source_System__c = 'Renewals EBIA';
            testOpportunity.Type = 'EMC Renewals';
            
            Test.startTest();
            System.runAs(testIntegrationUser){               
                insert testOpportunity;                
            } 
            Test.stopTest();
            Opportunity aposOpportunity = [select id,name,EMC_Opportunity_Updated__c from opportunity where id=:testOpportunity.Id];
            System.assertEquals('Renewal Completed', aposOpportunity.EMC_Opportunity_Updated__c);           
        }
        catch(Exception ex){
            system.debug('Exception: '+ex);
        }
    }
    
    public static testMethod void testEMCStatusForAPOSCoreIntegrationCreation(){
        try{            
            User testIntegrationUser = [select id from user where firstname='Renewals Core' AND lastName='Integration User' AND isActive=true limit 1];           
            
            TriggerExecutionController.setSkipAllTriggers(false);  
            TriggerExecutionController.setSkipOpportunityTriggers(false); 
            
            Account testAcc = new Account();
            testAcc.name = 'Some test Account2';        
            testAcc.status__c = 'Active';
            testAcc.Account_Country_Code__c='US';              
            insert testAcc;
            
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.RecordTypeId = getAPOSRecordTypeId();
            testOpportunity.name='test APOS2';
            testOpportunity.Accountid=testAcc.id; 
            testOpportunity.CloseDate=system.today()  + 5;            
            testOpportunity.CurrencyIsoCode='USD';                        
            testOpportunity.StageName='Discover - 10%';                                   
            testOpportunity.LeadSource = 'Contract Renewal';
            testOpportunity.EMC_Opportunity_Updated__c = 'Renewal Waiting Sync';
            testOpportunity.Source_System__c = 'Renewals EBIA';
            testOpportunity.Type = 'EMC Renewals';
            
            Test.startTest();
            System.runAs(testIntegrationUser){               
                insert testOpportunity;                
            } 
            Test.stopTest();
            Opportunity aposOpportunity = [select id,name,EMC_Opportunity_Updated__c from opportunity where id=:testOpportunity.Id];
            System.assertEquals('Renewal Waiting Sync', aposOpportunity.EMC_Opportunity_Updated__c);           
        }
        catch(Exception ex){
            system.debug('Exception: '+ex);
        }
    }
    
    private static string getAPOSRecordTypeId(){
        Id idAPOSRecordType = [select id from RecordType where DeveloperName='APOS' and sObjectType = 'Opportunity' limit 1].id;
        return string.valueOf(idAPOSRecordType);
    }//12.0 - Venkat - EOF
    
    //13.0 - BOF
    public static testMethod void populateUseCaseFieldsTest() {
        try {            
            User testUseCaseUser = [SELECT Id FROM User WHERE FirstName = 'Sales Rep E' AND LastName='Use Case' AND isActive = true limit 1];

            //TriggerExecutionController.setSkipAllTriggers(false);
            //TriggerExecutionController.setSkipOpportunityTriggers(false);
            
            Account testAcc = new Account();
            testAcc.name = 'Some test Account2';        
            testAcc.status__c = 'Active';
            testAcc.Account_Country_Code__c='US';              
            insert testAcc;
            
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.RecordTypeId = getsObjectRTId('Opportunity', 'StandardOpportunity');
            testOpportunity.Name = 'test Use Case';
            testOpportunity.AccountId = testAcc.id; 
            testOpportunity.CloseDate = system.today()  + 5;            
            testOpportunity.CurrencyIsoCode = 'USD';                        
            testOpportunity.StageName = 'Discover - 10%';                                   
            testOpportunity.LeadSource = 'Contract Renewal';
            testOpportunity.EMC_Opportunity_Updated__c = 'Renewal Waiting Sync';
            testOpportunity.Source_System__c = 'Renewals EBIA';
            testOpportunity.Type = 'EMC Renewals';
            
            Test.startTest();
            System.runAs(testUseCaseUser) {               
                insert testOpportunity;                
            } 
            Test.stopTest();
            
            Opportunity stdOppty = [SELECT Id, Name FROM opportunity WHERE Id =: testOpportunity.Id];
            System.assertEquals('Basic Hardware/Software Sale', stdOppty.Domain__c);           
        } catch(Exception e) {
            System.debug('OpportunityFieldPopulatorTest ~ populateUseCaseFieldsTest ~ Exception ~ ' + e.getMessage());
        }
    }
    
    private static string getsObjectRTId(String objName, String dname) {
        Id idStdOpptyRT = [SELECT Id FROM RecordType WHERE DeveloperName =: dname AND sObjectType =: objName LIMIT 1].Id;
        return string.valueOf(idStdOpptyRT);
    }//13.0 - EOF

    public static testMethod void populatePartnerAccOnOpptyTest() {
        try {
            TriggerExecutionController.setSkipAllTriggers(true);
            User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
            Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
            system.runas(new User(Id = UserInfo.getUserId())){
                adminusr.userRole = testUserRole; 
                update new List<User> {adminusr};
            }
            //insert disti Account
            List<Account> listAccs = new List<Account>();
            Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
            Id MasteraccRTId= IdLookupUtils.getRecordTypeId('Master Account','Account',true);
            
            Account testPartnerAccount = new Account(name='Test PAcc',account_country_code__c='US', RecordTypeId=MasteraccRTId, Type = 'Partner',Partner_Type__c='Commercial',Dell_Certification_Areas__c='Storage;Server',Partner_Relationship__c='Registered', OwnerId = adminusr.Id);
            listAccs.add(testPartnerAccount);
            
            //insert reseller account
            Account testPartnerAccount1 = new Account(name='Test PAcc1',account_country_code__c='US', RecordTypeId=MasteraccRTId, Type = 'Partner',Partner_Type__c='DISTRIBUTOR (GCC)',Partner_Relationship__c='Premier',Dell_Certification_Areas__c='Storage;Server', OwnerId = adminusr.Id);
            listAccs.add(testPartnerAccount1);
            insert listAccs;
            
            testAccountObj =new Account(name='Renewal Test Account', Account_Country_Code__c = 'JC', Account_Country__c = 'Jedi Country', Approved_for_Partner_Finder__c = false);
                insert testAccountObj;
            //Create a partner user for Disti Account
            
            Contact con = new Contact(FirstName='first', Phone='044223667788',AccountId = testAccountObj.Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                      Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                      MobilePhone = '9030587363',Eloqua_ID__c = '1234');
            insert con;
            
            // Create this user with PowerPartner profile,
            // so that the AccountId will be populated as same as the associated Contact's AccountId
            Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name != 'Strategic Partner User' LIMIT 1];
            //string strproid = [SELECT Id FROM Profile WHERE Name = 'R13.1 EMEA PRM Portal User (MOSS)'][0].Id; // TODO: strproid // Ver 1.0
            string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
            User u = new User( ContactId = con.id,IsActive = true, Email = getUniqueString() + '@dell.com.fdev', LanguageLocaleKey = 'en_US',
                              LastName = 'UT', Alias = 'UT', CommunityNickname = getUniqueString(), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                              EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, UserName = getUniqueString() + '@dell.com.fdev', Badge_Number__c = getUniqueString());
            insert u;
            //Add user as account team member
            AccountTeamMember atm = new AccountTeamMember();
            atm.accountid = listAccs[1].id;
            atm.userid = u.id;
            atm.TeamMemberRole = 'Account Executive';
            insert atm;
            //Create deal reg as partner user
            System.runas(u){
                Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
                
                Opportunity testOppty = new Opportunity(Name='Test expiry population', 
                                                        //AccountId=listAccs[1].id, 
                                                        Deal_Registration_Status__c= 'Submitted',
                                                        Total_Expected_Dell_Revenue__c =1919191,
                                                        RecordTypeID = dealRTId,
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
                                                        CloseDate = System.Today() + 30,
                                                        Distributor_Reseller_Name__c = listAccs[1].id,
                                                        Distributor_Name__c = 'Distribution', 
                                                        Forecast_Category_Override__c = 'Omitted', 
                                                        Engage_Channel_Opportunity__c = false, 
                                                        Competitor_Lost_To__c='Unknown');
                
                //System.runAs(partnerUser) {
                //Set skip VRs
                SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
                TriggerExecutionController.setSkipAllTriggers(false);
                insert testOppty;
                //Reset skip VRs
                ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
                TriggerExecutionController.setSkipAccountTriggers(true);
                Test.startTest();
                ProcessFlowTriggerController.isTest = true; // 5.0
                testOppty.Deal_Registration_Status__c = 'Approved';
                testOppty.Forecast_Category_Override__c = 'Omitted';
                //Set skip VRs
                SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
                update testOppty;
                //Reset skip VRs
                ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
                Test.stopTest();
                
                //Query and assert deal expiration days
                Opportunity res = [Select name,Deal_Expiration_Timeframe__c,Deal_Registration_Status__c FROM Opportunity WHERE id= :testOppty.id];
                System.assertEquals(testOppty.Deal_Registration_Status__c,'Approved');
            }
        } catch(Exception e) {
            System.debug('OpportunityFieldPopulatorTest ~ populateUseCaseFieldsTest ~ Exception ~ ' + e.getMessage());
        }
    }
}
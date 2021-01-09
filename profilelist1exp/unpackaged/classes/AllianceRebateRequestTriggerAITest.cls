@isTest(seeAlldata=false)
public class AllianceRebateRequestTriggerAITest {
    private static Opportunity opp = null;
    private static User usr = null;
    
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        profile profileId =   [select Id, Name from Profile where name like '%system admin%' limit 1];
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        listUserTdf[0].ProfileId=profileId.id;
        insert listUserTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }  
    
    // Create Alliance Rebate Request
    public testmethod static void createAllianceRebateRequestClientIntel() {
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Alliance_Rebate_Request__c", "Class_Name__c": "AllianceRebateRequestTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Alliance_Rebate_Request__c';
        tec.RecursiveCount__c = 2;
        insert tec;
        system.assertEquals(2, tec.RecursiveCount__c);
        //Opportunity opp1 = 
        //createOpportunityInfo('ct_alliance_' + System.currentTimeMillis() + '@dell.com');
        
        //list<Alliance_Rebate_Request__c> listRebateReq = new list<Alliance_Rebate_Request__c>();
        // list<string> listRegions = new list<string>{'LATAM','NA','APJ','EMEA','GLOBAL'};
        list<string> listRegions = new list<string>{'LATAM','NA','APJ','EMEA','GLOBAL'};
            list<Alliance_Rebate_Request__c> listRebateReq=TestDataFactory.createNAllianceRebateRequests(5);
        listRebateReq[0].Region__c=listRegions[0];
        listRebateReq[1].Region__c=listRegions[1];
        listRebateReq[2].Region__c=listRegions[2];
        listRebateReq[3].Region__c=listRegions[3];
        listRebateReq[4].Region__c=listRegions[4];
        /* for(string strRegion : listRegions){
Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
arReq.System_Partner_Name__c ='Intel';
arReq.Finance_Contact__c = 'xxx@dell.com';
arReq.Sales_Force_Deal_ID__c = opp.id;
arReq.Region__c=strRegion;
arReq.Client_Enterprise__c='Enterprise';
arReq.Partner_BDM_Name__c='test';
arReq.Status__c = 'Draft';
arReq.Business_Case_Information__c = 'test';
listRebateReq.add(arReq);

}*/
        test.starttest();
        insert listRebateReq;
        // Alliance_Rebate_Request_Team__c rebateTeam = [SELECT Id, User__c FROM Alliance_Rebate_Request_Team__c WHERE Alliance_Rebate_Request_Id__c = :listRebateReq[4].Id];
        // System.assertEquals(usr.Id, rebateTeam.User__c);
        test.stoptest();
    }
    
    // Create Opportunity Information
    
    /*  public static void createOpportunityInfo(String strUserName) {

Id stdOppRTyId = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);

TriggerExecutionController.setSkipAllTriggers(True);
opp = new Opportunity (
RecordTypeId= stdOppRTyId,
Name='TestOpportunity',
Type = 'Run Rate',
Domain__c='Deal Reg',
Solution_Type__c = 'Campus',
Solution_Name__c = 'Wireless Switches',
StageName='Plan - 1%',
Deal_Registration_Status__c = 'Recalled',
Deal_Created_Date_Time__c = System.Now(),
Deal_Expiration_Timeframe__c='60',                                       
CloseDate= System.Now().Date().addDays(180),
Deal_Expiration_Date__c=System.Now().Date().addDays(4),
Primary_Product_Delivery_Address_Region__c = 'APJ',
Request_Status__c='New');

insert opp;

// Create User
profile p = [select id,name from profile where name like '%system admin%'];

usr = new User(Alias = 'standt', Email='Testing01skdw0sl@dell.com', 
EmailEncodingKey='UTF-8', LastName='Testing28ws2', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, Country = 'US',
TimeZoneSidKey='America/Los_Angeles', UserName=strUserName, Badge_Number__c=string.valueof(system.now()));

insert usr;

// Create Opp Team member
OpportunityTeamMember otm = new OpportunityTeamMember();
otm.OpportunityId = opp.id;
otm.UserId  = usr.id; 
insert otm;

TriggerExecutionController.setSkipAllTriggers(false);
}*/
}
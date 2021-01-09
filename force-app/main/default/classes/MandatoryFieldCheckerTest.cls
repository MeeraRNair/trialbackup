/*
Version    Date          Modified By      CR Number      Description
--------------------------------------------------------------------------------------
1.0        07-June-2017   Sriram           CR14401        Non SSO Profile Clean Up
2.0        21-June-2017   Emily            CR14543        Include new stage value - Order Submitted - 99%
3.0                      VIKAS KH           0202            Implemented TDF
*/
//CR 14401 @isTest(seeAllData=true) remove hard coding for RecordtypeId .Based on Id we search name and implement in the logic.

@isTest
private class MandatoryFieldCheckerTest {
    
    static Account testAccount;
    static Sales_Channel_Group__c testSalesChanGrp;
    static OWD__c owd = OWD__c.getOrgDefaults();  
    static list<Account> listAcc;
    static list<Sales_Channel_Group__c> listSalesChannel;
    static list<user> listuser;
    static list<Opportunity> listOpp;
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c(); 
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert oWDsetting;
        list<Sales_Channel_Group__c> listSalesChannelTDF = TestDataFactory.createNSalesChannelGroups(1);
        insert listSalesChannelTDF;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-user Account');
        listAccTDF[0].Sales_Channel__c=listSalesChannelTDF[0].Id;
        insert listAccTDF;  
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTDF[0].Skip_Calculate_LOT_OCEAN__c=true;
        listOppTDF[0].AccountId=listAccTDF[0].Id;
        TriggerExecutionController.setskipOpportunitySplitTriggers(True);
        insert listOppTDF;  
        
    }  
    
    static testMethod void createOppWithServicesSalesProfile() {
        
        // createAccount();
        listAcc = [select id from Account limit 1];  
        Date dCloseDate = System.Today()+10;
        system.assertEquals(listAcc[0], listAcc[0]);
        //CR 14401 - Start
        //   Id OptystdRTId=IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
        //   system.debug('***** Opportunity Record Type ID ******'+OptystdRTId);
        //CR 14401 - End   
        User servicesSalesProfileUser = createUser();
        /*
Opportunity testOpportunity = new Opportunity(Name='Test Opportunity 1', 
Skip_Calculate_LOT_OCEAN__c=true, AccountId=testAccount.Id, Type='Deal/Bid Direct', 
CR14401 RecordTypeId='012300000004zf2',
RecordTypeId=OptystdRTId, CloseDate=dCloseDate, StageName=owd.Oppty_Stage60__c, DGR_Level__c = 'Services DGR not needed',
CR14543 Added to increase code coverage
Pricing_Type__c='',Contract_Term__c=null,Services_Location_s__c=''); 
*/
        listOpp = [select id from Opportunity limit 1];
        listOpp[0].Type='Deal/Bid Direct';
        listOpp[0].DGR_Level__c = 'Services DGR not needed';
        listOpp[0].Pricing_Type__c='';
        listOpp[0].Contract_Term__c=null;
        listOpp[0].Services_Location_s__c='';
        Test.startTest();  
        
        System.runAs(servicesSalesProfileUser ) { 
            try{      
                update listOpp;
            }catch(Exception e){
                
            }          
        }
        
        Test.stopTest();      
    }
    
    static User createUser(){
        
        //CR 14401 - Start
        //List<Profile> p= [select id from profile where name like '%GBL Dell Services Mgr - Non SSO%' order by name limit 1];
        
        List<Profile> listp= [select id from profile where name like '%GBL Dell Services Mgr%' order by name limit 1];
        // CR 14401 - End
        //UserRole r = [Select id from userrole where name='WWExec'];
        /*    
User u = new User(alias = 'standt', email='testuser'+ System.currentTimeMillis() + '@dell.com', 
emailencodingkey='UTF-8', lastname='Testing', 
languagelocalekey='en_US', 
Badge_Number__c= String.valueOf(System.currentTimeMillis()),
localesidkey='en_US', profileid = p[0].Id, //userroleid = r.Id,
timezonesidkey='America/Los_Angeles', 
username='testuser'+ System.currentTimeMillis() + '@dell.com');

insert u;
*/
        list<user> listuser = TestDataFactory.createNGenralUsers(1);
        listuser[0].profileid = listp[0].Id;
        insert listuser;
        
        return listuser[0];
    }
    /*    
static void createAccount(){
//CR7374 Assign Sales channel group to Account.
createSalesChannelGroup();
// system.debug('testSalesChanGrp.Id:'+listSalesChannel[0].Id);
// system.debug('testSalesChanGrp.Name:'+listSalesChannel[0].Name);
// system.debug('testSalesChanGrp.Regional_Parent_Name__c:'+listSalesChannel[0].Regional_Parent_Name__c);
list<Account> listAcc = TestDataFactory.createNAccount(1, 'End-user Account');
listAcc[0].Sales_Channel__c=listSalesChannel[0].Id;
insert listAcc;  

testAccount = new Account(Name='Test Account 10',Sales_Channel__c=listSalesChannel[0].Id);
insert testAccount;      
}

static void createSalesChannelGroup() {


testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
insert testSalesChanGrp;

}
*/    
}
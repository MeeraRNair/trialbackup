/***********************************************************
* Name          : VFCntrlr_RelationshipLeadAccPlayListTest
* Description   : Test Class for VFCntrlr_RelationshipLeadAccPlayList
* ---------------------------------------------------------
* Revision  Name        Date        Description 
* 1.0       Azwanti     18/05/2011  CR6069
* 2.0       Kokila      09-Jan-2018 FY20-DCE-0202 - Lead 2.0 - Campaign Status enhancements - "Aborted" status renamed to "Cancelled" 
*/
@isTest
private class VFCntrlr_RelationshipLeadAccPlayListTest {
    //Define variables
    //static Account testAcc;
    static list<Contact> listCon;
    static list<User> listUser;
    static list<Account> listAcc;
    static list<Campaign> listCamp;
    //static User userRecord1, userRecord2;
    //static List<User> userRecordList = new List<User>();
    //static List<Contact> testContactList = new List<Contact>();
    // static List<Account_Play__c> APList = new List<Account_Play__c>();
    static Account_Play__c testAccountPlay;
    //static Campaign testCampaign;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Contact> listConTDF = TestDataFactory.createNContacts(1);
        insert listConTDF;
        list<User> listUserTDF = TestDataFactory.createNGenralUsers(2);
        insert listUserTDF;
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampTDF;
        
    }
    
    static testMethod void customViewAccountPlayTest() {
        //to test 3 Account Play view
        PageReference pageRef = Page.APCustomView;
        Test.setCurrentPage(pageRef);
        VFCntrlr_RelationshipLeadAccPlayList controller = new VFCntrlr_RelationshipLeadAccPlayList();
        
        //1. My Account Play
        PageReference  pageRefExpectedmyap=new PageReference('/apex/accountplaylist?selectedAPViewFlag=myap');
        controller.setSelectedAPView('myap');
        PageReference pageRefActualmyap = controller.navigateToListAPView();
        
        String strExpectedmyap = pageRefExpectedmyap.getUrl();
        String strActualmyap = pageRefActualmyap.getUrl();
        System.assertEquals(strExpectedmyap,strActualmyap);
        
        String strExpectedmyAPQuery = 'SELECT Name,Account_Play_Owner_Role__c,Account_Play_Owner__c,Account__c,Campaign__c,Account_Play_Expiry_Date_New__c,Status__c FROM Account_Play__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\' AND Status__c !=\'Closed - Expired\') AND recordtypeid != \'' +GlobalVariables.LATTICE_AP_RECTYPE+ '\'  AND Account_Play_Owner__c = \'' + UserInfo.getUserId() + '\' ORDER BY Status_Importance__c ASC, Account_Play_Expiry_Date_New__c DESC LIMIT 10000';
        String strActualmyAPQuery = controller.getAPListQuery();
        System.assertEquals(strExpectedmyAPQuery,strActualmyAPQuery);
        
        //2. My Portfolio Account Play
        PageReference  pageRefExpectedmyportfolioap = new PageReference('/apex/accountplaylist?selectedAPViewFlag=myportfolioap');
        controller.setSelectedAPView('myportfolioap');
        PageReference pageRefActualmyportfolioap = controller.navigateToListAPView();
        
        String strExpectedmyportfolioap = pageRefExpectedmyportfolioap.getUrl();
        String strActualmyportfolioap = pageRefActualmyportfolioap.getUrl();
        System.assertEquals(strExpectedmyportfolioap,strActualmyportfolioap);
        
        String strExpectedmyPortfolioAPQuery = 'SELECT Name,Account_Play_Owner_Role__c,Account_Play_Owner__c,Account__c,Campaign__c,Account_Play_Expiry_Date_New__c,Status__c FROM Account_Play__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\' AND Status__c !=\'Closed - Expired\') AND recordtypeid != \'' +GlobalVariables.LATTICE_AP_RECTYPE+ '\'  AND (Account__r.OwnerId = \'' + UserInfo.getUserId() + '\'  OR Account__c IN :AccIdSet) ORDER BY Status_Importance__c ASC, Account_Play_Expiry_Date_New__c DESC LIMIT 10000';
        String strActualmyPortfolioAPQuery = controller.getAPListQuery();
        System.assertEquals(strExpectedmyPortfolioAPQuery,strActualmyPortfolioAPQuery);
        
        //3. All Account Play 
        PageReference  pageRefExpectedallap = new PageReference('/apex/accountplaylist?selectedAPViewFlag=allap');
        controller.setSelectedAPView('allap');
        PageReference pageRefActualallap = controller.navigateToListAPView();
        
        String strExpectedallap = pageRefExpectedallap.getUrl();
        String stractualallap = pageRefActualallap.getUrl();
        System.assertEquals(strExpectedallap,stractualallap);
        
        String strExpectedallAPQuery = 'SELECT Name,Account_Play_Owner_Role__c,Account_Play_Owner__c,Account__c,Campaign__c,Account_Play_Expiry_Date_New__c,Status__c FROM Account_Play__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\' AND Status__c !=\'Closed - Expired\') AND recordtypeid != \'' +GlobalVariables.LATTICE_AP_RECTYPE+ '\'  ORDER BY Status_Importance__c ASC, Account_Play_Expiry_Date_New__c DESC LIMIT 10000';
        String strActualallAPQuery = controller.getAPListQuery();
        System.assertEquals(strExpectedallAPQuery,strActualallAPQuery);
    }
    
    static testMethod void customViewRelationshipLeadTest() {
        //to test 3 Relationship Lead view
        PageReference pageRef = Page.RLCustomView;
        Test.setCurrentPage(pageRef);
        VFCntrlr_RelationshipLeadAccPlayList controller = new VFCntrlr_RelationshipLeadAccPlayList();
        
        //1. My Relationship Leads
        PageReference  pageRefExpectedmyrl=new PageReference('/apex/relationshipleadlist?isCurrentQuarterRLFlag=false&selectedRLViewFlag=myrl');
        controller.setSelectedRLView('myrl');
        PageReference pageRefActualmyrl = controller.navigateToListRLView();
        
        String strExpectedmyrl = pageRefExpectedmyrl.getUrl();
        String strActualmyrl = pageRefActualmyrl.getUrl();
        System.assertEquals(strExpectedmyrl,strActualmyrl);
        
        String strExpectedmyRLQuery = 'SELECT Name,Relationship_Lead_Owner_Role__c,Relationship_Lead_Owner__c,Contact__c,Account__c,Campaign__c,Due_Date__c,Status__c,Relationship_Lead_Score__c FROM Relationship_Lead__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\') AND Relationship_Lead_Owner__c = \'' + UserInfo.getUserId() + '\'  ORDER BY Status_Importance__c ASC, Score_Importance__c ASC, Due_Date__c ASC LIMIT 10000';
        String strActualmyRLQuery = controller.getRLlistQuery();
        System.assertEquals(strExpectedmyRLQuery,strActualmyRLQuery);
        
        
        //2. My Portfolio Relationship Leads
        PageReference  pageRefExpectedmyportfoliorl = new PageReference('/apex/relationshipleadlist?isCurrentQuarterRLFlag=false&selectedRLViewFlag=myportfoliorl');
        controller.setSelectedRLView('myportfoliorl');
        PageReference pageRefActualmyportfoliorl = controller.navigateToListRLView();
        
        String strExpectedmyportfoliorl = pageRefExpectedmyportfoliorl.getUrl();
        String strActualmyportfoliorl = pageRefActualmyportfoliorl.getUrl();
        System.assertEquals(strExpectedmyportfoliorl,strActualmyportfoliorl);
        
        String strExpectedmyPortfolioRLQuery = 'SELECT Name,Relationship_Lead_Owner_Role__c,Relationship_Lead_Owner__c,Contact__c,Account__c,Campaign__c,Due_Date__c,Status__c,Relationship_Lead_Score__c FROM Relationship_Lead__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\') AND (Contact__r.AccountId IN :listOfAccounts OR Contact__r.Account.OwnerId =\'' + UserInfo.getUserId() + '\') ORDER BY Status_Importance__c ASC, Score_Importance__c ASC, Due_Date__c ASC LIMIT 10000';
        String strActualmyPortfolioRLQuery = controller.getRLlistQuery();
        System.assertEquals(strExpectedmyPortfolioRLQuery,strActualmyPortfolioRLQuery);
        
        //3. All Relationship Leads 
        PageReference  pageRefExpectedallrl = new PageReference('/apex/relationshipleadlist?isCurrentQuarterRLFlag=false&selectedRLViewFlag=allrl');
        controller.setSelectedRLView('allrl');
        PageReference pageRefActualallrl = controller.navigateToListRLView();
        
        String strExpectedallrl = pageRefExpectedallrl.getUrl();
        String strActualallrl = pageRefActualallrl.getUrl();
        System.assertEquals(strExpectedallrl,strActualallrl);   
        
        String strExpectedallRLQuery = 'SELECT Name,Relationship_Lead_Owner_Role__c,Relationship_Lead_Owner__c,Contact__c,Account__c,Campaign__c,Due_Date__c,Status__c,Relationship_Lead_Score__c FROM Relationship_Lead__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\') ORDER BY Status_Importance__c ASC, Score_Importance__c ASC, Due_Date__c ASC LIMIT 10000';
        String strActualallRLQuery = controller.getRLlistQuery();
        System.assertEquals(strExpectedallRLQuery,strActualallRLQuery); 
        
        //1. My Relationship Leads and Current Quarter = true
        PageReference  pageRefExpectedcurrQuartermyrl=new PageReference('/apex/relationshipleadlist?isCurrentQuarterRLFlag=true&selectedRLViewFlag=myrl');
        controller.setSelectedRLView('myrl');      
        controller.iscurrentQuarterRL = true;  
        PageReference pageRefActualcurrQuartermyrl = controller.navigateToListRLView();
        
        String strExpectedcurrQuartermyrl = pageRefExpectedcurrQuartermyrl.getUrl();
        String strActualcurrQuartermyrl = pageRefActualcurrQuartermyrl.getUrl();
        System.assertEquals(strExpectedcurrQuartermyrl,strActualcurrQuartermyrl);
        
        String strExpectedmyCurrQuarterRLQuery = 'SELECT Name,Relationship_Lead_Owner_Role__c,Relationship_Lead_Owner__c,Contact__c,Account__c,Campaign__c,Due_Date__c,Status__c,Relationship_Lead_Score__c FROM Relationship_Lead__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\') AND Due_Date__c = THIS_FISCAL_QUARTER AND Relationship_Lead_Owner__c = \'' + UserInfo.getUserId() + '\'  ORDER BY Status_Importance__c ASC, Score_Importance__c ASC, Due_Date__c ASC LIMIT 10000';
        String stractualmyCurrQuarterRLQuery = controller.getRLlistQuery();
        System.assertEquals(strExpectedmyCurrQuarterRLQuery,stractualmyCurrQuarterRLQuery);
        
        //2. My Portfolio Relationship Leads and Current Quarter = true
        PageReference  pageRefExpectedcurrQuartermyportfoliorl = new PageReference('/apex/relationshipleadlist?isCurrentQuarterRLFlag=true&selectedRLViewFlag=myportfoliorl');
        controller.setSelectedRLView('myportfoliorl');
        PageReference pageRefActualcurrQuartermyportfoliorl = controller.navigateToListRLView();
        
        String strexpectedcurrQuartermyportfoliorl = pageRefExpectedcurrQuartermyportfoliorl.getUrl();
        String stractualcurrQuartermyportfoliorl = pageRefActualcurrQuartermyportfoliorl.getUrl();
        System.assertEquals(strexpectedcurrQuartermyportfoliorl,stractualcurrQuartermyportfoliorl);
        
        String strexpectedmyCurrQuarterPortfolioRLQuery = 'SELECT Name,Relationship_Lead_Owner_Role__c,Relationship_Lead_Owner__c,Contact__c,Account__c,Campaign__c,Due_Date__c,Status__c,Relationship_Lead_Score__c FROM Relationship_Lead__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\') AND Due_Date__c = THIS_FISCAL_QUARTER AND (Contact__r.AccountId IN :listOfAccounts OR Contact__r.Account.OwnerId =\'' + UserInfo.getUserId() + '\') ORDER BY Status_Importance__c ASC, Score_Importance__c ASC, Due_Date__c ASC LIMIT 10000';
        String stractualmyCurrQuarterPortfolioRLQuery = controller.getRLlistQuery();
        System.assertEquals(strexpectedmyCurrQuarterPortfolioRLQuery,stractualmyCurrQuarterPortfolioRLQuery);
        
        //3. All Relationship Leads and Current Quarter = true
        PageReference  pageRefExpectedcurrQuarterallrl = new PageReference('/apex/relationshipleadlist?isCurrentQuarterRLFlag=true&selectedRLViewFlag=allrl');
        controller.setSelectedRLView('allrl');
        PageReference pageRefActualcurrQuarterallrl = controller.navigateToListRLView();
        
        String strexpectedcurrQuarterallrl = pageRefExpectedcurrQuarterallrl.getUrl();
        String stractualcurrQuarterallrl = pageRefActualcurrQuarterallrl.getUrl();
        System.assertEquals(strexpectedcurrQuarterallrl,stractualcurrQuarterallrl); 
        
        String strexpectedallCurrQuarterRLQuery = 'SELECT Name,Relationship_Lead_Owner_Role__c,Relationship_Lead_Owner__c,Contact__c,Account__c,Campaign__c,Due_Date__c,Status__c,Relationship_Lead_Score__c FROM Relationship_Lead__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\') AND Due_Date__c = THIS_FISCAL_QUARTER ORDER BY Status_Importance__c ASC, Score_Importance__c ASC, Due_Date__c ASC LIMIT 10000';
        String stractualallCurrQuarterRLQuery = controller.getRLlistQuery();
        System.assertEquals(strexpectedallCurrQuarterRLQuery,stractualallCurrQuarterRLQuery);
    }  
    
    static testMethod void defaultAPViewTest() {
        //to test default Account Play view - 'Required Follow-Up' view        
        PageReference pageRef = Page.APCustomView;
        Test.setCurrentPage(pageRef);
        
        VFCntrlr_RelationshipLeadAccPlayList controller = new VFCntrlr_RelationshipLeadAccPlayList();
        
        List<SelectOption> listapItems = controller.getAPItems();   
        System.assertEquals(3, listapItems.size());
        
        PageReference  pageRefExpected=new PageReference('/apex/APCustomView?save_new=1&sfdc.override=1&fcf='+StringUtils.defaultString(Label.Default_AP_view_ID));        
        PageReference  pageRefActual = controller.redirectPage();
        System.assert(controller.redirectPage()!=null);
        
        String strexpected=pageRefExpected.getUrl();
        String stractual=pageRefActual.getUrl();        
        System.assertEquals(strexpected,stractual);
        
    }
    
    static testMethod void defaultRLViewTest() {
        //to test default Relationship Lead view - 'Required Follow-Up' view
        PageReference pageRef = Page.RLCustomView;
        Test.setCurrentPage(pageRef);
        
        VFCntrlr_RelationshipLeadAccPlayList controller = new VFCntrlr_RelationshipLeadAccPlayList();
        List<SelectOption> listrlItems = controller.getRLItems();   
        System.assertEquals(3, listrlItems.size());
        
        PageReference  pageRefExpected=new PageReference('/apex/RLCustomView?save_new=1&sfdc.override=1&fcf='+StringUtils.defaultString(Label.Default_RL_view_ID));
        PageReference  pageRefActual = controller.redirectPage();
        
        String strexpected=pageRefExpected.getUrl();
        String stractual=pageRefActual.getUrl();
        System.assertEquals(strexpected,stractual);
    }
    
    static testmethod void navigateBackButtonTest(){
        //1. Account Play Test Back button
        listAcc = [Select Id from Account limit 1];
        system.assertNotEquals(listAcc[0].id, null);
        PageReference pageRefAP = Page.APCustomView;
        Test.setCurrentPage(pageRefAP);
        VFCntrlr_RelationshipLeadAccPlayList controller = new VFCntrlr_RelationshipLeadAccPlayList();
        controller.setSelectedAPView('myap');
        controller.navigateToListAPView();
        
        PageReference  expectedbackAP = new PageReference('/apex/apcustomview');
        PageReference  actualbackAP = controller.navigateToAPTab();
        
        //2. Relationship Leads Test Back button
        PageReference pageRefRL = Page.RLCustomView;
        Test.setCurrentPage(pageRefRL);
        controller.setSelectedAPView('myrl');
        controller.navigateToListRLView();
        
        PageReference  expectedbackRL = new PageReference('/apex/rlcustomview');
        PageReference  actualbackRL = controller.navigateToRLTab();
        system.debug('expected_backRL ' + expectedbackRL);
        system.debug('actual_backRL ' + actualbackRL);
    } 
    static testmethod void subTitletest(){
        PageReference myAPPage = Page.accountplaylist;
        Test.setCurrentPage(myAPPage);
        ApexPages.currentPage().getParameters().put('selectedAPViewFlag', 'myap');      
        
        VFCntrlr_RelationshipLeadAccPlayList controller = new VFCntrlr_RelationshipLeadAccPlayList();
        system.assertEquals('My Account Plays', controller.subTitle);
        
        ApexPages.currentPage().getParameters().put('selectedAPViewFlag', 'myportfolioap');
        controller = new VFCntrlr_RelationshipLeadAccPlayList();
        system.assertEquals('My Portfolio Account Plays', controller.subTitle);
        
        ApexPages.currentPage().getParameters().put('selectedAPViewFlag', 'allap');
        controller = new VFCntrlr_RelationshipLeadAccPlayList();
        system.assertEquals('All Account Plays', controller.subTitle);
        
        PageReference myRLPage = Page.relationshipleadlist;
        Test.setCurrentPage(myRLPage);
        
        ApexPages.currentPage().getParameters().put('selectedRLViewFlag', 'myrl');      
        controller = new VFCntrlr_RelationshipLeadAccPlayList();    
        system.assertEquals('My Relationship Leads', controller.subTitle); 
        
        ApexPages.currentPage().getParameters().put('selectedRLViewFlag', 'myportfoliorl');     
        controller = new VFCntrlr_RelationshipLeadAccPlayList();    
        system.assertEquals('My Portfolio Relationship Leads', controller.subTitle);
        
        ApexPages.currentPage().getParameters().put('selectedRLViewFlag', 'allrl');     
        ApexPages.currentPage().getParameters().put('isCurrentQuarterRLFlag', 'true');
        controller = new VFCntrlr_RelationshipLeadAccPlayList();    
        system.assertEquals('All Relationship Leads in Current Quarter', controller.subTitle);
        
        
        PageReference allAPPage = controller.navigateToListAPView();        
        controller.hasNext = true;
        controller.next();
        // system.assertEquals(controller.currentPage, 1);
        
        controller.hasPrevious = true;
        controller.previous();
        system.assertEquals(controller.currentPage, 1);
        
    }
    
    // Commented by Hussain to reduce test class running time as this method is taking more time to run
    // Date: 29/01/2014
    
    /*    
static testmethod void pagination_test(){   
TestDataCreation(); 

//Create Account Play

for (integer i = 0; i < 55; i++) {
testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id, 
Campaign_Vehicle__c = testCampaign.Type, Status__c = 'Requires Follow-Up', Inside_Sales_Rep__c = userRecord1.Id);

APList.add(testAccountPlay);
}
insert APList;


VFCntrlr_RelationshipLeadAccPlayList controller = new VFCntrlr_RelationshipLeadAccPlayList();
controller.isTest = true;
controller.setSelectedAPView('allap');
PageReference allAPPage = controller.navigateToListAPView();        
controller.hasNext = true;
controller.next();
system.assertEquals(controller.currentPage, 2);

controller.hasPrevious = true;
controller.previous();
system.assertEquals(controller.currentPage, 1);

}

*/
    
    
    //==================================================== TestDataCreation ===============================================================
    static void testDataCreation() {
        //create Account
        listAcc = [Select Id from Account limit 1];
        /*testAcc = new Account(
name='Account CR5987',
Account_Country_Code__c = 'AI',
Account_Country__c = 'ANGUILIA',            
Account_ID__c = ''+System.currentTimeMillis()
);
insert testAcc;        
*/
        //Contact Creation
        ListCon = [Select Id from Contact limit 1];
        listcon[0].AccountId = listAcc[0].Id;
        update listCon[0];
        /*testContactList.clear();
for (integer i = 0; i < 2; i++) {

Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+i);
testContactList.add(testContact);
}                                            
insert testContactList;
*/
        //Create User
        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];        
        listUser = [Select Id from User limit 2];
        listUser[0].Username='testUser1'+System.currentTimeMillis()+'@test.com';
        listUser[0].ProfileId = listUserProfile[0].Id;
        listUser[0].TimeZoneSidKey='America/Los_Angeles';
        update listUser[0];
        listUser[1].Username='testUser2'+System.currentTimeMillis()+'@test.com';
        listUser[1].ProfileId = listUserProfile[1].Id;
        Update listUser[1];
        /*userRecord1 = new User(
Username='testUser1'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test1@dell.com', 
FirstName='Tfirst A', 
LastName='TLast',
ProfileId = userProfile[0].Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST12345',
Title = 'Test Title'
);
userRecordList.add(userRecord1);

userRecord2 = new User(
Username='testUser2'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test2@dell.com', 
FirstName='Tfirst B', 
LastName='TLast',
ProfileId = userProfile[1].Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST56789',
Title = 'Test Title'
);
userRecordList.add(userRecord2);

insert userRecordList; */
        
        //Campaign creation 
        //v2.0 - Start
        /*testCampaign = new Campaign (Type='Dell Day', EndDate= date.newInstance(2010, 1, 1), 
IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2010, 1, 1), 
Name='AZ Test Campaign CR5987', Follow_Up_Role__c = 'Inside Sales Rep',
Is_this_Account_Play_Campaign__c = True, Account_Play_Expiry_Date__c = System.today() + 60,
Proceed_with_cancellation__c = 'No');*/
        /*testCampaign = new Campaign (Type='Dell Day', EndDate= date.newInstance(2010, 1, 1), 
IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2010, 1, 1), 
Name='AZ Test Campaign CR5987', Follow_Up_Role__c = 'Inside Sales Rep',
Is_this_Account_Play_Campaign__c = True, Account_Play_Expiry_Date__c = System.today() + 60);
//v2.0 - End
insert testCampaign;*/
        listCamp = [Select Id from Campaign limit 1];
        listCamp[0].Account_Play_Expiry_Date__c = System.today() + 60;
        listCamp[0].StartDate=date.newInstance(2010, 1, 1);
        update listCamp[0];
    }
}
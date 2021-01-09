/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CSMBUtilClassTest {
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static list<Contact> listCon;
    static list<User> listuser;
 //   public static Account account;
 //   public static Opportunity opportunity;
 //   public static Contact cont;
    public static Support_Request__c supportReq;
    public static Contract contract;
    public static Contract contract1;
    public static Contract contract2;
    public static Contract contract3;
    public static User user;
    public static Set<String> setaprroverFields =new Set<String>();
    public static Map<String,String> mapOfApproverFields = new Map<String,String>();
   @testSetup static void setup(){
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

        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
        insert listAccTDF;
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        TriggerExecutioncontroller.setSkipOpportunitySplitTriggers(True);
        insert listOppTDF;
        list<Contact> listConTDF = TestDataFactory.CreateNContacts(1);
        insert listConTDF;
        list<user> listUserTDF = TestDataFactory.CreateNGenralUsers(1);
        insert listUserTDF;
    }

    public static void createData(){
        
        //Men Mee added to avoid SQOL 101 Limit exception
         TriggerExecutionController.setSkipAccountTriggers(true);
         TriggerExecutionController.setSkipContactTriggers(true);
  /*       
        ID acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
         account = new Account(name='TEST',recordtypeid=acRecTypeId);
         
         insert account;
         */
        test.startTest();
        listAcc = [select id from Account limit 1];
        listOpp = [select id,AccountID from Opportunity limit 1];
        listOpp[0].AccountID = listAcc[0].id;
        listOpp[0].closeDate = system.Date.today();
        TriggerExecutioncontroller.setSkipOpportunityTriggers(True);
        update listOpp;
/*        
         opportunity = new Opportunity(accountId=account.id,
            name='TestOpp',
            Type='Run Rate',
            Solution_Type__c='Business Processing',
            StageName='Plan - 1%',
            //CloseDate=date.parse('12/10/2011')); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
            CloseDate=System.Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        
         insert opportunity;
         */
        listCon = [select id,AccountID,Email from Contact limit 1];
        listCon[0].accountId=listAcc[0].Id;
        listCon[0].Email='test@ust-global.com';
        update listCon;
        /*
         cont = new Contact(FirstName='TestContact1',
             LastName='TestContactlast1',
             accountId=account.Id,
             Email='test@ust-global.com',
             fax='01987645',
             MobilePhone='0000019',
             Phone='0000000');
           
         insert cont; 
*/
         //Men Mee added to avoid SQOL 101 Limit exception
         TriggerExecutionController.setSkipAccountTriggers(false);
         TriggerExecutionController.setSkipContactTriggers(false);
         
         //Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request CSMB Contract Support', 'Support_Request__c', true);
         Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request Contracts Support', 'Support_Request__c', true);
         supportReq = new Support_Request__c(Opportunity__c= listOpp[0].id,
             CSMB_Contract_Request_Type__c='New Contract',
             Region__c='Americas',
             Sub_Region__c='Latin America',
             Contact_Name__c=listCon[0].id,
             Support_Status__c='Pending',
             RecordTypeId= srRecordTypeId,
             Status__c='New',  // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
             Segment_Business_Unit__c='PLE');
        
          insert supportReq;
        /*        
          Profile profile = [Select id from Profile where name like '%Contract Manager' limit 1];
          String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev'; // Fenny added
          user = new User(Alias = 'CM101',
                  LastName = 'testCM101',
                  Email = 'x.y@ust-global.com',
                  Username = username,
                  CommunityNickname = 'testCM101',
                  EmailEncodingKey = 'ISO-8859-1',
                  TimeZoneSidKey = 'America/Panama',
                  LocaleSidKey = 'en_US',
                  LanguageLocaleKey = 'en_US',
                  ProfileId = profile.id,
                  Badge_number__c='CM101');
            insert user;
            */
        listUser = [select id from user limit 1];
            contract = new Contract(accountId=listAcc[0].Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=listuser[0].id,
                  CSMB_Support_Request__c =supportReq.id,
                  Add_Approver_2__c=listuser[0].id,
                  No_Approval_Required__c=false);
          
          insert contract;
          
          contract1 = new Contract(accountId=listAcc[0].Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=listUser[0].id,
                  CSMB_Support_Request__c =supportReq.id,
                  Add_Approver_1__c=listuser[0].id,
                  No_Approval_Required__c=false);
          
          insert contract1;
          
          //updating contract with changes in approver-fields
          contract1.No_Approval_Required__c=false;
          contract1.Add_Approver_1__c = null;
          contract1.Add_Approver_2__c = listuser[0].id;
          update contract1;
          contract2 = new Contract(accountId=listAcc[0].Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=listuser[0].id,
                  CSMB_Support_Request__c =supportReq.id,
                  Accounting__c=listuser[0].id,
                  No_Approval_Required__c=false);
                  
          insert contract2;
          
          //updating contract with no changes in approver-fields
          update contract2;
         /* contract3 = new Contract(accountId=account.Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=user.id,
                  CSMB_Support_Request__c =supportReq.id,
                  Credit__c=user.id,
                  No_Approval_Required__c=false);
                  
          insert contract3;*/
            mapOfApproverFields.put('Accounting__c','Dupe_Accounting__c');
            mapOfApproverFields.put('Credit__c','Dupe_Credit__c');
            mapOfApproverFields.put('Finance1__c','Dupe_Finance__c');
            mapOfApproverFields.put('Legal1__c','Dupe_Legal__c');
            mapOfApproverFields.put('Sales_GM_VP__c','Dupe_Sales_GM_VP__c');
            mapOfApproverFields.put('Add_Approver_1__c','Dupe_Add_Approver_1__c');
            mapOfApproverFields.put('Add_Approver_2__c','Dupe_Add_Approver_2__c');
        
            setaprroverFields = mapOfApproverFields.keySet();
                  test.stopTest();

        CSMBUtilClass.isValueChanged(null, null);
          }
    static testMethod void myUnitTest() {
        createData();
    //    Test.startTest();
        //CR11722
        //System.assertEquals(user.id, CSMBUtilClass.getDummyId(contract1, setaprroverFields));
        System.assertEquals(listuser[0].id, CSMBUtilClass.getDummyId(contract1));
        //CR11722-end
        
      //  test.stopTest();
    }
}
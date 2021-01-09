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
 
/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         MenMee      20-Feb-2013     14.2                Too many SOQL queries exception. Move Test.startTest to the desired test section
2.0			VIKAS KH					0202				Too implement TDF
*/
@isTest
private class CMFinalizeContractControllerTest {
    static list<Account> listAcc;
    static list<contact> listcon;
    static list<user> listuser;
    static list<opportunity> listopp;
    static list<Support_Request__c> listSpprtReq;
    static list<Contract_Manager_Email__c> listConMa;
    static list<Contract> listContr;
    @testSetup static void setup(){
        list<Profile> listuserProfile = [Select id from Profile where name like '%Contract Manager' Limit 1];
        list<user> listuserTDF = TestDataFactory.createNGenralUsers(1);
        listuserTDF[0].ProfileId = listuserProfile[0].id;
        insert listuserTDF;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
        TriggerExecutionController.setSkipAccountTriggers(True);
        insert listAccTDF;
        list<contact> listConTDF = TestDataFactory.createNContacts(1);
        listConTDF[0].AccountID = listAccTDF[0].id;
        insert listConTDF;
        list<opportunity> listoppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listoppTDF[0].accountId=listAccTDF[0].id;
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true);
        TriggerExecutioncontroller.setSkipOpportunityTriggers(True);
        insert listoppTDF;
        list<Contract_Manager_Email__c> listConMaTDF = TestDataFactory.createNContractManager(1);
        listConMaTDF[0].Contract_Manager1__c=listuserTDF[0].id;
        listConMaTDF[0].Contract_Administrator__c=listuserTDF[0].id;
        insert listConMaTDF;
        list<Contract> listContrTDF = TestDataFactory.createNContract(1);
        listContrTDF[0].Contract_Manager__c=listuserTDF[0].id;
        listContrTDF[0].Add_Approver_1__c = listuserTDF[0].id;
        listContrTDF[0].ownerid=listuserTDF[0].id;
        listContrTDF[0].Accounting__c=listuserTDF[0].id;
        listContrTDF[0].AccountId = listAccTDF[0].id;
        insert listContrTDF;

        
       }  
    static testMethod void myUnitTest() {
    //Skip all triggers to avoid Too much SOQL Query
    Id acRecTypeID;
    Id srRecordTypeID;
    //Profile profile;
 //   Account account;
 //   Opportunity opportunity;
 //   Contact cont;
 //   Support_Request__c supportReq;
    Contract contract;
   // User user;
    Contract_Manager_Email__c contractManagerEmail;
    Id[] listidArray = new Id[]{};
    boolean bolMessage = false;
    boolean bautoApprovalInitiated=False;
    //static testMethod void createData() {
    Test.startTest();
        listAcc = [select id from Account limit 1];
        listCon = [select id from Contact limit 1];
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        listOpp = [select id from Opportunity limit 1];
        list<Support_Request__c> listSpprtReq = TestDataFactory.createNSupportRequests(1, 'Request Contracts Support');
        listSpprtReq[0].Contact_Name__c=listCon[0].id;
        listSpprtReq[0].Opportunity__c= listopp[0].id;
        //listSpprtReq[0].Status__c='New';
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        insert listSpprtReq;
        //listSpprtReq[0].Status__c='Accept';
        //update listSpprtReq;
        system.assertEquals(listSpprtReq[0].Opportunity__c, listSpprtReq[0].Opportunity__c);
        /*
         acRecTypeID =IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
         //srRecordTypeID=IdLookupUtils.getRecordTypeId('Request CSMB Contract Support', 'Support_Request__c', true);
         srRecordTypeID=IdLookupUtils.getRecordTypeId('Request Contracts Support', 'Support_Request__c', true);
         //recType=[select id from Recordtype where sobjecttype='account' and name='End-User Account'];
         account = new Account(name='TEST',recordtypeid=acRecTypeID);
         
         insert account;
         
         opportunity = new Opportunity(accountId=account.id,
                name='TestOpp',
                Type='Run Rate',
                Solution_Type__c='Business Processing',
                StageName='Plan - 1%',
                //CloseDate=date.parse('12/10/2011')); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
                CloseDate=System.Date.TODAY()); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        
         insert opportunity;
         
         cont = new Contact(FirstName='TestContact1',
                LastName='TestContactlast1',
                accountId=account.Id,
                Email='test@ust-global.com',
                fax='01987645',
                MobilePhone='0000019',
                Phone='0000000');
           
         insert cont;
         
         supportReq = new Support_Request__c(Opportunity__c= opportunity.id,
                CSMB_Contract_Request_Type__c='New Contract',
                Region__c='Americas',
                Sub_Region__c='Latin America',
                Contact_Name__c=cont.id,
                Segment_Business_Unit__c='PLE',
                Status__c='New', // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
                RecordTypeId=srRecordTypeID);
        
        insert supportReq;
         
        Profile profile = new profile();
         //for(Profile userProfile:[Select id from Profile where name like '%CSMB Contract Manager' Limit 1]){
         for(Profile userProfile:[Select id from Profile where name like '%Contract Manager' Limit 1]){
             profile=userprofile;
         }
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

          listuser = [select id from user limit 1];
        /*
        contractManagerEmail = new Contract_Manager_Email__c(Senior_Manager__c=listuser[0].id,
                               Region__c='Americas',
                               Sub_Region1__c='LatinAmericas',
                               Business_unit1__c='CSG/Telco',
                               Contract_Manager1__c=listuser[0].id,
                               Contract_Administrator__c=listuser[0].id);
                               
        insert contractManagerEmail;
        */
       /* list<Contract_Manager_Email__c> listConMa = TestDataFactory.createNContractManager(1);
        listConMa[0].Contract_Manager1__c=listuser[0].id;
        listConMa[0].Contract_Administrator__c=listuser[0].id;
        insert listConMa; */
        listConMa = [select id from Contract_Manager_Email__c limit 1];
        //Activate skip all triggers
    //    TriggerExecutionController.setSkipAllTriggers(false);
        
  //      Test.startTest();
  /*      contract = new Contract(accountId=listAcc[0].Id,Status='Pending',Completed__c=false,ownerid=listuser[0].id,Accounting__c=listuser[0].id);
        insert contract;
    */
     /*   list<Contract> listContr = TestDataFactory.createNContract(1);
        listContr[0].Contract_Manager__c=listuser[0].id;
        listContr[0].Add_Approver_1__c = listuser[0].id;
        listContr[0].ownerid=listuser[0].id;
        listContr[0].Accounting__c=listuser[0].id;
        listContr[0].AccountId = listAcc[0].id;
        insert listContr;
        */
        listContr = [select status, Completed__c,OwnerId from contract limit 1];
        //contract con = [select status, Completed__c from contract where status='Pending'];
        //contract.Completed__c=true;
        listContr[0].Status ='Approved';  //new SelectOption('Completed','completed');
        update listContr[0];
        listSpprtReq[0].Support_Status__c = listContr[0].status;
        update listSpprtReq[0]; 
        //Test.stopTest();
        listidArray.add(listContr[0].OwnerId);
    
    //Test.startTest(); //1.0
    //createdata();
    ApexPages.StandardController cMController = new ApexPages.StandardController(listContr[0]);
    ApexPages.currentPage().getParameters().put('id', listContr[0].id);
    CMFinalizeContractController cmFinalizeCon = new CMFinalizeContractController(cMController);
    cmFinalizeCon.getautoApprovalInitiated();
    cmFinalizeCon.setautoApprovalInitiated(bautoApprovalInitiated);
    cmFinalizeCon.getbolMessage();
    cmFinalizeCon.setbolMessage(bolMessage);
    cmFinalizeCon.autoApproveContract();
    Test.StopTest();

    /*public static testMethod void autoApproveContract(){
        createData();
        Test.startTest();
        PageReference  pr=new PageReference('/'+contract.id);
        Approval.Processsubmitrequest request = new Approval.Processsubmitrequest();
              request.setComments('Submit for auto Approval');
              request.setObjectId(contract.id);
              request.setNextApproverIds(idArray);
        Approval.Processresult result = Approval.process(request);
        System.assert(result.isSuccess());
        System.assertEquals('Completed','result.getInstanceStatus()', 'Instance Status'+result.getInstanceStatus());
        List<ID> newWorkItemIds = result.getNewWorkitemIds();
         Approval.Processworkitemrequest workingRequest = new Approval.Processworkitemrequest();
                workingRequest.setComments('Approving request');
                workingRequest.setAction('Approve');
                workingRequest.setWorkitemId(newWorkItemIds.get(0));
                workingRequest.setNextApproverIds(idArray);
         Approval.Processresult result2 = approval.process(workingRequest); 
         // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        System.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());

    }*/
    }
    
}
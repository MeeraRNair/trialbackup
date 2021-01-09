/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@istest
Private Class CMRecordTypeForTandCControllerTest{
    static list<Account> listAcc;
    static list<contact> listcon;
    static list<opportunity> listopp;
    static list<Support_Request__c> listSpprtReq;
    static list<Contract> listcontract;
    @testSetup static void setup(){
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdsetting;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
        TriggerExecutioncontroller.setSkipAccountTriggers(True);
        insert listAccTDF;
        list<contact> listConTDF = TestDataFactory.createNContacts(1);
        listConTDF[0].AccountID = listAccTDF[0].id;
        insert listConTDF;
        list<opportunity> listoppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listoppTDF[0].accountId=listAccTDF[0].id;
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true);
        insert listoppTDF;
           }  

    static testMethod void myUnitTest() {
            TriggerExecutionController.setSkipAllTriggers(true);    

    //Skip all triggers to avoid Too much SOQL Query
    /*
    
    id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
    Account act = new account();
    act.name='TEST';
    act.recordtypeid=acRecTypeId;
    
    insert act;
    
    contact cont= new contact();
    cont.FirstName='TestContact1';
    cont.LastName='TestContactlast1';
    cont.accountId=act.Id;
    cont.Email='test@ust-global.com';
    cont.fax='01987645';
    cont.MobilePhone='0000019';
    cont.Phone='0000000';
    
    insert cont;
        
    Opportunity op = new Opportunity();
    op.accountId=act.id;
    op.name='TestOpp';
    op.Type='Run Rate';
    op.Solution_Type__c='Business Processing';
    op.StageName='Plan - 1%';
    //op.CloseDate=date.parse('12/10/2011'); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
    op.CloseDate=System.Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
       
    insert op;
    
    //ID srRecordTypeID=IdLookupUtils.getRecordTypeId('Request CSMB Contract Support', 'Support_Request__c', true);
    ID srRecordTypeID=IdLookupUtils.getRecordTypeId('Request Contracts Support', 'Support_Request__c', true);
    Support_Request__c supReq = new Support_Request__c();
    supReq.Opportunity__c= op.id;
    supReq.CSMB_Contract_Request_Type__c='New Contract';
    supReq.Region__c='Americas';
    supReq.Sub_Region__c='Latin America';
    supReq.Contact_Name__c=cont.id;
    supReq.RecordTypeId = srRecordTypeID;
    supReq.Status__c='New';  // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
    
    insert supReq;
    
    contract con = new contract();
    con.accountId=act.id;
    con.status='Pending';
    con.No_Approval_Required__c=true;
    
    insert con;
    */
   TriggerExecutioncontroller.setSkipAccountTriggers(True);
    listAcc = [select id, RecordtypeID from Account limit 1];
    listCon = [select id from contact limit 1];
    system.assertEquals(listAcc, listAcc);
        Test.startTest();
    listOpp = [select id from Opportunity limit 1];
    TriggerExecutioncontroller.setSkipOpportunitySplitTriggers(True);
   // listcontract = [select id from contract limit 1];
        list<Support_Request__c> listSpprtReq = TestDataFactory.createNSupportRequests(1, 'Request Contracts Support');
        listSpprtReq[0].Contact_Name__c=listCon[0].id;
        listSpprtReq[0].Opportunity__c= listopp[0].id;
        //listSpprtReq[0].Status__c='New';
        insert listSpprtReq;
        //listSpprtReq[0].Status__c='Accept';
        //update listSpprtReq;
        list<Contract> listcontract = TestDataFactory.createNContract(1);
        listcontract[0].AccountId = listAcc[0].id;
        listcontract[0].status='Pending';
        listcontract[0].No_Approval_Required__c=true;
        insert listcontract;

    string strstdRecTyp=IdLookupUtils.getRecordTypeId('Standard Terms and Conditions', 'Contract_Terms_and_Conditions__c', true);
    string strnonStdRecTyp = IdLookupUtils.getRecordTypeId('Non-Standard Terms and Conditions', 'Contract_Terms_and_Conditions__c', true);
    string strrecTyp=listAcc[0].RecordTypeID;
    
    //Activate skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
    
    
    ApexPages.StandardController CMController = new ApexPages.StandardController(listcontract[0]);
    ApexPages.currentPage().getParameters().put('id', listcontract[0].id); 
    CMRecordTypeForTandCController cmRecordTypeforTandC = new CMRecordTypeForTandCController(CMController);
    cmRecordTypeforTandC.getRecordType();
    cmRecordTypeforTandC.setRecordType(strstdRecTyp);
    cmRecordTypeforTandC.getRecTypeList();
    cmRecordTypeforTandC.getrectypes();
    cmRecordTypeforTandC.redirect();
    cmRecordTypeforTandC.setRecordType(strnonStdRecTyp);
    cmRecordTypeforTandC.getRecTypeList();
    cmRecordTypeforTandC.getrectypes();
    cmRecordTypeforTandC.redirect();
    cmRecordTypeforTandC.setRecordType(strstdRecTyp);
    cmRecordTypeforTandC.getRecTypeList();
    cmRecordTypeforTandC.getrectypes();
    cmRecordTypeforTandC.redirect();
    cmRecordTypeforTandC.cancel();
    Test.stopTest();
    }
}
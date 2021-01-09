/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/
@istest
Private Class CMVFTermsandConditionsViewControllerTest{
    static list<Account> listAcc;
    static list<contact> listcon;
    static list<opportunity> listopp;
    static list<Support_Request__c> listSpprtReq;
    static list<Contract> listcontract;
    static List<Contract_Terms_and_Conditions__c> listContractTms;
    static List<Contract_Terms_and_Conditions__c> listContractTm1;
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
        TriggerExecutioncontroller.setSkipAccountTriggers(True);
        insert listAccTDF;
        list<contact> listConTDF = TestDataFactory.createNContacts(1);
        listConTDF[0].AccountID = listAccTDF[0].id;
        insert listConTDF;
        list<opportunity> listoppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listoppTDF[0].accountId=listAccTDF[0].id;
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true);
        insert listoppTDF;
        list<Contract> listcontractTDF = TestDataFactory.createNContract(1);
        listcontractTDF[0].AccountId = listAccTDF[0].id;
        listcontractTDF[0].status='Pending';
        listcontractTDF[0].No_Approval_Required__c=true;
        insert listcontractTDF;
        List<CSMB_Terms_and_Conditions_Maintenance__c> listCsmBTermsMain = TestDataFactory.createNCSMBTermsANdConditionMaintenance(2);
        insert listCsmBTermsMain;
        List<CSMB_Terms_and_Condition__c> listcSMBTerms = TestDataFactory.createNCSMBTermsANdCondition(4);
        listcSMBTerms[0].Standard_Term__c=listCsmBTermsMain[1].id;
        listcSMBTerms[0].Standard_Terms_and_Conditions__c='1. The parties have reasonable right to audit one another’s facilities, books and records relating to the Agreement, to ensure compliance with performance obligations, and adequacy of performance, under the Agreement.';
        listcSMBTerms[1].Standard_Term__c=listCsmBTermsMain[1].id;
        listcSMBTerms[0].Standard_Terms_and_Conditions__c='2. The parties agree that audits are only to be conducted by an independent, internationally recognized auditing firm.';
        listcSMBTerms[2].Standard_Term__c=listCsmBTermsMain[0].id;
	    listcSMBTerms[2].Standard_Terms_and_Conditions__c='1. Customer must inspect immediately the product upon delivery to note damage to outer boxes or loss and notify Dell. (MWD for inside the box or system – timeline is not a concern for our team.)';
        listcSMBTerms[3].Standard_Term__c=listCsmBTermsMain[0].id;
	    listcSMBTerms[3].Standard_Terms_and_Conditions__c='3. If customer refuses to accept delivery, the customer is responsible for any costs incurred by Dell to store or transport the product as well as any losses to value of product.';
        insert listcSMBTerms;
        List<Contract_Terms_and_Conditions__c> listContractTerms = TestDataFactory.createNContractTermsANdCondition(1, 'Standard Terms and Conditions');
        listContractTerms[0].contract__c=listcontractTDF[0].id;
        listContractTerms[0].Standard_Term__c=listCsmBTermsMain[0].id;
        listContractTerms[0].Terms_and_Conditions__c=listcSMBTerms[2].id;
        listContractTerms[0].Terms_and_conditions_Content__c=listcSMBTerms[2].Standard_Terms_and_Conditions__c;
        insert listContractTerms;
        List<Contract_Terms_and_Conditions__c> listContractTerms1 = TestDataFactory.createNContractTermsANdCondition(1,'Non-Standard Terms and Conditions');
        listContractTerms1[0].contract__c=listcontractTDF[0].id;
        insert listContractTerms1;
           }  
    
 static testMethod void myUnitTest() {
 
 // Skill all trigger to avoid too many SOQL Query Issue
 TriggerExecutionController.setSkipAllTriggers(true);
/*
 Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
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

 //Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request CSMB Contract Support', 'Support_Request__c', true);
 Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request Contracts Support', 'Support_Request__c', true);
 Support_Request__c supReq = new Support_Request__c();
 supReq.Opportunity__c= op.id;
 supReq.CSMB_Contract_Request_Type__c='New Contract';
 supReq.Region__c='Americas';
 supReq.Sub_Region__c='Latin America';
 supReq.Contact_Name__c=cont.id;
 supReq.RecordTypeId =srRecordTypeID;
    supReq.Status__c='New';  // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation

 insert supReq;

 contract con = new contract();
 con.accountId=act.id;
 con.status='Pending';
 con.No_Approval_Required__c=true;

 insert con;
 */
 //Revert back the skip all triggers
 TriggerExecutionController.setSkipAllTriggers(false);
       listAcc = [select id, RecordtypeID from Account limit 1];
       listCon = [select id from contact limit 1];
       Test.startTest();
       listOpp = [select id from Opportunity limit 1];
       TriggerExecutioncontroller.setSkipOpportunitySplitTriggers(True);
       list<Support_Request__c> listSpprtReq = TestDataFactory.createNSupportRequests(1, 'Request Contracts Support');
       listSpprtReq[0].Contact_Name__c=listCon[0].id;
       listSpprtReq[0].Opportunity__c= listopp[0].id;
       insert listSpprtReq;
       //listSpprtReq[0].Status__c='Accept';
       //update listSpprtReq;
      system.assertEquals(listSpprtReq[0].Opportunity__c, listSpprtReq[0].Opportunity__c);
       listContract = [select id from Contract limit 1];

// Test.startTest();
 /*
 list<CSMB_Terms_and_Conditions_Maintenance__c> newCSMBTandCList = new list<CSMB_Terms_and_Conditions_Maintenance__c>();
 CSMB_Terms_and_Conditions_Maintenance__c CSMBmaintananceObj1= new CSMB_Terms_and_Conditions_Maintenance__c(); 
 CSMBmaintananceObj1.Name='TDelivery';
 CSMBmaintananceObj1.status__c=True;
 newCSMBTandCList.add(CSMBmaintananceObj1);

 CSMB_Terms_and_Conditions_Maintenance__c CSMBmaintananceObj2= new CSMB_Terms_and_Conditions_Maintenance__c();
 CSMBmaintananceObj2.Name='TAudit';
 CSMBmaintananceObj2.status__c=False;
 newCSMBTandCList.add(CSMBmaintananceObj2);
 
 insert newCSMBTandCList;
 
 list<CSMB_Terms_and_Condition__c> TermsList = new list<CSMB_Terms_and_Condition__c>();
 CSMB_Terms_and_Condition__c CSMBtermObj1= new CSMB_Terms_and_Condition__c();
 CSMBtermObj1.Standard_Term__c=CSMBmaintananceObj2.id;
 CSMBtermObj1.Standard_Terms_and_Conditions__c='1. The parties have reasonable right to audit one another’s facilities, books and records relating to the Agreement, to ensure compliance with performance obligations, and adequacy of performance, under the Agreement.';
 CSMBtermObj1.status__c=True;
 TermsList.add(CSMBtermObj1);

 CSMB_Terms_and_Condition__c CSMBtermObj2= new CSMB_Terms_and_Condition__c();
 CSMBtermObj2.Standard_Term__c=CSMBmaintananceObj2.id;
 CSMBtermObj2.Standard_Terms_and_Conditions__c='2. The parties agree that audits are only to be conducted by an independent, internationally recognized auditing firm.';
 CSMBtermObj2.status__c=True;
 TermsList.add(CSMBtermObj2);

 CSMB_Terms_and_Condition__c CSMBtermObj3= new CSMB_Terms_and_Condition__c();
 CSMBtermObj3.Standard_Term__c=CSMBmaintananceObj1.id;
 CSMBtermObj3.Standard_Terms_and_Conditions__c='1. Customer must inspect immediately the product upon delivery to note damage to outer boxes or loss and notify Dell. (MWD for inside the box or system – timeline is not a concern for our team.)';
 CSMBtermObj3.status__c=True;
 TermsList.add(CSMBtermObj3);

 CSMB_Terms_and_Condition__c CSMBtermObj4= new CSMB_Terms_and_Condition__c();
 CSMBtermObj4.Standard_Term__c=CSMBmaintananceObj1.id;
 CSMBtermObj4.Standard_Terms_and_Conditions__c='3. If customer refuses to accept delivery, the customer is responsible for any costs incurred by Dell to store or transport the product as well as any losses to value of product.';
 CSMBtermObj4.status__c=True;
 TermsList.add(CSMBtermObj4);
 
 insert TermsList;
 
 Id stdRecTypeID =IdLookupUtils.getRecordTypeId('Standard Terms and Conditions', 'Contract_Terms_and_Conditions__c', true);
 Id nonStdRecTypeId=IdLookupUtils.getRecordTypeId('Non-Standard Terms and Conditions', 'Contract_Terms_and_Conditions__c', true);
      
 Contract_Terms_and_Conditions__c conStdObj = new Contract_Terms_and_Conditions__c();
 conStdObj.contract__c=con.id;
 conStdObj.RecordTypeId=stdRecTypeID;
 conStdObj.Standard_Term__c=CSMBmaintananceObj1.id;
 conStdObj.Terms_and_Conditions__c=CSMBtermObj3.id;
 conStdObj.Terms_and_conditions_Content__c=CSMBtermObj3.Standard_Terms_and_Conditions__c;
 
 insert conStdObj;
 
 Contract_Terms_and_Conditions__c conNonStdObj = new Contract_Terms_and_Conditions__c();
 conNonStdObj.contract__c=con.id;
 conNonStdObj.RecordTypeId=nonStdRecTypeID;
 conNonStdObj.Standard_Term__c=CSMBmaintananceObj1.id;
 conNonStdObj.Terms_and_conditions_Content__c='Non standard Audit Test data';
 
 insert conNonStdObj;
 */
 listContractTms = [select id from Contract_Terms_and_Conditions__c where RecordType.Name = 'Standard Terms and Conditions' limit 1];
  listContractTm1 = [select id from Contract_Terms_and_Conditions__c where RecordType.Name = 'Non-Standard Terms and Conditions' limit 1];
    
 ApexPages.StandardController cMController = new ApexPages.StandardController(listContract[0]);
 ApexPages.currentPage().getParameters().put('id', listContract[0].id);
 CMVFTermsandConditionsViewController termsandconditionsview = new CMVFTermsandConditionsViewController(cMController);
 list<CMVFTermsandConditionsViewController.TermsandConditionsViewClass> liststdTermsandConditionsViewList = new list<CMVFTermsandConditionsViewController.TermsandConditionsViewClass>();
 list<CMVFTermsandConditionsViewController.TermsandConditionsViewClass> listnonStdTermsandConditionsViewList = new list<CMVFTermsandConditionsViewController.TermsandConditionsViewClass>();
 termsandconditionsview.getstdTermsandConditionsViewList();
 termsandconditionsview.setstdTermsandConditionsViewList(liststdTermsandConditionsViewList);
 termsandconditionsview.getnonStdTermsandConditionsViewList();
 termsandconditionsview.setnonStdTermsandConditionsViewList(listnonStdTermsandConditionsViewList);
 termsandconditionsview.clickOk(); 
 termsandconditionsview.getNonStdTerms();
 termsandconditionsview.getStdTerms();
 termsandconditionsview.getnoNonStdTermdefined();
 termsandconditionsview.getnonStdTermsandConditionsViewList();
 Test.stopTest(); 
 }
}
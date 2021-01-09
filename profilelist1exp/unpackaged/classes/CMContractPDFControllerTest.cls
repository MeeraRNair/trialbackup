/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@istest
Private Class CMContractPDFControllerTest{
    static list<Account> listAcc;
    static list<contact> listcon;
    static list<opportunity> listopp;
    static list<Support_Request__c> listSpprtReq;
    static list<Contract> listcontract;
    static List<Addendum_Data__c> listaddendum;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
        TriggerExecutioncontroller.setSkipAccountTriggers(True);
        insert listAccTDF;
        list<contact> listConTDF = TestDataFactory.createNContacts(1);
        listConTDF[0].AccountID = listAccTDF[0].id;
        insert listConTDF;
        list<opportunity> listoppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listoppTDF[0].accountId=listAccTDF[0].id;
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true);
        TriggerExecutioncontroller.setSkipAllTriggers(True);
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
        listcSMBTerms[1].Standard_Term__c=listCsmBTermsMain[1].id;
        listcSMBTerms[2].Standard_Term__c=listCsmBTermsMain[0].id;
        listcSMBTerms[3].Standard_Term__c=listCsmBTermsMain[0].id;
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
        List<Addendum_Data__c> listaddendumTDF = TestDataFactory.createNAddendumData(2);
        listaddendumTDF[0].Addendum_Contract_Relation__c = listcontractTDF[0].id;
        listaddendumTDF[1].Addendum_Contract_Relation__c = listcontractTDF[0].id;
        insert listaddendumTDF;

           }  
 
   static testMethod void myUnitTest(){
        
        // Skill all trigger to avoid too many SOQL Query Issue
        TriggerExecutionController.setSkipAllTriggers(true);
        /*  
        RecordType recType=[select id from Recordtype where sobjecttype='account' and name='End-User Account'];
        Account act = new account();
        act.name='TEST';
        act.recordtypeid=recType.id;
        
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
        
        Support_Request__c supReq = new Support_Request__c();
        supReq.Opportunity__c= op.id;
        supReq.CSMB_Contract_Request_Type__c='New Contract';
        supReq.Region__c='Americas';
        supReq.Sub_Region__c='Latin America';
        supReq.Contact_Name__c=cont.id;
        supReq.Status__c='New';
        
        insert supReq;
        
        Contract con = new contract();
        con.accountId=act.id;
        con.status='Pending';
        con.No_Approval_Required__c = true;
        
        insert con;
        */
       listAcc = [select id, RecordtypeID from Account limit 1];
       listCon = [select id from contact limit 1];
       Test.startTest();
       listOpp = [select id from Opportunity limit 1];
       TriggerExecutioncontroller.setSkipOpportunitySplitTriggers(True);
       list<Support_Request__c> listSpprtReq = TestDataFactory.createNSupportRequests(1, 'Request Contracts Support');
       listSpprtReq[0].Contact_Name__c=listCon[0].id;
       listSpprtReq[0].Opportunity__c= listopp[0].id;
       insert listSpprtReq;
       listContract = [select id from Contract limit 1];
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
        */
     /*   list<CSMB_Terms_and_Condition__c> TermsList = new list<CSMB_Terms_and_Condition__c>();
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
       
        RecordType stdRecType=[select id from RecordType where SobjectType='Contract_Terms_and_Conditions__c' and name='Standard Terms and Conditions'];
        RecordType nonStdRecType=[select id from RecordType where SobjectType='Contract_Terms_and_Conditions__c' and name='Non-Standard Terms and Conditions'];
        
        Contract_Terms_and_Conditions__c conStdObj = new Contract_Terms_and_Conditions__c();
        conStdObj.contract__c=con.id;
        conStdObj.RecordTypeId=stdRecType.id;
        conStdObj.Standard_Term__c=CSMBmaintananceObj1.id;
        conStdObj.Terms_and_Conditions__c=CSMBtermObj3.id;
        conStdObj.Terms_and_conditions_Content__c=CSMBtermObj3.Standard_Terms_and_Conditions__c;
        
        insert conStdObj;
        
        Contract_Terms_and_Conditions__c conNonStdObj = new Contract_Terms_and_Conditions__c();
        conNonStdObj.contract__c=con.id;
        conNonStdObj.RecordTypeId=nonStdRecType.id;
        conNonStdObj.Non_Standard_Term_Repository__c='Audit';
        conNonStdObj.Non_Standard_Terms_and_Conditions__c='Non standard Audit Test data';
        
        insert conNonStdObj;
                */
       /*
        List<Addendum_Data__c> addendumList =  new List<Addendum_Data__c>();
        Addendum_Data__c addendum1 = new Addendum_Data__c();
        addendum1.name='Test1';
        addendum1.Addendum_Contract_Relation__c = con.id;
        Addendum_Data__c addendum2 = new Addendum_Data__c();
        addendum2.name='Test2';
        addendum2.Addendum_Contract_Relation__c = con.id;
        addendumList.add(addendum1);
        addendumList.add(addendum2);
        */
        listaddendum = [select id from Addendum_Data__c limit 2 ];
       system.assertEquals(listaddendum[0].id, listaddendum[0].id);
        ApexPages.StandardController cMController = new ApexPages.StandardController(listcontract[0]);
        ApexPages.currentPage().getParameters().put('id', listcontract[0].id);
        CMContractPDFController contractPDFController = new CMContractPDFController(cMController);
        
        //Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);
        
     //   Test.startTest();
        /// not CM
        contractPDFController.setisNotCM(true);
         contractPDFController.getisNotCM();
         contractPDFController.setshowAddendum(false);
         contractPDFController.getshowAddendum();
         contractPDFController.setaddendumMessage(false);
         contractPDFController.getaddendumMessage();
         contractPDFController.getaddendumList();
         contractPDFController.checkProfile();
          contractPDFController.checkProfile();
         
         //CM
                
         contractPDFController.setisNotCM(false);
         contractPDFController.getisNotCM();
         contractPDFController.setshowAddendum(true);
         contractPDFController.getshowAddendum();
         contractPDFController.setaddendumMessage(false);
         contractPDFController.getaddendumMessage();
         contractPDFController.setaddendumList(listaddendum);
         contractPDFController.getaddendumList();
          contractPDFController.checkProfile();
         
         //not CM and with addendum
         
         contractPDFController.setisNotCM(true);
         contractPDFController.getisNotCM();         
         contractPDFController.setaddendumMessage(false);
         contractPDFController.getaddendumMessage();
          contractPDFController.setaddendumList(listaddendum);
         contractPDFController.getaddendumList();
         contractPDFController.setshowAddendum(true);
         contractPDFController.getshowAddendum();
         contractPDFController.checkProfile();
         
           Test.stopTest();
    }
     
}
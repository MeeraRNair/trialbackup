/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         MenMee      21-Feb-2013     14.2                Too many SOQL queries exception. Move Test.startTest to the desired test section
2.0		    Vikas Kh					0202				Implemented TDF
*/

@istest
Private Class CMStdTermsControllerTest{
     static list<Account> listAcc;
    static list<contact> listcon;
    static list<user> listuser;
    static list<opportunity> listopp;
    static list<Support_Request__c> listSpprtReq;
    static list<Contract> listContract;
    static List<Contract_Terms_and_Conditions__c> listContractTms;
    static List<Contract_Terms_and_Conditions__c> listContractTm1;
    Static list<CSMB_Terms_and_Conditions_Maintenance__c> listCSMBTandCM;
    static list<CSMB_Terms_and_Condition__c> listTermsandCon;

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
        list<Contract> listContrTDF = TestDataFactory.createNContract(1);
        listContrTDF[0].Accounting__c=listuserTDF[0].id;
        listContrTDF[0].AccountId = listAccTDF[0].id;
        listContrTDF[0].status='Pending';
        insert listContrTDF;
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
 /*       List<Contract_Terms_and_Conditions__c> listContractTerms = TestDataFactory.createNContractTermsANdCondition(1, 'Standard Terms and Conditions');
        listContractTerms[0].contract__c=listContrTDF[0].id;
        listContractTerms[0].Standard_Term__c=listCsmBTermsMain[0].id;
        listContractTerms[0].Terms_and_Conditions__c=listcSMBTerms[2].id;
        listContractTerms[0].Terms_and_conditions_Content__c=listcSMBTerms[2].Standard_Terms_and_Conditions__c;
        insert listContractTerms;
        List<Contract_Terms_and_Conditions__c> listContractTerms1 = TestDataFactory.createNContractTermsANdCondition(1,'Non-Standard Terms and Conditions');
        listContractTerms1[0].contract__c=listContrTDF[0].id;
        insert listContractTerms1;
*/
    }  
    static testMethod void myUnitTest() {
    //Test.startTest(); 1.0
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
    
    Profile profile = new profile();
    //for(Profile userProfile:[Select id from Profile where name like '%CSMB Contract Manager' Limit 1]){
    for(Profile userProfile:[Select id from Profile where name like '%Contract Manager' Limit 1]){
       profile=userprofile;
    }
    String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev'; // Fenny added
    User user = new User(Alias = 'CM101',
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
    
    contract con = new contract();
    con.accountId=act.id;
    con.status='Pending';
    con.Accounting__c=user.id;
    
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
        //listSpprtReq[0].Status__c='New';
        insert listSpprtReq;
        //listSpprtReq[0].Status__c='Accept';
        //update listSpprtReq;
        listContract = [select id from Contract limit 1];
   		system.assertEquals(listContract[0], listContract[0]);
   // list<CSMB_Terms_and_Conditions_Maintenance__c> newCSMBTandCList = new list<CSMB_Terms_and_Conditions_Maintenance__c>();
   // List<CSMB_Terms_and_Conditions_Maintenance__c> maintananceIdList = new List<CSMB_Terms_and_Conditions_Maintenance__c>();
    boolean bshowTandC=false;
    boolean bshowStdTandC = false;
    boolean beditTerms=false;
    boolean bshowMultiPickofTandC=true;
    boolean binactiveTermsbool=false;
    string[] listtermsToAdd = new string[]{};
    string[] listtermsToRemove = new string[]{};
    string stradd1='TAudit';
    string strremove1='TDelivery';
    set<string> setTandC= new set<string>();
    set<Id> setcurSelEditstandardTerms = new set<Id>();
    set<Id> setcurSelEditTerms = new set<Id>();
    Id contractId;
    List<selectOption> listavailableTandC = new List<selectOption>();
    listavailableTandC.add(new selectoption('TAudit','TAudit'));
    List<selectOption> listselectedTandC = new List<selectOption>();
    listselectedTandC.add(new selectoption('TDelivery','TDelivery'));
    List<selectOption> listfullAvailableTandC = new List<SelectOption>();
    listfullAvailableTandC.add(new selectoption('TAudit','TAudit'));
    listfullAvailableTandC.add(new selectoption('TDelivery','TDelivery'));
    List<Contract_Terms_and_Conditions__c> listcontractTermsandConditions = new List<Contract_Terms_and_Conditions__c>();
     listCSMBTandCM = [select id from CSMB_Terms_and_Conditions_Maintenance__c limit 2 ];
     listTermsandCon = [select id,Standard_Terms_and_Conditions__c from CSMB_Terms_and_Condition__c limit 4 ];
    /*
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
    CSMBtermObj1.Standard_Terms_and_Conditions__c='Test Content';
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
    */
       list<CSMB_Terms_and_Condition__c> listnewTandCList= new list<CSMB_Terms_and_Condition__c>();
    
     //Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
    
    //Test.startTest();   //1.0        
    ApexPages.StandardController cMController = new ApexPages.StandardController(listContract[0]);
    ApexPages.currentPage().getParameters().put('id', listContract[0].id);
    ApexPages.currentPage().getParameters().put('isEditButtonClicked','true');
    ApexPages.currentPage().getParameters().put('isNewButtonClicked','false');
    CMStdTermsController cmStdTCon2 = new CMStdTermsController(cMController );
    ApexPages.currentPage().getParameters().put('isEditButtonClicked','false');
    ApexPages.currentPage().getParameters().put('isNewButtonClicked','true');    
    listContract[0].status='Approved';
    update listContract[0];
    CMStdTermsController cmStdTCon1 = new CMStdTermsController(CMController );    
    cmStdTCon1.getStatusForCon(listContract[0].id);
    cmStdTCon1.TandC=setTandC;
    cmStdTCon1.curSelEditstandardTerms=setcurSelEditstandardTerms;
    cmStdTCon1.curSelEditTerms=setcurSelEditTerms;
    cmStdTCon1.getavailableTandC();
    cmStdTCon1.setavailableTandC(listavailableTandC);
    cmStdTCon1.getselectedTandC();
    cmStdTCon1.setselectedTandC(listselectedTandC);
    cmStdTCon1.getfullAvailableTandC ();
    cmStdTCon1.setfullAvailableTandC (listfullAvailableTandC);
    cmStdTCon1.gettermstoadd();
    listtermstoAdd.add(stradd1);
    listtermsToRemove.add(strremove1);
    cmStdTCon1.settermstoadd(listtermstoAdd);
    cmStdTCon1.gettermsToRemove();
    cmStdTCon1.settermsToRemove(listtermsToRemove);
    cmStdTCon1.newCSMBTandCList=listCSMBTandCM;
    cmStdTCon1.getnewTandCList();
    cmStdTCon1.setnewTandCList(listnewTandCList);
    cmStdTCon1.getshowTandC();
    cmStdTCon1.setshowTandC(bshowTandC);
    cmStdTCon1.getshowMultiPickofTandC();
    cmStdTCon1.setshowMultiPickofTandC(bshowMultiPickofTandC);
    cmStdTCon1.getinactiveTermsbool();
    cmStdTCon1.setinactiveTermsbool(binactiveTermsbool);
    cmStdTCon1.addCurSelectedTandC();
    cmStdTCon1.removeCurSelectedTandC();
    cmStdTCon1.getTermsAndConditionInnerClassList(); 
    cmStdTCon1.getSelectedTermsandConditionsClassList();
    cmStdTCon1.getinactiveStdTerms();
    cmStdTCon1.getinactiveTerms(); 
    cmStdTCon1.confirmTerms();
    
    CMStdTermsController.TermsAndConditionInnerClass termsAndConditionInnerClassobj = new CMStdTermsController.TermsAndConditionInnerClass(listTermsandCon[0],True,false);
    list<CMStdTermsController.TermsAndConditionInnerClass> listTermsAndConditionInnerClassList = new list<CMStdTermsController.TermsAndConditionInnerClass>();
    listTermsAndConditionInnerClassList.add(TermsAndConditionInnerClassobj);
    cmStdTCon1.setTermsAndConditionInnerClassList(listTermsAndConditionInnerClassList);
    CMStdTermsController.SelectedTermsandConditionsClass selectedTermsAndConditionInnerClassobj = new CMStdTermsController.SelectedTermsandConditionsClass(listCSMBTandCM[1],listTermsAndConditionInnerClassList);
    list<CMStdTermsController.SelectedTermsandConditionsClass> listSelectedTermsAndConditionInnerList = new list<CMStdTermsController.SelectedTermsandConditionsClass>();
    listSelectedTermsAndConditionInnerList.add(selectedTermsAndConditionInnerClassobj);
    cmStdTCon1.setSelectedTermsandConditionsClassList(listSelectedTermsAndConditionInnerList);

    cmStdTCon1.saveTerms();
    Contract_Terms_and_Conditions__c conTermsObj = [select id,Standard_Term__c,Terms_and_conditions_Content__c from Contract_Terms_and_Conditions__c where contract__c=:listContract[0].id];
   // listContractTms = [select id from Contract_Terms_and_Conditions__c where RecordType.Name = 'Standard Terms and Conditions' limit 1];
//    System.AssertEquals('Test Content',conTermsObj.Terms_and_conditions_Content__c);
    
    ApexPages.currentPage().getParameters().put('id', listContract[0].id);
    ApexPages.currentPage().getParameters().put('isEditButtonClicked','true');
    ApexPages.currentPage().getParameters().put('isNewButtonClicked','false');   
    CMStdTermsController cmStdTCon = new CMStdTermsController(CMController );
    cmStdTCon.getStatusForCon(listContract[0].id);
    cmStdTCon.TandC=setTandC;
    cmStdTCon.curSelEditstandardTerms=setcurSelEditstandardTerms;
    cmStdTCon.curSelEditTerms=setcurSelEditTerms;
    cmStdTCon.getavailableTandC();
    cmStdTCon.setavailableTandC(listavailableTandC);
    cmStdTCon.getselectedTandC();
    cmStdTCon.setselectedTandC(listselectedTandC);
    cmStdTCon.getfullAvailableTandC ();
    cmStdTCon.setfullAvailableTandC (listfullAvailableTandC);
    cmStdTCon.gettermstoadd();
    cmStdTCon.settermstoadd(listtermstoadd);
    cmStdTCon.gettermsToRemove();
    cmStdTCon.settermsToRemove(listtermsToRemove);
    cmStdTCon.newCSMBTandCList=listCSMBTandCM;
    cmStdTCon.getnewTandCList();
    cmStdTCon.setnewTandCList(listnewTandCList);
    cmStdTCon.contractTermsandConditionsList=listcontractTermsandConditions;
    cmStdTCon.getshowTandC();
    cmStdTCon.setshowTandC(bshowTandC);
    cmStdTCon.getshowMultiPickofTandC();
    cmStdTCon.setshowMultiPickofTandC(bshowMultiPickofTandC);
    cmStdTCon.getinactiveTermsbool();
    cmStdTCon.setinactiveTermsbool(binactiveTermsbool);
    cmStdTCon.addCurSelectedTandC();
    cmStdTCon.removeCurSelectedTandC();
    cmStdTCon.confirmTerms();
    cmStdTCon.saveTerms();
    cmStdTCon.getshowStdTandC();
    Test.stopTest();
    }
}
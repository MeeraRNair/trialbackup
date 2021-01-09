@istest
Private Class CMNonStdTermsControllerTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'End-User Account');
        insert listAccTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(1);
        listConTdf[0].AccountId=listAccTdf[0].id;
        insert listConTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<Support_Request__c> listSupReqTdf=TestDataFactory.createNSupportRequests(1, 'Request Contracts Support');
        listSupReqTdf[0].Opportunity__c=listOppTdf[0].id;
        insert listSupReqTdf;
        
        Profile userProfile=[Select id from Profile where name like '%Contract Manager' Limit 1];
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(1);
        listUserTdf[0].ProfileId=userProfile.id;
        listUserTdf[0].LastName = 'testCM101';
        insert listUserTdf;
        list<contract> listContractTdf=TestDataFactory.createNContract(1);
        listContractTdf[0].Accounting__c=listUserTdf[0].id;
        listContractTdf[0].AccountId=listAccTdf[0].id;
        insert listContractTdf;
        List<CSMB_Terms_and_Conditions_Maintenance__c> listCSMBTCMTdf=TestDataFactory.createNCSMBTermsANdConditionMaintenance(1);
        insert listCSMBTCMTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void myUnitTest() {
        //RecordType recType=[select id from Recordtype where sobjecttype='account' and name='End-User Account'];
        /* Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
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
Test.startTest();    
Opportunity op = new Opportunity();
op.accountId=act.id;
op.name='TestOpp';
op.Type='Run Rate';
op.Solution_Type__c='Business Processing';
op.StageName='Plan - 1%';
//op.CloseDate=date.parse('12/10/2011'); // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
op.CloseDate=System.Date.TODAY(); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
TriggerExecutionController.setSkipAllTriggers(true);

insert op;
TriggerExecutionController.setSkipAllTriggers(false);

//Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request CSMB Contract Support', 'Support_Request__c', true);
Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request Contracts Support', 'Support_Request__c', true);
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
ProfileId = profile.id ,
Badge_number__c='CM101');

insert user;
*/
        test.startTest();
        Account act=[select id from Account where Recordtype.name='End-User Account' Limit 1];
        system.assertNotEquals(act.id, null);
        user user=[select id from  user where LastName = 'testCM101' Limit 1];
        Support_Request__c supReq=[select id,Opportunity__c from Support_Request__c where RecordType.name='Request Contracts Support' Limit 1];
        
        /*  Contract_Manager_Email__c contractManagerEmail = new Contract_Manager_Email__c(Senior_Manager__c=user.id,
Region__c='Americas',
Sub_Region1__c='LatinAmericas',
Business_unit1__c='CSG/Telco',
Contract_Manager1__c=user.id,
Contract_Administrator__c=user.id);

//insert contractManagerEmail;
*/
        /*contract con = new contract();
con.accountId=act.id;
con.status='Pending';
con.Accounting__c=user.id;

insert con;
*/
        contract con = [select id,accountId,status,Accounting__c from contract where accountId=:act.id Limit 1];
        
        // boolean showTandC=false;
        boolean bshowMultiPickofTandC=true;
        boolean bshowNonStdTandC=false;
        string[] listTermsToAdd = new string[]{};
            string[] listTermsToRemove = new string[]{};
                string strStradd1='TAudit';
        string strRemove1='TDelivery';
        String strIsEditButtonClicked='false';
        set<string> setTandC= new set<string>();
        Id contractId;
        List<selectOption> listavailableTandC = new List<selectOption>();
        listavailableTandC.add(new selectoption('TAudit','TAudit'));
        List<selectOption> listselectedTandC = new List<selectOption>();
        listselectedTandC.add(new selectoption('TDelivery','TDelivery'));
        List<selectOption> listfullAvailableTandC = new List<SelectOption>();
        listfullAvailableTandC.add(new selectoption('TAudit','TAudit'));
        listfullAvailableTandC.add(new selectoption('TDelivery','TDelivery'));
        
        List<Contract_Terms_and_Conditions__c> listcontractTermsandConditionsList = new List<Contract_Terms_and_Conditions__c>();
        /*list<CSMB_Terms_and_Conditions_Maintenance__c> newCSMBTandCList = new list<CSMB_Terms_and_Conditions_Maintenance__c>();

CSMB_Terms_and_Conditions_Maintenance__c CSMBmaintananceObj1= new CSMB_Terms_and_Conditions_Maintenance__c();  
CSMBmaintananceObj1.Name='TDelivery';
CSMBmaintananceObj1.status__c=True;
newCSMBTandCList.add(CSMBmaintananceObj1);

CSMB_Terms_and_Conditions_Maintenance__c CSMBmaintananceObj2= new CSMB_Terms_and_Conditions_Maintenance__c();
CSMBmaintananceObj2.Name='TAudit';
CSMBmaintananceObj2.status__c=True;
newCSMBTandCList.add(CSMBmaintananceObj2);

insert newCSMBTandCList;
*/
        list<CSMB_Terms_and_Conditions_Maintenance__c> listnewCSMBTandC=[select Name,status__c from CSMB_Terms_and_Conditions_Maintenance__c Limit 1];
        
        ApexPages.StandardController cmController = new ApexPages.StandardController(con);
        ApexPages.currentPage().getParameters().put('id', con.id);
        ApexPages.currentPage().getParameters().put('StrIsEditButtonClicked','true');
        ApexPages.currentPage().getParameters().put('isNewButtonClicked','false');  
        CMNonStdTermsController cmStdTCon2 = new CMNonStdTermsController(cmController);
        
        ApexPages.currentPage().getParameters().put('StrIsEditButtonClicked','false');
        ApexPages.currentPage().getParameters().put('isNewButtonClicked','true');
        CMNonStdTermsController cmStdTCon1 = new CMNonStdTermsController(cmController);
        cmStdTCon1.TandC=setTandC;
        cmStdTCon1.getavailableTandC();
        cmStdTCon1.setavailableTandC(listavailableTandC);
        cmStdTCon1.getselectedTandC();
        cmStdTCon1.setselectedTandC(listselectedTandC);
        cmStdTCon1.getfullAvailableTandC ();
        cmStdTCon1.setfullAvailableTandC (listfullAvailableTandC);
        cmStdTCon1.gettermstoadd();
        listTermstoAdd.add(strStradd1);
        listTermsToRemove.add(strRemove1);
        cmStdTCon1.settermstoadd(listTermstoAdd);
        cmStdTCon1.gettermsToRemove();
        cmStdTCon1.settermsToRemove(listTermsToRemove);
        cmStdTCon1.addCurSelectedTandC();
        cmStdTCon1.removeCurSelectedTandC();
        cmStdTCon1.confirmTerms();
        CMNonStdTermsController.TermsAndConditionClass termsInnerClassObj = new CMNonStdTermsController.TermsAndConditionClass(listnewCSMBTandC[0],'Testdata','section1','insert');
        List<CMNonStdTermsController.TermsAndConditionClass> listTermsandConditionsClass = new List<CMNonStdTermsController.TermsAndConditionClass>();
        listTermsandConditionsClass.add(termsInnerClassObj);
        cmStdTCon1.setTermsandConditionsClassList(listTermsandConditionsClass);
        cmStdTCon1.saveTerms();
        
        ApexPages.currentPage().getParameters().put('id', con.id);
        ApexPages.currentPage().getParameters().put('StrIsEditButtonClicked','true');
        ApexPages.currentPage().getParameters().put('isNewButtonClicked','false'); 
        
        CMNonStdTermsController cmStdTCon = new CMNonStdTermsController(cmController);
        cmStdTCon.TandC=setTandC;
        cmStdTCon.getavailableTandC();
        cmStdTCon.setavailableTandC(listavailableTandC);
        cmStdTCon.getselectedTandC();
        cmStdTCon.setselectedTandC(listselectedTandC);
        cmStdTCon.getfullAvailableTandC ();
        cmStdTCon.setfullAvailableTandC (listfullAvailableTandC);
        cmStdTCon.gettermstoadd();
        listTermstoAdd.add(strStradd1);
        listTermsToRemove.add(strRemove1);
        cmStdTCon.settermstoadd(listTermstoAdd);
        cmStdTCon.gettermsToRemove();
        cmStdTCon.settermsToRemove(listTermsToRemove);
        cmStdTCon.addCurSelectedTandC();
        cmStdTCon.removeCurSelectedTandC();
        cmStdTCon.getshowNonStdTandC();
        cmStdTCon.setshowNonStdTandC(bshowNonStdTandC);
        cmStdTCon.getshowMultiPickofTandC();
        cmStdTCon.setshowMultiPickofTandC(bshowMultiPickofTandC);
        cmStdTCon.confirmTerms();
        CMNonStdTermsController.TermsAndConditionClass termsInnerClassObj1 = new CMNonStdTermsController.TermsAndConditionClass(listnewCSMBTandC[0],'Testdata1','section1','insert');
        List<CMNonStdTermsController.TermsAndConditionClass> listTermsandConditionsClass1 = new List<CMNonStdTermsController.TermsAndConditionClass>();
        listTermsandConditionsClass1.add(termsInnerClassObj1);
        cmStdTCon1.setTermsandConditionsClassList(listTermsandConditionsClass1);
        cmStdTCon1.saveTerms();
        Test.stopTest();
    }
}
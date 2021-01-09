@IsTest
public class CSMBContractTriggerHandlerBUTest {
    public static id recordTypeID;
    public static Account account;
    public static Opportunity opportunity;
    public static Contact cont;
    public static Support_Request__c supportReq;
    public static Contract contract;
    public static User user;
    public static Set<String> setAprroverFields =new Set<String>();
    public static Map<String,String> mapOfApproverFields = new Map<String,String>();
        
    @testSetup
    static void dataSetup(){
        CSSR_Pursuit_Support__c proposalCSSR = new CSSR_Pursuit_Support__c(Name = 'Proposal', Resource_Type_Name__c = 'CSSR');
        insert proposalCSSR;
    }
    
    static testmethod void myUnitTestForBeforeInsertUpdateContract(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeUpdate' => new List<Boolean>{true, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contract", "Class_Name__c": "CSMBContractTriggerHandlerBU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);

        TriggerExecutionController.setSkipAllTriggers(true);

        Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
        account = new Account(name='TEST',recordtypeId=acRecTypeId);
        
        insert account;
        
        opportunity = new Opportunity(accountId=account.id,
                                      name='TestOpp',
                                      Type='Run Rate',
                                      Solution_Type__c='Business Processing',
                                      StageName='Plan - 1%',
                                      Forecast_Category_Override__c = 'Commit',
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
        
        //Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request CSMB Contract Support', 'Support_Request__c', true);
       // Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request Contracts Support', 'Support_Request__c', true);
       	Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);
        supportReq = new Support_Request__c(Opportunity__c= opportunity.id,
                                            // CSMB_Contract_Request_Type__c='New Contract',
                                            // Region__c='Americas',
                                            // Sub_Region__c='Latin America',
                                            //  Contact_Name__c=cont.id,
                                            Support_Status__c='Pending',
                                            RecordTypeId= srRecordTypeId,
                                            Services_Proposal_Support__c = 'Yes',
                                            Status__c='New'); // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        // Segment_Business_Unit__c='PLE');
        
        insert supportReq;
        
        Profile profile = new profile();
        for(Profile userProfile:[Select id from Profile where name like '%Contract Manager' Limit 1]){
            profile=userprofile;
        } 
        String strUserName = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev'; // Fenny added
        user = new User(Alias = 'CM101',
                        LastName = 'testCM101',
                        Email = 'x.y@ust-global.com',
                        Username = strUserName,
                        CommunityNickname = 'testCM101',
                        EmailEncodingKey = 'ISO-8859-1',
                        TimeZoneSidKey = 'America/Panama',
                        LocaleSidKey = 'en_US',
                        LanguageLocaleKey = 'en_US',
                        ProfileId = profile.Id,
                        Badge_number__c='CM101');
        insert user;

        TriggerExecutionController.setSkipAllTriggers(false);      

        contract = new Contract(accountId=account.Id,
                                Status='Pending',
                               // Completed__c=false,
                                ownerid=user.id,
                                CSMB_Support_Request__c =supportReq.id,
                              //  Add_Approver_2__c=user.id,
                                No_Approval_Required__c=true);
        
        insert contract;

        Contract c1 = [Select Id,Status From Contract Where AccountId =:account.Id AND Id=:contract.Id];
        c1.Status = 'Approved';
        c1.Add_Approver_2__c=user.id;
        c1.No_Approval_Required__c = false;
        update c1;

        Contract resCon = [SELECT Accounting__c, Dupe_Accounting__c, 
                                Credit__c, Dupe_Credit__c,
                                Finance1__c, Dupe_Finance__c,
                                Legal1__c, Dupe_Legal__c,
                                Sales_GM_VP__c, Dupe_Sales_GM_VP__c,
                                Add_Approver_1__c, Dupe_Add_Approver_1__c,
                                Add_Approver_2__c, Dupe_Add_Approver_2__c FROM Contract WHERE Id = :contract.Id];
        
        // Because Add_Approver_2__c is assigned when update, so all below fields having the Add_Approver_2__c value
        // Logic in ContractFieldPopulator and CSMBUtilClass
        System.assertEquals(user.id,resCon.Dupe_Accounting__c);
        System.assertEquals(user.id,resCon.Dupe_Credit__c);
        System.assertEquals(user.id,resCon.Dupe_Finance__c);
        System.assertEquals(user.id,resCon.Dupe_Legal__c);
        System.assertEquals(user.id,resCon.Dupe_Sales_GM_VP__c);
        System.assertEquals(user.id,resCon.Dupe_Add_Approver_1__c);
        System.assertEquals(user.id,resCon.Dupe_Add_Approver_2__c);
        
    }
}
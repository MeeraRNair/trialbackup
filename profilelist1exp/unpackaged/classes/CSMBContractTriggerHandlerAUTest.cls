@IsTest
public class CSMBContractTriggerHandlerAUTest {
    public static id recordTypeID;
    public static Account account;
    public static Opportunity opportunity;
    public static Contact cont;
    public static Support_Request__c supportReq;
    public static Contract contract;
    public static Contract contract1;
    public static Contract contract2;
    public static Contract contract3;
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
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Contract", "Class_Name__c": "CSMBContractTriggerHandlerAU"},';
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
        
        contract1 = new Contract(accountId=account.Id,
                                 Name = 'Contracttwo',
                                 Status='Pending',
                                 //  Completed__c=false,
                                 ownerid=user.id,
                                 CSMB_Support_Request__c =supportReq.id,
                                 Add_Approver_1__c=user.id,
                                 No_Approval_Required__c=false);
        
        insert contract1;
        
        TriggerExecutionController.setSkipAllTriggers(false);

        Contract c1 = [Select Id,Status From Contract Where AccountId =:account.Id AND Id=:contract1.Id];
        c1.Status = 'Approved';
        update c1;

        Support_Request__c updatedSR = [SELECT Support_Status__c FROM Support_Request__c WHERE Id = :supportReq.id];
        system.debug('### AAA - supportReq.id - ' + supportReq.id);
        system.assertEquals('Approved', updatedSR.Support_Status__c);
    }
}
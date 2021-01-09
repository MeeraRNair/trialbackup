@isTest
private class CSMBbeforeInsertUpdateContractTest{
    //public static List<Contract> contractList = new List<Contract>();    
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
    public static String contractStatus;
    public static String supportReqStatus;
    public static Set<String> aprroverFields =new Set<String>();
    public static Map<String,String> mapOfApproverFields = new Map<String,String>();


    public static void createData(){
        //Men Mee added to avoid SQOL 101 Limit exception
         TriggerExecutionController.setSkipAccountTriggers(true);
         TriggerExecutionController.setSkipContactTriggers(true);
         
        Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
         account = new Account(name='TEST',recordtypeid=acRecTypeId);
         
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
         
         //Men Mee added to avoid SQOL 101 Limit exception
         TriggerExecutionController.setSkipAccountTriggers(false);
         TriggerExecutionController.setSkipContactTriggers(false);
         
         //Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request CSMB Contract Support', 'Support_Request__c', true);
         Id srRecordTypeID=IdLookupUtils.getRecordTypeId('Request Contracts Support', 'Support_Request__c', true);
         supportReq = new Support_Request__c(Opportunity__c= opportunity.id,
             CSMB_Contract_Request_Type__c='New Contract',
             Region__c='Americas',
             Sub_Region__c='Latin America',
             Contact_Name__c=cont.id,
             Support_Status__c='Pending',
             RecordTypeId= srRecordTypeId,
             Status__c='New',  // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
             Segment_Business_Unit__c='PLE');
        
          insert supportReq;
          
          Profile profile = new profile();
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
                  ProfileId = profile.Id,
                  Badge_number__c='CM101');
            insert user;
            
            contract = new Contract(accountId=account.Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=user.id,
                  CSMB_Support_Request__c =supportReq.id,
                  Add_Approver_2__c=user.id,
                  No_Approval_Required__c=false);
          
          insert contract;
          
          contract1 = new Contract(accountId=account.Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=user.id,
                  CSMB_Support_Request__c =supportReq.id,
                  Add_Approver_1__c=user.id,
                  No_Approval_Required__c=false);
          
          insert contract1;
          
          contract1.Add_Approver_1__c = null;
          contract1.Accounting__c= user.id;
          
          update contract1;
          contract2 = new Contract(accountId=account.Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=user.id,
                  CSMB_Support_Request__c =supportReq.id,
                  Accounting__c=user.id,
                  No_Approval_Required__c=false);
                  
          insert contract2;
          
          contract3 = new Contract(accountId=account.Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=user.id,
                  CSMB_Support_Request__c =supportReq.id,
                  Credit__c=user.id,
                  No_Approval_Required__c=false);
                  
          insert contract3;
            mapOfApproverFields.put('Accounting__c','Dupe_Accounting__c');
            mapOfApproverFields.put('Credit__c','Dupe_Credit__c');
            mapOfApproverFields.put('Finance1__c','Dupe_Finance__c');
            mapOfApproverFields.put('Legal1__c','Dupe_Legal__c');
            mapOfApproverFields.put('Sales_GM_VP__c','Dupe_Sales_GM_VP__c');
            mapOfApproverFields.put('Add_Approver_1__c','Dupe_Add_Approver_1__c');
            mapOfApproverFields.put('Add_Approver_2__c','Dupe_Add_Approver_2__c');
        
            aprroverFields = mapOfApproverFields.keySet();
          }
          static testMethod void myUnitTestForBeforeInsertUpdateContract(){
        
            Test.startTest();
                createData();
                //id dummyID = CSMBUtilClass.getDummyId(contract1,aprroverFields);
                contract resCon = [select name,Dupe_Accounting__c,Dupe_Add_Approver_1__c,Dupe_Add_Approver_2__c,Dupe_Credit__c,Dupe_Finance__c,Dupe_Legal__c,Dupe_Sales_GM_VP__c,Add_Approver_2__c from Contract where id=:contract.id];
                
                System.assertEquals(resCon.Dupe_Accounting__c,resCon.Add_Approver_2__c);
                System.assertEquals(resCon.Dupe_Credit__c,resCon.Add_Approver_2__c);
                System.assertEquals(resCon.Dupe_Finance__c,resCon.Add_Approver_2__c);
                System.assertEquals(resCon.Dupe_Legal__c,resCon.Add_Approver_2__c);
            Test.stopTest();
         }
}
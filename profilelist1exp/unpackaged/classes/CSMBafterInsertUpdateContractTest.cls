@isTest
private class CSMBafterInsertUpdateContractTest{
    public static List<Contract> contractList = new List<Contract>();    
    public static id recordTypeID;
    public static Account account;
    public static Opportunity opportunity;
    public static Contact cont;
    public static Support_Request__c supportReq;
    public static Contract contract,contract1;
    public static User user;
    public static String contractStatus;
    public static String supportReqStatus;


    public static void createData(){
         Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
         
         //Men Mee added to avoid SQOL 101 Limit exception
         TriggerExecutionController.setSkipAccountTriggers(true);
         TriggerExecutionController.setSkipContactTriggers(true);
                  
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
             Segment_Business_Unit__c='PLE',
             Status__c='New',  // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
             RecordTypeId= srRecordTypeId);
        
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
                  ProfileId = profile.id,
                  Badge_number__c='CM101');
            insert user;
            
          contract = new Contract(accountId=account.Id,
                  Status='Pending',
                  Completed__c=false,
                  ownerid=user.id,
                  CSMB_Support_Request__c =supportReq.id,
                  No_Approval_Required__c=true);          
                 
          insert contract;

                
        /*LIST<RecordType>  recordTypeList = [SELECT id FROM RecordType where name =:'Request CSMB Support'];         
        if(recordTypeList.size()>0){            
                for(RecordType recordType : recordTypeList){                
                recordTypeID = recordType.id;                                
            }            
        }*/

    }
    static testMethod void myUnitTestForRejected() {
        createData();
        
        Test.startTest();

        contract.status = 'Rejected';
        update contract;
          
        contractList.add(contract);
                    
        For(Contract contractObj : contractList){                 
            if(contractObj.status == 'Rejected'){                     
                Support_Request__c supportReqObj = [select name,Support_Status__c from Support_Request__c where id=:contractObj.CSMB_Support_Request__c];                     
                //supportReqObj.Support_Status__c = contractObj.status;                     
                //update supportReqObj; 
                contractStatus =contractObj.status;
                supportReqStatus =  supportReqObj.Support_Status__c;                                                                     
            }           
        }
        Test.stopTest();
        System.assertEquals(contractStatus, supportReqStatus);
    }
    
    static testMethod void myUnitTestForApproved() {
        createData();
        
        Test.startTest();

        contract.status = 'Approved';
        update contract;
          
        contractList.add(contract);
                    
        For(Contract contractObj : contractList){                 
            if(contractObj.status == 'Approved'){                     
                Support_Request__c supportReqObj = [select name,Support_Status__c from Support_Request__c where id=:contractObj.CSMB_Support_Request__c];                     
                //supportReqObj.Support_Status__c = contractObj.status;                     
                //update supportReqObj; 
                contractStatus =contractObj.status;
                supportReqStatus =  supportReqObj.Support_Status__c;                                                                     
            }           
        }
        Test.stopTest();
        System.assertEquals(contractStatus, supportReqStatus);
    }
    static testMethod void myUnitTestForCompleted() {
        createData();
        
        Test.startTest();

        contract.status = 'Completed';
        update contract;
          
        contractList.add(contract);
                    
        For(Contract contractObj : contractList){                 
            if(contractObj.status == 'Completed'){                     
                Support_Request__c supportReqObj = [select name,Support_Status__c from Support_Request__c where id=:contractObj.CSMB_Support_Request__c];                     
                //supportReqObj.Support_Status__c = contractObj.status;                     
                //update supportReqObj; 
                contractStatus =contractObj.status;
                supportReqStatus =  supportReqObj.Support_Status__c;                                                                     
            }           
        }
        
        System.assertEquals(contractStatus, supportReqStatus);
        Test.stopTest();
    }
    static testMethod void myUnitTestForCancelled() {
        createData();
        
        Test.startTest();

        contract.status = 'Cancelled';
        update contract;
          
        contractList.add(contract);
                    
        For(Contract contractObj : contractList){                 
            if(contractObj.status == 'Cancelled'){                     
                Support_Request__c supportReqObj = [select name,Support_Status__c from Support_Request__c where id=:contractObj.CSMB_Support_Request__c];                     
                //supportReqObj.Support_Status__c = contractObj.status;                     
                //update supportReqObj; 
                contractStatus =contractObj.status;
                supportReqStatus =  supportReqObj.Support_Status__c;                                                                     
            }           
        }       
        //System.assertEquals(contractStatus, supportReqStatus);
         Test.stopTest();
    }
    
    ///// new code for more than one contracts for one SR
   /* static testMethod void myUnitTestForMultipleContracts() {
         Test.startTest(); 
             createData();         
             contract1 = new Contract(accountId=account.Id,
                      Status='Pending',
                      Completed__c=false,
                      ownerid=user.id,
                      CSMB_Support_Request__c =supportReq.id,
                      No_Approval_Required__c=false,
                      Add_Approver_1__c=user.id);
              
              insert contract1;
              
              contract1.status = 'Approved';
              update contract1;
              contractList.add(contract1);
              
              
              contract.status = 'Finalized';
              update contract;          
              contractList.add(contract);
              
              //update contractList;
                             
              Contract latestConObj = contractList[0];
              for(integer i=0;i<contractList.size()-1;i++){    
                   if(ContractList[i+1].CreatedDate > latestConObj.CreatedDate ){
                        latestConObj = ContractList[i+1];
                        System.debug('*******************latestConObj *********************'+latestConObj);
                   }
              }
              Support_Request__c supportReqObj = [select name,Support_Status__c from Support_Request__c where id=:latestConObj.CSMB_Support_Request__c];
              System.assertEquals(latestConObj.status, supportReqObj.Support_Status__c);
          Test.stopTest();   
    }
    */    
}
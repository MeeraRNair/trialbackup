/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@IsTest
private class VFCntrlr_CertiTrackerDecertifyTest {  
    static list<Account> listAcc;
    @testsetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
       listAccTDF[0].Status__c = 'Active';
        listAccTDF[0].Partner_Relationship__c = 'Preferred';
        insert listAccTDF;        
    }
    public static testmethod void testDecertify(){
    Test.startTest();
    CertificationTracker_UpdateSuggestion.isTestExecution = true; 
    List<String> listLeadID = new List<String>();    
        //Create partner Account
  /*      Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active',Partner_Relationship__c = 'Preferred');
                      
        insert acc;       
               */
        listAcc = [select id from Account limit 1];
        Certification_Tracker__c certTracker = new Certification_Tracker__c();               
        certTracker.Account_name__c = listAcc[0].id;     
                  
        insert certTracker;
                        
        PageReference pageRef = Page.DeCertifyPopUp;
        pageRef.getParameters().put('id',certTracker.id);
        pageRef.getParameters().put('Acct',listAcc[0].id);
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(certTracker);
        VFCntrlr_CertiTrackerDecertify  decertify = new VFCntrlr_CertiTrackerDecertify(sc);    
        VFCntrlr_CertiTrackerDecertify  decertify1 = new VFCntrlr_CertiTrackerDecertify();    

        //VFCntrlr_CertiTrackerDecertify decertify = new VFCntrlr_CertiTrackerDecertify();
        decertify.confirm();
        decertify.closePopup();
        decertify.confirmPopup();
        
        listAcc[0].Partner_Relationship__c = 'Premier';
        update listAcc[0];
         decertify.confirmPopup();
         for(Lead leadresult : [SELECT ID,Account__c FROM Lead WHERE Account__c =: listAcc[0].id]){           
            listLeadID.add(leadresult.Id);
            AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
           // response.OracleError = '';
          //  response.ErrorDescription = '';
          //  response.IsAccountDuplicate=true;           
           // response.ID = '375836';            
            CertificationTracker_UpdateSuggestion.result = response;
            //call future method
            CertificationTracker_UpdateSuggestion.TrackerUpdateSuggestion(listLeadID);
            System.debug('###Result: '+ leadresult);
            //check whether the Lead ID field is not null
            System.assertNotEquals(leadresult.ID,null);  
            System.debug('@@@@@@@ Lead: '+ leadResult);
        }
    Test.stopTest();
     }    
}
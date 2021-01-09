@isTest
private class SpecialistSearchTest
{
    private static testMethod void testSpecialistSearch(){
        String AccountName;
        SpecialistSearchCtrl controller = new SpecialistSearchCtrl();
        
        Account accountObj;
        Id accRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true); 
        accountObj = new Account(name='Test', RecordtypeId = accRTId);
        insert accountObj; 

        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
        Opportunity opp1=new Opportunity (name='test opp', 
                                   accountID=accountObj.Id,
                                   Domain__c='Cross/Non Domain',
                                   Type = 'Extension',
                                   Solution_Type__c = 'Cloud Integration',
                                   Solution_Name__c = 'Boomi Solution',
                                   CurrencyIsoCode = 'USD',
                                   StageName='Plan - 1%',
                                   CloseDate=System.Today()
                                   );
        insert opp1;
    
    List<profile> ShareProfiles; 
    
      ShareProfiles = [select id,name from Profile where name like '%GBL Channel Marketing%' order by CreatedDate DESC limit 1];
        
       user usr = new User(
                    Username='mkttest@dll.com',
                    Alias = 'test1', 
                    Email='test3445@dell.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId = ShareProfiles[0].Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='UATUser', 
                    isActive = TRUE
                    );
        insert usr;             
      
       
        Sales_Connect_User__c sc = new Sales_Connect_User__c(Name = 'TestSc',
                                                            CurrencyIsoCode = 'USD',
                                                            Badge_ID__c = '7868768df43434',
                                                            IsSpecialistActive__c = true,
                                                            User__c = usr.ID
                                                                                                                
                                                            //IsUserActive__c = true
                                                            );
                                                            
        insert sc;
        
        Account acc = New Account();
       
        If(opp1.id != Null)
        {
 
      //  AccountName=[select account.Name from Opportunity where id=:opp1.Id limit 1].account.name;
           AccountName=[select Name from Account where id=:opp1.accountID limit 1].NAME;

        System.debug('**myAccountName'+AccountName);
        }
        List <Sales_Connect_User__c> scUser = controller.getSpecialist();
        String Conditions = controller.getConditions();
        String OppId = controller.getOppId();
        System.AssertEquals(null ,OppId); 
        String OppName = controller.getOppName();
        PageReference display = controller.Display();
        PageReference gotoOpp = controller.gotoOpportunity();
       // PageReference gotoSR = controller.gotoSpecialistRequest();
        String gotoSR = controller.getSupportRequestURL();
        PageReference previous = controller.Previous();
        PageReference next = controller.Next();
      //  Boolean disablePrevious = controller.getDisablePrevious();
      //  Boolean disableNext = controller.getDisableNext();
        String pageNumber = controller.getPageNumber();
        String recordNumber = controller.getRecordNumber();
        string TempAccountName='name';
            }
}
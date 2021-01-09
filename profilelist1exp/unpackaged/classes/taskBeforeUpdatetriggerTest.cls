/**
 * Test for taskBeforeUpdatetrigger
 */
@isTest
private class taskBeforeUpdatetriggerTest{

    static testMethod void taskBeforeUpdatetrigger() {
            Profile prof = new Profile();
            Profile profile = [select id from profile where name = 'System Administrator' limit 1];
            User user = new User(
                                Username='test' + System.currentTimeMillis() + '@test.com',
                                Alias = 'test1', 
                                Email='test@dell.com', 
                                FirstName='John', 
                                LastName='Doe', 
                                Title = 'GCC Program Manager',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test'+System.currentTimeMillis()
                               );           
            insert user;         
            Account acc = new Account();
                acc.OwnerId =user.Id; 
                acc.Name = 'Sak Test01';
            insert acc;       
            string recTypeId=IdLookupUtils.getRecordTypeId('LOB Registration Task', 'Task', true);  
            task newTask = new task();
                                    newTask.ownerID=acc.ownerID;
                                    newTask.subject='LOB TO Be Approved';
                                    newTask.RecordtypeID=recTypeId;
                                    newTask.ActivityDate=system.today();
                                    insert newTask;
    }

    static testMethod void lobAfterUpdateTrigger() {
            Profile prof = new Profile();
            Profile profile = [select id from profile where name = 'System Administrator' limit 1];
            User user = new User(
                                        Username='test' + System.currentTimeMillis() + '@test.com',
                                        Alias = 'test1', 
                                        Email='test@dell.com', 
                                        FirstName='John', 
                                        LastName='Doe', 
                                        Title = 'GCC Program Manager',
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis()
                                       );
            insert user;
            string recTypeId=IdLookupUtils.getRecordTypeId('Partner Account','Account',true); 
          system.runAs(user){
            Account acc = new Account();
                acc.OwnerId =user.Id; 
                acc.Name = 'Sak Test01';
                acc.Is_GTM_Partner__c=true;
                acc.recordtypeID=recTypeId;
            insert acc;

            Account acc1 = new Account();
                acc1.OwnerId =user.Id; 
                acc1.Name = 'Sak Test01';
                acc1.Type='End user';
                acc1.Participating_in_LOB_Program__c=true;
            insert acc1;
            AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Account Executive',AccountId = acc1.Id,UserId = user.id);
        insert atbr;

            LOB_Registration__c lobreg = new LOB_Registration__c();                                  
                                   lobreg.LOB_registration_status__c ='Partner(submit for approval)';  
                                  // lobreg.LOB_registration_status__c ='Open';                    
                                   lobreg.Registered_End_User__c = acc1.Id;
                                   lobreg.Preferred_GTM_Partner_Account__c=acc.Id;     
             insert lobreg;
             update lobreg;
          }
     
    }

}
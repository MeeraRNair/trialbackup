@isTest

private class beforeInsertUpdateMDFApproverTest{
 
    static testMethod void TestbeforeInsertUpdateMDFApprover() {
        //final List<Profile> testprofile = [select id,name from Profile where name IN ('MDF Co-Marketing Manager', 'MDF Marketing Operations / Contract Admin')];

                                               
List <Profile> p = [SELECT Id FROM Profile WHERE name IN ('MDF Co-Marketing Manager', 'MDF Marketing Operations / Contract Admin')]; 
 User u = new User(Alias = 'standt', Email='testuser@dellteam.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p[0].Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuser@dellteam.com');
insert u; 

           System.runAs(u){
            MDF_Approver__c MA = new MDF_Approver__c();
            
            MA.Region__c = 'APJ';
            MA.Sub_Region__c = 'APJ';
            MA.Country__c = 'All Countries';
            MA.Business_Segment__c = 'Consumer';
            MA.Program_Type__c = 'Event';
            MA.Program_Approver__c = u.id;
            MA.POP_Approver__c = u.id;
            
            insert MA;
            }
        }
  //insert
  //Create a record2
  //insert
  }
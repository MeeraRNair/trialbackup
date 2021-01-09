@isTest(seeAlldata=true)
public class AccountEmailUtilitiesTest{
    
     private static testMethod void TestMethodOne() {
     List<Certification_Process_Setup__c> newsetup = new list<Certification_Process_Setup__c>();
       List<Certification_Process_Setup__c> AllSetps = [select id,name,Send_Email_to_Partner_Admin__c  from Certification_Process_Setup__c];
      Id partnerRTId = System.Label.RecType_Partner_Account; 
      
     Map<ID, Account> mapAccounts = new Map<ID, Account>([SELECT Id,
                                                                 Name,
                                                                 Partner_Relationship__c,
                                                                 RecordTypeId,
                                                                 IsPartner,
                                                                 Account_Country_Code__c  FROM Account
                                                                 where IsPartner=true and ( Partner_Relationship__c ='Preferred' OR Partner_Relationship__c ='Premier' )
                                                                 And RecordTypeId =: partnerRTId LIMIT 6]);
                                                                 
          List<String> regions = new list<String>();
                      regions.add('APJ');
                      regions.add('Canada');
                      regions.add('EC-EMEA');
                      regions.add('EMEA');
                      regions.add('LATAM');
                      regions.add('US');
                      Integer i = 0;                                           
                                                                 
                             
     for(id eachid : mapAccounts.keyset()){
             
          Certification_Process_Setup__c eachsetup = new Certification_Process_Setup__c();
          eachsetup = AllSetps [i];
             eachsetup.Region__c =regions[i];
             eachsetup.Send_Email_to_Partner_Admin__c = true;
             eachsetup.name = regions[i];
             eachsetup.Certification_Admin_Mailbox__c = 'test@test.com';
             newsetup.add(eachsetup);
             
             i++;
             }                       
             
             upsert newsetup;          
                                                                 
     
     AccountEmailUtilities.sendEmailToPartnerAdminUsers(mapAccounts ,mapAccounts, mapAccounts );
     
     
     }

}
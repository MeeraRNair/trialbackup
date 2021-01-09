@isTest(seeAlldata=true)
private class vfctrl_DellAcceptTermsTest {
   public static testMethod void method1() {
   
    //Master Account Insertion
        Account a1=new Account();
        a1.Name='MG1212';
        a1.Master_Group_Affinity_ID__c='1212';
        TriggerExecutionController.setSkipAllTriggers(true);
        insert a1;

        
    //Partner Track Insertion        
        Partner_Track__c p = new Partner_Track__c();
        p.partner_Track_affinityId__c = '1212';
        p.Primary_Sales_Motion_Affinity_ID__c='1212';
        TriggerExecutionController.setSkipAllTriggers(true);
        insert p; 
             
      //Contact Insertion
        Contact con = new Contact();
        con.AccountId = a1.Id;
        con.FirstName = 'test';
        con.LastName = 'user';
        con.Email = 'testuser@gmail.com';
        con.Phone = '973949364986';
        con.Status__c = 'Prospect';
        con.Job_Function__c = 'OTHER';
        con.Job_Function_Role__c = 'Others';
        con.Decision_Making_Role__c = 'Influencer';
        con.Selected_Track__c = p.id; 
        insert con;
        
        //User Insertion
        List<Profile> listPartnerProfiles = [select id,name from Profile where UserType =: 'PowerPartner' limit 2];
        User partnerUser = new user();
        partnerUser.Username='testing1160789@DELLTEAM.com';
        partnerUser.Alias = 'test'; 
        partnerUser.Email='test1160789@DELLTEAM.com';
        partnerUser.FirstName='Jhon'; 
        partnerUser.LastName='Test1160789';
        partnerUser.ProfileId = listPartnerProfiles[1].Id; 
        partnerUser.LanguageLocaleKey='en_US';
        partnerUser.LocaleSidKey='en_US'; 
        partnerUser.EmailEncodingKey='ISO-8859-1';
        partnerUser.TimeZoneSidKey='America/New_York';
        partnerUser.Badge_Number__c='984647YTDGC';
        partnerUser.ContactId = con.id;
        partnerUser.Enable_Partner_Admin__c = true;
        partnerUser.Enable_as_Partner_Group_Administrator__c = true;
        partnerUser.isActive = TRUE;
        insert partnerUser;       

            
      System.runAs(partnerUser) {
      vfctrl_DellAcceptTerms vc = new vfctrl_DellAcceptTerms();
      vfctrl_DellAcceptTerms.newAcceptTerms(String.ValueOf(con.id));   
      }
   }
}
@isTest
public class ViewDealAccessTestcls {
  static testMethod void showpiedata() {
     /* *** */
      TriggerExecutionController.setSkipUserTriggers(true);
         TriggerExecutionController.setSkipAccountTriggers(true);
         TriggerExecutionController.setSkipContactTriggers(true);
     /* ****** */
      
       account acc = new account();
      acc.name = 'testacc';
      acc.Account_ID__c = '121221';
      insert acc;
      
      contact cc = new contact();
      cc.LastName = 'testcontact1';
      cc.accountid = acc.id;
      cc.Email='test@test.com';
       insert cc;
      
      List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listuser = new List<User>();
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'bilo'+intuserNumber+'_mishra'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber)+string.valueof(Math.abs(Crypto.getRandomInteger()));
        User newUser1 = new User(profileId = listp[1].id,username = strnewusername,email = 'pb@ff.com',Badge_Number__c=null, PortalRole = 'Manager',
                                emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',
                                lastname='lastname user utils',contactId = cc.id,
                                Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Admin__c =true);
        listuser.add(newUser1);
         insert listuser;
 
     list<Opportunity> listoppList = new list<Opportunity>();
      system.runAs(listuser[0]){
           
       opportunity opportunityObject  = new opportunity();
            list<opportunity> listopportunityList = new list<Opportunity>();
               for(integer inti=0;inti<2;inti++){
                        opportunityObject=new Opportunity(
                            name='test opportunity',
                            stagename='Plan - 1%',
                            closedate=System.Today().addDays(5),
                            Solution_Type__c='IT Simplification',
                            Solution_Name__c='Systems Management',
                            Type='Deal/Bid-Direct',
                            Primary_Product_Delivery_Address_Region__c='NORTH AMERICA',
                            Primary_Product_Delivery_Address_Country__c='UNITED STATES',
                            //Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                            accountid=acc.id,
                            RecordTypeId=GlobalVariables.STANDARD_OPP_RECTYPE,
                            CurrencyIsoCode='USD',
                           // OwnerId=userList[0].id,
                            OS_Type__c='Solaris',
                           
                            Won_Lost_Comment__c='ggg',
                            Reason_Won_Lost__c='Incumbent',
                            Materials_Used_to_Help_Close_Deal__c='Case Study',
                            Customer_Willing_To__c='Complete a case Study',
                            Deal_Created_Date_Time__c=System.now(),
                            Total_Expected_Dell_Revenue__c=1236,
                            Justification_Statement__c='ddd',
                            End_User_Account_Name__c=cc.name,
                            End_User_Account_Department__c='dasjdfhd',
                            Total_of_End_of_User_Employees__c='100-199',
                            End_User_Mailing_City__c='dsffddf',
                            End_User_Mailing_Country__c='dsffddf',
                            Deal_Registration_Status__c='Approved',
                            End_User_First_Name__c='dsffddf',
                            End_User_Last_Name__c='dsffddf',
                            End_User_Phone__c='2222',
                            Solution_Scope__c='Hardware and support only',
                            Competitor_Lost_To__c='ddd'
                        ) ;
        
                        listopportunityList.add(opportunityObject);
                    }
                    system.assertEquals(opportunityObject.Deal_Created_Date_Time__c, System.now());
                    Test.startTest();
                     
                    Database.SaveResult[] listopptyInsertresults=Database.insert(listopportunityList, false);
      } 
      
      ContactOpportunityStages__c co = new ContactOpportunityStages__c();
        co.SalesmotionAccount__c = acc.id;
        co.Opportunity_Stage__c = 'Plan - 1%';
        co.contact__c = cc.id;
       insert co;
      
      list<ContactOpportunityStages__c> listconopplist = [select id,SalesmotionAccount__c,contact__c,Opportunity_Stage__c
                                                       from ContactOpportunityStages__c where id=:co.id and contact__c =: cc.id ];
      
     
      
      //Test.startTest();
     
      
      Apexpages.StandardController sc = new Apexpages.StandardController(cc);
      viewDealAccesscls vdc = new viewDealAccesscls(sc);
      try{vdc.showOppStages();}catch(exception e){}
      try{vdc.straccountname = acc.id;
         // vdc.stgs = opp.StageName;
          vdc.showOppStages();}catch(exception e){}
      try{vdc.getPieData();}catch(exception e){}
      try{vdc.getAccountList();}catch(exception e){}
      
      Test.stopTest();
      //PieWedgeData pwd = new PieWedgeData();
     
      
  }
}
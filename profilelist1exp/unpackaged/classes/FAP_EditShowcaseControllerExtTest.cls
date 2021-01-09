/* 

History:
Version Date            Modified By                 Description     
--------------------------------------------------------------------------------------
1.0     28-Feb-2019     On behalf Masam, Shravan    FAP FY20_0202
*/


@IsTest
private class FAP_EditShowcaseControllerExtTest {
 private static testmethod void executeShowcaseEdit()
 {
        Account acct = new Account();
        acct.Name='Test Account 123 ABC';        
        insert acct;
        
        Partner_Track__c pt=new Partner_Track__c();
        pt.Approved_for_Partner_Finder__c=true;
        pt.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        pt.User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        pt.Partner_Program_Tier__c='Gold';
        insert pt;
        pt.Partner_Account__c = true;       
        update pt;
        
        Partner_Location__c loc = new Partner_Location__c();              
        loc.Name = ' Test Location ';
        loc.Latitude__c =  random(-90, 90);
        loc.Longitude__c =  random(-180,180);
        loc.Partner_Track__c = pt.Id;
        loc.Point_of_Contact_Email__c = 'tloc'+  '1' +'@testlocation.com';  
        insert loc;
                        
       Contact c = New Contact(LastName = 'Test', accountid = acct.id ,Selected_track__c = pt.id,Phone='78930927834');
       insert c;
        
        User newUser = createPartnerUser(c.id);  
        /*Contact c1 = New Contact(LastName = 'Test123', Selected_track__c = pt.id,Phone='78930924734',Partner_User__c=newUser.Id);
        test.startTest();
        insert c1;
        test.stopTest();
        acct.IsPartner = true;
        update acct; */
        system.runAs(newUser){
        PageReference pageRef = Page.FAP_PartnerDetails;
        pageRef.getParameters().put('id', pt.id);
        Test.setCurrentPage(pageRef);
          
         Partner_Showcase__c partnershowcase = new Partner_Showcase__c(Short_Description__c='Test Test',Long_Description__c='<img>long desc</img>',Partner_Track__c=pt.id);
         insert partnershowcase;

         /*partnershowcase.Partner_Track__c=pt.id;
         update partnershowcase;*/
         ApexPages.StandardController sc = new ApexPages.standardController(partnershowcase);
         FAP_EditShowcaseControllerExt showcasecontroller = new FAP_EditShowcaseControllerExt(sc);     
         showcasecontroller.doOnLoad();
         showcasecontroller.saveDetail();
         string errorcode='errorcode';
         showcasecontroller.getMessages();
         showcasecontroller.doCancel();
         FAP_EditShowcaseControllerExt.getPartnerAccountID();
         //system.assertnotEquals(showcasecontroller.ERROR_NO_ACCOUNT_ID,'ERROR_NO_ACCOUNT_ID1');
         system.assertnotEquals(showcasecontroller.errorOccurred,true);
         system.assertnotEquals(showcasecontroller.errorCode,'true');
         system.assertnotEquals(showcasecontroller.isIE,true);
         system.assertnotEquals(showcasecontroller.isFirefox,true);
         system.assertnotEquals(showcasecontroller.isChrome,true);
        }
     }
  /*  private static testmethod void executeShowcaseShowCaseIDNull()
    {
        Account acct = new Account();
        acct.Name='Test Account 123 ABC';
        acct.Profile_Published_to_Partner_Finder__c='Yes';
        acct.Approved_for_Partner_Finder__c=true;
        acct.Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        acct.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        
        insert acct;
        Partner_Track__c pt=new Partner_Track__c();
        pt.Approved_for_Partner_Finder__c=true;
        pt.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        pt.User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        pt.Partner_Program_Tier__c='Gold';
        insert pt;
        pt.Partner_Account__c = true;       
        update pt;
        
        Partner_Location__c loc = new Partner_Location__c();              
        loc.Name = ' Test Location ';
        loc.Latitude__c =  random(-90, 90);
        loc.Longitude__c =  random(-180,180);
        loc.Partner_Track__c = pt.Id;
        loc.Point_of_Contact_Email__c = 'tloc'+  '1' +'@testlocation.com';  
        insert loc;
                
        acct.Partner_Track__c = pt.id;
        update acct;
        Contact c = New Contact(LastName = 'Test', AccountID = acct.id,Phone='78930927834');
        insert c;
        User newUser = createPartnerUser(c.id);    
        Contact c1 = New Contact(LastName = 'Test123', AccountID = acct.id,Phone='78930924734',Partner_User__c=newUser.Id);
        test.startTest();
        insert c1;
        test.stopTest();
        acct.IsPartner = true;
        update acct;
     
        
        PageReference pageRef = Page.FAP_PartnerDetails;
        pageRef.getParameters().put('id', acct.Id);
        Test.setCurrentPage(pageRef);

         Partner_Showcase__c partnershowcase = new Partner_Showcase__c(Short_Description__c='Test Test',Long_Description__c='<img>long desc</img>');
         partnershowcase.Partner_Track__c=pt.id;
         ApexPages.StandardController sc = new ApexPages.standardController(partnershowcase);
         FAP_EditShowcaseControllerExt showcasecontroller = new FAP_EditShowcaseControllerExt(sc);     

         showcasecontroller.doOnLoad();
         FAP_PageUtils.dateOfProfileUpdate(pt.id);
         showcasecontroller.saveDetail();

         system.assertnotEquals(showcasecontroller.ERROR_NO_ACCOUNT_ID,'ERROR_NO_ACCOUNT_ID1');
        
     }  */     
    private static testmethod void executeShowcaseEditPartnerAccountID()
    {

      Partner_Track__c pt=new Partner_Track__c();
        pt.Approved_for_Partner_Finder__c=true;
        pt.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        pt.User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        pt.Partner_Program_Tier__c='Gold';
        insert pt;
        pt.Partner_Account__c = true;       
        update pt;
         Partner_Showcase__c partnershowcase = new Partner_Showcase__c(Short_Description__c='Test Test',Long_Description__c='<img>long desc</img>');
         partnershowcase.Partner_Track__c=pt.id;
         ApexPages.StandardController sc = new ApexPages.standardController(partnershowcase);
         FAP_EditShowcaseControllerExt showcasecontroller = new FAP_EditShowcaseControllerExt(sc);     
         showcasecontroller.doOnLoad();
         showcasecontroller.saveDetail();
         //system.assertnotEquals(showcasecontroller.ERROR_NO_ACCOUNT_ID,'ERROR_NO_ACCOUNT_ID1');
        
     }    
    
    
    
    private static Double random(Double min, Double max){
      return min + (Math.random() * (max - min));
    }        
    private static List<Account> createTestAccount(Integer count){
        List<Account> records = new List<Account>();
        for(Integer i = 0; i < count; i++){
            records.add(new Account(name='test'+i));
        }
        return records;
    }
    private static user createPartnerUser(ID cId){
    Profile p = [Select ID, Name from Profile Where Name = 'R16.10 APJ PRM Portal User (MOSS)'];  
        user u = New User(
            UserName = 'test_' + math.random() + '@test.com',
            FirstName = 'Test-First',
            LastName = 'Test-Last',
            Alias = 'test',
            email = 'test' + math.random() + '@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = p.id,
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = cId,
            Badge_Number__c ='46568'
            
        );

    insert u;
        return u;
    }       
}
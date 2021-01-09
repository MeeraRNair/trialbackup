/********************************** ********************************** ********************************** 
 Written By : Sai Prasanth.
 Purpose: To code coverage for DealRegUtils Apex class.
 Description :  DealRegUtilsTestMethod1() is used to cover the if statements justifications in apex class. 
                DealRegUtilsTestMethod2() is used to cover the else statements justifications in apex class. 
 
 ********************************** ********************************** **********************************/ 


@isTest
private class DealRegUtilsTest
{

  /**********************************  This method used for IF statemetns in the controller class. ********************/
 
 Static testmethod void DealRegUtilsTestMethod1()
 {
 GCUserProfiles__c gcuser = new GCUserProfiles__c();
 gcuser.Name = UserInfo.getProfileId();
 insert gcuser;
 
 //calling isGCCountry() method.
   DealRegUtils.isGCCountry();
   
   
   
   
   
   //calling isOwnerIdhasGcProfile() method.
   DealRegUtils.isOwnerIdhasGcProfile(UserInfo.getUserid());
   
   
   
   set<id> ownersSet = new set<id>();
   ownersSet.add(UserInfo.getUserId());
   
  //calling isOwnerHasGCProfile  method.
    DealRegUtils.isOwnerHasGCProfile(ownersSet);
    
    
    CountryNotApplicableToNonGC__c countryCS = new CountryNotApplicableToNonGC__c();
    countryCS.Name ='CHINNA';
    insert countryCS;
    
    //calling isGCDeal method.
    DealRegUtils.isGCDeal('CHINA');
    

 }
 
 
   /**********************************  This method used for Else statemetns in the controller class. ********************/

 Static testmethod void DealRegUtilsTestMethod2()
 {
 
User userRaja = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000Tesingop190@dell.com',
     Username = 'puser000Tesingop190@dell.com',
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     Badge_Number__c ='9101999101'
     );
 
 System.runAs(userRaja) {

 GCUserProfiles__c gcuser = new GCUserProfiles__c();
 gcuser.Name = userRaja.id;
 insert gcuser;
 
 //calling isGCCountry() method.
   DealRegUtils.isGCCountry();
   
   
   
   
   
   //calling isOwnerIdhasGcProfile() method.
   DealRegUtils.isOwnerIdhasGcProfile(UserInfo.getUserId());
   
   
   
  set<id> ownersSet = new set<id>();
   ownersSet.add(gcuser.id);
   
  //calling isOwnerHasGCProfile  method.
    DealRegUtils.isOwnerHasGCProfile(ownersSet);
    
    
    CountryNotApplicableToNonGC__c countryCS = new CountryNotApplicableToNonGC__c();
    countryCS.Name ='PAKISTHAN';
    insert countryCS;
    
    //calling isGCDeal method.
    DealRegUtils.isGCDeal('CHINA');
    
 
 }
 
 }
}
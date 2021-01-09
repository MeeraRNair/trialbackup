/*
 * Author   : Sui Yee
 * Purpose  : Utility test class for creating Contact related data. 
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      11611       16.07       12-Jun-2015     Sui Yee         Created.
 * 2.0      15378       02.03       09-Jan-2018     Ravali          Remove the code related to NPS_Criteria_met__c field
 */
 
@isTest
public class ContactTestData {

    public static boolean bCreate = true;
    public static integer iNumberOfContacts = 5;
    public static list<Contact> lstContacts;
  
    public static testMethod void createContact() {
        populateCommonContactFields();
        if(bCreate) {
            insert lstContacts;
        }
    }
    
    private static testMethod void populateCommonContactFields() {
      Account accInstance = new Account();
      accInstance.Name = 'testAccount';
      insert accInstance;
      
      lstContacts = new list<Contact>();
        for(integer i=0; i<iNumberOfContacts; i++) {
          Contact con = new Contact();
          con.AccountId = accInstance.Id;
          con.Email = 'test@test.com';
          con.phone = '6739';
          con.LastName = 'conLastName';
          con.FirstName = 'conFirstName';
          con.Status__c = 'Customer';
          con.Email_Opt_In__c = 'yes';
          con.Survey__c = 'yes';
          con.Decision_Making_Role__c = 'Technical Buyer';
          //con.NPS_Criteria_Met__c = True; //v2.0
      
          lstContacts.add(con);
        }
    }
    
    static testMethod void TestDecNPSqualifiedcontact(){
      Account acc = new Account();
      acc.Name = 'testAccount';
      acc.NPS_Qualified_Contacts__c = 1;
      insert acc;
     
      Contact con = new Contact();
      con.AccountId = acc.Id;
      con.Email = 'test@test.com';
      con.phone = '6739';
      con.LastName = 'conLastName';
      con.FirstName = 'conFirstName';
      con.Status__c = 'Customer';
      con.Email_Opt_In__c = 'yes';
      con.Survey__c = 'yes';
      con.Decision_Making_Role__c = 'Technical Buyer';
      //con.NPS_Criteria_Met__c = True; //v2.0
        
      insert con;
      con.Email = Null;
      //con.NPS_Criteria_Met__c = False; //v2.0
      update con;
    }
}
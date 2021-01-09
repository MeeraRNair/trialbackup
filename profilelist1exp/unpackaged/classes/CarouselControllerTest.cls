/*
History:
Version     Date                Modified By         CR#         Description     
--------------------------------------------------------------------------------------
1.0                                                             Created
1.2         23-May-2019       Abhinav                         Modified conditions
*/

@isTest
public class CarouselControllerTest {
    static list<user> listuser;
    static testmethod void run2condition() {
        List<String> listPickListValues= new List<String>();
        Schema.DescribeFieldResult fieldResult = User.User_Persona__c.getDescribe();
        List<Schema.PicklistEntry> listple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : listple){
            listPickListValues.add(pickListVal.getLabel());
        }
        
        /*      //Create a user with Standard User profile       
Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
List<User> tstUser = new List<User>();

User userRecord1 = new User(Username='testvaliduser1' +'@dell.com',
Alias = 'Test', 
Email='Test212'+'@dell.com',            
LastName='Test22',
Title='GCC Program Manager', 
ProfileId = profile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Country = 'US',
Persona__c = pickListValuesList[0],
Badge_Number__c='Test1'+System.currentTimeMillis()
);
tstUser.add(userRecord1);
User userRecord2 = new User(Username='testvaliduser2' +'@dell.com',
Alias = 'Test', 
Email='Test212'+'@dell.com',            
LastName='Test22',
Title='GCC Program Manager', 
ProfileId = profile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Country='US',
Persona__c = '',
Badge_Number__c='Test2'+System.currentTimeMillis()
);
tstUser.add(userRecord2);
insert tstUser;
*/
        list<user> listUser = TestDataFactory.CreateNGenralUsers(2);
        listUser[0].Email='Test212'+'@dell.com';           
        listUser[0].LastName='Test22';
        listUser[0].Title='GCC Program Manager'; 
        listUser[0].LanguageLocaleKey='en_US'; 
        listUser[0].LocaleSidKey='en_US'; 
        listUser[0].EmailEncodingKey='UTF-8'; 
        listUser[0].TimeZoneSidKey='America/Los_Angeles';
        listUser[0].Country = 'US';
        listUser[0].User_Persona__c = '';
        listUser[0].Badge_Number__c='Test1'+System.currentTimeMillis();
        listUser[1].Email='Test212'+'@dell.com';           
        listUser[1].LastName='Test22';
        listUser[1].Title='GCC Program Manager'; 
        listUser[1].LanguageLocaleKey='en_US'; 
        listUser[1].LocaleSidKey='en_US'; 
        listUser[1].EmailEncodingKey='UTF-8'; 
        listUser[1].TimeZoneSidKey='America/Los_Angeles';
        listUser[1].Country = 'US';
        listUser[1].Badge_Number__c='Test2'+System.currentTimeMillis();
        
        insert listUser;
        system.assertEquals('US', listUser[1].Country);
        //Creating Test Data here
        Carousel_Configuration__c cc = new Carousel_Configuration__c();
        cc.Description__c = 'Test Description';
        cc.Header__c = 'Test Header';
        cc.Image_Onclick_URL__c = 'https://www.test.com';
        cc.Type__c = 'Fixed';
        cc.Active__c = True;
        insert cc;
        
        Test.startTest();
        //Create Account using the user profile
        System.runAs(listuser[0]) {
            CarouselController.getCarouselRecords();
        }
        System.runAs(listuser[1]) {
            CarouselController.getCarouselRecords();
        }
        Test.stopTest();
        
    }
}
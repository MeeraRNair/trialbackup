/*
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Sandhya     16-June-2012    13.7        7110    Contexual search on loation
1.1         Fenny       19-Jul-2012     13.7        7110    CRQ 0417
1.2         Niveda      28-May-2019     FY20-0702   17541   City, postal code and distance search
*/
@IsTest
private class FAP_AutoCompleteLocationTest {

    private static testmethod void testInvalidSearchStrThrowingException(){
        assertInvalidSearchStrThrowingException(null);
        assertInvalidSearchStrThrowingException('');
        assertInvalidSearchStrThrowingException('x');
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');
    }
    
    private static void assertInvalidSearchStrThrowingException(String searchStr){
        Boolean exceptionCaught = false;
        try{
            new FAP_AutoCompleteLocation(searchStr);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(
            exceptionCaught == true, 
            'new FAP_AutoCompleteLocation(' 
                + (searchStr == null ? 'null' : '\'' + searchStr + '\'') 
                + ') did not throw FAP_IllegalArgumentException');
    }
    
    
    private static testmethod void testKeywordAutoCompleteByCityName(){
        Account acct = getAcct('Test Rty395i832ij Test');
        Partner_Location__c location = new Partner_Location__c(
             name               = 'test'
            ,Street__c          = '123 Broadway'
            ,City__c            = 'Rty395i832ij'
            ,State_Province__c  = 'NY'
            ,Postal_Code__c     = '10001'
            ,Country__c         = 'UNITED STATES'
            ,Account__c         = acct.id
            ,Longitude__c       = 0
            ,Latitude__c        = 0);
        insert location;
        
        final List<String> results = new FAP_AutoCompleteLocation('ty395i832i').execute();
        System.assertNotEquals(null,results);
        //System.assert(results.size() >= 1, 'Expected at least one result');
        //System.assertEquals('Rty395i832ij',results.get(0));
    }
    
    // Ver 1.1
    private static testmethod void testLocationAutoCompleteByAllCityNameBeginWith(){
        Account acct = getAcct('Test Rty395i832ij Test');
        list<Partner_Location__c>lstLocation = new list <Partner_Location__c>();
        for(Integer i = 1; i <= 7; i++){
          Partner_Location__c location = new Partner_Location__c(
               name               = 'test'
              ,Street__c          = '123 Broadway'
              ,City__c            = 'xyz' + i
              ,State_Province__c  = 'NY'
              ,Postal_Code__c     = '10001'
              ,Country__c         = 'UNITED STATES'
              ,Account__c         = acct.id
              ,Longitude__c       = 0
              ,Latitude__c        = 0);
              lstLocation.add(location);
          
        }
        insert lstLocation;
        
        final List<String> results = new FAP_AutoCompleteLocation('xyz').execute();
        /*System.assertNotEquals(null,results);
        System.assert(results.size() == 5, 'Expected only 5 location returned');
        System.assertEquals('xyz1',results.get(0));
        System.assertEquals('xyz5',results.get(4));*/
    }
    
    // Ver 1.1
    private static testmethod void testLocationAutoCompleteByAllCityNameBeginWith2(){
        Account acct = getAcct('Test Rty395i832ij Test');
        list<Partner_Location__c>lstLocation = new list <Partner_Location__c>();
        for(Integer i = 1; i <= 7; i++){
          Partner_Location__c location = new Partner_Location__c(
               name               = 'test'
              ,Street__c          = '123 Broadway'
              ,City__c            = 'xyz' + i
              ,State_Province__c  = 'NY'
              ,Postal_Code__c     = '10001'
              ,Country__c         = 'UNITED STATES'
              ,Account__c         = acct.id
              ,Longitude__c       = 0
              ,Latitude__c        = 0);
              lstLocation.add(location);
          
        }
        insert lstLocation;
         
        list<Partner_Location__c>lstNewLocation = new list <Partner_Location__c>(); 
        for(Integer i = 8; i <= 9; i++){
          Partner_Location__c location = new Partner_Location__c(
               name               = 'test'
              ,Street__c          = '123 Broadway'
              ,City__c            = i + 'xyz'
              ,State_Province__c  = 'NY'
              ,Postal_Code__c     = '10001'
              ,Country__c         = 'UNITED STATES'
              ,Account__c         = acct.id
              ,Longitude__c       = 0
              ,Latitude__c        = 0);
              lstNewLocation.add(location);
          
        }
        insert lstNewLocation;
        
        final List<String> results = new FAP_AutoCompleteLocation('xyz').execute();
       /* System.assertNotEquals(null,results);
        System.assert(results.size() == 5, 'Expected only 5 location returned');
        System.assertEquals('xyz1',results.get(0));
        System.assertEquals('xyz5',results.get(4));*/
    }
    
    // Ver 1.1
    private static testmethod void testLocationAutoCompleteByCityNameBeginWithAndWildcardSearch(){
        Account acct = getAcct('Test Rty395i832ij Test');
        
        list<Partner_Location__c>lstLocation = new list <Partner_Location__c>(); 
        for(Integer i = 1; i <= 3; i++){
          Partner_Location__c location = new Partner_Location__c(
               name               = 'test'
              ,Street__c          = '123 Broadway'
              ,City__c            = 'xyz' + i
              ,State_Province__c  = 'NY'
              ,Postal_Code__c     = '10001'
              ,Country__c         = 'UNITED STATES'
              ,Account__c         = acct.id
              ,Longitude__c       = 0
              ,Latitude__c        = 0);
           lstLocation.add(location);
        
        }
        insert lstLocation;
        
        list<Partner_Location__c>lstNewLocation = new list <Partner_Location__c>(); 
        for(Integer i = 4; i <= 7; i++){
          Partner_Location__c location = new Partner_Location__c(
               name               = 'test'
              ,Street__c          = '123 Broadway'
              ,City__c            = i + 'xyz'
              ,State_Province__c  = 'NY'
              ,Postal_Code__c     = '10001'
              ,Country__c         = 'UNITED STATES'
              ,Account__c         = acct.id
              ,Longitude__c       = 0
              ,Latitude__c        = 0);
           lstNewLocation.add(location);
          
        }
        insert lstNewLocation;
        
        final List<String> results = new FAP_AutoCompleteLocation('xyz').execute();
        System.assertNotEquals(null,results);
       /* System.assert(results.size() == 5, 'Expected only 5 location returned');
        System.assertEquals('xyz1',results.get(0));
        System.assertEquals('xyz3',results.get(2));
        System.assertEquals('4xyz',results.get(3));
        System.assertEquals('5xyz',results.get(4)); */
    }
    
    // Ver 1.1
    private static testmethod void testLocationAutoCompleteByAllCityNameNotBeginWith(){
        Account acct = getAcct('Test Rty395i832ij Test');
        
        list<Partner_Location__c>lstLocation = new list <Partner_Location__c>(); 
        for(Integer i = 1; i <= 3; i++){
          Partner_Location__c location = new Partner_Location__c(
               name               = 'test'
              ,Street__c          = '123 Broadway'
              ,City__c            = i + 'xyz'
              ,State_Province__c  = 'NY'
              ,Postal_Code__c     = '10001'
              ,Country__c         = 'UNITED STATES'
              ,Account__c         = acct.id
              ,Longitude__c       = 0
              ,Latitude__c        = 0);
              
              lstLocation.add(location);
        }
        insert lstLocation;
        
        list<Partner_Location__c>lstNewLocation = new list <Partner_Location__c>();
        for(Integer i = 4; i <= 7; i++){
          Partner_Location__c location = new Partner_Location__c(
               name               = 'test'
              ,Street__c          = '123 Broadway'
              ,City__c            = i + 'xyz' + i
              ,State_Province__c  = 'NY'
              ,Postal_Code__c     = '10001'
              ,Country__c         = 'UNITED STATES'
              ,Account__c         = acct.id
              ,Longitude__c       = 0
              ,Latitude__c        = 0);
          lstNewLocation.add(location);
         
        }
        insert lstNewLocation;
        
        final List<String> results = new FAP_AutoCompleteLocation('xyz').execute();
        System.assertNotEquals(null,results);
        /*System.assert(results.size() == 5, 'Expected only 5 location returned');
        System.assertEquals('1xyz',results.get(0));
        System.assertEquals('3xyz',results.get(2));
        System.assertEquals('4xyz4',results.get(3));
        System.assertEquals('5xyz5',results.get(4));*/
    }
    
    // Ver 1.1
    private static testmethod void testLocationAutoCompleteByCityNameLessThanFive(){
        Account acct = getAcct('Test Rty395i832ij Test');
        
        Partner_Location__c location = new Partner_Location__c(
             name               = 'test'
            ,Street__c          = '123 Broadway'
            ,City__c            = 'xyz1'
            ,State_Province__c  = 'NY'
            ,Postal_Code__c     = '10001'
            ,Country__c         = 'UNITED STATES'
            ,Account__c         = acct.id
            ,Longitude__c       = 0
            ,Latitude__c        = 0);
        insert location;
        
        location = new Partner_Location__c(
             name               = 'test'
            ,Street__c          = '123 Broadway'
            ,City__c            = '2xyz'
            ,State_Province__c  = 'NY'
            ,Postal_Code__c     = '10001'
            ,Country__c         = 'UNITED STATES'
            ,Account__c         = acct.id
            ,Longitude__c       = 0
            ,Latitude__c        = 0);
        insert location;
        location = new Partner_Location__c(
             name               = 'test'
            ,Street__c          = '123 Broadway'
            ,City__c            = '3xyz3'
            ,State_Province__c  = 'NY'
            ,Postal_Code__c     = '10001'
            ,Country__c         = 'UNITED STATES'
            ,Account__c         = acct.id
            ,Longitude__c       = 0
            ,Latitude__c        = 0);
        insert location;
        
        final List<String> results = new FAP_AutoCompleteLocation('xyz').execute();
        System.assertNotEquals(null,results);
        /*System.assert(results.size() == 3, 'Expected only 3 location returned');
        System.assertEquals('xyz1',results.get(0));
        System.assertEquals('2xyz',results.get(1));
        System.assertEquals('3xyz3',results.get(2));*/
    }
    
    private static testmethod void testKeywordAutoCompleteByPostalCode(){
        Account acct = getAcct('Test Rty395i832ij Test');
        Partner_Location__c location = new Partner_Location__c(
             name               = 'test'
            ,Street__c          = '123 Broadway'
            ,City__c            = 'Rty395i832ij'
            ,State_Province__c  = 'NY'
            ,Postal_Code__c     = 'Rty395i832ij'
            ,Country__c         = 'UNITED STATES'
            ,Account__c         = acct.id
            ,Longitude__c       = 0
            ,Latitude__c        = 0);
        insert location;

        final List<String> results = new FAP_AutoCompleteLocation('ty395i832i').execute();
        System.assertNotEquals(null,results);
       // System.assert(results.size() >= 1, 'Expected at least one result');
       // System.assertEquals('Rty395i832ij',results.get(0));
    }
    
       
    private static Account getAcct(String name){
        
        Account acct = new Account(
            name = name,
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            Partner_User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId(),
            Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now());
        insert acct;
        acct.IsPartner = true;
        update acct;
        
        Partner_Location__c loc = new Partner_Location__c();
        loc.Name = 'test location';
        loc.Longitude__c = 0;
        loc.Latitude__c = 0;
        loc.Is_Primary__c = true;
        loc.Account__c = acct.id;
        insert loc;

        return acct;
    }

}
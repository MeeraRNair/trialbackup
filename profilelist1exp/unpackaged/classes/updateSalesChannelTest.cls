/*
* Revision CR Number   Release No      Date           Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
  1.0      CR16118     FY19-DCS-0802  11-Jul-2018     Pallavi         Removed commented parts and debug statements as part of code reduce story 5240537          

*/

@isTest
private class updateSalesChannelTest {

    private static Map<String, String> sParams;
    
    //Test Condition:
    //Create Account record with "Sales Channel Group ID" corresponding to existing Sales Channel Group.
    static testMethod void associateAccount_SalesChannelGroup_NewAccWithExistingSCG(){
             
        //Create Test Data      
        Sales_Channel_Group__c testSCG = (Sales_Channel_Group__c) TestDataGenerator.getObject(new Sales_Channel_Group__c(), 1)[0];
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, null, false)[0];

        try {
            Test.startTest();   
            
            testAcc.Sales_Channel_ID__c = testSCG.Group_ID__c;          
            insert testAcc;              
            Test.stopTest();
            
            //Asserts that the Sales Channel lookup of the inserted record contains specified Sales Channel Group   
            Account insertedAcc = [SELECT Sales_Channel__c FROM Account WHERE id = :testAcc.id];
            system.assertEquals(insertedAcc.Sales_Channel__c, testSCG.id);
        }
        catch(Exception e){
            system.debug('## Caught APEX exception' + e.getMessage());
        }                   
    }
    
    //Test Condition:
    //Create Account record with "Sales Channel Group ID"  not corresponding to any Sales Channel Group records.
    public static testMethod void associateAccount_SalesChannelGroup_NewAccWithNonExistingSCG(){
         
        //Create Test Data      
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, null, false)[0];
        
        try {
            Test.startTest();
            
            testAcc.Sales_Channel_ID__c = '9999999999';
            insert testAcc;
            
            Test.stopTest();
            
            //Get the details of newly created Sales Channal Group
            Sales_Channel_Group__c createdSCG = [SELECT Id, Group_ID__c, name FROM Sales_Channel_Group__c WHERE Group_ID__c='9999999999'];
            //Assert that the name of created Sales Channel Group is '-'
            system.assertEquals(createdSCG.name,'-');
            
            //Asserts that Account record's "Sales Channel Group ID" field will have value identical to that of the new Sales Channel Group record's "Group ID" field.  
            system.assertEquals(testAcc.Sales_Channel_ID__c, createdSCG.Group_ID__c);
             
            //Asserts that the Sales Channel lookup of the inserted record contains specified Sales Channel Group   
            Account insertedAcc = [SELECT Sales_Channel__c FROM Account WHERE id = :testAcc.id];
            system.assertEquals(insertedAcc.Sales_Channel__c, createdSCG.id);
        }
        catch(Exception e){
            system.debug('## Caught APEX exception' + e.getMessage());
        } 
    }
    
    //Test Condition:
    //Account update: Change the value of an account record's "Sales Channel Group ID" to that corresponding to another existing Sales Channel Group
    public static testMethod void associateAccount_SalesChannelGroup_UpdateAccWithExistingSCG(){
           
        sParams = new Map<String, String>();
        List<SObject> testSCGList; 
        
        //Create Test Data
        //creates two Sales channel group records
        testSCGList = TestDataGenerator.getObject(new Sales_Channel_Group__c(), 2);
  
        //creates account with first Sales channel group reference
        sParams.put('str_Sales_Channel_ID__c', string.valueOf(testSCGList[0].get('Group_ID__c')));
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
                                
        Account insertedAcc = [SELECT Sales_Channel_ID__c from Account WHERE id = :testAcc.Id];               
        system.assertEquals(insertedAcc.Sales_Channel_ID__c, testSCGList[0].get('Group_ID__c'));
   
        try {        
            Test.startTest();
            
            //assigns the second sales channel group Id to the Account
            testAcc.Sales_Channel_ID__c = string.valueOf(testSCGList[1].get('Group_ID__c'));               
            update testAcc;
                            
            Test.stopTest();
            
            insertedAcc = [SELECT Sales_Channel_ID__c from Account WHERE id = :testAcc.Id];                     
            system.assertEquals(insertedAcc.Sales_Channel_ID__c, string.valueOf(testSCGList[1].get('Group_ID__c')));
        }
        catch(Exception e){
            system.debug('## Caught APEX exception' + e.getMessage());
        } 
    }    
    
    //Test Condition:
    //Account update:Update the "Sales Channel Group ID" field of an account record to a value that does not correspond to any existing Sales Channel Group.    
    public static testMethod void associateAccount_SalesChannelGroup_UpdateAccWithNonExistingSCG(){
            
        
        sParams = new Map<String, String>();
        
        //Create Test Data        
        //creates a Sales channel group record
        Sales_Channel_Group__c testSCG = (Sales_Channel_Group__c) TestDataGenerator.getObject(new Sales_Channel_Group__c(), 1)[0];
                                                    
        //creates account with above Sales channel group reference
        sParams.put('str_Sales_Channel_ID__c', testSCG.Group_ID__c);
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();
        
        Account insertedAcc = [SELECT Sales_Channel_ID__c FROM Account WHERE id = :testAcc.Id];       
        system.assertEquals(insertedAcc.Sales_Channel_ID__c, testSCG.Group_ID__c);
        
        try {       
            //updates the test Account record
            Test.startTest();
            
            //Sales_Channel_ID__c of Account is assigned with a non existing group Id
            testAcc.Sales_Channel_ID__c='99999999999';
            update testAcc;
            
            Test.stopTest();
            
            //Get the details of newly created Sales Channal Group
            Sales_Channel_Group__c insertedSCG = [SELECT Id, Group_ID__c,name FROM Sales_Channel_Group__c WHERE Group_ID__c='99999999999'];
            //***Assert that the name of created Sales Channel Group is '-'
            system.assertEquals(insertedSCG.name,'-');
                     
            insertedAcc = [SELECT Sales_Channel_ID__c FROM Account WHERE id =:testAcc.Id];          
            system.assertEquals(insertedAcc.Sales_Channel_ID__c, insertedSCG.Group_ID__c);          
        }
        catch(Exception e){
            system.debug('## Caught APEX exception' + e.getMessage());
        }    
    }        
      
   //Test Condition
   //Account update:Update the "Sales Channel Group ID" field of an account record to null. 
   public static testMethod void associateAccount_SalesChannelGroup_UpdateAccWithNullSCG(){
        
        sParams = new Map<String, String>();
                
        //Create Test Data        
        //creates a Sales channel group record
        Sales_Channel_Group__c testSCG = (Sales_Channel_Group__c) TestDataGenerator.getObject(new Sales_Channel_Group__c(), 1)[0];
                                            
        //creates account with above Sales channel group reference
        sParams.put('str_Sales_Channel_ID__c', testSCG.Group_ID__c);
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();
        
        Account insertedAcc = [SELECT Sales_Channel_ID__c FROM Account WHERE id = :testAcc.Id];
        system.assertEquals(insertedAcc.Sales_Channel_ID__c,testSCG.Group_ID__c);
       
        try {
            //updates the test Account record
            Test.startTest();
            
            //Sales_Channel_ID__c of Account is assigned with a non existing group Id
            testAcc.Sales_Channel_ID__c=null;
            update testAcc;
            
            Test.stopTest();
                 
            insertedAcc = [SELECT Sales_Channel_ID__c FROM Account WHERE id = :testAcc.Id];
                        
            //***Asserts that the Sales channel relation has been successfully updated with null
            system.assertEquals(insertedAcc.Sales_Channel_ID__c,null);
        }
        catch(Exception e){
            system.debug('## Caught APEX exception' + e.getMessage());
        } 
    }        
    
    //Test Condition    
    //Account insert : with Sales Channel Group ID= null.   
    public static testMethod void associateAccount_SalesChannelGroup_NewAccWithNullSCG(){
            
        //creates account with null  Sales channel group Id
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, null, false)[0];

        try {           
            //inserts the test Account
            Test.startTest();           
            insert testAcc;
            Test.stopTest();
                 
            Account insertedAcc = [SELECT Sales_Channel_ID__c FROM Account WHERE id = :testAcc.Id];
            system.assertEquals(insertedAcc.Sales_Channel_ID__c,null);
         }
        catch(Exception e){
            system.debug('## Caught APEX exception' + e.getMessage());
        } 
    } 
}
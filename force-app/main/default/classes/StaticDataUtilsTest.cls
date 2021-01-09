/**
This is a test class for StaticDataUtils

* Revision CR Number           Release No      Date            Modified By     Description
* -------- ---------           ----------      -----------     ------------    -----------
* 1.0      9833(15.07)                         23.07.2014      KP              Creation.
* 2.0      16149                               12.07.2018      Pallavi         removed method calls that were refering tho the commented methods in the main class as part of code reduce story 5240511
*/

@isTest(SeeAllData=true) 
private class StaticDataUtilsTest{

    static testMethod void testRecordTypeMethods(){         
        // Test Record Types Related Methods - New
        StaticDataUtils.getRecordTypeIds('Account');       
        System.assertEquals(StaticDataUtils.getRecordTypeIdByName( 'Account', 'End-User Account'), '012300000004zesAAA');
        System.assertEquals(StaticDataUtils.getRecordTypeNameById('Account', '012300000004zesAAA'), 'End-User Account');        
        StaticDataUtils.getRecordTypeIdsByNames('Account', new set<string> {'End-User Account'});     
    }
    static testMethod void testGetCurrentUserDetails(){
        // Test Current User Detail Methods
        StaticDataUtils.getCurrentUserDetails();
    } 
}
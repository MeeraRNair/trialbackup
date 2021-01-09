/*
 * Author   : Ragu
 * Purpose  : Test Utility class
 * 
 * Revision	CR Number	Release No	Date			Modified By  	Description
 * --------	---------	----------	-----------		------------	-----------
 * 1.0      CR10496		15.10		08-Oct-2014		Ragu			Created
 * 
 */
@isTest
private class Utility_Test {

    static testMethod void testUtility() {
        Utility.printLimitsConsumption('From Utility_Test.testUtility()');
        Utility.getFieldsForQuery(new Asset());
        
        boolean bChanged = Utility.checkStageChangeAcrossOpenAndClosed('Win - 100%', 'Win - 100%');
        System.assertEquals(bChanged, false);
        
        boolean bClosed = Utility.isClosedStage('Win - 100%');
        System.assertEquals(bClosed, true);
        
        boolean bOpen = Utility.isOpenStage('Win - 100%');
        System.assertEquals(bOpen, false);
    }
    
}
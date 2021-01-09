@isTest
class batchLicenseScheduleTest{  
  static testmethod void testLicense(){ 
     Test.startTest(); 
  
        String sch = '0 58 15 * * ?';   
        String SCid = System.schedule('One Time Run',sch, new BatchLicenseScheduleExecute()); 
     Test.stopTest();     
  }
}
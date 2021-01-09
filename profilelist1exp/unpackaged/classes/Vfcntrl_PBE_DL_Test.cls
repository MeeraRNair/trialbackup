/*
* Revision  CR Number   Release No    Date            Modified By     Description
* --------- ---------   -----------   -------         ------------    ---------
  1.0       CR16118     FY19-DCS-0802 09-Jul-2018     Pallavi         Removed few product records as part of code reduce story 5240537

*/
@isTest
public class Vfcntrl_PBE_DL_Test {
 
 static testMethod void TestData1(){
 
  List<Product2> prodList = new  List<Product2>();
  
  Product2 prod1 = new Product2(Business_Family__c = 'EMC', IsActive = True, Name = 'Test1', Product_ID__c = 'test solution1');
  prodList.add(prod1);
  Product2 prod4 = new Product2(Business_Family__c = 'EMC', IsActive = false, Name = 'Test4', Product_ID__c = 'test solution4');
  prodList.add(prod4);
   
  Product2 prod5 = new Product2(IsActive = True, Name = 'Test4', Product_ID__c = 'test solution5');
  prodList.add(prod5);
  
  Product2 prod6 = new Product2(IsActive = false, Name = 'Test4', Product_ID__c = 'test solution6');
  prodList.add(prod6);   
  insert prodList;
  
  Vfcntrl_PBE_DL prodtest = new Vfcntrl_PBE_DL();
  prodtest.constructorMethod();
     
  Vfcntrl_PBE_DL_GCC prodtest1 = new Vfcntrl_PBE_DL_GCC();
  prodtest1.constructorMethod();
 
}
}
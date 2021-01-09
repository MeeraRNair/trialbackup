@isTest
public class GenericHistoryControllerTester {
/************************************************************************
* Description:
* Test class for GenericHistoryControllerTester
*
* Version   Author      Date            Remark
* 1.0       Raymond     19-01-2012      Created.
*
*************************************************************************/  
static testMethod void myTestGenericHistoryComponentController() {
        
        //create controller
        GenericHistoryComponentController controller = new GenericHistoryComponentController();
        //null myObject
        system.assert(controller.getObjectHistory().size() == 0);        
        
        Test.startTest();
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Test.stopTest();

        //Account allows for history in related lists in visualforce, this is simply a standard object being used to get code coverage so you can use the component for other custom and standard objects.
        list<AccountHistory> lstAccHistories = [select AccountId from accounthistory where isdeleted = false limit 1];
        if(lstAccHistories != null && !lstAccHistories.isEmpty()) {
            system.assert(lstAccHistories.size() == 1); //limit in case of 50,000 record governor limit
            string accid = lstAccHistories[0].AccountId;
            
            //Set myObject
            controller.myObject = [select id from Account where id=:accid];             
            system.assert(controller.getObjectHistory().size() > 0); 
        }      
    }

}
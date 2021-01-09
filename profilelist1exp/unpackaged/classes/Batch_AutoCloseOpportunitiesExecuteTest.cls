@istest( SeeAllData = true)
Private Class Batch_AutoCloseOpportunitiesExecuteTest {

    static testMethod void Test_Batch_AutoCloseOpportunitiesExecute(){
    
        Test.StartTest();  
        
        Batch_AutoCloseOpportunitiesExecute b= new Batch_AutoCloseOpportunitiesExecute();
        String t = '0 0 * * * ? *';
        System.schedule('Auto Close Opportunities', t, b);        

        Test.StopTest();

    }
}
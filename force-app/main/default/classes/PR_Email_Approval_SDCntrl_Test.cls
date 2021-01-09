@isTest
public class PR_Email_Approval_SDCntrl_Test {
	@isTest
    public static void emailTest(){
        Partner_Request__c p=new Partner_Request__c(Company__c='test',First_Name__c='testfirst');
        insert p;
        test.startTest();
        PR_Email_Approval_SDCntrl.gettingData(null);
        Partner_Request__c pr=PR_Email_Approval_SDCntrl.gettingData(p.id);
        PR_Email_Approval_SDCntrl.update_PR_Data(null);
        PR_Email_Approval_SDCntrl.update_PR_Data(pr);
        pr.Approve_Is_Complete_Flag__c=true;
        PR_Email_Approval_SDCntrl.update_PR_Data(pr);
        test.stopTest();
    }
}
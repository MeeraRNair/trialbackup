/* ============================================================
 * This Controller Created for deleting Case Managtment Queue Record, Allow if there is no cases with this Queue Name
 * CR 9022 - Version 0.1 Developed by Rakesh Muppiri on 22-01-2014
 * ============================================================
 */
 
public class DeleteCaseManagementQueueCntrl {
    public Case_management_Queue__c CasemngmtRec;
    public DeleteCaseManagementQueueCntrl(ApexPages.StandardController controller) {
        CasemngmtRec = [SELECT Id,Name FROM Case_management_Queue__c  WHERE ID =: controller.getId()];
        Queue = CasemngmtRec.Name;
        i= [SELECT count() FROM case Where Queue_Name__c =: CasemngmtRec.Name];
        if(i>0){
            allow = false;        //If there are no case records with the Queue name
        }
        else{
            allow = true;
        }
    }

    public Static boolean execute = false;
    public String Queue{set;get;}
    public Integer i{set;get;}
    public boolean allow{set;get;}
   
    public Pagereference deleteQueue(){
        PageReference pageRef = new PageReference('/a3q?fcf=00BA0000004Wf2C');    //Case Management Queue List view link
        If(allow && DeleteCaseManagementQueueCntrl.execute == false){
            DeleteCaseManagementQueueCntrl.execute = true;
        Case_Management_Queue__c q = [SELECT Id FROM Case_Management_Queue__c Where Name=: CasemngmtRec.Name LIMIT 1];
        delete q;
        return pageRef;
        }
        else
        return null;
    }
}
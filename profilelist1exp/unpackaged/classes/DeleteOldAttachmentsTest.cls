/*
* Author  : Nagaraju Yelluri
* Purpose : To display Account Revenue Trends Information.
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR15065                 31-Oct-2017     Nagaraju        This class gives the test coverage for DeleteOldAttachments class.
*/
@isTest
public class DeleteOldAttachmentsTest {
    public static testmethod void testcase1() {
        TriggerExecutionController.setSkipAllTriggers(true);  
        //user u = Drawloop_TerritoryPlanningTest.createTestData(); 
        
        Test.startTest();
        Territory_Plan__c tp_Obj = new Territory_Plan__c(
            name = 'test 101011 planning');
         insert tp_Obj;
         System.debug('TP id: '+tp_Obj.id);
         //TriggerExecutionController.setSkipAttachmentTriggers(false); 
        //system.runAs(u) {
            List<Attachment> aList = new List<Attachment>();
            String filecontent='This is a test attachment'; 
            Attachment a =new Attachment(name = 'FY2017 Q03 Nagaraju Yelluri Territory Plan', parentId = tp_Obj.Id, body = Blob.valueOf(filecontent));
            Attachment b =new Attachment(name = 'FY2018 Q03 Nagaraju Yelluri Territory Plan', parentId = tp_Obj.Id, body = Blob.valueOf(filecontent));
            Attachment c =new Attachment(name = 'FY2018 Q03 Nagaraju Yelluri Territory Plan', parentId = tp_Obj.Id, body = Blob.valueOf(filecontent));
            aList.add(a);
            //aList.add(b);
            //aList.add(c);
            insert aList;
            insert c;
            
            System.debug('Attachment id :'+c.id);
            //System.debug('Object type :'+a.ParentId.getSObjectType());
            AttachmentTriggerHandler handler = new AttachmentTriggerHandler();
             try{
            handler.onAfterInsert();
            }catch(exception ex){}
            
            DeleteOldAttachments.tp_deleteOldAttachment(aList);
              PopulateCaseFeed.PopulateAttachmentInsertedStausonCase(aList);
        //}
        Test.stopTest();
    }
}
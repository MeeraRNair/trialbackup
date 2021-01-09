/* Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      14068		FY18-DCS-0502	14-Mar-2017		Gan				Unit test to cover the GDMRequestFieldPopulator
 */

@isTest
public class GDMRequestFieldPopulatorTest {

    static testMethod void test_populateBuddyAccessApprovedRejectedComments() {
        triggerexecutioncontroller.setSkipAllTriggers(True);
        //create a buddy request
        Id IdBuddyAccessRT = IdLookupUtils.getRecordTypeId('Buddy Access','GDM_Request__c',true);
        
        //User Record INSERTION
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        List<User> listUser = new List<User>();
        User objROLManager = new User( Username='TestROLM' +System.currentTimeMillis() + '@test.com',
                             Alias = 'ROLM'+056,
                             Email='testROLM'+ 012 +'@dell.com',
                             FirstName='ROLM'+0,
                             LastName='TestBA'+100,
                             ProfileId = userProfile.Id,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
                             EmailEncodingKey='UTF-8',
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='9000' + String.valueOf(Math.round(Math.random()*1000000000)));
        
        User objRepOnLeave = new User( Username='TestROL' +System.currentTimeMillis() + '@test.com',
                             Alias = 'ROL'+056,
                             Email='testROL'+ 012 +'@dell.com',
                             FirstName='ROL'+0,
                             LastName='TestBA'+100,
                             ProfileId = userProfile.Id,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
                             EmailEncodingKey='UTF-8',
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='9000' + String.valueOf(Math.round(Math.random()*1000000000)));
        
        User objBuddy = new User( Username='TestBuddy' +System.currentTimeMillis() + '@test.com',
                             Alias = 'Buddy'+056,
                             Email='testBuddy'+ 012 +'@dell.com',
                             FirstName='Buddy'+0,
                             LastName='TestBA'+100,
                             ProfileId = userProfile.Id,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
                             EmailEncodingKey='UTF-8',
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='8000' + String.valueOf(Math.round(Math.random()*1000000000)));
        
        listUser.add(objROLManager);
        listUser.add(objRepOnLeave);
        listUser.add(objBuddy);
        
        insert listUser;
        
        listUser[1].ManagerId = listUser[0].id;
        listUser[2].ManagerId = listUser[0].id;
        update listUser;
        
        GDM_Request__c objGdmReq = new GDM_Request__c(RecordTypeId = IdBuddyAccessRT,
                                            Rep_on_Leave__c = listUser[1].id,
                                            Buddy__c = listUser[2].id,
                                            Buddy_Access_Start_Date__c = System.Today(),
											Buddy_Access_End_Date__c = System.Today() + 2,
                                            Reason_Requested__c = 'Holidays',
                                            ROL_Manager__c = listUser[0].id
                                            );
        
        insert objGdmReq;
        
        string strApproveComments = 'Approved and Closed';
        system.debug('ZY: objROLManager.id : '  + objROLManager.id);
        //insert approval process if not created... unable to inset to process steps
        if([select count() from ProcessInstance where targetobjectid=:objGdmReq.id] < 1)
        {       
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(objGdmReq.Id);
            req.setNextApproverIds(new Id[] {objROLManager.id});
            system.debug('ZY: objROLManager.id : '  + objROLManager.id);
            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);
        }
     
        triggerexecutioncontroller.setSkipAllTriggers(False);
        
        Test.startTest();
        //check comments field should be null
        System.assertEquals(null, objGdmReq.Approval_Rejection_Comments__c);
        
        objGdmReq.Buddy_Access_Status__c = 'Approved and scheduled';
        update objGdmReq;
 
        //unable to validate as I cant inset the comments for approval via the unit test
        //System.assertEquals(approveComments, objGdmReqs.Approval_Rejection_Comments__c);
            
        Test.stopTest();
    }
}
/* 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      -       													created
 * 2.0		13113		FY17-DCS-0602	04-May-2016		Azwanti			LM2_6-Fix Test Class Impacted on Campaign RT Deactivated (Part 1)
 */

@isTest
Private class Batch_CMAPSendEmailforAccepted_Test {
    static testMethod void Batch_CMAPSendEmailforAccepted_Test1(){
        
        
                Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
                Id PartAccount= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
                Profile pf = [Select id From Profile Where Name = 'R16.10 APJ PRM Portal User (MOSS)'];
                
                
                TriggerExecutionController.setSkipAllTriggers(True);
                CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
                testData.getAccount(true);
                testData.getContact(true);
                testData.getPartnerUser(true);
                testData.getCampaign(true);
                CMAP_Helper.skipinsert = true;
                
                
                Account acc = new Account(Name = 'Partner Account', RecordTypeId = PartAccount);
                insert acc;
                
                Contact con = new Contact(LastName = 'PartnerCon', AccountId = acc.Id, Status__c = 'Customer', 
                              Decision_Making_Role__c = 'Influencer',Job_Function__c = 'Executives', 
                              Job_Function_Role__c =  'CEO',Phone = '93977373', EMail = 'rahul_moshra8@dell.com');
                insert con;              
                system.debug('Contact Id is'+con);
                
                
                User usr = new User(FirstName = 'Test', LastName = 'PartnerUser', Email = 'rahul_moshra8@dell.com', userName = 'rahul_moshra8@dell.com',
                           ProfileId = pf.Id, IsActive =true, ContactId = con.Id, timezonesidkey='America/Los_Angeles',alias = 'nerRahul',
                           emailencodingkey='UTF-8', languagelocalekey='en_US',Badge_Number__c  = '77958496',
                           localesidkey='en_US', country='United States');
                           
                insert usr; 
     
                Lead leadObj = new Lead(lastName = 'Test Lead',
                email ='testcmap@cmaptest.com',
                LeadSource  = 'Web',
                Lead_Type__c = 'Inbound',
                Dell_Partner_can_contact_me__c = true,
                status = 'Open - Channel Lead',
                Phone='88967544',
                RecordTypeId = leadRTId,
                Country = 'US',
                Partner_Account__c =acc.Id,
                Campaign__c  = testdata.campObj.Id,
                Company = 'Test Company',
                Partner_User__c =testData.PartnerUser.Id,
               // Partner_Admin__c =usr.Id,
                Ready_For_Scoring__C = TRUE,
                Send_email_for_Accepted_Status__c = TRUE,
                Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)'
                );
                
                insert leadObj; 
                
                leadObj.OwnerId = usr.Id;
                update leadObj;
                system.debug('Owner Id is updated');
                
                system.debug('Inserted User id is'+usr);
                
                Id CampRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0 
        
                Test.startTest();
        
                TriggerExecutionController.setSkipUserTriggers(true);
                Lead leadObj1 = new Lead(lastName = 'Test Lead',
                        email ='testcmap@cmaptest.com',
                        LeadSource  = 'Web',
                        Lead_Type__c = 'Inbound',
                        Dell_Partner_can_contact_me__c = true,
                        status = 'Open - Channel Lead',
                        Phone='88967544',
                        RecordTypeId = leadRTId,
                        Country = 'US',
                        Partner_Account__c =testdata.accountObj.Id,
                        Campaign__c  = testdata.campObj.Id,
                        Company = 'Test Company',
                        Partner_User__c =testData.PartnerUser.Id,
                        //Partner_Admin__c =testData.pUser2.Id,
                        Ready_For_Scoring__C = TRUE,
                        Send_email_for_Accepted_Status__c = TRUE,
                        Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)'
                        );
                        
                insert leadObj1;       
                test.StopTest();
                 Batch_CMAPSendEmailforAccepted obj = new  Batch_CMAPSendEmailforAccepted();
                 obj.query='SELECT ID, OwnerId, Send_email_for_Accepted_Status__c  FROM Lead LIMIT 1';
                Id BatchId = Database.executeBatch(obj, 200);
    }
}
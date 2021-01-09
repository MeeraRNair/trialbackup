@isTest(seealldata=false)
public class DealOppCreationCntrlTest {

    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert owdsetting;
    }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
     static testMethod void testDealOppCreation() {
      triggerexecutioncontroller.setSkipAllTriggers(True);
             
             System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
             vr.Bypass_Opportunity_VRs__c = true;
             insert vr;
         account acc = new account(name='Testaccount',account_country__c='china');
         acc.RecordTypeId = IdLookupUtils.getRecordTypeId('End-User account','account', TRUE);
         insert acc;
         Contact con = new Contact(LastName = 'test con',accountId = acc.Id,phone='998888888888',mobilephone='8987878679899',email='testll@gmail.com',fax='676777');
         insert con;
         accountTeamMember accT  = new accountTeamMember(accountId=acc.Id, TeamMemberRole='account Executive', UserId= userInfo.getUserId());
         insert accT;
         
         //User admin = [Select Id,Name FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=True LIMIT 1];
                User u;
               // system.runAs(admin){
                     
                     Profile profileName = [SELECT Id, Name FROM Profile WHERE UserType ='PowerPartner' LIMIT 1];
                     
                     u = new User(Alias = 'standt', Email='standarduser@dell.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = profileName.Id,Badge_Number__c ='757757557',
                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduserNew@dell.com',contactId=con.Id);
                    //u = [Select Id,Name From User WHERE UserType='PowerPartner' LIMIT 1];
                    INSERT u;
                    
                    //u.UserType ='PowerPartner';
                   // update u;
             //   }      
                                                    
            //system.runas(u)
            {
            Opportunity op = new Opportunity();
                                                //system.runas(u){
            
            op.name = 'TestOpp';
            op.stagename = 'Lost, Cancelled - 0%';
           // op.Probability = 100;
         //   op.ForecastCategoryName = 'Closed';    
          //  op.Forecast_Category_Override__c = 'Closed';
            op.closedate = System.today().addDays(90);
            op.CurrencyIsoCode = 'EUR';
            op.Domain__c = 'EUC';
            op.Competitor_Lost_To__c = '3i-Infotech';
            op.Solution_Type__c = 'Mobility Solutions';
            op.Solution_Name__c = 'Tablet Solutions';
            op.Competitor_Lost_To__c = 'Unknown';
            op.Type = 'Run Rate';
            op.accountId=acc.Id;
            op.RecordTypeId = IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity', TRUE);
            op.Deal_Created_Date_Time__c = System.today();
            op.Customer_consent_to_engage_partner__c = true;
            TriggerControlHandler.setOpportunityTriggersInactive();
            system.assertEquals(op.name,'TestOpp');
            test.startTest();
            insert op;
         System.debug('ooooooo'+op);
         ApexPages.currentpage().getParameters().put('SegmentOppID',op.Id);
         ApexPages.currentpage().getParameters().put('partnerUserId',u.Id);
          ApexPages.currentpage().getParameters().put('salesmotionID',acc.Id); 
         DealOppCreationCntrl obj = new DealOppCreationCntrl();
                obj.IsaccountTeamMember = true;
                obj.DealOpp.Customer_consent_to_engage_partner__c = true;
                obj.test = false;
                obj.UpdateSegOpp();
                obj.Cancel();
                obj.SaveOpp();
                
            System.debug('-------------++++++++++');
            
               
                
                try{
                    PageReference p = obj.SaveOpp();
                }
                catch(Exception e){}
                //obj.Cancel();
            test.stopTest();
        }
     }
}
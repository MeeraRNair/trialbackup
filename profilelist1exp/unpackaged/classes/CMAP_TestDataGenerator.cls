/* 
REVISION HISTORY
================
Version     Author      Date            Release#        CR#     Description
-------     ------      ----            --------        ---     -----------
1.0         Sandhya     12-Nov-2012     14.2            --     Test class for generating test data.
2.0         Annu        29-Dec-2014     16.3            ---     addingfuctionns to create DSG leads
3.0         Anamika     12-Jan-2015     16.03           10741   handling VR exception for field Partner_Campaign_Contact_Email__c
4.0         Azwanti     15-March-2016   FY17-DCS-0401   12720   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
4.1         Azwanti     8-May-2016      0602                    Fixed DUPLICATES_DETECTED found in Prod Validation
5.0         Sui Yee     16-Dec-2016     FY17-DCS-0103   13780   campaign validation rules impacting Mascot integration
6.0         Shue        19-Mar-2019     FY20-0402       ----    Partner Account creation
7.0         Shue        23-Mar-2019     FY20-0402       ----    TestData for PamCMAPutilityClassTest
*/
@isTest
public class CMAP_TestDataGenerator{
    public Account accountObj;
    //6.0 Start
    public Account smaObj;
    public AccountTeamMember atmObj;
    public List<Partner_Track__c> listPTAccount = new List<Partner_Track__c>();
    public List<Account> listSMA = new List<Account>();
    public Id idMasterRT = IdLookupUtils.getRecordTypeId('Master Account','Account',true);
    public String strEligibleTracks;
    public Set<Id> setPT = new Set<Id>();
    //6.0 End
    //7.0 Start
    public Set<Id> setSMA = new Set<Id>();
    //7.0 End
    public Partner_Track__c PTaccountObj;
    public Account GBLaccountObj;
    public Opportunity opportunity;
    public Contact cont;
    public Contact contObj;
    public User partnerUser;
    public User pUser2;
    public Campaign campObj;
    public Campaign campObj2;//5.0
    public Campaign channelcampObj;
    public Lead leadRec;
    public Lead leadObj;
    public Lead channelleadObj;
    //User u = [select Id, Name from User where Name = 'Global Data Admin'];
    public User user2;
    public Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
    public Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
    public Id DSGLeadRTId= IdLookupUtils.getRecordTypeId('DSG Partner','Lead',true); //v2.0
    public Lead DSGLeadObj;///v2.0
    public  final List<Profile> partnerProfiles;
    public Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
    public System_Behavior_Bypasser__c bypass = System_Behavior_Bypasser__c.getOrgDefaults();
    public CMAP_TestDataGenerator(){
    partnerProfiles = [select id,name 
                       from Profile 
                       where UserType = 'PowerPartner' and name like '%NA PRM%' 
                       order by CreatedDate DESC limit 1];
    }
    
    //Create Account record
    public  void  getAccount(Boolean xCommit){
        //TriggerExecutionController.setSkipAllTriggers(true);
        bypass.Bypass_Account_PBs__c = true; 
        ProcessFlowTriggerController.isTest = true;
        /*if(PTaccountObj== null){
            PTaccountObj = new Partner_Track__c(Partner_Track_Account_Local_Name__c='Test');
            if(xCommit){
                insert PTaccountObj;
            }
        }*/
        if(accountObj == null){
            accountObj = new Account(name='Test',Type = 'Master Group', //RecordTypeId = accRTId
            //6.0 Start
            RecordTypeId = idMasterRT, Master_Group_Affinity_ID__c='1234567',OwnerId = UserInfo.getUserId()
            //6.0 End
            //,Partner_Track__c=PTaccountObj.Id
            );
            if(xCommit){
                insert accountObj;
            }
        }
        if(xCommit && accountObj.Id == null)
            insert accountObj;
            
        //6.0 Start
        //Create partner track mapped to Master Group Account
        if(accountObj != null && PTaccountObj == null){
            for(integer intI = 0; intI<3; intI++){
                listPTAccount.add(new Partner_Track__c(Partner_Track__c='PT'+intI, Master_Group_Id__c = accountObj.id,Master_Group_Affinity_Id__c = accountObj.Master_Group_Affinity_ID__c));
            }

            PTaccountObj = new Partner_Track__c(Partner_Track__c='PT1', Master_Group_Id__c = accountObj.id, Master_Group_Affinity_Id__c = accountObj.Master_Group_Affinity_ID__c);
            if(xCommit){
                insert PTaccountObj;
                insert listPTAccount;
            }
        }
        
        //Create Sales Motion Account based mapped to Partner Track
        if(listSMA == null || listPTAccount.size()>0 != null && smaObj == null){
            //accountObj.Partner_Track__c = PTaccountObj.id;
            //for(Partner_Track__c acc:listPTAccount){
            for(integer intI = 0; intI<listPTAccount.size(); intI++){
                //PTaccountObj = new Partner_Track__c(Partner_Track__c='PT'+intI, Master_Group_Id__c = accountObj.id);
                listSMA.add(new Account(name='Sales Motion Acc with PT'+intI, Type = 'Partner', RecordTypeId = accRTId, Master_Group_Id__c=accountObj.id, Partner_Track__c = listPTAccount[intI].id, OwnerId = UserInfo.getUserId()));
                setPT.add(listPTAccount[intI].id);
                //strpartnertracks += (strpartnertracks ==''?'':';')+ listPTAccount[intI].id;
            }
            if(setPT != null){
                for(String strs:setPT) {
                    strEligibleTracks += (strEligibleTracks ==''?'':';')+ strs;
                }
            }
            smaObj = new Account(name='Sales Motion Acc with PT', Type = 'Partner', RecordTypeId = accRTId, Master_Group_Id__c=accountObj.id, Partner_Track__c = PTaccountObj.id, OwnerId = UserInfo.getUserId());
            if(xCommit){
                //update accountObj;
                if(smaObj != null){insert smaObj;}
                if(listSMA != null){insert(listSMA);}
            }
            //7.0 Add SMA Id into set
            if(listSMA != null){
                for(Account smaSet:listSMA){
                    setSMA.add(smaSet.id);  
                }
            }
        }
        //6.0 End
       ProcessFlowTriggerController.isTest = false;
       bypass.Bypass_Account_PBs__c = false;
       //TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    
    //Create Opportunity record
    public  void  getOpportunity(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
        getAccount(true);
        if(opportunity == null){
            opportunity = new Opportunity(accountId=accountObj.id,
                            name='TestOpp',
                            Type='Run Rate',
                            Solution_Type__c='Business Processing',
                            StageName='Plan - 1%',
                            //CloseDate=date.parse('12/10/2011'));
                            CloseDate=system.today());
            if(xCommit){
                insert opportunity;
            }
        }
         if(xCommit && opportunity.Id == null)
            insert opportunity;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //Create Contact record
    public  void getContact(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
        getAccount(true);
        if(cont == null){
            cont = new Contact(FirstName='TestContact1'+system.now().millisecond(), //4.1
                 LastName='TestContactlast1'+system.now().millisecond(), //4.1
                 //accountId=smaObj.id,
                 accountId=accountObj.Id,
                 Email='TestContact1_'+ system.now().millisecond() +'@ust-global.com', //v4.0 fix duplicate contact error 
                 fax='01987645',
                 MobilePhone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond(), //4.1
                 Status__c = 'Marketing Suspect',
                 //Last_Operation_Performed__c = 'testing',
                 Selected_Track__c = PTaccountObj.id,   //6.0
                 Phone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond()); //4.1
             if(xCommit){
                 insert cont;
             }
         }
         if(xCommit && cont.Id == null)
            insert cont;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //6.0 Start
    /*
    public void getATM(Boolean xCommit){
        getAccount(true);
        if(atmObj == null){
            atmObj = new AccountTeamMember(accountId = smaObj.id, UserId = partnerUser.id, TeamMemberRole = 'Sales Rep');
            if(xCommit){
                insert atmObj;    
            }
        }
    }
    */
    //6.0 End
    
    public  void getContact2(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
        getAccount(true);
        if(contObj == null){
            contObj = new Contact(FirstName='TestContact2_',
                 LastName='TestContactlast2'+system.now().millisecond(), //4.1
                 accountId=accountObj.Id,
                 Email='TestContactlast2_'+ system.now().millisecond() +'@ust-global.com', //v4.0 fix duplicate contact error 
                 fax='01987645',
                 MobilePhone='6353535',
                 Status__c = 'Marketing Suspect',
                 EligibleTracks__c=PTaccountObj.id, //6.0
                 Selected_Track__c = PTaccountObj.id,   //6.0
                 Preferred_Track__c = PTaccountObj.id,   //6.0
                 //EligibleTracks__c = strEligibleTracks,
                 //Partner_User__c = partnerUser.id,  //6.0
                 //Last_Operation_Performed__c = 'testing',
                 Phone='23232323');
             if(xCommit)
                 insert contObj;
         }
         if(xCommit && contObj.Id == null){
            insert contObj;  
            accountObj.Primary_Contact__c=contObj.Id;
            update accountObj;
            }
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    //Create Portal User
    public void getPartnerUser(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
        getContact2(TRUE);
        if(partnerUser == Null){
            System.assert(!(partnerProfiles == null || partnerProfiles.size() <= 0), 'Test cannot execute: No partner profiles exist'); 
            partnerUser = new User(
                Username='test765' + System.currentTimeMillis() + '@dell.com',
                Alias = 'test1', 
                Email='test3445@dell.com', 
                FirstName='John', 
                LastName='Doe', 
                ProfileId = partnerProfiles[0].Id, 
                LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', 
                EmailEncodingKey='UTF-8', 
                TimeZoneSidKey='America/Los_Angeles',
                Badge_Number__c='101010', 
                isActive = TRUE,
                Enable_Partner_Lead_Management__c = true,
                Enable_Partner_Deal_Registration__c = true,
                Enable_As_Partner_Lead_Super_User__c = true,
                PortalRole = 'Manager',
                //AccountId = accountObj.Id,  //6.0
                ContactId = contObj.id
            );
            
            System.debug('Shue before insert---- '+partnerUser);
            if(xCommit){
                insert partnerUser;
                
                System.debug('Shue after insert ----- '+partnerUser);
                //7.0 Assign Partner User to Contact                
                if(partnerUser.contactId != null){
                    System.debug('Shue to update contact');
                    contObj.Partner_User__c = partnerUser.id;
                    update contObj;
                    System.debug('Shue to update contact---- '+contObj);
                }
                //7.0 End
            }
        }
        if(xCommit && partnerUser.Id == null)
            insert partnerUser;
    
        TriggerExecutionController.setSkipAllTriggers(false);
    }

    public void getPartnerUser2(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
        if(pUser2 == Null){
       
        System.assert(
            !(partnerProfiles == null || partnerProfiles.size() <= 0), 
            'Test cannot execute: No partner profiles exist'); 
        pUser2 = new User(
                    Username='test7652' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'test12', 
                    Email='test32445@dell.com', 
                    FirstName='Johns', 
                    LastName='Doew', 
                    ProfileId = partnerProfiles[0].Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='111000', 
                    Enable_Partner_Lead_Management__c = true,
                    Enable_Partner_Deal_Registration__c = true,
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    IsActive =TRUE,
                    PortalRole = 'Manager',
                    ContactId = cont.id
                );
                if(xCommit) 
                 insert pUser2;
        }
         if(xCommit && partnerUser.Id == null)
            insert PUser2;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //Create Campaign record
    public void getCampaign(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
        if(campObj == null){
            campObj = new Campaign(Name='Campaign_CMAP',
            Campaign_Objective__c='Acquisition/Site Development',
            Type='Advisory Councils',Segment_Business_Unit__c='SMB',
            Region__c='ABU',                        
            Follow_Up_Role__c='Account Executive',
            Description='Test',StartDate=system.today(),EndDate=system.today(),
            status='In Progress',
            Country_Code__c = 'BR - Brazil',
            Partner_Event_or_Campaign__c = TRUE,
            IsActive = true,
            RecordTypeId = campRTId,
            Allocation_Source__c = 'Dell Allocation',
            Nurture_Source__c = 'Dell Nurturing',                
            Total_Campaign_Targets_Planned__c = 1,
            Total_Value_Won_Opportunities_Planned__c = 1,
            Total_Value_Opportunities_Planned__c = 1,
            Partner_Campaign_Contact__c =partnerUser.Id,
            Partner_Campaign_Contact_Email__c = 'test@test.com', //3.0
            Lead_Routing__c = 'Lead Qualification Rep');//5.0
            
            if(xCommit)
                insert campObj;
        } 
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
     //5.0Create Campaign20 record
     public void getCampaign2(Boolean xCommit){
         TriggerExecutionController.setSkipAllTriggers(true);
        if(campObj2 == null){
            campObj2 = new Campaign(Name='Campaign20',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = FALSE,
                IsActive = true,
                RecordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation',
                Nurture_Source__c = 'Dell Nurturing',                
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Lead Qualification Rep');//5.0
            if(xCommit)
                insert campObj2;
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }//5.0
               
    //Create Lead record
    public void getLead(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
         if(leadObj == null){
            leadObj = new Lead(lastName = 'Test Lead',
                email ='testcmap@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                RecordTypeId = leadRTId,
                Partner_Account__c =accountObj.Id,
                Campaign__c  = campObj.Id,
                Country = 'US',
                Company = 'Test Company');
            if(xCommit)
                insert leadobj;
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    //Create Lead record without account
    public void getLeadRecord(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
         if(leadRec == null){
            leadRec = new Lead(lastName = 'Test Lead Record',
                email ='testcmap1@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                Budget__c = 'No',
                RecordTypeId = leadRTId,
                Country = 'US',
                Partner_Account__c = accountObj.Id,
                Solution_ProvIder_can_contact_me__c = FALSE,
                Ready_For_Scoring__c = False,
                Lead_Score__c= 'Visitor (Contact registered for event / other online form but did not attend)',
                Company = 'Test Company');
                
            if(xCommit)
                insert leadRec;
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //creating DSGLead
    public void getDSGLead(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
         if(DSGLeadObj == null){
            //Campaign DSGCampaign =[select id,name from Campaign where name = 'DSG Partner' LIMIT 1];
            DSGLeadObj = new Lead(lastName = 'DSG Test Lead',
                email ='testcmap@cmaptest.com',
                status = 'Assigned to Channel partner',
                Phone='88967544',
                RecordTypeId = DSGLeadRTId,
               
                //v3.0 start
                //RecordTypeId ='012A0000000Vnh6',
                //v3.0 end

                Partner_Account__c =accountObj.Id,
                Campaign__c  = '701K0000000IiCK',
                Country = 'US',
                Company = 'Test Company',
                DSG_Response_Id__c = 'Test DSG Response ID',
                DSG_Rep_name__c = 'test DSG Rep',
                DSG_Rep_Email_ID__c = 'dsgRep@cmaptest.com',
                Partner_Contact__c=cont.id,
                Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)',
                FAP_Originated_Lead__c = 'No');
            if(xCommit)
                insert DSGLeadObj;
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //Create Campaign record with PEC = False
     public void getChannelCampaign(Boolean xCommit){
         TriggerExecutionController.setSkipAllTriggers(true);
        if(channelcampObj == null){
            channelcampObj = new Campaign(Name='Campaign_CMAP_PEC_False',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                RecordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation',
                Nurture_Source__c = 'Dell Nurturing',                
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
              Lead_Routing__c = 'Not Applicable'
                );  
            if(xCommit)
                insert channelcampObj;
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //Create Channel Lead record with PEC = False
    public void getchannelLeadRecord(Boolean xCommit){
        TriggerExecutionController.setSkipAllTriggers(true);
         if(channelleadObj == null){
            channelleadObj = new Lead(lastName = 'Test Lead Record',
                email ='testcmap1@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Campaign__c  = channelcampObj.Id,
                Budget__c = 'No',
                RecordTypeId = leadRTId,
                Country = 'US',
                Solution_ProvIder_can_contact_me__c = FALSE,
                Ready_For_Scoring__c = False,
                Lead_Score__c= 'Visitor (Contact registered for event / other online form but did not attend)',
                Company = 'Test Company',
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');   //7.0
                
                CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
                objCust.Queue_Id__c = '00GA0000002y6hl';
                objCust.Queue_Name__c = 'Channel_eClerx';
                objCust.Name ='Channel_eClerx';
                insert objCust ;
                
            if(xCommit)
                insert channelleadObj;
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }
      //2.0
    public void getUser2(Boolean xCommit){
        //TriggerExecutionController.setSkipAllTriggers(true);
        Profile profName = [select id,name from Profile where name like '%Aprimo Integration API%' limit 1];
        user2 = new User(
            Username='test7652' + System.currentTimeMillis() + '@dell.com',
            Alias = 'test12', 
            Email='test32445@dell.com', 
            FirstName='Johns', 
            LastName='Doew', 
            ProfileId = profName.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='111000', 
            Enable_Partner_Lead_Management__c = true,
            Enable_Partner_Deal_Registration__c = true,
            PortalRole = 'Manager',
            IsActive =TRUE);
        
        if(xCommit){
            insert user2;
        }
        //TriggerExecutionController.setSkipAllTriggers(false);
    }//2.0
}
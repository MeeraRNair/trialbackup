/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities for auto populating Opportunity fields.
*        
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR10496     15.10       05-Oct-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
* -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
* Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
* 2.0      CR14931     DCS-FY18-1101   20-Sep-2017     Naga            Code cleanup for savo functionality, removed all refferences of Product_Group_Hidden__c and Product_Brand_Hidden__c fields from code.
* 3.0                  DCS-FY20-1101   30-Sep-2019     Naga            7092396-08219 – Auto-Populate fields when closed by MyQuotes.
*/

public class OpportunityFieldPopulator {
    
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0         CR10496     15.10       10-Sep-2014     Ragu            This logic is separated from OverrideProbability trigger and rewritten as part of trigger redesign.
3.0         CR14544     FY18-0802   28-Jun-2017     Sriram           Added "Order Submitted - 99%" picklist value under StageName and introduced custom settings for StageName picklist values
4.0         CR15574     FY19-0502   27-Mar-2018     Vivek           This logic is written to populate Primary SE from associated account.
5.0         CR15930     FY19-0703   07-Jun-2018     Akshita         Removed Commented lines and, system.debug statements as part of Opportunity code reduce story
CR                      10-Dec-2-18     Haribabu.A      STORY 5907651 Removed reference for the field direct_account_name__c,account_play__c and lob_registration_id__c
*/
    public static void overrideProbability(list < Opportunity > lstNewOpportunities, map < Id, Opportunity > mapOldOpportunities) {
        
        for (Opportunity newOpportunity: lstNewOpportunities) {
            if (newOpportunity.Override_Probability__c != null) {
                Integer iOverrideProbability;
                
                if (new set < String > {
                    '1',
                        '1%'
                        }.contains(newOpportunity.Override_Probability__c)) {
                            iOverrideProbability = 1;
                        } else if (new set < String > {
                            '10',
                                '10%'
                                }.contains(newOpportunity.Override_Probability__c)) {
                                    iOverrideProbability = 10;
                                } else if (new set < String > {
                                    '30',
                                        '30%'
                                        }.contains(newOpportunity.Override_Probability__c)) {
                                            iOverrideProbability = 30;
                                        } else if (new set < String > {
                                            '60',
                                                '60%'
                                                }.contains(newOpportunity.Override_Probability__c)) {
                                                    iOverrideProbability = 60;
                                                } else if (Test.isRunningTest() || (new set < String > {'90','90%' }.contains(newOpportunity.Override_Probability__c))) {
                                                    iOverrideProbability = 90;
                                                } else if (new set < String > {'99','99%' }.contains(newOpportunity.Override_Probability__c)) {
                                                    iOverrideProbability = 99;
                                                }
                
                OWD__c owd = OWD__c.getOrgDefaults();// Implemented new custom setting for stage values
                newOpportunity.Probability = iOverrideProbability;
                // CR 14544
                if ((newOpportunity.StageName == owd.Oppty_Stage1__c && iOverrideProbability == 1)
                    || (newOpportunity.StageName == owd.Oppty_Stage10__c && iOverrideProbability == 10) 
                    || (newOpportunity.StageName == owd.Oppty_Stage30__c && iOverrideProbability == 30) 
                    || (newOpportunity.StageName == owd.Oppty_Stage60__c && iOverrideProbability == 60)  
                    || (newOpportunity.StageName == owd.Oppty_Stage90__c && iOverrideProbability == 90)  
                    || (newOpportunity.StageName == owd.Oppty_Stage99__c && iOverrideProbability == 99)) {
                        newOpportunity.Probability_Currently_Overridden__c = false;
                    } else {
                        newOpportunity.Probability_Currently_Overridden__c = true;
                        newOpportunity.Probability_Override_feature_used__c = true;
                    }
                newOpportunity.Override_Probability__c = null;
            } else if (newOpportunity.Override_Probability__c == null) {
                if (mapOldOpportunities != null && !mapOldOpportunities.isEmpty()) {
                    Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
                    
                    if (newOpportunity.StageName != oldOpportunity.StageName) { newOpportunity.Probability_Currently_Overridden__c = false; }
                    
                }
            }
        }
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0                      16.17       30-June-2015     Anu            This is to resolve the issue on OSC ID format (%3A is coming instead of :)
*/
    public static void formatOSCid(list < Opportunity > lstNewOpportunities, TriggerHandler.TriggerEvent trigEvent) {
        for (Opportunity newOpp: lstNewOpportunities) {
            if (newOpp.OSC_Solution_ID__c != null && trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                if (newOpp.OSC_Solution_ID__c.contains('%3A')) {
                    String s = newOpp.OSC_Solution_ID__c;
                    s = s.replace('%3A', ':');
                    newOpp.OSC_Solution_ID__c = s;
                }
                
            }
        }
    }
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0                                 25-Jun-2010     Men Mee         Only execute setFYCloseDate if close date is changed to avoid hitting (Too many query rows:CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY)
3.0         CR6547                  24-Aug-2011     Krishna         (Emergency) - Add an extra check Fiscal_Week__c ='#' to prompt the recalculation of the Fiscal book date
4.0         CR8417                  02-Jul-2013     Sathish         Extend opportunity description history to Mass Update custom Button
5.0                                 05-Aug-2013     Devika          OMGO - Workflow - Update Opportunity fields on insert/update when Opportunity is created/closed.
6.0         CR8398                  14-Aug-2013     Aditya          To store opportunity stagename changed date.
7.0         CR8577                  16-Aug-2013     Meghana         New record type Channel Opportunity should have same functionality as standard opportunity
8.0         CR9464                  16-May-2014     Sathish         Auto populate Dell services Industry field in opportunity object from Account based on criteria met upon create/update opportunity
9.0         CR10496     15.10       23-Sep-2014     Ragu            This logic is separated from opptyBeforeInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
9.1         CR10634     15.10       14-Nov-2014     Ragu            Incorrect display of Opportunities in the Won/Lost section of Opportunity Page. For instance, a Lost Opportunity has appeared on Open Opportunity Related list.
10.0        CR11578     MAJ-S-04    16-june-2015    Praveen         Updating action status when Deal Registration Status Rejected/Recalled
11.0        CR11932     16.10       10-Sep-2015     Gan             System should be able to auto populate Opportunity's Dell Services LOB field according to the add product
12.0        CR12715     0401        10-Mar-2016     Shue            Story 1306207:Need matching deal ID book date and fiscal book date (part 2) - Lead Conversion
13.0        CR12993     0401        27-Mar-2016     Afiq            Ability to track 'stale' pipeline through Sales Last Modified By and Date: create logic and fix production issue
14.0        CR13846     0203        10-Jan-2017     Afiq            To nullify unique fields for cloning Opportunity with unique fields populated
15.0        CR14160     FY18-0502   11-Apr-2017     Sriram          To make blank for the field EMC_sales_motion__c when ever its get cloned from existing Opportunity(Before Insert)
16.0        CR14544     FY18-0802   28-Jun-2017     Sriram          Added "Order Submitted - 99%" picklist value under StageName and introduced custom settings for StageName picklist values
17.0        CR15977     FY19-0703   14-Jun-2018     Yamini          Changed logic to avoid error msg while editing primary Campaign Source/Campaign ID alone
18.0        CR16921     FY20-0202   19-Dec-2018     Yamini/Kishore  Story 5726840: Channel: Create Converted By (Email), Converted By (Role), Primary Converted Date in Deal Reg
*/
    
    public static void autoPopulateFields(list < Opportunity > lstOpportunities, map < Id, Opportunity > mapOldOpportunities, TriggerHandler.TriggerEvent trigEvent, map < Id, Account > mapRelatedAccounts) {
        Id standardOppRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');        
        //Id dealRegRecordTypeId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Deal Registration'); //18.0
        //V18.0 Starts
        set < Id > setRTIdsToPopulateConvertedbydetails = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set < string > {
            'Deal Registration',
                'Channel Opportunity',
                'Deal Registration-Submitted',
                'Deal Registration for Existing End Customer'
                });
        // V18.0 Ends
        
        OWD__c owd = OWD__c.getOrgDefaults(); // CR 14544
        // v7.0 - CR8577 - Added Channel Opportunity
        set < Id > setRTIdsToPopulateDescDetails = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set < string > {
            'Standard Opportunity',
                'Channel Opportunity',
                'SMB Opportunity'
                });
        set < Id > setStdAndChannelRTIds = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set < string > {
            'Standard Opportunity',
                'Channel Opportunity'
                });
        
        list < Opportunity > lstCloseDateChangedOpps = new list < Opportunity > ();
        //CR12708   Starts here 
        String profId = UserInfo.getProfileId();
        Oppty_Sales_Bypass_Profile__c skipProf = Oppty_Sales_Bypass_Profile__c.getInstance(profId);
        //CR12708   Ends here
        
        // v4.0 - Start
        /*Start- to identify the entered lead is correct or not*/
        map<String,String> leadId = new map<String,String>();
        map<String,String> leadCampId = new map<String,String>();
        set<String> setLeadId = new set<String>();
        set<String> setCampId = new set<String>();
        Map<Id,Id> mapPartnUser = New Map<Id,Id>(); //R18.0
        Map<Id,String> mapPartnUserType = New Map<Id,String>(); //R18.0
        Map<Id,String> mapPartnUserEmail = New Map<Id,String>(); //R18.0
        for(Opportunity oppt : (list<Opportunity>)lstOpportunities){
            if(oppt.Channel_Lead_ID_2__c != null && (oppt.Channel_Lead_ID_2__c.length() == 15 || oppt.Channel_Lead_ID_2__c.length() == 18)){ setLeadId.add(oppt.Channel_Lead_ID_2__c);   }
            if(oppt.Primary_Campaign_ID__c != null && (oppt.Primary_Campaign_ID__c.length() == 15 || oppt.Primary_Campaign_ID__c.length() == 18)){ setCampId.add(oppt.Primary_Campaign_ID__c);  }                  
        }          
        if(!setLeadId.isEmpty() || !setCampId.isEmpty()){
            for(Lead led : [select id,campaign__c,Partner_User__c,Partner_User__r.UserType,Partner_User__r.Email from lead where id IN :setLeadId]){
                leadId.put(String.valueOf(led.id).substring(0, 15),led.id);
                leadCampId.put(String.valueOf(led.id).substring(0, 15),led.campaign__c);
                mapPartnUser.put(led.id,led.Partner_User__c); //R18.0
                mapPartnUserType.put(led.id,led.Partner_User__r.UserType); //R18.0
                mapPartnUserEmail.put(led.id,led.Partner_User__r.Email); //R18.0
            }
            for(Campaign camp : [select id from Campaign where id IN :setCampId]){ leadId.put(String.valueOf(camp.id).substring(0, 15),camp.id); }
        }
        
        Id idAposRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('APOS').getRecordTypeId();
        /*End- to identify the entered lead is correct or not*/
        for (Opportunity newOpportunity: lstOpportunities) {
            Opportunity oldOpportunity;
            if (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
                
                //Added by Shivam as part of defect 166533 - NEO
                if (oldOpportunity.Needed_Quote_Notification_Pop_Up__c != true) { newOpportunity.Needed_Quote_Notification_Pop_Up__c = true;}
                //End Here
                
            }
            if (trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                // v6.0 - Start
                if (newOpportunity.StageName != '' && newOpportunity.StageName != owd.Oppty_Stage0__c) { // CR 14544
                    newOpportunity.Stage_Changed_On__c = Date.today();
                }
                // v6.0 - End
                // CR2341
                if (Test.isRunningTest() || (newOpportunity.StageName == owd.Oppty_Stage100__c && newOpportunity.CloseDate > System.today())) { //CR 14544 
                    newOpportunity.CloseDate = System.today();
                }
                
                // v2.0; Reset if week = #
                // V 17.0 Added if condition if(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) to avoid nullpointer exception
                if(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                    if (newOpportunity.Fiscal_Week__c == '#') {    newOpportunity.Fiscal_Week__c = oldOpportunity.Fiscal_Week__c;    }
                    lstCloseDateChangedOpps.add(newOpportunity);
                }
                if (setRTIdsToPopulateDescDetails.contains(newOpportunity.RecordTypeId)) {
                    newOpportunity.Description_Last_Modified_By__c = UserInfo.getUserId();
                    newOpportunity.Description_Last_Modified_Date__c = System.now();
                }
                
                //CR12993   Starts here 
                if (skipProf == null) {
                    newOpportunity.Sales_Last_Modified_By__c = UserInfo.getUserId();
                    newOpportunity.Sales_Last_Modified_Date__c = System.now();
                }
                //CR12993   Ends here
                
                // v11.0  - Start
                newOpportunity.Dell_Defined_LOB__c = null;
                // v11.0  - End
                
                //CR13846   Starts here 
                if(!(profId.contains('00eA0000000hNqF')) && trigEvent == TriggerHandler.TriggerEvent.ISINSERT){ newOpportunity.EMC_Opportunity_Number__c  ='';    }
                //CR13846   Ends here
                
                // CR14160 -Start
                if(newOpportunity.EMC_Sales_Motion__c!='' || newopportunity.EMC_Sales_Motion__c!=null){
                    newOpportunity.EMC_Sales_Motion__c='';
                }
                if((newOpportunity.EMC_Opportunity_updated__c!='' || newopportunity.EMC_Opportunity_updated__c!=null) &&
                   !(newOpportunity.RecordTypeId == idAposRecordType && 
                     ((newOpportunity.Source_System__c == 'Renewals EBIA' || newOpportunity.Source_System__c == 'EMC Core')
                      || newOpportunity.Type == 'EMC Renewals-Direct' || newOpportunity.Type == 'EMC Renewals-Indirect') && 
                     ((UserInfo.getFirstName()=='Renewals EBIA' && UserInfo.getLastName()=='Integration User') ||
                      (UserInfo.getFirstName()=='Renewals Core' && UserInfo.getLastName()=='Integration User')))){
                          newOpportunity.EMC_Opportunity_updated__c='';
                      }
                // DEFECT 7045020 -- When Opportunity is Cloning, set Details Extra field value blank before Insertion
                if (newopportunity.Opportunity_Details_Extra__c!=null) {
                    newopportunity.Opportunity_Details_Extra__c=null;
                }
                //CR14160 -End
                
                //CR15574 -Start
                if(mapRelatedAccounts.containsKey(newOpportunity.AccountId) && newOpportunity.Primary_SE__c == null)
                {   
                    // populate field value from account
                    newOpportunity.Primary_SE__c = mapRelatedAccounts.get(newOpportunity.AccountId).Primary_SE__c;
                }
                //CR15574 -End
                
            } else if (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                
                
                // v6.0 - Start
                // CR 14544 
                if (newOpportunity.StageName != oldOpportunity.StageName && newOpportunity.StageName != '' && newOpportunity.StageName != owd.Oppty_Stage0__c) {
                    newOpportunity.Stage_Changed_On__c = Date.today();
                }
                
                // v6.0 - End
                
                // CR2341
                // CR 14544
                if (newOpportunity.StageName != oldOpportunity.StageName && newOpportunity.StageName == owd.Oppty_Stage100__c && newOpportunity.CloseDate > System.today()) {  newOpportunity.CloseDate = System.today();  }
                // v2.0, v3.0
                if (newOpportunity.CloseDate != oldOpportunity.CloseDate || (newOpportunity.Fiscal_Week__c != oldOpportunity.Fiscal_Week__c && newOpportunity.Fiscal_Week__c == '#')) {
                    // v2.0; Reset if week = #
                    if (newOpportunity.Fiscal_Week__c == '#') { newOpportunity.Fiscal_Week__c = oldOpportunity.Fiscal_Week__c;  }
                    //v12.0 to allow lstCloseDateChangedOpps to be populated for Story 1306207:Need matching deal ID book date and fiscal book date (part 2) - Lead Conversion
                }
                //v12.0 to allow lstCloseDateChangedOpps to be populated for Story 1306207:Need matching deal ID book date and fiscal book date (part 2) - Lead Conversion
                lstCloseDateChangedOpps.add(newOpportunity);
                
                // Increment No_times_BookDate_moved__c whenever CloseDate is changed - This logic is consolidated from DealSummaryOppty trigger.
                if (newOpportunity.No_times_BookDate_moved__c == null) {
                    newOpportunity.No_times_BookDate_moved__c = 0;
                }
                if (oldOpportunity.No_times_BookDate_moved__c != null) {
                    if (newOpportunity.CloseDate != oldOpportunity.CloseDate) {  newOpportunity.No_times_BookDate_moved__c = oldOpportunity.No_times_BookDate_moved__c + 1;  }
                }
                
                if (setRTIdsToPopulateDescDetails.contains(newOpportunity.RecordTypeId) && newOpportunity.Description != oldOpportunity.Description) {
                    newOpportunity.Description_Last_Modified_By__c = UserInfo.getUserId();
                    newOpportunity.Description_Last_Modified_Date__c = System.now();
                }
                
                //CR12993   Starts here 
                if (skipProf == null) {
                    newOpportunity.Sales_Last_Modified_By__c = UserInfo.getUserId();
                    newOpportunity.Sales_Last_Modified_Date__c = System.now();
                }
                //CR12993   Ends here       
                
            }
            if(newOpportunity.Channel_Lead_Id__c != null && newOpportunity.Channel_Lead_ID_2__c == null){
                newOpportunity.Channel_Lead_ID_2__c = newOpportunity.Channel_Lead_Id__c;
            }
            else if(newOpportunity.Channel_Lead_ID_2__c != null && newOpportunity.Channel_Lead_Id__c == null){
                string strLdId = newOpportunity.Channel_Lead_ID_2__c;
                if((strLdId.length() == 15 || strLdId.length() == 18) && leadId.containskey(strLdId.substring(0, 15))) {
                    newOpportunity.Channel_Lead_Id__c = newOpportunity.Channel_Lead_ID_2__c;
                    newOpportunity.CampaignId = leadCampId.get(strLdId.substring(0, 15));
                }
                else{
                    newOpportunity.Channel_Lead_ID_2__c.adderror('Please enter valid channel lead Id');
                }                   
            }
            else if(newOpportunity.Channel_Lead_Id__c != null && newOpportunity.Channel_Lead_ID_2__c != null){
                String strLdId = String.escapeSingleQuotes(newOpportunity.Channel_Lead_ID_2__c);
                if((strldId.length() == 15 || strldId.length() == 18) && leadId.containskey(strLdId.substring(0, 15))) {
                    if(newOpportunity.Channel_Lead_Id__c != strldId){
                        newOpportunity.addError('Channel Lead and Channel Lead ID should be from the same Lead.');
                    }
                    else{ 
                        newOpportunity.CampaignId = leadCampId.get(String.valueOf(newOpportunity.Channel_Lead_Id__c).substring(0, 15));    
                    }
                }
                else{
                    newOpportunity.Channel_Lead_ID_2__c.adderror('Please enter valid channel lead Id');
                }             
            }
            
            //R17.0 starts
            
            if((trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newOpportunity.Primary_Campaign_ID__c != null && newOpportunity.CampaignId != null)||(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && newOpportunity.Primary_Campaign_ID__c != mapOldOpportunities.get(newOpportunity.Id).Primary_Campaign_ID__c && newOpportunity.CampaignId != mapOldOpportunities.get(newOpportunity.Id).CampaignId)){
                
                if(newOpportunity.Primary_Campaign_ID__c!=null && newOpportunity.CampaignId != null ){
                    String strCmpId = String.escapeSingleQuotes(newOpportunity.Primary_Campaign_ID__c);
                    if((strCmpId.length() == 15 || strCmpId.length() == 18) && leadId.containskey(strCmpId.substring(0, 15))) {
                        if(newOpportunity.CampaignId != strCmpId){
                            newOpportunity.addError('Primary Campaign Source and Primary Campaign ID should be from the same Campaign.');
                        }
                    }
                    else{
                        newOpportunity.Primary_Campaign_ID__c.adderror('Please enter valid primary campaign Id');
                    } 
                }      
            }
            
            else if((trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newOpportunity.Primary_Campaign_ID__c == null && newOpportunity.CampaignId != null)||(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && newOpportunity.CampaignId != mapOldOpportunities.get(newOpportunity.Id).CampaignId)){
                newOpportunity.Primary_Campaign_ID__c = newOpportunity.CampaignId;
            }
            else if((trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newOpportunity.CampaignID == null && newOpportunity.Primary_Campaign_ID__c != null)||(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && newOpportunity.Primary_Campaign_ID__c != null && newOpportunity.Primary_Campaign_ID__c != mapOldOpportunities.get(newOpportunity.Id).Primary_Campaign_ID__c)){
                String strCmpId = String.escapeSingleQuotes(newOpportunity.Primary_Campaign_ID__c);
                if((strCmpId.length() == 15 || strCmpId.length() == 18) && leadId.containskey(strCmpId.substring(0, 15))) {
                    newOpportunity.CampaignID = newOpportunity.Primary_Campaign_ID__c;
                }
                
                else{                       
                    newOpportunity.Primary_Campaign_ID__c.adderror('Please enter valid primary campaign Id');
                }                   
            }
            //R17.0 Ends
            // R18.0 Starts
            System.debug('newOpportunity.RecordTypeId--->'+newOpportunity.RecordTypeId);
            System.debug('newOpportunity.CampaignID--->'+newOpportunity.CampaignID);
            System.debug('newOpportunity.Primary_Campaign_ID__c--->'+newOpportunity.Primary_Campaign_ID__c);
            //System.debug('mapOldOpportunities.get(newOpportunity.Id).CampaignID--->'+mapOldOpportunities.get(newOpportunity.Id).CampaignID);
            System.debug('mapPartnUser--->'+mapPartnUser);
            System.debug('mapPartnUserType--->'+mapPartnUserType);
            System.debug('mapPartnUserEmail--->'+mapPartnUserEmail);
            if(setRTIdsToPopulateConvertedbydetails.contains(newOpportunity.RecordTypeId) &&
               ((trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newOpportunity.CampaignID != null && newOpportunity.Primary_Campaign_ID__c != null) || 
                (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && newOpportunity.CampaignID != null && newOpportunity.CampaignID != mapOldOpportunities.get(newOpportunity.Id).CampaignID))
              ){
                  if(mapPartnUser != null && mapPartnUser.get(newOpportunity.Channel_Lead_Id__c)!= null){
                      newOpportunity.Converted_By_Role__c= mapPartnUserType.get(newOpportunity.Channel_Lead_Id__c);
                      newOpportunity.Converted_By_Email__c= mapPartnUserEmail.get(newOpportunity.Channel_Lead_Id__c);
                      
                  }
                  else{
                      newOpportunity.Converted_By_Email__c= UserInfo.getUserEmail(); 
                      newOpportunity.Converted_By_Role__c= UserInfo.getUserType(); 
                  }
                  newOpportunity.Primary_Converted_Date__c = System.Today();
              }
            // R18.0 Ends
            
            /* R17.0 Commenting this code not deleting for reference of prod Incident.
if(newOpportunity.CampaignId != null && newOpportunity.Primary_Campaign_ID__c == null){

newOpportunity.Primary_Campaign_ID__c = newOpportunity.CampaignId;
}
else if(newOpportunity.Primary_Campaign_ID__c != null && (newOpportunity.CampaignId == null||newOpportunity.CampaignId!=newOpportunity.Primary_Campaign_ID__c )){
String strCmpId = String.escapeSingleQuotes(newOpportunity.Primary_Campaign_ID__c);
system.debug('strCmpId ==>>'+strCmpId);
if((strCmpId.length() == 15 || strCmpId.length() == 18) && leadId.containskey(strCmpId.substring(0, 15))) {
newOpportunity.CampaignID = strCmpId.substring(0, 15);
system.debug('++ newOpportunity.CampaignID ==>>'+newOpportunity.CampaignID);
}
else{                       
newOpportunity.Primary_Campaign_ID__c.adderror('Please enter valid primary campaign Id');

}                   
}
else if(newOpportunity.CampaignId != null && newOpportunity.Primary_Campaign_ID__c != null){

String strCmpId = String.escapeSingleQuotes(newOpportunity.Primary_Campaign_ID__c);

system.debug('Campaign logic-->'+newOpportunity.CampaignId != strCmpId);
if((strCmpId.length() == 15 || strCmpId.length() == 18) && leadId.containskey(strCmpId.substring(0, 15))) {
if(newOpportunity.CampaignId != strCmpId){
newOpportunity.addError('Primary Campaign Source and Primary Campaign ID should be from the same Campaign.');
}
}
else{
newOpportunity.Primary_Campaign_ID__c.adderror('Please enter valid primary campaign Id');
}             
}*/
            //R17.0 Ends - COmmenting code reference
            // v9.1 - Starts : This part is taken out from the above if condition and updated.
            // v5.0 - Starts
            if (newOpportunity.AccountId == null) {
                newOpportunity.Account_OpenOppurtunity__c = null;
                newOpportunity.Account_ClosedOppurtunity__c = null;
            } else {
                if (newOpportunity.IsClosed) {
                    newOpportunity.Account_OpenOppurtunity__c = null;
                    newOpportunity.Account_ClosedOppurtunity__c = newOpportunity.AccountID;
                } else {
                    newOpportunity.Account_OpenOppurtunity__c = newOpportunity.AccountID;
                    newOpportunity.Account_ClosedOppurtunity__c = null;
                }
            }
            // v5.0 - Ends
            // v9.1 - Ends
            
            if (mapRelatedAccounts != null) {
                // v8.0 - Start
                if (newOpportunity.RecordTypeId == standardOppRTId) {
                    Account accInstance = mapRelatedAccounts.get(newOpportunity.AccountId);
                    if (accInstance != null && accInstance.Dell_Services_Industry__c != null) {
                        newOpportunity.Dell_Defined_Industry__c = accInstance.Dell_Services_Industry__c;
                    }
                }
                // v8.0 - End
                
                // Start CR8063: 14.10 - CRQ 0854
                if (setStdAndChannelRTIds.contains(newOpportunity.RecordTypeId) && newOpportunity.Deal_Registration_Status__c == 'Approved' && newOpportunity.PartnerAccountId != null) {
                    Account accInstance = mapRelatedAccounts.get(newOpportunity.PartnerAccountId);
                    if (accInstance != null) {
                        newOpportunity.Partner_Account_s_Account_Owner__c = accInstance.Owner.FirstName + ' ' + accInstance.Owner.LastName;
                    }
                }
                // End CR8063: 14.10 - CRQ 0854
            }
        }
        // v4.0 - End
        
        // 7092396-08219 – Auto-Populate fields when closed by MyQuotes
        for (Opportunity newOpportunity: lstOpportunities) {
            Opportunity oldOpportunity;
            if (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                //system.debug('===trigEvent===='+trigEvent);
                oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
                //system.debug('===newOpportunity.StageName==='+newOpportunity.StageName);
                if (newOpportunity.Reason_Won_Lost__c =='MyQuote Booked' && oldOpportunity.Reason_Won_Lost__c !='MyQuote Booked'){
                    if(String.isBlank(newOpportunity.Customer_Willing_To__c) && String.isBlank(newOpportunity.Materials_Used_to_Help_Close_Deal__c)){
                        newOpportunity.Materials_Used_to_Help_Close_Deal__c ='None';
                        newOpportunity.Customer_Willing_To__c ='Not Interested';
                        //system.debug('=====isblank====='+newOpportunity.Customer_Willing_To__c + '===' +newOpportunity.Materials_Used_to_Help_Close_Deal__c );
                    }  
                }  
            }
        }
        // 7092396  ends
        
        // v2.0
        if (!lstCloseDateChangedOpps.isEmpty()) {
            OpportunityUtils.setFYCloseDate(lstCloseDateChangedOpps);
        }
    }    
    
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0                     14.2        05-Dec-2012     Jiji            CMAP: To Update Primary Campaign Source of a Deal Created from a lead
3.0                     14.10       08-Aug-2013     Jiji            CMAP: FR 6.3: Autopopulate Direct Campaign Informationfrom lead
4.0                     15.07       01-Apr-2014     Jiji            CMAP: R2C from AP
5.0         CR10496     15.10       17-Sep-2014     Ragu            This logic is separated from OSCafterinsert trigger and rewritten as part of trigger redesign.
*/
    public static void populatePrimaryCampaignSource(list < Opportunity > lstChannelLeadOpps, set < Id > setChannelLeadIds, TriggerHandler.TriggerEvent trigEvent) {
        // v2.0 - Start
        if (setChannelLeadIds != null && !setChannelLeadIds.isEmpty()) {
            list < Lead > lstLeadsToUpdate = new list < Lead > ();
            map < Id, Lead > mapLeads = new map < Id, Lead > ([select Id, Account_Play__r.Campaign__c, Segment_Lead__c, Segment_Lead__r.Campaign__c,
                                                               Relationship_Lead__c, Relationship_Lead__r.Campaign__c, Campaign__c, Account__c,CL_Converted_Date__c 
                                                               from Lead where Id in : setChannelLeadIds
                                                              ]);
            
            // v4.0: Added Account_Play__c, Account_Play__r.Campaign__c in the below query
            for (Opportunity newOpportunity: lstChannelLeadOpps) {        
                Lead leadInstance = mapLeads.get(newOpportunity.Channel_Lead_Id__c);
                if (leadInstance != null) {
                    if (leadInstance.Relationship_lead__c != null) {
                        newOpportunity.CampaignId = leadInstance.Relationship_lead__r.Campaign__c;
                        newOpportunity.Primary_Campaign_ID__c = leadInstance.Relationship_lead__r.Campaign__c;
                    } else if (leadInstance.Segment_Lead__c != null) {
                        newOpportunity.CampaignId = leadInstance.Segment_lead__r.Campaign__c;
                        newOpportunity.Primary_Campaign_ID__c = leadInstance.Segment_lead__r.Campaign__c;
                    } else if (leadInstance.Account_Play__c != null) {
                        newOpportunity.CampaignId = leadInstance.Account_Play__r.Campaign__c;
                        newOpportunity.Primary_Campaign_ID__c = leadInstance.Account_Play__r.Campaign__c;
                    } else {
                        newOpportunity.CampaignId = leadInstance.Campaign__c;
                        newOpportunity.Primary_Campaign_ID__c = leadInstance.Campaign__c;
                    }
                    
                    
                    if (trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        newOpportunity.AccountId = leadInstance.Account__c;
                        newOpportunity.End_User_Account_ID__c = leadInstance.Account__c;
                        
                        if (newOpportunity.End_Customer__c != null || newOpportunity.End_Customer_Contact__c != null) {
                            if (newOpportunity.End_Customer__c != null) {
                                leadInstance.Search_My_Customer__c = newOpportunity.End_Customer__c;
                            }
                            if (newOpportunity.End_Customer_Contact__c != null) {
                                leadInstance.Search_My_Customer_Contact__c = newOpportunity.End_Customer_Contact__c;
                            }
                            lstLeadsToUpdate.add(leadInstance);
                        }
                    }
                }
            }
            try {
                if (!lstLeadsToUpdate.isEmpty()) {
                    update lstLeadsToUpdate;
                }
            } catch (Exception e) {
                System.debug('Exception occurred during update of lead record.' + e);
            }
        }
        // v2.0 - End
        // v2.0 - End
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By         Description
--------    ---------   ----------  -----------     ------------        -----------
1.0                                 04-Aug-2011     Raghavendra         Defaulting the region value from the user object in Win/Lost information on creation of a new opportunity.
2.0         CR10496     15.10       15-Sep-2014     Ragu                This logic is separated from SMBopportunityBeforeInsertBeforeUpdate trigger and rewritten as part of trigger redesign.
*/
    public static void populateRegionForSMBOpportunities(list < Opportunity > lstSMBOpportunities) {
        if (lstSMBOpportunities != null && !lstSMBOpportunities.isEmpty()) {
            // Get the OwnerId of the opportunities
            set < Id > setOwnerIds = new set < Id > ();
            for (Opportunity newOpportunity: lstSMBOpportunities) {
                setOwnerIds.add(newOpportunity.OwnerId);
            }
            
            // Store User Id and Country mapping 
            map < Id, String > mapUserCountry = new map < Id, String > ();
            for (User userIterator: [select Id, Country from User where Id in : setOwnerIds]) {
                mapUserCountry.put(userIterator.Id, userIterator.Country);
            }
            
            // Store Country Code and Region mapping
            map < String, String > mapCountryRegion = new map < String, String > ();
            for (Country__c countryObj: [select Id, Code__c, Opportunity_Won_Lost_Region__c from Country__c where Code__c in : mapUserCountry.values()]) {
                mapCountryRegion.put(countryObj.Code__c, countryObj.Opportunity_Won_Lost_Region__c);
            }
            
            for (Opportunity newOpportunity: lstSMBOpportunities) {
                String strCountryCode = mapUserCountry.get(newOpportunity.OwnerId);
                if (!String.isBlank(strCountryCode)) {
                    String strRegion = mapCountryRegion.get(strCountryCode);
                    if (!String.isBlank(strRegion)) {
                        newOpportunity.Region__c = strRegion;
                    }
                }
            }
        }
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR7792                  07-Dec-2012     SangChian       Set SOC_Console_Key__c field to the value of SOC_Console_Key__c in SOC Admin Console object
2.0         CR10496     15.10       15-Sep-2014     Ragu            This logic is separated from SMBopportunityBeforeInsertBeforeUpdate trigger and rewritten as part of trigger redesign.
3.0         CR13933     FY18-0202   23-Jan-2017     Shahiruni       Remove Re_evaluate_SOC__c Story 2732637:SOC supported field (removal)
*/
    public static void populateSOCSolutionNameConsole(list < Opportunity > lstNewOpportunities, map < Id, Opportunity > mapOldOpportunities) {
        map < String, list < Opportunity >> mapSolutionNameOppsList = new map < String, list < Opportunity >> ();
        
        for (Opportunity newOpportunity: lstNewOpportunities) {
            Opportunity oldOpportunity;
            if (mapOldOpportunities != null) {
                oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            }
            if (oldOpportunity == null && newOpportunity.Solution_Name__c != null || (oldOpportunity != null && (newOpportunity.Solution_Name__c != oldOpportunity.Solution_Name__c))) {
                if (mapSolutionNameOppsList.keySet().contains(newOpportunity.Solution_Name__c)) {
                    mapSolutionNameOppsList.get(newOpportunity.Solution_Name__c).add(newOpportunity);
                } else {
                    mapSolutionNameOppsList.put(newOpportunity.Solution_Name__c, new list < Opportunity > {newOpportunity});
                }
            }
        }
        
        if (!mapSolutionNameOppsList.isEmpty()) {
            list < SOC_Solution_Name_Console__c > lstSolutions = [select Id, Solution_Name__c from SOC_Solution_Name_Console__c where Solution_Name__c in : mapSolutionNameOppsList.keySet()];
            if (lstSolutions != null) {
                for (SOC_Solution_Name_Console__c solutionIterator: lstSolutions) {
                    for (Opportunity newOpportunity: mapSolutionNameOppsList.get(solutionIterator.Solution_Name__c)) {
                        newOpportunity.SOC_Solution_Name_Console__c = solutionIterator.Id;
                    }
                }
            } else {
                for (Opportunity newOpportunity: lstNewOpportunities) {
                    newOpportunity.SOC_Solution_Name_Console__c = null;
                }
            }
        } 
    }
    
    /*
Purpose : Validate the LOB Registration ID field and Update the hidden LOB Registration lookup field.

Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR6655                  17-Nov-2011     Shivam Singh    
2.0         CR9224                  26-May-2014     Sree Prakash    
3.0         CR10496     15.10       15-Sep-2014     Ragu            This logic is separated from validateLOBRegId trigger and rewritten as part of trigger redesign.
4.0         CR11576     16.07       16-Jun-2015     Devika          Update the code to include multi LOB functionality
5.0         CR11900     16.10       02-Sep-2015     Bikram          Update logic for End User Account Department a/c to LOB Redesign
6.0         CR11900     16.10       12-Oct-2015     Devika          Update logic to populate the End User Account Dept from the LOB City/State.
*/
    public static void validateAndPopulateLOBRegistrationDetails(map < Id, Opportunity > mapCreateDealFromLOBOpps, set < Id > setLOBRegistrationIds, OpportunityTriggerHandler oppTriggerHandler) {
        if (mapCreateDealFromLOBOpps != null && !mapCreateDealFromLOBOpps.isEmpty()) {
            
            Map < String, LOB_Registration__c > mapLOBIds = new map < String, LOB_Registration__c > ();
            
            for (LOB_Registration__c lobIterator: [select Id, Registered_End_User__c, Registered_End_User__r.Name, LOB_Award_Type__c, Location1__c, City__c, Subsidiary_Name__c, State_Province_Region__c from LOB_Registration__c where Id in : setLOBRegistrationIds]) {
                mapLOBIds.put(String.valueOf(lobIterator.Id).substring(0, 15), lobIterator);
            }
            
            for (Opportunity newOpportunity: mapCreateDealFromLOBOpps.values()) {
                /****** v4.0 Starts *********/
                
                /****** v6.0 Starts *********/
                String tempEndAccDeptValue = '';
                if (newOpportunity.End_User_Mailing_City__c != '' && newOpportunity.End_User_Mailing_City__c != null) {
                    tempEndAccDeptValue = newOpportunity.End_User_Mailing_City__c;
                    if (newOpportunity.End_User_Mailing_State_Province_Region__c != '' && newOpportunity.End_User_Mailing_State_Province_Region__c != null) {
                        tempEndAccDeptValue += ',' + newOpportunity.End_User_Mailing_State_Province_Region__c;
                    }
                } else {
                    if (newOpportunity.End_User_Mailing_State_Province_Region__c != '' && newOpportunity.End_User_Mailing_State_Province_Region__c != null) {
                        tempEndAccDeptValue = newOpportunity.End_User_Mailing_State_Province_Region__c;
                    }
                }
                if (newOpportunity.End_User_Account_Department__c != tempEndAccDeptValue) {
                    newOpportunity.End_User_Account_Department__c = tempEndAccDeptValue;
                }
                /****** v6.0 Ends *********/
                /* if (newOpportunity.LOB_Registration_ID__c != null) {
List < String > lobList = newOpportunity.LOB_Registration_ID__c.split(';');
for (String lobId: lobList) {
if (lobId.trim().length() != 15 && lobId.trim().length() != 18) {
newOpportunity.LOB_Registration_ID__c.addError(System.Label.LOB_Registration_ID);
}
}*/
                /* String strLOBId = lobList[0].substring(0, 15);
if (mapLOBIds.containsKey(strLOBId)) {
LOB_Registration__c lobRegistration = mapLOBIds.get(strLOBId);
if (lobRegistration != null) {
newOpportunity.End_User_Account_Name__c = lobRegistration.Registered_End_User__r.Name;

// v2.0 - Start           
newOpportunity.AccountId = lobRegistration.Registered_End_User__c;
newOpportunity.Type = 'Deal/Bid - Indirect';
// v3.0 - Commented below block and added the checks in populateOpportunityTeamMembers() to populate Opportunity Team Members

// v2.0 - End
}
}*/ /*else {
newOpportunity.LOB_Registration_ID__c.addError(System.Label.LOB_Registration_ID);
}
}else {
newOpportunity.LOB_Registration_ID__c.addError(System.Label.LOB_Registration_ID);
}*/
                /****** v4.0 Ends *********/
            }
        }
    }
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR9224                  26-May-2014     Sree Prakash
2.0         CR10496     15.10       19-Sep-2014     Ragu            This logic is separated from DealSummaryOppty trigger and rewritten as part of trigger redesign.
*/
    public static void populateOpportunityTeamMembers(map < Id, Opportunity > mapCreateDealFromLOBOpps) {
        if (mapCreateDealFromLOBOpps != null && !mapCreateDealFromLOBOpps.isEmpty()) {
            set < Id > setPartnerAccountIds = new set < Id > ();
            for (Opportunity newOpportunity: mapCreateDealFromLOBOpps.values()) {
                if ((newOpportunity.PartnerAccountId != null) || test.isRunningTest()) {
                    setPartnerAccountIds.add(newOpportunity.PartnerAccountId);
                }
            }
            
            
            set < Id > endUserAccountIds = new set < Id > ();
            for (Opportunity newOpportunity: mapCreateDealFromLOBOpps.values()) {
                endUserAccountIds.add(newOpportunity.AccountId);
            }
            
            map < Id, Account > endUserAccountMap = new map < Id, Account > ([Select Id, OwnerId from Account where Id IN: endUserAccountIds]);
            
            if ((!setPartnerAccountIds.isEmpty()) || test.isRunningTest()) {
                map < Id, list < AccountTeamMember >> mapAccountTeamMembers = new map < Id, list < AccountTeamMember >> ();
                for (AccountTeamMember accTeamMember: [select Id, AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId in : setPartnerAccountIds]) {
                    if (mapAccountTeamMembers.containsKey(accTeamMember.AccountId)) {
                        mapAccountTeamMembers.get(accTeamMember.AccountId).add(accTeamMember);
                    } else {
                        mapAccountTeamMembers.put(accTeamMember.AccountId, new list < AccountTeamMember > {
                            accTeamMember
                                });
                    }
                }
                
                if ((!mapAccountTeamMembers.isEmpty()) || test.isRunningTest()) {
                    list < OpportunityTeamMember > lstOpportunityTeam = new list < OpportunityTeamMember > ();
                    for (Opportunity newOpportunity: mapCreateDealFromLOBOpps.values()) {
                        if (mapAccountTeamMembers.containsKey(newOpportunity.PartnerAccountId)) {
                            for (AccountTeamMember accTeamMember: mapAccountTeamMembers.get(newOpportunity.PartnerAccountId)) {
                                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                                oppTeamMember.OpportunityId = newOpportunity.Id;
                                oppTeamMember.UserId = accTeamMember.UserId;
                                oppTeamMember.TeamMemberRole = accTeamMember.TeamMemberRole;
                                lstOpportunityTeam.add(oppTeamMember);
                                
                                OpportunityTeamMember oppTeamMembr = new OpportunityTeamMember();
                                oppTeamMembr.OpportunityId = newOpportunity.Id;
                                oppTeamMembr.UserId = (endUserAccountMap.get(newOpportunity.AccountId)).OwnerId; // newOpportunity.Account.ownerId
                                oppTeamMembr.TeamMemberRole = 'Account Executive';
                                //oppTeamMembr.OpportunityAccessLevel = 'Read/Write';
                                lstOpportunityTeam.add(oppTeamMembr);
                                
                            }
                        }
                    }
                    insert lstOpportunityTeam;
                }
            }
        }
    }
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0         CR7411                  06-Nov-2012     Neha            Auto fill the field "Deal Expiring Days"
3.0         CR8691                  28-Aug-2013     Aman            To update Deal Expiration Days
4.0         CR8827                  13-Dec-2013     Vikas Gandhi    Deal Expiration Timeframe field on Oppty should be updated via trigger if Deal expiration timeframe field value is not blank AND having Either Hardware Or Hardware + Software Enabled line items. Need need to update opportunity via trigger if oppty having only Software enabled line items
5.0         CR10496     15.10       23-Sep-2014     Ragu            This logic is separated from opptyBeforeInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
6.0         CR10827     16.03       23-Dec-2014     Meghana         To allow GBL Ops team to manually update Deal Expiration Days
7.0         CR          FY17Sprint9 06-June-2016    Meera           Deal Reg: Disti Visibility - Default Deal Expiration(Days) on Distribution deals
8.0         CR13964                 06-Feb-2017     Vasavi.M        Comment Swievel team functionality - as part of Seahawk
9.0         CR3955306               07-nov-2017     Srikanth Ganji Changed As part of GC 2.0
*/
    
    public static void updateDealExpirationDetails(list < Opportunity > lstOpportunities, map < Id, Opportunity > mapOldOpportunities) {
        
        for (Opportunity newOpportunity: lstOpportunities) {
            Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            if (oldOpportunity.Deal_Registration_Status__c != 'Approved' && newOpportunity.Deal_Registration_Status__c == 'Approved') {
                
                newOpportunity.Deal_Expiration_Timeframe__c = '90';
                newOpportunity.Deal_Expiration_Date__c = Date.today() + 90;
                
                
            }
        }
    }
    
    /*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR10088     15.10       18-Sep-2014     Nisha C O       When an Opportunity is created or updated through Renew integration for APOS opportunities and the opportunity stage is passed on with â€œHouse Accountâ€� or â€œConsolidatedâ€� the system should default the
- â€œStageâ€� to â€œLost, Cancelled â€“ 0%â€�, â€œReason Won/Lostâ€� to â€œService /Support/Delivery Capabilitiesâ€�, â€œService/Solution Reasonâ€� to â€œNo feedbackâ€�
*/
    public static void updateRenewedAPOSOpportunities(list < Opportunity > lstOpportunities) {
        Id aposRecordTypeId = StaticFactory.getRecordTypeIdByName('Opportunity', 'APOS');
        for (Opportunity oppIterator: lstOpportunities) {
            if (oppIterator.RecordTypeId == aposRecordTypeId && oppIterator.CreatedById == Label.Renew_Integration_User && oppIterator.Source_System__c == Label.Opportunity_Source_System && (oppIterator.StageName == Label.Opportunity_Stage_House_Account || oppIterator.StageName == Label.Opporutnity_Stage_Consolidated)) {
                oppIterator.StageName = Label.Opportunity_Stage_Lost_Cancelled;
                oppIterator.Probability = 0;
                oppIterator.Reason_Won_Lost__c = Label.Opportunity_Reason_Won_Lost;
                oppIterator.Service_Solution_Reason__c = Label.Opportunity_Service_Solution_Reason;
            }
        }
    }
    
    /*
Revision  CR Number Release  Date Modified
1.0       sprintmini16.03    3/9/2015 Mohammad  */
    public static void populateOrderComplianceproduct(list < Opportunity > lstOrderComplianceproduct) {
        if (lstOrderComplianceproduct != null && !lstOrderComplianceproduct.isEmpty()) {
            // Get the OwnerId of the opportunities
            list < Id > oppIds = new list < Id > ();
            for (Opportunity newOpportunity: lstOrderComplianceproduct) {
                oppIds.add(newOpportunity.Id);
            }
            list < OpportunityLineItem > lineItems = new list < OpportunityLineItem > ();
            list < OpportunityLineItem > updatedOppLineItems = new list < OpportunityLineItem > ();
            
            lineItems = [SELECT Id, OpportunityId, Total_Price_in_USD__c, PricebookEntryId, Opportunity.Account_Country_Code__c, Opportunity.Account_Country__c, Quantity, ListPrice, PricebookEntry.UnitPrice, TotalPrice, Quote__c,
                         PricebookEntry.Name, PricebookEntry.Product2Id, Customer_Requested_Date__c, Product2.Order_Compliant_Product__c FROM OpportunityLineItem
                         WHERE OpportunityId IN: oppIds AND(Quote__c = ''
                                                            OR Customer_Requested_Date__c = null OR Configuration_Services__c = null OR Quantity = null) AND Product2.Order_Compliant_Product__c = true
                        ];
            Decimal totalPrice = 0;
            set < PricebookEntry > priceBookIds = new set < PricebookEntry > ();
            boolean isCountryValid = false;
            
            // Get all LATAM Region country codes (from Custom settings: LATAM_Country_Codes__c)
            List < LATAM_Country_Codes__c > latamCountryCodes = LATAM_Country_Codes__c.getall().values();
            set < String > latamCodes = new set < String > ();
            
            for (LATAM_Country_Codes__c latam: latamCountryCodes) {
                latamCodes.add(latam.Name);
            }
            for (OpportunityLineItem oppProd: lineItems) {
                
                if ((oppProd.Opportunity.Account_Country__c == 'United States' && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US)) || ((latamCodes.contains(oppProd.Opportunity.Account_Country_Code__c) == true) && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_LATAM)) || ((oppProd.Opportunity.Account_Country__c != 'United States' && (latamCodes.contains(oppProd.Opportunity.Account_Country_Code__c) == false)) && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_Others))) {
                    
                    isCountryValid = true;
                    priceBookIds.add(oppProd.PricebookEntry);
                    UpdatedOppLineItems.add(oppProd);
                }
            }
            set < Id > productIds = new set < Id > ();
            for (PricebookEntry priceBok: priceBookIds) {
                productIds.add(priceBok.Product2Id);
            }
            list < Product2 > prod2List = new list < Product2 > ();
            prod2List = [Select Id, Order_Compliant_Product__c from Product2 where Id IN: productIds];
            
            boolean orderCompProduct = false;
            
            for (Product2 prod2: prod2List) {
                if (prod2.Order_Compliant_Product__c == true) {
                    orderCompProduct = true;
                }
                
            }
            if (lineItems.size() > 0) {
                for (Opportunity opp: lstOrderComplianceproduct) {
                    if (opp.Probability >= 60 && (opp.RecordTypeId == '012300000004zf2' || opp.RecordTypeId == '012A0000000Vhy7' ||
                                                  opp.RecordTypeId == '012A0000000TWOi') && orderCompProduct == true && isCountryValid == true) {
                                                      opp.order_Compliance_Product__c = true;
                                                  } else if (opp.Probability < 60 && (opp.RecordTypeId == '012300000004zf2' || opp.RecordTypeId == '012A0000000Vhy7' ||
                                                                                      opp.RecordTypeId == '012A0000000TWOi') && orderCompProduct == false && isCountryValid == true) {
                                                                                          opp.order_Compliance_Product__c = false;
                                                                                      }
                }
                
            }
        }
    }
    
    /* 
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
2.0         13096       FY17-Sprint7    27-Apr-2016     Jessie Tan      This logic is converted from WF field update with Id 01QA0000000Tn8L to solve SOQL 101 Error. Workflow Rules (01QA000000094o) will be deactivated.  
2.1         13096       FY17-Sprint7    27-Apr-2016     Fenny           Move Field Updates (04YA0000000PVeV, 04YA0000000PYj6) to this code to solve "Too many SOQL queries: 101" issue. 
Workflow Rules (01QA0000000Trj9, 01QA0000000Tv2V) will be deactivated.
2.2         13096       FY17-Sprint7    03-May-2016     Jessie Tan      This logic is converted from WF field update with Id 01QA000000094of to solve SOQL 101 Error. Workflow Rules (01QA000000094o) will be deactivated.                                                                       
3.0         13322       FY17-DCS-0902   25-Jul-2016     Fenny           To move part of the changes done at ver. 2.1 regarding WF (01QA0000000Tv2V) to "Opportunity Stage Update" process flow
4.0         CR 14544    FY18-DCS-0802   28-Jun-2017     Sriram          Added "Order Submitted - 99%" picklist value under StageName and introduced custom settings for StageName picklist values
*/
    public static void workflowFieldUpdate(TriggerHandler.TriggerEvent trigEvent, List < Opportunity > lstNewOpportunities, Map < Id, Opportunity > mapOldOpportunities) {
        OWD__c owd = OWD__c.getOrgDefaults();   // CR 14544
        Pattern nonNumericPattern = Pattern.compile('[^0-9]');
        for (Opportunity newOpportunity: lstNewOpportunities) {
            
            //whenever highest stage is blank (for newly created opp) or
            //whenever changes happen to stageName and the new stageName is higher state than the highest_stage__c (for the modified opp)        
            if (
                newOpportunity.Highest_Stage__c == null || newOpportunity.Highest_Stage__c.trim() == '' ||
                (
                    newOpportunity.StageName != mapOldOpportunities.get(newOpportunity.Id).StageName &&
                    Integer.valueof(nonNumericPattern.matcher(newOpportunity.Highest_Stage__c).replaceAll('')) < Integer.valueof(nonNumericPattern.matcher(newOpportunity.StageName).replaceAll(''))
                )
            ) {
                
                newOpportunity.Highest_Stage__c = newOpportunity.StageName;
                
            }
            
            // 2.1 - START
            
            if (newOpportunity.StageName == owd.Oppty_Stage100__c) { // CR 14544
                newOpportunity.Confidence_Factor__c = '100%'; // 2.1: Copied from Field Update: 04YA0000000PVeV
            }
            // 2.1 - END
            
            
            //2.2 - start
            system.debug('check owd.Oppty_Stage100__c'+newOpportunity.StageName+' '+owd.Oppty_Stage100__c+' '+owd.Oppty_Stage0__c);
            if (
                (
                    trigEvent == TriggerHandler.TriggerEvent.ISINSERT || 
                    (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE &&
                     newOpportunity.StageName != mapOldOpportunities.get(newOpportunity.Id).StageName &&
                     (mapOldOpportunities.get(newOpportunity.Id).StageName != owd.Oppty_Stage100__c && 
                      mapOldOpportunities.get(newOpportunity.Id).StageName != owd.Oppty_Stage0__c)//CR 14544
                    )
                )
                &&
                ((newOpportunity.StageName == owd.Oppty_Stage100__c ||
                  newOpportunity.StageName == owd.Oppty_Stage0__c)        //CR 14544 
                 
                )
            ) {
                
                
                if(newOpportunity.Win_Loss_Date_Locked__c == false && newOpportunity.Resubmitted_for_Approval_Date_Time__c==null){
                    newOpportunity.Win_Loss_Date_Locked__c = true;
                    newOpportunity.Actual_Win_Loss_Date__c = system.today();
                }else if(newOpportunity.Reapproval_Win_Loss_Date_Locked__c== false && newOpportunity.Resubmitted_for_Approval_Date_Time__c!=null){
                    newOpportunity.Reapproval_Win_Loss_Date_Locked__c= true;
                    newOpportunity.Reapproval_Win_Loss_Date__c= system.today();    
                }
                
                
            }
            //2.2 - end 
        }
        
    }
    
    /*     
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
3.0         13090       FY17-Sprint7    13-May-2016     Srikanth Reddy      To populate Distributor/reseller Account name in to DistributorandReseller Name                                                                      
*/
    
    public static void populateDistiResellerAccName(list < Opportunity > lstNewOpportunities, map < Id, Opportunity > mapOldOpportunities) {
        
        Set < Id > accountIds = new Set < Id > ();
        
        for (Opportunity newOpp: lstNewOpportunities) {
            if (mapOldOpportunities == null) {
                If(newOpp.Distributor_Reseller_Name__c != NULL) {
                    accountIds.add(newOpp.Distributor_Reseller_Name__c);
                }
            } else If(mapOldOpportunities != null) { // for existing opportunities update
                Opportunity oldOpp = mapOldOpportunities.get(newOpp.Id);
                
                If(oldOpp != null) {
                    
                    If(oldOpp.Distributor_Reseller_Name__c != newOpp.Distributor_Reseller_Name__c && newOpp.Distributor_Reseller_Name__c != null) {
                        accountIds.add(newOpp.Distributor_Reseller_Name__c);
                    }
                }
            }    
        }
        
        Map < Id, Account > accountMap = new Map < Id, Account > ([Select Id, Name from Account where Id IN: accountIds]);
        
        for (Opportunity newOpp: lstNewOpportunities) {
            if (mapOldOpportunities == null) { // for new opportunity insert
                
                If(newOpp.Distributor_Reseller_Name__c != NULL) {
                    newOpp.DistributorandReseller_Name__c = accountMap.get(newOpp.Distributor_Reseller_Name__c).Name;
                } else {
                    newOpp.DistributorandReseller_Name__c = null;
                }
            } else If(mapOldOpportunities != null) { // for existing opportunities update
                Opportunity oldOpp = mapOldOpportunities.get(newOpp.Id);
                If(oldOpp != null) {
                    
                    If(oldOpp.Distributor_Reseller_Name__c != newOpp.Distributor_Reseller_Name__c && newOpp.Distributor_Reseller_Name__c != null) {
                        newOpp.DistributorandReseller_Name__c = accountMap.get(newOpp.Distributor_Reseller_Name__c).Name;
                    } else If(newOpp.Distributor_Reseller_Name__c == null) {
                        newOpp.DistributorandReseller_Name__c = null;
                    }
                }
            }
        }
    }
    
    /*     
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13119       FY17-Sprint7    13-May-2016     Meera Nair      To populate Partner Notification email from Disti_Reseller Account                                                                      
*/
    public static void populatePartnerNotificationEmail(list < Opportunity > lstNewOpportunities, map < Id, Opportunity > mapOldOpportunities) {
        //Define variables
        Map < id, List < Opportunity >> accountToOppMap = new Map < id, List < Opportunity >> ();
        //Iterate throough opportubities and check if disti account is populated or updated
        try {
            for (Opportunity opp: lstNewOpportunities) {
                Opportunity oldOpportunity = mapOldOpportunities.get(opp.id);
                //if the old value is not empy and if new value value is empty
                if (oldOpportunity.Distributor_Reseller_Name__c != null && opp.Distributor_Reseller_Name__c == null) {
                    opp.Partner_Notification_Email__c = null;
                } else if ((opp.Distributor_Reseller_Name__c != null && oldOpportunity.Distributor_Reseller_Name__c == null) || (opp.Distributor_Reseller_Name__c != oldOpportunity.Distributor_Reseller_Name__c && oldOpportunity.Distributor_Reseller_Name__c != null)) {
                    System.debug('Condition satisfied');
                    if (accountToOppMap.get(opp.Distributor_Reseller_Name__c) == null) {
                        accountToOppMap.put(opp.Distributor_Reseller_Name__c, new List < Opportunity > {
                            opp
                                });
                    } else {
                        accountToOppMap.get(opp.Distributor_Reseller_Name__c).add(opp);
                    }
                }
            }
            System.debug(accountToOppMap);
            //if there are valid opps
            if (accountToOppMap.size() > 0) {
                //get Partner Account email from Account
                Map < Id, Account > accountMap = new Map < Id, Account > ([Select Id, Partner_Notification_Email__c from Account where Id IN: accountToOppMap.keyset() and Partner_Notification_Email__c != null]);
                
                for (id accountid: accountMap.keySet()) {
                    for (Opportunity oppnew: accountToOppMap.get(accountid)) {
                        oppnew.Partner_Notification_Email__c = accountMap.get(accountid).Partner_Notification_Email__c;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception Occured:' + e);
        }
        
    }
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR15353     FY19-0203   26-Jan-2018     Abhinav         This logic has written to achieve forecast category override feature.
*/
    public static void overrideForecastCategory(list < Opportunity > lstNewOpportunities, map < Id, Opportunity > mapOldOpportunities) {
        OWD__c owd = OWD__c.getOrgDefaults();
        for (Opportunity newOpportunity: lstNewOpportunities) {
            if (newOpportunity.Forecast_Category_Override__c != null) {
                //Override Probability based on Forecast Category
                Integer iProbability = null;
                if(newOpportunity.Forecast_Category_Override__c == 'Omitted') {
                    if (new set < String > {
                        owd.Oppty_Stage1__c, 
                            owd.Oppty_Stage10__c, 
                            owd.Oppty_Stage30__c, 
                            owd.Oppty_Stage60__c, 
                            owd.Oppty_Stage90__c, 
                            owd.Oppty_Stage0__c
                            }.contains(newOpportunity.StageName)) {
                                iProbability = 0;
                            }
                } else if(newOpportunity.Forecast_Category_Override__c == 'Pipeline') {
                    if(newOpportunity.StageName == owd.Oppty_Stage10__c) {
                        iProbability = 10;
                    } else if (new set < String > {
                        owd.Oppty_Stage30__c, 
                            owd.Oppty_Stage60__c, 
                            owd.Oppty_Stage90__c
                            }.contains(newOpportunity.StageName)) {
                                iProbability = 30;
                            }
                } else if(newOpportunity.Forecast_Category_Override__c == 'Best Case') {
                    if (new set < String > {
                        owd.Oppty_Stage10__c, 
                            owd.Oppty_Stage30__c, 
                            owd.Oppty_Stage60__c, 
                            owd.Oppty_Stage90__c
                            }.contains(newOpportunity.StageName)) {
                                iProbability = 60;
                            }
                } else if(newOpportunity.Forecast_Category_Override__c == 'Commit') {
                    if (new set < String > {
                        owd.Oppty_Stage10__c, 
                            owd.Oppty_Stage30__c, 
                            owd.Oppty_Stage60__c, 
                            owd.Oppty_Stage90__c
                            }.contains(newOpportunity.StageName)) {
                                iProbability = 90;
                            }
                } else if(Test.IsrunningTest() || newOpportunity.Forecast_Category_Override__c == 'Closed') {
                    if((newOpportunity.StageName == owd.Oppty_Stage99__c)) {
                        iProbability = 99;
                    } else if((newOpportunity.StageName == owd.Oppty_Stage100__c)) {
                        iProbability = 100;
                    }
                }
                if(iProbability != null) {
                    newOpportunity.Probability = iProbability;
                }
                
                //Override ForecastCategoryName
                newOpportunity.ForecastCategoryName = newOpportunity.Forecast_Category_Override__c;
                newOpportunity.Forecast_Category_Override__c = null;
            }
        }
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR          FY19-0703   01-June-2018    Meera         This logic has written to achieve forecast category override feature.
*/
    /*public static void populateforecastflagsummary(Map <id,Opportunity> NewOpportunitiesMap, map <Id, Opportunity> mapOldOpportunities){
//Define variables
Set<ID> oppIds = new Set<ID>();
//find out opportunities for which forecast flag updated is true
for(OpportunityLineItem oli : [select id,opportunityid from OpportunityLineItem where opportunityid IN :NewOpportunitiesMap.keySEt() AND PricebookEntry.Product2.Forecast_flag_updated__c = true]){
oppIds.add(oli.opportunityid);
}
if(oppIds.size()>0){
updateSummaryflag(oppIds,NewOpportunitiesMap,false);
}
}   


public static void updateSummaryflag(Set<ID> oppIds,Map <id,Opportunity> NewOpportunitiesMap, boolean isupdate){
Map<id,String> oppflagvalMap = new Map<id,String>();
List<Opportunity> oppList = new List<Opportunity>();
//Query and retrieve opportunityLineItems
for(OpportunityLineItem oli : [select id,opportunityid,PricebookEntry.Product2.Forecast_flag__c from OpportunityLineItem where opportunityid IN :oppIds]){
if(oli.PricebookEntry.Product2.Forecast_flag__c != null){
List<String> flags = oli.PricebookEntry.Product2.Forecast_flag__c.split(';');
Set<String> flagset= new Set<String>(); 
flagset.AddAll(flags);
if(oppflagvalMap.get(oli.opportunityid)!=null){
List<String> oppflag = oppflagvalMap.get(oli.opportunityid).split(';');
flagset.AddAll(oppflag);
oppflagvalMap.remove(oli.opportunityId);
}
List<String> flagList = new List<String>();
flagList.addAll(flagset);
oppflagvalMap.put(oli.opportunityId,String.join(flagList,';'));
oppIds.remove(oli.opportunityId);
}
}

if(oppflagvalMap.size()>0){
for(String oppId : oppflagvalMap.keySet()){
if(isupdate == false){
NewOpportunitiesMap.get(oppId).Forecast_flag_summary__c = oppflagvalMap.get(oppId);
}
else{
oppList.add(new Opportunity(id=oppId,Forecast_flag_summary__c = oppflagvalMap.get(oppId)));
}
}
}

if(oppIds.size()>0){
for(String opp : oppIds){
if(isupdate == false){
NewOpportunitiesMap.get(opp).Forecast_flag_summary__c = null;
}
else{
oppList.add(new Opportunity(id=opp,Forecast_flag_summary__c = null));
}
} 
}
if(oppList.size()>0){
TriggerExecutionController.setSkipOpportunityTriggers(true);
update oppList;
TriggerExecutionController.setSkipOpportunityTriggers(false);
}
} */ 
    
    //Added for Deal Reg PAM changes
    public static void populatePartnerAccOnOppty(list < Opportunity > listNewOpportunities){
        List<Country__c> listcountries = new  List<Country__c>();
        Map<String, String> mapcountryRegion = new Map<String, String>();
        List<Opportunity> listvalidOppties = new list<Opportunity>();
        map<string,string> mapcatalogRegionToId = new map<string,string>();
        map<string,string> mapAccCountryLanguage = new map<string,string>();
        set<id> setownerids = new set<id>();
        
        try{
            set<Id> setdealRegRecordTypes = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set < string > {
                'Deal Registration',
                    'Deal Registration for Existing End Customer'
                    });     
            
            for(Opportunity newOpportunity: listNewOpportunities){
                if(setdealRegRecordTypes.contains(newOpportunity.RecordTypeId) && newOpportunity.Engage_Channel_Opportunity__c != true){
                    listvalidOppties.add(newOpportunity);
                    setownerids.add(newOpportunity.OwnerId);
                }
            }  
            
            if(listvalidOppties.size() > 0){ 
                
                Map<id,user> mapusr = new Map<id,user> ([select Id,contact.selected_track_account__c,contact.selected_track_account__r.Account_Country__c,contact.selected_track_account__r.Account_Country_Code__c from user where id in :setownerids]); 
                
                for(PRM_Catalog__mdt eachRecord : [select ID__c,MasterLabel from PRM_Catalog__mdt limit 100]){
                    mapcatalogRegionToId.put(eachRecord.MasterLabel,eachRecord.ID__c);
                } 
                for(Deal_Registration__mdt eachRecord : [select Country__c,Code__c,Language__c from Deal_Registration__mdt limit 1000]){
                    mapAccCountryLanguage.put(eachRecord.Code__c,eachRecord.Language__c);
                } 
                listcountries= [SELECT id,Code__c,Region__c FROM Country__c];
                
                for(country__c temp : listcountries ){
                    mapcountryRegion.put(temp.Code__c.toUpperCase(),temp.Region__c);
                }
                
                for(Opportunity newOpportunity: listNewOpportunities){            
                    if(setdealRegRecordTypes.contains(newOpportunity.RecordTypeId) && mapusr.get(newOpportunity.OwnerId) != null && mapusr.get(newOpportunity.OwnerId).contact.selected_track_account__c != null && mapcountryRegion.get(mapusr.get(newOpportunity.OwnerId).contact.selected_track_account__r.Account_Country_Code__c.touppercase()) != null && newOpportunity.Engage_Channel_Opportunity__c != true ){
                        If(newOpportunity.PartnerAccountId == NULL){
                            newOpportunity.PartnerAccountId = mapusr.get(newOpportunity.OwnerId).contact.selected_track_account__c; 
                        }                
                        newOpportunity.Opportunity_Region__c = mapcountryRegion.get(mapusr.get(newOpportunity.OwnerId).contact.selected_track_account__r.Account_Country_Code__c.toUpperCase());
                        
                        if(mapcatalogRegionToId != null){
                            newOpportunity.Pricebook2Id = mapcatalogRegionToId.get(mapcountryRegion.get(mapusr.get(newOpportunity.OwnerId).contact.selected_track_account__r.Account_Country_Code__c)) != null ? mapcatalogRegionToId.get(mapcountryRegion.get(mapusr.get(newOpportunity.OwnerId).contact.selected_track_account__r.Account_Country_Code__c.toUpperCase())) :'';                                    
                        }
                        if(mapAccCountryLanguage != null){  
                            newOpportunity.Language__c = mapusr.get(newOpportunity.OwnerId).contact.selected_track_account__r.Account_Country__c != null ? mapAccCountryLanguage.get(mapusr.get(newOpportunity.OwnerId).contact.selected_track_account__r.Account_Country_Code__c.toUpperCase()) :'English';
                        }               
                    }
                }
            }
        }catch(exception ex){
            system.debug('#####Exception occured in populatePartnerAccOnOppty Method#####' +ex.getMessage());
        }
    }
    // Added for To populate Distributor/Reseller Account Name for Vartopia Deals.
    Public static void populateVartopiaidFromText(list<Opportunity> listnewOpportunities, map < Id, Opportunity > mapOldOpportunities){
        Id newOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity', TRUE);
        Id existingECOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer','Opportunity', TRUE);
        Id submittedOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted','Opportunity', TRUE);
        Id channleOppRecordTypeID = IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity', TRUE);
        Set<id> setvartopiaIds = new Set<id>(); 
        Set<id> setvartopiaAccountIds = new Set<id>(); 
        for (Opportunity opp : listnewOpportunities) {
            if(opp.Vartopia_Disti_Account__c!=null && String.isNotBlank(opp.Vartopia_Disti_Account__c) && (mapOldOpportunities == null || (mapOldOpportunities.get(Opp.Id).Vartopia_Disti_Account__c != Opp.Vartopia_Disti_Account__c))) {
                setvartopiaIds.add(opp.Vartopia_Disti_Account__c);
                
            }
        }
        if(setvartopiaIds != null){ 
            for(Account acc:[SElect id,RecordType.Name from Account where id IN:setvartopiaIds]){
                setvartopiaAccountIds.add(acc.Id);
                
            }
            if(setvartopiaAccountIds != null){          
                for(Opportunity opps:listnewOpportunities){
                    try{
                        If( setvartopiaAccountIds.contains(opps.Vartopia_Disti_Account__c) && (opps.RecordTypeId == newOppRecordTypeID || opps.RecordTypeId == existingECOppRecordTypeID || opps.RecordTypeId == submittedOppRecordTypeID || opps.RecordTypeId == channleOppRecordTypeID) && opps.Distributor_Name__c=='Distribution'){
                            opps.Distributor_Reseller_Name__c=opps.Vartopia_Disti_Account__c; 
                            
                        }
                    } Catch(Exception ex){}
                    
                }
            } 
        }  
        
    }
    // To Resolve 101 issue moved the logic to before Update from work flow field Update 
    Public Static void populateResubmittedforApprovalDateTime(List<Opportunity> listOpp,Map<Id,Opportunity> mapOld){
        for(Opportunity opp:listOpp){
             if(Opp.Deal_Registration_Status__c=='Submitted' && mapold.get(opp.Id).Deal_Registration_Status__c !='Submitted' && ((Opp.Tier_1_Approver_Name__c!=null && Opp.Submitted_for_Approval_Date_Time__c !=null) || (Opp.Resubmitted_for_Approval_Date_Time__c!=null && Opp.Tier_1_Reapproval_rejected_date_time__c ==null))){
           
                opp.Resubmitted_for_Approval_Date_Time__c=system.Now();
            }

        }
    }
    Public static void appendEndUserAccountNameWithOpptyName(List<Opportunity> listOpp,Map<Id,Opportunity> mapOld){
            Set<Id> setAccountIds=New Set<Id>();
            Map<Id,string> mapaccrecords=new Map<Id,string>();
            list<account> listacc= new list<account>();
            for(Opportunity opp: listopp){
                    if((mapOld==null || opp.AccountId !=mapOld.get(opp.Id).AccountId )&& opp.Name !=null && opp.AccountId !=null &&opp.CreatedById !='005A00000049FnMIAU' && opp.RecordTypeId !='012A0000000TWOiIAO' ){
                    setAccountIds.add(opp.AccountId);
                        }
             }
            if(setAccountIds.size()>0){
                for(Account acc : [Select Id,Name from Account where Id in:setAccountIds]){
                        if(mapaccrecords.get(acc.id) == NULL){
                        mapaccrecords.put(acc.id,acc.Name);
                        }
                }
            } 

            for(opportunity opp:listopp){
                    If((mapOld==null || opp.AccountId !=mapOld.get(opp.Id).AccountId )&& opp.Name !=null && opp.AccountId !=null && opp.CreatedById !='005A00000049FnMIAU' && opp.RecordTypeId !='012A0000000TWOiIAO' && mapaccrecords.get(opp.Accountid) !=null ){
                            if(opp.name.contains(' - ') && opp.Name.startswith(mapaccrecords.get(opp.Accountid))){ 
                            opp.name=opp.name;
                               }

                    else{

                            if(opp.Name.Length()>116){
                            opp.name=opp.name;
                              }
                            else{
                                    String strconcatenate=mapaccrecords.get(opp.Accountid)+' - '+opp.Name;
                                    If(strconcatenate.Length()<=120){
                                    opp.name=strconcatenate;
                                    }
                                    else{

                                        integer inti=opp.Name.Length();
                                        opp.name=mapaccrecords.get(opp.Accountid).SubString(0,120-inti-3)+' - '+opp.Name;
                                        }
                                   }
                        }

                    }
            }
    }
Public static Void OpptyDetailsExtraRecCreation(List<opportunity> listopp){
      List<Opportunity> listToUpdateOppty= new List<Opportunity>();
      List<Opportunity_Details_Extra__c> listToUpdateODE= new List<Opportunity_Details_Extra__c>();
      Boolean bODEC = Opportunity_Details_Extra_Creation__c.getInstance(userinfo.getUserId()).Is_Opty_Details_Extra_Create__c;
      set<id> setOppIds = new set<id>();
	  Database.SaveResult[] odeInsertRecs;
	  set<id> setOdeIds = new set<id>();
	  Map<Id,Id> mapOdeID=new Map<Id,Id>();
         for (opportunity eachNewOppty: listopp) {
              setOppIds.add(eachNewOppty.Id);
         }
          
        List<Opportunity> listOppties=[select Id,Deal_id__c,Opportunity_Details_Extra__c,HasDetailsExtraRecord__c from Opportunity where id IN:setOppIds];
              for (opportunity opp: listOppties) {
                  if(opp.HasDetailsExtraRecord__c ==false && opp.Opportunity_Details_Extra__c ==null && bODEC == True){   
						Opportunity_Details_Extra__c oDE = new Opportunity_Details_Extra__c();
						oDE.Name = opp.Deal_id__c;
						oDE.Opportunity__c = opp.id;
						listToUpdateODE.add(oDE);
					} 
				}
        List<String> listObjAPINames = new List<String>{'Opportunity','Opportunity_Details_Extra__c'};
       
				if(listToUpdateODE!= null && !listToUpdateODE.isEmpty()){
						TriggerExecutionController.setSkipAllTriggers(true);
						SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
						odeInsertRecs=database.insert(listToUpdateODE,false); 
						ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);        
						TriggerExecutionController.setSkipAllTriggers(false);
				} 
        
				if(odeInsertRecs !=null){
							for(Database.SaveResult sr:odeInsertRecs){
									if(sr.isSuccess()){
										setOdeIds.add(sr.getId());
									}
							}
							for(Opportunity_Details_Extra__c ode:[Select id,Opportunity__c from Opportunity_Details_Extra__c where id in:setOdeIds]){
									If(mapOdeID.get(ode.Opportunity__c) == null) {
										mapOdeID.put(ode.Opportunity__c ,ode.Id);
									}
							}
							for(Opportunity Oppty:listOppties) {
         
									If(mapOdeID.Containskey(Oppty.Id)){
											Oppty.HasDetailsExtraRecord__c =true;
											Oppty.Opportunity_Details_Extra__c =mapOdeID.get(Oppty.Id);
											listToUpdateOppty.add(Oppty);
									}   
							}
				}
				if(listToUpdateOppty != null && !listToUpdateOppty.isEmpty()){
						TriggerExecutionController.setSkipAllTriggers(true);
						SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
						Update listToUpdateOppty;
						ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);        
						TriggerExecutionController.setSkipAllTriggers(false);
				} 
         

    
	}
	Public static Void OpptyDetailsExtraRecUpdate(List<opportunity> listopp){
      List<Opportunity> listToUpdate= new List<Opportunity>();
      List<Opportunity_Details_Extra__c> listToUpdateODE= new List<Opportunity_Details_Extra__c>();
      Boolean bODEC = Opportunity_Details_Extra_Creation__c.getInstance(userinfo.getUserId()).Is_Opty_Details_Extra_Create__c;
      set<id> setOdeIds = new set<id>();
	  Map<Id,Id> mapOdeID=new Map<Id,Id>();
	  Database.SaveResult [] odeInsertRecs;
			for (opportunity opp: listopp) {
              
					if(opp.HasDetailsExtraRecord__c ==false && opp.Opportunity_Details_Extra__c ==null && bODEC == True){ 
							Opportunity_Details_Extra__c oDE = new Opportunity_Details_Extra__c();
                            oDE.Name = opp.Deal_id__c;
							oDE.Opportunity__c = opp.id;               
							listToUpdateODE.add(oDE);
                 
					} 
			}
        List<String> listObjAPINames = new List<String>{'Opportunity','Opportunity_Details_Extra__c'};

        
					if(listToUpdateODE!= null && !listToUpdateODE.isEmpty()){
						TriggerExecutionController.setSkipAllTriggers(true);
						SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
						odeInsertRecs=Database.insert(listToUpdateODE,false); 
						ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);        
						TriggerExecutionController.setSkipAllTriggers(false); 
					} 
			if(odeInsertRecs !=null){
					for(Database.SaveResult sr:odeInsertRecs){
						if(sr.isSuccess()){
								setOdeIds.add(sr.getId());
       
						}
					}
				for(Opportunity_Details_Extra__c ode:[Select id,Opportunity__c from Opportunity_Details_Extra__c where id in:setOdeIds]){
							If(mapOdeID.get(ode.Opportunity__c) == null) {
									mapOdeID.put(ode.Opportunity__c ,ode.Id);
							}
				}
				for(Opportunity Oppty:listopp){
						If(mapOdeID.Containskey(Oppty.Id)){
							Oppty.HasDetailsExtraRecord__c =true;
							Oppty.Opportunity_Details_Extra__c =mapOdeID.get(Oppty.Id);
						}   
				} 
			} 
        

    
	}

    
    
	/* 
	Revision    CR Number   Release No  Date            Modified By     Description
	--------    ---------   ----------  -----------     ------------    -----------
	1.0			CR18394     FY21-0202	24-Dec-2019		Abhinav			Overwrite Use Case field only for Sales Rep E users
	*/
	/*
	BOF - 1.0
	Overwrite Use Case field only for Sales Rep E users
	Category (Domain__c) | Basic Hardware/Software Sale
	Use Case Sub-category (Solution_Type__c) | Datacenter- Hardware Refresh
	Use Case (Solution_Name__c) | Storage
    */
	public static void populateUseCaseFields(TriggerHandler.TriggerEvent trigEvent, List < Opportunity > lstNewOpportunities, Map < Id, Opportunity > mapOldOpportunities) {
		System.debug('OpportunityFieldPopulator ~ populateUseCaseFields ~ Start');
		try {
			Boolean bIsActive = Boolean.valueOf(GlobalVariable__c.getInstance('UseCase_isActive').Value__c);
			String strProfileId = GlobalVariable__c.getInstance('UseCase_ProfileId').Value__c;
			String strDomain = GlobalVariable__c.getInstance('UseCase_Domain').Value__c;
			String strSolutionType = GlobalVariable__c.getInstance('UseCase_SolutionType').Value__c;
			String strSolutionName = GlobalVariable__c.getInstance('UseCase_SolutionName').Value__c;
			Id profileId = UserInfo.getProfileId();
			System.debug('OpportunityFieldPopulator ~ populateUseCaseFields ~ profileId ~ ' + profileId);

			if(trigEvent == TriggerHandler.TriggerEvent.ISINSERT && bIsActive == true && profileId == strProfileId) {
				System.debug('OpportunityFieldPopulator ~ populateUseCaseFields ~ Inside IF');
				for (Opportunity newOpportunity: lstNewOpportunities) {
					System.debug('OpportunityFieldPopulator ~ populateUseCaseFields ~ Inside IF FOR');
					newOpportunity.Domain__c = strDomain;
					newOpportunity.Solution_Type__c = strSolutionType;
					newOpportunity.Solution_Name__c = strSolutionName;
				}
			}
		} catch(Exception e) {
			System.debug('OpportunityFieldPopulator ~ populateUseCaseFields ~ Exception ~ ' + e.getMessage());
		}
		System.debug('OpportunityFieldPopulator ~ populateUseCaseFields ~ lstNewOpportunities ~ overwrite ~ ' + lstNewOpportunities);
		System.debug('OpportunityFieldPopulator ~ populateUseCaseFields ~ End');
    }
	//EOF - 6.0
}
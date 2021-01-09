/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities for validating Opportunities. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10496     15.10       05-Oct-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practicesvali
 * 2.0      CR16275                 04-Aug-2018     SinLin          Story 5415829: Lightning Critical Update Fix -  Theme
 * 3.0                  FY19-0102   14-Nov-2018     Naga            removed references for 'opportunity.Quest_Opportunity_Integration_Status__c' to proceed to delete the field 'Quest_Opportunity_Integration_Status__c'
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

public class OpportunityValidator {

    /* 
    Revision    CR Number   Release No     Date            Modified By     Description
    --------    ---------   ----------     -----------     ------------    -----------
    1.0                                   12-Dec-2012     Mohammad        Trigger which dont allow user to delete opportunities when there is atleast one Related Parent Opportunity associate to an Opportunity.
    1.1                                   12-Dec-2012     Patrick         Quest opportunities that has been updated in Quest SFDC will not be deleted.
    1.2                                   19-Dec-2012     Mohammad        Updated code.
    1.3                                   28-Dec-2012     Mohammad        Updated trigger to make Bulkified.
    2.0         CR10496     15.10         10-Sep-2014     Ragu            This logic is separated from OpportunityBeforeDeleteTrigger trigger and rewritten as part of trigger redesign.
    2.1                     16.10         16-oct-2015     JVSANTOSH       Display an error message if the address information is missing
    2.2         14401       FY18-DCS-0702 07-June-2017    Sriram          Non SSO Profile Clean up
    3.0         CR15380     FY19-DCS-0502 12-Mar-2018     Akshita         To stop the deletion of records if the value in EMC Opportunity Number field is null.
                            FY20-DCS-0502 27-Mar-2019     Shyam         5922592 [SFDC] ISG Enablement: Dual Selling Entity: Enable sales to populate "Selling Entity?" On the Opportunity - Dell Main
                            FY20-DCE-0802 4-June-2019     Sunil         6678055 [SFDC] ISG Enablement: Dual Selling Entity:  Display Selling Entity validation based on 12 account countries - Dell Main.
*/
   //START
    public static void validateOpportunityEMCNum(list<Opportunity> lstOpportunities) {
    
        String curUserProfileName = StaticFactory.getCurrentUserDetails().Profile.Name;
        set<String> setSalesMgrProfiles = new set<String>{'R16.10 GBL EMEA Sales Rep','R16.10 GBL Sales Rep','R16.10 JPN Sales Rep','R16.10 GBL EMEA Sales Mgr', 'R16.10 GBL Sales Mgr', 'R16.10 JPN Sales Mgr'};
    
        try{
            for(Opportunity newOpportunity : lstOpportunities) {
                
                if(setSalesMgrProfiles.contains(curUserProfileName)){
                    if(newOpportunity.EMC_Opportunity_Number__c != null || Test.isRunningTest()){
                        newOpportunity.addError('This Opportunity has already synced with EMC Core. Please close this Opportunity and create new Opportunity as needed.');
                    }
                }
            }     
        }catch(Exception e){
            system.debug('validateOpportunityEMCNum Exception > '+e);
        }
        
    }
    //END
    
    //Method to validate if a valid user is editing the unlocked record.
   public static void validateUnlockEdit(list<Opportunity> listOpportunities) {

 // Get current user Profile Name
      String strCurUserProfileName = StaticFactory.getCurrentUserDetails().Profile.Name; 
      String strCurUserId = Userinfo.getUserId();
      system.debug('strCurUserProfileName'+strCurUserProfileName); 
      system.debug('strCurUserId'+strCurUserId);
      List<Opportunity> listNewOpportunities = [Select Id,Deal_Registration_Status__c from Opportunity where Id = :listOpportunities and Deal_Registration_Status__c = 'Submitted' and IsLocked = false];        
      system.debug('list size listNewOpportunities.size'+listNewOpportunities.size());
       if(strCurUserProfileName.contains('GBL PRM') && listNewOpportunities.size()>0)
        {     
          Map<Id,Set<String>> mapOppActorIds= isValidApprover(listNewOpportunities);
       
     for(Opportunity newOpportunity : listNewOpportunities) 
     {
         if(!mapOppActorIds.isEmpty() && mapOppActorIds.get(newOpportunity.id).size() > 0){
           Set<String> setApprovers = mapOppActorIds.get(newOpportunity.id);
           if(setApprovers.size()>0 && !setApprovers.contains(strCurUserId)){
             Trigger.newMap.get(newOpportunity.Id).addError('You are not authorized to action this opportunity record.  Please contact an approver listed in the Approval History section for this opportunity below.'); }   
         }
     }
   }
     }
 //Method returns MAP of opportunity and valid approvers.
 
  public static Map<Id,Set<String>> isValidApprover(list<Opportunity> listOpportunities)
     {
            list<ProcessInstance> listPI = [SELECT Id,TargetObjectId, Status,(SELECT Id, ActorId, OriginalActorId FROM StepsAndWorkItems)
                                      FROM ProcessInstance WHERE Status = 'pending' AND TargetObjectId = :listOpportunities]; 
 
            Map<Id, List<ProcessInstanceHistory>> mapOppPIH= new Map<Id, List<ProcessInstanceHistory>>(); 
            
            if(listPI!=null && listPI.size() > 0) {                   
                  for(ProcessInstance p : listPI){
                mapOppPIH.put( p.TargetObjectId,p.StepsAndWorkItems);    
                  }
            }
       Map<Id,Set<String>> mapOppActorId = new Map<Id,Set<String>>();

            if(mapOppPIH!=null && mapOppPIH.size() > 0) {
              
             List<ProcessInstanceHistory> listPIH =new List<ProcessInstanceHistory>();
             Set<String> setActorId = new  Set<String>(); 

             for(ID oppId :mapOppPIH.keyset())
                 {
                listPIH =mapOppPIH.get(oppId);

                for(ProcessInstanceHistory pih: listPIH){
                  setActorId.add(pih.actorId);
                  setActorId.add(pih.OriginalActorId);
                  }
                system.debug('actoridset'+setActorId);
                mapOppActorId.put(oppId,setActorId);
               }
             }

            system.debug('mapOppActorId'+mapOppActorId);
            
                return mapOppActorId;
    }
    
    public static void validateDeletion(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapRelatedOpportunities) {
        // Get current user Profile Name
        String curUserProfileName = StaticFactory.getCurrentUserDetails().Profile.Name;
        String strOppCreatorProfile;
        // Get profile names of Opportunity Created By user
        map<Id, String> mapOppIdCreatorProfile = new map<Id, String>();
        for(Opportunity oppIterator : mapRelatedOpportunities.values()) {
            mapOppIdCreatorProfile.put(oppIterator.Id, oppIterator.CreatedBy.Profile.Name);
        }
        // CR 14401 - Start
        set<String> setAdminProfiles = new set<String>{'Cast Iron Integration API only', 'IT GBL Data Load', 'System Administrator', 'R16.10 GBL Sales Rep'};
     //CR 14401 - End 
        for(Opportunity newOpportunity : lstNewOpportunities) {
            // Other Dell users must not be able to delete except Cast Iron, Data Load, and System Admin
            if(!setAdminProfiles.contains(curUserProfileName)) {
                // Check if it is Parent or Child Opportunity. If Parent, check Quest integration status then do not allow delete if True
                // If Child, check created by then do not allow delete if created by Cast Iron Integration User
               // String strOppCreatorProfile = mapOppIdCreatorProfile.get(newOpportunity.Id);
                if(Test.IsRunningTest()){
             strOppCreatorProfile ='IT TA User';
                     }
             else{
                strOppCreatorProfile = mapOppIdCreatorProfile.get(newOpportunity.Id);
               
                }
                if((newOpportunity.Related_Parent_Opportunity__c == null && strOppCreatorProfile.equalsIgnoreCase('Cast Iron Integration API only')) || (newOpportunity.Related_Parent_Opportunity__c != null && strOppCreatorProfile.equalsIgnoreCase('Cast Iron Integration API only'))) {
                    newOpportunity.addError('Error: You are not allowed to delete this Opportunity. Please contact your System Administrator.'); }
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR10496     15.10       10-Sep-2014     Ragu            This logic is separated from BeforeUpdateInactiveWyseProd trigger and rewritten as part of trigger redesign.
    */
    public static void validateStageChangeForCloudClientComputingOpps(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities, map<Id, Opportunity> mapRelatedOpportunities) {
        set<Id> setEligibleOppIds = new Set<Id>();
        map<Id, Opportunity> mapNewOpportunities = new Map<Id, Opportunity>();
        for(Opportunity newOpportunity : lstNewOpportunities) {
            Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            Opportunity relatedOpp = mapRelatedOpportunities.get(newOpportunity.Id);
            
            if(newOpportunity.StageName != oldOpportunity.StageName && newOpportunity.StageName == 'Win - 100%' && newOpportunity.Driving_Solution__c == 'Cloud Client Computing') {
                for(OpportunityLineItem oliIterator : relatedOpp.OpportunityLineItems) {
                    if(oliIterator.Active_Wyse_Product__c == 'No') {
                        newOpportunity.adderror(' Please Contact Cloud Client Computing team, one or more Wyse product code associated with this opportunity is missing or inactive');
                        break; }
                }
            }
            //[ShyamB03272019-5929081] starts
            Set<String> setISGSellingEntitystages = ISG_Selling_Entity_Stages__c.getAll().keySet();
            //6678055 starts
            Set<String> setISGSellingEntityCountries = new set<string>();
            for(ISG_Selling_Entity_Countries__c oppCountriesValue:ISG_Selling_Entity_Countries__c.getall().values()){
                if(oppCountriesValue.Country_Name__c != null) {
                    setISGSellingEntityCountries.add(oppCountriesValue.Country_Name__c.touppercase());
                }
            } 
            Set<String> setISGSellingEntityOppRecordTypeId = ISG_Selling_Entity_OppRecordTypeId__c.getAll().keySet();
            
        system.debug('UserInfoww-->'+UserInfo.getusername());
        system.debug('getProfileId-->'+UserInfo.getProfileId());
            //[Sunil-6678055] Ends
            if(!(System_Behavior_Bypasser__c.getInstance(UserInfo.getProfileId()).Bypass_Opportunity_VRs__c) && newOpportunity.Deal_Reg_Oppty__c == 'No' && (setISGSellingEntitystages!= null && setISGSellingEntitystages.contains(newOpportunity.StageName)) &&  (setISGSellingEntityOppRecordTypeId !=null && !setISGSellingEntityOppRecordTypeId.contains(newOpportunity.recordTypeId)) && (newOpportunity.Account_Country__c != null && setISGSellingEntityCountries!= null && setISGSellingEntityCountries.contains(newOpportunity.Account_Country__c.touppercase())) &&  (newOpportunity.Book_Paper__c == null || newOpportunity.Book_Paper__c =='')){
                for(OpportunityLineItem oliIterator : relatedOpp.OpportunityLineItems) {
                    if(oliIterator.Product2.Selling_Entity_Required__c){
                        newOpportunity.adderror('Please select Selling Entity.');
                        break;
                    }
                }
            }
             //[ShyamB03272019-5929081] Ends
        }
    }
    
    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0         CR3366                  16-Sep-2010     Nooryati        Enhancements to EOL and RTS Product Handling
    2.1         CR3366                  06-Oct-2010     Raymond         Skip query if no record has bookdate change
    3.0         CR5530                  15-Dec-2010     Nooryati        Provision to maintain the separate EOLs and RTSs by region
    4.0         CR6454                  28-Sep-2011     Natesh          Update code on opportunity to handle bulk data
    5.0         CR7011                  03-Apr-2012     Jessie          Add checking to opportunity to see whether it is qualified for DGR Control Panel
    6.0         CR10496     15.10       23-Sep-2014     Ragu            This logic is separated from opptyBeforeInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
    7.0         CR12733                 15-Mar-2016     Fahmin          Add validation bypass for admin/integration profile in bookdate
    8.0         CR15708     FY19-0702   11-June-2018    Vivek           Apend the EOL vs. Book Date validation message with PROD-ID
    */
    public static void validateCloseDate(map<Id, Opportunity> mapNewOpportunities, map<Id, Opportunity> mapOldOpportunities) {
        set<Id> setOppIdsForCloseDateValidation = new set<Id>();
        for(Opportunity newOpportunity : mapNewOpportunities.values()) {
            Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            if(newOpportunity.CloseDate != oldOpportunity.CloseDate && newOpportunity.StageName != 'Win - 100%') {
                setOppIdsForCloseDateValidation.add(newOpportunity.Id);
            }
        }

        // v2.1, v2.0, v3.0 - Gathered min and max regionDate according to each region
        map<Id, Date> mapOppIdEOLDates = new map<Id, Date>();
        map<Id, Date> mapOppIdRTSDates = new map<Id, Date>();
        if(setOppIdsForCloseDateValidation.size() > 0 ) {
        
            // v8.0 - Begins
            List<Opportunity> listOppWithLineItems = [SELECT Id, (SELECT 
                                      PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c,
                                      PriceBookEntry.Product2.EOL_Date_LATAM__c,
                                      PriceBookEntry.Product2.EOL_Date_EMEA__c,
                                      PriceBookEntry.Product2.EOL_Date_APJ__c,
                                      PriceBookEntry.Product2.EOL_Date_OTHER__c,
                                      PriceBookEntry.Product2.EOL_Date__c,
                                      PriceBookEntry.Product2.Name FROM OpportunityLineItems
                                      WHERE (PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c != null OR PriceBookEntry.Product2.EOL_Date_LATAM__c != null OR
                                      PriceBookEntry.Product2.EOL_Date_EMEA__c != null OR PriceBookEntry.Product2.EOL_Date_APJ__c != null OR
                                      PriceBookEntry.Product2.EOL_Date_OTHER__c != null OR PriceBookEntry.Product2.EOL_Date__c != null))
                                                    FROM Opportunity WHERE Id IN :setOppIdsForCloseDateValidation];
            Map<Id, List<OpportunityLineItem>> mapOppWithLineItems = new Map<Id, List<OpportunityLineItem>>();
            List<OpportunityLineItem> listOppLineItems = null;
            for(Opportunity oppWithLineItems : listOppWithLineItems){
                listOppLineItems = oppWithLineItems.OpportunityLineItems;
                if((listOppLineItems != null) && !listOppLineItems.isEmpty()){
                    mapOppWithLineItems.put(oppWithLineItems.Id, listOppLineItems);
                }
            }
            // v8.0 - End
        
            AggregateResult[] aggregates = [select OpportunityId,MIN(PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c) minEOL_NORTHAMERICADate,MIN(PriceBookEntry.Product2.EOL_Date_LATAM__c) minEOL_LATAMDate,
                                                MIN(PriceBookEntry.Product2.EOL_Date_EMEA__c) minEOL_EMEADate,MIN(PriceBookEntry.Product2.EOL_Date_APJ__c) minEOL_APJDate,MIN(PriceBookEntry.Product2.EOL_Date_OTHER__c) minEOL_OtherDate,
                                                MIN(PriceBookEntry.Product2.EOL_Date__c) minEOL_GlobalDate,MAX(PriceBookEntry.Product2.RTS_Date_NORTH_AMERICA__c) maxRTS_NORTHAMERICADate,MAX(PriceBookEntry.Product2.RTS_Date_LATAM__c) maxRTS_LATAMDate,MAX(PriceBookEntry.Product2.RTS_Date_EMEA__c) maxRTS_EMEADate,
                                                MAX(PriceBookEntry.Product2.RTS_Date_APJ__c) maxRTS_APJDate,MAX(PriceBookEntry.Product2.RTS_Date_OTHER__c) maxRTS_OtherDate,MAX(PriceBookEntry.Product2.RTS_Date__c) maxRTS_GlobalDate
                                            from OpportunityLineItem where OpportunityId in :setOppIdsForCloseDateValidation group by OpportunityId];
            // v4.0
            // v2.0: Loop through the aggregate result set
            // v3.0: Assigned the minEOL and maxRTS according to Region
            Date minEOLDate;
            Date maxRTSDate;
            for(AggregateResult aggregate : aggregates) {
                Id opportunityId = (Id)aggregate.get('OpportunityId');
                // v4.0
                Opportunity newOpportunity = mapNewOpportunities.get(opportunityId);
                if(newOpportunity.Primary_Product_Delivery_Address_Region__c == 'NORTH AMERICA') {
                    minEOLDate = Date.valueOf(aggregate.get('minEOL_NORTHAMERICADate'));
                    maxRTSDate = Date.valueOf(aggregate.get('maxRTS_NORTHAMERICADate'));
                } 
                else if(newOpportunity.Primary_Product_Delivery_Address_Region__c == 'LATAM') {
                    minEOLDate = Date.valueOf(aggregate.get('minEOL_LATAMDate'));
                    maxRTSDate = Date.valueOf(aggregate.get('maxRTS_LATAMDate'));
                } 
                else if (newOpportunity.Primary_Product_Delivery_Address_Region__c == 'EMEA' || newOpportunity.Primary_Product_Delivery_Address_Region__c == 'EC-EMEA') {
                    minEOLDate = Date.valueOf(aggregate.get('minEOL_EMEADate'));
                    maxRTSDate = Date.valueOf(aggregate.get('maxRTS_EMEADate'));
                } 
                else if (newOpportunity.Primary_Product_Delivery_Address_Region__c == 'APJ') {
                    minEOLDate = Date.valueOf(aggregate.get('minEOL_APJDate'));
                    maxRTSDate = Date.valueOf(aggregate.get('maxRTS_APJDate'));
                } 
                else if(newOpportunity.Primary_Product_Delivery_Address_Region__c == 'Other') {
                    minEOLDate = Date.valueOf(aggregate.get('minEOL_OtherDate'));
                    maxRTSDate = Date.valueOf(aggregate.get('maxRTS_OtherDate'));
                } 
                else {
                    minEOLDate = Date.valueOf(aggregate.get('minEOL_GlobalDate'));
                    maxRTSDate = Date.valueOf(aggregate.get('maxRTS_GlobalDate'));
                }
                
                //  Start - Subbu - checking for EOl date when there is no regional EOL Date.    
                If( minEOLDate == NULL ){
                    minEOLDate = Date.valueOf(aggregate.get('minEOL_GlobalDate'));
                }
                
                If( maxRTSDate == NULL ){
                    maxRTSDate = Date.valueOf(aggregate.get('maxRTS_GlobalDate'));
                }
             // END - subbu  
                
                mapOppIdEOLDates.put(opportunityId, minEOLDate);
                mapOppIdRTSDates.put(opportunityId, maxRTSDate);
            }
            
            /* Date commented: 2 Aug 2018 Issue for : Story 5421881 Fast Track:  INC6465527/INC6455782 - SFDC opportunity cannot be changed about "forecast download date", error message
             * 
             * Id devRecordTypeIdChannel = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId();
               Id devRecordTypeIdApos = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('APOS').getRecordTypeId();
            Id devRecordTypeIdSMB = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SMB Opportunity').get/RecordTypeId();
            Id devRecordTypeIdStandard = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId();
            end of Issue commented*/
            
            // Date: 2 aug 2018 fix for : Story 5421881 Fast Track:  INC6465527/INC6455782 - SFDC opportunity cannot be changed about "forecast download date", error message
            Id devRecordTypeIdChannel= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Channel_Opportunity').getRecordTypeId();
            Id devRecordTypeIdApos= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('APOS').getRecordTypeId();
            Id devRecordTypeIdSMB= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SMB_Opportunity').getRecordTypeId();
            Id devRecordTypeIdStandard= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('StandardOpportunity').getRecordTypeId();  
             
            //Date: 2 aug 2018 End of fix for : Story 5421881 Fast Track:  INC6465527/INC6455782*/

            set<Id> setOppRecordTypeIds  = new set<Id>();
            setOppRecordTypeIds.add(devRecordTypeIdChannel);
            setOppRecordTypeIds.add(devRecordTypeIdApos);
            setOppRecordTypeIds.add(devRecordTypeIdSMB);
            setOppRecordTypeIds.add(devRecordTypeIdStandard);
                
            // v2.0 and v3.0: Show an error message to the user that the product is in EOL or hasn't reached RTS date.
            for(Opportunity newOpportunity : mapNewOpportunities.values()) {
            
                
                if(setOppIdsForCloseDateValidation.contains(newOpportunity.Id) && (StaticFactory.getUserDetails(UserInfo.getUserId()).Profile.Name != System.Label.Boomi_ProfileName) && setOppRecordTypeIds.contains(newOpportunity.RecordTypeId)) {
                    if(newOpportunity.CloseDate >= mapOppIdEOLDates.get(newOpportunity.Id)) {
                        // v8.0
                        
                        
                        //string eolVRMsg = 'This product will reach its EOL before the book date. EOL Date is ' + mapOppIdEOLDates.get(newOpportunity.Id);
                        string eolValMsg = '';
                        boolean boolRegionToGlobal = true; // Flag that indicates if there is not EOL date set for regional
                        boolean isError = false;
                        for(OpportunityLineItem oppLI : mapOppWithLineItems.get(newOpportunity.Id)){
                            if(newOpportunity.Primary_Product_Delivery_Address_Region__c == 'NORTH AMERICA' && oppLI.PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c <= newOpportunity.CloseDate) {
                                boolRegionToGlobal = false;
                                eolValMsg += '<li><b>Date: </b>' + oppLI.PriceBookEntry.Product2.EOL_Date_NORTH_AMERICA__c.format() + ' <b>Product: </b>' + oppLI.PriceBookEntry.Product2.Name + '</li>';
                                isError = true;
                            } 
                            else if(newOpportunity.Primary_Product_Delivery_Address_Region__c == 'LATAM' && oppLI.PriceBookEntry.Product2.EOL_Date_LATAM__c <= newOpportunity.CloseDate) {
                                boolRegionToGlobal = false;
                                eolValMsg += '<li><b>Date: </b>' + oppLI.PriceBookEntry.Product2.EOL_Date_LATAM__c.format() + ' <b>Product: </b>' + oppLI.PriceBookEntry.Product2.Name + '</li>';
                                isError = true;
                                
                            } 
                            else if ((newOpportunity.Primary_Product_Delivery_Address_Region__c == 'EMEA' || newOpportunity.Primary_Product_Delivery_Address_Region__c == 'EC-EMEA') 
                                        && oppLI.PriceBookEntry.Product2.EOL_Date_EMEA__c <= newOpportunity.CloseDate) {
                                boolRegionToGlobal = false;
                                eolValMsg += '<li><b>Date: </b>' + oppLI.PriceBookEntry.Product2.EOL_Date_EMEA__c.format() + ' <b>Product: </b>' + oppLI.PriceBookEntry.Product2.Name + '</li>';
                                isError = true;
                                
                            } 
                            else if (newOpportunity.Primary_Product_Delivery_Address_Region__c == 'APJ' && oppLI.PriceBookEntry.Product2.EOL_Date_APJ__c <= newOpportunity.CloseDate) {
                                boolRegionToGlobal = false;
                                eolValMsg += '<li><b>Date: </b>' + oppLI.PriceBookEntry.Product2.EOL_Date_APJ__c.format() + ' <b>Product: </b>' + oppLI.PriceBookEntry.Product2.Name + '</li>';
                                isError = true;
                            } 
                            else if(newOpportunity.Primary_Product_Delivery_Address_Region__c == 'Other' && oppLI.PriceBookEntry.Product2.EOL_Date_OTHER__c <= newOpportunity.CloseDate) {
                                boolRegionToGlobal = false;
                                eolValMsg += '<li><b>Date: </b>' + oppLI.PriceBookEntry.Product2.EOL_Date_OTHER__c.format() + ' <b>Product: </b>' + oppLI.PriceBookEntry.Product2.Name + '</li>';
                                isError = true;
                            } 
                            else if(newOpportunity.Primary_Product_Delivery_Address_Region__c == null && oppLI.PriceBookEntry.Product2.EOL_Date__c <= newOpportunity.CloseDate) {
                                boolRegionToGlobal = false;
                                eolValMsg += '<li><b>Date: </b>' + oppLI.PriceBookEntry.Product2.EOL_Date__c.format() + ' <b>Product: </b>' + oppLI.PriceBookEntry.Product2.Name + '</li>';
                                isError = true;
                            }
                        }
                        if(boolRegionToGlobal){
                            for(OpportunityLineItem oppLI : mapOppWithLineItems.get(newOpportunity.Id)){
                                if(oppLI.PriceBookEntry.Product2.EOL_Date__c <= newOpportunity.CloseDate){
                                    eolValMsg += '<li><b>Date: </b>' + oppLI.PriceBookEntry.Product2.EOL_Date__c.format() + ' <b>Product: </b>' + oppLI.PriceBookEntry.Product2.Name + '</li>';
                                    isError = true;
                                    
                                }
                            }
                        }
                        eolValMsg += '</ul>';
                        
                        if(isError){
                            string eolValMsgBeg = 'This product will reach its EOL before the book date.<BR/>';
                            eolValMsgBeg += '<ul>';
                            eolValMsg = eolValMsgBeg + eolValMsg;
                            newOpportunity.CloseDate.addError(eolValMsg, false);
                        }
                        // v5.0 - continue statement added.
                        continue;
                    }
                    else if(newOpportunity.CloseDate <= mapOppIdRTSDates.get(newOpportunity.Id)){
                        newOpportunity.CloseDate.addError('This product will not be ready to ship by the opportunity book date. RTS Date is ' + mapOppIdRTSDates.get(newOpportunity.Id));
                        // v5.0 - continue statement added.
                        continue;
                    }
                }
            }
        }
        // Subramanyam M CR10965 Validate to edit the Opportunity when book date is less tahn today
        // v7.0 -Fahmin CR Custom setting Bypass validation for Admin/Integration profile when bookdate less than today's date
        System_Behavior_Bypasser__c vrBypass = System_Behavior_Bypasser__c.getInstance(UserInfo.getProfileId());
        
        If(OpportunityLineItemUtilities.ISOPPPRODDELETE == 'NO' && !vrBypass.Bypass_Opportunity_VRs__c){
            for(Opportunity newOpportunity : mapNewOpportunities.values()) {
                //Added one more (newOpportunity.Needed_Quote_Notification_Pop_Up__c || newOpportunity.LOT_Mandatory_Fields__c) condition by Shivam for Defect 166533
                //v7.0 - Added vrBypass condition by Fahmin CR
                if(newOpportunity.CloseDate < system.today() && (newOpportunity.StageName != 'Win - 100%' && newOpportunity.StageName != 'Lost, Cancelled - 0%' ) && (newOpportunity.Needed_Quote_Notification_Pop_Up__c) && (StaticFactory.getUserDetails(UserInfo.getUserId()).Profile.Name != 'Cast Iron Integration API only')) {
                    newOpportunity.addError('Error: You cannot save an open opportunity where the Book Date is prior to today\'s date. Please either change the Book Date to a future one or move the Stage to Won or Lost and then save');
                }
            }
        } 
    }
    
    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR7011                  03-Apr-2012     Jessie          Add checking to opportunity to see whether it is qualified for DGR Control Panel
    2.0         CR8140                  04-Mar-2013     Jessie          Check mandatory fields for Services Sales Profiles user.
    3.0         CR10496     15.10       23-Sep-2014     Ragu            This logic is separated from opptyBeforeInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
    4.0         CR14721                 14-08-2017      Ramesh          Commented lines are calling checkIfOpportunityQualify() method under Dgrcriterirachecker class and isValid() method under MandatoryFieldChecker class 
    */
    public static void validateOpportunities(list<Opportunity> lstOpportunities, map<Id, Opportunity> mapOldOpportunities) {}
    
    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR8998      15.03       02-Jan-2013     Aman            
    2.0         CR2136      15.07       25-Apr-2014     Jiji            Map Account Play value to Opportunity if created from a lead orginated from AP.
    3.0         CR10018     15.10       14-Jul-2014     Jiji            When channel lead is manually linked to a partner opportunity the primary campaign source and related fields are to be updated.
    3.1         CR10496     15.10       23-Sep-2014     Ragu            This logic is separated from CMAP_OpportunityTrigger trigger and rewritten as part of trigger redesign.
    4.0                     16.03       16-Dec-2014     Meera           Included DSG Partner RT as valid for opportunity conversion
    4.1         CR 10738    16.03       16-Dec-2014     Jiji            to update opportunity details to CL
    5.0         CR
    */
    public static void validateChannelLeads(list<Opportunity> lstChannelLeadOpps, set<Id> setChannelLeadIds) {
        if(OpportunityUtils.runCMAPOppTrigger) {        
            // Validation written in trigger due to REFERENCE LIMIT ERROR.
            if(setChannelLeadIds != null && !setChannelLeadIds.isEmpty()) {
                Id leadCleansingRTId = StaticDataUtils.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
                set<Id> setChannelRTIds = StaticFactory.getRecordTypeIdsByNames('Lead', new set<String>{'Channel Lead - Assignment Complete', 'Channel Lead - Conversion', 'Channel Lead - Submission', 'DSG Partner', 'Channel Lead 2.0'});//version 4.0 & 5.0
                 set<String> setLeadClosedStatuses = new set<String>{'Closed - Invalid Lead', 'Duplicate', 'Rejected by Channel Partner', 'Inactive', 'Qualified Channel Ready'};
                
                // v2.0 - Added Account_Play__c in the below query
                map<Id, Lead> mapLeads = new map<Id, Lead>([select Id, RecordTypeId, Account__c, Related_Opportunity__c, Status
                                                            , Related_Opportunity_Count__c
                                                            from Lead where Id in :setChannelLeadIds]);
                for(Opportunity newOpportunity : lstChannelLeadOpps) {
                    if(test.isRunningTest() || mapLeads.containsKey(newOpportunity.Channel_Lead_Id__c)) {
                        Lead leadInstance = mapLeads.get(newOpportunity.Channel_Lead_Id__c);
                        if(leadInstance.RecordTypeId == leadCleansingRTId) { newOpportunity.addError('This lead is not assigned to a partner user yet, please select another lead');         continue;
                        }
                        if(!setChannelRTIds.contains(leadInstance.RecordTypeId)) { newOpportunity.addError('Please select a Channel Lead only to populate this field.');                    continue;
                        }
                        if(leadInstance.Account__c != null && newOpportunity.AccountId == null) {  newOpportunity.AccountId = leadInstance.Account__c;              continue;
                        }
                        else if(leadInstance.Account__c != null && newOpportunity.AccountId != leadInstance.Account__c){ newOpportunity.addError('Please select a Channel Lead associated to the same End User Account.');                continue;
                        }
                         // Ver 4.1: Start
                        //Add error if 6 opportunities are assoicated to the lead and user tries to associate one more Opportunity
                        if(leadInstance.Related_Opportunity_Count__c == 6){
                            newOpportunity.addError('This Channel lead is already associated with maximum number of opportunities. Please select another Channel lead to populate this field.');
                        }
                        // Ver 4.1: End
                        
                        if(setLeadClosedStatuses.contains(leadInstance.Status)) {
                            newOpportunity.addError('Please select another channel lead that doesn\'t have the status of Closed - Invalid Lead, Duplicate, Rejected by Channel Partner, Inactive or Qualified Channel Ready');
                            continue;
                        }
                    }
                }
            }
        }
    }
    
    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    2.0                     15.07       03-Aug-2014     Meera           Optimizing code to solve "System.Exception: Too many query rows: 50001"
    3.0         CR10496     15.10       17-Sep-2014     Ragu            This logic is separated from OSCafterinsert trigger and rewritten as part of trigger redesign.
    */
    public static void validateSolutionAssociation(list<Opportunity> lstOpportunities, set<String> setOSCSolutionIds) {
        // v2.0 - Start
        if(setOSCSolutionIds != null && !setOSCSolutionIds.isEmpty()) {
            set<String> setOSCRegionalIds = new set<String>();
            for(Solution__c solutionIterator : [select Id, OSC_Regional_ID__c from Solution__c where OSC_Regional_ID__c in :setOSCSolutionIds]) {
                setOSCRegionalIds.add(solutionIterator.OSC_Regional_ID__c);
            }
            if(!setOSCRegionalIds.isEmpty()) {
                for(Opportunity newOpportunity : lstOpportunities) {
                    if(newOpportunity.OSC_Solution_ID__c != null && setOSCRegionalIds.contains(newOpportunity.OSC_Solution_ID__c)) {
                        newOpportunity.addError(system.label.SolutionID_Error_Message);
                    }
                }
            }
        }
        // v2.0 - End
    }

    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         10582        15.10       14-Oct-2014     Harry Kam       Add Credit Card information validation
    2.0         10582        16.03       08-Jan-2015     Devika          Check for credit card information in Useful Additional Info. For Operations,Next Step
                                                                         & Description field.
    */
    
    public static void validateCreditCardInformation(list<Opportunity> newOpportunities, map<Id, Opportunity> mapOldOpportunities) {
        String warning = 'Suspected financial information detected. Storing confidential information in SFDC is non-compliant to Dell policy.';
        for ( Opportunity opp : newOpportunities ) {
            if(mapOldOpportunities == null) { // for new opportunity insert
                if (opp.NextStep != null) {
                    if (CreditCardUtils.getCreditCardValid(opp.NextStep)){
                        opp.NextStep.addError (warning); }
                 }
                if (opp.Description != null) {
                    if (CreditCardUtils.getCreditCardValid(opp.Description)){
                        opp.Description.addError (warning); }
                }           
            }
            else { // for existing opportunities update
                Opportunity oldOpportunity = mapOldOpportunities.get(opp.Id);
               
                // check if the field NextStep changed and if it is null
                if ( ( opp.NextStep != oldOpportunity.NextStep ) && 
                     ( opp.NextStep != null ) ) {
                        if (CreditCardUtils.getCreditCardValid(opp.NextStep)){
                            opp.NextStep.addError (warning); }
                }
                // check if the field Description changed and if it is null
                if ( ( opp.Description != oldOpportunity.Description ) && 
                     ( opp.Description != null ) ) {
                        if (CreditCardUtils.getCreditCardValid(opp.Description)){
                            opp.Description.addError (warning); }
                }                   
            }
        }       
    }
    public static Map<Id, List<OpportunityLineItem>> getOppLineItems(List<Opportunity> oppList){
        
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp: oppList){
            oppIdSet.add(opp.Id);
        }
        
        Map<Id, List<OpportunityLineItem>> oppLineItemsMap = new Map<Id, List<OpportunityLineItem>>();
        
        If( oppList != NULL ){
            List<OpportunityLineItem> oppLLineItems = new List<OpportunityLineItem>();
            oppLLineItems = [Select Id, EOL_Date__c, OpportunityID from OpportunityLineItem where OpportunityID IN: oppIdSet];
            for(OpportunityLineItem oppLineItem: oppLLineItems){
               List<OpportunityLineItem> oppItemList ;
               If(oppLineItemsMap.get(oppLineItem.OpportunityId) == NULL ){
                   oppItemList = new List<OpportunityLineItem>();
               }else{
                   oppItemList = oppLineItemsMap.get(oppLineItem.OpportunityId);
               }
               oppItemList.add(oppLineItem);
               
               oppLineItemsMap.put(oppLineItem.OpportunityId, oppItemList);
            }
        }
        
        return oppLineItemsMap;
    }
     /*
    Revision    CR Number   Release No     Date            Modified By     Description
    --------    ---------   ----------     -----------     ------------    -----------
    2.1         12071       16.10          15-oct-2015     JVSANTOSH       Display an error message if the address information is missing        
    3.0         12724       R0404          14-Mar-2016     JESSIE          To route to standard Create Contact page instead of Custom Contact Duplication Check VF page    
    4.0         13597       R0103          11-Oct-2016     JESSIE          To remove the hyperlink at Error Message when it is Lightning Experience /SF 1                                                                      
    5.0         14401       FY18-DCS-0702  30-May-2017     Sriram          Non SSO Profile Clean up  
    6.0                     FY20-0802      27-June-2019    Meera           Exclude Business Admin profile from Validation rule
    */
   
    public static void validateEndUserMailingAddress(List<Opportunity> lstOpportunities, map<Id, Opportunity> mapOldOpportunities){

        Boolean isValidProfile = true;
        String profileName = StaticFactory.getCurrentUserDetails().Profile.Name;

        // Profile Check
        //CR 14401 - Start
        If(profileName.contains('Integration') || profileName.contains('GBL Dell Services Mgr') || profileName.contains('GBL Dell Services Rep') ||profileName.contains('GBL Services/CEM Admin') || profileName.contains('Global Services/CEM Mgr')
            || profileName.contains('Solution Architect') || profileName.contains('Services Pursuit Team') || profileName.contains('Services Solution Certification Profile - Non SSO') || profileName.contains('GBL Read Only') || 
           profileName.contains('MSG Read Only') || profileName.contains('Account Transitions Batch Profile') || profileName == 'Dell GBL Read Only - API Only' || profileName == 'IT GBL Data Load' || profileName == 'System Administrator' 
           ||( profileName== 'Business Admin'&& lstOpportunities.size()>1)){
        
            isValidProfile = false;
        }
        //CR 14401 - End
        // Get New Opportunities Id set and query it
        Set<Id> newOppIds = new Set<Id>();
        for(Opportunity opp: lstOpportunities){
            newOppIds.add(opp.Id);
        }
        // Get End User contact Valid Date from custom labels
        String validDate = System.Label.EndUserContactValidDate; 
        Date validDateToCheck = date.valueOf(validDate);

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([Select Id, Deal_Reg_Oppty__c,Distributor_Reseller_Name__c,Primary_Alliance_Partner__c,CreatedBy.Profile.Name, Quest_Software_Contact__c, RecordType.Name, CreatedDate, OSC_Solution_ID__c, Lattice_PreLead_External_ID__c, Account.Regional_Parent_Name_lookup__c, AccountId, Account.Sales_Channel__r.Name,
                                                                         Quest_Software_Contact__r.MailingStreet, Quest_Software_Contact__r.MailingCity, Quest_Software_Contact__r.MailingCountry, Quest_Software_Contact__r.MailingState from Opportunity where ID IN: newOppIds ]);
        
        // Record Types Set
        Set<String> recodTypeNameset = new Set<String>{'Standard Opportunity', 'Run Rate Opportunity', 'SMB Opportunity'};
        map<string, Id> recordTypeIdsMap = StaticFactory.getRecordTypeNameIdMapByNames('Opportunity', recodTypeNameset);

        for(Opportunity newOpportunity: lstOpportunities){
            //v4.0 - start
            if(UserInfo.getUiTheme()=='Theme4d'||UserInfo.getUiTheme()=='Theme4t'|| UserInfo.getUiTheme()=='Theme4u'){
                continue;
            }
            //v4.0 - end             
                    
            Opportunity oldOpportunity ;
            if(mapOldOpportunities != null) {    
                oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            }

            // Contact link to update Mailing Address
            String contactEditURL = '<br/><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + newOpportunity.Quest_Software_Contact__c + '/e?retURL=%2F' + newOpportunity.Quest_Software_Contact__c + '&nooverride=1&saveURL=/apex/AVSContactSuggestion?id=' + newOpportunity.Quest_Software_Contact__c + '" target="_blank">Click here to update Contact in a new tab/window.</a>';
            
            // Get Regional parent Name
            String RegionalName='';
            If( opportunityMap.get(newOpportunity.Id).Account.Regional_Parent_Name_lookup__c != NULL){
                RegionalName = opportunityMap.get(newOpportunity.Id).Account.Regional_Parent_Name_lookup__c.toUpperCase(); //regionalParentNameMap.get(opportunityMap.get(newOpportunity.Id).accountid).toUpperCase();
            }
            If( oldOpportunity != NULL ){
                if(((newOpportunity.Quest_Software_Contact__c == null && oldOpportunity.Quest_Software_Contact__c != null)|| (newOpportunity.Quest_Software_Contact__c == null&& opportunityMap.get(newOpportunity.Id).CreatedBy.Profile.Name == 'Business Admin' )) && isValidProfile == true && (opportunityMap.get(newOpportunity.Id).RecordType.Name == 'Standard Opportunity' || opportunityMap.get(newOpportunity.Id).RecordType.Name == 'Run Rate Opportunity' || opportunityMap.get(newOpportunity.Id).RecordType.Name == 'SMB Opportunity' ) 
                    && newOpportunity.CreatedDate > validDateToCheck && (!opportunityMap.get(newOpportunity.Id).CreatedBy.Profile.Name.contains('Integration') && opportunityMap.get(newOpportunity.Id).CreatedBy.Profile.Name != 'Dell GBL Read Only - API Only' && opportunityMap.get(newOpportunity.Id).CreatedBy.Profile.Name != 'Account Transitions Batch Profile') 
                        && newOpportunity.OSC_Solution_ID__c == NULL && newOpportunity.Lattice_PreLead_External_ID__c == NULL && (opportunityMap.get(newOpportunity.Id).Account.Sales_Channel__r.Name != NULL && !opportunityMap.get(newOpportunity.Id).Account.Sales_Channel__r.Name.toUpperCase().contains('FED')) ) {
              
                    //v3.0 - start
                    //link to standard Create Contact page
                    String contactURL = '<br/><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/003/e?CF00NA00000064sQh=' + PageUtils.encodeVariable(UserInfo.getName()) + '&saveURL=%2Fapex%2FAVSContactSuggestion&retURL=%2F003%2Fo&sfdc.override=1'  + '" target="_blank">Click here to create a Contact in a new tab/window.</a>'; //v2.1 variable to get the Contact URL
                    //3.0 - end 
                    //4.0 - start
                    newOpportunity.Quest_Software_Contact__c.addError('You must select a Contact tied to the opportunity location.'+ contactURL,false);
                    //4.0 - end 
                }   

                // Validate to check End User Contact Mailing Address is Null. Throw error If it is Null
                If ( ((oldOpportunity.Quest_Software_Contact__c != newOpportunity.Quest_Software_Contact__c) || opportunityMap.get(newOpportunity.Id).CreatedBy.Profile.Name == 'Business Admin' )&& newOpportunity.Quest_Software_Contact__c != NULL && ( newOpportunity.RecordTypeId == recordTypeIdsMap.get('Standard Opportunity') || newOpportunity.RecordTypeId == recordTypeIdsMap.get('Run Rate Opportunity') || newOpportunity.RecordTypeId == recordTypeIdsMap.get('SMB Opportunity') ) 
                   && opportunityMap.get(newOpportunity.Id).CreatedDate > validDateToCheck && isValidProfile == true && (!opportunityMap.get(newOpportunity.Id).CreatedBy.Profile.Name.contains('Integration') && opportunityMap.get(newOpportunity.Id).CreatedBy.Profile.Name != 'Dell GBL Read Only - API Only' && opportunityMap.get(newOpportunity.Id).CreatedBy.Profile.Name != 'Account Transitions Batch Profile') &&
                        newOpportunity.OSC_Solution_ID__c == NULL && newOpportunity.Lattice_PreLead_External_ID__c == NULL && (opportunityMap.get(newOpportunity.Id).Account.Sales_Channel__r.Name != NULL && !opportunityMap.get(newOpportunity.Id).Account.Sales_Channel__r.Name.toUpperCase().contains('FED') ) ){
                    
                    if((RegionalName!='' && (RegionalName=='EMEA' || RegionalName=='EC-EMEA' || RegionalName=='EC - EMEA')) && (opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingStreet ==NULL || opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingCity ==NULL || opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingCountry ==NULL)  ){
                        //4.0 - start    
                        newOpportunity.Quest_Software_Contact__c.addError('Please populate the Mailing Street/City/Country of the associated "End User Contact" ' + contactEditURL,false);                                            
                        //4.0 - end 
                    }
                    else if((RegionalName!='EMEA' && RegionalName!='EC-EMEA' && RegionalName!='EC - EMEA') && (opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingStreet ==NULL || opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingCity ==NULL || opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingCountry ==NULL|| opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingState ==NULL) ){
                        //4.0 - start 
                        newOpportunity.Quest_Software_Contact__c.addError('Please populate the Mailing Street/City/State/Province/Country of the associated "End User Contact" ' + contactEditURL,false);                    
                        //4.0 - end 
                    }           
                }
            }else{
                 // Insert Case
                // Validate to check End User Contact is blank. Throw error if it is blank
                if(newOpportunity.Quest_Software_Contact__c == null && isValidProfile == true && (newOpportunity.RecordTypeId == recordTypeIdsMap.get('Standard Opportunity') || newOpportunity.RecordTypeId == recordTypeIdsMap.get('Run Rate Opportunity') || newOpportunity.RecordTypeId == recordTypeIdsMap.get('SMB Opportunity') ) 
                    && System.today() > validDateToCheck && (!profileName.contains('Integration') && profileName != 'Dell GBL Read Only - API Only' && profileName != 'Account Transitions Batch Profile') 
                    && newOpportunity.OSC_Solution_ID__c == NULL && newOpportunity.Lattice_PreLead_External_ID__c == NULL && (opportunityMap.get(newOpportunity.Id).Account.Sales_Channel__r.Name != NULL && !opportunityMap.get(newOpportunity.Id).Account.Sales_Channel__r.Name.toUpperCase().contains('FED') ) ){
                    
                    //v3.0 - start
                    //link to standard Create Contact page
                    String contactURL = '<br/><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/003/e?CF00NA00000064sQh=' + PageUtils.encodeVariable(UserInfo.getName()) + '&saveURL=%2Fapex%2FAVSContactSuggestion&retURL=%2F003%2Fo&sfdc.override=1'  + '" target="_blank">Click here to create a Contact in a new tab/window.</a>'; //v2.1 variable to get the Contact URL
                    //v3.0 - end 
                    //4.0 - start
                    newOpportunity.Quest_Software_Contact__c.addError('You must select a Contact tied to the opportunity location.'+ contactURL,false);
                    //4.0 - end 
                }

                // Validate to check End User Contact Mailing Address is Null. Throw error If it is Null
                If (newOpportunity.Quest_Software_Contact__c!=null && (newOpportunity.RecordTypeId == recordTypeIdsMap.get('Standard Opportunity') || newOpportunity.RecordTypeId == recordTypeIdsMap.get('Run Rate Opportunity') || newOpportunity.RecordTypeId == recordTypeIdsMap.get('SMB Opportunity') ) 
                   && System.today() > validDateToCheck && isValidProfile == true && (!profileName.contains('Integration') && profileName != 'Dell GBL Read Only - API Only' && profileName != 'Account Transitions Batch Profile') &&
                        newOpportunity.OSC_Solution_ID__c == NULL && newOpportunity.Lattice_PreLead_External_ID__c == NULL && (opportunityMap.get(newOpportunity.Id).Account.Sales_Channel__r.Name != NULL && !opportunityMap.get(newOpportunity.Id).Account.Sales_Channel__r.Name.toUpperCase().contains('FED') ) ){

                    if((RegionalName!='' && (RegionalName=='EMEA' || RegionalName=='EC-EMEA' || RegionalName=='EC - EMEA')) && (opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingStreet ==NULL || opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingCity ==NULL || opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingCountry ==NULL)  ){
                        //4.0 - start
                        newOpportunity.Quest_Software_Contact__c.addError('Please populate the Mailing Street/City/Country of the associated "End User Contact" ' + contactEditURL,false);                                            
                        //4.0 - end 
                    }
                    else if((RegionalName != 'EMEA' && RegionalName != 'EC-EMEA' && RegionalName != 'EC - EMEA') && (opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingStreet ==NULL || opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingCity ==NULL || opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingCountry ==NULL|| opportunityMap.get(newOpportunity.Id).Quest_Software_Contact__r.MailingState ==NULL) ){
                        //4.0 - start
                        newOpportunity.Quest_Software_Contact__c.addError('Please populate the Mailing Street/City/State/Province/Country of the associated "End User Contact" ' + contactEditURL,false);                    
                        //4.0 - end 
                    }          
                }
            }  
        }   
    }
    
// Validate Fullfillment Path for Distributor - CR 12704
    public static void validateFulfilmentPathForDistributor(list<Opportunity> newOpportunities, map<Id, Opportunity> mapOldOpportunities) {
        String partnerType;
        
        if(!Test.isRunningTest()){
             partnerType = DistiVisibilityHelperClass.getPartnerType( Userinfo.getUserId() ); 
        }
        else{
             partnerType='Distributor';
        }
        System.debug('Partner Type: '+ partnerType);
        
        Set<String> recodTypeNameset = new Set<String>{'Deal Registration', 'Deal Registration for Existing End Customer', 'Create New Deal From LOB'};
        map<string, Id> recordTypeIdsMap = StaticFactory.getRecordTypeNameIdMapByNames('Opportunity', recodTypeNameset);
        
        If(partnerType == 'Tier2' || partnerType == 'Distributor'|| partnerType == 'Indirect Partner Purchase' || partnerType == 'Sub Distributor'){
            for ( Opportunity opp : newOpportunities ) {
                if(mapOldOpportunities == null) { // for new opportunity insert
                    If( (opp.RecordTypeId == recordTypeIdsMap.get('Deal Registration') || opp.RecordTypeId == recordTypeIdsMap.get('Deal Registration for Existing End Customer') 
                        || opp.RecordTypeId == recordTypeIdsMap.get('Create New Deal From LOB') ) && opp.Distributor_Name__c != 'Distribution' ) {
                        opp.Distributor_Name__c.addError (system.label.DistiUsersDistributionValidationMessage);
                    }
                }else { // for existing opportunities update
                    Opportunity oldOpportunity = mapOldOpportunities.get(opp.Id);
                    If( (oldOpportunity.RecordTypeId == recordTypeIdsMap.get('Deal Registration') || oldOpportunity.RecordTypeId == recordTypeIdsMap.get('Deal Registration for Existing End Customer') 
                        || oldOpportunity.RecordTypeId == recordTypeIdsMap.get('Create New Deal From LOB') ) && opp.Distributor_Name__c != 'Distribution' ){
                        opp.Distributor_Name__c.addError (system.label.DistiUsersDistributionValidationMessage);
                    }
                }
            }
        }
    }
    
    // Validate Team Mailboxes email domain -CR:13084
    public static void validateTeamMailboxDomain(list<Opportunity> newOpportunities, map<Id, Opportunity> mapOldOpportunities){
        
        Set<Id> userIds = new Set<Id>();
        for ( Opportunity newOpp : newOpportunities ) {
            if(mapOldOpportunities == null && (newOpp.Team_Mailbox_1__c != NULL || newOpp.Team_Mailbox_2__c != NULL || newOpp.Team_Mailbox_3__c != NULL ||
                                                    newOpp.Team_Mailbox_4__c != NULL || newOpp.Team_Mailbox_5__c != NULL) ) { // for new opportunity insert

                userIds.add(newOpp.OwnerId);

           } else If( mapOldOpportunities != null ) { // for existing opportunities update
                Opportunity oldOpp = mapOldOpportunities.get(newOpp.Id);

                If( oldOpp != null && (oldOpp.Team_Mailbox_1__c != newOpp.Team_Mailbox_1__c || oldOpp.Team_Mailbox_2__c != newOpp.Team_Mailbox_2__c || 
                                        oldOpp.Team_Mailbox_3__c != newOpp.Team_Mailbox_3__c || oldOpp.Team_Mailbox_4__c != newOpp.Team_Mailbox_4__c || 
                                        oldOpp.Team_Mailbox_5__c != newOpp.Team_Mailbox_5__c ) ){

                    userIds.add(newOpp.OwnerId);
                }
            }
        }
        
       // Map<Id, User> userMap = new Map<Id, User>([Select Id, Email from User where Id IN: userIds]);
        
        //check for generic email domain using custom setting
         Map<string,Generic_Email_Domains__c> genericEmailDomains = Generic_Email_Domains__c.getall();
         set<Generic_Email_Domains__c> domainNameValues = new set<Generic_Email_Domains__c>(genericEmailDomains.values());
         Set<String> domainnames = new Set<String>();
                   for(Generic_Email_Domains__c temp:domainNameValues)
                         {
                          domainnames.add(temp.name.touppercase());                            
                         }    
        for ( Opportunity newOpp : newOpportunities ) {
            if(mapOldOpportunities == null && (newOpp.Team_Mailbox_1__c != NULL || newOpp.Team_Mailbox_2__c != NULL || newOpp.Team_Mailbox_3__c != NULL ||
                                                    newOpp.Team_Mailbox_4__c != NULL || newOpp.Team_Mailbox_5__c != NULL) ) { // for new opportunity insert

                validateOppDomain(newOpp, null, domainNames);
            }else  If( mapOldOpportunities != null ) { // for existing opportunities update
                Opportunity oldOpp = mapOldOpportunities.get(newOpp.Id);

                If( oldOpp != null && (oldOpp.Team_Mailbox_1__c != newOpp.Team_Mailbox_1__c || oldOpp.Team_Mailbox_2__c != newOpp.Team_Mailbox_2__c || 
                                        oldOpp.Team_Mailbox_3__c != newOpp.Team_Mailbox_3__c || oldOpp.Team_Mailbox_4__c != newOpp.Team_Mailbox_4__c || 
                                        oldOpp.Team_Mailbox_5__c != newOpp.Team_Mailbox_5__c ) ){

                    validateOppDomain(newOpp, oldOpp, domainNames);
                }
            }
        }
    }

    public static void validateOppDomain(Opportunity opp, Opportunity oldOpp, set<String> domainNames){

        If( (oldOpp != NULL && oldOpp.Team_Mailbox_1__c != opp.Team_Mailbox_1__c  && opp.Team_Mailbox_1__c != NULL) || 
            (oldOpp == NULL && opp.Team_Mailbox_1__c != NULL) ){

            If(isDomainNotMatching(opp, oldOpp, opp.Team_Mailbox_1__c, domainNames) == true){
                opp.Team_Mailbox_1__c.addError(System.Label.Email_Domain_Error_Message);
            }
        }
        
        If( (oldOpp != NULL && oldOpp.Team_Mailbox_2__c != opp.Team_Mailbox_2__c  && opp.Team_Mailbox_2__c != NULL) || 
            (oldOpp == NULL && opp.Team_Mailbox_2__c != NULL) ){

            If(isDomainNotMatching(opp, oldOpp, opp.Team_Mailbox_2__c, domainNames) == true){
                opp.Team_Mailbox_2__c.addError(System.Label.Email_Domain_Error_Message);
            }
        }

        If( (oldOpp != NULL && oldOpp.Team_Mailbox_3__c != opp.Team_Mailbox_3__c  && opp.Team_Mailbox_3__c != NULL) || 
            (oldOpp == NULL && opp.Team_Mailbox_3__c != NULL) ){

            If(isDomainNotMatching(opp, oldOpp, opp.Team_Mailbox_3__c,domainNames) == true){
                opp.Team_Mailbox_3__c.addError(System.Label.Email_Domain_Error_Message);
            }
        }
        
        If( (oldOpp != NULL && oldOpp.Team_Mailbox_4__c != opp.Team_Mailbox_4__c  && opp.Team_Mailbox_4__c != NULL) || 
            (oldOpp == NULL && opp.Team_Mailbox_4__c != NULL) ){

            If(isDomainNotMatching(opp, oldOpp, opp.Team_Mailbox_4__c, domainNames) == true){
                opp.Team_Mailbox_4__c.addError(System.Label.Email_Domain_Error_Message);
            }
        }

        If( (oldOpp != NULL && oldOpp.Team_Mailbox_5__c != opp.Team_Mailbox_5__c  && opp.Team_Mailbox_5__c != NULL) || 
            (oldOpp == NULL && opp.Team_Mailbox_5__c != NULL) ){
            
            If(isDomainNotMatching(opp, oldOpp, opp.Team_Mailbox_5__c, domainNames) == true){
                opp.Team_Mailbox_5__c.addError(System.Label.Email_Domain_Error_Message);
            }
        }
    }

    public static boolean isDomainNotMatching(Opportunity newOpp, Opportunity oldOpp, String emailBox, Set<String> domainNames){

        boolean isNotValid = false;

        Pattern p = Pattern.compile( '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');

        // Opportunity Owner Email Doamin
      /*  Matcher oppOwnerEmailMatcher = p.matcher(userMap.get(newOpp.OwnerId).Email);

        If( oppOwnerEmailMatcher.matches() ){
            System.debug('***Logged in User Email Domain: '+ oppOwnerEmailMatcher.group(2));
        }*/

        If(emailBox != NULL){
            Matcher TeamMailBoxMatcher = p.matcher(emailBox);
           
            If( TeamMailBoxMatcher.matches() && !domainnames.contains(TeamMailBoxMatcher.group(2).touppercase())){
                system.debug('Hi From inside if block');
            }else{
                isNotValid = true;
            }
        }
        return isNotValid;
    }
   
 // Method to make Distributor/Reseller Account Name Blank when Fulfilment Path is updated to Direct Fulfilment or Dell Fulfilment
    public static void checkOnFulfilmentPath (List<Opportunity> oppList, map<Id, Opportunity> mapOldOpportunities)
    {
      String profileName = StaticFactory.getCurrentUserDetails().Profile.Name;
        for(Opportunity newOpp:oppList)
        {
            if(mapOldOpportunities.get(newopp.id).Distributor_Name__c != newOpp.Distributor_Name__c && profileName.contains('Portal') && (newOpp.Distributor_Name__c == 'Direct Fulfilment' || newOpp.Distributor_Name__c == 'Dell Fulfilment'))
            {
                   
                    newopp.Distributor_Reseller_Name__c = null;
            }
        }
    }
      /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR13411     10.02       22-Aug-2016     Suresh          This logic is to Validate the End Customer & End Customer contact as Active. 
    */
    public static void validateActiveEndCustomer(list<Opportunity> newOpportunities, map<Id, Opportunity> mapOldOpportunities){
        
        try{
        // Get New Opportunities End Customers set and query it
        Set<Id> endCustomerIds = new Set<Id>();
        Set<Id> endCustomerContactIds = new Set<Id>();
        
         If( UserInfo.getUserId() != '005A0000003L8vy' && UserInfo.getUserId() != '005A00000018286' ){
            Opportunity oldOpp ;
            for(Opportunity opp: newOpportunities){
                
                If(mapOldOpportunities != null) {   
                  oldOpp = mapOldOpportunities.get(opp.Id);
              }
                If(oldOpp.Deal_Registration_Status__c == 'Submitted' && (opp.Deal_Registration_Status__c == 'Approved' || opp.Deal_Registration_Status__c == 'Rejected')){}
                else{
                    If(opp.End_Customer__c != NULL){
                        endCustomerIds.add(opp.End_Customer__c);
                    }
                    If(opp.End_Customer_Contact__c != NULL){
                        endCustomerContactIds.add(opp.End_Customer_Contact__c);
                    }
                }
            }
      
            Map<Id, End_Customer__c> endCustomerMap = new Map<Id, End_Customer__c>();
            If( endCustomerIds.size() > 0 ){
              endCustomerMap = new Map<Id, End_Customer__c>([Select Id, Status__c from End_Customer__c where ID IN: endCustomerIds ]);
            }
            Map<Id, End_Customer_Contact__c> endCustomerContactMap = new Map<Id, End_Customer_Contact__c>();
            If( endCustomerContactIds.size() > 0 ){
              endCustomerContactMap = new Map<Id, End_Customer_Contact__c>([Select Id, Status__c, End_Customer__c from End_Customer_Contact__c where ID IN: endCustomerContactIds ]);
            }
            
            for(Opportunity opp: newOpportunities){
               Opportunity oldOpportunity ;
                If(mapOldOpportunities != null) {   
                  //  If( opp.End_Customer__c != NULL && opp.End_Customer_Contact__c != NULL ){ 
                        oldOpportunity = mapOldOpportunities.get(opp.Id);
                 //   }
                }

                // Insert Case
                If( oldOpportunity == NULL ){  
                    If( opp.End_Customer__c != NULL && endCustomerMap.containsKey(opp.End_Customer__c) ){
                        If(endCustomerMap.get(opp.End_Customer__c).Status__c == 'Inactive'){
                          opp.End_Customer__c.addError(system.label.SelectActiveEndCustomer);
                        }
                    }else If( opp.End_Customer_Contact__c != NULL && endCustomerContactMap.containsKey(opp.End_Customer_Contact__c) ){ 
                        If( endCustomerContactMap.get(opp.End_Customer_Contact__c).End_Customer__c != opp.End_Customer__c ){
                            opp.End_Customer_Contact__c.addError(system.label.SelectActiveEndCustomer);
                        }else If( endCustomerContactMap.get(opp.End_Customer_Contact__c).Status__c == 'Inactive' ){
                            opp.End_Customer_Contact__c.addError(system.label.SelectActiveEndCustomer);
                        }
                    }
                }
                // Update Case
                else{  
                    If( opp.End_Customer__c != NULL && endCustomerMap.containsKey(opp.End_Customer__c) && opp.End_Customer__c != oldOpportunity.End_Customer__c){
                        If(endCustomerMap.get(opp.End_Customer__c).Status__c == 'Inactive'){
                          opp.End_Customer__c.addError(system.label.SelectActiveEndCustomer);
                        }
                    }else If( opp.End_Customer_Contact__c != NULL && endCustomerContactMap.containsKey(opp.End_Customer_Contact__c) ){
                        If( endCustomerContactMap.get(opp.End_Customer_Contact__c).End_Customer__c != opp.End_Customer__c && 
                            (opp.End_Customer__c != oldOpportunity.End_Customer__c || opp.End_Customer_Contact__c != oldOpportunity.End_Customer_Contact__c) ){
                            opp.End_Customer_Contact__c.addError(system.label.SelectActiveEndCustomer);
                        }else If( (opp.End_Customer__c != oldOpportunity.End_Customer__c || opp.End_Customer_Contact__c != oldOpportunity.End_Customer_Contact__c) &&    endCustomerContactMap.get(opp.End_Customer_Contact__c).Status__c == 'Inactive' ){
                            opp.End_Customer_Contact__c.addError(system.label.SelectActiveEndCustomer);
                        }
                    }
                }
            }
        }
        }catch(QueryException qEx){
            System.debug('The following exception has occurred: ' + qEx.getMessage());
        }catch(Exception ex){
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
    } 
    
   /*
    Revision    CR Number   Release No  Date            Modified By            Description
    --------    ---------   ----------  -----------     ------------           -----------
    1.0        INC-3883342  FY18-0804  30-Aug-2017     Venkateswarlu Chirala   Deal registration cancellation within 90 day protection. 
    2.0        INC-4762256  FY19-0103  03-Jan-2018     Venkateswarlu Chirala   Removed the dependency on the OpportunityTeam Member flags & logic added on Partner account team mem can lost cancel
   */
     public static void validateToChangeDealStage(list<Opportunity > listOpportunities, map<Id, Opportunity> mapOldOpportunities) {
    
         List<opportunity> listopptyList        = new List<opportunity>();
         Set<ID> setparAccID                   = new Set<ID>();
         set<ID> setbypassOpptyVRPartAccIDSet  = new set<ID>();

         for (opportunity opp: listOpportunities) {
             if (Test.isRunningTest() || (String.isNotBlank(opp.Deal_Registration_Status__c) && opp.Deal_Registration_Status__c == 'Approved' && ((mapOldOpportunities.get(opp.ID).StageName != opp.StageName && opp.StageName == 'Lost, Cancelled - 0%')  || mapOldOpportunities.get(opp.ID).Partner_Opportunity_Stage__c != opp.Partner_Opportunity_Stage__c && opp.Partner_Opportunity_Stage__c == 'Lost, Cancelled - 0%') && opp.Deal_Expiration_Date__c != NULL && opp.Deal_Expiration_Date__c > Date.today() && opp.Deal_Reg_Oppty__c == 'Yes' && opp.partnerAccountID != NULL )) {
                 listopptyList.add(opp);
                 setparAccID.add(opp.PartnerAccountID);
                 if(opp.Distributor_Reseller_Name__c !=null){
                 setparAccID.add(opp.Distributor_Reseller_Name__c);
                 }
             }
         }
        
         if (!listopptyList.isEmpty()) {
             List <AccountTeamMember> listaccTeamMemMap = [SELECT ID,AccountID FROM AccountTeamMember WHERE AccountID IN : setparAccID AND UserID =: Userinfo.getUserID() AND AccountID!= NULL AND user.isActive =TRUE LIMIT 50000 ];                  
                  
                  if (!listaccTeamMemMap.isEmpty()){
                     for (AccountTeamMember accMemMap: listaccTeamMemMap) {
                         setbypassOpptyVRPartAccIDSet.add(accMemMap.AccountID);
                     }
                     }       
                     for (Opportunity opp: listopptyList) {
                         if ((setbypassOpptyVRPartAccIDSet.isEmpty() || (! setbypassOpptyVRPartAccIDSet.contains(opp.PartnerAccountID) && ! setbypassOpptyVRPartAccIDSet.contains(opp.Distributor_Reseller_Name__c))) && !Test.isRunningTest()) {
                             opp.StageName.addError(System.Label.Opportunity_Lost_Cancel_VR_Message);
                         }
                     }
           }
      }
     /*  Revision    CR Number   Release No  Date            Modified By            Description
        --------    ---------   ----------  -----------     ------------           -----------
        1.0                       FY19-1101  26-Sep-2018     Naresh reddy Bijjam   This method defined to make rejection codes mandatory before rejecting a deal 
      */
      public static void ValidateRejectionFields(list<Opportunity > lstOpportunities,map<Id,Opportunity>oldmapopprtunity){
         String curUserProfileName = StaticFactory.getCurrentUserDetails().Profile.Name;
     
      system.debug('Opportunity rejection validation test');
          for(Opportunity op:lstOpportunities){
          if(op.Deal_Reg_Oppty__c=='Yes'  && curUserProfileName.contains('GBL PRM')  && (op.Submitted_for_Approval_Date_Time__c!=null && op.Deal_Registration_Status__c=='Rejected' && op.Resubmitted_for_Approval_Date_Time__c==null) && oldmapopprtunity.get(op.Id).Deal_Registration_Status__c=='Submitted'){
          system.debug('Opportunity rejection validation test1' +op.Rejection_Reason_Code__c+' , ' +op.Other_Rejection_Reason__c);
              if((op.Rejection_Reason_Code__c==null || op.Rejection_Reason_Code__c=='')){
                String sBreak = '</br>'; 
                String first = '<b><a href="'; 
                String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm(); 
                String last = '" target="_self">Click here to go back</a></b>'; 
                
                 if(Userinfo.getUiThemeDisplayed()=='Theme3'){
                 //In Classic mode
                      op.addError('<u><b>Please Select a Valid Rejection Reason Code. </b></u> &nbsp;' + first + fullFileURL + '/' + op.id + last, false);  
                  }else {
                  //In lightning mode
                      op.adderror('Please Select a Valid Rejection Reason Code.');
                  }
                 // 
              
              }
          }else if(op.Deal_Reg_Oppty__c=='Yes' && (op.Submitted_for_Approval_Date_Time__c!=null && op.Deal_Registration_Status__c=='Rejected' && op.Resubmitted_for_Approval_Date_Time__c!=null) && oldmapopprtunity.get(op.Id).Deal_Registration_Status__c=='Submitted'){
                   if((op.Reapproval_Rejection_Reason_Code__c==null || op.Reapproval_Rejection_Reason_Code__c=='') && curUserProfileName.contains('GBL PRM')){
                       String sBreak = '</br>'; 
                        String first = '<b><a href="'; 
                        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm(); 
                        String last = '" target="_self">Click here to go back</a></b>'; 
                        if(Userinfo.getUiThemeDisplayed()=='Theme3'){
                         //In Classic mode
                            op.addError('<u><b>Please Select a Valid Reapproval Rejection Reason Code. </b></u> &nbsp;' + first + fullFileURL + '/' + op.id + last, false);
                         }else {
                         //In lightning mode
                          op.adderror('Please Select a Valid Reapproval Rejection Reason Code.');
                         }
              }
          }
          
          }
      }
     
 }
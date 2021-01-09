/*****************************************************************************
*CreatedBy : Ankur Saxena
* 
* Purpose: To accomodate the changes which needs to be done for Renewal Opportunity
*
* Story No.6302878- Ankur - RenewalOpportunityTriggerHandler to add dummy product.
* Story 7350413:      Ankur   RE129- Dummy Line Item- Re-process
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 3.0      CR17954    FY20-DCS-1002 05-Sep-2019     Shubham Bhatt     Creating New method setOpportunityOwner  
* 4.0      CR18285    FY20-DCS-0102 08-Nov-2019     Shubham Bhatt     Creating New method setEMCOpportunityUpdated  
* 5.0      CR18376    FY20-DCS-0202 10-Dec-2019     Shubham Bhatt     Creating New method createRenewalQuotingCase  
* 5.1      TFS8079809 FY20-DCS-0202 16-Feb-2020     Gan               Fixing production defect TFS8079809 where email sending to AE unintentionally
*******************************************************************************/

Public Class RenewalOpportunityTriggerHandler {
    
    
    Public Static void validateEmcOppAmountUpdateRenewal(List < Opportunity > listOpp, Map < Id, Opportunity > mapOldOpp) {
        
        Id devRecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('APOS').getRecordTypeId();
        map < id, Decimal > mapOppidAmount = New map < id, Decimal > ();
        map < id, list < opportunityLineItem >> mapOppLineItem = New map < id, list < opportunitylineItem >> ();
        map < id, opportunity > mapIdOpp = New Map < id, opportunity > ();
        map < id, id > mapOppPricebookid = New map < id, id > ();
        Set < String > setCurrencyCode = New Set < String > ();
        system.debug('----listOpp---' + listOpp);
        For (opportunity opp: listOpp) {
            If(opp.EMC_Opportunity_Amount__c!= null && (mapOldOpp.get(opp.id).EMC_Opportunity_Amount__c!= opp.EMC_Opportunity_Amount__c || opp.EMC_Opportunity_Amount__c != opp.Amount) && opp.Number_of_Line_Items__c!= 0) {
                
                mapOppidAmount.put(opp.Id, Opp.EMC_Opportunity_Amount__c);
                
                mapOppPricebookid.put(opp.id, opp.pricebook2Id);
                
                mapIdOpp.put(opp.id, opp);
                setCurrencyCode.add(opp.CurrencyIsoCode);
            }
            
        }
        map < string, id > mappricebookentryid = New Map < string, id > ();
        List < PriceBookEntry > listPriceBookList = [SELECT Id, Product2Id, Product2.Product_ID__c, pricebook2id, currencyIsoCode, Product2.Name FROM PriceBookEntry WHERE Product2.Product_ID__c =: System.Label.DummyProductId And PriceBook2Id IN: mapOppPricebookid.values() And currencyIsoCode IN: setCurrencyCode];
        system.debug('----listPriceBookList ----' + listPriceBookList);
        For (PriceBookEntry lst: listPriceBookList) {
            mappricebookentryid.put(lst.pricebook2id + '-' + lst.currencyIsoCode, lst.id);
        }
        
        list < opportunityLineItem > listLineItem = New list < opportunityLineItem > ();
        map < id, opportunitylineItem > mapOppIdOpportunityLineItem = New map < id, opportunitylineItem > ();
        map < id, decimal > mapopportunitylinetotalprice = New map < id, decimal > ();
        listLineItem = [select id, opportunityid, Product2.Product_ID__c, Product2Id, TotalPrice from opportunityLineItem where opportunityId IN: mapOppidAmount.keyset()];
        list < opportunityLineItem > listOppi = New list < opportunityLineItem > ();
        list < opportunityLineItem > listOliDelete = New list < opportunityLineItem > ();
        
        For (opportunityLineItem opl: listLineItem) {
            If (opl.Product2.Product_ID__c == System.Label.DummyProductId) {
                mapOppIdOpportunityLineItem.put(opl.opportunityId, opl);
            } else {
                If (mapopportunitylinetotalprice.containskey(opl.opportunityid)) {
                    Double dblS = mapopportunitylinetotalprice.get(opl.opportunityId);
                    dblS = dblS + opl.TotalPrice;
                    mapopportunitylinetotalprice.put(opl.opportunityid, dblS);
                } else {
                    mapopportunitylinetotalprice.put(opl.opportunityid, opl.totalPrice);
                }
            }
        }
        
        For (id striIds: mapOppidAmount.keyset()) {
            Decimal dcAmount = mapOppidAmount.get(striIds);
            Decimal dcLineItemAmount = 0;
            If (mapopportunitylinetotalprice.containskey(striIds)) {
                dcLineItemAmount = mapopportunitylinetotalprice.get(striIds);
            }
            If (dcAmount!= dcLineItemAmount && !mapOppIdOpportunityLineItem.containskey(striIds)) {
                Decimal dcAbc = dcAmount - dcLineItemAmount;
                OpportunityLineItem oppli = New OpportunityLineItem(); //---->Create OpportunityLineItem.
                If (mapIdOpp.get(striIds).pricebook2Id!= null) {
                    oppli.PricebookEntryId = mappricebookentryid.get(MapIdOpp.get(striIds).PriceBook2Id + '-' + mapIdopp.get(striIds).currencyIsoCode);
                } else {oppli.PricebookEntryId = mappricebookentryid.get(System.label.getStandardPriceBookId + '-' + mapIdOpp.get(striIds).currencyIsoCode);
                       }
                oppli.OpportunityId = striIds;
                oppli.Quantity = 1;
                oppli.TotalPrice = dcAbc;
                listOppi.add(oppli);
            }
            If (dcAmount!= dcLineItemAmount && mapOppIdOpportunityLineItem.containskey(striIds)) {
                Decimal dcAbc = dcAmount - dcLineItemAmount;
                OpportunityLineItem oppli = mapOppIdOpportunityLineItem.get(striIds); //---->Create OpportunityLineItem.
                oppli.Quantity = 1;
                oppli.TotalPrice = dcAbc;
                listOppi.add(oppli);
            }
            If (dcAmount == dcLineItemAmount && mapOppIdOpportunityLineItem.containskey(striIds)) {
                OpportunityLineItem oppli = mapOppIdOpportunityLineItem.get(striIds); //---->Create OpportunityLineItem.
                listOliDelete.add(oppli);
            }
            
        }
        list < opportunityLineItem > listOliInsert = New List < OpportunityLineItem > ();
        list < opportunityLineItem > listOliUpdate = New List < OpportunityLineItem > ();
        For (opportunityLineItem opli: listOppi) {
            If (opli.id == null) {
                listOliInsert.add(opli);
            } else if (opli.id != null) {
                listOliUpdate.add(opli);
                
            }
            
        }
        
        List < Database.SaveResult > listResultsInsert = New list < Database.SaveResult > ();
        List < Database.SaveResult > listResultsUpdate = New list < Database.SaveResult > ();
        Set < Id > setStrId = New Set < Id > ();
        map < id, string > mapError = New Map < id, string > ();
        Try {
            If (!listOliInsert.isempty()) {
                TriggerExecutionController.SetskipAlltriggers(true);
                listResultsInsert = Database.insert(listOliInsert, false);
                TriggerExecutionController.SetskipAlltriggers(false);
                
                For (Integer intNum = 0; intNum < listResultsInsert.size(); intNum++) {
                    If (!listResultsInsert[intNum].isSuccess()) {
                        String strA;
                        //setStrId.add(listOliInsert[intNum].OpportunityId);
                        For (Database.Error err: listResultsInsert[intNum].getErrors()) {
                            strA = err.getMessage();
                        }
                        mapError.put(listOliInsert[intNum].OpportunityId, strA);
                    }
                }
            }
            If (!listOliUpdate.isempty()) {
                TriggerExecutionController.SetskipAlltriggers(true);
                listResultsUpdate = Database.update(listOliUpdate, false);
                TriggerExecutionController.SetskipAlltriggers(false);
                For (Integer intNum = 0; intNum < listResultsUpdate.size(); intNum++) {
                    If (!listResultsUpdate[intNum].isSuccess()) {
                        String strA;
                        //setStrId.add(listOliInsert[intNum].OpportunityId);
                        For (Database.Error err: listResultsUpdate[intNum].getErrors()) {
                            strA = err.getMessage();
                        }
                        mapError.put(listOliUpdate[intNum].OpportunityId, strA);
                    }
                }
            }
            system.debug('listResultsInsert@@===' + listResultsInsert);
            system.debug('listResultsUpdate@@===' + listResultsUpdate);
            // system.debug('setStrId@==='+ setStrId);
            If (!mapError.isempty()) {
                For (opportunity opps: listOpp) {
                    If (mapError.containsKey(opps.id)) { opps.adderror('ERROR::' + mapError.get(opps.id));
                                                       }
                }
            }
        } catch (DmlException e) {
            TriggerExecutionController.SetskipAlltriggers(false);
            System.debug('The Upsert exception has occurred Due To Following: ' + e.getMessage());
            
            
        }
        map < id, String > mapErrorD = New Map < id, string > ();
        If (!listOliDelete.isempty()) {
            List < Database.DeleteResult > listResultsDelete = New list < Database.DeleteResult > ();
            Try {
                
                //delete listOliDelete;
                If (!listOliDelete.isempty()) {
                    TriggerExecutionController.SetskipAlltriggers(true);
                    listResultsDelete = Database.delete(listOliDelete, false);
                    TriggerExecutionController.SetskipAlltriggers(false);
                    For (Integer intNum = 0; intNum < listResultsDelete.size(); intNum++) {
                        If (!listResultsDelete[intNum].isSuccess()) {
                            
                            String strA;
                            //setStrId.add(listOliInsert[intNum].OpportunityId);
                            For (Database.Error err: listResultsDelete[intNum].getErrors()) {
                                strA = err.getMessage();
                            } mapErrorD.put(listOliDelete[intNum].OpportunityId, strA);
                        }
                    }
                }
                If (!mapErrorD.isempty()) {
                    For (opportunity opps: listOpp) {
                        If (mapErrorD.containsKey(opps.id)) {
                            opps.adderror('ERROR ::' + mapErrorD.get(opps.id));
                        }
                    }
                }
                system.debug('listResultsDelete@@===' + listResultsDelete);
                //system.debug('setdelete@==='+ setdelete);
            } catch (DmlException e) {
                TriggerExecutionController.SetskipAlltriggers(false);
                System.debug('The Delete exception has occurred Due To Following: ' + e.getMessage());
            }
        }
        
    }
    
    Public Static map<id,String> getValidatePricebook( Set<id> setId )
    {
        Map<id,string> mapValues = New Map<id,string>();
        
        List<Account> listAcc = [select id,name,Regional_Parent_Name_lookup__c,Regional_Sub_Parent_Name_lookup__c from Account where ID IN:  setId];
        system.debug('list Account '+ listAcc);
        For (Account acc : listAcc)
        {
            If (!String.isBlank(acc.Regional_Parent_Name_lookup__c)) {
                If (acc.Regional_Parent_Name_lookup__c == 'APJ')
                {
                    mapValues.put(acc.id,'ABU/APJ Standard Catalog');
                }
                Else If (acc.Regional_Parent_Name_lookup__c == 'EMEA')
                {
                    mapValues.put(acc.id,'EMEA Standard Catalog');
                }
                Else If (acc.Regional_Parent_Name_lookup__c == 'AMER')
                {
                    If(String.isBlank(acc.Regional_Sub_Parent_Name_lookup__c) || acc.Regional_Sub_Parent_Name_lookup__c == 'NAMER' || Acc.Regional_Sub_Parent_Name_lookup__c == 'NORTH AMER') {
                        mapValues.put(acc.id,'ABU/APJ Standard Catalog');
                    }
                    Else {
                        mapValues.put(acc.id,'LA Standard Catalog');
                    }
                }
                
            } 
            
        }
        system.debug('map values ==='+ mapvalues);
        Return mapValues;
    }
    
    /*******************************************************************************************************************/
    
    Public Static void validateEmcOppAmountRenewalbeforeInsert(List < Opportunity > listOpp) {
        
        Map < id, string > mapAccIdPricebook = New Map < id, string > ();
        Set < id > setAccId = New Set < Id > ();
        For (opportunity opp: ListOpp) {
            If (opp.AccountId!= null && opp.pricebook2Id == null) {
                setAccId.add(opp.AccountId);
            } else if (Opp.pricebook2Id != null) {
                opp.Amount = opp.EMC_Opportunity_Amount__c;
            }
            
        }
        If (!setAccId.isempty()) {
            mapAccIdPricebook = getValidatePricebook(setAccId);
        }
        //system.debug('mapAccIdPricebook==='+mapAccIdPricebook);
        
        //string strA = RenewalOpportunity_Utils.strsourceSystemRenewalsEBIA ;
        For (opportunity opp: listOpp) {
            system.debug('in main class ===Ankur');
            If (opp.EMC_Opportunity_Amount__c!= null && opp.EMC_Opportunity_Amount__c!= opp.Amount) {
                opp.Amount = opp.EMC_Opportunity_Amount__c;
                If (mapAccIdPricebook.containskey(opp.AccountId)) {
                    
                    String stringIds = RenewalsLabels__c.getInstance(mapAccIdPricebook.get(opp.AccountId)).labelValue__c;
                    
                    opp.pricebook2Id = stringIds;
                    
                    system.debug('opp amount ===' + opp.Amount);
                    system.debug('pricebookId===' + opp.pricebook2Id);
                }
                
            }
        }
        
        
    }
    /****************************************END of Before Insert **************************************************/
    
    
    /*********START*********Added by Shubham Bhatt(Rubicon)*****************************************/
    /*********START*********STORY - 6295277*****************************************/
    //method to update opportunity owner as per account team member user, if role Is "Service Global Renewals Sales Rep" else account owner will be opportunity owner 
    //on creation of opportunity
    Public Static void setOpportunityOwner(list < opportunity > listInsertedOptties) {
        Try {
            
            list < accountteammember > listAccTeamMember = New list < accountteammember > (); //to fetch all related account team members related to accounts coming in loop 
            map < id, id > mapAccntOptyWithOwnerFromTeamMember = New map < id, id > (); //map for storing account with owners if found respective teammemberrole
            map < id, id > mapAccntOptyWithoutTeamMember = New map < id, id > (); //map for storing account with account owner when no record present for account team member 
            map < id, list < opportunity >> mapAccntOppty = New map < id, list < opportunity >> (); //map to store account with all related opportunities
            Set < id > setAccountIdsWhichDoesntHaveMemberRole = New Set < Id > (); //Set To store ids Of accounts which are Not having account team members
            //filling map with account And related opportunities
            For (opportunity opp: listInsertedOptties) {
                If (mapAccntOppty.containsKey(opp.accountid)) {
                    List < opportunity > listOpptyToBeAdded = mapAccntOppty.get(opp.accountid);
                    listOpptyToBeAdded.add(opp);
                    mapAccntOppty.put(opp.accountid, listOpptyToBeAdded);
                } else {
                    mapAccntOppty.put(opp.accountid, New List < opportunity > {
                        opp
                            });
                }
            }
            
            //fetching all team members record related to associated accounts coming with opportunities
            If (!mapAccntOppty.isEmpty()) {
                listAccTeamMember = [select id, userid, accountid, TeamMemberRole, account.ownerid from accountteammember where accountid in: mapAccntOppty.keyset() And TeamMemberRole =: RenewalOpportunity_Utils.strteamMemberRole order by lastmodifieddate desc];
            }
            
            //filling maps as per the criteria of team member records
            If (!listAccTeamMember.isEmpty()) {
                For (accountteammember acctTeamMem: listAccTeamMember) {
                    If (!mapAccntOptyWithOwnerFromTeamMember.containskey(acctTeamMem.accountid)) {
                        mapAccntOptyWithOwnerFromTeamMember.put(acctTeamMem.accountid, acctTeamMem.userid);
                    }
                }
                
            }
            
            //filling maps as per the criteria when no team member record found
            If (!mapAccntOppty.isEmpty()) {
                For (id idValue: mapAccntOppty.keyset()) {
                    If (!mapAccntOptyWithOwnerFromTeamMember.containsKey(idValue)) {
                        setAccountIdsWhichDoesntHaveMemberRole.add(idValue);
                    }
                }
            }
            system.debug('---last  444-' + setAccountIdsWhichDoesntHaveMemberRole);
            If (!setAccountIdsWhichDoesntHaveMemberRole.isEmpty()) {
                map < id, account > mapAccntToFetchOwner = New map < id, account > (OpportunityTriggerHandler.oppRecordSelector.mapRelatedAccounts);
                For (id accId: mapAccntOppty.keyset()) { 
                    If (mapAccntToFetchOwner.containsKey(accId) && setAccountIdsWhichDoesntHaveMemberRole.contains(accId)) {
                        mapAccntOptyWithoutTeamMember.put(accId, mapAccntToFetchOwner.get(accId).ownerid);
                    }
                    
                }
            }
            
            system.debug('---last  44-' + mapAccntOptyWithOwnerFromTeamMember);
            system.debug('---last  4444-' + mapAccntOptyWithoutTeamMember);
            
            //assigning opportunities owners accordingly from respective maps
            For (opportunity opp: listInsertedOptties) {
                If (!mapAccntOptyWithOwnerFromTeamMember.isEmpty()) {
                    If (mapAccntOptyWithOwnerFromTeamMember.containskey(opp.accountid)) {
                        opp.ownerid = mapAccntOptyWithOwnerFromTeamMember.get(opp.accountid);
                    }
                }
                If (!mapAccntOptyWithoutTeamMember.isEmpty()) {
                    If (mapAccntOptyWithoutTeamMember.containskey(opp.accountid)) {
                        opp.ownerid = mapAccntOptyWithoutTeamMember.get(opp.accountid);
                    }
                }
                
            }
            
        }
        Catch(DmlException e) {
            System.debug('The exception has occurred while setting opportunity owner: ' + e.getMessage());
        }
    }
    /*********STOP*********STORY - 6295277*****************************************/
    /*********START*********STORY - 7643105*********************this method is setting the EMC Opportunity Updated field as RENEWAL WAITING SYNC********************/
    Public Static void setEMCOpportunityUpdated(list < opportunity > listInsertedOptties, map<id,opportunity> mapOldOpties) {
        For (opportunity opp: listInsertedOptties){
            If (mapOldOpties!= null){
                If ((opp.EMC_Opportunity_updated__c!= RenewalOpportunity_Utils.strRenewalWaitingSync) &&
                    (
                        opp.PO_at_Partner__c != mapOldOpties.get(opp.id).PO_at_Partner__c ||
                        opp.Name!= mapOldOpties.get(opp.id).Name ||
                        opp.AccountId != mapOldOpties.get(opp.id).AccountId ||
                        opp.CurrencyIsoCode != mapOldOpties.get(opp.id).CurrencyIsoCode ||
                        opp.OwnerId != mapOldOpties.get(opp.id).OwnerId ||
                        opp.CloseDate != mapOldOpties.get(opp.id).CloseDate ||
                        opp.StageName != mapOldOpties.get(opp.id).StageName || 
                        opp.ForecastCategoryName != mapOldOpties.get(opp.id).ForecastCategoryName ||
                        opp.VCE_Forecast_Amount__c != mapOldOpties.get(opp.id).VCE_Forecast_Amount__c ||
                        opp.Support_Level__c != mapOldOpties.get(opp.id).Support_Level__c ||
                        opp.PO_Number__c != mapOldOpties.get(opp.id).PO_Number__c ||
                        opp.Renewals_Campaign__c != mapOldOpties.get(opp.id).Renewals_Campaign__c || 
                        opp.Distributor_Direct_Reseller_Account__c != mapOldOpties.get(opp.id).Distributor_Direct_Reseller_Account__c || 
                        opp.Indirect_Partner_Account__c != mapOldOpties.get(opp.id).Indirect_Partner_Account__c || 
                        opp.Primary_Alliance_Partner__c != mapOldOpties.get(opp.id).Primary_Alliance_Partner__c || 
                        opp.Reason_Won_Lost__c != mapOldOpties.get(opp.id).Reason_Won_Lost__c || 
                        opp.Confirm_Competitor_Lost_To__c != mapOldOpties.get(opp.id).Confirm_Competitor_Lost_To__c || 
                        opp.Confirm_Competitor_Lost_To_Product__c != mapOldOpties.get(opp.id).Confirm_Competitor_Lost_To_Product__c || 
                        opp.Amount != mapOldOpties.get(opp.id).Amount || 
                        opp.Probability != mapOldOpties.get(opp.id).Probability || 
                        opp.Discount_Percentage__c != mapOldOpties.get(opp.id).Discount_Percentage__c  
                    )
                   ){
                       opp.EMC_Opportunity_updated__c = RenewalOpportunity_Utils.strRenewalWaitingSync;
                   }
            }else{
                opp.EMC_Opportunity_updated__c = RenewalOpportunity_Utils.strRenewalWaitingSync;
            }	
        }
    }
    /*********STOP*********STORY - 7643105*********************this method is setting the EMC Opportunity Updated field as RENEWAL WAITING SYNC********************/
    /*********START*********Added by Shubham Bhatt for STORY - 7754350****************************************/
    //Moving a node from PB Opportunity - Process Builder - Master 1 (Created) which created case for renewal opty when created by is Renewal EBIA Integration user
    Public Static void createRenewalQuotingCase(list<OpportunityChangeEvent> listOpty,map<id,  OpportunityChangeEvent> mapOptyChangeEvent ){
        list<opportunity> listRenewalOpty = new list<opportunity>();//to filter APOS opties
        List<Exception__c> listException = new List<Exception__c>();//list for keeping track of failed records
        map<id, case> mapOptyCase = new map<id,case>();//to keep case records - to be created to related opties
        list<id> listOptyId = new list<id>();
        map<Id, Opportunity> mapRelatedOpptyRecords;//  = new map<Id, Opportunity>();
         
        for(OpportunityChangeEvent opp : listOpty) {
            if(opp.ChangeEventHeader.getchangetype() == 'CREATE'){
                listOptyId.addAll(opp.ChangeEventHeader.getRecordIds());
            }
        }
        if(!listOptyId.isEmpty()){
            for(opportunity opp:   ([select Id,source_system__c,type,Trigger_Expiry_Qtr__c,recordtypeid,createdby.firstname,createdby.lastname,account.name from Opportunity where Id in :listOptyId])){
                if((opp.createdby.firstname == 'Renewals EBIA' && opp.createdby.lastname == 'Integration User')  && 
                   ((opp.recordtypeid == RenewalsConstants.aposRecordTypeId) && (opp.Source_System__c == RenewalsConstants.strsourceSystemEMCCore || opp.Source_System__c == RenewalsConstants.strsourceSystemRenewalsEBIA ||opp.type == RenewalsConstants.strtypeEMCRenewalsDirect || opp.type == RenewalsConstants.strtypeEMCRenewalsInDirect))){
                       listRenewalOpty.add(opp); 
                   }   
            }
        }
          
        if(listRenewalOpty != null){
            for(opportunity opp : listRenewalOpty){
                if(!mapOptyCase.containsKey(opp.id) ){
                    case cse = new case(); 
                    //5.1
                    cse.CaseRTMigrate__Customer_Account_Name__c = opp.accountid;
                    cse.CaseRTMigrate__Opportunity_Name__c = opp.id; 
                    cse.Case_Reason_Order_Support__c = 'Proactive Renewal';
                    cse.Description = 'Please create quote based on opp gen assets available in the opportunity product page. Also, double check that all assets are included by performing a full pull';
                    cse.Origin = 'Opp Gen';
                    cse.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().Get('Renewals Quote Request').getRecordTypeId();
                    cse.Status = 'Open';
                    cse.Sub_Type_Order_Support__c  = 'New Quote';
                    cse.Subject = 'PROACTIVE: '  + opp.account.Name +'_' + opp.Trigger_Expiry_Qtr__c;
                    cse.createdbyid = opp.CreatedById;
                    mapOptyCase.put(opp.id,cse);
                } 
            }
        }
        try {
            system.debug('--mapOptyCasemapOptyCase---'+mapOptyCase); 
            If (!mapOptyCase.values().isEmpty()){
                TriggerExecutionController.setSkipAllTriggers(true);
                Database.SaveResult[] listCase = Database.insert( mapOptyCase.values(), false);
                TriggerExecutionController.setSkipAllTriggers(false);
                
                //creating exception records for those which got errored out
                for(Integer intVar =0; intVar < listCase.size(); intVar++) {
                    if(!listCase.get(intVar).isSuccess()) {
                        // DML operation failed
                        listException.add(new Exception__c(Title__c = 'Renewal Proactive opportunity case creation', Error_Messages__c = '- Insertion Failed: Please refer to Notes field for Detailed Error Message', Object_type__c = 'Case', Object_ID__c =  mapOptyCase.values().get(intVar).Id, Operation__c = 'Insert', Process_Name__c = 'Renewal Proactive opportunity case creation', Notes__c = '- Insertion Failed: ' + listCase.get(intVar).getErrors()));
                    }
                }
            }
            insert listException;
        }catch(Exception e) {
            system.debug('--exception while creating renewal proactive opportunity case creation---'+e.getMessage());
            
        } 
    }
    /*********STOP*********Added by Shubham Bhatt(Rubicon) STORY - 7754350*****************************************/
}
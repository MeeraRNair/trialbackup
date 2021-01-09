/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         ....        ....            ....            ....            Initial class creation
2.0         CR 14342    FY18-DCS-0602   18-May-2017     Syidah          Direct associate Deal ID
3.0         CR 14660    FY18-DCS-0802   19-Jul-2017     Emily           To improve performance by not calling @future method
4.0         CR 16671    FY19-DCE-0102   15-Oct-2018     Venkat          Add validations as per OSC requirement.
*/    

global class SFDC_OSC_IntegrationService
{
    global class DealInfo
    {
        webService String status;
        webService String stage;
        webService Date expirationDate;
        webService String opportunityId;
        webService String opportunityName;
        webService String accountName;
    }
    
    //2.0
    global class DealInfoDirect
    {
        webService String status;
        webService String stage;
        webService Date expirationDate;
        webService String opportunityId;
        webService String opportunityName;
        webService String accountName;
        webService String errorDetails;
    }
    
    webService static DealInfo GetDealInfo(String dealId)
    {
        if(String.isNotBlank(dealId))
        {
            List<Opportunity> lstOpp = [SELECT Id, Name, Account.Name, StageName, Deal_Expiration_Date__c, Deal_Registration_Status__c FROM Opportunity WHERE Deal_ID__c =: dealId LIMIT 1];
            if(!lstOpp.isEmpty())
            {
                DealInfo objDI = new DealInfo();
                objDI.status = lstOpp.get(0).Deal_Registration_Status__c;
                objDI.stage = lstOpp.get(0).StageName;
                objDI.expirationDate = lstOpp.get(0).Deal_Expiration_Date__c;
                objDI.opportunityId = lstOpp.get(0).Id;
                objDI.opportunityName = lstOpp.get(0).Name;
                objDI.accountName = lstOpp.get(0).Account.Name;
                
                return objDI;
            }
        }
        return null;
    }
    
    //2.0
    webService static DealInfoDirect GetDealInfoDirect(String dealId, String errorDetails)
    {        
        if(String.isNotBlank(dealId))
        {
            List<Opportunity> lstOpp = [SELECT Id, Name, Account.Name, StageName, Deal_Expiration_Date__c, Deal_Registration_Status__c FROM Opportunity WHERE Deal_ID__c =: dealId LIMIT 1];
            if(!lstOpp.isEmpty())
            {
                DealInfoDirect objDI = new DealInfoDirect();
                objDI.status = lstOpp.get(0).Deal_Registration_Status__c;
                objDI.stage = lstOpp.get(0).StageName;
                objDI.expirationDate = lstOpp.get(0).Deal_Expiration_Date__c;
                objDI.opportunityId = lstOpp.get(0).Id;
                objDI.opportunityName = lstOpp.get(0).Name;
                objDI.accountName = lstOpp.get(0).Account.Name;
                objDI.errorDetails = '';
                
                return objDI;
            }
        }
        else if(String.isNotBlank(errorDetails))
        {
             DealInfoDirect objDI = new DealInfoDirect();
                objDI.status = '';
                objDI.stage = '';
                objDI.expirationDate = null;
                objDI.opportunityId = '';
                objDI.opportunityName = '';
                objDI.accountName = '';
                objDI.errorDetails = errorDetails;
                
                return objDI;            
        }       
        return null;
    }
    
    webService static DealInfo GetDealInfoForSolution(String solutionId, String region)
    {
        if(String.isNotBlank(solutionId) && String.isNotBlank(region))
        {
            String OSCRegionalId = region + ':' + solutionId;
            List<Solution__c> lstSolution = [SELECT Opportunity__r.Id, Opportunity__r.Name, Opportunity__r.Account.Name, Opportunity__r.StageName, Opportunity__r.Deal_Expiration_Date__c, Opportunity__r.Deal_Registration_Status__c FROM Solution__c WHERE OSC_Regional_ID__c =: OSCRegionalId LIMIT 1];
            if(!lstSolution.isEmpty() && lstSolution.get(0).Opportunity__r.Id != null)
            {
                DealInfo objDI = new DealInfo();
                objDI.status = lstSolution.get(0).Opportunity__r.Deal_Registration_Status__c;
                objDI.stage = lstSolution.get(0).Opportunity__r.StageName;
                objDI.expirationDate = lstSolution.get(0).Opportunity__r.Deal_Expiration_Date__c;
                objDI.opportunityId = lstSolution.get(0).Opportunity__r.Id;
                objDI.opportunityName = lstSolution.get(0).Opportunity__r.Name;
                objDI.accountName = lstSolution.get(0).Opportunity__r.Account.Name;
                
                return objDI;
            }
        }
        return null;
    }
    
    //V4.0 OSC confirmed its not using this Web Service
    webService static DealInfo AssociateDealWithSolution(String dealId, String solutionId, String region)
    {
        if(String.isNotBlank(dealId) && String.isNotBlank(solutionId) && String.isNotBlank(region))
        {
            String OSCRegionalId = region + ':' + solutionId;
            List<Solution__c> lstSolution = [SELECT Id, Opportunity__c FROM Solution__c WHERE OSC_Regional_ID__c =: OSCRegionalId LIMIT 1];
            
            if(lstSolution.isEmpty())
            {
                List<Opportunity> lstOpp = [SELECT Id FROM Opportunity WHERE Deal_ID__c =: dealId LIMIT 1];
                
                if(!lstOpp.isEmpty())
                {
                    Solution__c objSol = new Solution__c();
                    objSol.Opportunity__c = lstOpp.get(0).Id;
                    objSol.OSC_Regional_ID__c = OSCRegionalId;
                    
                    insert objSol;
                    
                    OSCWebServiceCallout.sendNotification(new List<Id>{lstOpp.get(0).Id}, 'Association');
                    
                    return GetDealInfo(dealId);
                }
            }
            else if(!lstSolution.isEmpty() && lstSolution.get(0).Opportunity__c != null)
            {
                return GetDealInfo(dealId);
            }
        }
        return null;
    }
    
    //2.0
    webService static DealInfoDirect DirectAssociateDealWithSolution(String dealId, String solutionId, String region)
    {
        if(String.isNotBlank(dealId) && String.isNotBlank(solutionId) && String.isNotBlank(region))
        {
            //List<User> lstUser = [SELECT Id FROM User WHERE Badge_Number__c =: userBadgeNo and Email =: userEmail LIMIT 1];
            //List<OpportunityShare> lstOppShare = [SELECT Id, OpportunityId  FROM OpportunityShare WHERE UserOrGroupId =: lstUser.get(0).Id and OpportunityId in (SELECT Id FROM Opportunity WHERE Deal_ID__c =: dealId) LIMIT 1];
            
            //V4.0 - Start
            List<Opportunity> listOpp = [SELECT Id,Deal_Reg_Oppty__c,StageName,Deal_Expiration_Date__c,Deal_Registration_Status__c FROM Opportunity WHERE Deal_ID__c =: dealId LIMIT 1];
                
            if(listOpp.isEmpty())
            {
                return GetDealInfoDirect('', 'This Deal Id does not exist in SFDC');             
            }
            else if(listOpp[0].Deal_Reg_Oppty__c == 'Yes' && listOpp[0].Deal_Expiration_Date__c != null  && listOpp[0].Deal_Expiration_Date__c < Date.today())
            {
                return GetDealInfoDirect('', 'This Deal is expired, please choose a different deal');
            }
            else if(listOpp[0].Deal_Reg_Oppty__c == 'Yes' && listOpp[0].Deal_Registration_Status__c != 'Approved'){
                return GetDealInfoDirect('', 'This Deal is not (yet) approved, please choose a different deal');
            }
            else if(listOpp[0].StageName == 'Win - 100%'){
                return GetDealInfoDirect('', 'This Opportunity is already closed as Won, please choose a different deal');
            }
            else if(listOpp[0].StageName == 'Lost, Cancelled - 0%'){
                return GetDealInfoDirect('', 'This Opportunity is already closed as Lost, please choose a different deal');
            } //V4.0 - End
            else
            {
                String strOSCRegionalId = region + ':' + solutionId;
                List<Solution__c> listSolution = [SELECT Id, Opportunity__c FROM Solution__c WHERE OSC_Regional_ID__c =: strOSCRegionalId LIMIT 1];
                
                if(listSolution.isEmpty())
                {
                    Solution__c objSol = new Solution__c();
                    objSol.Opportunity__c = listOpp.get(0).Id;
                    objSol.OSC_Regional_ID__c = strOSCRegionalId;
                    
                    //3.0 - CR 14660
                    Map<id,Opportunity> mapOpp = new Map<id,Opportunity>();
                    Map<Id,List<String>> listSendSol = new Map<Id,List<String>>();
                    Map<Id,List<Opportunitylineitem>> mapOpptyLineItem = new Map<ID,List<Opportunitylineitem>>();
                    list<opportunitylineitem> listOpptyLineItem = new list<opportunitylineitem>();
                    list<OSCWebServiceCallout.error> listIntegrationResults = new list<OSCWebServiceCallout.error>();
                            
                    Opportunity o = [select id, name, Account.Name, End_User_Account_Name__c, deal_id__c, deal_type__c, Deal_Expiration_Date__c, StageName, Deal_Registration_Status__c, OSC_Solution_Id__c, Opportunity_Customer_Number__r.Name, Affinity_ID__c, Unassigned_End_User__c, Unweighted_Rev_USD__c,partnerAccount.Account_id__c,PartnerAccount.name,PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c,PartnerAccount.Partner_Track__r.name 
                                    from opportunity 
                                    where id =:listOpp.get(0).Id];  
                    
                    listOpptyLineItem = [select Opportunity.Id, PricebookEntry.product2.name, PricebookEntry.productcode, product_type__c 
                                        from opportunitylineitem 
                                        where opportunity.id =:o.id];
                    
                    if(o != null)
                    { 
                        mapOpp.put(o.id,o);
                        listSendSol.put(o.id,new List<String>{strOSCRegionalId});
                        if(listOpptyLineItem.size() > 0){
                            mapOpptyLineItem.put(o.id,listOpptyLineItem);
                        }
                                              
                        listIntegrationResults = OSCWebServiceCallout.processRequest(mapOpp, listSendSol, 'Association', mapOpptyLineItem,true);
                        system.debug('################ listIntegrationResults' + listIntegrationResults);
                        
                        for(OSCWebServiceCallout.Error e: listIntegrationResults){
                            if(e.Messages.size() > 0){                         
                                return GetDealInfoDirect('', e.Messages[0].Description);
                            }     
                        }
                        
                        insert objSol;
                    
                        //OSCWebServiceCallout.sendNotification(new List<Id>{listOpp.get(0).Id}, 'Association');
                        
                        return GetDealInfoDirect(dealId, '');                         
                    }                   
                }
                else if(!listSolution.isEmpty() && listSolution.get(0).Opportunity__c != null)
                {
                    return GetDealInfoDirect(dealId, '');
                }               
            }
        }
        return null;
    }    
}
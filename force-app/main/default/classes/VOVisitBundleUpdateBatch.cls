/**
 * Batch job to handle the Visit Bundle sync issue,
 * this should be called from a scheduled job to handle the syn issue hourly
 * 
 */
global class VOVisitBundleUpdateBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext bct)
    {
        Datetime dtFrom = Datetime.now();
        dtFrom = dtFrom.addHours(-2);
        String strQuery = 'Select Id, VisitOpsP__Opp_Name__c, VisitOps__Opportunity__c, VisitOps__Opportunity__r.AccountId,'
														 +' VisitOps__VB_OppName__c, VisitOps__Opportunity__r.Name,'
														 +' VisitOps__VB_CompanyName__c, VisitOps__Opportunity__r.Account.Name,'
														 +' VisitOps__VB_OppCloseDate__c, VisitOps__Opportunity__r.closedate,'
														 +' VisitOps__VB_OppAmount__c, VisitOps__Opportunity__r.Unweighted_Rev_USD__c, Opp_Amount__c,'
														 +' VisitOps__VB_OppSalesStage__c, VisitOps__Opportunity__r.StageName,'
														 +' VisitOps__VB_OppMainCompetitors__c, VisitOps__Opportunity__r.Primary_Competitor__c,'
														 +' VO_Opportunity_Deal_ID_Number__c, VisitOps__Opportunity__r.Deal_ID__c, VisitOps__Opportunity__r.EMC_Opportunity_Number__c,'
														 +' Corresponding_Opportunity_ID__c, VO_Opportunity_Number_for_Reporting__c, VisitOpsP__Child_Parent_Org_Name__c,'
														 +' VO_Opportunity_Owner__c, VisitOps__Opportunity__r.Owner.Name,'
														 +' VO_Opportunity_Type__c, VisitOps__Opportunity__r.Type,'
														 +' VO_Account_Address__c, VisitOps__Opportunity__r.Account.Billing_Address_CN__c,'
														 +' VO_Account_Region_District__c, VisitOps__Opportunity__r.Sales_Channel_Region_Name__c,'
														 +' VO_Account_Classification__c, VisitOps__Opportunity__r.Account.Account_Classification__c,'
														 +' VO_Account_Country__c, VisitOps__Opportunity__r.Account.Account_Country__c,'
														 +' VO_Account_Segment_Name__c, VisitOps__Opportunity__r.Account.Segment_Name_lookup__c,'
														 +' VO_Account_Segment_Desc__c, VisitOps__Opportunity__r.Account.Segment_Desc__c,'
														 +' VO_Account_Segment_Business_Unit__c, VisitOps__Opportunity__r.Account.Segment_Business_Unit_Name__c,'
														 +' VO_Account_SFDC_ID__c,'
														 +' VO_Account_Affinity_ID__c, VisitOps__Opportunity__r.Affinity_ID__c,'
														 +' VO_Opportunity_Reason_Won_Lost__c, VisitOps__Opportunity__r.Reason_Won_Lost__c,'
														 +' VO_Probability__c, VisitOps__Opportunity__r.Probability,'
														 +' VO_Duplicate_Opportunity_ID__c, VisitOps__Opportunity__r.Duplicate_Opportunity_ID__c,'
														 +' VO_Account_Type__c, VisitOps__Opportunity__r.Account.RecordType.Name,'
														 +' VO_Account_DUNS_Number__c, VisitOps__Opportunity__r.Account.D_U_N_S__c,'
														 +' VO_Account_Region_Division__c, VisitOps__Opportunity__r.Account.Region_Desc__c,'
														 +' VO_Account_Theater__c, VisitOps__Opportunity__r.Account.Regional_Parent_Name_lookup__c,'
														 +' VO_Account_Industry__c, VisitOps__Opportunity__r.Account.Industry,'
														 +' VO_Parent_Account__c, VisitOps__Opportunity__r.Account.Parent.Name,'
														 +' VO_Partner_Type__c, VisitOps__Opportunity__r.Account.Partner_Type__c,'
														 +' VO_Partner_Relationship__c, VisitOps__Opportunity__r.Account.Partner_Relationship__c,'
														 +' VO_Global_Account__c, VisitOps__Opportunity__r.Account.Global_Account_Indicator__c,'
														 +' VO_Account_Executive_Name__c, VisitOps__Opportunity__r.Account.Account_Executive_PDM__r.Name,'
														 +' VO_Account_Executive_Email__c, VisitOps__Opportunity__r.Account.Account_Executive_PDM__r.Email,'
														 +' VO_Account_UCID__c, VisitOps__Opportunity__r.Account.EMC_ID__c,'
														 +' VisitOps__VisitArrivalDateTime__c'
														 +' From VisitOps__VisitBundle__c Where (LastModifiedDate >= :dtFrom OR VisitOps__Opportunity__r.SystemModStamp >= :dtFrom)'
														 +' Order By CreatedDate';
        return Database.getQueryLocator(strQuery);
    }
 
    global void execute(Database.BatchableContext bCtx, List<VisitOps__VisitBundle__c> listVBundle)
    {
        List<VisitOps__VisitBundle__c> listVBToUpdate = new List<VisitOps__VisitBundle__c>();
		Map<String, List<VisitOps__VisitBundle__c> > mapOppNumVistBundle = new Map<String, List<VisitOps__VisitBundle__c> >();
		for(VisitOps__VisitBundle__c vBundle : listVBundle)
		{
			if(vBundle.VisitOps__Opportunity__c == null)
			{
				if(!mapOppNumVistBundle.containsKey(vBundle.VO_Opportunity_Number_for_Reporting__c)){
					mapOppNumVistBundle.put(vBundle.VO_Opportunity_Number_for_Reporting__c, new List<VisitOps__VisitBundle__c>{vBundle});
				}
				else {
					mapOppNumVistBundle.get(vBundle.VO_Opportunity_Number_for_Reporting__c).add(vBundle);
				}
			}
			else
			{
                populateVisitBundle(vBundle, vBundle.VisitOps__Opportunity__r, listVBToUpdate);
			}
		}
		
		if(!mapOppNumVistBundle.isEmpty())
		{
			for(Opportunity oppr : getOpportunities(mapOppNumVistBundle.keySet()))
			{
				String strOppNumber = mapOppNumVistBundle.containsKey(oppr.Deal_ID__c) ? oppr.Deal_ID__c : oppr.EMC_Opportunity_Number__c;
				
				if(String.isBlank(strOppNumber))
				{
					continue;
				}
				
				for(VisitOps__VisitBundle__c vbl : mapOppNumVistBundle.get(strOppNumber))
				{
					populateVisitBundle(vbl, oppr, listVBToUpdate);
				}
				
			}
		}
        if(!listVBToUpdate.isEmpty())
        {
            update listVBToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bct)
    {
        
    }
    
    /**
     * Returns the List for opportunities related to the Deal Ids or Opportunity numbers 
     * 
     */
    private List<Opportunity> getOpportunities(Set<String> setOppNo)
	{
		return [SELECT Id, Name, Deal_ID__c, EMC_Opportunity_Number__c, AccountId, Account.Name, closedate, Unweighted_Rev_USD__c, Primary_Competitor__c, Account.RecordType.Name,
					Owner.Name, Type, Account.Billing_Address_CN__c, Sales_Channel_Region_Name__c, Account.Account_Classification__c, Account.Account_Country__c, Account.Segment_Name_lookup__c,
					Account.Segment_Desc__c, Account.Segment_Business_Unit_Name__c, Affinity_ID__c, Reason_Won_Lost__c, Probability, Duplicate_Opportunity_ID__c, RecordType.Name, Account.D_U_N_S__c,
					Account.Region_Desc__c, Account.Regional_Parent_Name_lookup__c, Account.Industry, Account.Parent.Name,Account.Partner_Type__c, Account.Partner_Relationship__c, Account.Global_Account_Indicator__c,
					Account.Account_Executive_PDM__r.Name, Account.Account_Executive_PDM__r.Email, Account.EMC_ID__c, StageName
					FROM Opportunity
					WHERE Deal_ID__c IN :setOppNo OR EMC_Opportunity_Number__c IN :setOppNo];
	}
	
	/**
     * Update the related Visit Bundle fields for any change in related Opportunity field values 
     * 
     */
	private VisitOps__VisitBundle__c populateVisitBundle(VisitOps__VisitBundle__c vBundle, Opportunity oppt, List<VisitOps__VisitBundle__c> listVBToUpdate)
	{
        Boolean bIsModified = false;
		if(vBundle.VisitOps__VB_OppName__c !=  oppt.Name) {bIsModified = true; vBundle.VisitOps__VB_OppName__c = oppt.Name;}
		
        if(vBundle.VisitOpsP__Opp_Name__c !=  oppt.Name) {bIsModified = true; vBundle.VisitOpsP__Opp_Name__c = oppt.Name;}
        
        if(vBundle.VisitOps__VB_CompanyName__c !=  oppt.Account.Name) {bIsModified = true; vBundle.VisitOps__VB_CompanyName__c = oppt.Account.Name;}
		
        if(vBundle.VisitOps__VB_OppCloseDate__c !=  oppt.closedate) {bIsModified = true; vBundle.VisitOps__VB_OppCloseDate__c = oppt.closedate;}
		
        if(vBundle.VisitOps__VB_OppAmount__c != oppt.Unweighted_Rev_USD__c) {bIsModified = true; vBundle.VisitOps__VB_OppAmount__c=oppt.Unweighted_Rev_USD__c;	vBundle.CurrencyIsoCode='USD';}
		
        if(vBundle.Opp_Amount__c != oppt.Unweighted_Rev_USD__c) {bIsModified = true; vBundle.Opp_Amount__c = oppt.Unweighted_Rev_USD__c;	vBundle.CurrencyIsoCode='USD'; }
        
		if(vBundle.VisitOps__VB_OppSalesStage__c !=  oppt.StageName) {bIsModified = true; vBundle.VisitOps__VB_OppSalesStage__c = oppt.StageName; }
		
        if(vBundle.VisitOps__VB_OppMainCompetitors__c !=  oppt.Primary_Competitor__c) {bIsModified = true; vBundle.VisitOps__VB_OppMainCompetitors__c = oppt.Primary_Competitor__c;}
		
        if(String.isNotBlank(vBundle.VisitOpsP__Child_Parent_Org_Name__c) && vBundle.VisitOpsP__Child_Parent_Org_Name__c != 'EMC'){bIsModified = true; vBundle.VisitOpsP__Child_Parent_Org_Name__c = 'EMC';}
		
        if(String.isNotBlank(oppt.Deal_ID__c) && vBundle.VO_Opportunity_Deal_ID_Number__c != oppt.Deal_ID__c)
		{
            bIsModified = true;
			vBundle.VO_Opportunity_Deal_ID_Number__c = oppt.Deal_ID__c;
		}
		else if(String.isBlank(oppt.Deal_ID__c) && vBundle.VO_Opportunity_Deal_ID_Number__c != oppt.EMC_Opportunity_Number__c)
		{
            bIsModified = true;
			vBundle.VO_Opportunity_Deal_ID_Number__c = oppt.EMC_Opportunity_Number__c;
		}
		
		if(String.isNotBlank(oppt.Deal_ID__c) && vBundle.Corresponding_Opportunity_ID__c != oppt.EMC_Opportunity_Number__c)
		{
            bIsModified = true;
			vBundle.Corresponding_Opportunity_ID__c = oppt.EMC_Opportunity_Number__c;
		}
		else if(String.isBlank(oppt.Deal_ID__c) && vBundle.Corresponding_Opportunity_ID__c != oppt.Deal_ID__c)
		{
            bIsModified = true;
			vBundle.Corresponding_Opportunity_ID__c = oppt.Deal_ID__c;
		}
		
		IF(	vBundle.VO_Opportunity_Owner__c !=  oppt.Owner.Name) {bIsModified = true; vBundle.VO_Opportunity_Owner__c = oppt.Owner.Name;	}
		
		IF(	vBundle.VO_Opportunity_Type__c !=  oppt.Type) {bIsModified = true; vBundle.VO_Opportunity_Type__c = oppt.Type;	}
		
		IF(	vBundle.VO_Account_Region_District__c !=  oppt.Sales_Channel_Region_Name__c) {bIsModified = true; vBundle.VO_Account_Region_District__c = oppt.Sales_Channel_Region_Name__c;	}
		
		IF(	vBundle.VO_Account_Classification__c !=  oppt.Account.Account_Classification__c) {bIsModified = true; vBundle.VO_Account_Classification__c = oppt.Account.Account_Classification__c;	}
		
		IF(	vBundle.VO_Account_Country__c !=  oppt.Account.Account_Country__c	) {bIsModified = true; vBundle.VO_Account_Country__c = oppt.Account.Account_Country__c;	}
		
		IF(	vBundle.VO_Account_Segment_Name__c !=  oppt.Account.Segment_Name_lookup__c) {bIsModified = true; vBundle.VO_Account_Segment_Name__c = oppt.Account.Segment_Name_lookup__c;	}
		
		IF(	vBundle.VO_Account_Segment_Desc__c !=  oppt.Account.Segment_Desc__c) {bIsModified = true; vBundle.VO_Account_Segment_Desc__c = oppt.Account.Segment_Desc__c;	}
		
		IF(	vBundle.VO_Account_Segment_Business_Unit__c !=  oppt.Account.Segment_Business_Unit_Name__c) {bIsModified = true; vBundle.VO_Account_Segment_Business_Unit__c = oppt.Account.Segment_Business_Unit_Name__c;	}
		
		IF(	vBundle.VO_Account_SFDC_ID__c !=  oppt.AccountId	) {bIsModified = true; vBundle.VO_Account_SFDC_ID__c = oppt.AccountId;	}
		
		IF(	vBundle.VO_Account_Affinity_ID__c !=  oppt.Affinity_ID__c	) {bIsModified = true; vBundle.VO_Account_Affinity_ID__c = oppt.Affinity_ID__c;	}
		
		IF(	vBundle.VO_Opportunity_Reason_Won_Lost__c !=  oppt.Reason_Won_Lost__c	) {bIsModified = true; vBundle.VO_Opportunity_Reason_Won_Lost__c = oppt.Reason_Won_Lost__c;	}
		
		IF(	vBundle.VO_Probability__c !=  string.valueof(oppt.Probability)) {bIsModified = true; vBundle.VO_Probability__c = string.valueof(oppt.Probability);                 	}
		
		IF(	vBundle.VO_Duplicate_Opportunity_ID__c !=  oppt.Duplicate_Opportunity_ID__c) {bIsModified = true; vBundle.VO_Duplicate_Opportunity_ID__c = oppt.Duplicate_Opportunity_ID__c;	}
		
		IF(	vBundle.VO_Account_Type__c !=  oppt.Account.RecordType.Name) {bIsModified = true; vBundle.VO_Account_Type__c = oppt.Account.RecordType.Name;	}
		
		IF(	vBundle.VO_Account_DUNS_Number__c !=  oppt.Account.D_U_N_S__c	) {bIsModified = true; vBundle.VO_Account_DUNS_Number__c = oppt.Account.D_U_N_S__c;	}
		
		IF(	vBundle.VO_Account_Region_Division__c !=  oppt.Account.Region_Desc__c	) {bIsModified = true; vBundle.VO_Account_Region_Division__c = oppt.Account.Region_Desc__c;	}
		
		IF(	vBundle.VO_Account_Theater__c !=  oppt.Account.Regional_Parent_Name_lookup__c	) {bIsModified = true; vBundle.VO_Account_Theater__c = oppt.Account.Regional_Parent_Name_lookup__c;	}
		
		IF(	vBundle.VO_Account_Industry__c !=  oppt.Account.Industry	) {bIsModified = true; vBundle.VO_Account_Industry__c = oppt.Account.Industry;	}
		
		IF(	vBundle.VO_Parent_Account__c !=  oppt.Account.Parent.Name	) {bIsModified = true; vBundle.VO_Parent_Account__c = oppt.Account.Parent.Name;	}
		
		IF(	vBundle.VO_Partner_Type__c !=  oppt.Account.Partner_Type__c) {bIsModified = true; vBundle.VO_Partner_Type__c = oppt.Account.Partner_Type__c;	}
		
		IF(	vBundle.VO_Partner_Relationship__c !=  oppt.Account.Partner_Relationship__c) {bIsModified = true; vBundle.VO_Partner_Relationship__c = oppt.Account.Partner_Relationship__c;	}
		
		IF(	vBundle.VO_Global_Account__c !=  oppt.Account.Global_Account_Indicator__c) {bIsModified = true; vBundle.VO_Global_Account__c = oppt.Account.Global_Account_Indicator__c;	}
		
		IF(	vBundle.VO_Account_Executive_Name__c !=  oppt.Account.Account_Executive_PDM__r.Name) {bIsModified = true; vBundle.VO_Account_Executive_Name__c = oppt.Account.Account_Executive_PDM__r.Name;	}
		
		IF(	vBundle.VO_Account_Executive_Email__c !=  oppt.Account.Account_Executive_PDM__r.Email) {bIsModified = true; vBundle.VO_Account_Executive_Email__c = oppt.Account.Account_Executive_PDM__r.Email;	}
		
		IF(	vBundle.VO_Account_UCID__c !=  oppt.Account.EMC_ID__c	) {bIsModified = true; vBundle.VO_Account_UCID__c = oppt.Account.EMC_ID__c;	}
		
		IF(vBundle.VO_Account_Address__c != (String.isNotBlank(oppt.Account.Billing_Address_CN__c) ? oppt.Account.Billing_Address_CN__c.replace('<br>', ' ') : oppt.Account.Billing_Address_CN__c))
		{
            bIsModified = true;
			vBundle.VO_Account_Address__c =  String.isNotBlank(oppt.Account.Billing_Address_CN__c) ? oppt.Account.Billing_Address_CN__c.replace('<br>', ' ') : oppt.Account.Billing_Address_CN__c;
		}
		
        if(bIsModified == true)
        {
            listVBToUpdate.add(vBundle);
        }
		return vBundle;
	}
}
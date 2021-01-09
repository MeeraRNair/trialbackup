/**
 * Opportunity change event Utility class,
 * Performs all the operations on opportunity after change event insert operation
 * can be used for any opp related dml operation but should be only after events
 * Test class - OpportunityChangeUtilityTest
 * @author: Rajiv Ranjan
 * @since: 09-12-2019
 * */
public class OpportunityChangeUtility {
	
	static Map<Id, Opportunity> mapIdOpps =  new Map<Id, Opportunity>();
	static Map<String, Opportunity> mapOppNumberOpps =  new Map<String, Opportunity>();
	
	static Map<String, Id> mapUnLinkedOppNumVBs = new Map<String, Id>();
	static Map<Id, Id> mapUnLinkedOppIdVBs = new Map<Id, Id>();
	
	static Set<Id> setVBId = new Set<Id>();
	static List<VisitOps__VisitBundle__c> listVBRecordsToUpdate = new List<VisitOps__VisitBundle__c>();
	
    /**
     * Sync visit bundle records related to opportunities in context
     * @param: listOppEvnts - List of OpportunityChangeEvent
     * @author: Rajiv Ranjan
     * @since: 09-12-2019
     * */
	public static void populateReledVBRecords(List<OpportunityChangeEvent> listOppEvnts)
	{
        //Iterate over Opportunity change event list to get the Ids and fields getting modified
        for(OpportunityChangeEvent oppEvnt : listOppEvnts)
        {
            //List of opportunity ids in context with same set of changes
            List<Id> listOppRecordIds = oppEvnt.ChangeEventHeader.getRecordIds();
			
            //change event header, contains the changed field and other info
            EventBus.ChangeEventHeader header = oppEvnt.ChangeEventHeader;
            
            //On update contais changed field else empty
            List<String> changedFields = header.changedFields;
            
            //Get the change event related parameters as key value
            Map<String,Object> mapEventChanges = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(oppEvnt));
            
            //Null oppty object, just being used to reuse the field values
            Opportunity oppt;
            
            //populate the map with key as Opportunity number,
            //will be used later to sync unlinked VB records if opportunity gets created after Visits
            if(mapEventChanges.containsKey('EMC_Opportunity_Number__c'))
            {
                mapOppNumberOpps.put(mapEventChanges.get('EMC_Opportunity_Number__c').toString(), oppt);
            }
            for(Id oppId : listOppRecordIds)
            {
                mapIdOpps.put(oppId, oppt);
            }
        }
        //Fetch all the opportunities and related account and owner details related to opp ids in context
		fetchOpps();
        
        //Fetch all the Visit Bundles related linked and unlinked opportunities
		fetchAllVisitBundles();
        
        //Populate the Visit Bundle records with the related opps field changes
		populateVBRecords(listOppEvnts);
        
        //update the related VB records
		System.debug('>>> listVBRecordsToUpdate ' + listVBRecordsToUpdate);
        if(!listVBRecordsToUpdate.isEmpty())
        {
			update listVBRecordsToUpdate;   
        }
	}
	
    /**
     * Returns all the opportunity related details
     * @param: none
     * @author: Rajiv Ranjan
     * @since: 09-12-2019
     * @return: Map<Id, Opportunity>
     * */
	public static Map<Id, Opportunity> fetchOpps()
	{
		mapIdOpps = new Map<Id, Opportunity>([Select Id, AccountId, Deal_ID__c, EMC_Opportunity_Number__c, Account.Account_ID__c, Account.Name, Account.Billing_Address_CN__c, Account.Account_Classification__c, Account.Account_Country__c,
					Account.Segment_Name_lookup__c, Account.Segment_Name__c, Account.Segment_Desc__c, Account.Segment_Business_Unit_Name__c, Account.RecordType.Name, Account.D_U_N_S__c, Account.Region_Desc__c,
					Account.Regional_Parent_Name_lookup__c, Account.Industry, Account.Parent.Name, Account.Partner_Type__c, Account.Partner_Relationship__c,
					Account.Global_Account_Indicator__c, Account.Account_Executive_PDM__r.Name, Account.Account_Executive_PDM__r.Email, Account.EMC_ID__c,
					CreatedBy.Profile.Name, OwnerId, Owner.Name, Owner.FirstName, Owner.LastName, Owner.Email, 
					Owner.Contact.Email, Owner.Contact.AccountId, Owner.Contact.Phone, Owner.Contact.Account.Partner_Relationship__c, Owner.Profile.Name
					From Opportunity where Id IN :mapIdOpps.keySet()]);
					
		return mapIdOpps;
	}
	
    /**
     * Returns all the VB records which are linked or unlinked to the opportunities in context
     * @param: none
     * @author: Rajiv Ranjan
     * @since: 09-12-2019
     * @return: void
     * */
	public static void fetchAllVisitBundles()
	{
		for(VisitOps__VisitBundle__c vbVar : [Select Id, VisitOps__Opportunity__c, VO_Opportunity_Number_for_Reporting__c From VisitOps__VisitBundle__c Where VO_Opportunity_Number_for_Reporting__c IN :mapOppNumberOpps.keySet() OR VisitOps__Opportunity__c IN :mapIdOpps.keySet()])
		{
			if(String.isNotBlank(vbVar.VisitOps__Opportunity__c))
			{
				mapUnLinkedOppIdVBs.put(vbVar.VisitOps__Opportunity__c, vbVar.Id);
			}
			else
			{
				mapUnLinkedOppNumVBs.put(vbVar.VO_Opportunity_Number_for_Reporting__c, vbVar.Id);
			}
		}
        System.debug('mapUnLinkedOppIdVBs >>> ' + mapOppNumberOpps);
        System.debug('mapUnLinkedOppNumVBs >>> ' + mapIdOpps);
        System.debug('mapUnLinkedOppIdVBs >>> ' + mapUnLinkedOppIdVBs);
        System.debug('mapUnLinkedOppNumVBs >>> ' + mapUnLinkedOppNumVBs);
	}
	
    /**
     * Sync the VB records wrt the related opps on either change event type is create or edit
     * @param: listOppEvnts, list of OpportunityChangeEvent
     * @author: Rajiv Ranjan
     * @since: 09-12-2019
     * @return: void
     * */
	public static void populateVBRecords(List<OpportunityChangeEvent> listOppEvnts)
	{
        for(OpportunityChangeEvent oppEvnt : listOppEvnts)
        {
            List<Id> listOppRecordIds = oppEvnt.ChangeEventHeader.getRecordIds();
            
            EventBus.ChangeEventHeader header = oppEvnt.ChangeEventHeader;
            List<String> changedFields = header.changedFields; //On update contais changed field else empty
            
            Map<String,Object> mapEventChanges = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(oppEvnt));
            
            Opportunity oppt;
            if(oppEvnt.ChangeEventHeader.getChangeType() == 'CREATE')
            {
                populateFields(changedFields, true, oppEvnt);
            }
            if(oppEvnt.ChangeEventHeader.getChangeType() == 'UPDATE')
            {
                populateFields(changedFields, false, oppEvnt);
            }
        }
	}
	
    /**
     * Populate a single VB object with field values changes for opps in context, either linked or unlinked
     * 
     * @param: changedFields -  List - list of modified fields if dml is update
     * 		   isCreate - 		Boolean - specifies if dml is create operaion
     * 		   oppEvnt - 		List - List of OpportunityChangeEvent
     * @author: Rajiv Ranjan
     * @since: 09-12-2019
     * @return: void
     * */
	public static void populateFields(List<String> changedFields, Boolean isCreate, OpportunityChangeEvent oppEvnt)
	{
		VisitOps__VisitBundle__c vblToUpdate = new VisitOps__VisitBundle__c();
		Boolean isModified = false;
		List<Id> listOppRecordIds = oppEvnt.ChangeEventHeader.getRecordIds();
		OWD__c owd = OWD__c.getOrgDefaults();
        
		for(Id oppId : listOppRecordIds)
		{
			Opportunity oppt = mapIdOpps.get(oppId);
			vblToUpdate.Id = mapUnLinkedOppIdVBs.containsKey(oppId) ? mapUnLinkedOppIdVBs.get(oppId)
							: mapUnLinkedOppNumVBs.containsKey(oppt.EMC_Opportunity_Number__c) ? mapUnLinkedOppNumVBs.get(oppt.EMC_Opportunity_Number__c)
							: mapUnLinkedOppNumVBs.get(oppt.Deal_ID__c);
			System.debug('>>>oppEvnt ' + oppEvnt);
			
			if(String.isBlank(vblToUpdate.Id))
            {
                continue;
            }
			if((changedFields.contains('StageName') && ((oppEvnt.StageName == owd.Oppty_Stage100__c  || oppEvnt.StageName == owd.Oppty_Stage0__c)) || isCreate))
			{
				isModified = true;
				vblToUpdate.VisitOps__VB_OppSalesStage__c = oppEvnt.StageName;
				vblToUpdate.VisitOps__Send_Notification_to_Visit_Team_Owner__c = true;
				vblToUpdate.VisitOps__Visit_Team_Owner_Email__c = oppt.Owner.Email;
			}
			
            vblToUpdate.VisitOps__Opportunity__c = oppId;
			
			if(changedFields.contains('Name') || isCreate)
			{
				isModified = true;
				vblToUpdate.VisitOps__VB_OppName__c = oppEvnt.Name;
				vblToUpdate.VisitOpsP__Opp_Name__c = oppEvnt.Name;
			}
			if(changedFields.contains('Amount') || isCreate)
			{
				isModified = true;
				vblToUpdate.Opp_Amount__c=oppEvnt.Amount;
				vblToUpdate.VisitOps__VB_OppAmount__c =oppEvnt.Amount;
				vblToUpdate.CurrencyIsoCode='USD';
			}
			if(changedFields.contains('CloseDate') || isCreate)
			{
				isModified = true;
				vblToUpdate.VisitOps__VB_OppCloseDate__c = oppEvnt.CloseDate;
			}
			if(changedFields.contains('Primary_Competitor__c') || isCreate)
			{
				isModified = true;
				vblToUpdate.VisitOps__VB_OppMainCompetitors__c = oppEvnt.Primary_Competitor__c;
			}
			if(changedFields.contains('OwnerId') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Opportunity_Owner__c = oppt.Owner.Name;
			}
			if(changedFields.contains('Type') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Opportunity_Type__c = oppEvnt.Type;
			}
			if(changedFields.contains('Sales_Channel_Region_Name__c') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Account_Region_District__c = oppEvnt.Sales_Channel_Region_Name__c;
			}
			if(changedFields.contains('AccountId') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Account_SFDC_ID__c = oppEvnt.AccountId;
                vblToUpdate.VisitOps__VB_CompanyName__c = oppt.Account.Name;
                if(oppt.Account.Billing_Address_CN__c!=null){
                    vblToUpdate.VO_Account_Address__c = oppt.Account.Billing_Address_CN__c.replace('<br>',' ');
                }
                vblToUpdate.VO_Account_Classification__c = oppt.Account.Account_Classification__c;
                vblToUpdate.VO_Account_Country__c = oppt.Account.Account_Country__c;
                vblToUpdate.VO_Account_Segment_Name__c = oppt.Account.Segment_Name__c;
                vblToUpdate.VO_Account_Segment_Desc__c = oppt.Account.Segment_Desc__c;
                vblToUpdate.VO_Account_Segment_Business_Unit__c = oppt.Account.Segment_Business_Unit_Name__c;
			}
			if(changedFields.contains('Affinity_ID__c') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Account_Affinity_ID__c = oppEvnt.Affinity_ID__c;
			}
			if(changedFields.contains('Reason_Won_Lost__c') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Opportunity_Reason_Won_Lost__c = oppEvnt.Reason_Won_Lost__c;
			}
			if(changedFields.contains('Probability') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Probability__c = string.valueof(oppEvnt.Probability);
			}
			if(changedFields.contains('Deal_ID__c') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Opportunity_Deal_ID_Number__c = oppEvnt.Deal_ID__c;
			}
			if(changedFields.contains('Duplicate_Opportunity_ID__c') || isCreate)
			{
				isModified = true;
				vblToUpdate.VO_Duplicate_Opportunity_ID__c = oppEvnt.Duplicate_Opportunity_ID__c;
			}
			if(changedFields.contains('EMC_Opportunity_Number__c') || isCreate)
			{
				isModified = true;
				if(String.isNotBlank(oppt.Deal_ID__c))
				{
					vblToUpdate.Corresponding_Opportunity_ID__c = oppEvnt.EMC_Opportunity_Number__c;
				}
				else
				{
					vblToUpdate.Corresponding_Opportunity_ID__c = oppEvnt.EMC_Opportunity_Number__c;
				}
			}
			
			if(isModified)
			{
				listVBRecordsToUpdate.add(vblToUpdate);
			}
			
		}
	}
}
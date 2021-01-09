/***********************************************************
* Name          : VFCntrl_newOppQuickCreate
* Description   : Controller for Opportunity Quick Crate
* ---------------------------------------------------------
* Revision  Name               Date             Description
* 1.0       Meera        04.April.2018    Story 4848231:BUCPWFY19LX-00201: Record Quick Create VF Button (Thor)
*        
* 
************************************************************/
public with sharing class VFCntrl_newOppQuickCreate {
    //Declare variables
    public Opportunity opp{get;set;}    
    public String oppid{get
        {
            System.debug('##oppId'+oppid);
            if(oppid==null || oppid=='')
                oppid=opp.id;
            return oppid;
        }
set;}
    public Boolean isSuccess{get;set;}
    public VFCntrl_newOppQuickCreate(ApexPages.StandardSetController standardController) {
        opp = new Opportunity();
        //Default RT to standard opportunity
        Id idstdoppRT = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');
        opp.recordtypeId = idstdoppRT;        
    }
    
    //Save Opportunity
    public void Save(){
		opp.Quick_Create__c = true;
		isSuccess = true;
        /* Pricebook2 pb = [SELECT CurrencyIsoCode,Id,Name FROM Pricebook2 where name='EMEA Standard Catalog'];
        opp.pricebook2id = pb.id;*/
        Database.SaveResult sr = Database.insert(opp, false);

		// Iterate through each returned result
		
			if (sr.isSuccess()) {
				// Operation was successful, so get the ID of the record that was processed
				System.debug('Successfully inserted opp. Opp ID: ' + sr.getId());
				System.debug(opp.id);
				oppid = opp.id;
			}
			else {
				// Operation failed, so get all errors  
				String errmsg = '';
				for(Database.Error err : sr.getErrors()) {
					System.debug('The following error has occurred.');                    
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('Account fields that affected this error: ' + err.getFields());
					errmsg+=err.getMessage();
                    isSuccess = false;
				}
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errmsg));
			}
    }
    
}
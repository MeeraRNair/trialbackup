/***********************************************************
* Name          : BatchUpdAccountOwnerForPartnerExecute
* Description   : Update Parnter Account Owner
* ---------------------------------------------------------
* Revision      Release	Name    Date            Description
* 1.0			12.1	MenMee	22.12.2010		CR5716 Processing Account owner change using batch Apex
* 1.1			12.1	MenMee	28.01.2011		Parameterize batch size in custom label
* 1.2					MenMee	22.03.2011		CR6022 Exception Handling
***********************************************************/

global class BatchUpdAccountOwnerForPartnerExecute implements Schedulable {
	 
	global static void execute(SchedulableContext SC) {		
		Id batchinstanceid;
		integer batchSize;
		
		System.debug('### Execute');
		if (System.Label.BatchUpdPartnerAccountOwner_Batch_Size != '-') {
			//Rev 1.2
			try {		
				batchSize = Integer.valueOf(System.Label.BatchUpdPartnerAccountOwner_Batch_Size);
			}
			catch (TypeException te) {
				batchSize = 10;
			}
		
			batchinstanceid = database.executeBatch(new BatchUpdAccountOwnerForPartner(), batchSize);
		}
		else {
			batchinstanceid = database.executeBatch(new BatchUpdAccountOwnerForPartner());
		}
	} 
	
	global static void executeBatch(BatchUpdAccountOwnerForPartner batch) {		
		Id batchinstanceid;
		integer batchSize;
		
		System.debug('### ExecuteBatch');	
		if (System.Label.BatchUpdPartnerAccountOwner_Batch_Size != '-') {
			//Rev 1.2
			try {		
				batchSize = Integer.valueOf(System.Label.BatchUpdPartnerAccountOwner_Batch_Size);
			}
			catch (TypeException te) {
				batchSize = 10;
			}
			batchinstanceid = database.executeBatch(batch, batchSize);
		}
		else {
			batchinstanceid = database.executeBatch(batch);
		}
	}
	
}
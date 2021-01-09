/*
 * Author   : Krishna
 * Purpose  : Utility Class Which handles file attachment on Opportunity and Support Request
 * 
 * Revision CR Number   Release No    Date            Modified By     Description
 * -------- ---------   ----------    -----------     ------------    -----------
 * 1.0      15108       FY18-DCS-0203 09-Nov-2017     Krishnakumar    PSA006 - Files to myDeal - create logic
 * 
 */

public class MyDealFileIntegration{
	private static String CSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);

	public static void processContentVersions(List<ContentVersion> listContentVersion,Map<Id,ContentVersion> mapOldContentVersion){
		Set<ID> setSupReqId = new Set<ID>();
    	Set<ID> setOpptyId = new Set<ID>();
    	Set<Id> setContDocId = new Set<Id>();
    	if(SuppReqMyDealIntegration.REQUIRE_CALLOUT){
			for(ContentVersion objContVersion:listContentVersion){			
				ContentVersion oldVers = (ContentVersion)mapOldContentVersion.get(objContVersion.id);
			    system.debug('**Old file - '+oldVers.Title+' ** New File--'+objContVersion.Title);
			    if(oldVers.Title != objContVersion.Title){
			        setContDocId.add(objContVersion.ContentDocumentId);
			    }				
			}	
			system.debug('Content Document Id---'+setContDocId);	
			List<ContentDocumentLink> listContentDocLink = new List<ContentDocumentLink>();//[Select id,contentdocumentid,LinkedEntityId From ContentDocumentLink where ContentDocumentId in :setContDocId];
			for(ContentDocument objContDoc:[Select (Select LinkedEntityId From ContentDocumentLinks) From ContentDocument where id in:setContDocId]){
				listContentDocLink.addAll(objContDoc.ContentDocumentLinks);
			}

			SyncFileDetailsToMydeal(listContentDocLink);
		}
	}

	public static void processContentDocument(List<ContentDocument> listContentDoc){
		Set<ID> setSupReqId = new Set<ID>();
    	Set<ID> setOpptyId = new Set<ID>();
    	Set<Id> setContDocId = new Set<Id>();
    	if(SuppReqMyDealIntegration.REQUIRE_CALLOUT){
	    	for(ContentDocument objContDoc:listContentDoc){			
				setContDocId.add(objContDoc.Id);			
			}		
			List<ContentDocumentLink> listContentDocLink = [Select LinkedEntityId From ContentDocumentLink where ContentDocumentId in :setContDocId];
			SyncFileDetailsToMydeal(listContentDocLink);
		}

	}

	public static void processContentDocumentLinksInsert(List<ContentDocumentLink> listContentDocLink){
		SyncFileDetailsToMydeal(listContentDocLink);
	}

	public static void processContentDocumentLinksDelete(List<ContentDocumentLink> listContentDocLink){
		SyncFileDetailsToMydeal(listContentDocLink);
	}

    private static void SyncFileDetailsToMydeal(List<ContentDocumentLink> listContentDocLink){
    	Set<ID> setSupReqId = new Set<ID>();
    	Set<ID> setOpptyId = new Set<ID>();
	    if(SuppReqMyDealIntegration.REQUIRE_CALLOUT){
	    	for(ContentDocumentLink objDocLink:listContentDocLink){
	    		Schema.SObjectType sobjectType = objDocLink.LinkedEntityId.getSObjectType();
		        String sobjectName = sobjectType.getDescribe().getName();    
		        system.debug(''+objDocLink.LinkedEntityId+'---sobjectName--'+sobjectName);
		        if('Support_Request__c'.equals(sobjectName)){
		           setSupReqId.add(objDocLink.LinkedEntityId);
		        }else if('Opportunity'.equals(sobjectName)){
		           setOpptyId.add(objDocLink.LinkedEntityId);
		        } 
	    	}	    	
	       	if(!setSupReqId.isEmpty() || !setOpptyId.isEmpty()){        	
        		Map<Id, Support_Request__c> suppReqMap = new Map<Id, Support_Request__c>([Select id from Support_Request__c where RecordTypeId = :CSS_RECORDTYPEID AND Solution_Architect__c = 'Yes' and (Opportunity__C IN:setOpptyId OR id in:setSupReqId)]);
    			System.debug('**%%%%**'+suppReqMap);
		   	    if(suppReqMap !=null && !suppReqMap.isEmpty()){
		    	    SuppReqMyDealIntegration.integrateMyDeal(suppReqMap.keySet());
		        	SuppReqMyDealIntegration.REQUIRE_CALLOUT = false;
		    	}
		    }
	    }
    }
}
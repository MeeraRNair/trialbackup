public class ContactTriggerHelper {
    
    public static void updateAuditTracks(List<Contact> listNewContacts,Map<Id,Contact> mapOldContacts){
        System.debug('updateAuditTracks');
        List<String> listoldContactEligibleTracks = new List<String>();
        List<String> listnewContactEligibleTracks = new List<String>();
        List<Contact> listConUpdate = new List<Contact>();
        Map<Id,Contact> mapNewContacts = new Map<Id,Contact>(listNewContacts);
        Set<String> setAuditTracks = new Set<String>();
        if(mapNewContacts!= null && mapNewContacts.size() > 0){
            for(Contact con: mapNewContacts.values()){
                System.debug('New Tracks'+mapNewContacts.get(con.Id).EligibleTracks__c+'Old Tracks'+mapOldContacts.get(con.Id).EligibleTracks__c);
                if(mapNewContacts.get(con.Id).EligibleTracks__c != mapOldContacts.get(con.Id).EligibleTracks__c){
                    System.debug('mapNewContacts.get(con.Id).EligibleTracks__c' + mapNewContacts.get(con.Id).EligibleTracks__c);
                    if(mapOldContacts!= null && String.isNotBlank(mapOldContacts.get(con.Id).EligibleTracks__c)){
           				 listoldContactEligibleTracks = mapOldContacts.get(con.Id).EligibleTracks__c.trim().split(';');
                     }
                    System.debug('New Contact -> EligibleTracks__c');
                    if(String.isNotBlank(mapNewContacts.get(con.Id).EligibleTracks__c)){
                       listnewContactEligibleTracks = mapNewContacts.get(con.Id).EligibleTracks__c.trim().split(';');
                    }
                    System.debug('listoldContactEligibleTracks::'+listoldContactEligibleTracks);
                    System.debug('listnewContactEligibleTracks::'+listnewContactEligibleTracks);
                       
                    if(mapOldContacts!= null && listoldContactEligibleTracks.size() > 0 && listnewContactEligibleTracks.size() >0){
                        System.debug('During Updation');
                        if(listoldContactEligibleTracks.equals(listnewContactEligibleTracks)){
                            System.debug('No Change to Eligible Tracks');
                        }
                        else{
                            System.debug('Eligible Tracks Changes:');
                            if(String.isNotBlank(con.Audit_Track__c)){
                                List<String> listAuditTracks = new List<String>();
                        		listAuditTracks = con.Audit_Track__c.trim().split(';');
                           		setAuditTracks.addAll(listAuditTracks);
                                for(String strEligibleTracks : listoldContactEligibleTracks){
									if(listnewContactEligibleTracks.contains(strEligibleTracks)){
										System.debug('Operation: Remove : Do nothing');
									}
									else{
										if(con.Audit_Track__c.contains(strEligibleTracks)){
											setAuditTracks.remove(strEligibleTracks);
											System.debug('setAuditTracks>>'+setAuditTracks);
										   
										}
									}
                                }
								String strpartnertracks='';
								if(setAuditTracks.size() > 0){
									for(String str : setAuditTracks){
										strpartnertracks += (strpartnertracks ==''?'':';')+ str;
									}
									mapNewContacts.get(con.Id).Audit_Track__c = strpartnertracks;
									//listConUpdate.add(con);
								}
								else{
									mapNewContacts.get(con.Id).Audit_Track__c = strpartnertracks;
									//listConUpdate.add(con);
								}
								
           
                                
                            }
                            
                           
                        }
                    }

                	
                
                }
                
            }

		}
    }
  

}
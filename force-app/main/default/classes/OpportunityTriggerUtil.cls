public class OpportunityTriggerUtil {
    
    public static void populateOpportunityTeam(List<Opportunity> oppList){
        Set<id> accids = new Set<id>();
   	    Map<id,List<id>> accidtoOppIdsMap = new Map<id,List<id>>();        
		set<ID> teammemberids = new set<ID>();
        List<OpportunityTeamMember> otmToInsert = new List<OpportunityTeamMember>();
        //Get AccountIDS
        Savepoint savep = Database.setSavepoint();
		try{
			
			for(Opportunity opp : oppList){
				if(opp.AccountId != null){
				   //accids.add(opp.accid);
				   if(accidtoOppIdsMap.get(opp.AccountId)!=null){
						accidtoOppIdsMap.get(opp.AccountId).add(opp.id);
					}
					else{
						accidtoOppIdsMap.put(opp.AccountId,new List<id>{opp.id});
					} 
				}
				
			}
			
			System.debug(accidtoOppIdsMap);
			Map<id,id> accidTouserIDmap = new Map<id,id>();
			//Query and retrieve Account teammember
			if(accidtoOppIdsMap.size()>0){
				for(AccountTeamMember atm : [SELECT AccountId,TeamMemberRole,UserId FROM AccountTeamMember
											  WHERE AccountId IN :accidtoOppIdsMap.keySet() AND TeamMemberRole='Sales Manager']){
					accidTouserIDmap.put(atm.AccountId,atm.UserId);                              
				}
				
				//Create Opp Team Member
				
				if(accidTouserIDmap.size()>0){
					Integer reccnt = 0;
					for(ID accid : accidTouserIDmap.keySet()) {
						for(ID oppID :accidtoOppIdsMap.get(accid) ){
                            OpportunityTeamMember otm;
							if(reccnt==1){
								otm = new OpportunityTeamMember( UserId =accidTouserIDmap.get(accid),TeamMemberRole = 'Sales Manager');//,OpportunityId=oppID
							}
							else{
								otm = new OpportunityTeamMember( UserId =accidTouserIDmap.get(accid),OpportunityId=oppID, TeamMemberRole = 'Sales Manager');//
							}
							
							otmToInsert.add(otm);
							reccnt++;
						}
					} 
				 }
				if(otmToInsert.size()>0 &&  Limits.getDMLStatements() < Limits.getLimitDMLStatements()){					
						  
						if(otmToInsert.size()>1){
							//otmToInsert[0].UserId = null;
						    Database.SaveResult[] resultlist = Database.Insert(otmToInsert,false);
							ExceptionUtil.logException('Opportunity','Opp Team Addition',resultlist);
                            ExceptionUtil.publishException('Opportunity','Opp Team Addition',resultlist);
						}
						else{
							insert otmToInsert;
						}
								  
				}
                else{
                    ExceptionUtil.logException('Opportunity','Opp Team Addition',null,'Reached DML governor Limit');	
                    //ExceptionUtil.publishException('Opportunity','Opp Team Addition',oppList[0].id,exdetails);
                }
			}
		}catch(Exception e){
					String exdetails =  e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                                                  +' ; '+e.getTypeName() ;
					//ExceptionUtil.logException('Opportunity','Opp Team Addition',oppList[0].id,exdetails);	
                    ExceptionUtil.publishException('Opportunity','Opp Team Addition',oppList[0].id,exdetails);
                    //throw new ExceptionUtil.MyException('Exception happend during Opp Team Addition'+e.getMessage());
                }
        //Create split record
        List<OpportunitySplit> oppsplit = new List<OpportunitySplit>();
        try{
			
            
			//query and get teammember details
			
				List<OpportunityTeamMember> otmsuccessList = [SELECT id,UserID,OpportunityID from OpportunityTeamMember WHERE OpportunityID IN :oppList and TeamMemberRole ='Sales Manager'];
				for(OpportunityTeamMember otmnew : otmsuccessList){
					OpportunitySplit sp = new OpportunitySplit();
					//sp.OpportunityId = otmnew.OpportunityID;
					sp.SplitPercentage = 30;          
					sp.SplitOwnerID = otmnew.UserId;
					oppsplit.add(sp);
				}
			
			
            if(oppsplit.size()>0){
                insert oppsplit;
            }
        }catch(Exception e){            
            String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                 +' ; '+e.getTypeName() ;
            //ExceptionUtil.logException('Opportunity','Opp Split Addition',oppList[0].id,exdetails);
            ExceptionUtil.publishException('OpportunitySplit','Opp Split Addition',oppList[0].id,exdetails);
            Database.rollback( savep );
            
        }
        
        
    }

}
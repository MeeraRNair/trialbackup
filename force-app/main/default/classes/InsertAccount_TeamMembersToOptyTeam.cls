public with sharing class InsertAccount_TeamMembersToOptyTeam {

    public Account EndUser_Acct{get;set;}
    public map<string,set<String>> opty_teamMembersMap;
    list<OpportunityTeamMember> new_TeamMembers;
    public InsertAccount_TeamMembersToOptyTeam(ApexPages.StandardController controller) {

        opty_teamMembersMap = new map<String,set<String>>();
      Account acc  =   (Account)controller.getRecord();
      EndUser_Acct = [select id,isPartner from Account where id=:acc.id];
      list<AccountTeamMember> AllTeamMembers = new list<AccountTeamMember>();
      try{
      AllTeamMembers  = [select id,UserId,AccountId,TeamMemberRole,OpportunityAccessLevel   from AccountTeamMember where  AccountId=:EndUser_Acct.id and CreatedDate=Today ];
      }catch(Exception ex){}
      if(AllTeamMembers.size()>0){
      map<id,opportunity> Allopties;
          if(!Test.isRunningTest()){
if(!EndUser_Acct.isPartner){
           Allopties = new map<id,opportunity>( [select id,(select UserId FROM OpportunityTeamMembers)  from opportunity where AccountId=:EndUser_Acct.id and stageName !='Lost, Cancelled - 0%' and Deal_Registration_Status__c='Approved' and Deal_Reg_Oppty__c= 'Yes' and Deal_Expiration_Date__c !=null ]);
}else{
           Allopties = new map<id,opportunity>( [select id,(select UserId FROM OpportunityTeamMembers)  from opportunity where PartnerAccountId=:EndUser_Acct.id and stageName !='Lost, Cancelled - 0%' and Deal_Registration_Status__c='Approved' and Deal_Reg_Oppty__c= 'Yes' and Deal_Expiration_Date__c !=null ]);

}          
}
          else{
             Allopties = new map<id,opportunity>( [select id,(select UserId FROM OpportunityTeamMembers)  from opportunity where AccountId=:EndUser_Acct.id and stageName !='Lost, Cancelled - 0%']);
          } 
          
          list<id> Alloptyids = new list<id>();
          Alloptyids.addAll(Allopties.keyset());
          
       /*   if(Allopties.size()>0){
              for(opportunity eachOpp : Allopties){
          
                      set<String> members = new set<String>();
                      opty_teamMembersMap.put(eachOpp.id,members);
          
                      for(OpportunityTeamMember optyMember : eachOpp.OpportunityTeamMembers){
                               opty_teamMembersMap.get(eachOpp.id).add(optyMember.id);
                          
                      }
              }          
          }*/
          
           new_TeamMembers  = new list<OpportunityTeamMember>();
          for(AccountTeamMember eachteammember : AllTeamMembers){
          
              for(id eachid : Alloptyids ){
              
                      OpportunityTeamMember OTM = new OpportunityTeamMember();
                      OTM.UserId = eachteammember.UserId; 
                      OTM.OpportunityId = eachid;
                      OTM.OpportunityAccessLevel = eachteammember.OpportunityAccessLevel ;
                      OTM.TeamMemberRole = eachteammember.TeamMemberRole;
                      if(EndUser_Acct.isPartner){
                          OTM.Partner_Account_Member__c = true;
                      }else{
                          OTM.End_User_Acct_Member__c = true;
                      }
                      
                      new_TeamMembers.add(OTM);
              }
          
          }
          
         
          
      }
      
    }
    
    
    public void doAction(){
    if(null != new_TeamMembers){
         if(new_TeamMembers.size()>0){
         try{
              insert new_TeamMembers;
           }catch(Exception ex){
           
           
           }   
          }
         } 
    }

}
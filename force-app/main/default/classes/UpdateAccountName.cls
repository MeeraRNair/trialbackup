public class UpdateAccountName{

 //   @InvocableMethod(label='Update Account Name' )
     public static Void update_accountNames(map<id,Account>  NewAccs,map<id,Account>  OldAccs) {
     
     set<String> NameChangedAccountIds =  new set<String>();
     for(String eachid:OldAccs.keyset()){
         if(OldAccs.get(eachid).Name !=NewAccs.get(eachid).Name){
             NameChangedAccountIds.add(eachid);
         }
     
     }
      
         TriggerExecutionController.setSkipAllTriggers(true);
      
          
          
          list<user> UpdatedUsers = new list<User>(); 
          if(NameChangedAccountIds !=null && !NameChangedAccountIds.IsEmpty()){   
      for(user u :[select id,CompanyName,Contact.AccountId from user where Contact.AccountId in :NameChangedAccountIds AND ContactId != Null]){
      
                  u.companyName = NewAccs.get(u.contact.AccountId).Name;
                  UpdatedUsers .add(u);
      }    
      }
      if(!UpdatedUsers .isEmpty()){
      
          update UpdatedUsers ;
      }
          
                 TriggerExecutionController.setSkipAllTriggers(false);
      
          
      }


}
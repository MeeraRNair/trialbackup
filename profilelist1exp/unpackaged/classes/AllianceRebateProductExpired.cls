public class AllianceRebateProductExpired {
   
    @InvocableMethod(label='Get Alliance Names' description='Returns the list of Product names corresponding to the specified form IDs.')
  public static void changeAllianceStatus(List<ID> ids) {
      Rebate_Request_Product__c product = [select id,Alliance_Rebate_Request__c from Rebate_Request_Product__c where id =: ids[0]];
    List<Rebate_Request_Product__c> listOfProduct = [select id from Rebate_Request_Product__c where Alliance_Rebate_Request__c =: product.Alliance_Rebate_Request__c AND Status__c != 'Expired'];
        Alliance_Rebate_Request__c request = new Alliance_Rebate_Request__c(id = product.Alliance_Rebate_Request__c);
         if(listOfProduct.size()>0){
       }
else{
         request.Status__c = 'Expired' ; 
     }
      update request;
  }


}
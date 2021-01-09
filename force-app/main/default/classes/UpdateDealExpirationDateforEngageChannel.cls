/**************************************************************************************
Revision CR Number      Release No   Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
  1.0       CR 13212                 4th Jul 2016     Bikram         To Update Deal Expiration Date for Engage Channel Deals
  2.0         CR3955306               08-nov-2017     Srikanth Ganji Changed As part of GC 2.0
  
****************************************************************************************/
public class UpdateDealExpirationDateforEngageChannel{

    public static Boolean TestData = false;
    public static void updateDealExpirationEngageChannel(list < Opportunity > lstOpportunities, map < Id, Opportunity > mapOldOpportunities) {
        for (Opportunity newOpportunity: lstOpportunities) {
            System.debug('UpdateDealExpirationDateforEngageChannel -> updateDealExpirationEngageChannel'+mapOldOpportunities.KeySet());
            Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
            System.debug('UpdateDealExpirationDateforEngageChannel -> updateDealExpirationEngageChannel'+oldOpportunity.Engage_Channel_Opportunity__c);
            System.debug('UpdateDealExpirationDateforEngageChannel -> updateDealExpirationEngageChannel'+newOpportunity.Engage_Channel_Opportunity__c);
            If( newOpportunity.Engage_Channel_Opportunity__c == TRUE && oldOpportunity.Engage_Channel_Opportunity__c == False ){
                System.debug('UpdateDealExpirationDateforEngageChannel -> updateDealExpirationEngageChannel-> in if block');
                newOpportunity.Deal_Expiration_Timeframe__c = '90';
                newOpportunity.Deal_Expiration_Date__c = Date.today() + 90;
            }
            System.debug(newOpportunity.Deal_Expiration_Timeframe__c+'UpdateDealExpirationDateforEngageChannel -> updateDealExpirationEngageChannel'+newOpportunity.Deal_Expiration_Date__c);
            System.debug('UpdateDealExpirationDateforEngageChannel -> updateDealExpirationEngageChannel Exit!!');
            
        }
    }
 }
 
 
/*public class UpdateDealExpirationDateforEngageChannel{

 public static Boolean TestData = false;
 
 
 public static void updateDealExpirationEngageChannel(list < Opportunity > lstOpportunities, map < Id, Opportunity > mapOldOpportunities, map < Id, Opportunity > mapRelatedOpportunities) {
  String partnerRel;
  
  Set<Id> userIds = new Set<Id>();
  Set<Id> ownerIds = new Set<Id>();
  for(Opportunity newOpportunity: lstOpportunities){
      Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
      If( newOpportunity.Engage_Channel_Opportunity__c == TRUE && oldOpportunity.Engage_Channel_Opportunity__c == False ){
        Opportunity relatedOpportunity = mapRelatedOpportunities.get(newOpportunity.Id);  
        userIds.add(relatedOpportunity.ownerid);
        ownerIds.add(newOpportunity.ownerid);
      }
  }
     List<User> users = new List<User>();
     If(userIds.size() > 0){
        users = [Select Id, contact.account.Partner_Type__c, contact.account.Partner_Tier__c, contact.account.Partner_Relationship__c from User where Id IN: userIds];
     }
    Map<Id, String> partnerTypeMap = new Map<Id, String>();
    for(User u: users){
        String partnerType = '';
        
        If( u.contact != NULL ){
         If( u.contact.account.Partner_Type__c != NULL &&
                    (u.contact.account.Partner_Type__c.toUpperCase().equals('Distributor (GCC)'))) {
                                
          // Check If Distributor
          partnerType = 'Distributor';
          
         } 
         else If( u.contact.account.Partner_Type__c != NULL && (u.contact.account.Partner_Type__c.toUpperCase().contains('COMMERCIAL') && 
                  (u.contact.account.Partner_Tier__c == 'Tier 2' || u.contact.account.Partner_Tier__c == 'Tier2' ||  u.contact.account.Partner_Tier__c == 'Indirect Partner Purchase' ) ))
         {
          // Check If Tier 2
          partnerType = 'Tier2';
         }
         else 
          {
          // Check If Tier 1
          partnerType = 'Tier1';
         }
        }
        partnerTypeMap.put(u.Id, partnerType);
    }
     
     Map<Id, boolean> ownerMap = new Map<Id, boolean>();
     If(ownerIds.size() > 0){
        ownerMap = DealRegUtils.isOwnerHasGCProfile(ownerIds);
     }
  for (Opportunity newOpportunity: lstOpportunities) {
   Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
   Opportunity relatedOpportunity = mapRelatedOpportunities.get(newOpportunity.Id);

   //Check if opportunity owner is a distributor
    //if(DistiVisibilityHelperClass.getPartnerType(relatedOpportunity.ownerid) == 'Distributor') {
    if(partnerTypeMap.get(relatedOpportunity.ownerid) == 'Distributor') {   
    if (relatedOpportunity.Distributor_Reseller_Name__c != null && relatedOpportunity.Distributor_Reseller_Name__r.Partner_Relationship__c != null) {
         system.debug('>> if block');
     partnerRel = relatedOpportunity.Distributor_Reseller_Name__r.Partner_Relationship__c;
    }
   } else {
   system.debug('>> else block');
   System.debug(relatedOpportunity);
   System.debug(relatedOpportunity.Owner);
   System.debug(relatedOpportunity.Owner.Contact);
   System.debug(relatedOpportunity.Owner.Contact.Account);
   
    partnerRel = relatedOpportunity.Owner.Contact.Account.Partner_Relationship__c;
   }
   System.debug('partnerRel:' + partnerRel);
      
   //Logic to update Deal Expiration Date   
      If( newOpportunity.Engage_Channel_Opportunity__c == TRUE && oldOpportunity.Engage_Channel_Opportunity__c == False ){
          if(ownerMap.get(newOpportunity.OwnerId) == True){
               /*if (partnerRel == 'Premier' ) {
                newOpportunity.Deal_Expiration_Timeframe__c = '180';
                newOpportunity.Deal_Expiration_Date__c = Date.today() + 180;
               } else if (partnerRel == 'Preferred') {
                newOpportunity.Deal_Expiration_Timeframe__c = '120';
                newOpportunity.Deal_Expiration_Date__c = Date.today() + 120;
               } else if (partnerRel == 'Registered') {
                newOpportunity.Deal_Expiration_Timeframe__c = '60';
                newOpportunity.Deal_Expiration_Date__c = Date.today() + 60;           
               }
               if (PartnerStatusUtilityClass.PremierTypeContains(partnerRel) ) {
                newOpportunity.Deal_Expiration_Timeframe__c = '180';
                newOpportunity.Deal_Expiration_Date__c = Date.today() + 180;
               } else if (PartnerStatusUtilityClass.PreferredTypeContains(partnerRel)) {
                newOpportunity.Deal_Expiration_Timeframe__c = '120';
                newOpportunity.Deal_Expiration_Date__c = Date.today() + 120;
               } else if (PartnerStatusUtilityClass.RegisteredTypeContains(partnerRel)) {
                newOpportunity.Deal_Expiration_Timeframe__c = '60';
                newOpportunity.Deal_Expiration_Date__c = Date.today() + 60;
            
               }

           }else{
               newOpportunity.Deal_Expiration_Timeframe__c = '90';
               newOpportunity.Deal_Expiration_Date__c = Date.today() + 90;
           }
      }
  }
 }
}*/
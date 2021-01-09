/***********************************************************
* Name          : SnPDealRegistrationMainClass 
* Description   : 13.10 Rel - Collection of methods to update Integration Key Expiration Date field, encrypt integration key,
*                                 and update Partner ID in SV Form
* ---------------------------------------------------------
* Revision      Release     Name        Date            Description
* 1.0           13.10       Pat Redor   17.07.2012      CR 7375 - Functionalities for S&P Vendor Partner Information and S&P Vendors object
* 2.0           0102        Sarbjeet     12.04.2019     Added the logic to bypass for the test class SNPUTILSTEST
************************************************************/
public class SnPDealRegistrationMainClass {
    
    public static void updateIntegrationKeyExpirationDate(Map<Id, List<String>> snpVendorNames, List<S_P_Vendor_Automation__c> svAutoList){
        
        for(S_P_Vendor_Automation__c svAuto : svAutoList){
           if(snpVendorNames.get(svAuto.Id).size() > 1)
               if((svAuto.Integration_Key_Expiration_Days__c != null) && (snpVendorNames.get(svAuto.Id) != null))
                   svAuto.Expiration_Date__c = Date.today().addDays(svAuto.Integration_Key_Expiration_Days__c.intValue());
        }
        
        update svAutoList;
    }
    
    public static S_P_Vendor_Partner_Information__c encryptIntegrationKey(S_P_Vendor_Partner_Information__c svpi, List<S_P_Vendor_Automation__c> svAutoList){
        
        for(S_P_Vendor_Automation__c svAuto : svAutoList){ 
            if(svpi.S_P_Vendor_Automation_Id__c == svAuto.Id) { 
                svpi.Integration_Key__c = EncodingUtil.base64encode(Crypto.generateMac(
                                          'hmacSHA1', Blob.valueOf(svpi.Integration_Key__c), 
                                          EncodingUtil.base64Decode(svAuto.Key_for_Encoding_and_Decoding__c)));
                svpi.Partner_Validation_Required__c = true;
                svpi.Integration_Key_Error__c = false;
            }
        }
        
        return svpi;
    }
    
    public static S_P_Vendors__c updatePartnerID(S_P_Vendors__c svRec, Map<String, S_P_Vendor_Partner_Information__c> svpiMap){
        String svKey = '';
       
        try {
            if(svRec.Segment_Name__c != null)
                svKey = (svRec.S_P_Vendors_Name__c.toLowerCase().trim() + svRec.Country__c.toLowerCase().trim() + svRec.Segment_Name__c.toLowerCase()).trim();
            else if(svRec.Country__c != null)
                svKey = svRec.S_P_Vendors_Name__c.toLowerCase().trim() + svRec.Country__c.toLowerCase().trim();
                
            if(svpiMap.get(svKey) != null)
                svRec.Partner_ID__c = svpiMap.get(svKey).Id;
        } catch(NullPointerException npe){
            
        }
        
        return svRec;
    }
    
    public static void sendEmailReminderForExpiringPartnerInformation(){
        Integer daysInterval = 0;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Map<String, List<String>> toAddressesBasedOnVendor;         
        List<Group> publicGroupMembers;
        List<S_P_Vendor_Automation__c> svAutoList = [SELECT Id, Expiration_Date__c, Vendor_Name__c, Vendor_URL__c FROM S_P_Vendor_Automation__c 
                                                        WHERE Expiration_Date__c <> NULL]; 
        
        if(!svAutoList.isEmpty()){
            publicGroupMembers = [SELECT Id, Name,
                                         (SELECT GroupId, UserOrGroupId FROM GroupMembers) 
                                  FROM Group WHERE Name LIKE 'SnP:%Product Managers'];
                                  
            toAddressesBasedOnVendor = sortGroupMembersForEashVendor(publicGroupMembers, svAutoList);
                            
            for(S_P_Vendor_Automation__c svAuto : svAutoList){
                daysInterval = System.today().daysBetween(svAuto.Expiration_Date__c);
                System.debug('*** TEST Days Between Today and Expiration Date ***' + System.today() + ' ** ' + svAuto.Expiration_Date__c + 
                                                            ' ** ' + daysInterval);                
                if(daysInterval <= 11 && daysInterval > 0){
                    mail.setHTMLBody('<font face = \"Calibri\">Vendor Name: ' + svAuto.Vendor_Name__c + '<br /><br />' +
                                     'Please proceed and login to this <a href=' + svAuto.Vendor_URL__c + '>' + svAuto.Vendor_Name__c + 
                                     ' link</a> ' + 
                                     'with all the partner user logins to get the Integration Key. <br /><br />' + 
                                     'Update the Integration Key in the <i>Partner Information</i> file and ' + 
                                     'raise a Data Load Request to load this information into SFDC.</font>');
                    mail.setSubject('S&P Deal Registration: ' + daysInterval + ' day(s) to Integration Key Expiration Date');
                    
                    try{                    
                        mail.setToAddresses(toAddressesBasedOnVendor.get(svAuto.Vendor_Name__c.toLowerCase().trim()));
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
                    } catch (NullPointerException npe){
                        continue;
                    }
                }
            }
        }
    }
    
    private static Map<String, List<String>> sortGroupMembersForEashVendor(List<Group> publicGroupMembers, 
                                                                    List<S_P_Vendor_Automation__c> svAutoList){
        Map<String, List<String>> tmpStorageMap = new Map<String, List<String>>();
        Map<Id, User> snpUserMap;
        Set<Id> userIds = new Set<Id>();
        String tmpVendorSplit;
        String tmpVendorName;
        
        for(Group grp : publicGroupMembers)
            for(GroupMember gm : grp.GroupMembers)
                userIds.add(gm.UserOrGroupId);
        
        if(!userIds.isEmpty())
            snpUserMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id IN :userIds]);
        
        for(S_P_Vendor_Automation__c svAuto : svAutoList){
            tmpVendorName = svAuto.Vendor_Name__c.toLowerCase().trim();
            
            for(Group grp : publicGroupMembers){
                tmpVendorSplit = PublicGroupUpdate.extractVendorNameFromPublicGroupName(grp.Name).toLowerCase().trim();
                
                for(GroupMember gm : grp.GroupMembers){
                    System.debug('*** TEST: Split-VendorName-UserId-Email *** ' + 
                        tmpVendorSplit + '-' + tmpVendorName + '-' + gm.UserOrGroupId + '-' + 
                        snpUserMap.get(gm.UserOrGroupId).Email);
                        
                    if(tmpVendorSplit == tmpVendorName){
                        if(tmpStorageMap.get(tmpVendorName) == null){
                            tmpStorageMap.put(tmpVendorName, new List<String>{
                                                    snpUserMap.get(gm.UserOrGroupId).Email});
                             System.debug('*** TEST: tmpStorageMap *** ' + tmpStorageMap);                 
                        }
                        else{
                            tmpStorageMap.get(tmpVendorName).add(snpUserMap.get(gm.UserOrGroupId).Email);
                            System.debug('*** TEST: tmpStorageMap *** ' + tmpStorageMap); 
                        }
                    }
                }
            }
        }
        
        if(!tmpStorageMap.isEmpty())
            return tmpStorageMap;
        return null;
    }
    
    public static void computeSnPProdQuantity(List<OpportunityLineItem> oppLineItemList, List<S_P_Vendors__c> svRecList){
        String oppBrandCombiKey;
        Integer tmpQuantity = 0;
        Map<String, Integer> totalQuantityMap = new Map<String, Integer>();
        List<S_P_Vendors__c> svRecListUpdate = new List<S_P_Vendors__c>();
       // List<S_P_Vendors__c> svRecList = [SELECT Id, Name, Opportunity__c, Total_S_P_Product_Quantity__c, S_P_Vendors_Name__c 
       //                                     FROM S_P_Vendors__c
       //                                     WHERE Opportunity__c IN :oppIdSet];
        
        System.debug('*** TEST oppLineItemList *** ' + oppLineItemList);
        for(OpportunityLineItem oli : oppLineItemList){
            System.debug('*** TEST S&P Registratble *** ' + oli.S_P_Registerable__c);
            if(oli.S_P_Registerable__c != 'TRUE') 
                oli.Quantity = 0; // Temporarily set quantity to zero
                
            oppBrandCombiKey = oli.OpportunityId + '-' + oli.Brand_Desc__c.toLowerCase().trim();
            System.debug('*** TEST OLI Opportunity Id and Brand Description Combination *** ' + oppBrandCombiKey);
            
            if(totalQuantityMap.get(oppBrandCombiKey) != null) {
                tmpQuantity = totalQuantityMap.get(oppBrandCombiKey);
                totalQuantityMap.remove(oppBrandCombiKey); 
                System.debug('*** TEST tmpQuantity and Map Remove *** ' + tmpQuantity + ' ** ' + 
                                totalQuantityMap.get(oppBrandCombiKey));
                                    
                totalQuantityMap.put(oppBrandCombiKey, tmpQuantity + oli.Quantity.intValue());
                System.debug('*** TEST New Quantity *** ' + totalQuantityMap.get(oppBrandCombiKey));
            }
            else
                totalQuantityMap.put(oppBrandCombiKey, oli.Quantity.intValue());
        }
        
        for(S_P_Vendors__c svRec : svRecList){
            oppBrandCombiKey = svRec.Opportunity__c + '-' + svRec.S_P_Vendors_Name__c.toLowerCase().trim();
            System.debug('*** TEST SV REC Opportunity Id and Brand Description Combination *** ' + oppBrandCombiKey);
            
            if(totalQuantityMap.get(oppBrandCombiKey) != null) {
                svRec.Total_S_P_Product_Quantity__c = totalQuantityMap.get(oppBrandCombiKey);
                svRecListUpdate.add(svRec);
            }
        }
        System.debug('*** TEST svRecListUpdate *** ' + svRecListUpdate);
        if(!svRecListUpdate.isEmpty()) {
		//2.0 Starts
            if (!Test.isrunningTest()){
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
            }
           //2.0 Ends 
            Database.update(svRecListUpdate);
			//2.0 Starts
            if (!Test.isrunningTest()){
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
            }
			//2.0 Ends
        }
    }
}
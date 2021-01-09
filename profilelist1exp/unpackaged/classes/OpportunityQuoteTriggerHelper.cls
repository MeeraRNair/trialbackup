/*
History:
Version     Date                Modified By         CR#                Description     
--------------------------------------------------------------------------------------
1.0                                                                    Created
1.1         05-Aug-2019         Abhinav             CR#17870           Commented Threshold logic
*/
public class OpportunityQuoteTriggerHelper {
    
    public static void validateQuotesAgainstProbability(List<Opportunity> listOpp, Map<Id,Opportunity> mapOld){
        Needed_Quote_GS__c nqgs = Needed_Quote_GS__c.getOrgDefaults();
        List<Opportunity> listQualifyOpp = new List<Opportunity>();
        Map<Id,Opportunity> mapOppswihtOLIs = new Map<Id,Opportunity>();
        for(opportunity opp : listOpp) {
            Opportunity oldOpp = mapOld.get(opp.id);
            if(opp.Probability >= 60 && opp.StageName != oldOpp.StageName) {
                listQualifyOpp.add(opp);
            }
        }
        
        if(!listQualifyOpp.isEmpty()) {
            mapOppswihtOLIs = new Map<Id,Opportunity>([
                            SELECT Id, StageName, Account_Country__c, Account_Country_Code__c, 
                                    (SELECT Id, Quote__c, LOT_Indicator__c, Ocean_Indicator__c, Product2.Order_Compliant_Product__c, Total_Price_in_USD__c
                                            From OpportunityLineItems
                                            where (Quote__c = null OR Quantity = null OR Configuration_Services__c = null OR Customer_Requested_Date__c = null))
                              From Opportunity
                              Where Id IN:listQualifyOpp
                 
                           ]);
            
            // Get all LATAM Region country codes (from Custom settings: LATAM_Country_Codes__c)
            List<LATAM_Country_Codes__c> listLatamCountryCode = LATAM_Country_Codes__c.getall().values();
            set<String> setLatamCode = new set<String>();
            for(LATAM_Country_Codes__c latam: listLatamCountryCode){
                setLatamCode.add(latam.Name);
            }
            for(Opportunity oppq : listOpp) {
                if(mapOppswihtOLIs.containsKey(oppq.id)) {
                    Opportunity oppwithProduct = mapOppswihtOLIs.get(oppq.id);
					Boolean bHasOpptyError = false;
					for(OpportunityLineItem oppProd : oppwithProduct.OpportunityLineItems) {
						//1.1 - EOF
						/*if(
							(oppq.Account_Country__c == 'United States' && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US)) || 
							(setLatamCode.contains(oppq.Account_Country_Code__c) == true  && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_LATAM)) || 
							(oppq.Account_Country__c != 'United States' && setLatamCode.contains(oppq.Account_Country_Code__c) == false && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_Others ))
						) {
							bHasOpptyError = true;
							break;
						}*/
						//1.1 - EOF
						if(oppProd.LOT_Indicator__c || oppProd.Ocean_Indicator__c || (oppProd.Product2.Order_Compliant_Product__c && oppProd.Total_Price_in_USD__c >= Integer.valueOf(System.Label.Threshold_US) )) {
							bHasOpptyError = true;
							break;
						}
					}
					if(bHasOpptyError) {
						oppq.addError(nqgs.trigger_alt_msg__c);
					}
                }
            }
        }
    }
}
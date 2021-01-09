/*
 * Author   : Ragu
 * Purpose  : Act as a intermediate class between LOT Ocean specific classes and triggers.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 2.0      CR2559      R11.5       23-Apr-2010     Raymond         Updated for CR2559 & CR2560.
 * 2.1      CR2805                  17-Jun-2010     Nooryati        Auto populate Primary Delivery Address Country & Primary Delivery Address Region during Opportunity Creation
 * 2.2      CR2810                  24-Jun-2010     Nooryati        Prompt input for Direct Trailer when Opportunity is LOT eligible
 * 2.3                              27-Jun-2010     Raymond         Added code to reset LOT/OCEAN flags if Probability is 0 (to prevent WF triggered recalc)
 * 2.4                              29-Jul-2010     Raymond         Modified to fix defect 61175.
 * 2.5      CR4372                  08-Sep-2010     Raymond         Fix Partner Approval problem by preventing country/region validation if previous record type is not "Standard Opportunity" (from Deal Registration)
 * 3.0      CR5532                  09-Dec-2010     Raymond         Enable Auto-populating LOT Region and Country for Partner Deal. Getting Country from End USer Mailing Country field
 * 4.0      CR6656                  30-Nov-2011     Fenny           Prevent the validation on Primary_Product_Delivery_Address_Region__c and Primary_Product_Delivery_Address_Country__c if the End User Mailing Country value is not part of the picklist values.
 *                                                                  Because from LOB deal registration perspective, the End User Mailing Country is populated from End User Account country field which is a free text.
 * 5.0      CR7118                  21-May-2012     Patrick         Auto populate Primary Product Delivery Address Country & Primary Product Delivery Address Region during "SMB Opportunity" Creation (Add Integration Profiles exclusion)
 * 6.0      CR8577                  16-Aug-2013     Meghana         New record type Channel Opportunity should have same functionality as standard opportunity
 * 7.0      CR9337                  22-May-2014     Devika          Add LOT Functionality for Channel Opportunities.
 * 8.0      CR10496     15.10       25-Sep-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices. This class has the functionalities which are separated from opptyBeforeInsertUpdateTrigger trigger.
 * 9.0      CR12402     CSM0104     30-Nov-2015     Afiq            Comment identical SQL call
 * 10.0     CR13322     CSM0902     23-Aug-2015     Afiq            Change Skip_Calculate_LOT_OCEAN__c checking and reverse changes
 * 11.0     CR15486     FY19-0401   05-Mar-2018     Emily           Field Trip clean up for Opportunity
 * 12.0     CR15591     FY19-0502   02-Apr-2018     Pallavi Mani    Removed LOT_Ocean_field_Changes__c fields logic related to Quote_Numbers__c field as part of story 4795081
 */

public class LOTOcean {

    public static void populateLOTOceanRelatedDetails(list<Opportunity> lstOpportunities) {
        try {
            // v2.1
            if(!GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION) {
                // v2.4: Execute this for every profile, to ensure that the setCountries is available later in calculation
                set<String> setCountries = new set<String>();
                for(Opportunity oppIterator : lstOpportunities) {
                    // If the user selected some value for Primary Delivery Address Country, add the value, else get from sales channel
                    if(oppIterator.Primary_Product_Delivery_Address_Country__c != null) {
                        setCountries.add(oppIterator.Primary_Product_Delivery_Address_Country__c);
                    } 
                    else {
                        if(oppIterator.Sales_Channel_Country__c != null) {
                            setCountries.add(oppIterator.Sales_Channel_Country__c);
                        }
                        if(oppIterator.End_User_Mailing_Country__c != null) {
                            setCountries.add(oppIterator.End_User_Mailing_Country__c);
                        }
                    }
                }
                
                // v4.0: Get list of valid Country names
                set<String> setEndUserMailingCountries = new set<String>();
                Schema.DescribeFieldResult field = Opportunity.End_User_Mailing_Country__c.getDescribe();
                for(Schema.Picklistentry pickListValue : field.getPicklistValues()) {
                    setEndUserMailingCountries.add(pickListValue.getValue());
                }
                
                String strCurrentUserProfileName = StaticFactory.getCurrentUserDetails().Profile.Name;
                set<String> setAdminProfiles = new set<String>{'IT GBL Data Load'};
                map<Id, Profile> mapProfilesToSkipLOTOcean = LOTOCEANUtils.getProfileIdToSkipLOTOcean();
                if(!setAdminProfiles.contains(strCurrentUserProfileName) && !mapProfilesToSkipLOTOcean.keySet().contains(UserInfo.getProfileId())) {
                    
                    boolean bIntegrationProfile = LOTOCEANUtils.getIntegrationProfiles().keySet().contains(UserInfo.getProfileId());
                    
                    LOTOCEANUtils.countrySet = setCountries;
                    LOTOCEANUtils.setupCountryToRegionMap();
                    
                    /*9.0 Start
                    LOTOCEANUtils.setRMCountryMappingMap();
                    9.0 End */
                    
                    map<String, String> RMCountryMap = LOTOCEANUtils.RMCountryMappingMap;
                    
                    Id smbRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'SMB Opportunity');
                    // v6.0 - Added 'Channel Opportunity' in the setRTIdsForLOTOcean
                    set<Id> setRTIdsForLOTOcean = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set<String>{'Standard Opportunity', 'Channel Opportunity'});
                    
                    for(Opportunity oppIterator : lstOpportunities) {
                        // v2.5 - Added condition to check if the Opportunity Record Type has changed from non Standard Opportunity. If so, skip the validation to avoid error
                        // v3.0 - Removed condition that checks if this is converted from Partner deal
                        // v5.0 - Added in the if statement the record type id of SMB Opportunity and the exclusion of integration profiles
                        if(setRTIdsForLOTOcean.contains(oppIterator.RecordTypeId) || (oppIterator.RecordTypeId == smbRTId && !bIntegrationProfile)) {
                            if(oppIterator.Primary_Product_Delivery_Address_Region__c == null || oppIterator.Primary_Product_Delivery_Address_Country__c == null) {
                                String tempCountry = '';
                                String tempRegion = '';
                                if(oppIterator.Sales_Channel_Country__c == null) {
                                    tempCountry = oppIterator.End_User_Mailing_Country__c;
                                }
                                else {
                                    if(RMCountryMap.containsKey(oppIterator.Sales_Channel_Country__c)) {
                                        tempCountry = RMCountryMap.get(oppIterator.Sales_Channel_Country__c);
                                    } 
                                    else {
                                        tempCountry = oppIterator.Sales_Channel_Country__c;
                                    }
                                    
                                    if(!LOTOCEANUtils.countryToStdRegionMap.containsKey(tempCountry.toUpperCase())) {
                                        tempCountry = oppIterator.End_User_Mailing_Country__c;
                                    }
                                }
                                if(tempCountry != null) {
                                    tempCountry = tempCountry.toUpperCase();
                                }
                                
                                // v4.0: Check if the country is found in the valid picklist values
                                if(setEndUserMailingCountries.contains(tempCountry)) {
                                    tempRegion = LOTOCEANUtils.countryToStdRegionMap.get(tempCountry);
                                    
                                    // v3.0 - If Sales Channel is empty, check End User Mailing Country field for value
                                    // v3.0 - not limiting to Partner Record ID here,  may be useful for other "possible cases"
                                    if(tempCountry != null && tempRegion != null) {
                                        oppIterator.Primary_Product_Delivery_Address_Region__c = tempRegion;
                                        oppIterator.Primary_Product_Delivery_Address_Country__c = tempCountry;
                                    } 
                                    else {
                                        oppIterator.Primary_Product_Delivery_Address_Region__c.addError('Please fill in Primary Product Delivery Address Region.');
                                        oppIterator.Primary_Product_Delivery_Address_Country__c.addError('Please fill in Primary Product Delivery Address Country.');
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch (Exception e) {
            emailUtils.sendSupportEmail(e.getMessage() + 'The opportunity set being processed was ' + trigger.new, dellConfig.errorEmail);
            System.debug('DEBUG: Caught exception ' + e.getStackTraceString() + ' ' + e.getMessage());
        }
    }
    
    public static void lotOceanCalculation(map<Id, Opportunity> mapNewOpportunities, map<Id, Opportunity> mapOldOpportunities) {
        // v2.0
        //try {
            map<Id, Profile> mapProfilesToSkipLOTOcean = LOTOCEANUtils.getProfileIdToSkipLOTOcean();
            if(!mapProfilesToSkipLOTOcean.keySet().contains(UserInfo.getProfileId())) {
                // v7.0 - Added Standard Opportunity in the below Record Type set.
                set<Id> setRTIdsForLOTOcean = StaticFactory.getRecordTypeIdsByNames('Opportunity', new set<String>{'Standard Opportunity', 'Channel Opportunity', 'SMB Opportunity'});
                map<Id, Opportunity> mapOppsForLOTCalc = new map<Id, Opportunity>();
                for(Opportunity newOpportunity : mapNewOpportunities.values()) {
                    Opportunity oldOpportunity;
                    if(mapOldOpportunities != null) {
                        oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
                    }
                    
                    if(!setRTIdsForLOTOcean.contains(newOpportunity.RecordTypeId)) {
                        continue;
                    }
                    
                    // v2.3
                    if(newOpportunity.Probability == 0) {
                        newOpportunity.LOT_Large_Opportunity__c = false;
                        newOpportunity.LOT_Large_Opportunity_Potential__c = false;
                        newOpportunity.LOT_Mandatory_Fields__c = false;
    
                        if(newOpportunity.Eligible_for_Ocean__c == 'Yes') {
                            newOpportunity.Eligible_for_Ocean__c = 'No';
                            newOpportunity.Ocean_Opportunity_Notification_Pop_Up__c = true;
                        }
                    }
                    
                    // v7.0 - Added StageName check in the below if condition
                    // Skip_Calculate_LOT_OCEAN__c flag is set in workflow "R9.7 opportunity Stage changes to won/lost" to prevent recalculation of LOT and OCean, which triggers SOQL Limit error
                    // v10.0 - Added checking StageName to calculate OCEAN/LOT 
                    if(!GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION && !newOpportunity.Skip_Calculate_LOT_OCEAN__c && newOpportunity.Probability != 0 && !(newOpportunity.StageName == 'Plan - 1%' && newOpportunity.StageName == 'Discover - 10%')) {
                        if(oldOpportunity != null && (newOpportunity.Recalculate_LOT_OCEAN__c 
                            || newOpportunity.How_many_shipments__c != oldOpportunity.How_many_shipments__c
                            || newOpportunity.CloseDate != oldOpportunity.CloseDate
                            || newOpportunity.StageName != oldOpportunity.StageName
                            || newOpportunity.Probability != oldOpportunity.Probability
                            || newOpportunity.Primary_Product_Delivery_Address_Country__c != oldOpportunity.Primary_Product_Delivery_Address_Country__c
                            || newOpportunity.Primary_Product_Delivery_Address_Region__c != oldOpportunity.Primary_Product_Delivery_Address_Region__c
                            || newOpportunity.Customer_Requested_Delivery_Date__c != oldOpportunity.Customer_Requested_Delivery_Date__c
                            || newOpportunity.Is_CFI_included__c != oldOpportunity.Is_CFI_included__c
                            || newOpportunity.Additional_vol_to_team_Quarterly__c != oldOpportunity.Additional_vol_to_team_Quarterly__c
                            || newOpportunity.Adjustment_weeks__c != oldOpportunity.Adjustment_weeks__c
                            || newOpportunity.Must_Arrive_By_Date__c != oldOpportunity.Must_Arrive_By_Date__c
                            || newOpportunity.Adjustment_Potential_Cost_Saving__c != oldOpportunity.Adjustment_Potential_Cost_Saving__c
                            || newOpportunity.Direct_Trailer_Opportunity__c != oldOpportunity.Direct_Trailer_Opportunity__c)) {
                            
                            String strAllChanges = '';
                            set<String> setChangedFields = new set<String>();
                            
                            if(newOpportunity.Recalculate_LOT_OCEAN__c) {
                                newOpportunity.Recalculate_LOT_OCEAN__c = false;
                                strAllChanges = '[Opportunity Product]';
                                setChangedFields.Add('Quantity');
                            }
                           
                            // v2.1
                            if(newOpportunity.Primary_Product_Delivery_Address_Region__c != oldOpportunity.Primary_Product_Delivery_Address_Region__c) {
                                String strFieldChange = '[Primary Product Delivery Address Region:' + oldOpportunity.Primary_Product_Delivery_Address_Region__c + ' > ' + newOpportunity.Primary_Product_Delivery_Address_Region__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + ',' + strFieldChange);
                                setChangedFields.Add('Primary_Product_Delivery_Address_Region__c');
                            }
                            // v2.1
                            if(newOpportunity.Primary_Product_Delivery_Address_Country__c != oldOpportunity.Primary_Product_Delivery_Address_Country__c) {
                                String strFieldChange = '[Primary Product Delivery Address Country:' + oldOpportunity.Primary_Product_Delivery_Address_Country__c + ' > ' + newOpportunity.Primary_Product_Delivery_Address_Country__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + ',' + strFieldChange);
                                setChangedFields.Add('Primary_Product_Delivery_Address_Country__c');
                            }
                            if(newOpportunity.Customer_Requested_Delivery_Date__c != oldOpportunity.Customer_Requested_Delivery_Date__c) {
                                String strFieldChange = '[Customer Requested Delivery Date:' + oldOpportunity.Customer_Requested_Delivery_Date__c + ' > ' + newOpportunity.Customer_Requested_Delivery_Date__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('Customer_Requested_Delivery_Date__c');
                            }
                            if(newOpportunity.Probability != oldOpportunity.Probability) {
                                String strFieldChange = '[Probability:' + oldOpportunity.Probability + ' > ' + newOpportunity.Probability + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('Probability');
                            }
                            if(newOpportunity.CloseDate != oldOpportunity.CloseDate) {
                                String strFieldChange = '[Book Date:' + oldOpportunity.CloseDate + ' > ' + newOpportunity.CloseDate + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('CloseDate');
                            }
                            
                            if(newOpportunity.Is_CFI_included__c != oldOpportunity.Is_CFI_included__c) {
                                String strFieldChange = '[Is CFI Included:' + oldOpportunity.Is_CFI_included__c + ' > ' + newOpportunity.Is_CFI_included__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('Is_CFI_included__c');
                            }
                            if(newOpportunity.Additional_vol_to_team_Quarterly__c != oldOpportunity.Additional_vol_to_team_Quarterly__c) {
                                String strFieldChange = '[Additional vol to team Quarterly:' + oldOpportunity.Additional_vol_to_team_Quarterly__c + ' > ' + newOpportunity.Additional_vol_to_team_Quarterly__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('Additional_vol_to_team_Quarterly__c');
                            }
                            if(newOpportunity.Adjustment_weeks__c != oldOpportunity.Adjustment_weeks__c) {
                                String strFieldChange = '[Adjustment weeks:' + oldOpportunity.Adjustment_weeks__c + ' > ' + newOpportunity.Adjustment_weeks__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('Adjustment_weeks__c');
                            }
                            if(newOpportunity.How_many_shipments__c != oldOpportunity.How_many_shipments__c) {
                                String strFieldChange = '[How many shipments:' + oldOpportunity.How_many_shipments__c + ' > ' + newOpportunity.How_many_shipments__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('How_many_shipments__c');
                            }
                            if(newOpportunity.Direct_Trailer_Opportunity__c != oldOpportunity.Direct_Trailer_Opportunity__c) {
                                String strFieldChange = '[Direct Trailer Opportunity:' + oldOpportunity.Direct_Trailer_Opportunity__c + ' > ' + newOpportunity.Direct_Trailer_Opportunity__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('Direct_Trailer_Opportunity__c');
                            }
                            if(newOpportunity.Adjustment_Potential_Cost_Saving__c != oldOpportunity.Adjustment_Potential_Cost_Saving__c) {
                                String strFieldChange = '[Adjustment Total Potential Cost Saving:' + oldOpportunity.Adjustment_Potential_Cost_Saving__c + ' > ' + newOpportunity.Adjustment_Potential_Cost_Saving__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('Adjustment_Potential_Cost_Saving__c');
                            }
                            if(newOpportunity.Must_Arrive_By_Date__c != oldOpportunity.Must_Arrive_By_Date__c) {
                                String strFieldChange = '[Must Arrive By Date:' + oldOpportunity.Must_Arrive_By_Date__c + ' > ' + newOpportunity.Must_Arrive_By_Date__c + ']';
                                strAllChanges = (strAllChanges == '' ? strFieldChange : strAllChanges + '\n' + strFieldChange);
                                setChangedFields.Add('Must_Arrive_By_Date__c');
                            }
    
                            if(strAllChanges != '') {
                                strAllChanges = 'Changes made on ' + System.now() + ' by ' + UserInfo.getName() + ' :-\n' + strAllChanges;
                                newOpportunity.LOT_OCEAN_Field_Changes__c = strAllChanges;
                            }
                            
                            if(setChangedFields.size() == 1 && setChangedFields.contains('Adjustment_Potential_Cost_Saving__c')) {
                                if(newOpportunity.Potential_Cost_Savings_If_Ocean__c != null) {
                                    Double dPotentialCostSavings = newOpportunity.Potential_Cost_Savings_If_Ocean__c / (1 + (oldOpportunity.Adjustment_Potential_Cost_Saving__c == null ? 0 : oldOpportunity.Adjustment_Potential_Cost_Saving__c) / 100);
                                    newOpportunity.Potential_Cost_Savings_If_Ocean__c = dPotentialCostSavings + dPotentialCostSavings * (newOpportunity.Adjustment_Potential_Cost_Saving__c == null ? 0 : newOpportunity.Adjustment_Potential_Cost_Saving__c) / 100;
                                }
                            }
                            else {
                                mapOppsForLOTCalc.put(newOpportunity.Id, newOpportunity);
                            }
                        }
                        else if(oldOpportunity == null) {
                            // MARKER - Ragu on 07-Oct-2014: This else part is reserved for future to skip Opportunity triggers after
                            // insert / update / delete / undelete of OpportunityLineItems => OpportunityLineItemUtilities.initiateDGRCalculations()
                            String strAllChanges = '';
                            set<String> setChangedFields = new set<String>();
                            
                            if(newOpportunity.Recalculate_LOT_OCEAN__c) {
                                newOpportunity.Recalculate_LOT_OCEAN__c = false;
                                strAllChanges = '[Opportunity Product]';
                                setChangedFields.Add('Quantity');
                            }
                            
                            if(strAllChanges != '') {
                                strAllChanges = 'Changes made on ' + System.now() + ' by ' + UserInfo.getName() + ' :-\n' + strAllChanges;
                                newOpportunity.LOT_OCEAN_Field_Changes__c = strAllChanges;
                            }
                            mapOppsForLOTCalc.put(newOpportunity.Id, newOpportunity);
                        }
                    }
                    
                    // Reset the flag to false
                    //v10.0 Change from checking True and set it to False to checking for False and set it to True
                    if(!newOpportunity.Skip_Calculate_LOT_OCEAN__c) {
                        newOpportunity.Skip_Calculate_LOT_OCEAN__c = true;
                    }
                }
                
                if(!mapOppsForLOTCalc.isEmpty()) {
                    LOTOCEANUtils lotOceanUtil = new LOTOCEANUtils(mapOppsForLOTCalc);
                    list<Opportunity> lstLOTQualifiedOpps = lotOceanUtil.processLOTQualifiedOppty();
                    if(lstLOTQualifiedOpps != null) {
                        for(Opportunity oppIterator: lstLOTQualifiedOpps) {
                            Opportunity newOpportunity = mapNewOpportunities.get(oppIterator.Id);
                            
                            newOpportunity.LOT_Large_Opportunity__c = oppIterator.LOT_Large_Opportunity__c;
                            newOpportunity.LOT_Large_Opportunity_Potential__c = oppIterator.LOT_Large_Opportunity_Potential__c;
                            newOpportunity.LOT_OCEAN_Email_Notification__c = oppIterator.LOT_OCEAN_Email_Notification__c;
                            newOpportunity.Error_Description__c = oppIterator.Error_Description__c;
                            newOpportunity.LOT_Mandatory_Fields__c = oppIterator.LOT_Mandatory_Fields__c;
    
                        }
                    }
                    
                   
                    list<Opportunity> lstOceanQualifiedOpps = lotOceanUtil.processOCEANQualifiedOppty();
                    Id channelOppRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Channel Opportunity');
                    if(lstOceanQualifiedOpps != null) {
                        for(Opportunity oppIterator: lstOceanQualifiedOpps) {
                            
                            Opportunity newOpportunity = mapNewOpportunities.get(oppIterator.Id);
                            newOpportunity.Error_Description__c = oppIterator.Error_Description__c;
                            newOpportunity.Calculated_Delivery_in_Weeks__c = oppIterator.Calculated_Delivery_in_Weeks__c;
                            newOpportunity.Potential_Cost_Savings_If_Ocean__c = oppIterator.Potential_Cost_Savings_If_Ocean__c;
                            newOpportunity.Eligible_for_Ocean__c = oppIterator.Eligible_for_Ocean__c;
                            newOpportunity.Do_you_want_to_pursue_Ocean__c = oppIterator.Do_you_want_to_pursue_Ocean__c;
                            newOpportunity.Ocean_Type__c = oppIterator.Ocean_Type__c;
                            
                            // v7.0 - Added Record Type check
                            if(oppIterator.RecordTypeId != channelOppRTId) {
                                newOpportunity.LOT_OCEAN_Email_Notification__c = oppIterator.LOT_OCEAN_Email_Notification__c;
                            }
                            if(newOpportunity.Ocean_Opportunity_Notification_Pop_Up__c != oppIterator.Ocean_Opportunity_Notification_Pop_Up__c) {
                                newOpportunity.Ocean_Opportunity_Notification_Pop_Up__c = true;
                            }
                        }
                    }
                    GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
                }
            }
    }

}
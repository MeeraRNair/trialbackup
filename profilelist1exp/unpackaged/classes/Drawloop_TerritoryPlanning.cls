/***********************************************************
    * Name          : Drawloop_TerritoryPlanning 
    * ---------------------------------------------------------
    * Revision  Name     CR#        Date           Description
    * 1.0      Swathi    13642      11/24/2016     Added comments not to modify this class.
    * 2.0      Josie     14090      04/27/2017     (FT- Titans) - Added 3 New Roles
    * 3.0      Harsha    14786      08/15/2017     (FT- Titans) Modified query method,teamroles and commonfields variables,
    * 												and moved related methods to TP_utilities class
    

    //This class written by Drawloop vendor.
    //Dont modify this class. Please contact Power team if needed.
    //Purpose of this class to populate data from Revenue, Account Team Member on to Territory Plan Template i.e DDP. 
************************************************************/


global class Drawloop_TerritoryPlanning implements Loop.IApexDataSource {
    @testVisible
    private static final string accountTeamObjectName = 'Apex_AccountTeam';
    @testVisible
    private static final string accountPrioritization1ObjectName = 'Apex_AccountPrioritization1';
    @testVisible
    private static final string accountPrioritization2ObjectName = 'Apex_AccountPrioritization2';
    @testVisible
    private static final string lobRevenueTrendObjectName = 'Apex_LobRevenueTrend';
    @testVisible
    private static final string focusAccountObjectName = 'Apex_FocusAccount';
    @testVisible
    private static final string summarizedRevenueObjectName = 'Apex_SummarizedRevenue';
    @testVisible
    private static final string partnerRevenueObjectName = 'Apex_PartnerRevenue';
    @testVisible
    private static final string partnerGrowthObjectName = 'Apex_PartnerGrowth';
    @testVisible
    private static final string territoryPlanningObjectName = 'Apex_TerritoryPlanning';
    @testVisible
    private static final List<string> teamRoles = TP_Utilities.teamRoles; //v3.0
    @testVisible
    private static final List<string> commonFields = TP_Utilities.commonFields; //v3.0
    
    private final List<string> revenuePrefixes = new List<string>{
        'L4Q_Revenue_',
        'P4Q_Revenue_',
        'PP4Q_Revenue_'
    };
    
    private final integer maxSlide1AccountPrioritizationRows = 19;
    
    public Set<String> getGlobalDescribe() {
        return new Set<string> {
            accountTeamObjectName,
            accountPrioritization1ObjectName,
            accountPrioritization2ObjectName,
            lobRevenueTrendObjectName,
            focusAccountObjectName,
            summarizedRevenueObjectName,
            partnerRevenueObjectName,
            partnerGrowthObjectName,
            territoryPlanningObjectName
        };
    }
    
    private Loop.ExternalData.FieldInfo createFieldInfo(string name, string label, Schema.DisplayType type) {
        Loop.ExternalData.FieldInfo outputInfo = new Loop.ExternalData.FieldInfo(name, type);
        outputInfo.label = label;
        return outputInfo;
    }
    
    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objNames) {
        List<Loop.ExternalData.DataObject> output = new List<Loop.ExternalData.DataObject>();
        
        for (string objName : objNames) {
            List<Loop.ExternalData.FieldInfo> outputFields = new List<Loop.ExternalData.FieldInfo>();
            if (objName == accountTeamObjectName) {
               system.debug('*******1');
                for (string role : teamRoles) {
                    outputFields.add(createFieldInfo(
                        TP_Utilities.normalizeRoleFieldName(role),
                        role + ' Names',
                        Schema.DisplayType.STRING));
                    //system.debug('*******2*****'+role);
                }
            } else if (objName == accountPrioritization1ObjectName || objName == accountPrioritization2ObjectName) {
                outputFields.add(createFieldInfo('AccountName',  'Account Name', Schema.DisplayType.STRING));
                
                outputFields.add(createFieldInfo('CFY_Revenue', 'CFY Revenue',  Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('LFY_Revenue', 'LFY Revenue',  Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('PFY_Revenue', 'PFY Revenue', Schema.DisplayType.CURRENCY));
                
                outputFields.add(createFieldInfo('Q1_Revenue',   'Q1 Revenue',   Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('Q2_Revenue',   'Q2 Revenue',   Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('Q3_Revenue',   'Q3 Revenue',   Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('Q4_Revenue',   'Q4 Revenue',   Schema.DisplayType.CURRENCY));
                
                outputFields.add(createFieldInfo('QQ_Growth',    'Q/Q Growth',   Schema.DisplayType.PERCENT));
                outputFields.add(createFieldInfo('YY_Growth',    'Y/Y Growth',   Schema.DisplayType.PERCENT));
                
                outputFields.add(createFieldInfo('L4Q_Revenue', 'Last 4 Quarters Revenue', Schema.DisplayType.CURRENCY));
            } else if (objName == lobRevenueTrendObjectName) {
                outputFields.add(createFieldInfo('AccountName',  'Account Name', Schema.DisplayType.STRING));
                
                for (string commonField : commonFields) {
                    outputFields.add(createFieldInfo('L4Q_Revenue_'+commonField, 'Last 4 Quarters Revenue - '+commonField, Schema.DisplayType.CURRENCY));
                    outputFields.add(createFieldInfo('QQ_Revenue_'+commonField,  'Q/Q Revenue - '+commonField, Schema.DisplayType.PERCENT));
                    outputFields.add(createFieldInfo('YY_Revenue_'+commonField,  'Y/Y Revenue - '+commonField, Schema.DisplayType.PERCENT));
                }
                
                outputFields.add(createFieldInfo('L4Q_Revenue', 'Last 4 Quarters Revenue - Total', Schema.DisplayType.CURRENCY));
            } else if (objName == focusAccountObjectName) {
                outputFields.add(createFieldInfo('AccountName',  'Account Name', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('AccountPlanName',  'Account Plan Name', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('Status',  'Status', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('NumberOfStrategies',  'Number of Strategies', Schema.DisplayType.STRING));
            } else if (objName == summarizedRevenueObjectName) {
                outputFields.add(createFieldInfo('L4Q_Revenue_Total', 'Last 4 Quarters Revenue - Total', Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('P4Q_Revenue_Total', 'Past 4 Quarters Revenue - Total', Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('PP4Q_Revenue_Total', 'Previous Past 4 Quarters Revenue - Total', Schema.DisplayType.CURRENCY));
                
                outputFields.add(createFieldInfo('L4Q_Margin_Total', 'Last 4 Quarters Margin - Total', Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('P4Q_Margin_Total', 'Past 4 Quarters Margin - Total', Schema.DisplayType.CURRENCY));
                outputFields.add(createFieldInfo('PP4Q_Margin_Total', 'Previous Past 4 Quarters Margin - Total', Schema.DisplayType.CURRENCY));
                
                List<string> commonPlus = new List<string>(commonFields);
                commonPlus.addAll(new List<string>{ 'Partner', 'Direct' });
                for (string commonField : commonPlus) {
                    outputFields.add(createFieldInfo('L4Q_Revenue_'+commonField, 'Last 4 Quarters Revenue - '+commonField, Schema.DisplayType.CURRENCY));
                    outputFields.add(createFieldInfo('P4Q_Revenue_'+commonField, 'Past 4 Quarters Revenue - '+commonField, Schema.DisplayType.CURRENCY));
                    outputFields.add(createFieldInfo('PP4Q_Revenue_'+commonField, 'Previous Past 4 Quarters Revenue - '+commonField, Schema.DisplayType.CURRENCY));
                }
            } else if (objName == partnerRevenueObjectName) {
                outputFields.add(createFieldInfo('AccountName',  'Account Name', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('Revenue',  'Revenue', Schema.DisplayType.CURRENCY));
            } else if (objName == partnerGrowthObjectName) {
                outputFields.add(createFieldInfo('Quarter',  'Quarter Name', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('Revenue',  'Revenue', Schema.DisplayType.CURRENCY));
            } else if (objName == territoryPlanningObjectName) {
                outputFields.add(createFieldInfo('CFYQ',  'Current Fiscal Year Quarter (FY#### Q##)', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('CFY',  'Current Fiscal Year (FY##)', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('LFY',  'Last Fiscal Year (FY##)', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('PFY',  'Previous Fiscal Year (FY##)', Schema.DisplayType.STRING));
                outputFields.add(createFieldInfo('IncludePrioritization2', 'Include the second slide for Account Prioritization', Schema.DisplayType.BOOLEAN));
            }
            output.add(new Loop.ExternalData.DataObject(objName, outputFields));
        }
         system.debug('*******3 output*****'+output);
        return output;
    }
    
    public Set<string> getChildRelationships(string objectName) {
        return new Set<string>();
    }
    
    //Ver 3.0 start
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        Loop.ExternalData.QueryResultSet results = new Loop.ExternalData.QueryResultSet();
        
        try {

            Set<string> last4Quarters = TP_Utilities.initiateFYQuarterCalc();
                        
            for (string objectName : requestInfo.GetObjectNames()) {
                List<string> fields = new List<string>();
                system.debug('*******4 objectName*****'+objectName );

                Loop.ExternalData.QueryResult result = new Loop.ExternalData.QueryResult(objectName, fields);
                List<List<string>> rows = new List<List<string>>();
                
                if (objectName == accountTeamObjectName) {
                    for (string role : teamRoles) {
                        fields.add(TP_Utilities.normalizeRoleFieldName(role));
                    }
                    rows = TP_Utilities.getAccountTeamRecords(teamRoles);
                    //system.debug('*******4 aTemaRecords*****'+rows);
                     
                } else if (objectName == accountPrioritization1ObjectName || objectName == accountPrioritization2ObjectName) {
                    fields.addAll(new List<string>{
                        'AccountName', 'CFY_Revenue', 'LFY_Revenue', 'PFY_Revenue',
                        'Q1_Revenue', 'Q2_Revenue', 'Q3_Revenue', 'Q4_Revenue',
                        'QQ_Growth', 'YY_Growth', 'L4Q_Revenue'
                    });
                    rows = TP_Utilities.getAccountPrioritization(objectName, TP_Utilities.accountIds, maxSlide1AccountPrioritizationRows, accountPrioritization1ObjectName, accountPrioritization2ObjectName);
                   // system.debug('***getAccountPrioritization***  : '+rows);

                } else if (objectName == lobRevenueTrendObjectName) {
                    fields.add('AccountName');
                    for (string commonField : commonFields) {
                        fields.add('L4Q_Revenue_'+commonField);
                        fields.add('QQ_Revenue_'+commonField);
                        fields.add('YY_Revenue_'+commonField);
                    }
                    fields.add('L4Q_Revenue');
                    rows = TP_Utilities.getLobRevenueTrends();
                  //  system.debug('***getLobRevenueTrends***  : '+rows);
                } else if (objectName == focusAccountObjectName) {
                    fields.addAll(new List<string>{
                        'AccountName', 'AccountPlanName', 'Status', 'NumberOfStrategies'
                    });
                    rows = TP_Utilities.getFocusAccountPlans();
                  //  system.debug('***getFocusAccountPlans***  : '+rows);
                } else if (objectName == summarizedRevenueObjectName) {
                    fields.addAll(new List<string>{
                        'L4Q_Revenue_Total', 'P4Q_Revenue_Total', 'PP4Q_Revenue_Total',
                        'L4Q_Margin_Total', 'P4Q_Margin_Total', 'PP4Q_Margin_Total'
                    });
                    List<string> commonPlus = new List<string>(commonFields);
                    commonPlus.addAll(new List<string>{ 'Partner', 'Direct' });
                    for (string commonField : commonPlus) {
                        for (string prefix : revenuePrefixes) {
                            fields.add(prefix+commonField);
                        }
                    }
                    rows = TP_Utilities.getSummarizedRevenue();
                    //system.debug('***getSummarizedRevenue***  : '+rows);
                } else if (objectName == partnerRevenueObjectName) {
                    fields.addAll(new List<string>{
                        'AccountName', 'Revenue'
                    });
                    rows = TP_Utilities.getPartnerRevenue(last4Quarters);
                  //  system.debug('***getPartnerRevenue***  : '+rows);
                } else if (objectName == partnerGrowthObjectName) {
                    fields.addAll(new List<string>{
                        'Quarter', 'Revenue'
                    });
                    rows = TP_Utilities.getPartnerGrowth();
                 //   system.debug('***getPartnerGrowth***  : '+rows);
                } else if (objectName == territoryPlanningObjectName) {
                    fields.addAll(new List<string>{
                        'CFYQ', 'CFY', 'LFY', 'PFY', 'IncludePrioritization2'
                    });
                    rows = TP_Utilities.getTerritoryPlanning(maxSlide1AccountPrioritizationRows);
                 //   system.debug('***territory planning***  : '+rows);
                }
                
                result = new Loop.ExternalData.QueryResult(objectName, fields);
                result.rows.addAll(rows);
                
                results.add(result);
                //system.debug('***Harsha*** results : '+results);
                //system.debug('***Harsha*** fields : '+fields);
            }
        } catch (Exception ex) {
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            throw new DdpApexException(ex.getMessage(), ex);
        }
        
        return results;
    }
    //ver3.0 end
    
    
    private class DdpApexException extends Exception {}
}
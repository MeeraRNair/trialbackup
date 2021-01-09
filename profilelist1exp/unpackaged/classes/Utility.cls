/*
 * Author   : Ragu
 * Purpose  : Contains utility methods which can be reused.
 * 
 * Revision	CR Number	Release No	Date			Modified By  	Description
 * --------	---------	----------	-----------		------------	-----------
 * 1.0      CR10496		15.10		05-Sep-2014		Ragu			Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 1.1		CR10496		15.10		29-Sep-2014		Ragu			Added method for printing usage against the governor limits
 * 1.2		CR10496		15.10		07-Oct-2014		Ragu			Added method for generating dynamic query
 * 1.3		CR10634		15.10		14-Nov-2014		Ragu			Added utility methods related to Opportunity stage - not used in this release but can be used in future
 * 2.0      CR10751     16.03       19-Dec-2014     Ragu            Introduced methods for converting list to set and set to list.
 */

public class Utility {
	
	// v1.0 - Created
	public static boolean isIdAvailable(list<sObject> records) {
		boolean bIdAvailable = false;
		for(sObject iterator : records) {
			if(iterator.get('Id') != null) {
				bIdAvailable = true;
				break;
			}
		}
		return bIdAvailable;
	}
	
	// v1.0 - Created
    public static set<Id> getIds(list<sObject> records) {
        set<Id> setIds = new set<Id>();
        if(records != null && !records.isEmpty()) {
            for(sObject iterator : records) {
                if(iterator.get('Id') != null) {
                    setIds.add(String.valueOf(iterator.get('Id')));
                }
            }
        }
        return setIds;
    }
    
    // v1.1 - Created
    public static void printLimitsConsumption(String strIdentifier) {
    	System.debug('Governor Limits Consumption Summary - ' + strIdentifier);
    	System.debug('SOQL Queries  : ' + Limits.getQueries() + ' out of ' + Limits.getLimitQueries());
    	System.debug('DML Statements: ' + Limits.getDMLStatements() + ' out of ' + Limits.getLimitDMLStatements());
    	System.debug('Future Methods: ' + Limits.getFutureCalls() + ' out of ' + Limits.getLimitFutureCalls());
    }
    
    // v1.2 - Created
    public static string getFieldsForQuery(SObject sObj) {
    	String strFields = '';
		for(Schema.SObjectField field : sObj.getSObjectType().getDescribe().fields.getMap().values()) {
		   strFields += field.getDescribe().getName() + ', ';
		}
		
		if(strFields.length() > 0) {
			strFields = strFields.subString(0, strFields.length() - 1);
		}
		return strFields;
    }
    
    // v1.3 - Created
    public static boolean checkStageChangeAcrossOpenAndClosed(string newStage, string oldStage) {
    	map<string, set<string>> mapOppStages = StaticFactory.getOpportunityStageByGrouping();
    	set<string> setOpenStages = mapOppStages.get('Open');
    	set<string> setClosedStages = mapOppStages.get('Closed');
    	
    	boolean bChanged = false;
    	if((setOpenStages.contains(newStage) && setClosedStages.contains(oldStage))
    		|| (setOpenStages.contains(oldStage) && setClosedStages.contains(newStage))) {
    		bChanged = true;
    	}
    	return bChanged;
    }
    
    // v1.3 - Created
    public static boolean isClosedStage(string stageName) {
    	map<string, set<string>> mapOppStages = StaticFactory.getOpportunityStageByGrouping();
    	set<string> setClosedStages = mapOppStages.get('Closed');
    	
    	boolean bClosedStage = false;
    	if(setClosedStages.contains(stageName)) {
    		bClosedStage = true;
    	}
    	return bClosedStage;
    }
    
    // v1.3 - Created
    public static boolean isOpenStage(string stageName) {
    	map<string, set<string>> mapOppStages = StaticFactory.getOpportunityStageByGrouping();
    	set<string> setOpenStages = mapOppStages.get('Open');
    	
    	boolean bOpenStage = false;
    	if(setOpenStages.contains(stageName)) {
    		bOpenStage = true;
    	}
    	return bOpenStage;
    }
    
    // v2.0 - Created
    public static list<String> getList(set<String> setStrings) {
    	list<String> lstStrings = new list<String>();
    	lstStrings.addAll(setStrings);
    	return lstStrings;
    }
    
    // v2.0 - Created
    public static set<String> getSet(list<String> lstStrings) {
    	set<String> setStrings = new set<String>();
    	setStrings.addAll(lstStrings);
    	return setStrings;
    }
    
    // v2.0 - Created
    public static list<Id> getList(set<Id> setIds) {
    	list<Id> lstIds = new list<Id>();
    	lstIds.addAll(setIds);
    	return lstIds;
    }
    
    // v2.0 - Created
    public static set<Id> getSet(list<Id> lstIds) {
    	set<Id> setIds = new set<Id>();
    	setIds.addAll(lstIds);
    	return setIds;
    }

}
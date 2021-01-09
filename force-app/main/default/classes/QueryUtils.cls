/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 2.0		11555		16.07		28-May-2015		Ragu			Added formQuery() method to prepare the query string based on the object and set of fields parameter.
 * 
 * 
 */
 
public with sharing class QueryUtils {
	
    public static String getWhereClauseFromInput(Map<Id, Id> ClauseInputMap,String first, String second){
        String WhereClause = ''; 
        Boolean firstIteration = true;
        for (String key: ClauseInputMap.keySet()) {
            if(!firstIteration) {
                WhereClause += ' OR ';              
            }
            WhereClause += '('+ first + '=\'' + key + '\' AND '+ second +'=\'' + ClauseInputMap.get(key) + '\')';
            firstIteration = false;
        }
                
        if (WhereClause != '') {
        	WhereClause = ' WHERE ' + WhereClause; //'<space>WHERE<space>'
        }
        return WhereClause;
    }
    
	// v2.0 - Form the dynamic query based on the parameters passed
	public static String formQuery(String strObjectAPIName, set<String> setFields) {
		setFields.remove('Id');
		String strQuery = 'select Id';
		for(String strField : setFields) {
			strQuery += ', ' + strField;
		}
		return strQuery + ' from ' + strObjectAPIName;
	}
	
}
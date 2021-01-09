/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 *
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a
 * copy of the License at:
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
global class SObjectUtils {

	global static Boolean isAnyFieldBlank(SObject obj, String[] fields){
		if(obj == null || ArrayUtils.isEmpty(fields)){
			return false;
		}
		Boolean anyFieldBlank = false;
		Object value = null;
		for(String field : fields){
			value = obj.get(field);
			if(value == null || (value instanceof String && StringUtils.isBlank((String)value))){
				anyFieldBlank = true;
			}
		}
		return anyFieldBlank;
	}

	global static String toString(SObject obj){
		if(Limits.getFieldsDescribes() >= Limits.getLimitFieldsDescribes()){
			return null;
		}
		if(obj == null){
			return 'null';
		}
		Schema.DescribeSObjectResult objDesc = obj.getSObjectType().getDescribe();
		List<String> fieldValues = new List<String>();
	   	Map<String, Schema.SObjectField> m = objDesc.fields.getMap();
	   	for (Schema.SObjectField f : m.values()) {
			Schema.DescribeFieldResult d = f.getDescribe();
			fieldValues.add(d.getName() + '=' + obj.get(d.getName()));
		}
		return '<#' + objDesc.getName() + '(' + StringUtils.joinArray(fieldValues,',') + ')>';
	}

	public static boolean isValueChanged(SObject oldValue, SObject newValue, List<String> fieldList) {
        if(oldValue == null || newValue == null){ return false;}
        for (String fieldAPIName: fieldList) {
            System.debug('## compare value: '+oldValue.get(fieldAPIName)+'->'+ newValue.get(fieldAPIName));

            if (oldValue.get(fieldAPIName) <> newValue.get(fieldAPIName)) {
                return true;
            }
        }
        //implies no change
        return false;
    }

    public static List<selectOption> getPickValues(Sobject object_name, String field_name, String first_val) {
      	List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
      	if (first_val != null) { //if there is a first value being provided
         	options.add(new selectOption(first_val, first_val)); //add the first option
      	}
      	Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
      	Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
      	Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      	List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      	for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
         	options.add(new selectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
      	}
      	return options; //return the List
	}

	public static Map<String, Schema.SObjectField> getSObjectFields (SObject obj){
		Schema.sObjectType sobject_type = obj.getSObjectType();
		Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
		Map<String, Schema.SObjectField> sMap =  sobject_describe.fields.getMap();
		return sMap;

	}


}
/*
 * Author   : Ragu
 * Purpose  : Enforces methods to derived record selector classes.
 *          Classes which are deriving this class should define methods getRecords(list, map) and getRelatedRecords(list). 
 * 
 * Revision	CR Number	Release No	Date			Modified By  	Description
 * --------	---------	----------	-----------		------------	-----------
 * 1.0      CR10496		15.10		05-Sep-2014		Ragu			Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 
 * 
 */

public abstract class RecordSelector {
    
    protected abstract void getRecords(list<sObject> records, map<Id, sObject> oldRecords);
    protected abstract void getRelatedRecords(list<sObject> records);
    
    protected void getRecords(list<sObject> records, list<sObject> oldRecords) {
        map<Id, sObject> mapOldRecords = new map<Id, sObject>();
        if(oldRecords != null && !oldRecords.isEmpty()) {
            for(sObject iterator : oldRecords) {
                if(opportunity.Id != null) {
                    mapOldRecords.put(iterator.Id, iterator);
                }
            }
        }
        this.getRecords(records, mapOldRecords);
    }

}
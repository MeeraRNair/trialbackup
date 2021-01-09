/*
 * Author   : Fenny
 * Purpose  : Centralize the record selection process for Case.
 *          Defines the methods which iterate and segregate the S_P_Vendors__c records for further use.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0		18309		FY20-0102		25-Nov-2019			Fenny			Accessible SnPVendorsRecordSelector
**/

public with sharing class SnPVendorsRecordSelector extends RecordSelector {

    public SnPVendorsRecordSelector(List<sObject> listNewSnP, Map<Id, sObject> mapOldSnP, TriggerHandler snpHandler) {
        this.getRecords(listNewSnP, mapOldSnP);
        this.getRelatedRecords(listNewSnP);
    }

    protected override void getRecords(list<sObject> listRecords, map<Id, sObject> mapRecords){

    }

    protected override void getRelatedRecords(list<sObject> listRecords){

    }
}
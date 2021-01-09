/*
 * Author   :
 * Purpose  :
 *
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0                                                                  Originated
 * 2.0      CR 13091    FY17-DCS-0602   18-May-2016     Gan             Create a new passed in parameter to hold the report name
 * 3.0      CR 13598    FY17-DCS-0103   11-Oct-2016     Sajith          Fix hyperlinks from product map export
 * 4.0      CR 13972    FY18-DCS-0302   03-Feb-2017     Sajith          Fix for Phone field export
*/

public class ChildRecordsExporter
{
    public List<sObject> lstChildData {get; set;}
    public Component.Apex.DataTable objDT{get; set;}
    public String fileName{get; set;}
    public String sfdcURL {get;set;}

    public ChildRecordsExporter()
    {
        String customSettingName = ApexPages.CurrentPage().getParameters().get('csn');
        String sObjectName = ApexPages.CurrentPage().getParameters().get('on');
        String parentRecordId = ApexPages.CurrentPage().getParameters().get('pri');
        String parentReferenceField = ApexPages.CurrentPage().getParameters().get('prf');
        //2.0
        String strFileName = ApexPages.CurrentPage().getParameters().get('fn');
        //3.0
        sfdcURL = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';
        //2.0
        if(strFileName!= null) {
            fileName = strFileName + '.xls';
        }
        else {
            fileName = sObjectName.endsWith('__c') ? sObjectName.removeEnd('__c') + '.xls' : sObjectName + '.xls';
        }

        List<sObject> lstColumnData = retrieveColumnData(customSettingName);
        lstChildData = retrieveChildData(sObjectName, parentRecordId, parentReferenceField, lstColumnData);

        objDT = generateDataTable(lstColumnData, 'lstChildData');
    }

    private Component.Apex.DataTable generateDataTable(List<sObject> lstColumnData, String childDataListVariableName)
    {
        Component.Apex.DataTable objDT = new Component.Apex.DataTable();
        objDT.columns = lstColumnData.size();
        objDT.border = '1';
        objDT.expressions.value = '{!' + childDataListVariableName + '}';
        objDT.var = 'objChildData';

        for(sObject objColumnData : lstColumnData)
        {
            Component.Apex.Column objCol = new Component.Apex.Column();
            objCol.headerValue = (String)objColumnData.get('Name');
            //3.0 Fix hyperlink for lookup fields in the export file
            //4.0 Checking the data type to export accordingly
            if (objColumnData.get('Data_Type__c')=='Lookup'){
                Component.Apex.OutputLink objOL = new Component.Apex.OutputLink();
                //4.0 Adding sfdcURL if the lookUP field is not empty
                objOL.expressions.value = '{!IF(objChildData[\'' + (String)objColumnData.get('API_Name__c') + '\'] != null,sfdcURL + objChildData[\'' + (String)objColumnData.get('API_Name__c') + '\'],\'\')}';
                Component.Apex.OutputText objOT = new Component.Apex.OutputText();
                System.debug(LoggingLevel.Info,'Data value Checked :' + objColumnData.get('Lookup_Field__c'));
                if(!String.isEmpty((String)objColumnData.get('Lookup_Field__c'))) {
                    objOT.expressions.value = '{!objChildData[\'' + (String)objColumnData.get('Lookup_Field__c') + '\']}';
                    System.debug(LoggingLevel.Info,'Data value Extracted :' + objOT.expressions.value);
                }
                else{
                    objOT.expressions.value = '{!objChildData[\'' + (String)objColumnData.get('API_Name__c') + '\']}';
                }
                objOL.childComponents.add(objOT);
               	objCol.childComponents.add(objOL);
                
            }
            //4.0 Adding a ' in front of phone number field to display the field as text while exporting
            else if (objColumnData.get('Data_Type__c')=='Phone'){ 
                Component.Apex.OutputText objOT = new Component.Apex.OutputText();
                //Checking whether the field is empty and if not empty, prefixing a single quote 
                objOT.expressions.value = '{!IF(objChildData[\'' + (String)objColumnData.get('API_Name__c') + '\'] != null,\" \' \" + objChildData[\'' + (String)objColumnData.get('API_Name__c') + '\'],\'\')}';
                objCol.childComponents.add(objOT);
            }
            else{
                Component.Apex.OutputField objOF = new Component.Apex.OutputField();
                objOF.expressions.value = '{!objChildData[\'' + (String)objColumnData.get('API_Name__c') + '\']}';
                objCol.childComponents.add(objOF);
            }
            objDT.childComponents.add(objCol);
        }

        return objDT;
    }

    private List<sObject> retrieveColumnData(String customSettingName)
    {
        Map<String, Schema.SObjectType> mapSObjectNameToSObjects = Schema.getGlobalDescribe();
        Schema.SObjectType customSetting_ObjType = mapSObjectNameToSObjects.get(customSettingName);
        Schema.DescribeSObjectResult customSetting_DescribeResult = customSetting_ObjType.getDescribe();
        Map<String, Schema.SObjectField> mapCustomSettingFieldNameToFields = customSetting_DescribeResult.fields.getMap();

        String query = 'SELECT ';

        for(String fieldName : mapCustomSettingFieldNameToFields.keySet())
        {
            query = query + fieldName + ', ';
        }

        query = query.removeEnd(', ');
        query = query + ' FROM ' + customSettingName + ' WHERE Include_in_File__c = true ORDER BY Order__c ASC';

        List<sObject> lstColumnData = Database.query(query);

        return lstColumnData;
    }

    private List<sObject> retrieveChildData(String sObjectName, String parentRecordId, String parentReferenceField, List<sObject> lstColumnData)
    {
        String query = 'SELECT ';

        for(sObject objColumnData : lstColumnData)
        {
            query = query + (String)objColumnData.get('API_Name__c') + ', ';
            //3.0 Pick the relationship field to show as the hyperlink text in the excel file
            if(objColumnData.get('Data_Type__c')=='Lookup') {
                if(!String.isEmpty((String)objColumnData.get('Lookup_Field__c'))) {
                    query = query + (String)objColumnData.get('Lookup_Field__c') + ', ';
                }
            }
        }

        query = query.removeEnd(', ');
        query = query + ' FROM ' + sObjectName + ' WHERE ' + parentReferenceField + ' = \'' + parentRecordId + '\' ORDER BY Id ASC';

        List<sObject> lstChildData = Database.query(query);

        return lstChildData;
    }
}
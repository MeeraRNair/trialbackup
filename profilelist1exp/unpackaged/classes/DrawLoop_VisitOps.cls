/*
* Author  : Krishnakumar M
* Purpose : DrawLoop Data for VisitOps Functionality
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR16163      FY19-08-02 20-Jun-2018     Krishnakumar    Drawloop 02 - Create print menu selection and options
* 2.0      CR16163      FY19-10-02 06-Sep-2018     Krishnakumar    Fixing the Rich Text Issue
* 3.0      CR17344      FY20-0502  08-April-2019   Ekta            Participants need to be ordered alphabetically by last name.
* 4.0      CR17329      FY20-0502  03-April-2019   subramani       Show on Presenter Agenda” = True , Then Display the agenda session in Platinum Internal Template Agenda 
* 5.0      CR17350      FY20-0502  03-April-2019   subramani       Show on Customer Agenda” = True , Then Display the agenda session time, title , subtopics if any and discussion leader in Platinum External Agenda
* 6.0      CR17344      FY20-0502  27-May-2019     Elton           Added new Parent-Child Relationship for Agenda Session Date to Agenda Session
* 7.0      CR18091      FY20-1101  13-Sep-2019     Elton           Change condition for adding Agenda Session to output file.
 

*/
global class DrawLoop_VisitOps implements Loop.IApexDataSource{
  @testVisible
    private Static Final string VISIT_START_TIME = 'Apex_VisitTime';
    @testVisible
    private Static Final string ACCOUNT_NAMES = 'Apex_AccountName';
    @testVisible
    private Static Final string AGENDA_DATE = 'Apex_AgendaDate';
    @testVisible
    private Static Final string AGENDA_DETAILS = 'Apex_AgendaDetail';
    @testVisible
    private Static Final string ATTENDEE_DETAIL = 'Apex_AttendeeDetail';
    
   
    // query used for the 'ApexSoql' object
    private string strVisitSoqlQuery = 'SELECT id,VisitOps__ArrivalDateTimeLocationTZ__c FROM VisitOps__Visit__c WHERE id = :visitId';
    private string strCompanyQuery = 'SELECT id,VisitOps__Company_Name__c FROM VisitOps__Company__c WHERE VisitOps__Visit__c = :visitId';
    private string strAgendaChild1 = 'select  Id,Name,VisitOps__IsParked__c,VisitOps__Show_on_Presenter_Agenda__c,VisitOps__Agenda_Title__c,VisitOps__Start_Time__c,VisitOps__StartTimeLocationTZ__c,VisitOps__Objectives__c,VisitOps__Show_on_Customer_Agenda__c,VisitOps__Agenda_Subtopics__c,VisitOps__EndTimeLocationTZ__c,VisitOps__Topic__r.VisitOps__TopicName__c,(select Id,VisitOps__Presenter_name_formula__c,VisitOps__Title__c,VisitOps__Agenda__c from VisitOps__Presenter_Agenda_Links__r where VisitOps__Status__c=\'Accepted\') from VisitOps__Agenda__c where VisitOps__Visit__c=:visitId and VisitOps__IsParked__c=False order by VisitOps__Start_Time__c asc';   
    //CR17344 Participants need to be ordered alphabetically by last name.
    private string strAttendeeQuery = 'select id,VisitOps__Title__c,VisitOps__Name__c,VisitOps__Company__c,VisitOps__Attendee_Types__c,VisitOps__LastName__c from VisitOps__Attendee__c where VisitOps__Visit__c =:visitId order by VisitOps__Attendee_Types__c,VisitOps__Company__c,VisitOps__LastName__c';
    //private string presenterQuery = 'select Id,VisitOps__Presenter_name_formula__c,VisitOps__Title_formula__c,VisitOps__Agenda__c from VisitOps__Presenter_Agenda_Link__c where VisitOps__Status__c=\'Accepted\' and VisitOps__Agenda__c in (select id from VisitOps__Agenda__c where VisitOps__Visit__c=:visitId)';

    public Set<string> getGlobalDescribe() {
        // Return a set of object names that this Apex class will provide data for.
        // In this example, we will provide data from a single SOQL query.
        return new Set<string>{
            VISIT_START_TIME,
                ACCOUNT_NAMES,
                AGENDA_DETAILS,
                AGENDA_DATE,
                ATTENDEE_DETAIL            
                };
                    }
    
    public Set<string> getChildRelationships(string strObjectName) {
        // Return a set of object names corresponding to the children for the ObjectName specified 
        /*if (strObjectName == AGENDA_DETAILS) {
return new Set<string> {presenterDetail};
}     */
        //CR17344: Creating Parent Child relationship for Date to Agenda for Gold External Template
        if(strObjectName == AGENDA_DATE){
            return new Set<string> {AGENDA_DETAILS};
        }
        return new Set<string>();
    }

    public List<Loop.ExternalData.DataObject> describeObjects(List<string> listObjectName) {
      // Declare the variable to be returned.
        List<Loop.ExternalData.DataObject> listDescribeObjectResults  = new List<Loop.ExternalData.DataObject>();

        for(string strObjectName : listObjectName){
          List<Loop.ExternalData.FieldInfo> listFields = new List<Loop.ExternalData.FieldInfo>();
          if (strObjectName == VISIT_START_TIME) {
             listFields.add(new Loop.ExternalData.FieldInfo('VisitOps__ArrivalDateTimeLocationTZ__c', Schema.DisplayType.String));                
          }else if(strObjectName == ACCOUNT_NAMES){
            listFields.add(new Loop.ExternalData.FieldInfo('AccName', Schema.DisplayType.String));
          }
          //CR17344:Creating Parent Child relationship for Date to Agenda for Gold External Template
          else if(strObjectName == AGENDA_DATE){
                listFields.add(new Loop.ExternalData.FieldInfo('Id', Schema.DisplayType.ID));
                listFields.add(new Loop.ExternalData.FieldInfo('FullDate', Schema.DisplayType.String));
                listFields.add(new Loop.ExternalData.FieldInfo('StartDate', Schema.DisplayType.Date));
                listFields.add(new Loop.ExternalData.FieldInfo('InitialDate', Schema.DisplayType.Date));
          }else if(strObjectName == AGENDA_DETAILS){
            //listFields.add(new Loop.ExternalData.FieldInfo('BreakTable', Schema.DisplayType.String)); 
            //CR17344:Creating Parent Child relationship for Date to Agenda for Gold External Template 
            Loop.ExternalData.FieldInfo referenceField = new Loop.ExternalData.FieldInfo('ParentId', Schema.DisplayType.REFERENCE);
                referenceField.referenceTo = AGENDA_DATE; 
                listFields.add(referenceField);
            listFields.add(new Loop.ExternalData.FieldInfo('StartDate', Schema.DisplayType.Date));          
            listFields.add(new Loop.ExternalData.FieldInfo('FullDate', Schema.DisplayType.String));
            listFields.add(new Loop.ExternalData.FieldInfo('StartTime', Schema.DisplayType.String));
            listFields.add(new Loop.ExternalData.FieldInfo('EndTime', Schema.DisplayType.String));
            listFields.add(new Loop.ExternalData.FieldInfo('Topic', Schema.DisplayType.String));
            listFields.add(new Loop.ExternalData.FieldInfo('Title', Schema.DisplayType.String));
            listFields.add(new Loop.ExternalData.FieldInfo('Agenda', Schema.DisplayType.ID));
             
            //2.0 Start
            Loop.ExternalData.FieldInfo subTopField = new Loop.ExternalData.FieldInfo('Subtopic', Schema.DisplayType.TextArea);
            subTopField.isHtmlFormatted = true;
            listFields.add(subTopField);    
            Loop.ExternalData.FieldInfo objectiveField = new Loop.ExternalData.FieldInfo('Objectives', Schema.DisplayType.TextArea);
            objectiveField.isHtmlFormatted = true;
            listFields.add(objectiveField);  
            Loop.ExternalData.FieldInfo presenterField = new Loop.ExternalData.FieldInfo('Presenter', Schema.DisplayType.TextArea);
            presenterField.isHtmlFormatted = true;
            listFields.add(presenterField);            
            //2.0 End
            //listFields.add(new Loop.ExternalData.FieldInfo('PresenterTitle', Schema.DisplayType.String));

          }else if(strObjectName == ATTENDEE_DETAIL){
            listFields.add(new Loop.ExternalData.FieldInfo('Name', Schema.DisplayType.String));          
            listFields.add(new Loop.ExternalData.FieldInfo('title', Schema.DisplayType.String));
            listFields.add(new Loop.ExternalData.FieldInfo('company', Schema.DisplayType.String));
          }/*else if(strObjectName == presenterDetail){
            listFields.add(new Loop.ExternalData.FieldInfo('Name', Schema.DisplayType.String));          
            listFields.add(new Loop.ExternalData.FieldInfo('title', Schema.DisplayType.String));
            Loop.ExternalData.FieldInfo presenterField = new Loop.ExternalData.FieldInfo('Agenda', Schema.DisplayType.ID);
            presenterField.referenceTo = AGENDA_DETAILS;
            listFields.add(presenterField); 
          }*/
         // Add to results list
          listDescribeObjectResults.add(new Loop.ExternalData.DataObject(strObjectName, listFields));
        }
      return listDescribeObjectResults;
    }

    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        system.debug('request info============'+requestInfo);
        Map<String,String> mapDates = new map<String,String>(); 
        Id visitId = requestInfo.RecordId;
        Id ddpId=requestInfo.DDPId;
        Loop__DDP__c ddpName=[select id,Loop__Output_Filename__c from Loop__DDP__c where id=:ddpId];
        system.debug('id======'+ddpName);
        // Declare the variable to be returned.
        Loop.ExternalData.QueryResultSet queryResultSet = new Loop.ExternalData.QueryResultSet();
        try{
        // Loop through all objects requested. The QueryResultSet instance returned needs to contain a QueryResult instance for each object requested.
        for (string strObjectName : requestInfo.GetObjectNames()) {
          // Declare listFields list for QueryResult instance
            List<string> listFields = new List<string>();
          // Declare query result to add to QueryResultSet instance
            Loop.ExternalData.QueryResult queryResult = null;
            // set up fields list to get data for QueryResult instance
            if (strObjectName == VISIT_START_TIME) {
                listFields = new List<string>{ 'VisitOps__ArrivalDateTimeLocationTZ__c'};
                
                // Since we added fields to the list, update the QueryResult instance
                queryResult = new Loop.ExternalData.QueryResult(strObjectName, listFields);
                for (SObject record : Database.query(strVisitSoqlQuery)) {
                    // Store the values (as strings) from the record in the same order of the fields defined in the QueryResult instance
                    List<string> listRecordValues = new List<string>();
                    for (string strField : listFields) {
                      system.debug('Start time---'+record.get(strField));
                      Datetime dtVisitTimeStr = Datetime.valueOf(String.valueOf(record.get(strField)));//.format('MMMM dd, YYYY');
                        listRecordValues.add(dtVisitTimeStr.format('MMMM dd, YYYY'));
                    }
                    //system.debug('Values from the query'+listRecordValues);
                    // Add the values to the QueryResult instance rows
                    queryResult.rows.add(listRecordValues);
                    
                }
            }else if(strObjectName == ACCOUNT_NAMES){
              listFields = new List<string>{ 'AccName'};
              List<string> listRecordValues = new List<string>();
              String strAccName ='';
              // Since we added fields to the list, update the QueryResult instance
                queryResult = new Loop.ExternalData.QueryResult(strObjectName, listFields);
                for (SObject record : Database.query(strCompanyQuery)) {
                  for (string strField : listFields) {
                    if(strAccName == ''){
                        strAccName =  String.valueOf(record.get('VisitOps__Company_Name__c'));
                      }else{
                        strAccName = strAccName +', '+ String.valueOf(record.get('VisitOps__Company_Name__c'));
                      }
                  }
                }
                listRecordValues.add(strAccName);
                queryResult.rows.add(listRecordValues);
                }
            //CR17344: Creating Parent Child relationship for Date to Agenda for Gold External Template
            else if(strObjectName == AGENDA_DATE){  
                    listFields = new List<string>{'Id','FullDate','StartDate','InitialDate'};
                    Integer intRowCount = 0;
                    String strInitialDate = '';
                    Set<String> setDate = new Set<String>();
                    queryResult = new Loop.ExternalData.QueryResult(strObjectName, listFields);
                    for(VisitOps__Agenda__c objAgen:Database.query(strAgendaChild1)){
                        List<String> listAgDate = new List<String>();  
                        //4.0 start
                        String strAgendaDate1 = (DateTime.valueOf(objAgen.VisitOps__StartTimeLocationTZ__c)).format('MMMM d, YYYY');         
                        //7.0 Change condition for adding Agenda Session to output file.
                        if(((ddpName.Loop__Output_Filename__c.contains('Internal') && objAgen.VisitOps__Show_on_Presenter_Agenda__c==True) || (ddpName.Loop__Output_Filename__c.contains('External') && objAgen.VisitOps__Show_on_Customer_Agenda__c==True)) && !setDate.contains(strAgendaDate1)){ 
                            //ID
                            listAgDate.add(''+intRowCount);
                            mapDates.put(''+Date.valueOf(objAgen.VisitOps__StartTimeLocationTZ__c),''+intRowCount);
                            //FullDate
                            setDate.add(strAgendaDate1);
                            listAgDate.add(strAgendaDate1);
                            system.debug('Start time---strAgendaDate1 >> '+strAgendaDate1);
                            //StartDate
                            listAgDate.add(''+Date.valueOf(objAgen.VisitOps__StartTimeLocationTZ__c)); 
                            //Initial Date
                            if(intRowCount==0){
                                strInitialDate = ''+Date.valueOf(objAgen.VisitOps__StartTimeLocationTZ__c);
                            }
                            listAgDate.add(strInitialDate);
                            intRowCount++;
                            System.debug(listAgDate);
                            queryResult.rows.add(listAgDate);
                        }
                    }
            }else if(strObjectName == AGENDA_DETAILS){  
              listFields = new List<string>{'ParentId','StartDate','FullDate','StartTime','EndTime','Topic','Title','Agenda','Subtopic','Objectives','Presenter'};
              String strDateBkUp = '';  
              String strTitle = ''; 
              String strObjective = ''; 
              Integer intRowCount = 0;            
              queryResult = new Loop.ExternalData.QueryResult(strObjectName, listFields);
              for(VisitOps__Agenda__c objAgen:Database.query(strAgendaChild1)){
                 List<String> listAgDate = new List<String>();  
                 //4.0 start
                 //7.0 Change condition for adding Agenda Session to output file.
                 if((ddpName.Loop__Output_Filename__c.contains('Internal') && objAgen.VisitOps__Show_on_Presenter_Agenda__c==True) || (ddpName.Loop__Output_Filename__c.contains('External') && objAgen.VisitOps__Show_on_Customer_Agenda__c==True)){
               system.debug('inside for loop=====');
               //4.0 end
              // queryResult.rows.add(listAgDate);
             // List<String> listAgDate = new List<String>();  
               String strPresLnk = '';
               //ParentId
               listAgDate.add(mapDates.get(''+Date.valueOf(objAgen.VisitOps__StartTimeLocationTZ__c)));
               //StartDate
               listAgDate.add(''+Date.valueOf(objAgen.VisitOps__StartTimeLocationTZ__c)); 
               //FullDate
               String strAgendaDate1 = (DateTime.valueOf(objAgen.VisitOps__StartTimeLocationTZ__c)).format('MMMM d, YYYY');         
               listAgDate.add(strAgendaDate1);
               system.debug('Start time---strAgendaDate1 >> '+strAgendaDate1);
               //StartTime 
               DateTime dtAgendaDate2 = DateTime.valueOf(objAgen.VisitOps__StartTimeLocationTZ__c);
              // listAgDate.add(dtAgendaDate2.format('h:mm a'));
              // CR17344  Update AM PM in lower case 
              String str =  dtAgendaDate2.format('h:mm a');
              listAgDate.add(str.replace('AM', 'a.m.').replace('PM','p.m.'));
               system.debug('Start time---dtAgendaDate2 >> '+dtAgendaDate2.format('h:mm a'));
               system.debug('Start time---agendaDate >> '+str.replace('AM', 'am').replace('PM','pm'));
               //EndTime
               DateTime dtAgendaDate3 = DateTime.valueOf(objAgen.VisitOps__EndTimeLocationTZ__c);
               listAgDate.add(dtAgendaDate3.format('h:mm a'));
               system.debug('Start time---dtAgendaDate3 >> '+dtAgendaDate3.format('h:mm a'));
               //Topic
               listAgDate.add(objAgen.VisitOps__Topic__r.VisitOps__TopicName__c);
               //Title
               listAgDate.add(objAgen.VisitOps__Agenda_Title__c);
               //ID
               listAgDate.add(objAgen.id); 
               //Subtopic
               strTitle = objAgen.VisitOps__Agenda_Subtopics__c;
               listAgDate.add(strTitle); 
               //Objectives
               strObjective = objAgen.VisitOps__Objectives__c; 
               listAgDate.add(strObjective); 
               //listAgDate.add('Test Presetner');
               for(VisitOps__Presenter_Agenda_Link__c objPresLnk:objAgen.VisitOps__Presenter_Agenda_Links__r){
               
                 if(strPresLnk == ''){
                   strPresLnk = '<b>'+objPresLnk.VisitOps__Presenter_name_formula__c+'</b><br/>'+((objPresLnk.VisitOps__Title__c == null)?'':'<i style="font-size:0.9rem">'+objPresLnk.VisitOps__Title__c+'</i><br/>');
                 }else{
                   strPresLnk = strPresLnk +'<br/><b>'+objPresLnk.VisitOps__Presenter_name_formula__c+'</b><br/>'+((objPresLnk.VisitOps__Title__c==null)?'':'<i style="font-size:0.9rem">'+objPresLnk.VisitOps__Title__c+'</i><br/>');
                 }             
                }
                 
               if(strPresLnk!= ''){
                 listAgDate.add(strPresLnk);
                 }else{
                   listAgDate.add(' ');
                 }
                 intRowCount++;
               queryResult.rows.add(listAgDate);
             }
             }
               //System.debug('888888---'+queryResult.rows);
               //rows.add(listAgDate);               
            } else if(strObjectName == ATTENDEE_DETAIL){
              listFields = new List<string>{ 'Name','title','company'};
              //List<string> recordValues = new List<string>();
              List<string> listCustomer = new List<string>();
              List<string> listPartner = new List<string>();
              List<string> listOther = new List<string>();
              List<string> listEmp = new List<string>();
              queryResult = new Loop.ExternalData.QueryResult(strObjectName, listFields);
              for(VisitOps__Attendee__c objAtten:Database.query(strAttendeeQuery)){
               if(objAtten.VisitOps__Attendee_Types__c =='Customer'){
                 listCustomer.add((objAtten.VisitOps__Name__c == null)?'':objAtten.VisitOps__Name__c);
                 listCustomer.add((objAtten.VisitOps__Title__c == null)?'':objAtten.VisitOps__Title__c);
                 listCustomer.add((objAtten.VisitOps__Company__c == null)?'':objAtten.VisitOps__Company__c);
               }else if(objAtten.VisitOps__Attendee_Types__c=='Partner'){
                 listPartner.add((objAtten.VisitOps__Name__c == null)?'':objAtten.VisitOps__Name__c);
                 listPartner.add((objAtten.VisitOps__Title__c == null)?'':objAtten.VisitOps__Title__c);
                 listPartner.add((objAtten.VisitOps__Company__c == null)?'':objAtten.VisitOps__Company__c);
               }else if(objAtten.VisitOps__Attendee_Types__c =='Other'){
                 listOther.add((objAtten.VisitOps__Name__c == null)?'':objAtten.VisitOps__Name__c);
                 listOther.add((objAtten.VisitOps__Title__c == null)?'':objAtten.VisitOps__Title__c);
                 listOther.add((objAtten.VisitOps__Company__c == null)?'':objAtten.VisitOps__Company__c);
               }else if(objAtten.VisitOps__Attendee_Types__c=='Employee'){
                 listEmp.add((objAtten.VisitOps__Name__c == null)?'':objAtten.VisitOps__Name__c);
                 listEmp.add((objAtten.VisitOps__Title__c == null)?'':objAtten.VisitOps__Title__c);
                 listEmp.add((objAtten.VisitOps__Company__c == null)?'':objAtten.VisitOps__Company__c);
               }
              }
               List<string> listRecordValues = null;
               for(Integer intX=0;intX<listCustomer.size();intX++){
                 if(intX==0 || Math.mod(intX,3) == 0)
                 {
                   listRecordValues = new List<string>();
                   }
                 listRecordValues.add(listCustomer.get(intX));
                 
                 if(Math.mod(intX,3) == 0){
                   queryResult.rows.add(listRecordValues);
                 }
               } 
               for(Integer intX=0;intX<listPartner.size();intX++){
                 if(intX==0 || Math.mod(intX,3) == 0)
                 {
                   listRecordValues = new List<string>();
                   }
                 listRecordValues.add(listPartner.get(intX));
                 
                 if(Math.mod(intX,3) == 0){
                   queryResult.rows.add(listRecordValues);
                 }
               } 
               for(Integer intX=0;intX<listOther.size();intX++){
                 if(intX==0 || Math.mod(intX,3) == 0)
                 {
                   listRecordValues = new List<string>();
                   }
                 listRecordValues.add(listOther.get(intX));
                 if(Math.mod(intX,3) == 0){
                   queryResult.rows.add(listRecordValues);
                 }
               } 
               for(Integer intX=0;intX<listEmp.size();intX++){
                 if(intX==0 || Math.mod(intX,3) == 0)
                 {
                   listRecordValues = new List<string>();
                   }
                 listRecordValues.add(listEmp.get(intX));
                 if(Math.mod(intX,3) == 0){
                   queryResult.rows.add(listRecordValues);
                 }
               }                              
               //System.debug('999999---'+queryResult.rows);
            }/* else if(strObjectName == presenterDetail){
              try{
                listFields = new List<string>{ 'Name','title','Agenda'};
                queryResult = new Loop.ExternalData.QueryResult(strObjectName, listFields);
                System.debug('****Calling presenter detail...');
                for(VisitOps__Presenter_Agenda_Link__c objPres:Database.query(presenterQuery)){
                  List<string> listRecordValues = new List<string>();

                  listRecordValues.add(String.valueOf(objPres.get('VisitOps__Presenter_name_formula__c')));
                  listRecordValues.add(String.valueOf(objPres.get('VisitOps__Title_formula__c')));
                  listRecordValues.add(String.valueOf(objPres.get('VisitOps__Agenda__c')));
                  queryResult.rows.add(listRecordValues);
                }
                System.debug('****Calling presenter detail...'+queryResult.rows);
              }catch(Exception ex){
                ex.getStackTraceString();
              }              
            }*/    
            
            // Add the QueryResult instance to the QueryResultSet instance
            // This needs to be done for every object specified in requestInfo.GetObjectNames(), regardless of whether data is required for the request.
            queryResultSet.add(queryResult);
        }
        }catch(Exception ex){
          system.debug('Error--'+ex.getStackTraceString());
          system.debug('Error--'+ex.getMessage());
          system.debug('Error--'+ex.getLineNumber());

        }
      return queryResultSet;

    }
}
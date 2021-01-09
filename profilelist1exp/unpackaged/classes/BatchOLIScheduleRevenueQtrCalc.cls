/*
* Author  : Harsha Chadalavada
* Purpose : To display Account Revenue Trends Information.
* 
* Revision   CR Number     Release No  Date            Modified By     Description
* --------   ---------     ----------  -----------     ------------    -----------
*  1.0       CR16316       FY19-0902   6-Aug-2018     Harsha          Created class to calculate revenue from OpportunityLineItemSchedule
*/

global class BatchOLIScheduleRevenueQtrCalc implements Database.Batchable<sObject>, Database.Stateful {
	
    /* Use the customized query from custom metadata "Schedule Revenue Batch Setting"  */
    
    public string OLIids; // Pass opportunityLineItem Id's as "('00k0m000003qSAf','00k0m000003iSAf','00k0m000003kSAf')"
    Public string sBookDateFromPast; 
    private static final Integer MAX_ATTEMPTS = 2;
    public boolean bRerunFailedRecords;
    public string query;
    public boolean bIgnoreAllClosedOppty;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Schedule_Revenue_Batch_Setting__mdt srbs = [select id,RerunFailedRecords__c,BookDateFromPast__c,IgnoreAllClosedOppty__c from Schedule_Revenue_Batch_Setting__mdt limit 1];
        dateTime bookDate = ((srbs.BookDateFromPast__c != Null)? srbs.BookDateFromPast__c : Null);
        bRerunFailedRecords = srbs.RerunFailedRecords__c;
        bIgnoreAllClosedOppty = srbs.IgnoreAllClosedOppty__c;
        if(query == Null){
            query = 'SELECT id,Scheduled_Current_Qrt_Rev__c,Scheduled_Next_Qrt_Rev__c,HasRevenueSchedule '+
                'FROM opportunityLineItem '+
                'WHERE (HasRevenueSchedule = true) ';
        }
        if(bIgnoreAllClosedOppty){
            query+= 'AND (opportunity.isclosed = false) ';
        }
        if(bookDate != Null){
            sBookDateFromPast = bookDate.format('yyyy-MM-dd');
            query+= 'AND (opportunity.CloseDate >='+sBookDateFromPast+') AND (opportunity.stageName != \'Lost, Cancelled - 0%\') ';
        }
        if(OLIids!= Null){
            query+= 'AND (id in '+OLIids+') ';
        }
        system.debug('----query-----'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){       
        set<id> oliAllIds = new set<id>();
        list<opportunitylineitem> oliList = (list<opportunitylineitem>)scope;
        for(opportunitylineitem oli : oliList){
            oliAllIds.add(oli.Id);
        }        
        list<opportunitylineitem> oliUpdate = OLIScheduleRevenueQtrCalcHelper.updateSchRev(oliAllIds);
        if(Test.isRunningTest()){
            oliUpdate[0].S_P_Deal_Status__c = 'Rejected';
        }
        map<id, opportunitylineitem> oliUpdateSchRevMap = new map<id, opportunitylineitem>(oliUpdate);
        if(!oliUpdate.isempty()){
            try{
                integer iRetry=1;
                integer iRetry_dup=1;
                TriggerExecutionController.setSkipAllTriggers(true);
                Database.SaveResult[] lsrOLI;
                while(iRetry<=MAX_ATTEMPTS){
                    boolean bUpdateFail = false;
                    lsrOLI = Database.update(oliUpdate, false);
                    iRetry=3;
                    if(bRerunFailedRecords){
                        list<opportunitylineitem> oliFailedRec = new list<opportunitylineitem>();
                        for(integer i=0;i<lsrOLI.size();i++){
                            if (!lsrOLI.get(i).isSuccess()) {
                                bUpdateFail = true;
                                oliFailedRec.add(oliUpdateSchRevMap.get(oliUpdate.get(i).id));
                            }
                        }
                        if(bUpdateFail && (iRetry_dup<4)){
                            ++iRetry_dup;
                            iRetry = iRetry_dup;
                            oliUpdate.clear();
                            oliUpdate.addall(oliFailedRec);
                        }
                    }
                }
                TriggerExecutionController.setSkipAllTriggers(false);
                list<Exception__c> excpList = new list<Exception__c>();
                for(integer i=0;i<lsrOLI.size();i++){
                    if (!lsrOLI.get(i).isSuccess()) { 
                        System.debug('###DEBUG### BatchOLIScheduleRevQtrCalc update error - ' + lsrOLI.get(i).getID() + ' -- '+ lsrOLI.get(i));
                        system.debug('error record ID----'+oliUpdate.get(i).id);
                        /*Database.Error objError = lsrOLI[i].getErrors().get(0);
                        system.debug('objError----'+objError);
                    	string strErrMsg = objError.getMessage().left(240);
                        string strStatusCode = string.valueof(objError.getStatusCode()).left(240);
                        excpList.add(new Exception__c(Error_Messages__c='-Update failed-'+strErrMsg,
                                                     Object_type__c='OpportunityLineItem',
                                                     Operation__c='Update', Process_Name__c='BatchOLIScheduleRevQtrCalc',
                                                     Notes__c='BatchOLIScheduleRevQtrCalc class - updatefailed - '+lsrOLI.get(i),
                                                     Object_ID__c=oliUpdate.get(i).id,
                                                     Error_Codes__c=strStatusCode));
                        //failedOLIids.add(oliUpdate.get(i).id);*/
                    }
                }
                /*if(!excpList.isEmpty()){
                    Database.SaveResult[] lsrExcp = Database.insert(excpList, false);
                    //reRunBatchClass = true;
                	system.debug('*****Harsha****excpList : '+excpList);
                	system.debug('*****Harsha****lsrExcp : '+lsrExcp);
                   // bExceptionExist = true;
                                        
                }*/
                
            }
            catch(exception e){
                System.debug('###DEBUG### BatchOLIScheduleRevQtrCalc exception error - ' +e);
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('------BatchOLIScheduleRevQtrCalc---- FINSH METHOD-----');
        map<string, date> qtrsMap = OLIScheduleRevenueQtrCalcHelper.getFiscalQtrs();
        date nextQtrstart = qtrsMap.get('nextQtrStart');
        integer iDay = nextQtrstart.day()+2; //to start on Monday.
        integer iMonth = nextQtrstart.month();
        integer iYear = nextQtrstart.year();
        string cronTrg = '0 0 9 '+iDay+' '+iMonth+' ? '+iYear;
        BatchOLIScheduleRevenueQtrCalc_Scheduler g = new BatchOLIScheduleRevenueQtrCalc_Scheduler();
		system.schedule('BatchOLIScheduleRevenueQtrCalc_Scheduler'+system.now(), cronTrg, g);
       
    }
}
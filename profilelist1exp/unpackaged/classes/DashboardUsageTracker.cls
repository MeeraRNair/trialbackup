/***********************************************************
* Name          : DashboardUsageTracker
* Description   : Scheduler class runs every 1 hour
* Test Class    : DashboardUsageTrackerTest

History:
Version     Date            Modified By     CR          Description     
--------------------------------------------------------------------------------------
1.0         25-Oct-2016     Krishna         13635       Scheduler class Runs every hour and pick the refreshed dashboards
*/


global class DashboardUsageTracker implements Schedulable{
    
    public static String CRON_EXP = '0 0 * * * ?';
    
    global void execute(SchedulableContext ctx){
        try{
            Map<ID,Dashboard_Tracker__c> dashTrackMap = new Map<id,Dashboard_Tracker__c>();
            for(Dashboard_Tracker__c trackObj:[select id,name,Dashboard_ID__c,ReportIds__c  from Dashboard_Tracker__c]){
                dashTrackMap.put(trackObj.Dashboard_ID__c, trackObj);
            }
            system.debug('Dashboard Tracker Map --'+dashTrackMap.keySet());
            Map<Id,DateTime> refreshedTimeMap = new Map<ID,DateTime>();
            Set<ID> refreshDash = filterDashboard(dashTrackMap,refreshedTimeMap);
            if(!refreshDash.isEmpty()){
                InsertTrackerRec(refreshDash,refreshedTimeMap);
            }
        }catch(Exception ex){
            System.debug(''+ex.getStackTraceString());
            System.debug(''+ex.getMessage());
            Exception__c execRec =  new Exception__c( Error_Messages__c = ex.getMessage(),Object_type__c='Dashboard', Process_Name__c='DashboardUsageTracker');
            insert execRec;
        }        
    }
    
    private Set<ID> filterDashboard(Map<ID,Dashboard_Tracker__c> dashTrackMap,Map<Id,DateTime> refreshedTimeMap){
        Dashboard_Tracker__c dashTrackObj = null;
        Datetime lastHourModifiedRec = System.now().addhours(-1);
        List<ID> reportIDList = new List<ID>();
        List<Report> reportList = new List<Report>();
        Set<ID> dashRefreshed = new Set<ID>();
        Report reportObj;
        Report reportObj1;
        Report reportObj2;
        String reportRefresh;
        String reportRefresh1;
        String reportRefresh2;
        
        for(ID dashObj:dashTrackMap.keySet()){
            dashTrackObj = dashTrackMap.get(dashObj);
            reportIDList = dashTrackObj.ReportIds__c.split(',');
            System.debug('$$$Dashboard Name---'+dashTrackObj.name);
            reportList = [select id,name,lastrundate from Report where id IN :reportIDList and lastrundate > :lastHourModifiedRec and lastrundate != null order by lastrundate desc];
            for(Integer x=0;x<reportList.size();x++){
                //Comparing 3 Report record's last run date.
                reportObj = reportList.get(x);
                reportRefresh = reportObj.lastrundate.format('HH:mm');
                if((x+1) < reportList.size()){
                    reportObj1 = reportList.get(x+1);
                    reportRefresh1 = reportObj.lastrundate.format('HH:mm');
                }
                if((x+2) < reportList.size()){
                    reportObj2 = reportList.get(x+2);
                    reportRefresh2 = reportObj.lastrundate.format('HH:mm');
                }                       
                
                system.debug(reportRefresh+' == '+reportRefresh1+ ' ' + reportRefresh2);
                if((reportRefresh!=null && reportRefresh1 != null && reportRefresh.equals(reportRefresh1)) || 
                   (reportRefresh!=null && reportRefresh2 != null && reportRefresh.equals(reportRefresh2))){
                       dashRefreshed.add(dashObj);
                       refreshedTimeMap.put(dashObj, reportObj.lastrundate);
                   }
            }
        }       
        return dashRefreshed;
    }
    
    private void InsertTrackerRec(Set<ID> dashboardMod,Map<Id,DateTime> refreshedTimeMap){
        SF1_Adoption__c trackerObj;
        try{
            List<SF1_Adoption__c> trackerList = new List<SF1_Adoption__c>(); 
            
            for(Dashboard dash:[select id,DeveloperName,Type,RunningUserId,LastViewedDate,LastReferencedDate from dashboard where id in :dashboardMod]){
                System.debug('Dashboard Executed--'+dash.DeveloperName);
                trackerObj = new SF1_Adoption__c();
                trackerObj.Object_Name__c = 'Dashboard';
                trackerObj.Source__c = 'DashboardUsageTracker';
                trackerObj.User_Action__c = '';
                trackerObj.User_Edited_Date__c = Datetime.now();
                trackerObj.Dashboard_ID__c = dash.id;
                trackerObj.Dashboard_name__c = dash.DeveloperName;
                trackerObj.User_Name__c = dash.RunningUserId;
                trackerObj.Record_ID__c = dash.id;
                //trackerObj.User_Name__c = UserInfo.getUserId();
                trackerObj.Last_Refreshed_Date__c = refreshedTimeMap.get(dash.id);
                trackerList.add(trackerObj);
            }
            if(!trackerList.isEmpty()){
                List<Exception__c> failedRecords = new List<Exception__c>();
                List<Database.SaveResult> result = Database.insert(trackerList);
                for(Integer i=0;i<result.size();i++){
                    if (!result.get(i).isSuccess()){
                        Database.Error ex = result.get(i).getErrors().get(0); 
                        Exception__c execRec =  new Exception__c( Error_Messages__c = ex.getMessage(),Object_type__c='Dashboard',Object_ID__c= null, Process_Name__c='DashboardUsageTracker-'+trackerList.get(i).Dashboard_name__c);
                        failedRecords.add(execRec);
                    }
                }
                if(!failedRecords.isEmpty()){
                    insert failedRecords;
                }
            }  
        }catch(Exception ex){
            system.debug('Exception Occured...'+ex.getMessage());
            Exception__c execRec =  new Exception__c( Error_Messages__c = ex.getMessage(),Object_type__c='Dashboard',Object_ID__c= trackerObj.Id, Process_Name__c='DashboardUsageTracker');
            insert execRec;
        }
    }
}
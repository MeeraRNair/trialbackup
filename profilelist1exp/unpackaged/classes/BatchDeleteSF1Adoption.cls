/*********************************************************************************************
Author: Emily Chiong

History:
Revision CR Number   Release No      Date            Modified By     Description
----------------------------------------------------------------------------------------------
1.0      CR13165     FY17-DCS-0701   26-May-2016     Emily           Batch job to delete Mobile records older than 90 days or created by test users

**********************************************************************************************/

global class BatchDeleteSF1Adoption implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<SF1_Adoption__c> listAdoptionToDel = new List<SF1_Adoption__c>();
    public String strQuery;
    public Boolean bReRun;
    
    global database.querylocator start(Database.BatchableContext BC){
        system.debug('###DEBUG### '+Database.getQueryLocator(strQuery));
        system.debug('###DEBUG### strQuery：'+strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject obj: scope){
            SF1_Adoption__c Adoptions = (SF1_Adoption__c)obj;
            
            listAdoptionToDel.add(Adoptions);            
        }
        
        system.debug('###DEBUG### listAdoptionToDel: '+listAdoptionToDel); 
        
        if(listAdoptionToDel.size() > 0){
            Database.DeleteResult[] resultList = Database.delete(listAdoptionToDel,false);
        }    
    }    
    
    global void finish(Database.BatchableContext info){  
        
        system.debug('###DEBUG### bReRun: '+bReRun); 
        
        if(bReRun){
            system.debug('###DEBUG### ReRun');
            
            String strSeconds, strMinutes, strHours, strDayOfMonth, strMonth, strDayOfWeek, strYear, strSchTime;
            
            datetime dtSysTime = system.now();      
            datetime dtSysTimeAddOneMin = dtSysTime.addMinutes(1); 
            
            strSeconds = string.valueOf(dtSysTimeAddOneMin.second());
            strMinutes = string.valueOf(dtSysTimeAddOneMin.minute()); 
            strHours = string.valueOf(dtSysTimeAddOneMin.hour());      
            strDayOfMonth = string.valueOf(dtSysTimeAddOneMin.day());
            strMonth = string.valueOf(dtSysTimeAddOneMin.month());
            strDayOfWeek = '?';
            strYear = string.valueOf(dtSysTimeAddOneMin.year()); 
            strSchTime = strSeconds + ' ' + strMinutes + ' ' + strHours + ' ' + strDayOfMonth + ' ' + strMonth + ' ' + strDayOfWeek + ' ' + strYear;
            
            system.debug('###DEBUG### dtSysTimeAddOneMin: '+dtSysTimeAddOneMin);
            system.debug('###DEBUG### strSchTime: '+strSchTime);           
            
            BatchDeleteSF1AdoptionScheduler u = new BatchDeleteSF1AdoptionScheduler();            
            u.strSQL = strQuery;          
            system.debug('###DEBUG### strQuery: ' + strQuery);
            system.schedule('BatchDeleteSF1Adoption' + string.valueof(dtSysTimeAddOneMin), strSchTime, u);
        }    
    }  
}
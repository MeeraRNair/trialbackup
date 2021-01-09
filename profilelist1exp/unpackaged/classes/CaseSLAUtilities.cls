/* 
 * Author           : Bharadwaj
 * Purpose          : SLA Metrics
 * Created Date     : 18-Dec-2017
 * User Story:6558912:30-May-2019 Code modified for Assigned condition by Dasari,SaiKrishna
 */ 

public class CaseSLAUtilities {        
    
  public static void updateCaseHistory(list<Case> lstNewCases, map<Id, Case> mapOldCases) {
            
      List<Case_Status_History__c> CaseStatUpdtList = new List<Case_Status_History__c>();
      List<Case_Status_History__c> CaseStatInsrList = new List<Case_Status_History__c>();
      
      Set<ID> ids = mapOldCases.keySet(); 
      
      List<Case> caseList = 
          [Select Id,(SELECT id,Status__c,Time_In__c,Time_Out__c,Case_Id__c FROM Case_Status_Histories__r  where Time_Out__c = null order by createddate desc limit 1)
            FROM Case Where Id in :ids ];
      
      map<Id, Case_Status_History__c> caseHistMap = new map<Id, Case_Status_History__c>();
      
      for(Case caseObj : caseList){          
            for(Case_Status_History__c caseHist: caseObj.Case_Status_Histories__r ){
                caseHistMap.put(caseObj.Id, caseHist);
            }
        }       

      if(caseHistMap.size()>0)
            {  
        for(Case newCase : lstNewCases) {            
            Case oldCase = mapOldCases.get(newCase.Id);              
            
            Case_Status_History__c newCaseHistInsrt  = new Case_Status_History__c ();
            Case_Status_History__c newCaseHistUpdt  = new Case_Status_History__c ();
            //6558912 Story Changes
            //if((oldCase.Status <>'Assigned' && newCase.Status == 'Assigned'))
            if((oldCase.Status <>'Assigned' && newCase.Status == 'Assigned')||(oldCase.OwnerId <> newCase.OwnerId && string.valueOf(oldCase.OwnerId).startsWith('005') && string.valueOf(NewCase.OwnerId).startsWith('00G') && oldCase.Status =='Open' && oldCase.Status <>'Re-Open' && newCase.Status <>'Re-Open'))
            {              
              
                    // to update the old record     
                    if(caseHistMap.containsKey(newcase.id))
                    {                   
                    newCaseHistUpdt=   caseHistMap.get(newcase.id);                
                    //map_caseid_history.get(newcase.id);
                     newCaseHistUpdt.Time_Out__c=system.now(); 
                     DateTime dtOut = system.now();
                     DateTime dtIn = newCaseHistUpdt.Time_In__c;                        
                     newCaseHistUpdt.Duration__c= (dtOut.getTime() - dtIn.getTime() ) / 60000; 
                     CaseStatUpdtList.add(newCaseHistUpdt);               
              
                    // to insert new record
                    newCaseHistInsrt.case__c   =newCase.Id;                                             
                    newCaseHistInsrt.case_id__c=newCase.Id;
                    newCaseHistInsrt.Status__c='Assigned';
                    newCaseHistInsrt.Time_In__c= system.now();
                    CaseStatInsrList.add(newCaseHistInsrt);
                    }
                
            }  
            else if( ((oldCase.Status <>'In Progress' && newCase.Status == 'In Progress') && (oldCase.Status <>'Assigned')) 
                      ||  ( oldCase.OwnerId <> newCase.OwnerId && string.valueOf(oldCase.OwnerId).startsWith('00G')  )    // (oldCase.Status <>'In Progress' && newCase.Status == 'In Progress') &&
                 )
            {                 
                    
                    
                // to update the old record
                if(caseHistMap.containsKey(newcase.id))
                    {
                     newCaseHistUpdt=   caseHistMap.get(newcase.id);
                         //map_caseid_history.get(newcase.id);
                     newCaseHistUpdt.Time_Out__c=system.now();
                     DateTime dtOut = system.now();
                     DateTime dtIn = newCaseHistUpdt.Time_In__c;                        
                     newCaseHistUpdt.Duration__c= (dtOut.getTime() - dtIn.getTime() ) / 60000; 
                     CaseStatUpdtList.add(newCaseHistUpdt);                
                   
                    // to insert new record                     
                    newCaseHistInsrt.case__c   =newCase.Id;                    
                    newCaseHistInsrt.case_id__c=newCase.Id;
                    newCaseHistInsrt.Status__c='In Progress';
                    newCaseHistInsrt.Time_In__c= system.now();
                    CaseStatInsrList.add(newCaseHistInsrt); 
                    }
                
            }else if((oldCase.Status <>'Pending Internal' && newCase.Status == 'Pending Internal') )
            {                
                // to update the old record
                if(caseHistMap.containsKey(newcase.id))
                    {
                     newCaseHistUpdt=   caseHistMap.get(newcase.id);
                     //map_caseid_history.get(newcase.id);
                     newCaseHistUpdt.Time_Out__c=system.now();
                     DateTime dtOut = system.now();
                     DateTime dtIn = newCaseHistUpdt.Time_In__c;                      
                     newCaseHistUpdt.Duration__c= (dtOut.getTime() - dtIn.getTime() ) / 60000; 
                     CaseStatUpdtList.add(newCaseHistUpdt);                
                    // to insert new record
                    newCaseHistInsrt.case__c   =newCase.Id; 
                    newCaseHistInsrt.case_id__c=newCase.Id;
                    newCaseHistInsrt.Status__c='Pending Internal';
                    newCaseHistInsrt.Time_In__c= system.now();
                    CaseStatInsrList.add(newCaseHistInsrt);
                    }
            } else if((oldCase.Status <>'Pending Customer' && newCase.Status == 'Pending Customer') )
            { 
                               
                    // to update the old record 
                    if(caseHistMap.containsKey(newcase.id))
                    {
                     newCaseHistUpdt=   caseHistMap.get(newcase.id);
                     //map_caseid_history.get(newcase.id);          
                     newCaseHistUpdt.Time_Out__c=system.now(); 
                     DateTime dtOut = system.now();
                     DateTime dtIn = newCaseHistUpdt.Time_In__c;                         
                     newCaseHistUpdt.Duration__c= (dtOut.getTime() - dtIn.getTime() ) / 60000; 
                     CaseStatUpdtList.add(newCaseHistUpdt);               
              
                    // to insert new record                             
                    newCaseHistInsrt.case__c   =newCase.Id; 
                    newCaseHistInsrt.case_id__c=newCase.Id;
                    newCaseHistInsrt.Status__c='Pending Customer';
                    newCaseHistInsrt.Time_In__c= system.now();
                    CaseStatInsrList.add(newCaseHistInsrt);               
                    }
            } 
            else if((oldCase.Status <>'Re-Open' && newCase.Status == 'Re-Open') )
            { 
                
                    // to update the old record                         
                    if(caseHistMap.containsKey(newcase.id))
                    {       
                     newCaseHistUpdt=   caseHistMap.get(newcase.id);
                     //map_caseid_history.get(newcase.id);  
                     newCaseHistUpdt.Time_Out__c=system.now(); 
                     DateTime dtOut = system.now();
                     DateTime dtIn = newCaseHistUpdt.Time_In__c;                     
                     newCaseHistUpdt.Duration__c= (dtOut.getTime() - dtIn.getTime() ) / 60000; 
                     CaseStatUpdtList.add(newCaseHistUpdt);               
              
                    // to insert new record                             
                    newCaseHistInsrt.case__c   =newCase.Id; 
                    newCaseHistInsrt.case_id__c=newCase.Id;
                    newCaseHistInsrt.Status__c='Re-Open';
                    newCaseHistInsrt.Time_In__c= system.now();
                    CaseStatInsrList.add(newCaseHistInsrt); 
                    }
                
            } else if( (oldCase.OwnerId <> newCase.OwnerId && string.valueOf(oldCase.OwnerId).startsWith('005')) || (oldCase.Status <>'Reassigned' && newCase.Status == 'Reassigned') ) 
            { 
                
                    // to update the old record                 
                    if(caseHistMap.containsKey(newcase.id))
                    { 
                    newCaseHistUpdt=   caseHistMap.get(newcase.id);
                     //map_caseid_history.get(newcase.id);
                     newCaseHistUpdt.Time_Out__c=system.now(); 
                     DateTime dtOut = system.now();
                     DateTime dtIn = newCaseHistUpdt.Time_In__c;                     
                     newCaseHistUpdt.Duration__c= (dtOut.getTime() - dtIn.getTime() ) / 60000; 
                     CaseStatUpdtList.add(newCaseHistUpdt);               
              
                    // to insert new record                             
                    newCaseHistInsrt.case__c   =newCase.Id; 
                    newCaseHistInsrt.case_id__c=newCase.Id;
                    newCaseHistInsrt.Status__c='Reassigned';
                    newCaseHistInsrt.Time_In__c= system.now();
                    CaseStatInsrList.add(newCaseHistInsrt);               
                    }
            } else if( ((oldCase.Status <>'Closed (No Issue)' && newCase.Status == 'Closed (No Issue)') ||
                    (oldCase.Status <>'Closed (Resolved)' && newCase.Status == 'Closed (Resolved)')) && (oldCase.Status <>'Assigned')  )
            { 
               
                    // to update the old record 
                    if(caseHistMap.containsKey(newcase.id))
                    { 
                    newCaseHistUpdt=   caseHistMap.get(newcase.id);
                     //map_caseid_history.get(newcase.id);              
                     newCaseHistUpdt.Time_Out__c=system.now(); 
                     DateTime dtOut = system.now();
                     DateTime dtIn = newCaseHistUpdt.Time_In__c;                    
                     newCaseHistUpdt.Duration__c= (dtOut.getTime() - dtIn.getTime() ) / 60000; 
                     CaseStatUpdtList.add(newCaseHistUpdt);               
              
                    // to insert new record                             
                    newCaseHistInsrt.case__c   =newCase.Id; 
                    newCaseHistInsrt.case_id__c=newCase.Id;
                    newCaseHistInsrt.Status__c='Closed';
                    newCaseHistInsrt.Time_In__c= system.now();
                    CaseStatInsrList.add(newCaseHistInsrt);               
                    }
            } else if((oldCase.Status <>'Completed' && newCase.Status == 'Completed') )
            { 
               
                    // to update the old record                 
                    if(caseHistMap.containsKey(newcase.id))
                    {
                    newCaseHistUpdt=   caseHistMap.get(newcase.id);
                     //map_caseid_history.get(newcase.id);   
                     newCaseHistUpdt.Time_Out__c=system.now(); 
                     DateTime dtOut = system.now();
                     DateTime dtIn = newCaseHistUpdt.Time_In__c;                      
                     newCaseHistUpdt.Duration__c= (dtOut.getTime() - dtIn.getTime() ) / 60000; 
                     CaseStatUpdtList.add(newCaseHistUpdt);               
              
                    // to insert new record                             
                    newCaseHistInsrt.case__c   =newCase.Id; 
                    newCaseHistInsrt.case_id__c=newCase.Id;
                    newCaseHistInsrt.Status__c='Completed';
                    newCaseHistInsrt.Time_In__c= system.now();
                    CaseStatInsrList.add(newCaseHistInsrt);               
                    }
            }  
                       
        }    
      update CaseStatUpdtList;
      insert CaseStatInsrList; 
     }
  }
    
    
  public static void updateAggrValToCase(list<Case_Status_History__c> lstNewCaseHists, map<Id, Case_Status_History__c> mapOldCaseHists)
  {   
       List<Case> CaseUpdtList = new List<Case>(); 
      
       List<String> caseHistlist = new List<String>();
       Map<Id,String> casHistMap = new Map<Id,String>();
      
       for(Case_Status_History__c newCaseHist1 : lstNewCaseHists)
       {
           caseHistlist.add(newCaseHist1.Case_Id__c);
       } 
      
       for(Case_Status_History__c newCaseHist2 : lstNewCaseHists)
       {
           casHistMap.put(newCaseHist2.Case_Id__c,newCaseHist2.Status__c);          
       }
      
      List<AggregateResult> agrList =
                [SELECT sum(duration__C),sum(No_of_Weekends__c),Case_Id__c  FROM Case_Status_History__c where  status__C in : casHistMap.values()
                 and case_id__c in :caseHistlist 
                 and Time_Out__c <> null  GROUP BY Case_Id__c,Status__c];
      //system.debug('AgrValues='+agrList); 
            Integer DurTime=0;
            Integer WkndCnt=0;
      
        map<String,AggregateResult> agrMap = new map<String,AggregateResult>();
        for(AggregateResult agrVal : agrList)
            {                
                agrMap.put((String)agrVal.get('Case_Id__c'), agrVal);        
            } 
      
      
      List<Case> caseListToUpdate = new List<Case>();
      
        for(Case_Status_History__c newCaseHist : lstNewCaseHists) { 
            
            case tc=new case();
            
            if((newCaseHist.Status__c !='Completed') && (newCaseHist.Status__c !='Closed')) 
            {
           // system.debug('AgrMap='+agrMap);
            AggregateResult agrVal=agrMap.get(newCaseHist.Case_Id__c);
                
                DurTime=(Integer) math.abs((Decimal)agrVal.get('expr0'));
                WkndCnt=(Integer) math.abs((Decimal)agrVal.get('expr1'));              
            
            tc.id=newCaseHist.Case_Id__c;
                
            if(newCaseHist.Status__c=='Assigned')
            {               
                tc.Time_in_Assigned_New__c=
                String.valueOf((Integer)math.floor(math.floor((DurTime-WkndCnt*1440) / 60))) + ':'+ String.valueOf((Integer)math.floor(math.mod((DurTime-WkndCnt*1440) ,60))) ;
            }
            else if(newCaseHist.Status__c=='In Progress')
            {                
                tc.Time_in_In_Progress_new__c=
                String.valueOf((Integer)math.floor(math.floor((DurTime-WkndCnt*1440) / 60))) + ':'+ String.valueOf((Integer)math.floor(math.mod((DurTime-WkndCnt*1440) ,60))) ;
            }
            else if(newCaseHist.Status__c=='Pending Internal')
            {               
                tc.Time_in_Pending_Internal_New__c=
                String.valueOf((Integer)math.floor(math.floor((DurTime-WkndCnt*1440) / 60))) + ':'+ String.valueOf((Integer)math.floor(math.mod((DurTime-WkndCnt*1440) ,60))) ;
            }
            else if(newCaseHist.Status__c=='Pending Customer')
            {
                tc.Minutes_In_Pending_Customer_New__c=(Integer)math.floor(DurTime-WkndCnt*1440);                 
                tc.Time_In_Pending_Customer_New__c=                
                String.valueOf((Integer)math.floor(math.floor((DurTime-WkndCnt*1440) / 60))) + ':'+ String.valueOf((Integer)math.floor(math.mod((DurTime-WkndCnt*1440) ,60))) ;
            }
            else if(newCaseHist.Status__c=='Re-Open')
            {                
                tc.Time_In_Re_Open_New__c=
                String.valueOf((Integer)math.floor(math.floor((DurTime-WkndCnt*1440) / 60))) + ':'+ String.valueOf((Integer)math.floor(math.mod((DurTime-WkndCnt*1440) ,60))) ;
            }            
            else if(newCaseHist.Status__c=='Reassigned')
            {                
                tc.Time_In_Reassigned_New__c=
                String.valueOf((Integer)math.floor(math.floor((DurTime-WkndCnt*1440) / 60))) + ':'+ String.valueOf((Integer)math.floor(math.mod((DurTime-WkndCnt*1440) ,60))) ;
            }       
            
                caseListToUpdate.add(tc);                          
        }
      }
             
    update caseListToUpdate;                 
   
  }
      
   public static void updtSlaValsInCase(list<Case_Status_History__c> lstCaseHists) 
   {    
      
       List<String> caseHistlist = new List<String>();        
            
       for(Case_Status_History__c newCaseHist1 : lstCaseHists)
       {
           caseHistlist.add(newCaseHist1.Case_Id__c);
       }        
      
       List<AggregateResult> agrList=
                [SELECT sum(duration__C) ,sum(No_of_Weekends__c) ,case_id__c FROM Case_Status_History__c where              
                 case_id__c in :caseHistlist                
                  GROUP BY Case_Id__c];
       
           Integer DurTime=0;
           Integer WkndCnt=0;
 
        map<String,AggregateResult> agrMap = new map<String,AggregateResult>();
        for(AggregateResult agrVal : agrList)
            {                
                agrMap.put((String)agrVal.get('Case_Id__c'), agrVal);        
            }    
       
      List<Case> caseListToUpdate = new List<Case>();
      
       
       for(Case_Status_History__c caseStatHist : lstCaseHists)
       {     
           case tc=new case();            
           if(caseStatHist.Status__c =='Closed') 
            {         
             AggregateResult agrVal=agrMap.get(caseStatHist.Case_Id__c);
                
                DurTime=(Integer) math.abs((Decimal)agrVal.get('expr0'));
                WkndCnt=(Integer) math.abs((Decimal)agrVal.get('expr1'));
                
                tc.id=caseStatHist.Case_Id__c;
                tc.Open_To_Close_Min__c=(Integer) math.floor(DurTime-WkndCnt*1440);               
                caseListToUpdate.add(tc);
                
            } 
         else if (caseStatHist.Status__c =='Completed')
         {               
             
                AggregateResult agrVal=agrMap.get(caseStatHist.Case_Id__c);
                DurTime=(Integer) math.abs((Decimal)agrVal.get('expr0'));
                WkndCnt=(Integer) math.abs((Decimal)agrVal.get('expr1'));
           
                tc.id=caseStatHist.Case_Id__c;
                tc.Sla_Case_Duration_New__c=String.valueOf((Integer)math.floor(math.floor((DurTime-WkndCnt*1440) / 60))) + ':'+ String.valueOf((Integer)math.floor(math.mod((DurTime-WkndCnt*1440) ,60))) ;         
                tc.Completed_Flag__c='Y';
                caseListToUpdate.add(tc);  
              
        }  
            
       }
       
      update caseListToUpdate;  
      
   }
    
   public static void insertFrstRecInCaseHist(list<Case> lstCases) {
         
         List<Case_Status_History__c> CaseStatList = new List<Case_Status_History__c>();
       
         for(Case newCase : lstCases){
                Case_Status_History__c newCaseHist  = new Case_Status_History__c ();                
                newCaseHist.case_id__c =newCase.Id;
                newCaseHist.case__c    =newCase.Id; 
                newCaseHist.Status__c  ='Open';
                newCaseHist.Time_In__c = system.now();
                CaseStatList.add(newCaseHist);
            }
         insert CaseStatList;
         
     }
    
      
  public static void deleteCaseHistory(list<Case> lstNewCases, map<Id, Case> mapOldCases) {
             
      List<Case_Status_History__c> CaseStatDelList = new List<Case_Status_History__c>();
           
      Set<ID> ids = mapOldCases.keySet();  
      
      List<Case> caseList = 
          [Select Id,(SELECT id FROM Case_Status_Histories__r )
            FROM Case Where Id in : ids  and completed_flag__c='Y'];
      
      //system.debug('completed=caseList='+caseList);
      
            map<Id, List<Case_Status_History__c>> caseHistMap = new map<Id, List<Case_Status_History__c>>();
            List<Case_Status_History__c> casehistoryLst = new List<Case_Status_History__c>();
      
      for(Case caseObj : caseList){          
            for(Case_Status_History__c caseHist: caseObj.Case_Status_Histories__r ){
                casehistoryLst.add(caseHist);                
            }
          caseHistMap.put(caseObj.Id, casehistoryLst);
        }
      
     //system.debug('completed=caseHistMap='+caseHistMap);
      
       if(caseHistMap.size()>0)
       {
        for(Case newCase : lstNewCases) {            
            Case oldCase = mapOldCases.get(newCase.Id);              
            
            if((oldCase.Completed_Flag__c <>'Y' && newCase.Completed_Flag__c == 'Y') )
            {               
              
                for(Case_Status_History__c ch : caseHistMap.get(newcase.id))
                    {
                        Case_Status_History__c CaseStatDel  = new Case_Status_History__c ();
                        CaseStatDel.Id=ch.Id;
                        CaseStatDelList.add(CaseStatDel);
                    }
                //system.debug('deleteList='+CaseStatDelList);
            }  
        } 
      
      delete CaseStatDelList;
       }
  }
    
    
    
}
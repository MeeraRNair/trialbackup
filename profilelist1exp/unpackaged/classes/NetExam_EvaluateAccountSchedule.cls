global class NetExam_EvaluateAccountSchedule implements Schedulable{
  global Id AccountId;

  global void execute(SchedulableContext sc){      
      List<String> batchList = new List<String>();  
      batchList.add(AccountId);
      PartnerProfileIntegration.integratePartnerData(batchList);    
  }
}
public class UpdateAPVStatus {
public static void updateStatusField(Set<Id> packageIdSet,Map<Id,Package__c> packageMap) {
   Associated_Programs_Vendors__c apvObj;
   List <Associated_Programs_Vendors__c> ApvList= new List <Associated_Programs_Vendors__c> (); 
   List <Associated_Programs_Vendors__c> apvUpdateList= new List <Associated_Programs_Vendors__c> (); 

        ApvList=[select Id,Status__c,Package__c from Associated_Programs_Vendors__c where 
                Package__c in:packageIdSet];                
        for(Associated_Programs_Vendors__c apvELt:ApvList){             
            if(packageMap.get(apvELt.Package__c)!=null){
              // apvObj=new Associated_Programs_Vendors__c(id=apvELt.Id); 
                apvELt.Status__c=packageMap.get(apvELt.Package__c).Status__c;
                apvUpdateList.add(apvELt);
            }  
        }
        update apvUpdateList;
    }

}
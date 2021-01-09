public class createAPVforProposedAPV{

     
    public static Map<ID,MDF_Program__c> mdfPgmMap=new Map<ID,MDF_Program__c>();
    public static List<Associated_Programs_Vendors__c> apvList=new List<Associated_Programs_Vendors__c>();
    public static Map<String,RecordType> APVRecordMap=new Map<String,RecordType>();
      
    public static void insertAPVRecord(List<Proposed_Associated_Program_Vendor__c> pAPVList, Set<ID> mdfIdSet,  Map<ID,vendor__c> subVendorMap){    
        
        //Get the Record type Map for APVs      
        for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='Associated_Programs_Vendors__c'])    {           
            APVRecordMap.put(rtElt.Name,rtElt);
        }  

        //Get the Mdf program details for cterating the APV
        for(MDF_Program__c mdf:[select id,Name,Program_Status__c,OwnerId,Rate_Card_Price__c,Program_Type__c,
                            Pricing_Type__c,POP_Details__c,  Fiscal_Quarter__c,Region__c ,Business_Segment__c,Country__c,sub_region__c 
                            from MDF_Program__c where id IN :mdfIdSet]){
            mdfPgmMap.put(mdf.id,mdf);                                
        }
        
        //Map the proposed Apv fields, MDF program fields for creating new APV record
        
        for (Proposed_Associated_Program_Vendor__c pAPV:pAPVList){
        
            MDF_Program__c mdfRecord=mdfPgmMap.get(pAPV.MDF_Program__c);
            Vendor__c subvendorRec= subVendorMap.get(pAPV.Vendor__c);
            
            Associated_Programs_Vendors__c apvRecord=new Associated_Programs_Vendors__c(
                        recordtypeId = APVRecordMap.get('Vendor Association').Id,
                        Vendor__c= pAPV.Vendor__c,
                        Rate_Card_Price__c= mdfRecord.Rate_Card_Price__c,                
                        MDF_Program__c= pAPV.MDF_Program__c                
            );   
            
            if(mdfRecord.Pricing_Type__c =='Variable' || subvendorRec.Budgeted_Discount__c == null){
                apvRecord.Budgeted_Price__c=mdfRecord.Rate_Card_Price__c;                    
            }
            if(mdfRecord.Pricing_Type__c =='Non-Variable' && mdfRecord.Rate_Card_Price__c!=null && subvendorRec.Budgeted_Discount__c!=null){                    
                apvRecord.Budgeted_Price__c=mdfRecord.Rate_Card_Price__c*((100 - subvendorRec.Budgeted_Discount__c)/100);
            }                
            apvList.add(apvRecord);            
        }
         try{
            if(apvList.size()>0){
                insert apvList;
            }
        }catch (exception e){
        }
    }
}
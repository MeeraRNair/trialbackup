/* ============================================================
 * This Controller Created for creating New Cross Functional Matrix Record
 * CR 9022 - Version 0.1 Developed by Rakesh Muppiri on 22-01-2014
 * ============================================================
 */
public class NewCrossFunctionalMatrixCntrl{
    public Cross_Functional_Matrix__c CFMT{set;get;}
    public NewCrossFunctionalMatrixCntrl(ApexPages.StandardController controller) {
        CFMT = new Cross_Functional_Matrix__c();
        Countries = new List<SelectOption>();
        Segments = new List<SelectOption>();
        SubSegments = new List<SelectOption>();
        
        List<String> Cntry= new List<String>();
        List<String> Seg= new List<String>();
        List<String> SubSeg= new List<String>();
        
        Set<String> Countrs= new Set<String>();
        Set<String> Segs= new Set<String>();
        Set<String> SubSegs= new Set<String>();
        if( controller.getid() != null){
            CFMT  = [SELECT NSS_Category__c, Country__c, Segment__c, Sub_Segment__c, Owner__c, CC_Owner__c, Functional_Call_To_Action__c FROM Cross_Functional_Matrix__c  WHERE ID =: controller.getId() LIMIT 1];
            Country = CFMT.Country__c;
            Segment = CFMT.Segment__c;
            SubSegment = CFMT.Sub_Segment__c;
        }
        for(Case_Management_Queue__c a: [SELECT Segment__c,Sub_Segment__c,Country__c FROM Case_Management_Queue__c WHERE Segment__c!= NULL AND Country__c != NULL ]){
            
            Countrs.add(a.Country__c );
            Segs.add(a.Segment__c);
            SubSegs.add(a.Sub_Segment__c);
        }
        Cntry.addAll(Countrs);
        Seg.addAll(Segs);
        SubSeg.addAll(SubSegs);
        
        Cntry.sort();
        Seg.sort();
        
        SubSeg.sort();
   
      Countries.add(new SelectOption('','--select--'));
      Segments.add(new SelectOption('','--select--'));
      SubSegments.add(new SelectOption('','--select--'));
           
      for (String s: Cntry){      
        Countries.add(new SelectOption(s,s));
      }
      for (String s: Seg){      
        Segments.add(new SelectOption(s,s));
      }
      
      for (String s: SubSeg){
          if(s != null)      
              SubSegments.add(new SelectOption(s,s));
      } 
    }
    public string Country{set;get;}
    public string Segment{set;get;}
    public string SubSegment{set;get;}
    public List<SelectOption>Countries{get;set;}
    public List<SelectOption>Segments{get;set;}
    public List<SelectOption>SubSegments{get;set;}
    
    
    String err = System.Label.NPS_Case_Management_Queue_Error_Message;
    public PageReference InsertCFMx(){
       if(Segment == NULL || country == NULL){
            CFMT.addError(err);
            return null;
        }
        CFMT.Segment__c = Segment;
        CFMT.Sub_Segment__c = SubSegment;
        CFMT.Country__c = country;
        insert CFMT; 
        PageReference p = new PageReference('/'+CFMT.Id);  
        return p;             
    }
    public PageReference UpdateCFMx() {
        if(Segment == NULL || country == NULL){
            CFMT.addError(err);
            return null;
        }
        CFMT.Segment__c = Segment;
        CFMT.Sub_Segment__c = SubSegment;
        CFMT.Country__c = country;
        update CFMT;            
        return new PageReference('/'+CFMT.Id);
    }
}
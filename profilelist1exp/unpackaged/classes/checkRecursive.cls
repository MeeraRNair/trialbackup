Public Class checkRecursive{
    Private Static Boolean OpportunityTrigger_CBO = True;
    private static boolean OpportunitySplitTrigger_CBO = true; //Afiq introduce splitCountCBO
    Private Static Integer i = 0;
    Private Static Boolean bsnpVendor= True;
    Private Static Integer intsnpVendorCount = 0;
    private static Integer splitCountCBO = 0; //Afiq introduce splitCountCBO

    Public Static Boolean snpVendorRunOnce(){
    If (bsnpVendor){
            If (intsnpVendorCount == 3){
             bsnpVendor=false;
      }   
      intsnpVendorCount ++;
      
     Return True;
    }
    Else{
   
        Return bsnpVendor;
    }
 

    }   
    
   //added by Gan
    Public Static Integer getCounter() {
       Return i;

    } 
    
    Public Static Boolean OpportunityTrigger_CBORunOnce(){
    system.debug('G1 -> i: ' + i + ', current limit:' + Limits.getQueries());
        If (Limits.getQueries() == 0 & i!= 0) {
            i = 0; 
            OpportunityTrigger_CBO = true;
        }
    If (OpportunityTrigger_CBO){
        If (i == 3){
             OpportunityTrigger_CBO =false;
      }   
      i++;
     Return True;
    }else{
        Return OpportunityTrigger_CBO;
    }
    }
    
    //Afiq introduce splitCountCBO
    public static boolean OpportunitySplitTrigger_CBORunOnce(){
		if(OpportunitySplitTrigger_CBO){
			//set variable to less than 2 so it will only run for BeforeInsert and BeforeUpdate
			if(splitCountCBO <2){
				OpportunitySplitTrigger_CBO =false;
		}   
		splitCountCBO ++;
		return true;
		}
		else{
			return OpportunitySplitTrigger_CBO;
		}
    }  
      
}
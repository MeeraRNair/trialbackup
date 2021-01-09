public class POPDetailLandingController {
    String programId;
    MDF_Program__c program = new MDF_Program__c();

    public POPDetailLandingController(){
        programId = Apexpages.currentPage().getParameters().get('Id');
        program = [Select m.Name, m.Id, m.Program_Owner__c, m.POP_Owner__c From MDF_Program__c m where m.Id = :programId];
    }
    
    public Pagereference Redirect(){
        Proof_of_Performance_POP__c newPOP = new Proof_of_Performance_POP__c();
        List<Profile> userProfile=[select Name from profile where id = :userinfo.getProfileId()];
        
        try{
            if(userinfo.getUserId()!= program.Program_Owner__c && userinfo.getUserId()!= program.POP_Owner__c &&
                         !(userProfile[0].Name.contains('MDF Marketing Operations / Contract Admin')) &&  !(userProfile[0].Name.contains('MDF Co-Marketing  Manager'))){            
                ApexPages.Message msg ;
                msg = new ApexPages.Message(ApexPages.severity.WARNING,'Only POP Owner/Program Owner of the MDF Program or Marketing operations/Marketing Manager are authorised to create new POP record.');
                ApexPages.addMessage(msg);
                return null;
            }else {            
                String soql = 'Select count() from Proof_of_Performance_POP__c where MDF_Program__c = \''+program.Id+'\'';
                Integer POPcount = Database.countQuery(soql);
                newPOP.MDF_Program__c = program.Id;
                if( POPcount == 0){
                    newPOP.Name = program.Name + ' #1';
                }
                else{
                    newPOP.Name = program.Name + ' #'+(POPcount+1);
                }
                insert newPOP;
            }
        }
        catch(Exception e){
            //Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Unable to create New Proof of Performance');
            //Apexpages.addMessage(msg);
            Pagereference detail = new Pagereference('/'+program.Id);
            return detail;
        }
        Pagereference detail = new Pagereference('/'+newPOP.Id);
        return detail;
    }

}
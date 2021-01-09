public class OppEditRedirectController{
    
    Opportunity opp ;
    String oppId ;
    
    public OppEditRedirectController(ApexPages.StandardController controller) {       
        oppId = ApexPages.currentPage().getParameters().get('id');
        opp = [Select Id, Probability,NextStep, StageName from Opportunity where id =: oppId];
        system.debug('----Opp: '+ opp);
        //redirectToVF();
    }
    
    
    public pageReference redirectToVF(){
        
        String oldStageName = opp.NextStep;
        String oldProb = String.valueOf(opp.Probability);
        system.debug('----opp.Probability: '+ opp.Probability);
        String redirectURL;
        pagereference page ;
        
        String dupStageName  ;
        if(opp.StageName == 'Propose - 60%'){
            dupStageName = 'propose60';
        } else if(opp.StageName == 'Plan - 1%'){
          dupStageName = 'plan1';
        
        }else if(opp.StageName == 'Discover - 10%'){
          dupStageName = 'discover10';
        }else if(opp.StageName == 'Qualify - 30%'){
          dupStageName = 'qualify30';
        }
        else if(opp.StageName == 'Commit - 90%'){
          dupStageName = 'commit90';
        }
        
        String ProbStageName = oldProb + '$' + dupStageName ;
        
        redirectURL = '/' + opp.Id + '/e?retURL=%2F' + opp.Id + '&nooverride=1&saveURL=' + '/' + 'apex/OpportunityEditPage?oldProbability=' + ProbStageName ; // + '&OldOppStage=' + oldStageName;
      //  redirectURL = '/' + opp.Id + '/e?retURL=%2F' + opp.Id + '&nooverride=1&saveURL=' + '/' + 'apex/SampleEditOpp?oldProbability={!opp.Probability}&OldOppStage={!opp.StageName} ; //'&OldOppStage=' + oldStageName +
        page = new pagereference(redirectURL);
        page.setRedirect(TRUE);
       
        system.debug('---URL: ' + redirectURL);
        
        return page;
    }
}
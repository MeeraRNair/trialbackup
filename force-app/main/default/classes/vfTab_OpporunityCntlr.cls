/*
History:
Version   Date          Modified By     Description
--------------------------------------------------------------------------------------
1.0      12-Aug-2013    Meghana         Created for OMGO-Workflow
*/
public with sharing class vfTab_OpporunityCntlr{
    Public PageReference redirect(){
        ID roleId = '00E30000000w2Bz';
            try{
                system.debug ('$$$Debug role id'+UserInfo.getUserRoleId());
                if (UserInfo.getUserRoleId() == roleId )
                    return PageUtils.redirect('/006/o');   
                else
                    return PageUtils.redirect('/apex/VfCustomOpportunityHomePage?fcf=00B300000036NNe');         
            
        }
        catch(Exception ex){  
            system.debug('###DEBUG### Error -- '+ex.getMessage());           
          }  
        return null;
    }
}
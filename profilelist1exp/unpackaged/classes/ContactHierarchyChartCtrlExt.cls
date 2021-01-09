public with sharing class ContactHierarchyChartCtrlExt {

    public List<Contact> contactList{get;set;}
    public String rowSet{get;set;}
    public string retUrl;
    public ContactHierarchyChartCtrlExt(ApexPages.StandardController controller) {
        Account acc = (Account)controller.getRecord();
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        //contactList  = [SELECT id, FirstName, LastName, ReportsTo.FirstName, ReportsTo.LastName FROM Contact WHERE AccountId = :acc.id];
        Boolean first = true;
        rowSet='';
        Map<string,string> roleColorMap = new Map<string,string>();

        roleColorMap.put('Power Sponsor / Decision Maker','red');
        roleColorMap.put('Sponsor/ Champion','blue');
        roleColorMap.put('Influencer','green');
        roleColorMap.put('Business User','rgb(115,115,115)');
        roleColorMap.put('Evaluator','yellow');
        roleColorMap.put('Purchasing / Procurement','orange');
        roleColorMap.put('Financial Buyer','brown');
        roleColorMap.put('Technical Buyer','rgb(255,0,255)');
        roleColorMap.put('Operational Buyer','black');
        roleColorMap.put('Legal Approver','rgb(128,128,0)');
        roleColorMap.put('Unknown','rgb(128,0,255)');
        
        Map<string,string> heatMap = new Map<string,string>();
        heatMap .put('Delighted', System.Label.heatmap_delighted_transparent_img_url);
        heatMap .put('Dissatisfied', System.Label.heatmap_dissatisfied_transparent_img_url);
        heatMap .put('Satisfied', System.Label.heatmap_satisfied_transparent_img_url);

        Integer i = 0;

        List<Contact> contactList = [SELECT id, FirstName, LastName,ReportsToId, Title, Department, ReportsTo.FirstName, ReportsTo.LastName, ReportsTo.AccountId, Decision_Making_Role__c,Relationship_Heat_Map__c  FROM Contact WHERE AccountId = :acc.id ];
        //AND ReportsTo.AccountId = :acc.id

        Map<string, string> parentChildMap = new Map<string,string>();
        List<string> orphanList = new List<string>();

        for(Contact con : contactList ){
            parentChildMap.put(con.ReportsToId,con.Id);
            system.debug('Reports to     '  + con.ReportsToId + '    Contact    ' + con.Id);
            if(con.ReportsToId == null){
                orphanList.add(con.Id);
            }
        }

        List<string> newOrphanList = new List<string>();

        for(Integer j = 0 ; j < orphanList.size() ; j++){
            if(parentChildMap.get(orphanList.get(j))!= null){
                system.debug('Removing this from Orphan   ' + orphanList.get(j));
                //orphanList.remove(j);
            } else {
                newOrphanList.add(orphanList.get(j));
            }
        system.debug('orphanList.size()     ' + orphanList.size() + 'Current Iteration   ' + j);
        }

        orphanList = newOrphanList;


        for(string orphan : orphanList)
            system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Orphan' + orphan );
        if(orphanList != null && orphanList.size() > 0){
            for(Integer k = 0 ; k < contactList.size(); k++){
                for(Integer l = 0 ; l < orphanList.size(); l++){
                    if(orphanList.get(l) == contactList.get(k).Id){
                        system.debug('Removed this    ' + contactList.get(k));
                        contactList.remove(k);
                    }
            }
        }
        }


        if(contactList != null && contactList.size() > 1){
             for (Contact con: contactList){


            //boolean isOrphan = (parentChildMap);
            //if(con.)
            boolean showHigherNode = (con.ReportsToId!=null && con.ReportsTo.AccountId == acc.Id) ;
            boolean lastCon = (contactList.size() == i);

            //if(!lastCon && con.ReportsToId == null)
                //continue;

            if (!first){
                rowSet +=',';
            }
            //System.debug('###  con' +  con);
           // System.debug('###  con.ReportsTo.FirstName ' +  con.ReportsTo.FirstName );

           //[{v:'Mike', f:'Mike<div style="color:red; font-style:italic">President</div>'}, '', 'The President'],
          //[{v:'Jim', f:'Jim<div style="color:red; font-style:italic">Vice President</div>'}, 'Mike', 'VP'],
          //['Alice', 'Mike', ''],
          //['Bob', 'Jim', 'Bob Sponge'],
          //['Carol', 'Bob', '']

            string dept = con.Department != null ? con.Department : '';
            string title = con.Title != null ? con.Title : '';
            rowSet += '[ {v: \'';
            rowSet +=  String.escapeSingleQuotes(con.FirstName) + ' '+ String.escapeSingleQuotes(con.LastName);
            rowSet += '\'';
            rowSet += ', f:\'';
            rowSet += ((con.Relationship_Heat_Map__c!= null && con.Relationship_Heat_Map__c!= '') ?'<img src="' +heatMap.get(con.Relationship_Heat_Map__c) +  '" width="20" height="20">': '');
            rowSet += '<div style="color:black; font-weight: bold">';
             rowSet +=  String.escapeSingleQuotes(con.FirstName) + ' '+ String.escapeSingleQuotes(con.LastName);
              rowSet += '</div>';
             rowSet += '<div style="color:black; font-style:italic">';
             rowSet += '<br/>' + String.escapeSingleQuotes(title) + '<br/>' + String.escapeSingleQuotes(dept);
             rowSet += '</div>';
            rowSet += '\'';
            rowSet += '}';
            rowSet +=  ',';
            rowSet +=  '\'';
            rowSet +=  lastCon ? '' : (showHigherNode ?(String.escapeSingleQuotes(con.ReportsTo.FirstName) + ' '+ String.escapeSingleQuotes(con.ReportsTo.LastName)):'');
            rowSet +=  '\'';
            rowSet +=  ',';
            rowSet +=  '\'';
            rowSet +=  '1';
            rowSet +=  '\'';
            rowSet +=  ',';
            rowSet +=  '\'';
            rowSet += 'border: 3px solid ' + roleColorMap.get(String.escapeSingleQuotes(con.Decision_Making_Role__c == null ? ' ' : con.Decision_Making_Role__c ));
            rowSet +=  '\'';
            rowSet += ']';
            //rowSet += ',\'\']';
            System.debug('### row output  '+'jhygkjhgi  ' + con.Id + con.FirstName + ' '+ con.LastName + '\'- \'' +  con.ReportsToId!=null?(con.ReportsTo.FirstName + ' '+ con.ReportsTo.LastName):'' + '\'' + ',\'\'$' );
            first= false;
            i++;
           // System.debug('###  rowSet ' +'        Count ' + i++ +  rowSet );
        }//end for

       }


        System.debug('###  rowSet ' +  rowSet );
        //['Alice', 'Mike', ''],
    }

    public PageReference redirectBack(){

        return PageUtils.redirect(retUrl);

    }
}
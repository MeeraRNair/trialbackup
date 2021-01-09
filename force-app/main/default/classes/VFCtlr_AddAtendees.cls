Public Class VFCtlr_AddAtendees{
        Transportation__c tranportaionObj=new Transportation__c();
        Transportation__c tranportaionUpdateObj=new Transportation__c();
        List<Attendees__c> AttendeesList=new List<Attendees__c>();
        List<Attendees__c> AttendeesUpdateList=new List<Attendees__c>();
        List<AttendeeWrapper> AttendeeWrapperRecords=new List<AttendeeWrapper>();
        Boolean displayTbl=false;
        Boolean errorMsg=false;        
             
          //Wrapper class        
          public class AttendeeWrapper{            
                  public Attendees__c attendeeElt {get; set;}
                  public Boolean selected {get; set;}            
                  //Constructor for wrapper class            
                  public AttendeeWrapper(Attendees__c attendeeObj){                
                  attendeeElt = attendeeObj;
                  selected = false;            
              }        
          } 
     
     
        public VFCtlr_AddAtendees(ApexPages.StandardController controller){ 
            Id tranportObjId=controller.getId();
            AttendeeWrapper attendeeWrapper;            
            tranportaionObj=[select id,Customer_Engagement__c,Selected_Attendee__c            
                            from Transportation__c where id =:tranportObjId];  
                                     
            if(tranportaionObj.Customer_Engagement__c!=null){
                AttendeesList=[select id,name,Attendee_Name__c,Customer_Engagement__c,recordTypeId,recordType.name 
                from Attendees__c where Customer_Engagement__c=:tranportaionObj.Customer_Engagement__c];
             }
             
            String oldVal=tranportaionObj.Selected_Attendee__c;
            System.debug('###AttendeesList'+AttendeesList);  
            System.debug('###oldVal'+oldVal);  
            if(AttendeesList.size()>0){
                for(Attendees__c attendeeRec:AttendeesList){
                    if(oldVal==null){
                        attendeeWrapper=new AttendeeWrapper(attendeeRec);
                        attendeeWrapper.selected = false;
                        AttendeeWrapperRecords.add(attendeeWrapper);
                        System.debug('###oldVal==null'+attendeeRec);
                    } 
                    if(oldVal!=null && !oldVal.contains(attendeeRec.Id)){
                        attendeeWrapper=new AttendeeWrapper(attendeeRec);
                        attendeeWrapper.selected = false;
                        AttendeeWrapperRecords.add(attendeeWrapper);
                        System.debug('###oldVal!=null'+attendeeRec);
                    }    
                }
            }
            if(AttendeeWrapperRecords.size()==0){
                errorMsg=true;
                displayTbl=false;
            }
            if(AttendeeWrapperRecords.size()>0){
                displayTbl=true;
                errorMsg=false;
            }
            System.debug('###AttendeeWrapperRecords'+AttendeeWrapperRecords);  
                                
        }
        
        public List<AttendeeWrapper> getAttendeeList(){                     
            return AttendeeWrapperRecords;        
        }                
        public void setAttendeeList(List<AttendeeWrapper> wList){                        
            this.AttendeeWrapperRecords=wList;       
        }
        public boolean getDisplayTbl(){
            return displayTbl; 
        }
        public boolean getErrorMsg(){
            return errorMsg; 
        }
        public pagereference addAttendee(){
            String oldVal;
            String temp;
            pagereference pageRef=new pagereference('/'+tranportaionObj.Id); 
            //tranportaionUpdateObj=new Transportation__c(id=tranportaionObj.Id);
            oldVal=tranportaionObj.Selected_Attendee__c;
            for(AttendeeWrapper rec:AttendeeWrapperRecords){                
                if(rec.selected==true){
                    if(oldVal==null){
                        oldVal='<br></br><a href="/'+rec.attendeeElt.Id+'">'+rec.attendeeElt.Attendee_Name__c+'</a> - '+rec.attendeeElt.recordType.name;          
                    }
                    if(oldVal!=null && !(oldVal.contains(rec.attendeeElt.Id))){
                        oldVal=oldVal+'<br></br><a href="/'+rec.attendeeElt.Id+'">'+rec.attendeeElt.Attendee_Name__c+'</a> - '+rec.attendeeElt.recordType.name;          
                    }
                    
                }
             }
             tranportaionObj.Selected_Attendee__c=oldVal;          
            update tranportaionObj; 
            
            return pageRef;
        }
    
 }
/***********************************************************

* Name          : Availability 

* Description: Helper Class  for calendar booking for Executive Briefing Center

* ---------------------------------------------------------

* Revision  Name    Date        Description

* 1.0       Ambily  30-Mar-2011:   CR #5748 
* 2.0       Ambily  30-Jun-2011:   CR #6358 ,CR #6364 ,CR # 6365 , CR #6366 ,CR #6367

 

************************************************************/

public class Availability {
    
    Public Integer calendarDate{get;set;}
    Public Date calendarDateFormat{get;set;}
    Public String calendarMonth{get;set;}
    Public Integer calendaryear{get;set;}
    Public String singleroomsAM{get;set;}
    Public String doubleroomsAM{get;set;}
    Public String dayOfTheweek{get;set;}
    Public String singleroomsPM{get;set;}
    Public String doubleroomsPM{get;set;}
    Public String singleRoomAvailabilityAM{get;set;}
    Public String singleRoomAvailabilityPM{get;set;}
    Public String doubleRoomAvailabilityAM{get;set;}
    Public String doubleRoomAvailabilityPM{get;set;}
    Public String waitingListBooking{get;set;}
    Public String waitingList{get;set;}
    Public String timeSlot{get;set;}
    Public List<TourWrapper> TourWrapperRecords=new List<TourWrapper>();
    Public TourWrapper tourWrapperObject{get;set;}
    
    public Availability(){}
    
    //CR 6367
    public class TourWrapper{            
      public String tourValue {get; set;}
      public String tourColour {get; set;}            
      public String tourName {get; set;}            
    
    
    //Constructor for wrapper class            
      public TourWrapper(){                
      }
      public TourWrapper(String tourValue, String tourColour,String tourName,Integer dummyvar){                
          this.tourValue = tourValue;
          this.tourColour = tourColour;            
          this.tourName = tourName;   
        }        
    } 
    
    public List<TourWrapper> getTourList(){                     
      return TourWrapperRecords;        
    }                
    
    public void setTourList(List<TourWrapper> wList){                        
      this.TourWrapperRecords=wList;       
    }

}
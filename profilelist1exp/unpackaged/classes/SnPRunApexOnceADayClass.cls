global class SnPRunApexOnceADayClass implements Schedulable {
    public static String CRON_EXP = '0 0 0 ? * MON-FRI'; // Runs every day at 12:00AM from MON to FRI
    
    global void execute(SchedulableContext SC){
        SnPDealRegistrationMainClass.sendEmailReminderForExpiringPartnerInformation();
    }    
    
}
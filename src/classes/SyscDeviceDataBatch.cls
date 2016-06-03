public with sharing class SyscDeviceDataBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Patient_Id__c, Full_Name__c, Gender__c, Steps_Completed__c, Goal__c, Height__c FROM Patient__c ORDER BY createdDate ASC');
    }
    
	public void execute(Database.BatchableContext BC, List<Patient__c> patientList) {
        
		String todaysDate =String.valueOf(System.today());
        todaysDate = todaysDate.replace(' 00:00:00', '');
        List<Patient__c> patientListToUpdate = new List<Patient__c>();
        for(Patient__c patient :patientList){
            Integer stepsCompleted = 0;
            String url = FitForceUtility.ACTIVITY_API.replace('TODAY', todaysDate);
            String activityJson = FitForceUtility.doHTTPCallout(FitForceUtility.GET, url);
            ActivityWrapper activityWrapper = (ActivityWrapper) JSON.deserialize(activityJson, Type.forName('ActivityWrapper'));
            for(ActivityWrapper.Activities act :activityWrapper.activities){
                System.debug('Steps :'+act.steps);
                if(act.steps != NULL){
                    patient.Steps_Completed__c = Integer.valueOf(act.steps);
                    patientListToUpdate.add(patient);
                }
            }
        }
        Database.update(patientListToUpdate);
	}
    
	public void finish(Database.BatchableContext BC) {    
	}
}
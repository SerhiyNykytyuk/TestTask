public without sharing class CaseTriggerHandler {

    private static Set<Id> caseAccountIds;
    private static Map<Id, Account> accountsWithCases;
    private static List <Account> accountsToUpdate;

    public static void onAfterInsert(List<Case> newCaseRecords){
        runCalculations(newCaseRecords);
    }

    public static void onAfterUpdate(List<Case> newCaseRecords){
        runCalculations(newCaseRecords);
    }

    private static void runCalculations(List<Case> newCaseRecords){
        if(validateCaseSummariesAreUpdateble()){
            initiateCollections(newCaseRecords);
            populateAccountsForUpdate();
            update accountsToUpdate;
        }
    }

    private static Boolean validateCaseSummariesAreUpdateble(){

        Schema.DescribeFieldResult openCasesField = Account.NumberOfOpenCases__c.getDescribe();
        Schema.DescribeFieldResult closedCasesField = Account.NumberOfClosedCases__c.getDescribe();

        return openCasesField.isUpdateable() && closedCasesField.isUpdateable();
    }

    private static void initiateCollections(List<Case> newCaseRecords) {
        initiateAccountIds(newCaseRecords);
        initiateAccountsWithCasesMap();
        accountsToUpdate = new List <Account>();
	}

    private static void initiateAccountIds(List<Case> newCaseRecords) {
		caseAccountIds = new Set<Id> ();

		for (Case cas : newCaseRecords) {
            if(cas.AccountId != NULL){
                caseAccountIds.add(cas.AccountId);
            }			
		}
    }

    private static void initiateAccountsWithCasesMap(){
        accountsWithCases = new Map<Id, Account> (
                        [SELECT Id, NumberOfOpenCases__c, NumberOfClosedCases__c, 
                        (SELECT Id, IsClosed FROM Cases)
                        FROM Account WHERE Id IN :caseAccountIds]);
    }

    private static void populateAccountsForUpdate(){
        for(Id accId : caseAccountIds){
            Account acc = calculateAccountCases(accountsWithCases.get(accId));
            accountsToUpdate.add(acc);
        }
    }
    
    private static Account calculateAccountCases(Account acc){
        
        Integer countOpenCases = 0;
        Integer countClosedCases = 0;

        for(Case relatedCase : acc.Cases){
            if (relatedCase.isClosed == true) {
                countClosedCases++;
            } else {
                countOpenCases++;
            }
        }

        acc.NumberOfOpenCases__c = countOpenCases;
        acc.NumberOfClosedCases__c = countClosedCases;
                    
        return acc;
    }
}
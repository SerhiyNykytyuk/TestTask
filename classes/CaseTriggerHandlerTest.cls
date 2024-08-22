@isTest
private class CaseTriggerHandlerTest {

    @TestSetup
    static void createTestData() {
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
    }

    @isTest
    static void testInserAndUpdatetOneThousandCases() {
        Test.startTest();

        User u = [SELECT Id FROM User WHERE Id=: userInfo.getUserId()];
        system.runAs(u){

            Account acc = [SELECT Id FROM Account LIMIT 1];
            System.assertNotEquals(null, acc, 'Should not be null, inserted in test setup');

            insertCasesAndCheckAccount(acc);
            updateCasesAndCheckAccount(acc);
        }

        Test.stopTest();
    }

    static void insertCasesAndCheckAccount(Account acc){
        List<Case> cases = prepareCasesRecords(acc);
        insert cases;

        Account accountWithCasesRecalculated = [SELECT Id, NumberOfOpenCases__c, NumberOfClosedCases__c FROM Account LIMIT 1];
        System.assertEquals(500, accountWithCasesRecalculated.NumberOfOpenCases__c, 'Should be 500 according to test data');
        System.assertEquals(500, accountWithCasesRecalculated.NumberOfClosedCases__c, 'Should be 500 according to test data');
    }

    static void updateCasesAndCheckAccount(Account acc){
        List<Case> openCases = [SELECT Id, AccountId, Status FROM Case WHERE IsClosed = false AND AccountId = :acc.Id];
        List<Case> casesForUpdate = new List<Case>();

        for (Case cas : openCases){
            cas.Status = 'Closed';
            casesForUpdate.add(cas);
        }
        update casesForUpdate;

        Account accountWithAllCasesClosed = [SELECT Id, NumberOfOpenCases__c, NumberOfClosedCases__c FROM Account LIMIT 1];
        System.assertEquals(0, accountWithAllCasesClosed.NumberOfOpenCases__c, 'Should be 0 according to changes');
        System.assertEquals(1000, accountWithAllCasesClosed.NumberOfClosedCases__c, 'Should be 1000 according to changes');
    }

    static List<Case> prepareCasesRecords(Account acc) {
        List<Case> cases = new List<Case>();

        for (Integer i = 0; i < 500; i++){
            String subj = i.toString();

            Case casOpen = prepareCaseRecord(acc); 
            Case casClosed = prepareCaseRecord(acc);
            casClosed.Status = 'Closed';
 
            cases.add(casOpen);
            cases.add(casClosed);
        }

        return cases;
    }

    static Case prepareCaseRecord(Account acc){
        Case cas = new Case(
            Subject = 'open', 
            AccountId = acc.Id, 
            Status ='New', 
            Priority = 'Medium', 
            Origin = 'Email');

        return cas;
    }
}
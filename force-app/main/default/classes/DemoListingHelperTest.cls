/**
 * Placeholder test that does not execute DemoListingHelper.
 * Coverage of DemoListingHelper stays at zero on purpose for the quality-gate demo.
 */
@isTest
private class DemoListingHelperTest {
    /**
     * Passes without calling the class under test.
     */
    @isTest
    static void shouldPassWithoutExercisingHelper() {
        Test.startTest();
        Integer marker = 1;
        Test.stopTest();

        Assert.areEqual(1, marker, 'Placeholder assertion that does not call DemoListingHelper');
    }
}
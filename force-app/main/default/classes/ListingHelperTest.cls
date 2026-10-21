/**
 * Tests for ListingHelper.
 */
@isTest
private class ListingHelperTest {
    /**
     * A listing with a city name is reported as having a city.
     */
    @isTest
    static void shouldDetectCityWhenPresent() {
        Test.startTest();
        Boolean present = ListingHelper.hasCity('Boston');
        Test.stopTest();

        Assert.isTrue(present, 'Expected a non-blank city to be detected');
    }
}
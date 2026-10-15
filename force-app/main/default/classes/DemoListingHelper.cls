/**
 * Demo helper for listing price bands. Used to show a quality-gate coverage miss.
 */
public with sharing class DemoListingHelper {
    private static final Decimal FULL_PERCENT = 100;

    /**
     * Prevents instantiation. Use the static methods.
     */
    private DemoListingHelper() {
    }

    /**
     * @param city City name from a listing
     * @return True when the city has a value
     * @example
     * Boolean present = DemoListingHelper.hasCity('Boston');
     */
    public static Boolean hasCity(String city) {
        return String.isNotBlank(city);
    }

    /**
     * @param price Listing price
     * @param percent Percent below the price
     * @return Lower edge of the price band, or zero when an input is missing
     * @example
     * Decimal floorPrice = DemoListingHelper.lowerPrice(500000, 20);
     */
    public static Decimal lowerPrice(Decimal price, Decimal percent) {
        if (price == null || percent == null) {
            return 0;
        }
        return price * (1 - (percent / FULL_PERCENT));
    }

    /**
     * @param price Listing price
     * @param percent Percent above the price
     * @return Upper edge of the price band, or zero when an input is missing
     * @example
     * Decimal ceilingPrice = DemoListingHelper.upperPrice(500000, 20);
     */
    public static Decimal upperPrice(Decimal price, Decimal percent) {
        if (price == null || percent == null) {
            return 0;
        }
        return price * (1 + (percent / FULL_PERCENT));
    }
}
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

    /**
     * @param price Listing price
     * @param candidate Price to compare
     * @param percent Allowed percent above and below the listing price
     * @return True when the candidate sits inside the price band
     * @example
     * Boolean similar = DemoListingHelper.isWithinBand(500000, 550000, 20);
     */
    public static Boolean isWithinBand(Decimal price, Decimal candidate, Decimal percent) {
        if (price == null || candidate == null || percent == null) {
            return false;
        }
        return candidate >= lowerPrice(price, percent) && candidate <= upperPrice(price, percent);
    }
}
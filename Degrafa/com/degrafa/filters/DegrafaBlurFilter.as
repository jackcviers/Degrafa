package com.degrafa.filters
{
    import flash.filters.BitmapFilter;
    import flash.filters.BlurFilter;

    /**
     * A bindable Degrafa-fied wrapper for flash.filters.BlurFilter.
     *
     * todo: poach documentation for filter properties from Flex SDK.
     *
     * @author josh
     */
    public class DegrafaBlurFilter extends DegrafaFilter
    {
        //--------------------------------------------------------------------------
        //
        //  Actual (proxied) filter
        //
        //--------------------------------------------------------------------------

        private var _bitmapFilter : BlurFilter;

        /**
         * @return the proxied flash.filters.BlurFilter
         */
        override public function get bitmapFilter() : BitmapFilter
        {
            return _bitmapFilter;
        }

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function DegrafaBlurFilter(blurX : Number = 4.0,
                                          blurY : Number = 4.0,
                                          quality : int = 1)
        {
            super();
            _bitmapFilter = new BlurFilter(blurX,
                                           blurY,
                                           quality);
        }

        //--------------------------------------------------------------------------
        //
        //  Work
        //
        //--------------------------------------------------------------------------

        //----------------------------------
        //  blurX
        //----------------------------------

        [Bindable("propertyChange")]
        public function get blurX() : Number
        {
            return _bitmapFilter.blurX;
        }

        public function set blurX(value : Number) : void
        {
            setValue("blurX", value);
        }

        //----------------------------------
        //  blurY
        //----------------------------------

        [Bindable("propertyChange")]
        public function get blurY() : Number
        {
            return _bitmapFilter.blurY;
        }

        public function set blurY(value : Number) : void
        {
            setValue("blurY", value);
        }

        //----------------------------------
        //  quality
        //----------------------------------

        [Bindable("propertyChange")]
        public function get quality() : int
        {
            return _bitmapFilter.quality;
        }

        public function set quality(value : int) : void
        {
            setValue("quality", value);
        }
    }
}
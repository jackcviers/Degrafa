package com.degrafa.filters
{
    import flash.filters.BevelFilter;
    import flash.filters.BitmapFilter;

    /**
     * A bindable Degrafa-fied wrapper for flash.filters.BevelFilter.
     *
     * todo: poach documentation for filter properties from Flex SDK.
     *
     * @author josh
     */
    public class DegrafaBevelFilter extends DegrafaFilter
    {
        //--------------------------------------------------------------------------
        //
        //  Actual (proxied) filter
        //
        //--------------------------------------------------------------------------

        private var _bitmapFilter : BevelFilter;

        /**
         * @return the proxied flash.filters.BevelFilter
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

        public function DegrafaBevelFilter(distance : Number = 4.0,
                                           angle : Number = 45,
                                           highlightColor : uint = 0xFFFFFF,
                                           highlightAlpha : Number = 1.0,
                                           shadowColor : uint = 0x000000,
                                           shadowAlpha : Number = 1.0,
                                           blurX : Number = 4.0,
                                           blurY : Number = 4.0,
                                           strength : Number = 1,
                                           quality : int = 1,
                                           type : String = "inner",
                                           knockout : Boolean = false)
        {
            super();
            _bitmapFilter = new BevelFilter(distance,
                                            angle,
                                            highlightColor,
                                            highlightAlpha,
                                            shadowColor,
                                            shadowAlpha,
                                            blurX,
                                            blurY,
                                            strength,
                                            quality,
                                            type,
                                            knockout);
        }

        //--------------------------------------------------------------------------
        //
        //  Work
        //
        //--------------------------------------------------------------------------

        //----------------------------------
        //  distance
        //----------------------------------

        [Bindable("propertyChange")]
        public function get distance() : Number
        {
            return _bitmapFilter.distance;
        }

        public function set distance(value : Number) : void
        {
            setValue("distance", value);
        }

        //----------------------------------
        //  angle
        //----------------------------------

        [Bindable("propertyChange")]
        public function get angle() : Number
        {
            return _bitmapFilter.angle;
        }

        public function set angle(value : Number) : void
        {
            setValue("angle", value);
        }

        //----------------------------------
        //  highlightColor
        //----------------------------------

        [Bindable("propertyChange")]
        public function get highlightColor() : uint
        {
            return _bitmapFilter.highlightColor;
        }

        public function set highlightColor(value : uint) : void
        {
            setValue("highlightColor", value);
        }

        //----------------------------------
        //  highlightAlpha
        //----------------------------------

        [Bindable("propertyChange")]
        public function get highlightAlpha() : Number
        {
            return _bitmapFilter.highlightAlpha;
        }

        public function set highlightAlpha(value : Number) : void
        {
            setValue("highlightAlpha", value);
        }

        //----------------------------------
        //  shadowColor
        //----------------------------------

        [Bindable("propertyChange")]
        public function get shadowColor() : uint
        {
            return _bitmapFilter.shadowColor;
        }

        public function set shadowColor(value : uint) : void
        {
            setValue("shadowColor", value);
        }

        //----------------------------------
        //  shadowAlpha
        //----------------------------------

        [Bindable("propertyChange")]
        public function get shadowAlpha() : Number
        {
            return _bitmapFilter.shadowAlpha;
        }

        public function set shadowAlpha(value : Number) : void
        {
            setValue("shadowAlpha", value);
        }

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
        //  strength
        //----------------------------------

        [Bindable("propertyChange")]
        public function get strength() : Number
        {
            return _bitmapFilter.strength;
        }

        public function set strength(value : Number) : void
        {
            setValue("strength", value);
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

        //----------------------------------
        //  type
        //----------------------------------

        [Bindable("propertyChange")]
        public function get type() : String
        {
            return _bitmapFilter.type;
        }

        public function set type(value : String) : void
        {
            setValue("type", value);
        }

        //----------------------------------
        //  knockout
        //----------------------------------

        [Bindable("propertyChange")]
        public function get knockout() : Boolean
        {
            return _bitmapFilter.knockout;
        }

        public function set knockout(value : Boolean) : void
        {
            setValue("knockout", value);
        }
    }
}
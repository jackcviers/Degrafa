package com.degrafa.filters
{
    import flash.filters.BitmapFilter;
    import flash.filters.GlowFilter;

    /**
     * A bindable Degrafa-fied wrapper for flash.filters.GlowFilter.
     *
     * todo: poach documentation for filter properties from Flex SDK.
     *
     * @author josh
     */
    public class DegrafaGlowFilter extends DegrafaFilter
    {
        //--------------------------------------------------------------------------
        //
        //  Actual (proxied) filter
        //
        //--------------------------------------------------------------------------

        private var _bitmapFilter : GlowFilter;

        /**
         * @return the proxied flash.filters.GlowFilter
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

        public function DegrafaGlowFilter(color : uint = 0xFF0000,
                                          alpha : Number = 1.0,
                                          blurX : Number = 6.0,
                                          blurY : Number = 6.0,
                                          strength : Number = 2,
                                          quality : int = 1,
                                          inner : Boolean = false,
                                          knockout : Boolean = false)
        {
            super();
            _bitmapFilter = new GlowFilter(color,
                                           alpha,
                                           blurX,
                                           blurY,
                                           strength,
                                           quality,
                                           inner,
                                           knockout);
        }

        //--------------------------------------------------------------------------
        //
        //  Work
        //
        //--------------------------------------------------------------------------

        //----------------------------------
        //  color
        //----------------------------------

        [Bindable("propertyChange")]
        public function get color() : uint
        {
            return _bitmapFilter.color;
        }

        public function set color(value : uint) : void
        {
            setValue("color", value);
        }

        //----------------------------------
        //  alpha
        //----------------------------------

        [Bindable("propertyChange")]
        public function get alpha() : Number
        {
            return _bitmapFilter.alpha;
        }

        public function set alpha(value : Number) : void
        {
            setValue("alpha", value);
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
        //  inner
        //----------------------------------

        [Bindable("propertyChange")]
        public function get inner() : Boolean
        {
            return _bitmapFilter.inner;
        }

        public function set inner(value : Boolean) : void
        {
            setValue("inner", value);
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
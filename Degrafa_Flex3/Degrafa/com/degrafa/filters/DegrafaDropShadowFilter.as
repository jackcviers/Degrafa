package com.degrafa.filters
{
    import flash.filters.BitmapFilter;
    import flash.filters.DropShadowFilter;

    /**
     * A bindable Degrafa-fied wrapper for flash.filters.DropShadowFilter.
     *
     * todo: poach documentation for filter properties from Flex SDK.
     *
     * @author josh
     */
    public class DegrafaDropShadowFilter extends DegrafaFilter
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function DegrafaDropShadowFilter(distance : Number = 4.0,
                                                angle : Number = 45,
                                                color : uint = 0,
                                                alpha : Number = 1.0,
                                                blurX : Number = 4.0,
                                                blurY : Number = 4.0,
                                                strength : Number = 1.0,
                                                quality : int = 1,
                                                inner : Boolean = false,
                                                knockout : Boolean = false,
                                                hideObject : Boolean = false)
        {
            super();
            _bitmapFilter = new DropShadowFilter(distance,
                                                  angle,
                                                  color,
                                                  alpha,
                                                  blurX,
                                                  blurY,
                                                  strength,
                                                  quality,
                                                  inner,
                                                  knockout,
                                                  hideObject);
        }

        //--------------------------------------------------------------------------
        //
        //  Actual (proxied) filter
        //
        //--------------------------------------------------------------------------

        private var _bitmapFilter : DropShadowFilter;

        /**
         * @return the proxied flash.filters.DropShadowFilter
         */
        override public function get bitmapFilter() : BitmapFilter
        {
            return _bitmapFilter;
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
        //  color
        //----------------------------------

        [Bindable("propertyChange")]
        public function get color() : Number
        {
            return _bitmapFilter.color;
        }

        public function set color(value : Number) : void
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
        public function get quality() : Number
        {
            return _bitmapFilter.quality;
        }

        public function set quality(value : Number) : void
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

        //----------------------------------
        //  hideObject
        //----------------------------------

        [Bindable("propertyChange")]
        public function get hideObject() : Boolean
        {
            return _bitmapFilter.hideObject;
        }

        public function set hideObject(value : Boolean) : void
        {
            setValue("hideObject", value);
        }
    }
}
package com.degrafa.filters
{
    import flash.filters.BitmapFilter;
    import flash.filters.GradientGlowFilter;

    /**
     * A bindable Degrafa-fied wrapper for flash.filters.GradientGlowFilter.
     *
     * todo: poach documentation for filter properties from Flex SDK.
     *
     * @author josh
     */
    public class DegrafaGradientGlowFilter extends DegrafaFilter
    {
        //--------------------------------------------------------------------------
        //
        //  Actual (proxied) filter
        //
        //--------------------------------------------------------------------------

        private var _bitmapFilter : GradientGlowFilter;

        /**
         * @return the proxied flash.filters.GradientGlowFilter
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

        public function DegrafaGradientGlowFilter(distance : Number = 4.0,
                                                  angle : Number = 45,
                                                  colors : Array = null,
                                                  alphas : Array = null,
                                                  ratios : Array = null,
                                                  blurX : Number = 4.0,
                                                  blurY : Number = 4.0,
                                                  strength : Number = 1,
                                                  quality : int = 1,
                                                  type : String = "inner",
                                                  knockout : Boolean = false)
        {
            super();
            _bitmapFilter = new GradientGlowFilter(distance,
                                                   angle,
                                                   colors,
                                                   alphas,
                                                   ratios,
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
        //  colors
        //----------------------------------

        [Bindable("propertyChange")]
        public function get colors() : Array
        {
            return _bitmapFilter.colors;
        }

        public function set colors(value : Array) : void
        {
            setValue("colors", value);
        }

        //----------------------------------
        //  alphas
        //----------------------------------

        [Bindable("propertyChange")]
        public function get alphas() : Array
        {
            return _bitmapFilter.alphas;
        }

        public function set alphas(value : Array) : void
        {
            setValue("alphas", value);
        }

        //----------------------------------
        //  ratios
        //----------------------------------

        [Bindable("propertyChange")]
        public function get ratios() : Array
        {
            return _bitmapFilter.ratios;
        }

        public function set ratios(value : Array) : void
        {
            setValue("ratios", value);
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
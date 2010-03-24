package com.degrafa.filters
{
    import flash.filters.BitmapFilter;
    import flash.filters.ConvolutionFilter;

    /**
     * A bindable Degrafa-fied wrapper for flash.filters.ConvolutionFilter.
     *
     * todo: poach documentation for filter properties from Flex SDK.
     *
     * @author josh
     */
    public class DegrafaConvolutionFilter extends DegrafaFilter
    {
        //--------------------------------------------------------------------------
        //
        //  Actual (proxied) filter
        //
        //--------------------------------------------------------------------------

        private var _bitmapFilter : ConvolutionFilter;

        /**
         * @return the proxied flash.filters.ConvolutionFilter
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

        public function DegrafaConvolutionFilter(matrixX : Number = 0,
                                                 matrixY : Number = 0,
                                                 matrix : Array = null,
                                                 divisor : Number = 1.0,
                                                 bias : Number = 0.0,
                                                 preserveAlpha : Boolean = true,
                                                 clamp : Boolean = true,
                                                 color : uint = 0,
                                                 alpha : Number = 0.0)
        {
            super();
            _bitmapFilter = new ConvolutionFilter(matrixX,
                                                  matrixY,
                                                  matrix,
                                                  divisor,
                                                  bias,
                                                  preserveAlpha,
                                                  clamp,
                                                  color,
                                                  alpha);
        }

        //--------------------------------------------------------------------------
        //
        //  Work
        //
        //--------------------------------------------------------------------------

        //----------------------------------
        //  matrixX
        //----------------------------------

        [Bindable("propertyChange")]
        public function get matrixX() : Number
        {
            return _bitmapFilter.matrixX;
        }

        public function set matrixX(value : Number) : void
        {
            setValue("matrixX", value);
        }

        //----------------------------------
        //  matrixY
        //----------------------------------

        [Bindable("propertyChange")]
        public function get matrixY() : Number
        {
            return _bitmapFilter.matrixY;
        }

        public function set matrixY(value : Number) : void
        {
            setValue("matrixY", value);
        }

        //----------------------------------
        //  matrix
        //----------------------------------

        [Bindable("propertyChange")]
        public function get matrix() : Array
        {
            return _bitmapFilter.matrix;
        }

        public function set matrix(value : Array) : void
        {
            setValue("matrix", value);
        }

        //----------------------------------
        //  divisor
        //----------------------------------

        [Bindable("propertyChange")]
        public function get divisor() : Number
        {
            return _bitmapFilter.divisor;
        }

        public function set divisor(value : Number) : void
        {
            setValue("divisor", value);
        }

        //----------------------------------
        //  bias
        //----------------------------------

        [Bindable("propertyChange")]
        public function get bias() : Number
        {
            return _bitmapFilter.bias;
        }

        public function set bias(value : Number) : void
        {
            setValue("bias", value);
        }

        //----------------------------------
        //  preserveAlpha
        //----------------------------------

        [Bindable("propertyChange")]
        public function get preserveAlpha() : Boolean
        {
            return _bitmapFilter.preserveAlpha;
        }

        public function set preserveAlpha(value : Boolean) : void
        {
            setValue("preserveAlpha", value);
        }

        //----------------------------------
        //  clamp
        //----------------------------------

        [Bindable("propertyChange")]
        public function get clamp() : Boolean
        {
            return _bitmapFilter.clamp;
        }

        public function set clamp(value : Boolean) : void
        {
            setValue("clamp", value);
        }

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
    }
}
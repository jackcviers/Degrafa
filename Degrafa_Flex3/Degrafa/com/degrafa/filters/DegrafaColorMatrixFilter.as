package com.degrafa.filters
{
    import flash.filters.BitmapFilter;
    import flash.filters.ColorMatrixFilter;

    /**
     * A bindable Degrafa-fied wrapper for flash.filters.ColorMatrixFilter.
     *
     * todo: poach documentation for filter properties from Flex SDK.
     *
     * @author josh
     */
    public class DegrafaColorMatrixFilter extends DegrafaFilter
    {
        //--------------------------------------------------------------------------
        //
        //  Actual (proxied) filter
        //
        //--------------------------------------------------------------------------

        private var _bitmapFilter : ColorMatrixFilter;

        /**
         * @return the proxied flash.filters.ColorMatrixFilter
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

        public function DegrafaColorMatrixFilter(matrix : Array = null)
        {
            super();
            _bitmapFilter = new ColorMatrixFilter(matrix);
        }

        //--------------------------------------------------------------------------
        //
        //  Work
        //
        //--------------------------------------------------------------------------

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
    }
}
package com.degrafa.filters
{
    import flash.display.BitmapData;
    import flash.filters.BitmapFilter;
    import flash.filters.DisplacementMapFilter;
    import flash.geom.Point;

    /**
     * A bindable Degrafa-fied wrapper for flash.filters.DisplacementMapFilter.
     *
     * todo: poach documentation for filter properties from Flex SDK.
     *
     * @author josh
     */
    public class DegrafaDisplacementMapFilter extends DegrafaFilter
    {
        //--------------------------------------------------------------------------
        //
        //  Actual (proxied) filter
        //
        //--------------------------------------------------------------------------

        private var _bitmapFilter : DisplacementMapFilter;

        /**
         * @return the proxied flash.filters.DisplacementMapFilter
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

        public function DegrafaDisplacementMapFilter(mapBitmap : BitmapData = null,
                                                     mapPoint : Point = null,
                                                     componentX : uint = 0,
                                                     componentY : uint = 0,
                                                     scaleX : Number = 0.0,
                                                     scaleY : Number = 0.0,
                                                     mode : String = "wrap",
                                                     color : uint = 0,
                                                     alpha : Number = 0.0)
        {
            super();
            _bitmapFilter = new DisplacementMapFilter(mapBitmap,
                                                      mapPoint,
                                                      componentX,
                                                      componentY,
                                                      scaleX,
                                                      scaleY,
                                                      mode,
                                                      color,
                                                      alpha);
        }

        //--------------------------------------------------------------------------
        //
        //  Work
        //
        //--------------------------------------------------------------------------

        //----------------------------------
        //  mapBitmap
        //----------------------------------

        [Bindable("propertyChange")]
        public function get mapBitmap() : BitmapData
        {
            return _bitmapFilter.mapBitmap;
        }

        public function set mapBitmap(value : BitmapData) : void
        {
            setValue("mapBitmap", value);
        }

        //----------------------------------
        //  mapPoint
        //----------------------------------

        [Bindable("propertyChange")]
        public function get mapPoint() : Point
        {
            return _bitmapFilter.mapPoint;
        }

        public function set mapPoint(value : Point) : void
        {
            setValue("mapPoint", value);
        }

        //----------------------------------
        //  componentX
        //----------------------------------

        [Bindable("propertyChange")]
        public function get componentX() : uint
        {
            return _bitmapFilter.componentX;
        }

        public function set componentX(value : uint) : void
        {
            setValue("componentX", value);
        }

        //----------------------------------
        //  componentY
        //----------------------------------

        [Bindable("propertyChange")]
        public function get componentY() : uint
        {
            return _bitmapFilter.componentY;
        }

        public function set componentY(value : uint) : void
        {
            setValue("componentY", value);
        }

        //----------------------------------
        //  scaleX
        //----------------------------------

        [Bindable("propertyChange")]
        public function get scaleX() : Number
        {
            return _bitmapFilter.scaleX;
        }

        public function set scaleX(value : Number) : void
        {
            setValue("scaleX", value);
        }

        //----------------------------------
        //  scaleY
        //----------------------------------

        [Bindable("propertyChange")]
        public function get scaleY() : Number
        {
            return _bitmapFilter.scaleY;
        }

        public function set scaleY(value : Number) : void
        {
            setValue("scaleY", value);
        }

        //----------------------------------
        //  mode
        //----------------------------------

        [Bindable("propertyChange")]
        public function get mode() : String
        {
            return _bitmapFilter.mode;
        }

        public function set mode(value : String) : void
        {
            setValue("mode", value);
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
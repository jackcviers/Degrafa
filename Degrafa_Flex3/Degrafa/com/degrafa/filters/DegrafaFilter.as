package com.degrafa.filters
{
    import com.degrafa.core.DegrafaObject;

    import flash.filters.BitmapFilter;

    /**
     * Base for all filter proxies required to support bindings and states
     * @author josh
     *
     */
    public class DegrafaFilter extends DegrafaObject
    {
        public function DegrafaFilter()
        {
            super();
        }

        /**
         * Returns the actual filter to be applied
         * @return the native BitmapFilter instance - subclasses to override :)
         */
        public function get bitmapFilter() : BitmapFilter
        {
            throw new Error("Subclass to override get bitmapFilter()");
        }

        /**
         * To cut down on boilerplate in subclasses. Boilerplate would of course be faster.
         *
         * todo: replace with boilerplate - the list of filters ain't gonna change soon :D
         *
         * @param name
         * @param value
         *
         */
        protected function setValue(name : String, value : *) : void
        {
            var oldValue : * = bitmapFilter[name];

            if (oldValue == value)
                return;

            bitmapFilter[name] = value;
            dispatchPropertyChange(false, name, oldValue, value);
        }

        //TODO - Josh: impl this :)

//        private var _enabled : Boolean = true;
//
//        //TODO: Custom bindable event
//        [Bindable]
//        /**
//         * If false, this effect will not be applied
//         */
//        public function get enabled() : Boolean
//        {
//            return _enabled;
//        }
//
//        public function set enabled(value : Boolean) : void
//        {
//            _enabled = value;
//        }
//
//        private var _state : String;
//
//        //TODO: Custom bindable event
//        [Bindable]
//        /**
//         * The state at which to apply this filter. This property is specific to Skinning.
//         */
//        public function get state() : String
//        {
//            return state;
//        }
//
//        public function set state(value : String) : void
//        {
//            _state = value;
//        }
    }
}
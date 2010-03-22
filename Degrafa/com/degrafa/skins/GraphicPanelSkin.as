package com.degrafa.skins
{
    import com.degrafa.core.IGraphicSkin;
    import com.degrafa.states.IDegrafaStateClient;
    
    import flash.events.Event;
    
    import mx.containers.Panel;
    import mx.core.mx_internal;
    import mx.skins.halo.PanelSkin;
    use namespace mx_internal;

    [Exclude(name="graphicsData", kind="property")]
    [Exclude(name="percentWidth", kind="property")]
    [Exclude(name="percentHeight", kind="property")]
    [Exclude(name="target", kind="property")]

    [DefaultProperty("geometry")]

    [Bindable(event="propertyChange")]

    public class GraphicPanelSkin extends PanelSkin implements IGraphicSkin, IDegrafaStateClient
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function GraphicPanelSkin()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        //--------------------------------------------------------------------------
        //
        //  Make headerHeight easy to get to!
        //
        //--------------------------------------------------------------------------

        [Bindable]
        protected var headerHeight:Number;
        
        //--------------------------------------------------------------------------
        //
        //  Overrides
        //
        //--------------------------------------------------------------------------

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            headerHeight = parent is Panel ? Object(parent).mx_internal::getHeaderHeightProxy() : 0;

            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            // Another wonderful side effect of lacking real mixins
            mixin_updateDisplayList(unscaledWidth, unscaledHeight);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Guts of it!
        //
        //--------------------------------------------------------------------------

        // If only we had real mixins... or, you know, the Halo class Hierarchy wasn't retarded.
        include "DegrafaSkinMixin.as.inc";
    }
}
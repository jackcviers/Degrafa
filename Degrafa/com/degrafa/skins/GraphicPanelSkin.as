package com.degrafa.skins
{
    import com.degrafa.core.IGraphicSkin;
    import com.degrafa.core.IGraphicsFill;
    import com.degrafa.core.IGraphicsStroke;
    import com.degrafa.core.collections.FillCollection;
    import com.degrafa.core.collections.GeometryCollection;
    import com.degrafa.core.collections.StrokeCollection;
    import com.degrafa.geometry.Geometry;
    import com.degrafa.states.IDegrafaStateClient;
    import com.degrafa.states.State;
    import com.degrafa.states.StateManager;
    import com.degrafa.triggers.ITrigger;
    
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    import mx.core.mx_internal;
    import mx.events.PropertyChangeEvent;
    import mx.events.PropertyChangeEventKind;
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
        public function GraphicPanelSkin()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        // If only we had real mixins... or, you know, the Halo class Hierarchy wasn't retarded.
        include "DegrafaSkinMixin.as.inc";
    }
}
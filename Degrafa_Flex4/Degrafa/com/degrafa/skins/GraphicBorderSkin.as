////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008 The Degrafa Team : http://www.Degrafa.com/team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////
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
    import mx.skins.Border;
    use namespace mx_internal;


    [Exclude(name="graphicsData", kind="property")]
    [Exclude(name="percentWidth", kind="property")]
    [Exclude(name="percentHeight", kind="property")]
    [Exclude(name="target", kind="property")]

    [DefaultProperty("geometry")]

    [Bindable(event="propertyChange")]

    /**
     * GraphicBorderSkin is an extension of Border for use declarativly.
     **/
    public class GraphicBorderSkin extends Border implements IGraphicSkin, IDegrafaStateClient
    {
        public function GraphicBorderSkin()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            // Another wonderful side effect of lacking real mixins
            mixin_updateDisplayList(unscaledWidth, unscaledHeight);
        }

        // If only we had real mixins... or, you know, the Halo class Hierarchy wasn't retarded.
        include "DegrafaSkinMixin.as.inc";
    }
}
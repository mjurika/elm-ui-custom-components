customElements.define('map-view', class extends HTMLElement {

    /* #region [Constructor] */

    constructor() {
        super();

        this._map = null;
        this._view = null;
        this._basemap = null;
    }

    /* #endregion [Constructor] */


    /* #region [Properties] */

    get baseMap() {
        return this._basemap;
    }

    set baseMap(value) {
        this._basemap = value;
        if (this._map) {
            this._map.basemap = value;
        }
    }

    /* #endregion [Properties] */


    /* #region [Event handlers] */

    /* #endregion [Event handlers] */


    /* #region [Callback] */

    connectedCallback() {
        var that = this;

        // Create map
        require([
            "esri/Map",
            "esri/views/SceneView",
            "esri/geometry/Point",
            "esri/Graphic",
            "esri/layers/GraphicsLayer"
        ], function (Map, SceneView, Point, Graphic, GraphicsLayer) {
            that._map = new Map({
                basemap: that._basemap,
                ground: "world-elevation"
            });
            that._view = new SceneView({
                container: that,
                map: that._map,
                center: [19.5, 48.7],
                zoom: 17
            });

            var graphicsLayer = new GraphicsLayer();
            that._map.add(graphicsLayer);

            var symbol = {
                type: "point-3d",  // autocasts as new PointSymbol3D()
                symbolLayers: [{
                    type: "object",  // autocasts as new ObjectSymbol3DLayer()
                    width: 5,    // diameter of the object from east to west in meters
                    height: 10,  // height of object in meters
                    depth: 15,   // diameter of the object from north to south in meters
                    resource: { primitive: "sphere" },
                    material: { color: "red" }
                }],
                verticalOffset: {
                    screenLength: 40,
                    maxWorldLength: 100,
                    minWorldLength: 20
                },
                callout: {
                    type: "line",  // autocasts as new LineCallout3D()
                    size: 1.5,
                    color: [150, 150, 150],
                    border: {
                        color: [50, 50, 50]
                    }
                }
            };

            var point = new Point({
                longitude: 19.5,
                latitude: 48.7
            });
            var pointGraphic = new Graphic({
                geometry: point,
                symbol: symbol
            });
            debugger;

            graphicsLayer.add(pointGraphic);
        });
    }

    /* #endregion [Callback] */
})
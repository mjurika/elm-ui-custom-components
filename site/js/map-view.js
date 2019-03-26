customElements.define('map-view', class extends HTMLElement {

    /* #region [Constructor] */

    constructor() {
        super();

        this._map = null;
        this._view = null;
        this._basemap = null;
        this._showPosition = null;

        this._outlineGraphic = null;
        this._graphic = null;
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

    set position(value) {
        if (!value) {
            return;
        }

        this._showPosition(value);
    }

    /* #endregion [Properties] */


    /* #region [Callback] */

    connectedCallback() {
        var that = this;

        // Create map
        require([
            "esri/Map",
            "esri/views/SceneView",
            "esri/Graphic",
            "esri/geometry/Circle",
            "esri/geometry/support/jsonUtils",
        ], function (Map, SceneView, Graphic, Circle, geometryJsonUtils) {
            // Init map and view
            that._map = new Map({
                basemap: that._basemap,
                ground: "world-elevation"
            });

            that._view = new SceneView({
                container: that,
                map: that._map,
                camera: {
                    position: {
                        latitude: 43.68,
                        longitude: 19.53,
                        z: 543500
                    },
                    tilt: 45,
                    heading: 0
                }
            });


            /**
             * Sets the scene extent using goTo method.
             * 
             * @param {object} extent Scene extent/geometry.
             */
            that._setExtent = function (extent) {
                if (!extent.spatialReference) {
                    extent.spatialReference = that._view.spatialReference.toJSON();
                }

                if (!extent.declaredClass) {
                    extent = geometryJsonUtils.fromJSON(extent);
                }

                return that._view.goTo({
                    target: extent
                });
            };


            /**
             * Show location.
             * 
             * @param {object} value Gelocation.
             */
            that._showPosition = function (value) {
                var point = {
                    type: "point",
                    latitude: value.latitude,
                    longitude: value.longitude,
                    spatialReference: {
                        wkid: 102100
                    }
                };

                var location = new Circle({
                    center: point,
                    radius: value.accuracy,
                    geodesic: true,
                    radiusUnit: "meters"
                });

                if (that._outlineGraphic && that._graphic) {
                    that._view.graphics.remove(that._outlineGraphic);
                    that._view.graphics.remove(that._graphic);
                }

                that._outlineGraphic = new Graphic({
                    geometry: location,
                    symbol: {
                        type: "simple-fill",
                        color: [0, 145, 234, 0.12],
                        outline: {
                            color: [0, 145, 234],
                            width: 0.3
                        }
                    }
                });

                that._graphic = new Graphic({
                    geometry: point,
                    symbol: {
                        type: "simple-marker",
                        style: "circle",
                        color: [0, 145, 234],
                        size: 8,
                        outline: {
                            type: "simple-line",
                            color: [255, 255, 255],
                            width: 1.3
                        }
                    }
                });

                that._view.graphics.add(that._outlineGraphic);
                that._view.graphics.add(that._graphic);

                that._setExtent(that._outlineGraphic);
            };
        });
    }

    /* #endregion [Callback] */
})
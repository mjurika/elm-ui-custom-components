customElements.define('map-view', class extends HTMLElement {

    /* #region [Constructor] */

    constructor() {
        super();

        this._map = null;
        this._view = null;
        this._basemap = null;
        this._measurement = null;
        this._showPosition = null;

        this._outlineGraphic = null;
        this._graphic = null;
        this._activeWidget = null;
        this._pointGraphic = null;
    }

    /* #endregion [Constructor] */


    /* #region [Properties] */

    /**
     * Return current basemap Id.
     */
    get baseMap() {
        return this._basemap;
    }


    /**
     * Sets current basemap Id.
     */
    set baseMap(value) {
        this._basemap = value;
        if (this._map) {
            this._map.basemap = value;
        }
    }


    /**
     * Return current measurement type.
     */
    get measurement() {
        return this._measurement;
    }


    /**
     * Sets current measurement type.
     */
    set measurement(value) {
        this._measurement = value;
        if (!this._setActiveWidget) {
            return;
        }
        this._setActiveWidget(value);
    }


    /**
     * Sets and shows position on map.
     */
    set position(value) {
        if (!value) {
            return;
        }

        this._showPosition(value);
    }


    /**
     * Goes to and shows geometry on map.
     */
    set location(geometry) {
        if (!geometry || !this._setExtent) {
            return;
        }
        geometry[0].extent.spatialReference = {
            wkid: 4326
        };
        this._setExtent(geometry[0].extent);
        this._addPointGraphic(geometry[0].location.x, geometry[0].location.y);
    }

    /* #endregion [Properties] */


    /* #region [Callback] */

    /**
     * Invoked each time the custom element is appended into a document-connected element.
     */
    connectedCallback() {
        var that = this;

        // Create map and define map functions
        require([
            "esri/Map",
            "esri/views/SceneView",
            "esri/Graphic",
            "esri/geometry/Circle",
            "esri/geometry/Point",
            "esri/geometry/support/jsonUtils",
            "esri/widgets/DirectLineMeasurement3D",
            "esri/widgets/AreaMeasurement3D"
        ], function (Map, SceneView, Graphic, Circle, Point, geometryJsonUtils, DirectLineMeasurement3D, AreaMeasurement3D) {
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


            /* #region [Map functions] */

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


            /**
             * Adds graphic to mark point.
             * 
             * @param {float} longitude Longitude.
             * @param {float} latitude Latitude.
             */
            that._addPointGraphic = function (longitude, latitude) {
                if (that._pointGraphic) {
                    that._view.graphics.remove(that._pointGraphic);
                }
                that._pointGraphic = new Graphic({
                    geometry: new Point({
                        longitude: longitude,
                        latitude: latitude
                    }),
                    symbol: {
                        type: "simple-marker",
                        style: "circle",
                        color: [244, 67, 54],
                        size: 8,
                        outline: {
                            type: "simple-line",
                            color: [255, 255, 255],
                            width: 1.3
                        }
                    }
                });
                that._view.graphics.add(that._pointGraphic);
            };


            /**
             * Sets active widget.
             * 
             * @param {string} type Type of widget.
             */
            that._setActiveWidget = function (type) {
                if (that._activeWidget) {
                    that._view.ui.remove(that._activeWidget);
                    that._activeWidget.destroy();
                    that._activeWidget = null;
                }

                switch (type) {
                    case "distance":
                        that._activeWidget = new DirectLineMeasurement3D({
                            view: that._view
                        });

                        that._activeWidget.viewModel.newMeasurement();
                        that._view.ui.add(that._activeWidget, "top-right");
                        break;
                    case "area":
                        that._activeWidget = new AreaMeasurement3D({
                            view: that._view
                        });

                        that._activeWidget.viewModel.newMeasurement();
                        that._view.ui.add(that._activeWidget, "top-right");
                        break;
                    case "none":
                        if (that._activeWidget) {
                            that._view.ui.remove(that._activeWidget);
                            that._activeWidget.destroy();
                            that._activeWidget = null;
                        }
                        break;
                }
            }

            /* #endregion [Map functions] */
        });
    }

    /* #endregion [Callback] */
})
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
            "esri/views/SceneView"
        ], function (Map, SceneView) {
            that._map = new Map({
                basemap: that._basemap,
                ground: "world-elevation"
            });
            that._view = new SceneView({
                container: that,
                map: that._map,
                center: [19.5, 48.7],
                zoom: 8
            });
        });
    }

    /* #endregion [Callback] */
})
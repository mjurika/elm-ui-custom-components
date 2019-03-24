
require([
    "esri/Map",
    "esri/views/SceneView"
], function (Map, SceneView) {
    customElements.define('map-view', class extends HTMLElement {

        /* #region [Constructor] */

        constructor() {
            super();
            debugger;

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
            debugger;
            this._basemap = value;
            this._map.basemap = value;
        }

        /* #endregion [Properties] */


        /* #region [Event handlers] */

        /* #endregion [Event handlers] */


        /* #region [Callback] */

        connectedCallback() {
            this._map = new Map({
                basemap: this._basemap,
                ground: "world-elevation"
            });
            this._view = new SceneView({
                container: this,
                map: this._map,
                center: [19.5, 48.7],
                zoom: 8
            });

            // this._map.basemap = "satellite";
            // this._map.basemap = "hybrid";
        }

        /* #endregion [Callback] */
    })
});



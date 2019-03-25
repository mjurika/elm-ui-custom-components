customElements.define('geo-location', class extends HTMLElement {

    /* #region [Constructor] */

    constructor() {
        super();
        
        this._triggerPosition = null;
        this._latitude = null;
        this._longtitude = null;
    }

    /* #endregion [Constructor] */


    /* #region [Properties] */

    get latitude() {
        return this._latitude;
    }

    set latitude(value) {
        this._latitude = value;
    }

    get longtitude() {
        return this._longtitude;
    }

    set longtitude(value) {
        this._longtitude = value;
    }

    get triggerPosition() {
        return this._triggerPosition;
    }

    set triggerPosition(value) {
        debugger;
        // Don't trigger on first set.
        var doit = this._triggerPosition !== null;
        this._triggerPosition = value;
        if (doit) {
            var that = this;
            function dispatch() {
                that.dispatchEvent(new CustomEvent('position'));
            }
            // Need to delay or Elm doesn't call view.
            window.setTimeout(dispatch, 1);        
        }
    }

    get position() {
        debugger;
        navigator.geolocation.getCurrentPosition(function(position) {
            return { 
                latitude: position.coords.latitude,
                longtitude: position.coords.longtitude
            }
        });
    }

    /* #endregion [Properties] */


    /* #region [Event handlers] */

    /* #endregion [Event handlers] */


    /* #region [Callback] */

    connectedCallback() {
        debugger;
        if ("geolocation" in navigator) {
            /* geolocation is available */
        } else {
            /* geolocation IS NOT available */
        }
    }

    /* #endregion [Callback] */
})
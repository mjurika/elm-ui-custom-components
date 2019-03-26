customElements.define('geo-location', class extends HTMLElement {

    /* #region [Constructor] */

    constructor() {
        super();

        this._triggerPosition = null;
        this._latitude = null;
        this._longitude = null;
        this._accuracy = null;
    }

    /* #endregion [Constructor] */


    /* #region [Properties] */

    get latitude() {
        return this._latitude;
    }

    set latitude(value) {
        this._latitude = value;
    }

    get longitude() {
        return this._longitude;
    }

    set longitude(value) {
        this._longitude = value;
    }

    get accuracy() {
        return this._accuracy;
    }

    set accuracy(value) {
        this._accuracy = value;
    }

    get triggerPosition() {
        return this._triggerPosition;
    }

    set triggerPosition(value) {
        // Don't trigger on first set.
        var doit = this._triggerPosition !== null;
        this._triggerPosition = value;
        if (!doit) {
            return;
        }

        var that = this;
        navigator.geolocation.getCurrentPosition(function (position) {
            that._latitude = position.coords.latitude;
            that._longitude = position.coords.longitude;
            that._accuracy = position.coords.accuracy;

            function dispatch() {
                that.dispatchEvent(new CustomEvent('position'));
            }
            // Need to delay or Elm doesn't call view.
            window.setTimeout(dispatch, 1);
        });
    }

    get position() {
        return {
            latitude: this.latitude,
            longitude: this.longitude,
            accuracy: this.accuracy
        }
    }

    /* #endregion [Properties] */


    /* #region [Callback] */

    connectedCallback() {

    }

    /* #endregion [Callback] */
})
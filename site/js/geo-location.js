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

    /**
     * Return latitude.
     */
    get latitude() {
        return this._latitude;
    }


    /**
     * Sets latitude.
     */
    set latitude(value) {
        this._latitude = value;
    }


    /**
     * Return longitude.
     */
    get longitude() {
        return this._longitude;
    }


    /**
     * Sets longitude.
     */
    set longitude(value) {
        this._longitude = value;
    }


    /**
     * Return accuracy.
     */
    get accuracy() {
        return this._accuracy;
    }


    /**
     * Sets accuracy.
     */
    set accuracy(value) {
        this._accuracy = value;
    }


    /**
     * Return triggerPosition.
     */
    get triggerPosition() {
        return this._triggerPosition;
    }


    /**
     * Triggers setting position.
     */
    set triggerPosition(value) {
        // Don't trigger on first set.
        var doit = this._triggerPosition !== null;
        this._triggerPosition = value;
        if (!doit || !navigator.geolocation) {
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


    /**
     * Returns current position.
     */
    get position() {
        return {
            latitude: this.latitude,
            longitude: this.longitude,
            accuracy: this.accuracy
        }
    }

    /* #endregion [Properties] */


    /* #region [Callback] */

    /**
     * Invoked each time the custom element is appended into a document-connected element.
     */
    connectedCallback() {

    }

    /* #endregion [Callback] */
})
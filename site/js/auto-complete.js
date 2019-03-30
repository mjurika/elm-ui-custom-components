customElements.define('auto-complete', class extends HTMLElement {

  /* #region [Constructor] */

  constructor() {
    super();
    this._autocomplete = null;
    this._data = null;
    this._label = null;
    this._value = null;
    this._magicKey = null;
    this._inputNode = null;

    this._html =
      (label) =>
        `<div class="row">
          <div class="input-field col s12">
            <i class="material-icons prefix">search</i>
            <input type="text" id="autocomplete-input" class="autocomplete">
            <label for="autocomplete-input">${label}</label>
          </div>
        </div>`;

    this.debounced = function (delay, fn) {
      let timerId;
      return function (...args) {
        if (timerId) {
          clearTimeout(timerId);
        }
        timerId = setTimeout(() => {
          fn(...args);
          timerId = null;
        }, delay);
      }
    }
  }

  /* #endregion [Constructor] */


  /* #region [Properties] */

  get data() {
    return this._data;
  }

  set data(value) {
    this._data = value;
    if (!value || value.length < 0) {
      return;
    }

    var update = {}
    for (var i = 0, len = value.length; i < len; i++) {
      update[value[i].text] = null;
    }

    this._autocomplete.updateData(update);
  }

  get label() {
    return this._label;
  }

  set label(value) {
    this._label = value;
  }

  get value() {
    return this._value;
  }

  set value(value) {
    this._value = value;
  }

  get magicKey() {
    return this._magicKey;
  }

  set magicKey(value) {
    this._magicKey = value;
  }

  /* #endregion [Properties] */


  /* #region [Event handlers] */

  /**
   * 
   * @param {object} Event arguments.
   * 
   *  Event handler for autocomplete input.
   *  Sets value property and dispatches event.
   */
  _on_input(e) {
    if (!(e && e.target && e.target.value)) {
      return;
    }

    this._value = e.target.value;
    var that = this
    function dispatch() {
      that.dispatchEvent(new CustomEvent("onInput"));
    }
    // Need to delay or Elm doesn't call view.
    window.setTimeout(dispatch, 1);
  };


  /**
   * 
   * @param {object} Event arguments.
   * 
   *  Event handler for autocompleted event.
   *  Sets magicKey property and dispatches event.
   */
  _on_autocomplete(value) {
    this._magicKey = null;
    for (var i = 0, len = this.data.length; i < len; i++) {
      if (this.data[i].text === value) {
        this._magicKey = this.data[i].magicKey;
        break;
      }
    }

    if (!this._magicKey) {
      return;
    }

    var that = this
    function dispatch() {
      that.dispatchEvent(new CustomEvent("onAutocomplete"));
    }
    // Need to delay or Elm doesn't call view.
    window.setTimeout(dispatch, 1);
  };

  /* #endregion [Event handlers] */


  /* #region [Callback] */

  connectedCallback() {
    // Set element innerHtml
    this.innerHTML = this._html(this.label);
    this._inputNode = this.querySelector("input");
    // Init autocomplete
    this._autocomplete = M.Autocomplete.init(this._inputNode, {
      onAutocomplete: this._on_autocomplete.bind(this)
    });

    // Set input eventhandler function
    this._inputNode.addEventListener("input", this.debounced(300, this._on_input.bind(this)), false);
  }

  /* #endregion [Callback] */
})
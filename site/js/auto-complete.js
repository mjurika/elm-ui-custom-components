customElements.define('auto-complete', class extends HTMLElement {

  /* #region [Constructor] */

  constructor() {
    super();
    this._autocomplete = null;
    this._data = null;
    this._label = null;
    this._value = null;

    this._html =
      (label) =>
        `<div class="row">
          <div class="input-field col s12">
            <i class="material-icons prefix">search</i>
            <input type="text" id="autocomplete-input" class="autocomplete">
            <label for="autocomplete-input">${label}</label>
          </div>
        </div>`;
  }

  /* #endregion [Constructor] */


  /* #region [Properties] */

  get data() {
    return this._data;
  }

  set data(value) {
    this._data = value;
    if (!value) {
      return;
    }
    var update = {}
    for (var i = 0, len = value.length; i < len; i++) {
      update[value[i].text] = null;
    }
    
    this._autocomplete.updateData(update);
    this._autocomplete.open();
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

  /* #endregion [Properties] */


  /* #region [Event handlers] */

  /**
   * 
   * @param {string} baseMap
   * 
   *  Event handler for button click.
   *  Sets baseMap property and dispatches event.
   */
  _on_input(value) {
    this._value = value;
    var that = this
    function dispatch() {
      that.dispatchEvent(new CustomEvent("onInput"));
    }
    // Need to delay or Elm doesn't call view.
    window.setTimeout(dispatch, 1);
  };

  /* #endregion [Event handlers] */


  /* #region [Callback] */

  connectedCallback() {
    // Set element innerHtml
    this.innerHTML = this._html(this.label);
    var inputNode = this.querySelector("input");
    // Init autocomplete
    this._autocomplete = M.Autocomplete.init(inputNode, {});

    // Set input eventhandler function
    inputNode.addEventListener("input", this._on_input.bind(this));
    inputNode.addEventListener("blur", this._on_focus);
  }

  /* #endregion [Callback] */
})
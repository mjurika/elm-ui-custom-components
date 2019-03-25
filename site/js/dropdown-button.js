customElements.define('dropdown-button', class extends HTMLElement {

  /* #region [Constructor] */

  constructor() {
    super();
    this._title = null;
    this._baseMap = null;
    this._dropdownItems = [];

    this._wrapperHtml =
      (title, items) =>
        `<a class="dropdown-trigger btn" href="#" data-target="${title}">${title}</a>
          <ul id="${title}" class="dropdown-content">
            ${items}
          </ul>`;
    this._itemHtml =
      (title, baseMap) =>
        `<li><a href="#!" data-click="${baseMap}">${title}</a></li>`;
  }

  /* #endregion [Constructor] */


  /* #region [Properties] */

  get dropdownTitle() {
    return this._title;
  }

  set dropdownTitle(value) {
    this._title = value;
  }

  get dropdownItems() {
    let itemsHtml = "";
    this._dropdownItems.forEach(function (item) {
      itemsHtml += this._itemHtml(item.title, item.baseMap);
    }, this);
    return itemsHtml;
  }

  set dropdownItems(value) {
    this._dropdownItems = value;
  }

  get baseMap() {
    return this._baseMap;
  }

  set baseMap(value) {
    this._baseMap = value;
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
  _on_click(baseMap) {
    this._baseMap = baseMap;
    var that = this
    function dispatch() {
      that.dispatchEvent(new CustomEvent("btnClicked"));
    }
    // Need to delay or Elm doesn't call view.
    window.setTimeout(dispatch, 1);
  };

  /* #endregion [Event handlers] */


  /* #region [Callback] */

  connectedCallback() {
    // Set element innerHtml
    this.innerHTML = this._wrapperHtml(this.dropdownTitle, this.dropdownItems);
    // Init MAterialize dropdown
    this._instance = M.Dropdown.init(this.querySelector('.dropdown-trigger'), {});

    // Set click eventhandler function
    var that = this;
    this.querySelectorAll("[data-click]").forEach((btn) => {
      btn.addEventListener('click', (e) => {
        that._on_click(e.target.dataset.click);
      });
    });
  }

  /* #endregion [Callback] */
})
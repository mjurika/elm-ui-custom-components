
(function () {
  customElements.define('dropdown-button', class extends HTMLElement {

    constructor() {
      super();
      this._title = null;
      this._dropdownItems = [];

      this._wrapperHtml =
        (title, items) =>
          `<a class="dropdown-trigger btn" href="#" data-target="${title}">${title}</a>
          <ul id="${title}" class="dropdown-content">
            ${items}
          </ul>`;
      this._itemHtml =
        (title, action) =>
          `<li><a href="#!" onClick="action('${action}')">${title}</a></li>`;
    }

    get dropdownTitle() {
      return this._title;
    }

    set dropdownTitle(value) {
      this._title = value;
    }

    get dropdownItems() {
      let itemsHtml = "";
      this._dropdownItems.forEach(function (item) {
        itemsHtml += this._itemHtml(item.title, item.action);
      }, this);
      return itemsHtml;
    }

    set dropdownItems(value) {
      this._dropdownItems = JSON.parse(value);
    }

    connectedCallback() {
      this.innerHTML = this._wrapperHtml(this.dropdownTitle, this.dropdownItems);
      this._instance = M.Dropdown.init(this.querySelector('.dropdown-trigger'), {});

      window.action = function (action) {
        function dispatch() {
          this.dispatchEvent(new CustomEvent(action));
        }
        // Need to delay or Elm doesn't call view.
        window.setTimeout(dispatch, 1);
      };
    }
  })
})();


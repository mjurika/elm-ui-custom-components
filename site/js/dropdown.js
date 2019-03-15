
(function () {
  customElements.define('dropdown-button', class extends HTMLElement {

    constructor() {
      super();
      this._title = "Default title";
      this._item = "ONE";

      this._html = 
        (title, item) => 
          `<a class="dropdown-trigger btn" href="#" data-target="dropdown1">${title}</a>
          <ul id="dropdown1" class="dropdown-content">
            <li><a href="#!">${item}</a></li>
            <li><a href="#!">two</a></li>
            <li><a href="#!">three</a></li>
            <li><a href="#!"><i class="material-icons">view_module</i>four</a></li>
            <li><a href="#!"><i class="material-icons">cloud</i>five</a></li>
          </ul>`;
    }

    get dropdownTitle() {
      return this._title;
    }

    set dropdownTitle(value) {
      this._title = value;
    }

    connectedCallback() {
      this.innerHTML =this._html(this._title, this._item);
      this._instance = M.Dropdown.init(this.querySelector('.dropdown-trigger'), {});
    }
  })
})();


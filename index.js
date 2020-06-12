// Disable url mangling.
// Since our fonts are in `./static/fonts`, but will be published under `./fonts`,
// we need to prevent webpack from trying to resolve the font's path,
// because it will not find anything unter e.g. `./fonts/font-file.woff`.
import "!style-loader!css-loader?url=false!./style.css";

const { Elm } = require("./src/Main.elm");
const pagesInit = require("elm-pages");

pagesInit({
  mainElmModule: Elm.Main
});

module View exposing (View, map, placeholder)

import Html.Styled as Html
import Renderer exposing (Rendered)


type alias View msg =
    { title : String
    , body : Rendered msg
    }


map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = Html.map fn doc.body
    }


placeholder : String -> View msg
placeholder moduleName =
    { title = "Placeholder - " ++ moduleName
    , body = Html.text moduleName
    }

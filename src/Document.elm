module Document exposing (Block(..), Document, Inline(..), Link, Text, TextStyle)

import Url exposing (Url)


type alias Document =
    List Block


type Block
    = Title String
    | Heading (List Inline)
    | Subheading (List Inline)
    | Paragraph (List Inline)


type Inline
    = TextInline Text
    | LinkInline Link


type alias Text =
    { style : TextStyle
    , content : String
    }


type alias TextStyle =
    { emphasized : Bool
    }


type alias Link =
    { text : List Text
    , url : Url
    }

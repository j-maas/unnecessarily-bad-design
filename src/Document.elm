module Document exposing (Block(..), Document, Text, TextStyle)


type alias Document =
    List Block


type Block
    = Title String
    | Heading String
    | Subheading String
    | Paragraph (List Text)


type alias Text =
    { style : TextStyle
    , content : String
    }


type alias TextStyle =
    { emphasized : Bool
    }

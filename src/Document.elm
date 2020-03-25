module Document exposing (Block(..), Document, Inline(..), Link, Path, Reference, Text, TextStyle, pathFromString)

import List.Extra as List
import Pages exposing (PathKey)
import Pages.PagePath exposing (PagePath)
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
    | ReferenceInline Reference


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


type alias Path =
    PagePath PathKey


pathFromString : String -> Maybe Path
pathFromString raw =
    List.find (\page -> raw == Pages.PagePath.toString page) Pages.allPages


type alias Reference =
    { text : List Text
    , path : Path
    }

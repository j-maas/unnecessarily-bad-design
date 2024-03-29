module Document exposing (Block(..), Code, CodeLanguage(..), Document, FlatInline(..), Image, Inline(..), Key(..), Keys, Link, Reference, Source, Text, TextStyle, codeLanguageFromString, keyFromString, keysFromString, plainText)

import Dict exposing (Dict)
import List.Extra as List
import Url exposing (Url)


type alias Document path =
    List (Block path)


type Block path
    = Title String
    | Heading (List (Inline path))
    | Subheading (List (Inline path))
    | Paragraph (List (Inline path))
    | CodeBlock Code
    | ImageBlock (Image path)


{-| Since `Note`s should not contain other `Note`s, we differentiate between flat and other inlines.
-}
type Inline path
    = FlatInline (FlatInline path)
    | Note (List (FlatInline path))


type FlatInline path
    = TextInline Text
    | LinkInline Link
    | ReferenceInline (Reference path)
    | CodeInline Code
    | KeysInline Keys


type alias Text =
    { style : TextStyle
    , content : String
    }


type alias TextStyle =
    { emphasized : Bool
    }


plainText : String -> Text
plainText text =
    { style = { emphasized = False }
    , content = text
    }


type alias Link =
    { text : List Text
    , url : Url
    }


type alias Reference path =
    { text : List Text
    , path : path
    }


type CodeLanguage
    = Bash


codeLanguageFromString : String -> Maybe CodeLanguage
codeLanguageFromString raw =
    case raw of
        "bash" ->
            Just Bash

        _ ->
            Nothing


type alias Code =
    { src : String
    , language : CodeLanguage
    }


type alias Keys =
    ( Key, List Key )


type Key
    = Letter Char
    | Tab
    | Up
    | Down
    | Ctrl
    | Shift
    | Enter


keysFromString : String -> Maybe Keys
keysFromString raw =
    case String.split "+" raw of
        firstRaw :: restRaw ->
            restRaw
                |> List.foldl
                    (\next maybeKeys ->
                        maybeKeys
                            |> Maybe.andThen
                                (\( f, r ) ->
                                    keyFromString next
                                        |> Maybe.map (\n -> ( f, r ++ [ n ] ))
                                )
                    )
                    (keyFromString firstRaw |> Maybe.map (\first -> ( first, [] )))

        _ ->
            Nothing


keyFromString : String -> Maybe Key
keyFromString raw =
    case String.toList raw of
        [ char ] ->
            Just <| Letter char

        [ 'C', 'T', 'R', 'L' ] ->
            Just Ctrl

        [ 'S', 'H', 'I', 'F', 'T' ] ->
            Just Shift

        [ 'E', 'N', 'T', 'E', 'R' ] ->
            Just Enter

        [ 'T', 'A', 'B' ] ->
            Just Tab

        [ 'U', 'P' ] ->
            Just Up

        [ 'D', 'O', 'W', 'N' ] ->
            Just Down

        _ ->
            Nothing


type alias Image path =
    { fallbackSource : { mimeType : String, source : Source path }
    , extraSources : Dict String (List (Source path))
    , alt : String
    , caption : List (Inline path)
    , credit : Maybe (List (Inline path))
    }


type alias Source path =
    { src : path
    , width : Int
    , height : Int
    }

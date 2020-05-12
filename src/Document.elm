module Document exposing (Block(..), Code, CodeLanguage(..), Document, Inline(..), Key(..), Keys, Link, Path, Reference, Text, TextStyle, codeLanguageFromString, keyFromString, keysFromString, pathFromString)

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
    | CodeBlock Code


type Inline
    = TextInline Text
    | LinkInline Link
    | ReferenceInline Reference
    | CodeInline Code
    | KeysInline Keys


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

        ['S', 'H','I','F','T'] ->
            Just Shift
        ['E','N','T','E','R'] -> Just Enter

        [ 'T', 'A', 'B' ] ->
            Just Tab

        
        [ 'U', 'P' ] ->
            Just Up

        [ 'D', 'O', 'W', 'N' ] ->
            Just Down


        _ ->
            Nothing

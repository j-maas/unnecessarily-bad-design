module Renderer exposing (Text, heading, paragraph, rem, render, subheading, title)

import Document exposing (..)
import Element exposing (Element)
import Element.Font as Font


type alias Rendered msg =
    Element msg



-- Render


render : Document -> Rendered msg
render blocks =
    List.map
        (\block ->
            case block of
                Title content ->
                    title content

                Heading content ->
                    heading content

                Subheading content ->
                    subheading content

                Paragraph contents ->
                    paragraph
                        (List.map
                            (\text ->
                                { style = { italic = text.style.emphasized }
                                , content = text.content
                                }
                            )
                            contents
                        )
        )
        blocks
        |> document



-- View


document : List (Rendered msg) -> Rendered msg
document contents =
    Element.textColumn
        [ Element.spacing 10
        , Element.width Element.fill
        ]
        contents


title : String -> Rendered msg
title text =
    headingLevel 1 text


heading : String -> Rendered msg
heading text =
    headingLevel 2 text


subheading : String -> Rendered msg
subheading text =
    headingLevel 3 text


headingLevel : Int -> String -> Rendered msg
headingLevel level text =
    let
        fontSize =
            case level of
                1 ->
                    rem 1.5

                2 ->
                    rem 1.25

                _ ->
                    rem 1.1
    in
    Element.paragraph
        [ Font.size fontSize
        , Font.family [ Font.typeface "Bitter", Font.serif ]
        , Font.bold
        ]
        [ Element.text text
        ]


paragraph : List Text -> Rendered msg
paragraph content =
    Element.paragraph
        [ Font.family
            [ Font.typeface "Source Sans Pro"
            , Font.sansSerif
            ]
        ]
        (List.map renderText content)


renderText : Text -> Rendered msg
renderText text =
    let
        italic =
            if text.style.italic then
                [ Font.italic ]

            else
                []
    in
    Element.el italic (Element.text text.content)


type alias Text =
    { style : { italic : Bool }
    , content : String
    }


baseFontSize =
    16


rem : Float -> Int
rem percent =
    baseFontSize
        * percent
        |> round

module Renderer exposing (Rendered, Text, heading, mainContent, paragraph, render, renderDocument, subheading, title)

import Css exposing (em, num, rem, zero)
import Css.Global
import Document exposing (..)
import Html as PlainHtml
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes exposing (css)


type alias Rendered msg =
    Html msg



-- Render


renderDocument : Document -> Rendered msg
renderDocument blocks =
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



-- Landmarks


render : Rendered msg -> PlainHtml.Html msg
render content =
    Html.toUnstyled content


mainContent : List (Rendered msg) -> Rendered msg
mainContent contents =
    Html.main_
        [ css
            [ Css.padding (rem 1)
            , Css.maxWidth (rem 52)
            , Css.margin Css.auto
            ]
        ]
        contents



-- Text


document : List (Rendered msg) -> Rendered msg
document contents =
    let
        headings =
            Css.Global.each
                [ Css.Global.typeSelector "h1"
                , Css.Global.typeSelector "h2"
                , Css.Global.typeSelector "h3"
                ]

        paragraphs =
            Css.Global.typeSelector "p"
    in
    Html.article
        [ css
            [ Css.Global.children
                [ headings
                    [ Css.Global.adjacentSiblings
                        [ paragraphs
                            [ Css.marginTop (rem 0.5)
                            ]
                        ]
                    ]
                , paragraphs
                    [ Css.Global.adjacentSiblings
                        [ headings
                            [ Css.marginTop (rem 1)
                            ]
                        ]
                    ]
                , paragraphs
                    [ Css.Global.adjacentSiblings
                        [ paragraphs
                            [ Css.marginTop (rem 0.5)
                            ]
                        ]
                    ]
                ]
            ]
        ]
        contents


title : String -> Rendered msg
title text =
    Html.h1
        [ css
            [ headingStyle
            , Css.fontSize
                (rem 1.5)
            ]
        ]
        [ Html.text text ]


heading : String -> Rendered msg
heading text =
    Html.h2
        [ css
            [ headingStyle
            , Css.fontSize
                (rem 1.25)
            ]
        ]
        [ Html.text text ]


subheading : String -> Rendered msg
subheading text =
    Html.h3
        [ css
            [ headingStyle
            , Css.fontSize
                (rem 1.1)
            ]
        ]
        [ Html.text text ]


headingStyle : Css.Style
headingStyle =
    Css.batch
        [ Css.fontFamilies [ "Bitter", "serif" ]
        , Css.fontWeight Css.bold
        , Css.margin zero
        ]


paragraph : List Text -> Rendered msg
paragraph content =
    Html.p
        [ css [ paragraphStyle ]
        ]
        (List.map renderText content)


paragraphStyle : Css.Style
paragraphStyle =
    Css.batch
        [ Css.fontFamilies [ "Source Sans Pro", "sans-serif" ]
        , Css.margin zero
        , Css.lineHeight (num 1.3)
        ]


renderText : Text -> Rendered msg
renderText text =
    let
        italic =
            if text.style.italic then
                [ Css.fontStyle Css.italic ]

            else
                []

        styles =
            italic
    in
    if List.isEmpty styles then
        Html.text text.content

    else
        Html.span [ css styles ] [ Html.text text.content ]



-- Element.el italic (Element.text text.content)


type alias Text =
    { style : { italic : Bool }
    , content : String
    }

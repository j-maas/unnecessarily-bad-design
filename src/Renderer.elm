module Renderer exposing (Rendered, heading, mainContent, paragraph, render, renderDocument, subheading, title)

import Css exposing (em, num, rem, zero)
import Css.Global
import Document exposing (..)
import Html as PlainHtml
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as HtmlAttributes exposing (css)
import Pages.PagePath
import Url


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

                Heading contents ->
                    heading contents

                Subheading contents ->
                    subheading contents

                Paragraph contents ->
                    paragraph contents
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
            , Css.maxWidth (rem 40)
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


heading : List Document.Inline -> Rendered msg
heading contents =
    Html.h2
        [ css
            [ headingStyle
            , Css.fontSize
                (rem 1.25)
            ]
        ]
        (List.map renderInline contents)


subheading : List Document.Inline -> Rendered msg
subheading contents =
    Html.h3
        [ css
            [ headingStyle
            , Css.fontSize
                (rem 1.1)
            ]
        ]
        (List.map renderInline contents)


headingStyle : Css.Style
headingStyle =
    Css.batch
        [ Css.fontFamilies [ "Bitter", "serif" ]
        , Css.fontWeight Css.bold
        , Css.margin zero
        ]


paragraph : List Inline -> Rendered msg
paragraph content =
    Html.p
        [ css [ paragraphStyle ]
        ]
        (List.map renderInline content)


paragraphStyle : Css.Style
paragraphStyle =
    Css.batch
        [ Css.fontFamilies [ "Muli", "sans-serif" ]
        , Css.margin zero
        , Css.lineHeight (num 1.3)
        ]


renderInline : Inline -> Rendered msg
renderInline inline =
    case inline of
        Document.TextInline text ->
            renderText [] text

        Document.LinkInline link ->
            renderLink link

        Document.ReferenceInline reference ->
            renderReference reference

        Document.CodeInline code ->
            renderCode code


renderText : List Css.Style -> Text -> Rendered msg
renderText extraStyles text =
    let
        italic =
            if text.style.emphasized then
                [ Css.fontStyle Css.italic ]

            else
                []

        styles =
            italic ++ extraStyles
    in
    if List.isEmpty styles then
        Html.text text.content

    else
        Html.span [ css styles ] [ Html.text text.content ]


renderLink : Document.Link -> Rendered msg
renderLink link =
    viewLink
        { text = List.map (renderText []) link.text
        , url = Url.toString link.url
        }


viewLink : { text : List (Rendered msg), url : String } -> Rendered msg
viewLink { text, url } =
    let
        unvisitedColor =
            Css.rgb 22 22 162

        visitedColor =
            Css.inherit
    in
    Html.a
        [ HtmlAttributes.href url
        , css
            [ Css.color unvisitedColor
            , Css.visited
                [ Css.color visitedColor
                ]
            , Css.hover
                [ Css.textDecorationStyle Css.dotted
                ]
            ]
        ]
        text


renderReference : Document.Reference -> Rendered msg
renderReference reference =
    viewLink
        { text =
            List.map
                (renderText
                    [ Css.fontFamilies [ "Bitter", "serif" ]
                    , Css.textTransform Css.uppercase
                    , Css.fontSize (em 0.8)
                    ]
                )
                reference.text
        , url = Pages.PagePath.toString reference.path
        }


renderCode : Document.Code -> Rendered msg
renderCode code =
    Html.span
        [ css
            [ Css.whiteSpace Css.preWrap
            , Css.fontFamilies [ "Source Code Pro", "monospace" ]
            , Css.borderRadius (em 0.2)
            , Css.backgroundColor (Css.hsl 0 0 0.9)
            , Css.padding (em 0.05)
            , Css.fontSize (em 0.95)
            ]
        ]
        [ Html.text code.text ]

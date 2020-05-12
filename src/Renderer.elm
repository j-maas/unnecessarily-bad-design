module Renderer exposing (Rendered, heading, mainContent, paragraph, render, renderDocument, subheading, title)

import Css exposing (em, num, px, rem, zero)
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

                CodeBlock code ->
                    codeBlock code
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
            , Css.maxWidth (rem 48)
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
        , Css.lineHeight (num 1.2)
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
        [ Css.fontFamilies [ "Asap", "sans-serif" ]
        , Css.margin zero
        , Css.lineHeight (num 1.35)
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

        Document.KeysInline keys ->
            renderKeys keys


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
    if text.style.emphasized then
        Html.em [ css styles ] [ Html.text text.content ]

    else if List.isEmpty styles then
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
    Html.code
        [ css [ codeFontStyle, codeBackgroundStyle ]
        ]
        [ Html.text code.src ]


codeBlock : Document.Code -> Rendered msg
codeBlock code =
    Html.pre [ css [ codeBackgroundStyle, Css.padding (em 1) ] ]
        [ Html.code [ css [ codeFontStyle ] ] [ Html.text code.src ] ]


codeFontStyle : Css.Style
codeFontStyle =
    Css.batch
        [ Css.whiteSpace Css.preWrap
        , Css.fontFamilies [ "Source Code Pro", "monospace" ]
        ]


codeBackgroundStyle : Css.Style
codeBackgroundStyle =
    Css.batch
        [ Css.borderRadius (em 0.2)
        , Css.backgroundColor (Css.hsl 0 0 0.9)
        , Css.padding2 (em 0.05) (em 0.2)
        , Css.fontSize (em 0.95)
        ]


renderKeys : Document.Keys -> Rendered msg
renderKeys keys =
    case keys of
        ( first, [] ) ->
            renderKey first

        ( first, rest ) ->
            Html.kbd [ css [ Css.whiteSpace Css.preWrap ] ]
                (List.map renderKey (first :: rest)
                    -- \u{200B} is a zero-width space to allow breaking after the +
                    |> List.intersperse (Html.text "+\u{200B}")
                )


renderKey : Document.Key -> Rendered msg
renderKey key =
    let
        borderColor =
            Css.hsl 0 0 0.75

        keyText =
            -- \u{00A0} is a non-breaking space to disallow breaking inside a key
            case key of
                Document.Letter l ->
                    String.fromChar l

                Document.Ctrl ->
                    "Ctrl"

                Document.Shift ->
                    "Shift\u{00A0}⇧"

                Document.Enter ->
                    "Enter\u{00A0}↵"

                Document.Tab ->
                    "Tab\u{00A0}↹"

                Document.Up ->
                    "↑\u{00A0}up"

                Document.Down ->
                    "↓\u{00A0}down"
    in
    Html.kbd
        [ css
            [ codeFontStyle
            , Css.fontSize (em 0.8)
            , Css.padding2 (em 0) (em 0.1)
            , Css.border3 (px 1) Css.solid borderColor
            , Css.borderRadius (em 0.2)
            , Css.boxShadow5 Css.inset zero (px -1) zero borderColor
            , Css.verticalAlign Css.center
            , Css.whiteSpace Css.pre
            ]
        ]
        [ Html.text keyText ]

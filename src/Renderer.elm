module Renderer exposing (Rendered, backgroundTextStyle, body, heading, mainContent, navigation, paragraph, render, renderDocument, renderReference, subheading, title)

import Css exposing (em, num, pct, px, rem, vh, zero)
import Css.Global
import Document exposing (..)
import Html as PlainHtml
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attributes exposing (css)
import Metadata exposing (ArticleMetadata)
import Pages
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath
import Url


type alias Rendered msg =
    Html msg



-- Render


body : List (Rendered msg) -> Rendered msg
body content =
    Html.div
        [ css
            [ Css.padding (rem 1)
            , Css.maxWidth (rem 48)
            , Css.margin Css.auto
            , bodyFontFamily
            ]
        ]
        content


type alias PagePath =
    PagePath.PagePath Pages.PathKey


navigation : PagePath -> Rendered msg
navigation index =
    Html.nav
        [ css [ Css.marginBottom (rem 1) ]
        ]
        [ navLink index "Go back to overview"
        ]


navLink : PagePath -> String -> Rendered msg
navLink path text =
    viewLink
        { url = PagePath.toString path
        , text = [ Html.text text ]
        , styles = [ Css.fontStyle Css.italic ]
        }


renderDocument : ArticleMetadata -> Document -> Rendered msg
renderDocument meta blocks =
    (List.map
        (\block ->
            case block of
                Title content ->
                    title content

                Heading contents ->
                    heading contents

                Subheading contents ->
                    subheading contents

                Paragraph contents ->
                    paragraph [] contents

                CodeBlock code ->
                    codeBlock code

                ImageBlock image ->
                    imageBlock image
        )
        blocks
        ++ [ ccLicense meta.authors
           ]
    )
        |> document


ccLicense : String -> Rendered msg
ccLicense authors =
    Html.footer
        [ css
            [ Css.marginTop (rem 4)
            , backgroundTextStyle
            ]
        ]
        [ Html.text ("This article, written by " ++ authors ++ ", is licensed under ")
        , viewLink
            { text =
                let
                    icon path styles =
                        Html.img
                            [ Attributes.src (ImagePath.toString path)
                            , Attributes.width 14
                            , Attributes.height 14
                            , css
                                ([ Css.width (em 0.9)
                                 , Css.height Css.auto
                                 , Css.position Css.relative
                                 , Css.bottom (em -0.1)
                                 ]
                                    ++ styles
                                )
                            ]
                            []
                in
                [ Html.text "CC BY 4.0"
                , Html.span [ css [ Css.whiteSpace Css.noWrap ] ]
                    [ icon Pages.images.cc.cc [ Css.paddingLeft (em 0.2) ]
                    , icon Pages.images.cc.by [ Css.paddingLeft (em 0.1) ]
                    ]
                ]
            , url = "https://creativecommons.org/licenses/by/4.0/"

            -- Break normally inside the link.
            , styles = []
            }
        , Html.text "."
        ]



-- Landmarks


render : Rendered msg -> PlainHtml.Html msg
render content =
    Html.toUnstyled content


mainContent : List (Rendered msg) -> Rendered msg
mainContent contents =
    Html.main_ [] contents



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
                            [ Css.marginTop paragraphSpacing
                            ]
                        ]
                    ]
                ]
            ]
        ]
        contents


paragraphSpacing : Css.Rem
paragraphSpacing =
    rem 1


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
        [ headingFontFamily
        , Css.fontWeight Css.bold
        , Css.margin zero
        , Css.lineHeight (num 1.2)
        ]


paragraph : List Css.Style -> List Inline -> Rendered msg
paragraph styles content =
    Html.p
        [ css (paragraphStyle :: styles)
        ]
        (List.map renderInline content)


paragraphStyle : Css.Style
paragraphStyle =
    Css.batch
        [ paragraphFontStyle
        , Css.margin zero
        ]


bodyFontFamily : Css.Style
bodyFontFamily =
    Css.fontFamilies [ "Rubik", "Verdana", "sans-serif" ]


headingFontFamily : Css.Style
headingFontFamily =
    Css.fontFamilies [ "Merriweather", "Georgia", "serif" ]


paragraphFontStyle : Css.Style
paragraphFontStyle =
    Css.batch
        [ Css.lineHeight (num 1.35)
        ]


renderInline : Inline -> Rendered msg
renderInline inline =
    case inline of
        Document.FlatInline plain ->
            renderFlatInline plain

        Document.Note content ->
            renderNote content


renderFlatInline : FlatInline -> Rendered msg
renderFlatInline inline =
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
        , styles = []
        }


viewLink : { text : List (Rendered msg), url : String, styles : List Css.Style } -> Rendered msg
viewLink { text, url, styles } =
    let
        unvisitedColor =
            Css.rgb 22 22 162

        visitedColor =
            Css.inherit
    in
    Html.a
        [ Attributes.href url
        , css
            ([ Css.color unvisitedColor
             , Css.visited
                [ Css.color visitedColor
                ]
             , hover
                [ Css.textDecorationStyle Css.dotted
                ]
             ]
                ++ styles
            )
        ]
        text


renderReference : Document.Reference -> Rendered msg
renderReference reference =
    viewLink
        { text =
            List.map
                (renderText
                    [ Css.fontWeight Css.bold
                    , Css.fontSize (em 0.8)
                    ]
                )
                reference.text
        , url = PagePath.toString reference.path
        , styles = []
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
        , Css.backgroundColor (Css.hsla 0 0 0.5 0.15)
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


imageBlock : Document.Image -> Rendered msg
imageBlock image =
    let
        credits =
            case image.credit of
                Just credits_ ->
                    [ Html.i
                        [ css
                            [ Css.marginTop (rem 0.25)
                            , Css.fontStyle Css.normal
                            , Css.fontSize (em 0.9)
                            , Css.display Css.inlineBlock
                            , Css.maxWidth (pct 90)
                            , Css.textAlign Css.end
                            , Css.float Css.right
                            , backgroundTextStyle
                            ]
                        ]
                        (List.map renderInline credits_)
                    ]

                Nothing ->
                    []
    in
    Html.figure
        [ css
            [ Css.margin2 paragraphSpacing zero
            , framedStyle
            , Css.overflow Css.hidden
            , paragraphFontStyle
            , Css.displayFlex
            , Css.flexDirection Css.column
            , Css.alignItems Css.center
            ]
        ]
        [ let
            dimensions =
                ImagePath.dimensions image.src |> Maybe.withDefault { width = 0, height = 0 }
          in
          Html.img
            [ Attributes.src (ImagePath.toString image.src)
            , Attributes.alt image.alt
            , Attributes.width dimensions.width
            , Attributes.height dimensions.height
            , css
                [ Css.maxWidth (pct 100)
                , Css.width (pct 100)
                , Css.height Css.auto
                ]
            ]
            []
        , Html.figcaption
            [ css
                [ Css.boxSizing Css.borderBox
                , Css.width (pct 100)
                , Css.padding (rem 0.5)
                , Css.alignSelf Css.flexStart

                -- Frame only top of caption.
                , framedBorderStyle
                , Css.borderLeft zero
                , Css.borderRight zero
                , Css.borderBottom zero
                ]
            ]
            (paragraph [] image.caption
                :: credits
            )
        ]


framedStyle : Css.Style
framedStyle =
    let
        spacing =
            0.5
    in
    Css.batch
        [ framedBorderStyle
        , Css.borderRadius (rem spacing)
        ]


framedBorderStyle : Css.Style
framedBorderStyle =
    Css.border3 (px 1) Css.solid (Css.hsla 0 0 0 0.25)


backgroundTextStyle : Css.Style
backgroundTextStyle =
    Css.batch
        [ Css.opacity (num 0.5)
        , hover
            [ Css.opacity (num 1)
            ]
        ]


{-| This solution to notes is inspired by <https://edwardtufte.github.io/tufte-css/#sidenotes>
-}
renderNote : List FlatInline -> Rendered msg
renderNote content =
    Html.span
        [ css
            [ Css.Global.children
                [ Css.Global.typeSelector "input"
                    [ Css.pseudoClass "checked"
                        [ Css.Global.adjacentSiblings
                            [ Css.Global.typeSelector "small"
                                [ Css.display Css.block ]
                            ]
                        ]
                    ]
                ]
            , Css.display Css.inline
            ]
        ]
        [ Html.input
            [ Attributes.type_ "checkbox"
            , Attributes.attribute "aria-label" "Toggle whether note is shown"
            , css
                [ Css.verticalAlign Css.middle
                , Css.margin zero
                ]
            ]
            []
        , Html.small
            [ css
                [ Css.display Css.none
                , Css.padding2 (rem 0.25) (rem 0.5)
                , framedStyle
                , Css.margin2 (rem 0.5) (rem 0.5)
                , Css.fontSize (em 1)
                ]
            ]
            (List.map renderFlatInline content)
        ]


hover : List Css.Style -> Css.Style
hover styles =
    Css.batch
        [ Css.hover styles
        , Css.pseudoClass "focus-within" styles
        ]

module Main exposing (main)

import Document exposing (Document)
import Documents.Markup
import Element exposing (Element)
import Element.Region
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Metadata exposing (Metadata)
import Pages exposing (images, pages)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath exposing (PagePath)
import Pages.Platform
import Pages.StaticHttp as StaticHttp
import Renderer


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Nothing
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "Learn to create good software"
    , iarcRatingId = Nothing
    , name = "How to program"
    , themeColor = Nothing
    , startUrl = pages.index
    , shortName = Nothing
    , sourceIcon = images.iconPng
    }


main : Pages.Platform.Program Model Msg Metadata Document
main =
    Pages.Platform.application
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ Documents.Markup.document ]
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        , onPageChange = \_ -> ()
        , generateFiles = generateFiles
        , internals = Pages.internals
        }


generateFiles :
    List
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        , body : String
        }
    ->
        List
            (Result String
                { path : List String
                , content : String
                }
            )
generateFiles _ =
    []


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view :
    List ( PagePath Pages.PathKey, Metadata )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        StaticHttp.Request
            { view : Model -> Document -> { title : String, body : Html Msg }
            , head : List (Head.Tag Pages.PathKey)
            }
view _ meta =
    StaticHttp.succeed
        { view =
            \_ document ->
                let
                    { title, body } =
                        viewPage meta document
                in
                { title = title
                , body =
                    Renderer.render
                        body
                }
        , head = head meta.frontmatter
        }


viewPage :
    { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Document
    -> { title : String, body : Renderer.Rendered Msg }
viewPage page document =
    case page.frontmatter of
        Metadata.Page metadata ->
            { title = metadata.title
            , body =
                let
                    rendered =
                        Renderer.renderDocument (Document.Title metadata.title :: document)
                in
                Renderer.mainContent
                    [rendered]
            }


commonHeadTags : List (Head.Tag Pages.PathKey)
commonHeadTags =
    [ Head.rssLink "/blog/feed.xml"
    , Head.sitemapLink "/sitemap.xml"
    ]


{-| <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
<https://htmlhead.dev>
<https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
<https://ogp.me/>
-}
head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    commonHeadTags
        ++ (case metadata of
                Metadata.Page meta ->
                    Seo.summaryLarge
                        { canonicalUrlOverride = Nothing
                        , siteName = "elm-pages-starter"
                        , image =
                            { url = images.iconPng
                            , alt = "elm-pages logo"
                            , dimensions = Nothing
                            , mimeType = Nothing
                            }
                        , description = siteTagline
                        , locale = Nothing
                        , title = meta.title
                        }
                        |> Seo.website
           )


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://elm-pages-starter.netlify.com"


siteTagline : String
siteTagline =
    "Starter blog for elm-pages"

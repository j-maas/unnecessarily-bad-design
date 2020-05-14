module Main exposing (main)

import Document exposing (Document)
import Documents.Markup
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
    , description = siteTagline
    , iarcRatingId = Nothing
    , name = siteName
    , themeColor = Nothing
    , startUrl = pages.index
    , shortName = Nothing
    , sourceIcon = images.iconPng
    }


main : Pages.Platform.Program Model Msg Metadata Document
main =
    Pages.Platform.init
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ Documents.Markup.document ]
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        , onPageChange = Nothing
        , internals = Pages.internals
        }
        |> Pages.Platform.toProgram


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
                    navigation =
                        -- Do not display navigation on the index.
                        if pages.index == page.path then
                            []

                        else
                            [ Renderer.navigation pages.index ]

                    rendered =
                        Renderer.renderDocument (Document.Title metadata.title :: document)
                in
                Renderer.body
                    (navigation
                        ++ [ Renderer.mainContent
                                [ rendered ]
                           ]
                    )
            }


commonHeadTags : List (Head.Tag Pages.PathKey)
commonHeadTags =
    []


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
                        , siteName = siteName
                        , image =
                            { url = images.iconPng
                            , alt = "elm-pages logo"
                            , dimensions = Nothing
                            , mimeType = Nothing
                            }
                        , description = siteTagline
                        , locale = Just "en"
                        , title = meta.title
                        }
                        |> Seo.website
           )


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://elm-pages-starter.netlify.com"


siteName : String
siteName =
    "How to program"


siteTagline : String
siteTagline =
    "Everything you didn't know you needed to know about programming."

module Page.Index exposing (Data, Model, Msg, page)

import Article exposing (Frontmatter)
import Css exposing (rem, zero)
import Css.Global
import DataSource exposing (DataSource)
import Document
import Head
import Head.Seo as Seo
import Html.Styled as Html
import Html.Styled.Attributes exposing (css)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url as Url
import Path
import Renderer
import Shared
import Site
import Url
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    Article.allArticlesFrontmatter


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Site.siteSeoBase { title = Site.siteName, description = Site.siteDescription }
        |> Seo.website


type alias Data =
    List Frontmatter


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = "Unnecessarily bad design"
    , body =
        Renderer.body
            [ Renderer.title "Unnecessarily bad design"
            , Html.ul
                [ css
                    [ Css.margin zero
                    , Css.marginTop (rem 1)
                    , Css.marginBottom (rem 3)
                    , Css.padding zero
                    , Css.listStyleType Css.none
                    , Css.Global.children
                        [ Css.Global.typeSelector "li"
                            [ Css.Global.adjacentSiblings
                                [ Css.Global.typeSelector "li"
                                    [ Css.marginTop (rem 0.5)
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
                (List.map
                    (\article ->
                        let
                            title =
                                [ Document.ReferenceInline { text = [ Document.plainText article.title ], path = Path.fromString article.slug } ]
                                    |> List.map Document.FlatInline

                            question =
                                [ Document.plainText article.question ]
                                    |> List.map Document.TextInline
                                    |> List.map Document.FlatInline
                        in
                        Html.li []
                            [ Renderer.heading title
                            , Renderer.paragraph [] question
                            ]
                    )
                    static.data
                )
            , let
                repoUrl =
                    { protocol = Url.Https
                    , host = "github.com"
                    , port_ = Nothing
                    , path = "/y0hy0h/unnecessarily-bad-design"
                    , query = Nothing
                    , fragment = Nothing
                    }

                contribute =
                    [ Document.TextInline (Document.plainText "If you know more examples of unnecessarily bad design, contribute to the ")
                    , Document.LinkInline { text = [ Document.plainText "GitHub repository" ], url = repoUrl }
                    , Document.TextInline (Document.plainText ".")
                    ]
                        |> List.map Document.FlatInline
              in
              Renderer.paragraph [ Renderer.backgroundTextStyle ] contribute
            ]
    }

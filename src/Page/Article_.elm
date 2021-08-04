module Page.Article_ exposing (Data, Model, Msg, page)

import Article exposing (Article)
import DataSource exposing (DataSource)
import Document
import Head
import Head.Seo as Seo
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Renderer
import Shared
import Site
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { article : String }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    Article.allArticlesFrontmatter
        |> DataSource.map (List.map (\article -> { article = article.slug }))


data : RouteParams -> DataSource Data
data routeParams =
    Article.articleForSlug routeParams.article


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Site.siteSeoBase { title = fullTitle static.data.frontmatter.title, description = static.data.frontmatter.question }
        |> Seo.article
            { tags = []
            , section = Just "Interaction Design"
            , publishedTime = Nothing
            , modifiedTime = Nothing
            , expirationTime = Nothing
            }


type alias Data =
    Article


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    let
        article =
            static.data

        questionInline =
            Document.plainText article.frontmatter.question
                |> Document.TextInline
                |> Document.FlatInline
                |> List.singleton
                |> Document.Paragraph

        title =
            fullTitle article.frontmatter.title

        fullDocument =
            Document.Title title :: questionInline :: article.document

        fullArticle =
            { article | document = fullDocument }

        rendered =
            Renderer.renderDocument fullArticle
    in
    { title = title
    , body =
        Renderer.body
            [ Renderer.navigation
            , Renderer.mainContent
                [ rendered ]
            ]
    }


fullTitle : String -> String
fullTitle shortTitle =
    shortTitle ++ ", an unnecessarily bad design"

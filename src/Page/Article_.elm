module Page.Article_ exposing (Data, Model, Msg, page)

import Article exposing (Article, Frontmatter)
import DataSource exposing (DataSource)
import Document
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path
import Renderer
import Shared
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
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


type alias Data =
    Article


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
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
            article.frontmatter.title ++ ", an unnecessarily bad design"

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
            (Renderer.navigation
                :: [ Renderer.mainContent
                        [ rendered ]
                   ]
            )
    }

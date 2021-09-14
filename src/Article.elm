module Article exposing (Article, Frontmatter, allArticles, allArticlesFrontmatter, articleForSlug, frontmatterForSlug)

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob
import Document exposing (Document)
import Markup
import OptimizedDecoder as Decode exposing (Decoder)
import Path exposing (Path)


type alias Article =
    { frontmatter : Frontmatter
    , document : Document Path
    }


type alias Frontmatter =
    { slug : String
    , title : String
    , question : String
    , authors : String
    }


allArticles : DataSource (List Article)
allArticles =
    glob
        |> DataSource.map (List.map articleForSlug)
        |> DataSource.resolve


allArticlesFrontmatter : DataSource (List Frontmatter)
allArticlesFrontmatter =
    glob
        |> DataSource.map (List.map frontmatterForSlug)
        |> DataSource.resolve


glob : DataSource (List String)
glob =
    Glob.succeed (\slug -> slug)
        |> Glob.match (Glob.literal "articles/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".emu")
        |> Glob.toDataSource


frontmatterForSlug : String -> DataSource Frontmatter
frontmatterForSlug slug =
    File.onlyFrontmatter (frontMatterDecoder slug) (filePathFromSlug slug)


articleForSlug : String -> DataSource Article
articleForSlug slug =
    File.bodyWithFrontmatter
        (\body ->
            frontMatterDecoder slug
                |> Decode.map
                    (\frontmatter ->
                        { frontmatter = frontmatter
                        , body = body
                        }
                    )
        )
        (filePathFromSlug slug)
        |> DataSource.andThen
            (\raw ->
                Markup.compile raw.body
                    |> DataSource.fromResult
                    |> DataSource.andThen identity
                    |> DataSource.map
                        (\document ->
                            { frontmatter = raw.frontmatter, document = document }
                        )
            )


filePathFromSlug : String -> String
filePathFromSlug slug =
    "articles/" ++ slug ++ ".emu"


frontMatterDecoder : String -> Decoder Frontmatter
frontMatterDecoder slug =
    Decode.map3
        (\title question authors ->
            { slug = slug
            , title = title
            , question = question
            , authors = authors
            }
        )
        (Decode.field "title" Decode.string)
        (Decode.field "question" Decode.string)
        (Decode.field "authors" Decode.string)

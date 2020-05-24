module Metadata exposing (ArticleMetadata, Metadata(..), decoder)

import Json.Decode as Decode


type Metadata
    = Index
    | Article ArticleMetadata


type alias ArticleMetadata =
    { title : String
    , question : String
    }


decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\pageType ->
                case pageType of
                    "article" ->
                        Decode.map2
                            (\title question ->
                                Article
                                    { title = title
                                    , question = question
                                    }
                            )
                            (Decode.field "title" Decode.string)
                            (Decode.field "question" Decode.string)

                    "index" ->
                        Decode.succeed Index

                    _ ->
                        Decode.fail <| "Unexpected page type " ++ pageType
            )

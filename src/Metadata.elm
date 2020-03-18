module Metadata exposing (Metadata(..), PageMetadata, decoder)

import Json.Decode as Decode


type Metadata
    = Page PageMetadata


type alias PageMetadata =
    { title : String }


decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\pageType ->
                case pageType of
                    "page" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title -> Page { title = title })

                    _ ->
                        Decode.fail <| "Unexpected page type " ++ pageType
            )

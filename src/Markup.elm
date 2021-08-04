module Markup exposing (compile)

import Document exposing (Block(..), Document, Text)
import Mark
import Mark.Error
import Url exposing (Url)


compile : String -> Result String Document
compile rawText =
    case Mark.compile bodyDocument rawText of
        Mark.Success blocks ->
            Ok blocks

        Mark.Almost partial ->
            Err (errorsToString partial.errors)

        Mark.Failure errors ->
            Err (errorsToString errors)


errorsToString : List Mark.Error.Error -> String
errorsToString errors =
    List.map Mark.Error.toString errors
        |> String.join "\n"


bodyDocument : Mark.Document Document
bodyDocument =
    Mark.document
        (\blocks -> blocks)
        (Mark.manyOf
            [ headingMark
            , subheadingMark
            , paragraphMark
            , bashMark
            , imageMark
            ]
        )


headingMark : Mark.Block Block
headingMark =
    Mark.block "Heading"
        Heading
        richTextMark


subheadingMark : Mark.Block Block
subheadingMark =
    Mark.block "Subheading"
        Subheading
        richTextMark


paragraphMark : Mark.Block Block
paragraphMark =
    richTextMark
        |> Mark.map Paragraph


richTextMark : Mark.Block (List Document.Inline)
richTextMark =
    Mark.textWith
        { view = \styles text -> Ok <| Document.FlatInline <| Document.TextInline (convertText styles text)
        , replacements = Mark.commonReplacements
        , inlines =
            flatInlines (Ok << Document.FlatInline)
                ++ [ noteInline
                   ]
        }
        |> Mark.verify
            (\results ->
                List.foldl
                    (\next result ->
                        case ( next, result ) of
                            ( Ok inline, Ok inlines ) ->
                                Ok (inlines ++ [ inline ])

                            ( Err errors, Err previousErrors ) ->
                                Err (previousErrors ++ errors)

                            ( Err errors, Ok _ ) ->
                                Err errors

                            ( Ok _, Err errors ) ->
                                Err errors
                    )
                    (Ok [])
                    results
                    |> Result.mapError
                        (\errors ->
                            { title = "Invalid annotation"
                            , message =
                                [ errorsToString errors ]
                            }
                        )
            )


flatTextMark : Mark.Block (List Document.FlatInline)
flatTextMark =
    Mark.textWith
        { view = \styles text -> Document.TextInline (convertText styles text)
        , replacements = Mark.commonReplacements
        , inlines =
            flatInlines identity
        }


flatInlines : (Document.FlatInline -> a) -> List (Mark.Record a)
flatInlines mapping =
    [ linkInline mapping
    , bashInline mapping
    , keyInline mapping
    ]


convertText : Mark.Styles -> String -> Text
convertText styles text =
    { style =
        { emphasized = styles.italic
        }
    , content = text
    }


linkInline : (Document.FlatInline -> a) -> Mark.Record a
linkInline mapping =
    Mark.annotation "link"
        (\styledContents url ->
            Document.LinkInline
                { text = List.map (\( styles, text ) -> convertText styles text) styledContents
                , url = url
                }
                |> mapping
        )
        |> Mark.field "url" urlMark


urlMark : Mark.Block Url
urlMark =
    Mark.string
        |> Mark.verify
            (\str ->
                Url.fromString str
                    |> Result.fromMaybe
                        { title = "Invalid URL"
                        , message = [ "This URL is not in a valid format." ]
                        }
            )


bashInline : (Document.FlatInline -> a) -> Mark.Record a
bashInline mapping =
    Mark.verbatim "bash"
        (\code ->
            Document.CodeInline
                { src = code
                , language = Document.Bash
                }
                |> mapping
        )


bashMark : Mark.Block Block
bashMark =
    Mark.block "Bash"
        (\code ->
            CodeBlock { language = Document.Bash, src = code }
        )
        Mark.string


keyInline : (Document.FlatInline -> a) -> Mark.Record a
keyInline mapping =
    Mark.verbatim "key"
        (\_ key ->
            Document.KeysInline key
                |> mapping
        )
        |> Mark.field "c" keyMark


keyMark : Mark.Block Document.Keys
keyMark =
    Mark.string
        |> Mark.verify
            (\str ->
                Document.keysFromString str
                    |> Result.fromMaybe
                        { title = "Invalid key"
                        , message = [ "This key code is invalid." ]
                        }
            )


imageMark : Mark.Block Block
imageMark =
    Mark.record "Image"
        (\src alt caption credit ->
            Document.ImageBlock
                { src = src
                , alt = alt
                , caption = caption
                , credit = credit
                }
        )
        |> Mark.field "src" imagePathMark
        |> Mark.field "alt" Mark.string
        |> Mark.field "caption" richTextMark
        |> Mark.field "credit" optionalRichtTextMark
        |> Mark.toBlock


imagePathMark : Mark.Block String
imagePathMark =
    Mark.string


optionalRichtTextMark : Mark.Block (Maybe (List Document.Inline))
optionalRichtTextMark =
    richTextMark
        |> Mark.map
            (\inlines ->
                if List.isEmpty inlines then
                    Nothing

                else
                    Just inlines
            )


noteInline : Mark.Record (Result (List Mark.Error.Error) Document.Inline)
noteInline =
    Mark.verbatim "note"
        (\raw ->
            case Mark.compile flatInlineDocument raw of
                Mark.Success inlines ->
                    Ok (Document.Note inlines)

                Mark.Almost partial ->
                    Err partial.errors

                Mark.Failure errors ->
                    Err errors
        )


flatInlineDocument : Mark.Document (List Document.FlatInline)
flatInlineDocument =
    Mark.document
        (\blocks -> blocks)
        flatTextMark

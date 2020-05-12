module Documents.Markup exposing (document)

import Document exposing (Block(..), Document, Text)
import Json.Decode exposing (Decoder)
import Mark
import Mark.Error
import Metadata exposing (Metadata)
import Url exposing (Url)


type alias PagesDocument =
    { extension : String
    , metadata : Decoder Metadata
    , body : String -> Result String Document
    }


document : PagesDocument
document =
    { extension = "emu"
    , metadata = Metadata.decoder
    , body =
        \rawText ->
            case Mark.compile bodyDocument rawText of
                Mark.Success blocks ->
                    Ok blocks

                Mark.Almost partial ->
                    Err (errorsToString partial.errors)

                Mark.Failure errors ->
                    Err (errorsToString errors)
    }


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
        { view = \styles text -> Document.TextInline (convertText styles text)
        , replacements = Mark.commonReplacements
        , inlines =
            [ linkInline
            , referenceInline
            , bashInline
            , keyInline
            ]
        }


convertText : Mark.Styles -> String -> Text
convertText styles text =
    { style =
        { emphasized = styles.italic
        }
    , content = text
    }


linkInline : Mark.Record Document.Inline
linkInline =
    Mark.annotation "link"
        (\styledContents url ->
            Document.LinkInline
                { text = List.map (\( styles, text ) -> convertText styles text) styledContents
                , url = url
                }
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


referenceInline : Mark.Record Document.Inline
referenceInline =
    Mark.annotation "ref"
        (\styledContents path ->
            Document.ReferenceInline
                { text = List.map (\( styles, text ) -> convertText styles text) styledContents
                , path = path
                }
        )
        |> Mark.field "path" pathMark


pathMark : Mark.Block Document.Path
pathMark =
    Mark.string
        |> Mark.verify
            (\str ->
                Document.pathFromString str
                    |> Result.fromMaybe
                        { title = "Dead reference"
                        , message = [ "This reference does not match any of the existing pages." ]
                        }
            )


bashInline : Mark.Record Document.Inline
bashInline =
    Mark.verbatim "bash"
        (\code ->
            Document.CodeInline
                { src = code
                , language = Document.Bash
                }
        )


bashMark : Mark.Block Block
bashMark =
    Mark.block "Bash"
        (\code ->
            CodeBlock { language = Document.Bash, src = code }
        )
        Mark.string


keyInline : Mark.Record Document.Inline
keyInline =
    Mark.verbatim "key"
        (\_ key ->
            Document.KeysInline key
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

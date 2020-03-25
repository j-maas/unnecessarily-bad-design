module Documents.Markup exposing (document)

import Document exposing (..)
import Mark
import Mark.Error
import Metadata exposing (Metadata)
import Pages.Document
import Url exposing (Url)


document : ( String, Pages.Document.DocumentHandler Metadata Document )
document =
    Pages.Document.parser
        { extension = "mu"
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
            [ linkInline, referenceInline ]
        }


plainTextMark : Mark.Block (List Text)
plainTextMark =
    Mark.textWith
        { view = convertText
        , replacements = Mark.commonReplacements
        , inlines =
            []
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

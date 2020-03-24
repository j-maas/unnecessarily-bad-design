module Documents.Markup exposing (document)

import Document exposing (..)
import Mark
import Mark.Error
import Metadata exposing (Metadata)
import Pages.Document


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
            , textMark
            ]
        )


headingMark : Mark.Block Block
headingMark =
    Mark.block "Heading"
        Heading
        Mark.string


subheadingMark : Mark.Block Block
subheadingMark =
    Mark.block "Subheading"
        Subheading
        Mark.string


textMark : Mark.Block Block
textMark =
    Mark.text
        (\styles text ->
            { style =
                { emphasized = styles.italic
                }
            , content = text
            }
        )
        |> Mark.map Paragraph

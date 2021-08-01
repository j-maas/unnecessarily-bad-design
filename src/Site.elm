module Site exposing (config)

import DataSource
import Head
import MimeType
import Pages.Manifest as Manifest
import Pages.Url as Url
import Path
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    ()


config : SiteConfig Data
config =
    \_ ->
        { data = data
        , canonicalUrl = "https://y0hy0h.github.io/unnecessarily-bad-design/"
        , manifest = manifest
        , head = head
        }


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


head : Data -> List Head.Tag
head static =
    [ Head.sitemapLink "/sitemap.xml"
    , Head.icon [] svgMimeType (Url.fromPath <| Path.join [ "favicon.svg" ])
    ]


svgMimeType : MimeType.MimeImage
svgMimeType =
    MimeType.OtherImage "svg+xml"


manifest : Data -> Manifest.Config
manifest static =
    Manifest.init
        { name = "Unnecessarily bad design"
        , description = "Things that hard to use for no damn reason."
        , startUrl = Route.Index |> Route.toPath
        , icons = []
        }

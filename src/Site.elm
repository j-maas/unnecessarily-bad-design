module Site exposing (config, faviconAlt, faviconPath, siteDescription, siteName, siteSeoBase)

import DataSource
import Head
import Head.Seo as Seo
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
    { data = data
    , canonicalUrl = "https://y0hy0h.github.io/unnecessarily-bad-design/"
    , manifest = manifest
    , head = head
    }


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


head : Data -> List Head.Tag
head _ =
    [ Head.sitemapLink "/sitemap.xml"
    , Head.icon [] svgMimeType (Url.fromPath <| faviconPath)
    ]


faviconPath : Path.Path
faviconPath =
    Path.join [ "favicon.svg" ]


faviconAlt : String
faviconAlt =
    "A stove's pictogram indicating that the knob controls the bottom left heating plate."


svgMimeType : MimeType.MimeImage
svgMimeType =
    MimeType.OtherImage "svg+xml"


manifest : Data -> Manifest.Config
manifest _ =
    Manifest.init
        { name = siteName
        , description = siteDescription
        , startUrl = Route.Index |> Route.toPath
        , icons = []
        }


siteName : String
siteName =
    "Unnecessarily bad design"


siteDescription : String
siteDescription =
    "Things that hard to use for no damn reason."


siteSeoBase : { title : String, description : String } -> Seo.Common
siteSeoBase { title, description } =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = siteName
        , image =
            { url = Url.fromPath faviconPath
            , alt = faviconAlt
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = description
        , locale = Nothing
        , title = title
        }

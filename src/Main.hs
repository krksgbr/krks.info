{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BangPatterns #-}
import           GHC.IO.Encoding
import           Data.Monoid                    ( mappend )
import           Hakyll
import           Data.Maybe                     ( fromMaybe )
import           Control.Monad                  ( liftM )
import           Debug.Trace                   as Debug
import           System.FilePath                ( splitDirectories
                                                , takeBaseName
                                                , takeFileName
                                                )
import           Data.List                      ( elemIndex
                                                , sortOn
                                                )
import           Data.Ord                       ( comparing )
import           System.Environment             ( lookupEnv )

aboutMd = "about.md"
cvMd = "cv.md"
contactMd = "contact.md"
projectMds = "projects/*"
rndrProjectMds = "rndrprojects/*"


sortProjects :: [String] -> [Item a] -> [Item a]
sortProjects projectNames = sortOn projectIndex
    where
        itemBaseName = takeBaseName . toFilePath . itemIdentifier
        projectIndex a = elemIndex (itemBaseName a) projectNames

projectField :: String -> [Item String] -> [String] -> Context a
projectField fieldName projects projectNames = listField
        fieldName
        defaultContext
        (return $ sortProjects projectNames projects)


defaultRules :: Rules ()
defaultRules = do
        route $ setExtension "html"
        compile $ pandocCompiler >>= relativizeUrls


getConfig :: IO Configuration
getConfig = do
        contentDirectory <- lookupEnv "IN"
        outDirectory     <- lookupEnv "OUT"
        return
                (defaultConfiguration
                        { providerDirectory    = fromMaybe "content"
                                                           contentDirectory
                        , destinationDirectory =
                                fromMaybe
                                        (destinationDirectory
                                                defaultConfiguration
                                        )
                                        outDirectory
                        }
                )

generateSite :: Configuration -> IO ()
generateSite config = hakyllWith config $ do
        match "images/*" $ do
                route idRoute
                compile copyFileCompiler

        match "files/*" $ do
                route idRoute
                compile copyFileCompiler

        match "css/*" $ do
                route idRoute
                compile compressCssCompiler

        match "favicon/*" $ do
                route $ customRoute (takeFileName . toFilePath)
                compile copyFileCompiler

        match (fromList [aboutMd, cvMd, contactMd]) defaultRules
        match projectMds                            defaultRules
        match rndrProjectMds                        defaultRules

        match "index.html" $ do
                route idRoute
                compile $ do
                        about        <- loadBody aboutMd
                        projects     <- loadAll projectMds
                        rndrProjects <- loadAll rndrProjectMds
                        cv           <- loadBody cvMd
                        contact      <- loadBody contactMd
                        let indexCtx =
                                    projectField
                                                    "projects"
                                                    projects
                                                    [ "thesisproject"
                                                    , "underpressure"
                                                    ]
                                            <> projectField
                                                       "rndrProjects"
                                                       rndrProjects
                                                       [ "25th-hour"
                                                       , "dokgen"
                                                       , "openrndrorg"
                                                       , "road"
                                                       , "pagesmagazine"
                                                       ]
                                            <> constField "title" "Home"
                                            <> field
                                                       "about"
                                                       (const $ return about)
                                            <> field "cv" (const $ return cv)
                                            <> field
                                                       "contact"
                                                       (const $ return contact)
                                            <> defaultContext

                        getResourceBody
                                >>= applyAsTemplate indexCtx
                                >>= loadAndApplyTemplate
                                            "templates/default.html"
                                            indexCtx
                                >>= relativizeUrls

        match "templates/*" $ compile templateBodyCompiler



main :: IO ()
main = getConfig >>= generateSite

{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Application
    ( getApplicationDev
    , appMain
    , develMain
    , makeFoundation
    ) where

import           Control.Monad.Logger                      (liftLoc,
                                                            runLoggingT)
import           Database.Persist.Postgresql               (createPostgresqlPool,
                                                            pgConnStr,
                                                            pgPoolSize,
                                                            runSqlPool)
import           Import
import           LambdaCms.Core
import           LambdaCms.Core.Settings                   (generateUUID)
import           Language.Haskell.TH.Syntax                (qLocation)
import           Network.Wai.Handler.Warp                  (Settings,
                                                            defaultSettings, defaultShouldDisplayException,
                                                            runSettings,
                                                            setHost,
                                                            setOnException,
                                                            setPort)
import qualified Network.Wai.Middleware.MethodOverridePost as MiddlewareMOP
import           Network.Wai.Middleware.RequestLogger      (Destination (Logger),
                                                            IPAddrSource (..),
                                                            OutputFormat (..),
                                                            destination,
                                                            mkRequestLogger,
                                                            outputFormat)
import           System.Log.FastLogger                     (defaultBufSize,
                                                            newStdoutLoggerSet,
                                                            toLogStr)
-- Import all relevant handler modules here.
-- Don't forget to add new modules to your cabal file!
import           Handler.Common
import           Handler.Page
import           Handler.Tutorial
-- import           LambdaCmsOrg.Tutorial
import           LambdaCmsOrg.Page

-- This line actually creates our YesodDispatch instance. It is the second half
-- of the call to mkYesodData which occurs in Foundation.hs. Please see the
-- comments there for more details.
mkYesodDispatch "App" resourcesApp

getAdminHomeRedirectR :: Handler Html
getAdminHomeRedirectR = do
    redirect $ CoreAdminR AdminHomeR

-- | This function allocates resources (such as a database connection pool),
-- performs initialization and return a foundation datatype value. This is also
-- the place to put your migrate statements to have automatic database
-- migrations handled by Yesod.
makeFoundation :: AppSettings -> IO App
makeFoundation appSettings' = do
    -- Some basic initializations: HTTP connection manager, logger, and static
    -- subsite.
    appHttpManager' <- newManager
    appLogger' <- newStdoutLoggerSet defaultBufSize >>= makeYesodLogger
    appStatic' <-
        (if appMutableStatic appSettings' then staticDevel else static)
        (appStaticDir appSettings')

    -- We need a log function to create a connection pool. We need a connection
    -- pool to create our foundation. And we need our foundation to get a
    -- logging function. To get out of this loop, we initially create a
    -- temporary foundation without a real connection pool, get a log function
    -- from there, and then create the real foundation.
    let mkFoundation appConnPool' = App { appSettings    = appSettings'
                                        , appStatic      = appStatic'
                                        , appHttpManager = appHttpManager'
                                        , appLogger      = appLogger'
                                        , appConnPool    = appConnPool'
                                        , getLambdaCms   = CoreAdmin
                                        , getTutorialAdmin = TutorialAdmin
                                        , getPageAdmin = PageAdmin
                                        }
        tempFoundation = mkFoundation $ error "connPool forced in tempFoundation"
        logFunc = messageLoggerSource tempFoundation appLogger'

    -- Create the database connection pool
    pool <- flip runLoggingT logFunc $ createPostgresqlPool
        (pgConnStr  $ appDatabaseConf appSettings')
        (pgPoolSize $ appDatabaseConf appSettings')

    let theFoundation = mkFoundation pool
    runLoggingT
        (runSqlPool (mapM_ runMigration [ migrateAll
                                        , migrateLambdaCmsCore
                                        , migrateLambdaCmsOrgTutorial
                                        , migrateLambdaCmsOrgPage
                                        ]) pool)
        (messageLoggerSource theFoundation appLogger')
    timeNow <- getCurrentTime
    -- insert admin
    let admin = appAdmin appSettings'
    madmin <- runSqlPool (getBy (UniqueEmail admin)) pool
    case madmin of
        Nothing -> do
            uuid <- generateUUID
            flip runSqlPool pool $ do
                uid <- insert User { userIdent     = uuid
                                   , userPassword  = Nothing
                                   , userName      = takeWhile (/= '@') admin
                                   , userEmail     = admin
                                   , userActive    = True
                                   , userToken     = Nothing
                                   , userCreatedAt = timeNow
                                   , userLastLogin = Nothing
                                   , userDeletedAt = Nothing
                                   }
                mapM_ (insert_ . UserRole uid) [minBound .. maxBound]
        _ -> return ()
    -- insert non existing pages
    (pages :: [Entity Page]) <- flip runSqlPool pool $ selectList [] []
    let (types :: [PageType] ) = filter (`notElem` (map (pageType . entityVal) pages)) [minBound..maxBound]
    flip runSqlPool pool $ mapM_ (\t -> insert_ $ Page t "" timeNow) types

    return theFoundation

-- | Convert our foundation to a WAI Application by calling @toWaiAppPlain@ and
-- applyng some additional middlewares.
makeApplication :: App -> IO Application
makeApplication foundation = do
    logWare <- mkRequestLogger def
        { outputFormat =
            if appDetailedRequestLogging $ appSettings foundation
                then Detailed True
                else Apache
                        (if appIpFromHeader $ appSettings foundation
                            then FromFallback
                            else FromSocket)
        , destination = Logger $ loggerSet $ appLogger foundation
        }

    -- Create the WAI application and apply middlewares
    appPlain <- toWaiAppPlain foundation
    return $ logWare $ MiddlewareMOP.methodOverridePost appPlain

-- | Warp settings for the given foundation value.
warpSettings :: App -> Settings
warpSettings foundation =
      setPort (appPort $ appSettings foundation)
    $ setHost (appHost $ appSettings foundation)
    $ setOnException (\_req e ->
        when (defaultShouldDisplayException e) $ messageLoggerSource
            foundation
            (appLogger foundation)
            $(qLocation >>= liftLoc)
            "yesod"
            LevelError
            (toLogStr $ "Exception from Warp: " ++ show e))
      defaultSettings

-- | For yesod devel, return the Warp settings and WAI Application.
getApplicationDev :: IO (Settings, Application)
getApplicationDev = do
    settings <- loadAppSettings [configSettingsYml] [] useEnv
    foundation <- makeFoundation settings
    app <- makeApplication foundation
    wsettings <- getDevSettings $ warpSettings foundation
    return (wsettings, app)

-- | main function for use by yesod devel
develMain :: IO ()
develMain = develMainHelper getApplicationDev

-- | The @main@ function for an executable running this site.
appMain :: IO ()
appMain = do
    -- Get the settings from all relevant sources
    settings <- loadAppSettingsArgs
        -- fall back to compile-time values, set to [] to require values at runtime
        [configSettingsYmlValue]

        -- allow environment variables to override
        useEnv

    -- Generate the foundation from the settings
    foundation <- makeFoundation settings

    -- Generate a WAI Application from the foundation
    app <- makeApplication foundation

    -- Run the application with Warp
    runSettings (warpSettings foundation) app

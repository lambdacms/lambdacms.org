{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Foundation where

import qualified Data.Set             as S
import           Database.Persist.Sql (ConnectionPool, runSqlPool)
import           Import.NoFoundation
import           LambdaCms.Core
-- import           LambdaCmsOrg.Tutorial
import           LambdaCmsOrg.Page
import qualified Network.Wai          as W
import           Roles
import           Text.Hamlet          (hamletFile)
import           Text.Jasmine         (minifym)
-- import           Text.Julius           (juliusFile)
import           Yesod.Auth.BrowserId (authBrowserId)
import           Yesod.Core.Types     (Logger)
import           Yesod.Default.Util   (addStaticContentExternal)
-- | The foundation datatype for your application. This can be a good place to
-- keep settings and values requiring initialization before your application
-- starts running, such as database connections. Every handler will have
-- access to the data present here.
data App = App
    { appSettings      :: AppSettings
    , appStatic        :: Static -- ^ Settings for static file serving.
    , appConnPool      :: ConnectionPool -- ^ Database connection pool.
    , appHttpManager   :: Manager
    , appLogger        :: Logger
    , getLambdaCms     :: CoreAdmin
    , getTutorialAdmin :: TutorialAdmin
    , getPageAdmin     :: PageAdmin
    }

instance HasHttpManager App where
    getHttpManager = appHttpManager

-- Set up i18n messages. See the message folder.
mkMessage "App" "messages" "en"

-- This is where we define all of the routes in our application. For a full
-- explanation of the syntax, please see:
-- http://www.yesodweb.com/book/routing-and-handlers
--
-- Note that this is really half the story; in Application.hs, mkYesodDispatch
-- generates the rest of the code. Please see the linked documentation for an
-- explanation for this split.
mkYesodData "App" $(parseRoutesFile "config/routes")

-- | A convenient synonym for creating forms.
type Form x = Html -> MForm (HandlerT App IO) (FormResult x, Widget)

-- Please see the documentation for the Yesod typeclass. There are a number
-- of settings which can be configured by overriding methods here.
instance Yesod App where
    -- Controls the base of generated URLs. For more information on modifying,
    -- see: https://github.com/yesodweb/yesod/wiki/Overriding-approot
    approot = ApprootMaster $ appRoot . appSettings

    -- Store session data on the client in encrypted cookies,
    -- default session idle timeout is 120 minutes
    makeSessionBackend _ = fmap Just $ defaultClientSessionBackend
        120    -- timeout in minutes
        "/tmp/client_session_key.aes"

    defaultLayout widget = do
        master <- getYesod
        mmsg <- getMessage
        can <- getCan
        mcr <- getCurrentRoute
        messageRenderer <- getMessageRender

        -- We break up the default layout into two components:
        -- default-layout is the contents of the body tag, and
        -- default-layout-wrapper is the entire page. Since the final
        -- value passed to hamletToRepHtml cannot be a widget, this allows
        -- you to use normal widget features in default-layout.

        pc <- widgetToPageContent $ do
            $(combineStylesheets 'StaticR
                [ css_main_css
                ])
            $(combineScripts 'StaticR
                [ js_jquery_js
                -- , js_bootstrap_js
                , js_hoh_js
                ])
            $(widgetFile "highlighting")
            $(widgetFile "default-layout")
            addStylesheetRemote "http://fonts.googleapis.com/css?family=Oswald"
            addStylesheetRemote "http://fonts.googleapis.com/css?family=Quattrocento"
        withUrlRenderer $(hamletFile "templates/default-layout-wrapper.hamlet")

    -- The page to be redirected to when authentication is required.
    authRoute _ = Just $ AuthR LoginR

    isAuthorized theRoute _ = case theRoute of
        (StaticR _) -> return Authorized
        (CoreAdminR (AdminStaticR _)) -> return Authorized
        _ -> do
            method <- waiRequest >>= return . W.requestMethod
            y <- getYesod
            murs <- maybeAuthId >>= mapM getUserRoles
            return $ isAuthorizedTo y murs $ actionAllowedFor theRoute method

    -- This function creates static content files in the static folder
    -- and names them based on a hash of their content. This allows
    -- expiration dates to be set far in the future without worry of
    -- users receiving stale content.
    addStaticContent ext mime content = do
        master <- getYesod
        let staticDir = appStaticDir $ appSettings master
        addStaticContentExternal
            minifym
            genFileName
            staticDir
            (StaticR . flip StaticRoute [])
            ext
            mime
            content
      where
        -- Generate a unique filename based on the content itself
        genFileName lbs = "autogen-" ++ base64md5 lbs

    -- What messages should be logged. The following includes all messages when
    -- in development, and warnings and errors in production.
    shouldLog app _source level =
        appShouldLogAll (appSettings app)
            || level == LevelWarn
            || level == LevelError

    makeLogger = return . appLogger

-- How to run database actions.
instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend
    runDB action = do
        master <- getYesod
        runSqlPool action $ appConnPool master
instance YesodPersistRunner App where
    getDBRunner = defaultGetDBRunner appConnPool

instance YesodAuth App where
    type AuthId App = UserId

    -- Where to send a user after successful login
    loginDest _ = CoreAdminR AdminHomeR
    -- Where to send a user after logout
    logoutDest _ = AuthR LoginR

    -- Override the above two destinations when a Referer: header is present
    redirectToReferer _ = True

    getAuthId = getLambdaCmsAuthId

    maybeAuthId = lambdaCmsMaybeAuthId

    -- You can add other plugins like BrowserID, email or OAuth here
    authPlugins _ = [authBrowserId def]

    authHttpManager = getHttpManager

    authLayout = adminAuthLayout

instance LambdaCmsAdmin App where
    type Roles App = RoleName

    actionAllowedFor (FaviconR)                    "GET"     = Unauthenticated
    actionAllowedFor (RobotsR)                     "GET"     = Unauthenticated
    actionAllowedFor (HomeR)                       "GET"     = Unauthenticated
    actionAllowedFor (AuthR _)  _                            = Unauthenticated
    actionAllowedFor (CoreAdminR (AdminStaticR _)) "GET"     = Unauthenticated
    actionAllowedFor (CoreAdminR (UserAdminActivateR _ _)) _ = Unauthenticated
    actionAllowedFor (CommunityR)                  "GET"     = Unauthenticated
    actionAllowedFor (DocumentationR _)            "GET"     = Unauthenticated
    actionAllowedFor _          _                            = Roles $ S.fromList [Admin]

    coreR = CoreAdminR
    authR = AuthR
    masterHomeR = HomeR

    getUserRoles userId = cachedBy cacheKey . fmap toRoleSet . runDB $ selectList [UserRoleUserId ==. userId] []
        where
            cacheKey = encodeUtf8 $ toPathPiece userId
            toRoleSet = S.fromList . map (userRoleRoleName . entityVal)

    setUserRoles userId rs = runDB $ do
        deleteWhere [UserRoleUserId ==. userId]
        mapM_ (insert_ . UserRole userId) $ S.toList rs

    adminMenu = (defaultCoreAdminMenu CoreAdminR)
                ++ (defaultPageAdminMenu PageAdminR)
                ++ (defaultTutorialAdminMenu TutorialAdminR)
    renderLanguages _ = ["en"]

    mayAssignRoles = do
        authId <- requireAuthId
        roles <- getUserRoles authId
        return $ isAdmin roles

    lambdaCmsSendMail = lift . renderSendMail

instance LambdaCmsOrgTutorial App where
    tutorialR = TutorialAdminR

instance LambdaCmsOrgPage App where
    pageR = PageAdminR

instance YesodAuthPersist App

-- This instance is required to use forms. You can modify renderMessage to
-- achieve customized and internationalized form validation messages.
instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage

-- Note: Some functionality previously present in the scaffolding has been
-- moved to documentation in the Wiki. Following are some hopefully helpful
-- links:
--
-- https://github.com/yesodweb/yesod/wiki/Sending-email
-- https://github.com/yesodweb/yesod/wiki/Serve-static-files-from-a-separate-domain
-- https://github.com/yesodweb/yesod/wiki/i18n-messages-in-the-scaffolding

isAdmin :: S.Set RoleName -> Bool
isAdmin = S.member Admin

githubSocial :: Text -> Maybe Text -> Text -> Widget
githubSocial user repo kind = do
    let githubSocialTitle = case kind of
            "watch"  -> MsgGithubStar
            "fork"   -> MsgGithubFork
            "follow" -> MsgGithubFollow
            x        -> error . unpack $ "Type " <> x <> " is not supported."

        url = "http://ghbtns.com/github-btn.html?user=" <> user
              <> "&type=" <> kind
              <> "&count=true"
              <> (maybe "" ("&repo=" <>) repo)

    $(widgetFile "github-social")

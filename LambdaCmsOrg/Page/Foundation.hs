{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE RankNTypes            #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE ViewPatterns          #-}

module LambdaCmsOrg.Page.Foundation where

import           Yesod
import           Data.Text                 (Text)
import           Network.Wai               (requestMethod)
import           Control.Arrow             ((&&&))

import           LambdaCms.Core

import           LambdaCmsOrg.Page.Message (PageMessage, defaultMessage, englishMessage)
import qualified LambdaCmsOrg.Page.Message as Msg
import           LambdaCmsOrg.Page.Models
import           LambdaCmsOrg.Page.PageType

data PageAdmin = PageAdmin

mkYesodSubData "PageAdmin" $(parseRoutesFile "config/routes")

instance LambdaCmsOrgPage master => RenderMessage master PageMessage where
    renderMessage = renderPageMessage

type PageHandler a = forall master. LambdaCmsOrgPage master => HandlerT PageAdmin (HandlerT master IO) a

type PageForm x = forall master. LambdaCmsOrgPage master => Html -> MForm (HandlerT master IO) (FormResult x, WidgetT master IO ())

class LambdaCmsAdmin master => LambdaCmsOrgPage master where
    pageR :: Route PageAdmin -> Route master

    renderPageMessage :: master
                       -> [Text]
                       -> PageMessage
                       -> Text
    renderPageMessage m (lang:langs) = do
        case (lang `elem` (renderLanguages m), lang) of
            (True, "en") -> englishMessage
            _ -> renderPageMessage m langs
    renderPageMessage _ _ = defaultMessage

class ToHuman a where
    toHuman :: a -> Text

instance ToHuman PageType where
    toHuman Homepage      = "homepage"
    toHuman Documentation = "documentation"
    toHuman Community     = "community"

defaultPageAdminMenu :: LambdaCmsOrgPage master => (Route PageAdmin -> Route master) -> [AdminMenuItem master]
defaultPageAdminMenu tp = [ MenuItem (SomeMessage Msg.MenuPage) (tp PageAdminIndexR) "file" ]

instance LambdaCmsOrgPage master => LambdaCmsLoggable master Page where
    logMessage y "POST"   = translatePageLogs y Msg.LogCreatedPage
    logMessage y "PATCH"  = translatePageLogs y Msg.LogUpdatedPage
    logMessage y "DELETE" = translatePageLogs y Msg.LogDeletedPage
    logMessage _ _        = const []

translatePageLogs :: forall b master.
                     ( LambdaCmsOrgPage master
                     , RenderMessage master b
                     ) => master -> (Text -> b) -> Page -> [(Text, Text)]
translatePageLogs y msg e = map (id &&& messageFor) $ renderLanguages y
    where messageFor lang = renderMessage y [lang] . msg . toHuman $ pageType e

logPage :: LambdaCmsOrgPage master => Page -> HandlerT master IO [(Text, Text)]
logPage page = do
    y <- getYesod
    method <- waiRequest >>= return . requestMethod
    return $ logMessage y method page

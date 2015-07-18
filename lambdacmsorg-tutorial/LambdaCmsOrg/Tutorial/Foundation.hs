{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE RankNTypes            #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE ViewPatterns          #-}
{-# OPTIONS_GHC -fno-warn-orphans  #-}

module LambdaCmsOrg.Tutorial.Foundation where

import           Control.Arrow                 ((&&&))
import           Data.Text                     (Text)
import           Network.Wai                   (requestMethod)
import           Yesod

import           LambdaCms.Core

import           LambdaCmsOrg.Tutorial.Message (TutorialMessage, defaultMessage,
                                                englishMessage)
import qualified LambdaCmsOrg.Tutorial.Message as Msg
import           LambdaCmsOrg.Tutorial.Models

data TutorialAdmin = TutorialAdmin

mkYesodSubData "TutorialAdmin" $(parseRoutesFile "config/routes")

instance LambdaCmsOrgTutorial master => RenderMessage master TutorialMessage where
    renderMessage = renderTutorialMessage

type TutorialHandler a = forall master. LambdaCmsOrgTutorial master => HandlerT TutorialAdmin (HandlerT master IO) a

type TutorialForm x = forall master. LambdaCmsOrgTutorial master => Html -> MForm (HandlerT master IO) (FormResult x, WidgetT master IO ())

class LambdaCmsAdmin master => LambdaCmsOrgTutorial master where
    tutorialR :: Route TutorialAdmin -> Route master

    renderTutorialMessage :: master
                       -> [Text]
                       -> TutorialMessage
                       -> Text
    renderTutorialMessage m (lang:langs) = do
        case (lang `elem` (renderLanguages m), lang) of
            (True, "en") -> englishMessage
            _ -> renderTutorialMessage m langs
    renderTutorialMessage _ _ = defaultMessage

defaultTutorialAdminMenu :: LambdaCmsOrgTutorial master => (Route TutorialAdmin -> Route master) -> [AdminMenuItem master]
defaultTutorialAdminMenu tp = [ MenuItem (SomeMessage Msg.MenuTutorial) (tp TutorialAdminIndexR) "book" ]

instance LambdaCmsOrgTutorial master => LambdaCmsLoggable master Tutorial where
    logMessage y "POST"   = translateTutorialLogs y Msg.LogCreatedTutorial
    logMessage y "PATCH"  = translateTutorialLogs y Msg.LogUpdatedTutorial
    logMessage y "DELETE" = translateTutorialLogs y Msg.LogDeletedTutorial
    logMessage _ _        = const []

translateTutorialLogs :: forall b master.
                     ( LambdaCmsOrgTutorial master
                     , RenderMessage master b
                     ) => master -> (Text -> b) -> Tutorial -> [(Text, Text)]
translateTutorialLogs y msg e = map (id &&& messageFor) $ renderLanguages y
    where messageFor lang = renderMessage y [lang] . msg $ tutorialTitle e

logTutorial :: LambdaCmsOrgTutorial master => Tutorial -> HandlerT master IO [(Text, Text)]
logTutorial tutorial = do
    y <- getYesod
    method <- waiRequest >>= return . requestMethod
    return $ logMessage y method tutorial

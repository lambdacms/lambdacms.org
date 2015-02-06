{-# LANGUAGE ScopedTypeVariables #-}

module Handler.Tutorial where

import           Import
import           LambdaCms.Core
-- import           Text.Markdown

getTutorialIndexR :: Handler Html
getTutorialIndexR = do
    can <- getCan
    (tutorials :: [Entity Tutorial]) <- runDB $ selectList [] []
    defaultLayout $ do
        $(widgetFile "tutorials/index")

getTutorialShowR :: TutorialId -> Handler Html
getTutorialShowR tutorialId = do
    tutorial <- runDB $ get404 tutorialId
    defaultLayout $ do
        $(widgetFile "tutorials/show")

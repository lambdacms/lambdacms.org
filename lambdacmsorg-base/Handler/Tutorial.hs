{-# LANGUAGE ScopedTypeVariables #-}

module Handler.Tutorial where

import           Import


getTutorialShowR :: TutorialId -> Handler Html
getTutorialShowR tutorialId = do
    tutorial <- runDB $ get404 tutorialId
    defaultLayout $ do
        $(widgetFile "tutorials/show")

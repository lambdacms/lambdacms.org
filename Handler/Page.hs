{-# LANGUAGE ScopedTypeVariables #-}

module Handler.Page where

import           Import
import           LambdaCms.Core
import           LambdaCmsOrg.Page
import           Text.Markdown

getHomeR :: Handler Html
getHomeR = do
    Entity _ page <- runDB . getBy404 $ UniquePage Homepage
    defaultLayout $ do
        setTitle "Welcome To LambdaCms-org!"
        $(widgetFile "homepage")

getCommunityR :: Handler Html
getCommunityR = do
    Entity _ page <- runDB . getBy404 $ UniquePage Community
    defaultLayout $ do
        setTitle "Community"
        $(widgetFile "community")

getDocumentationR :: Handler Html
getDocumentationR = do
    can <- getCan
    Entity _ page <- runDB . getBy404 $ UniquePage Documentation
    (tutorials :: [Entity Tutorial]) <- runDB $ selectList [] []
    defaultLayout $ do
        setTitle "Documentation"
        $(widgetFile "documentation")

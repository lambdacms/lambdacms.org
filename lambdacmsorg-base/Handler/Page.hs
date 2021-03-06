{-# LANGUAGE ScopedTypeVariables #-}

module Handler.Page where

import           Import
import           LambdaCms.Core
import           LambdaCmsOrg.Page

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
        $(widgetFile "page")

getDocumentationIndexR :: Handler Html
getDocumentationIndexR = do
    can <- getCan
    Entity _ page <- runDB . getBy404 $ UniquePage Documentation
    (tutorials :: [Entity Tutorial]) <- runDB $ selectList [] []
    defaultLayout $ do
        setTitle "Documentation"
        $(widgetFile "documentation")

getLicenseR :: Handler Html
getLicenseR = do
    Entity _ page <- runDB . getBy404 $ UniquePage License
    defaultLayout $ do
        setTitle "License"
        $(widgetFile "page")

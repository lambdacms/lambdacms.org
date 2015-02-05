{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE QuasiQuotes         #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}

module LambdaCmsOrg.Page.Handler.Page
    ( getPageAdminIndexR
    , getPageAdminNewR
    , postPageAdminNewR
    , getPageAdminEditR
    , patchPageAdminEditR
    , deletePageAdminEditR
    ) where

import           ClassyPrelude             (tshow)
import           Control.Arrow             ((&&&))
import           Data.Maybe                (fromJust, fromMaybe, isJust)
import           Data.Time                 (UTCTime, getCurrentTime, utctDay)
import           LambdaCms.Core.Settings
import           LambdaCmsOrg.Page.Import
import qualified LambdaCmsOrg.Page.Message as Msg
import           Yesod.Text.Markdown

getPageAdminIndexR    :: PageHandler Html
getPageAdminNewR      :: PageHandler Html
postPageAdminNewR     :: PageHandler Html
getPageAdminEditR     :: PageId -> PageHandler Html
patchPageAdminEditR   :: PageId -> PageHandler Html
deletePageAdminEditR  :: PageId -> PageHandler Html

getPageAdminIndexR = lift $ do
    can <- getCan
    (pages :: [Entity Page]) <- runDB $ selectList [] []
    adminLayout $ do
        setTitleI Msg.PageIndex
        $(widgetFile "index")

getPageAdminNewR = lift $ do
    can <- getCan
    ct <- liftIO getCurrentTime
    (fWidget, enctype) <- generateFormPost $ pageForm Nothing ct
    adminLayout $ do
        setTitleI Msg.NewPage
        $(widgetFile "new")

postPageAdminNewR = do
    ct <- liftIO getCurrentTime
    ((results, fWidget), enctype) <- lift . runFormPost $ pageForm Nothing ct
    case results of
        FormSuccess page -> do
            _ <- lift . runDB $ insert page
            lift $ logAction =<< logPage page
            lift $ setMessageI Msg.SaveSuccess
            redirect PageAdminIndexR
        _ -> lift $ do
            can <- getCan
            adminLayout $ do
                setTitleI Msg.NewPage
                $(widgetFile "new")

getPageAdminEditR pageId = lift $ do
    page <- runDB $ get404 pageId
    can <- getCan
    ct <- liftIO getCurrentTime
    (fWidget, enctype) <- generateFormPost $ pageForm (Just page) ct
    adminLayout $ do
        setTitleI Msg.EditPage
        $(widgetFile "edit")

patchPageAdminEditR pageId = do
    page <- lift . runDB $ get404 pageId
    ct <- liftIO getCurrentTime
    ((results, fWidget), enctype) <- lift . runFormPost $ pageForm (Just page) ct
    case results of
        FormSuccess newPage -> do
            lift $ runDB $ replace pageId newPage
            lift $ logAction =<< logPage newPage
            lift $ setMessageI Msg.UpdateSuccess
            redirect $ PageAdminEditR pageId
        _ -> lift $ do
            can <- getCan
            adminLayout $ do
                setTitleI Msg.EditPage
                $(widgetFile "edit")

deletePageAdminEditR pageId = do
    page <- lift . runDB $ get404 pageId
    lift $ logAction =<< logPage page
    lift . runDB $ delete pageId
    lift $ setMessageI Msg.DeleteSuccess
    redirect PageAdminIndexR

pageForm :: Maybe Page -> UTCTime -> PageForm Page
pageForm mPage utct = renderBootstrap3 BootstrapBasicForm $ Page
    <$> areq (selectField types) (bfs Msg.Type) (pageType <$> mPage)
    <*> areq markdownField (withAttrs (bfs Msg.Content) [("rows", "20")]) (pageMarkdown <$> mPage)
    <*> pure (fromMaybe utct $ pageCreatedAt <$> mPage)
    <*  bootstrapSubmit (BootstrapSubmit Msg.Save " btn-success " [])
    where types = optionsPairs $ map (tshow &&& id) [minBound..maxBound]
          withAttrs fs attrs = fs { fsAttrs = (fsAttrs fs) ++ attrs }

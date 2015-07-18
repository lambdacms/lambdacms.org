{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE QuasiQuotes         #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}

module LambdaCmsOrg.Tutorial.Handler.Tutorial
    ( getTutorialAdminIndexR
    , getTutorialAdminNewR
    , postTutorialAdminNewR
    , getTutorialAdminEditR
    , patchTutorialAdminEditR
    , deleteTutorialAdminEditR
    ) where

import           Data.Maybe                    (fromJust, fromMaybe, isJust)
import           Data.Time                     (UTCTime, getCurrentTime,
                                                utctDay)
import           LambdaCms.Core.Settings
import           LambdaCmsOrg.Tutorial.Import
import qualified LambdaCmsOrg.Tutorial.Message as Msg
import           Yesod.Text.Markdown

getTutorialAdminIndexR    :: TutorialHandler Html
getTutorialAdminNewR      :: TutorialHandler Html
postTutorialAdminNewR     :: TutorialHandler Html
getTutorialAdminEditR     :: TutorialId -> TutorialHandler Html
patchTutorialAdminEditR   :: TutorialId -> TutorialHandler Html
deleteTutorialAdminEditR  :: TutorialId -> TutorialHandler Html

getTutorialAdminIndexR = lift $ do
    can <- getCan
    (tutorials :: [Entity Tutorial]) <- runDB $ selectList [] []
    adminLayout $ do
        setTitleI Msg.TutorialIndex
        $(widgetFile "index")

getTutorialAdminNewR = lift $ do
    can <- getCan
    ct <- liftIO getCurrentTime
    (fWidget, enctype) <- generateFormPost $ tutorialForm Nothing ct
    adminLayout $ do
        setTitleI Msg.NewTutorial
        $(widgetFile "new")

postTutorialAdminNewR = do
    ct <- liftIO getCurrentTime
    ((results, fWidget), enctype) <- lift . runFormPost $ tutorialForm Nothing ct
    case results of
        FormSuccess tutorial -> do
            _ <- lift . runDB $ insert tutorial
            lift $ logAction =<< logTutorial tutorial
            lift $ setMessageI Msg.SaveSuccess
            redirect TutorialAdminIndexR
        _ -> lift $ do
            can <- getCan
            adminLayout $ do
                setTitleI Msg.NewTutorial
                $(widgetFile "new")

getTutorialAdminEditR tutorialId = lift $ do
    tutorial <- runDB $ get404 tutorialId
    can <- getCan
    ct <- liftIO getCurrentTime
    (fWidget, enctype) <- generateFormPost $ tutorialForm (Just tutorial) ct
    adminLayout $ do
        setTitleI Msg.EditTutorial
        $(widgetFile "edit")

patchTutorialAdminEditR tutorialId = do
    tutorial <- lift . runDB $ get404 tutorialId
    ct <- liftIO getCurrentTime
    ((results, fWidget), enctype) <- lift . runFormPost $ tutorialForm (Just tutorial) ct
    case results of
        FormSuccess newTutorial -> do
            lift $ runDB $ replace tutorialId newTutorial
            lift $ logAction =<< logTutorial newTutorial
            lift $ setMessageI Msg.UpdateSuccess
            redirect $ TutorialAdminEditR tutorialId
        _ -> lift $ do
            can <- getCan
            adminLayout $ do
                setTitleI Msg.EditTutorial
                $(widgetFile "edit")

deleteTutorialAdminEditR tutorialId = do
    tutorial <- lift . runDB $ get404 tutorialId
    lift . runDB $ delete tutorialId
    lift $ logAction =<< logTutorial tutorial
    lift $ setMessageI Msg.DeleteSuccess
    redirect TutorialAdminIndexR

tutorialForm :: Maybe Tutorial -> UTCTime -> TutorialForm Tutorial
tutorialForm mTutorial utct = renderBootstrap3 BootstrapBasicForm $ Tutorial
    <$> areq textField (bfs Msg.Title) (tutorialTitle <$> mTutorial)
    <*> areq textareaField (fsWithAttrs [("rows", "10")] (bfs Msg.Teaser)) (tutorialTeaser <$> mTutorial)
    <*> areq markdownField (fsWithAttrs [("rows", "20")] (bfs Msg.Content)) (tutorialContent <$> mTutorial)
    <*> pure (fromMaybe utct $ tutorialCreatedAt <$> mTutorial)
    <*  bootstrapSubmit (BootstrapSubmit Msg.Save " btn-success " [])
    where fsWithAttrs attrs fs = fs { fsAttrs = (fsAttrs fs) ++ attrs }

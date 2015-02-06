{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-name-shadowing #-}

module LambdaCmsOrg.Tutorial.Message
       ( TutorialMessage (..)
       , defaultMessage
         -- * All languages
       , englishMessage
       ) where

import           Data.Monoid ((<>))
import           Data.Text   (Text)

data TutorialMessage =
    MenuTutorial
  | TutorialIndex
  | NewTutorial
  | EditTutorial
  | SaveSuccess
  | UpdateSuccess
  | DeleteSuccess
  | Title
  | Save
  | Back
  | Delete
  | CreatedOn
  | ChangeTutorialSettings
  | NoTutorialsFound
  | Content
  | Teaser
  | LogCreatedTutorial { title :: Text}
  | LogUpdatedTutorial { title :: Text}
  | LogDeletedTutorial { title :: Text}

defaultMessage :: TutorialMessage -> Text
defaultMessage = englishMessage

englishMessage :: TutorialMessage -> Text
englishMessage MenuTutorial           = "Tutorials"
englishMessage TutorialIndex          = "Tutorial overview"
englishMessage NewTutorial            = "New tutorial"
englishMessage EditTutorial           = "Edit tutorial"
englishMessage SaveSuccess            = "Successfully saved"
englishMessage UpdateSuccess          = "Successfully updated"
englishMessage DeleteSuccess          = "Successfully deleted"
englishMessage Title                  = "Title"
englishMessage Save                   = "Save"
englishMessage Back                   = "Back"
englishMessage Delete                 = "Delete"
englishMessage CreatedOn              = "Created on"
englishMessage ChangeTutorialSettings = "Change tutorial settings"
englishMessage NoTutorialsFound       = "No tutorials found"
englishMessage Content                = "Content"
englishMessage Teaser                 = "Teaser"
englishMessage (LogCreatedTutorial title) = "Created tutorial \"" <> title <> "\""
englishMessage (LogUpdatedTutorial title) = "Updated tutorial \"" <> title <> "\""
englishMessage (LogDeletedTutorial title) = "Deleted tutorial \"" <> title <> "\""

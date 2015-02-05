{-# LANGUAGE OverloadedStrings #-}

module LambdaCmsOrg.Page.Message
       ( PageMessage (..)
       , defaultMessage
         -- * All languages
       , englishMessage
       ) where

import           Data.Monoid ((<>))
import           Data.Text   (Text)

data PageMessage =
    MenuPage
  | PageIndex
  | NewPage
  | EditPage
  | SaveSuccess
  | UpdateSuccess
  | DeleteSuccess
  | Type
  | Content
  | Save
  | Back
  | Delete
  | CreatedOn
  | ChangePageSettings
  | NoPagesFound
  | LogCreatedPage { title :: Text}
  | LogUpdatedPage { title :: Text}
  | LogDeletedPage { title :: Text}

defaultMessage :: PageMessage -> Text
defaultMessage = englishMessage

englishMessage :: PageMessage -> Text
englishMessage MenuPage           = "Pages"
englishMessage PageIndex          = "Page overview"
englishMessage NewPage            = "New page"
englishMessage EditPage           = "Edit page"
englishMessage SaveSuccess           = "Successfully saved"
englishMessage UpdateSuccess         = "Successfully updated"
englishMessage DeleteSuccess         = "Successfully deleted"
englishMessage Type                 = "Type"
englishMessage Content                 = "Content"
englishMessage Save                  = "Save"
englishMessage Back                  = "Back"
englishMessage Delete                = "Delete"
englishMessage CreatedOn             = "Created on"
englishMessage ChangePageSettings = "Change page settings"
englishMessage NoPagesFound       = "No pages found"
englishMessage (LogCreatedPage title) = "Created page \"" <> title <> "\""
englishMessage (LogUpdatedPage title) = "Updated page \"" <> title <> "\""
englishMessage (LogDeletedPage title) = "Deleted page \"" <> title <> "\""

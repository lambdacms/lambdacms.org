{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE ViewPatterns          #-}
{-# OPTIONS_GHC -fno-warn-orphans  #-}

module LambdaCmsOrg.Page
       ( module Export
       )where

import           LambdaCmsOrg.Page.Foundation   as Export
import           LambdaCmsOrg.Page.Handler.Page as Export
import           LambdaCmsOrg.Page.Import
import           LambdaCmsOrg.Page.Models       as Export
import           LambdaCmsOrg.Page.PageType     as Export

instance LambdaCmsOrgPage master => YesodSubDispatch PageAdmin (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesPageAdmin)

{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}

module LambdaCmsOrg.Page
       ( module Export
       )where

import LambdaCmsOrg.Page.Import
import LambdaCmsOrg.Page.Foundation        as Export
import LambdaCmsOrg.Page.Models            as Export
import LambdaCmsOrg.Page.PageType          as Export
import LambdaCmsOrg.Page.Handler.Page   as Export

instance LambdaCmsOrgPage master => YesodSubDispatch PageAdmin (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesPageAdmin)

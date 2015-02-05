{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}

module LambdaCmsOrg.Tutorial
       ( module Export
       )where

import LambdaCmsOrg.Tutorial.Import
import LambdaCmsOrg.Tutorial.Foundation        as Export
import LambdaCmsOrg.Tutorial.Models            as Export
import LambdaCmsOrg.Tutorial.Handler.Tutorial   as Export

instance LambdaCmsOrgTutorial master => YesodSubDispatch TutorialAdmin (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesTutorialAdmin)

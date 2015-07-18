{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE ViewPatterns          #-}
{-# OPTIONS_GHC -fno-warn-orphans  #-}

module LambdaCmsOrg.Tutorial
       ( module Export
       )where

import           LambdaCmsOrg.Tutorial.Foundation       as Export
import           LambdaCmsOrg.Tutorial.Handler.Tutorial as Export
import           LambdaCmsOrg.Tutorial.Import
import           LambdaCmsOrg.Tutorial.Models           as Export

instance LambdaCmsOrgTutorial master => YesodSubDispatch TutorialAdmin (HandlerT master IO) where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesTutorialAdmin)

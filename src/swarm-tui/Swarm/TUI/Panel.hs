{-# LANGUAGE TemplateHaskell #-}

-- |
-- SPDX-License-Identifier: BSD-3-Clause
--
-- A small custom "panel widget" for use in the Swarm TUI. Panels draw
-- a border around some content, with the color of the border
-- depending on whether the panel is currently focused.  Panels exist
-- within a 'FocusRing' such that the user can cycle between the
-- panels (using /e.g./ the @Tab@ key).  Panels can also have labels
-- at up to 6 locations (top\/bottom, left\/center\/right).
module Swarm.TUI.Panel (
  panel,
) where

import Brick
import Brick.Focus
import Brick.Widgets.Border
import Control.Lens
import Swarm.TUI.Border
import Swarm.Util (applyWhen)

data Panel n = Panel
  {_panelName :: n, _panelLabels :: BorderLabels n, _panelContent :: Widget n}

makeLenses ''Panel

instance Named (Panel n) n where
  getName = view panelName

drawPanel :: Eq n => AttrName -> FocusRing n -> Panel n -> Widget n
drawPanel attr fr = withFocusRing fr drawPanel'
 where
  drawPanel' :: Bool -> Panel n -> Widget n
  drawPanel' focused p =
    applyWhen focused (overrideAttr borderAttr attr) $
      borderWithLabels (p ^. panelLabels) (p ^. panelContent)

-- | Create a panel.
panel ::
  Eq n =>
  -- | Border attribute to use when the panel is focused.
  AttrName ->
  -- | Focus ring the panel should be part of.
  FocusRing n ->
  -- | The name of the panel. Must be unique.
  n ->
  -- | The labels to use around the border.
  BorderLabels n ->
  -- | The content of the panel.
  Widget n ->
  Widget n
panel attr fr nm labs w = drawPanel attr fr (Panel nm labs w)

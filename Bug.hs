import Data.Text (Text, pack)
import Control.Monad
import System.Exit
import qualified GI.Gio as Gio
import qualified GI.Gtk as Gtk
import qualified Data.GI.Base.GType as Gtk

main :: IO ()
main = do
  m_app <- Gtk.applicationNew (Just (pack "serokell.debug.trigger-gvalue-bug-app")) []
  app <- maybe (die "could not create app") return m_app
  void $ Gio.onApplicationActivate app $ do
    window <- Gtk.applicationWindowNew app

    -- Create listStore and treeView
    listStore <- Gtk.listStoreNew [Gtk.gtypeString]
    treeView <- Gtk.treeViewNewWithModel listStore
    do column <- Gtk.treeViewColumnNew
       renderer <- Gtk.cellRendererTextNew
       void $ Gtk.treeViewColumnSetTitle column (pack "First Column")
       void $ Gtk.treeViewColumnPackStart column renderer False
       void $ Gtk.treeViewColumnAddAttribute column renderer (pack "text") 0
       void $ Gtk.treeViewAppendColumn treeView column
       void $ Gtk.treeViewSetHeadersVisible treeView True

    -- Fill the first cell
    do value <- Gtk.toGValue (Just "First Cell" :: Maybe String)
       iter <- Gtk.listStoreAppend listStore
       Gtk.listStoreSet listStore iter [0] [value]

    void $ Gtk.onTreeViewCursorChanged treeView $ do
      (mTreePath, _) <- Gtk.treeViewGetCursor treeView
      case mTreePath of
        Nothing -> die "No iterator"
        Just treePath -> do
          (isValid, iter) <- Gtk.treeModelGetIter listStore treePath
          unless isValid $ die "Invalid iterator"
          gvalue <- Gtk.treeModelGetValue listStore iter 0
          -- Trigger the bug
          Just s <- Gtk.fromGValue gvalue :: IO (Maybe String)
          putStrLn s

    Gtk.containerAdd window treeView
    Gtk.widgetShowAll window
  void $ Gio.applicationRun app Nothing

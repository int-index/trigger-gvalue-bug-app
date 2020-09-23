# Trigger a ListStore/GValue Bug

It used to work:

```
nix-shell --command "runhaskell Bug.hs -Wall"
```

But no longer does:

```
nix-shell --arg broken false --command "runhaskell Bug.hs -Wall"
```

```
(ghc:19451): GLib-GObject-CRITICAL **: 01:16:38.003: g_value_get_string: assertion 'G_VALUE_HOLDS_STRING (value)' failed
Bug.hs: user error (Pattern match failure in do expression at Bug.hs:40:11-16)
Bug.hs: interrupted
Bug.hs: warning: too many hs_exit()s
```

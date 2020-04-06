# keep-temp-buffers.el
The script saves all buffers (temporary and file based) when emacs exits and restores them at startup.

## Install
Copy the script to your emacs scripts folder and add the following lines to the end of your `.emacs`.
```emacs-lisp
(require 'keep-temp-buffers) ; or you can use (load "PATH/keep-temp-buffers.el")
(load-temp-buffers)
(add-hook 'kill-emacs-hook 'save-temp-buffers)
```

Make sure you've added it to the end of `.emacs`. This will help you to load buffers properly.

If you don't want the buffers to be saved this session, use the following command:
```
(do-not-save-temp-buffers)
```
Next session previously saved buffers will be loaded. 

## How it works
All buffers are saved in `~/.emacs.d/temp-buffers`. You can save currently opened buffers via `save-temp-buffers`.
Buffers are saved when emacs exits. 

All data are kept as a list. So, file buffers are represented as a list like (:file "file path").
Non-file buffers are also kept as a list and contain all the text and major mode, like this (:name "buffer name" :mode major-mode :text "buffer text")

You can load saved buffers via `load-temp-buffers`.

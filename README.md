# keep-temp-buffers.el
Save and load buffers automatically.
I know there are sessions in Emacs, but I prefer own easy to use script.
It keeps all buffers (besides onces started with " " or "*") to load them next emacs session automatically.

## Install
Copy the script to your emacs scripts folder and add the following lines to the end of your `.emacs`.
```emacs-lisp
(require 'keep-temp-buffers) ; or you can use (load "PATH/keep-temp-buffers.el")
(load-temp-buffers)
(add-hook 'kill-emacs-hook 'save-temp-buffers)
```

Make sure you've added it to the end of `.emacs`. This will help you to load buffers properly.

If you don't want buffers to be saved this session, use the following command:
```
(do-not-save-temp-buffers)
```
Next session, of course, previously saved buffers will be loaded. 

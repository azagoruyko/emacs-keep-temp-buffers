;;;; Keep temporary buffers

(defvar keep-temp-buffers/save-p t "Save buffers via `save-temp-buffers`?")

(defun do-not-save-temp-buffers()
  "Do not save temp buffers via `save-temp-buffers`."
  (interactive)
  (setq keep-temp-buffers/save-p nil))

(defun save-temp-buffers()
  "Save temporary buffers to load them next session.
Save all buffers which name doesn't start with *(star).
File buffers keep as file paths."
  (interactive)
  
  (when keep-temp-buffers/save-p
    (let* ((file-name "~/.emacs.d/temp-buffers")
	   (temp-file-name (concat file-name "#"))
	   (current-buffer (buffer-name))
	   (current-point (point))
	   (allowed '("*scratch*"))
	   (buffers (buffer-list))
	   (is-valid (lambda (name)
		       (and (or (not (string-match "^[ ]*\\*" name))
				(member name allowed))
			    (not (string-match "^[ ]+" name))
			    (not buffer-read-only)))))

      (copy-file file-name temp-file-name)
      
      (save-excursion
	(find-file file-name)
	(erase-buffer)

	(print (list (cl-loop
		      for b in buffers
		      for bn = (buffer-name b)
		      for bf = (buffer-file-name b)
		      when (funcall is-valid bn)
		      collect (save-excursion
				(set-buffer b)
				(if (and bf (file-exists-p bf))
				    (progn
				      (save-buffer)
				      (list :file bf))
				  (save-restriction
				    (widen)
				    (list :name bn
					  :mode major-mode
					  :text (buffer-substring-no-properties (point-min)
										(point-max)))))))

		     (if (funcall is-valid current-buffer)
			 (list :default current-buffer :point current-point)
		       (list :default "*scratch*" :point 1)))
	       (current-buffer))

	(save-buffer)
	(kill-buffer))
      
      (delete-file temp-file-name))
    (setq keep-temp-buffers/save-p nil)))
;; ----------------------------------------------
(defun load-temp-buffers()
  "Load saved temporary buffers."
  (interactive)

  (let* ((file-name "~/.emacs.d/temp-buffers")
	 (temp-file-name (concat file-name "#"))
	 default-buffer
	 default-point)

    (when (file-exists-p temp-file-name)
      (warn "Found temporary file. Original buffers file will be recovered")
      (copy-file temp-file-name file-name t)
      (delete-file temp-file-name))

    (if (not (file-exists-p file-name))
	(warn "File buffer '%s' doesn't exist" file-name)      
      (save-excursion
	(find-file file-name)

	(let* ((data (read (current-buffer)))
	       (buffers-data (car data))
	       (default-data (car (cdr data))))

	  (cl-loop
	   for item in buffers-data
	   for file = (plist-get item :file)
	   for name = (plist-get item :name)
	   for mode = (plist-get item :mode)
	   for text = (plist-get item :text) do

	   (save-excursion
	     (if file
		 (if (file-exists-p file)
		     (progn
		       (message "Loading '%s' file" file)
		       (find-file file))
		   (warn "Cannot find '%s' file. Skipped" file))

	       (message "Loading '%s' buffer" name)
	       (set-buffer (get-buffer-create name))
	       (funcall mode)
	       (erase-buffer)
	       (insert text))))

	  (setq default-buffer (plist-get default-data :default))
	  (setq default-point (plist-get default-data :point)))
	
	(kill-buffer))

      (when (and (get-buffer default-buffer)
		 default-point)
	(switch-to-buffer default-buffer)
	(goto-char default-point)))))

(provide 'keep-temp-buffers)

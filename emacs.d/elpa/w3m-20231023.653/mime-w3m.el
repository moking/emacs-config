;;; mime-w3m.el --- mime-view content filter for text -*- lexical-binding: nil -*-

;; Copyright (C) 2001-2005, 2009, 2010, 2012, 2013, 2017, 2019, 2021-2023
;; TSUCHIYA Masatoshi <tsuchiya@namazu.org>

;; Author: TSUCHIYA Masatoshi <tsuchiya@namazu.org>,
;;         Akihiro Arisawa    <ari@mbf.sphere.ne.jp>
;; Keywords: HTML, MIME, multimedia, mail, news

;; This file is *NOT* yet part of SEMI (Suite of Emacs MIME Interfaces).

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; To use this module along with a SEMI-based mail client (e.g.
;; Wanderlust), add this one to your ~/.emacs file or ~/.wl.el file:
;;
;; (require 'mime-w3m)

;;; Code:

(eval-when-compile (require 'cl-lib)) ;; cl-labels
(require 'mime-view nil t)
(eval-and-compile
  (unless (featurep 'mime-view)
    ;; Conceal the warnings that will be issued unless the SEMI package
    ;; and its requirements have been installed.
    (defvar mime-view-text/html-previewer nil)
    (declare-function ctree-set-calist-strictly "calist")
    (declare-function mime-content-type-parameter "mime-def")
    (declare-function mime-entity-content "mime")
    (declare-function mime-entity-content-type "mime")
    (declare-function mime-entity-fetch-field "mime")
    (declare-function mime-entity-type/subtype "mime")
    (declare-function mime-find-entity-from-content-id "mime")
    (declare-function mime-find-root-entity "mime")
    (declare-function mime-insert-text-content "mime")
    (declare-function mime-uri-parse-cid "mime")
    (declare-function set-alist "alist")))
(require 'w3m)

(defcustom mime-w3m-display-inline-images 'default
  "Non-nil means that inline images are displayed.
When this option is equal to `default',
`w3m-default-display-inline-images' is refered instead of this option,
to decide whether inline images are displayed."
  :group 'w3m
  :group 'mime-view
  :type '(radio (const :format "%v " nil)
		(sexp :format "non-nil "
		      :match
		      (lambda (widget value)
			(and value (not (eq value 'default))))
		      :value-to-internal
		      (lambda (widget value)
			(if (and value (not (equal value "default")))
			    (widget-sexp-value-to-internal widget value)
			  "t")))
		(const default)))

(defcustom mime-w3m-safe-url-regexp "\\`cid:"
  "Regexp that matches safe url names.
Some HTML mails might have the trick of spammers using <img> tags.  It
is likely to be intended to verify whether you have read the mail.
You can prevent your personal informations from leaking by setting
this to the regexp which matches the safe url names.  The value of the
variable `w3m-safe-url-regexp' will be bound with this value.  You may
set this value to nil if you consider all the urls to be safe."
  :group 'mime-w3m
  :type '(choice (regexp :format "%t: %v")
		 (const :tag "All URLs are safe" nil)))

(defcustom mime-w3m-after-cursor-move-hook
  '(w3m-print-this-url)
  "Hook run each time after the cursor moves in mime-w3m buffers.
This hook is called by the `mime-w3m-check-current-position' function
by way of `post-command-hook'."
  :group 'mime-w3m
  :type 'hook)

(defcustom mime-w3m-setup-hook nil
  "Hook run at the end of function `mime-w3m-setup'."
  :group 'mime-w3m
  :type 'hook)

(defvar mime-w3m-message-structure nil)
(make-variable-buffer-local 'mime-w3m-message-structure)

(defun mime-w3m-insinuate ()
  "Insinuate `mime-w3m' module to SEMI."
  (setq mime-view-text/html-previewer nil)
  (let (flag)
    (when (boundp 'mime-preview-condition)
      (cl-labels
	  ((overwrite (x)
		      (if (symbolp x)
			  (if (eq x 'mime-preview-text/html)
			      (setq flag 'mime-w3m-preview-text/html)
			    (when (eq x 'mime-w3m-preview-text/html)
			      (setq flag t))
			    x)
			(if (consp x)
			    (cons (overwrite (car x)) (overwrite (cdr x)))
			  x))))
	(setq mime-preview-condition
	      (overwrite mime-preview-condition))))
    (unless flag
      (eval-after-load "mime-view"
	'(progn
	   (ctree-set-calist-strictly
	    'mime-preview-condition
	    '((type . text)
	      (subtype . html)
	      (body . visible)
	      (body-presentation-method . mime-w3m-preview-text/html)))
	   (set-alist 'mime-view-type-subtype-score-alist
		      '(text . html) 3))))))

(defun mime-w3m-setup ()
  "Setup `mime-w3m' module."
  (require 'w3m)
  (when (eq mime-w3m-display-inline-images 'default)
    (setq mime-w3m-display-inline-images w3m-default-display-inline-images))
  (unless (assq 'mime-view-mode w3m-cid-retrieve-function-alist)
    (push (cons 'mime-view-mode 'mime-w3m-cid-retrieve)
	  w3m-cid-retrieve-function-alist))
  (run-hooks 'mime-w3m-setup-hook))

;;;###autoload
(defun mime-w3m-preview-text/html (entity situation)
  (mime-w3m-setup)
  (setq mime-w3m-message-structure (mime-find-root-entity entity))
  (let ((p (point))
	(xref
	 (or (mime-entity-fetch-field entity "xref")
	     (mime-entity-fetch-field mime-w3m-message-structure "xref"))))
    (goto-char p)
    (insert "\n")
    (goto-char p)
    (save-restriction
      (narrow-to-region p p)
      (mime-insert-text-content entity)
      (run-hooks 'mime-text-decode-hook)
      (condition-case err
	  (let ((w3m-safe-url-regexp mime-w3m-safe-url-regexp)
		(w3m-display-inline-images mime-w3m-display-inline-images)
		w3m-force-redisplay)
	    (w3m-region p (point-max)
			(and (stringp xref)
			     (string-match "\\`http://" xref)
			     xref)
			(mime-content-type-parameter
			 (mime-entity-content-type entity)
			 "charset"))
	    (add-text-properties p (point-max)
				 (list 'keymap w3m-minor-mode-map
				       'text-rendered-by-mime-w3m t)))
	(error (message "%s" err))))))

(advice-add
 'mime-display-message :after
 ;; Add some emacs-w3m utility functions to pre/post-command-hook.
 (lambda (&rest _)
   (when (featurep 'w3m)
     (add-hook 'pre-command-hook 'w3m-store-current-position nil t)
     (add-hook 'post-command-hook 'mime-w3m-check-current-position nil t)))
 '((name . add-emacs-w3m-functions-to-pre/post-command-hook)))

(defun mime-w3m-check-current-position ()
  "Run `mime-w3m-after-cursor-move-hook' if the cursor has been moved."
  (when (and (/= (point) (car w3m-current-position))
	     (ignore-errors
	       (or (get-text-property (point)
				      'text-rendered-by-mime-w3m)
		   (get-text-property (car w3m-current-position)
				      'text-rendered-by-mime-w3m))))
    (run-hooks 'mime-w3m-after-cursor-move-hook)))

(defun mime-w3m-cid-retrieve (url &rest args)
  (let ((entity (mime-find-entity-from-content-id
		 (mime-uri-parse-cid url)
		 (with-current-buffer w3m-current-buffer
		   mime-w3m-message-structure))))
    (when entity
      ;; `mime-decode-string' should be performed in a unibyte buffer.
      (w3m-insert-string (mime-entity-content entity))
      (mime-entity-type/subtype entity))))

(advice-add
 'kill-new :filter-args
 ;; Strip `keymap' or `local-map' properties from a killed string.
 (lambda (args)
   (let ((str (car args)))
     (if (text-property-any 0 (length str) 'text-rendered-by-mime-w3m t str)
	 (progn
	   (remove-text-properties 0 (length str) '(keymap nil local-map nil)
				   str)
	   (cons str (cdr args)))
       args)))
 '((name . strip-keymap-properties-from-kill)))

(mime-w3m-insinuate)

(provide 'mime-w3m)

;;; mime-w3m.el ends here

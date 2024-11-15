;;; line-reminder-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from line-reminder.el

(autoload 'line-reminder-mode "line-reminder" "\
Minor mode `line-reminder-mode'.

This is a minor mode.  If called interactively, toggle the
`Line-Reminder mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `line-reminder-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(put 'global-line-reminder-mode 'globalized-minor-mode t)
(defvar global-line-reminder-mode nil "\
Non-nil if Global Line-Reminder mode is enabled.
See the `global-line-reminder-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `global-line-reminder-mode'.")
(custom-autoload 'global-line-reminder-mode "line-reminder" nil)
(autoload 'global-line-reminder-mode "line-reminder" "\
Toggle Line-Reminder mode in all buffers.
With prefix ARG, enable Global Line-Reminder mode if ARG is positive;
otherwise, disable it.

If called from Lisp, toggle the mode if ARG is `toggle'.
Enable the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

Line-Reminder mode is enabled in all buffers where
`line-reminder--turn-on-line-reminder-mode' would do it.

See `line-reminder-mode' for more information on Line-Reminder mode.

(fn &optional ARG)" t)
(autoload 'line-reminder-clear-reminder-lines-sign "line-reminder" "\
Clear all the reminder lines' sign." t)
(autoload 'line-reminder-transfer-to-saved-lines "line-reminder" "\
Transfer the `change-lines' to `saved-lines'." t)
(register-definition-prefixes "line-reminder" '("line-reminder-"))

;;; End of scraped data

(provide 'line-reminder-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; line-reminder-autoloads.el ends here

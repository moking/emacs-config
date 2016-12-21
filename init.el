(require 'package)
(add-to-list 'package-archives
         '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)

(when (not package-archive-contents)
    (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(add-to-list 'load-path "~/.emacs.d/custom")

(require 'setup-general)
(if (version< emacs-version "24.4")
    (require 'setup-ivy-counsel)
  (require 'setup-helm)
  (require 'setup-helm-gtags))
;; (require 'setup-ggtags)
(require 'setup-cedet)
(require 'setup-editing)



;; function-args
;; (require 'function-args)
;; (fa-config-default)
;; (define-key c-mode-map  [(tab)] 'company-complete)
;; (define-key c++-mode-map  [(tab)] 'company-complete)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ecb-options-version "2.50")
 '(ecb-primary-secondary-mouse-buttons (quote mouse-1--mouse-2))
 '(ecb-source-path
   (quote
    ((#("/home/nifan/git/mcopy-dedup" 0 27
        (help-echo "Mouse-2 toggles maximizing, mouse-3 displays a popup-menu"))
      "mcopy-dedup"))))
 '(ecb-tip-of-the-day nil)
 '(package-selected-packages
   (quote
    (zygospore helm-gtags helm yasnippet ws-butler volatile-highlights use-package undo-tree iedit dtrt-indent counsel-projectile company clean-aindent-mode anzu)))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Inconsolata" :foundry "PfEd" :slant normal :weight normal :height 120 :width normal)))))

(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(add-to-list 'company-backends 'company-c-headers)


(add-to-list 'load-path "~/.emacs.d/elpa/evil")
(require 'evil)
(evil-mode 1)

(cscope-setup)
(global-set-key (kbd "M-;") 'comment-dwim-2)
(global-set-key (kbd "M-p") 'ace-window)

(define-key global-map [(control f3)]  'cscope-set-initial-directory)
(define-key global-map [(control f4)]  'cscope-unset-initial-directory)
(define-key global-map [(control f5)]  'cscope-find-this-symbol)
(define-key global-map [(control f6)]  'cscope-find-global-definition)
(define-key global-map [(control f7)]
  'cscope-find-global-definition-no-prompting)
(define-key global-map [(control f8)]  'cscope-pop-mark)
(define-key global-map [(control f9)]  'cscope-history-forward-line)
(define-key global-map [(control f10)] 'cscope-history-forward-file)
(define-key global-map [(control f11)] 'cscope-history-backward-line)
(define-key global-map [(control f12)] 'cscope-history-backward-file)
(define-key global-map [(meta f9)]  'cscope-display-buffer)
(define-key global-map [(meta f10)] 'cscope-display-buffer-toggle)

 (load-file "~/.emacs.d/elpa/dedicated.el")
(require 'dedicated)

(defun save_and_normal (&optional arg)
  "saving buffer and go to normal mode."
  (interactive)
  (save-buffer)
  (evil-normal-state)
)


(define-key global-map [(f1)]  'save_and_normal)
(show-paren-mode)

(define-key global-map [(meta f12)]  'dedicated-mode)

(tabbar-mode)
(global-set-key (kbd "M-]") 'tabbar-forward-group)
(global-set-key (kbd "M-[") 'tabbar-backward-group)
(global-set-key (kbd "M-<right>") 'tabbar-forward-tab)
(global-set-key (kbd "M-<left>") 'tabbar-backward-tab)

(define-key evil-normal-state-map "e" 'end-of-line)
(define-key evil-normal-state-map "wl" 'windmove-right)
(define-key evil-normal-state-map "wh" 'windmove-left)
(define-key evil-normal-state-map "ww" 'ace-window)

;;{{{ General
;; enable common lisp extensions
(require 'cl)
;; disable beep
(setq visible-bell 1)
;;}}}

;;{{{ Packages
;; helper to evaluate a remote emacs lisp file
(defun eval-url (url)
  (let ((buffer (url-retrieve-synchronously url)))
    (save-excursion
      (set-buffer buffer)
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move)
      (eval-region (point) (point-max))
      (kill-buffer (current-buffer)))))
;; helper to install el-get
(defun install-el-get ()
  (eval-url "https://github.com/dimitri/el-get/raw/master/el-get-install.el")
  (el-get-emacswiki-refresh))
;; initialize el-get
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
;; install el-get if not installed already
(unless (require 'el-get nil t)
  (install-el-get))
;; set package-specific intialization directory
(setq el-get-user-package-directory "~/.emacs.d/packages.d")
;; declare required packages
(setq
 my:el-get-packages
 '(el-get
   evil-surround
   linum-relative
   color-theme-almost-monokai))
;; local recipes/overrides
(setq
 el-get-sources
 '((:name evil
	  :after (progn
		   (global-set-key (kbd "M-h") 'evil-window-left)
		   (global-set-key (kbd "M-l") 'evil-window-right)
		   (global-set-key (kbd "M-k") 'evil-window-up)
		   (global-set-key (kbd "M-j") 'evil-window-down)
		   (global-set-key (kbd "M-<left>") 'evil-window-left)
		   (global-set-key (kbd "M-<right>") 'evil-window-right)
		   (global-set-key (kbd "M-<up>") 'evil-window-up)
		   (global-set-key (kbd "M-<down>") 'evil-window-down)))

   (:name evil-leader
	  :after (progn
		   (setq evil-leader/leader ",")))

   (:name evil-nerd-commenter
	  :website "http://github.com/redguardtoo/evil-nerd-commenter"
	  :description "Emulate NERDCommenter plugin for vim"
	  :type github
	  :pkgname "redguardtoo/evil-nerd-commenter"
	  :features evil-nerd-commenter
	  :depends evil
	  :after (progn
		   (define-key
		     evil-normal-state-map
		     (kbd "\\\\")
		     'evilnc-comment-or-uncomment-lines)))

   (:name move-text
	  :depends evil
	  :after (progn
		   (global-set-key [M-up] 'move-text-up)
		   (global-set-key [M-down] 'move-text-down)
		   ))

   (:name helm
   	  :depends evil
   	  :after (progn
   		   (define-key evil-normal-state-map (kbd "C-p") 'helm-find)))

   (:name folding
	  :post-init (folding-mode-add-find-file-hook))
   ))
;; put the custom recipes in the my:el-get-packages variable
(setq my:el-get-packages
      (append my:el-get-packages
	      (loop for src in el-get-sources
		    collect (el-get-source-name src))))
;; ensure required packages are installed/loaded
(el-get 'sync my:el-get-packages)
;;}}}

;;{{{ Backup
;; prefix with a dot as well as postfix with a tilde
(defun custom-make-backup-file-name ( file )
  (let ((d (file-name-directory file))
	(f (file-name-nondirectory file)))
    (concat d "." f "~")))
(setq make-backup-file-name-function 'custom-make-backup-file-name)
(defun backup-file-name-p ( file )
  (let ((letters (string-to-list (file-name-nondirectory file))))
    (and (> 2 (length letters))
	 (equal "." (first letters))
	 (equal "~" (last letters)))))
(defun file-name-sans-versions ( file )
  (if (not (backup-file-name-p file))
      file
    (let ((d (file-name-directory file))
	  (f (file-name-nondirectory file)))
      (let ((letters (string-to-list f)))
	(concat d (subseq letters 1 (- (length f) 1)))))))
;;}}}

;;{{{ UI
(setq default-frame-alist '((font-backend . "xft")
			    (font . "Ubuntu Mono-17")
			    (scroll-bar-mode . 0)
			    (menu-bar-lines . 0)
			    (tool-bar-lines . 0)))
;; hide toolbar
(tool-bar-mode 0)
;; hide menubar
(menu-bar-mode 0)
;; hide scrollbar
(scroll-bar-mode 0)
;; don't blink
(blink-cursor-mode 0)
;;}}}

;;{{{ Behavior
;; show matching parens
(show-paren-mode 1)
;; show line numbers
(line-number-mode 1)
(column-number-mode 1)
(global-linum-mode t)
;;}}}
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(safe-local-variable-values (quote ((eval setq default-directory (locate-dominating-file buffer-file-name ".dir-locals.el"))))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(linum-relative-current-face ((t :foreground "red"))))

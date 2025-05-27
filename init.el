

;; Do not show the startup screen.
(setq inhibit-startup-message t)

;; Disable tool bar, menu bar, scroll bar.
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)


;; Use `command` as `meta` in macOS.
(setq mac-command-modifier 'meta)

;; Do not use `init.el` for `custom-*` code - use `custom-file.el`.
(setq custom-file "~/.config/emacs/custom-file.el")

;; Assuming that the code in custom-file is execute before the code
;; ahead of this line is not a safe assumption. So load this file
;; proactively.
(load-file custom-file)


;; Make all commands of the “package” module present.
(require 'package)

;; Internet repositories for new packages.
(setq package-archives '(("gnu"    . "http://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa"  . "http://melpa.org/packages/")))

;; Update local list of available packages:
;; Get descriptions of all configured ELPA packages,
;; and make them available for download.
(package-refresh-contents)

;;  Make sure use-package is installed
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

;; We can now invoke (use-package XYZ :ensure t) which should check for the XYZ package and makes sure it is accessible. If the file is not on our system, the :ensure t part tells use-package to download it —using the built-in package manager
(setq use-package-always-ensure t)


(use-package auto-package-update
  :config
  ;; Delete residual old versions
  (setq auto-package-update-delete-old-versions t)
  ;; Do not bother me when updates have taken place.
  (setq auto-package-update-hide-results t)
  ;; Update installed packages at startup if there is an update pending.
  (auto-package-update-maybe))


;; quelpa for installing  packages from git
(use-package quelpa
  :custom (quelpa-upgrade-p t "Always try to update packages")
  :config
  ;; Get ‘quelpa-use-package’ via ‘quelpa’
  (quelpa
   '(quelpa-use-package
     :fetcher git
     :url "https://github.com/quelpa/quelpa-use-package.git"))
  (require 'quelpa-use-package))





(use-package system-packages
  :ensure t)

(use-package gcmh
  :demand t
  :config
  (gcmh-mode 1))


(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))




(use-package emacs
  :hook
  ('before-save . #'delete-trailing-whitespace)
  :config

  ;; Set default font size (120 = 12pt)
  (set-face-attribute 'default nil :height 120)

  (setq-default
   indent-tabs-mode nil
   fill-column 115
   truncate-string-ellipsis "…"
   sentence-end-double-space nil
   cursor-type '(box .  2)
   cursor-in-non-selected-windows nil
   bidi-paragraph-direction 'left-to-right)
  (setq
   tab-width 4
   tab-always-indent 'complete
   require-final-newline t
   custom-safe-themes t
   confirm-kill-emacs #'yes-or-no-p
   dired-kill-when-opening-new-dired-buffer t
   completion-cycle-threshold 3
   tab-always-indent 'complete
   version-control t
   kept-new-versions 10
   kept-old-versions 0
   delete-old-versions t
   vc-make-backup-files t
   make-backup-files nil
   use-dialog-box nil
   global-auto-revert-non-file-buffers t
   blink-cursor-mode nil
   history-delete-duplicates t
   default-directory "~/"
   confirm-kill-processes nil
   ;; Open files in new windows instead of replacing current buffer
   switch-to-buffer-obey-display-actions t
   display-buffer-alist
   '((".*" (display-buffer-reuse-window display-buffer-pop-up-window)
      (reusable-frames . visible)
      (pop-up-windows . t))))
  (delete-selection-mode t)
  (column-number-mode t)
  (size-indication-mode t)
  ;; (global-hl-line-mode 1)
  (global-auto-revert-mode 1)
  (defalias 'yes-or-no-p 'y-or-n-p)
  (prefer-coding-system 'utf-8)
  (set-charset-priority 'unicode)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-language-environment   'utf-8)
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  (defun prot/keyboard-quit-dwim ()
    "Do-What-I-Mean behaviour for a general `keyboard-quit'.

    The generic `keyboard-quit' does not do the expected thing when
    the minibuffer is open.  Whereas we want it to close the
    minibuffer, even without explicitly focusing it.

    The DWIM behaviour of this command is as follows:

      - When the region is active, disable it.
      - When a minibuffer is open, but not focused, close the minibuffer.
      - When the Completions buffer is selected, close it.
      - In every other case use the regular `keyboard-quit'."
    (interactive)
    (cond
     ((region-active-p)
      (keyboard-quit))
     ((derived-mode-p 'completion-list-mode)
      (delete-completion-window))
     ((> (minibuffer-depth) 0)
      (abort-recursive-edit))
     (t
      (keyboard-quit))))
  :bind
  ("C-g" . #'prot/keyboard-quit-dwim)
  ("C-c q" . #'bury-buffer)
  ("<escape>" . #'keyboard-escape-quit)
  )



;;------------------------------------------ Package Configuration ends -----------------------------------------------


(use-package helm
  :init (helm-mode t)
  :bind (("M-x"     . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x b"   . helm-mini)     ;; See buffers & recent files; more useful.
         ("C-x r b" . helm-filtered-bookmarks)
         ("C-x C-r" . helm-recentf)  ;; Search for recently edited files
         ("C-c i"   . helm-imenu) ;; C.f. "C-x t m" (imenu-list)
         ;; ("C-u C-c i" . imenu-list)  ;; TODO FIXME  Key sequence C-u C-c i starts with non-prefix key C-u
         ("C-h a"   . helm-apropos)
         ;; Look at what was cut recently & paste it in.
         ("M-y" . helm-show-kill-ring)
         ("C-x C-x" . helm-all-mark-rings)
         :map helm-map
         ;; We can list 'actions' on the currently selected item by C-z.
         ("C-z" . helm-select-action)
         ;; Let's keep tab-completeion anyhow.
         ("TAB"   . helm-execute-persistent-action)
         ("<tab>" . helm-execute-persistent-action)))

;; Configure Helm mini sources
(setq helm-mini-default-sources '(helm-source-buffers-list
                                  helm-source-recentf
                                  helm-source-bookmarks
                                  helm-source-bookmark-set
                                  helm-source-buffer-not-found))

;; Make RETURN key act the same way as “y” key for “y-or-n” prompts.
;; E.g., (y-or-n-p "Happy?") accepts RETURN as “yes”.
(define-key y-or-n-p-map [return] 'act)


;; Move to end/ start of line of code,comment skipping whitespaces
(use-package mwim

  :bind (("C-a" . mwim-beginning)
         ("C-e" . mwim-end)))





(use-package goto-chg
  :ensure t
  :bind (("C-." . goto-last-change)
         ("C-," . goto-last-change-reverse)))




;; Save backup files in a dedicated directory, files startig with ~
(setq backup-directory-alist '(("." . "~/.saves")))



(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map ) )

(use-package apheleia

  :hook (prog-mode . apheleia-mode)
  ;; FIXME: Clj specific stuff should be moved out of here
  ;; :ensure-system-package cljstyle
  :config
  (setf (alist-get 'cljstyle apheleia-formatters)
	'("cljstyle" "pipe"))
  ;; NOTE: Need to install `isort` and `ruff` for this
  (add-to-list 'apheleia-mode-alist '(python-ts-mode . (isort ruff)))
  (add-to-list 'apheleia-mode-alist '(clojure-mode . cljstyle))
  (add-to-list 'apheleia-mode-alist '(clojurec-mode . cljstyle))
  (add-to-list 'apheleia-mode-alist '(clojurescript-mode . cljstyle))
  (apheleia-global-mode t))





(use-package rainbow-delimiters

  :hook ((prog-mode . rainbow-delimiters-mode)
         (emacs-lisp-mode . rainbow-delimiters-mode)))


(use-package jarchive
  :demand t)








(use-package eglot

  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename))
  :hook
  (go-mode . eglot-ensure)
  :config
  (jarchive-setup)
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode)
                 "basedpyright-langserver" "--stdio"))
  :custom
  (eglot-autoshutdown t)
  (eglot-extend-to-xref nil)
  (eglot-confirm-server-initiated-edits nil)
  (eglot-sync-connect nil)
  ;; don't need these features as they are provided from elsewhere
  (eglot-ignored-server-capabilities '(:hoverProvider
                                       :documentOnTypeFormattingProvider
                                       :executeCommandProvider))
  (eglot-connect-timeout 120)
  :custom-face
  (eglot-inlay-hint-face  ((t (:inherit shadow :weight semi-light :height 0.8)))))





;; NOTE!!!: This is for making LSP faster.
;; `cargo install emacs-lsp-booster`

(use-package eglot-booster
  :quelpa (eglot-booster :fetcher github
                         :repo "jdtsmith/eglot-booster"
                         :branch "main")
  :after eglot
  :config (eglot-booster-mode))




(use-package markdown-mode

  :ensure-system-package (multimarkdown)
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package yaml-mode )



(use-package flycheck
  :config
  (setq-default flycheck-indication-mode 'left-fringe)
  (setq-default flycheck-highlighting-mode 'columns)
  :hook
  ;; limiting its use because for other langs we have lsp
  ((emacs-lisp-mode . flycheck-mode)
   (flycheck-mode . flycheck-set-indication-mode)))



(use-package rg

  :commands (rg-menu rg-dwim)
  :ensure-system-package (rg . ripgrep)
  :bind (("C-c s" . rg-menu)
         ("C-c d" . rg-dwim))
  :config
  (rg-enable-default-bindings))


(use-package tree-sitter-langs)

(use-package blackout
  :ensure t)

(use-package python
  :mode ("\\.py\\'" . python-ts-mode)
  :blackout "Π"
  :config
  (blackout 'python-ts-mode "Π")
  (require 'tree-sitter)
  (require 'tree-sitter-langs))


(use-package pet
  :commands (pet-mode)
  :init
  (add-hook 'python-base-mode-hook 'pet-mode -10)
  (add-hook 'python-mode-hook
            (lambda ()
              (setq-local python-shell-interpreter (pet-executable-find "python")
                          python-shell-virtualenv-root (pet-virtualenv-root))
              (pet-eglot-setup)
              (pet-flycheck-setup))))




(use-package paredit
  :blackout t
  :bind
  (:map paredit-mode-map
        ("M-(" . paredit-wrap-round)
        ("M-{" . paredit-wrap-curly)
        ("{" . paredit-open-curly)
        ("M-[" . paredit-wrap-square)
        ("M-]" . paredit-close-square-and-newline)
        ("C-(" . paredit-forward-slurp-sexp)
        ("C-{" . paredit-forward-barf-sexp)
        ("C-)" . paredit-backward-slurp-sexp)
        ("C-}" . paredit-backward-barf-sexp)
        ("RET" . nil)
        ("M-;" . nil)
        ("M-j" . paredit-newline))
  :hook ((clojure-mode . enable-paredit-mode)
         (clojurescript-mode . enable-paredit-mode)
         (clojurec-mode . enable-paredit-mode)
         (cider-repl-mode . enable-paredit-mode)
         (emacs-lisp-mode . enable-paredit-mode)
         (eval-expression-minibuffer-setup . enable-paredit-mode)
         (lisp-interaction-mode . enable-paredit-mode))
  :config
  (show-paren-mode t))



(use-package sql-indent
  :mode ("\\.sql\\'" . sqlind-minor-mode))


(use-package csv-mode
  :blackout "CSV"
  :mode ("\\.csv\\'" . csv-mode)
  :custom (csv-align-max-width 115))





(use-package jsonian

  :mode ("\\.json\\'" . jsonian-mode))



(use-package js2-mode
  :interpreter (("node" . js2-mode))
  :blackout "JS"
  :mode "\\.\\(js\\|json\\)$"
  ;; JS2 has its own faces, here I override them with `font-lock` faces for an uniform look
  :custom-face
  (js2-function-param ((t (:foreground ,(face-foreground 'font-lock-variable-name-face)))))
  (js2-function-call ((t (:foreground ,(face-foreground 'font-lock-function-name-face)))))
  (js2-object-property ((t (:foreground ,(face-foreground 'font-lock-variable-name-face)))))
  (js2-external-variable ((t (:foreground ,(face-foreground 'font-lock-variable-name-face)))))
  (js2-jsdoc-tag ((t (:foreground ,(face-foreground 'font-lock-doc-face)))))
  (js2-jsdoc-type ((t (:foreground ,(face-foreground 'font-lock-type-face)))))
  (js2-jsdoc-value ((t (:foreground ,(face-foreground 'font-lock-variable-name-face)))))
  (js2-private-member ((t (:foreground ,(face-foreground 'font-lock-variable-name-face)))))
  (js2-private-function-call ((t (:foreground ,(face-foreground 'font-lock-function-name-face)))))
  (js2-keywords ((t (:foreground ,(face-foreground 'font-lock-keyword-face)))))
  (js2-warning ((t (:foreground ,(face-foreground 'font-lock-warning-face)))))
  (js2-error ((t (:foreground ,(face-foreground 'error)))))
  (js2-constant ((t (:foreground ,(face-foreground 'font-lock-constant-face)))))
  (js2-built-in ((t (:foreground ,(face-foreground 'font-lock-builtin-face)))))
  (js2-string ((t (:foreground ,(face-foreground 'font-lock-string-face)))))
  (js2-regexp ((t (:foreground ,(face-foreground 'font-lock-string-face)))))
  (js2-comment ((t (:foreground ,(face-foreground 'font-lock-comment-face)))))
  (js2-instance-member ((t (:foreground ,(face-foreground 'font-lock-variable-name-face)))))
  (js2-magic-paren ((t (:foreground ,(face-foreground 'font-lock-preprocessor-face)))))
  :config
  (add-hook 'js-mode-hook 'js2-minor-mode)
  (setq js2-basic-offset 2
        js2-highlight-level 3
        js2-mode-show-parse-errors nil
        js2-mode-show-strict-warnings nil))




(use-package jinx
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))




(use-package consult-eglot
  :after (eglot)
  :commands (consult-eglot-symbols))




(use-package which-key
  :ensure t
  :commands (which-key-mode)
  :init
  (which-key-mode))




;;---- GIT packages ----------------;;;

(use-package magit

  :commands (magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-diff-refine-hunk t)
  (git-commit-fill-column 72)
  (magit-diff-refine-hunk t)
  (magit-section-highlight-hook nil)
  (magit-define-global-key-bindings nil)
  (magit-log-arguments '("--graph" "--decorate" "--color"))
  :config
  (let ((sans-serif-family (face-attribute 'variable-pitch :family)))
    (set-face-attribute 'magit-diff-file-heading nil :family sans-serif-family :weight 'normal :bold nil)
    (set-face-attribute 'magit-diff-file-heading-highlight nil :family sans-serif-family :weight 'normal :bold nil)
    (set-face-attribute 'magit-section-child-count nil :family sans-serif-family :weight 'normal :bold nil)
    (set-face-attribute 'magit-section-heading nil :family sans-serif-family :bold t)
    (set-face-attribute 'magit-section-highlight nil :family sans-serif-family :bold t))
  :bind
  ("C-x g" . magit-status))




(use-package git-timemachine
  :after magit
  :bind (:map prog-mode-map
              ("C-c g t" . git-timemachine)))


(use-package git-modes

  :mode (("\\.gitattributes\\'" . gitattributes-mode)
         ("\\.gitconfig\\'" . gitconfig-mode)
         ("\\.gitignore\\'" . gitignore-mode)))


(use-package git-timemachine
  :after magit
  :bind (:map prog-mode-map
              ("C-c g t" . git-timemachine)))


(use-package diff-hl

  :after magit
  :hook
  (magit-post-refresh . #'diff-hl-magit-post-refresh)
  :custom
  (diff-hl-side 'left)
  (diff-hl-margin-symbols-alist '((insert . "│")
                                  (delete . "-")
                                  (change . "│")
                                  (unknown . "?")
                                  (ignored . "i")))
  :config
  (setq vc-git-diff-switches '("--histogram"))
  (global-diff-hl-mode))


(use-package hl-todo

  :after (ef-themes)
  :init
  (global-hl-todo-mode 1)
  :config
  (ef-themes-with-colors
   (setq hl-todo-keyword-faces
         `(("DONE" . ,green)
           ("TODO" . ,red)
           ("HOLD" . ,yellow)
           ("OKAY" . ,green-warmer)
           ("NEXT" . ,blue)
           ("NOTE" . ,blue-warmer)
           ("DONT" . ,yellow-warmer)
           ("FAIL" . ,red-warmer)
           ("BUG" . ,red-warmer)
           ("FIXME" . ,red-warmer)
           ("XXX" . ,red-warmer)
           ("DEPRECATED" . ,yellow)
           ("HACK" . ,cyan)))))


(use-package blamer

  :bind (("s-i" . blamer-show-posframe-commit-info))
  :custom
  (blamer-idle-time 0.5)
  (blamer-min-offset 10)
  (blamer-author-formatter "  ✎ %s ")
  (blamer-datetime-formatter "[%s]")
  (blamer-commit-formatter " ● %s")
  (blamer-type 'visual)
  (blamer-view 'overlay-right)
  (blamer-max-commit-message-length 70)
  :custom-face
  (blamer-face ((t :foreground "#E06C75"
                   :background nil
                   :height 200
                   :italic t)))
  :commands (blamer-mode))



;;------ clojure --------




;;; clojure.el

(use-package clojure-mode
  :blackout ((clojure-mode . "CLJ")
             (clojurec-mode . "CLJC")
             (clojurescript-mode . "CLJS"))
  :mode (("\\.clj\\'" . clojure-mode)
         ("\\.cljc\\'" . clojurec-mode)
         ("\\.cljs\\'" . clojurescript-mode)
         ("\\.edn\\'" . clojure-mode))
  :hook ((clojure-mode . subword-mode)
         (clojure-mode . rainbow-delimiters-mode)
         (clojure-mode . eldoc-mode))
  :config
  (setq clojure-indent-style 'always-indent)
  (setq clojure-use-metadata-for-privacy t))


(use-package cider
  :hook (clojure-mode . cider-mode)
  :bind (("C-c C-l" . cider-repl-clear-buffer))
  :custom
  (nrepl-log-messages t)
  (cider-repl-display-in-current-window t)
  (cider-repl-pop-to-buffer-on-connect nil)
  (cider-repl-use-clojure-font-lock t)
  (cider-repl-use-content-types t)
  (cider-save-file-on-load t)
  (cider-prompt-for-symbol nil)
  (cider-font-lock-dynamically '(macro core var))
  (nrepl-hide-special-buffers t)
  (cider-repl-buffer-size-limit 100000)
  (cider-overlays-use-font-lock t)
  (cider-dynamic-indentation nil)
  (cider-repl-display-help-banner nil)
  (cider-repl-prompt-function #'cider-repl-prompt-abbreviated)
  (cider-format-code-options '(("indents" ((".*" (("inner" 0)))))))
  (cider-auto-mode nil)
  (cider-prefer-local-resources t)
  :config
  (defun cider-repl-type-for-buffer (&optional buffer)
    "Return the matching connection type (clj or cljs) for BUFFER.
BUFFER defaults to the `current-buffer'.  In cljc buffers return
multi.  This function infers connection type based on the major mode.
For the REPL type use the function `cider-repl-type'."
    (with-current-buffer (or buffer (current-buffer))
      (cond
       ((seq-some #'derived-mode-p '(clojurescript-ts-mode clojurescript-mode)) 'cljs)
       ((seq-some #'derived-mode-p '(clojurec-ts-mode clojurec-mode)) cider-clojurec-eval-destination)
       ((seq-some #'derived-mode-p '(clojure-ts-mode clojure-mode)) 'clj)
       (cider-repl-type))))
  ;; (defun cider--xref-backend () nil)
  (cider-repl-toggle-pretty-printing))


;;----- treemacs






(use-package treemacs
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                5000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-indentation                     1
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil

          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               60
          treemacs-width                           30
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    (treemacs-resize-icons 20)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-git-commit-diff-mode t)
    (treemacs-fringe-indicator-mode 'always)

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))
    (treemacs-hide-gitignored-files-mode t))
  (treemacs-project-follow-mode 1)
  :bind
  (:map global-map
        ("s-t"       . treemacs-add-and-display-current-project)
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))










;;---------------Cool Packages----------------------------









(use-package dumb-jump
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read))






(use-package ctrlf

  :bind (("C-s" . ctrlf-forward-default)
         ("C-M-s" . ctrlf-forward-alternate)
         ("C-r" . ctrlf-backward-default)
         ("C-M-r" . ctrlf-backward-alternate))
  :config (ctrlf-mode +1))


(use-package nerd-icons-corfu
  )

;; alternative to company completion at point minibuffer.
(use-package corfu

  :config
  (defun corfu-complete-and-quit ()
    (interactive)
    (corfu-complete)
    (corfu-quit))
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode +1)
  :bind (:map corfu-map
              ("C-n" . corfu-next)
              ("TAB" . corfu-next)
              ([tab] . corfu-next)
              ("C-p" . corfu-previous)
              ("S-TAB" . corfu-previous)
              ([backtab] . corfu-previous)
              ("RET" . corfu-complete-and-quit)
              ("<return>" . corfu-complete-and-quit)
              ("C-g" . corfu-quit)
              ("C-q" . corfu-quick-insert)
              ("S-SPC" . corfu-insert-separator)
              ([remap completion-at-point] . corfu-complete)
              ("M-d" . corfu-popupinfo-toggle)
              ("M-p" . corfu-popupinfo-scroll-down)
              ("M-n" . corfu-popupinfo-scroll-up))
  :custom
  (corfu-cycle nil)
  (corfu-auto t)
  (corfu-count 9)
  (corfu-on-exact-match 'quit)
  (corfu-preselect-first t)
  (corfu-quit-at-boundary 'separator)
  (corfu-auto-delay 0.0)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match t)
  (corfu-scroll-margin 5))


(use-package corfu-prescient

  :after (prescient corfu)
  :demand t
  :init
  (corfu-prescient-mode +1))






(use-package cape
  :demand t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file))




(use-package treemacs-magit

  :hook treemacs
  :after (treemacs magit)
  :ensure t)




(use-package super-save

  :init
  (super-save-mode 1)
  :config
  (setq super-save-auto-save-when-idle t)
  (setq auto-save-default nil))






(use-package saveplace

  :init
  (save-place-mode 1)
  :config
  (setq-default save-place t))



(use-package savehist

  :demand t
  :init
  (savehist-mode 1)
  :config
  (setq savehist-additional-variables
        '(search-ring regexp-search-ring kill-ring mark-ring)
        savehist-autosave-interval 60))





(use-package ace-window

  :bind
  ("M-o" . ace-window))


(use-package expand-region

  :bind
  ("C-=" . #'er/expand-region))







(use-package dictionary

  :after (org)
  :bind (:map text-mode-map
              ("M-." . dictionary-lookup-definition)
              :map org-mode-map
              ("M-." . dictionary-lookup-definition)
              :map dictionary-mode-map
              ("M-." . dictionary-lookup-definition))
  :init
  (add-to-list 'display-buffer-alist
               '("^\\*Dictionary\\*" display-buffer-in-side-window
                 (side . right)
                 (window-width . 50)))
  :custom
  (dictionary-server "dict.org"))





(use-package avy

  :bind
  ("M-g M-c" . avy-goto-char-timer)
  ("M-g M-g" . avy-goto-line)
  :config
  (setq avy-background t)
  (defun avy-action-helpful (pt)
    (save-excursion
      (goto-char pt)
      (helpful-at-point))
    (select-window
     (cdr (ring-ref avy-ring 0)))
    t)
  (setf (alist-get ?H avy-dispatch-alist) 'avy-action-helpful))





(use-package helpful

  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))







(use-package hide-mode-line

  :hook
  (treemacs-mode . hide-mode-line-mode))


(load-theme `manoj-dark)


;; AI related


(use-package aidermacs
  :bind (("C-c a" . aidermacs-transient-menu))
  :config
  ;; Set API_KEY in .bashrc, that will automatically picked up by aider or in elisp
  (setenv "DEEPSEEK_API_KEY" "<api-key>")

  :custom
  ;; See the Configuration section below
  (aidermacs-use-architect-mode t)
  (aidermacs-default-model "openrouter/deepseek/deepseek-chat-v3-0324:free" ))


(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))  ; pick your own prefix key here
  :init
  (persp-mode))





;;- ediff

(setq ediff-keep-variants nil)
(setq ediff-make-buffers-readonly-at-startup nil)
(setq ediff-merge-revisions-with-ancestor t)
(setq ediff-show-clashes-only t)

(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; (eval-buffer)
;; [[file:~/.emacs.d/init.org::*Support for ‘Custom’][Support for ‘Custom’:1]]
(setq custom-file "~/.emacs.d/custom.el")
(ignore-errors (load custom-file)) ;; It may not yet exist.
;; Support for ‘Custom’:1 ends here

;; [[file:~/.emacs.d/init.org::*Support for ‘Custom’][Support for ‘Custom’:2]]
(setq enable-local-variables :safe)
;; Support for ‘Custom’:2 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:1]]
;; Make all commands of the “package” module present.
(require 'package)

;; Internet repositories for new packages.
(setq package-archives '(("org"       . "http://orgmode.org/elpa/")
                         ("gnu"       . "http://elpa.gnu.org/packages/")
                         ("melpa"     . "http://melpa.org/packages/")))

;; Actually get “package” to work.
(package-initialize)
(package-refresh-contents)
;; =use-package= ---The start of =init.el=:1 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:2]]
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
;; =use-package= ---The start of =init.el=:2 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:3]]
(setq use-package-always-ensure t)
;; =use-package= ---The start of =init.el=:3 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:4]]
(use-package auto-package-update
  :defer 10
  :config
  ;; Delete residual old versions
  (setq auto-package-update-delete-old-versions t)
  ;; Do not bother me when updates have taken place.
  (setq auto-package-update-hide-results t)
  ;; Update installed packages at startup if there is an update pending.
  (auto-package-update-maybe))
;; =use-package= ---The start of =init.el=:4 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:5]]
;; Making it easier to discover Emacs key presses.
(use-package which-key
  :diminish
  :defer 5
  :config (which-key-mode)
          (which-key-setup-side-window-bottom)
          (setq which-key-idle-delay 0.05))
;; =use-package= ---The start of =init.el=:5 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:6]]
(use-package diminish
  :defer 5
  :config ;; Let's hide some markers.
    (diminish  'org-indent-mode))
;; =use-package= ---The start of =init.el=:6 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:7]]
;; Efficient version control.
;;
;; Bottom of Emacs will show what branch you're on
;; and whether the local file is modified or not.
(use-package magit
  :config (global-set-key (kbd "C-x g") 'magit-status))

(use-package htmlize :defer t)
;; Main use: Org produced htmls are coloured.
;; Can be used to export a file into a coloured html.

;; Get org-headers to look pretty! E.g., * → ⊙, ** ↦ ◯, *** ↦ ★
;; https://github.com/emacsorphanage/org-bullets
(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

;; Haskell's cool
(use-package haskell-mode :defer t)

;; Lisp libraries with Haskell-like naming.
(use-package dash)    ;; “A modern list library for Emacs”
(use-package s   )    ;; “The long lost Emacs string manipulation library”.

;; Library for working with system files;
;; e.g., f-delete, f-mkdir, f-move, f-exists?, f-hidden?
(use-package f)
;; =use-package= ---The start of =init.el=:7 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:8]]
  ;; Allow tree-semantics for undo operations.
  (use-package undo-tree
    :diminish                       ;; Don't show an icon in the modeline
    :config
      ;; Always have it on
      (global-undo-tree-mode)

      ;; Each node in the undo tree should have a timestamp.
      (setq undo-tree-visualizer-timestamps t)

      ;; Show a diff window displaying changes between undo nodes.
      (setq undo-tree-visualizer-diff t))

  ;; Execute (undo-tree-visualize) then navigate along the tree to witness
  ;; changes being made to your file live!
;; =use-package= ---The start of =init.el=:8 ends here

;; [[file:~/.emacs.d/init.org::*=use-package= ---The start of =init.el=][=use-package= ---The start of =init.el=:9]]
(defun my/git-commit-reminder ()
  (insert "\n\n# The commit subject line ought to finish the phrase:
# “If applied, this commit will ⟪your subject line here⟫.” ")
  (beginning-of-buffer))

(add-hook 'git-commit-setup-hook 'my/git-commit-reminder)
;; =use-package= ---The start of =init.el=:9 ends here

;; [[file:~/.emacs.d/init.org::enable making init and readme][enable making init and readme]]
  (defun my/make-init-el-and-README ()
    "Tangle an el and a github README from my init.org."
    (interactive "P") ;; Places value of universal argument into: current-prefix-arg
    (when current-prefix-arg
      (let* ((time      (current-time))
             (_date     (format-time-string "_%Y-%m-%d"))
             (.emacs    "~/.emacs")
             (.emacs.el "~/.emacs.el"))
        ;; Make README.org
        (save-excursion
          (org-babel-goto-named-src-block "make-readme") ;; See next subsubsection.
          (org-babel-execute-src-block))

        ;; remove any other initialisation file candidates
        (ignore-errors
          (f-move .emacs    (concat .emacs _date))
          (f-move .emacs.el (concat .emacs.el _date)))

        ;; Make init.el
        (org-babel-tangle)
        ;; (byte-compile-file "~/.emacs.d/init.el")
        (load-file "~/.emacs.d/init.el")

        ;; Acknowledgement
        (message "Tangled, compiled, and loaded init.el; and made README.md … %.06f seconds"
                 (float-time (time-since time))))))

(add-hook 'after-save-hook 'my/make-init-el-and-README nil 'local-to-this-file-please)
;; enable making init and readme ends here

;; [[file:~/.emacs.d/init.org::*‘Table of Contents’ for Org vs. Github][‘Table of Contents’ for Org vs. Github:1]]
(use-package toc-org
  ;; Automatically update toc when saving an Org file.
  :hook (org-mode . toc-org-mode)
  ;; Use both “:ignore_N:” and ":export_N:” to exlude headings from the TOC.
  :custom (toc-org-noexport-regexp
           "\\(^*+\\)\s+.*:\\(ignore\\|noexport\\)\\([@_][0-9]\\)?:\\($\\|[^ ]*?:$\\)"))
;; ‘Table of Contents’ for Org vs. Github:1 ends here

;; [[file:~/.emacs.d/init.org::*‘Table of Contents’ for Org vs. Github][‘Table of Contents’ for Org vs. Github:2]]
(cl-defun my/org-replace-tree-contents (heading &key (with "") (offset 0))
  "Replace the contents of org tree HEADING with WITH, starting at OFFSET.

Clear a subtree leaving first 3 lines untouched  ⇐  :offset 3
Deleting a tree & its contents                   ⇐  :offset -1, or any negative number.
Do nothing to a tree of 123456789 lines          ⇐  :offset 123456789

Precondition: offset < most-positive-fixnum; else we wrap to a negative number."
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (re-search-forward (format "^\\*+ %s" (regexp-quote heading)))
    ;; To avoid ‘forward-line’ from spilling onto other trees.
    (org-narrow-to-subtree)
    (org-mark-subtree)
    ;; The 1+ is to avoid the heading.
    (dotimes (_ (1+ offset)) (forward-line))
    (delete-region (region-beginning) (region-end))
    (insert with)
    (widen)))

;; Erase :TOC: body ---provided we're using toc-org.
;; (my/org-replace-tree-contents "Table of Contents")
;; ‘Table of Contents’ for Org vs. Github:2 ends here

;; [[file:~/.emacs.d/init.org::*Installing Emacs packages directly from source][Installing Emacs packages directly from source:1]]
(use-package quelpa
  :defer t
  :custom (quelpa-upgrade-p t "Always try to update packages")
  :config
  ;; Get ‘quelpa-use-package’ via ‘quelpa’
  (quelpa
   '(quelpa-use-package
     :fetcher git
     :url "https://github.com/quelpa/quelpa-use-package.git"))
  (require 'quelpa-use-package))
;; Installing Emacs packages directly from source:1 ends here

;; [[file:~/.emacs.d/init.org::*=magit= ---Emacs' porcelain interface to gitq][=magit= ---Emacs' porcelain interface to gitq:1]]
;; See here for a short & useful tutorial:
;; https://alvinalexander.com/git/git-show-change-username-email-address
(when (equal ""
(shell-command-to-string "git config user.name"))
  (shell-command "git config --global user.name \"Musa Al-hassy\"")
  (shell-command "git config --global user.email \"alhassy@gmail.com\""))
;; =magit= ---Emacs' porcelain interface to gitq:1 ends here

;; [[file:~/.emacs.d/init.org::*=magit= ---Emacs' porcelain interface to gitq][=magit= ---Emacs' porcelain interface to gitq:2]]
(use-package magit
  :defer t
  :custom ;; Do not ask about this variable when cloning.
          (magit-clone-set-remote.pushDefault t))

(cl-defun maybe-clone (remote &optional (local (concat "~/" (file-name-base remote))))
  "Clone a REMOTE repository if the LOCAL directory does not exist.

Yields ‘repo-already-exists’ when no cloning transpires,
otherwise yields ‘cloned-repo’.

LOCAL is optional and defaults to the base name; e.g.,
if REMOTE is https://github.com/X/Y then LOCAL becomes ~/Y."
  (if (file-directory-p local)
      'repo-already-exists
    (async-shell-command (concat "git clone " remote " " local))
    (add-to-list 'magit-repository-directories `(,local   . 0))
    'cloned-repo))

(maybe-clone "https://github.com/alhassy/emacs.d" "~/.emacs.d")
(maybe-clone "https://github.com/alhassy/alhassy.github.io")
(maybe-clone "https://github.com/alhassy/CheatSheet")
(maybe-clone "https://github.com/alhassy/ElispCheatSheet")
(maybe-clone "https://github.com/alhassy/CatsCheatSheet")
(maybe-clone "https://github.com/alhassy/islam")

;; For brevity, many more ‘maybe-clone’ clauses are hidden in the source file.
;; =magit= ---Emacs' porcelain interface to gitq:2 ends here

;; [[file:~/.emacs.d/init.org::*=magit= ---Emacs' porcelain interface to gitq][=magit= ---Emacs' porcelain interface to gitq:3]]
(maybe-clone "https://github.com/alhassy/OCamlCheatSheet")
(maybe-clone "https://github.com/alhassy/AgdaCheatSheet")
(maybe-clone "https://github.com/alhassy/org-agda-mode")
(maybe-clone "https://github.com/JacquesCarette/TheoriesAndDataStructures")
(maybe-clone "https://github.com/alhassy/RubyCheatSheet")
(maybe-clone "https://github.com/alhassy/melpa")
(maybe-clone "https://github.com/alhassy/PrologCheatSheet")
(maybe-clone "https://github.com/alhassy/FSharpCheatSheet")

(maybe-clone "https://gitlab.cas.mcmaster.ca/armstmp/cs3mi3.git" "~/3mi3")
(maybe-clone "https://github.com/alhassy/MyUnicodeSymbols")
(maybe-clone "https://github.com/alhassy/interactive-way-to-c")
(maybe-clone "https://github.com/alhassy/next-700-module-systems-proposal.git" "~/thesis-proposal")
(maybe-clone "https://github.com/JacquesCarette/MathScheme")
(maybe-clone "https://github.com/alhassy/gentle-intro-to-reflection" "~/reflection/")

;; Private repos

(maybe-clone "https://gitlab.cas.mcmaster.ca/schaapal/metaocaml-kwic.git" "~/alex") ;; metaprogramming, ocaml, phd
(maybe-clone "https://gitlab.cas.mcmaster.ca/MathScheme/TheoryPresentations.git" "~/yasmine") ;; theory presentations, scala, phd
(maybe-clone "https://gitlab.cas.mcmaster.ca/MathScheme/Differentiating-Programs.git" "~/noel") ;; calculus for datatypes, phd

;;
(maybe-clone "https://gitlab.cas.mcmaster.ca/alhassm/CAS781" "~/cas781") ;; cat adventures
;;
;; (maybe-clone "https://gitlab.cas.mcmaster.ca/carette/cs3fp3.git" "~/3fp3")
;; (maybe-clone "https://gitlab.cas.mcmaster.ca/RATH/RATH-Agda"     "~/RATH-Agda")
(maybe-clone "https://gitlab.cas.mcmaster.ca/3ea3-winter2019/assignment-distribution.git" "~/3ea3/assignment-distribution")
(maybe-clone "https://gitlab.cas.mcmaster.ca/3ea3-winter2019/notes.git" "~/3ea3/notes")
(maybe-clone "https://gitlab.cas.mcmaster.ca/3ea3-winter2019/assignment-development.git" "~/3ea3/assignment-development")
(maybe-clone "https://gitlab.cas.mcmaster.ca/3ea3-winter2019/kandeeps.git" "~/3ea3/sujan")
(maybe-clone "https://gitlab.cas.mcmaster.ca/3ea3-winter2019/horsmane.git" "~/3ea3/emily")
(maybe-clone "https://gitlab.cas.mcmaster.ca/3ea3-winter2019/anderj12.git" "~/3ea3/jacob")
;; (maybe-clone "https://gitlab.cas.mcmaster.ca/alhassm/3EA3.git" "~/3ea3/_2018")
;; (maybe-clone "https://gitlab.cas.mcmaster.ca/2DM3/LectureNotes.git" "~/2dm3")

;; Likely want to put a hook when closing emacs, or at some given time,
;; to show me this buffer so that I can ‘push’ if I haven't already!
;
; (magit-list-repositories)
;; =magit= ---Emacs' porcelain interface to gitq:3 ends here

;; [[file:~/.emacs.d/init.org::*=magit= ---Emacs' porcelain interface to gitq][=magit= ---Emacs' porcelain interface to gitq:4]]
(require 'magit-git)

(defun my/magit-check-file-and-popup ()
  "If the file is version controlled with git
  and has uncommitted changes, open the magit status popup."
  (let ((file (buffer-file-name)))
    (when (and file (magit-anything-modified-p t file))
      (message "This file has uncommited changes!")
      (when nil ;; Became annyoying after some time.
      (split-window-below)
      (other-window 1)
      (magit-status)))))

;; I usually have local variables, so I want the message to show
;; after the locals have been loaded.
(add-hook 'find-file-hook
  '(lambda ()
      (add-hook 'hack-local-variables-hook 'my/magit-check-file-and-popup)))
;; =magit= ---Emacs' porcelain interface to gitq:4 ends here

;; [[file:~/.emacs.d/init.org::*=magit= ---Emacs' porcelain interface to gitq][=magit= ---Emacs' porcelain interface to gitq:5]]
(use-package git-timemachine :defer t)
;; =magit= ---Emacs' porcelain interface to gitq:5 ends here

;; [[file:~/.emacs.d/init.org::*Syncing to the System's =$PATH=][Syncing to the System's =$PATH=:1]]
(use-package exec-path-from-shell
  :init
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))
;; Syncing to the System's =$PATH=:1 ends here

;; [[file:~/.emacs.d/init.org::*Installing OS packages, and automatically keeping my system up to data, from within Emacs][Installing OS packages, and automatically keeping my system up to data, from within Emacs:1]]
;; Auto installing OS system packages
(use-package use-package-ensure-system-package
  :defer 5
  :config (system-packages-update))

;; Ensure our operating system is always up to date.
;; This is run whenever we open Emacs & so wont take long if we're up to date.
;; It happens in the background ^_^
;;
;; After 5 seconds of being idle, after starting up.
;; Installing OS packages, and automatically keeping my system up to data, from within Emacs:1 ends here

;; [[file:~/.emacs.d/init.org::*Installing OS packages, and automatically keeping my system up to data, from within Emacs][Installing OS packages, and automatically keeping my system up to data, from within Emacs:3]]
;; An Emacs-based interface to the package manager of your operating system.
(use-package helm-system-packages :defer t)
;; Installing OS packages, and automatically keeping my system up to data, from within Emacs:3 ends here

;; [[file:~/.emacs.d/init.org::*Installing OS packages, and automatically keeping my system up to data, from within Emacs][Installing OS packages, and automatically keeping my system up to data, from within Emacs:4]]
;; Unlike the Helm variant, we need to specify our OS pacman.
(setq system-packages-package-manager 'brew)
;; Installing OS packages, and automatically keeping my system up to data, from within Emacs:4 ends here

;; [[file:~/.emacs.d/init.org::*“Being at the Helm” ---Completion & Narrowing Framework][“Being at the Helm” ---Completion & Narrowing Framework:1]]
(use-package helm
 :diminish
 :init (helm-mode t)
 :bind (("M-x"     . helm-M-x)
        ("C-x C-f" . helm-find-files)
        ("C-x b"   . helm-mini)     ;; See buffers & recent files; more useful.
        ("C-x r b" . helm-filtered-bookmarks)
        ("C-x C-r" . helm-recentf)  ;; Search for recently edited files
        ("C-c i"   . helm-imenu)
        ("C-h a"   . helm-apropos)
        ;; Look at what was cut recently & paste it in.
        ("M-y" . helm-show-kill-ring)

        :map helm-map
        ;; We can list ‘actions’ on the currently selected item by C-z.
        ("C-z" . helm-select-action)
        ;; Let's keep tab-completetion anyhow.
        ("TAB"   . helm-execute-persistent-action)
        ("<tab>" . helm-execute-persistent-action)))
;; “Being at the Helm” ---Completion & Narrowing Framework:1 ends here

;; [[file:~/.emacs.d/init.org::*“Being at the Helm” ---Completion & Narrowing Framework][“Being at the Helm” ---Completion & Narrowing Framework:2]]
(setq helm-mini-default-sources '(helm-source-buffers-list
                                    helm-source-recentf
                                    helm-source-bookmarks
                                    helm-source-bookmark-set
                                    helm-source-buffer-not-found))
;; “Being at the Helm” ---Completion & Narrowing Framework:2 ends here

;; [[file:~/.emacs.d/init.org::*“Being at the Helm” ---Completion & Narrowing Framework][“Being at the Helm” ---Completion & Narrowing Framework:3]]
(system-packages-ensure "surfraw")
; ⇒  “M-x helm-surfraw” or “C-x c s”
;; “Being at the Helm” ---Completion & Narrowing Framework:3 ends here

;; [[file:~/.emacs.d/init.org::*“Being at the Helm” ---Completion & Narrowing Framework][“Being at the Helm” ---Completion & Narrowing Framework:4]]
(use-package helm-swoop
  :bind  (("C-s"     . 'helm-swoop)           ;; search current buffer
          ("C-M-s"   . 'helm-multi-swoop-all) ;; Search all buffer
          ;; Go back to last position where ‘helm-swoop’ was called
          ("C-S-s" . 'helm-swoop-back-to-last-point)
          ;; swoop doesn't work with PDFs, use Emacs' default isearch instead.
          :map pdf-view-mode-map
          ("C-s" . isearch-forward))
  :custom (helm-swoop-speed-or-color nil "Give up colour for speed.")
          (helm-swoop-split-with-multiple-windows nil "Do not split window inside the current window."))
;; “Being at the Helm” ---Completion & Narrowing Framework:4 ends here

;; [[file:~/.emacs.d/init.org::*Having a workspace manager in Emacs][Having a workspace manager in Emacs:1]]
(use-package perspective
  :defer t
  :config ;; Activate it.
          (persp-mode)
          ;; In the modeline, tell me which workspace I'm in.
          (persp-turn-on-modestring))
;; Having a workspace manager in Emacs:1 ends here

;; [[file:~/.emacs.d/init.org::*Excellent PDF Viewer][Excellent PDF Viewer:1]]
(use-package pdf-tools
  :defer t
  ; :init   (system-packages-ensure "pdf-tools")
  :custom (pdf-tools-handle-upgrades nil)
          (pdf-info-epdfinfo-program "/usr/local/bin/epdfinfo")
  :config (pdf-tools-install))

;; Now PDFs opened in Emacs are in pdfview-mode.
;; Excellent PDF Viewer:1 ends here

;; [[file:~/.emacs.d/init.org::*Who am I? ---Using Gnus for Gmail][Who am I? ---Using Gnus for Gmail:1]]
(setq user-full-name    "Musa Al-hassy"
      user-mail-address "alhassy@gmail.com")
;; Who am I? ---Using Gnus for Gmail:1 ends here

;; [[file:~/.emacs.d/init.org::*Who am I? ---Using Gnus for Gmail][Who am I? ---Using Gnus for Gmail:3]]
     (setq message-send-mail-function 'smtpmail-send-it)
;; Who am I? ---Using Gnus for Gmail:3 ends here

;; [[file:~/.emacs.d/init.org::*Who am I? ---Using Gnus for Gmail][Who am I? ---Using Gnus for Gmail:6]]
;; After startup, if Emacs is idle for 10 seconds, then start Gnus.
;; Gnus is slow upon startup since it fetches all mails upon startup.
(run-with-idle-timer 10 nil #'gnus)
;; Who am I? ---Using Gnus for Gmail:6 ends here

;; [[file:~/.emacs.d/init.org::*Prettifications][Prettifications:1]]
;; Fancy icons for Emacs
;; Only do this once:
(use-package all-the-icons :defer t)
  ; :config (all-the-icons-install-fonts 'install-without-asking)

;; Make mail look pretty
(use-package all-the-icons-gnus
  :defer t
  :config (all-the-icons-gnus-setup))

;; While we're at it: Make dired, ‘dir’ectory ‘ed’itor, look pretty
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))
;; Prettifications:1 ends here

;; [[file:~/.emacs.d/init.org::*Prettifications][Prettifications:2]]
(setq gnus-sum-thread-tree-vertical        "│"
      gnus-sum-thread-tree-leaf-with-other "├─► "
      gnus-sum-thread-tree-single-leaf     "╰─► "
      gnus-summary-line-format
      (concat
       "%0{%U%R%z%}"
       "%3{│%}" "%1{%d%}" "%3{│%}"
       "  "
       "%4{%-20,20f%}"
       "  "
       "%3{│%}"
       " "
       "%1{%B%}"
       "%s\n"))
;; Prettifications:2 ends here

;; [[file:~/.emacs.d/init.org::*Super Terse Tutorial][Super Terse Tutorial:2]]
(with-eval-after-load 'gnus
  (bind-key "t"
          (lambda (N) (interactive "P") (gnus-summary-move-article N "[Gmail]/Trash"))
          gnus-summary-mode-map))

;; Orginally: t ⇒ gnus-summary-toggle-header
;; Super Terse Tutorial:2 ends here

;; [[file:~/.emacs.d/init.org::*Capturing Mail as Todo/Notes][Capturing Mail as Todo/Notes:1]]
(with-eval-after-load 'gnus

(bind-key "c" #'my/org-capture-buffer gnus-article-mode-map)
;; Orginally: c ⇒ gnus-summary-catchup-and-exit

(bind-key "C"
          (lambda (&optional keys)
            (interactive "P") (my/org-capture-buffer keys 'no-additional-remarks))
          gnus-article-mode-map))
;; Orginally: C ⇒ gnus-summary-cancel-article
;; Capturing Mail as Todo/Notes:1 ends here

;; [[file:~/.emacs.d/init.org::*Auto-completing mail addresses][Auto-completing mail addresses:1]]
(use-package gmail2bbdb
  :defer t
  :custom (gmail2bbdb-bbdb-file "~/Dropbox/bbdb"))

(use-package bbdb
 :after company ;; The “com”plete “any”thig mode is set below in §Prose
 :hook   (message-mode . bbdb-insinuate-gnus)
         (gnus-startup-hook . bbdb-insinuate-gnus)
 :custom (bbdb-file gmail2bbdb-bbdb-file)
         (bbdb-use-pop-up t)                        ;; allow popups for addresses
 :config (add-to-list 'company-backends 'company-bbdb))
;; Auto-completing mail addresses:1 ends here

;; [[file:~/.emacs.d/init.org::*Jumping to extreme semantic units][Jumping to extreme semantic units:1]]
;; M-< and M-> jump to first and final semantic units.
;; If pressed twice, they go to physical first and last positions.
(use-package beginend
  :diminish
  :config (beginend-global-mode))
;; Jumping to extreme semantic units:1 ends here

;; [[file:~/.emacs.d/init.org::*Hydra: Supply a prefix only once][Hydra: Supply a prefix only once:1]]
;; Invoke all possible key extensions having a common prefix by
;; supplying the prefix only once.
;; The standard syntax:
;; (defhydra hydra-example (global-map "C-c v") ;; Prefix
;;   ;; List of triples (extension method description) )
;; Hydra: Supply a prefix only once:1 ends here

;; [[file:~/.emacs.d/init.org::*Hydra: Supply a prefix only once][Hydra: Supply a prefix only once:2]]
;; Use ijkl to denote ↑←↓→ arrows.


;; Provides a *visual* way to choose a window to switch to.
(use-package switch-window :defer t)
;; :bind (("C-x o" . switch-window)
;;        ("C-x w" . switch-window-then-swap-buffer))

;; Have a thick ruler between vertical windows
(window-divider-mode)
;; Hydra: Supply a prefix only once:2 ends here

;; [[file:~/.emacs.d/init.org::*Quickly pop-up a terminal, run a command, close it ---and zsh][Quickly pop-up a terminal, run a command, close it ---and zsh:1]]
(use-package shell-pop
  :defer t
  :custom
    ;; This binding toggles popping up a shell, or moving cursour to the shell pop-up.
    (shell-pop-universal-key "C-t")

    ;; Percentage for shell-buffer window size.
    (shell-pop-window-size 30)

    ;; Position of the popped buffer: top, bottom, left, right, full.
    (shell-pop-window-position "bottom")

    ;; Please use an awesome shell.
    (shell-pop-term-shell "/bin/zsh"))
;; Quickly pop-up a terminal, run a command, close it ---and zsh:1 ends here

;; [[file:~/.emacs.d/init.org::*Quickly pop-up a terminal, run a command, close it ---and zsh][Quickly pop-up a terminal, run a command, close it ---and zsh:2]]
;; Be default, Emacs please use zsh
;; E.g., M-x shell
(setq shell-file-name "/bin/zsh")
;; Quickly pop-up a terminal, run a command, close it ---and zsh:2 ends here

;; [[file:~/.emacs.d/init.org::*Restarting Emacs ---Keeping buffers open across sessions?][Restarting Emacs ---Keeping buffers open across sessions?:1]]
;; Provides only the command “restart-emacs”.
(use-package restart-emacs
  :defer t
  ;; Let's define an alias so there's no need to remember the order.
  :config (defalias 'emacs-restart #'restart-emacs))
;; Restarting Emacs ---Keeping buffers open across sessions?:1 ends here

;; [[file:~/.emacs.d/init.org::*Restarting Emacs ---Keeping buffers open across sessions?][Restarting Emacs ---Keeping buffers open across sessions?:2]]
(setq-default save-place  t)
(setq save-place-file "~/.emacs.d/etc/saveplace")
;; Restarting Emacs ---Keeping buffers open across sessions?:2 ends here

;; [[file:~/.emacs.d/init.org::*Automatic Backups][Automatic Backups:1]]
;; New location for backups.
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; Silently delete execess backup versions
(setq delete-old-versions t)

;; Only keep the last 1000 backups of a file.
(setq kept-old-versions 1000)

;; Even version controlled files get to be backed up.
(setq vc-make-backup-files t)

;; Use version numbers for backup files.
(setq version-control t)
;; Automatic Backups:1 ends here

;; [[file:~/.emacs.d/init.org::*Automatic Backups][Automatic Backups:2]]
(use-package backup-walker
  :commands backup-walker-start)
;; Automatic Backups:2 ends here

;; [[file:~/.emacs.d/init.org::*Automatic Backups][Automatic Backups:3]]
;; Make Emacs backup everytime I save

(defun my/force-backup-of-buffer ()
  "Lie to Emacs, telling it the curent buffer has yet to be backed up."
  (setq buffer-backed-up nil))

(add-hook 'before-save-hook  'my/force-backup-of-buffer)
;; Automatic Backups:3 ends here

;; [[file:~/.emacs.d/init.org::*Screencapturing the Current Emacs Frame][Screencapturing the Current Emacs Frame:1]]
(defun my/capture-emacs-frame (&optional prefix output)
"Insert a link to a screenshot of the current Emacs frame.

Unless the name of the OUTPUT file is provided, read it from the
user. If PREFIX is provided, let the user select a portion of the screen."
(interactive "p")
(defvar my/emacs-window-id
   (s-collapse-whitespace (shell-command-to-string "osascript -e 'tell app \"Emacs\" to id of window 1'"))
   "The window ID of the current Emacs frame.

    Takes a second to compute, whence a defvar.")

(let* ((screen  (if prefix "-i" (concat "-l" my/emacs-window-id)))
       (temp    (format "emacs_temp_%s.png" (random)))
       (default (format-time-string "emacs-%m-%d-%Y-%H:%M:%S.png")))
;; Get output file name
  (unless output
    (setq output (read-string (format "Emacs screenshot filename (%s): " default)))
    (when (s-blank-p output) (setq output default)))
;; Clear minibuffer before capturing screen or prompt user
(message (if prefix "Please select region for capture …" "♥‿♥"))
;; Capture current screen and resize
(thread-first
    (format "screencapture -T 2 %s %s" screen temp)
    (concat "; magick convert -resize 60% " temp " " output)
    (shell-command))
(f-delete temp)
;; Insert a link to the image and reload inline images.
(insert (concat "[[file:" output "]]")))
(org-display-inline-images nil t))

(bind-key* "C-c M-s" #'my/capture-emacs-frame)
;; Screencapturing the Current Emacs Frame:1 ends here

;; [[file:~/.emacs.d/init.org::*Editor Documentation with Contextual Information][Editor Documentation with Contextual Information:1]]
(use-package helpful :defer t)

(defun my/describe-symbol (symbol)
  "A “C-h o” replacement using “helpful”:
   If there's a thing at point, offer that as default search item.

   If a prefix is provided, i.e., “C-u C-h o” then the built-in
   “describe-symbol” command is used.

   ⇨ Pretty docstrings, with links and highlighting.
   ⇨ Source code of symbol.
   ⇨ Callers of function symbol.
   ⇨ Key bindings for function symbol.
   ⇨ Aliases.
   ⇨ Options to enable tracing, dissable, and forget/unbind the symbol!
  "
  (interactive "p")
  (let* ((thing (symbol-at-point))
         (val (completing-read
               (format "Describe symbol (default %s): " thing)
               (vconcat (list thing) obarray)
               (lambda (vv)
                 (cl-some (lambda (x) (funcall (nth 1 x) vv))
                          describe-symbol-backends))
               t nil nil))
         (it (intern val)))
    (cond
     (current-prefix-arg (funcall #'describe-symbol it))
     ((or (functionp it) (macrop it) (commandp it)) (helpful-callable it))
     (t (helpful-symbol it)))))

;; Keybindings.
(global-set-key (kbd "C-h o") #'my/describe-symbol)
(global-set-key (kbd "C-h k") #'helpful-key)
;; Editor Documentation with Contextual Information:1 ends here

;; [[file:~/.emacs.d/init.org::*Startup message: Emacs & Org versions][Startup message: Emacs & Org versions:1]]
;; Silence the usual message: Get more info using the about page via C-h C-a.
(setq inhibit-startup-message t)

(defun display-startup-echo-area-message ()
  "The message that is shown after ‘user-init-file’ is loaded."
  (message
      (concat "Welcome "      user-full-name
              "! Emacs "      emacs-version
              "; Org-mode "   org-version
              "; System "     (system-name)
              "; Time "       (emacs-init-time))))
;; Startup message: Emacs & Org versions:1 ends here

;; [[file:~/.emacs.d/init.org::*Startup message: Emacs & Org versions][Startup message: Emacs & Org versions:2]]
;; Welcome Musa Al-hassy! Emacs 26.1; Org-mode 9.3; System alhassy-air.local
;; Startup message: Emacs & Org versions:2 ends here

;; [[file:~/.emacs.d/init.org::*Startup message: Emacs & Org versions][Startup message: Emacs & Org versions:4]]
;; Keep self motivated!
(setq frame-title-format '("" "%b - Living The Dream (•̀ᴗ•́)و"))
;; Startup message: Emacs & Org versions:4 ends here

;; [[file:~/.emacs.d/init.org::*My to-do list: The initial buffer when Emacs opens up][My to-do list: The initial buffer when Emacs opens up:1]]
(find-file "~/Dropbox/todo.org")
(split-window-right)			  ;; C-x 3
(other-window 1)                              ;; C-x 0
(let ((enable-local-variables :all)           ;; Load *all* locals.
      (org-confirm-babel-evaluate nil))       ;; Eval *all* blocks.
  (find-file "~/.emacs.d/init.org"))
;; My to-do list: The initial buffer when Emacs opens up:1 ends here

;; [[file:~/.emacs.d/init.org::*Exquisite Themes][Exquisite Themes:1]]
;; Treat all themes as safe; no query before use.
(setf custom-safe-themes t)

;; Nice looking themes ^_^
(use-package solarized-theme :defer t)
(use-package doom-themes :defer t)
(use-package spacemacs-common
  :defer t
  :ensure spacemacs-theme)
;; Exquisite Themes:1 ends here

;; [[file:~/.emacs.d/init.org::*Exquisite Themes][Exquisite Themes:2]]
;; Infinite list of my commonly used themes.
(setq my/themes '(doom-solarized-light doom-vibrant spacemacs-light))
(setcdr (last my/themes) my/themes)
;; Exquisite Themes:2 ends here

;; [[file:~/.emacs.d/init.org::*Exquisite Themes][Exquisite Themes:3]]
(cl-defun my/disable-all-themes (&key (new-theme (pop my/themes)))
  "Disable all themes and load NEW-THEME, which defaults from ‘my/themes’."
  (interactive)
  (dolist (τ custom-enabled-themes)
    (disable-theme τ))
  (when new-theme (load-theme new-theme)))

(defalias 'my/toggle-theme #' my/disable-all-themes)
(global-set-key "\C-x\ t" 'my/toggle-theme)
(my/toggle-theme)
;; Exquisite Themes:3 ends here

;; [[file:~/.emacs.d/init.org::*A sleek & informative mode line][A sleek & informative mode line:1]]
(setq display-time-day-and-date t)
(display-time)
;; (display-battery-mode -1)
;; Nope; let's use a fancy indicator …
(use-package fancy-battery
  :diminish
  :custom (fancy-battery-show-percentage  t)
          (battery-update-interval       15)
  :config (fancy-battery-mode))
;; A sleek & informative mode line:1 ends here

;; [[file:~/.emacs.d/init.org::*A sleek & informative mode line][A sleek & informative mode line:2]]
;; Following two taken care of in the spaceline package, below.
;; (column-number-mode                 t)
;; (line-number-mode                   t)
(setq display-line-numbers-width-start t)
(global-display-line-numbers-mode      t)
;; A sleek & informative mode line:2 ends here

;; [[file:~/.emacs.d/init.org::*A sleek & informative mode line][A sleek & informative mode line:3]]
;; When using helm & info & default, mode line looks prettier.
(use-package spaceline
  :custom (spaceline-buffer-encoding-abbrev-p nil)
          ;; Use an arrow to seperate modeline information
          (powerline-default-separator 'arrow)
          ;; Show “line-number : column-number” in modeline.
          (spaceline-line-column-p t)
          ;; Use two colours to indicate whether a buffer is modified or not.
          (spaceline-highlight-face-func 'spaceline-highlight-face-modified)
  :config (custom-set-faces '(spaceline-unmodified ((t (:foreground "black" :background "gold")))))
          (custom-set-faces '(spaceline-modified   ((t (:foreground "black" :background "cyan")))))
          (require 'spaceline-config)
          (spaceline-helm-mode)
          (spaceline-info-mode)
          (spaceline-emacs-theme))
;; A sleek & informative mode line:3 ends here

;; [[file:~/.emacs.d/init.org::*Powerful Directory Editing with ~dired~][Powerful Directory Editing with ~dired~:1]]
(use-package dired-subtree
  :bind (:map dired-mode-map
              ("i" . dired-subtree-toggle)))
;; Powerful Directory Editing with ~dired~:1 ends here

;; [[file:~/.emacs.d/init.org::*Powerful Directory Editing with ~dired~][Powerful Directory Editing with ~dired~:2]]
(use-package dired-collapse
  :hook (dired-mode . dired-collapse-mode))
;; Powerful Directory Editing with ~dired~:2 ends here

;; [[file:~/.emacs.d/init.org::*Powerful Directory Editing with ~dired~][Powerful Directory Editing with ~dired~:3]]
(use-package dired-filter
  :hook (dired-mode . (lambda () (dired-filter-group-mode)
                                 (dired-filter-by-garbage)))
  :custom
    (dired-garbage-files-regexp
      "\\(?:\\.\\(?:aux\\|bak\\|dvi\\|log\\|orig\\|rej\\|toc\\|out\\)\\)\\'")
    (dired-filter-group-saved-groups
      '(("default"
         ("Org"    (extension "org"))
         ("Executables" (exexutable))
         ("Directories" (directory))
         ("PDF"    (extension "pdf"))
         ("LaTeX"  (extension "tex" "bib"))
         ("Images" (extension "png"))
         ("Code"   (extension "hs" "agda" "lagda"))
         ("Archives"(extension "zip" "rar" "gz" "bz2" "tar"))))))
;; Powerful Directory Editing with ~dired~:3 ends here

;; [[file:~/.emacs.d/init.org::*Never lose the cursor][Never lose the cursor:1]]
;; Make it very easy to see the line with the cursor.
(global-hl-line-mode t)
;; Never lose the cursor:1 ends here

;; [[file:~/.emacs.d/init.org::*Never lose the cursor][Never lose the cursor:2]]
(use-package beacon
  :diminish
  :config (setq beacon-color "#666600")
  :hook   ((org-mode text-mode) . beacon-mode))
;; Never lose the cursor:2 ends here

;; [[file:~/.emacs.d/init.org::*Dimming Unused Windows][Dimming Unused Windows:1]]
(use-package dimmer
  :config (dimmer-mode))
;; Dimming Unused Windows:1 ends here

;; [[file:~/.emacs.d/init.org::*Buffer names are necessarily injective][Buffer names are necessarily injective:1]]
;; Note that ‘uniquify’ is builtin.
(require 'uniquify)
(setq uniquify-separator "/"               ;; The separator in buffer names.
      uniquify-buffer-name-style 'forward) ;; names/in/this/style
;; Buffer names are necessarily injective:1 ends here

;; [[file:~/.emacs.d/init.org::*Flashing when something goes wrong ---no blinking][Flashing when something goes wrong ---no blinking:1]]
(setq visible-bell 1)
;; Flashing when something goes wrong ---no blinking:1 ends here

;; [[file:~/.emacs.d/init.org::*Flashing when something goes wrong ---no blinking][Flashing when something goes wrong ---no blinking:2]]
(blink-cursor-mode 1)
;; Flashing when something goes wrong ---no blinking:2 ends here

;; [[file:~/.emacs.d/init.org::*Hiding Scrollbar, tool bar, and menu][Hiding Scrollbar, tool bar, and menu:1]]
(tool-bar-mode   -1)  ;; No large icons please
(scroll-bar-mode -1)  ;; No visual indicator please
(menu-bar-mode   -1)  ;; The Mac OS top pane has menu options
;; Hiding Scrollbar, tool bar, and menu:1 ends here

;; [[file:~/.emacs.d/init.org::*Highlight & complete parenthesis pair when cursor is near ;-)][Highlight & complete parenthesis pair when cursor is near ;-):1]]
(setq show-paren-delay  0)
(setq show-paren-style 'mixed)
(show-paren-mode)
;; Highlight & complete parenthesis pair when cursor is near ;-):1 ends here

;; [[file:~/.emacs.d/init.org::*Highlight & complete parenthesis pair when cursor is near ;-)][Highlight & complete parenthesis pair when cursor is near ;-):2]]
(use-package rainbow-delimiters
  :disabled
  :hook ((org-mode prog-mode text-mode) . rainbow-delimiters-mode))
;; Highlight & complete parenthesis pair when cursor is near ;-):2 ends here

;; [[file:~/.emacs.d/init.org::*Highlight & complete parenthesis pair when cursor is near ;-)][Highlight & complete parenthesis pair when cursor is near ;-):4]]
(electric-pair-mode 1)
;; Highlight & complete parenthesis pair when cursor is near ;-):4 ends here

;; [[file:~/.emacs.d/init.org::*Highlight & complete parenthesis pair when cursor is near ;-)][Highlight & complete parenthesis pair when cursor is near ;-):5]]
;; The ‘<’ and ‘>’ are not ‘parenthesis’, so give them no compleition.
(setq electric-pair-inhibit-predicate
      (lambda (c)
        (or (member c '(?< ?> ?~)) (electric-pair-default-inhibit c))))

;; Treat ‘<’ and ‘>’ as if they were words, instead of ‘parenthesis’.
(modify-syntax-entry ?< "w<")
(modify-syntax-entry ?> "w>")
;; Highlight & complete parenthesis pair when cursor is near ;-):5 ends here

;; [[file:~/.emacs.d/init.org::*Persistent Scratch Buffer][Persistent Scratch Buffer:1]]
(use-package persistent-scratch
  :defer t
  ;; In this mode, the usual save key saves to the underlying persistent file.
  :bind (:map persistent-scratch-mode-map
              ("C-x C-s" . persistent-scratch-save)))
;; Persistent Scratch Buffer:1 ends here

;; [[file:~/.emacs.d/init.org::*Persistent Scratch Buffer][Persistent Scratch Buffer:2]]
(defun scratch ()
   "Recreate the scratch buffer, loading any persistent state."
   (interactive)
   (switch-to-buffer-other-window (get-buffer-create "*scratch*"))
   (condition-case nil (persistent-scratch-restore) (insert initial-scratch-message))
   (org-mode)
   (persistent-scratch-mode)
   (persistent-scratch-autosave-mode 1))

;; This doubles as a quick way to avoid the common formula: C-x b RET *scratch*

;; Upon startup, close the default scratch buffer and open one as specfied above
(ignore-errors (kill-buffer "*scratch*") (scratch))
;; Persistent Scratch Buffer:2 ends here

;; [[file:~/.emacs.d/init.org::*Persistent Scratch Buffer][Persistent Scratch Buffer:3]]
(setq initial-scratch-message (concat
  "#+Title: Persistent Scratch Buffer"
  "\n#\n# Welcome! This’ a place for trying things out."
  "\n#\n# ⟨ ‘C-x C-s’ here saves to ~/.emacs.d/.persistent-scratch ⟩ \n\n"))
;; Persistent Scratch Buffer:3 ends here

;; [[file:~/.emacs.d/init.org::*Prose][Prose:1]]
(add-hook 'before-save-hook 'whitespace-cleanup)
;; Prose:1 ends here

;; [[file:~/.emacs.d/init.org::*Fill-mode ---Word Wrapping][Fill-mode ---Word Wrapping:1]]
(setq-default fill-column 80          ;; Let's avoid going over 80 columns
              truncate-lines nil      ;; I never want to scroll horizontally
              indent-tabs-mode nil)   ;; Use spaces instead of tabs
;; Fill-mode ---Word Wrapping:1 ends here

;; [[file:~/.emacs.d/init.org::*Fill-mode ---Word Wrapping][Fill-mode ---Word Wrapping:2]]
;; Wrap long lines when editing text
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'org-mode-hook 'turn-on-auto-fill)

;; Do not show the “Fill” indicator in the mode line.
(diminish 'auto-fill-function)
;; Fill-mode ---Word Wrapping:2 ends here

;; [[file:~/.emacs.d/init.org::*Fill-mode ---Word Wrapping][Fill-mode ---Word Wrapping:3]]
;; Bent arrows at the end and start of long lines.
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
(global-visual-line-mode 1)
;; Fill-mode ---Word Wrapping:3 ends here

;; [[file:~/.emacs.d/init.org::*Pretty Lists Markers][Pretty Lists Markers:1]]
;; (x y z) ≈ (existing-item replacement-item positivity-of-preceding-spaces)
(require 'cl)
(loop for (x y z) in '(("+" "◦" *)
                       ("-" "•" *)
                       ("*" "⋆" +))
      do (font-lock-add-keywords 'org-mode
                                 `((,(format "^ %s\\([%s]\\) " z x)
                                    (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) ,y)))))))
;; Pretty Lists Markers:1 ends here

;; [[file:~/.emacs.d/init.org::*Word Completion][Word Completion:1]]
(use-package company
  :diminish
  :config
  (global-company-mode 1)
  (setq ;; Only 2 letters required for completion to activate.
   company-minimum-prefix-length 2

   ;; Search other buffers for compleition candidates
   company-dabbrev-other-buffers t
   company-dabbrev-code-other-buffers t

   ;; Show candidates according to importance, then case, then in-buffer frequency
   company-transformers '(company-sort-by-backend-importance
                          company-sort-prefer-same-case-prefix
                          company-sort-by-occurrence)

   ;; Flushright any annotations for a compleition;
   ;; e.g., the description of what a snippet template word expands into.
   company-tooltip-align-annotations t

   ;; Allow (lengthy) numbers to be eligible for completion.
   company-complete-number t

   ;; M-⟪num⟫ to select an option according to its number.
   company-show-numbers t

   ;; Show 10 items in a tooltip; scrollbar otherwise or C-s ^_^
   company-tooltip-limit 10

   ;; Edge of the completion list cycles around.
   company-selection-wrap-around t

   ;; Do not downcase completions by default.
   company-dabbrev-downcase nil

   ;; Even if I write something with the ‘wrong’ case,
   ;; provide the ‘correct’ casing.
   company-dabbrev-ignore-case nil

   ;; Immediately activate completion.
   company-idle-delay 0)

  ;; Use C-/ to manually start company mode at point. C-/ is used by undo-tree.
  ;; Override all minor modes that use C-/; bind-key* is discussed below.
  (bind-key* "C-/" #'company-manual-begin)

  ;; Bindings when the company list is active.
  :bind (:map company-active-map
              ("C-d" . company-show-doc-buffer) ;; In new temp buffer
              ("<tab>" . company-complete-selection)
              ;; Use C-n,p for navigation in addition to M-n,p
              ("C-n" . (lambda () (interactive) (company-complete-common-or-cycle 1)))
              ("C-p" . (lambda () (interactive) (company-complete-common-or-cycle -1)))))

;; It's so fast that we don't need a key-binding to start it!
;; Word Completion:1 ends here

;; [[file:~/.emacs.d/init.org::*Word Completion][Word Completion:2]]
(use-package company-emoji
  :config (add-to-list 'company-backends 'company-emoji))
;; Word Completion:2 ends here

;; [[file:~/.emacs.d/init.org::*Word Completion][Word Completion:3]]
(use-package emojify
 :config (setq emojify-display-style 'image)
 :init (global-emojify-mode 1)) ;; Will install missing images, if need be.
;; Word Completion:3 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:1]]
(use-package flyspell
  :diminish
  :hook ((prog-mode . flyspell-prog-mode)
         ((org-mode text-mode) . flyspell-mode)))
;; Fix spelling as you type ---thesaurus & dictionary too!:1 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:2]]
(setq ispell-program-name "/usr/local/bin/aspell")
(setq ispell-dictionary "en_GB") ;; set the default dictionary
;; Fix spelling as you type ---thesaurus & dictionary too!:2 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:4]]
(eval-after-load "flyspell"
  ' (progn
     (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
     (define-key flyspell-mouse-map [mouse-3] #'undefined)))
;; Fix spelling as you type ---thesaurus & dictionary too!:4 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:5]]
(global-font-lock-mode t)
(custom-set-faces '(flyspell-incorrect ((t (:inverse-video t)))))
;; Fix spelling as you type ---thesaurus & dictionary too!:5 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:6]]
(setq ispell-silently-savep t)
;; Fix spelling as you type ---thesaurus & dictionary too!:6 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:7]]
(setq ispell-personal-dictionary "~/.emacs.d/.aspell.en.pws")
;; Fix spelling as you type ---thesaurus & dictionary too!:7 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:8]]
(add-hook          'c-mode-hook 'flyspell-prog-mode)
(add-hook 'emacs-lisp-mode-hook 'flyspell-prog-mode)
;; Fix spelling as you type ---thesaurus & dictionary too!:8 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:9]]
(use-package synosaurus
  :diminish synosaurus-mode
  :init    (synosaurus-mode)
  :config  (setq synosaurus-choose-method 'popup) ;; 'ido is default.
           (global-set-key (kbd "M-#") 'synosaurus-choose-and-replace))
;; Fix spelling as you type ---thesaurus & dictionary too!:9 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:10]]
;; (shell-command "brew cask install xquartz &") ;; Dependency
;; (shell-command "brew install wordnet &")
;; Fix spelling as you type ---thesaurus & dictionary too!:10 ends here

;; [[file:~/.emacs.d/init.org::*Fix spelling as you type ---thesaurus & dictionary too!][Fix spelling as you type ---thesaurus & dictionary too!:11]]
(use-package wordnut
 :bind ("M-!" . wordnut-lookup-current-word))

;; Use M-& for async shell commands.
;; Fix spelling as you type ---thesaurus & dictionary too!:11 ends here

;; [[file:~/.emacs.d/init.org::*Touch Typing][Touch Typing:2]]
(use-package speed-type :defer t)
;; Touch Typing:2 ends here

;; [[file:~/.emacs.d/init.org::*Touch Typing][Touch Typing:3]]
(use-package google-translate
 :defer t
 :config
   (global-set-key "\C-ct" 'google-translate-at-point))
;; Touch Typing:3 ends here

;; [[file:~/.emacs.d/init.org::*Using a Grammar & Style Checker][Using a Grammar & Style Checker:1]]
(use-package langtool
 :defer t
 :custom
  (langtool-language-tool-jar
   "~/Applications/LanguageTool-4.5/languagetool-commandline.jar"))
;; Using a Grammar & Style Checker:1 ends here

;; [[file:~/.emacs.d/init.org::*Using a Grammar & Style Checker][Using a Grammar & Style Checker:2]]
;; Quickly check, correct, then clean up /region/ with M-^
(eval-after-load 'langtool
(progn
(add-hook 'langtool-error-exists-hook
  (lambda ()
     (langtool-correct-buffer)
     (langtool-check-done)))

(global-set-key "\M-^"
                (lambda ()
                  (interactive)
                  (message "Grammar checking begun ...")
                  (langtool-check)))))
;; Using a Grammar & Style Checker:2 ends here

;; [[file:~/.emacs.d/init.org::*Lightweight Prose Proofchecking][Lightweight Prose Proofchecking:1]]
(use-package writegood-mode
  ;; Load this whenver I'm composing prose.
  :hook (text-mode org-mode)
  ;; Don't show me the “Wg” marker in the mode line
  :diminish
  ;; Some additional weasel words.
  :config
  (--map (push it writegood-weasel-words)
         '("some" "simple" "simply" "easy" "often" "easily" "probably"
           "clearly"               ;; Is the premise undeniably true?
           "experience shows"      ;; Whose? What kind? How does it do so?
           "may have"              ;; It may also have not!
           "it turns out that")))  ;; How does it turn out so?
           ;; ↯ What is the evidence of highighted phrase? ↯
;; Lightweight Prose Proofchecking:1 ends here

;; [[file:~/.emacs.d/init.org::*Placeholder Text ---For Learning & Experimenting][Placeholder Text ---For Learning & Experimenting:1]]
(use-package lorem-ipsum :defer t)
;; Placeholder Text ---For Learning & Experimenting:1 ends here

;; [[file:~/.emacs.d/init.org::*Some text to make us smile][Some text to make us smile:1]]
(use-package dad-joke
  :defer t
  :config (defun dad-joke () (interactive) (insert (dad-joke-get))))
;; Some text to make us smile:1 ends here

;; [[file:~/.emacs.d/init.org::*Unicode Input via Agda Input][Unicode Input via Agda Input:1]]
; (load (shell-command-to-string "agda-mode locate"))
;;
;; Seeing: One way to avoid seeing this warning is to make sure that agda2-include-dirs is not bound.
; (makunbound 'agda2-include-dirs)
;; Unicode Input via Agda Input:1 ends here

;; [[file:~/.emacs.d/init.org::*Unicode Input via Agda Input][Unicode Input via Agda Input:2]]
(load-file (let ((coding-system-for-read 'utf-8))
                (shell-command-to-string "/usr/local/bin/agda-mode locate")))
;; Unicode Input via Agda Input:2 ends here

;; [[file:~/.emacs.d/init.org::*Unicode Input via Agda Input][Unicode Input via Agda Input:3]]
(use-package agda-input
  :ensure nil ;; I have it locally.
  :demand t
  :hook ((text-mode prog-mode) . (lambda () (set-input-method "Agda")))
  :custom (default-input-method "Agda"))
  ;; Now C-\ or M-x toggle-input-method turn it on and offers
;; Unicode Input via Agda Input:3 ends here

;; [[file:~/.emacs.d/init.org::*Unicode Input via Agda Input][Unicode Input via Agda Input:4]]
;;(setq agda2-program-args (quote ("RTS" "-M4G" "-H4G" "-A128M" "-RTS")))
;; Unicode Input via Agda Input:4 ends here

;; [[file:~/.emacs.d/init.org::*Unicode Input via Agda Input][Unicode Input via Agda Input:5]]
(add-to-list 'agda-input-user-translations '("set" "𝒮ℯ𝓉"))
;; Unicode Input via Agda Input:5 ends here

;; [[file:~/.emacs.d/init.org::*Unicode Input via Agda Input][Unicode Input via Agda Input:6]]
(loop for item
      in '(;; categorial ;;
           ("alg" "𝒜𝓁ℊ")
           ("split" "▵")
           ("join" "▿")
           ("adj" "⊣")
           (";;" "﹔")
           (";;" "⨾")
           (";;" "∘")
           ;; lattices ;;
           ("meet" "⊓")
           ("join" "⊔")
           ;; residuals
           ("syq"  "╳")
           ("over" "╱")
           ("under" "╲")
           ;; Z-quantification range notation ;;
           ;; e.g., “∀ x ❙ R • P” ;;
           ("|"    "❙")
           ("with" "❙")
           ;; adjunction isomorphism pair ;;
           ("floor"  "⌊⌋")
           ("lower"  "⌊⌋")
           ("lad"    "⌊⌋")
           ("ceil"   "⌈⌉")
           ("raise"  "⌈⌉")
           ("rad"    "⌈⌉")
           ;; Arrows
           ("<=" "⇐")
        ;; more (key value) pairs here
        )
      do (add-to-list 'agda-input-user-translations item))
;; Unicode Input via Agda Input:6 ends here

;; [[file:~/.emacs.d/init.org::*Unicode Input via Agda Input][Unicode Input via Agda Input:7]]
;; Add to the list of translations using “emot” and the given, more specfic, name.
;; Whence, \emot shows all possible emotions.
(loop for emot
      in `(;; angry, cry, why-you-no
           ("whyme" "ლ(ಠ益ಠ)ლ" "ヽ༼ಢ_ಢ༽ﾉ☂" "щ(゜ロ゜щ)")
           ;; confused, disapprove, dead, shrug
           ("what" "「(°ヘ°)" "(ಠ_ಠ)" "(✖╭╮✖)" "¯\\_(ツ)_/¯")
           ;; dance, csi
           ("cool" "┏(-_-)┓┏(-_-)┛┗(-_-﻿ )┓"
            ,(s-collapse-whitespace "•_•)
                                      ( •_•)>⌐■-■
                                      (⌐■_■)"))
           ;; love, pleased, success, yesss
           ("smile" "♥‿♥" "(─‿‿─)" "(•̀ᴗ•́)و" "(งಠ_ಠ)ง"))
      do
      (add-to-list 'agda-input-user-translations emot)
      (add-to-list 'agda-input-user-translations (cons "emot" (cdr emot))))
;; Unicode Input via Agda Input:7 ends here

;; [[file:~/.emacs.d/init.org::*Unicode Input via Agda Input][Unicode Input via Agda Input:8]]
;; activate translations
(agda-input-setup)
;; Unicode Input via Agda Input:8 ends here

;; [[file:~/.emacs.d/init.org::*Increase/decrease text size][Increase/decrease text size:1]]
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
;; C-x C-0 restores the default font size
;; Increase/decrease text size:1 ends here

;; [[file:~/.emacs.d/init.org::*Moving Text Around][Moving Text Around:1]]
;; M-↑,↓ moves line, or marked region; prefix is how many lines.
(use-package move-text
  :config (move-text-default-bindings))
;; Moving Text Around:1 ends here

;; [[file:~/.emacs.d/init.org::*Enabling CamelCase Aware Editing Operations][Enabling CamelCase Aware Editing Operations:1]]
(global-subword-mode 1)
(diminish  'subword-mode)
;; Enabling CamelCase Aware Editing Operations:1 ends here

;; [[file:~/.emacs.d/init.org::*Mouse Editing Support][Mouse Editing Support:1]]
(setq mouse-drag-copy-region t)
;; Mouse Editing Support:1 ends here

;; [[file:~/.emacs.d/init.org::*Delete Selection Mode][Delete Selection Mode:1]]
(delete-selection-mode 1)
;; Delete Selection Mode:1 ends here

;; [[file:~/.emacs.d/init.org::*~M-n,p~: Word-at-Point Navigation][~M-n,p~: Word-at-Point Navigation:1]]
(use-package smartscan
  :defer t
  :config
    (global-set-key (kbd "M-n") 'smartscan-symbol-go-forward)
    (global-set-key (kbd "M-p") 'smartscan-symbol-go-backward)
    (global-set-key (kbd "M-'") 'my/symbol-replace))
;; ~M-n,p~: Word-at-Point Navigation:1 ends here

;; [[file:~/.emacs.d/init.org::*~M-n,p~: Word-at-Point Navigation][~M-n,p~: Word-at-Point Navigation:2]]
(defun my/symbol-replace (replacement)
  "Replace all standalone symbols in the buffer matching the one at point."
  (interactive  (list (read-from-minibuffer "Replacement for thing at point: " nil)))
  (save-excursion
    (let ((symbol (or (thing-at-point 'symbol) (error "No symbol at point!"))))
      (beginning-of-buffer)
      ;; (query-replace-regexp symbol replacement)
      (replace-regexp (format "\\b%s\\b" (regexp-quote symbol)) replacement))))
;; ~M-n,p~: Word-at-Point Navigation:2 ends here

;; [[file:~/.emacs.d/init.org::*~M-n,p~: Word-at-Point Navigation][~M-n,p~: Word-at-Point Navigation:3]]
;; C-n, next line, inserts newlines when at the end of the buffer
(setq next-line-add-newlines t)
;; ~M-n,p~: Word-at-Point Navigation:3 ends here

;; [[file:~/.emacs.d/init.org::*Letter-based Navigation][Letter-based Navigation:1]]
(use-package ace-jump-mode
  :defer t
  :config (bind-key* "C-c SPC" 'ace-jump-mode))

;; See ace-jump issues to configure for use of home row keys.
;; Letter-based Navigation:1 ends here

;; [[file:~/.emacs.d/init.org::*~C-c e n,p~: Taking a tour of one's edits][~C-c e n,p~: Taking a tour of one's edits:1]]
;; Give me a description of the change made at a particular stop.
(use-package goto-chg
  :defer t
  :custom (glc-default-span 0))


;; [[file:~/.emacs.d/init.org::*Getting Started][Getting Started:1]]
(use-package org
  :ensure org-plus-contrib
  :config
  (require 'ox-extra)
  (ox-extras-activate '(ignore-headlines)))
;; Getting Started:1 ends here

;; [[file:~/.emacs.d/init.org::*Getting Started][Getting Started:2]]
;; Replace the content marker, “⋯”, with a nice unicode arrow.
(setq org-ellipsis " ⤵")

;; Fold all source blocks on startup.
(setq org-hide-block-startup t)

;; Lists may be labelled with letters.
(setq org-list-allow-alphabetical t)

;; Avoid accidentally editing folded regions, say by adding text after an Org “⋯”.
(setq org-catch-invisible-edits 'show)

;; I use indentation-sensitive programming languages.
;; Tangling should preserve my indentation.
(setq org-src-preserve-indentation t)

;; Tab should do indent in code blocks
(setq org-src-tab-acts-natively t)

;; Give quote and verse blocks a nice look.
(setq org-fontify-quote-and-verse-blocks t)

;; Pressing ENTER on a link should follow it.
(setq org-return-follows-link t)
;; Getting Started:2 ends here

;; [[file:~/.emacs.d/init.org::*Getting Started][Getting Started:3]]
(setq initial-major-mode 'org-mode)
;; Getting Started:3 ends here

;; [[file:~/.emacs.d/init.org::*Executing code from ~src~ blocks][Executing code from ~src~ blocks:1]]
;; Seamless use of babel: No confirmation upon execution.
;; Downside: Could accidentally evaluate harmful code.
(setq org-confirm-babel-evaluate nil)
;; Executing code from ~src~ blocks:1 ends here

;; [[file:~/.emacs.d/init.org::*Executing code from ~src~ blocks][Executing code from ~src~ blocks:2]]
 (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell      . t)
     (python     . t)
     (haskell    . t)
     (ruby       . t)
     (ocaml      . t)
     (C          . t)  ;; Captial “C” gives access to C, C++, D
     (dot        . t)
     (latex      . t)
     (org        . t)
     (makefile   . t)))

;; Preserve my indentation for source code during export.
(setq org-src-preserve-indentation t)

;; The export process hangs Emacs, let's avoid this.
;; MA: For one reason or another, this crashes more than I'd like.
;; (setq org-export-in-background t)
;; Executing code from ~src~ blocks:2 ends here

;; [[file:~/.emacs.d/init.org::*Manipulating Sections][Manipulating Sections:1]]
;; Refile anywhere 1-level deep in current file,
;; or anywhere in my agenda files 2-levels deep
(setq org-refile-targets '((nil . (:maxlevel . 1))))
      ;; (org-agenda-files . (:maxlevel . 2))  ;; ← Not useful right now.

; Use full outline paths for refile targets - we file directly with IDO
;; When refiling, using Helm, show me the hierarchy paths
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-use-outline-path 'file-path)
;; Manipulating Sections:1 ends here

;; [[file:~/.emacs.d/init.org::*Manipulating Sections][Manipulating Sections:2]]
(setq org-use-speed-commands t)
;; Manipulating Sections:2 ends here

;; [[file:~/.emacs.d/init.org::*Seamless Navigation Between Source Blocks][Seamless Navigation Between Source Blocks:1]]
;; Overriding keys for printing buffer, duplicating gui frame, and isearch-yank-kill.
;;
(use-package org
  :bind (:map org-mode-map
              ("s-p" . org-babel-previous-src-block)
              ("s-n" . org-babel-next-src-block)
              ("s-e" . org-edit-src-code)
         :map org-src-mode-map
              ("s-e" . org-edit-src-exit)))
;; Seamless Navigation Between Source Blocks:1 ends here

;; [[file:~/.emacs.d/init.org::*Modifying ~<return>~][Modifying ~<return>~:1]]
(add-hook 'org-mode-hook '(lambda ()
   (local-set-key (kbd "<return>") 'org-return-indent))
   (local-set-key (kbd "C-M-<return>") 'electric-indent-just-newline))
;; Modifying ~<return>~:1 ends here

;; [[file:~/.emacs.d/init.org::*~C-a,e,k~ and Yanking of sections][~C-a,e,k~ and Yanking of sections:1]]
(setq org-special-ctrl-a/e t)
;; ~C-a,e,k~ and Yanking of sections:1 ends here

;; [[file:~/.emacs.d/init.org::*~C-a,e,k~ and Yanking of sections][~C-a,e,k~ and Yanking of sections:2]]
(setq org-special-ctrl-k t) ;; MA: Does not work …!
;; ~C-a,e,k~ and Yanking of sections:2 ends here

;; [[file:~/.emacs.d/init.org::*~C-a,e,k~ and Yanking of sections][~C-a,e,k~ and Yanking of sections:3]]
(setq org-yank-adjusted-subtrees t)
;; ~C-a,e,k~ and Yanking of sections:3 ends here

;; [[file:~/.emacs.d/init.org::*Hiding Emphasise Markers & Inlining Images][Hiding Emphasise Markers & Inlining Images:1]]
;; org-mode math is now highlighted ;-)
(setq org-highlight-latex-and-related '(latex))

;; Hide the *,=,/ markers
(setq org-hide-emphasis-markers t)

;; (setq org-pretty-entities t)
;; to have \alpha, \to and others display as utf8
;; http://orgmode.org/manual/Special-symbols.html
;; Hiding Emphasise Markers & Inlining Images:1 ends here

;; [[file:~/.emacs.d/init.org::*Proportional fonts for Headlines][Proportional fonts for Headlines:1]]
(set-face-attribute 'org-document-title nil :height 2.0)
;; (set-face-attribute 'org-level-1 nil :height 1.0)
;; Remaining org-level-𝒾 have default height 1.0, for 𝒾 : 1..8.
;;
;; E.g., reset org-level-1 to default.
;; (custom-set-faces '(org-level-1 nil))
;; Proportional fonts for Headlines:1 ends here

;; [[file:~/.emacs.d/init.org::*Show off-screen heading at the top of the window][Show off-screen heading at the top of the window:1]]
 (use-package org-sticky-header
  :hook (org-mode . org-sticky-header-mode)
  :config
  (setq-default
   org-sticky-header-full-path 'full
   ;; Child and parent headings are seperated by a /.
   org-sticky-header-outline-path-separator " / "))
;; Show off-screen heading at the top of the window:1 ends here

;; [[file:~/.emacs.d/init.org::*Jumping without hassle][Jumping without hassle:1]]
(defun my/org-goto-line (line)
  "Go to the indicated line, unfolding the parent Org header.

   Implementation: Go to the line, then look at the 1st previous
   org header, now we can unfold it whence we do so, then we go
   back to the line we want to be at.
  "
  (interactive "nEnter line: ")
  (goto-line line)
  (org-previous-visible-heading 1)
  (org-cycle)
  (goto-line line))
;; Jumping without hassle:1 ends here

;; [[file:~/.emacs.d/init.org::*Folding within a subtree][Folding within a subtree:1]]
(defun my/org-fold-current-subtree-anywhere-in-it ()
  "Hide the current heading, while being anywhere inside it."
  (interactive)
  (save-excursion
    (org-narrow-to-subtree)
    (org-shifttab)
    (widen)))

(add-hook 'org-mode-hook '(lambda ()
  (local-set-key (kbd "C-c C-h") 'my/org-fold-current-subtree-anywhere-in-it)))
;; Folding within a subtree:1 ends here

;; [[file:~/.emacs.d/init.org::*Making Block Delimiters Less Intrusive][Making Block Delimiters Less Intrusive:1]]
  (defvar-local rasmus/org-at-src-begin -1
    "Variable that holds whether last position was a ")

  (defvar rasmus/ob-header-symbol ?☰
    "Symbol used for babel headers")

  (defun rasmus/org-prettify-src--update ()
    (let ((case-fold-search t)
          (re "^[ \t]*#\\+begin_src[ \t]+[^ \f\t\n\r\v]+[ \t]*")
          found)
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward re nil t)
          (goto-char (match-end 0))
          (let ((args (org-trim
                       (buffer-substring-no-properties (point)
                                                       (line-end-position)))))
            (when (org-string-nw-p args)
              (let ((new-cell (cons args rasmus/ob-header-symbol)))
                (cl-pushnew new-cell prettify-symbols-alist :test #'equal)
                (cl-pushnew new-cell found :test #'equal)))))
        (setq prettify-symbols-alist
              (cl-set-difference prettify-symbols-alist
                                 (cl-set-difference
                                  (cl-remove-if-not
                                   (lambda (elm)
                                     (eq (cdr elm) rasmus/ob-header-symbol))
                                   prettify-symbols-alist)
                                  found :test #'equal)))
        ;; Clean up old font-lock-keywords.
        (font-lock-remove-keywords nil prettify-symbols--keywords)
        (setq prettify-symbols--keywords (prettify-symbols--make-keywords))
        (font-lock-add-keywords nil prettify-symbols--keywords)
        (while (re-search-forward re nil t)
          (font-lock-flush (line-beginning-position) (line-end-position))))))

  (defun rasmus/org-prettify-src ()
    "Hide src options via `prettify-symbols-mode'.

  `prettify-symbols-mode' is used because it has uncollpasing. It's
  may not be efficient."
    (let* ((case-fold-search t)
           (at-src-block (save-excursion
                           (beginning-of-line)
                           (looking-at "^[ \t]*#\\+begin_src[ \t]+[^ \f\t\n\r\v]+[ \t]*"))))
      ;; Test if we moved out of a block.
      (when (or (and rasmus/org-at-src-begin
                     (not at-src-block))
                ;; File was just opened.
                (eq rasmus/org-at-src-begin -1))
        (rasmus/org-prettify-src--update))
      ;; Remove composition if at line; doesn't work properly.
      ;; (when at-src-block
      ;;   (with-silent-modifications
      ;;     (remove-text-properties (match-end 0)
      ;;                             (1+ (line-end-position))
      ;;                             '(composition))))
      (setq rasmus/org-at-src-begin at-src-block)))

  (defun rasmus/org-prettify-symbols ()
    (mapc (apply-partially 'add-to-list 'prettify-symbols-alist)
          (cl-reduce 'append
                     (mapcar (lambda (x) (list x (cons (upcase (car x)) (cdr x))))
                             `(("#+begin_src" . ?✎) ;; ➤ 🖝 ➟ ➤ ✎
                               ("#+end_src"   . ?□) ;; ⏹
                               ("#+header:" . ,rasmus/ob-header-symbol)
                               ("#+begin_quote" . ?»)
                               ("#+end_quote" . ?«)))))
    (turn-on-prettify-symbols-mode)
    (add-hook 'post-command-hook 'rasmus/org-prettify-src t t))


;; Last up­dated: 2019-06-09
;; Making Block Delimiters Less Intrusive:1 ends here

;; [[file:~/.emacs.d/init.org::*Making Block Delimiters Less Intrusive][Making Block Delimiters Less Intrusive:2]]
(add-hook 'org-mode-hook #'rasmus/org-prettify-symbols)
(org-mode-restart)
;; Making Block Delimiters Less Intrusive:2 ends here

;; [[file:~/.emacs.d/init.org::*Making Block Delimiters Less Intrusive][Making Block Delimiters Less Intrusive:3]]
(global-prettify-symbols-mode)

(defvar my/prettify-alist nil
  "Musa's personal prettifications.")

(loop for pair in '(;; Example of how pairs like this to beautify org block delimiters
                    ("#+begin_example" . (?ℰ (Br . Bl) ?⇒)) ;; ℰ⇒
                    ("#+end_example"   . ?⇐)                 ;; ⇐
                    ;; Actuall beautifications
                    ("<=" . ?≤) (">=" . ?≥)
                    ("->" . ?→) ("-->". ?⟶) ;; threading operators
                    ("[ ]" . ?□) ("[X]" . ?☑) ("[-]" . ?◐)) ;; Org checkbox symbols

      do (push pair my/prettify-alist))

(loop for hk in '(text-mode-hook prog-mode-hook org-mode-hook)
      do (add-hook hk (lambda ()
                        (setq prettify-symbols-alist
                              (append my/prettify-alist prettify-symbols-alist)))))
;; Making Block Delimiters Less Intrusive:3 ends here

;; [[file:~/.emacs.d/init.org::*Making Block Delimiters Less Intrusive][Making Block Delimiters Less Intrusive:4]]
;; Un-disguise a symbol when cursour is inside it or at the right-edge of it.
(setq prettify-symbols-unprettify-at-point 'right-edge)
;; Making Block Delimiters Less Intrusive:4 ends here

;; [[file:~/.emacs.d/init.org::*Org-mode's ~<𝒳~ Block Expansions][Org-mode's ~<𝒳~ Block Expansions:1]]
(require 'org-tempo)
;; Org-mode's ~<𝒳~ Block Expansions:1 ends here

;; [[file:~/.emacs.d/init.org::*Working with Citations][Working with Citations:1]]
(use-package org-ref :defer t
  :custom ;; Files to look at when no “╲bibliography{⋯}” is not present in a file.
          ;; Most useful for non-LaTeX files.
        (reftex-default-bibliography '("~/thesis-proposal/papers/References.bib"))
        (bibtex-completion-bibliography (car reftex-default-bibliography))
        (org-ref-default-bibliography reftex-default-bibliography))

;; Quick BibTeX references, sometimes.
(use-package helm-bibtex :defer t)
(use-package biblio :defer t)
;; Working with Citations:1 ends here

;; [[file:~/.emacs.d/init.org::*Bibliography & Coloured LaTeX using Minted][Bibliography & Coloured LaTeX using Minted:1]]
(setq org-latex-listings 'minted
      org-latex-packages-alist '(("" "minted"))
      org-latex-pdf-process
      '("pdflatex -shell-escape -output-directory %o %f"
        "biber %b"
        "pdflatex -shell-escape -output-directory %o %f"
        "pdflatex -shell-escape -output-directory %o %f"))
;; Bibliography & Coloured LaTeX using Minted:1 ends here

;; [[file:~/.emacs.d/init.org::*Ensuring Useful HTML Anchors][Ensuring Useful HTML Anchors:1]]
(defun my/ensure-headline-ids (&rest _)
  "Org trees without a

All non-alphanumeric characters are cleverly replaced with ‘-’.

If multiple trees end-up with the same id property, issue a
message and undo any property insertion thus far.

E.g., ↯ We'll go on a ∀∃⇅ adventure
   ↦  We'll-go-on-a-adventure
"
  (interactive)
  (let ((ids))
    (org-map-entries
     (lambda ()
       (org-with-point-at (point)
         (let ((id (org-entry-get nil "CUSTOM_ID")))
           (unless id
             (thread-last (nth 4 (org-heading-components))
               (s-replace-regexp "[^[:alnum:]']" "-")
               (s-replace-regexp "-+" "-")
               (s-chop-prefix "-")
               (s-chop-suffix "-")
               (setq id))
             (if (not (member id ids))
                 (push id ids)
               (message-box "Oh no, a repeated id!\n\n\t%s" id)
               (undo)
               (setq quit-flag t))
             (org-entry-put nil "CUSTOM_ID" id))))))))

;; Whenever html & md export happens, ensure we have headline ids.
(advice-add 'org-html-export-to-html   :before 'my/ensure-headline-ids)
(advice-add 'org-md-export-to-markdown :before 'my/ensure-headline-ids)
;; Ensuring Useful HTML Anchors:1 ends here

;; [[file:~/.emacs.d/init.org::*HTML “Folded Drawers”][HTML “Folded Drawers”:1]]
(defun my/org-drawer-format (name contents)
  "Export to HTML the drawers named with prefix ‘fold_’, ignoring case.

The resulting drawer is a ‘code-details’ and so appears folded;
the user clicks it to see the information therein.
Henceforth, these are called ‘fold drawers’.

Drawers without such a prefix may be nonetheless exported if their
body contains ‘:export: t’ ---this switch does not appear in the output.
Thus, we are biased to generally not exporting non-fold drawers.

One may suspend export of fold drawers by having ‘:export: nil’
in their body definition.

Fold drawers naturally come with a title.
Either it is specfied in the drawer body by ‘:title: ⋯’,
or otherwise the drawer's name is used with all underscores replaced
by spaces.
"
  (let* ((contents′ (replace-regexp-in-string ":export:.*\n?" "" contents))
         (fold? (s-prefix? "fold_" name 'ignore-case))
         (export? (string-match ":export:\s+t" contents))
         (not-export? (string-match ":export:\s+nil" contents))
         (title′ (and (string-match ":title:\\(.*\\)\n" contents)
                      (match-string 1 contents))))

    ;; Ensure we have a title.
    (unless title′ (setq title′ (s-join " " (cdr (s-split "_" name)))))

    ;; Output
    (cond
     ((and export? (not fold?)) contents′)
     (not-export? nil)
     (fold?
      (thread-last contents′
        (replace-regexp-in-string ":title:.*\n" "")
        (format "<details class=\"code-details\"> <summary> <strong>
            <font face=\"Courier\" size=\"3\" color=\"green\"> %s
            </font> </strong> </summary> %s </details>" title′))))))

(setq org-html-format-drawer-function 'my/org-drawer-format)
;; HTML “Folded Drawers”:1 ends here

;; [[file:~/.emacs.d/init.org::*\[\[https://revealjs.com/?transition=zoom#/\]\[Reveal.JS\]\] -- The HTML Presentation Framework][[[https://revealjs.com/?transition=zoom#/][Reveal.JS]] -- The HTML Presentation Framework:1]]
(use-package ox-reveal :defer t
  :custom (org-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js"))
;; [[https://revealjs.com/?transition=zoom#/][Reveal.JS]] -- The HTML Presentation Framework:1 ends here

;; [[file:~/.emacs.d/init.org::*\[\[https://revealjs.com/?transition=zoom#/\]\[Reveal.JS\]\] -- The HTML Presentation Framework][[[https://revealjs.com/?transition=zoom#/][Reveal.JS]] -- The HTML Presentation Framework:3]]
(setq org-reveal-title-slide "<h1>%t</h1> <h3>%a</h3>
<font size=\"1\">
<a href=\"?print-pdf&showNotes=true\">
⟪ Flattened View ; Press <code>?</code> for Help ⟫
</a>
</font>")
;; [[https://revealjs.com/?transition=zoom#/][Reveal.JS]] -- The HTML Presentation Framework:3 ends here

;; [[file:~/.emacs.d/init.org::*Capturing ideas & notes without interrupting the current workflow][Capturing ideas & notes without interrupting the current workflow:1]]
;; Location of my todos/notes file
(setq org-default-notes-file "~/Dropbox/todo.org")

;; “C-c c” to quickly capture a task/note
(define-key global-map "\C-cc" #'my/org-capture) ;; See below.
;; Capturing ideas & notes without interrupting the current workflow:1 ends here

;; [[file:~/.emacs.d/init.org::*Capturing ideas & notes without interrupting the current workflow][Capturing ideas & notes without interrupting the current workflow:2]]
(cl-defun my/make/org-capture-template
   (shortcut heading &optional (no-todo nil) (description heading) (scheduled nil))
  "Quickly produce an org-capture-template.

  After adding the result of this function to ‘org-capture-templates’,
  we will be able perform a capture with “C-c c ‘shortcut’”
  which will have description ‘description’.
  It will be added to the tasks file under heading ‘heading’.

  ‘no-todo’ omits the ‘TODO’ tag from the resulting item; e.g.,
  when it's merely an interesting note that needn't be acted upon.

  Default for ‘description’ is ‘heading’. Default for ‘no-todo’ is ‘nil’.

  Scheduled items appear in the agenda; true by default.

  The target is ‘file+headline’ and the type is ‘entry’; to see
  other possibilities invoke: C-h o RET org-capture-templates.
  The “%?” indicates the location of the Cursor, in the template,
  when forming the entry.
  "
  `(,shortcut ,description entry
      (file+headline org-default-notes-file ,heading)
         ,(concat "*" (unless no-todo " TODO") " %?\n"
                (when nil ;; this turned out to be a teribble idea.
                  ":PROPERTIES:\n:"
                (if scheduled
                    "SCHEDULED: %^{Any time ≈ no time! Please schedule this task!}t"
                  "CREATED: %U")
                "\n:END:") "\n\n ")
      :empty-lines 1 :time-prompt t))

(setq org-capture-templates
      (loop for (shortcut heading)
            in (-partition 2 '("t" "Tasks, Getting Things Done"
                               "r" "Research"
                               "2" "2FA3"
                               "m" "Email"
                               "e" "Emacs (•̀ᴗ•́)و"
                               "i" "Islam"
                               "b" "Blog"
                               "a" "Arbitrary Reading and Learning"
                               "l" "Programming Languages"
                               "p" "Personal Matters"))
            collect  (my/make/org-capture-template shortcut heading)))

;; Update: Let's schedule tasks during the GTD processing phase.
;;
;; For now, let's automatically schedule items a week in advance.
;; TODO: FIXME: This overwrites any scheduling I may have performed.
;; (defun my/org-capture-schedule ()
;;   (org-schedule nil "+7d"))
;;
;; (add-hook 'org-capture-before-finalize-hook 'my/org-capture-schedule)
;; Capturing ideas & notes without interrupting the current workflow:2 ends here

;; [[file:~/.emacs.d/init.org::*Capturing ideas & notes without interrupting the current workflow][Capturing ideas & notes without interrupting the current workflow:3]]
;; Cannot mark an item DONE if it has a  TODO child.
;; Conversely, all children must be DONE in-order for a parent to be DONE.
(setq org-enforce-todo-dependencies t)
;; Capturing ideas & notes without interrupting the current workflow:3 ends here

;; [[file:~/.emacs.d/init.org::*Capturing ideas & notes without interrupting the current workflow][Capturing ideas & notes without interrupting the current workflow:4]]
  ;; Ensure notes are stored at the top of a tree.
  (setq org-reverse-note-order nil)
;; Capturing ideas & notes without interrupting the current workflow:4 ends here

;; [[file:~/.emacs.d/init.org::*Capturing ideas & notes without interrupting the current workflow][Capturing ideas & notes without interrupting the current workflow:5]]
(cl-defun my/org-capture-buffer (&optional keys no-additional-remarks
                                           (heading-regexp "Subject: \\(.*\\)"))
  "Capture the current [narrowed] buffer as a todo/note.

This is mostly intended for capturing mail as todo tasks ^_^

When NO-ADDITIONAL-REMARKS is provided, and a heading is found,
then make and store the note without showing a pop-up.
This is useful for when we capture self-contained mail.

The HEADING-REGEXP must have a regexp parenthesis construction
which is used to obtain a suitable heading for the resulting todo/note."
  (interactive "P")
  (let* ((current-content (substring-no-properties (buffer-string)))
         (heading         (progn (string-match heading-regexp current-content)
                                 (or (match-string 1 current-content) ""))))
    (org-capture keys)
    (insert heading "\n\n\n\n" (s-repeat 80 "-") "\n\n\n" current-content)

    ;; The overtly verbose conditions are for the sake of clarity.
    ;; Moreover, even though the final could have “t”, being explicit
    ;; communicates exactly the necessary conditions.
    ;; Being so verbose leads to mutual exclusive clauses, whence order is irrelevant.
    (cond
     ((s-blank? heading)
        (beginning-of-buffer) (end-of-line))
     ((and no-additional-remarks (not (s-blank? heading)))
        (org-capture-finalize))
     ((not (or no-additional-remarks (s-blank? heading)))
        (beginning-of-buffer) (forward-line 2) (indent-for-tab-command)))))
;; Capturing ideas & notes without interrupting the current workflow:5 ends here

;; [[file:~/.emacs.d/init.org::*Capturing ideas & notes without interrupting the current workflow][Capturing ideas & notes without interrupting the current workflow:6]]
(defun my/org-capture (&optional prefix keys)
  "Capture something!

      C-c c   ⇒ Capture something; likewise for “C-uⁿ C-c c” where n ≥ 3.
C-u   C-c c   ⇒ Capture current [narrowed] buffer.
C-u 5 C-c c   ⇒ Capture current [narrowed] buffer without adding additional remarks.
C-u C-u C-c c ⇒ Goto last note stored."
  (interactive "p")
  (case prefix
    (4     (my/org-capture-buffer keys))
    (5     (my/org-capture-buffer keys :no-additional-remarks))
    (t     (org-capture prefix keys))))
;; Capturing ideas & notes without interrupting the current workflow:6 ends here

;; [[file:~/.emacs.d/init.org::*Step 2: Filing your tasks][Step 2: Filing your tasks:1]]
;; Add a note whenever a task's deadline or scheduled date is changed.
(setq org-log-redeadline 'time)
(setq org-log-reschedule 'time)
;; Step 2: Filing your tasks:1 ends here

;; [[file:~/.emacs.d/init.org::*Step 3: Quickly review the upcoming week][Step 3: Quickly review the upcoming week:1]]
(define-key global-map "\C-ca" 'org-agenda)
;; Step 3: Quickly review the upcoming week:1 ends here

;; [[file:~/.emacs.d/init.org::*Step 7: Archiving Tasks][Step 7: Archiving Tasks:1]]
;; C-c a s ➩ Search feature also looks into archived files.
;; Helpful when need to dig stuff up from the past.
(setq org-agenda-text-search-extra-files '(agenda-archives))
;; Step 7: Archiving Tasks:1 ends here

;; [[file:~/.emacs.d/init.org::*Step 7: Archiving Tasks][Step 7: Archiving Tasks:2]]
;; Invoking the agenda command shows the agenda and enables
;; the org-agenda variables.
;; ➩ Show my agenda upon Emacs startup.
(org-agenda "a" "a") ;; Need this to have “org-agenda-custom-commands” defined.
;; Step 7: Archiving Tasks:2 ends here

;; [[file:~/.emacs.d/init.org::*Step 7: Archiving Tasks][Step 7: Archiving Tasks:3]]
;; Pressing ‘c’ in the org-agenda view shows all completed tasks,
;; which should be archived.
(add-to-list 'org-agenda-custom-commands
  '("c" todo "DONE|ON_HOLD|CANCELLED" nil))
;; Step 7: Archiving Tasks:3 ends here

;; [[file:~/.emacs.d/init.org::*Step 7: Archiving Tasks][Step 7: Archiving Tasks:4]]
(add-to-list 'org-agenda-custom-commands
  '("u" alltodo ""
     ((org-agenda-skip-function
        (lambda ()
              (org-agenda-skip-entry-if 'scheduled 'deadline 'regexp  "\n]+>")))
              (org-agenda-overriding-header "Unscheduled TODO entries: "))))
;; Step 7: Archiving Tasks:4 ends here

;; [[file:~/.emacs.d/init.org::*Tag! You're it!][Tag! You're it!:1]]
 (setq org-tags-column -77) ;; the default
;; Tag! You're it!:1 ends here

;; [[file:~/.emacs.d/init.org::*Tag! You're it!][Tag! You're it!:2]]
(use-package helm-org) ;; Helm for org headlines and keywords completion.
(add-to-list 'helm-completing-read-handlers-alist
             '(org-set-tags-command . helm-org-completing-read-tags))

;; Also provides: helm-org-capture-templates
;; Tag! You're it!:2 ends here

;; [[file:~/.emacs.d/init.org::*Tag! You're it!][Tag! You're it!:3]]
(use-package org-pretty-tags
  :diminish t
  :demand t
  :config
   (setq org-pretty-tags-surrogate-strings
         '(("Neato"    . "💡")
           ("Blog"     . "✍")
           ("Audio"    . "♬")
           ("Video"    . "📺")
           ("Book"     . "📚")
           ("Running"  . "🏃")
           ("Question" . "❓")
           ("Wife"     . "💕")
           ("Text"     . "💬") ; 📨 📧
           ("Friends"  . "👪")
           ("Self"     . "🍂")
           ("Finances" . "💰")
           ("Car"      . "🚗") ; 🚙 🚗 🚘
           ("Urgent"   . "🔥"))) ;; 📥 📤 📬
   (org-pretty-tags-global-mode 1))
;; Tag! You're it!:3 ends here

;; [[file:~/.emacs.d/init.org::*Pretty Prioritisation Markers][Pretty Prioritisation Markers:1]]
(setq org-lowest-priority ?D) ;; Now org-speed-eky ‘,’ gives 4 options
(setq org-priority-faces
'((?A :foreground "red" :weight bold)
  (?B . "orange")
  (?C . "yellow")
  (?D . "green")))
;; Pretty Prioritisation Markers:1 ends here

;; [[file:~/.emacs.d/init.org::*Pretty Prioritisation Markers][Pretty Prioritisation Markers:2]]
(use-package org-fancy-priorities
  :diminish t
  :hook   (org-mode . org-fancy-priorities-mode)
  :custom (org-fancy-priorities-list '("HIGH" "MID" "LOW" "OPTIONAL")))
;; Pretty Prioritisation Markers:2 ends here

;; [[file:~/.emacs.d/init.org::*Super Agenda][Super Agenda:1]]
;; List of all the files & directories where todo items can be found. Only one
;; for now: My default notes file.
(setq org-agenda-files (list org-default-notes-file))

;; Display tags really close to their tasks.
(setq org-agenda-tags-column -10)

;; How many days ahead the default agenda view should look
(setq org-agenda-span 'day)
;; May be any number; the larger the slower it takes to generate the view.
;; One day is thus the fastest ^_^

;; How many days early a deadline item will begin showing up in your agenda list.
(setq org-deadline-warning-days 14)

;; In the agenda view, days that have no associated tasks will still have a line showing the date.
(setq org-agenda-show-all-dates t)

;; Scheduled items marked as complete will not show up in your agenda view.
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-deadline-if-done  t)
;; Super Agenda:1 ends here

;; [[file:~/.emacs.d/init.org::*Super Agenda][Super Agenda:2]]
(setq org-agenda-start-on-weekday nil)
;; Super Agenda:2 ends here

;; [[file:~/.emacs.d/init.org::*Super Agenda][Super Agenda:3]]
(use-package org-super-agenda
  :hook (org-agenda-mode . origami-mode) ;; Easily fold groups via TAB.
  :bind (:map org-super-agenda-header-map ("<tab>" . origami-toggle-node))
  :config
  (org-super-agenda-mode)
  (setq org-super-agenda-groups
        '((:name "Important" :priority "A")
          (:name "Personal" :habit t)
          ;; For everything else, nicely display their heading hierarchy list.
          (:auto-map (lambda (e) (org-format-outline-path (org-get-outline-path)))))))

;; MA: No noticable effect when using org-super-agenda :/
;;
;; Leave new line at the end of an entry.
;; (setq org-blank-before-new-entry '((heading . t) (plain-list-item . t)))
;; Super Agenda:3 ends here

;; [[file:~/.emacs.d/init.org::*Automating \[\[https://en.wikipedia.org/wiki/Pomodoro_Technique\]\[Pomodoro\]\] ---“Commit for only 25 minutes!”][Automating [[https://en.wikipedia.org/wiki/Pomodoro_Technique][Pomodoro]] ---“Commit for only 25 minutes!”:1]]
;; Tasks get a 25 minute count down timer
(setq org-timer-default-timer 25)

;; Use the timer we set when clocking in happens.
(add-hook 'org-clock-in-hook
  (lambda () (org-timer-set-timer '(16))))

;; unless we clocked-out with less than a minute left,
;; show disappointment message.
(add-hook 'org-clock-out-hook
  (lambda ()
  (unless (s-prefix? "0:00" (org-timer-value-string))
     (message-box "The basic 25 minutes on this difficult task are not up; it's a shame to see you leave."))
     (org-timer-stop)))
;; Automating [[https://en.wikipedia.org/wiki/Pomodoro_Technique][Pomodoro]] ---“Commit for only 25 minutes!”:1 ends here

;; [[file:~/.emacs.d/init.org::*The Setup][The Setup:1]]
(defun my/org-journal-new-entry (prefix)
  "Open today’s journal file and start a new entry.

  With a prefix, we use the work journal; otherwise the personal journal."
  (interactive "P")
  (-let [org-journal-file-format (if prefix "Work-%Y-%m-%d" org-journal-file-format)]
    (org-journal-new-entry nil)
    (org-mode)
    (org-show-all)))

(use-package org-journal
  ;; C-u C-c j ⇒ Work journal ;; C-c C-j ⇒ Personal journal
  :bind (("C-c j" . my/org-journal-new-entry))
  :config
  (setq org-journal-dir         "~/Dropbox/journal/"
        org-journal-file-type   'yearly
        org-journal-file-format "Personal-%Y-%m-%d"))
;; The Setup:1 ends here

;; [[file:~/.emacs.d/init.org::*Workflow States][Workflow States:1]]
(setq org-todo-keywords
      '((sequence "TODO(t)" "STARTED(s@/!)" "|" "DONE(d/!)")
        (sequence "WAITING(w@/!)" "ON_HOLD(h@/!)" "|" "CANCELLED(c@/!)")))

;; Since DONE is a terminal state, it has no exit-action.
;; Let's explicitly indicate time should be noted.
(setq org-log-done 'time)
;; Workflow States:1 ends here

;; [[file:~/.emacs.d/init.org::*Workflow States][Workflow States:2]]
(setq org-todo-keyword-faces
      '(("TODO"      :foreground "red"          :weight bold)
        ("STARTED"   :foreground "blue"         :weight bold)
        ("DONE"      :foreground "forest green" :weight bold)
        ("WAITING"   :foreground "orange"       :weight bold)
        ("ON_HOLD"   :foreground "magenta"      :weight bold)
        ("CANCELLED" :foreground "forest green" :weight bold)))
;; Workflow States:2 ends here

;; [[file:~/.emacs.d/init.org::*Workflow States][Workflow States:3]]
(setq org-use-fast-todo-selection t)
;; Workflow States:3 ends here

;; [[file:~/.emacs.d/init.org::*Workflow States][Workflow States:4]]
;; Install the tool
; (async-shell-command "brew cask install java") ;; Dependency
; (async-shell-command "brew install plantuml")

;; Tell emacs where it is.
;; E.g., (async-shell-command "find / -name plantuml.jar")
(setq org-plantuml-jar-path
      "/usr/local/Cellar/plantuml/1.2019.13/libexec/plantuml.jar")

;; Enable C-c C-c to generate diagrams from plantuml src blocks.
(add-to-list 'org-babel-load-languages '(plantuml . t) )
(require 'ob-plantuml)

; Use fundamental mode when editing plantuml blocks with C-c '
(add-to-list 'org-src-lang-modes '("plantuml" . fundamental))
;; Workflow States:4 ends here

;; [[file:~/.emacs.d/init.org::*Clocking Work Time][Clocking Work Time:1]]
;; Record a note on what was accomplished when clocking out of an item.
(setq org-log-note-clock-out t)
;; Clocking Work Time:1 ends here

;; [[file:~/.emacs.d/init.org::*Clocking Work Time][Clocking Work Time:2]]
(setq confirm-kill-emacs 'yes-or-no-p)
;; Clocking Work Time:2 ends here

;; [[file:~/.emacs.d/init.org::*Clocking Work Time][Clocking Work Time:3]]
;; Resume clocking task when emacs is restarted
(org-clock-persistence-insinuate)

;; Show lot of clocking history
(setq org-clock-history-length 23)

;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)

;; Sometimes I change tasks I'm clocking quickly ---this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)

;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)

;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist t)

;; Do not prompt to resume an active clock
(setq org-clock-persist-query-resume nil)

;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)
;; Clocking Work Time:3 ends here

;; [[file:~/.emacs.d/init.org::*Estimates versus actual time][Estimates versus actual time:1]]
 (push '("Effort_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")
       org-global-properties)
;; Estimates versus actual time:1 ends here

;; [[file:~/.emacs.d/init.org::*Estimates versus actual time][Estimates versus actual time:2]]
(setq org-clock-sound "~/.emacs.d/school-bell.wav")
;; Estimates versus actual time:2 ends here

;; [[file:~/.emacs.d/init.org::*Habit Formation][Habit Formation:1]]
;; Show habits for every day in the agenda.
(setq org-habit-show-habits t)
(setq org-habit-show-habits-only-for-today nil)

;; This shows the ‘Seinfeld consistency’ graph closer to the habit heading.
(setq org-habit-graph-column 90)

;; In order to see the habit graphs, which I've placed rightwards, let's
;; always open org-agenda in ‘full screen’.
;; (setq org-agenda-window-setup 'only-window)
;; Habit Formation:1 ends here

;; [[file:~/.emacs.d/init.org::*Actually Doing Things][Actually Doing Things:1]]
;; Obtain a notifications and text-to-speech utilities
(system-packages-ensure "espeak") ;; Alternatively: espeak-ng supports 109 languages
(system-packages-ensure "terminal-notifier") ;; MacOS specific

(run-at-time
 "09:00am"
 (* 2 60 60) ;; Every two hours
 (lambda ()
   (shell-command
    (format "%s"
            '(terminal-notifier
              -title    \"Check your agenda!\"
              -subtitle \"Is what you\'re doing …\"
              -message  \"… in alignment with your goals?\"
              -sound t -appIcon ~/.emacs.d/images/emacs-logo.png
              ;; Speak at a speed of 125 words per minute; ie slowed down.
              & espeak -s 125 \"Maybe it\'s time to do another task?\")))))
;; Actually Doing Things:1 ends here

;; [[file:~/.emacs.d/init.org::*Which function are we writing?][Which function are we writing?:1]]
(add-hook 'prog-mode-hook #'which-function-mode)
(add-hook 'org-mode-hook  #'which-function-mode)
;; Which function are we writing?:1 ends here

;; [[file:~/.emacs.d/init.org::*Which function are we writing?][Which function are we writing?:2]]
(add-hook 'emacs-lisp-mode-hook #'check-parens)
;; Which function are we writing?:2 ends here

;; [[file:~/.emacs.d/init.org::*Highlight defined Lisp symbols][Highlight defined Lisp symbols:1]]
;; Emacs Lisp specific
(use-package highlight-defined
  :hook (emacs-lisp-mode . highlight-defined-mode))
;; Highlight defined Lisp symbols:1 ends here

;; [[file:~/.emacs.d/init.org::*Eldoc for Lisp and Haskell][Eldoc for Lisp and Haskell:1]]
(use-package eldoc
  :hook (emacs-lisp-mode . turn-on-eldoc-mode)
        (lisp-interaction-mode . turn-on-eldoc-mode)
        (haskell-mode . turn-on-haskell-doc-mode)
        (haskell-mode . turn-on-haskell-indent))
;; Eldoc for Lisp and Haskell:1 ends here

;; [[file:~/.emacs.d/init.org::*Jumping to definitions & references][Jumping to definitions & references:1]]
(use-package dumb-jump
  :bind (("M-g q"     . dumb-jump-quick-look) ;; Show me in a tooltip.
         ("M-g ."     . dumb-jump-go-other-window)
         ("M-g b"     . dumb-jump-back)
         ("M-g p"     . dumb-jump-go-prompt)
         ("M-g a"     . xref-find-apropos)) ;; aka C-M-.
  :config
  ;; If source file is visible, just shift focus to it.
  (setq dumb-jump-use-visible-window t))
;; Jumping to definitions & references:1 ends here

;; [[file:~/.emacs.d/init.org::*Version Control with SVN ---Using Magit!][Version Control with SVN ---Using Magit!:1]]
(use-package magit-svn
  :hook (magit-mode . magit-svn-mode))
;; Version Control with SVN ---Using Magit!:1 ends here

;; [[file:~/.emacs.d/init.org::*What's changed & who's to blame?][What's changed & who's to blame?:1]]
;; Hunk navigation and commiting.
(use-package git-gutter
  :diminish
  :config (global-git-gutter-mode))
;; Diff updates happen in real time according when user is idle.
;; What's changed & who's to blame?:1 ends here

;; [[file:~/.emacs.d/init.org::*What's changed & who's to blame?][What's changed & who's to blame?:2]]
;; What's changed & who's to blame?:2 ends here

;; [[file:~/.emacs.d/init.org::*What's changed & who's to blame?][What's changed & who's to blame?:3]]
;; Colour fringe to indicate alterations.
;; (use-package diff-hl)
;; (global-diff-hl-mode)
;; What's changed & who's to blame?:3 ends here

;; [[file:~/.emacs.d/init.org::*What's changed & who's to blame?][What's changed & who's to blame?:4]]
;; Popup for who's to blame for alterations.
(use-package git-messenger
  :custom ;; Always show who authored the commit and when.
          (git-messenger:show-detail t)
          ;; Message menu let's us use magit diff to see the commit change.
          (git-messenger:use-magit-popup t))

;; View current file in browser on github.
;; More generic is “browse-at-remote”.
(use-package github-browse-file :defer t)

;; Add these to the version control hydra.
;;
;; What's changed & who's to blame?:4 ends here

;; [[file:~/.emacs.d/init.org::*What's changed & who's to blame?][What's changed & who's to blame?:5]]
(use-package git-link :defer t)


;; [[file:~/.emacs.d/init.org::*Highlighting TODO-s & Showing them in Magit][Highlighting TODO-s & Showing them in Magit:1]]
;; NOTE that the highlighting works even in comments.
(use-package hl-todo
  ;; I want todo-words highlighted in prose, not just in code fragements.
  ;; :hook (org-mode . hl-todo-mode)
  :config
    ;; Adding new keywords
    (loop for kw in '("TEST" "MA" "WK" "JC")
          do (add-to-list 'hl-todo-keyword-faces (cons kw "#dc8cc3")))
    (global-hl-todo-mode))   ;; Enable it everywhere.
;; Highlighting TODO-s & Showing them in Magit:1 ends here

;; [[file:~/.emacs.d/init.org::*Highlighting TODO-s & Showing them in Magit][Highlighting TODO-s & Showing them in Magit:2]]
(defun add-watchwords () "Add TODO: words to font-lock keywords."
  (font-lock-add-keywords nil
                          '(("\\(\\<TODO\\|\\<FIXME\\|\\<HACK\\|@.+\\):" 1
                             font-lock-warning-face t))))

(add-hook 'prog-mode-hook #'add-watchwords)
;; Highlighting TODO-s & Showing them in Magit:2 ends here

;; [[file:~/.emacs.d/init.org::*Highlighting TODO-s & Showing them in Magit][Highlighting TODO-s & Showing them in Magit:3]]
;; MA: The todo keywords work in code too!
(use-package magit-todos
  :after magit
  :after hl-todo
  :hook (org-mode . magit-todos-mode)
  :config
  ;; For some reason cannot use :custom with this package.
  (custom-set-variables
    '(magit-todos-keywords (list "TODO" "FIXME" "MA" "WK" "JC")))
  ;; Ignore TODOs mentioned in exported HTML files; they're duplicated from org src.
  (setq magit-todos-exclude-globs '("*.html"))
  (magit-todos-mode))
;; Highlighting TODO-s & Showing them in Magit:3 ends here

;; [[file:~/.emacs.d/init.org::*Highlighting TODO-s & Showing them in Magit][Highlighting TODO-s & Showing them in Magit:4]]

;; [[file:~/.emacs.d/init.org::*Aggressive Indentation][Aggressive Indentation:1]]
;; Always stay indented: Automatically have blocks reindented after every change.
(use-package aggressive-indent
  :config (global-aggressive-indent-mode t))

;; Use 4 spaces in places of tabs when indenting.
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;; Aggressive Indentation:1 ends here

;; [[file:~/.emacs.d/init.org::*Being Generous with Whitespace][Being Generous with Whitespace:1]]
(use-package electric-operator
  :diminish
  :hook (c-mode . electric-operator-mode))
;; Being Generous with Whitespace:1 ends here

;; [[file:~/.emacs.d/init.org::*On the fly syntax checking][On the fly syntax checking:1]]
(use-package flycheck
  :diminish
  :init (global-flycheck-mode)
  :config ;; There may be multiple tools; I have GHC not Stack, so let's avoid that.
  (setq-default flycheck-disabled-checkers '(haskell-stack-ghc emacs-lisp-checkdoc))
  :custom (flycheck-display-errors-delay .3))
;; On the fly syntax checking:1 ends here

;; [[file:~/.emacs.d/init.org::*On the fly syntax checking][On the fly syntax checking:3]]
(use-package flymake
  :hook ((emacs-lisp-mode . (lambda () (flycheck-mode -1)))
         (emacs-lisp-mode . flymake-mode))
  :bind (:map flymake-mode-map
              ("C-c ! n" . flymake-goto-next-error)
              ("C-c ! p" . flymake-goto-prev-error)))
;; On the fly syntax checking:3 ends here

;; [[file:~/.emacs.d/init.org::*Coding with a Fruit Salad: Semantic Highlighting][Coding with a Fruit Salad: Semantic Highlighting:1]]
(use-package color-identifiers-mode
  :config (global-color-identifiers-mode))

;; Sometimes just invoke: M-x color-identifiers:refresh
;; Coding with a Fruit Salad: Semantic Highlighting:1 ends here

;; [[file:~/.emacs.d/init.org::*Text Folding with Origami-mode][Text Folding with Origami-mode:1]]
(use-package origami
  ;; In Lisp languages, by default only function definitions are folded.
  :hook ((agda2-mode lisp-mode c-mode) . origami-mode)
  :config
  ;; With basic support for one of my languages.
  (push '(agda2-mode . (origami-markers-parser "{-" "-}"))
         origami-parser-alist))
;; Text Folding with Origami-mode:1 ends here

;; [[file:~/.emacs.d/init.org::*Text Folding with Origami-mode][Text Folding with Origami-mode:2]]
(defun my/search-hook-function ()
  (when origami-mode (origami-toggle-node (current-buffer) (point))))

;; Open folded nodes if a search stops there.
(add-hook 'helm-swoop-after-goto-line-action-hook #'my/search-hook-function)
;;
;; Likewise for incremental search, isearch, users.
;; (add-hook 'isearch-mode-end-hook #'my/search-hook-function)
;; Text Folding with Origami-mode:2 ends here

;; [[file:~/.emacs.d/init.org::*Text Folding with Origami-mode][Text Folding with Origami-mode:3]]
;; Text Folding with Origami-mode:3 ends here

;; [[file:~/.emacs.d/init.org::*Jump between windows using Cmd+Arrow & between recent buffers with Meta-Tab][Jump between windows using Cmd+Arrow & between recent buffers with Meta-Tab:1]]
(use-package windmove
  :config ;; use command key on Mac
          (windmove-default-keybindings 'super)
          ;; wrap around at edges
          (setq windmove-wrap-around t))
;; Jump between windows using Cmd+Arrow & between recent buffers with Meta-Tab:1 ends here

;; [[file:~/.emacs.d/init.org::*Jump between windows using Cmd+Arrow & between recent buffers with Meta-Tab][Jump between windows using Cmd+Arrow & between recent buffers with Meta-Tab:2]]
(use-package buffer-flip
  :bind
   (:map buffer-flip-map
    ("M-<tab>"   . buffer-flip-forward)
    ("M-S-<tab>" . buffer-flip-backward)
    ("C-g"       . buffer-flip-abort))
  :config
    (setq buffer-flip-skip-patterns
        '("^\\*helm\\b")))
;; key to begin cycling buffers.
(global-set-key (kbd "M-<tab>") 'buffer-flip)
;; Jump between windows using Cmd+Arrow & between recent buffers with Meta-Tab:2 ends here

;; [[file:~/.emacs.d/init.org::*Intro][Intro:1]]
;; Add yasnippet support for all company backends
;;
(cl-defun my/company-backend-with-yankpad (backend)
  "There can only be one main completition backend, so let's
   enable yasnippet/yankpad as a secondary for all completion
   backends.

   Src: https://emacs.stackexchange.com/a/10520/10352"

  (if (and (listp backend) (member 'company-yankpad backend))
      backend
    (append (if (consp backend) backend (list backend))
            '(:with company-yankpad))))
;; Intro:1 ends here

;; [[file:~/.emacs.d/init.org::*Intro][Intro:2]]
;; Yet another snippet extension program
(use-package yasnippet
  :diminish yas-minor-mode
  :config
    (yas-global-mode 1) ;; Always have this on for when using yasnippet syntax within yankpad
    ;; respect the spacing in my snippet declarations
    (setq yas-indent-line 'fixed))

;; Alternative, Org-based extension program
(use-package yankpad
  :diminish
  :config
    ;; Location of templates
    (setq yankpad-file "~/.emacs.d/yankpad.org")

    ;; Ignore major mode, always use defaults.
    ;; Yankpad will freeze if no org heading has the name of the given category.
    (setq yankpad-category "Default")

    ;; Load the snippet templates ---useful after yankpad is altered
    (yankpad-reload)

    ;; Set company-backend as a secondary completion backend to all existing backends.
    (setq company-backends (mapcar #'my/company-backend-with-yankpad company-backends)))
;; Intro:2 ends here

;; [[file:~/.emacs.d/init.org::*Intro][Intro:5]]
(cl-defun org-insert-link ()
  "Makes an org link by inserting the URL copied to clipboard and
  prompting for the link description only.

  Type over the shown link to change it, or tab to move to the
  description field.

  This overrides Org-mode's built-in ‘org-insert-link’ utility;
  whence C-c C-l uses the snippet."
  (interactive)
  (insert "my_org_insert_link")
  (yankpad-expand))
;; Intro:5 ends here

;; [[file:~/.emacs.d/init.org::*Re-Enabling Templates][Re-Enabling Templates:1]]
;; After init hook; see above near use-package install.
(yankpad-reload)
;; Re-Enabling Templates:1 ends here

;; [[file:~/.emacs.d/init.org::*Helpful Utilities & Shortcuts][Helpful Utilities & Shortcuts:1]]
;; change all prompts to y or n
(fset 'yes-or-no-p 'y-or-n-p)

;; Enable all ‘possibly confusing commands’ such as helpful but
;; initially-worrisome “narrow-to-region”, C-x n n.
(setq-default disabled-command-function nil)
;; Helpful Utilities & Shortcuts:1 ends here

;; [[file:~/.emacs.d/init.org::*Documentation Pop-Ups][Documentation Pop-Ups:1]]
(use-package company-quickhelp
 :config
   (setq company-quickhelp-delay 0.1)
   (company-quickhelp-mode))
;; Documentation Pop-Ups:1 ends here

;; [[file:~/.emacs.d/init.org::*Reload buffer with ~f5~][Reload buffer with ~f5~:1]]
(global-set-key [f5] '(lambda () (interactive) (revert-buffer nil t nil)))
;; Reload buffer with ~f5~:1 ends here

;; [[file:~/.emacs.d/init.org::*Reload buffer with ~f5~][Reload buffer with ~f5~:2]]
;; Auto update buffers that change on disk.
;; Will be prompted if there are changes that could be lost.
(global-auto-revert-mode 1)

;; Don't show me the “ARev” marker in the mode line
(diminish 'auto-revert-mode)
;; Reload buffer with ~f5~:2 ends here

;; [[file:~/.emacs.d/init.org::*Kill to start of line][Kill to start of line:1]]
;; M-k kills to the left
(global-set-key "\M-k" '(lambda () (interactive) (kill-line 0)) )
;; Kill to start of line:1 ends here

;; [[file:~/.emacs.d/init.org::*Killing buffers & windows: ~C-x k~ has a family][Killing buffers & windows: ~C-x k~ has a family:1]]
(global-set-key (kbd "C-x k")
  (lambda (&optional prefix)
"C-x k     ⇒ Kill current buffer & window
C-u C-x k ⇒ Kill OTHER window and its buffer
C-u C-u C-x C-k ⇒ Kill all other buffers and windows

Prompt only if there are unsaved changes."
     (interactive "P")
     (pcase (or (car prefix) 0)
       ;; C-x k     ⇒ Kill current buffer & window
       (0  (kill-this-buffer)
           (unless (one-window-p) (delete-window)))
       ;; C-u C-x k ⇒ Kill OTHER window and its buffer
       (4  (other-window 1)
           (kill-this-buffer)
           (unless (one-window-p) (delete-window)))
       ;; C-u C-u C-x C-k ⇒ Kill all other buffers and windows
       (16   (mapc 'kill-buffer (delq (current-buffer) (buffer-list)))
             (delete-other-windows)))))
;; Killing buffers & windows: ~C-x k~ has a family:1 ends here

;; [[file:~/.emacs.d/init.org::*Switching from 2 horizontal windows to 2 vertical windows][Switching from 2 horizontal windows to 2 vertical windows:1]]
(defun my/ensure-two-vertical-windows ()
  "I used this method often when programming in Coq.

When there are two vertical windows, this method ensures the left-most
window contains the buffer with the cursour in it."
  (interactive)
  (let ((otherBuffer (buffer-name)))
    (other-window 1)                ;; C-x 0
    (delete-window)                 ;; C-x 0
    (split-window-right)			;; C-x 3
    (other-window 1)                ;; C-x 0
    (switch-to-buffer otherBuffer)	;; C-x b RET
    (other-window 1)))

(global-set-key (kbd "C-|") 'my/ensure-two-vertical-windows)
;; Switching from 2 horizontal windows to 2 vertical windows:1 ends here

;; [[file:~/.emacs.d/init.org::*Obtaining Values of ~#+KEYWORD~ Annotations][Obtaining Values of ~#+KEYWORD~ Annotations:1]]
;; Src: http://kitchingroup.cheme.cmu.edu/blog/2013/05/05/Getting-keyword-options-in-org-files/
(defun org-keywords ()
  "Parse the buffer and return a cons list of (property . value) from lines like: #+PROPERTY: value"
  (org-element-map (org-element-parse-buffer 'element) 'keyword
                   (lambda (keyword) (cons (org-element-property :key keyword)
                                           (org-element-property :value keyword)))))

(defun org-keyword (KEYWORD)
  "Get the value of a KEYWORD in the form of #+KEYWORD: value"
  (cdr (assoc KEYWORD (org-keywords))))
;; Obtaining Values of ~#+KEYWORD~ Annotations:1 ends here

;; [[file:~/.emacs.d/init.org::*Publishing articles to my personal blog][Publishing articles to my personal blog:1]]
(define-key global-map "\C-cb" 'my/publish-to-blog)

(cl-defun my/publish-to-blog (&optional (draft nil) (local nil))
  "
  Using ‘AlBasmala’ setup to publish current article to my blog.
  Details of AlBasmala can be found here:
  https://alhassy.github.io/AlBasmala/

  Locally: ~/alhassy.github.io/content/AlBasmala.org

  A ‘draft’ will be produced in about ~7 seconds, but does not re-produce
  a PDF and the article has a draft marker near the top. Otherwise,
  it will generally take ~30 seconds due to PDF production, which is normal.
  The default is not a draft and it takes ~20 seconds for the live
  github.io page to update.

  The ‘local’ optiona indicates whether the resulting article should be
  viewed using the local server or the live webpage. Live page is default.

  When ‘draft’ and ‘local’ are both set, the resulting page may momentarily
  show a page-not-found error, simply refresh.
  "

  (load-file "~/alhassy.github.io/content/AlBasmala.el")

  ;; --MOVE ME TO ALBASMALA--
  ;; Sometimes the file I'm working with is not a .org file, so:
  (setq file.org (buffer-name))

  (preview-article :draft draft)
  (unless draft (publish))
  (let ((server (if local "http://localhost:4000/" "https://alhassy.github.io/")))
    (async-shell-command (concat "open " server NAME "/") "*blog-post-in-browser*"))
)
;; Publishing articles to my personal blog:1 ends here

;;; lsp-tailwindcss.el --- A lsp-mode client for tailwindcss  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  A.I.

;; Author: A.I. <merrick@luois.me>
;; Keywords: language tools
;; Version: 0.2
;; Package-Requires: ((lsp-mode "7.1") (f "0.20.0") (emacs "26.1"))
;; Keywords: tailwindcss
;; URL: https://github.com/merrickluo/lsp-tailwindcss

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; provide the connection to lsp-mode and tailwindcss language server

;;; Code:
(require 'lsp-mode)

(defgroup lsp-tailwindcss nil
  "Adds lsp-mode support for tailwindcss."
  :group 'lsp-mode)

(defcustom lsp-tailwindcss-add-on-mode t
  "Specify lsp-tailwindcss as add-on so it can work with other language servers."
  :type 'boolean
  :group 'lsp-tailwindcss)

(defcustom lsp-tailwindcss-major-modes '(web-mode html-mode css-mode rjsx-mode typescript-mode typescript-tsx-mode tsx-ts-mode)
  "Major modes that lsp-tailwindcss should activate."
  :type 'list
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

;;; Language server global settings:
(defcustom lsp-tailwindcss-emmet-completions nil
  "Enable completions when using Emmet-style syntax.
For example div.bg-red-500.uppercase."
  :type 'boolean
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-show-pixel-equivalents nil
  "Show px equivalents for rem CSS values in completions and hovers."
  :type 'boolean
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-root-font-size 16
  "Root font size in pixels.
Used to convert rem CSS values to their px equivalents,
 see `lsp-tailwindcss-show-pixel-equivalents'"
  :type 'number
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-validate nil
  "Enable linting.
Rules can be configured individually using the lsp-tailwindcss-lint-* settings:
  ignore: disable lint rule entirely
  warning: rule violations will be considered \"warnings\"
  error: rule violations will be considered \"errors\""
  :type 'boolean
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-hovers nil
  "Enable hovers, default: true."
  :type 'boolean
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.3"))

(defcustom lsp-tailwindcss-suggestions t
  "Enable autocomplete suggestions, default: true."
  :type 'boolean
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.3"))

(defcustom lsp-tailwindcss-code-actions nil
  "Enable code actions, default: true."
  :type 'boolean
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.3"))

(defcustom lsp-tailwindcss-lint-invalid-screen "error"
  "Unknown screen name used with the @screen directive."
  :type '(choice (const "ignore")
          (const "warning")
          (const "error"))
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-lint-invalid-variant "error"
  "Unknown variant name used with the @variants directive."
  :type '(choice (const "ignore")
          (const "warning")
          (const "error"))
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-lint-invalid-tailwind-directive "error"
  "Unknown value used with the @tailwind directive."
  :type '(choice (const "ignore")
          (const "warning")
          (const "error"))
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-lint-invalid-apply "error"
  "Unsupported use of the @apply directive."
  :type '(choice (const "ignore")
          (const "warning")
          (const "error"))
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-lint-invalid-config-path "error"
  "Unknown or invalid path used with the theme helper."
  :type '(choice (const "ignore")
          (const "warning")
          (const "error"))
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-lint-css-conflict "warning"
  "Class names on the same HTML element.
Which apply the same CSS property or properties."
  :type '(choice (const "ignore")
          (const "warning")
          (const "error"))
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-lint-recommended-variant-order "warning"
  "Class variants not in the recommended order (applies in JIT mode only)."
  :type '(choice (const "ignore")
          (const "warning")
          (const "error"))
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.2"))

(defcustom lsp-tailwindcss-class-attributes ["class" "className" "ngClass"]
  "The HTML attributes to provide class completions, hover previews, linting etc."
  :type 'lsp-string-vector
  :group 'lsp-tailwindcss
  :package-version '(lsp-tailwindcss . "0.3"))

(lsp-register-custom-settings
 '(("tailwindCSS.emmetCompletions" lsp-tailwindcss-emmet-completions t)
   ("tailwindCSS.showPixelEquivalents" lsp-tailwindcss-show-pixel-equivalents t)
   ("tailwindCSS.rootFontSize" lsp-tailwindcss-root-font-size)
   ("tailwindCSS.validate" lsp-tailwindcss-validate t)
   ("tailwindCSS.hovers" lsp-tailwindcss-hovers t)
   ("tailwindCSS.suggestions" lsp-tailwindcss-suggestions t)
   ("tailwindCSS.codeActions" lsp-tailwindcss-code-actions t)
   ("tailwindCSS.lint.invalidScreen" lsp-tailwindcss-lint-invalid-screen)
   ("tailwindCSS.lint.invalidVariant" lsp-tailwindcss-lint-invalid-variant)
   ("tailwindCSS.lint.invalidTailwindDirective" lsp-tailwindcss-lint-invalid-tailwind-directive)
   ("tailwindCSS.lint.invalidApply" lsp-tailwindcss-lint-invalid-apply)
   ("tailwindCSS.lint.invalidConfigPath" lsp-tailwindcss-lint-invalid-config-path)
   ("tailwindCSS.lint.cssConflict" lsp-tailwindcss-lint-css-conflict)
   ("tailwindCSS.lint.recommendedVariantOrder" lsp-tailwindcss-lint-recommended-variant-order)
   ("tailwindCSS.classAttributes" lsp-tailwindcss-class-attributes)))
;;; Language server global settings ends here

(lsp-dependency 'tailwindcss-language-server
                '(:system "tailwindcss-language-server")
                '(:npm
                  :package "@tailwindcss/language-server"
                  :path "tailwindcss-language-server"))

(defun lsp-tailwindcss--has-config-file ()
  "Check if there is a tailwindcss config file exists.
To keep it simple and performant,only check for conventional location."
  (or (file-exists-p (f-join (lsp-workspace-root) "tailwind.config.js"))
      (file-exists-p (f-join (lsp-workspace-root) "tailwind.config.ts"))
      (locate-dominating-file (buffer-file-name) "tailwind.config.js")
      (locate-dominating-file (buffer-file-name) "tailwind.config.ts")))

(defun lsp-tailwindcss--activate-p (&rest _args)
  "Check if tailwindcss language server can/should start."
  (message (lsp-workspace-root))
  (and (lsp-workspace-root)
       (apply #'provided-mode-derived-p major-mode lsp-tailwindcss-major-modes)
       (lsp-tailwindcss--has-config-file)))

(defun lsp-tailwindcss--company-dash-hack (workspace)
  "Append - to the lsp completion-trigger-characters.
WORKSPACE: current workspace.
workaround the problem that company-mode completion
not work when typing \"-\" in classname."
  (with-lsp-workspace workspace
    (let* ((caps (lsp--workspace-server-capabilities workspace))
           (comp (lsp:server-capabilities-completion-provider? caps))
           (trigger-chars (append (lsp:completion-options-trigger-characters? comp) nil)))
      (lsp:set-completion-options-trigger-characters?
       comp
       (vconcat
        (cl-pushnew "-" trigger-chars :test #'string=))))))

(defun lsp-tailwindcss--initialization-options ()
  "The tailwindcss-language-server requires configuration not be null."
  (ht ("configuration" (lsp-configuration-section "tailwindcss"))))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection
                   (lambda ()
                     `(,(lsp-package-path 'tailwindcss-language-server) "--stdio")))
  :activation-fn #'lsp-tailwindcss--activate-p
  :server-id 'tailwindcss
  :priority -1
  :add-on? lsp-tailwindcss-add-on-mode
  :initialization-options #'lsp-tailwindcss--initialization-options
  :initialized-fn #'lsp-tailwindcss--company-dash-hack
  :download-server-fn (lambda (_client callback error-callback _update?)
                        (lsp-package-ensure 'tailwindcss-language-server callback error-callback))))

(provide 'lsp-tailwindcss)
;;; lsp-tailwindcss.el ends here

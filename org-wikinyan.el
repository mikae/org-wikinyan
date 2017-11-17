;; org-wikinyan.el --- Wiki-like file for emacs
;;
;; Author: Minae Yui <minae.yui.sain@gmail.com>
;; Version: 0.1
;; URL: todo
;; Keywords:
;; Compatibility:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;; `org-wikinyan' contains two link types:
;;   - [[wiki:path][]] - absolute links.
;;   - [[wikir:path][]] - relative links.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(require 'org)
(require 'ox-html)
(require 'cl-lib)
(require 'f)
(require 's)

;; Constants
(defconst org-wikinyan-sublink-patterns (list "\\\\*\\* %s"
                                              "<<%s>>"))

;; Vars
(defvar org-wikinyan-location "~/wikinyan"
  "Path to wiki")

(defvar org-wikinyan-emacs-path "emacs"
  "Path to Emacs executable. Default value 'emacs'.")

(defvar org-wikinyan-user-init-file
  (concat (f-join user-emacs-directory
                  "init.el"))
  "Path to init.el file used for asynchronous export.")

;; Utils
(define-skeleton org-wikinyan--insert-main-index-header
  "Inserts `org-wikinyan' header"
  "\n"
  "\n")

(define-skeleton org-wikinyan--insert-header
  "Inserts `org-wikinyan' header"
  "\n"
  "Nyyyaaan~~~\n"
  "\n")

(defun org-wikinyan--page->org (pagename &optional relatively)
  "Get filepath of page with PAGENAME.
If RELATIVELY return filepath relative of current org page."
  (concat (f-slash (if relatively
                       (f-dirname buffer-file-name)
                     org-wikinyan-location))
          (replace-regexp-in-string "<|.*|>" "" pagename)
          ".org"))

(defun org-wikinyan--page->html (pagename &optional relatively)
  "Get filepath of page with PAGENAME.
If RELATIVELY return filepath relative of current org page."
  (concat (f-slash (if relatively
                       (f-dirname buffer-file-name)
                     org-wikinyan-location))
          (replace-regexp-in-string "<|.*|>" "" pagename)
          ".html"))

(defun org-wikinyan--page->sublink (pagename)
  "Get sublink of link PAGENAME."
  (or (substring (car (s-match "<|.*|>" pagename)) 2 -2)
      ""))

;; Links
(defun org-wikinyan--follow-sublink (sublink)
  "Follow SUBLINK in current org file."
  (let ((--patterns org-wikinyan-sublink-patterns))
    (while (and --patterns
                (eq (point)
                    (point-min)))
      (goto-char (point-min))
      (re-search-forward (format (car --patterns) sublink) nil :noerror)
      (setq --patterns (cdr --patterns)))))

;; Wiki absolute links relatively of `org-wikinyan-location'
(defun org-wikinyan--follow-absolute (pagename)
  "Follow absolute link."
  (let ((org-wiki-filepath (org-wikinyan--page->org pagename))
        (org-wiki-sublink  (org-wikinyan--page->sublink pagename)))
    (message "follow: \"%s\"" org-wiki-sublink)

    (find-file org-wiki-filepath)
    (if (not (f-exists-p org-wiki-filepath))
        (progn
          (org-wikinyan--insert-header)
          (save-buffer))
      (when (> (length org-wiki-sublink)
               0)
        (org-wikinyan--follow-sublink org-wiki-sublink))
      )))

(defun org-wikinyan--export-absolute (path desc backend)
  "Export absolute link."
  (let ((--path (f-relative (org-wikinyan--page->html path)
                            (f-dirname buffer-file-name))))
    (cl-case backend
      (html
       (format "<a href='%s'>%s</a>"
               --path
               (or desc --path))))))

(defun org-wikinyan--follow-relative (pagename)
  "Follow absolute link."
  (let ((org-wiki-filepath (org-wikinyan--page->org pagename
                                                    :relatively))
        (org-wiki-sublink  (org-wikinyan--page->sublink pagename)))
    (message "follow: \"%s\"" org-wiki-sublink)
    (find-file org-wiki-filepath)
    (if (not (f-exists-p org-wiki-filepath))
        (progn
          (org-wikinyan--insert-header)
          (save-buffer))
      (when (> (length org-wiki-sublink)
               0)
        (org-wikinyan--follow-sublink org-wiki-sublink))
      )))

(defun org-wikinyan--export-relative (path desc backend)
  "Export absolute link."
  (cl-case backend
    (html
     (format "<a href='%s'>%s</a>"
             (org-wikinyan--page->html path :relatively)
             (or desc path)))))

;; Wiki relative links relatively of current location
(eval-after-load 'org
  '(progn
     (org-add-link-type "wikia"
                        #'org-wikinyan--follow-absolute
                        #'org-wikinyan--export-absolute)

     (org-add-link-type "wikir"
                        #'org-wikinyan--follow-relative
                        #'org-wikinyan--export-relative)
     ))

;; Commands
(defun org-wikinyan-open-index ()
  "Opens index file."
  (interactive)
  (unless (f-dir-p org-wikinyan-location)
    (error "org-wikinyan-open-index: `org-wikinyan-location' is not valid: %s"
           org-wikinyan-location))

  (let ((--index-path (f-join org-wikinyan-location
                              "index.org")))
    (find-file --index-path)
    (when (not (f-file-p --index-path))
      (org-wikinyan--insert-main-index-header)
      (save-buffer))))

(defun org-wikinyan-export-html-sync ()
  "Export wiki"
  (interactive)
  (let ((org-html-htmlize-output-type 'css)
        (org-html-htmlize-font-prefix "org-"))
    (org-publish
     `("html"
       :base-directory       ,org-wikinyan-location
       :base-extension       "org"
       :publishing-directory ,org-wikinyan-location
       :publishing-function  org-html-publish-to-html
       :table-of-contents    nil
       :recursive            t)
     t)))

(defun org-wikinyan-export-html ()
  "Export all pages to html.
Note: This function doesn't freeze Emacs since it starts another Emacs process."
  (interactive)
  (compile (mapconcat 'identity
                      `(,org-wikinyan-emacs-path
                        "--batch"
                        "-l" ,org-wikinyan-user-init-file
                        "-f" "org-wikinyan-export-html-sync"
                        "--kill")
                      " ")))

(provide 'org-wikinyan)
;;; org-wikinyan.el ends here

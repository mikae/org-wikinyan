;; test-org-wikinyan.el ---
;;
;; Author: Minae Yui <minae.yui.sain@gmail.com>
;; Version: 0.1
;; URL:
;; Keywords:
;; Compatibility:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;; .
;;
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
(require 'org-wikinyan)

(require 'buttercup)
(require 'f)

(defconst org-wikinyan-unit-test-location (f-dirname load-file-name))

(defconst org-wikinyan-temp-location (f-join org-wikinyan-unit-test-location
                                             "org-wikinyan"))

(describe "org-wikinyan"
  (before-each
    (when (f-dir-p org-wikinyan-temp-location)
      (f-delete org-wikinyan-temp-location :force))

    (f-mkdir org-wikinyan-temp-location)

    (setq org-wikinyan-location
          org-wikinyan-temp-location))

  (after-all
    (when (f-dir-p org-wikinyan-temp-location)
      (f-delete org-wikinyan-temp-location :force)))

  (describe "org-wikinyan-open-index"
    (it "Is an command"
      (expect (commandp 'org-wikinyan-open-index)
              :to-be t))

    (it "Raises an error if `org-wikinyan-location' is not valid path"
      (setq org-wikinyan-location nil)
      (expect (org-wikinyan-open-index)
              :to-throw))

    (it "Creates index page"
      (org-wikinyan-open-index)

      (expect buffer-file-name
              :to-equal (f-join org-wikinyan-location
                                "index.org")))

    (it "Fills it with content"
      (org-wikinyan-open-index)
      (expect (length (buffer-string))
              :not :to-be 0)))
  )

;; Local Variables:
;; eval: (put 'describe    'lisp-indent-function 'defun)
;; eval: (put 'it          'lisp-indent-function 'defun)
;; eval: (put 'before-each 'lisp-indent-function 'defun)
;; eval: (put 'after-each  'lisp-indent-function 'defun)
;; eval: (put 'before-all  'lisp-indent-function 'defun)
;; eval: (put 'after-all   'lisp-indent-function 'defun)
;; End:

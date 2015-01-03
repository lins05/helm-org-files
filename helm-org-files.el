;;; helm-org-files.el --- quickly switch to opened or bookmarked org files

;; this file is not part of Emacs

;; Copyright (C) 2015 Shuai Lin
;; Author: Shuai Lin
;; Maintainer: Shuai Lin
;; Description: quickly switch to opened or bookmarked org files

;; Created: Sun Jan 4 01:45 2015 (+0800)
;; Version: 0.1
;; URL: https://github.com/lins05/helm-org-files
;; Keywords: helm completion convenience org
;; Compatibility:

;;; Installation:

;; 1. install `helm' from github
;;
;; 2. clone the `helm-org-files' repository to "~/.emacs.d/helm-org-files"
;;
;; 3. add to your config
;;
;;      (push "~/.emacs.d/helm-org-files" load-path)
;;      (require 'helm-config)
;;      (require 'helm-org-files)
;;      (global-set-key (kbd "M-o") 'helm-org-files)
;;


;;; Commentary:

;; This package provides a helm source for opened and bookmarked org-mode files.
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
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

;;; Code:


(eval-when-compile (require 'cl))

(require 'helm)
(require 'f)

(defclass helm-source-basic-org-files (helm-source-in-buffer)
   ((init :initform (lambda ()
                      (bookmark-maybe-load-default-file)
                      (helm-init-candidates-in-buffer
                          'global
                        (helm-org-file-collect-org-files)))))
  "A class to define opened org files and bookmarked org files")

(defmethod helm--setup-source :before ((source helm-source-basic-org-files))
    (oset source :action (helm-make-actions
                          "Find file" 'helm-org-files-file-file))
    (oset source :persistent-help "Show this file")
    (oset source :action-transformer '(helm-transform-file-load-el
                                       helm-transform-file-browse-url
                                       helm-transform-file-cache))
    (oset source :candidate-transformer '(helm-skip-boring-files
                                          helm-highlight-files
                                          helm-w32-pathname-transformer)))

(setq helm-source-org-files
  (helm-make-source "Org files" 'helm-source-basic-org-files))

(defun helm-org-files ()
  (interactive)
  (helm :sources helm-source-org-files
        :buffer "*helm org files*"))

(defun helm-org-file-collect-org-files ()
  (let ((fns ()))
    (loop for buf in (buffer-list) do
          (let ((fname (buffer-file-name buf)))
            (when (and fname
                       (string= (or (f-ext fname) "") "org"))
              (push (f-filename fname) fns))))
    (loop for fname in (bookmark-all-names) do
          (when (and (string= (f-ext fname) "org")
                     (not (member fname fns)))
            (push fname fns)))
    fns))


(defun helm-org-files-file-file (name)
  (let ((found nil)
        (pattern (f-base name)))
    (loop for buf in (buffer-list) until found do
          (let ((fname (buffer-file-name buf)))
            (when (and fname
                       (string= (or (f-ext fname) "") "org")
                       (string-match pattern (f-no-ext (f-base fname))))
              (setq found t)
              (switch-to-buffer buf))))
    (unless found
      (loop for fname in (bookmark-all-names) until found do
            (when (and (string= (or (f-ext fname) "") "org")
                       (string-match pattern (f-no-ext (f-base fname))))
              (setq found t)
              (bookmark-jump fname))))))

(provide 'helm-org-files)

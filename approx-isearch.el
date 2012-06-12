;;; approx-isearch.el --- approximate pattern matching library, 曖昧検索ライブラリ

;; Copyright (C) 2004, 2012 Susumu OTA

;; Author: Susumu OTA <susumu.ota at g mail dot com>
;; Keywords: approximate pattern matching, search, isearch

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
          
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
          
;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA


;;; Commentary:
;;
;; `isearch-search-fun-function' が定義されている Emacs 用の isearch
;; カスタマイズ用関数群. `isearch-search-fun-function' を変更すること
;; によって isearch の挙動を変更します.
;;
;; approx-search.el のコメントを参照してください.


;;; Code:

(eval-when-compile
  (require 'cl))

(require 'approx-search)

;;;
;;; parameter
;;;
(defvar approx-isearch-auto-p nil
  "Auto approximate pattern matching mode or not.
non-nil なら通常の search で見つからなかった場合のみ曖昧検索を行う.")

(defun approx-isearch-search-fun ()
  "Return the function to use for the search.
Can be changed via `isearch-search-fun-function' for special needs.
isearch をカスタマイズするための関数. approx-search-{forward,backward} 用."
  (cond (isearch-word
	 (if isearch-forward 'word-search-forward 'word-search-backward))
	(isearch-regexp
	 (if isearch-forward 're-search-forward 're-search-backward))
	(t
	 (if isearch-forward
	     (if approx-isearch-auto-p 'approx-auto-search-forward
	       'approx-search-forward)
	   (if approx-isearch-auto-p 'approx-auto-search-backward
	     'approx-search-backward)))))

(defvar approx-isearch-original-search-fun-function
  (when (boundp 'isearch-search-fun-function)
    isearch-search-fun-function)
  "Original `isearch-search-fun-function' value.
元の値に戻せるように `isearch-search-fun-function' の値を保存しておく.")

;; (setq isearch-search-fun-function #'approx-isearch-search-fun)


;;;
;;; isearch enable/disable
;;;
(defun approx-isearch-enable-p ()
  "Return t if approx-isearch enabled.
曖昧検索を使った isearch が有効か否かを返す."
  (interactive)
  (cond ((eq isearch-search-fun-function #'approx-isearch-search-fun)
	 (message "t")
	 t)
	(t
	 (message "nil")
	 nil)))

(defun approx-isearch-set-enable ()
  "Set approx-isearch enabled.
曖昧検索を使った isearch を有効にする."
  (interactive)
  (setq isearch-search-fun-function #'approx-isearch-search-fun)
  (message "t"))

(defun approx-isearch-set-disable ()
  "Set approx-isearch disabled.
曖昧検索を使った isearch を無効にする."
  (interactive)
  (setq isearch-search-fun-function approx-isearch-original-search-fun-function)
  (message "nil"))

(defun approx-isearch-toggle-enable ()
  "Toggle approx-isearch.
曖昧検索を使った isearch の有効/無効を切り替える."
  (interactive)
  (if (approx-isearch-enable-p)
      (approx-isearch-set-disable)
    (approx-isearch-set-enable)))


(provide 'approx-isearch)

;;; approx-isearch.el ends here

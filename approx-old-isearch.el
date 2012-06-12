;;; approx-old-isearch.el --- approximate pattern matching library, 曖昧検索ライブラリ

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
;; `isearch-search-fun-function' が定義されていない Emacs 用の isearch
;; カスタマイズ用関数群. advice を使って isearch の挙動を変更します.
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


;;;
;;; advice
;;;
(defvar approx-isearch-do-isearch-p nil
  "non-nil なら approx-search を行う. internal variable. 変更不可.")

(defvar approx-isearch-enable-p nil
  "non-nil なら approx-search を行う. internal variable. 変更不可.")

(defadvice isearch-search (around approx-isearch-search disable)
  "Adviced by approx-search."
  (when (approx-isearch-enable-p)
    (setq approx-isearch-do-isearch-p t))
  (unwind-protect
      ad-do-it
    (setq approx-isearch-do-isearch-p nil)))

(defadvice search-forward (around approx-isearch-search-forward disable)
  "Adviced by approx-search."
  (if approx-isearch-do-isearch-p
      (setq ad-return-value
	    (if approx-isearch-auto-p
		(let ((approx-isearch-do-isearch-p nil))
		  (approx-auto-search-forward (ad-get-arg 0)
					      (ad-get-arg 1)
					      (ad-get-arg 2)
					      (ad-get-arg 3)))
	      (approx-search-forward (ad-get-arg 0)
				     (ad-get-arg 1)
				     (ad-get-arg 2)
				     (ad-get-arg 3))))
    ad-do-it))

(defadvice search-backward (around approx-isearch-search-backward disable)
  "Adviced by approx-search."
  (if approx-isearch-do-isearch-p
      (setq ad-return-value
	    (if approx-isearch-auto-p
		(let ((approx-isearch-do-isearch-p nil))
		  (approx-auto-search-backward (ad-get-arg 0)
					       (ad-get-arg 1)
					       (ad-get-arg 2)
					       (ad-get-arg 3)))
	      (approx-search-backward (ad-get-arg 0)
				      (ad-get-arg 1)
				      (ad-get-arg 2)
				      (ad-get-arg 3))))
    ad-do-it))

;;;
;;; isearch enable/disable
;;;
(defun approx-isearch-enable-p ()
  "Return t if approx-isearch enabled.
曖昧検索を使った isearch が有効か否かを返す."
  (interactive)
  (cond (approx-isearch-enable-p
	 (message "t")
	 t)
	(t
	 (message "nil")
	 nil)))

(defun approx-isearch-set-enable ()
  "Set approx-isearch enabled.
曖昧検索を使った isearch を有効にする."
  (interactive)
  (ad-enable-advice 'isearch-search
		    'around
		    'approx-isearch-search)
  (ad-activate 'isearch-search)
  (ad-enable-advice 'search-forward
		    'around
		    'approx-isearch-search-forward)
  (ad-activate 'search-forward)
  (ad-enable-advice 'search-backward
		    'around
		    'approx-isearch-search-backward)
  (ad-activate 'search-backward)
  (setq approx-isearch-enable-p t)
  (message "t"))

(defun approx-isearch-set-disable ()
  "Set approx-isearch disabled.
曖昧検索を使った isearch を無効にする."
  (interactive)
  (ad-disable-advice 'isearch-search
		     'around
		     'approx-isearch-search)
  (ad-activate 'isearch-search)
  (ad-disable-advice 'search-forward
		     'around
		     'approx-isearch-search-forward)
  (ad-activate 'search-forward)
  (ad-disable-advice 'search-backward
		     'around
		     'approx-isearch-search-backward)
  (ad-activate 'search-backward)
  (setq approx-isearch-enable-p nil)
  (message "nil"))

(defun approx-isearch-toggle-enable ()
  "Toggle approx-isearch.
曖昧検索を使った isearch の有効/無効を切り替える."
  (interactive)
  (if (approx-isearch-enable-p)
      (approx-isearch-set-disable)
    (approx-isearch-set-enable)))


(provide 'approx-old-isearch)

;;; approx-old-isearch.el ends here

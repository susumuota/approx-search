;;; approx-isearch.el --- approximate pattern matching library, ۣ�渡���饤�֥��

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
;; `isearch-search-fun-function' ���������Ƥ��� Emacs �Ѥ� isearch
;; �������ޥ����Ѵؿ���. `isearch-search-fun-function' ���ѹ����뤳��
;; �ˤ�ä� isearch �ε�ư���ѹ����ޤ�.
;;
;; approx-search.el �Υ����Ȥ򻲾Ȥ��Ƥ�������.


;;; Code:

(eval-when-compile
  (require 'cl))

(require 'approx-search)

;;;
;;; parameter
;;;
(defvar approx-isearch-auto-p nil
  "Auto approximate pattern matching mode or not.
non-nil �ʤ��̾�� search �Ǹ��Ĥ���ʤ��ä����Τ�ۣ�渡����Ԥ�.")

(defun approx-isearch-search-fun ()
  "Return the function to use for the search.
Can be changed via `isearch-search-fun-function' for special needs.
isearch �򥫥����ޥ������뤿��δؿ�. approx-search-{forward,backward} ��."
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
�����ͤ��᤻��褦�� `isearch-search-fun-function' ���ͤ���¸���Ƥ���.")

;; (setq isearch-search-fun-function #'approx-isearch-search-fun)


;;;
;;; isearch enable/disable
;;;
(defun approx-isearch-enable-p ()
  "Return t if approx-isearch enabled.
ۣ�渡����Ȥä� isearch ��ͭ�����ݤ����֤�."
  (interactive)
  (cond ((eq isearch-search-fun-function #'approx-isearch-search-fun)
	 (message "t")
	 t)
	(t
	 (message "nil")
	 nil)))

(defun approx-isearch-set-enable ()
  "Set approx-isearch enabled.
ۣ�渡����Ȥä� isearch ��ͭ���ˤ���."
  (interactive)
  (setq isearch-search-fun-function #'approx-isearch-search-fun)
  (message "t"))

(defun approx-isearch-set-disable ()
  "Set approx-isearch disabled.
ۣ�渡����Ȥä� isearch ��̵���ˤ���."
  (interactive)
  (setq isearch-search-fun-function approx-isearch-original-search-fun-function)
  (message "nil"))

(defun approx-isearch-toggle-enable ()
  "Toggle approx-isearch.
ۣ�渡����Ȥä� isearch ��ͭ��/̵�����ڤ��ؤ���."
  (interactive)
  (if (approx-isearch-enable-p)
      (approx-isearch-set-disable)
    (approx-isearch-set-enable)))


(provide 'approx-isearch)

;;; approx-isearch.el ends here
